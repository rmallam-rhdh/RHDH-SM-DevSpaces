#!/usr/bin/env bash
# Unit: template + skeleton include Jenkins, Helm, Sonar, tests, Dev Spaces.
# System: render placeholders, npm test, helm lint.
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
need() {
  if grep -Fq "$1" "$2"; then
    echo "OK  $1"
  else
    echo "FAIL missing $1 in $2"
    fail=1
  fi
}

T="$DIR/template-nodejs-golden-path.yaml"
S="$DIR/skeleton-nodejs-golden-path"
need "name: acme-nodejs-golden-path" "$T"
need "title: GitHub repository name" "$T"
need "required: [appName, githubOwner]" "$T"
need "publish:github" "$T"
need "title: GitHub repository" "$T"
need "steps['publish'].output.remoteUrl" "$T"
need "steps['publish'].output.repoContentsUrl" "$T"
need "/dashboard/#/load-factory?url=" "$T"
need "title: Helm chart" "$T"
need "title: Jenkinsfile" "$T"
need "title: OpenShift project" "$T"
need "skeleton-nodejs-golden-path" "$T"
need "template-nodejs-golden-path.yaml" "$DIR/location.yaml"
need "stage('SonarQube')" "$S/Jenkinsfile"
need "stage('Helm lint')" "$S/Jenkinsfile"
need "helm lint chart" "$S/Jenkinsfile"
need "sonar.projectKey" "$S/sonar-project.properties"
need "kind: Deployment" "$S/chart/templates/deployment.yaml"
need "backstage.io/kubernetes-id" "$S/chart/templates/_helpers.tpl"
need "jenkins.io/job-full-name" "$S/catalog-info.yaml"
need "sonarqube.org/project-key" "$S/catalog-info.yaml"
need "jira/project-key: SCRUM" "$S/catalog-info.yaml"
need "servicenow.com/entity-id" "$S/catalog-info.yaml"
need "dynatrace.com/dynatrace-entity-id: SERVICE-39720C1E0047A5C0" "$S/catalog-info.yaml"
need "kiali.io/namespace" "$S/catalog-info.yaml"
need "acme.io/helm-chart" "$S/catalog-info.yaml"
need "acme.io/mesh: ambient" "$S/catalog-info.yaml"
need "acme.io/devspaces-factory-url" "$S/catalog-info.yaml"
need "backstage.io/source-location: url:https://github.com/" "$S/catalog-info.yaml"
need "title: Helm chart" "$S/catalog-info.yaml"
need "title: Jenkins CI" "$S/catalog-info.yaml"
need "defaultContainer 'nodejs'" "$S/Jenkinsfile"
need "kind: AuthorizationPolicy" "$S/chart/templates/authorization-policy.yaml"
need "spec: {}" "$S/chart/templates/authorization-policy.yaml"
need "kind: HTTPRoute" "$S/chart/templates/httproute.yaml"
need "name: platform-ingressgateway" "$S/chart/values.yaml"
need "className: istio" "$S/chart/values.yaml"
need "istio-ingressgateway" "$S/chart/templates/route-mesh-ingress.yaml"
need "gatewayClassName:" "$S/chart/templates/gateway.yaml"
need "mode: Terminate" "$S/chart/templates/gateway.yaml"
need "kind: DestinationRule" "$S/chart/templates/destination-rule.yaml"
need "ISTIO_MUTUAL" "$S/chart/templates/destination-rule.yaml"
need "istio-waypoint" "$S/chart/templates/waypoint.yaml"
need "istio-ingressgateway" "$S/chart/templates/route-mesh-ingress.yaml"
need "termination: passthrough" "$S/chart/templates/route-mesh-ingress.yaml"
need "clusterBaseDomain" "$T"

if grep -q "publish:bitbucket" "$T"; then
  echo "FAIL template publishes to Bitbucket"
  fail=1
fi
if grep -q "/f?url=" "$T"; then
  echo "FAIL template still uses Dev Spaces /f factory path (404 on this cluster)"
  fail=1
fi
if grep -q 'url: https://github.com/\${{ parameters.githubOwner }}' "$T"; then
  echo "FAIL output links must use publish remoteUrl (parameters are empty on this Hub)"
  fail=1
fi
if grep -E "remoteUrl \}\}/(blob|tree)/" "$T"; then
  echo "FAIL file/dir links must use repoContentsUrl (remoteUrl includes .git and 404s on GitHub)"
  fail=1
fi
if grep 'source-location:' "$S/catalog-info.yaml" | grep -q '\.git/'; then
  echo "FAIL source-location must not include .git in the GitHub path"
  fail=1
