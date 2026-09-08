# Platform Discovery Workshop — Miro Board Content

> **How to use this file in Miro:**
> 1. Create a new Miro board.
> 2. Create one **Frame** per section below (use the Frame tool, label it with the section title).
> 3. Inside each frame, create a **Document** widget and paste the section content.
> 4. Add a **Table** widget per section using the "Answer Capture Table" template at the bottom.
> 5. Optionally create a **Mindmap** from the question headings to show the branching structure.
>
> **Board layout (left → right):**
> `[0. Workshop Intro]` → `[1. Environment]` → `[2. Developer Hub]` → `[3. Service Mesh]` → `[4. GitOps]` → `[5. Security]` → `[Facilitator Guide]`

---

## FRAME 0 — Workshop Intro

# Platform Discovery Session

**Purpose:** Understand the acme's current environment, needs, and constraints so we can design the right platform solution — covering Internal Developer Portal (RHDH), Service Mesh, GitOps delivery, and Security posture.

**Who should be in the room:**
- Platform / Infrastructure leads
- DevOps / CI-CD owners
- Security representative
- Application team representative (dev lead or architect)
- Delivery sponsor / product owner (optional but valuable)

**Ground rules:**
- No wrong answers — we're here to learn, not to judge
- If something isn't decided yet, say so — that's just as useful as a firm answer
- We'll take notes in this board — you can see everything we capture
- The agenda is flexible — we'll spend more time where it matters most

**Agenda (approx. 2 hours):**
1. Environment & Infrastructure — 20 min
2. Internal Developer Portal — 30 min
3. Service Mesh — 20 min
4. GitOps & Delivery — 20 min
5. Security & Compliance — 15 min
6. Wrap-up & next steps — 15 min

**Outcome:** After this session we will produce:
- A gap analysis against the proposed solution
- A prioritised list of design decisions to make
- A revised delivery plan with confirmed scope

---

**Session details:**

| Field | Value |
|---|---|
| Acme | |
| Consultant | |
| Date | |
| Attendees | |

---

## FRAME 1 — Environment & Infrastructure

# Environment & Infrastructure

*Goal: understand the cluster topology, identity, secrets, and monitoring baseline before designing anything on top of it.*

---

### Q1 — OpenShift Version
**What OpenShift version(s) are deployed across the clusters?**
> *e.g. 4.14 on Non-Prod, 4.13 on Prod — note any differences*

**Answer:**

---

### Q2 — Number of Clusters
**How many OpenShift clusters are in scope?**
- [ ] 1 cluster
- [ ] 2–3 clusters → *follow up: what are each cluster's roles?*
- [ ] 4 or more → *follow up: is there a hub/management cluster (ACM)?*

**Cluster roles (if multiple):**

| Cluster | Role / Purpose |
|---|---|
| | |
| | |
| | |

**Hub/fleet management tool (if applicable):**

---

### Q3 — Network Restrictions
**Is the environment air-gapped or restricted from the public internet?**
- [ ] Fully air-gapped → *follow up: private registries and proxy config?*
- [ ] Partially restricted (proxy/allowlist) → *follow up: private registries and proxy config?*
- [ ] No restrictions

**Private registries / proxy URL:**

---

### Q4 — Identity Provider
**What identity provider (IdP) is used for authentication?**
- [ ] Keycloak / Red Hat SSO
- [ ] Microsoft Entra ID (Azure AD) → *follow up: cloud-only or synced with on-prem AD?*
- [ ] Okta
- [ ] LDAP / Active Directory
- [ ] Other (specify protocol: OIDC / SAML)

**Notes:**

---

### Q5 — Secrets Management
**Is a secrets manager deployed?**
- [ ] HashiCorp Vault → *follow up: is External Secrets Operator (ESO) installed?*
- [ ] AWS Secrets Manager
- [ ] Azure Key Vault
- [ ] CyberArk
- [ ] No secrets manager yet
- [ ] Other

**ESO installed?** Yes / No
**Notes:**

---

### Q6 — Observability Stack
**What monitoring and observability tools are in use? (select all)**
- [ ] OpenShift built-in monitoring (Prometheus/Grafana)
- [ ] Datadog
- [ ] Dynatrace
- [ ] Splunk
- [ ] Elastic / EFK stack
- [ ] Nothing centralised yet

**Notes:**

---

## FRAME 2 — Internal Developer Portal (RHDH)

# Internal Developer Portal

*Goal: understand the current IDP landscape, what they need from RHDH, and the HA/architecture/RBAC decisions that will drive the design.*

---

### SECTION A — Current State

#### Q1 — Existing IDP
**Is there an existing Internal Developer Portal in use?**
- [ ] Yes → *which product? What are the pain points?*
- [ ] No → *have any solutions been evaluated?*

**Current IDP / pain points:**

---

#### Q2 — Source Control
**What source control system is used for application code?**
- [ ] Bitbucket Cloud
- [ ] Bitbucket Server / Data Center
- [ ] GitHub.com
- [ ] GitHub Enterprise (self-hosted)
- [ ] GitLab.com / GitLab self-managed
- [ ] Azure DevOps Repos

---

#### Q3 — CI/CD Tools
**What CI/CD tools are used for building and deploying applications? (select all)**
- [ ] Jenkins
- [ ] Tekton / OpenShift Pipelines
- [ ] GitHub Actions
- [ ] Azure DevOps Pipelines
- [ ] GitLab CI
- [ ] Atlassian Bamboo

---

#### Q4 — Current Onboarding Process
**How are new services currently onboarded? Walk me through the process.**
> *From "I need a new microservice" to "it is deployed" — who does what, how long does it take?*

**Answer:**

---

#### Q5 — Key Integrations
**Which integrations are most important to expose in the IDP? (select all)**
- [ ] Kubernetes / OpenShift resource view
- [ ] Jenkins build status
- [ ] SonarQube quality gate
- [ ] Snyk vulnerability scanning
- [ ] Jira issue tracking
- [ ] JFrog Artifactory
- [ ] ArgoCD / GitOps status
- [ ] API management (IBM APIC / Kong / Apigee)
- [ ] TechDocs / documentation

