#!/usr/bin/env python3
from pathlib import Path
import sys
if len(sys.argv)!=2: raise SystemExit("usage: harden_web.py <index.html>")
path=Path(sys.argv[1])
html=path.read_text(encoding="utf-8")
security_meta = """		<meta name="referrer" content="no-referrer">
		<meta name="robots" content="noindex,nofollow,noarchive,nosnippet">
		<meta http-equiv="Permissions-Policy" content="camera=(), microphone=(), geolocation=(), payment=(), usb=(), interest-cohort=()">
		<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' 'wasm-unsafe-eval'; connect-src 'self' wss://multiplayer.sonnenhainrpg.de; img-src 'self' data: blob:; media-src 'self' blob:; worker-src 'self' blob:; style-src 'self' 'unsafe-inline'; font-src 'self' data:; object-src 'none'; frame-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests">
"""


if 'name="referrer"' not in html:
    html=html.replace('</head>',security_meta+'\n</head>',1)
html=html.replace('<html lang="en">','<html lang="de">',1)
path.write_text(html,encoding="utf-8")
print(f"hardened {path}; website access is enforced by Apache")
