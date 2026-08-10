# ==============================================================================
# THEORY: DOCKER VOLUMES & DATA PERSISTENCE
# ==============================================================================
# Containers have an ephemeral/stateless writable layer by default. When a container
# is deleted, all data written inside it is lost.
#
# THREE TYPES OF DOCKER STORAGE:
# 1. Named Volumes (Recommended for persistent data like DBs):
#    - Stored in Docker-managed host storage area (`/var/lib/docker/volumes/`).
#    - Independent of container lifecycle; survive container deletions.
#    - Can be safely shared between multiple containers.
#
# 2. Bind Mounts (Recommended for local development & hot reloading):
#    - Mounts an exact path from the host machine into the container.
#    - Changes on host immediately reflect inside container.
#
# 3. tmpfs Mounts:
#    - Stored in host system memory only (never written to disk).
#
# USEFUL DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Volume Management:
#    docker volume create website-data       # Create named volume
#    docker volume ls                        # List all volumes
#    docker volume inspect website-data      # Inspect mount path on host
#    docker volume rm website-data           # Delete specific volume
#    docker volume prune                     # Delete all unused volumes
#
# 2. Run Container with Named Volume:
#    docker run -d -p 3000:80 --name website-main -v website-data:/usr/share/nginx/html nginx:alpine
#
# 3. Run Container with Bind Mount (e.g. mounting host folder):
#    docker run -d -p 3000:80 --name website-dev -v $(pwd)/html:/usr/share/nginx/html:ro nginx:alpine
#
# 4. Using the newer `--mount` syntax (more explicit):
#    docker run -d -p 3000:80 --name website-mount \
#      --mount type=volume,source=website-data,target=/usr/share/nginx/html \
#      nginx:alpine
# ==============================================================================

FROM nginx:alpine

# The VOLUME instruction defines a mount point with specified path
# and marks it as holding externally mounted volume from native host or other containers.
VOLUME ["/usr/share/nginx/html"]

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]