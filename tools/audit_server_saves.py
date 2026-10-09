"""Prüft Server-Spielstände auf Vermischung durch Charakterwechsel (nur lesen).

Läuft auf dem Spielserver: python3 - <spielstand-ordner> <spec-base64> < audit_server_saves.py
Gibt einen Markdown-Bericht aus. Tokens und Dateinamen erscheinen nicht.

Hinweise auf Vermischung (Fehler A1, behoben am 9.10.2026):
- abgeschlossene Quests, deren Zielgebiet weit über der Charakterstufe liegt
- besiegte Klassenbosse weit über der Charakterstufe
- zwei Charaktere mit identischem, nicht trivialem Quest- und Ereignisstand
"""
import base64
import json
import sys
from pathlib import Path

MARGIN = 3  # so viele Stufen über der eigenen Stufe gelten noch als möglich


def load_records(directory: Path):
    for path in sorted(directory.glob("*.json")):
        try:
            record = json.loads(path.read_text())
        except Exception:
            continue
        data = record.get("data")
        if isinstance(data, dict):
            yield record, data, path.stat().st_mtime


def main():
    directory = Path(sys.argv[1])
    spec = json.loads(base64.b64decode(sys.argv[2]))
    rows, flagged, fingerprints = [], [], {}
    for record, data, mtime in load_records(directory):
        name = str(data.get("hero_name", "?"))[:16]
        level = int(data.get("level", 1) or 1)
        quests = data.get("quests", []) or []
        bosses = data.get("bosses_defeated", []) or []
        events = data.get("event_states", []) or []
        done = [i for i, q in enumerate(quests) if isinstance(q, dict) and int(q.get("state", 0)) >= 3]
        too_high = [spec["quests"][i]["title"] for i in done if i < len(spec["quests"]) and spec["quests"][i]["level"] > level + MARGIN]
        boss_high = [spec["bosses"][i]["name"] for i, b in enumerate(bosses) if b and i < len(spec["bosses"]) and spec["bosses"][i]["level"] > level + MARGIN]
        state = json.dumps([[int(q.get("state", 0)) for q in quests if isinstance(q, dict)], events, bosses])
        if len(done) >= 3:
            fingerprints.setdefault(state, []).append(name)
        row = {"name": name, "uuid": str(record.get("uuid", ""))[:8], "level": level, "class": data.get("class_id", "?"),
               "done": len(done), "bosses": sum(1 for b in bosses if b), "revision": record.get("revision", 0),
               "too_high": too_high, "boss_high": boss_high}
        rows.append(row)
        if too_high or boss_high:
            flagged.append(row)
    twins = {k: v for k, v in fingerprints.items() if len(v) > 1}
    print(f"# Prüfung der Server-Spielstände\n\n{len(rows)} Charaktere geprüft, {len(flagged)} auffällig, {len(twins)} Gruppen mit identischem Stand.\n")
    print("## Auffällig (Fortschritt über der eigenen Stufe)\n")
    if not flagged:
        print("Keine.\n")
    for r in flagged:
        print(f"- **{r['name']}** ({r['uuid']}), Stufe {r['level']}: Quests {', '.join(r['too_high']) or '–'}; Bosse {', '.join(r['boss_high']) or '–'}")
    print("\n## Identischer Quest-, Ereignis- und Bossstand\n")
    if not twins:
        print("Keine.\n")
    for names in twins.values():
        print("- " + ", ".join(names))
    print("\n## Alle Charaktere\n\n| Name | ID | Stufe | Klasse | Quests fertig | Bosse | Revision |\n|---|---|---|---|---|---|---|")
    for r in rows:
        print(f"| {r['name']} | {r['uuid']} | {r['level']} | {r['class']} | {r['done']} | {r['bosses']} | {r['revision']} |")


if __name__ == "__main__":
    main()
