# Golden Path Live Session — Facilitator Runbook

**Use:** Hands-on or walkthrough workshop (90–120 min)  
**Audience:** Platform Engineering, app team leads, IDP team  
**Goal:** Run the golden path end-to-end narrative — RHDH scaffold → Dev Spaces → CI/CD → GitOps → promotion gates

**Repo map:** `golden-path/` (templates) · `components/developer-hub/` (RHDH) · `components/devspaces/` (Dev Spaces) · `components/policy-as-code/` (Kyverno gates)

---

## 0. Before the session (PE prerequisites)

Complete or explicitly **mock/narrate** if not ready in the demo cluster.

| # | Prerequisite | Owner | Notes |
|---|--------------|-------|-------|
| 1 | RHDH deployed; user in Entra/AD group for RHDH access | PE | SSO/OIDC working |
| 2 | `golden-path/all-templates.yaml` registered in RHDH catalog | PE | See `app-config-cm.yaml` locations |
| 3 | Namespace catalog entities in `golden-path/catalog/namespaces/` | PE | **AcmeSpace** = existing OCP namespace; picker uses **Resource** entities |
| 4 | Target **AcmeSpace** exists on cluster OR process to create via OPaaS ticket | App team + PE | Template **does not** create namespace today — picks existing or PE provisions first |
| 5 | Bitbucket workspace + PE bot credentials for scaffolder publish | PE | CloudBees webhook can be post-session |
| 6 | Jenkins/CloudBees folder + multibranch job pattern | PE | Root CI + promotion; app repo carries **Jenkinsfile** |
| 7 | Artifactory repos whitelisted (OPaaS) | App team | Non-prod + prod repos; **Xray** scan on push |
| 8 | Argo CD instance + cluster credentials | PE | GitOps deploy agent |
| 9 | Vault KV v2 path + **kube auth** policy for app namespace | App team + SRE | See § Vault below; template does not scaffold Vault yet |
| 10 | Splunk index for app (AKB_ID) | App team | Platform logging contract |
| 11 | AD group for squad created | App team | Maps to RHDH RBAC + OCP RBAC |
| 12 | Dev Spaces on Non-Prod; user in Dev Spaces group | PE | Launch from RHDH factory URL |

**Naming alignment**

| Acme term | In this repo |
|-------------|----------------|
| Quarkus template | **Java:** acme says Quarkus; repo skeleton is **Spring Boot + Gradle** — rename in UI or swap skeleton before session |
| AcmeSpace | OpenShift **namespace** — `targetNamespace` in app-code template |
| Manifest repo | **`<app>-gitops`** — created by **Release Pipeline** template |
| PE repository | This gitops repo (`golden-path/`, catalog, components) |

---

## 1. Session agenda (suggested 100 min)

| Time | Section | Activity |
|------|---------|----------|
| 0:00 | **Landing** | RHDH homepage → prereqs README (narrate PE table above) |
| 0:10 | **Onboard service** | RHDH **Create** → Spring Boot/Quarkus **App Code** template |
| 0:30 | **Catalog** | Open new **Component** in catalog; annotations, Dev Spaces link |
| 0:40 | **Dev Spaces** | **Open in Dev Spaces** → build / test / run (inner loop) |
| 0:55 | **Release pipeline** | **Create** → Release Pipeline template → second repo + Jenkinsfile |
| 1:10 | **CI/CD swimlane** | Walk Jenkins stages + GitOps PR + Argo CD (demo or slides) |
| 1:25 | **Promotion & gates** | ServiceNow, manual promote, security toolchain |
| 1:35 | **Parking lot** | Open questions, Helm vs Kustomize, Lighthouse, Vault |

---

## 2. Developer workflow — facilitator script

### Step A — Jira (narrate)

- Story **In Progress** assigned to developer.
- **Start Feature** template (future) creates branch `feature/<JIRA-KEY>-...` — **not in repo yet**.
- **Today:** use **App Code** for new service; feature flow = manual branch + Dev Spaces.

