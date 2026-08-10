# ==============================================================================
# THEORY: CONTAINERIZING A NODE.JS / EXPRESS WEB APPLICATION
# ==============================================================================
# A Dockerfile is a recipe that defines the steps to build a container image.
#
# INSTRUCTION BREAKDOWN:
# 1. `FROM`: Specifies the base image.
#    - `node:latest` (or `node:22-alpine` for smaller footprint) provides Node runtime.
# 2. `WORKDIR`: Sets the working directory inside the container. Subsequent commands
#    (RUN, COPY, CMD) execute relative to this directory. If it doesn't exist, Docker creates it.
# 3. `COPY package*.json ./`: Copies only dependencies definition files first.
#    - LAYER CACHING: Docker caches each instruction. If package.json hasn't changed,
#      Docker skips `RUN npm ci`, speeding up subsequent builds significantly.
# 4. `RUN npm ci`: Runs clean install of dependencies based exactly on package-lock.json.
#    - `npm ci` is faster and more reliable than `npm install` for automated builds.
# 5. `COPY . .`: Copies the remaining application source code into `/app`.
# 6. `ENV`: Sets environment variables available during container runtime.
# 7. `EXPOSE`: Documents the port the application listens on (metadata, does not publish port).
# 8. `CMD`: Specifies the default command executed when the container starts.
#    - Use Exec Form: `["node", "src/index.js"]` (runs directly as PID 1, handles OS signals).
#    - Avoid Shell Form: `CMD node src/index.js` (spawns `/bin/sh -c` subshell).
#
# USEFUL DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Build the Docker Image:
#    docker build -t express-app:1.0.0 .
#
# 2. Run Container in Background (Detached) with Port Mapping:
#    docker run -d -p 5000:5000 --name my-express-app express-app:1.0.0
#
# 3. Run with Custom Environment Variables:
#    docker run -d -p 8080:8080 -e PORT=8080 --name my-express-app-custom express-app:1.0.0
#
# 4. Inspect Container Logs:
#    docker logs my-express-app
#    docker logs -f my-express-app      # Follow / stream logs
#
# 5. Execute interactive shell inside container:
#    docker exec -it my-express-app sh
#
# 6. Stop and Remove Container:
#    docker stop my-express-app
#    docker rm my-express-app
# ==============================================================================

FROM node:latest

WORKDIR /app

# Copy dependency manifests first to leverage Docker layer caching
COPY package*.json ./

# Install exact dependencies
RUN npm ci

# Copy application source code
COPY . . 

# Set default environment variables
ENV PORT=5000

# Document exposed port
EXPOSE 5000

# Exec form of CMD to ensure proper signal handling (SIGTERM)
CMD ["node", "src/index.js"]