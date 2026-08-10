# Topic 10: Docker Compose & Multi-Service Orchestration

## 1. What is Docker Compose?
**Docker Compose** is a declarative configuration tool for defining and running multi-container Docker applications using a single YAML file (`compose.yaml` or `docker-compose.yaml`).

Instead of running dozens of individual `docker run`, `docker network create`, and `docker volume create` commands, Compose manages the entire stack lifecycle with simple commands like `docker compose up` and `docker compose down`.

---

## 2. Core Concepts of Compose YAML

```yaml
name: key-value-app

services:
  backend:
    build:
      context: backend
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    environment:
      - MONGO_HOST=db
      - PORT=3000
    depends_on:
      - db
    networks:
      - key-value-net
    develop:
      watch:
        - action: sync
          path: ./backend/src
          target: /app/src

  db:
    image: mongodb/mongodb-community-server:latest
    ports:
      - "27018:27017"
    env_file:
      - .env.db
    volumes:
      - type: volume
        source: mongo-data
        target: /data/db
    networks:
      - key-value-net

volumes:
  mongo-data:

networks:
  key-value-net:
```

### Key Directives Explained:
- `services`: Defines the individual container services in the application.
- `build`: Specifies build context and Dockerfile name to build an image locally.
- `image`: Specifies a registry image to pull.
- `ports`: Maps host port to container port (`"HOST:CONTAINER"`).
- `environment` / `env_file`: Injects environment variables.
- `depends_on`: Expresses startup dependency order.
- `develop.watch`: Enables Docker Compose Watch for live file synchronization without full container restarts.
- `volumes`: Defines named storage volumes created at root level.
- `networks`: Defines isolated custom bridge networks shared by services.

---

## 3. Docker Compose CLI Cheatsheet

```bash
# Start all services in the background (detached mode)
docker compose up -d

# Force rebuild of images and start containers
docker compose up -d --build

# Start with live file watching (Compose Watch)
docker compose watch

# View status of services in the project
docker compose ps

# View real-time logs from all services
docker compose logs -f

# Follow logs from a single service
docker compose logs -f backend

# Execute a command inside a running service
docker compose exec backend sh
docker compose exec db mongosh

# Stop services without deleting volumes or networks
docker compose stop

# Stop and remove containers and networks (preserves volumes)
docker compose down

# Stop and remove EVERYTHING including named persistent volumes
docker compose down -v
```
