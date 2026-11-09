# Topic 12: Kubernetes Storage (emptyDir, PersistentVolume & PersistentVolumeClaim)

## 1. Why Storage Matters in Kubernetes

Containers are ephemeral by design: their writable layer is destroyed when the
container stops or restarts. For any stateful workload (databases, file uploads,
caches, logs), you need a **Volume** — a directory accessible to containers in a
Pod with a lifecycle that can outlive individual containers.

Kubernetes offers two broad categories of storage:

| Category | Lifecycle | Survives Container Restart? | Survives Pod Delete? | Example |
| :--- | :--- | :--- | :--- | :--- |
| **Ephemeral** | Tied to the Pod/Node | Yes | No | `emptyDir`, `hostPath` |
| **Persistent** | Independent of the Pod | Yes | Yes | `PersistentVolume` + `PVC` |

```
                     Storage Options in a Pod
+--------------------------------------------------------------------------+
|                                                                          |
|  +---------------------------------------------------------------+      |
|  |                      POD (on Node)                            |      |
|  |                                                               |      |
|  |  +------------------------+  +---------------------------+   |      |
|  |  | Container A            |  | Container B               |   |      |
|  |  | (main app)             |  | (sidecar / logger)        |   |      |
|  |  +-----------+-----------+  +-----------+---------------+   |      |
|  |             |                       |                       |   |      |
|  |             v                       v                       |   |      |
|  |  +----------------------+  +-----------------------+      |   |      |
|  |  |   emptyDir Volume    |  |  PersistentVolumeClaim|      |   |      |
|  |  |  (ephemeral, Node    |  |  (bound to a PV,      |      |   |      |
|  |  |   local storage)     |  |  survives Pod delete) |      |   |      |
|  |  +----------------------+  +-----------------------+      |   |      |
|  |             |                       |                       |   |      |
|  |             v (mountPath)           v (mountPath)           |   |      |
|  |  /scratch                       /data                        |   |      |
|  |                                                             |   |      |
|  +---------------------------------------------------------------+      |
|                                                                          |
|  Node-local disk                      External / Network / Local PV     |
+--------------------------------------------------------------------------+
```

## 2. emptyDir — Ephemeral Scratch Storage

An `emptyDir` volume is created when a Pod is assigned to a Node and exists only
as long as that Pod runs on that Node.

**Key characteristics:**
- **Ephemeral:** Data is **lost** when the Pod is deleted, evicted, or rescheduled to another Node.
- **Container-restart safe:** Survives individual container restarts within the same Pod.
- **Shared:** All containers in the Pod can mount the same `emptyDir` (useful for sidecar patterns).
- **Medium:** Defaults to the Node's disk. Set `emptyDir.medium: "Memory"` to use a RAM-backed tmpfs (faster, but data lost on Node reboot and counts against container memory).

```yaml
volumes:
  - name: temporary-storage
    emptyDir: {}
```

### Hands-On Manifest: `kubernetes/storage-and-percistance/empty-dir-example.yaml`

Two containers (`empty-dir-writer` and `empty-dir-reader`) mount the same
`temporary-storage` emptyDir at different paths. The reader mounts it
`readOnly: true`, demonstrating read-only access.

```bash
kubectl apply -f kubernetes/storage-and-percistance/empty-dir-example.yaml
kubectl describe pod empty-dir-demo
kubectl exec -it empty-dir-demo -c empty-dir-writer -- cat /usr/share/temp/hello.txt
kubectl delete pod empty-dir-demo   # data is now lost (ephemeral!)
```

> [!IMPORTANT]
> `emptyDir` data does **NOT** survive Pod deletion. Use it only for scratch
> space, caching, or sidecar sharing — never for durable application data.

## 3. PersistentVolume (PV) — Cluster Storage Resource

