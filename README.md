# 🚀 Docker & Kubernetes Masterclass Tutorial

Welcome to the comprehensive, hands-on learning hub for **Docker** (Containerization & Compose) and **Kubernetes** (Container Orchestration).

This repository is structured as an interactive curriculum pairing in-depth theoretical concepts with production-ready Dockerfiles, Compose setups, and Kubernetes manifests.

---

## 📑 Curriculum & Navigation

<details open>
<summary><h3>🐳 Part 1: Docker & Containerization</h3></summary>

| # | Topic | Description & Key Concepts | Theory Guide | Hands-on Code |
| :-: | :--- | :--- | :---: | :---: |
| **01** | **Introduction & Architecture** | Containers vs VMs, Daemon architecture, Namespaces & cgroups, lifecycle commands | [📖 Read Theory](docker/theory/01-introduction-and-architecture.md) | `docker run`, `docker ps` |
| **02** | **Dockerfile & Containerization** | Anatomy of a Dockerfile, Exec vs Shell form, Node.js containerization | [📖 Read Theory](docker/theory/02-dockerfile-and-containerization.md) | [📁 `containerize-express-app/`](docker/containerize-express-app/Dockerfile) |
| **03** | **Build Context & `.dockerignore`** | Context tarballs, ignoring `node_modules`, secret leakage prevention | [📖 Read Theory](docker/theory/03-build-context-and-dockerignore.md) | [📁 `build-context/`](docker/build-context/Dockerfile) |
| **04** | **`CMD` vs `ENTRYPOINT`** | Parameter overriding, binary execution, combining `ENTRYPOINT` + `CMD` | [📖 Read Theory](docker/theory/04-cmd-vs-entrypoint.md) | [📁 `cmd-entrypoint/`](docker/cmd-entrypoint/Dockerfile) |
| **05** | **Storage & Volumes** | Ephemeral layers, Named Volumes vs Bind Mounts vs tmpfs, anonymous volumes | [📖 Read Theory](docker/theory/05-storage-and-volumes.md) | [📁 `volumes/`](docker/volumes/Dockerfile) |
| **06** | **Image Optimization & Caching** | Instruction ordering, Alpine/Slim base images, pruning `devDependencies` | [📖 Read Theory](docker/theory/06-image-optimization-and-caching.md) | [📁 `optimizing-images/`](docker/optimizing-images/) |
| **07** | **Multi-Stage Builds & Distroless** | Compiling TypeScript, build isolation, Google Distroless runtime security | [📖 Read Theory](docker/theory/07-multistage-builds.md) | [📁 `multistage-builds/`](docker/multistage-builds/Dockerfile) |
| **08** | **Frontend Containerization (React)** | Dev container (HMR + Bind Mounts) vs Production multi-stage (Nginx) | [📖 Read Theory](docker/theory/08-frontend-containerization-react.md) | [📁 `react-container/`](docker/react-container/) |
| **09** | **Networking & Multi-Container Apps** | Bridge networks, DNS container discovery, MongoDB + Express setup | [📖 Read Theory](docker/theory/09-networking-and-multicontainer-apps.md) | [📁 `key-value-app/`](docker/key-value-app/) |
| **10** | **Docker Compose Orchestration** | Declarative stacks, services, networks, volumes, Compose Watch (`develop.watch`) | [📖 Read Theory](docker/theory/10-docker-compose.md) | [📁 `compose/`](docker/compose/compose.yaml) |

</details>

---

<details open>
<summary><h3>☸️ Part 2: Kubernetes Orchestration</h3></summary>

