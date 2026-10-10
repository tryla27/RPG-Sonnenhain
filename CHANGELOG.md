# Changelog

Die ausführlichen historischen Release-Notizen wurden unter `docs/archive/releases/` archiviert.

Neue Änderungen sollen ab jetzt in dieser Datei zusammengefasst werden. Detaildokumente zu größeren Umbauten können zusätzlich unter `docs/` liegen.

## Unreleased

- `access.php`: große Dateien ohne PHP-Zeitlimit (`set_time_limit(0)`), Ausgabe
  je MB geleert. `build_android_apk.sh` meldet Manifest und Signatur als
  Hinweise im Lauf.
- Android: Export-Preset „Android“ (arm64, ohne Gradle, `de.sonnenhainrpg.game`),
  `tools/build_android_apk.sh`, Workflow `build-android.yml`; `deploy-pages.yml`
  baut die APK mit und legt sie unter `/download/sonnenhain-rpg.apk` ab
  (Signatur aus Secrets `ANDROID_KEYSTORE_BASE64`/`ANDROID_KEYSTORE_PASSWORD`/
  `ANDROID_KEY_ALIAS`, sonst Wegwerf-Signatur). Website: `/mobile/` mit Download
  und Anleitung, Startseite verlinkt die App. `access.php` liefert `.apk` als
  Download. `project.godot`: Querformat auf Handys, ETC2/ASTC-Import.
- `GameContent.PORTALS`: sechster Torbogen Ascheberge (10550, 600) ↔
  Nebelheide (12300, 520). Rückseite eines Torbogens zeigt Ziel und Siegel des
  Ausgangsgebiets; Rückweg in versiegelte Gebiete gesperrt. `check_content.py`
  prüft jetzt „jedes Ostgebiet erreichbar“. Test `check_ascheberge_portal.gd`,
  Vorschau `tools/capture_portal_ascheberge.gd`.
- Waldschleim: `components/forest_slime_motion.gd` (Körper/Blatt aus
  `tools/build_slime_parts.py`, stufenloser Hüpfbogen, verzögertes Blatt) in
  `WoodlandArt.paint` für Laufen/Stehen; Angriff/Treffer/Tod weiter Bilder.
- Himmelsfalter (Typ 25): `components/himmelsfalter_art.gd` statt Block-Ersatz
  aus `MobDesign32`, Sternenstaub-Schuss in den Gegnergeschossen.
- Bewegte Vorschau: `tools/capture_slime_moth.gd`, `tools/make_gif.py`.
  Test `check_slime_moth_motion.gd`.
- Bestätigten Golem-Hardtekk-Loop (120 s, erste 24 s fünfmal) unter `music/boss_golem.wav` eingebunden; Spawn und Hälften nutzen die bestehende Boss-Erkennung. Musikübergänge in `MusicPlayback` ausgelagert, Golem blendet über 6 s ein, andere Themen weiterhin über 1,35 s. Bearbeitbare Quelle und Loop-Prüfung unter `music/source/golem/`.

- Goldener Ritter: `tools/build_golden_warrior.py` erzeugt aus dem ersten
  Sprungbild jeder Richtung `knight_8dir.png` (64×80, 8 Richtungen × Stehen 4,
  Gehen 6, Laufen 6, Angriff 4, Treffer 2). `rpg_hero.gd`: `uses_knight`,
  `knight_row` (Richtungen nach Bildschirm wie die Dateinamen; `direction_index`
  zählt andersherum, die Sprungbilder liefen dadurch spiegelverkehrt bei
  Diagonalen/Seiten), `knight_frame`, `paint_knight` (Rolle/Sturz per Drehung),
  `knight_attack` aus main.gd. Sprung im richtigen Seitenverhältnis.
  Vorschau `tools/capture_golden_knight.gd`, Test `check_golden_knight.gd`.
- Krieger: `rpg_hero.gd` zeichnete die goldenen Sprites (Stehen, Sprung) an
  `p+offset` unter der bereits gesetzten Welt-Verschiebung → doppelt verschoben,
  unsichtbar. Jetzt `draw_set_transform(Vector2.ZERO)` davor. Standbild
  (`GOLDEN_IDLE_ENABLED=false`) abgeschaltet. Vorschau
  `tools/capture_warrior_ingame.gd`. Typ 28 heißt „Dunkler kleiner Golem“.
- Golem-Sprite: Zeile 3 im Blatt = Seite nach links (gespiegelt erzeugt);
  `draw_texture_rect_region` mit negativer Breite zeichnete nichts.
  Vorschau im echten Spielbild `tools/capture_golem_ingame.gd`.
