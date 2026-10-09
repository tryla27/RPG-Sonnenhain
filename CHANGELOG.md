# Changelog

Die ausführlichen historischen Release-Notizen wurden unter `docs/archive/releases/` archiviert.

Neue Änderungen sollen ab jetzt in dieser Datei zusammengefasst werden. Detaildokumente zu größeren Umbauten können zusätzlich unter `docs/` liegen.

## Unreleased

- Fusionsregel D1: `components/fusion_cast.gd` plant Träger, Zündmarke,
  Träger-Impuls und Zündlimit. `cast_fusion_at_impact` (offline und Server)
  wirkt den Träger, markiert seine Geschosse und Zonen und zündet die
  Zweitfähigkeit am ersten Treffer (`trigger_fusion`, `execute_secondary_at`).
  `fusion_rules.gd` kennt nur noch `DAMAGE_IMPACT_POSITION` und
  `IMPULSE_IMPACT_POSITION`; alle Rezepte laufen als `CARRIER_IMPACT`.
  Reaktorwall (41) schickt einen Impuls. Test
  `tests/fusion/check_fusion_impact_origin.gd` spielt alle 528 Fusionen offline
  und auf dem Server durch. Vorschau `tools/capture_fusion_impact.gd`.
- Meistergaben anhand stabiler IDs repariert; alte Anhänger werden mit erhaltenen Werten im Halskettenplatz getragen.
- Dunkler Arkanhüter nach Kristallmoor versetzt (Gebietsstufe: 29 statt 43); Arenen, Beute, Quest und Kartenmarkierungen angepasst.
- Spawn und Wegsteine öffnen die Weltkarte; aktivierte Ziele starten per Kartenklick die bestehende, servergeprüfte Reise.
- Elara: breitere Kirche und zusätzliche Querpassage, Podest und aktuelle Kollisionsgrenzen bleiben erhalten.
- Pilzlinge verwenden weiterhin ausschließlich das saubere Giftzischen bei Freisetzung.

- Web-Ton repariert: Audio-Busse stehen jetzt in `default_bus_layout.tres`.
  Im Web-Export ohne Threads (Sample-Wiedergabe) bleiben zur Laufzeit per
  `AudioServer.add_bus()` angelegte Busse stumm; im Browser gemessen (Spitze 0
  vorher, Musik und Klicks hörbar nachher). `check_sound_bank` prüft das Layout.
- Neues Modul `components/menu_feedback.gd`: Rückfrage vor dem Verlassen
  (`leave_game`), Klickklang für jeden sichtbaren `ui_button`
  (`handle_panel_click` umschließt jetzt `panel_click`). Test
  `tests/ui/check_menu_feedback.gd`.
- Untere HUD-Leiste ohne Hintergrund (`HudLayout.draw_hud_button`,
  `draw_skill_slot`).
- Konzept-Paket 2: Patch Notes als klickbare Überschriftenliste
  (`components/patch_notes.gd`, Zustand `patch_view`), schlankes HUD in
  `components/hud_layout.gd` (Balken, Questzeile unten, XP-Linie, Kartenname
  unter der Minimap). `server_save_client.problem` steuert die Speicherzeile.
  `quest_guide.draw_hud_hover` nimmt eine Position. Test
  `tests/ui/check_hud_slim.gd`, Vorschau `tools/capture_hud.gd`; HUD-Textsuchen
  in `tools/check_content.py` entfernt, `check_quest_guide.gd` klickt die neue
  Questzeile.
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
