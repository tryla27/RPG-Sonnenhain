# Changelog

Die ausführlichen historischen Release-Notizen wurden unter `docs/archive/releases/` archiviert.

Neue Änderungen sollen ab jetzt in dieser Datei zusammengefasst werden. Detaildokumente zu größeren Umbauten können zusätzlich unter `docs/` liegen.

## Unreleased

- Dunkler Golem: `components/golem_boss.gd` (Altar, Schild, Steinhagel-Feld,
  Brockenwurf mit liegenden Brocken und umgeworfenen Bäumen, Schrei, Zerfall in
  zwei Hälften, Himmelsfalter-Wellen, Netzpaket, Speichern) und
  `components/golem_design.gd` (Bild). Gegnertypen 27/28, Server rechnet den
  Kampf, Brocken/Bäume in `golem_world.json` neben den Spielständen. Klänge
  `audio/sfx/golem/` (`tools/build_sfx.py`), Musikthema `boss_golem`
  (`music/boss_golem.ogg`, bis dahin Bossmusik). Test
  `tests/gameplay/check_dark_golem.gd`, Bild `tools/capture_dark_golem.gd`.
- Legendäre Rüstungen: `components/master_armor.gd` (Daten, Wirkungen),
  Aussehen 6–12 in `rpg_hero.gd`, Torvald ab Stufe 40, Drops (Klassenbosse 10 %,
  Elite ab Stufe 33 2 %), Dornen/Lebensraub auf dem Server. Test
  `tests/gameplay/check_master_armor.gd`, Bild `tools/capture_master_armor.gd`.
- Shop: `components/shop_trade.gd` (Menge, Gesamtwerte), `buy_items`,
  `sell_items`, `shop_quick_buy` (Enter über Angebot), `sell_all_preview`.
  Test `tests/ui/check_shop_trade.gd`, Bilder `tools/capture_shop_trade.gd`.
- Bosshüte sichtbar: `head_visual()` liefert 3–5 für Bosshüte,
  `RpgHero.paint_boss_hat`, Netzwerk-Grenze für `head` auf 5. Vorschau
  `tools/capture_boss_hats.gd`, Test `tests/gameplay/check_boss_hat_visual.gd`.
- Umbenannt: Stein-/Kristall-/Lavagolem → -wächter; Roter Sonnenkuchen →
  Rotkuchen, Blauer Mondkuchen → Blaukuchen (`FoodSystem.RENAMED`,
  `normalize_item` für Inventar und Shopbestand beim Laden). Test
  `tests/gameplay/check_renamed_items.gd`.
- Spell-Grenze 4 (`components/spell_return.gd`, `buy_skill`, Skill-Gegenstände)
  und Abgabe bei Borin (Panel `spell_return`, `give_back_spell`, 10 Sprüche).
  Abgegebene Fusionen werden auch aus `fusion_history` entfernt, weil die
  Verlaufs-Migration sie sonst beim Laden zurückholt. Test
  `tests/gameplay/check_spell_limit.gd`, Bilder `tools/capture_spell_return.gd`.
- Nebel schneller: Weltkarten-Overlay als `ImageTexture` (1 px je Zelle,
  einzelne Pixel bei `set_seen`), Dunkelheitsnetz gecacht nach Ausschnitt und
  `version`. Gemessen lokal: Karte 44 → 17 ms, Spielbild 17 → 12 ms pro Bild.
- Weltpaket pro Spieler nur mit Gegnern, Geschossen und Beute im Umkreis von
  2600 px (`components/world_snapshot.gd`), WebSocket-Puffer auf 1 MiB.
  Ursache für eingefrorene Gegner und fehlende Bosse: Pakete über 64 KiB
  scheiterten mit `ERR_OUT_OF_MEMORY`. Test
  `tests/network/check_world_snapshot_size.gd` (schlägt mit altem Code fehl).
- Server: `SERVER_HEARTBEAT` jede Minute (Spieler, je Klassenboss nächster
  Spieler, Boss-Abstand zum Feld, Abklingzeit) über stderr, damit es ungepuffert
  im Log landet; `BOSS_*` ebenso. `diagnose-server.yml` zeigt die letzten Zeilen.
