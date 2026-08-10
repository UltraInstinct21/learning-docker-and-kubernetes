# Topic 01: Kubernetes Introduction & Architecture

## 1. What is Kubernetes (K8s)?
**Kubernetes** is an open-source container orchestration system for automating application deployment, scaling, management, and self-healing.

### Key Capabilities:
- **Self-Healing**: Automatically restarts failed containers, reschedules them when nodes die, and replaces unresponsive instances.
- **Auto-Scaling**: Scales applications up or down horizontally based on CPU/RAM usage or custom metrics.
- **Service Discovery & Load Balancing**: Assigns single IP/DNS names to sets of containers and balances incoming traffic across them.
- **Automated Rollouts & Rollbacks**: Seamlessly rolls out new application versions with zero downtime and rolls back if health checks fail.

---

## 2. Kubernetes Cluster Architecture

A Kubernetes cluster consists of two main layers: **Control Plane (Master Node)** and **Worker Nodes**.

```
+-------------------------------------------------------------------------------+
|                             CONTROL PLANE (Master)                            |
|                                                                               |
|   +---------------+      +------------------+      +---------------------+    |
|   |  kube-apiserver | <--> |   etcd Storage   |      |   kube-scheduler    |    |
|   +---------------+      +------------------+      +---------------------+    |
|           ^                                                   |               |
|           |              +--------------------------+         |               |
|           +------------> | kube-controller-manager  | <-------+               |
|                          +--------------------------+                         |
+---------------------------------------+---------------------------------------+
                                        |
                 Communication via HTTPS (Port 6443)
                                        |
+---------------------------------------v---------------------------------------+
|                                WORKER NODES                                   |
|                                                                               |
|   +--------------------------------+     +--------------------------------+   |
|   |          Worker Node 1         |     |          Worker Node 2         |   |
|   |  +--------------------------+  |     |  +--------------------------+  |   |
|   |  |         kubelet          |  |     |  |         kubelet          |  |   |
|   |  +--------------------------+  |     |  +--------------------------+  |   |
|   |  +--------------------------+  |     |  +--------------------------+  |   |
|   |  |        kube-proxy        |  |     |  |        kube-proxy        |  |   |
|   |  +--------------------------+  |     |  +--------------------------+  |   |
|   |  +--------------------------+  |     |  +--------------------------+  |   |
|   |  | Container Runtime (CRI)  |  |     |  | Container Runtime (CRI)  |  |   |
|   |  +--------------------------+  |     |  +--------------------------+  |   |
|   |  [ Pod 1 ] [ Pod 2 ] [ Pod 3]  |     |  [ Pod 4 ] [ Pod 5 ] [ Pod 6]  |   |
|   +--------------------------------+     +--------------------------------+   |
+-------------------------------------------------------------------------------+
```

---

## 3. Control Plane Components

1. **`kube-apiserver`**:
   - The central front-end of the control plane.
   - Exposes the Kubernetes API (REST) and validates/configures data for all objects (Pods, Services, Deployments).
2. **`etcd`**:
   - Highly available, distributed key-value store.
   - Holds the complete state and configuration of the cluster (Single Source of Truth).
3. **`kube-scheduler`**:
   - Watches for newly created Pods that have no assigned Node.
   - Selects the best target Node for them based on resource requirements, taints/tolerations, node affinity, and workloads.
4. **`kube-controller-manager`**:
   - Runs background controller reconciliation loops.
   - Includes: Node Controller, ReplicaSet/Deployment Controller, EndpointSlice Controller, ServiceAccount Controller.

---

## 4. Worker Node Components

1. **`kubelet`**:
   - Primary agent running on each worker node.
   - Communicates with the API server, ensures containers described in PodSpecs are running and healthy.
2. **`kube-proxy`**:
   - Network proxy maintaining network rules (iptables / IPVS) on each node.
   - Translates Service ClusterIPs to individual backend Pod IPs for load balancing.
3. **Container Runtime (CRI)**:
   - The underlying software responsible for running containers (e.g. `containerd`, `CRI-O`).

---

## 5. Useful Cluster Inspection CLI Commands

```bash
# Check cluster connection & API status
kubectl cluster-info

# View all nodes in the cluster
kubectl get nodes -o wide

# Inspect detailed node resource capacity and conditions
kubectl describe node <node-name>

# View all control plane pods (in kube-system namespace)
kubectl get pods -n kube-system
```