A `PersistentVolume` is a cluster-level object representing a piece of storage
(e.g. a local disk, cloud EBS/Persistent Disk, NFS). It is provisioned by an
administrator (or dynamically by a StorageClass) and exists independently of any
Pod.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-volume
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce            # RWO: mounted read-write by a single Node
  persistentVolumeReclaimPolicy: Retain  # Keep volume after PVC is deleted
  storageClassName: local-storage
  local:
    path: /mnt/disks/local1
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values: ['minikube']
```

| Field | Meaning |
| :--- | :--- |
| `capacity.storage` | Size of the volume (e.g. `1Gi`) |
| `accessModes` | `ReadWriteOnce` (1 node), `ReadOnlyMany`, `ReadWriteMany` |
| `persistentVolumeReclaimPolicy` | `Retain` (keep), `Delete` (remove with PVC), `Recycle` |
| `storageClassName` | Groups PVs for dynamic provisioning / PVC binding |
| `nodeAffinity` | For local PVs: pins the volume to a specific Node |

**Volume lifecycle phases:** `Available` → `Bound` (claimed by a PVC) → `Released` → `Failed`/`Available` (reclaimed).

## 4. PersistentVolumeClaim (PVC) — Namespace Storage Request

A `PersistentVolumeClaim` is a namespace-scoped request for storage consumed by
a Pod. Kubernetes matches the PVC to an available PV that satisfies its
`storage`, `accessModes`, and `storageClassName`.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-volume-claim
spec:
  resources:
    requests:
      storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
```

The Pod then references the claim via `spec.volumes[].persistentVolumeClaim.claimName`.

## 5. Hands-On Manifest: `kubernetes/storage-and-percistance/local-volume.yaml`

This single file creates the full PV → PVC → Pod chain:

1. **PersistentVolume (`local-volume`)** — 1Gi local disk at `/mnt/disks/local1`, pinned to the `minikube` node via `nodeAffinity`, reclaim policy `Retain`.
2. **PersistentVolumeClaim (`local-volume-claim`)** — requests 1Gi with `ReadWriteOnce`.
3. **Pod (`empty-dir-demo`)** — mounts the claim at `/mnt/disks/local1` so data persists across container restarts and Pod rescheduling (on the same node).

```bash
kubectl apply -f kubernetes/storage-and-percistance/local-volume.yaml
kubectl get pv,pvc
kubectl describe pv local-volume
kubectl describe pod empty-dir-demo
```

> [!TIP]
> Check binding status with `kubectl get pv,pvc`. A successfully bound PVC shows `STATUS: Bound` for both the PV and PVC.

## 6. emptyDir vs. PersistentVolume — Quick Comparison

| Aspect | `emptyDir` | `PersistentVolume` + `PVC` |
| :--- | :--- | :--- |
| Lifecycle | Tied to Pod | Independent of Pod |
| Survives Pod delete? | ❌ No | ✅ Yes |
| Survives container restart? | ✅ Yes | ✅ Yes |
| Survives Node failure? | ❌ No | ✅ Yes (if PV is network-backed) |
| Use case | Scratch space, sidecar sharing, cache | Databases, uploads, durable state |
| Provisioning | Automatic (inline) | Admin-provisioned or dynamic (StorageClass) |

## 7. Related Curriculum Topics

- **Topic 05 (Docker):** Storage & Volumes — Docker named volumes vs bind mounts (`docker/theory/05-storage-and-volumes.md`)
- **Topic 10 (K8s):** Resource Requests, Limits & Quotas — pairs with storage for capacity planning (`kubernetes/theory/10-resource-requests-limits-and-quotas.md`)
- **Topic 11 (K8s):** Health Probes — containers with volumes often probe health on file readiness (`kubernetes/theory/11-health-probes-liveness-readiness-startup.md`)

## 8. Storage CLI Commands

```bash
# 1. Apply emptyDir demo
kubectl apply -f kubernetes/storage-and-percistance/empty-dir-example.yaml

# 2. Apply PV + PVC + Pod demo
kubectl apply -f kubernetes/storage-and-percistance/local-volume.yaml

# 3. View PersistentVolumes and PersistentVolumeClaims
kubectl get pv
kubectl get pvc
kubectl get pv,pvc

# 4. Inspect a PV in detail (capacity, nodeAffinity, reclaim policy)
kubectl describe pv local-volume

# 5. Inspect a PVC (binding status, capacity, access modes)
kubectl describe pvc local-volume-claim

# 6. Confirm a Pod is consuming the mounted volume
kubectl describe pod empty-dir-demo

# 7. List storage classes available in the cluster
kubectl get storageclass

# 8. Delete a PVC (volume handling depends on reclaim policy)
kubectl delete pvc local-volume-claim
```
