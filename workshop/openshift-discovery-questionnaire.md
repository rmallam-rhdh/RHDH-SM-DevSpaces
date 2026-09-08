# OpenShift Platform Discovery Questionnaire

**Reusable facilitator guide for Red Hat Developer Hub (RHDH) and OpenShift Service Mesh discovery**

| Field | Value |
|---|---|
| Acme | |
| Engagement | |
| Consultant(s) | |
| Cluster context | OpenShift (assumed OVN-Kubernetes; CNI deep-dive not required) |
| Clusters in scope | e.g. E-Dev / Non-Prod / Prod |
| Session dates | |
| Out of scope | ACS review (unless separately scheduled) |

---

## How to use this document

1. Run questions in order within each topic. Skip only when the answer is already known and logged.
2. Capture answers in the **Answer** lines (or copy rows into Miro / Confluence).
3. Use **If stuck** when the room goes quiet, answers are vague, or stakeholders disagree.
4. Use **OpenShift note** to keep discussion grounded in OCP / operators / Routes / GitOps — not generic Kubernetes theory.
5. End every day with: **Decisions**, **Open questions**, **Owners**, **Follow-ups**.

### Answer capture conventions

| Symbol | Meaning |
|---|---|
| `[ ]` | Option — tick what applies |
| `Answer:` | Free-text capture |
| `→` | Follow-up only if that option is selected |
| **Decision** | Must be resolved before design, or logged as assumption |

---

## If you are stuck — quick recovery moves

| Situation | What to do |
|---|---|
| “We don’t know yet” | Ask: *Who would decide this?* Log as open question with owner + date. Do not invent an answer. |
| Conflicting answers | Capture both views. Ask: *Which environment is the source of truth — Non-Prod or Prod?* Prefer the Prod / InfoSec view for security questions. |
| Too abstract | Ask for a **concrete walkthrough**: *Pick one service (e.g. payments-api). Walk me from commit → deploy → call another service.* |
| Too tool-focused | Reframe: *What outcome do you need? We’ll map the OpenShift construct after.* |
| Security vs platform deadlock | Park as: *Assumption for design* + *InfoSec confirmation required*. Continue with remaining topics. |
| Silence | Use the **If stuck** prompt under that question, or: *If you had to choose today knowing you can revisit in design, what would it be?* |
| Running over time | Park deep-dives; keep **Decision** questions only; move detail to parking lot. |

### OpenShift grounding questions (use anytime)

- *Where does this run today — which cluster, which project/namespace?*
- *Is it installed via OperatorHub / OLM Subscription, or Helm / manual?*
- *Is it managed by OpenShift GitOps (Argo CD), or outside GitOps?*
- *How do users reach it today — OpenShift Route, LoadBalancer, or internal Service only?*
- *Who has `cluster-admin` vs project admin for this?*

---

# Part A — Red Hat Developer Hub (RHDH)

**Suggested schedule:** 4 days × 3 hours (see RHDH discovery schedule).  
**Platform context:** RHDH on OpenShift via RHDH Operator (`Backstage` CR), typically namespace `rhdh`, exposed via Route, secrets via Vault/ESO or equivalent.

---

## A0. Session kick-off

| # | Question | Capture |
|---|---|---|
| A0.1 | What must this discovery confirm before design can start? | Answer: |
| A0.2 | Who are the named decision owners for platform, identity, security, and app teams? | Answer: |
| A0.3 | Which OpenShift clusters will host RHDH (and which are in scope for the Kubernetes plugin)? | Answer: |

**If stuck:** *If we only get three decisions this week, which three unblock design?*

---

## A1. Current IDP landscape

### A1.1 Is there an existing Internal Developer Portal?

- [ ] Yes → which product? (Backstage OSS / Port / Cortex / OpsLevel / Confluence / other)
- [ ] No → have any solutions been evaluated? Findings?

**Answer:**

**Why it matters (OpenShift):** Migration vs greenfield changes operator config, catalog import, and plugin priorities.

**If stuck:** *Where do developers go today to find a service, its owners, and how to deploy it on OpenShift?*

---

### A1.2 What are the main pain points with the current approach?

**Answer:**

