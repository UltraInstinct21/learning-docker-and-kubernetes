#!/bin/bash
# ==============================================================================
# THEORY & CHEATSHEET: RUNNING CONTAINERS / PODS IN KUBERNETES
# ==============================================================================
# In Kubernetes, containers are never run directly on host machines; they are always
# encapsulated inside Pods.
#
# RUNNING PODS IMPERATIVELY:
# The `kubectl run` command is the Kubernetes equivalent of `docker run`.
#
# ------------------------------------------------------------------------------
# 1. BASIC POD CREATION (IMPERATIVE)
# ------------------------------------------------------------------------------
# Run a basic Nginx pod:
# kubectl run my-nginx --image=nginx:alpine

# Run a pod with custom labels:
# kubectl run my-nginx --image=nginx:alpine --labels="app=web,env=dev"

# Run a pod and expose container port:
# kubectl run my-nginx --image=nginx:alpine --port=80

# Run a pod with environment variables:
# kubectl run my-app --image=alpine --env="DB_HOST=10.0.0.1" --env="DB_PORT=5432"

# ------------------------------------------------------------------------------
# 2. GENERATING YAML MANIFESTS (DRY-RUN CLIENT)
# ------------------------------------------------------------------------------
# The best practice to quickly scaffold YAML without creating the resource:
# kubectl run my-nginx --image=nginx:alpine --port=80 --dry-run=client -o yaml > pod.yaml

# ------------------------------------------------------------------------------
# 3. INTERACTIVE PODS & DEBUGGING
# ------------------------------------------------------------------------------
# Run an interactive temporary container (deleted automatically on exit `--rm`):
# kubectl run -it --rm debug-shell --image=busybox -- sh
# kubectl run -it --rm curl-test --image=curlimages/curl -- curl http://my-service

# Execute commands in a currently running pod:
# kubectl exec my-nginx -- ls -la /usr/share/nginx/html
# kubectl exec -it my-nginx -- sh

# View stdout/stderr logs of a pod:
# kubectl logs my-nginx
# kubectl logs -f my-nginx                # Stream live logs
# kubectl logs --tail=50 my-nginx         # View last 50 lines
# kubectl logs --previous my-nginx        # View logs of previously crashed instance

# Copy files between host and pod:
# kubectl cp ./index.html my-nginx:/usr/share/nginx/html/index.html
# kubectl cp my-nginx:/etc/nginx/nginx.conf ./nginx.conf

# Forward local port to pod:
# kubectl port-forward pod/my-nginx 8080:80

# ------------------------------------------------------------------------------
# 4. INSPECTION & TROUBLESHOOTING
# ------------------------------------------------------------------------------
# List pods with extended details (IP, Node):
# kubectl get pods -o wide

# Describe pod (view lifecycle events, container exit codes, crash loops):
# kubectl describe pod my-nginx

# View full live YAML/JSON of pod:
# kubectl get pod my-nginx -o yaml

# ------------------------------------------------------------------------------
# 5. CLEANUP
# ------------------------------------------------------------------------------
# Delete specific pod:
# kubectl delete pod my-nginx

# Force delete unresponsive pod immediately:
# kubectl delete pod my-nginx --grace-period=0 --force
# ==============================================================================
