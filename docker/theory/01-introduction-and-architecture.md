# Topic 01: Docker Introduction & Architecture

## 1. What is Docker?
Docker is an open-source platform that enables developers to package applications and their dependencies into standardized units called **Containers**. Containers ensure that applications run reliably and consistently across any environment—from local development laptops to production cloud clusters.

### Containers vs. Virtual Machines (VMs)

| Feature | Virtual Machine (VM) | Docker Container |
| :--- | :--- | :--- |
| **Architecture** | Includes a full Guest OS + Hypervisor | Shares the Host OS Kernel |
| **Size** | Gigabytes (GBs) | Megabytes (MBs) |
| **Startup Time** | Minutes | Milliseconds to Seconds |
| **Resource Usage** | High (memory & CPU statically allocated) | Low (shares system resources dynamically) |
| **Isolation** | Hardware-level isolation via Hypervisor | Process-level isolation via Linux Namespaces & cgroups |

```
+------------------------------------+      +------------------------------------+
|            Virtual Machine         |      |          Docker Container          |
+------------------------------------+      +------------------------------------+
|  App A   |  App B   |  App C       |      |  App A   |  App B   |  App C       |
|  Libs    |  Libs    |  Libs        |      |  Libs    |  Libs    |  Libs        |
| Guest OS | Guest OS | Guest OS     |      | Containers (isolated processes)   |
+------------------------------------+      +------------------------------------+
|             Hypervisor             |      |           Docker Engine            |
+------------------------------------+      +------------------------------------+
|              Host OS               |      |              Host OS               |
+------------------------------------+      +------------------------------------+
|          Physical Server           |      |          Physical Server           |
+------------------------------------+      +------------------------------------+
```

---

## 2. Docker Architecture

Docker uses a client-server architecture:
1. **Docker Client (`docker`)**: The primary CLI tool used to communicate with the Docker daemon.
2. **Docker Host (Daemon - `dockerd`)**: The background service managing containers, images, networks, and storage volumes.
3. **Docker Registry (e.g., Docker Hub)**: A repository for storing and distributing Docker images.
4. **Underlying Linux Technologies**:
   - **Namespaces**: Provide process isolation (PID, NET, MNT, IPC, UTS).
   - **Control Groups (cgroups)**: Limit and monitor resource usage (CPU, RAM, disk I/O).
   - **Union File System (UnionFS)**: Layered file system enabling lightweight copy-on-write image layers.

---

## 3. Core Concepts

- **Image**: An immutable, read-only template containing the application code, runtime, libraries, environment variables, and configuration.
- **Container**: A runnable, isolated instance of an image with a thin writable layer on top.
- **Volume**: Managed persistent storage decoupled from container lifecycles.
- **Network**: Virtual software bridge enabling isolated inter-container communication.

---

## 4. Essential Docker CLI Commands

### Checking Docker Environment
```bash
# Check Docker version and installation details
docker version

# View system-wide Docker information (containers running, images, storage driver)
docker info
```

### Image Management
```bash
# Search for images on Docker Hub
docker search nginx

# Pull an image from registry
docker pull node:22-alpine

# List locally downloaded images
docker images

# Remove an image
docker rmi node:22-alpine
```

### Container Management Lifecycle
```bash
# Run a container in detached mode (-d) with port forwarding (-p)
docker run -d -p 8080:80 --name my-web-server nginx:alpine

# List running containers
docker ps

# List all containers (including stopped ones)
docker ps -a

# View container resource usage in real-time
docker stats

# Stop and restart containers
docker stop my-web-server
docker start my-web-server
docker restart my-web-server

# Remove a stopped container
docker rm my-web-server

# Force stop and remove a running container
docker rm -f my-web-server
```

---

## 5. Summary & Key Takeaways
- Containers isolate processes while sharing the host OS kernel.
- The Docker Client communicates with the Docker Daemon via a REST API over UNIX sockets or TCP.
- Images are built from layered, read-only snapshots, while containers add a thin, temporary writable layer on top.