- Klassenbosse: Spawn zählt nur einen Boss im eigenen Feld
  (`class_boss_home_ok`), Streuner werden entfernt und geloggt
  (`BOSS_STRAY_REMOVED`, `BOSS_SPAWN`). Test
  `tests/gameplay/check_class_boss_stray.gd`. Neuer Workflow
  `diagnose-server.yml` (nur lesen) für Fehler- und Boss-Meldungen im Serverlog.
- Neue Wegsteine: Plateau-Grafik aus `tools/build_waystone_art.py`
  (`art/village/objects/wegstein-plateau.png`, `wegstein-obelisk.png`), Maße,
  Begehbarkeit (nur über die Treppe) und Zeichnen in
  `components/waystone_shrine_32.gd`. Deko, Fackeln und Ankunftspunkte meiden
  das Plateau; Geschosse stoppen nur am Obelisk. Test
  `tests/gameplay/check_waystone_plateau.gd`, Bilder `tools/capture_waystone_plateau.gd`.
- Hut des Jagdmeisters: „Ewige Pfeile“ (`HeadgearRules.eternal_arrows`), normale
  Schützenpfeile leben 8 s statt 1,2 s und enden beim ersten Treffer. Server
  liest `eternal_arrows` aus dem Spielerzustand. Test
  `tests/gameplay/check_eternal_arrows.gd`.
- Startmenü mit Konto: Speicherplätze aus `account_characters` statt lokaler
  Dateien, Laden über `open_account_character` (`components/account_slots.gd`).
  Test `tests/ui/check_account_start_slots.gd`.
- C1 Start im Dunkeln: `WorldFog` auf 64-px-Zellen, Sicht 640 px, Gruppe nur
  bis 1600 px. Neues Spielstandfeld `world_fog_fine` (Base64), `world_fog`
  bleibt als grobes 256-px-Feld; alte Stände werden beim Laden hochgerechnet.
  Dunkelheit im Spielbild als Dreiecksnetz mit Eckfarben (weicher Rand),
  Minikarte und Weltkarte dunkel. Server: `valid_snapshot`, Feldgrenze 80 → 96.
  Test `tests/gameplay/check_dark_start.gd`, Bilder `tools/capture_dark_start.gd`.
- B2 Tippgeräusch: `ui_tippen` (3 Varianten) und `ui_tippen_loeschen` in
  `tools/build_sfx.py`/`sound_bank.gd`, Regel in `components/typing_sound.gd`
  (max. 25 Anschläge/s), verdrahtet in Konto, Koop-Code, Name und Chat über
  `typing_feedback()`. Test `tests/audio/check_typing_sound.gd`.
- A1 Charakterwechsel: `reset_character_state()` (auch von `start_new_game`
  genutzt) vor jedem Laden eines anderen Charakters, `WorldFog.clear()`,
  Gruppe beim Trennen geleert, kein Autosave während des Ladens. Test
  `tests/gameplay/check_character_switch.gd` (schlägt mit altem Code fehl).
- Schritte je Untergrund: 10 Klänge × 4 Varianten unter `audio/sfx/schritte/`,
  `ground_surface_at` (Dorf über sichtbare Bodenfamilie, Spawnstein, Wege,
  Gebiete, innen/Gewölbe/Arena), Test `tests/audio/check_footsteps.gd`.
- `draw_village_ground` (halbtransparente Grundstücksrahmen) entfernt.
- Kapelle: Gangverbreiterung zeigt freien Steinboden in Originalgröße statt
  eines gedehnten Streifens (`ELARA_FLOOR_BAND_Y`, `ELARA_AISLE_*`).
- `components/foliage.gd`: Busch-Erkennung für Blütenbüsche, Kräuter,
  Hindernis- und Streubüsche; Test `tests/audio/check_bush_rustle.gd`.
- `teleport_brummen` (nahtlose Schleife, Umgebungs-Bus) mit
  `SoundBank.spawn_hum_gain`; Steuerungszeile entfernt; Knopf „WEITER“.
- Werkzeug `tools/capture_village_spots.gd` für Bildschirmfotos an Dorfstellen.
- Fusionsregel nachgeschärft (Angelo): Zündlimit 5 statt 3; Sprungangriff als
  Partner bewegt den Spieler beim Wirken weiter (`perform_jump_movement`,
  `FusionCast.jumps_at_cast`).
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
