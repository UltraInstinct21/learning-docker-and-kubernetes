# Topic 03: Build Context & `.dockerignore`

## 1. What is the Build Context?
When you run `docker build -t my-image .`, the path `.` is known as the **Build Context**.

Before the Docker daemon starts building the image, the Docker CLI archives the entire contents of the build context directory (recursively) and sends it over to the Docker daemon.

```
+-----------------------------+               +-------------------------------+
|      Docker Client (CLI)    |               |         Docker Daemon         |
+-----------------------------+               +-------------------------------+
| Directory: .                |               |                               |
| Files, Code, Assets         |  Tar Archive  | Receives Context              |
|                             | ------------> | Executes Dockerfile Commands  |
| .dockerignore filters files |               | (COPY can only see Context)   |
+-----------------------------+               +-------------------------------+
```

### Why is Build Context Critical?
1. **Security**: Any file in the context directory could accidentally be copied into the image if not excluded (e.g. `.env`, SSH keys, credentials).
2. **Build Speed**: Sending large unneeded files (like local `node_modules` or `.git`) over the socket slows down the build significantly (`Sending build context to Docker daemon...`).
3. **Cache Invalidation**: Unrelated file modifications inside the context will invalidate Docker build cache layers.

---

## 2. The Role of `.dockerignore`

A `.dockerignore` file works just like `.gitignore`. It tells the Docker CLI which files and folders to **exclude** before packing and sending the context to the daemon.

### Standard Production `.dockerignore` File

```gitignore
# Version control
.git
.gitignore

# Dependencies (MUST be excluded so container installs clean dependencies)
node_modules
npm-debug.log

# Build artifacts and local temp files
dist
build
coverage
*.log
.DS_Store

# Secrets and environment files (NEVER bake secrets into images!)
.env
.env.local
.env.*.local
*.pem
*.key

# Docker specific files
Dockerfile*
docker-compose*.yaml
README.md
```

---

## 3. Best Practices & Rules

1. **`COPY` cannot access files outside the context**:
   - `COPY ../shared /app/shared` will **fail** because `../shared` is outside the build context root.
2. **Always exclude local `node_modules`**:
   - The host system architecture (e.g., macOS or Ubuntu host) might have compiled native C++ binaries inside `node_modules` that are incompatible with the Linux container (e.g. Alpine). Always let the container run `npm ci` inside itself!

---

## 4. Useful CLI Commands

```bash
# Explicitly specifying context directory vs Dockerfile location
docker build -f ./docker/Dockerfile -t my-app:latest ./src

# Testing build context transfer size
# Watch the first line: "Sending build context to Docker daemon  1.25MB"
docker build -t test-context .
```
