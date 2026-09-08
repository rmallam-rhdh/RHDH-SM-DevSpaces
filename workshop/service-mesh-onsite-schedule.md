# Service Mesh — Onsite Design Workshop (Days 4–6)

**Format:** One main theme per day · collaborative design (not Q&A, not lab-driven)  
**Context:** Day 3 covers topology, rollout, mTLS, PKI, ingress & egress foundations  
**Day 7:** Developer Hub only — Service Mesh discovery closes end of Day 6  

**Locked (do not re-debate):** Ambient · mTLS · Waypoint · shared ingress gateway · OSSM 3

---

## Three-day overview (copy to Miro as three frames)


| Day       | Main topic                              | One-line purpose                                                                 | End-of-day deliverable                |
| --------- | --------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------- |
| **Day 4** | **Security & access design**            | Agree who services are, who they may talk to, and how policies are governed      | Access & governance pack              |
| **Day 5** | **Connectivity & production readiness** | Agree how services are exposed, which need L7/waypoint, and Prod vs Non-Prod bar | Connectivity & readiness pack         |
| **Day 6** | **Operations & assurance**              | Agree how the mesh is run, observed, audited, and handed to app teams            | Operating model + signed decision log |


---

# Day 4 — Security & access design

**Miro frame:** `SM-D4 · Security & access design`  
**Attendees:** Platform, InfoSec, app architects  
**Opens with:** 15 min recap of Day 3 (rollout list, mTLS plan, PKI, ingress/egress)

## What this day is about

Everything that answers: **“How do we identify workloads, and what are they allowed to do?”**

Not about ingress URLs or upgrades — purely **identity, trust boundaries, and access policy design**.

## Sub-topics (work through in order)


| #   | Sub-topic                     | Design focus                                                     |
| --- | ----------------------------- | ---------------------------------------------------------------- |
| 1   | **Trust boundaries**          | Trust domain per env/cluster; where identities are valid         |
| 2   | **Tenancy**                   | Hard / soft / hybrid default between namespaces and teams        |
| 3   | **Service identity**          | One ServiceAccount per service; naming standard                  |
| 4   | **Access policy model**       | Deny-default? Platform baseline + team extensions? Kyverno role? |
| 5   | **Allowed communication set** | For pilot app(s): who may call whom (access matrix)              |
| 6   | **Governance**                | Who proposes, approves, deploys, and audits policy changes       |


## Main activities (full day)


| Activity                | Miro template                      | Output                |
| ----------------------- | ---------------------------------- | --------------------- |
| Trust boundary mapping  | Boxes per env/cluster              | Trust domain matrix   |
| SA naming workshop      | Table: app → SA name               | SA standard           |
| AuthZ template design   | Platform vs team responsibilities  | AuthZ ownership model |
| Access matrix for pilot | Source × destination grid          | Signed access matrix  |
| Governance swimlane     | Propose → approve → deploy → audit | Governance RACI       |


## End of Day 4 — decision checklist

- [ ] Trust domain model agreed (InfoSec sign-off)
- [ ] Tenancy model chosen
- [ ] SA naming standard drafted
- [ ] AuthZ ownership model agreed
- [ ] Pilot app access matrix completed
- [ ] Policy governance RACI agreed

---

# Day 5 — Connectivity & production readiness

**Miro frame:** `SM-D5 · Connectivity & production readiness`  
**Attendees:** Platform, app architects, InfoSec/compliance, Prod readiness  
**Opens with:** 15 min recap of Day 4 access pack

## What this day is about

Everything that answers: **“How do services connect — inside the mesh, to users, and to Prod?”**

Builds on Day 3 ingress/egress headlines; goes deeper on **waypoint scope, L7 needs, and production bar**.

## Sub-topics (work through in order)


| #   | Sub-topic                      | Design focus                                       |
| --- | ------------------------------ | -------------------------------------------------- |
| 1   | **Waypoint scope**             | Which Phase 1 namespaces need a waypoint (not all) |
| 2   | **L7 requirements**            | Per app: path rules, JWT, headers — needed or not  |
| 3   | **Ingress catalogue**          | Hostnames, shared gateway, TLS ownership           |
| 4   | **Traffic & resilience**       | What’s in Phase 1 (retries, canary) vs backlog     |
| 5   | **Prod vs Non-Prod**           | Stricter mTLS, AuthZ, logging in Prod              |
| 6   | **Compliance & multi-cluster** | PCI/APRA/NZISM notes; multi-cluster now or later   |


## Main activities (full day)


