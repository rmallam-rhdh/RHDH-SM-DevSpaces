# Simulate a Node developer on UDI

This is the client story: a Node app on **Red Hat UDI**, not `ubi8/nodejs-20`. Same image as Java/Python workspaces; Node comes from the toolchain.

## Workspace on this cluster

`udi-node-demo` in `cluster-admin-devspaces`.

1. Local VS Code → Dev Spaces → **Connect** to **udi-node-demo**  
   (API: `https://api.rosa-89s85.bhg0.p3.openshiftapps.com:443`).
2. Open folder `/projects/node-app`.
3. In the **remote** terminal:

```bash
node -v
npm -v
npm test
npm start
```

4. Ports: **3000** / **api** — open in browser. `/health` returns JSON.
5. Extensions: Command Palette → **Extensions: Show Recommended Extensions**.  
   Install them under **Remote** (laptop VS Code). Browser che-code does **not** share that store.

## What this maps to in golden path

`golden-path/nodejs/skeleton/devfile.yaml` is the same idea: UDI `tools` container, `NODEJS_VERSION`, `npm ci` / `npm test` / `npm run dev`. After Bitbucket publish, the factory URL clones the real app repo instead of this sample.
