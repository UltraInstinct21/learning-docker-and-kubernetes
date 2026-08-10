# Topic 05: ReplicaSets & Pod Adoption

## 1. What is a ReplicaSet?
A **ReplicaSet (RS)** is a controller whose primary responsibility is to maintain a stable, specified number of running Pod replicas at all times.

- If a Pod crashes or its worker node fails, the ReplicaSet controller detects the discrepancy and automatically spawns a replacement Pod on a healthy node (**Self-Healing**).
- If extra Pods are manually created that match the selector, the ReplicaSet terminates the surplus Pods.

---

## 2. Anatomy of a ReplicaSet Manifest (`nginx-rs.yaml`)

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
spec:
  replicas: 3
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
          image: nginx:alpine
          ports:
            - containerPort: 80
```

> **CRITICAL RULE**: The labels defined in `spec.template.metadata.labels` **MUST** match the labels defined in `spec.selector.matchLabels`. If they do not match, the API server rejects the manifest with a validation error.

---

## 3. The Pod Adoption Mechanism
ReplicaSets do not only manage Pods that they created; they acquire ownership of **ANY existing unowned Pod** in the namespace whose labels match `spec.selector.matchLabels`.

```
1. Standalone Pod exists:
   [ nginx-standalone ] (Labels: app=web-server, Owner: None)

2. Apply ReplicaSet (replicas: 3, selector: app=web-server):
   ReplicaSet Controller checks: "How many pods match 'app=web-server'?"
   Count = 1 (nginx-standalone)
   
3. ReplicaSet ADOPTS nginx-standalone (sets metadata.ownerReferences).
   ReplicaSet needs 3 total, so it spawns only 2 new pods!
   Total running = 3.
```

---

## 4. ReplicaSet Scaling & Management CLI Commands

```bash
# 1. List replica sets
kubectl get rs

# 2. View detailed replica set status and events
kubectl describe rs nginx-rs

# 3. Imperative scaling of replicas
kubectl scale rs nginx-rs --replicas=5

# 4. Delete ReplicaSet and all its managed Pods (Cascading deletion - default)
kubectl delete rs nginx-rs

# 5. Delete ReplicaSet while leaving Pods running (Orphan deletion)
kubectl delete rs nginx-rs --cascade=orphan
```
