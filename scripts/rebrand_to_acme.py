#!/usr/bin/env python3
"""Rebrand client → acme without touching OAuth clientId/clientSecret."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKIP = {"gradle/wrapper"}

REPLACEMENTS = [
    ("https://github.com/client/gitops-platform", "https://github.com/rmallam-rhdh/RHDH-SM-DevSpaces"),
    (
        "https://github.com/client/backstage-templates/blob/main/all-templates.yaml",
        "https://github.com/rmallam-rhdh/RHDH-SM-DevSpaces/blob/main/golden-path/all-templates.yaml",
    ),
    (
        "https://github.com/client/service-catalog/blob/main/all-components.yaml",
        "https://github.com/rmallam-rhdh/RHDH-SM-DevSpaces/blob/main/golden-path/catalog/location.yaml",
    ),
    ("client.io", "acme.io"),
    ("ClientSpace", "AcmeSpace"),
    ("clientspace", "acmespace"),
    ("client-platform", "acme-platform"),
    ("backstage-client", "backstage-acme"),
    ("client-smcp", "acme-smcp"),
    ("client-logo", "acme-logo"),
    ("client-icon", "acme-icon"),
    ("com.client", "com.acme"),
    ("client.example.com", "acme.example.com"),
    ("client-springboot", "acme-springboot"),
    ("client-nodejs", "acme-nodejs"),
    ("client-kubernetes", "acme-kubernetes"),
    ("client-golden-path", "acme-golden-path"),
    ("client-deployer", "acme-deployer"),
    ("client-jenkins", "acme-jenkins"),
    ("client-argocd", "acme-argocd"),
    ("client-sonarqube", "acme-sonarqube"),
    ("client-jira", "acme-jira"),
    ("client-openshift", "acme-openshift"),
    ("client-docker", "acme-docker"),
    ("client-lint", "acme-lint"),
    ("client-unit-tests", "acme-unit-tests"),
    ("proj:client:", "proj:acme:"),
    ("CLIENT-XXXX", "ACME-XXXX"),
    ("Client Platform GitOps", "Acme Platform GitOps"),
    ("Client Platform Team", "Acme Platform Team"),
    ("Client Developer Hub", "Acme Developer Hub"),
    ("Client Red", "Acme Red"),
    ("Client Platform Discovery", "Acme Platform Discovery"),
    ("Client custom", "Acme custom"),
    ("Client to share", "Acme org to share"),
    ("Client to provide", "Acme org to provide"),
    ("Client to confirm", "Acme org to confirm"),
    ("for Client.", "for Acme."),
    ('for Client"', 'for Acme"'),
    ("nonprod-dc1-client-", "nonprod-dc1-acme-"),
    ("nonprod-dc2-client-", "nonprod-dc2-acme-"),
    ("/client/${", "/acme/${"),
    ("registry.*/client/", "registry.*/acme/"),
    ("${ARTIFACTORY_BASE_URL}/client/", "${ARTIFACTORY_BASE_URL}/acme/"),
    ('or "client"', 'or "acme"'),
    ("quay.io/repository-slug: client/", "quay.io/repository-slug: acme/"),
    ("Client Standard", "Acme Standard"),
    ("# Client Platform", "# Acme Platform"),
    ("description: Client ", "description: Acme "),
    ("Welcome to Client", "Welcome to Acme"),
    ("ClientNZ", "Acme"),
    ("github.com/client/", "github.com/rmallam-rhdh/RHDH-SM-DevSpaces/"),
    ("oc apply -f argocd/projects/client.yaml", "oc apply -f argocd/projects/acme.yaml"),
    ("└── client.yaml", "└── acme.yaml"),
    ("│   └── client.yaml", "│   └── acme.yaml"),
]

# Word-boundary replacements last
WORD_REPLACEMENTS = [
    (r"\bclient\b", "acme"),
    (r"\bClient\b", "Acme"),
]

TEXT_SUFFIXES = {
    ".yaml", ".yml", ".md", ".csv", ".sh", ".kts", ".java", ".json",
    ".properties", ".bat", "Jenkinsfile", "gradlew",
}


def should_process(path: Path) -> bool:
    if any(s in path.parts for s in SKIP):
        return False
    if path.name == "rebrand_to_acme.py":
        return False
    if path.suffix in TEXT_SUFFIXES or path.name in TEXT_SUFFIXES:
        return True
    return path.name == "gradlew"


def protect_oauth(text: str) -> tuple[str, list[tuple[str, str]]]:
    tokens = []
    patterns = [
        r"clientId:",
        r"clientSecret:",
        r"OAUTH_CLIENT_",
        r"GITHUB_OAUTH_CLIENT_",
        r"KEYCLOAK_PLUGIN_CLIENT_",
        r"AZURE_CLIENT_",
        r"your-client-id",
        r"your-client-secret",
        r"oauth-client-",
    ]
    for i, pat in enumerate(patterns):
        for m in re.finditer(pat, text):
            placeholder = f"__OAUTH_PROTECT_{i}_{m.start()}__"
            tokens.append((placeholder, m.group(0)))

    # Simple protect: replace full lines with clientId/clientSecret
    protected = text
    for placeholder, original in reversed(tokens):
        protected = protected.replace(original, placeholder, 1)
    return protected, tokens


def restore_oauth(text: str, tokens: list[tuple[str, str]]) -> str:
    for placeholder, original in tokens:
        text = text.replace(placeholder, original)
    return text


def rebrand(content: str) -> str:
    protected, tokens = protect_oauth(content)
    for old, new in REPLACEMENTS:
        protected = protected.replace(old, new)
    for pattern, repl in WORD_REPLACEMENTS:
        protected = re.sub(pattern, repl, protected)
    return restore_oauth(protected, tokens)


def main() -> None:
    count = 0
    for path in ROOT.rglob("*"):
        if not path.is_file() or not should_process(path):
            continue
        try:
            original = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        updated = rebrand(original)
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            count += 1
    print(f"Updated {count} files")


if __name__ == "__main__":
    main()
