#!/usr/bin/env bash
# Apply default-deny ingress NetworkPolicies to every eligible namespace.
# Skips OpenShift/Kubernetes/mesh system namespaces and Che-managed workspace
# namespaces (CheCluster networking.networkPolicy already stamps those).
set -euo pipefail
KUBECTL="${KUBECTL:-kubectl}"

should_isolate() {
  local ns="$1"
  case "$ns" in
    kube-*|openshift-*|default|istio-system|istio-cni|ztunnel|cnpg-system|dedicated-admin)
      return 1
      ;;
  esac
  [[ "$ns" == open-cluster-management* ]] && return 1
  return 0
}

policies_yaml() {
  local ns="$1"
  cat <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-same-namespace
  namespace: ${ns}
  labels:
    app.kubernetes.io/part-of: acme-platform
    app.kubernetes.io/component: network-isolation
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector: {}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-openshift-ingress
  namespace: ${ns}
  labels:
    app.kubernetes.io/part-of: acme-platform
    app.kubernetes.io/component: network-isolation
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              network.openshift.io/policy-group: ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-openshift-monitoring
  namespace: ${ns}
  labels:
    app.kubernetes.io/part-of: acme-platform
    app.kubernetes.io/component: network-isolation
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              network.openshift.io/policy-group: monitoring
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-openshift-devspaces
  namespace: ${ns}
  labels:
    app.kubernetes.io/part-of: acme-platform
    app.kubernetes.io/component: network-isolation
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: openshift-devspaces
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-devworkspace-operator
  namespace: ${ns}
  labels:
    app.kubernetes.io/part-of: acme-platform
    app.kubernetes.io/component: network-isolation
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: openshift-operators
EOF
}

seed_namespace() {
  local ns="$1"
  policies_yaml "$ns" | "$KUBECTL" apply --server-side --field-manager=network-isolation-seeder -f -
}

main() {
  local ns component isolation
  while read -r ns; do
    [ -n "$ns" ] || continue
    if ! should_isolate "$ns"; then
      echo "skip system $ns"
      continue
    fi
    isolation="$("$KUBECTL" get ns "$ns" -o jsonpath='{.metadata.labels.network\.acme\.io/isolation}' 2>/dev/null || true)"
    if [ "$isolation" = "disabled" ]; then
      echo "skip isolation=disabled $ns"
      continue
    fi
    component="$("$KUBECTL" get ns "$ns" -o jsonpath='{.metadata.labels.app\.kubernetes\.io/component}' 2>/dev/null || true)"
    if [ "$component" = "workspaces-namespace" ]; then
      echo "skip Che workspace $ns"
      continue
    fi
    echo "seed $ns"
    seed_namespace "$ns"
  done < <("$KUBECTL" get ns -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
