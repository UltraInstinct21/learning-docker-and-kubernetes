# ==============================================================================
# THEORY: CUSTOMIZING NGINX WEB SERVER IMAGES
# ==============================================================================
# Nginx is a high-performance HTTP server and reverse proxy.
#
# KEY CONCEPTS:
# 1. Base Image (`nginx:latest` or `nginx:alpine`): Comes with default Nginx configuration
#    and web root directory at `/usr/share/nginx/html`.
# 2. Layer Chaining (`&&`): Combining `apt-get update && apt-get install -y ... && rm -rf /var/lib/apt/lists/*`
#    into a single `RUN` instruction ensures package cache lists are not preserved in intermediate layers,
#    keeping the final image small.
# 3. File Permissions (`chown`): Ensuring the non-root `nginx` user has appropriate ownership.
# 4. Default Port: Nginx listens on port 80 inside the container.
#
# USEFUL DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Build the custom Nginx image:
#    docker build -t custom-nginx:1.0.0 .
#
# 2. Run Nginx container mapping host port 8080 to container port 80:
#    docker run -d -p 8080:80 --name my-custom-nginx custom-nginx:1.0.0
#
# 3. Test HTTP response in browser or terminal:
#    curl http://localhost:8080
#
# 4. Inspect running Nginx logs:
#    docker logs my-custom-nginx
#
# 5. Access bash inside Nginx container to test installed tools (like vim):
#    docker exec -it my-custom-nginx bash
#
# 6. Stop and remove container:
#    docker rm -f my-custom-nginx
# ==============================================================================

FROM nginx:latest

# Install tools in a single layer and clean apt cache to minimize image size
RUN apt-get update && apt-get install -y \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy custom HTML page into Nginx standard webroot
COPY index.html /usr/share/nginx/html/index.html

# Set appropriate file ownership for security
RUN chown nginx:nginx /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]