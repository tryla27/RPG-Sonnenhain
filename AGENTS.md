# Arbeitsregeln für Sonnenhain

Diese Regeln gelten für alle, die am Projekt arbeiten, ob Mensch oder KI-Assistent
(Claude, Codex, …). Sie sorgen dafür, dass neuer Code an der richtigen Stelle
landet und `main.gd` nicht weiter wächst.

## 1. Neuer Code gehört nicht in `main.gd`

`main.gd` ist mit über 13.000 Zeilen zu groß. Neue Systeme, Regeln und Daten
kommen in eigene Dateien unter `components/`. In `main.gd` steht höchstens die
Verdrahtung: ein `preload`, ein Aufruf, ein Feld für den Zustand.

Wenn du ohnehin an einer Stelle in `main.gd` arbeitest und die Logik dort klar
abgrenzbar ist, löse sie bei der Gelegenheit heraus (siehe Abschnitt 4).

## 2. Wohin gehört was?

| Art von Änderung | Ort |
|---|---|
| Gegner, Fähigkeiten, Quests, NPCs, Händler, Weltereignisse, Wahrzeichen, Wege, Torbogen | `components/game_content.gd` |
| Gegenstände, Beute, Stapel, Verkaufswerte, Elementfarben | `components/item_rules.gd` |
| Gebietsgrenzen, Wegabstand, Wegsteine, Klassenboss-Orte | `components/world_geometry.gd` |
| Koop-Einladungscodes, Prüfung eingehender Netzwerkdaten | `components/network_codec.gd` |
| Fusionen | `components/fusion_*.gd` |
| Halsketten | `components/arcane_necklaces.gd` |
| Mob-Kampf und -Navigation | `components/mob_combat.gd`, `components/mob_navigation.gd` |
| Monsteraussehen und Animationen | `components/monster_design_32.gd`, `components/woodland_*.gd`, `components/wolf_animation.gd` |
| Dorf (Gebäude, Wege, Innenräume, Objekte) | `components/village_*.gd` |
| Gelände und Boden | `components/terrain/` |
| Speichern | `components/local_save_store.gd`, `components/server_save_*.gd` |
| Patch Notes für Spieler | `components/patch_notes.gd` |
| Neues Thema ohne passende Datei | neue Datei `components/<thema>.gd` |
| Grafik, Klänge, Musik | `art/`, `audio/`, `music/` |
| Konzepte, Pläne, Entscheidungen | `docs/` |
| Tests | `tests/<bereich>/check_<thema>.gd` |
| Build- und Prüfwerkzeuge | `tools/` |

Gibt es schon eine passende Datei, erweitere sie, statt eine zweite für dasselbe
Thema anzulegen.

## 3. Wie ein Modul aussieht

- `extends RefCounted`, kurzer Kommentar oben: Was liegt hier, was nicht.
- Regeln und Daten möglichst **zustandslos**: `static func` und `const`. Was an
  Spielzustand gebraucht wird (Stufe, Klasse, nächste UID, …), wird als Parameter
  übergeben, nicht aus `main.gd` gelesen.
- Systeme mit eigenem Zustand (z. B. `food_system.gd`, `essence_system.gd`)
  bekommen `snapshot()` und `restore()` für Speichern und Laden.
- In `main.gd` einbinden mit `const Name=preload("res://components/<datei>.gd")`.

## 4. Bestehenden Code aus `main.gd` herauslösen

1. Bisherige Namen in `main.gd` behalten: Konstanten als Alias
   (`const X := Modul.X`), Methoden als einzeilige Weiterleitung. So bleiben
   Aufrufer, Unterklassen und Tests unverändert.
2. Methoden, die Tests überschreiben (z. B. `region_at`), werden innerhalb von
   `main.gd` weiter über die eigene Methode aufgerufen.
3. Vorher prüfen, dass alt und neu dasselbe liefern, auch bei kaputten Eingaben.
   Bei Zufall vor beiden Läufen dieselbe Saat setzen (`seed(...)`).
4. Einen Verhaltenstest für das neue Modul unter `tests/` anlegen.

Der Gesamtplan steht in `docs/architecture/main-modularization.md`.

## 5. Tests

- Neue Tests prüfen **Verhalten** (Funktion aufrufen, Ergebnis prüfen), nicht ob
  bestimmter Codetext in einer Datei steht. Solche Textsuchen brechen bei jedem
  Umbau, obwohl das Spiel noch funktioniert.
- Alte Textsuchen, die bei einer Änderung brechen, durch Verhaltensprüfungen
  ersetzen statt den gesuchten Text wiederherzustellen.
- Testdateien heißen `check_*.gd`. Die CI findet alles unter `tests/` automatisch.
- Vor dem Commit: alle Tests und `python3 tools/check_content.py` laufen lassen.

## 6. Git und Veröffentlichung

- `.gd`-Änderungen über einen eigenen Branch und Pull Request, damit die CI
  (Tests, Exporte, Server-Smoke-Test) vor dem Merge läuft.
- `[deploy]` in der Commit-Nachricht auf `main` liefert Website und Spielserver
  aus. Nur verwenden, wenn der Stand wirklich live gehen soll.
- Spielrelevante Änderungen in `components/patch_notes.gd` eintragen (die CI
  verlangt das bei Pull Requests), Entwicklerinfos in `CHANGELOG.md`.
- Von Godot erzeugte `.uid`- und `.import`-Dateien nur committen, wenn sie zu
  einer neu hinzugefügten Datei gehören, die das Projekt so verwendet. Nicht
  nebenbei mitcommitten, was ein lokaler Import verändert hat.
- Nächste Ziele und Entscheidungen stehen in `docs/NAECHSTE_ZIELE.md`. Nach
  Abschluss eines Ziels dort aktualisieren.
