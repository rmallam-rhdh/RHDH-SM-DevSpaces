#!/usr/bin/env bash
# Unit: GitHub org folder XML scans rmallam-rhdh/node* and Jenkinsfile.
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
F="$DIR/jenkins-github-org.xml"
S="$DIR/jenkins-github-org.py"
fail=0
need() {
  if grep -Fq "$1" "$2"; then
    echo "OK  $1"
  else
    echo "FAIL missing $1 in $2"
    fail=1
  fi
}
need "jenkins.branch.OrganizationFolder" "$F"
need "<repoOwner>rmallam-rhdh</repoOwner>" "$F"
need "<includes>node* quarkus* *web*</includes>" "$F"
need "<scriptPath>Jenkinsfile</scriptPath>" "$F"
need "<credentialsId></credentialsId>" "$F"
need "GitHubSCMNavigator" "$F"
need "OriginPullRequestDiscoveryTrait" "$F"
need "createItem?name=demo" "$S"
need "job/demo/job/nodejstest" "$S"
if [ "$fail" -ne 0 ]; then
  echo "Jenkins GitHub org tests failed"
  exit 1
fi
echo "Jenkins GitHub org tests passed"
