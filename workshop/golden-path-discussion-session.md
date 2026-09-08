# Golden Path — Show & Discuss Session

**Format:** Walkthrough + facilitated discussion (no live implementation)  
**Duration:** 60–90 min  
**Goal:** Align on **what the golden path looks like**, who does what, and what must be decided before build-out  
**Materials:** This repo on screen · RHDH screenshots (if available) · Miro/whiteboard for decisions

---

## How to run this session

| Do | Don't |
|----|--------|
| Show **templates, skeleton folders, Jenkinsfile, devfile** in the repo | Run scaffolder or deploy to cluster |
| Ask **“how do you do this today?”** before showing TO-BE | Present as finished product |
| Capture **variance** (Helm vs Kustomize, CloudBees vs Jenkins, Quarkus naming) | Argue one tool over another |
| Park **Vault, Lighthouse, ServiceNow detail** if time is short | Deep-dive one integration for 30 min |

**Opening line:**  
> *“This is a **target picture** and a **reference implementation** in Git — not what’s running in your cluster today. We’re here to react, challenge, and agree what ‘good’ looks like for Acme.”*

---

## Session flow (suggested)

| Time | Block | What you show | Discussion focus |
|------|-------|---------------|------------------|
| 0:00 | **Framing** | One-slide flow (§10 in runbook) | Why golden path; who owns what |
| 0:10 | **RHDH entry** | `template-app-code.yaml`, homepage links | Create vs catalog; personas |
| 0:25 | **What gets scaffolded** | `skeleton/`, `_shared/governance/` | Repo contents; PR template; trunk |
| 0:35 | **Two repos** | App repo + `pipeline-skeleton/gitops/` | Manifest repo; image tag updates |
| 0:45 | **Inner loop** | `devfile.yaml`, Dev Spaces architecture | vs local IDE; vs Lighthouse |
| 0:55 | **CI/CD & gates** | `Jenkinsfile` + supply-chain table | CloudBees; SNOW; manual promote |
| 1:10 | **Security chain** | Policy-as-code, ACS slide | roxctl, Xray, RHTPA, Cosign |
| 1:20 | **Decisions** | Parking lot | Sign-off actions |

---

## Block 1 — The story in one picture (5 min)

**Show:** End-to-end diagram (talk track only).

```
Jira story
  → RHDH "Create" (new service OR future "Start Feature")
  → Bitbucket source repo + catalog Component
  → Dev Spaces (Non-Prod) for inner loop
  → PR (template) → CloudBees CI
  → Image → Artifactory → manifest repo PR → Argo CD → AcmeSpace
  → Manual promote + ServiceNow → higher envs → Prod
```

**Discussion questions**

1. Where does this match how a team ships **today**? Where is it furthest from reality?
2. Is **trunk-based development** the standard, or do teams still use Gitflow?
3. Who must **approve** each hop — dev lead, platform, InfoSec, CAB?

---

## Block 2 — RHDH: how a developer starts (15 min)

**Show on screen**

| Artifact | Path | Say |
|----------|------|-----|
| Template list | `golden-path/all-templates.yaml` | “Four templates — two steps per language” |
| App code template | `golden-path/springboot/template-app-code.yaml` | “Form: app name, **AcmeSpace**, DC, Dev Spaces URL” |
| Namespace picker | `golden-path/catalog/namespaces/*.yaml` | “Namespaces must exist — we pick, we don’t create” |
| Success outputs | Template `output.links` section | “Bitbucket, catalog, Dev Spaces, next pipeline” |

**Discussion questions**

1. **New service vs feature:** Is “Onboard New Service” enough for now, or do you need **Start Feature** (branch from Jira, no new repo) on day one?
2. **AcmeSpace:** If namespace **already exists**, scaffold targets it — who provisions namespaces today (OPaaS, PE, app team)?
3. **Naming:** Template says Spring Boot / Gradle in repo; programme says **Quarkus** — same golden path, different skeleton, or two templates?
4. **Landing page:** What should RHDH homepage show — prereqs README, links to OPaaS, Vault request form?
5. **AD groups:** App teams create squad groups — how do those map to RHDH RBAC and OCP namespace access?

**Capture**

