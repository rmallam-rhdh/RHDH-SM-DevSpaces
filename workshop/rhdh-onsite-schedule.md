# Red Hat Developer Hub — Onsite Discovery Schedule (Miro-ready)

**Source:** `RHDH-Discovery-Questions-from-Miro.docx` (396 questions, 22 themes)  
**Onsite plan:** Day 1 (joint DH + SM) · Day 2 (RHDH) · Day 7 (RHDH close-out)  
**Service Mesh:** Days 3–6 — see [`service-mesh-onsite-schedule.md`](service-mesh-onsite-schedule.md)

---

## Question map by day (overview)

| Day | Focus | Doc sections covered | Approx. questions |
| --- | --- | --- | --- |
| **Day 1** (joint) | Why, who, current landscape, SCM/CI/CD | 01, 02, 06 (light), 07, 13 (success) | ~95 |
| **Day 2** (RHDH) | Golden paths, supply chain, integrations, plugins (start) | 08, 09, 11 (supply chain), 15 (boundary) | ~75 |
| **Day 7** (RHDH) | Architecture, IAM, security, HA, ops, close-out | 03–06, 08 (deep), 10–22 | ~226 |

*Original 4-day remote plan (Day 3) rolls into Day 7 for anything not closed on Day 2.*

---

## Miro frames

| Frame | Colour | When |
| --- | --- | --- |
| `DH · Problem statement` | White | Day 1 |
| `DH-D1 · Kick-off & landscape` | Blue | Day 1 |
| `DH-D2 · Golden paths & integrations` | Blue | Day 2 |
| `DH-D7 · Architecture, IAM & close-out` | Blue | Day 7 |
| `DH · Decision log` | Green | All days |
| `DH · Parking lot` | Grey | Phase 2 / remote |
| `DH ↔ SM · Boundary` | Purple | Day 2 + Day 7 |

---

# DAY 1 — Joint kick-off & current landscape

**Miro frame:** `DH-D1 · Kick-off & landscape`  
**Attendees:** Platform, app leads, PE, delivery sponsor, SM stakeholders (joint)  
**Goal:** Agree *why*, *who*, *what exists today* — not HA/RBAC depth (Day 7).

## Schedule blocks → question themes

| Block (acme schedule) | What we decide | Doc section | Question IDs |
| --- | --- | --- | --- |
| **Kick-off** | Agenda, owners, ground rules, design-phase exit | 01 | 1–5, A9–A10 |
| **Success & adoption** | Exec sponsor, pilot exit, adoption model, 6-month success | 01, 13 | 6–14, 17–18, 147–152, A2, A138–A142 |
| **Digi 2.0 landscape** | Teams, scale, app architecture, onboarding pain | 01, 02, 06 | 9–11, 15–17, 19–24, A11–A20, 62–63, 66–68 |
| **SCM & CI/CD** | Bitbucket, Jenkins, release flow, environments, GitOps maturity | 07 | 72–95, A74–A85 |

## Day 1 — questions (by section)

### §01 Why / Strategy / Scope

| # | Question |
| --- | --- |
| 1 | Why an IDP, and why now? What specifically is broken today? |
| 2 | What is the cost of the status quo — what happens if nothing changes? |
| 3 | Who is the executive sponsor and what outcome are they accountable for? |
| 4 | Is this funded as a project with an end date, or as an ongoing product? |
| 5 | What are the expectations and success criteria for the engagement? |
| 6 | What are the outcomes and deliverables? |
| 7 | What does success look like at the end of the pilot, versus at scale? |
| 8 | What are the pilot exit criteria, and who signs them off? |
| 9 | Which teams are the pilot candidates, and why those? |
| 10 | Which parts of CLIENT are in scope, and which are explicitly out? |
| 11 | What is explicitly out of scope for this engagement? |
| 12 | Which decisions are already made and not open for discussion? |
| 13 | Is adoption mandated, incentivised, or opt-in? |
| 14 | What is the big picture — where does Developer Hub sit relative to Service Mesh, OpenShift and the existing toolchain? |
| 15 | Has a previous platform or portal attempt been made at CLIENT? What happened? |
| 16 | Is there an existing developer portal or IDP in place, even partially? |
| 17 | How can we make developers use the IDP over their existing flow? What is the driver? |
| 18 | What developer journeys are the highest priority for Dev Hub? *(offline action)* |
| A1 | Is there an ADR process, and will RHDH design decisions be recorded in it? |
| A2 | What is the target state at 12 and 24 months — services, teams, templates? |
| A9 | Which discovery items must be closed before detailed design can begin? |
| A10 | What is the definition of done for the design phase, and who accepts it? |

