# Changelog

Die ausführlichen historischen Release-Notizen wurden unter `docs/archive/releases/` archiviert.

Neue Änderungen sollen ab jetzt in dieser Datei zusammengefasst werden. Detaildokumente zu größeren Umbauten können zusätzlich unter `docs/` liegen.

## Unreleased

- Sound-Paket 1: `components/sound_bank.gd` (Katalog, Audio-Busse, Stimmenlimits
  mit Vorrang, Varianten, Entfernungsdämpfung, Ducking, Monsterlaute aus dem
  Angriffszustand), Generator `tools/build_sfx.py`, 71 neue Dateien unter
  `audio/sfx/`, Test `tests/audio/check_sound_bank.gd`.
- Gegenstandsregeln (Gegenstands- und Beuteerzeugung, Stapelgrößen,
  Verkaufswert, Anzeigenamen, Elementfarben, Formvarianten) nach
  `components/item_rules.gd` ausgelagert, mit Verhaltenstest
  `tests/gameplay/check_item_rules.gd`. Die Sperr-Prüfung in
  `tools/check_inventory_sell_lock.gd` testet neue Gegenstände jetzt am Verhalten.
- Weltgeometrie (Gebietsgrenzen, Wegabstand, Wegsteine, Klassenboss-Arenen und
  -Häuser) nach `components/world_geometry.gd` ausgelagert, mit Verhaltenstest
  `tests/gameplay/check_world_geometry.gd`.
- Koop-Einladungscodes, Bereinigung fremder Quest-/Ereigniszeilen und
  Belohnungs-Payloads nach `components/network_codec.gd` ausgelagert, mit
  Verhaltenstest `tests/network/check_network_codec.gd`.
- Spielinhalte (Gegner, Fähigkeiten, Quests, NPCs, Händler, Weltereignisse,
  Wahrzeichen, Wege, Torbogen) aus `main.gd` nach `components/game_content.gd`
  ausgelagert; `main.gd` stellt sie unter denselben Namen weiter bereit.
- Repository- und Speicherstruktur bereinigt.
- Generierte Godot-Webexports aus dem Quellbaum entfernt.
- Dokumentation nach Themen geordnet.
- Zielarchitektur für die schrittweise Modularisierung von `main.gd` dokumentiert.

## Archiv

Siehe `docs/archive/releases/`.