---

#### Q6 — Platform Ownership
**Who would own and maintain the IDP platform after delivery?**
> *Team name, size, and current OpenShift/platform experience level*

**Answer:**

---

### SECTION B — High Availability & Resilience

#### Q7 — SLA Requirement
**What availability SLA is expected for the Developer Hub?**
> *This drives replicas, DB choice, and whether a DR cluster is needed*

- [ ] Best effort — planned downtime acceptable (dev tool only)
- [ ] 99.5% — minimal HA, short outages tolerable
- [ ] 99.9% (~8.7 hours/year) — standard production HA → *follow up: DB + replicas*
- [ ] 99.99% (~52 min/year) — mission critical → *follow up: DB + replicas + DR*

---

#### Q8 — Database Choice
**What database should back RHDH?**
> *SQLite is dev-only — not HA. RHDH requires PostgreSQL 14+ for HA.*

- [ ] Use an existing PostgreSQL instance → *follow up: version, host, who manages it?*
- [ ] Provision a managed PostgreSQL (RDS / Azure Database / Cloud SQL) → *follow up: which provider/region?*
- [ ] Deploy CloudNativePG operator on OpenShift (recommended) → *follow up: already installed?*
- [ ] SQLite / local DB is fine (non-HA, dev/demo only)

**PostgreSQL details:**

---

#### Q9 — Replica Count
**How many RHDH replica pods are expected?**
> *Each replica is ~1 vCPU / 1Gi minimum*

- [ ] 1 replica — dev/demo (no HA)
- [ ] 2 replicas — basic HA
- [ ] 3+ replicas — full HA with rolling upgrades → *follow up: node sizing + quota?*
- [ ] Auto-scale (HPA) based on load → *follow up: min/max bounds and scaling metric?*

**Node sizing / HPA config:**

---

#### Q10 — Disaster Recovery
**Is a DR instance of RHDH on a second cluster required?**
> *DR adds significant complexity — separate DB replication, ArgoCD multi-cluster, DNS failover*

- [ ] Yes — RTO/RPO requirements exist → *follow up: RTO/RPO targets and DR cluster?*
- [ ] No — single cluster is sufficient

**RTO / RPO targets:**

---

### SECTION C — Architecture & Storage

#### Q11 — Exposure
**How should the Developer Hub be exposed to users?**
- [ ] Internal only — accessible within the corporate network / VPN
- [ ] External — accessible from the public internet (with auth) → *follow up: domain + TLS cert management?*
- [ ] Both — internal for developers, external for partners/contractors

**Domain / TLS approach:**

---

#### Q12 — TechDocs Storage
**Where should TechDocs (documentation) be stored and rendered from?**
> *Local = docs built in the RHDH pod (simple but slow). Object storage = pre-built, fast, scales well.*

- [ ] Local (built inside RHDH pod) — simple, no extra infra
- [ ] AWS S3 or compatible object store → *follow up: bucket name and credentials owner?*
- [ ] Azure Blob Storage → *follow up: storage account and credentials owner?*
- [ ] OpenShift Data Foundation (ODF / NooBaa on-cluster S3) → *follow up: ODF already deployed?*
- [ ] Not decided yet

---

#### Q13 — Catalog Population
**How should the software catalog be populated with existing services? (select all)**
- [ ] Manual — teams add catalog-info.yaml to their repos
- [ ] Bitbucket/GitHub/GitLab auto-discovery (catalog backend module)
- [ ] Bulk import from existing CMDB or service registry
- [ ] Golden path templates self-register on creation
- [ ] Push via RHDH REST API from external tools

---

### SECTION D — Access Control (RBAC)

#### Q14 — User Personas
**What user personas need access to the Developer Hub? (select all)**
> *Each persona gets a different RBAC role — drives the permission model*

- [ ] Developer — view catalog, use templates, read CI/CD
- [ ] Tech Lead — can edit catalog entries, manage their team's components
- [ ] Platform / IDP team — full admin, can create templates
- [ ] Security team — read-only view across all components
- [ ] Engineering manager — dashboards and metrics only
- [ ] External contractors / partners — scoped read-only

---

#### Q15 — Ownership Model
**How should ownership of catalog items be managed?**
- [ ] Team-owned — each team manages their own components, no approval needed
- [ ] Platform-curated — IDP team approves all catalog changes
- [ ] Hybrid — teams own components, platform owns templates and systems

---

### SECTION E — Expectations & Success

#### Q16 — Definition of Success
**What does success look like for the Developer Hub in 6 months?**
> *Ask them to be specific — number of services in catalog, time to onboard a new service, adoption rate*

**Answer:**

---

#### Q17 — Adoption Driver
**What would make a developer choose the IDP over their current workflow?**
> *This reveals the real adoption blocker — usually: it must be faster than the old way, or mandated from above*

**Answer:**

---

#### Q18 — Executive Sponsor
**Is there an executive sponsor driving IDP adoption?**
> *Without exec sponsorship, IDP adoption is usually opt-in and slow*

- [ ] Yes — named sponsor with budget authority → *follow up: who and what is their stated goal?*
- [ ] No — developer-led initiative → *follow up: how will adoption be driven? Is a mandate planned?*

**Sponsor name / goal / mandate plan:**

---

## FRAME 3 — Service Mesh

# Service Mesh

*Goal: understand the current mesh state, network compatibility, security posture, traffic and L7 needs, observability, developer model, and Day-2 ownership — everything needed to design the OSSM3 ambient mesh rollout.*

---

### SECTION A — Current State

#### Q1 — Existing Mesh
**Is any service mesh currently deployed on these clusters?**
- [ ] Yes → *which product? What's working / what are the pain points? Which features are used?*
- [ ] No → *what is the primary driver for adopting a service mesh?*

**Current mesh / version:**

**Pain points:**

**Features actively used:**
- [ ] mTLS (mutual TLS)
- [ ] Traffic management (retries, timeouts, canary)
- [ ] AuthorizationPolicies
- [ ] Kiali / observability
- [ ] Ingress gateway
- [ ] Installed but not actively used

