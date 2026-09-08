# Platform Initiative — Problem, Opportunity & Scope

**Red Hat Developer Hub (RHDH) and OpenShift Service Mesh**  
**Platform:** OpenShift  
**Audience:** Delivery / architecture / acme stakeholders

---

## 1. Problem Statement

Current development and runtime tooling is fragmented across multiple platforms, resulting in:

| Problem | Impact |
|---|---|
| **High cognitive load** | Engineers navigate disparate tools and processes to find services, trigger builds, check deploy status, and understand runtime behaviour |
| **Inconsistent onboarding and experience** | New developers and new services follow tribal knowledge rather than a repeatable path from “idea” to “running on OpenShift” |
| **Duplication of effort** | Teams reinvent pipelines, manifests, security controls, and service scaffolding instead of reusing standardised **golden paths** |
| **Limited governance and enforcement** | Engineering, security, and compliance standards are documented but not consistently embedded in the tools developers actually use |
| **Toolchain complexity as a delivery barrier** | At enterprise level, lack of standardisation and toolchain sprawl slows delivery velocity and constrains innovation |

**Runtime / connectivity gap (Service Mesh):**  
East-west traffic between services often lacks a consistent model for **service identity**, **encryption in transit (mTLS)**, **least-privilege access**, **traffic/resiliency patterns**, and **service-level observability** — increasing operational risk and making zero-trust / compliance outcomes harder to evidence on OpenShift.

---

## 2. Opportunity

Adopting **Red Hat Developer Hub** and **Red Hat OpenShift Service Mesh** on OpenShift provides an opportunity to:

### Developer Hub (RHDH)

- Establish a **unified developer portal** (single pane of glass) for catalog, ownership, docs, CI/CD status, and OpenShift visibility  
- Enable **self-service provisioning** via standardised software templates and workflows  
- Improve **onboarding speed** and day-to-day developer productivity  
- Strengthen **governance, security, and compliance** through embedded guardrails (RBAC, secure-by-default templates, integration controls)  
- Align with **platform engineering** strategy and cloud-native practices  

### Service Mesh (OpenShift Service Mesh)

- Establish **consistent service-to-service trust** (identity + mTLS) across enrolled workloads  
- Enable **policy enforcement** (AuthorizationPolicies, deny-by-default where required) without changing application code (ambient mesh model)  
- Support **traffic management and resiliency** patterns (e.g. retries, canary-oriented controls) in a platform-standard way  
- Provide **mesh observability** (service graph, metrics, tracing hooks, security-relevant logs to enterprise SIEM such as Splunk)  
- Align mesh enrolment with **golden paths** so new services join the mesh by default where policy requires it  

### Combined platform outcome

A coherent **inner development loop** (discover → scaffold → build → deploy) and **runtime trust plane** (identity → mTLS → AuthZ → observe) on OpenShift — reducing cognitive load while raising the baseline for security and standardisation.

---

## 3. Scope

### 3.1 In scope

#### A. Red Hat Developer Hub

| Area | What is included |
|---|---|
| **Platform deployment** | Deploy RHDH on OpenShift via Infrastructure as Code / GitOps (Operator + `Backstage` instance), including baseline HA/architecture decisions agreed in design |
| **Identity & access** | SSO/OIDC integration; RBAC aligned to agreed personas; admin access model |
| **Tooling integrations** | Integration with agreed CI/CD, source control, and platform tooling (e.g. Bitbucket/GitHub/GitLab, Jenkins and/or OpenShift Pipelines, Argo CD / OpenShift GitOps, Kubernetes/OpenShift plugin, SonarQube, Snyk, Jira, Artifactory/Quay, TechDocs — final list confirmed in discovery) |
| **Software catalogue** | Establishment of software catalogue and **service ownership** model; catalog population approach agreed with the acme |
| **Golden paths** | Implementation of standardised templates and workflows (e.g. application code + release pipeline archetypes such as Spring Boot / Node.js), including **secure-by-default** guardrails agreed in design |
| **Governance** | RBAC and governance controls for portal use, template change control, and integration permission expectations |
| **Branding / UX (as agreed)** | Branding, theming, and baseline homepage / component dashboard configuration within RHDH capabilities |
| **Documentation & enablement** | Design artefacts, runbooks/README-level docs, and knowledge transfer for the platform owner team |

#### B. OpenShift Service Mesh

