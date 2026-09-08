# Golden Path Delivery Flow — Miro Workshop Pack

**Use:** Day 1 / Day 2 / Day 7 — AS-IS vs TO-BE discussion  
**Paste:** Import `golden-path-delivery-flow-stickies.csv` — **one row = one sticky** (Sticky column only)

---

## Miro frame layout (suggested)

| Frame | Colour | Title |
|-------|--------|-------|
| 1 | Blue | **GP-01 · Actors & ownership** |
| 2 | Grey | **GP-02 · AS-IS — Jira → Prod (today)** |
| 3 | Green | **GP-03 · TO-BE Golden Path (target)** |
| 4 | Amber | **GP-04 · Approval gates & manual steps** |
| 5 | Purple | **GP-05 · Systems & integrations** |
| 6 | Red | **GP-06 · Security & ACS touchpoints** |
| 7 | Orange | **GP-07 · Open decisions / variance** |

---

## GP-01 · Actors

| Actor | Role | Manual / Auto |
|-------|------|---------------|
| **Developer** | Feature work, commits, unit tests, PR | Manual + IDE automation |
| **Peer engineer** | PR review, Zephyr cases, manual QA | Manual |
| **QA engineer** (SoD) | Perf/UAT validation separate from dev | Manual + automated tests |
| **Platform Engineering** | Templates, Lighthouse, prod deploy, on-call | Manual + automated |
| **App owner / approver group** | Change approval, promote decisions | Manual |
| **Change approval board** | SNOW change window (some apps) | Manual |
| **InfoSec / ISG** | Release risk assessment, pentest engagement | Manual (ad-hoc today) |
| **External pentest** | Scheduled + material-change assessments | Manual |
| **RHDH / scaffolder** | Onboarding, golden-path template | Automated (TO-BE) |
| **Jenkins / Cloudbees** | CI build, test, image, deploy triggers | Automated |
| **Argo CD / Spinnaker** | GitOps / CD to clusters | Automated |
| **ACS (RHACS)** | Build + deploy policy checks | Automated |
| **Snyk / SonarQube / Xray** | Code + image scanning | Automated |

---

## GP-02 · AS-IS — Step flow (Jira → Prod)

```
Step 1  Jira feature defined → assigned → In Progress
Step 2  Branch created (Jira or manual) — Gitflow OR trunk (variance)
Step 3  Clone repo → IDE (IntelliJ / VSCode + Copilot) — hooks: build, lint, Snyk, Sonar, licence
Step 4  Commit & push → Bitbucket webhook → Cloudbees Jenkins
Step 5  PR opened → Snyk + Sonar decorate — some checks gate pipeline
Step 6  PR review & merge
Step 7  Image build → Artifactory — Xray scans (NOT gating today)
Step 8  Deploy: Lighthouse ephemeral (PR trigger) OR SysT auto on merge
Step 9  SysT — UI/API auto tests (must be green for higher envs)
Step 10 UAT + Perf (static, parallel) — manual promote judgement
Step 11 SNOW change request → approval window → change tasks (platform on standby)
Step 12 Prod deploy — Platform team only — Cloudbees OR Spinnaker (some Argo)
```

**AS-IS gaps called out in discovery:**
- No SBOM / attestation / provenance verification
- No roxctl in pipeline (ACS deploy/runtime Inform-only)
- No integration tests on Lighthouse ephemerals
- Per-service pipelines — limited standardization
- Lighthouse: resource/stability/data-taint limits (40 env cap)
- Microservices: no Lighthouse; component-only tests, no platform tide
- Docs: Markdown + AGENTS.md; partial Confluence export

---

## GP-03 · TO-BE Golden Path (target state)

### Two RHDH templates — do not mix them up

| Template | When | Creates Bitbucket repo? | Jira link |
|----------|------|-------------------------|-----------|
| **Onboard New Service** | First time a microservice joins the platform | **Yes** — new repo, Jenkinsfile, Devfile, catalog entry | Optional — can register component |
| **Start Feature** | Every Jira story on an **existing** service | **No** — uses existing repo | **Yes** — story key drives branch name |

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ONBOARDING (once per service — separate from feature flow)                  │
│  RHDH "Onboard New Service" → NEW Bitbucket repo + Jenkinsfile + Devfile    │
│  + catalog-info + mesh/ACS labels + AGENTS.md                               │
│  Experience API variant → trunk-based only + OAS 3.x scaffold               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│  FEATURE FLOW (repeat per Jira story — repo already exists)                 │
│  Jira story → RHDH "Start Feature" → branch in existing repo + DevSpace      │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
Step 1  Jira story created → linked to existing RHDH catalog component (repo already exists)
        Developer launches RHDH **"Start Feature"** action — does NOT create a new repo
Step 2  Template action: auto-create branch in existing Bitbucket repo (from Jira key)
        + DevSpace/Devfile checkout for that branch
Step 3  Contract-first: OAS 3.x + generated contract tests (Experience APIs)
Step 4  Develop in IDE — feedback loop on commit (lint, Snyk, Sonar, licence)
Step 5  PR → decorate (Snyk, Sonar, AI review) + signal → ephemeral env (Lighthouse)
Step 6  CI pipeline (standard inherited Jenkinsfile):
          unit test → build image → roxctl image check (ACS BUILD) →
          SBOM generate + sign/attest (TO-BE) → push Artifactory → Xray