**Primary adoption driver (if new):**
- [ ] Zero-trust / mTLS between services
- [ ] Compliance requirement (PCI, SOC2, etc.)
- [ ] Advanced traffic management (canary, retry)
- [ ] Service-level observability and tracing
- [ ] Platform standardisation

---

### SECTION B — Network & CNI Compatibility

#### Q2 — CNI Plugin
**What CNI plugin is installed on the cluster(s)?**
> *Ambient mesh (OSSM3) requires OVN-Kubernetes or Calico. Cilium needs special eBPF interop config. This is a hard compatibility check — the wrong answer here changes the architecture.*

- [ ] OVN-Kubernetes (OpenShift default) — fully supported ✓
- [ ] Calico — supported ✓
- [ ] Cilium — needs eBPF masquerade config → *follow up: Cilium version + eBPF masquerade enabled?*
- [ ] Other → *follow up: which CNI and any existing NetworkPolicies?*
- [ ] Not sure

**CNI version / notes:**

---

### SECTION C — Security & mTLS

#### Q3 — mTLS Posture
**What is the security posture requirement for service-to-service traffic?**
- [ ] All traffic must be mTLS (strict mode — OSSM3 default with ambient)
- [ ] East-west mTLS only (ingress traffic is handled separately)
- [ ] Specific namespaces or services only
- [ ] Not defined yet

---

#### Q4 — Certificate / PKI Strategy
**What certificate / PKI strategy should the mesh use for mTLS?**
> *Istio generates short-lived SPIFFE SVIDs (certs) per workload. By default it uses a self-signed CA — enterprises often require integration with their existing PKI for audit trails and cert inventory.*

- [ ] Istio self-signed CA — simple, automatic, no external dependency
- [ ] HashiCorp Vault PKI — Vault issues intermediate CA certs for Istio → *follow up: Vault PKI engine configured + cert-manager with istio-csr installed?*
- [ ] cert-manager with enterprise CA (Active Directory CS / EJBCA / Venafi) → *follow up: which CA + cert rotation period?*
- [ ] Bring our own root CA certificate (manually managed) → *follow up: which CA + cert rotation period?*
- [ ] Not decided yet

**CA / cert rotation requirement:**

---

### SECTION D — Ingress, Egress & L7

#### Q5 — Ingress
**How does external acme traffic currently enter the cluster?**
> *This determines whether we deploy an Istio Ingress Gateway or keep existing Routes — they can coexist but must be explicitly designed.*

- [ ] OpenShift Routes (HAProxy) — no mesh ingress today
- [ ] NGINX Ingress Controller
- [ ] F5 BIG-IP / external load balancer
- [ ] Istio Ingress Gateway (already deployed)
- [ ] Kubernetes Gateway API
- [ ] Mix — some Routes, some gateway

**Notes:**

---

#### Q6 — Egress Control
**Is egress control required — governing traffic that leaves the cluster to external APIs?**
> *e.g. a payment service calling a third-party API — do you need to audit, restrict, or route that traffic through an egress gateway?*

- [ ] Yes — all egress must go through a controlled gateway → *follow up: which services/namespaces + which external endpoints?*
- [ ] Selective — only certain services (e.g. PCI-scoped) → *follow up: which services + endpoints?*
- [ ] No — unrestricted egress is fine
- [ ] Not decided yet

**Services / endpoints requiring egress control:**

---

#### Q7 — Layer-7 Policies (Waypoint Proxy)
**Are Layer-7 policies required — decisions based on HTTP headers, JWT tokens, or request paths?**
> *L4 mTLS (encryption + identity) is provided automatically by ztunnel in ambient mode at zero cost. L7 policies require a Waypoint proxy per namespace — adds a pod per namespace but is opt-in and only where needed.*

- [ ] JWT / OIDC token validation at the mesh layer → *Waypoint required*
- [ ] Header-based routing (e.g. canary by user-agent or group header) → *Waypoint required*
- [ ] URL path-based AuthorizationPolicy (e.g. /admin only for platform-team SA) → *Waypoint required*
- [ ] Per-route rate limiting → *Waypoint required*
- [ ] No — L4 mTLS and basic deny-all / namespace-allow policies are enough

**Which namespaces need Waypoint proxies and what policies apply:**

---

### SECTION E — Traffic Management

#### Q8 — Traffic Patterns
**Which traffic management patterns are required? (select all)**
- [ ] Canary deployments (split traffic by weight)
- [ ] Blue/green deployments
- [ ] Circuit breaker / outlier detection (eject unhealthy pods)
- [ ] Automatic retries (with backoff)
- [ ] Rate limiting
- [ ] Traffic mirroring (shadow traffic to a new version)
- [ ] None required yet

**Notes (e.g. specific tool preference — Argo Rollouts, Flagger):**

---

### SECTION F — Observability

#### Q9 — Observability Capabilities
**What observability capabilities are expected from the mesh? (select all)**
> *This determines which components are deployed alongside the mesh control plane.*

- [ ] Kiali service graph — visual topology, health, and traffic dashboard
- [ ] Distributed tracing (traces across services) → *follow up: which tracing backend?*
  - [ ] Jaeger (OpenShift Distributed Tracing Platform)
  - [ ] Grafana Tempo
  - [ ] Zipkin
  - [ ] Datadog APM
  - [ ] Dynatrace
  - [ ] No backend yet — needs to be provisioned
- [ ] Prometheus metrics + Grafana dashboards for mesh traffic
- [ ] Access log export to existing log aggregator (Splunk / Elastic / Datadog)
- [ ] No specific mesh observability requirements

**Tracing backend / log aggregator details:**

---

### SECTION G — Developer Experience & Namespace Model

#### Q10 — Developer Awareness
**How much should application developers need to know about the mesh?**
> *Ambient mode is designed to be transparent — apps do not change. But some teams want to own their traffic policies. This drives the golden path template design and Kyverno auto-enrollment policies.*

- [ ] Fully transparent — developers deploy apps, mesh enrols them automatically via namespace label
- [ ] Developers are aware and define their own VirtualServices / DestinationRules
- [ ] Teams fully own their mesh config — platform provides the control plane only

---

