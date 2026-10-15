#!/usr/bin/env bash
# Unit + system tests for Digi 2.0 custom Dev Spaces UDI image.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CF="${ROOT}/Containerfile"
FAIL=0

pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*"; FAIL=$((FAIL + 1)); }

echo "==> Unit: Containerfile presence and HLD §13.5 tooling"
[[ -f "$CF" ]] || fail "missing Containerfile"
grep -qE 'FROM \$\{UDI_BASE\}|FROM registry\.redhat\.io/devspaces/udi' "$CF" \
  || fail "must FROM Red Hat Dev Spaces UDI base"
grep -q 'java-17-openjdk' "$CF" || fail "missing Java 17"
grep -q 'java-21-openjdk' "$CF" || fail "missing Java 21"
grep -q 'GRADLE_VERSION' "$CF" || fail "missing Gradle pin"
grep -q 'NODE_VERSION=20\|nodejs:20\|NODEJS_VERSION' "$CF" || fail "missing Node 20"
grep -q 'sonar-scanner' "$CF" || fail "missing Sonar Scanner"
grep -q 'snyk' "$CF" || fail "missing Snyk CLI"
grep -q 'pre-commit' "$CF" || fail "missing pre-commit"
grep -q 'yq' "$CF" || fail "missing yq"
grep -q 'update-ca-trust' "$CF" || fail "missing corporate CA trust step"
grep -q 'USER 10001' "$CF" || fail "must end as Dev Spaces non-root user 10001"
[[ -f "${ROOT}/config/npmrc" ]] || fail "missing config/npmrc"
[[ -f "${ROOT}/config/gradle.properties" ]] || fail "missing config/gradle.properties"
[[ -d "${ROOT}/certs" ]] || fail "missing certs/ directory"

if [[ "$FAIL" -eq 0 ]]; then
  pass "Containerfile and config match HLD tooling list"
fi

echo "==> System: podman build (skipped if no podman or registry auth)"
if ! command -v podman >/dev/null 2>&1; then
  echo "SKIP: podman not installed"
elif ! podman info >/dev/null 2>&1; then
  echo "SKIP: podman not usable in this environment"
else
  # Build only validates Dockerfile parse + early layers if pull fails with clear exit.
  set +e
  OUT="$(podman build --pull=missing -t digi20-devspaces-udi:test \
    -f "$CF" "$ROOT" 2>&1)"
  RC=$?
  set -e
  if [[ "$RC" -eq 0 ]]; then
    pass "podman build succeeded"
    # Runtime smoke (tools on PATH)
    for cmd in java gradle node npm jq yq curl openssl sonar-scanner snyk pre-commit; do
      if podman run --rm digi20-devspaces-udi:test bash -lc "command -v $cmd" >/dev/null 2>&1; then
        pass "runtime has $cmd"
      else
        fail "runtime missing $cmd"
      fi
    done
  elif echo "$OUT" | grep -qiE 'unauthorized|authentication required|denied|pull.*fail|unable to|error.*registry'; then
    echo "SKIP: cannot pull UDI base (registry.redhat.io login required)"
    echo "$OUT" | tail -5
  else
    fail "podman build failed unexpectedly"
    echo "$OUT" | tail -40
  fi
fi

if [[ "$FAIL" -gt 0 ]]; then
  echo "RESULT: $FAIL failure(s)"
  exit 1
fi
echo "RESULT: OK"
exit 0
