# Topic 02: Running Containers & Pod Management

## 1. What is a Pod?
A **Pod** is the smallest deployable and manageable computing unit in Kubernetes.

- A Pod encapsulates **one or more tightly coupled containers** that share:
  1. **Network Namespace**: Same IP address, port space, and localhost interface (`127.0.0.1`).
  2. **Storage Volumes**: Shared filesystem volumes mounted into each container.
  3. **Lifecycle**: Scheduled together on the exact same worker node.

```
+-------------------------------------------------------------+
|                            POD                              |
|  Pod IP: 10.244.1.45                                        |
|                                                             |
|  +---------------------------+  +------------------------+  |
|  |     Main Container        |  |  Sidecar Container     |  |
|  |     (Express App)         |  |  (Log Shipper/Proxy)   |  |
|  |     Port: 3000            |  |  Port: 9090            |  |
|  +-------------+-------------+  +------------+-----------+  |
|                |                             |              |
|                v                             v              |
|  +-------------------------------------------------------+  |
|  |           Shared Volume (/var/log/app)                |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

---

## 2. Declarative Pod Manifest (`nginx-pod.yaml`)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: web-server
    tier: frontend
spec:
  containers:
    - name: nginx-container
      image: nginx:alpine
      ports:
        - containerPort: 80
          name: http
      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "128Mi"
          cpu: "250m"
```

---

## 3. Pod Lifecycle Phases

1. **Pending**: Pod accepted by cluster, but one or more containers are not yet created or images are still downloading.
2. **Running**: Pod is bound to a node, and all containers have been created; at least one container is currently executing.
3. **Succeeded**: All containers in the Pod terminated successfully (exit code 0) and will not restart.
4. **Failed**: All containers terminated, and at least one container terminated in failure (non-zero exit code).
5. **Unknown**: Pod state could not be obtained (usually network communication failure with node).

---

## 4. Imperative Pod Management & Debugging CLI

### Creating and Generating Pods
```bash
# Imperative creation of a pod
kubectl run nginx-pod --image=nginx:alpine --port=80

# Dry-run generation of YAML manifest (Cheat code for writing YAML!)
kubectl run nginx-pod --image=nginx:alpine --port=80 --dry-run=client -o yaml > pod.yaml
```

### Inspecting and Debugging Pods
```bash
# List all pods with IP and Node placement
kubectl get pods -o wide

# View detailed pod events, restart counts, and state
kubectl describe pod nginx-pod

# Stream container logs
kubectl logs nginx-pod
kubectl logs -f nginx-pod

# Execute an interactive shell inside a container
kubectl exec -it nginx-pod -- sh

# Port-forward a pod port directly to your localhost (Debugging)
kubectl port-forward pod/nginx-pod 8080:80

# Copy files between local machine and pod container
kubectl cp nginx-pod:/etc/nginx/nginx.conf ./local-nginx.conf
```

### Deleting Pods
```bash
kubectl delete pod nginx-pod
```