### Step B — RHDH Create → App Code template

1. Open RHDH → **Create** (`/create`) or homepage **Create a New Service**.
2. Select **Spring Boot App — Application Code** (label as Quarkus if acme-facing).
3. Fill form:
   - **appName** — kebab-case (becomes repo name)
   - **AcmeSpace** — **EntityPicker** → pick existing namespace Resource (e.g. `nonprod-dc1-payments-dev`)
   - **targetCluster** — DC-1 or DC-2
   - **devSpacesBaseUrl** — Non-Prod Dev Spaces URL
4. **Run** scaffolder → wait for success.

**What gets created**

| Output | Where |
|--------|--------|
| Bitbucket **source repo** | `bitbucket.org/<workspace>/<appName>` |
| `catalog-info.yaml` | Repo root → registered in RHDH |
| `devfile.yaml` | Dev Spaces inner loop |
| `build.gradle.kts`, `Dockerfile`, `Jenkinsfile` placeholder | Source repo |
| Pre-commit, PR template | From `_shared/governance/` |
| Jira component | Linked to project key |

**Success screen links:** Bitbucket · **Open in Catalog** · **Open in Dev Spaces** · Next: Release Pipeline

**If AcmeSpace does not exist:** stop — PE/OPaaS creates namespace + catalog Resource first (see `golden-path/catalog/README.md`).

### Step C — Catalog view

1. **Catalog** → **Components** → `<appName>`.
2. Show: owner, system, tags, cluster/namespace annotations.
3. Show: `acme.io/devspaces-factory-url` (Dev Spaces deep link).
4. **Plugins** (if configured): Kubernetes, Sonar, Jenkins, Argo CD tabs.

### Step D — Dev Spaces (inner loop — not part of scaffold logic, but part of flow)

1. From scaffolder success or catalog → **Open in Dev Spaces**.
2. Workspace starts in `openshift-devspaces-{userid}`.
3. Run devfile commands: **install-hooks** → **build** → **test** → **run**.
4. **VS Code extensions** (narrate target): Copilot, Podman, Gradle, Quarkus/Java, OCP, live reload, Snyk, SonarQube — mix of local VS Code + UDI image.
5. Commit + push → triggers **CloudBees webhook** → Jenkins (after pipeline template).

### Step E — Release Pipeline template (second repo)

1. RHDH **Create** → **Spring Boot App — Release Pipeline**.
2. Same **appName** + Bitbucket workspace + namespace/env params.
3. Creates:
   - **`<appName>-gitops`** manifest repo (Kustomize **base + overlays/dev + overlays/prod**)
   - **Jenkinsfile** in app repo (or pipeline job wiring — per your Jenkins setup)
   - **Argo CD Application** CR for dev (+ prod overlay)

**Repo layout (source)**

```
<appName>/
  build.gradle.kts | package.json
  Jenkinsfile
  devfile.yaml
  Dockerfile
  catalog-info.yaml
  scripts/quality-gate.sh
  docs/ README.md
```

**Repo layout (manifest / gitops)**

```
<appName>-gitops/
  base/          Deployment, Service, Route, kustomization
  overlays/dev/  image tag / replicas / namespace patch
  overlays/prod/ digest pin, Jira change ticket annotation
```

**Helm vs Kustomize (answer for workshop)**

| AS-IS | Golden path in repo |
|-------|---------------------|
| Most CD uses **Helm** | Templates scaffold **Kustomize** |
| Standardisation target | **Argo CD + Kustomize** (or Helm wrapper — decision needed) |

---

## 3. CI/CD pipeline — full swimlane (TO-BE + gaps)

Use this slide when Jenkins is not live in the room.

### On commit / PR (source repo)

