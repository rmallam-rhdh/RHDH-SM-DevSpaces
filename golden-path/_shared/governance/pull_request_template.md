## Summary

<!-- What does this PR do? Link the Jira story -->

**Jira:** [ACME-XXXX](https://jira.example.com/browse/ACME-XXXX)

## Type of change

- [ ] Feature
- [ ] Bug fix
- [ ] Refactor / tech debt
- [ ] Platform / config only

## Testing

- [ ] Unit tests pass locally (`./scripts/quality-gate.sh`)
- [ ] Lint passes (`./scripts/quality-gate.sh --lint-only`)
- [ ] Manual / integration testing done (describe below)

**Test notes:**

## Security & quality (CI will verify)

- [ ] SonarQube quality gate — must be green on this PR
- [ ] Snyk — no new high/critical issues (or documented exception)
- [ ] No secrets, credentials, or `.env` files committed
- [ ] OpenAPI / contract updated if API surface changed

## Deployment

- [ ] Safe to deploy to SysT on merge
- [ ] Mesh / GitOps manifests updated if needed
- [ ] Database migration or backward compatibility considered

## Reviewer checklist

- [ ] Code follows team / golden-path conventions
- [ ] Appropriate test coverage for the change
- [ ] Logging and error handling are appropriate (no sensitive data in logs)