#### Q11 — Namespace / Team Isolation Model
**How are application namespaces structured?**
> *This drives the mesh enrollment and AuthorizationPolicy design. Shared namespaces require more granular workload-level policies.*

- [ ] One namespace per team — team owns everything inside
- [ ] One namespace per service / microservice
- [ ] One namespace per environment (dev/test/prod in the same cluster)
- [ ] Shared namespaces — multiple teams share a namespace
- [ ] Mixed — different teams have different structures

**Notes:**

---

### SECTION H — Scale & Multi-Cluster

#### Q12 — Scale
**Roughly how many services/namespaces would be enrolled in the mesh initially?**
- [ ] Fewer than 10 services
- [ ] 10–50 services
- [ ] 50–100 services
- [ ] More than 100 services

**Target scale at full rollout:**

---

#### Q13 — Multi-Cluster Federation
**Do services need to communicate across clusters within the mesh?**
> *e.g. a service in Non-Prod calls a shared API in the hub cluster — requires east-west gateways and federated service discovery*

- [ ] Yes — cross-cluster service calls in scope → *follow up: which clusters federated + which services span boundaries?*
- [ ] No — each cluster is an independent mesh
- [ ] Not now, but planned in future

**Cross-cluster services:**

---

### SECTION I — Compliance & Day-2

#### Q14 — Compliance Requirements
**Are there compliance or audit requirements that the mesh needs to satisfy?**
> *e.g. PCI-DSS zone isolation (cardholder data namespace must not communicate with general workloads), SOC2 encryption in transit, NZISM controls*

**Answer:**

---

#### Q15 — Day-2 Operations Ownership
**Who will own Service Mesh Day-2 operations — upgrades, incidents, and policy changes?**
> *The platform/infra team typically owns the control plane. App teams own their namespace policies. Is there an on-call rotation that covers mesh incidents?*

**Answer:**

---

#### Q16 — Upgrade Strategy
**How should mesh operator upgrades be handled?**
> *Sail Operator (OSSM3) upgrades follow OCP release cadence. Pinning means the team controls timing — relevant if there's a strict change board process.*

- [ ] Automatic — follow OCP cluster upgrade cadence
- [ ] Manual — platform team applies upgrades in a scheduled change window
- [ ] Pinned version — upgrade only when explicitly approved by security/change board

---

## FRAME 4 — GitOps & Delivery

# GitOps & Delivery

*Goal: understand the current delivery pipeline, repo structure, and environment model so we can design the right GitOps approach.*

---

### Q1 — GitOps Today
**Is GitOps currently used for managing deployments?**
- [ ] Yes → *which tool? Which environments does it manage?*
- [ ] No → *how are deployments done today?*

**GitOps tool:**
- [ ] ArgoCD / OpenShift GitOps
- [ ] Flux
- [ ] Jenkins X
- [ ] Other

**Environments managed:**
- [ ] Development
- [ ] Non-Prod / UAT
- [ ] Production
- [ ] All environments

**Current deployment approach (if no GitOps):**

---

### Q2 — Repo Structure
**How is the Git repository structure organised for deployment manifests?**
- [ ] Monorepo (all manifests in one repo)
- [ ] Multi-repo (one repo per service/team)
- [ ] Mixed — some mono, some multi
- [ ] No structured approach yet

---

### Q3 — Environments
**How many deployment environments exist and what are their names?**
> *e.g. E-Dev, Non-Prod, Prod — include any DR or staging environments*

**Answer:**

| Environment | Cluster | Purpose | GitOps managed? |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

---

### Q4 — Secrets in Pipelines
**How is secrets management handled in the delivery pipeline today?**
> *e.g. hardcoded in pipelines, Vault, Kubernetes Secrets, environment variables*

**Answer:**

---

### Q5 — Deployment Frequency
**What is the current production deployment frequency?**
- [ ] Multiple times per day
- [ ] Daily
- [ ] Weekly
- [ ] Monthly
- [ ] Ad hoc / no regular cadence

**Target frequency after platform delivery:**

---

## FRAME 5 — Security & Compliance

# Security & Compliance

*Goal: identify the compliance requirements, scanning posture, and policy enforcement model so Kyverno policies and release gates are correctly designed.*

---

### Q1 — Compliance Frameworks
**Which compliance frameworks or regulations apply? (select all)**
- [ ] PCI-DSS
- [ ] SOC 2
- [ ] ISO 27001
- [ ] APRA CPS 234 (financial services)
- [ ] NZISM / NZ government requirements
- [ ] Internal security policy only
- [ ] No formal compliance framework yet

---

### Q2 — Container Image Scanning
**Is container image scanning currently in place in the CI/CD pipeline?**
- [ ] Yes → *which tools?*
  - [ ] Snyk
  - [ ] Aqua Security
  - [ ] Palo Alto Prisma / Twistlock
  - [ ] Red Hat ACS (Advanced Cluster Security)
  - [ ] Clair / Quay built-in
  - [ ] Trivy
  - [ ] Other
- [ ] No

---

### Q3 — Image Signing
**Is there a requirement to sign container images (software supply chain)?**
- [ ] Yes → *is any signing tool already in use? (Cosign, Notary, internal tooling)*
- [ ] No — but open to it
- [ ] No requirement

**Current signing tool:**

---

### Q4 — Admission Control Policies
**Are admission control policies enforced on the cluster today? (OPA/Gatekeeper, Kyverno, etc.)**
- [ ] Yes → *which policy engine and what policies are enforced?*
- [ ] No

**Policy engine / current policies:**

---

### Q5 — Specific Security Constraints
**Are there any specific security requirements or constraints we should know about before designing the solution?**
> *e.g. no internet access for build agents, FIPS compliance, specific image registries only*

**Answer:**

---

## FRAME 6 — Facilitator Guide

# Facilitator Cheat Sheet

*Keep this out of acme view during the session. Reference it when answers trigger a branch.*

---

## Branching Logic Quick Reference

### Environment
| Answer | Follow-up |
|---|---|
| 2–3 clusters | Ask cluster roles (E-Dev / Non-Prod / Prod) |
| 4+ clusters | Cluster roles + hub/fleet management tool |
| Hub = yes | Which tool (ACM / Rancher / ArgoCD hub) |
| Air-gapped / partial | Private registries and proxy URL |
| IdP = Entra ID | Cloud-only or synced with on-prem AD? |
| Secrets = Vault | Is ESO already installed? |

