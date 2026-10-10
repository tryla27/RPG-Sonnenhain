# Dunkler Golem – Umsetzung (10.10.2026)

Vorgaben: `docs/konzepte/2026-10-09-golem/KONZEPT.md` und Angelos Antworten.
Vorschau: `golem.png` (erzeugt mit `tools/capture_dark_golem.gd`).

## Was drin ist

| Vorgabe | Umsetzung |
|---|---|
| Name, Größe | „Dunkler Golem“ (Typ 27), gezeichnet 4× Mob-Maßstab ≈ 5× Spieler, ≈ 430 px breit |
| Aussehen | schwarzer Basalt, lila Elixier-Risse, gesprungene Gesichtsplatte mit zwei Spalten, schwebende Steine über den Schultern (eigener Entwurf, keine Kopie) |
| Beschwörung | Altar im Himmelsgarten (14900, 8650), E genügt; online prüft der Server Abstand und ob schon ein Golem lebt. **Opfergaben vorerst aus** (Angelo 10.10., zum Testen): geplant 30 Steinbeeren + 1 Rotkuchen + 1 Blaukuchen, einschalten mit `SUMMON_COST = PLANNED_SUMMON_COST` in `golem_boss.gd` |
| Musik | Thema `boss_golem`: `music/boss_golem.ogg`, bis Angelos Lied da ist die Bossmusik |
| Bewegung | langsam (40), Schritt- und Schabgeräusche |
| Schild | stoppt, krümmt sich, −99 % Schaden für 8 s, Abklingzeit 30 s |
| Steinhagel-Feld | direkt mit dem Schild, Radius 320 px (20 m), 12 s, Einschläge mit Vorwarnung; im Feld +30 % Tempo und Verlangsamung halb so stark |
| Brockenwurf | alle 10 s: 1 s Schaben (Warnstreifen), Brocken fliegt 480 px und rollt 96 px, reißt Spieler und Gegner mit, wirft Bäume um, bleibt liegen bis zum nächsten Golem (höchstens 24) |
| Bäume | stehen nach 10 Minuten wieder |
| Schrei | einmal unter 40 %: Pause, dann trifft eine Welle jeden Spieler im Himmelsgarten (25 % Leben) |
| Tod | zerfällt sichtbar in Einzelteile und in zwei halbe Golems (Typ 28, halbe Größe, halbes Leben, halber Schaden) |
| Begleiter | alle 8 s bis zu 3 Himmelsfalter (Fernkampf), höchstens 10 gleichzeitig |
| Beute | jeder Beteiligte bekommt die Golem-Rüstung (100 Schutz) ins Inventar (online) bzw. als Beute (allein); nirgends zu kaufen |

## Werte (Balance, zum Nachjustieren)

- Leben: 7200 × Stufenfaktor (Stufe 40 → ×5,6 ≈ 40.300), je weiterem Spieler +70 %. Hälften je die Hälfte (≈ 20.200). Zu zweit zusammen ≈ 137.000.
- Schaden: Grundschaden `enemy_damage(27)` ≈ 233; Stampfer ×0,85 (0,6 s Ansage mit Ring, 4 s Abklingzeit, ausweichbar), Brocken ×1,0, Hagel ×0,3; Hälften ×0,5.
- Himmelsfalter: alle 8 s bis zu 3, höchstens 10 (bewusst schwer, Angelo 10.10.).
- Alles in `components/golem_boss.gd` oben als Konstanten.

## Technik

- Der Server rechnet den Kampf (`update_dedicated_enemies`), Spieler bekommen
  ihn im Weltpaket (`golem` oben im Paket, Golem-Zustand je Gegnerzeile).
  Geräusche auf Clients entstehen aus Zustandswechseln.
- Brocken und umgeworfene Bäume bleiben über Serverneustarts erhalten
  (`golem_world.json` neben den Spielständen), allein im Spielstand.
- Ein echtes 3D-Modell mit Physik-Ragdoll ist nicht Teil davon; der Zerfall ist
  ein Bild aus Einzelteilen mit Schwerkraft. 3D kommt mit D2.
