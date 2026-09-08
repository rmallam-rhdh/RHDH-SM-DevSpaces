# ACS Review — Discussion Points + What ACS Offers

**Session:** Current-state review + future-state recommendations  
**Assumption:** Many answers today will be *“no”* or *“don’t know”* — use the **What ACS offers** blocks to explain value without selling implementation.

**Known CLIENT context:** RHACS deployed; policies **inform-only**; InfoSec-owned; toolchain = Snyk, SonarQube, JFrog Xray, Jenkins, Nexus.

---

## 1. CVE process & remediation SLA

**Ask**
- End-to-end path: CVE detected → triaged → fixed → deployed
- Severity thresholds that block build vs deploy
- Remediation SLA by severity; override process

**If answer is no / don’t know**
- CVEs may be found in multiple tools with no single owner or SLA

**What ACS offers**
- **Single runtime view** of CVEs on **deployed** images and running workloads (complements Snyk at code time and Xray at registry time)
- **Risk prioritization** — CVE score + **exposure** (is the vulnerable package actually running? is the workload internet-facing?)
- **Policy-based gates** — e.g. “block deploy if Critical CVE with fix available and CVSS > 7”
- **Exception workflow** — scoped deferrals with expiry (who waived, why, until when)
- **Compliance reporting** — exportable posture for audit (what % of fleet is vulnerable, trending over time)

**Talking point:** *Snyk finds it in code, Xray finds it in the image, ACS tells you if it’s actually running in Prod and whether policy allows it to stay.*

---

## 2. Inform vs Enforce policy mode

**Ask**
- Which policy categories are active?
- Inform or Enforce per environment?
- Is admission controller blocking deploys?

**If answer is no / don’t know**
- Likely all **Inform** — visibility without blocking (matches board capture)
- Team may not know what would change if switched to Enforce

**What ACS offers**
- **Inform** — log/alert only; safe for learning baseline without breaking deployments
- **Enforce** — **admission controller** blocks non-compliant deploys; **runtime** can kill violating pods
- **Gradual rollout** — Inform in eDev → Enforce Critical-only in Non-Prod → full Enforce in Prod
- **Built-in policy sets** — RHACS defaults for CIS, NIST, PCI-oriented controls (tune before Enforce)
- **Per-scope enforcement** — different mode per cluster, namespace, or deployment

**Talking point:** *Inform is the right starting point. Enforce is the control — but only after false positives are understood and owners exist.*

---

## 3. Custom policies

**Ask**
- Any custom policies beyond defaults?
- Who authors, owns, and approves changes?

**If answer is no / don’t know**
- Probably running RHACS defaults only, changed ad hoc in UI

**What ACS offers**
- **Custom policies** in Rego-like DSL — e.g. “only images from Artifactory”, “no privileged pods in Prod”, “required labels for PCI zone”
- **Policy-as-code** — policies in Git, applied via API/CI (audit trail, PR review)
- **Reusable policy groups** — platform baseline + team extensions
- **Simulation** — test policy against historical deployments before Enforce

**Talking point:** *Defaults get you 70%. Custom policies encode CLIENT rules — registry allow-list, SA naming, mesh namespace labels.*

---

## 4. Alerts & violation handling

**Ask**
- Who receives ACS alerts today?
- Splunk integration? Triage process? SLAs?

**If answer is no / don’t know**
- Violations visible in ACS console only; no defined on-call or SIEM path

**What ACS offers**
- **Violation events** exportable to **Splunk** (HEC), email, webhook, PagerDuty, ServiceNow
- **Severity-based routing** — Critical → SecOps; Medium → platform ticket; Low → dashboard
- **Violation lifecycle** — open → in progress → resolved / deferred with reason
- **Audit log** — who changed policy, who deferred violation, when
- **Dashboards** — compliance %, top violating deployments, mean time to remediate

**Talking point:** *ACS without alert routing becomes shelfware. Splunk integration is the compliance story for a bank.*

---

## 5. Network graph → NetworkPolicy

**Ask**
- Is ACS network baseline used?
- Are NetworkPolicies generated from observed traffic?

**If answer is no / don’t know**
- Network visibility may exist in ACS but not acted on; K8s NetworkPolicies may be manual or absent

**What ACS offers**
- **Network graph** — observed flows between services, namespaces, external endpoints
- **Baseline learning** — “this is normal for payments-api” then alert on deviation
- **NetworkPolicy generation** — export suggested policies from observed traffic (human review before apply)
- **Exposed service detection** — workloads reachable from outside cluster
- **Mesh complement** — ACS sees **actual L3/L4 flows**; mesh adds **L7 identity + mTLS**; together = stronger zero-trust story

**Talking point:** *ACS network graph is not a replacement for Istio AuthZ — it’s the input for “what should be allowed” before you write policies.*

---

## 6. Deployment topology

**Ask**
- Where is ACS Central? Which clusters secured? One Central per env?

**If answer is no / don’t know**
- Central may exist but topology undocumented; not all clusters may be enrolled

**What ACS offers**
- **ACS Central** — management UI, API, policy engine, vulnerability DB (one per org or per env)
- **Secured Cluster Services** per cluster — **Sensor** (k8s API watch), **Collector** (node-level), **Admission Controller** (deploy-time gate)
- **Multi-cluster** — one Central managing eDev + Non-Prod + Prod (or separate Centrals for isolation)
- **RHACS on ROSA/OCP** — supported; can run Central on management cluster
- **Disconnected** — offline vulnerability feeds with periodic sync

**Talking point:** *Every cluster that runs apps should be a secured cluster — otherwise ACS has a blind spot.*

---

## 7. Ownership & operating model

**Ask**
- Platform vs InfoSec ownership? On-call? Upgrade cadence?

