# OpenShift Dev Spaces — Workshop Pack

**Use:** Day 2 (RHDH golden path) · Day 7 (platform architecture) · optional 90-min breakout  
**Audience:** Platform engineering, app team leads, InfoSec (read-only), RHDH owners  
**Goal:** Agree Dev Spaces placement, developer UX, sizing, and how it connects to RHDH + golden path

**Related repo:** `components/devspaces/`, `golden-path/*/skeleton/devfile.yaml`, `golden-path/_shared/governance/`

---

## Miro frame layout (suggested)

| Frame | Colour | Title |
|-------|--------|-------|
| 1 | Blue | **DS-01 · What & why** |
| 2 | Grey | **DS-02 · AS-IS developer inner loop** |
| 3 | Green | **DS-03 · TO-BE with Dev Spaces** |
| 4 | Purple | **DS-04 · Architecture & multi-DC** |
| 5 | Amber | **DS-05 · Golden path integration** |
| 6 | Red | **DS-06 · Security & compliance** |
| 7 | Orange | **DS-07 · Sizing & operations** |
| 8 | Teal | **DS-08 · Live demo script** |
| 9 | Pink | **DS-09 · Decisions & parking lot** |

Import stickies: `devspaces-workshop-stickies.csv` (Sticky column only)

---

## DS-01 · What & why (10 min)

### One-liner

> **OpenShift Dev Spaces** = browser-based VS Code + Git + build tools running as pods on OpenShift, defined by **`devfile.yaml`** in the app repo.

### What it is NOT

| Not | Actually |
|-----|----------|
| A replacement for Jenkins / Argo CD | Inner dev loop only |
| RHDH itself | RHDH **links** to Dev Spaces; operator runs on OCP |
| Production runtime | Dev/test coding environment |
| Mandatory for all devs | Golden path default; local IDE still allowed |

### Why Acme wants it

- Same toolchain for every developer (Java 21, Node 20, Gradle, npm)
- No laptop setup drift — onboard in minutes via RHDH template
- Pre-commit + quality-gate in cloud IDE before PR
- Aligns with **transparent + aware** mesh model (dev in eDev/Non-Prod DC, deploy via CI)

### Facilitator talking points

1. "How long does a new developer take to build and run a service locally today?"
2. "How many different JDK/Node versions are in use across teams?"
3. "Is Dev Spaces **default**, **optional**, or **mandatory** for greenfield?"

---

## DS-02 · AS-IS inner loop (10 min)

```
Jira story → clone Bitbucket → install JDK/Node/Gradle locally
  → IntelliJ / VSCode + Copilot → commit → push
  → PR (some teams: Sonar/Snyk on PR only)
  → Jenkins → deploy SysT
```

### AS-IS pain (capture on stickies)

- Laptop setup guides per team; days to first commit
- Inconsistent hook adoption (`--no-verify` common)
- VPN + cluster access for integration testing
- No standard PR template on all repos
- DevSpaces / Che not deployed (or unknown)

---

## DS-03 · TO-BE inner loop (15 min)

```
Jira → RHDH "Start Feature" (branch in existing repo)
  → Open in Dev Spaces (factory URL from catalog / template output)
  → devfile: VS Code (che-code) + Git + quality-gate commands
  → pre-commit on commit / pre-push tests
  → push → Bitbucket PR (template pre-filled)
  → Sonar + Snyk gate → Jenkins → Argo → SysT
```

### TO-BE components (already in gitops repo)

| Component | Location |
|-----------|----------|
| Dev Spaces operator + CheCluster | `components/devspaces/` |
| devfile per archetype | `golden-path/*/skeleton/devfile.yaml` |
| Pre-commit + PR template | `golden-path/_shared/governance/` |
| RHDH link after scaffold | Template output + catalog annotations |
| Namespace picker | `golden-path/catalog/namespaces/` |

### Two RHDH templates (do not mix)

| Template | Dev Spaces action |
|----------|-------------------|
| **Onboard New Service** | Creates repo with `devfile.yaml` + hooks + PR template |
| **Start Feature** | Opens workspace on **feature branch** (no new repo) |

---

## DS-04 · Architecture & two Non-Prod DCs (20 min)

### Cluster placement (recommended)

| Cluster | Dev Spaces? | Why |
|---------|-------------|-----|
| **eDev** | Primary | Lowest risk, sizing experiments |
| **Non-Prod DC-1 / DC-2** | Optional second install | Teams needing DC-local integrations |
| **Prod** | **No** | Compliance + resource isolation |

