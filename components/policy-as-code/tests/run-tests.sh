#!/usr/bin/env bash
# Unit + Kyverno-CLI tests for ServiceNow change-number format.
# Regex must stay in sync with:
#   - ClusterPolicy require-snow-change-number (check-snow-change-format)
#   - Jenkins Promote stage (SNOW_CHANGE_NUMBER ==~ /^CHG[0-9]{7}$/)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PAC="$(cd "${ROOT}/.." && pwd)"
REGEX='^CHG[0-9]{7}$'
failures=0

pass() { printf '  PASS  %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; failures=$((failures + 1)); }

expect_match() {
  local value="$1"
  if [[ "${value}" =~ ${REGEX} ]]; then
    pass "match ${value}"
  else
    fail "expected match for ${value}"
  fi
}

expect_reject() {
  local value="$1"
  if [[ "${value}" =~ ${REGEX} ]]; then
    fail "expected reject for ${value}"
  else
    pass "reject ${value}"
  fi
}

echo "== regex unit tests (${REGEX})"
expect_match 'CHG0001234'
expect_match 'CHG9999999'
expect_match 'CHG0000001'
expect_reject ''
expect_reject 'CHG-1234'
expect_reject 'CHG1234'
expect_reject 'chg0001234'
expect_reject 'INC0001234'
expect_reject 'PRB0001234'
expect_reject 'RITM0001234'
expect_reject 'CHG123'
expect_reject 'CHG00012345'
expect_reject 'CHG0001234 '
expect_reject ' CHG0001234'
expect_reject 'CHG0001234/1'

if [[ "${failures}" -ne 0 ]]; then
  echo "regex unit tests failed: ${failures}"
  exit 1
fi
echo "regex unit tests passed"

IMAGE="${KYVERNO_CLI_IMAGE:-ghcr.io/kyverno/kyverno-cli:v1.13.4}"
echo "== kyverno CLI tests (${IMAGE})"
podman run --rm \
  -v "${PAC}:/workspace:Z" \
  -w /workspace/tests \
  "${IMAGE}" \
  test /workspace/tests
