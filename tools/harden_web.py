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
		<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' 'wasm-unsafe-eval'; connect-src 'self'; img-src 'self' data: blob:; media-src 'self' blob:; worker-src 'self' blob:; style-src 'self' 'unsafe-inline'; font-src 'self' data:; object-src 'none'; frame-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests">
"""

gate_style = """
<style>
#human-gate{position:fixed;inset:0;z-index:99999;background:#101714;color:#f4ecd5;display:flex;align-items:center;justify-content:center;font-family:Arial,sans-serif}
#human-card{width:min(520px,calc(100% - 32px));background:#1a2722;border:1px solid #6f8c7f;border-radius:14px;padding:24px;box-shadow:0 20px 60px rgba(0,0,0,.45)}
#human-card h1{margin:0 0 8px;font-size:28px}
#human-card p{line-height:1.45;color:#cfdbd4}
#human-card input[type=number]{width:100%;box-sizing:border-box;padding:12px;margin:8px 0 12px;background:#0e1713;color:#fff;border:1px solid #698477;border-radius:8px;font-size:18px}
#human-card button{width:100%;padding:12px;border:0;border-radius:8px;background:#d4b06a;color:#1a1a16;font-weight:700;font-size:16px;cursor:pointer}
#human-card button:disabled{opacity:.45;cursor:not-allowed}
#human-links{margin-top:16px;text-align:center;font-size:13px}
#human-links a{color:#d9c18a;margin:0 7px}
#human-error{min-height:20px;color:#ffb0a8;font-size:13px}
</style>
"""

gate_html = """
<div id="human-gate" role="dialog" aria-modal="true" aria-labelledby="human-title">
  <div id="human-card">
    <h1 id="human-title">Privater Zugang</h1>
    <p id="invite-status">Sonnenhain ist nur über einen gültigen Einladungslink zugänglich.</p>
    <p>Nach bestätigter Einladung folgt eine kurze Mensch-Prüfung.</p>
    <p id="human-question"></p>
    <input id="human-answer" type="number" inputmode="numeric" autocomplete="off" aria-label="Antwort auf die Mensch-Prüfung">
    <label><input id="human-confirm" type="checkbox"> Ich bin ein Mensch und möchte das Spiel starten.</label>
    <div id="human-error" aria-live="polite"></div>
    <button id="human-start" type="button" disabled>PRÜFEN &amp; SPIEL STARTEN</button>
    <div id="human-links"><a href="/datenschutz.html">Datenschutz</a><a href="/impressum.html">Impressum</a><a href="/sicherheit.html">Sicherheit</a><a href="/">Startseite</a></div>
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
	const INVITE_SHA256 = '200a4cd17b7f7583097f7aa1ceff92ea7a7e4a18120ceb859c41ef6d4404d1a3';

	async function sha256Hex(value) {
		const bytes = new TextEncoder().encode(value);
		const hash = await crypto.subtle.digest('SHA-256', bytes);
		return Array.from(new Uint8Array(hash)).map((b) => b.toString(16).padStart(2, '0')).join('');
	}

	function waitForHumanGate() {
		return new Promise(async (resolve) => {
			const gate = document.getElementById('human-gate');
			const status = document.getElementById('invite-status');
			const question = document.getElementById('human-question');
			const answer = document.getElementById('human-answer');
			const confirm = document.getElementById('human-confirm');
			const start = document.getElementById('human-start');
			const error = document.getElementById('human-error');

			let invited = sessionStorage.getItem('sonnenhain_invited') === '1';
			if (!invited) {
				const params = new URLSearchParams(window.location.search);
				const token = params.get('invite') || '';
				if (token) {
					try {
						invited = (await sha256Hex(token)) === INVITE_SHA256;
					} catch (_) {
						invited = false;
					}
				}
				if (invited) {
					sessionStorage.setItem('sonnenhain_invited', '1');
					history.replaceState(null, '', window.location.pathname + window.location.hash);
				}
			}

			if (!invited) {
				status.textContent = 'Kein gültiger Einladungslink. Bitte verwende den persönlichen Sonnenhain-Einladungslink.';
				question.textContent = '';
				answer.style.display = 'none';
				confirm.parentElement.style.display = 'none';
				start.style.display = 'none';
				error.textContent = 'Zugriff gesperrt.';
				return;
			}

			status.textContent = 'Einladung bestätigt.';
			const a = 2 + Math.floor(Math.random() * 8);
			const b = 1 + Math.floor(Math.random() * 7);
			const expected = a + b;
			question.textContent = 'Mensch-Prüfung: Wie viel ist ' + a + ' + ' + b + '?';

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