| Activity                    | Miro template                              | Output                |
| --------------------------- | ------------------------------------------ | --------------------- |
| Waypoint scoring matrix     | Score apps: exposure, L7 need, zone        | Phase 1 waypoint list |
| L7 requirements table       | Per-app Y/N for path/JWT/headers           | L7 requirements       |
| Ingress catalogue           | App, hostname, TLS owner                   | Ingress catalogue     |
| Phase 1 vs backlog stickies | Canary, retries, timeouts, circuit breaker | Traffic backlog       |
| Prod vs Non-Prod poster     | Three columns: eDev · Non-Prod · Prod      | Environment baseline  |
| Compliance & multi-cluster  | Parking lot if needed                      | Notes + deferrals     |


## End of Day 5 — decision checklist

- [ ] Phase 1 waypoint namespaces listed
- [ ] L7 requirements captured per priority app
- [ ] Ingress catalogue agreed
- [ ] Traffic/resilience Phase 1 scope agreed
- [ ] Prod vs Non-Prod mesh baseline table complete
- [ ] Multi-cluster stance recorded (now / Phase 2 / N/A)

---

# Day 6 — Operations & assurance

**Miro frame:** `SM-D6 · Operations & assurance`  
**Attendees:** Platform, observability/Splunk owners, InfoSec, delivery sponsor (last 30 min)  
**Opens with:** 15 min recap of Days 3–5

## What this day is about

Everything that answers: **“How do we run this, prove it, and hand it to teams?”**

Closes discovery — no new architecture debates.

## Sub-topics (work through in order)


| #   | Sub-topic                   | Design focus                                          |
| --- | --------------------------- | ----------------------------------------------------- |
| 1   | **Observability**           | Who uses Kiali, metrics, traces; team visibility      |
| 2   | **Audit & Splunk**          | Which events matter; evidence for compliance          |
| 3   | **Day-2 operations**        | Upgrades, incidents, on-call, ownership               |
| 4   | **Developer & golden path** | What mesh objects exist when a new service is created |
| 5   | **Risks & assumptions**     | Design risks and mitigations                          |
| 6   | **Close-out**               | Decision log, open items, design phase kick-off       |


## Main activities (full day)


| Activity                    | Miro template                            | Output                      |
| --------------------------- | ---------------------------------------- | --------------------------- |
| Observability consumer map  | Who / what tool / what decision          | Consumer map                |
| Tracing shortlist           | Phase 1 backend choice                   | Tracing decision            |
| Evidence map                | Control → evidence (Git, logs, ticket)   | Splunk + evidence catalogue |
| Day-2 RACI                  | Upgrade, incident, enrolment             | Operating model RACI        |
| Golden-path day-in-the-life | New service from template → mesh objects | Enrolment spec              |
| Risk register               | Risk, owner, mitigation                  | Risk register               |
| Close-out                   | Fist-of-five + decision log export       | **Discovery complete**      |


## End of Day 6 — decision checklist

- [ ] Observability model agreed
- [ ] Splunk / audit evidence approach agreed
- [ ] Day-2 RACI agreed
- [ ] Golden-path mesh enrolment spec agreed
- [ ] Risk register populated
- [ ] Decision log signed; design phase scheduled

## Day 6 — Pre-workshop verification (facilitator only)

Run **before** Day 6 so you can speak confidently about observability and Day-2 operations.  
**Not a session activity** — use only if someone asks for a technical reference.

```bash
export KUBECONFIG=~/ocp.yaml   # or path to workshop cluster kubeconfig
```

| Topic (Miro card title) | What we decide (simple) | Pre-workshop test |
| ----------------------- | ----------------------- | ----------------- |
| **Observability** | Who uses Kiali, metrics, traces; platform vs app-team visibility; Phase 1 tracing backend | Open Kiali → Graph (`bookinfo`); verify Prometheus connected — see test script below |
| **Audit & Splunk** | Which mesh events matter for compliance; control → evidence map (Git, logs, ticket) | Sample ztunnel logs · `oc get telemetry -A` · prep Splunk field stickies (no live Splunk required) |
| **Day-2 operations** | Upgrade cadence, incident/on-call RACI, mesh enrolment ownership | `oc get istio,ztunnel -n istio-system` · check `CA_TRUSTED_NODE_ACCOUNTS` · confirm no ztunnel errors |
| **Golden path** | Namespace labels, SA, default policies, GitOps template for new services | Verify `bookinfo` labels · `oc get authorizationpolicy -A` · `oc get applications.argoproj.io -n openshift-gitops \| grep -i mesh` |
| **Risks & assumptions** | Risk register: item, owner, mitigation; what defers to Phase 2? | Document PoC gaps (CA expiry, gateway placement) — `openssl x509` on mesh CA; parking lot only |
| **Close-out** | Sign decision log; open items; design-phase kick-off date | Confirm pilot still works: `curl` bookinfo route → `200`; decision log frame ready on Miro |

