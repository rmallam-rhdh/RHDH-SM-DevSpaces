# Service Mesh Discovery — Workshop Schedule (Miro-ready)

**Platform:** OpenShift · **Product:** Red Hat OpenShift Service Mesh (OSSM 3)  
**Format:** 5 sessions × 2 hours (10 hours total)  
**Excludes:** ACS implementation (review-only if needed separately)

---

## Architecture decisions — LOCKED (do not re-debate in workshop)

Copy this block to Miro as a **green “Decided”** frame.

| Decision | Choice | What it means (simple) |
|---|---|---|
| **Mesh mode** | **Ambient** | Encryption via **ztunnel** on each node — no sidecar in every app pod |
| **Encryption** | **mTLS** | Service-to-service traffic is encrypted and identity-based |
| **L7 policy** | **Waypoint** | HTTP-level rules (paths, JWT, fine access) via waypoint proxy where needed |
| **Control plane** | **OSSM 3 / Sail Operator** | istiod + ztunnel in `istio-system`; ambient enrolment by namespace label |
| **Ingress pattern** | **One shared gateway** | Single `istio-ingressgateway` in `istio-system`; apps use Gateway + VirtualService |

**Traffic flow (reference diagram for Miro):**

```
Browser → OpenShift Route → Ingress Gateway → VirtualService → Waypoint (if L7) → App
                                                              ↘ ztunnel (mTLS) ↗
```

---

## Still to decide in discovery

Copy to Miro as an **amber “Open”** frame.

| # | Topic | Decision needed |
|---|---|---|
| 1 | Phase 1 scope | Which namespaces / apps enrol first |
| 2 | Trust domain | Per environment vs per cluster (InfoSec) |
| 3 | AuthZ default | Deny-all yes/no; platform vs team ownership |
| 4 | Waypoint scope | Which namespaces get a waypoint in Phase 1 (not all) |
| 5 | Ingress TLS | Edge termination vs passthrough; corporate CA on Route or gateway |
| 6 | Mesh PKI | Self-signed in Non-Prod vs bank CA from day one |
| 7 | Egress | Open / allowlist / PCI-locked |
| 8 | Observability | Kiali, Prometheus, tracing backend |
| 9 | Splunk | Which mesh events, index, retention |
| 10 | Day-2 model | Who upgrades mesh, who writes policies, on-call |

---

## Session schedule — copy each row to a Miro card

### Session 1 — Where we are and what we’re rolling out (2 h)

**Attendees:** Platform lead, networking, app tech lead  
**Miro frame title:** `SM-D1 · Current state & Phase 1 scope`

| Time | Topic | Plain question | Decision / output |
|---|---|---|---|
| 0:00–0:10 | Kick-off | What does “done” look like for discovery? | Agreed outcomes list |
| 0:10–0:40 | Current state | What mesh exists today? Version, enrolled namespaces, pain points | Current-state map |
| 0:40–1:10 | Namespace model | Who owns namespaces? Shared vs per-team? | Tenancy sketch |
| 1:10–1:40 | Ambient enrolment | How do namespaces join the mesh? Auto (Kyverno) or manual? Exclusions? | Enrolment rule |
| 1:40–2:00 | Phase 1 scope | Which apps/namespaces in E-Dev / Non-Prod first? Pilot app? | Phase 1 list + pilot |

---

### Session 2 — Security foundations (2 h)

**Attendees:** Platform, InfoSec, identity (if involved)  
**Miro frame title:** `SM-D2 · mTLS, identity & trust`

| Time | Topic | Plain question | Decision / output |
|---|---|---|---|
| 0:00–0:10 | Recap | Confirm Session 1 decisions | Open items list |
| 0:10–0:35 | mTLS rollout | PERMISSIVE → STRICT: when and where? Prod always STRICT? | mTLS migration plan |
| 0:35–1:00 | Trust domain | One trust domain per env or per cluster? Non-Prod ↔ Prod sharing allowed? | Trust domain matrix |
| 1:00–1:25 | Service identity | One ServiceAccount per service? No shared `default` SA? | SA naming standard |
| 1:25–1:50 | Tenancy | Hard deny-all between namespaces, or soft/hybrid? | Tenancy model |
| 1:50–2:00 | Wrap-up | InfoSec sign-off items | Actions + owners |

**Note:** mTLS is **locked** — this session is **how** we roll it out, not **if**.

---

### Session 3 — Traffic in and out + certificates (2 h)

**Attendees:** Platform, InfoSec/PKI, networking, app owners (external APIs)  
**Miro frame title:** `SM-D3 · Ingress, egress & PKI`

| Time | Topic | Plain question | Decision / output |
|---|---|---|---|
| 0:00–0:10 | Recap | Confirm Session 2 decisions | Open items list |
| 0:10–0:40 | Ingress | Routes + shared gateway? Where does TLS terminate? Public hostname pattern? | Ingress diagram |
| 0:40–1:10 | Certificates (public) | Corporate CA on Route or gateway? Wildcard vs per-app certs? | Public TLS approach |
| 1:10–1:40 | Certificates (mesh) | Bank CA for mesh mTLS or self-signed in Non-Prod first? Who rotates? | Mesh PKI approach |
| 1:40–2:00 | Egress | Must outbound traffic be allowlisted? PCI zones? | Egress policy level |

---

### Session 4 — Access rules and governance (2 h)

