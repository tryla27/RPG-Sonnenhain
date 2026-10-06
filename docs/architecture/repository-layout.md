# Repository-Struktur

Sonnenhain trennt ab jetzt Quellcode, Dokumentation und generierte Builds klar voneinander.

## Quellbaum

- `main.gd`, `main.tscn`, `components/`: aktive Godot-Laufzeit
- `art/`: Spielgrafik
- `audio/`: Soundeffekte und bestehende Audiodateien
- `music/`: Musik und Quellen
- `server/`: serverbezogene Dateien
- `tools/`: Tests, Prüf- und Build-Helfer
- `website/`: Website-Quellen
- `web-legal/`: rechtliche Website-Seiten
- `docs/`: Architektur, Mechaniken, Deployment, Design, Recht und Archiv
- `.github/workflows/`: CI/CD

## Generierte Dateien

Godot-Exports werden ausschließlich nach `build/` geschrieben. Der Ordner ist ignoriert und wird von CI/CD bei Bedarf neu erzeugt.

Insbesondere gehören folgende Dateien nicht mehr ins Repository:

- `index.wasm`
- `index.pck`
- `index.js`
- generierte Godot-HTML-/Icon-/Worklet-Dateien
- der alte Ordner `web/`

Der produktive Website-Workflow exportiert weiterhin frisch nach `build/site/game/`. Das Verhalten des Live-Deployments ändert sich dadurch nicht.

## Zielstruktur für die Laufzeit

Die bestehende Laufzeit bleibt zunächst pfadkompatibel. Neue Systeme sollen jedoch nach Verantwortung getrennt werden:

- Spieler/Bewegung
- Kampf
- Zauber und Fusion
- Welt und Navigation
- Multiplayer
- Save/Load
- UI
- Audio
- Daten und Balancing

Große Pfadverschiebungen werden erst vorgenommen, wenn alle direkten `res://main.gd`-Abhängigkeiten in Tests und Renderer schrittweise entfernt sind.
