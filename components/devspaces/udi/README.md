# Digi 2.0 custom Dev Spaces UDI

Custom **Universal Developer Image** for OpenShift Dev Spaces, based on Red Hat UDI (`registry.redhat.io/devspaces/udi-rhel9`).

Aligns with **HLD §13.5**, **DD-8**, and **DD-22**.

## Tools (from customer HLD)

| Tool | Notes |
|------|--------|
| Java 17 + 21 | Bank-supported JDKs; default `JAVA_HOME` → 21 |
| Gradle (pinned) | Quarkus / Spring golden path |
| Node 20 LTS + npm | Frontend / Node golden path |
| pre-commit | Shift-left git hooks |
| Sonar Scanner CLI | Local scans; Jenkins still owns quality gate |
| Snyk CLI | `snyk test` / `snyk code` before push |
| jq, yq, openssl, curl, git | Scripting / API debug |
| oc / kubectl | Non-Prod debug (RBAC-limited) |
| Corporate CA | Drop PEM/CRT into `certs/` before build |

## Build and push

```bash
# Login to Red Hat registry (UDI base)
podman login registry.redhat.io

# Optional: add corporate CAs
cp /path/to/corp-root.crt components/devspaces/udi/certs/

# Build
podman build \
  -t digi20-devspaces-udi:1.0.0 \
  -f components/devspaces/udi/Containerfile \
  components/devspaces/udi

# Push to Artifactory (replace host/path)
podman tag digi20-devspaces-udi:1.0.0 \
  artifactory.example.com/digi20/devspaces-udi:1.0.0
podman push artifactory.example.com/digi20/devspaces-udi:1.0.0
```

## Use in a devfile

```yaml
components:
  - name: tools
    container:
      image: artifactory.example.com/digi20/devspaces-udi:1.0.0
      mountSources: true
      sourceMapping: /projects
      env:
        - name: NODEJS_VERSION
          value: "20"
        - name: JAVA_HOME
          value: /usr/lib/jvm/java-21-openjdk
```

## Tests

```bash
./components/devspaces/udi/tests/test-udi-image.sh
```

- **Unit:** Containerfile and config content checks (no registry required)
- **System:** `podman build` when registry credentials and network are available

## Notes

- Prefer **CI-built** images in Artifactory; avoid `devfile` `autoBuild` in Non-Prod/Prod (HLD §13.7).
- Authenticated corporate proxy (NTLM/Kerberos) is a CheCluster / cluster concern, not baked into this image.
- ACS-scan the image before promoting beyond eDev.
