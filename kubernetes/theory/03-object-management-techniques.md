# Topic 03: Kubernetes Object Management Techniques

## 1. The Three Object Management Approaches

Kubernetes objects can be created, updated, and deleted using three different techniques:

| Technique | Description | Pros | Cons | Best For |
| :--- | :--- | :--- | :--- | :--- |
| **Imperative Commands** | Direct CLI action verbs (`run`, `create`, `delete`, `scale`). | Fast, single-line, great for quick debugging. | No audit trail, not reproducible in Git. | Development & quick one-off testing. |
| **Imperative Object Config** | Commands targeting specific files (`create -f`, `replace -f`). | Config stored in YAML, version controllable. | `replace` fails if object changed; rigid. | Small projects with single admin. |
| **Declarative Object Config** | `kubectl apply -f <dir/file>` (Desired State). | Automatic 3-way merge, idempotency, GitOps ready. | Complex to debug merge conflicts. | **Production standard (Industry Best Practice)**. |

---

## 2. Declarative Management & The 3-Way Merge

When you run `kubectl apply -f manifest.yaml`, Kubernetes performs a **3-way merge calculation** between:
1. **Local Configuration**: The YAML file on your machine.
2. **Live Configuration**: The current state stored inside the cluster (`etcd`).
3. **Last-Applied-Configuration**: Stored as an annotation (`kubectl.kubernetes.io/last-applied-configuration`) on the live object.

This allows Kubernetes to determine which fields were added, modified, or deleted without overwriting fields dynamically set by the cluster (e.g. status, clusterIPs, default values).

```
   Local YAML Config               Live Cluster State
  +-------------------+          +-------------------+
  | replicas: 3       |          | replicas: 2       |
  | image: nginx:1.26 |          | image: nginx:1.25 |
  +---------+---------+          +---------+---------+
            \                           /
             \                         /
              v                       v
          +-------------------------------+
          | Last-Applied-Configuration    |
          | (Annotation on object)        |
          +---------------+---------------+
                          |
                          v
               Calculated 3-Way Patch
               - Update replicas -> 3
               - Update image -> nginx:1.26
```

---

## 3. Multi-Resource Declarative Manifests (`---`)

Multiple Kubernetes resources (e.g., a Deployment, a Service, and a ConfigMap) can be declared in a single YAML file separated by triple dashes (`---`):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-server
  ports:
    - port: 80
      targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
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
        - name: web
          image: nginx:alpine
```

---

## 4. Useful Declarative CLI Commands

```bash
# Apply a single manifest
kubectl apply -f nginx.yaml

# Apply all manifests in a directory
kubectl apply -f ./manifests/

# Apply manifests recursively across subdirectories
kubectl apply -R -f ./k8s/

# Preview changes without applying (Diff check)
kubectl diff -f nginx.yaml

# Delete all resources defined in a manifest
kubectl delete -f nginx.yaml
```
