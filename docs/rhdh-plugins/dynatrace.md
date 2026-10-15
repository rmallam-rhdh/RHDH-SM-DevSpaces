# Dynatrace

**Status:** working (classic API token; DQL still needs OAuth)

Community plugin card uses proxy `/dynatrace` → `https://<env>.live.dynatrace.com/api/v2` with `Authorization: Api-Token`. DQL cards still need an OAuth client (`clientId` / `clientSecret` / `accountUrn`).

## Required

| Layer | What |
|---|---|
| Helm | `plugins.dynatrace.enabled: true` |
| Packages | community dynatrace + DQL frontend/backend OCI |
| App-config | proxy `/dynatrace` when `apiTarget` is set |
| pluginConfig | `dynatrace.environments[]` url, tokenUrl, clientId/secret, accountUrn |
| Catalog | `dynatrace.com/dynatrace-entity-id` (`SERVICE-…`) |

## Secrets

`DYNATRACE_URL`, `DYNATRACE_ACCESS_TOKEN`, plus OAuth `DYNATRACE_CLIENT_ID` / `DYNATRACE_CLIENT_SECRET` / `DYNATRACE_ACCOUNT_URN` for DQL.

Demo: `https://wkf10640.apps.dynatrace.com`. Classic API host is `https://wkf10640.live.dynatrace.com/api/v2`. Kitchen-sink: `SERVICE-39720C1E0047A5C0` (`astroshop-frontend`). Tab path `/dynatrace`.

## Known issues

| When | Error | Fix |
|---|---|---|
| 2026-10-09 | `403 Token is missing required scope` | New classic token with `entities.read` + `problems.read` now works. |
| — | DQL empty / OAuth fail | Create a Dynatrace OAuth client; DQL does not accept the classic `dt0c01` token |
