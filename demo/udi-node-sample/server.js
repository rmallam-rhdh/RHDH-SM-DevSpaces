#!/usr/bin/env node
"use strict";

const http = require("http");
const { execFileSync } = require("child_process");

const port = Number(process.env.PORT || 3000);

function tool(bin, args) {
  try {
    return execFileSync(bin, args, { encoding: "utf8" }).trim().split("\n")[0];
  } catch (err) {
    return `unavailable (${err.message})`;
  }
}

const page = () => `<!doctype html>
<html><head><meta charset="utf-8"><title>UDI Node demo</title></head>
<body style="font-family:sans-serif;margin:2rem;max-width:42rem">
  <h1>Node on Universal Developer Image</h1>
  <p>Same UDI tools container a golden-path Node developer gets. No language-specific image.</p>
  <ul>
    <li>node: ${tool("node", ["-v"])}</li>
    <li>npm: ${tool("npm", ["-v"])}</li>
    <li>git: ${tool("git", ["--version"])}</li>
  </ul>
  <p>Source: <code>/projects/node-app</code> — <code>npm start</code></p>
</body></html>`;

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok", runtime: "udi-node" }));
    return;
  }
  const body = page();
  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  res.end(body);
});

server.listen(port, "0.0.0.0", () => {
  console.log(`UDI Node demo listening on http://0.0.0.0:${port}`);
});
