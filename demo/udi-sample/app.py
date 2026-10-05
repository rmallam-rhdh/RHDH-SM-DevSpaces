#!/usr/bin/env python3
"""Minimal stdlib HTTP app — no pip. Runs on UDI python3."""
from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import shutil
import subprocess


def _ver(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT).strip().splitlines()[0]
    except Exception as exc:
        return f"unavailable ({exc})"


PAGE = """<!doctype html>
<html><head><meta charset="utf-8"><title>UDI client demo</title></head>
<body style="font-family:sans-serif;margin:2rem;max-width:40rem">
  <h1>Universal Developer Image</h1>
  <p>This workspace tools container is Red Hat UDI, not a language-specific stack image.</p>
  <ul>
    <li>Python: {python}</li>
    <li>Node: {node}</li>
    <li>Java: {java}</li>
    <li>Git: {git}</li>
  </ul>
  <p>Source: <code>/projects/udi-client-demo</code></p>
</body></html>
"""


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = PAGE.format(
            python=_ver(["python3", "--version"]),
            node=_ver(["node", "--version"]),
            java=_ver(["java", "-version"]),
            git=_ver(["git", "--version"]),
        ).encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(self.address_string(), "-", fmt % args)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8080"))
    print(f"UDI demo listening on 0.0.0.0:{port}")
    print("which python3:", shutil.which("python3"))
    HTTPServer(("0.0.0.0", port), Handler).serve_forever()