### Developer Hub
| Answer | Follow-up |
|---|---|
| IDP exists | Which product + pain points |
| No IDP | Prior evaluations? |
| SLA 99.9% | DB choice + replica count |
| SLA 99.99% | DB + replicas + DR |
| DB = existing PG | Version, host, DBA team contact |
| DB = managed PG | Cloud provider + region |
| DB = CloudNativePG | Already installed on cluster? |
| Replicas = 3+ or HPA | Node sizing + quota; HPA min/max + metric |
| DR = yes | RTO / RPO targets + DR cluster provisioned? |
| External exposure | Domain + TLS cert management |
| TechDocs = S3/Azure | Bucket/storage account + credentials owner |
| TechDocs = ODF | ODF/NooBaa already deployed? |
| Exec sponsor = yes | Name + stated KPI goal |
| Exec sponsor = no | How will adoption be driven? Is a mandate planned? (→ flag as risk) |

### Service Mesh
| Answer | Follow-up |
|---|---|
| Mesh exists | Which product + pain points + active features |
| Mesh = new | Primary adoption driver (zero-trust / compliance / traffic / observability) |
| CNI = Cilium | Cilium version + is eBPF masquerade enabled? (risk: ambient mode conflict) |
| CNI = other | Which CNI + any existing NetworkPolicies? |
| Egress = yes / selective | Which services/namespaces + which external endpoints do they call? |
| L7 = any option selected | Which namespaces need Waypoint proxies + what policies apply? |
| Tracing = yes | Which tracing backend (Jaeger / Tempo / Zipkin / Datadog / Dynatrace)? |
| PKI = Vault | Vault PKI engine configured? cert-manager + istio-csr installed? |
| PKI = cert-manager / own CA | Which CA + cert rotation period? InfoSec team owns this. |
| Multi-cluster = yes | Which clusters federated + which services span boundaries? |
| Namespace = shared | Flag: AuthorizationPolicies must be workload-level, not namespace-level |
| Upgrade = pinned | Get the change board cadence — affects operator install timeline |

### GitOps
| Answer | Follow-up |
|---|---|
| GitOps = yes | Which tool + which environments |
| GitOps = no | Current deployment approach |

### Security
| Answer | Follow-up |
|---|---|
| Scanning = yes | Which tools |
| Signing = yes | Existing tool (Cosign / Notary) |
| Admission control = yes | Which engine + current policies |

---

## Red Flags to Watch For

| Signal | Risk | Probe with |
|---|---|---|
| No exec sponsor for IDP | Voluntary adoption stalls at 30-40% | "How will you drive adoption?" |
| SQLite / no DB decision | RHDH data lost on pod restart | "What's the SLA expectation?" |
| No secrets manager | Hardcoded creds in pipelines | "How are service account tokens managed today?" |
| "We'll handle security later" | Policy debt → compliance failure | "Is PCI or APRA in scope?" |
| Air-gapped + no private registry | Operator install will fail | "How do you install operators today?" |
| 100+ services in mesh | Resource sizing and Day-2 ops complexity | "Who will manage mesh Day-2 operations?" |
| No GitOps + weekly deployments | Release velocity risk | "What's the target cadence after platform delivery?" |
| CNI = Cilium + eBPF masquerade on | Ambient mode ztunnel will conflict with Cilium | "Has Cilium been tested with OSSM3 ambient mode?" |
| Shared namespaces + strict mTLS | AuthZ policy gaps — workload-level SPIFFE IDs needed instead of namespace | "Can you move to a namespace-per-team model?" |
| L7 policies + 100+ namespaces | A Waypoint per namespace = 100+ extra pods — resource cost is significant | "Which namespaces actually need L7 — can we scope this down?" |
| No PKI/CA strategy | InfoSec may veto self-signed CA later — retrofit is painful | "Does your security policy mandate cert chain traceability?" |
| No observability owner | Kiali/Jaeger deployed but nobody monitoring — shelfware risk | "Who will look at this dashboard every day?" |
| Multi-cluster + no east-west gateway | Services will fail across clusters silently | "Is cross-cluster traffic already happening via NodePort/LB?" |
| "The team will figure it out" for Day-2 | No defined owner = nobody patches the mesh | "Can you name the person who will get paged for a mesh outage?" |

---

## Wrap-up Checklist

After the session, ensure these are captured before closing:

- [ ] All answers recorded in the topic frames above
- [ ] Red flags noted and assigned an owner
- [ ] Decisions outstanding — listed below
- [ ] Next session date agreed
- [ ] Stakeholders who need to be involved in decisions identified

**Outstanding decisions:**

| Decision | Owner | Target date |
|---|---|---|
| | | |
| | | |

---

## Answer Capture Table Template

*Create one of these per topic frame. Use it as a running record during the session.*

| # | Question summary | Answer | Follow-up? | Notes |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |

---

## FRAME 7 — Service Mesh Security Design

# Service Mesh — Security Design Review

*Goal: document trust boundaries, mTLS architecture, AuthZ policy design, lateral movement risks, egress controls, and Splunk integration — producing the security section of the design artefact.*

---

### Q1 — Trust Domain Design
**How should the Istio trust domain be designed?**
> *The trust domain is embedded in every SPIFFE identity (`spiffe://<trust-domain>/ns/<ns>/sa/<sa>`). A shared trust domain means Non-Prod and Prod workloads share a root of trust — typically unacceptable in financial services.*

- [ ] Single trust domain across all clusters → *flag: has InfoSec signed off on cross-environment identity sharing?*
- [ ] One trust domain per environment (Non-Prod / Prod) — **recommended for regulated environments**
- [ ] One trust domain per cluster — maximum isolation
- [ ] Not decided yet

**Security assumption to document:**

---

### Q2 — Tenancy Model
**What tenancy model is required — how strictly must teams and namespaces be isolated?**
> *Hard tenancy = deny-all by default, cryptographic isolation, no implicit trust. Financial services typically requires hard tenancy.*

