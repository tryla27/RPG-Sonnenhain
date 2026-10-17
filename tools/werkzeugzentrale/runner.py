"""Begrenzte Aufträge, atomare Statusdateien und kooperativer Abbruch per Job-ID."""
from __future__ import annotations

import datetime as dt
import json
import math
import os
from pathlib import Path
import re
import time
import uuid

from processes import execute

JOB_ID = re.compile(r"^[0-9]{8}-[0-9]{6}-[a-f0-9]{8}$")
TERMINAL = {"passed", "failed", "timed_out", "cancelled", "unknown"}


# Windows: Liest ein anderer Prozess (Fenster, CLI) die Statusdatei gerade, schlägt
# os.replace mit PermissionError fehl; ein Leser kann umgekehrt kurz auf eine
# gesperrte Datei treffen. Deshalb wenige, zeitlich begrenzte Versuche (insgesamt
# höchstens ~2 s), danach ein sichtbarer Fehler statt einer Endlosschleife.
FILE_ATTEMPTS = 40
FILE_WAIT = 0.05


def _replace(source, target, attempts=FILE_ATTEMPTS, wait=FILE_WAIT):
    for attempt in range(attempts):
        try:
            os.replace(source, target)
            return
        except PermissionError:
            if attempt == attempts - 1:
                raise
            time.sleep(wait)


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + "." + uuid.uuid4().hex + ".tmp")
    try:
        temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding="utf-8")
        _replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def read_json(path, attempts=FILE_ATTEMPTS, wait=FILE_WAIT):
    """Statusdatei lesen; kurz gesperrte oder gerade ersetzte Dateien erneut versuchen."""
    for attempt in range(attempts):
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except (PermissionError, json.JSONDecodeError):
            if attempt == attempts - 1:
                raise
            time.sleep(wait)


def load_job(home, job_id):
    if not JOB_ID.fullmatch(job_id):
        raise ValueError("Ungültige Auftrags-ID")
    return read_json(home / "jobs" / job_id / "job.json")


def cancel(home, job_id):
    record = load_job(home, job_id)
    if record["status"] in TERMINAL:
        return summary(record)
    (home / "jobs" / job_id / "cancel.request").touch()
    return {"id": job_id, "status": "cancel_requested"}


def summary(record):
    result = {key: record[key] for key in ("id", "name", "status", "duration_seconds", "error", "log", "cost_class", "limits") if key in record}
    result["steps"] = [{key: step[key] for key in ("action", "status", "exit_code") if key in step}
                       for step in record.get("steps", [])]
    return result


def validate(recipe):
    steps = recipe.get("steps", [])
    if not 1 <= len(steps) <= 12 or sum(len(s.get("commands", [])) for s in steps) > 12:
        raise ValueError("Auftrag muss 1–12 endliche Befehle enthalten")
    limit = recipe.get("timeout", 900)
    if not isinstance(limit, (int, float)) or not math.isfinite(limit) or not 0 < limit <= 1200:
        raise ValueError("Ungültige Gesamtdeadline (höchstens 1200 Sekunden)")
    for step in steps:
        if step.get("cost_class") != "local_compute":
            raise ValueError("Externe oder unbekannte Kostenklasse: Ausführung gesperrt")
        if step.get("detached"):
            raise ValueError("Dauerprozess in v2 noch gesperrt: Dienstregister und kontrollierter Stop ausstehend")
        if step.get("retries", 0) != 0:
            raise ValueError("Automatische Wiederholung ist gesperrt")
        timeout = step.get("timeout", 600)
        if not isinstance(timeout, (float, int)) or not math.isfinite(timeout) or timeout <= 0:
            raise ValueError("Ungültiges Schrittzeitlimit")
        if not step.get("commands"):
            raise ValueError("Leerer Produktionsschritt")
        for command in step["commands"]:
            if not command or not all(isinstance(v, str) and v and "\0" not in v for v in command):
                raise ValueError("Ungültige Argumentliste")
            if not Path(command[0]).is_absolute() or not Path(command[0]).is_file():
                raise ValueError("Werkzeug muss als vorhandener absoluter Dateipfad angegeben sein")
        if not Path(step["cwd"]).is_absolute() or not Path(step["cwd"]).is_dir():
            raise ValueError("Ungültiges Arbeitsverzeichnis")


def run(home, recipe, on_started=None):
    validate(recipe)
    job_id = dt.datetime.now().strftime("%Y%m%d-%H%M%S") + "-" + uuid.uuid4().hex[:8]
    jobs = home / "jobs"
    jobs.mkdir(parents=True, exist_ok=True)
    lock = jobs / "active.lock"
    try:
        descriptor = os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    except FileExistsError:
        raise RuntimeError("Ein Auftrag läuft oder muss nach einem Abbruch geprüft werden; vorhandene Sperre bleibt erhalten")
    root = jobs / job_id
    started = time.monotonic()
    record = {"id": job_id, "name": recipe["name"], "project": recipe["project"], "status": "running",
              "started": dt.datetime.now().astimezone().isoformat(), "steps": [], "cost_class": "local_compute",
              "limits": {"timeout_seconds": recipe.get("timeout", 900), "max_commands": 12, "retries": 0},
              "external_calls_by_runner": 0, "network_isolated": False, "chat_tokens": None,
              "log": str(root / "output.log")}
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump({"pid": os.getpid(), "job_id": job_id}, handle)
        root.mkdir()
        write_json(root / "job.json", record)
        if on_started:
            on_started(summary(record))
        deadline = started + recipe.get("timeout", 900)
        stop = root / "cancel.request"
        with (root / "output.log").open("w", encoding="utf-8") as log:
            for step in recipe["steps"]:
                state = {"action": step["id"], "status": "running"}
                record["steps"].append(state)
                write_json(root / "job.json", record)
                step_deadline = min(deadline, time.monotonic() + step.get("timeout", 600))
                for item in step.get("inputs", []):
                    if not Path(item).exists():
                        raise FileNotFoundError("Voraussetzung fehlt: " + item)
                for command in step["commands"]:
                    if stop.exists():
                        state["status"] = "cancelled"
                        break
                    if time.monotonic() >= step_deadline:
                        state["status"] = "timed_out"
                        break
                    log.write(json.dumps({"action": step["id"], "argv": command}, ensure_ascii=False) + "\n")
                    log.flush()
                    state.update(execute(command, step["cwd"], log, step_deadline, stop.exists))
                    if state["status"] != "passed":
                        break
                write_json(root / "job.json", record)
                if state["status"] != "passed":
                    record["status"] = state["status"]
                    break
            else:
                record["status"] = "passed"
    except BaseException as error:
        record.update(status="cancelled" if isinstance(error, KeyboardInterrupt) else "failed", error=str(error)[:600])
        if record["steps"] and record["steps"][-1]["status"] == "running":
            record["steps"][-1]["status"] = record["status"]
    finally:
        try:
            record["finished"] = dt.datetime.now().astimezone().isoformat()
            record["duration_seconds"] = round(time.monotonic() - started, 3)
            write_json(root / "job.json", record)
        finally:
            lock.unlink(missing_ok=True)
    return record