```
Push / PR opened
  → CloudBees webhook
  → Jenkins multibranch
       1. Checkout
       2. Unit test (Gradle / npm)
       3. SonarQube analysis + quality gate     [HARD GATE]
       4. Snyk (build.gradle.kts / package.json) [HARD GATE]
       5. Compile / build JAR
       6. Build container image (buildah)
       7. roxctl image scan                     [INFORM]
       8. roxctl image check                    [HARD GATE — ACS policy]
       9. SBOM generate (Syft / CycloneDX)      [ADD — TO-BE if not wired]
      10. Red Hat Trusted Artifact Signer       [Cosign sign — IN REPO Jenkinsfile]
      11. RHTPA / trusted profile analyse       [ADD — see § Supply chain]
      12. Push image → Artifactory (non-prod)   [Xray scan on push]
      13. roxctl deployment check on rendered manifest [HARD GATE]
      14. Update gitops overlays/dev Deployment image tag (+ digest)
      15. PR to manifest repo OR direct push (team policy)
  → Argo CD sync → deploy to AcmeSpace (dev)
       16. Integration tests (against route URL)
```

### Trunk-based promotion (after merge to `main`)

```
Merge to main
  → Same Jenkinsfile (main branch)
  → Build + push image (commit SHA tag)
  → Update overlay/dev (auto)
  → Manual approval gate — Non-Prod promote (Jenkins input / CloudBees)
  → ServiceNow change — pre-prod → prod (OPaaS: **both** prod and non-prod need SNOW)
  → Update overlay/uat | overlay/perf (if in scope — team variance)
  → Manual approval gate — Prod
  → Pull/tag/push **prod Artifactory** repository
  → Update overlay/prod Deployment (digest pin — Kyverno require-image-digest)
  → Argo CD sync prod
  → Splunk / Dynatrace observability
```

**Manual trigger today:** CloudBees — multibranch **Scan repository** or webhook on push; **manual promote** stages use Jenkins `input` step + ServiceNow ticket ID.

**Ephemeral envs (Lighthouse):** AS-IS for PR preview — **not** in golden-path template today; Dev Spaces covers inner loop; Lighthouse = separate parking lot.

---

## 4. Supply chain — what to add beyond your notes

| Tool | Stage | Purpose | In repo today? |
|------|-------|---------|----------------|
| **SonarQube** | CI | Code quality gate | ✅ Jenkinsfile |
| **Snyk** | CI | SCA / code | ✅ Jenkinsfile |
| **JFrog Xray** | Registry | Image CVE scan | Narrate — Artifactory push |
| **ACS `roxctl image check`** | CI | Policy gate before promote | 📋 TO-BE (documented in workshop) |
| **ACS `roxctl deployment check`** | CI | Manifest policy | 📋 TO-BE |
| **Cosign / RHTAS** | CI | Sign image digest | ✅ Jenkinsfile |
| **SBOM (Syft)** | CI | CycloneDX/SPDX attest | 📋 ADD to Jenkinsfile |
| **RHTPA** (Trusted Profile Analyzer) | CI | Profile compliance vs Red Hat trusted base | 📋 ADD — analyse image before push |
| **Kyverno** | Admission | Digest + cosign + Jira ticket prod | ✅ `components/policy-as-code/` |
| **ACS admission** | Deploy | Runtime enforce (phased) | 📋 Prod milestone |
| **Splunk** | Runtime | Logs / audit index (AKB_ID) | App team prereq |

**RHTPA one-liner for room:** *Analyses the built image against Red Hat trusted profiles before it is promoted — complements Xray (CVEs) and ACS (policy).*

---

## 5. OpenAPI v3.0 in templates

| Archetype | Today | How to use in session |
|-----------|-------|------------------------|
| **Node.js** | `golden-path/nodejs/skeleton/openapi.yaml` | Show contract-first; `npm` codegen if configured |
| **Java / Quarkus** | No `openapi.yaml` in Spring skeleton yet | **Narrate:** Experience APIs = OAS 3.x in repo root + generated tests; add file to skeleton post-workshop |

