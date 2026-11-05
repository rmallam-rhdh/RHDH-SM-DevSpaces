# UDI + Artifactory Gallery Redirect for VS Code Remote

Automatically install VS Code extensions on workspace `postStart` when connecting from **Desktop VS Code / Cursor Remote** in an egress-restricted environment—**without** disabling `"extensions.verifySignature": true`.

## Why this is needed

When `extensions.verifySignature` is `true` (default), `code --install-extension` queries `https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery` to fetch the `.sigzip` cryptographic signature archive. In an egress-blocked cluster, that request hangs for **90 seconds per plugin**.

Furthermore, different developers may connect with different versions of Desktop VS Code (`1.90`, `1.95`, `1.98`, etc.).

`scripts/install-remote-extensions.sh` solves both problems:
1. **Rewrites `extensionsGallery.serviceUrl` in `~/.vscode-server/bin/*/product.json`** to point at your **Artifactory Remote Marketplace proxy** (`ARTIFACTORY_MARKETPLACE_URL`), so VS Code resolves compatible extension versions for the developer's specific VS Code version and fetches `.sigzip` signatures through Artifactory in milliseconds.
2. **Batches all `--install-extension` arguments into a single CLI call**, avoiding repeated Node.js process startup overhead.
3. **Waits in the background (`UDI_WAIT_FOR_VSCODE_SERVER=true`)** when `postStart` fires before the developer has connected from local VS Code, then automatically patches `product.json` and installs extensions as soon as `~/.vscode-server` appears.

## Layout

| Path | Purpose |
|------|---------|
| `devfile.yaml` | Configures `ARTIFACTORY_MARKETPLACE_URL`, `REMOTE_EXTENSION_IDS`, and `postStart` |
| `scripts/install-remote-extensions.sh` | Patches `product.json` gallery URL + runs batched `code --install-extension` |
| `Containerfile` | Optional UDI layer that bakes `/usr/local/bin/install-remote-extensions.sh` and fallback `.vsix` files |
| `extensions.json` | Sample allowlist (id + version) for lab `.vsix` fetch |
| `vsix/` | Optional fallback `.vsix` directory |

## Environment Variables (`devfile.yaml`)

| Variable | Description |
|----------|-------------|
| `ARTIFACTORY_MARKETPLACE_URL` | Base URL of the Artifactory remote repository proxying VS Code Marketplace |
| `VSCODE_GALLERY_SERVICE_URL` | Override full gallery service URL (defaults to `${ARTIFACTORY_MARKETPLACE_URL}/_apis/public/gallery`) |
| `REMOTE_EXTENSION_IDS` | Semicolon-separated extension IDs resolved dynamically for the developer's VS Code version |
| `UDI_WAIT_FOR_VSCODE_SERVER` | Set to `"true"` so `postStart` watches in the background until the first remote connection |
| `UDI_EXTENSIONS_DIR` | Directory containing any local `.vsix` files (`/opt/udi-extensions`) |

## Tests

```bash
./components/devspaces/udi/examples/remote-extensions/tests/test-remote-extensions.sh
```
