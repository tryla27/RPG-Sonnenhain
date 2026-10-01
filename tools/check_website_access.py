"""Exercise the actual PHP gate, including protected game assets and failed logins."""
from pathlib import Path
import http.client
import json
import os
import re
import shutil
import socket
import subprocess
import tempfile
import time
from urllib.parse import urlencode


def main():
    root = Path(__file__).resolve().parent.parent
    with tempfile.TemporaryDirectory(prefix="sonnenhain-access-test-") as directory:
        fixture = Path(directory)
        web = fixture / "web"
        web.mkdir()
        shutil.copyfile(root / "website/access/access.php", web / "access.php")
        (web / "game").mkdir()
        (web / "patches").mkdir()
        (web / "index.html").write_text("SONNENHAIN HOME", encoding="utf-8")
        (web / "game/index.html").write_text("SONNENHAIN GAME", encoding="utf-8")
        (web / "game/index.wasm").write_bytes(bytes(range(256)) * 16384)
        (web / "patches/index.html").write_text("PATCH NOTES", encoding="utf-8")
        (web / "version.json").write_text(json.dumps({"commit": "fixture"}), encoding="utf-8")
        (web / ".htpasswd").write_text("SHOULD NEVER BE SERVED", encoding="utf-8")
        (web / "private.php").write_text("<?php echo 'SECRET';", encoding="utf-8")
        password = "test-only-password-not-production"
        hashed = subprocess.check_output(["php", "-r", "echo password_hash($argv[1], PASSWORD_BCRYPT);", password], text=True)
        hash_file = fixture / "access.htpasswd"
        hash_file.write_text("internal:" + hashed, encoding="utf-8")
        with socket.socket() as available:
            available.bind(("127.0.0.1", 0))
            port = available.getsockname()[1]
        env = dict(os.environ, SONNENHAIN_ACCESS_FILE=str(hash_file))
        log = (fixture / "php.log").open("w")
        server = subprocess.Popen(["php", "-S", f"127.0.0.1:{port}", "-t", str(web), str(web / "access.php")], env=env, stdout=log, stderr=log)
        cookie = ""

        def request(path, method="GET", form=None, extra=None, cookies=True):
            nonlocal cookie
            headers = dict(extra or {})
            if cookies and cookie:
                headers["Cookie"] = cookie
            body = None
            if form is not None:
                body = urlencode(form)
                headers["Content-Type"] = "application/x-www-form-urlencoded"
            connection = http.client.HTTPConnection("127.0.0.1", port, timeout=10)
            connection.request(method, path, body, headers)
            response = connection.getresponse()
            data = response.read()
            result = response.status, dict(response.getheaders()), data
            if cookies and response.getheader("Set-Cookie"):
                cookie = response.getheader("Set-Cookie").split(";", 1)[0]
            connection.close()
            return result

        try:
            for _ in range(100):
                try:
                    status, headers, body = request("/game/")
                    break
                except (OSError, http.client.HTTPException):
                    time.sleep(0.05)
            else:
                raise AssertionError("PHP gate failed to start")
            assert status == 302 and headers["Location"].startswith("/login?next="), (status, headers)
            assert "WWW-Authenticate" not in headers
            secure_cookie = headers["Set-Cookie"]
            for path in ["/", "/patches/", "/game/index.wasm", "/version.json"]:
                assert request(path, cookies=False)[0] == 302, path
            status, headers, body = request("/login?next=%2Fgame%2F")
            assert status == 200 and b'name="password"' in body and b'name="username"' not in body
            assert "Secure" in secure_cookie and "HttpOnly" in secure_cookie and "SameSite=Lax" in secure_cookie
            csrf = re.search(rb'name="csrf" value="([^"]+)"', body).group(1).decode()
            assert request("/login", "POST", {"password": password, "csrf": "wrong"})[0] == 403
            assert request("/login", "POST", {"password": "wrong", "csrf": csrf})[0] == 401
            old_cookie = cookie
            status, headers, body = request("/login", "POST", {"password": password, "csrf": csrf, "next": "/game/"})
            assert status == 303 and headers["Location"] == "/game/" and cookie != old_cookie
            assert request("/game/")[2] == b"SONNENHAIN GAME"
            assert request("/patches/")[2] == b"PATCH NOTES"
            assert request("/version.json")[0] == 200
            status, headers, body = request("/game/index.wasm", "HEAD")
            assert status == 200 and headers["Content-Type"] == "application/wasm" and int(headers["Content-Length"]) == 4194304 and body == b""
            status, headers, body = request("/game/index.wasm", extra={"Range": "bytes=256-511"})
            assert status == 206 and body == bytes(range(256)) and headers["Content-Range"] == "bytes 256-511/4194304"
            assert request("/game/index.wasm", extra={"Range": "bytes=99999999-"})[0] == 416
            assert request("/game/index.wasm", extra={"Range": "bytes=-0"})[0] == 416
            assert len(request("/game/index.wasm")[2]) == 4194304
            for path in ["/.htpasswd", "/private.php", "/%2e%2e/access.htpasswd", "/missing", "/access.php/secret"]:
                assert request(path)[0] == 404, path
            assert request("/game/", "POST")[0] == 405
            # A rotated hash invalidates an already authenticated session.
            hash_file.write_text("internal:" + subprocess.check_output(["php", "-r", "echo password_hash($argv[1], PASSWORD_BCRYPT);", password], text=True), encoding="utf-8")
            assert request("/game/")[0] == 302
            status, headers, body = request("/login")
            csrf = re.search(rb'name="csrf" value="([^"]+)"', body).group(1).decode()
            status, headers, body = request("/login", "POST", {"password": password, "csrf": csrf, "next": "//example.com"})
            assert status == 303 and headers["Location"] == "/"
            cookie = ""
            for _ in range(10):
                _, _, body = request("/login")
                csrf = re.search(rb'name="csrf" value="([^"]+)"', body).group(1).decode()
                assert request("/login", "POST", {"password": "wrong", "csrf": csrf})[0] == 401
                cookie = ""  # Rate limit must survive discarded sessions.
            _, _, body = request("/login")
            csrf = re.search(rb'name="csrf" value="([^"]+)"', body).group(1).decode()
            assert request("/login", "POST", {"password": password, "csrf": csrf})[0] == 429
            print("WEBSITE_ACCESS_OK password-only form, CSRF, session rotation, shared rate limit, protected pages/assets, HEAD/range/full WASM, traversal rejection and password rotation")
        finally:
            server.terminate()
            server.wait(timeout=10)
            log.close()


if __name__ == "__main__":
    main()