| Decision | Options | Owner |
|----------|---------|-------|
| Namespace model | Exists-only picker / auto-create via template | |
| Java archetype | Quarkus / Spring Boot / both | |
| Feature flow | Phase 1 manual branch / Phase 2 Start Feature template | |

---

## Block 3 — What lands in the repos (10 min)

**Show:** Folder tree of `golden-path/springboot/skeleton/` and `_shared/governance/`.

**Source repo (conceptual)**

- Gradle (or Quarkus), `Dockerfile`, `devfile.yaml`, `catalog-info.yaml`
- `scripts/quality-gate.sh`, pre-commit, **PR template**
- `docs/` + `README.md` (TechDocs — if enabled)

**Manifest repo (after release pipeline template)**

- Kustomize `base/` + `overlays/dev`, `overlays/prod`
- Deployment, Service, Route; mesh labels if enrolled

**Discussion questions**

1. Is **two repos** (source + gitops) the right split for all teams?
2. **Repo naming** — app name only, or prefix/squad convention?
3. **Branch naming** — tied to Jira key? Who creates the branch?
4. **PR template** in repo — what checks must humans attest (Sonar, Snyk, Zephyr, peer review)?
5. **OpenAPI v3** — contract-first for Experience APIs: mandatory in skeleton? (Node skeleton has `openapi.yaml`; Java does not yet.)
6. **AGENTS.md** / Copilot — include in template?

**Capture**

| Decision | Notes |
|----------|-------|
| GitOps layout | Kustomize (template) vs Helm (AS-IS) — migration plan? |
| OpenAPI in skeleton | Required for API services only? |
| Docs location | TechDocs in repo vs Confluence |

---

## Block 4 — Dev Spaces & inner loop (10 min)

**Show:** `devfile.yaml`, tooling table from `devspaces-workshop-miro.md` (Gradle, npm, quality-gate).

**Discussion questions**

1. **Dev Spaces vs local VS Code** — mandatory, default, or optional for greenfield?
2. **Prod RHDH → Non-Prod Dev Spaces** — acceptable for all code classifications?
3. **Extensions** — Copilot, Podman, Snyk, Sonar: platform image vs bring-your-own?
4. **Lighthouse ephemerals** — still needed for PR preview, or Dev Spaces + dev overlay enough?
5. **5pm shutdown / idle timeout** — cost vs developer friction?
6. Is inner loop **part of the template** or **platform capability** developers opt into?

**Capture**

| Decision | Choice |
|----------|--------|
| Dev Spaces policy | Mandatory / default / optional |
| PR ephemeral env | Lighthouse / shared dev / both |
| Workspace storage | Per-user PVC / ephemeral |

---

## Block 5 — CI/CD: CloudBees, promotion, ServiceNow (15 min)

**Show:** `pipeline-skeleton/Jenkinsfile` — read stage names only, don’t run.

**Stages to talk through**

1. Test → Sonar → Snyk  
2. Build image → push Artifactory  
3. Cosign sign  
4. Update **manifest repo** overlay with image tag/digest  
5. Argo CD sync dev  
6. Integration tests  
7. **Manual** promote prod + Jira/SNOW ticket  

**Discussion questions**

1. **Manual trigger today** — CloudBees webhook on push only, or also manual “deploy to dev”?
2. **Root pipeline vs repo Jenkinsfile** — inherit from shared library or copy per repo?
3. **Who updates Deployment.yaml** — CI job only, or can devs edit manifests?
4. **Promotion gates:** Which env pairs need **ServiceNow**? (You noted OPaaS: non-prod and prod; some apps perf→uat too.)
5. **Manual approval** — Jenkins input step vs CloudBees approval vs ServiceNow only?
6. **Ephemeral env** — who creates dependencies (DB mocks, wiremock, mesh)? Platform tide vs team-owned?
7. **Splunk index (AKB_ID)** — when is it requested in the flow?

**Capture**

| Gate | Automated / manual | Tool |
|------|------------------|------|
| PR merge | | Bitbucket + Sonar/Snyk |
| Deploy dev | | Argo CD |
| Promote UAT/perf | | |
| Promote prod | | SNOW + approver group |

---

## Block 6 — Security & supply chain (10 min)

**Show:** Supply chain table (narrate); optionally `components/policy-as-code/base/policies/release-gates.yaml`.

