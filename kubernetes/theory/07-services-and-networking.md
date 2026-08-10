# Topic 07: Kubernetes Services & Networking

## 1. Why Services?
Pods are ephemeral—they are created, destroyed, and rescheduled with **new dynamic IP addresses**. Clients cannot reliably connect directly to individual Pod IPs.

A **Service** provides a stable, long-lived IP address, DNS name, and load balancer across a dynamic set of Pods identified by a Label Selector.

```
Incoming Request: http://color-api:3000
                   |
                   v
   +-------------------------------+
   |      Service (ClusterIP)      |
   |      IP: 10.96.0.100:3000     |
   |      Selector: app=color-api  |
   +---------------+---------------+
                   |
         Load Balances Across Endpoints
         /             |             \
        v              v              v
+---------------+ +---------------+ +---------------+
| Pod 1         | | Pod 2         | | Pod 3         |
| 10.244.1.5:80 | | 10.244.2.8:80 | | 10.244.1.9:80 |
+---------------+ +---------------+ +---------------+
```

---

## 2. The Four Kubernetes Service Types

| Type | Accessibility | Description |
| :--- | :--- | :--- |
| **`ClusterIP`** | Internal Only | Default type. Assigns a cluster-internal virtual IP. Used for inter-service backend communication. |
| **`NodePort`** | External + Internal | Exposes the Service on a static high port (`30000-32767`) across every Worker Node IP (`NodeIP:NodePort`). |
| **`LoadBalancer`** | External Public | Provisions a cloud provider load balancer (AWS NLB/ALB, GCP LB) that routes to the NodePort automatically. |
| **`ExternalName`** | Internal Alias | Maps the Service DNS name directly to an external CNAME (e.g. `api.google.com`) without selectors or proxies. |

---

## 3. Practical Service Manifests

### A. ClusterIP Service (`color-api-clusterip.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: color-api-clusterip
spec:
  type: ClusterIP
  selector:
    app: color-api
  ports:
    - port: 3000        # Port exposed by this Service
      targetPort: 3000  # Port where application listens in Pod container
```

### B. NodePort Service (`color-api-nodeport.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: color-api-nodeport
spec:
  type: NodePort
  selector:
    app: color-api
  ports:
    - port: 3000        # Internal ClusterIP port
      targetPort: 3000  # Target Pod container port
      nodePort: 30080   # Static port opened on EVERY cluster node (30000-32767)
```

### C. ExternalName Service (`google-extname.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: google-extname
spec:
  type: ExternalName
  externalName: google.com  # Internal DNS lookup resolves directly to google.com CNAME
```

---

## 4. In-Cluster DNS Discovery Rules

CoreDNS provides automatic DNS records for every Service inside the cluster:
- Same namespace: `http://<service-name>:<port>` (e.g. `http://color-api-clusterip:3000`)
- Cross-namespace: `http://<service-name>.<namespace>.svc.cluster.local:<port>`

---

## 5. Service Inspection & Troubleshooting CLI Commands

```bash
# 1. List services with ClusterIP and NodePort info
kubectl get svc -o wide

# 2. View healthy backend Pod IPs registered to the Service
kubectl get endpoints color-api-clusterip
kubectl get endpointslices

# 3. Test service connectivity internally via temporary test pod
kubectl run test-curl --rm -it --image=curlimages/curl -- curl http://color-api-clusterip:3000/color

# 4. Port forward a service to localhost
kubectl port-forward svc/color-api-clusterip 8080:3000
```
