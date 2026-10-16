#!/usr/bin/env bash
# Unit: operator-only kustomize has Subscriptions, no CRs day-2 owns.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
fail=0
need_cmd() { command -v "$1" >/dev/null || { echo "missing $1" >&2; exit 1; }; }
need_cmd oc

need() {
  if grep -q -e "$1" "$2"; then
    echo "OK  $1"
  else
    echo "FAIL missing $1 in $3"
    fail=1
  fi
}
forbid() {
  if grep -q -e "$1" "$2"; then
    echo "FAIL must not contain $1 in $3"
    fail=1
  else
    echo "OK  no $1 in $3"
  fi
}

echo "== operator-only kustomize =="
RHDH="$(mktemp)"; SM="$(mktemp)"; DS="$(mktemp)"; NET="$(mktemp)"; GIT="$(mktemp)"
trap 'rm -f "$RHDH" "$SM" "$DS" "$NET" "$GIT"' EXIT

oc kustomize "$ROOT/components/developer-hub/operator" >"$RHDH"
oc kustomize "$ROOT/components/service-mesh/operator" >"$SM"
oc kustomize "$ROOT/components/devspaces/operator" >"$DS"
oc kustomize "$ROOT/components/cluster-network/base" >"$NET"
oc kustomize "$ROOT/components/openshift-gitops/base" >"$GIT"

need "kind: Subscription" "$RHDH" rhdh
need "name: rhdh" "$RHDH" rhdh
need "channel: fast-1.10" "$RHDH" rhdh
need "namespace: openshift-operators" "$RHDH" rhdh
forbid "kind: Backstage" "$RHDH" rhdh
forbid "kind: OperatorGroup" "$RHDH" rhdh

need "name: servicemeshoperator3" "$SM" mesh
need "name: kiali-ossm" "$SM" mesh
need "source: redhat-operators" "$SM" mesh
forbid "kind: Istio" "$SM" mesh
forbid "kind: Kiali" "$SM" mesh
forbid "kind: CatalogSource" "$SM" mesh

need "name: devspaces" "$DS" devspaces
need "kind: Namespace" "$DS" devspaces
forbid "kind: CheCluster" "$DS" devspaces

need "routingViaHost" "$NET" network
need "kind: Job" "$NET" network
need "kind: ClusterRole" "$NET" network

need "kind: ClusterRoleBinding" "$GIT" gitops
need "name: openshift-gitops-application-controller" "$GIT" gitops

echo "== Argo apps =="
for app in rhdh-operator service-mesh-operator devspaces-operator cluster-network; do
  f="$ROOT/argocd/apps/${app}.yaml"
  need "RHDH-SM-DevSpaces" "$f" "$app"
  need "demo/udi-devspaces" "$f" "$app"
done
need "components/developer-hub/operator" "$ROOT/argocd/apps/rhdh-operator.yaml" rhdh-app
need "components/service-mesh/operator" "$ROOT/argocd/apps/service-mesh-operator.yaml" mesh-app
need "components/devspaces/operator" "$ROOT/argocd/apps/devspaces-operator.yaml" ds-app
forbid "charts/developer-hub" "$ROOT/argocd/apps/rhdh-operator.yaml" rhdh-app

if [ "$fail" -ne 0 ]; then
  echo "Operator app tests failed"
  exit 1
fi
echo "Operator app tests passed"