- [ ] Hard tenancy — deny-all, every cross-namespace call requires an explicit AuthorizationPolicy
- [ ] Soft tenancy — namespace separation, some shared services implicitly allowed
- [ ] Hybrid — hard tenancy for production/regulated namespaces, soft for dev/test
- [ ] Not yet defined — **needs InfoSec input before design can be finalised**

---

### Q3 — Service Identity Requirements
**What service identity requirements must the mesh satisfy? (select all)**
> *SPIFFE SVIDs are issued per workload ServiceAccount: `spiffe://<trust-domain>/ns/<namespace>/sa/<serviceaccount>`*

- [ ] Standard SPIFFE/SVID per ServiceAccount — default Istio behaviour
- [ ] Dedicated ServiceAccount per service (no shared SAs) — **required for meaningful AuthZ policies**
- [ ] Cert issuance must be visible in existing PKI inventory / cert management tool
- [ ] Short cert lifetime required (e.g. 1-hour SVIDs) for least-privilege
- [ ] Cert issuance and rotation must be logged for audit

**Constraint to document:**

---

### Q4 — AuthorizationPolicy Design Philosophy
**Who defines AuthorizationPolicies and how are they governed?**
- [ ] Platform team owns all AuthorizationPolicies — centralised, auditable
- [ ] App teams own policies for their namespaces — platform sets baseline deny-all only
- [ ] Policy-as-code — Kyverno generates base policies, teams can extend (**recommended**)
- [ ] Not yet defined

---

### Q5 — Default Traffic Posture (Deny-All)
**Should the mesh default to deny-all between namespaces?**
> *Deny-all is the zero-trust baseline. Every service-to-service call must be explicitly authorised. Risk of not doing this: a compromised service can call any other service freely.*

- [ ] Yes — deny-all by default (**zero-trust posture — recommended**)
- [ ] No — allow by default within the mesh
- [ ] Deny-all only for production/regulated namespaces

---

### Q6 — Lateral Movement Risk
**If one service is compromised, what can it reach — and is that acceptable?**
> *Walk through this scenario with the acme: "If the frontend service is compromised, what services can an attacker call?" The answer drives AuthZ policy granularity: namespace-level, service-level, or method-level (GET /api only)?*

**Scenario walkthrough notes:**

**Acceptable lateral movement boundary:**

---

### Q7 — Service Impersonation Mitigations
**What controls prevent a rogue pod from claiming another service's identity? (select all)**
> *In Istio, identity comes from the ServiceAccount a pod runs as. If a developer can create a pod with another team's SA, they can impersonate that service.*

- [ ] Strict Kubernetes RBAC — developers cannot create pods in other namespaces
- [ ] Kyverno policy — deny pod creation with another team's ServiceAccount
- [ ] Pod Security Admission — enforce restricted profile
- [ ] ACS runtime policy — alert on unexpected service account usage
- [ ] No specific mitigations beyond default RBAC

---

### Q8 — Egress Data Exfiltration Controls
**What controls beyond an egress gateway are required to prevent data exfiltration? (select all)**
> *An egress gateway controls which endpoints services can call — it doesn't inspect content.*

- [ ] Istio Egress Gateway + ServiceEntry allowlist (controls which endpoints)
- [ ] DNS-level filtering — only approved FQDNs resolve from workload pods
- [ ] TLS inspection for egress traffic (break-and-inspect proxy)
- [ ] Data Loss Prevention (DLP) at network layer
- [ ] ACS network baseline — alert on unexpected external connections
- [ ] Egress gateway is sufficient

---

### Q9 — Security Events to Splunk
**What mesh security events must be forwarded to Splunk? (select all)**
> *Istio emits access logs in JSON — a log shipper (Vector / Fluent Bit) forwards to Splunk HEC. ACS can send policy violation events separately.*

- [ ] All service-to-service access logs (source, destination, response code, latency)
- [ ] AuthorizationPolicy DENY events — attempted unauthorised access
- [ ] mTLS handshake failures — potential impersonation attempt
- [ ] Audit log of AuthorizationPolicy + PeerAuthentication changes (who changed what)
- [ ] Egress gateway blocked requests
- [ ] ACS runtime policy violations on mesh-enrolled workloads

**Splunk index / HEC endpoint:**

---

### Q10 — Policy Change Audit Requirements
**What are the audit requirements for mesh policy changes?**
> *GitOps provides an audit trail via Git history. Some orgs also need real-time alerts when a policy change is applied. Who approves an emergency policy change outside the GitOps workflow?*

**Answer:**

**Emergency change procedure:**

---

### Q11 — Security Assumptions & Constraints
**What key security assumptions and constraints must be documented in the design artefact?**
> *e.g. "All workloads run with a dedicated ServiceAccount", "OVN-Kubernetes is the CNI", "No TLS inspection is permitted on internal east-west traffic"*

| Assumption / Constraint | Type | Owner |
|---|---|---|
| | | |
| | | |

---

### Risk Register (Mesh)

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Lateral movement via compromised service | High | High | Deny-all AuthZ + namespace isolation |
| Service impersonation via shared SA | Medium | High | Dedicated SA per service + Kyverno |
| Data exfiltration via egress | Medium | High | Egress gateway + ACS network baseline |
| Policy drift (AuthZ rules not in Git) | High | Medium | GitOps-only policy management |
| mTLS blind spot (workload not enrolled) | Medium | High | Kyverno auto-enrolment + audit policy |

---

## FRAME 8 — Developer Hub Security Design

# Developer Hub — Security Design Review

*Goal: document IAM requirements, plugin governance, supply chain security controls, secure-by-default golden path requirements, and RHDH-specific security risks.*

---

### Q1 — Authentication Requirements
**What authentication requirements apply to the Developer Hub? (select all)**
> *RHDH uses OIDC — but MFA, session timeout, and device trust requirements must come from the organisation's identity policy.*

- [ ] MFA required for all RHDH users
- [ ] MFA required for admin / platform-team users only
- [ ] Session timeout policy (e.g. 8-hour idle timeout)
- [ ] Device trust — managed-device-only access
- [ ] IP allowlisting — corporate network / VPN only
- [ ] Standard OIDC with no additional requirements