### Multi-DC developer entry

```
Option A — Multicluster redirector (one URL)
  devspaces.acme.example → OAuth → group map → DC-1 or DC-2 dashboard

Option B — RHDH catalog link per namespace
  acme.io/devspaces-factory-url on component page

Option C — Template parameter devSpacesBaseUrl per DC
```

### Architecture diagram (draw on Miro)

```
Developer → RHDH / Redirector URL
         → Dev Spaces (DC-1 or DC-2)
         → Bitbucket (git push)
         → Jenkins (same central CI)
         → Argo CD → app namespace (picked in template EntityPicker)
```

**Key rule:** Workspace cluster ≠ deploy cluster is OK; git is the handoff.

### Discovery questions

- One Dev Spaces URL or redirector?
- Same Bitbucket/Jenkins for both DCs?
- Can a workspace in DC-1 push code that deploys to DC-2?

---

## DS-05 · Golden path integration (15 min)

### What the template scaffolds

| File | Purpose |
|------|---------|
| `devfile.yaml` | che-code editor, UDI tools image, build/test/run commands |
| `.pre-commit-config.yaml` | Lint + quality-gate on commit; tests on push |
| `pull_request_template.md` | Bitbucket PR checklist (Jira, Sonar, Snyk) |
| `scripts/quality-gate.sh` | Shared entry for hooks, devfile, CI |
| `scripts/install-git-hooks.sh` | Run once after clone |

### devfile commands (demo these)

| Command | When |
|---------|------|
| `install-hooks` | First workspace session |
| `build` / `test` / `run` | Daily dev (Spring: `./gradlew`; Node: `npm`) |
| `lint` | Pre-commit equivalent |
| `quality-gate` | Before push |

### Dev Spaces tooling stack

Tools come from three layers — editor image, UDI tools container, and repo-scaffolded scripts.

**What you have now (golden path devfile)**

| Layer | What | Image / source |
|-------|------|----------------|
| **Editor** | VS Code in browser | `che-code` (separate Dev Spaces editor component) |
| **Tools container** | Build, Git, shell, devfile commands | `quay.io/devfile/universal-developer-image:ubi9-latest` |
| **Repo (per app)** | `gradlew`, hooks, `quality-gate.sh`, pre-commit config | Cloned from Bitbucket at workspace start |

**Already in stock UDI (no custom bake needed)**

| Category | Tools |
|----------|--------|
| **SCM** | `git`, `gh` (if enabled in image tag) |
| **Java** | OpenJDK 8/11/17/21 (via `JAVA_HOME`) |
| **Build** | Gradle (primary for Spring golden path); Maven also present in UDI |
| **Node** | Node.js + `npm` (versions vary by tag) |
| **Python** | Python 3, pip |
| **Containers** | `podman` / buildah (for local image builds) |
| **Shell / utils** | bash, curl, jq, make, etc. |

Spring Boot devfile sets `JAVA_HOME` for Java 21; Node template uses `NODEJS_VERSION` env.

**Wired in repo (not in the image — every scaffolded app)**

| Tool / pattern | Where | Runs in Dev Spaces |
|----------------|--------|-------------------|
| **pre-commit** framework | `.pre-commit-config.yaml` | After `install-git-hooks.sh` |
| **quality-gate.sh** | `scripts/` | lint, test, optional sonar/snyk |
| **Gradle wrapper** | `./gradlew` (`build.gradle.kts`) | build / test / run / sonar |
| **npm scripts** | `package.json` (Node skeleton) | lint, test, dev |
| **Spotless** (Java lint) | Gradle plugin in app | `quality-gate.sh --lint-only` |
| **ESLint** (Node lint) | `npm run lint` | `--lint-only` |

**Referenced but not guaranteed in UDI today**

| Tool | In stock UDI? | How to get it in workspace |
|------|---------------|----------------------------|
| **Sonar Scanner CLI** | Often **no** | Bake into custom image **or** `./gradlew sonar` **or** CI only |
| **Snyk CLI** | Often **no** | Bake into custom image **or** `npm i -g snyk` in devfile `postStart` **or** CI only |
| **roxctl (ACS)** | **No** | CI/deploy only — not needed in Dev Spaces |

| Where | Sonar / Snyk |
|-------|----------------|
| **Dev Spaces** | Optional shift-left (if platform adds CLI + tokens) |
| **PR + Jenkins** | **Required gates** (TO-BE) |