| # | Topic | Description & Key Concepts | Theory Guide | Hands-on Manifests |
| :-: | :--- | :--- | :---: | :---: |
| **01** | **Introduction & Architecture** | Control Plane (`apiserver`, `etcd`, `scheduler`) & Worker Nodes (`kubelet`, `kube-proxy`) | [📖 Read Theory](kubernetes/theory/01-introduction-and-architecture.md) | `kubectl cluster-info` |
| **02** | **Pods & Container Management** | Pod lifecycle, shared namespaces, debugging (`exec`, `logs`, `port-forward`, `cp`) | [📖 Read Theory](kubernetes/theory/02-running-containers-and-pods.md) | [📁 `running-containers/`](kubernetes/running-containers/) |
| **03** | **Object Management Techniques** | Imperative CLI vs Declarative (`kubectl apply`), 3-way merge patch, multi-object manifests | [📖 Read Theory](kubernetes/theory/03-object-management-techniques.md) | [📁 `object-management/`](kubernetes/object-management/) |
| **04** | **Labels, Annotations & Selectors** | Equality (`=`, `!=`) vs Set-based (`In`, `NotIn`), `matchExpressions`, label querying | [📖 Read Theory](kubernetes/theory/04-labels-annotations-and-selectors.md) | [📁 `labels-selectors/`](kubernetes/labels-selectors/) |
| **05** | **ReplicaSets & Pod Adoption** | Self-healing, reconciliation loop, scaling, unowned Pod adoption mechanism | [📖 Read Theory](kubernetes/theory/05-replicasets-and-pod-adoption.md) | [📁 `replica-sets/`](kubernetes/replica-sets/) |
| **06** | **Deployments & Rollouts** | `RollingUpdate` vs `Recreate`, `maxSurge`/`maxUnavailable`, rollout history & rollbacks | [📖 Read Theory](kubernetes/theory/06-deployments-and-rollouts.md) | [📁 `deployments/`](kubernetes/deployments/nginx-dep.yaml) |
| **07** | **Services & Networking** | In-cluster DNS discovery, `ClusterIP`, `NodePort`, `LoadBalancer`, `ExternalName` | [📖 Read Theory](kubernetes/theory/07-services-and-networking.md) | [📁 `services/`](kubernetes/services/) |
| **08** | **End-to-End Microservices Demo** | Automated load balancing demo with `color-api` microservice and `traffic-generator` | [📖 Read Theory](kubernetes/theory/08-end-to-end-microservices-demo.md) | [📁 `traffic-generator/`](kubernetes/traffic-generator/) |

</details>

---

## 📁 Repository Structure

```plaintext
├── docker/
│   ├── theory/                        # 📚 Numbered topic-by-topic Docker theory guides
│   ├── containerize-express-app/      # Anatomy of a Node.js Dockerfile
│   ├── build-context/                 # Build context demonstration & .dockerignore
│   ├── DOCKERFILE_NGINX/              # Custom Nginx image optimization
│   ├── cmd-entrypoint/                # CMD vs ENTRYPOINT patterns
│   ├── volumes/                       # Docker storage, volumes & persistence
│   ├── optimizing-images/             # Layer caching, base images, pruning dev deps
│   ├── multistage-builds/             # Multi-stage TypeScript build & Distroless runtime
│   ├── react-container/               # React dev (HMR) vs React prod (Nginx)
│   ├── key-value-app/                 # Multi-container shell orchestrated app + MongoDB
│   ├── compose/                       # Docker Compose specification & Compose Watch
│   └── notes-app/                     # Microservices backend setup with Docker Compose
│
└── kubernetes/
    ├── theory/                        # 📚 Numbered topic-by-topic Kubernetes theory guides
    ├── running-containers/            # Imperative container management cheatsheet & Pods
    ├── object-management/             # Declarative multi-object manifests
    ├── replica-sets/                  # ReplicaSets, self-healing & Pod adoption
    ├── deployments/                   # Zero-downtime rolling updates & rollbacks
    ├── labels-selectors/              # Equality & set-based matchExpressions
    ├── services/                      # ClusterIP, NodePort, and ExternalName services
    ├── color-api/                     # Demo Express microservice for service load balancing
    └── traffic-generator/             # Automated in-cluster traffic generator
```

---

## 🛠️ Prerequisites & Setup

### Docker
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine on Linux.
- Verify installation:
  ```bash
  docker --version
  docker compose version
  ```

### Kubernetes
- Use **Minikube**, **Kind**, or **Docker Desktop (Kubernetes enabled)**.
- Verify cluster access:
  ```bash
  kubectl cluster-info
  kubectl get nodes
  ```

---

## 💡 How to Use this Tutorial

1. **Start with the Theory**: Navigate to [`docker/theory/`](docker/theory/) or [`kubernetes/theory/`](kubernetes/theory/) and read through the numbered modules in sequence.
2. **Review Annotated Code**: Check the corresponding code directories to see real Dockerfiles, Compose specs, and YAML manifests annotated with inline explanations and CLI commands.
3. **Execute & Experiment**: Run the provided CLI commands and test manifests locally to observe behaviors like layer caching, self-healing, rolling updates, and service load balancing in real-time.
