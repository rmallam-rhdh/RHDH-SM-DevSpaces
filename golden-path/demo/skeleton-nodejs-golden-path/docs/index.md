# ${{ values.appName }}

${{ values.appDescription }}

## Pipeline

Jenkinsfile stages: **Install → Lint → Unit tests → SonarQube → Helm lint**.

Point a Jenkins job named `demo/${{ values.appName }}` at this repo. Set credential `SONAR_TOKEN` to run the scanner against `${{ values.sonarHostUrl }}`.

## Deploy

North-south is **OpenShift Route → Gateway API Gateway → HTTPRoute → app** (the Route targets `istio-ingressgateway`, not this Service). No VirtualService. AuthZ in this chart is **deny-all** plus ALLOW from the ingress gateway. **STRICT mTLS** is namespace-wide (`PeerAuthentication`), created by Kyverno when the namespace is enrolled — not a per-service object.

```bash
oc label namespace ${{ values.targetNamespace }} acme.io/mesh-enroll=true istio.io/dataplane-mode=ambient --overwrite
helm upgrade --install ${{ values.appName }} chart -n ${{ values.targetNamespace }}
```

Ingress: `https://${{ values.appName }}-${{ values.targetNamespace }}.${{ values.clusterBaseDomain }}`

The chart labels pods `backstage.io/kubernetes-id=${{ values.appName }}` for Topology.

## Dev Spaces

${{ values.devSpacesBaseUrl }}#https://github.com/${{ values.githubOwner }}/${{ values.appName }}?new&devfilePath=devfile.yaml