### Test script — observability (Kiali graph)

```bash
export KUBECONFIG=~/ocp.yaml

# Kiali route + Prometheus backend
oc get route kiali -n openshift-operators
oc get kiali kiali -n openshift-operators -o jsonpath='{.spec.external_services.prometheus.url}{"\n"}'
oc logs -n openshift-operators -l app=kiali --tail=30 | grep -i prometheus

# Metrics scrapers
oc get servicemonitor,podmonitor -n istio-system

# Generate traffic, then open Kiali → Graph → namespace bookinfo
BOOKINFO_HOST=$(oc get route -n bookinfo -o jsonpath='{.items[0].spec.host}' 2>/dev/null \
  || echo "istio-ingressgateway-bookinfo.apps.<cluster-domain>")
for i in $(seq 1 20); do
  curl -sk -o /dev/null "https://${BOOKINFO_HOST}/productpage"
done
```

### Test script — Day-2 / golden path

```bash
export KUBECONFIG=~/ocp.yaml

# Control plane health
oc get istio,ztunnel -n istio-system
oc get pods -n istio-system -l 'app in (istiod,ztunnel)'
oc logs -n istio-system -l app=ztunnel --tail=20 | grep -iE 'error|warn|BadSignature|impersonat' || true
oc get deploy -n istio-system -l app=istiod -o jsonpath='{range .items[*].spec.template.spec.containers[0].env[?(@.name=="CA_TRUSTED_NODE_ACCOUNTS")]}CA_TRUSTED={.value}{"\n"}{end}'

# Golden-path enrolment (pilot namespace)
oc get ns bookinfo --show-labels
oc get authorizationpolicy -A

# Mesh CA validity (risk discussion)
oc get configmap istio-ca-root-cert -n istio-system -o jsonpath='{.data.root-cert\.pem}' \
  | openssl x509 -noout -dates 2>/dev/null
```

### Detailed command reference (optional)

| Day 6 sub-topic              | What to verify                       | Pre-workshop command                                                                                                                                                                    | Healthy signal                                                  |
| ---------------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| **Control plane health**     | istiod and ztunnel running           | `oc get istio,ztunnel -n istio-system`                                                                                                                                                  | `state: Healthy` / `READY True`                                 |
| **Control plane pods**       | No crash loops                       | `oc get pods -n istio-system -l 'app in (istiod,ztunnel)'`                                                                                                                              | All `Running`, `READY` matches desired                          |
| **ztunnel → istiod trust**   | No CA / impersonation errors         | `oc logs -n istio-system -l app=ztunnel --tail=20 | grep -iE 'error|warn|BadSignature|impersonat'`                                                                                      | No repeated errors (empty or info only)                         |
| **istiod trusted ztunnel**   | Correct SA namespace                 | `oc get deploy -n istio-system -l app=istiod -o jsonpath='{range .items[*].spec.template.spec.containers[0].env[?(@.name=="CA_TRUSTED_NODE_ACCOUNTS")]}CA_TRUSTED={.value}{"\n"}{end}'` | `istio-system/ztunnel` (not `kube-system/ztunnel`)              |
| **Mesh CA bundle**           | Root cert in sync                    | `oc get configmap istio-ca-root-cert -n istio-system -o jsonpath='{.data.root-cert\.pem}' | openssl x509 -noout -dates 2>/dev/null`                                                     | Valid dates; matches `cacerts` secret                           |
| **User workload monitoring** | Prometheus scrapes mesh metrics      | `oc get configmap cluster-monitoring-config -n openshift-monitoring -o yaml | grep enableUserWorkload`                                                                                  | `enableUserWorkload: true`                                      |
| **Metrics scrapers**         | istiod + ztunnel monitors exist      | `oc get servicemonitor,podmonitor -n istio-system`                                                                                                                                      | `istiod-monitor` + `ztunnel-monitor` present                    |
| **Prometheus user-workload** | Scrape pods running                  | `oc get pods -n openshift-user-workload-monitoring -l app.kubernetes.io/name=prometheus`                                                                                                | `Running`                                                       |
| **Kiali**                    | UI reachable                         | `oc get route kiali -n openshift-operators`                                                                                                                                             | Route `Admitted`                                                |
| **Kiali → Prometheus**       | Metrics backend configured           | `oc get kiali kiali -n openshift-operators -o jsonpath='{.spec.external_services.prometheus.url}{"\n"}'`                                                                                | Thanos querier URL (not `prometheus.openshift-operators`)       |
| **Kiali health**             | Prometheus connected                 | `oc logs -n openshift-operators -l app=kiali --tail=30 | grep -i prometheus`                                                                                                            | `Prometheus connected` or no unreachable errors                 |
| **Service graph data**       | Traffic visible (optional)           | Generate traffic to pilot app, then open Kiali → Graph → `bookinfo`                                                                                                                     | Nodes show request rates (after 1–2 min)                        |
| **Tracing**                  | Telemetry CR present                 | `oc get telemetry -A`                                                                                                                                                                   | `enable-prometheus-metrics` or tracing config in `istio-system` |
| **Ingress gateway**          | Shared gateway in place              | `oc get deploy,svc istio-ingressgateway -n istio-system`                                                                                                                                | Deployment `Available`; Service has ports 80/443                |
| **Pilot app route**          | North-south path works               | `curl -sk -o /dev/null -w "%{http_code}\n" https://<bookinfo-route>/productpage`                                                                                                        | `200`                                                           |
| **Ambient enrolment**        | Pilot namespace labelled             | `oc get ns bookinfo --show-labels | grep dataplane-mode=ambient`                                                                                                                        | Label present                                                   |
| **Golden-path labels**       | Enrolment labels documented          | `oc get ns bookinfo -o jsonpath='{.metadata.labels}' | tr ',' '\n'`                                                                                                                     | `istio-discovery=enabled`, `istio.io/dataplane-mode=ambient`    |
| **AuthZ policies**           | Baseline policies exist (if applied) | `oc get authorizationpolicy -A`                                                                                                                                                         | List matches design discussion                                  |
| **GitOps / policies**        | Mesh config in Git (if used)         | `oc get applications.argoproj.io -n openshift-gitops | grep -i mesh`                                                                                                                    | Argo CD app present (adjust name to env)                        |
| **Splunk prep**              | Log fields to discuss                | `oc logs -n istio-system -l app=ztunnel --tail=5`                                                                                                                                       | Sample log lines for evidence-map conversation                  |


