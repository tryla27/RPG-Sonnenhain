"""Lokaler Webserver für Browser-Messungen des Webexports.

Aufruf: python tools/web_bench_server.py <export-ordner> <ergebnis-ordner> [port]
Liefert den Export mit den für Godot nötigen Kopfzeilen aus und speichert jede
POST-Anfrage an /bench als bench-<zeit>.json im Ergebnisordner.
Browser öffnen: http://127.0.0.1:<port>/index.html?bench=1
"""
import http.server, json, sys, time, pathlib, functools

root = pathlib.Path(sys.argv[1]); out = pathlib.Path(sys.argv[2]); port = int(sys.argv[3]) if len(sys.argv) > 3 else 8060
out.mkdir(parents=True, exist_ok=True)

class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()
    def do_POST(self):
        body = self.rfile.read(int(self.headers.get("Content-Length", 0)))
        try:
            data = json.loads(body)
        except ValueError:
            data = {"raw": body.decode("utf-8", "replace")}
        name = out / ("bench-%d.json" % int(time.time() * 1000))
        name.write_text(json.dumps(data, indent=1), encoding="utf-8")
        print("SAVED", name, flush=True)
        self.send_response(200); self.end_headers(); self.wfile.write(b"ok")
    def log_message(self, *args):
        pass

http.server.ThreadingHTTPServer(("127.0.0.1", port), functools.partial(Handler, directory=str(root))).serve_forever()
