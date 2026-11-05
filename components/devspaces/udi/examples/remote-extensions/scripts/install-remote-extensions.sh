#!/usr/bin/env bash
# Install VS Code extensions into the remote VS Code / che-code extension host
# with Artifactory gallery redirect so signature verification (verifySignature=true)
# succeeds via Artifactory without hitting the 90-second internet egress timeout.
set -euo pipefail

EXT_DIR="${UDI_EXTENSIONS_DIR:-/opt/udi-extensions}"
LOG="${UDI_EXTENSIONS_LOG:-/tmp/udi-extensions-install.log}"

# Artifactory remote Marketplace proxy settings (override in devfile env)
ARTIFACTORY_MARKETPLACE_URL="${ARTIFACTORY_MARKETPLACE_URL:-https://artifactory.example.com/artifactory/vscode-marketplace}"
GALLERY_SERVICE_URL="${VSCODE_GALLERY_SERVICE_URL:-${ARTIFACTORY_MARKETPLACE_URL%/}/_apis/public/gallery}"
GALLERY_ITEM_URL="${VSCODE_GALLERY_ITEM_URL:-${ARTIFACTORY_MARKETPLACE_URL%/}/items}"

# Optional semicolon/comma/space-separated extension IDs (resolved dynamically for the dev's VS Code version)
REMOTE_EXTENSION_IDS="${REMOTE_EXTENSION_IDS:-}"

log() {
  echo "$*"
  if mkdir -p "$(dirname "${LOG}")" 2>/dev/null; then
    echo "$*" >>"${LOG}" 2>/dev/null || true
  fi
}

log "==> $(date -Is 2>/dev/null || date) install-remote-extensions (EXT_DIR=${EXT_DIR})"

# Collect .vsix files from EXT_DIR (if any)
shopt -s nullglob
vsix=( "${EXT_DIR}"/*.vsix )
shopt -u nullglob

# Parse REMOTE_EXTENSION_IDS into an array (if provided)
ext_ids=()
if [[ -n "${REMOTE_EXTENSION_IDS}" ]]; then
  IFS=';, ' read -r -a ext_ids <<<"${REMOTE_EXTENSION_IDS}"
fi

if [[ ${#vsix[@]} -eq 0 && ${#ext_ids[@]} -eq 0 ]]; then
  log "No .vsix under ${EXT_DIR} and no REMOTE_EXTENSION_IDS set; nothing to do"
  exit 0
fi

# Rewrite extensionsGallery.serviceUrl in VS Code Server's product.json to point at Artifactory.
# This keeps extensions.verifySignature=true working without 90s egress timeouts to marketplace.visualstudio.com,
# and lets VS Code resolve extension versions matching the developer's specific VS Code client version.
patch_product_json() {
  shopt -s nullglob
  local products=(
    "${HOME}/.vscode-server/bin/"*/product.json
    "${HOME}/.vscode-server-insiders/bin/"*/product.json
    "${HOME}/.cursor-server/bin/"*/product.json
  )
  shopt -u nullglob

  if [[ ${#products[@]} -eq 0 ]]; then
    return 1
  fi

  for prod in "${products[@]}"; do
    [[ -f "${prod}" && -w "${prod}" ]] || continue
    if command -v jq >/dev/null 2>&1; then
      log "Patching extensionsGallery.serviceUrl in ${prod} -> ${GALLERY_SERVICE_URL}"
      jq --arg svc "${GALLERY_SERVICE_URL}" \
         --arg item "${GALLERY_ITEM_URL}" \
         '.extensionsGallery = ((.extensionsGallery // {}) + {
            serviceUrl: $svc,
            itemUrl: $item
          })' "${prod}" > "${prod}.tmp" \
        && mv "${prod}.tmp" "${prod}"
    fi
  done
  return 0
}