### Optional — generate traffic for Kiali graph

```bash
# Replace with your bookinfo route host
for i in $(seq 1 20); do
  curl -sk -o /dev/null https://istio-ingressgateway-bookinfo.apps.<cluster-domain>/productpage
done
```

### Optional — quick Kiali API check

```bash
TOKEN=$(oc whoami -t)
KIALI=$(oc get route kiali -n openshift-operators -o jsonpath='{.spec.host}')
curl -sk -o /dev/null -w "Kiali API: %{http_code}\n" \
  -H "Authorization: Bearer $TOKEN" \
  "https://${KIALI}/api/status"
```

---

## How the three days connect

```
Day 3 (foundation)     Day 4              Day 5                 Day 6
─────────────────     ─────              ─────                 ─────
Topology              WHO services       HOW they connect      HOW we run
Rollout               are + WHO they     (waypoint, ingress,   + prove it
mTLS / PKI            may talk to        Prod bar)             + hand off
Ingress / egress      + governance
```

---

## Miro — three frames + shared


| Frame                                         | Colour | Content                                 |
| --------------------------------------------- | ------ | --------------------------------------- |
| `SM · DECIDED`                                | Green  | Ambient, mTLS, waypoint, shared gateway |
| `SM-D4 · Security & access design`            | Blue   | Day 4 activities + checklist            |
| `SM-D5 · Connectivity & production readiness` | Blue   | Day 5 activities + checklist            |
| `SM-D6 · Operations & assurance`              | Blue   | Day 6 activities + checklist            |
| `SM · Decision log`                           | White  | All days                                |
| `SM · Parking lot`                            | Grey   | Phase 2 items                           |


---

## One sticky per day (for board header)

```
DAY 4 | Security & access design | Identity, trust, AuthZ, governance
DAY 5 | Connectivity & production readiness | Waypoint, ingress, Prod bar, compliance
DAY 6 | Operations & assurance | Observe, audit, Day-2, golden path, close-out
```

---

## Acme invite (one paragraph)

> Days 4–6 are structured as three design themes: **security & access** (identity and policy), **connectivity & production readiness** (waypoint, ingress, Prod standards), and **operations & assurance** (observability, audit, day-to-day ownership). Each day produces a named deliverable pack and decision checklist. Technical reference from the PoC is available if needed; sessions are collaborative design workshops across Platform, Application, and Security teams.

---

## Optional reference

Detailed sub-topic mapping from the original 7-day plan is absorbed as follows:


| Original topics                                                   | Now on    |
| ----------------------------------------------------------------- | --------- |
| Trust domain, SPIFFE, AuthZ, governance                           | **Day 4** |
| Waypoint, traffic, ingress detail, Prod/compliance, multi-cluster | **Day 5** |
| Observability, Splunk, Day-2, golden path, risks, close-out       | **Day 6** |


Day 3 (acme schedule) retains: topology, rollout, mTLS, PKI, ingress, egress foundations.