*Park to Day 7 if time short: A3–A8 (architecture standards, design authority, customisation appetite).*

### §02 Teams, Users & Scale

| # | Question |
| --- | --- |
| 19 | How many developers will be onboarded in the pilot? |
| 20 | Number of initial teams — what is the scaling plan? |
| 21 | Ownership model if more than one team — app / services / APIs / environments? |
| 22 | What is the team's skill level in OpenShift? |
| 23 | What are the three things developers complain about most? |
| 24 | What is the expected concurrent user load on RHDH? |
| 25 | Development ecosystems — languages / services / team skills? |
| A11–A20 | Peak users, geography, contractors, API volume, catalogue size, template volume, a11y, browsers, VDI, locales |

**Captured on Miro (WS):** ~5–6 teams, ~100 pilot ramp, ~1000 org-wide; Java (Micronaut/Spring/Quarkus) + Node micro-frontends; Release 1 Mar 2027, Release 2 Mar 2028.

### §06 Software Catalogue & Ownership *(landscape only)*

| # | Question |
| --- | --- |
| 62 | What is the initial set of apps / systems to appear in Developer Hub? |
| 63 | For the initial set of apps, what is the app architecture? |
| 66 | What is the unit of ownership — service, application, product, or system? |
| 67 | Will the catalogue be authoritative, or a view over an existing system of record? |
| 68 | Is there an existing application inventory or CMDB, and how accurate is it? |

*Full catalogue design → Day 7.*

### §07 Current State — SDLC, CI/CD & Source Control

| # | Question |
| --- | --- |
| 72–77 | SDLC walkthroughs — Java, Node, microservices lifecycle, CI/CD setup, SCM authority, archetypes |
| 78–95 | Tool versions, Jenkins ownership, pipeline standardisation, Tekton scope, namespace requests, time-to-prod, dependencies, GitOps, Helm/Kustomize, config repos, migrations, secrets, environments, promotion, approvals, rollback |
| A74–A85 | Bitbucket product/version, rate limits, branching, Jenkins auth, build agents, artefacts, registries, base images, build duration, manual gates |

### §13 Metrics & Outcomes *(success framing only)*

| # | Question |
| --- | --- |
| 147 | Are DORA metrics measured today, and from what baseline? |
| 148 | How will developer satisfaction be measured? |
| 150 | What single metric determines whether this succeeded? |
| 151 | What is the target time from idea to production for a new service? |
| 152 | What adoption level is expected, by when? |

## Day 1 — decision checklist

- [ ] Exec sponsor and adoption model agreed
- [ ] Pilot teams and exit criteria named
- [ ] Digi 2.0 landscape captured (teams, languages, service count)
- [ ] SCM and primary CI/CD tool confirmed
- [ ] Release / promotion walkthrough documented for Java + Node
- [ ] Top developer journeys listed (or owner assigned for offline completion)
- [ ] Open items parked with owner for Day 2 / Day 7

## Day 1 — context sticky (paste to Miro)

Problem: fragmented tooling, high cognitive load, inconsistent onboarding, no golden paths, weak governance.  
Opportunity: unified portal, self-service templates, faster onboarding, embedded guardrails, alignment with platform engineering.

