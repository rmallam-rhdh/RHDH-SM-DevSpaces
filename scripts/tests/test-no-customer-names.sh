#!/usr/bin/env bash
# Fail if customer denylist strings appear outside the Cursor rule.
# The needle is assembled so this file does not contain the denylist.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RULE=".cursor/rules/no-customer-names.mdc"
needle="$(printf '%s%s|%s%s' west pac wn zl)"

hits="$(
  rg -i -n -g '!.git/**' -g "!${RULE}" -- "$needle" "$ROOT" || true
)"

if [ -n "$hits" ]; then
  echo "$hits"
  echo "FAIL customer names found outside ${RULE}"
  exit 1
fi
echo "OK  no customer names outside ${RULE}"
