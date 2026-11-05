#!/usr/bin/env bash
# Unit + light system checks for the remote-extensions UDI example.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0
pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*"; FAIL=$((FAIL + 1)); }

echo "==> Unit: files"
[[ -f "${ROOT}/Containerfile" ]] || fail "missing Containerfile"
[[ -f "${ROOT}/devfile.yaml" ]] || fail "missing devfile.yaml"
[[ -f "${ROOT}/extensions.json" ]] || fail "missing extensions.json"
[[ -x "${ROOT}/scripts/fetch-vsix.sh" || -f "${ROOT}/scripts/fetch-vsix.sh" ]] || fail "missing fetch-vsix.sh"
[[ -f "${ROOT}/scripts/install-remote-extensions.sh" ]] || fail "missing install script"

echo "==> Unit: Containerfile contracts"
grep -q 'UDI_EXTENSIONS_DIR=/opt/udi-extensions' "${ROOT}/Containerfile" || fail "must set UDI_EXTENSIONS_DIR"
grep -q 'COPY vsix/\*\.vsix' "${ROOT}/Containerfile" || fail "must COPY vsix/*.vsix"
grep -q 'install-remote-extensions.sh' "${ROOT}/Containerfile" || fail "must install helper script"
grep -q 'USER 10001' "${ROOT}/Containerfile" || fail "must end as USER 10001"

echo "==> Unit: install script behaviour"
grep -q -- '--install-extension' "${ROOT}/scripts/install-remote-extensions.sh" \
  || fail "install script must call --install-extension"
grep -q 'DEFAULT_EXTENSIONS' "${ROOT}/scripts/install-remote-extensions.sh" \
  || fail "install script must fall back to DEFAULT_EXTENSIONS"
grep -q 'extensionsGallery' "${ROOT}/scripts/install-remote-extensions.sh" \
  || fail "install script must patch extensionsGallery in product.json"

echo "==> Unit: devfile postStart & Artifactory gallery config"
grep -q 'postStart:' "${ROOT}/devfile.yaml" || fail "devfile must define postStart"
grep -q 'install-remote-extensions' "${ROOT}/devfile.yaml" || fail "postStart must run installer"
grep -q 'DEFAULT_EXTENSIONS' "${ROOT}/devfile.yaml" || fail "devfile should set DEFAULT_EXTENSIONS for che-code"
grep -q 'ARTIFACTORY_MARKETPLACE_URL' "${ROOT}/devfile.yaml" || fail "devfile must configure ARTIFACTORY_MARKETPLACE_URL"
grep -q 'REMOTE_EXTENSION_IDS' "${ROOT}/devfile.yaml" || fail "devfile must configure REMOTE_EXTENSION_IDS"

echo "==> Unit: extensions manifest"
command -v jq >/dev/null || fail "jq required for manifest check"
jq -e 'type=="array" and length>=1' "${ROOT}/extensions.json" >/dev/null \
  || fail "extensions.json must be a non-empty array"
jq -e 'all(.[]; has("id") and has("version"))' "${ROOT}/extensions.json" >/dev/null \
  || fail "each extension needs id + version"

echo "==> System: dry-run install script with empty dir"
tmpdir="$(mktemp -d)"
REMOTE_EXTENSION_IDS="" UDI_EXTENSIONS_DIR="${tmpdir}" bash "${ROOT}/scripts/install-remote-extensions.sh" \
  && pass "empty dir is no-op" \
  || fail "empty dir should exit 0"
rm -rf "${tmpdir}"

echo "==> System: dry-run install with fake vsix (no code CLI → DEFAULT_EXTENSIONS path)"
tmpdir="$(mktemp -d)"
home="$(mktemp -d)"
echo "fake" >"${tmpdir}/demo.publisher-1.0.0.vsix"
if HOME="${home}" PATH="/usr/bin:/bin" REMOTE_EXTENSION_IDS="" UDI_EXTENSIONS_DIR="${tmpdir}" bash "${ROOT}/scripts/install-remote-extensions.sh"; then
  [[ -f "${home}/.udi/DEFAULT_EXTENSIONS" ]] && pass "wrote DEFAULT_EXTENSIONS helper file" \
    || fail "expected ${home}/.udi/DEFAULT_EXTENSIONS"
  grep -q 'demo.publisher-1.0.0.vsix' "${home}/.udi/DEFAULT_EXTENSIONS" \
    && pass "DEFAULT_EXTENSIONS lists vsix" \
    || fail "DEFAULT_EXTENSIONS content wrong"
else
  fail "install script should succeed without code CLI"
fi
rm -rf "${tmpdir}" "${home}"

echo "==> System: product.json gallery rewrite + single batched CLI invocation"
tmpdir="$(mktemp -d)"
home="$(mktemp -d)"
commit_dir="${home}/.vscode-server/bin/abc123commit"
mkdir -p "${commit_dir}/bin/remote-cli"
cat <<'EOF' > "${commit_dir}/product.json"
{
  "version": "1.95.0",
  "extensionsGallery": {
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "itemUrl": "https://marketplace.visualstudio.com/items"
  }
}
EOF
cat <<'EOF' > "${commit_dir}/bin/remote-cli/code"
#!/usr/bin/env bash
printf '%s\n' "$*" > "${HOME}/code-cli-args.txt"
EOF
chmod +x "${commit_dir}/bin/remote-cli/code"

if HOME="${home}" PATH="/usr/bin:/bin:$(dirname "$(command -v jq)")" \
   ARTIFACTORY_MARKETPLACE_URL="https://artifactory.corp.internal/artifactory/vscode-marketplace" \
   REMOTE_EXTENSION_IDS="redhat.vscode-yaml;dbaeumer.vscode-eslint" \
   UDI_EXTENSIONS_DIR="${tmpdir}" \
   bash "${ROOT}/scripts/install-remote-extensions.sh"; then
  svc="$(jq -r '.extensionsGallery.serviceUrl' "${commit_dir}/product.json")"
  if [[ "${svc}" == "https://artifactory.corp.internal/artifactory/vscode-marketplace/_apis/public/gallery" ]]; then
    pass "patched product.json extensionsGallery.serviceUrl to Artifactory"
  else
    fail "unexpected serviceUrl in product.json: ${svc}"
  fi
  if grep -q -- '--install-extension redhat.vscode-yaml --install-extension dbaeumer.vscode-eslint --force' "${home}/code-cli-args.txt"; then
    pass "invoked code CLI once with batched --install-extension args"
  else
    fail "unexpected CLI args: $(cat "${home}/code-cli-args.txt" 2>/dev/null || true)"
  fi
else
  fail "batched CLI install test failed"
fi
rm -rf "${tmpdir}" "${home}"

if [[ "${FAIL}" -ne 0 ]]; then
  echo "RESULT: FAIL (${FAIL})"
  exit 1
fi
echo "RESULT: OK"
