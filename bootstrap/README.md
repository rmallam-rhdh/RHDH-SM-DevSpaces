# Bring up a cluster

OpenShift GitOps must already be running (`openshift-gitops` namespace). Then two Applications, in order.

```bash
# 1) Day-1 — operators + Jenkins/Vault/Sonar/LDAP/stubs
oc apply -f bootstrap/root-app.yaml
# wait until rhdh, servicemeshoperator3, kiali-ossm, devspaces, cloudnative-pg CSVs are Succeeded

# 2) Fill Secret rhdh-secrets (copy from rhdh-platform-gitops/examples/rhdh-secrets.example.yaml)
oc -n rhdh apply -f rhdh-secrets.yaml

# 3) Day-2 — Backstage, Istio, CheCluster, CNPG Cluster
# In rhdh-platform-gitops set charts/developer-hub/values-deploy.yaml
# app.clusterBaseDomain to this cluster's *.apps domain, then:
oc apply -f argocd/app-of-apps.yaml
```

Do not apply `argocd/apps` from `rmallam/RHDH`. That repo is not this cluster's GitOps source.

Entra app `rhdh-login` redirect (Azure, not GitOps):

`https://backstage-developer-hub-rhdh.<clusterBaseDomain>/api/auth/microsoft/handler/frame`

Squid is day-2 (`rhdh-platform-gitops/argocd/apps/squid.yaml`). Apply Secret `squid-htpasswd` before that Application is Ready; Hub uses it when `httpProxy.enabled` is true.
