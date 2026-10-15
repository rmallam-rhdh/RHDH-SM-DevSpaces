# Jira

**Status:** working (Jira Cloud project `SCRUM`)

Jira **tab** on the Component (`/jira`), keyed by `jira/project-key`. Demo Hub talks to `https://mallamrakeshkumar.atlassian.net` with Cloud Basic auth (`email:apiToken`). Do not set `jira/component` unless that component exists on the project. The Roadie card is not a default RHDH tab until `entityTabs` mounts `entity.page.jira`.

## Required

| Layer | What |
|---|---|
| Helm | `plugins.jira.enabled: true`, `product: cloud` |
| Package | `roadiehq-backstage-plugin-jira` OCI |
| App-config | `jira.baseUrl`, `token` + proxy `/jira/api` with `Authorization: Basic …` |
| Catalog | `jira/project-key: SCRUM` |

## Secrets

`JIRA_BASE_URL`, `JIRA_TOKEN`

`JIRA_TOKEN` for Cloud is the full header value `Basic <base64(email:apiToken)>`, not a Bearer token. Vault key `secrets/rhdh/jira-token`.

## Known issues

| When | Error | Fix |
|---|---|---|
| 2026-10-09 | No Jira tab | Card was on Overview only. Chart now adds `entityTabs` `/jira` like ServiceNow. |
| 2026-10-09 | Cloud 401 with `Authorization: Bearer` | Chart now lets `plugins.jira.authorization` replace the Bearer prefix. Demo sets it to `${JIRA_TOKEN}` (Basic). |
