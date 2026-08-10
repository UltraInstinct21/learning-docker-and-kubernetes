# ==============================================================================
# THEORY: DOCKER BUILD CONTEXT & .dockerignore
# ==============================================================================
# WHAT IS THE BUILD CONTEXT?
# When you run `docker build [OPTIONS] PATH`, the `PATH` parameter specifies the
# Build Context directory.
#
# HOW IT WORKS:
# 1. The Docker CLI compresses everything in the build context directory into a tar
#    archive and transfers it to the Docker daemon (server).
# 2. Any `COPY` or `ADD` instruction in the Dockerfile can ONLY reference files
#    inside this build context. You cannot copy files outside of this path (e.g. `COPY ../file .` fails).
#
# WHY `.dockerignore` IS CRITICAL:
# Without a `.dockerignore` file:
# - Huge folders like `node_modules`, `.git`, or temporary build outputs get sent
#   to the Docker daemon, significantly slowing down build start times.
# - Sensitive files like `.env`, credentials, or private SSH keys risk being copied
#   into the image and exposed publicly.
#
# USEFUL DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Build using current directory as context:
#    docker build -t build-context-demo .
#
# 2. Build specifying a custom Dockerfile with separate context path:
#    docker build -f ./docker/build-context/Dockerfile -t demo ./docker/build-context
#
# 3. Observe the "Sending build context to Docker daemon" size in the terminal output:
#    Notice how a properly configured `.dockerignore` keeps this size under a few kilobytes!
# ==============================================================================

FROM node:latest

WORKDIR /app

# Copy files allowed by .dockerignore from build context into container WORKDIR
COPY . . 

CMD ["node", "index.js"]