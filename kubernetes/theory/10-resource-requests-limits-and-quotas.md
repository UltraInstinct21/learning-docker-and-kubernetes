# Topic 10: Resource Requests, Limits & ResourceQuotas

## 1. Why Resource Management?
In a shared Kubernetes cluster, applications compete for physical Node hardware (CPU and RAM). Without constraints:
- A single misbehaving application can consume all Node memory and crash adjacent Pods (No noisy neighbors!).
- The Kubernetes Scheduler cannot effectively place Pods without knowing their resource requirements.

```
+-----------------------------------------------------------------------------------+
| Node Hardware Capacity: 4 CPU Cores / 16Gi RAM                                    |
|                                                                                   |
|  +---------------------------+       +---------------------------+                |
|  | Pod A (Guaranteed)        |       | Pod B (Burstable)         |                |
|  | Request: 1 CPU, 2Gi RAM   |       | Request: 500m CPU, 1Gi    |                |
|  | Limit:   1 CPU, 2Gi RAM   |       | Limit:   2 CPU, 4Gi RAM   |                |
|  +---------------------------+       +---------------------------+                |
+-----------------------------------------------------------------------------------+
```

---

## 2. Container Requests vs. Limits

### A. Resource Requests (`spec.containers[].resources.requests`)
- **Purpose:** Minimum guaranteed resource allocation for the container.
- **Scheduling Impact:** The Kubernetes Scheduler uses `requests` to decide which Node has enough unallocated capacity to fit the Pod.
- **Units:**
  - **CPU:** Expressed in cores or millicores (`1` = 1 vCPU/core = `1000m`, `500m` = 0.5 CPU).
  - **Memory:** Expressed in bytes/binary SI units (`128Mi`, `256Mi`, `1Gi`, `2Gi`).

### B. Resource Limits (`spec.containers[].resources.limits`)
- **Purpose:** Hard upper limit on resources a container is permitted to consume.
- **Enforcement:**
  - **CPU Limit Exceeded:** Container is **throttled** (CPU clock time restricted via cgroups).
  - **Memory Limit Exceeded:** Container is terminated by the kernel with **`OOMKilled`** (Out Of Memory) status and restarted by Kubernetes.

---

## 3. Pod Quality of Service (QoS) Classes

Kubernetes automatically assigns a QoS class to every Pod based on its resource definitions:

| QoS Class | Condition | Eviction Priority |
| :--- | :--- | :--- |
| **`Guaranteed`** | Every container has CPU & Memory `requests` AND `limits` set explicitly, and `requests == limits`. | Lowest (Last to be evicted) |
| **`Burstable`** | At least one container has a request or limit set, but `requests != limits`. | Medium |
| **`BestEffort`** | No requests or limits are set for any container. | Highest (First to be killed under node pressure) |

---

## 4. Namespace ResourceQuotas (`kind: ResourceQuota`)

A **ResourceQuota** enforces aggregate resource consumption limits across an entire namespace.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    pods: "10"
    requests.cpu: "1"      # Total aggregate CPU requests across all pods <= 1 Core (1000m)
    requests.memory: "1Gi"  # Total aggregate RAM requests <= 1 GiB
    limits.cpu: "2"        # Total aggregate CPU limits <= 2 Cores
    limits.memory: "2Gi"   # Total aggregate RAM limits <= 2 GiB
```

> [!IMPORTANT]
> **Quota Enforcement Rule:** Once a `ResourceQuota` is applied to a namespace, **every Pod created in that namespace MUST explicitly specify resource requests and limits** (or have default limits injected via a `LimitRange`). Any Pod manifest missing resource specs will be rejected by the API server with a `Forbidden` error!

---

## 5. Deployment Scaling & Quota Math

When deploying a Deployment (e.g. 4 replicas) into a quota-restricted namespace:

$$\text{Total Requested CPU} = \text{replicas} \times \text{request.cpu per pod}$$

**Example Math (`color-api-depl.yaml`):**
- Deployment Replicas: `4`
- Pod Request: `cpu: 200m`, `memory: 256Mi`
- Total Deployment Request: $4 \times 200\text{m} = 800\text{m}$ CPU ($0.8$ core) and $4 \times 256\text{Mi} = 1024\text{Mi}$ RAM ($1\text{Gi}$).
- Namespace Quota: `requests.cpu: 1` ($1000\text{m}$), `requests.memory: 1Gi`.
- **Result:** $800\text{m} \le 1000\text{m}$ and $1\text{Gi} \le 1\text{Gi}$. All 4 pods pass quota validation!

If replicas were scaled to 6 ($6 \times 200\text{m} = 1200\text{m}$ CPU), the quota would be exceeded, and Kubernetes would refuse to schedule the extra Pods.

---

## 6. Resource Quota CLI Commands

```bash
# 1. View ResourceQuotas in a namespace
kubectl get resourcequota -n dev
kubectl get quota -n dev

# 2. Inspect detailed quota usage vs hard limits
kubectl describe resourcequota dev-quota -n dev

# 3. View real-time CPU and Memory consumption of Pods (requires metrics-server)
kubectl top pods -n dev
kubectl top pods --containers -n dev

# 4. View real-time Node resource usage
kubectl top nodes
```
