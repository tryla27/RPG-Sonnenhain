#!/usr/bin/env python3
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: harden_web.py <index.html>")

path = Path(sys.argv[1])
html = path.read_text(encoding="utf-8")

security_meta = """		<meta name="referrer" content="no-referrer">
		<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' 'wasm-unsafe-eval'; connect-src 'self'; img-src 'self' data: blob:; media-src 'self' blob:; worker-src 'self' blob:; style-src 'self' 'unsafe-inline'; font-src 'self' data:; object-src 'none'; base-uri 'self'; form-action 'none'; upgrade-insecure-requests">
"""

if 'name="referrer"' not in html:
    marker = '		<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">\n'
    if marker not in html:
        raise SystemExit("viewport marker not found; Godot HTML template changed")
    html = html.replace(marker, marker + security_meta, 1)

html = html.replace('<html lang="en">', '<html lang="de">', 1)
html = html.replace('<html>', '<html lang="de">', 1)

path.write_text(html, encoding="utf-8")
print(f"hardened {path}")
