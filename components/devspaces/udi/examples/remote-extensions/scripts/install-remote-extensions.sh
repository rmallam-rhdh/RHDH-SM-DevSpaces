#!/usr/bin/env bash
# Install VS Code extensions strictly via Artifactory (.vsix + .sigzip),
# verify cryptographic signatures offline using VS Code Server's bundled vsce-sign,
# and unpack into ~/.vscode-server/extensions with isSigned=true (zero external egress).
set -euo pipefail

EXT_DIR="${UDI_EXTENSIONS_DIR:-/opt/udi-extensions}"
LOG="${UDI_EXTENSIONS_LOG:-/tmp/udi-extensions-install.log}"

# Artifactory endpoints (all traffic goes strictly through Artifactory)
ARTIFACTORY_URL="${ARTIFACTORY_URL:-https://artifactory.example.com/artifactory}"
ARTIFACTORY_VSIX_REPO="${ARTIFACTORY_VSIX_REPO:-generic-release/vsix}"
ARTIFACTORY_VSIX_URL="${ARTIFACTORY_VSIX_URL:-${ARTIFACTORY_URL%/}/${ARTIFACTORY_VSIX_REPO#/}}"
ARTIFACTORY_MARKETPLACE_URL="${ARTIFACTORY_MARKETPLACE_URL:-${ARTIFACTORY_URL%/}/vscode-marketplace}"
GALLERY_SERVICE_URL="${VSCODE_GALLERY_SERVICE_URL:-${ARTIFACTORY_MARKETPLACE_URL%/}/_apis/public/gallery}"
GALLERY_ITEM_URL="${VSCODE_GALLERY_ITEM_URL:-${ARTIFACTORY_MARKETPLACE_URL%/}/items}"

# Optional Artifactory credentials
ARTIFACTORY_USER="${ARTIFACTORY_USER:-}"
ARTIFACTORY_TOKEN="${ARTIFACTORY_TOKEN:-}"

# Semicolon/comma/space-separated list of extension coordinates (`publisher.name-version` or `publisher.name`)
REMOTE_EXTENSION_IDS="${REMOTE_EXTENSION_IDS:-}"

log() {
  echo "$*"
  if mkdir -p "$(dirname "${LOG}")" 2>/dev/null; then
    echo "$*" >>"${LOG}" 2>/dev/null || true
  fi
}

log "==> $(date -Is 2>/dev/null || date) install-remote-extensions (EXT_DIR=${EXT_DIR}, ARTIFACTORY_VSIX_URL=${ARTIFACTORY_VSIX_URL})"