**If stuck:** Prompt with: slow onboarding, no service catalog, tribal knowledge in Confluence, no self-service templates, weak OpenShift visibility, broken CI status.

---

### A1.3 How are new services onboarded today?

Walk through: *“I need a new microservice” → it is running on OpenShift.*

| Step | Who | Tool | Typical time |
|---|---|---|---|
| | | | |

**If stuck:** Time-box a real example from the last quarter. *Who opened the ticket? Who created the project/namespace? Who set up the pipeline?*

---

### A1.4 Who will own RHDH after delivery?

Team name, size, OpenShift / operator experience:

**Answer:**

**Decision:** Named platform owner for Day-2 (upgrades, plugins, RBAC).

---

## A2. Source control and CI/CD

### A2.1 Primary SCM for application code?

- [ ] Bitbucket Cloud
- [ ] Bitbucket Server / Data Center
- [ ] GitHub.com / GitHub Enterprise
- [ ] GitLab.com / GitLab self-managed
- [ ] Azure DevOps Repos
- [ ] Other:

**Answer (host URLs, orgs/workspaces):**

**OpenShift note:** RHDH scaffolder and catalog discovery need network reachability from the cluster (or proxy) to SCM.

---

### A2.2 CI/CD tools in use? (select all)

- [ ] Jenkins
- [ ] Tekton / OpenShift Pipelines
- [ ] GitHub Actions
- [ ] Azure DevOps Pipelines
- [ ] GitLab CI
- [ ] Bamboo
- [ ] Other:

**Answer (which tool deploys to OpenShift today?):**

**If stuck:** *When an image lands in the registry, what updates the Deployment/DeploymentConfig or GitOps repo?*

---

### A2.3 Production deployment frequency today? Target after platform?

- [ ] Multiple / day [ ] Daily [ ] Weekly [ ] Monthly [ ] Ad hoc

**Target:**

---

## A3. Integration priorities (plugins)

### A3.1 Which integrations must appear in RHDH? (rank Must / Should / Could)

| Integration | Priority | Notes (URL, env) |
|---|---|---|
| Kubernetes / OpenShift resource view | | |
| Jenkins | | |
| Tekton / OpenShift Pipelines | | |
| Argo CD / OpenShift GitOps | | |
| SonarQube | | |
| Snyk | | |
| Jira | | |
| Artifactory / Quay | | |
| TechDocs | | |
| API management (APIC / Kong / Apigee) | | |

**OpenShift note:** Kubernetes plugin needs a SA token, API URL, and CA — usually bootstrapped into Vault/ESO for RHDH.

**If stuck:** *If developers only got three tiles on day one, which three reduce support tickets fastest?*

---

## A4. High availability and resilience

### A4.1 Availability SLA for Developer Hub?

- [ ] Best effort (dev tool; planned downtime OK)
- [ ] 99.5%
- [ ] 99.9% (standard HA) → drives DB + replicas
- [ ] 99.99% → drives DB + replicas + DR

**Decision:**

---

### A4.2 Database for RHDH? (SQLite is demo-only on OpenShift)

- [ ] Existing PostgreSQL (14+) → version, host, DBA owner:
- [ ] Managed PostgreSQL (RDS / Azure / Cloud SQL) → provider/region:
- [ ] CloudNativePG (or other PG operator) on OpenShift → already installed?
- [ ] SQLite / local — non-HA only

**OpenShift note:** For HA, RHDH pods (replicas ≥ 2) must share PostgreSQL. Storage for PG should be OpenShift-supported RWX/RWO as designed by platform.

**If stuck:** *If the RHDH pod restarts tonight, is losing catalog state acceptable?* If no → PostgreSQL is mandatory.

---

### A4.3 Replica count / HPA?

- [ ] 1 (no HA)
- [ ] 2 (basic HA)
- [ ] 3+ (rolling upgrades)
- [ ] HPA — min/max/metric:

**Node sizing / namespace quota available:**

---

### A4.4 Disaster Recovery instance required?

- [ ] Yes — RTO / RPO / DR cluster:
- [ ] No — single cluster enough

---

## A5. Architecture, exposure, catalog, branding

### A5.1 How should RHDH be exposed?

