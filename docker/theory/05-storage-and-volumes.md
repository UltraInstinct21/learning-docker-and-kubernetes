# Topic 05: Storage, Volumes & Persistence

## 1. The Ephemeral Container Problem
By default, all files created inside a Docker container are stored on a temporary **writable container layer**.

- **Ephemeral**: When the container is deleted (`docker rm`), all data written to that container layer is permanently lost.
- **Performance**: Writing directly to the container layer relies on storage drivers (overlay2), which adds I/O overhead compared to native host performance.

To store persistent data (such as database records, user uploads, logs), Docker provides dedicated storage mechanisms.

---

## 2. Types of Docker Storage

```
+-------------------------------------------------------------------------+
|                               Host Machine                              |
|                                                                         |
|  +--------------------+   +-------------------+   +------------------+  |
|  |   Named Volumes    |   |    Bind Mounts    |   |   tmpfs Mounts   |  |
|  | /var/lib/docker/   |   | /home/user/app/   |   | Host RAM Memory  |  |
|  | volumes/db_data/   |   | src/              |   |                  |  |
|  +---------+----------+   +---------+---------+   +--------+---------+  |
|            |                        |                      |            |
|            v                        v                      v            |
|  +---------+----------+   +---------+---------+   +--------+---------+  |
|  | /var/lib/mysql/    |   | /app/src/         |   | /tmp/cache/      |  |
|  +--------------------+   +-------------------+   +------------------+  |
|                                Container                                |
+-------------------------------------------------------------------------+
```

| Type | Stored On Host | Managed By | Best Use Case |
| :--- | :--- | :--- | :--- |
| **Named Volumes** | `/var/lib/docker/volumes/` | Docker Engine | Production databases, persistent data, shared container data |
| **Bind Mounts** | Any user-specified path on host | User / Host OS | Local development, live code reloading, host config files |
| **tmpfs Mounts** | System Memory (RAM) | Host Kernel | Sensitive credentials, high-performance temporary caches |

---

## 3. Using Named Volumes

Named volumes are completely managed by Docker and survive container deletions.

### Volume Management CLI
```bash
# 1. Create a volume
docker volume create mongo-data

# 2. List all volumes
docker volume ls

# 3. Inspect volume metadata & host storage path
docker volume inspect mongo-data

# 4. Remove a volume
docker volume rm mongo-data

# 5. Clean up all unattached/unused volumes
docker volume prune
```

### Attaching a Named Volume to a Container
```bash
# Syntax using -v: -v <volume_name>:<container_path>
docker run -d --name mongodb -v mongo-data:/data/db -p 27017:27017 mongo:7.0

# Syntax using explicit --mount (recommended for scripts)
docker run -d --name mongodb \
  --mount type=volume,source=mongo-data,target=/data/db \
  -p 27017:27017 mongo:7.0
```

---

## 4. Using Bind Mounts for Development

Bind mounts map an absolute host directory directly into the container filesystem.

```bash
# Map current working directory into container with hot reload
docker run -d -p 3000:3000 \
  -v $(pwd)/src:/app/src \
  --name my-dev-app node-app:dev

# Read-only bind mount (:ro) for configuration files
docker run -d -p 80:80 \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:alpine
```

---

## 5. The Anonymous Volume Trick for `node_modules`

When mounting the entire host project folder (`-v $(pwd):/app`), the host's empty or incompatible `node_modules` might overwrite the container's installed dependencies.

**Solution**: Use an anonymous volume to preserve `/app/node_modules`:
```bash
docker run -d -p 3000:3000 \
  -v $(pwd):/app \
  -v /app/node_modules \
  react-app:dev
```
Docker mounts `/app/node_modules` from a dedicated Docker-managed volume, keeping container dependencies intact while syncing host source code.
