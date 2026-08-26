# Topic 09: Namespaces & Cross-Namespace Communication

## 1. What are Namespaces?
In Kubernetes, **Namespaces** provide a mechanism for isolating groups of resources within a single cluster. They act as virtual clusters dividing cluster resources between multiple users, teams, or environments (e.g., `dev`, `staging`, `prod`).

```
+-----------------------------------------------------------------------------------+
| Kubernetes Cluster                                                                |
|                                                                                   |
|  +-------------------------------+     +-------------------------------+          |
|  | Namespace: dev                |     | Namespace: prod               |          |
|  |                               |     |                               |          |
|  | [ Pod: color-api ]            |     | [ Pod: color-api ]            |          |
|  | [ Service: color-api-svc ]    |     | [ Service: color-api-svc ]    |          |
|  +-------------------------------+     +-------------------------------+          |
|                                                                                   |
|  +-------------------------------+     +-------------------------------+          |
|  | Namespace: default            |     | Namespace: kube-system        |          |
|  | [ Pod: traffic-generator ]    |     | [ CoreDNS, kube-proxy, etc. ] |          |
|  +-------------------------------+     +-------------------------------+          |
+-----------------------------------------------------------------------------------+
```

---

## 2. Resource Scoping: Namespaced vs. Cluster-Scoped

| Category | Description | Examples |
| :--- | :--- | :--- |
| **Namespaced Resources** | Resources isolated within a specific namespace. Names must be unique within the namespace. | `Pod`, `Service`, `Deployment`, `ReplicaSet`, `ConfigMap`, `Secret`, `ResourceQuota`, `PersistentVolumeClaim` |
| **Cluster-Scoped Resources** | Global resources accessible across the entire cluster without namespace boundary. | `Node`, `Namespace`, `PersistentVolume`, `StorageClass`, `ClusterRole`, `ClusterRoleBinding` |

To list all namespaced resource types:
```bash
kubectl api-resources --namespaced=true
```
To list all cluster-scoped resource types:
```bash
kubectl api-resources --namespaced=false
```

---

## 3. Cross-Namespace DNS & Communication (CoreDNS)

Kubernetes automatically configures CoreDNS to resolve namespaced services. Every Service receives a Fully Qualified Domain Name (FQDN) using the following format:

$$\text{\`<service-name>.<namespace>.svc.cluster.local\`}$$

### DNS Resolution Rules:
1. **Same Namespace Communication:**
   Pods within the same namespace can connect using just the Service name:
   ```bash
   curl http://color-api-svc:80
   ```
2. **Cross-Namespace Communication:**
   Pods in another namespace (e.g., `default` namespace connecting to `dev` namespace) must specify the namespace or full FQDN:
   ```bash
   # Short cross-namespace syntax:
   curl http://color-api-svc.dev:80

   # Full FQDN syntax:
   curl http://color-api-svc.dev.svc.cluster.local:80/api
   ```

---

## 4. Practical Example & Manifests

### A. Defining a Namespace (`dev-ns.yaml`)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

### B. Deploying Resources into a Namespace (`color-api.yaml`)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: color-api
  namespace: dev # Explicitly target the dev namespace
  labels:
    app: color-api
spec:
  containers:
  - name: color-api
    image: ultrainstinct21/color-api:1.1.0
    ports:
    - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: color-api-svc
  namespace: dev
spec:
  type: ClusterIP
  selector:
    app: color-api
  ports:
  - port: 80
    targetPort: 80
```

### C. Accessing Cross-Namespace Service from `default` Namespace (`traffic-gen.yaml`)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: traffic-generator
  labels:
    app: traffic-generator
spec:
  containers:
  - name: traffic-generator
    image: lmacademy/traffic-generator:1.0.0
    args:
      # Cross-namespace target URL: <service>.<namespace>.svc.cluster.local
      - 'color-api-svc.dev.svc.cluster.local/api'
      - '1' # delay interval in seconds
```

---

## 5. Namespace CLI Management Commands

```bash
# 1. List all namespaces in the cluster
kubectl get namespaces
kubectl get ns

# 2. Create a namespace via CLI
kubectl create namespace staging

# 3. Switch default CLI context to a specific namespace
kubectl config set-context --current --namespace=dev

# 4. View current active namespace in CLI context
kubectl config view --minify --output 'jsonpath={..namespace}'

# 5. Get resources in a specific namespace
kubectl get pods -n dev
kubectl get svc --namespace=dev

# 6. Get resources across ALL namespaces
kubectl get pods -A
kubectl get pods --all-namespaces

# 7. Delete a namespace and ALL resources contained within it
kubectl delete namespace dev
```
