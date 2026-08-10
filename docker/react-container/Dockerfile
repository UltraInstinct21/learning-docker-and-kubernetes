# ==============================================================================
# THEORY: DOCKER FOR REACT PRODUCTION (MULTI-STAGE BUILD + NGINX)
# ==============================================================================
# In production, a Node.js development server should NEVER be used to serve static
# React/SPA assets.
#
# TWO-STAGE PRODUCTION WORKFLOW:
# - Stage 1 (Builder): Uses Node.js to install dependencies and compile React JSX/TSX
#   into static production HTML, CSS, and JS bundles (`/app/build`).
# - Stage 2 (Runner): Uses an ultra-lightweight Nginx web server (~20MB) to serve
#   those static files with optimal caching, gzip compression, and fast throughput.
# - The heavy Node.js runtime and node_modules are completely discarded!
#
# USEFUL DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Build the production image:
#    docker build -t react-app:prod .
#
# 2. Run the production Nginx container:
#    docker run -d -p 8080:80 --name react-prod react-app:prod
#
# 3. Access in browser:
#    http://localhost:8080
#
# 4. Compare image sizes between dev (Node runtime) and prod (Nginx only):
#    docker images | grep react-app
# ==============================================================================

# ------------------------------------------------------------------------------
# STAGE 1: Build production bundle
# ------------------------------------------------------------------------------
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . . 
RUN npm run build

# ------------------------------------------------------------------------------
# STAGE 2: Serve static bundle with high-performance HTTP server (Nginx)
# ------------------------------------------------------------------------------
FROM nginx:alpine 

# Copy compiled static assets from builder stage to Nginx web root
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]