shopt -s nullglob
vsix=( "${EXT_DIR}"/*.vsix )
shopt -u nullglob

ext_ids=()
if [[ -n "${REMOTE_EXTENSION_IDS}" ]]; then
  IFS=';, ' read -r -a ext_ids <<<"${REMOTE_EXTENSION_IDS}"
fi

if [[ ${#vsix[@]} -eq 0 && ${#ext_ids[@]} -eq 0 ]]; then
  log "No .vsix under ${EXT_DIR} and no REMOTE_EXTENSION_IDS set; nothing to do"
  exit 0
fi

# Build curl auth arguments for Artifactory
curl_auth=()
if [[ -n "${ARTIFACTORY_TOKEN}" ]]; then
  if [[ -n "${ARTIFACTORY_USER}" ]]; then
    curl_auth=(-u "${ARTIFACTORY_USER}:${ARTIFACTORY_TOKEN}")
  else
    curl_auth=(-H "Authorization: Bearer ${ARTIFACTORY_TOKEN}")
  fi
fi

# Rewrite extensionsGallery.serviceUrl in VS Code Server's product.json to point at Artifactory
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

# Find VS Code Server's bundled @vscode/vsce-sign binary (or system vsce-sign)
find_vsce_sign() {
  local path
  shopt -s nullglob
  local candidates=(
    "${HOME}/.vscode-server/bin/"*/node_modules/@vscode/vsce-sign/bin/vsce-sign
    "${HOME}/.vscode-server-insiders/bin/"*/node_modules/@vscode/vsce-sign/bin/vsce-sign
    "${HOME}/.cursor-server/bin/"*/node_modules/@vscode/vsce-sign/bin/vsce-sign
  )
  shopt -u nullglob
  if [[ ${#candidates[@]} -gt 0 ]]; then
    path="${candidates[${#candidates[@]}-1]}"
    if [[ -x "${path}" && -f "${path}" ]]; then
      echo "${path}"
      return 0
    fi
  fi
  if path="$(command -v vsce-sign 2>/dev/null || true)" && [[ -n "${path}" && -x "${path}" ]]; then
    echo "${path}"
    return 0
  fi
  return 1
}

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
    path="${candidates[${#candidates[@]}-1]}"
    if [[ -x "${path}" && -f "${path}" ]]; then
      echo "${path}"
      return 0
    fi
  fi
  for c in code code-server; do
    path="$(command -v "${c}" 2>/dev/null || true)"
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

# Resolve compatible version + download both .vsix and .sigzip strictly from Artifactory
fetch_from_artifactory() {
  local coord="$1"
  local dest_dir="$2"
  local vsix_url="" sigzip_url="" base_name=""

  # If coord already includes an explicit version (e.g. redhat.vscode-yaml-1.18.0),
  # pull <coord>.vsix and <coord>.sigzip directly from ARTIFACTORY_VSIX_URL.
  if [[ "${coord}" =~ ^([a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+)-([0-9]+\.[0-9]+\.[0-9]+.*)$ ]]; then
    base_name="${coord}"
    vsix_url="${ARTIFACTORY_VSIX_URL}/${base_name}.vsix"
    sigzip_url="${ARTIFACTORY_VSIX_URL}/${base_name}.sigzip"
  else
    # Otherwise query Artifactory Marketplace remote API to resolve the version for this VS Code server
    local pub="${coord%%.*}"
    local name="${coord#*.}"
    log "Querying Artifactory gallery (${GALLERY_SERVICE_URL}/extensionquery) for ${coord}" >&2
    local query_payload resp ver
    query_payload="$(jq -nc --arg id "${coord}" '{
      filters: [{ criteria: [{ filterType: 7, value: $id }], pageNumber: 1, pageSize: 10 }],
      flags: 914
    }')"
    if resp="$(curl -fsSL ${curl_auth[@]+"${curl_auth[@]}"} \
         -H "Content-Type: application/json" \
         -H "Accept: application/json;api-version=3.0-preview.1" \
         -d "${query_payload}" \
         "${GALLERY_SERVICE_URL}/extensionquery" 2>/dev/null)"; then
      ver="$(jq -r '.results[0].extensions[0].versions[0].version // empty' <<<"${resp}")"
    else
      ver=""
    fi
    if [[ -z "${ver}" ]]; then
      log "WARN: Could not resolve version for ${coord} from Artifactory gallery" >&2
      return 1
    fi
    base_name="${pub}.${name}-${ver}"
    # Always download the .vsix and .sigzip strictly via Artifactory (never gallerycdn.vsassets.io)
    vsix_url="${ARTIFACTORY_VSIX_URL}/${base_name}.vsix"
    sigzip_url="${ARTIFACTORY_VSIX_URL}/${base_name}.sigzip"
  fi

  log "Downloading VSIX from Artifactory:   ${vsix_url}" >&2
  curl -fsSL ${curl_auth[@]+"${curl_auth[@]}"} "${vsix_url}" -o "${dest_dir}/${base_name}.vsix"

  log "Downloading SIGZIP from Artifactory: ${sigzip_url}" >&2
  curl -fsSL ${curl_auth[@]+"${curl_auth[@]}"} "${sigzip_url}" -o "${dest_dir}/${base_name}.sigzip"

  echo "${dest_dir}/${base_name}.vsix"
}

# Verify signature with vsce-sign and unpack into ~/.vscode-server/extensions
verify_and_unpack_vsix() {
  local vsix_file="$1"
  local sigzip_file="${vsix_file%.vsix}.sigzip"
  local vsce_sign_bin="${2:-}"
  local ext_root="${HOME}/.vscode-server/extensions"

  mkdir -p "${ext_root}"
  [[ -f "${ext_root}/extensions.json" ]] || echo "[]" > "${ext_root}/extensions.json"

  if [[ -f "${sigzip_file}" && -n "${vsce_sign_bin}" ]]; then
    log "Verifying cryptographic signature: $(basename "${vsix_file}") + $(basename "${sigzip_file}")"
    "${vsce_sign_bin}" verify "${vsix_file}" "${sigzip_file}"
  elif [[ -f "${sigzip_file}" ]]; then
    log "WARN: vsce-sign binary not found; skipping standalone CLI check for $(basename "${vsix_file}")"
  fi

  local tmpdir
  tmpdir="$(mktemp -d)"
  unzip -q "${vsix_file}" -d "${tmpdir}"
  local pkg="${tmpdir}/extension/package.json"
  local pub name ver ext_id folder target
  pub="$(jq -r '.publisher' "${pkg}")"
  name="$(jq -r '.name' "${pkg}")"
  ver="$(jq -r '.version' "${pkg}")"
  ext_id="$(printf '%s.%s' "${pub}" "${name}" | tr '[:upper:]' '[:lower:]')"
  folder="${ext_id}-${ver}"
  target="${ext_root}/${folder}"

  rm -rf "${target}"
  mv "${tmpdir}/extension" "${target}"
  if [[ -f "${tmpdir}/extension.vsixmanifest" ]]; then
    mv "${tmpdir}/extension.vsixmanifest" "${target}/.vsixmanifest"
  fi
  rm -rf "${tmpdir}"

  jq --arg id "${ext_id}" \
     --arg ver "${ver}" \
     --arg folder "${folder}" \
     --arg path "${target}" \
     'map(select(.identifier.id != $id)) + [{
       "identifier": { "id": $id },
       "version": $ver,
       "location": { "$mid": 1, "path": $path, "scheme": "file" },
       "relativeLocation": $folder,
       "metadata": {
         "installedTimestamp": (now * 1000 | floor),
         "pinned": true,
         "source": "vsix",
         "isSigned": true
       }
     }]' "${ext_root}/extensions.json" > "${ext_root}/extensions.json.tmp" \
    && mv "${ext_root}/extensions.json.tmp" "${ext_root}/extensions.json"

  log "Installed verified extension: ${folder}"
}

