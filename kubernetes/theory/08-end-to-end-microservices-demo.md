# Topic 08: End-to-End Microservices & Traffic Generator Demo

## 1. Demo Architecture & Objective

This hands-on tutorial demonstrates how Kubernetes distributes incoming HTTP requests across multiple Pod replicas behind a `ClusterIP` Service using an automated load testing container (`traffic-generator`).

```
+-------------------------------------------------------------------------------+
| Kubernetes Cluster                                                            |
|                                                                               |
|  +---------------------------+       HTTP GET /color (every 1s)               |
|  | Traffic Generator Pod     | ------------------------------------+          |
|  | (traffic-generator)       |                                     |          |
|  +---------------------------+                                     v          |
|                                                     +-----------------------+ |
|                                                     | color-api-clusterip   | |
|                                                     | Service (Port 3000)   | |
|                                                     +-----------+-----------+ |
|                                                                 |             |
|                                   Round-Robin Load Distribution |             |
|                                   +-------------+---------------+             |
|                                   |             |               |             |
|                                   v             v               v             |
|                              +---------+   +---------+     +---------+        |
|                              | Pod 1   |   | Pod 2   |     | Pod 3   |        |
|                              | (Red)   |   | (Green) |     | (Blue)  |        |
|                              +---------+   +---------+     +---------+        |
+-------------------------------------------------------------------------------+
```

---

## 2. Components Breakdown

1. **`color-api` Microservice (`kubernetes/color-api`)**:
   - Express.js HTTP API returning JSON with a dynamically assigned pod name, random color, and server environment.
   - Endpoint: `GET /color`
2. **`color-api-dep.yaml`**:
   - Deployment maintaining 3 replicas of the `color-api` container.
3. **`color-api-clusterip.yaml`**:
   - Internal `ClusterIP` service binding to `app=color-api` on port 3000.
4. **`traffic-generator` (`kubernetes/traffic-generator`)**:
   - An Alpine container running a shell loop that sends continuous HTTP requests to `http://color-api-clusterip:3000/color` and logs the responses.

---

## 3. Step-by-Step Execution Guide

### Step 1: Deploy the Backend API and ClusterIP Service
```bash
# Apply deployment (3 replicas)
kubectl apply -f kubernetes/services/color-api-dep.yaml

# Apply ClusterIP service
kubectl apply -f kubernetes/services/color-api-clusterip.yaml

# Verify backend pods are Running
kubectl get pods -l app=color-api -o wide
```

### Step 2: Deploy the Traffic Generator
```bash
kubectl apply -f kubernetes/services/traffic-gen-dep.yaml
```

### Step 3: Stream Logs to Observe In-Cluster Load Balancing
```bash
# Follow logs of the traffic generator
kubectl logs -l app=traffic-gen -f
```

**Observed Output**:
```
Response from: color-api-dep-78b94f9644-abcde (Color: #FF5733)
Response from: color-api-dep-78b94f9644-xyz12 (Color: #33FF57)
Response from: color-api-dep-78b94f9644-qwe89 (Color: #3357FF)
Response from: color-api-dep-78b94f9644-abcde (Color: #FF5733)
```
Each request is evenly distributed across different backend Pod instances!

---

## 4. Scaling During Live Traffic
Observe self-healing and dynamic endpoint registration:

```bash
# Scale up from 3 to 6 replicas during live traffic
kubectl scale deployment/color-api-dep --replicas=6

# Check endpoints - 6 IPs are now instantly registered in the service!
kubectl get endpoints color-api-clusterip
```

---

## 5. Cleanup
```bash
kubectl delete -f kubernetes/services/traffic-gen-dep.yaml
kubectl delete -f kubernetes/services/color-api-clusterip.yaml
kubectl delete -f kubernetes/services/color-api-dep.yaml
```
