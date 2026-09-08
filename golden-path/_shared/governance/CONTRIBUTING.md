# Contributing

## Git hooks (required for golden-path repos)

After cloning, install hooks once:

```bash
./scripts/install-git-hooks.sh
```

| Hook | Runs |
|------|------|
| **pre-commit** | Trailing whitespace, private-key check, `quality-gate.sh --lint-only` |
| **pre-push** | Unit tests via `quality-gate.sh` |

PR merge still requires **SonarQube** and **Snyk** on the Bitbucket/Jenkins pipeline — hooks are shift-left feedback, not the only gate.

Emergency bypass (discouraged): `git commit --no-verify`

## Pull requests

Use the PR template (auto-filled from `pull_request_template.md` on Bitbucket Cloud, or `.bitbucket/pullrequest/default.md` on Bitbucket Server).

## OpenShift Dev Spaces

Open `devfile.yaml` from the RHDH catalog link or run **quality-gate** from the Dev Spaces command palette.

| Archetype | Build / test in workspace |
|-----------|---------------------------|
| **Spring Boot** | `./gradlew test`, `./gradlew bootRun`, `quality-gate.sh` |
| **Node.js** | `npm test`, `npm run dev`, `quality-gate.sh` |