---

# DAY 2 — Golden paths, supply chain & integrations

**Miro frame:** `DH-D2 · Golden paths & integrations`  
**Attendees:** Platform, app architects, InfoSec (supply chain), CI/CD owners  
**Opens with:** 15 min recap of Day 1

## Schedule blocks → question themes

| Block (acme schedule) | What we decide | Doc section | Question IDs |
| --- | --- | --- | --- |
| **Recap** | Day 1 decisions / open items | — | — |
| **Golden Paths** | What templates create; Java/Node flows; guardrails | 09 | 108–117, A98–A111 |
| **ACS & Supply chain** | Scan gates, base images, Cosign, CVE process, ACS ↔ template | 11 | 123–130, 129–130, A119–A128 |
| **Integration priorities** | Must-have plugins at launch vs backlog | 08 | 96–107, A86–A97 |
| **Plugins deep dive** *(if time)* | Auth, permissions, endpoints per integration | 08, 19 | 96–107, A86–A97, A191–A195 |

## Day 2 — questions (by section)

### §09 Golden Paths / Software Templates

| # | Question |
| --- | --- |
| 108 | Which software templates are needed at launch, beyond Java Spring Boot and Node? |
| 109 | What should a template create — repo, pipeline, namespace, catalogue entry, or all? |
| 110 | What must a new service have on day one to be compliant? |
| 111 | Are there mandated internal libraries or SDKs that templates must include? |
| 112 | What default security guardrails go into templates? |
| 113 | Who owns and maintains templates once they exist? |
| 114 | How will template changes reach services already generated from them? |
| 115 | May teams deviate from a golden path, and through what process? |
| 116 | Are there existing reference apps or starter repos to build templates from? |
| 117 | How will template usage be measured? |
| A98–A111 | Full Java/Node step sequences, Git SA, branch protection, Jenkins job, namespace, Argo CD app, Jira/change record, parameters, credentials, template CI, versioning, duration, idempotency |

**Captured (WS):** Templates should apply guardrails automatically; manual security attestation not desired.

### §11 Security, Compliance & Governance *(supply chain focus)*

| # | Question |
| --- | --- |
| 123–125 | Current security controls; what security enforces; desired new controls |
| 126–127 | Quality/security gates per build; vulnerability thresholds |
| 128 | Can a gate be overridden, by whom, and is it logged? |
| 129–130 | Image signing / SBOM; segregation of duties |
| A126 | What secrets scanning applies to repos created by templates? |

**Captured (WS):** Snyk, SonarQube, JFrog Xray, Nexus, RHACS (inform-only).

### §08 Plugins & Integrations

| # | Question |
| --- | --- |
| 96–107 | Required plugins — Jenkins, K8s, SonarQube, Snyk, Jira, Artifactory, Git, API Connect; launch vs aspirational; branding |
| A86–A97 | Per-integration endpoints, auth, SA, Argo CD, Tekton, ServiceNow, Confluence, API Connect, Dynatrace/Splunk, rate limits, degraded UX |

### §15 RHDH ↔ Service Mesh Boundary *(golden-path seam)*

| # | Question |
| --- | --- |
| 159–164 | RHDH↔mesh integration expectation; mesh graph in portal; template registers mesh; pilot overlap; mesh configs in templates; HTTPRoutes in templates |
| A148–A152 | Mesh objects as catalogue Resources; Kiali plugin vs link; mesh onboarding workflow; template-generated policies; post-template ownership |

## Day 2 — decision checklist

- [ ] Launch templates defined (Java + Node minimum)
- [ ] Template scope agreed (repo / pipeline / namespace / catalogue / mesh)
- [ ] Supply-chain gates documented (Snyk, Sonar, Xray, signing)
- [ ] ACS ↔ template integration stance recorded
- [ ] Plugin priority matrix (Must / Should / Could) complete
- [ ] Mesh boundary: does template auto-enrol in mesh? (yes/no/defer)
- [ ] Outstanding plugin deep-dives assigned to Day 7

