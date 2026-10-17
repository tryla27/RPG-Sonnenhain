# Werkzeugzentrale – Prüfstand und Übergabe

Stand: 17.10.2026, abends. Version `2.0-paket1` (`tools/werkzeugzentrale/hub.py`).

## Umgesetzt (Paket 0 und 1 des Umsetzungsplans)

- Code liegt im Spiel-Repository unter `tools/werkzeugzentrale/` (Branch
  `feature/werkzeugzentrale-v2`), Doku unter `docs/werkzeugzentrale/`.
  Maschinenpfade (`config.local.json`) und Auftragsdaten (`jobs/`) sind per
  `.gitignore` ausgeschlossen. `.gdignore` hält Godot aus dem Ordner heraus.
- Feste Aktionen (`recipes.py`), keine dynamischen Agentenrezepte.
- Gemeinsame monotone Gesamtdeadline (höchstens 1200 s), Schrittdeadline,
  höchstens 12 Befehle, 0 automatische Wiederholungen.
- Prozessbaum je Befehl: Windows Job Object (`KILL_ON_JOB_CLOSE`) bzw.
  POSIX-Prozessgruppe. Der Werkzeugbefehl startet erst nach der Zuordnung
  (Startbyte über `worker.py`). Zeitüberschreitung, Stopp und Runnerabsturz
  beenden eigene Kindprozesse; fremde Prozesse bleiben.
- Abbruch über `hub.py cancel <job-id>` und die STOP-Schaltfläche
  (gemeinsamer Weg über `cancel.request`).
- Kostenklasse ist Pflicht; nur `local_compute` läuft. Dauerprozesse (Spiel,
  ComfyUI-Dienst) und KI-Generierung sind gesperrt, bis Dienst- und
  Queueverwaltung einen kontrollierten Stopp können.
- Auftragssperre `jobs/active.lock`; eine vorhandene Sperre wird nie entfernt.
- Statusdateien atomar ersetzt; unter Windows kurz gesperrte Dateien beim
  Schreiben und Lesen mit höchstens 40 Versuchen à 50 ms (≈ 2 s), danach ein
  sichtbarer Fehler. Behebt den beim Abbruchtest gefundenen Sperrfehler
  (gleichzeitiges Lesen durch das Fenster und Ersetzen durch den Runner).
- Ausgaben für den Agenten auf 4 KiB begrenzt; volle Logs bleiben lokal.

## Geprüft

- 17.10. (Windows, vorheriger Agent): Versionsabfragen von Godot, Blender,
  Inkscape und Krita über den Runner; Zeitlimit- und Runnerabsturz-Test
  beenden eigene Kindprozesse. Fenster startet.
- 17.10. abends (Linux-Container): 17 von 18 Runner-Tests bestanden, der
  Windows-Crashtest ist dort übersprungen. Neu: kurz gesperrte Statusdatei,
  dauerhaft gesperrte Datei mit begrenztem Abbruch, halb geschriebene Datei,
  gleichzeitiger Leser während eines laufenden Auftrags.
- Die Runner-Tests laufen in der CI (`ci.yml`) und in `tools/run_all_tests.sh`.

## Offen (nächste Schritte)

1. **Auf Windows nachprüfen** (PC): alle 18 Tests einschließlich
   Job-Object-Crashtest und echtem Abbruch, während das Fenster läuft:
   ```powershell
   cd <Spiel-Checkout>\tools\werkzeugzentrale
   python -m unittest -v test_runner
   ```
2. **Alten Einstieg umstellen:** `E:\Sonnenhain-Tools\werkzeugzentrale\` (v1)
   als Weiterleitung auf `tools/werkzeugzentrale/START.ps1` des Checkouts;
   alte Oberfläche (Fenster „Sonnenhain · Werkzeugzentrale“) vorher schließen.
   `config.local.json` mit `project` und `tools_root` anlegen
   (Vorlage `config.example.json`).
3. **Paket 2** laut Umsetzungsplan: Fingerabdruck je Auftrag, Doppelstartschutz,
   Prozessbesitz über PID und Startzeit, Zustand `unknown` nach Neustart.
4. ComfyUI: `/system_stats` antwortete nicht; keine API-Verbindung und keine
   Generierung nachgewiesen.
5. Vollständigen Workflow `grafikpaket` mit echten Ausgaben ausführen und
   Bilder beurteilen (erst nach Paket 3: Ausgaben getrennt prüfen, dann übernehmen).

Nicht behauptet: Netzwerkisolation, Messung oder Begrenzung von Chat-Token,
Schutz vor Netzwerkzugriffen gestarteter Programme.