- [ ] Internal only (corp network / VPN)
- [ ] External (internet + auth) → domain + TLS approach:
- [ ] Both

**OpenShift note:** Default pattern is an **OpenShift Route** (+ optional private router / firewall). Confirm cert source (cluster wildcard, cert-manager, InfoSec-issued).

---

### A5.2 TechDocs storage?

- [ ] Local (built in pod)
- [ ] S3 / compatible
- [ ] Azure Blob
- [ ] ODF / NooBaa on-cluster
- [ ] Undecided

**Answer (bucket / owner):**

---

### A5.3 How will the software catalog be populated?

- [ ] Manual `catalog-info.yaml` in repos
- [ ] SCM auto-discovery (Bitbucket/GitHub/GitLab module)
- [ ] Bulk import from CMDB / registry
- [ ] Golden path templates self-register
- [ ] Push via API

---

### A5.4 Branding / homepage expectations?

**Answer:** (logo, colours, links, clocks, announcements)

---

## A6. Golden Paths and supply chain

### A6.1 Which golden path templates are in scope?

- [ ] Spring Boot — app code
- [ ] Spring Boot — release pipeline
- [ ] Node.js — app code
- [ ] Node.js — release pipeline
- [ ] Other:

**OpenShift note:** Templates should produce Deployment/Service/Route (or GitOps manifests), namespace labels for mesh if required, and pipeline that pushes to Quay/Artifactory.

---

### A6.2 Secure-by-default controls in templates? (select all that must be default)

- [ ] `runAsNonRoot`
- [ ] `readOnlyRootFilesystem`
- [ ] `allowPrivilegeEscalation: false`
- [ ] CPU/memory limits required
- [ ] Default-deny NetworkPolicy
- [ ] Ambient mesh enrolment label
- [ ] Vulnerability scan stage in pipeline
- [ ] SBOM generation
- [ ] Cosign image signing

**Decision:** Minimum secure-by-default set for v1 templates.

---

### A6.3 Image / registry governance?

- [ ] Approved registries only (Quay / Artifactory) — enforced how?
- [ ] Approved base image list in templates
- [ ] Cosign signature required
- [ ] Scan gate (no Critical/High) before deploy
- [ ] None yet

---

### A6.4 Vulnerability management process (CVE → production fix)?

| Severity | Notify who | Owner of fix | SLA | Exception process |
|---|---|---|---|---|
| Critical | | | | |
| High | | | | |
| Medium | | | | |

**If stuck:** Pick last Critical CVE they remember. Walk the timeline.

---

### A6.5 Who can change templates and `catalog-info.yaml`?

- [ ] Platform + security approval for templates
- [ ] Peer review only
- [ ] Sandbox test before prod promotion
- [ ] Signed commits / branch protection
- [ ] Informal

---

## A7. IAM, RBAC, admin access

### A7.1 Authentication requirements?

- [ ] MFA all users
- [ ] MFA admins only
- [ ] Session timeout policy:
- [ ] Managed-device only
- [ ] IP allowlist / VPN only
- [ ] Standard OIDC only

**IdP:** Keycloak / RH-SSO / Entra ID / Okta / other:

**OpenShift note:** Align RHDH OIDC with the same IdP used for OpenShift console where possible (reduces identity sprawl). Confirm groups claim for RBAC.

---

### A7.2 User personas needing access?

- [ ] Developer
- [ ] Tech lead
- [ ] Platform / IDP admin
- [ ] Security (read-only)
- [ ] Engineering manager
- [ ] External / contractor (scoped)

**Catalog ownership model:**

- [ ] Team-owned
- [ ] Platform-curated
- [ ] Hybrid (teams own components; platform owns templates/systems)

---

### A7.3 Admin access and break-glass?

Named admins:

Break-glass if IdP down:

**If stuck:** *If Keycloak/Entra is unavailable Monday morning, how does platform still operate RHDH?*

---

## A8. RHDH security & integration governance

### A8.1 Who approves new plugins?

- [ ] Platform + change board
- [ ] Security must approve permissions
- [ ] Informal
- [ ] Undefined

---

### A8.2 How are plugin secrets stored and rotated?