---

# DAY 7 — Architecture, IAM, operations & close-out

**Miro frame:** `DH-D7 · Architecture, IAM & close-out`  
**Attendees:** Platform, identity, InfoSec, observability, PE sponsor (last 30 min)  
**Opens with:** 15 min recap of Day 2

## Schedule blocks → question themes

| Block (acme schedule) | What we decide | Doc section | Question IDs |
| --- | --- | --- | --- |
| **Plugins deep dive** *(continue)* | Auth, permissions, token scope per system | 08, 19 | Remaining 96–107, A86–A97, A191–A200 |
| **Architecture & exposure** | Clusters, Route/TLS, TechDocs, catalog population | 03, 10, 16, 17 | 26–37, 118–122, A153–A180, A112–A118 |
| **IAM & RBAC** | Entra OIDC, personas, groups, break-glass | 05, 20 | 50–61, A43–A54, A201–A210 |
| **Security & governance** | Plugin gate, secrets, privilege escalation, audit | 11, 18 | 131–134, A119–A125, A181–A190 |
| **HA & resilience** | SLA, PostgreSQL, replicas, DR | 04 | 38–49, A33–A42 |
| **Branding & UX** | Theme, homepage, dashboards | 08, 18 | 107, A188 |
| **Observability** | Metrics, logs, audit, Splunk, on-call | 21 | A211–A222 |
| **DevSpaces** | Sizing and capacity for dev workspaces | 03 | 32, A21–A32 *(workspace-related)* |
| **PE / Security conversation** | Ownership, RACI, RAID | 12, 14 | 135–146, 153–158, A129–A147 |
| **Close-out** | Decision log, open items, next steps | 14, 22 | 153–158, A143–A147, A223–A232 |

## Day 7 — questions (by section)

### §03 Platform, Infrastructure & Sizing

| # | Question |
| --- | --- |
| 26–37 | Clusters RHDH interacts with; instance placement; prod in non-prod cluster; OCP version; connected/proxied; DevSpaces; blockers; firewall; reachability |
| A21–A32 | Node topology, taints, quotas, PSA, storage classes, ODF, ingress capacity, sidecar injection, autoscaling, maintenance, API load, ARO |

**Captured (WS):** 2 DCs × 3 clusters; ARO end of year; fleet 4.20→4.22→5.2; in-cluster PG for Dev Hub DB (bank VMware PG future uncertain).

### §04 Database, HA, DR & Service Levels

| # | Question |
| --- | --- |
| 38–49 | Storage/DB; external PostgreSQL HA; latency; sizing; backup/restore; HA requirements; SLA/SLO; DR RTO/RPO; non-prod instance for upgrades; upgrade cadence |
| A33–A42 | PG version, operator vs external, pooling, growth, backup, restore test, cross-DC replication, rebuild from Git, patching, per-env DB |

### §05 Identity, Authentication & Authorisation

| # | Question |
| --- | --- |
| 50–61 | Auth model; Entra claims; personas; groups; catalogue visibility; MFA; JML; service accounts |
| A43–A54 | App registration, OIDC/PKCE, token lifetimes, session cookie, stable ID, group overflow, Graph ingestion, guest accounts, downstream auth, step-up, group rename |

**Captured (WS):** Entra for internal users; on-prem AD for OCP RBAC; Ping / SailPoint / CyberArk in programme.

### §06 Software Catalogue & Ownership *(full design)*

| # | Question |
| --- | --- |
| 64–65, 69–71 | Population method; ownership; metadata; freshness; non-OCP systems |
| A55–A73 | Entity kinds, System/Domain definitions, naming, namespaces, lifecycle, APIs, resources, annotations, providers, refresh, catalog-info location, validators, bulk import, CMDB sync, retirement, orphans |

### §08 Plugins & Integrations *(deep dive — remaining)*