---

### Q2 — Admin Access & Break-Glass
**Who has RHDH admin access and what is the break-glass procedure?**
> *Admin access = ability to change RBAC policies, install plugins, modify the catalog. If the IdP is down, can someone still access RHDH?*

**Named admins / role:**

**Break-glass account location:**

**IdP-down procedure:**

---

### Q3 — Plugin Governance
**Who can approve and install new plugins into the Developer Hub?**
> *Each plugin has access to the backend API, catalog, and potentially secrets. An unreviewed plugin could exfiltrate service account tokens.*

- [ ] Platform team only — change board process + security review before installation
- [ ] Security team must approve — plugin permissions reviewed for least-privilege
- [ ] Informal — platform team decides without a formal gate
- [ ] Not yet defined

**Review checklist requirements:**

---

### Q4 — Secrets Management for Plugins
**How are plugin API tokens and integration secrets managed and rotated?**
> *RHDH plugins need tokens for Jenkins, Jira, Snyk, Artifactory, etc. If the RHDH pod is compromised, an attacker gets all of them.*

- [ ] Vault + External Secrets Operator — secrets never land in Git, auto-rotated (**recommended**)
- [ ] Kubernetes Secrets (not encrypted at rest by default)
- [ ] Sealed Secrets / SOPS — encrypted in Git
- [ ] Manually managed — tokens set by admin, no rotation policy

**Rotation schedule:**

---

### Q5 — Software Supply Chain Governance
**How is the software supply chain governed for catalog and template changes? (select all)**
> *A malicious catalog entry can mislead developers. A bad template creates bad scaffolded code at scale.*

- [ ] All catalog-info.yaml changes require a peer-reviewed PR — no direct push to main
- [ ] Template changes require platform team + security team sign-off
- [ ] Signed commits required (GPG / Sigstore)
- [ ] Branch protection enforced — no force-push, required status checks
- [ ] No formal governance yet

---

### Q6 — Container Image Governance
**What image governance is required for images deployed via golden path templates? (select all)**
- [ ] Only approved registries (Quay.io, Artifactory) — enforced by Kyverno
- [ ] Approved base image list — templates only offer pre-approved base images
- [ ] Images must be Cosign-signed before deployment
- [ ] Vulnerability scan must pass (no Critical/High CVEs) before deploy
- [ ] ACS admission controller blocks policy-violating images
- [ ] No formal image governance yet

---

### Q7 — Vulnerability Management Process
**From CVE detected to remediated in production — walk me through the process.**
> *Who gets notified? Who owns the fix? What is the SLA by severity? How are exceptions handled? How is compliance tracked?*

**Current process:**

**SLA by severity:**
- Critical: ___
- High: ___
- Medium: ___

**Exception / risk acceptance process:**

---

### Q8 — Secure-by-Default Golden Path Requirements
**What security controls must be baked into golden path templates by default? (select all)**
> *Secure-by-default = a developer using the template gets these without thinking about them.*

- [ ] Containers run as non-root (runAsNonRoot: true)
- [ ] Read-only root filesystem (readOnlyRootFilesystem: true)
- [ ] No privileged containers (allowPrivilegeEscalation: false)
- [ ] Resource limits required — no limit = no deploy (Kyverno enforced)
- [ ] Default-deny NetworkPolicy applied to scaffolded namespace
- [ ] Namespace automatically enrolled in service mesh (ambient label)
- [ ] Vulnerability scan stage in Jenkinsfile by default
- [ ] SBOM (Software Bill of Materials) generated in the build pipeline

---

### Q9 — Privilege Escalation Risk
**What can a golden path template actually create on the cluster — and is that permission scope appropriate?**
> *The RHDH scaffolder runs with its ServiceAccount permissions. If that SA can create ClusterRoleBindings, a malicious template author could escalate privileges.*

**Scaffolder SA current permissions:**

**Minimum required permissions:**

**Gap / remediation:**

---

### Q10 — Token Scoping & Credential Exposure
**How are the service account tokens RHDH uses to talk to other services scoped? (select all)**
- [ ] Kubernetes SA token scoped to read-only on specific resources only
- [ ] Token bound to RHDH pod identity (short-lived bound service account token)
- [ ] External integration tokens rotated on a defined schedule (e.g. 90 days)
- [ ] Vault dynamic secrets — tokens generated per-session with TTL
- [ ] All token usage logged and alertable

---

### Q11 — Template Misuse Risk
**What guardrails prevent a malicious or misconfigured template from being published?**
- [ ] Only platform team can merge template changes — requires platform + security approval
- [ ] Template PRs require peer review (no mandatory security sign-off)
- [ ] Template changes tested in sandbox before production promotion
- [ ] No specific gate — standard PR process applies

---

### Q12 — Integration Permission Scope Review
**What permissions do RHDH integrations have — Jenkins, Jira, Bitbucket, Snyk, Artifactory?**

| Integration | Current Permission Scope | Minimum Required | Gap? |
|---|---|---|---|
| Jenkins | | | |
| Jira | | | |
| Bitbucket | | | |
| Snyk | | | |
| Artifactory | | | |

---

### Risk Register (Developer Hub)

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Plugin exfiltrates secrets via RHDH SA | Medium | High | Plugin governance gate + permission audit |
| Malicious template creates over-privileged resources | Medium | High | Scaffolder SA least-privilege + sandbox testing |
| Compromised integration token (Jenkins/Jira) | Medium | High | Vault dynamic secrets + rotation |
| Catalog poisoning (fake component registered) | Low | Medium | PR review + signed commits |
| Developer escalates via template to ClusterAdmin | Low | Critical | RBAC audit + Kyverno deny |

---

## FRAME 9 — ACS Advanced Cluster Security Review

# Red Hat Advanced Cluster Security — Current State & Future Architecture

*Goal: assess current ACS deployment, utilisation, policy coverage, integrations, and produce future state architecture with operating model recommendations.*

---

### SECTION A — Current State Assessment

