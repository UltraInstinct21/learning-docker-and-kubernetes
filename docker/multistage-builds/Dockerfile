# ==============================================================================
# THEORY: MULTI-STAGE BUILDS & DISTROLESS RUNTIME
# ==============================================================================
# Multi-stage builds allow you to use multiple `FROM` statements in a single Dockerfile.
# Each `FROM` instruction begins a new stage with a clean base image.
#
# WHY USE MULTI-STAGE BUILDS?
# 1. Separation of Concerns: Separate heavy build tools (TypeScript, build tools,
#    compilers, test runners) from the minimal production runtime.
# 2. Drastic Size Reduction: Only copy the compiled artifacts (e.g. `dist/`) and
#    production dependencies into the final image.
# 3. Enhanced Security: Build tools and vulnerability-prone packages are completely
#    excluded from the final production container.
#
# DISTROLESS IMAGES (`gcr.io/distroless/nodejs22`):
# - Google Container Tools "Distroless" images contain ONLY your application and its
#   runtime dependencies (Node.js).
# - They do NOT contain package managers (apt, apk), shells (/bin/sh, /bin/bash),
#   or any other standard Linux programs.
# - Attackers cannot easily execute arbitrary commands or download malicious scripts.
#
# USEFUL DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Build the final production image:
#    docker build -t ts-app:multistage .
#
# 2. Build up to a specific intermediate stage (e.g. for debugging build stage):
#    docker build --target build -t ts-app:build-stage .
#
# 3. Inspect the final lightweight image size:
#    docker images ts-app:multistage
#
# 4. Run the production container:
#    docker run -d -p 3000:3000 --name ts-prod ts-app:multistage
# ==============================================================================

# ------------------------------------------------------------------------------
# STAGE 1: Build & Compile TypeScript to JavaScript
# ------------------------------------------------------------------------------
FROM node:alpine AS build
WORKDIR /app
COPY package*.json ./
# Install all dependencies (including TypeScript devDependencies)
RUN npm ci

COPY src src 
COPY tsconfig.json tsconfig.json
# Compiles TS files to JavaScript in /app/dist
RUN npm run build

# ------------------------------------------------------------------------------
# STAGE 2: Install Production-Only Dependencies
# ------------------------------------------------------------------------------
FROM node:alpine AS deps
WORKDIR /app
COPY package*.json ./
# Install only production dependencies
RUN npm ci --only=production

# ------------------------------------------------------------------------------
# STAGE 3: Minimal Distroless Production Runtime
# ------------------------------------------------------------------------------
FROM gcr.io/distroless/nodejs22

WORKDIR /app

# Copy production node_modules from deps stage
COPY --from=deps /app/node_modules node_modules

# Copy compiled JavaScript output from build stage
COPY --from=build /app/dist dist

ENV PORT=3000
EXPOSE 3000

# Non-root distroless container entrypoint
CMD ["dist/index.js"]