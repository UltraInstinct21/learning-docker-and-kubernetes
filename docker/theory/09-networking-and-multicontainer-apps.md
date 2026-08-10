# Topic 09: Docker Networking & Multi-Container Systems

## 1. Docker Network Drivers

Docker provides several built-in network drivers:

| Driver | Description | Common Use Case |
| :--- | :--- | :--- |
| **bridge** | Default private network created on the host. Containers can communicate with each other. | Standalone containers on a single host. |
| **host** | Removes network isolation between container and host (shares host's network stack directly). | Maximum throughput applications (benchmarking). |
| **none** | Disables all networking inside the container. | Isolated security jobs (e.g. key generation). |
| **overlay** | Enables multi-host networking across different physical machines. | Docker Swarm / Kubernetes networking. |

---

## 2. Default Bridge vs. User-Defined Bridge Networks

```
+--------------------------------------------------------------------------------+
| Host: User-Defined Bridge Network (key-value-net)                              |
|                                                                                |
|  +--------------------+   DNS Query: "mongodb"   +--------------------------+  |
|  |  Backend Container | -----------------------> |    MongoDB Container     |  |
|  |  name: backend     |                          |    name: mongodb         |  |
|  |  IP: 172.18.0.3    | <----------------------- |    IP: 172.18.0.2        |  |
|  +--------------------+    Port 27017 Response   +--------------------------+  |
+--------------------------------------------------------------------------------+
```

### Why Always Use User-Defined Bridge Networks?
1. **Automatic DNS Resolution**: Containers connected to a user-defined network can communicate using **container names** as hostnames (e.g. `curl http://backend:3000` or `mongodb://mongodb:27017`).
2. **Default Bridge Lacks DNS**: The default `bridge` network does NOT provide automatic DNS resolution; containers must use IP addresses, which change whenever containers restart.
3. **Better Isolation**: Containers on different custom bridge networks cannot communicate with each other unless explicitly attached.

---

## 3. Network Management CLI Commands

```bash
# 1. Create a custom bridge network
docker network create key-value-net

# 2. List networks
docker network ls

# 3. Inspect network details (connected containers and their assigned IPs)
docker network inspect key-value-net

# 4. Connect a running container to a network
docker network connect key-value-net my-container

# 5. Disconnect a container from a network
docker network disconnect key-value-net my-container

# 6. Remove a network
docker network rm key-value-net
```

---

## 4. Multi-Container Orchestration with Shell Scripts

For a multi-tier application (e.g. MongoDB Database + Node.js API):

```bash
# 1. Create network & volume
docker network create app-net
docker volume create db-data

# 2. Start Database Container on app-net
docker run -d --name mongodb \
  --network app-net \
  -v db-data:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME=root \
  -e MONGO_INITDB_ROOT_PASSWORD=secret \
  mongo:7.0

# 3. Start Backend Container on the same network
# Backend connects directly via hostname "mongodb"
docker run -d --name backend \
  --network app-net \
  -p 3000:3000 \
  -e MONGO_HOST=mongodb \
  my-backend:latest
```