**Attendees:** Platform, InfoSec, SecOps, app architects  
**Miro frame title:** `SM-D4 · AuthZ, blast radius & governance`

| Time | Topic | Plain question | Decision / output |
|---|---|---|---|
| 0:00–0:10 | Recap | Confirm Session 3 decisions | Open items list |
| 0:10–0:40 | Access rules | Deny-all default? Platform baseline + team extensions? Kyverno templates? | AuthZ ownership model |
| 0:40–1:10 | Blast radius | If frontend / API / batch job is hacked — what can it reach? Acceptable? | Blast-radius diagram |
| 1:10–1:40 | Waypoint scope | Which namespaces need waypoint in Phase 1? (path/JWT rules) | Waypoint namespace list |
| 1:40–2:00 | Governance | GitOps-only policy changes? Emergency process? Splunk audit? | Governance RACI |

**Note:** Waypoint is **locked** as the L7 mechanism — this session decides **where**, not **if**.

---

### Session 5 — Operate, observe, close-out (2 h)

**Attendees:** Platform, observability/Splunk owners, SecOps, delivery sponsor (last 30 min)  
**Miro frame title:** `SM-D5 · Observability, Day-2 & close-out`

| Time | Topic | Plain question | Decision / output |
|---|---|---|---|
| 0:00–0:10 | Recap | Sessions 1–4 decision summary | Conflict check |
| 0:10–0:35 | Observability | Kiali for whom? Tracing backend? Prometheus/Grafana mesh dashboards? | Observability target |
| 0:35–1:00 | Splunk | Access logs, AuthZ DENY, mTLS failures, policy changes — which events? Index? Retention? | Splunk event catalogue |
| 1:00–1:25 | Day-2 | Who upgrades istiod/ztunnel/waypoint? Who writes AuthZ? On-call? Golden-path auto-enrol? | Operating model RACI |
| 1:25–1:45 | Traffic (Phase 1) | Canary/retries needed now or later? Prove what in Non-Prod first? | Phase 1 traffic backlog |
| 1:45–2:00 | Risks & close | Top risks + mitigations; open questions with owners and dates | Risk register + decision log |

**Optional backlog (not Phase 1 unless acme insists):** multi-cluster mesh, full canary/Flagger, compliance deep-dive workshop.

---

## Miro board layout — suggested frames

Copy frame titles exactly for consistency.

| Frame # | Frame title | Colour | Content |
|---|---|---|---|
| 0 | `SM · Architecture DECIDED` | Green | Locked decisions table (top of doc) |
| 1 | `SM · Still OPEN` | Amber | Open decisions checklist |
| 2 | `SM-D1 · Current state & Phase 1 scope` | Blue | Session 1 table |
| 3 | `SM-D2 · mTLS, identity & trust` | Blue | Session 2 table |
| 4 | `SM-D3 · Ingress, egress & PKI` | Blue | Session 3 table |
| 5 | `SM-D4 · AuthZ, blast radius & governance` | Blue | Session 4 table |
| 6 | `SM-D5 · Observability, Day-2 & close-out` | Blue | Session 5 table |
| 7 | `SM · Decision log` | White | Decision \| Rationale \| Owner \| Date |
| 8 | `SM · Parking lot` | Grey | Items deferred to design / Phase 2 |

---

## Sticky templates for Miro (one sticky per line)

**Decision sticky:**
```
DECISION: [topic]
Choice: [what was agreed]
Owner: [name/team]
Date: [YYYY-MM-DD]
```

**Open item sticky:**
```
OPEN: [topic]
Question: [plain English]
Owner: [who will answer]
Due: [date]
```

**Risk sticky:**
```
RISK: [short name]
Impact: H/M/L
Mitigation: [action]
Owner: [team]
```

---

## Mapping — old 7-day plan → new 5-session plan

| Old day | Old topic | New session |
|---|---|---|
| Day 1 | Current state, drivers | Session 1 |
| Day 2 | Namespaces, enrolment, rollout | Session 1 |
| Day 3 | mTLS, trust domain, SPIFFE | Session 2 |
| Day 4 | PKI, ingress, egress | Session 3 |
| Day 5 | AuthZ, lateral movement, governance | Session 4 |
| Day 6 | Waypoint, traffic, multi-cluster | Session 4 (waypoint) + Session 5 (traffic backlog) |
| Day 7 | Observability, Splunk, Day-2, risks | Session 5 |

**Removed from core path (parking lot):** multi-cluster federation, deep compliance workshop, extended canary/Flagger design.

---

## Outcomes at end of discovery

| Deliverable | Description |
|---|---|
| Architecture baseline | Ambient + mTLS + waypoint (locked) |
| Phase 1 scope | Namespaces, pilot app, enrolment rules |
| Security baseline | Trust domain, SA standard, AuthZ model, waypoint list |
| Traffic model | Ingress, egress, PKI (public + mesh) |
| Operating model | Ownership, upgrades, golden-path enrolment |
| Observability | Kiali/Prometheus/tracing + Splunk events |
| Risk register | Top risks with mitigations and owners |
| Decision log | All open items closed or assigned with dates |

---

## Facilitator note

- Do **not** reopen ambient vs sidecar, mTLS yes/no, or waypoint vs no waypoint.
- If the room goes deep on SPIFFE/PKI internals, park for **design phase**.
- Each session must end with **at least 3 decisions** in the decision log.
- InfoSec must be in **Session 2 and 4** minimum.
