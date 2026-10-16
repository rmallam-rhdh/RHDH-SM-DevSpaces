#!/usr/bin/env bash
# Templates fetch skeletons from this repo/branch, not rmallam/RHDH.
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

if grep -R -n 'github.com/rmallam/RHDH/tree' "$DIR" --include='*.yaml'; then
  echo "FAIL templates still fetch from rmallam/RHDH"
  fail=1
else
  echo "OK  no rmallam/RHDH/tree fetches"
fi

if grep -R -n 'tree/rhdh-demo/' "$DIR" --include='*.yaml'; then
  echo "FAIL still pointing at branch rhdh-demo"
  fail=1
else
  echo "OK  no rhdh-demo branch"
fi

if grep -R -n 'rosa-89s85' "$DIR" --include='*.yaml'; then
  echo "FAIL leftover dead-cluster URLs"
  fail=1
else
  echo "OK  no rosa-89s85"
fi

need() {
  if grep -q "$1" "$2"; then
    echo "OK  $1 in $(basename "$2")"
  else
    echo "FAIL missing $1 in $2"
    fail=1
  fi
}

need "RHDH-SM-DevSpaces/tree/main/golden-path/demo/skeleton-nodejs-golden-path" "$DIR/template-nodejs-golden-path.yaml"
need "RHDH-SM-DevSpaces/tree/main/golden-path/demo/skeleton-quarkus-golden-path" "$DIR/template-quarkus-golden-path.yaml"
need "RHDH-SM-DevSpaces/tree/main/golden-path/demo/skeleton-nodejs-website" "$DIR/template-nodejs-website.yaml"
need "RHDH-SM-DevSpaces/tree/main/golden-path/demo/skeleton-plugin-kitchen-sink" "$DIR/template-plugin-kitchen-sink.yaml"
need "RHDH-SM-DevSpaces/tree/main/golden-path/demo/skeleton-node-udi" "$DIR/template-node-udi-devspaces.yaml"
need "kind: Deployment" "$DIR/skeleton-nodejs-golden-path/chart/templates/deployment.yaml"
need "kind: Deployment" "$DIR/skeleton-quarkus-golden-path/chart/templates/deployment.yaml"
need "kind: Deployment" "$DIR/skeleton-nodejs-website/chart/templates/deployment.yaml"

if [ "$fail" -ne 0 ]; then
  echo "Skeleton URL tests failed"
  exit 1
fi
echo "Skeleton URL tests passed"
