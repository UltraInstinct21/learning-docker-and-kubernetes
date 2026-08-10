# Topic 04: Labels, Annotations & Selectors

## 1. Labels vs. Annotations

Both Labels and Annotations are key-value metadata attached to Kubernetes objects, but they serve fundamentally different purposes:

| Metadata Type | Purpose | Queryable via Selectors? | Typical Examples |
| :--- | :--- | :--- | :--- |
| **Labels** | Identifying and grouping objects into subsets. | **Yes** (`kubectl get -l`) | `app: color-api`, `env: production`, `tier: backend`, `version: v1` |
| **Annotations** | Attaching non-identifying metadata for tools & controllers. | **No** | Build git commit SHA, build timestamps, ingress controller configs (`nginx.ingress.kubernetes.io/rewrite-target`) |

---

## 2. Selectors: Equality-Based vs. Set-Based

Kubernetes uses **Selectors** to dynamically bind Services, Deployments, and ReplicaSets to matching Pods.

### A. Equality-Based Requirements (`=`, `==`, `!=`)
Matches objects where the key equals or does not equal a single specific value.

```yaml
# Used in Services and simple Pod manifests
selector:
  app: color-api
  tier: backend
```

### B. Set-Based Requirements (`In`, `NotIn`, `Exists`, `DoesNotExist`)
Allows filtering by a set of values or checking key existence.

```yaml
# Used in Deployments, ReplicaSets, Job controllers (matchExpressions)
selector:
  matchExpressions:
    - key: environment
      operator: In
      values: ["staging", "production"]
    - key: tier
      operator: NotIn
      values: ["legacy"]
    - key: canary
      operator: Exists
```

---

## 3. Combining `matchLabels` and `matchExpressions`

In workload controllers (Deployments, ReplicaSets), you can combine both. All conditions are evaluated with a logical **AND**:

```yaml
spec:
  selector:
    matchLabels:
      app: color-api
    matchExpressions:
      - key: environment
        operator: In
        values: [production, staging]
```

---

## 4. Querying Labels via CLI Cheatsheet

```bash
# 1. Show all labels attached to pods
kubectl get pods --show-labels

# 2. Add custom columns for specific label keys in output
kubectl get pods -L app,environment,tier

# 3. Filter pods using equality selector (-l)
kubectl get pods -l app=color-api

# 4. Filter pods using inequality selector
kubectl get pods -l environment!=production

# 5. Filter pods using set-based selector
kubectl get pods -l 'environment in (staging, production)'
kubectl get pods -l 'tier notin (frontend)'

# 6. Filter pods by label key existence
kubectl get pods -l 'canary'

# 7. Add or update a label on an existing live pod
kubectl label pod color-api-1 environment=production --overwrite

# 8. Remove a label from a pod (append hyphen -)
kubectl label pod color-api-1 environment-
```
