# UDI client demo

Dev Spaces workspace whose **tools** container is Red Hat **Universal Developer Image** (`registry.redhat.io/devspaces/udi-rhel9`), not `ubi9/python-39` or a language-only image.

UDI already includes Python, Node, Java, Maven, Git, and `oc`. `app.py` uses stdlib only (no `pip install`).

## Open on this cluster (dashboard)

1. Choose editor: **VS Code - Open Source** (or default).
2. Git repo URL (after this folder is on `main`):

   `https://github.com/rmallam/RHDH-SM-DevSpaces.git`

   Factory (skips the form):

   `https://devspaces.apps.rosa.rosa-89s85.bhg0.p3.openshiftapps.com/dashboard/#/load/workspace/factory?url=https://github.com/rmallam/RHDH-SM-DevSpaces&devfilePath=demo/udi-sample/devfile.yaml`

3. In the workspace terminal: `python3 --version`, `node --version`, `java -version`, then `python3 app.py`.
4. Open the **app** endpoint from the Dev Spaces ports UI.

## Local VS Code connector

Sign in with the ROSA **API** URL (`https://api.rosa-89s85.bhg0.p3.openshiftapps.com:443`), not the dashboard host, then **Connect** to `udi-client-demo`.
