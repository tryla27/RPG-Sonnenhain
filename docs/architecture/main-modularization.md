# Plan zur Modularisierung von main.gd

`main.gd` ist derzeit die zentrale Laufzeitklasse und wird von zahlreichen Tests und Renderer-Helfern direkt geladen, erweitert oder sogar als Text geprüft. Ein sofortiges Verschieben oder Aufteilen würde deshalb viele Regressionstests und Laufzeitabhängigkeiten gleichzeitig brechen.

## Vorgehen

Die Modularisierung erfolgt schrittweise, ohne die öffentliche API von `main.gd` abrupt zu ändern.

1. Reine Daten und Konstanten in dedizierte Ressourcen/Module auslagern.
2. Zustandsarme Hilfsfunktionen in `components/` verschieben.
3. Systeme mit klaren Grenzen extrahieren:
   - Spell/Fusion
   - Combat
   - Save
   - Multiplayer
   - UI
   - Audio
   - World/Navigation
4. `main.gd` behält vorübergehend Wrapper-Funktionen, damit bestehende Tests stabil bleiben.
5. Tests von Textsuche in `main.gd` auf Verhaltensprüfungen bzw. Modul-APIs umstellen.
6. Erst danach die eigentliche Hauptszene und Datei in eine tiefere Ordnerstruktur verschieben.

## Ziel

`main.gd` soll langfristig nur noch Initialisierung, Zusammenschaltung und wenige globale Zustandsübergänge enthalten. Gameplay-Logik, Daten und Rendering sollen in klar benannte Module ausgelagert sein.
