# Kubernetes namespace catalog

Resources in `namespaces/` populate the **EntityPicker** dropdown in golden-path scaffolder forms.

## Conventions

| Field | Purpose |
|-------|---------|
| `metadata.name` | Must match the **OpenShift namespace name** on that cluster |
| `spec.type` | Always `kubernetes-namespace` |
| `metadata.annotations.acme.io/cluster` | `nonprod-dc1` or `nonprod-dc2` — filters the picker after DC selection |
| `metadata.annotations.acme.io/environment` | `dev` or `prod` — separates dev vs pre-prod pickers |
| `spec.owner` | Catalog group — controls who can see the namespace in RHDH |

## Adding a namespace

1. Provision the namespace on the target OpenShift cluster (GitOps / platform ticket).
2. Add a YAML file under `namespaces/`.
3. Register it in `location.yaml`.
4. RHDH catalog refresh picks it up — appears in the template form.

## Example entity name

`nonprod-dc1-payments-dev` → OpenShift namespace `nonprod-dc1-payments-dev` on Non-Prod DC-1.
