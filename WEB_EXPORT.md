# Sonnenhain im Browser hosten

Der einzige Web-Exportordner im Repository ist jetzt `docs/`.
Er besitzt eine `.gdignore`, damit Godot den fertigen Browser-Build nicht erneut als Projektressourcen importiert.

## Export

1. Das Projekt in Godot 4.7.2 öffnen.
2. Unter **Editor → Exportvorlagen verwalten** die passenden Exportvorlagen installieren.
3. **Projekt → Exportieren → Web → Projekt exportieren** wählen.
4. Als Ziel `docs/index.html` verwenden.
5. Den gesamten Inhalt von `docs/` auf den Webhost laden.

Website:
https://sonnenhainrpg.de/

Server-Ziel:
`/home/sites/site100047525/web/htdocs/sonnenhainrpg.de/`

PowerShell-Upload:
```powershell
scp -r "C:\Users\angel\OneDrive\Dokumente\GitHub\RPG-Sonnenhain\docs\*" ssh300011111@ngcobalt378.manitu.net:/home/sites/site100047525/web/htdocs/sonnenhainrpg.de/
```

## Projektstruktur

- Kein Web-Build mehr im Projekt-Root.
- Kein zweiter Build mehr unter `web/`.
- `docs/` ist die einzige deploybare Web-Ausgabe.
- `music/source/` bleibt als Entwicklungsquelle erhalten.
- Nicht benötigte WAV-Duplikate von OGG-Musikstücken wurden entfernt.

## Spielstände

Browser-Spielstände liegen in Godots `user://`-Speicher des Browsers und werden durch einen normalen Austausch der Web-Build-Dateien nicht absichtlich gelöscht. v28 besitzt zusätzlich eine Save-Migration mit Backup für ältere Spielstände.