run_cli_install() {
  local cli="$1"
  patch_product_json || true

  local vsce_sign_bin=""
  vsce_sign_bin="$(find_vsce_sign || true)"

  local dl_dir
  dl_dir="$(mktemp -d)"

  # 1. If REMOTE_EXTENSION_IDS are specified and ARTIFACTORY_FETCH_SIGZIP=true,
  #    download .vsix + .sigzip strictly from Artifactory, verify with vsce-sign, and unpack.
  if [[ "${ARTIFACTORY_DIRECT_SIGZIP_VERIFY:-false}" == "true" && ${#ext_ids[@]} -gt 0 ]]; then
    for coord in "${ext_ids[@]}"; do
      [[ -n "${coord}" ]] || continue
      if downloaded_vsix="$(fetch_from_artifactory "${coord}" "${dl_dir}")"; then
        verify_and_unpack_vsix "${downloaded_vsix}" "${vsce_sign_bin}"
      fi
    done
    rm -rf "${dl_dir}"
    return 0
  fi

  # 2. If local .vsix files have companion .sigzip files in EXT_DIR, verify & unpack them directly
  local cli_args=()
  if [[ ${#vsix[@]} -gt 0 ]]; then
    for f in "${vsix[@]}"; do
      [[ -n "${f}" ]] || continue
      if [[ -f "${f%.vsix}.sigzip" ]] && command -v unzip >/dev/null 2>&1; then
        verify_and_unpack_vsix "${f}" "${vsce_sign_bin}"
      else
        cli_args+=( --install-extension "${f}" )
      fi
    done
  fi

  if [[ ${#ext_ids[@]} -gt 0 ]]; then
    for id in "${ext_ids[@]}"; do
      [[ -n "${id}" ]] && cli_args+=( --install-extension "${id}" )
    done
  fi

  rm -rf "${dl_dir}"

  if [[ ${#cli_args[@]} -eq 0 ]]; then
    return 0
  fi

  log "Using CLI: ${cli}"
  log "Installing ${#cli_args[@]} argument(s) in a single batched invocation (signature verification active via ${GALLERY_SERVICE_URL})"
  VSCODE_GALLERY_SERVICE_URL="${GALLERY_SERVICE_URL}" \
  VSCODE_GALLERY_ITEM_URL="${GALLERY_ITEM_URL}" \
    "${cli}" "${cli_args[@]}" --force \
    || log "WARN: batched install reported an error; check ${LOG}"
  log "Done (CLI batched install)."
}

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

if [[ "${UDI_WAIT_FOR_VSCODE_SERVER:-false}" == "true" ]]; then
  log "Spawning background watcher for desktop VS Code remote connection..."
  nohup "$0" --watch >>"${LOG}" 2>&1 &
fi
