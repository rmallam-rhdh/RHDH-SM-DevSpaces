#!/usr/bin/env bash
# Local / Dev Spaces quality checks — same entrypoint used in devfile commands and CI.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

RUN_LINT=false
RUN_TEST=true
RUN_SNYK=false
RUN_SONAR=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lint-only) RUN_LINT=true; RUN_TEST=false; shift ;;
    --sonar) RUN_SONAR=true; shift ;;
    --snyk) RUN_SNYK=true; shift ;;
    *) echo "Unknown option: $1"; exit 2 ;;
  esac
done

if [[ "$RUN_LINT" == true ]]; then
  if [[ -f package.json ]]; then
    npm run lint --if-present
  elif [[ -f build.gradle.kts || -f build.gradle ]]; then
    ./gradlew -q spotlessCheck
  fi
  exit 0
fi

if [[ -f package.json ]]; then
  npm test
elif [[ -f build.gradle.kts || -f build.gradle ]]; then
  ./gradlew -q test
fi

if [[ "$RUN_SNYK" == true ]] && command -v snyk >/dev/null 2>&1; then
  snyk test --severity-threshold=high || true
fi

if [[ "$RUN_SONAR" == true ]] && [[ -n "${SONAR_TOKEN:-}" ]] && command -v sonar-scanner >/dev/null 2>&1; then
  sonar-scanner \
    -Dsonar.projectKey="${SONAR_PROJECT_KEY:-$(basename "$ROOT")}" \
    -Dsonar.host.url="${SONAR_HOST_URL}" \
    -Dsonar.login="${SONAR_TOKEN}"
fi

echo "quality-gate: OK"