#### Q1 — Deployment Topology
**ACS version and deployment topology?**
> *ACS Central on which cluster? Which clusters have Secured Cluster services (sensor + collector + admission controller)?*

| Component | Location / Version |
|---|---|
| ACS Central | |
| Secured Cluster — E-Dev | |
| Secured Cluster — Non-Prod | |
| Secured Cluster — Prod | |

---

#### Q2 — Cluster & Namespace Coverage
**Which clusters and namespaces are covered by ACS?**
- [ ] All clusters have Secured Cluster services ✓
- [ ] Production only — lower environments not covered ⚠️
- [ ] Partial — some clusters covered, some not
- [ ] Central installed but no Secured Clusters connected

**Uncovered clusters / blind spots:**

---

#### Q3 — Policy Coverage & Enforcement Mode
**Which ACS policy categories are active and at what enforcement level?**
> *Inform = alerts only. Enforce = blocks (admission controller or kill container).*

| Policy Category | Enabled? | Enforcement Mode |
|---|---|---|
| Build: image vulnerability scanning | | Inform / Enforce |
| Deploy: configuration checks (privileged, resources) | | Inform / Enforce |
| Runtime: unexpected process execution | | Inform / Enforce |
| Runtime: unexpected network connections | | Inform / Enforce |
| Runtime: sensitive file access | | Inform / Enforce |

---

#### Q4 — Vulnerability Management Process
**From CVE detected by ACS to remediated in production — walk me through the current process.**
> *Who gets notified? Who triages? What is the SLA? How are exceptions tracked?*

**Current process:**

**Gaps identified:**

---

#### Q5 — Compliance Profiles
**Which compliance profiles are enabled and actively used?**
- [ ] CIS OpenShift Benchmark
- [ ] CIS Kubernetes Benchmark
- [ ] NIST 800-53
- [ ] PCI-DSS
- [ ] APRA CPS 234 / custom financial services profile
- [ ] NZISM
- [ ] No compliance profiles actively used

**Who reviews compliance reports:**

---

### SECTION B — Integration Assessment

#### Q6 — Splunk / SIEM Integration
**Are ACS alerts and events forwarded to Splunk today?**
- [ ] Yes — ACS → Splunk HEC integration is live ✓
- [ ] Partially — some event types forwarded
- [ ] Via syslog to a log aggregator (not Splunk directly)
- [ ] No SIEM integration — ACS console only ⚠️

**Events currently forwarded:**

**Events missing from SIEM:**

---

#### Q7 — Pipeline Integration (Build Gates)
**Is ACS integrated into CI/CD for build-time security gates?**
- [ ] roxctl runs in Jenkins — fails build on policy violation
- [ ] roxctl runs in Tekton / OpenShift Pipelines
- [ ] ACS admission controller blocks violating images at deploy time
- [ ] ACS verifies Cosign signatures at deploy time
- [ ] No pipeline integration — ACS only scans deployed images ⚠️

---

#### Q8 — Developer Hub Integration
**Is ACS vulnerability and policy data surfaced in the Developer Hub?**
- [ ] Yes — ACS data visible in RHDH today
- [ ] Planned — this is a requirement for the new RHDH deployment
- [ ] No — developers must log into ACS console directly
- [ ] Not considered yet

---

#### Q9 — Service Mesh Integration
**Does ACS monitor mesh-enrolled workloads and can it correlate with mesh observability?**
- [ ] Yes — ACS + Kiali network data are correlated
- [ ] Yes — ACS monitors the same workloads but tools are separate
- [ ] ACS network baseline only — no mesh deployed
- [ ] ACS is not monitoring mesh-enrolled namespaces

---

### SECTION C — Operations & Governance

#### Q10 — Operational Ownership
**Who owns and operates ACS Central, and is there an on-call process for violations?**
> *ACS generates many alerts. Without a clear owner and triage process, it becomes shelfware.*

**ACS Central owner:**

**On-call / violation response process:**

**Runbook exists?** Yes / No

---

#### Q11 — Policy Governance
**How are ACS policies managed — who can create, modify, or delete them?**
- [ ] Policy-as-code — ACS policies in Git, applied via GitOps (full audit trail) (**recommended**)
- [ ] UI-managed with a formal change request process
- [ ] UI-managed ad hoc — any ACS admin can change policies ⚠️
- [ ] No defined governance process

---

#### Q12 — NetworkPolicy Generation
**Is ACS used to generate Kubernetes NetworkPolicies from observed traffic?**
- [ ] Yes — ACS generates NetworkPolicies from the baseline
- [ ] No — NetworkPolicies managed separately (Kyverno / manually)
- [ ] Not aware this feature exists

---

### SECTION D — Pain Points & Future Vision

#### Q13 — Current Pain Points
**What is not working well with the current ACS deployment?**
> *Common answers: alert fatigue, no SIEM integration, not connected to pipelines, compliance reports unread, no clear owner, unknown version, only Inform-mode so nothing is blocked.*

**Pain points:**

---

#### Q14 — Future State Vision
**What does success look like for ACS in 12 months?**
> *Probe for measurable outcomes: MTTR for Critical CVEs, % builds blocked, compliance score target, runtime violations trending down.*

**Success metrics:**

| Metric | Current State | 12-Month Target |
|---|---|---|
| MTTR for Critical CVEs | | |
| % CI/CD builds with ACS gate | | |
| Compliance score (CIS/NIST/PCI) | | |
| Runtime violations / week | | |
| SIEM integration coverage | | |

---

### ACS Future State Architecture (to be completed post-session)

**Integration points for design:**
1. ACS → Splunk: all violation events, compliance reports, vulnerability summaries (via HEC)
2. ACS → Jenkins/Tekton: roxctl image scan + image check as required pipeline stage
3. ACS → RHDH: component vulnerability status via proxy endpoint (custom plugin or ACS API)
4. ACS → Service Mesh: network baseline correlated with Kiali service graph (combined observability)
5. ACS → OpenShift: admission controller in Enforce mode for Critical/High policy violations in Prod
6. ACS → GitOps: ACS policy-as-code managed via ArgoCD (same pattern as Kyverno policies)

---

*Generated by Cursor AI · Acme Platform Discovery · v1.0*
