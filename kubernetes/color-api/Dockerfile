# ==============================================================================
# THEORY: CONTAINERIZING A NODE.JS MICROSERVICE FOR KUBERNETES
# ==============================================================================
# DOCKER CLI COMMANDS:
# ------------------------------------------------------------------------------
# 1. Build Docker Image:
#    docker build -t ultrainstinct21/color-api:1.1.0 .
#
# 2. Run Container Locally:
#    docker run -d -p 8080:80 --name color-api ultrainstinct21/color-api:1.1.0
#
# 3. Push to Docker Hub / Registry:
#    docker push ultrainstinct21/color-api:1.1.0
# ==============================================================================

FROM node:22-alpine

WORKDIR /app

# Optimize build caching by copying dependencies definitions first
COPY package*.json ./

RUN npm ci

# Copy application source code
COPY . .

# Expose port 80 (standard HTTP port)
EXPOSE 80

CMD ["npm", "start"]