- `GolemBoss.load_state`: liegengebliebene Brocken zerbröseln nach Neustart
  (`crumble`), Kampf gilt als beendet.
- Golem v2 Teil 2 (Optik): `tools/build_golem_art.py` erzeugt
  `art/monsters/golem/golem_sheet.png` + `golem_glow.png` (128 px, 3 Ansichten ×
  11 Bilder); `GolemDesign.draw_golem` zeichnet das Sprite (2,5×/1,25×),
  Trefferzonen angepasst (`HEAD_CENTER` −58 u). `GolemDesign.draw_stone`
  (feste Saat, 9–12 Ecken, Flächen, Dellen, Riss) für Brocken, Hagel, Trümmer.
  `tools/build_armor_icons.gd` rendert `art/items/legendary_armor_64.png`
  (3D, 7 × 64 px), `ItemStyle32` nutzt sie für Entwurf 6–12;
  `ItemRules.item_design` liefert für legendäre Rüstungen den Entwurf (vorher
  auf 11 gekappt, Golem-Rüstung zeigte das Sternenquell-Bild). Neue
  Golem-Rüstung am Charakter (`rpg_hero.gd`). Test `check_golem_art.gd`.
- Golem v2 Teil 1 (`components/golem_boss.gd`): Prozent-Schaden ohne Rüstung
  (`golem_hit_players(..., fraction)`, `rpc_golem_damage`, `apply_golem_damage`
  mit `damage_ignores_armor`), Trefferzonen `shot_zone`/`zone_mult` (Geschosse
  über `shot_hit_zone` in main.gd), A*-Wegsuche auf 64-px-Raster mit Budget,
  Sichtlinie gecacht, Ausweichen/Durchbrechen, `end_fight` mit Zerbröseln und
  `cooldown_until` (golem_world.json), Rücksetzen nach 5 min ohne Spieler,
  `lite_snapshot` außerhalb des Himmelsgartens, `net_info` ohne Wegdaten,
  `golem_trees_changed(key)` → `invalidate_static_area`, Server-Log
  `GOLEM_PERF` jede Minute. HP 8640/4320, Schaden 95/47. F3-Anzeige
  `components/perf_overlay.gd`. Tests `check_golem_v2.gd`, `check_perf_overlay.gd`,
  Netztest erweitert; Vorschau `tools/capture_golem_v2_combat.gd`.
- Einstellungen (`draw_pause_panel`): Pause-Titel, Backup Export/Import,
  „Speichern & zur Startseite“ und Oberflächen-Regler entfernt; UI-Klänge nutzen
  `effects_volume` (`ui_volume` bleibt im Speicherstand). Vorschau
  `tools/capture_settings_panel.gd`.
- 3D-Landschaft: `WorldObstacles3D.probe_report` → `report_3d_probe` →
  `rpc_client_3d_report` (Server-Log `CLIENT_3D`, in der Server-Diagnose sichtbar).
- Essensanzeige: `HudLayout.draw_effect_chips` (92×28-Kacheln, 4 pro Reihe,
  Details beim Darüberfahren) statt 348×58-Leiste. Test
  `tests/ui/check_effect_chips.gd`, Bild `tools/capture_food_chips.gd`.
- Nahrungsbüsche: `FoodSystem.configure` verteilt 8–12 Fruchtbüsche + 3 Kräuter
  je Gebiet (`spread_points`, `bush_spot_ok`, deterministisch). Alte Erntezeiten
  an den bisherigen drei Plätzen verfallen. Test
  `tests/gameplay/check_food_bushes.gd`, Bild `tools/capture_food_bushes.gd`.
- Spawn-Brummen aus (`SPAWN_HUM_ENABLED`). Vollbild: `DisplayMode.lock_escape`
  (Keyboard Lock im Browser), `EscapeCounter` für den F11-Hinweis.
  Ausrüstung: `toggle_equipment_item` tauscht neues und altes Teil im Inventar
  (`toggle_equipment_item_core` enthält die bisherige Logik). Infos für getragene
  Teile: `worn_item_at`, `worn_slot_rects`. Test
  `tests/ui/check_equipment_swap.gd`, Bild `tools/capture_worn_tooltip.gd`.
- Geschosse: `projectile_world_blocked` (Server) kennt jetzt Laternen, Zäune,
  Brett, Brunnen, Dorfbäume, Vorplätze und Wegstein-Obelisken; Clients nutzen in
  der Oberwelt dieselbe Regel. Eigene Online-Schüsse zerschellen lokal sofort
  (`local_projectile_breaks` gegen doppelte Server-Meldungen),
  `play_break_sound` + `projectile_material` (stein/metall/holz). Test
  `tests/gameplay/check_arrow_impacts.gd`.
