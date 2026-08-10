# Topic 07: Multi-Stage Builds & Distroless Runtimes

## 1. Why Multi-Stage Builds?
In traditional single-stage Docker builds, compiling languages (such as TypeScript, Go, Rust, Java) required the final image to retain compilers, build tools, SDKs, and dev dependencies, resulting in bloated images (500MB - 1.5GB) with high vulnerability counts.

**Multi-Stage Builds** solve this by using multiple `FROM` instructions in a single Dockerfile:
- Each stage runs in an isolated temporary container.
- You can cherry-pick and **copy only compiled artifacts** (`dist/` or binaries) into the final minimal runtime image.

```
+-------------------------------------------------------------+
| STAGE 1: Build Stage (FROM node:alpine AS build)            |
| - Installs TypeScript, full devDependencies                 |
| - Compiles TS -> JavaScript (/app/dist)                     |
+-------------------------------------------------------------+
                              |
                     COPY --from=build /app/dist
                              v
+-------------------------------------------------------------+
| STAGE 2: Production Dependencies (FROM node:alpine AS deps) |
| - Installs production-only dependencies (npm ci --omit=dev) |
+-------------------------------------------------------------+
                              |
                     COPY --from=deps /app/node_modules
                              v
+-------------------------------------------------------------+
| STAGE 3: Final Minimal Runtime (FROM gcr.io/distroless)     |
| - Zero build tools, zero compilers                          |
| - Final Image Size: ~100MB (down from 1GB!)                 |
+-------------------------------------------------------------+
```

---

## 2. Practical TypeScript Multi-Stage Dockerfile

```dockerfile
# ------------------------------------------------------------------------------
# STAGE 1: Build & Compile TypeScript
# ------------------------------------------------------------------------------
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY src src
COPY tsconfig.json tsconfig.json
RUN npm run build  # Output compiled JS to /app/dist

# ------------------------------------------------------------------------------
# STAGE 2: Clean Production Dependencies
# ------------------------------------------------------------------------------
FROM node:22-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# ------------------------------------------------------------------------------
# STAGE 3: Distroless Secure Production Image
# ------------------------------------------------------------------------------
FROM gcr.io/distroless/nodejs22
WORKDIR /app

# Copy artifacts from intermediate stages
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

ENV PORT=3000
EXPOSE 3000

CMD ["dist/index.js"]
```

---

## 3. What are Distroless Images?
Distroless images (`gcr.io/distroless/...`) are created by Google:
- They contain **only** your application binary and its direct runtime (Node.js, Java, Python).
- They do **NOT** contain package managers (`apt`, `apk`), shells (`/bin/sh`, `/bin/bash`), or typical Linux utilities.
- **Security Impact**: Even if an attacker discovers a remote code execution exploit in an app, they cannot spawn an interactive shell or download malicious binaries (`curl`/`wget`).

---

## 4. Useful CLI Commands

```bash
# Build the complete final multi-stage image
docker build -t ts-microservice:prod .

# Build up to a specific intermediate stage (e.g. for testing/debugging)
docker build --target build -t ts-microservice:dev-stage .

# Compare size against single-stage images
docker images ts-microservice:prod
```