*Complete any Day 2 gaps; add ServiceNow, Vault, Dynatrace, Splunk, DX, CloudBees, Argo CD, PagerDuty per acme schedule.*

### §10 Documentation / TechDocs

| # | Question |
| --- | --- |
| 118–122 | Storage/render; object storage; migration from Confluence; ownership; docs-as-code mandatory? |
| A112–A118 | Local vs external builder, bucket lifecycle, air-gapped mkdocs, structure template, diagrams, review, Confluence migration scope |

### §11 Security, Compliance & Governance *(full)*

| # | Question |
| --- | --- |
| 131–134 | Regulations (RBNZ, Privacy Act, PCI, ISO); data residency; change records; approved tooling list |
| A119–A125 | Threat model, pen test, data classification, trusted registry, RHACS on RHDH namespace, network policies, SIEM/audit |
| A127–A128 | Platform vuln SLA; regulatory constraints on identity/audit data |

### §12 Operating Model & People

| # | Question |
| --- | --- |
| 135–146 | Post go-live owner; team formation; engineer count; on-call; product owner; prioritisation; champions; training; feedback; skills gaps; decommission; migration vs new-only |
| A129–A137 | RACI, L1/L2/L3, handover criteria, documentation set, KT plan, subscriptions, lifecycle, team onboarding, self-service vs platform-assisted |

### §13 Metrics & Outcomes *(remaining)*

| # | Question |
| --- | --- |
| 149 | Who reports metrics, to whom, how often? |
| A138–A142 | Baseline measurements, auto vs survey, reporting cadence, template-created ratio, cognitive load |

### §14 Risks, Dependencies & Timeline

| # | Question |
| --- | --- |
| 153–158 | Immovable dates; dependencies; change freeze; stop risks; missing stakeholders; unasked questions |
| A143–A147 | Safe Secure identity stream; ARO readiness; hardware order; blocking decisions; PostgreSQL contingency |

### §15 RHDH ↔ Service Mesh Boundary *(confirm Day 2 decisions)*

*Revisit 159–164, A148–A152 — sign off with SM Day 6 outputs.*

### §16 Deployment Architecture & Installation

| A153–A168 | Operator vs Helm, version, channel, image mirror, namespaces, replicas, PDB, anti-affinity, probes, Argo CD, rollback, canary, SCC, multi-DC topology |

### §17 Networking, Ingress, TLS & Certificates

| A169–A180 | Route vs Ingress vs LB; FQDN; TLS mode; CA; cert-manager; proxy/NO_PROXY; allow-list; TLS inspect; trust bundle; session affinity; WebSockets; timeouts |

### §18 Configuration & Secrets Management

| A181–A190 | app-config structure; GitOps; secrets in Vault/CyberArk/ESO; rotation; change process; drift detection; feature flags; branding; new plugin process; config test env |

### §19 Dynamic Plugins & Extensibility

| A191–A200 | Supported vs community vs custom; packaging; npm mirror; version pinning; security review; custom plugin ownership; build pipeline; blast radius; elevated permissions; documentation |

### §20 RBAC & Permissions Design

| A201–A210 | RBAC plugin day one; policies in Git vs DB; roles; Entra group mapping; conditional policies; catalogue register rights; template execute rights; RBAC admin separation; audit; default posture |

### §21 Observability, Operations & Support of RHDH

| A211–A222 | User-workload monitoring; Grafana/Perses dashboards; alerts; SLIs/SLOs; Splunk forwarding; audit log stream; tracing; runbooks; incident severity; catalogue errors; Red Hat support escalation; capacity |

### §22 Testing, Acceptance & Cutover

| A223–A232 | Test environments; NFR load/soak/failover; load profile; DR test; UAT scenarios; go-live criteria; cutover plan; comms plan; decommission; hypercare |

### §01 / §02 overflow *(if not closed Day 1)*