fi
if [ -f "$S/chart/templates/virtual-service.yaml" ]; then
  echo "FAIL greenfield chart must not ship VirtualService (use HTTPRoute)"
  fail=1
fi
if [ -f "$S/chart/templates/peer-authentication.yaml" ]; then
  echo "FAIL PeerAuthentication is namespace/mesh scoped (Kyverno), not per service"
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "Node.js golden-path template tests failed"
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
python3 - "$S" "$WORKDIR" <<'PY'
import pathlib, shutil, re, sys
src, dst = map(pathlib.Path, sys.argv[1:])
shutil.copytree(src, dst, dirs_exist_ok=True)
vals = {
    "appName": "demo-node-gp",
    "appDescription": "test render",
    "githubOwner": "rmallam-rhdh",
    "port": "3000",
    "targetNamespace": "demo-dev",
    "clusterBaseDomain": "apps.example.test",
    "sonarHostUrl": "http://sonarqube.sonarqube.svc:9000",
    "sonarProjectKey": "demo-node-gp",
    "devSpacesBaseUrl": "https://devspaces.example.test",
}
pat = re.compile(r"\$\{\{\s*values\.(\w+)\s*\}\}")
for p in dst.rglob("*"):
    if p.is_file():
        text = p.read_text()
        p.write_text(pat.sub(lambda m: vals[m.group(1)], text))
print("rendered", dst)
PY

(cd "$WORKDIR" && npm run lint && npm test)
helm lint "$WORKDIR/chart"

MESH="$(mktemp)"
NOMESH="$(mktemp)"
trap 'rm -rf "$WORKDIR"; rm -f "$MESH" "$NOMESH"' EXIT
helm template demo-node-gp "$WORKDIR/chart" -n demo-dev >"$MESH"
helm template demo-node-gp "$WORKDIR/chart" -n demo-dev --set mesh.enabled=false --set route.enabled=true >"$NOMESH"

mesh_need() {
  if grep -q "$1" "$MESH"; then
    echo "OK  mesh render $1"
  else
    echo "FAIL mesh render missing $1"
    fail=1
  fi
}
mesh_need "kind: AuthorizationPolicy"
mesh_need "name: demo-node-gp-deny-all"
mesh_need "name: demo-node-gp-allow-ingress"
mesh_need "cluster.local/ns/istio-system/sa/istio-ingressgateway"
mesh_need "kind: HTTPRoute"
mesh_need "platform-ingressgateway"
mesh_need "kind: Gateway"
mesh_need "gatewayClassName: istio"
mesh_need "mode: Terminate"
mesh_need "istio-ingressgateway-certs"
mesh_need "kind: DestinationRule"
mesh_need "mode: ISTIO_MUTUAL"
mesh_need "gatewayClassName: istio-waypoint"
mesh_need "demo-node-gp-demo-dev.apps.example.test"
mesh_need "name: istio-ingressgateway"
mesh_need "serviceAccountName: demo-node-gp"
mesh_need "sidecar.istio.io/inject: \"false\""
mesh_need "istio.io/dataplane-mode: ambient"
mesh_need "istio.io/use-waypoint:"

if grep -q "kind: VirtualService" "$MESH"; then
  echo "FAIL mesh render must not emit VirtualService; use HTTPRoute"
  fail=1
fi
if grep -q "kind: PeerAuthentication" "$MESH"; then
  echo "FAIL mesh render must not emit PeerAuthentication; it is namespace/mesh scoped"
  fail=1
fi
if grep -A25 "kind: Route" "$MESH" | grep -E -q 'targetPort: http$'; then
  echo "FAIL mesh render still has a Route to the app Service (bypasses ingress gateway)"
  fail=1
fi
if ! awk '/kind: Gateway$/{c=1} c&&/namespace: istio-system/{found=1} END{exit !found}' "$MESH"; then
  echo "FAIL Gateway API Gateway must live in istio-system with the ingressgateway"
  fail=1
fi
if ! grep -A25 "kind: Route" "$MESH" | grep -E -q 'targetPort: https$'; then
  echo "FAIL mesh render missing Route to ingress gateway https"
  fail=1
fi
if ! grep -q "kind: Route" "$NOMESH"; then
  echo "FAIL mesh-off render missing app Route"
  fail=1
fi
if grep -q "kind: AuthorizationPolicy" "$NOMESH"; then
  echo "FAIL mesh-off render still has AuthorizationPolicy"
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "Node.js golden-path mesh helm tests failed"
  exit 1
fi
echo "Node.js golden-path template tests passed"