- Golem-Klänge nach Angelos Wahl (Klangprobe Runde 1): `golem_schritt_klein`
  (halbe Golems, Probe B), `brocken_landen` = Probe B, `golem_schrei` mit zwei
  Varianten (bisher + Probe C), zufällig (`"random":true` im Katalog,
  `SoundBank.pick_variant`). Rezepte bleiben in `tools/build_golem_sfx_draft.py`,
  `tools/build_sfx.py` übernimmt sie mit gleicher Saat. Vorbereitet:
  `GolemBoss.HAIL_RAIN_SOUND` für einen langen Felsregen pro Feld.
- 3D-Landschaft: Rückfall auf 2D, wenn der 3D-Viewport nach 0,8 s keine
  Pixel zeigt (`WorldObstacles3D.active`, `probe`, `visible_pixels`; Log
  `OBSTACLES_3D_FALLBACK`). Alte Ostmauern zeichnen im Rückfall wieder.
  Test `tests/rendering/check_obstacles_3d_fallback.gd`, Bild
  `docs/design/obstacles-live-3d/rueckfall-2d.png`.
- Testmodus online: `valid_network_teleport` nimmt Kartenreisen von Spielern mit
  `test_mode` an (nur zu Wegstein-Ankunftspunkten), passend zu
  `WaystoneMap.source_valid`. Test `tests/network/check_testmode_travel.gd`.
- Golem-Altar auf der Karte: `GolemDesign.draw_map_marker`, Bild
  `tools/capture_golem_map_marker.gd`.
- Dunkler Golem: `components/golem_boss.gd` (Altar, Schild, Steinhagel-Feld,
  Brockenwurf mit liegenden Brocken und umgeworfenen Bäumen, Schrei, Zerfall in
  zwei Hälften, Himmelsfalter-Wellen, Netzpaket, Speichern) und
  `components/golem_design.gd` (Bild). Gegnertypen 27/28, Server rechnet den
  Kampf, Brocken/Bäume in `golem_world.json` neben den Spielständen. Klänge
  `audio/sfx/golem/` (`tools/build_sfx.py`), Musikthema `boss_golem`
  (`music/boss_golem.ogg`, bis dahin Bossmusik). Test
  `tests/gameplay/check_dark_golem.gd`, Bild `tools/capture_dark_golem.gd`.
- Golem online geprüft: `tools/check_dark_golem_network.gd` (Server + 3 Spieler
  über WebSocket: Beschwören, Kampf, Schrei, Zerfall, Rüstung nur für
  Beteiligte, `golem_world.json`). Golem ohne Rückstoß/Betäubung, Nahkampf
  rechnet seinen Körperradius ein. `server_action_allowed` blockt die erste
  Aktion kurz nach Serverstart nicht mehr.
- Golem-Balance (Angelo 10.10.): Stampfer mit 0,6 s Ansage (Ring am Boden),
  4 s Abklingzeit, Schaden ×0,85 statt ×1,3; Leben +20 % (7200/3600);
  Himmelsfalter bleiben bei höchstens 10.
- Golem vorerst ohne Opfergaben beschwörbar (`GolemBoss.SUMMON_COST` leer,
  geplante Kosten in `PLANNED_SUMMON_COST`). Test: Golem-Rüstung in keiner
  Laden-Rotation.
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

## 10.10.2026 – Echte 3D-Körper für Außenkarten

- 72 Landschaftsmotive für Maps 1–12 und sechs gemeinsame Mauermodule als echte ArrayMesh-Körper mit 64×64-Materialtexturen, 58 gelegentliche kurze Animationen.
- Gemeinsamer transparenter 3D-Viewport mit individuell animierten Instanzen; laufende Mesh-Projektionen werden mit Figuren und Wegsteinen nach Fußpunkt sortiert. Keine vorgerenderten Sprite-Dateien.
- Bestehende feste Kollisionspunkte und Kampfregeln bleiben zuständig; zusätzliche Pflanzen haben keine Collider. Map 0 inklusive ihrer Dorfgrenzen bleibt unverändert.
- Server und Innenräume erzeugen keine 3D-Viewports. Geometrie wird pro Motiv einmal erstellt und wiederverwendet; nur sichtbare Instanzen bleiben aktiv.
- Vorschauen und Architektur: docs/design/obstacles-live-3d/README.md. Nutzer hat diese Veröffentlichung ausdrücklich freigegeben.