**Recommended bake for Acme custom image (Phase 1 target)** — workshop decision **D8**

| Image | Audience |
|-------|----------|
| `artifactory…/acme/devspaces-udi-java:21` | Spring Boot golden path |
| `artifactory…/acme/devspaces-udi-node:20` | Node golden path |
| Or one **fat** `devspaces-standard:1.x` | Platform default |

| Tool | Why bake |
|------|----------|
| **git** | Core (already in UDI) |
| **Java 21 + 17** | Bank-supported JDKs only |
| **Gradle 8.x** | Pinned version (Spring Boot golden path) |
| **Node 20 LTS + npm** | Pinned version |
| **pre-commit** | Avoid pip install every workspace |
| **Sonar Scanner** | Shift-left scans in Dev Spaces |
| **Snyk CLI** | `snyk test` / `snyk code` before push |
| **jq, yq, openssl, curl** | Scripts / API debugging |
| **oc / kubectl** (optional) | `oc` debug against Non-Prod (RBAC-limited) |
| **Corporate CA certs** | Trust internal Bitbucket, Sonar, Artifactory |
| **Gradle init / `gradle.properties` + npm registry** | Point to Artifactory (read-only mirror) |

**Workshop summary slide (four tiers)**

| Tier | Tools |
|------|--------|
| **A — Image (platform)** | UDI base + pinned JDK/Node/Gradle + git + pre-commit + Sonar scanner + Snyk CLI + corp CA + Artifactory settings |
| **B — Editor (che-code)** | VS Code + approved extensions |
| **C — Repo (golden path template)** | devfile commands, quality-gate, hooks, PR template, gradlew/npm |
| **D — CI only (not Dev Spaces)** | Full Sonar quality gate, Snyk policy gate, roxctl, Xray, deploy |

> **Phase 1:** public UDI + che-code + repo hooks/scripts. **Target:** bank-mirrored UDI with **Java 21, Node 20, Gradle, Git, pre-commit, Sonar Scanner, Snyk CLI**, and Artifactory trust — **enforcement stays on PR/Jenkins**, not in the image alone.

### RHDH catalog annotations

```yaml
acme.io/devspaces-url: ...
acme.io/devspaces-factory-url: ...
acme.io/devfile-path: devfile.yaml
acme.io/cluster: nonprod-dc1
```

### Source analysis in Dev Spaces (shift-left)

| Tool | In Dev Spaces? | Hard gate? |
|------|----------------|------------|
| ESLint / Spotless | Yes (devfile — `./gradlew spotlessCheck` or `npm run lint`) | No |
| `quality-gate.sh` | Yes | No |
| SonarQube | Yes (if SONAR_TOKEN) | **PR / Jenkins** |
| Snyk | Yes (if SNYK_TOKEN) | **PR / Jenkins** |

**Facilitator line:** "Dev Spaces catches problems early; Bitbucket + Jenkins decide what merges."

---

## DS-06 · Security & compliance (15 min)

### Topics to decide

| Topic | Options |
|-------|---------|
| Workspace isolation | Per-user namespace (`openshift-devspaces-{userid}`) |
| Git credentials | OAuth to Bitbucket; no PATs in devfile |
| Secrets in workspace | OCP secrets → env; never in repo |
| Network egress | Reach Sonar, Snyk, Bitbucket, Artifactory? |
| Data classification | Can PCI-scoped code run in Dev Spaces? |
| Image source | `quay.io/devfile/universal-developer-image` vs bank mirror |
| Audit | Who can access whose workspace logs? |

### Mesh relationship

- Dev workspace namespaces: **usually not mesh-enrolled** (simpler)
- Deployed app namespaces: mesh via golden path (`mesh-enroll`)
- Devs validate mesh behaviour in **SysT**, not in IDE pod

### InfoSec questions

1. Is cloud IDE acceptable for all code classifications?
2. `--no-verify` on hooks — acceptable with PR gates?
3. Session timeout / idle workspace shutdown (cost + security)?

---

## DS-07 · Sizing & operations (15 min)

### Control plane (per cluster)

| Component | Ballpark |
|-----------|----------|
| Dev Spaces operator + CheCluster | ~1–2 Gi (shared) |
| Per active workspace | 2–4 Gi RAM, 0.5–2 CPU |

### Sizing worksheet (fill in workshop)

