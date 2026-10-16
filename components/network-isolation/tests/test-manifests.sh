#!/usr/bin/env bash
# Unit: kustomize renders isolation policies + seeder. System: lab ns only,
# OpenShift ingress/monitoring/Dev Spaces/DW operator allowed, no catch-all CIDR.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/../../.." && pwd)"
DIR="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

oc kustomize "$DIR" >"$OUT" || { echo "FAIL kustomize network-isolation"; exit 1; }

need() {
  if grep -q -e "$1" "$OUT"; then
    echo "OK  $1"
  else
    echo "FAIL missing $1"
    fail=1
  fi
}
forbid() {
  if grep -q -e "$1" "$OUT"; then
    echo "FAIL must not contain $1"
    fail=1
  else
    echo "OK  no $1"
  fi
}

need "kind: NetworkPolicy"
need "kind: CronJob"
need "name: network-isolation-seeder"
need "name: allow-from-same-namespace"
need "name: allow-from-openshift-ingress"
need "name: allow-from-openshift-monitoring"
need "name: allow-from-openshift-devspaces"
need "name: allow-from-devworkspace-operator"
need "network.openshift.io/policy-group: ingress"
need "network.openshift.io/policy-group: monitoring"
need "kubernetes.io/metadata.name: rhdh"
need "kubernetes.io/metadata.name: openshift-operators"
need "kubernetes.io/metadata.name: cnpg-system"
need "kubernetes.io/metadata.name: openshift-devspaces"

for ns in jenkins vault sonarqube ldap saas-stubs squid rhdh rhdh-dr demo-dev istio-mesh-tools; do
  need "namespace: ${ns}"
done

forbid "0.0.0.0/0"
forbid "namespace: istio-system"
forbid "namespace: openshift-ingress"
forbid "namespace: openshift-gitops"
forbid "namespace: openshift-devspaces"
forbid "kind: Subscription"

python3 - "$OUT" <<'PY'
import re
import sys
from collections import defaultdict
text = open(sys.argv[1]).read()
docs = [d for d in text.split("\n---\n") if d.strip()]
by_ns = defaultdict(set)
fail = 0
for d in docs:
    if not re.search(r"(?m)^kind: NetworkPolicy$", d):
        continue
    ns = None
    name = None
    for line in d.splitlines():
        if line.startswith("  namespace:"):
            ns = line.split(":", 1)[1].strip()
        if line.startswith("  name:") and name is None:
            name = line.split(":", 1)[1].strip()
    if not ns or not name:
        print("FAIL could not parse NetworkPolicy")
        fail = 1
        continue
    by_ns[ns].add(name)
    if "policyTypes:" not in d or "- Ingress" not in d:
        print("FAIL policyTypes Ingress", ns, name)
        fail = 1
base = {
    "allow-from-same-namespace",
    "allow-from-openshift-ingress",
    "allow-from-openshift-monitoring",
    "allow-from-openshift-devspaces",
    "allow-from-devworkspace-operator",
}
tools = {"jenkins", "vault", "sonarqube", "ldap", "saas-stubs", "squid"}
ops = {"rhdh", "rhdh-dr"}
for ns, names in sorted(by_ns.items()):
    if not base <= names:
        print("FAIL", ns, "missing base", base - names)
        fail = 1
    if ns in tools and "allow-from-rhdh" not in names:
        print("FAIL", ns, "missing allow-from-rhdh")
        fail = 1
    if ns not in tools and "allow-from-rhdh" in names:
        print("FAIL", ns, "must not allow-from-rhdh")
        fail = 1
    if ns in ops and "allow-from-platform-operators" not in names:
        print("FAIL", ns, "missing operators allow")
        fail = 1
if fail:
    sys.exit(1)
print("OK ", len(by_ns), "namespaces", sum(len(v) for v in by_ns.values()), "policies")
PY

# Seeder skip list (no cluster needed).
# shellcheck source=../seeder/apply.sh
# shellcheck disable=SC1091
source "$DIR/seeder/apply.sh"
assert_skip() {
  if should_isolate "$1"; then
    echo "FAIL should skip $1"
    fail=1
  else
    echo "OK  skip $1"
  fi
}
assert_seed() {
  if should_isolate "$1"; then
    echo "OK  seed $1"
  else
    echo "FAIL should seed $1"
    fail=1
  fi
}
assert_skip kube-system
assert_skip openshift-ingress
assert_skip openshift-devspaces
assert_skip default
assert_skip istio-system
assert_skip istio-cni
assert_skip ztunnel
assert_skip cnpg-system
assert_skip dedicated-admin
assert_skip open-cluster-management-agent-addon
assert_seed jenkins
assert_seed demo-dev
assert_seed cluster-admin-devspaces
assert_seed acme-new-app

grep -q "workspaces-namespace" "$DIR/seeder/apply.sh" && echo "OK  seeder skips Che workspace ns" || {
  echo "FAIL seeder must skip Che workspace namespaces"
  fail=1
}

APP="$REPO/argocd/apps/network-isolation.yaml"
if [ -f "$APP" ]; then
  grep -q "path: components/network-isolation" "$APP" && echo "OK  app path" || { echo "FAIL app path"; fail=1; }
  grep -q "targetRevision: main" "$APP" && echo "OK  app revision" || { echo "FAIL app revision"; fail=1; }
else
  echo "FAIL missing Argo app"
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "Network isolation tests failed"
  exit 1
fi
echo "Network isolation tests passed"
