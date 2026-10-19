# Acme Platform GitOps

OpenShift GitOps (ArgoCD) repository for deploying and managing:
- **Red Hat OpenShift Service Mesh 2.x** (Istio-based, with Kiali)
- **Red Hat Developer Hub (RHDH)** (Backstage-based internal developer portal)

---

## Repository Layout

```
acme/
├── bootstrap/
│   └── root-app.yaml                     # App of Apps — applied once to bootstrap
├── argocd/
│   ├── projects/
│   │   └── acme.yaml                # Scoped ArgoCD AppProject
│   └── apps/
│       ├── service-mesh.yaml             # ArgoCD Application → service-mesh overlay
│       └── developer-hub.yaml            # ArgoCD Application → developer-hub overlay
└── components/
    ├── service-mesh/
    │   ├── base/
    │   │   ├── kustomization.yaml
    │   │   ├── namespace.yaml
    │   │   ├── operator/                  # Kiali + Service Mesh operator subscriptions
    │   │   └── instance/                  # SMCP, SMMR, Kiali CR
    │   └── overlays/production/
    │       └── kustomization.yaml         # Production resource patches
    └── developer-hub/
        ├── base/
        │   ├── kustomization.yaml
        │   ├── namespace.yaml
        │   ├── operator/                  # RHDH operator subscription
        │   └── instance/                  # Backstage CR, ConfigMaps, RBAC, Secrets
        └── overlays/production/
            └── kustomization.yaml         # Production replica + DB patches
```

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| `oc` / `kubectl` | ≥ 4.14 | Cluster access |
| `kustomize` | ≥ 5.x | Validate manifests locally |
| `kubeseal` | ≥ 0.26 | Encrypt secrets before committing |
| OpenShift GitOps Operator | installed | ArgoCD runtime |
| Sealed Secrets Controller | installed | Secret decryption on cluster |

---

## Initial Bootstrap

Day-1 operators and lab tools. Day-2 CRs (Backstage, Istio, CheCluster, CNPG Cluster) are [rhdh-platform-gitops](https://github.com/rmallam-rhdh/rhdh-platform-gitops).

See [bootstrap/README.md](bootstrap/README.md) for the two-Application bring-up.

### 1. Clone

```bash
git clone https://github.com/rmallam-rhdh/RHDH-SM-DevSpaces
cd RHDH-SM-DevSpaces
git checkout main
```

### 2. Point Argo CD at this repo, then at day-2

```bash
oc apply -f bootstrap/root-app.yaml
# After operator CSVs are Succeeded, apply Secret rhdh-secrets and
# rhdh-platform-gitops argocd/app-of-apps.yaml — see bootstrap/README.md
```

---

## Component Details

### OpenShift Service Mesh

| Resource | Namespace | Description |
|----------|-----------|-------------|
| `Subscription/kiali-ossm` | `openshift-operators` | Kiali Operator |
| `Subscription/servicemeshoperator` | `openshift-operators` | Service Mesh Operator |
| `ServiceMeshControlPlane/acme-smcp` | `openshift-service-mesh` | Istio control plane (mTLS enabled) |
| `ServiceMeshMemberRoll/default` | `openshift-service-mesh` | Enrolls `rhdh` and app namespaces |
| `Kiali/kiali` | `openshift-service-mesh` | Mesh observability UI |

**Enroll a new namespace into the mesh:** add it to `spec.members` in `components/service-mesh/base/instance/smmr.yaml`.

### Red Hat Developer Hub

| Resource | Namespace | Description |
|----------|-----------|-------------|
| `Subscription/rhdh` | `rhdh` | RHDH Operator |
| `ConfigMap/app-config-rhdh` | `rhdh` | Backstage `app-config.yaml` |
| `ConfigMap/dynamic-plugins-rhdh` | `rhdh` | Dynamic plugin configuration |
| `SealedSecret/rhdh-secrets` | `rhdh` | Env vars (OAuth tokens, keys) |
| `Backstage/acme` | `rhdh` | Backstage CR — triggers full deployment |
| `ClusterRole/rhdh-kubernetes-reader` | cluster | Read-only k8s access for the portal |

**Access the portal:** After sync, the Route is auto-created by the operator:
```bash
oc get route -n rhdh
```

---

## Adding Application Namespaces to the Mesh

1. Add the namespace to `components/service-mesh/base/instance/smmr.yaml`:
   ```yaml
   spec:
     members:
       - rhdh
       - my-new-app-namespace   # ← add here
   ```
2. Commit and push — ArgoCD auto-syncs the SMMR.

---

## Upgrade Strategy

- **Service Mesh:** Update `spec.version` in `smcp.yaml` (e.g. `v2.6` → `v2.7`).
- **RHDH Operator:** Update `spec.channel` in `operator/subscription.yaml` (e.g. `fast-1.4` → `fast-1.5`).
- **App config changes:** Edit `app-config-cm.yaml`; ArgoCD will roll the Backstage pod.

---

## Security Notes

- **mTLS** is enforced by default between all mesh-enrolled services (`automtls: true`).
- **Outbound traffic policy** is `REGISTRY_ONLY` — only registered services can receive traffic.
- **Secrets** are managed via Sealed Secrets. Never commit plain `Secret` objects.
- **RBAC:** RHDH has read-only cluster access scoped to safe resource types.
