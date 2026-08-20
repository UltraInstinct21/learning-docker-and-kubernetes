# Topic 06: Image Optimization & Layer Caching

## 1. How Docker Layer Caching Works
Each instruction in a Dockerfile generates an intermediate layer. When rebuilding an image:
- If a layer's instruction and its dependencies have not changed, Docker **reuses the cached layer** (`---> Using cache`).
- **The Golden Rule of Caching**: As soon as a single layer changes, **all subsequent layers below it are invalidated and must be rebuilt from scratch**.

---

## 2. Optimization Strategy 1: Instruction Ordering

Order instructions from **least frequently changed** to **most frequently changed**.

### Inefficient Ordering (Breaks Cache Constantly)
```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY . .            # Changing 1 line of code invalidates this layer...
RUN npm ci          # ...forcing a full 2-minute npm download every single build!
CMD ["node", "index.js"]
```

### Optimized Ordering (Utilizes Cache)
```dockerfile
FROM node:22-alpine
WORKDIR /app

# Step 1: Copy only dependency manifests (changes rarely)
COPY package*.json ./

# Step 2: Install dependencies (Cached 99% of the time!)
RUN npm ci

# Step 3: Copy frequently changing source code last
COPY . .

CMD ["node", "index.js"]
```

---

## 3. Optimization Strategy 2: Base Image Selection

Choosing a minimal base image reduces image size by up to **85%** and eliminates thousands of unneeded system binaries and security vulnerabilities.

| Base Image | Size | Operating System | Use Case |
| :--- | :--- | :--- | :--- |
| `node:22` | ~1.1 GB | Full Debian (Build tools, Python, gcc) | Heavy native C++ module builds |
| `node:22-slim` | ~220 MB | Minimal Debian | General Node.js apps needing standard glibc |
| `node:22-alpine` | ~140 MB | Alpine Linux (musl libc + busybox) | Ultra-compact production microservices |
| `gcr.io/distroless/nodejs22` | ~130 MB | None (Only Node binary + dependencies) | High-security production containers |

---

## 4. Optimization Strategy 3: Pruning DevDependencies

Development tools (TypeScript, Jest, ESLint, Webpack) should not exist in production containers.

```dockerfile
# Installs only runtime dependencies from "dependencies" in package.json
RUN npm ci --only=production
```

---

## 5. Optimization Strategy 4: Chaining Commands & Cleaning Package Caches

In package managers (like `apt-get` or `apk`), always combine installation and cleanup in a single `RUN` layer:

```dockerfile
# Single RUN command ensures cache files are deleted in the same layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl jq && \
    rm -rf /var/lib/apt/lists/*
```

---

## 6. Inspecting Image Layers & Size

```bash
# View all layers and their contribution to image size
docker history my-app:latest

# Compare sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Force build without using cache
docker build --no-cache -t my-app:fresh .
```