| Tool | When | Gate or inform? |
|------|------|-----------------|
| SonarQube | CI | **Gate** on PR/merge |
| Snyk | CI | **Gate** |
| JFrog Xray | Registry | Today scan — **gate TBD** |
| ACS `roxctl image check` | CI | **Gate** (TO-BE) |
| ACS `roxctl deployment check` | CI on manifest | **Gate** (TO-BE) |
| SBOM (Syft) | CI | Generate + store (TO-BE) |
| Cosign / RHTAS | CI | Sign; Kyverno verify on deploy |
| **RHTPA** (Trusted Profile Analyzer) | CI | Profile vs trusted base (TO-BE) |
| ACS admission | Deploy | Enforce phased |
| Splunk | Runtime | Audit / ops |

**Discussion questions**

1. **Xray vs roxctl** — duplicate gates or divide responsibility (Xray=CVE, ACS=policy)?
2. **Shift-left in Dev Spaces** — Sonar/Snyk in workspace optional; **hard gate stays in CI** — agree?
3. **Cosign + digest pin** — required for prod only or all envs?
4. **Material change** — when does ISG / pentest engage?
5. **Artifactory whitelist** — OPaaS prereq: who requests, how long?

---

## Block 7 — Vault, secrets, platform prereqs (5 min)

**Narrate** (not in template yet):

- Vault **kube auth**; prod/nonprod paths; `VaultSecret` CR  
- SF SRE owns platform; teams self-service namespace config via Bitbucket/CloudBees  
- Default KV path per AcmeSpace / app  

**Discussion questions**

1. Should the golden path scaffold a **default Vault path + VaultSecret stub**?
2. **AppRole vs kube auth** — what do app teams use today?
3. **Secrets in Dev Spaces** — OCP secrets injection only; never in repo — sufficient?

---

## Block 8 — Service mesh touchpoint (5 min)

**Show:** Template `enrollInMesh` flag; gitops labels (high level).

**Discussion questions**

1. Mesh enrolment at **scaffold time** vs separate workflow?
2. Dev workspace namespaces — **not** meshed; validate mesh in SysT — agree?
3. AuthorizationPolicies — platform baseline + team HTTPRoute tuning?

---

## Parking lot — stick on the board

Use these if the room goes quiet or you need a close:

| # | Topic | Question |
|---|-------|----------|
| P1 | Helm → Kustomize | Migration timeline or dual support? |
| P2 | Quarkus vs Spring Boot | One Java template or two? |
| P3 | Start Feature template | Phase 1 or 2? |
| P4 | Lighthouse | Keep, replace, or complement Dev Spaces? |
| P5 | CloudBees webhooks | PE creates per repo or org-wide pattern? |
| P6 | RHTPA + SBOM | Mandatory in phase 1 CI? |
| P7 | ServiceNow in RHDH | Portal integration or pipeline-only? |
| P8 | FinOps | Chargeback per workspace hour? |

---

## Close — actions to assign (5 min)

| Action | Owner | By when |
|--------|-------|---------|
| Confirm AcmeSpace provisioning process + catalog namespace list | PE | |
| Confirm Java archetype name (Quarkus vs Spring Boot) | Architecture | |
| Confirm SNOW gates per environment pair | Change mgmt | |
| Confirm Artifactory / OPaaS whitelist lead time | App teams | |
| Review template repo — feedback on two-repo layout | Squad leads | |
| Schedule follow-up: live demo in Non-Prod (Milestone 2) | PE | |

**Closing line:**  
> *“What you’ve seen is the **contract** between platform and app teams — templates encode opinion; your feedback decides what’s mandatory vs optional in phase 1.”*

---

## Quick reference — files to have open

| Topic | File |
|-------|------|
| Templates | `golden-path/springboot/template-app-code.yaml` |
| Skeleton | `golden-path/springboot/skeleton/` |
| Governance | `golden-path/_shared/governance/` |
| GitOps | `golden-path/springboot/pipeline-skeleton/gitops/` |
| Pipeline | `golden-path/springboot/pipeline-skeleton/Jenkinsfile` |
| Namespaces | `golden-path/catalog/namespaces/` |
| Dev Spaces | `golden-path/springboot/skeleton/devfile.yaml` |
| Kyverno | `components/policy-as-code/base/policies/` |
| Full pipeline detail | `workshop/golden-path-live-session-runbook.md` §3 |
