"""Interner Bootstrap: ohne explizites Startbyte wird kein Werkzeug gestartet."""
import subprocess
import sys


if __name__ == "__main__":
    if sys.stdin.buffer.read(1) != b"1":
        raise SystemExit(125)
    raise SystemExit(subprocess.call(sys.argv[1:], stdin=subprocess.DEVNULL, shell=False))
