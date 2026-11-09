# Topic 11: Kubernetes Health Probes (Liveness, Readiness & Startup)

## 1. Why Health Probes?

Containers can fail in subtle ways: an application may start but be stuck in a
deadlock, it may be alive but not yet ready to serve requests, or it may be slow
to boot. Without probes, Kubernetes assumes a container is healthy simply because
its process is running — which is not enough for production workloads.

**Kubernetes Probes** are diagnostic checks performed by the `kubelet` on a
container to determine its health and traffic eligibility. There are three probe
types, each serving a distinct purpose:

| Probe | Question It Answers | Failure Consequence | Best For |
| :--- | :--- | :--- | :--- |
| **Startup Probe** | Has the application finished starting up? | Delays all other probes until success | Slow-starting apps (legacy, large JVMs) |
| **Liveness Probe** | Is the application alive and healthy? | Container is **restarted** (killed + recreated) | Deadlocks, crashes, unrecoverable state |
| **Readiness Probe** | Is the application ready to serve traffic? | Pod removed from **Service Endpoints** (no traffic) | Warm-up, loading caches, dependency checks |

```
                 Kubelet Probe Flow (per container)
+--------------------------------------------------------------------------+
|                                                                          |
|  Container starts                                                       |
|         |                                                                |
|         v                                                                |
|  +--------------------------+                                            |
|  |   STARTUP PROBE          |  (running until first success)            |
|  |  path: /up               |                                            |
|  +-----------+-------------+                                            |
|          Success                                                   |
|         / \                                                         |
|        Yes  No  (keeps checking; Liveness & Readiness blocked)      |
|         |                                                           |
|         v                                                           |
|  +--------------------------+                                       |
|  |   LIVENESS PROBE         |  (periodic, e.g. every 5s)            |
|  |  path: /health           |  Failure -> Container RESTART         |
|  +-----------+-------------+                                       |
|          Success                                                   |
|         / \                                                        |
|        Yes  No  -> kubelet kills container, restart policy applies  |
|         |                                                          |
|         v                                                          |
|  +--------------------------+                                       |
|  |   READINESS PROBE        |  (periodic, e.g. every 5s)            |
|  |  path: /ready            |  Failure -> Pod removed from Endpoints|
|  +-----------+-------------+                                       |
|          Success                                                   |
|         / \                                                        |
|        Yes  No  -> Pod still runs, but receives NO traffic         |
|         |                                                          |
|         v                                                          |
|     Pod is Healthy + Ready -> Receives traffic via Service         |
|                                                                          |
+--------------------------------------------------------------------------+
```

## 2. Probe Configuration Fields

Probes are configured at the **container level** (`spec.template.spec.containers[]`):

```yaml
      livenessProbe:
        httpGet:
          path: /health        # HTTP endpoint to check
          port: 80
        initialDelaySeconds: 5 # Wait before first probe (app needs to boot)
        periodSeconds: 5       # How often to probe
        failureThreshold: 3    # Consecutive failures before marking unhealthy
        timeoutSeconds: 1      # Time to wait for a response
```

| Field | Purpose |
| :--- | :--- |
| `httpGet.path` / `port` | HTTP endpoint the kubelet calls |
| `initialDelaySeconds` | Grace period before probing begins |
| `periodSeconds` | Frequency of the probe |
| `failureThreshold` | Number of consecutive failures to trigger action |
| `timeoutSeconds` | Max time to wait for probe response |

> [!IMPORTANT]
> **Probes live inside the container spec**, NOT at the Pod or Deployment spec
> level. Placing `livenessProbe`/`readinessProbe`/`startupProbe` under
> `spec.template.spec` (instead of inside `containers[]`) will cause Kubernetes
> to ignore them or reject the manifest!

## 3. Probe Types (Probe Handlers)

A probe can check health in one of three ways:

### A. HTTP Get (`httpGet`)
Calls an HTTP endpoint. Status codes `200-399` mean success.
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
```

### B. Container Exec (`exec`)
Runs a command inside the container. Exit code `0` means success.
```yaml
livenessProbe:
  exec:
    command: ["cat", "/tmp/healthy"]
