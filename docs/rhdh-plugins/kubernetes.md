# Kubernetes + Topology

**Status:** working

Lists cluster objects and draws the Topology card for a catalog Component.

## Required

| Layer | What |
|---|---|
| Helm | `plugins.kubernetes.enabled: true` |
| Packages | in-tree kubernetes backend/frontend + `backstage-community-plugin-topology` |
| App-config | `kubernetes.clusterLocatorMethods` (`authProvider: serviceAccount`) |
| Pod | `automountServiceAccountToken: true` on the Backstage backend (operator defaults **false**) |
| ClusterRole | `rhdh-kubernetes-reader` (`rbac.kubernetesReader: true`) bound to `rbac.serviceAccount` (default `default` in `rhdh`) |
| RHDH CSV | `kubernetes.clusters.read` and `kubernetes.resources.read` on `role:default/developer` |
| `pluginsWithPermission` | must include `kubernetes` |
| Catalog | `backstage.io/kubernetes-id: <label-value>` (omit `backstage.io/kubernetes-namespace` for multi-cluster & multi-namespace discovery) |

Workload must carry label `backstage.io/kubernetes-id=<same value>`. The Hub deployment patch sets that label to `{{ include "rhdh.fullname" . }}` (lab: `developer-hub`).

The Kubernetes / Topology tab is **live cluster objects**, not the Git repo. Catalog annotations only say *what to look for*:

- `backstage.io/kubernetes-id` — must equal a label on Pods/Deployments/Services/Routes across all target namespaces and clusters
- `backstage.io/kubernetes-namespace` — **intentionally omitted** in Golden Path templates so RHDH discovers resources across multiple clusters and differently-named environment namespaces (`edev`, `nprd`, `prod`) using a single shared `catalog-info.yaml`

**What you should see** when a workload is deployed: Deployments, Pods (CPU/memory), Services, Routes, and mesh objects the ClusterRole can list.

**Why `nodejstest` is empty:** the golden path only published Git + catalog. Nothing has been `helm upgrade --install` (or Argo-synced) in `demo-dev` with label `backstage.io/kubernetes-id=nodejstest`. CI running a Jenkinsfile does not create those objects unless a deploy stage does. Kitchen-sink shows Topology because that entity’s id is `developer-hub`, which is the Hub pods already running in `rhdh`.

## Secrets

| Env | Demo |
|---|---|
| `KUBE_API_URL` | unused when url is `https://kubernetes.default.svc` |
| `KUBE_SA_TOKEN` / `KUBE_CA_DATA` | empty on demo — in-cluster token + `skipTLSVerify: true` |

## ClusterRole rules (chart)

`charts/developer-hub/templates/rbac-k8s.yaml` — `get/list/watch` on core workloads, OpenShift routes, Tekton, Argo, Istio/Sail, plus:

- `metrics.k8s.io` pods/nodes (CPU/memory on the card)
- `pods/log`

`rbac.clusterAdmin` stays **false**.

## Known issues

| When | Error | Fix |
|---|---|---|
| 2026-10-08 | Missing Permission `kubernetes.clusters.read` / `kubernetes.resources.read` | CSV + `pluginsWithPermission` (`values.yaml` / `values-demo.yaml`) |
| 2026-10-08 | `ENOENT` `/var/run/secrets/kubernetes.io/serviceaccount/token` | `automountServiceAccountToken: true` on Backstage CR patch |
| 2026-10-08 | `403` `metrics.k8s.io/v1beta1/.../pods` | add metrics (+ pods/log) to `rhdh-kubernetes-reader` |
