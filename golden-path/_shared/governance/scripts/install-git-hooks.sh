#!/usr/bin/env bash
# Install git hooks for this repository (run once after clone).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

chmod +x scripts/quality-gate.sh .githooks/pre-commit .githooks/pre-push 2>/dev/null || true

if command -v pre-commit >/dev/null 2>&1; then
  echo "Installing hooks via pre-commit framework..."
  pre-commit install
  pre-commit install --hook-type pre-push
else
  echo "pre-commit not found — using .githooks/ (git config core.hooksPath)"
  git config core.hooksPath .githooks
fi

echo "Git hooks installed. Bypass only in emergencies: git commit --no-verify"