Step 7  roxctl deployment check (ACS) → deploy ephemeral (image tag = branch/PR)
Step 8  Integration / tide tests on ephemeral (subset → full platform tide TO-BE)
Step 9  Merge → auto SysT deploy → UI/API regression (gate)
Step 10 UAT + Perf parallel → QA sign-off (SoD) → performance benchmark
Step 11 SNOW CR + approver group (+ ISG if material) → change window
Step 12 Prod — GitOps (Argo CD standard) — ACS admission Enforce — platform deploy
Step 13 Runtime ACS + mesh observability → Splunk
```

---

## GP-04 · Approval gates

| Gate | AS-IS | TO-BE | Owner |
|------|-------|-------|-------|
| Pre-commit hooks | Some teams | Standard in template | Dev team |
| PR checks (Snyk/Sonar) | Gates some pipelines | All golden-path repos | Dev team |
| **ACS build (`roxctl image check`)** | ❌ Not in pipeline | ✅ Fail build on policy | Platform + InfoSec |
| Xray (registry) | Scan only, no gate | Policy gate (align with ACS?) | InfoSec |
| PR human review | Required | Required (+ AI assist) | Dev team |
| Lighthouse ephemeral | Self-service form | PR signal auto-provision | Platform |
| SysT automated tests | Required for promote | Required | QA / Dev |
| UAT / Perf | Manual judgement | Manual + defined DoD | QA (SoD) |
| **ACS deploy (`roxctl deployment check`)** | ❌ | ✅ Pre-apply in CI/GitOps PR | Platform |
| **ACS admission (cluster)** | Inform only | Enforce (phased) | InfoSec |
| SNOW change approval | Most apps | Retain — integrate metadata from pipeline | App owner |
| Prod deploy | Platform only | Platform + GitOps sync | Platform |
| Pentest / ISG | Ad-hoc Teams | Checklist for material changes | InfoSec |

---

## GP-05 · Systems map

| Phase | Systems |
|-------|---------|
| Planning | **Jira**, Zephyr, Confluence (export) |
| Onboarding | **RHDH**, Bitbucket, template repo |
| Develop | **DevSpaces** (Devfile), IntelliJ/VSCode, Copilot, **AGENTS.md** |
| Source | **Bitbucket**, Git (Gitflow / trunk — standardize TO-BE) |
| CI | **Cloudbees Jenkins**, inherited Jenkinsfile |
| Artifact | **Artifactory**, **Xray**, SBOM tool (TO-BE), cosign/sigstore (TO-BE) |
| Security scan | **Snyk**, **SonarQube**, **ACS roxctl**, **RHACS** Central |
| Ephemeral | **Lighthouse** portal → OpenShift |
| Static envs | **SysT**, **UAT**, **Perf** |
| CD / Prod | **Argo CD** (standardize), Cloudbees, Spinnaker (legacy) |
| Change | **SNOW** |
| Runtime | OpenShift, **ACS** runtime, **Istio mesh** (TO-BE), Splunk |

---

## GP-06 · ACS placement (build + deploy)

| Stage | Tool | When | Gate? |
|-------|------|------|-------|
| **Build** | `roxctl image scan` | After `docker build` / before push | Report |
| **Build** | `roxctl image check` | Before Artifactory promote | **Fail pipeline** |
| **Build** | `roxctl deployment check` | On rendered K8s/Helm manifest in CI | **Fail pipeline** |
| **Registry** | ACS registry integration | On push / scheduled | Inform → Enforce |
| **Deploy** | ACS admission webhook | `oc apply` / Argo sync | **Block deploy** (Enforce) |
| **Runtime** | ACS sensor/collector | Running workload | Inform → Enforce |
| **Notify** | ACS → Splunk HEC | On violation | Per-policy opt-in |

**CI token:** ACS Continuous Integration role — no admin console access.

---

## GP-07 · Open decisions for workshop

- Gitflow vs trunk — mandate trunk for Experience APIs only, or all microservices?
- Single CD tool: Argo CD vs Cloudbees vs Spinnaker per env?
- Xray gate vs ACS `roxctl` — duplicate or divide responsibility?
- Lighthouse: integration test tide — who owns, which schedule?
- SBOM + attestation standard (Syft, CycloneDX, cosign)?
- RHDH template: which steps are Phase 1 vs later?
- ACS Enforce: CI first, then admission, then runtime?
- Ephemeral env trigger: PR webhook vs chat command vs RHDH action?

---

## ASCII — AS-IS vs TO-BE (paste as Miro diagram)

### AS-IS
```
Jira → branch → IDE → commit → Bitbucket → Jenkins → [Snyk/Sonar gate]
  → PR review → merge → image → Artifactory [Xray scan, no gate]
  → Lighthouse ephemeral (PR) / SysT (merge) → UAT∥Perf → SNOW → Prod
                                                      ↑ manual
                                    ACS: runtime Inform only (no roxctl)
```

### TO-BE Golden Path
```
Jira → RHDH template → branch + DevSpace → OAS contract tests
  → IDE feedback → PR [Snyk/Sonar/AI] → ephemeral (auto)
  → Jenkins [unit | roxctl image check | SBOM | push | roxctl deploy check]
  → Lighthouse tide tests → merge → SysT [auto tests] → UAT∥Perf → SNOW → Argo → Prod
                              ↑ ACS admission Enforce          ↑ ACS runtime
```
