#!/usr/bin/env python3
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: harden_web.py <index.html>")

path = Path(sys.argv[1])
html = path.read_text(encoding="utf-8")

security_meta = """		<meta name="referrer" content="no-referrer">
		<meta name="robots" content="noindex,nofollow,noarchive,nosnippet">
		<meta http-equiv="Permissions-Policy" content="camera=(), microphone=(), geolocation=(), payment=(), usb=(), interest-cohort=()">
		<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' 'wasm-unsafe-eval'; connect-src 'self' wss://multiplayer.sonnenhainrpg.de; img-src 'self' data: blob:; media-src 'self' blob:; worker-src 'self' blob:; style-src 'self' 'unsafe-inline'; font-src 'self' data:; object-src 'none'; frame-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests">
"""

gate_style = """
<style>
#human-gate{position:fixed;inset:0;z-index:99999;background:#081a2a;color:#f4ecd5;display:flex;align-items:center;justify-content:center;font-family:Arial,sans-serif}
#human-card{width:min(520px,calc(100% - 32px));background:#10283c;border:2px solid #c9a45e;border-radius:0;padding:24px;box-shadow:0 20px 60px rgba(0,0,0,.45)}
#human-card h1{margin:0 0 8px;font-size:28px}
#human-card p{line-height:1.45;color:#bacbd6}
#human-card input[type=number]{width:100%;box-sizing:border-box;padding:12px;margin:8px 0 12px;background:#0b2033;color:#fff;border:2px solid #c9a45e;border-radius:0;font-size:18px}
#human-card button{width:100%;padding:12px;border:0;border-radius:0;background:#d4b06a;color:#1a1a16;font-weight:700;font-size:16px;cursor:pointer}
#human-card button:disabled{opacity:.45;cursor:not-allowed}
#human-links{margin-top:16px;text-align:center;font-size:13px}
#human-links a{color:#d9c18a;margin:0 7px}
#human-error{min-height:20px;color:#ffb0a8;font-size:13px}
</style>
"""

gate_html = """
<div id="human-gate" role="dialog" aria-modal="true" aria-labelledby="human-title">
  <div id="human-card">
    <h1 id="human-title">Mensch-Prüfung</h1>
    <p>Sonnenhain ist über die Webadresse direkt erreichbar. Vor dem Spielstart folgt nur eine kurze Mensch-Prüfung.</p>
    <p id="human-question"></p>
    <input id="human-answer" type="number" inputmode="numeric" autocomplete="off" aria-label="Antwort auf die Mensch-Prüfung">
    <label><input id="human-confirm" type="checkbox"> Ich bin ein Mensch und möchte das Spiel starten.</label>
    <div id="human-error" aria-live="polite"></div>
    <button id="human-start" type="button" disabled>PRÜFEN &amp; SPIEL STARTEN</button>
    <div id="human-links"><a href="/datenschutz.html">Datenschutz</a><a href="/impressum.html">Impressum</a><a href="/nutzungsregeln.html">Regeln</a><a href="/jugendschutz.html">Jugendschutz</a><a href="/lizenzen.html">Lizenzen</a><a href="/sicherheit.html">Sicherheit</a><a href="/">Startseite</a></div>
  </div>
</div>
"""

if 'name="referrer"' not in html:
    marker = '		<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">\n'
    if marker not in html:
        raise SystemExit("viewport marker not found; Godot HTML template changed")
    html = html.replace(marker, marker + security_meta + gate_style, 1)

if 'id="human-gate"' not in html:
    body_marker = '	<body>\n'
    if body_marker not in html:
        raise SystemExit("body marker not found; Godot HTML template changed")
    html = html.replace(body_marker, body_marker + gate_html, 1)

gate_js = r"""
	function waitForHumanGate() {
		return new Promise((resolve) => {
			const gate = document.getElementById('human-gate');
			const question = document.getElementById('human-question');
			const answer = document.getElementById('human-answer');
			const confirm = document.getElementById('human-confirm');
			const start = document.getElementById('human-start');
			const error = document.getElementById('human-error');

			const a = 2 + Math.floor(Math.random() * 8);
			const b = 1 + Math.floor(Math.random() * 7);
			const expected = a + b;
			question.textContent = 'Wie viel ist ' + a + ' + ' + b + '?';

			function refresh() {
				start.disabled = !confirm.checked || answer.value.trim() === '';
			}
			confirm.addEventListener('change', refresh);
			answer.addEventListener('input', refresh);
			answer.addEventListener('keydown', (event) => {
				if (event.key === 'Enter' && !start.disabled) start.click();
			});
			start.addEventListener('click', () => {
				if (Number(answer.value) !== expected) {
					error.textContent = 'Die Antwort stimmt noch nicht.';
					answer.focus();
					return;
				}
				error.textContent = '';
				gate.remove();
				resolve();
			});
			answer.focus();
		});
	}
"""

if 'function waitForHumanGate()' not in html:
    marker = "	const missing = Engine.getMissingFeatures({\n"
    if marker not in html:
        raise SystemExit("Godot startup marker not found")
    html = html.replace(marker, gate_js + "\n" + marker, 1)

old = """		setStatusMode('progress');
		engine.startGame({
"""
new = """		waitForHumanGate().then(() => {
			setStatusMode('progress');
			return engine.startGame({
"""
if old in html:
    html = html.replace(old, new, 1)
    html = html.replace("""		}).then(() => {
			setStatusMode('hidden');
		}, displayFailureNotice);
""", """			}).then(() => {
				setStatusMode('hidden');
			}, displayFailureNotice);
		}).catch(displayFailureNotice);
""", 1)

html = html.replace('<html lang="en">', '<html lang="de">', 1)
html = html.replace('<html>', '<html lang="de">', 1)

path.write_text(html, encoding="utf-8")
print(f"hardened {path}")