| Area | What is included |
|---|---|
| **Mesh platform** | Istio-based service mesh capabilities via **Red Hat OpenShift Service Mesh** (target: OSSM 3 ambient unless discovery locks an alternate constrained by existing estate) |
| **Control plane** | Mesh control plane installation and configuration for agreed Non-Prod (and Prod where in engagement scope) on OpenShift |
| **Service identity & mTLS** | Service identity model and mTLS architecture (trust domain / tenancy decisions from design); certificate lifecycle approach as agreed |
| **Policy enforcement** | AuthorizationPolicy design and baseline enforcement (e.g. deny-all / least privilege patterns) for enrolled namespaces |
| **Traffic management** | Traffic management and resiliency patterns agreed for the pilot / platform standard (e.g. retries, timeouts, canary-oriented controls) |
| **Ingress / egress (as agreed)** | Design and baseline implementation aligned with OpenShift Routes and/or mesh gateways; egress controls where required by discovery |
| **Observability** | Mesh observability (e.g. Kiali / metrics / tracing integration points) and security logging requirements for integration with enterprise observability (e.g. Splunk) as agreed |
| **Enrolment model** | Namespace enrolment approach (including golden-path / policy-as-code auto-enrolment where agreed) |
| **Documentation & enablement** | Mesh design artefacts (trust, AuthZ, risks/mitigations), operational ownership model, and KT for Day-2 owners |

#### C. Integration between RHDH and Service Mesh (platform coherence)

| Area | What is included |
|---|---|
| **Template alignment** | Golden path updates so new services can enrol in the mesh and inherit default policies where required |
| **Visibility** | RHDH/Kubernetes plugin configuration to surface relevant OpenShift and mesh-related resources for catalogued components (as supported) |
| **Pilot path** | One measurable pilot application path: catalogued in RHDH, deployed via agreed pipeline/GitOps, enrolled in mesh, with mTLS/policy/observability validated |

---

### 3.2 Out of scope

| Area | Clarification |
|---|---|
| **Full replacement of existing CI/CD tooling** | RHDH integrates with and orchestrates visibility/self-service around existing CI/CD; it does not rip-and-replace Jenkins/Azure DevOps/etc. unless explicitly added later |
| **Major re-platforming of legacy applications** | No broad rewrite or migration of legacy estates onto the IDP/mesh as a delivery outcome of this initiative |
| **Non-cloud-native workloads outside IDP adoption** | Workloads not participating in the OpenShift / IDP adoption path are out of scope |
| **ACS (Advanced Cluster Security) implementation** | ACS deep implementation, Enforce-mode rollout, and product remediation are out of scope unless covered under a separate review/SOW (discovery may note integration opportunities only) |
| **Enterprise IdP replacement** | Consuming existing IdP (e.g. Entra ID / Keycloak); not replacing corporate identity platforms |
| **Organisation-wide mandatory adoption programme** | Platform enables adoption; enterprise change management / mandated rollout beyond agreed pilot cohorts is acme-owned unless separately scoped |
| **Multi-cluster mesh federation (unless agreed)** | Independent per-cluster mesh is the default; cross-cluster federation only if explicitly added after discovery |
| **Application code remediation** | Fixing application defects, performance tuning of business services, or rewriting services to become mesh-aware beyond platform defaults |
| **Full enterprise SIEM redesign** | Defining mesh/RHDH log events and integration points; not rebuilding Splunk architecture enterprise-wide |
| **Network CNI redesign** | Standard OpenShift networking assumed; CNI replacement/custom CNI programmes out of scope |

---

## 4. Success criteria (summary)

| Domain | Measurable outcome |
|---|---|
| **RHDH** | RHDH deployed via IaC/GitOps with SSO and agreed plugins; software catalogue live with ownership model; ≥2 golden path templates published; pilot app onboarded with working CI/CD trigger path |
| **Service Mesh** | Control plane verified on agreed clusters; mTLS and baseline policies active for enrolled namespaces; pilot app traffic/resiliency and observability validated |
| **Combined** | Developers can discover → scaffold → deploy on OpenShift through a standard path; enrolled services operate under a documented trust and policy model |

---

## 5. Assumptions

- Target platform is **OpenShift**; GitOps (OpenShift GitOps / Argo CD) is the preferred delivery mechanism for platform components  
- Discovery confirms final plugin list, HA/DB choices, mesh trust/AuthZ posture, and Non-Prod vs Prod rollout sequencing  
- Acme provides access to clusters, IdP, SCM, CI/CD, and security stakeholders for discovery and design decisions  
- A named **platform owner** exists (or is designated) for Day-2 operations of RHDH and mesh  

---

## 6. Dependencies / constraints

- Availability of Non-Prod (and Prod, if in scope) OpenShift clusters and operator install rights  
- Identity provider readiness for OIDC  
- Secret management approach (e.g. Vault / ESO) for RHDH integrations  
- InfoSec approval path for mTLS/trust domain, AuthZ defaults, and egress controls  
- Splunk / observability team engagement for security event onboarding  

---

*Document version: aligned to RHDH + OpenShift Service Mesh initiative scope (ACS implementation excluded unless separately engaged).*