| IDs | Topic |
| --- | --- |
| A3–A8 | Architecture standards, design authority, ARB cadence, customisation, prior PoCs, single entry point |

## Day 7 — decision checklist

- [ ] Cluster placement and namespace for RHDH agreed
- [ ] PostgreSQL approach and HA/DR targets signed off
- [ ] Entra OIDC + persona → group → role mapping draft complete
- [ ] RBAC default posture and admin break-glass documented
- [ ] Plugin governance gate and secrets approach agreed
- [ ] TechDocs backend chosen
- [ ] Ingress, TLS, and DNS ownership recorded
- [ ] Observability + Splunk event list for RHDH agreed
- [ ] DevSpaces sizing decision (or explicit deferral)
- [ ] Day-2 owner and RACI named
- [ ] Risk register populated; dependencies with dates
- [ ] **Developer Hub discovery complete** — decision log signed

---

## Parking lot → remote / design phase

| Item | Owner | Notes |
| --- | --- | --- |
| Highest-priority developer journeys (Q18) | CLIENT | Outstanding board action |
| Capability matrix / environment diagram | CLIENT | Outstanding board action |
| Internal PostgreSQL service future | CLIENT | VMware PG uncertainty |
| Full §22 cutover detail | Platform | After design, pre-implementation |
| Questions marked **Additional** not reached | Facilitator | Carry to design workshops |

---

## One sticky per block (copy to Miro)

### Day 1

```
DH-D1 | Kick-off | Agenda, owners, ground rules
DH-D1 | Success | Exec sponsor, pilot exit, adoption model
DH-D1 | Landscape | Teams, languages, Digi 2.0 topology
DH-D1 | SCM/CI/CD | Bitbucket + Jenkins flows Java/Node
DH-D1 | Metrics | DORA baseline, time-to-prod target
```

### Day 2

```
DH-D2 | Golden path | Java + Node — what template creates
DH-D2 | Guardrails | Auto security — no manual attestation
DH-D2 | Supply chain | Snyk, Sonar, Xray, signing gates
DH-D2 | ACS | Template integration stance
DH-D2 | Plugins | Must/Should/Could matrix
DH-D2 | Mesh boundary | Template enrols mesh? HTTPRoute?
```

### Day 7

```
DH-D7 | Architecture | Clusters, namespace, operator install
DH-D7 | HA/DR | SLA, PostgreSQL, replicas, RTO/RPO
DH-D7 | IAM | Entra OIDC, personas, MFA, break-glass
DH-D7 | RBAC | Roles, groups, conditional policies
DH-D7 | Security | Plugin gate, secrets, network policy
DH-D7 | TechDocs | Backend, Confluence migration?
DH-D7 | Observability | Splunk, alerts, on-call
DH-D7 | DevSpaces | Sizing and capacity
DH-D7 | Operating model | RACI, handover, KT
DH-D7 | CLOSE | Decision log + design kick-off
```

---

## How RHDH days connect to Service Mesh

```
Day 1 (joint)     Day 2 (RHDH)        Days 3–6 (SM)       Day 7 (RHDH)
─────────────     ────────────        ─────────────       ────────────
WHY + WHO         WHAT templates      HOW mesh works      HOW RHDH runs
Current SDLC      create + WHICH      Identity, ingress   IAM, HA, ops
                  plugins matter      waypoint, Day-2     close-out
        └──────── mesh in template? ──────────┘
                  (§15 boundary)
```

---

## Facilitator notes

| Day | Planned | Tip |
| --- | --- | --- |
| Day 1 | Full day joint | Keep RHDH to landscape + SDLC — defer HA/RBAC to Day 7 |
| Day 2 | RHDH blocks | Golden path + supply chain need decisions, not demos |
| Day 7 | Full RHDH close | Must end with signed decision log; mesh topics only via §15 |

**Total unique RHDH questions:** 396 (164 from Miro + 232 Additional).  
**Not all 396 need answers in the room** — log assumptions for design phase where the acme defers.