**If answer is no / don’t know**
- InfoSec may own policies; platform may not know their ACS ops role

**What ACS offers**
- Clear **RACI split**:
  - **Platform** — deploy Central, secured clusters, upgrades, integrations (Splunk, CI)
  - **InfoSec** — policy definition, Enforce decisions, exception approval
  - **App teams** — remediate violations on their workloads
- **RBAC in ACS** — Admin, Analyst, Continuous Integration (CI token only)
- **API + roxctl** — automate without console access

**Talking point:** *ACS is a shared product — platform runs it, security governs it, apps fix their stuff.*

---

## 8. Central database

**Ask**
- Where is the DB? Who owns backup/restore?

**If answer is no / don’t know**
- Default embedded DB on PVC; backup may never have been tested

**What ACS offers**
- **Embedded Postgres** (default) or **external Postgres** for HA
- **Backup** — DB snapshot + config export; restore procedure documented by Red Hat
- **Data held** — policies, violations, image metadata, compliance state (not application data)
- **Retention** — configurable violation and risk history

**Talking point:** *Before Enforce in Prod, prove you can restore Central — it’s the policy brain.*

---

## 9. High availability

**Ask**
- Is Central HA? What if Central is down?

**If answer is no / don’t know**
- Single replica common in early deployments

**What ACS offers**
- **Multiple Central replicas** behind load balancer
- **External Postgres** with HA for state
- **Secured clusters keep running** if Central is temporarily unavailable — collectors buffer; enforcement uses last-known policy
- **DR** — second Central site or restore from backup (RTO/RPO decision)

**Talking point:** *HA matters when Enforce is on — Central outage shouldn’t mean uncontrolled deploys.*

---

## 10. JFrog Artifactory integration

**Ask**
- Is Artifactory integrated with ACS? How does Xray relate?

**If answer is no / don’t know**
- ACS may only see images **after** deploy, not at registry scan time

**What ACS offers**
- **Registry integration** — ACS scans images in Artifactory/Quay on push or on schedule
- **Deployed vs registry view** — compare “what’s in the registry” vs “what’s actually running” (version drift)
- **Policy on image source** — only allow images from `artifactory.acme.../team/*`
- **Complements Xray** — Xray at artifact/repo layer; ACS at **cluster deploy + runtime** layer (defence in depth, not duplicate)

**Talking point:** *Xray gates the registry; ACS gates the cluster. Both can reference the same image digest.*

---

## 11. CI/CD & roxctl pipeline gates

**Ask**
- Is roxctl in Jenkins today? What fails a build?

**If answer is no / don’t know**
- ACS likely **deploy-time or runtime only** — no shift-left gate

**What ACS offers**
- **`roxctl image scan`** — scan image in pipeline before push to registry
- **`roxctl image check`** — evaluate image against ACS policies (fail build on violation)
- **`roxctl deployment check`** — validate manifest before `oc apply`
- **CI service account** — limited ACS token for pipelines only (no admin)
- **Shift-left + shift-right** — pipeline gate (build) + admission controller (deploy) + runtime (running)

**Example gate stack for CLIENT**
```
Bitbucket → Jenkins → Snyk (code) → build image → Xray (image) → roxctl check (ACS policy) → push Artifactory → deploy → ACS admission (Enforce)
```

**Talking point:** *roxctl is how ACS participates in golden-path templates without developers logging into the ACS console.*

---

## 12. RHDH & Service Mesh touchpoints

**Ask**
- ACS data in Developer Hub? ACS step in templates? Mesh + ACS correlation?

**If answer is no / don’t know**
- Developers use separate tools; no portal view of security posture

**What ACS offers**
- **ACS API** — expose vuln count, policy status per deployment (RHDH plugin or proxy)
- **Golden-path step** — template runs `roxctl image check` before first deploy
- **Component page tile** — “ACS posture: 2 Medium CVEs, 0 policy violations”
- **With mesh** — ACS runtime anomalies + Kiali traffic graph + Istio AuthZ DENY logs → combined Splunk story
- **RHDH namespace** — apply ACS policies like any workload (Inform first, Enforce when ready)

**Talking point:** *ACS doesn’t need to be in RHDH on day one — but the API makes “security in the portal” possible without a big integration project.*

---

## Quick “ACS value” one-liners (if room is quiet)

| Topic | One-liner |
|-------|-----------|
| CVE | ACS shows what’s vulnerable **and running**, not just what’s in the repo |
| Inform/Enforce | Inform learns; Enforce protects |
| Custom policies | Encode CLIENT rules once, apply everywhere |
| Alerts | No Splunk path = no audit trail |
| Network graph | See traffic before you write NetworkPolicy or AuthZ |
| Topology | Unsecured cluster = blind spot |
| Ownership | Platform runs it, security governs it, apps fix it |
| Database | Backup Central before you Enforce in Prod |
| HA | Enforce mode needs reliable Central |
| Artifactory | Registry scan + runtime scan = full image lifecycle |
| roxctl | Put ACS in Jenkins, not just in the cluster |
| RHDH | API-first — surface posture in the portal later |

---

## Decision capture (end of session)

| Topic | Current (likely) | ACS can offer | Priority | Owner |
|-------|------------------|---------------|----------|-------|
| Policy mode | Inform only | Enforce roadmap by env | | InfoSec |
| CVE SLA | Undefined | Risk-ranked remediation | | |
| Splunk | No | HEC integration | | |
| roxctl | No | Jenkins gate | | |
| NetworkPolicy | No | Baseline → generated policies | | |
| HA | Don’t know | Multi-replica Central | | Platform |
| RHDH | No | API / template step | Defer? | |

---

*Facilitator note: This is a **review**, not in-scope implementation. Capture recommendations; separate SOW for Enforce rollout.*
