#!/usr/bin/env python3
"""Put Jira Cloud Basic + Dynatrace classic token into Vault. Never prints secret values."""
from __future__ import annotations

import argparse
import base64
import json
import os
import re
import ssl
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

CTX = ssl._create_unverified_context()

JIRA_EMAIL = "mallamrakeshkumar@gmail.com"
JIRA_BASE = "https://mallamrakeshkumar.atlassian.net"
DT_APPS = "https://wkf10640.apps.dynatrace.com"
DT_LIVE = "https://wkf10640.live.dynatrace.com"
DEFAULT_KEY_FILE = Path.home() / "Desktop" / "Jira key.md"
VAULT_HOST = "vault-vault.apps.rosa.rosa-89s85.bhg0.p3.openshiftapps.com"

JIRA_TOKEN_RE = re.compile(r"ATATT[A-Za-z0-9_\-=]+")
DT_TOKEN_RE = re.compile(r"dt0[cs]01\.[A-Za-z0-9]+\.[A-Za-z0-9]+")


def parse_key_file(text: str) -> tuple[str, str]:
    jira = JIRA_TOKEN_RE.findall(text)
    dyn = DT_TOKEN_RE.findall(text)
    if not jira:
        raise ValueError("no Jira ATATT token in key file")
    if not dyn:
        raise ValueError("no Dynatrace dt0c01 token in key file")
    return jira[0], dyn[0]


def jira_basic_header(email: str, api_token: str) -> str:
    raw = base64.b64encode(f"{email}:{api_token}".encode()).decode()
    return f"Basic {raw}"


def http(url: str, headers: dict[str, str], method: str = "GET", data: bytes | None = None):
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, context=CTX, timeout=20) as resp:
            return resp.status, resp.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()


def check_jira(basic: str) -> None:
    status, raw = http(
        f"{JIRA_BASE}/rest/api/3/project/SCRUM",
        {"Authorization": basic, "Accept": "application/json"},
    )
    if status != 200:
        raise SystemExit(f"jira project SCRUM HTTP {status}")
    status, _raw = http(
        f"{JIRA_BASE}/rest/api/3/search/jql?jql=project%3DSCRUM&maxResults=1",
        {"Authorization": basic, "Accept": "application/json"},
    )
    if status != 200:
        raise SystemExit(f"jira search HTTP {status}")
    print("jira cloud SCRUM ok")


def check_dynatrace(token: str) -> str:
    status, raw = http(
        f"{DT_LIVE}/api/v2/entities?pageSize=5&entitySelector=type(%22SERVICE%22)",
        {"Authorization": f"Api-Token {token}", "Accept": "application/json"},
    )
    if status == 403:
        print("dynatrace token missing entities.read/problems.read — proxy will 403 until recreated")
        return ""
    if status != 200:
        print(f"dynatrace entities HTTP {status}")
        return ""
    try:
        ents = json.loads(raw).get("entities") or []
    except json.JSONDecodeError:
        return ""
    if not ents:
        print("dynatrace has no SERVICE entities yet")
        return ""
    entity_id = ents[0].get("entityId") or ""
    print(f"dynatrace service {entity_id}")
    return entity_id


def vault_put(token: str, suffix: str, value: str) -> None:
    url = f"https://{VAULT_HOST}/v1/secrets/data/rhdh/{suffix}"
    body = json.dumps({"data": {"value": value}}).encode()
    status, raw = http(
        url,
        {"Content-Type": "application/json", "X-Vault-Token": token},
        method="POST",
        data=body,
    )
    if status not in (200, 204):
        raise SystemExit(f"vault put {suffix} HTTP {status}")


def oc_vault_token() -> str:
    raw = subprocess.check_output(
        ["oc", "-n", "vault", "get", "secret", "vault-root", "-o", "jsonpath={.data.token}"],
        text=True,
    ).strip()
    return base64.b64decode(raw).decode()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--key-file", default=str(DEFAULT_KEY_FILE))
    parser.add_argument("--email", default=JIRA_EMAIL)
    parser.add_argument("--apply", action="store_true", help="write Vault (needs oc)")
    args = parser.parse_args()

    text = Path(args.key_file).read_text()
    jira_tok, dt_tok = parse_key_file(text)
    basic = jira_basic_header(args.email, jira_tok)
    check_jira(basic)
    check_dynatrace(dt_tok)

    if not args.apply:
        print("checked only (pass --apply after oc login to write Vault)")
        return 0

    vault_token = os.environ.get("VAULT_TOKEN") or oc_vault_token()
    vault_put(vault_token, "jira-base-url", JIRA_BASE)
    vault_put(vault_token, "jira-token", basic)
    vault_put(vault_token, "dynatrace-url", DT_APPS)
    vault_put(vault_token, "dynatrace-access-token", dt_tok)
    print("vault jira + dynatrace keys written")
    return 0


if __name__ == "__main__":
    sys.exit(main())