# Prefer a real Code CLI when present (desktop Remote-SSH / remote connector).
# Fall back to DEFAULT_EXTENSIONS for che-code (browser / Dev Spaces editor).
find_code_cli() {
  local c path
  shopt -s nullglob
  local candidates=(
    "${HOME}/.vscode-server/bin/"*/bin/remote-cli/code
    "${HOME}/.vscode-server/bin/"*/bin/code
    "${HOME}/.cursor-server/bin/"*/bin/remote-cli/code
    "${HOME}/.cursor-server/bin/"*/bin/cursor
  )
  shopt -u nullglob
  if [[ ${#candidates[@]} -gt 0 ]]; then
    # Newest install path last (Bash 3.2+ compatible)
    path="${candidates[${#candidates[@]}-1]}"
    if [[ -x "${path}" && -f "${path}" ]]; then
      echo "${path}"
      return 0
    fi
  fi
  for c in code code-server; do
    path="$(command -v "${c}" 2>/dev/null || true)"
    # Reject shell builtins / functions that are not a real binary (e.g. "." ).
    if [[ -n "${path}" && "${path}" != "." && -x "${path}" && -f "${path}" ]]; then
      echo "${path}"
      return 0
    fi
  done
  if [[ -x /checode/checode && -f /checode/checode ]]; then
    echo /checode/checode
    return 0
  fi
  return 1
}

run_cli_install() {
  local cli="$1"
  patch_product_json || true

  local install_args=()
  if [[ ${#vsix[@]} -gt 0 ]]; then
    for f in "${vsix[@]}"; do
      [[ -n "${f}" ]] && install_args+=( --install-extension "${f}" )
    done
  fi
  if [[ ${#ext_ids[@]} -gt 0 ]]; then
    for id in "${ext_ids[@]}"; do
      [[ -n "${id}" ]] && install_args+=( --install-extension "${id}" )
    done
  fi

  if [[ ${#install_args[@]} -eq 0 ]]; then
    return 0
  fi

  log "Using CLI: ${cli}"
  log "Installing ${#install_args[@]} argument(s) in a single batched invocation (signature verification active via ${GALLERY_SERVICE_URL})"
  VSCODE_GALLERY_SERVICE_URL="${GALLERY_SERVICE_URL}" \
  VSCODE_GALLERY_ITEM_URL="${GALLERY_ITEM_URL}" \
    "${cli}" "${install_args[@]}" --force \
    || log "WARN: batched install reported an error; check ${LOG}"
  log "Done (CLI batched install)."
}

# Optional --watch mode: wait in background for ~/.vscode-server to appear when dev connects from local VS Code
if [[ "${1:-}" == "--watch" ]]; then
  max_wait="${UDI_VSCODE_WAIT_SECONDS:-900}"
  elapsed=0
  log "Waiting up to ${max_wait}s for local VS Code remote server connection..."
  while (( elapsed < max_wait )); do
    if CODE_CLI="$(find_code_cli)" && [[ "${CODE_CLI}" != "/checode/checode" ]]; then
      run_cli_install "${CODE_CLI}"
      exit 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done
  log "Timed out waiting for remote VS Code server after ${max_wait}s."
  exit 0
fi

if CODE_CLI="$(find_code_cli)"; then
  run_cli_install "${CODE_CLI}"
  exit 0
fi

# If no remote CLI exists yet (postStart runs before desktop VS Code connects):
# 1. Export DEFAULT_EXTENSIONS for in-browser che-code
if [[ ${#vsix[@]} -gt 0 ]]; then
  joined=""
  for f in "${vsix[@]}"; do
    if [[ -n "${joined}" ]]; then
      joined="${joined};${f}"
    else
      joined="${f}"
    fi
  done
  export DEFAULT_EXTENSIONS="${joined}"
  log "No code CLI yet — set DEFAULT_EXTENSIONS for che-code:"
  log "  DEFAULT_EXTENSIONS=${DEFAULT_EXTENSIONS}"
  mkdir -p "${HOME}/.udi"
  printf '%s\n' "${DEFAULT_EXTENSIONS}" >"${HOME}/.udi/DEFAULT_EXTENSIONS"
  log "Wrote ${HOME}/.udi/DEFAULT_EXTENSIONS"
fi

# 2. If UDI_WAIT_FOR_VSCODE_SERVER=true, spawn a non-blocking background watcher so that as soon as
#    the developer connects from their local VS Code, product.json is patched and extensions install automatically.
if [[ "${UDI_WAIT_FOR_VSCODE_SERVER:-false}" == "true" ]]; then
  log "Spawning background watcher for desktop VS Code remote connection..."
  nohup "$0" --watch >>"${LOG}" 2>&1 &
fi
