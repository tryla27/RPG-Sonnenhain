"""Sonnenhain-Werkzeugzentrale v2: lokale, begrenzte Produktionsaufträge."""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import urllib.request

from recipes import actions, WORKFLOWS
import runner

HOME = Path(__file__).resolve().parent
VERSION = "2.0-paket1"


def read_config():
    path = HOME / "config.local.json"
    value = json.loads(path.read_text(encoding="utf-8-sig")) if path.exists() else {
        "project": "../..", "tools_root": os.environ.get("SONNENHAIN_TOOLS_ROOT", "E:/Sonnenhain-Tools"),
        "comfy_url": "http://127.0.0.1:8188"}
    for key in ("project", "tools_root"):
        value[key] = str((HOME / value[key]).resolve())
    if value.get("comfy_url") != "http://127.0.0.1:8188":
        raise ValueError("Nur die deklarierte lokale ComfyUI-Adresse ist unterstützt")
    if not (Path(value["project"]) / "project.godot").is_file():
        raise ValueError("Projektpfad enthält keine project.godot")
    return value


def project_identity(config):
    try:
        def git(*args):
            result = subprocess.run(["git", "-C", config["project"], *args], capture_output=True,
                                    text=True, timeout=3, creationflags=subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0)
            return result.stdout.strip()[:500] if result.returncode == 0 else None
        return {"path": config["project"], "branch": git("branch", "--show-current"),
                "commit": git("rev-parse", "HEAD"),
                "tracked_changes": bool(git("diff", "--name-only", "HEAD", "--", "tools/werkzeugzentrale", "tools/art_pipeline", "project.godot"))}
    except (OSError, subprocess.TimeoutExpired):
        return {"path": config["project"], "git": "unknown"}


def comfy_status(config):
    try:
        opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
        with opener.open(config["comfy_url"] + "/system_stats", timeout=2) as response:
            raw = response.read(65537)
        if len(raw) > 65536:
            raise ValueError("Statusantwort zu groß")
        info = json.loads(raw)
        return {"ready": True, "devices": [str(d.get("name", ""))[:120] for d in info.get("devices", [])[:4]]}
    except Exception:
        return {"ready": False, "reason": "API nicht erreichbar, noch nicht bereit oder ungültige Antwort"}


def status(config):
    registry = actions(config)
    probes = {"godot": "godot.version", "blender": "blender.version", "krita": "krita.version",
              "inkscape": "inkscape.version", "comfyui": "comfy.start"}
    return {"version": VERSION, "project": project_identity(config),
            "tools": {key: {"installed": all(Path(p).is_file() for p in [registry[a]["commands"][0][0], *registry[a]["inputs"]])}
                      for key, a in probes.items()},
            "comfy_api": comfy_status(config), "external_ai": "blocked", "chat_tokens": None,
            "network_isolated": False, "services": "in_v2_bis_Dienstverwaltung_gesperrt"}


def plan(config, name):
    registry = actions(config)
    ids = WORKFLOWS.get(name, [name])
    if any(key not in registry for key in ids):
        raise ValueError("Unbekannte Aktion")
    return {"name": name, "project": config["project"], "identity": project_identity(config),
            "timeout": 1200 if name == "comfy.concepts" else 900,
            "steps": [registry[key] for key in ids]}


def plan_summary(recipe):
    return {"name": recipe["name"], "project": recipe.get("identity", recipe["project"]),
            "limits": {"timeout_seconds": recipe["timeout"], "max_commands": 12, "retries": 0},
            "steps": [{k: step[k] for k in ("id", "title", "cost_class", "detached", "effect")} for step in recipe["steps"]]}


def run(config, name, on_started=None):
    recipe = plan(config, name)
    if name == "comfy.concepts":
        raise ValueError("Generierung vorerst gesperrt: bestehendes Skript hat noch keine auftragsbezogene Queue-Unterbrechung")
    return runner.run(HOME, recipe, on_started)


def history():
    rows = []
    for path in sorted((HOME / "jobs").glob("*/job.json"), reverse=True)[:10]:
        try:
            rows.append(runner.summary(runner.read_json(path)))
        except (ValueError, OSError):
            rows.append({"id": path.parent.name, "status": "unknown"})
    return rows


def emit(value):
    output = json.dumps(value, ensure_ascii=False, indent=2)
    if len(output.encode("utf-8")) > 4096:
        if isinstance(value, list):
            while value and len(json.dumps(value, ensure_ascii=False).encode("utf-8")) > 3000:
                value = value[:-1]
            output = json.dumps({"items": value, "truncated": True, "hint": "Einzelauftrag mit job <id> abrufen"}, ensure_ascii=False)
        else:
            output = json.dumps({"status": "details_required", "hint": "Einzelne Aktion planen oder lokale job.json öffnen"})
    print(output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["status", "list", "plan", "run", "history", "job", "cancel", "gui"])
    parser.add_argument("action", nargs="?")
    parser.add_argument("--execute", action="store_true")
    parser.add_argument("--details", action="store_true", help="Detailplan lokal speichern und Pfad ausgeben")
    args = parser.parse_args()
    try:
        config = read_config()
        if args.command == "gui":
            from gui import main as gui_main
            gui_main(config)
            return 0
        if args.command == "status":
            result = status(config)
        elif args.command == "list":
            result = {"version": VERSION, "actions": [{"id": k, "title": v["title"],
                        "available": not v["detached"] and k != "comfy.concepts"} for k, v in actions(config).items()], "workflows": WORKFLOWS}
        elif args.command == "history":
            result = history()
        elif not args.action:
            raise ValueError("Aktionsname oder Auftrags-ID fehlt")
        elif args.command == "cancel":
            result = runner.cancel(HOME, args.action)
        elif args.command == "job":
            result = runner.summary(runner.load_job(HOME, args.action))
        elif args.command == "run" and args.execute:
            result = runner.summary(run(config, args.action))
        else:
            recipe = plan(config, args.action)
            if args.details:
                target = HOME / "jobs" / "last-plan.json"
                runner.write_json(target, recipe)
                result = {"plan": str(target), "name": recipe["name"]}
            else:
                result = plan_summary(recipe)
        emit(result)
        return 1 if isinstance(result, dict) and result.get("status") in ("failed", "timed_out", "cancelled", "error") else 0
    except Exception as error:
        emit({"status": "error", "error": str(error)[:600]})
        return 1


if __name__ == "__main__":
    sys.exit(main())
