# Topic 08: Frontend Containerization (React, Vite & SPAs)

## 1. Frontend Development vs. Production Paradigms

Single Page Applications (React, Vue, Angular, Svelte) require two completely distinct container architectures:

| Environment | Strategy | Web Server | Image Size | Reload Mechanism |
| :--- | :--- | :--- | :--- | :--- |
| **Development** | Node.js dev server (`npm start` / `vite`) | Webpack / Vite Dev Server | ~300 MB | Bind Mounts + Hot Module Replacement (HMR) |
| **Production** | Multi-Stage Build: Node builds assets $\rightarrow$ Nginx serves static files | High-performance Nginx / Caddy | ~25 MB | Immutable static asset serving |

---

## 2. React Development Container (`Dockerfile.dev`)

In development, we want instant updates when editing source code without rebuilding images.

```dockerfile
FROM node:22-alpine AS dev
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### Running with Bind Mounts
```bash
docker run -d -p 3000:3000 \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/public:/app/public \
  -v /app/node_modules \
  --name react-dev react-app:dev
```

---

## 3. React Production Multi-Stage Container (`Dockerfile`)

In production, Node.js should never be used to serve static HTML/JS/CSS files. Nginx provides far superior connection handling, caching headers, and memory efficiency.

```dockerfile
# ------------------------------------------------------------------------------
# STAGE 1: Build static React bundle
# ------------------------------------------------------------------------------
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build  # Generates static files in /app/build

# ------------------------------------------------------------------------------
# STAGE 2: Lightweight Nginx server
# ------------------------------------------------------------------------------
FROM nginx:alpine
# Copy compiled static files into Nginx default root directory
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## 4. Useful CLI Commands

```bash
# Build production bundle
docker build -t react-app:prod .

# Run production container
docker run -d -p 80:80 --name my-react-website react-app:prod

# Inspect Nginx static files inside container
docker exec -it my-react-website ls -la /usr/share/nginx/html
```