- [ ] Vault + External Secrets Operator (**typical on OpenShift GitOps**)
- [ ] Kubernetes Secrets only
- [ ] Sealed Secrets / SOPS
- [ ] Manual, no rotation

**Rotation schedule:**

---

### A8.3 What can the scaffolder ServiceAccount create on the cluster?

Current permissions:

Minimum required:

**Risk:** Over-privileged SA → privilege escalation via malicious template.

**OpenShift note:** Prefer least privilege in the `rhdh` namespace / target projects — avoid `cluster-admin` for scaffolder in production designs.

---

### A8.4 Integration token least-privilege review

| Integration | Current scope | Minimum needed | Gap? |
|---|---|---|---|
| Jenkins | | | |
| Jira | | | |
| Bitbucket / SCM | | | |
| Snyk | | | |
| Artifactory / Quay | | | |
| Argo CD | | | |
| OpenShift API (K8s plugin) | | | |

---

### A8.5 Template misuse / credential exposure controls?

- [ ] Platform+security merge gate for templates
- [ ] Sandbox promotion path
- [ ] Short-lived / bound SA tokens
- [ ] Vault dynamic secrets
- [ ] Token usage auditing

---

## A9. Success, adoption, close-out

### A9.1 What does success look like in 6 months?

(Be specific: # services in catalog, time to first deploy, adoption %)

**Answer:**

---

### A9.2 What would make developers prefer RHDH over today’s workflow?

**Answer:**

---

### A9.3 Executive sponsor?

- [ ] Yes — name and goal:
- [ ] No — how will adoption be driven? Mandate planned?

**Red flag:** No sponsor + voluntary adoption → plan for low uptake.

---

### A9.4 Day close-out checklist

- [ ] Decisions logged
- [ ] Open questions with owners/dates
- [ ] Assumptions documented
- [ ] Risks noted
- [ ] Next session agenda agreed

---

# Part B — OpenShift Service Mesh

**Suggested schedule:** 7 days × 3 hours (see Service Mesh discovery schedule).  
**Platform context:** OpenShift Service Mesh 3 (Sail Operator) ambient mode is the reference pattern unless acme already runs OSSM 2.x. CNI compatibility workshopping is **not required** on standard OpenShift (OVN-Kubernetes).  
**Excluded:** ACS (unless separate engagement).

---

## B0. Kick-off

| # | Question | Capture |
|---|---|---|
| B0.1 | Clusters and environments for mesh (E-Dev / Non-Prod / Prod)? | Answer: |
| B0.2 | Is the target OSSM 3 ambient, OSSM 2 sidecar, or undecided? | Answer: |
| B0.3 | What must discovery prove before Non-Prod install design? | Answer: |

**OpenShift note:** Mesh components typically land in `istio-system`, `ztunnel`, `istio-cni` via OLM operators — confirm who may install cluster-scoped operators.

---

## B1. Current mesh state

### B1.1 Is any service mesh deployed today?

- [ ] Yes → product/version:
- [ ] No → go to B1.4

**Namespaces enrolled / control-plane topology:**

---

### B1.2 What is working well? What are the pain points?

**Answer:**

**If stuck:** Sidecar CPU/RAM, upgrade pain, certificate issues, policy sprawl, poor Kiali adoption, “installed but unused”.

---

### B1.3 Features actively used? (select all)

- [ ] mTLS
- [ ] Traffic management (retry/timeout/canary)
- [ ] AuthorizationPolicies
- [ ] Kiali / observability
- [ ] Ingress gateway
- [ ] Installed but not actively used

---

### B1.4 If greenfield — primary adoption drivers? (rank)

- [ ] Zero-trust / mTLS
- [ ] Compliance
- [ ] Traffic management
- [ ] Observability / tracing
- [ ] Platform standardisation

**Decision:** Top driver that design must optimise for.

---

## B2. Namespaces, enrolment, scale

### B2.1 How are application projects/namespaces structured?

- [ ] One per team
- [ ] One per service
- [ ] One per environment (on same cluster)
- [ ] Shared namespaces
- [ ] Mixed

**Who creates OpenShift projects today?**

**If stuck:** *Show me three real project names in Non-Prod and who owns them.*

---

### B2.2 Ambient enrolment model

- [ ] Manual label `istio.io/dataplane-mode=ambient` per namespace
- [ ] Auto-enrol via policy-as-code (e.g. Kyverno)
- [ ] Hybrid (auto for app namespaces; exclude platform/system)

**Exclusions (never mesh):** e.g. `openshift-*`, monitoring, ingress — list:

**OpenShift note:** Confirm operator namespaces (`istio-system`, `ztunnel`) and whether user-workload monitoring is enabled for mesh metrics.

---

### B2.3 Scale and rollout

| Phase | Clusters | # namespaces / services | Pilot app | Success criteria |
|---|---|---|---|---|
| Phase 1 | | | | |
| Phase 2 | | | | |
| Full | | | | |

**Non-Prod → Prod sequence:**

---

## B3. Trust, mTLS, identity

### B3.1 Service-to-service mTLS posture?

- [ ] All traffic STRICT
- [ ] East-west STRICT; ingress separate
- [ ] Selective namespaces only
- [ ] Not defined

**Migration:** PERMISSIVE during onboard then STRICT? Timeline:

**Decision:**

---

### B3.2 Trust domain design?

- [ ] Single across all clusters
- [ ] One per environment (Non-Prod / Prod) — **typical for regulated**
- [ ] One per cluster
- [ ] Undecided

**If stuck (InfoSec):** *Should a Non-Prod workload ever present an identity that Prod trusts?* Usually **no** → per-env trust domain.

---

### B3.3 Tenancy model?

- [ ] Hard — deny-all; explicit AuthZ for every cross-namespace call
- [ ] Soft — namespace separation; some shared services allowed
- [ ] Hybrid — hard in Prod/regulated; soft in dev/test

---

### B3.4 Service identity requirements?

- [ ] Standard SPIFFE per ServiceAccount
- [ ] Dedicated SA per service (no shared SAs) — **recommended for AuthZ**
- [ ] Short-lived SVIDs
- [ ] Cert issuance visible in PKI inventory
- [ ] Cert issuance/rotation audited

**OpenShift note:** Identity = `spiffe://<trust-domain>/ns/<project>/sa/<sa>`. Shared `default` SA destroys AuthZ usefulness.

---

## B4. PKI, ingress, egress

### B4.1 Mesh certificate / PKI strategy?

- [ ] Istio self-signed CA (simple)
- [ ] Vault PKI (+ istio-csr / cert-manager pattern)
- [ ] cert-manager + enterprise CA (ADCS / EJBCA / Venafi)
- [ ] Bring-your-own root CA
- [ ] Undecided

**Rotation requirements / CA owner:**

**If stuck:** *Does InfoSec require every workload cert to chain to corporate root?* If yes → not self-signed long-term.

---

### B4.2 How does north-south traffic enter OpenShift today?

- [ ] OpenShift Routes (HAProxy)
- [ ] NGINX Ingress
- [ ] F5 / external LB
- [ ] Istio Ingress Gateway
- [ ] Kubernetes Gateway API
- [ ] Mixed

**Preferred future:** Keep Routes + mesh east-west, or mesh gateway for some apps?

**OpenShift note:** Routes and mesh commonly **coexist**. Decide explicitly per app class — do not assume all traffic moves to Istio Gateway on day one.

---

### B4.3 Is egress control required?

- [ ] All egress via controlled gateway
- [ ] Selective (e.g. PCI-scoped)
- [ ] No — unrestricted OK
- [ ] Undecided

| Namespace / service | Allowed external endpoints | Port | Owner |
|---|---|---|---|
| | | | |

**Additional controls?** DNS allowlist / TLS inspection / DLP / none beyond ServiceEntry

---

## B5. Authorization, threats, governance

### B5.1 Default posture between namespaces?

- [ ] Deny-all (zero-trust) — **recommended for Prod**
- [ ] Allow-by-default; deny selectively
- [ ] Deny-all only for regulated/Prod namespaces

---

### B5.2 Who owns AuthorizationPolicies?

- [ ] Platform owns all
- [ ] Teams own their namespaces; platform owns baseline deny-all
- [ ] Policy-as-code baseline + team extensions — **recommended**

**OpenShift note:** Prefer AuthZ manifests in Git → OpenShift GitOps; avoid long-term UI-only policy edits.

---

### B5.3 Lateral movement walkthrough

Pick: frontend **or** API **or** batch job compromised.

| Compromised workload | What can it call today? | Acceptable? | Required AuthZ granularity |
|---|---|---|---|
| | | Y/N | namespace / service / method |

---

### B5.4 Service impersonation mitigations?

- [ ] Strict project RBAC (no create in others’ projects)
- [ ] Kyverno — deny wrong SA
- [ ] Pod Security Admission restricted
- [ ] Other:
- [ ] None beyond default

---

### B5.5 Policy change audit / emergency change?

Who can change AuthZ:

GitOps-only?

Emergency break-glass:

Audit to Splunk? Y/N

---

## B6. L7, traffic, resiliency, multi-cluster, Prod, compliance

### B6.1 Are L7 policies required? (Waypoint)

- [ ] JWT / OIDC at mesh
- [ ] Header-based routing
- [ ] Path-based AuthZ
- [ ] Per-route rate limit
- [ ] No — L4 mTLS + AuthZ enough

**Namespaces needing Waypoint:**

**If stuck:** *Do you need to allow GET /health from everyone but deny /admin except platform SA?* If yes → L7/Waypoint.

---

### B6.2 Traffic / resiliency patterns required?

- [ ] Canary
- [ ] Blue/green
- [ ] Circuit breaker / outlier detection
- [ ] Retries
- [ ] Rate limiting
- [ ] Mirroring
- [ ] None yet

**Tooling preference:** Mesh-native vs Argo Rollouts / Flagger:

**Non-Prod patterns to prove before Prod:**

---

### B6.3 Multi-cluster federation required?

- [ ] Yes — clusters and spanning services:
- [ ] No — independent mesh per cluster
- [ ] Future only

---

### B6.4 Prod-specific differences from Non-Prod?

| Topic | Non-Prod | Prod |
|---|---|---|
| mTLS mode | | |
| AuthZ strictness | | |
| Egress | | |
| Change window / upgrades | | |

---

### B6.5 Compliance / audit requirements for mesh?

- [ ] PCI-DSS zone isolation
- [ ] SOC 2
- [ ] ISO 27001
- [ ] APRA CPS 234
- [ ] NZISM
- [ ] Internal policy only
- [ ] None formal

**Answer (what evidence must mesh provide?):**

---

## B7. Observability, Splunk, Day-2, risks, close-out

### B7.1 Observability expectations?

- [ ] Kiali service graph
- [ ] Distributed tracing → backend: Jaeger (OCP Distributed Tracing) / Tempo / Zipkin / Datadog / Dynatrace / none yet
- [ ] Prometheus + Grafana mesh dashboards
- [ ] Access logs to log platform

**Who looks at this weekly?**

**OpenShift note:** Enable user workload monitoring if scraping istiod/ztunnel via ServiceMonitor; confirm existing cluster monitoring ownership.

---

### B7.2 Mesh security events to Splunk (or SIEM)?

- [ ] Service-to-service access logs
- [ ] AuthorizationPolicy DENY
- [ ] mTLS handshake failures
- [ ] Policy change audit (who changed AuthZ)
- [ ] Egress blocked requests

**HEC / index / owner / retention:**

**If stuck:** *Which three events would SecOps actually alert on in week one?* Start there; expand later.

---

### B7.3 Day-2 ownership

| Area | Owner | On-call? | Runbook? |
|---|---|---|---|
| Control plane / operators | | | |
| Namespace AuthZ / enrolment | | | |
| Certificates / PKI | | | |
| Observability / Kiali | | | |

**Upgrade strategy:**

- [ ] Follow OCP upgrade cadence automatically
- [ ] Manual change window
- [ ] Pinned — security/change board approval

---

### B7.4 Developer experience model?

- [ ] Transparent — auto-enrol; developers don’t manage mesh config
- [ ] Aware — teams write VirtualService / DestinationRule
- [ ] Full owner — platform provides control plane only

**Golden path auto-enrolment required?** Y/N

---

### B7.5 Security assumptions and constraints (must document)

| # | Assumption or constraint | Type | Owner |
|---|---|---|---|
| 1 | | Assumption / Constraint | |
| 2 | | | |
| 3 | | | |

---

### B7.6 Risk register (draft)

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Lateral movement via compromised service | | | Deny-all AuthZ + least privilege |
| Service impersonation via shared SA | | | Dedicated SA + RBAC/Kyverno |
| Data exfiltration via egress | | | Egress allowlist + monitoring |
| Policy drift (AuthZ not in Git) | | | GitOps-only policies |
| Workload not enrolled in mesh | | | Auto-enrol + audit exceptions |
| | | | |

---

### B7.7 Close-out checklist

- [ ] Decisions logged (trust, mTLS, enrolment, AuthZ, ingress/egress, obs)
- [ ] Open questions with owners/dates
- [ ] Assumptions and constraints captured
- [ ] Risk register drafted
- [ ] Explicitly out of scope confirmed (ACS, implementation unless agreed)
- [ ] Design session agenda agreed

---

# Appendix 1 — OpenShift-specific facilitator cheat sheet

| Topic | Prefer this framing on OpenShift |
|---|---|
| Ingress | OpenShift **Route** vs Istio/Gateway API — coexistence is normal |
| Install | **OLM Subscription** / Sail Operator / RHDH Operator — not “helm on the side” unless true |
| GitOps | **OpenShift GitOps (Argo CD)** App-of-Apps for mesh + RHDH manifests |
| Secrets | **External Secrets + Vault** (or enterprise secret store) over plaintext in Git |
| Projects | OpenShift **Project** ≈ namespace + defaults; ask who can `oc new-project` |
| Identity | Same IdP as OCP console where possible for RHDH OIDC |
| Mesh mode | Default discovery target: **OSSM 3 ambient** unless OSSM 2 already entrenched |
| CNI | **Do not workshop CNI** on standard OCP; assume OVN-K unless acme states otherwise |
| Monitoring | Cluster monitoring + **user workload monitoring** for mesh ServiceMonitors |
| RBAC | Separate **cluster-admin** (platform) from project admin (app teams) |

---

# Appendix 2 — Red flags (pause and probe)

| Signal | Risk | Probe |
|---|---|---|
| No RHDH exec sponsor | Low adoption | How will usage be mandated or incentivised? |
| SQLite / “DB later” for HA SLA | Data loss / no HA | Confirm SLA again |
| RHDH scaffolder effectively cluster-admin | Privilege escalation | Minimum permissions for templates? |
| Plugin tokens with admin scope | Credential blast radius | Least-privilege per integration? |
| Shared `default` SA in all pods | AuthZ meaningless | Dedicated SA per service? |
| Allow-all between namespaces in Prod | Lateral movement | Acceptable blast radius? |
| Self-signed CA + “InfoSec must approve” | Rework | Corporate CA requirement? |
| Mesh installed, nobody owns Day-2 | Shelfware / outage | Who is paged for mesh failure? |
| All L7 Waypoints for 100+ namespaces | Cost / complexity | Which namespaces truly need L7? |
| No Splunk owner for mesh DENY events | Blind SIEM | Who alerts on AuthZ deny spikes? |

---

# Appendix 3 — Decision log template

| ID | Topic (RHDH / Mesh) | Decision | Date | Owner | Status |
|---|---|---|---|---|---|
| D-001 | | | | | Proposed / Confirmed / Deferred |

---

# Appendix 4 — Open question log template

| ID | Question | Blocking design? | Owner | Due | Resolution |
|---|---|---|---|---|---|
| Q-001 | | Y/N | | | |

---

# Appendix 5 — Topic index (quick jump)

**RHDH:** A1 Landscape · A2 SCM/CI · A3 Plugins · A4 HA · A5 Architecture · A6 Golden Paths · A7 IAM/RBAC · A8 Security governance · A9 Success  

**Service Mesh:** B1 Current state · B2 Enrolment/scale · B3 Trust/mTLS/identity · B4 PKI/ingress/egress · B5 AuthZ/threats · B6 Traffic/Prod/compliance · B7 Obs/Day-2/risks  

---

*OpenShift Platform Discovery Questionnaire · Reusable facilitator pack · Excludes ACS unless scheduled separately*