**Template enhancement (backlog):** scaffolder parameter `apiTitle` / `apiVersion` → generate `openapi.yaml` + catalog **API** entity.

---

## 6. Vault — how it fits (narrate; not scaffolded yet)

| Topic | Current Acme pattern |
|-------|-------------------------|
| Platform scope | SF SRE owns Vault; **namespaces self-service** via Bitbucket/CloudBees |
| Auth | **Kubernetes auth** — SA in app namespace → Vault role → policy |
| Environments | Separate **prod** and **nonprod** Vault paths for app secrets |
| Consumption in OCP | **VaultSecret** (static/dynamic) CR — ESO/VSO pattern |
| Golden path gap | Template should scaffold default KV path + `VaultSecret` stub — **not in repo yet** |

**Desired path pattern (example):** `secret/data/<acmespace>/<appName>/nonprod/...`

---

## 7. Open questions — facilitator answers

| Question | Short answer |
|----------|----------------|
| Manual trigger — CloudBees? | **Yes** — webhook on push; multibranch scan; promote stages use **manual input** + ServiceNow |
| Ephemeral envs + dependencies? | **Lighthouse** today for PR ephemerals; golden path uses **Dev Spaces** for inner loop + **dev overlay** for shared dev |
| Helm or Kustomize for Argo? | **AS-IS: Helm**; **golden path repo: Kustomize** — align in standardisation workshop |
| Namespace exists vs new? | **Picker assumes exists**; OPaaS creates AcmeSpace; Kyverno can label `mesh-enroll` |
| ServiceNow scope? | Pre-prod→prod **all apps**; some teams also perf→uat — encode in Jenkins promote stages |
| CloudBees webhooks? | PE creates when repo scaffolded — post step after Bitbucket publish |

---

## 8. Demo fallback checklist

If live integrations fail, show **in repo**:

| Show | Path |
|------|------|
| Template definition | `golden-path/springboot/template-app-code.yaml` |
| Devfile | `golden-path/springboot/skeleton/devfile.yaml` |
| Jenkins stages | `golden-path/springboot/pipeline-skeleton/Jenkinsfile` |
| GitOps overlays | `golden-path/springboot/pipeline-skeleton/gitops/` |
| Kyverno prod gates | `components/policy-as-code/base/policies/release-gates.yaml` |
| Namespace catalog | `golden-path/catalog/namespaces/` |

---

## 9. Parking lot (capture on stickies)

- [ ] Rename Spring Boot template → Quarkus in RHDH UI
- [ ] Start Feature template (branch from Jira, no new repo)
- [ ] VaultSecret + default path in scaffolder
- [ ] `roxctl` + SBOM + RHTPA stages in Jenkinsfile
- [ ] UAT/perf overlays in gitops skeleton
- [ ] ServiceNow plugin in RHDH vs Jenkins-only
- [ ] Lighthouse vs Dev Spaces positioning
- [ ] Helm → Kustomize migration standard

---

## 10. One-page flow (project on screen)

```
Jira (In Progress)
    ↓
RHDH Create → App Code template
    ↓
Bitbucket source repo + catalog Component
    ↓
RHDH → Open in Dev Spaces (Non-Prod) → build/test/run → commit/push
    ↓
RHDH Create → Release Pipeline template
    ↓
Bitbucket gitops repo + Jenkinsfile + Argo CD app
    ↓
CloudBees CI: test → scan → sign → push Artifactory → update manifest → Argo deploy dev
    ↓
PR → merge main → manual promote → ServiceNow → prod Artifactory → Argo prod
```

---

**Facilitator close:** *Golden path standardises **what** is in the repo; PE owns **platform wiring** (AD, Vault, Artifactory whitelist, webhooks). App teams own **AcmeSpace** request and squad AD group.*
