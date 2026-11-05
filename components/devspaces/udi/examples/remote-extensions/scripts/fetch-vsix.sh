#!/usr/bin/env bash
# Lab helper: download sample VSIX into ./vsix/ (OpenVSX).
# For air-gapped builds, drop pre-mirrored .vsix files into vsix/ and skip this.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VSIX_DIR="${ROOT}/vsix"
MANIFEST="${ROOT}/extensions.json"
OPENVSX_URL="${OPENVSX_URL:-https://open-vsx.org}"

mkdir -p "${VSIX_DIR}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

count="$(jq 'length' "${MANIFEST}")"
echo "Fetching ${count} extension(s) into ${VSIX_DIR}"

jq -c '.[]' "${MANIFEST}" | while read -r row; do
  id="$(jq -r '.id' <<<"${row}")"
  ver="$(jq -r '.version' <<<"${row}")"
  ns="${id%%.*}"
  name="${id#*.}"
  out="${VSIX_DIR}/${id}-${ver}.vsix"
  if [[ -f "${out}" ]]; then
    echo "  skip (exists) ${out##*/}"
    continue
  fi
  url="${OPENVSX_URL}/api/${ns}/${name}/${ver}/file/${id}-${ver}.vsix"
  echo "  GET ${url}"
  curl -fsSL --location -o "${out}" "${url}"
  echo "  wrote ${out##*/} ($(wc -c <"${out}") bytes)"
done

echo "Done. $(find "${VSIX_DIR}" -name '*.vsix' | wc -l | tr -d ' ') vsix file(s)."