```

### C. TCP Socket (`tcpSocket`)
Attempts to open a TCP connection to a port. Success if connection established.
```yaml
livenessProbe:
  tcpSocket:
    port: 3306
```

## 4. Hands-On Manifests

| Manifest | What It Demonstrates | Directory |
| :--- | :--- | :--- |
| `color-api-pod.yaml` | Startup + Liveness probes (commented out, enable one at a time) | `kubernetes/health-probes/` |
| `color-api-depl.yaml` | Readiness Probe with 6 replicas + Startup Probe | `kubernetes/health-probes/readiness-probe/` |
| `color-api-svc.yaml` | Service whose Endpoints reflect readiness | `kubernetes/health-probes/readiness-probe/` |
| `traffic-gen.yaml` | Traffic generator to observe load balancing | `kubernetes/health-probes/readiness-probe/` |

## 5. The Demo Microservice (`color-api`)

The `color-api` Express app exposes the probe endpoints used by these manifests:

| Endpoint | Role | Behavior |
| :--- | :--- | :--- |
| `GET /health` | **Liveness** | Returns `200 ok`; returns `503` if `FAIL_LIVENESS=true` |
| `GET /ready`  | **Readiness** | Returns `200 ok`; returns `503 (~50%)` if `FAIL_READINESS=true` |
| `GET /up`     | **Startup** | Always returns `200 ok` |

Environment variables control failure simulation:

| Variable | Meaning |
| :--- | :--- |
| `FAIL_LIVENESS=true` | Liveness probe fails -> container is restarted |
| `FAIL_READINESS=true` | Readiness probe fails -> Pod removed from Service Endpoints |
| `DELAY_STARTUP=true` | Blocks startup for 60s -> illustrates Startup Probe delay |

## 6. Lifecycle Failure Scenarios

### Scenario A: Liveness Failure (Deadlock)
- `FAIL_LIVENESS=true` → `/health` returns `503`
- Kubelet marks container unhealthy after `failureThreshold` consecutive failures
- **Result:** Container is killed and restarted (restart policy applies); you may see `CrashLoopBackOff`

### Scenario B: Readiness Failure (Warm-up / Overload)
- `FAIL_READINESS=true` → `/ready` returns `503` intermittently
- Pod stays **Running** but is removed from `color-api-svc` Endpoints
- **Result:** Traffic-gen only reaches Ready Pods; `kubectl get endpoints color-api-svc` shrinks

### Scenario C: Slow Startup
- `DELAY_STARTUP=true` → app blocks for 60s before listening
- Without a Startup Probe, Liveness Probe would kill the container during boot
- With a Startup Probe (`/up`), all other probes are delayed until startup completes

## 7. Probe CLI Commands

```bash
# 1. Apply the full health-probe demo stack
kubectl apply -f kubernetes/health-probes/color-api-pod.yaml
kubectl apply -f kubernetes/health-probes/readiness-probe/color-api-depl.yaml
kubectl apply -f kubernetes/health-probes/readiness-probe/color-api-svc.yaml
kubectl apply -f kubernetes/health-probes/readiness-probe/traffic-gen.yaml

# 2. Watch Pod readiness states in real time
kubectl get pods -l app=color-api-deployment -w

# 3. Inspect Endpoints — unready Pods disappear automatically
kubectl get endpoints color-api-svc

# 4. Describe a Pod to see probe events, restarts, and state
kubectl describe pod color-api-pod
kubectl describe pod <color-api-deployment-pod>

# 5. Stream traffic-generator logs to see which backends receive traffic
kubectl logs -f traffic-gen

# 6. Port-forward the Service and test load balancing
kubectl port-forward svc/color-api-svc 8080:80
curl http://localhost:8080/api

# 7. Restart count and probe failures
kubectl get pods -o wide
kubectl top pods   # requires metrics-server
```

## 8. Quick Reference: Choosing the Right Probe

| Situation | Recommended Probe | Action on Failure |
| :--- | :--- | :--- |
| App takes long to boot; avoid premature kills | **Startup Probe** | Delays Liveness/Readiness until ready |
| App deadlocks; needs automatic restart | **Liveness Probe** | Restart the container |
| App is up but not yet serving traffic | **Readiness Probe** | Remove Pod from Service Endpoints |
