# Topic 02: Dockerfile & Application Containerization

## 1. What is a Dockerfile?
A **Dockerfile** is a plain text file containing a sequence of instructions used to build a Docker image automatically. Each instruction adds a new read-only layer to the image.

---

## 2. Anatomy of a Dockerfile

| Instruction | Purpose | Example |
| :--- | :--- | :--- |
| `FROM` | Sets the base image (must be the first non-comment instruction). | `FROM node:22-alpine` |
| `WORKDIR` | Sets the working directory inside the container. | `WORKDIR /app` |
| `COPY` | Copies files from the host build context to the container filesystem. | `COPY package*.json ./` |
| `ADD` | Like `COPY`, but supports remote URLs and automatic tar extraction. *(Prefer `COPY` for predictability)* | `ADD archive.tar.gz /app/` |
| `RUN` | Executes commands during build time to create new layers (e.g. installing packages). | `RUN npm ci` |
| `ENV` | Sets persistent environment variables available during build and runtime. | `ENV PORT=5000` |
| `ARG` | Defines build-time variables (not persisted in runtime). | `ARG VERSION=1.0` |
| `EXPOSE` | Documents the network ports the application listens on at runtime. | `EXPOSE 5000` |
| `VOLUME` | Creates a mount point for external persistent storage. | `VOLUME ["/data"]` |
| `CMD` | Specifies default executable and arguments when running the container. | `CMD ["node", "src/index.js"]` |
| `ENTRYPOINT`| Configures the container to run as a fixed executable. | `ENTRYPOINT ["node"]` |

---

## 3. Practical Example: Containerizing an Express App

```dockerfile
# 1. Base Image
FROM node:22-alpine

# 2. Set working directory
WORKDIR /app

# 3. Copy dependency definitions first (Optimizes layer caching!)
COPY package*.json ./

# 4. Install exact dependencies
RUN npm ci

# 5. Copy remaining source code
COPY . .

# 6. Set environment variables & expose port
ENV PORT=5000
EXPOSE 5000

# 7. Exec form of CMD
CMD ["node", "src/index.js"]
```

---

## 4. Exec Form vs. Shell Form

Every `CMD` and `ENTRYPOINT` instruction can be written in two forms:

### Exec Form (Preferred)
```dockerfile
CMD ["node", "src/index.js"]
```
- **Runs directly as PID 1** inside the container without spawning a shell.
- **Proper Signal Handling**: Correctly forwards `SIGTERM` and `SIGINT` signals from `docker stop`, enabling graceful application shutdown.

### Shell Form (Avoid when possible)
```dockerfile
CMD node src/index.js
```
- Spawns `/bin/sh -c "node src/index.js"`.
- The shell process becomes PID 1, meaning `SIGTERM` signals sent by `docker stop` are not passed to your application process, causing dirty shutdowns and timeouts.

---

## 5. Useful CLI Commands

### Building Images
```bash
# Build image from Dockerfile in current directory
docker build -t express-app:1.0.0 .

# Build with custom Dockerfile name
docker build -f Dockerfile.prod -t express-app:prod .

# Build with build arguments
docker build --build-arg VERSION=2.0 -t express-app:2.0 .
```

### Running Containers
```bash
# Run container in background with port mapping
docker run -d -p 5000:5000 --name express-app express-app:1.0.0

# Override environment variables at runtime
docker run -d -p 8080:8080 -e PORT=8080 --name custom-express express-app:1.0.0

# Inspect logs
docker logs express-app
docker logs -f --tail 50 express-app
```
