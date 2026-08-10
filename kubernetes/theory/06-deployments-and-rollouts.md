# Topic 06: Deployments, Rollouts & Rollbacks

## 1. Why Deployments?
While ReplicaSets ensure high availability and replica counts, they **do not support declarative rolling updates** when you update container images or configurations.

A **Deployment** is a higher-level abstraction that sits on top of ReplicaSets:
- A Deployment creates and manages **ReplicaSets**.
- A ReplicaSet creates and manages **Pods**.

```
[ Deployment (nginx-dep) ]
           |
           +---> [ Old ReplicaSet (v1 - replicas: 0) ]
           |
           +---> [ New ReplicaSet (v2 - replicas: 3) ]
                           |
                           +---> [ Pod 1 (v2) ]
                           +---> [ Pod 2 (v2) ]
                           +---> [ Pod 3 (v2) ]
```

---

## 2. Deployment Deployment Strategies

### A. `RollingUpdate` (Default & Zero-Downtime)
Gradually replaces old Pods with new ones, ensuring continuous application availability.

- `maxSurge`: Maximum number/percentage of extra Pods created above desired replicas during rollout (e.g. `25%` or `1`).
- `maxUnavailable`: Maximum number/percentage of Pods that can be unavailable during rollout (e.g. `25%` or `0` for strict zero-downtime).

### B. `Recreate`
Terminates all existing Pods simultaneously before creating new Pods. Incurs temporary application downtime, but guarantees no two versions run at the same time.

---

## 3. Declarative Deployment Manifest (`nginx-dep.yaml`)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-dep
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: web-server
  template:
    metadata:
      labels:
        app: web-server
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
```

---

## 4. Rollout Management & Rollback CLI Commands

```bash
# 1. Check current rollout status in real-time
kubectl rollout status deployment/nginx-dep

# 2. View rollout revision history
kubectl rollout history deployment/nginx-dep

# 3. Update container image to trigger a new rollout revision
kubectl set image deployment/nginx-dep nginx=nginx:1.28-alpine --record

# 4. Pause and Resume a rollout (for canary testing / batch updates)
kubectl rollout pause deployment/nginx-dep
kubectl rollout resume deployment/nginx-dep

# 5. Undo and rollback to the previous working revision
kubectl rollout undo deployment/nginx-dep

# 6. Rollback to a specific revision from history
kubectl rollout undo deployment/nginx-dep --to-revision=2

# 7. Restart all pods in a deployment (recreates pods rolling without config change)
kubectl rollout restart deployment/nginx-dep
```