| Input | Your value |
|-------|------------|
| Developers using Dev Spaces | ___ |
| Peak concurrent workspaces | ___ |
| Avg workspace memory limit | ___ Gi |
| **Total RAM headroom needed** | ___ Gi |
| Idle timeout | ___ min |
| Max workspaces per user | 3 (default in CheCluster) |
| Storage strategy | per-user PVC (default) |

### Day-2 ownership

| Task | Owner |
|------|-------|
| Operator upgrades | Platform |
| CheCluster / devfile registry | Platform |
| devfile in app repos | App team (from template) |
| UDI image mirror | Platform |
| Cost monitoring | Platform + FinOps |

### Upgrade note

Dev Spaces upgrades **independent** of OCP — plan Non-Prod first, `RevisionBased` not relevant here (CheCluster not istiod).

---

## DS-08 · Live demo script (30 min)

**Prerequisites:** Dev Spaces installed (`oc get checluster -n openshift-devspaces`), sample repo or golden-path output.

### Part 1 — Platform check (5 min)

```bash
oc get checluster -n openshift-devspaces
oc get pods -n openshift-devspaces
oc get route -n openshift-devspaces
```

Open dashboard URL → SSO login.

### Part 2 — Sample workspace (10 min)

1. Dashboard → **Samples** → Node.js or import Git URL with `devfile.yaml`
2. Wait for workspace **Running**
3. Show: Explorer, terminal, Git panel, Commands (build/test/run)
4. Run **install-hooks** then edit a file → commit (show hook if configured locally)

### Part 3 — Golden path factory URL (10 min)

From RHDH template output or catalog:

```
{DEVSPACES_URL}/dashboard/#/load/workspace/factory?url={BITBUCKET_REPO}&devfilePath=devfile.yaml
```

Show branch parameter for **Start Feature** flow.

### Part 4 — Handoff to CI (5 min)

Push branch → show PR template → point to Sonar/Snyk on PR (even if not wired in demo env).

### Demo fallback

If operator not installed: walk through `devfile.yaml` + architecture frames only; schedule follow-up on eDev.

---

## DS-09 · Decisions to capture

| # | Decision | Options | Owner | Phase |
|---|----------|---------|-------|-------|
| D1 | Dev Spaces mandatory? | Mandatory / default / optional | | 1 |
| D2 | Which cluster(s)? | eDev only / DC-1 / DC-2 / both | | 1 |
| D3 | Single URL? | Redirector / per-DC URLs / RHDH links only | | 1 |
| D4 | Sizing (concurrent WS) | Number | | 1 |
| D5 | Idle timeout | Minutes | | 1 |
| D6 | Bitbucket auth model | OAuth / PAT / SSH | | 1 |
| D7 | Sonar/Snyk tokens in workspace | Shared SA / per-user | | 2 |
| D8 | UDI vs custom image | Public / Artifactory mirror | | 1 |
| D9 | PCI / classified code in Dev Spaces | Yes / no / exception | InfoSec | 1 |
| D10 | RHDH embed vs external link | Plugin / deep link | | 2 |

---

## Parking lot

- DevSpaces vs local IDE policy for contractors
- Copilot in Dev Spaces workspace
- Integration with Lighthouse ephemerals (PR env vs Dev Spaces)
- Licence for Red Hat Dev Spaces vs upstream Che
- DR: Dev Spaces unavailable — fallback to local IDE runbook

---

## 90-minute agenda (suggested)

| Time | Frame | Activity |
|------|-------|----------|
| 0:00 | DS-01 | What & why |
| 0:10 | DS-02 | AS-IS pain capture |
| 0:20 | DS-03 | TO-BE walkthrough (golden path) |
| 0:35 | DS-04 | Two DCs + redirector |
| 0:50 | DS-05 | Template / devfile / hooks |
| 1:00 | DS-06 | Security (InfoSec) |
| 1:10 | DS-07 | Sizing worksheet |
| 1:20 | DS-08 | Live demo (or recorded) |
| 1:50 | DS-09 | Decisions & actions |

---

## Facilitator cheat sheet

**If they ask "vs GitHub Codespaces"** — on-cluster, same SSO/network as OCP, Devfile standard, Red Hat support.

**If they ask "vs local IntelliJ"** — not either/or; Dev Spaces for standardisation, IDE for power users.

**If they ask "cost"** — concurrent workspaces × RAM × hours; idle timeout is the main control.

**If they ask "who installs"** — Platform (`components/devspaces/` GitOps); app teams only maintain `devfile.yaml` from template.
