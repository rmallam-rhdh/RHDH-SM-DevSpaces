#!/usr/bin/env python3
"""Create Jenkins GitHub Organization folder demo scanning rmallam/node* quarkus* *web*.

Does not print credentials. Uses JENKINS_USER / JENKINS_PASSWORD (demo: admin/password)
and optional GITHUB_PAT for higher GitHub API limits.
"""
from __future__ import annotations

import base64
import json
import os
import ssl
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

CTX = ssl._create_unverified_context()
HERE = Path(__file__).resolve().parent
BASE = os.environ.get(
    "JENKINS_URL",
    "https://jenkins-jenkins.apps.rosa.rosa-89s85.bhg0.p3.openshiftapps.com",
)
USER = os.environ.get("JENKINS_USER", "admin")
PASSWORD = os.environ.get("JENKINS_PASSWORD", "password")
CRED_ID = "github-rmallam"


def http(method: str, path: str, data=None, content_type: str | None = None):
    hdrs = {
        "Authorization": "Basic "
        + base64.b64encode(f"{USER}:{PASSWORD}".encode()).decode()
    }
    body = None
    if data is not None:
        body = data if isinstance(data, bytes) else data.encode()
        if content_type:
            hdrs["Content-Type"] = content_type
    req = urllib.request.Request(BASE + path, data=body, headers=hdrs, method=method)
    try:
        with urllib.request.urlopen(req, context=CTX, timeout=90) as resp:
            return resp.status, resp.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()


def ensure_github_cred(pat: str) -> None:
    code, raw = http(
        "GET",
        "/credentials/store/system/domain/_/api/json?tree=credentials[id]",
    )
    ids = []
    if code == 200:
        ids = [c.get("id") for c in json.loads(raw).get("credentials") or []]
    if CRED_ID in ids:
        print("credential github-rmallam already present")
        return
    payload = json.dumps(
        {
            "": "0",
            "credentials": {
                "scope": "GLOBAL",
                "id": CRED_ID,
                "username": "rmallam",
                "password": pat,
                "description": "GitHub PAT for rmallam/node* org scan",
                "stapler-class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl",
                "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl",
            },
        }
    )
    body = urllib.parse.urlencode({"json": payload}).encode()
    code, raw = http(
        "POST",
        "/credentials/store/system/domain/_/createCredentials",
        data=body,
        content_type="application/x-www-form-urlencoded",
    )
    if code not in (200, 302, 303, 204):
        raise SystemExit(f"create credential failed {code}: {raw[:300]!r}")
    print("created credential github-rmallam")


def ensure_org_folder(credentials_id: str = "") -> None:
    xml = (HERE / "jenkins-github-org.xml").read_text()
    xml = xml.replace(
        "<credentialsId></credentialsId>",
        f"<credentialsId>{credentials_id}</credentialsId>",
    )
    code, _raw = http("GET", "/job/demo/api/json")
    if code == 200:
        print("job demo exists — updating config")
        code, raw = http(
            "POST",
            "/job/demo/config.xml",
            data=xml,
            content_type="application/xml;charset=UTF-8",
        )
        if code not in (200, 204):
            raise SystemExit(f"update demo folder failed {code}: {raw[:400]!r}")
        return
    code, raw = http(
        "POST",
        "/createItem?name=demo",
        data=xml,
        content_type="application/xml;charset=UTF-8",
    )
    if code not in (200, 204):
        raise SystemExit(f"create demo folder failed {code}: {raw[:400]!r}")
    print("created organization folder demo")


def scan_and_wait() -> None:
    code, raw = http("POST", "/job/demo/build")
    if code not in (200, 201, 302, 303, 204):
        raise SystemExit(f"scan trigger failed {code}: {raw[:300]!r}")
    print("triggered organization scan")
    deadline = time.time() + 180
    while time.time() < deadline:
        code, raw = http(
            "GET",
            "/job/demo/api/json?tree=jobs[name,url,_class],scanAllRepositoriesLog[url]",
        )
        if code == 200:
            jobs = json.loads(raw).get("jobs") or []
            names = [j.get("name") for j in jobs]
            print("discovered", names or "(none yet)")
            if "nodejstest" in names:
                http("POST", "/job/demo/job/nodejstest/build")
                print("triggered nodejstest branch indexing")
                return
        time.sleep(8)
    raise SystemExit("timed out waiting for demo/nodejstest (scan rmallam/node*)")


def main() -> None:
    code, raw = http("GET", "/whoAmI/api/json")
    if code != 200:
        raise SystemExit(f"jenkins auth failed {code}")
    me = json.loads(raw)
    if me.get("anonymous"):
        raise SystemExit("jenkins still anonymous")
    print("jenkins user", me.get("name"))
    # Public github.com/rmallam-rhdh/node* can scan without a PAT. Set GITHUB_PAT to
    # raise API limits / see private repos.
    pat = os.environ.get("GITHUB_PAT", "").strip()
    cred_id = ""
    if pat:
        ensure_github_cred(pat)
        cred_id = CRED_ID
    else:
        print("no GITHUB_PAT — scanning public repos anonymously")
    ensure_org_folder(cred_id)
    scan_and_wait()
    print(
        "Jenkins org folder: "
        f"{BASE}/job/demo/"
    )
    print(
        "Expected job URL: "
        f"{BASE}/job/demo/job/nodejstest/"
    )


if __name__ == "__main__":
    main()
