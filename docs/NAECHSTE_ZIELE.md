# Sonnenhain – nächste Ziele

16.10.2026 · Umsetzung: Erstes Grafik-/Leistungspaket lokal eingebaut und
geprüft. Stabile Atlasseiten, Minimapcache, Kampfvorbereitung, Effektfolgen
und persönlicher Dorfschmuck sind angebunden. 23 neue Modelle, neun
Kriegeranimationen, Ragdoll und Porträts stehen im Grafiklabor.
[Stand, Messwerte, Vorschaubilder und offene Arbeit](QUALITY_V1_UMSETZUNG.md).
Nächste Priorität: Browser-/Koopvergleich, PR/CI und kleiner Gebietspilot.
Online-Lags sind noch nicht nachweislich behoben; keine Live-Schaltung.

16.10.2026: Angelo priorisiert deutlich flüssigeres Spiel und feste
Gegenstände wie Mauern. [Neues Grafik-/Gameplay-/Leistungskonzept](GRAFIK_GAMEPLAY_PERFORMANCE_KONZEPT.md):
statische und dynamische Darstellung trennen, feste Module und Rendercaches
erproben, erst danach den grafisch verbesserten Tor-/Hof-Piloten umsetzen.
Status Konzept; keine gemessene Lag-Behebung oder neue Spielumsetzung.

16.10.2026: Angelo meldet **Lags seit den 3D-Modellen auf den Maps**.
Allgemeiner Online-/Leistungsfehler, nicht auf den Golem beschränkt.
P1 vor weiterem breitem 3D-Ausbau, bei unspielbarem Verlauf P0.
[Befund und Untersuchungsplan](SERVER_LAGS_3D.md); Ursache noch unbestätigt.

16.10.2026: Eigenes [Verbesserungskonzept](VERBESSERUNGSKONZEPT.md)
auf Angelos Auftrag erstellt: verständlicher Einstieg, lesbare Kämpfe,
freiwillige Entdeckungen, sichtbare persönliche Dorfreaktionen und Fusionen
als Schwerpunkt. Erstes vorgeschlagenes Paket: „Heimkehr nach Sonnenhain“.
Status: Konzept; keine Spieländerungen oder neuen Prüfergebnisse.

Aktueller priorisierter Arbeitsplan, ergänzt am 16. Oktober 2026:
[ARBEITSPLAN.md](ARBEITSPLAN.md). Er legt Reihenfolge, Wichtigkeit,
Status und Abschlusskriterien fest; die Konzepte darunter liefern die Details.

16.10.2026: [Nächste Qualitätsstufe mit Blender, ComfyUI, Inkscape und Krita](NEXT_LEVEL_PLAN.md)
ergänzt: gemeinsames Stilblatt, klare Quell-/Exportwege, Krieger-Pilot und
anschließender Ausbau von Monstern, UI und Ausrüstung. Einstieg, Browser/Golem
und Fortschrittsregeln bleiben die ersten Umsetzungspakete. Planungsänderung,
noch keine neuen Assets, Installationen oder Veröffentlichung.

12.10.2026: Erstes Einstiegspaket lokal geprüft (134 Projektprüfungen grün):
kleine Schritte decken die Karte auf, Laden beachtet echte Gebietssperren,
Dorfstein bleibt erhalten, Ratshallen-Weg frei, Holztrefferklänge ergänzt.
Seit 12.10.2026 live (Commit `79bf216`, PR #134). Website-/Server-Versionsgleichheit
und öffentliche Mehrspieler-/Speicherprüfungen sind bestätigt. Details und verbleibende Prüfungen:
[Einstiegsbericht](konzepte/2026-10-11-startbereich/README.md).
Zusätzlicher Questablauf mit drei Klassen und isolierte Web-Prüfszene ergänzen
den Nachweis; endgültiger PR-Kopf ebenfalls CI-grün und mit konkreter
Merge-/Live-Freigabe veröffentlicht. Als Nächstes: veraltete Starttexte zu
Miras Standort, manueller Einstieg, Brave-/Golem-Prüfung, anschließend Fortschritt.

Folgearbeit 12.10.: Starttexte sind lokal korrigiert, bewegte Schleime/Käfer
in drei Klassen geprüft (135 Projektprüfungen grün). Interaktive Prüfszene
liegt vor; längerer manueller Browser-Durchgang blieb nach Werkzeugabbruch
offen. Noch nicht veröffentlicht. [Bericht](konzepte/2026-10-12-einstieg/README.md).

Stand: 11. Oktober 2026. Rezeptbuch, Golem-Musikstart und Netzwerkoptimierung
sind veröffentlicht (PR #133, Live-Commit `3180af0`). Website und Server sowie
die öffentlichen Mehrspieler- und Speicherprüfungen waren erfolgreich.
Der aktuelle Arbeitsplan steht im
[Konzept für die nächsten Schritte](konzepte/2026-10-11-naechste-schritte/KONZEPT.md).
Die älteren Abschnitte darunter dokumentieren den Verlauf; ihr damaliger
Offen-/PR-Stand kann inzwischen überholt sein.
Die zuletzt bestätigten Nutzerentscheidungen haben Vorrang vor älteren Konzepten.

## Entscheidungen

- 11.10.2026: Fertige Bereiche (Rezeptbuch, Golem-Musikstart und
  Netzwerk-/Wegsuche-Optimierung) hochladen und live schalten, danach ein
  Konzept für die verbleibenden Schritte erstellen. Ausdrückliche Freigabe
  von Angelo. Grundlage ist der aktuelle Hauptstand einschließlich der
  inzwischen übernommenen Android-Steuerung und Monsteranimationen.
- 11.10.2026: Android-App ausdrücklich erst nach weiteren Updates ausliefern
  (Angelo: „nein wir updaten zuerst noch weiter dann kommt die app“).
  Der jetzige Live-Gang betrifft Website und Server; die bestehende APK
  benötigt für Online-Spiel mit Protokoll 10 später ebenfalls ein Update.

- 10.10.2026: Golem-Musik bestätigt: ausschließlich erste 24 Sekunden der letzten Probe fünfmal als 120-Sekunden-Loop. Beim Spawn langsam über sechs Sekunden einblenden; Bass und Snare ab Sekunde 12 jeder Wiederholung, keine zusätzliche Melodie ab Sekunde 24.

- 10.10.2026: Echte 3D-Modelle mit Höhe und Tiefe für alle Außenmaps 1–12, sechs Motive je Karte und sechs Mauermodule. Map 0 bleibt unverändert. Live-Schaltung mit „Ok kannst live gehen“ ausdrücklich freigegeben; aktive Mesh-Instanzen werden in der bisherigen Spielperspektive mit Figuren sortiert.


- 9.10.2026: Nutzer bestätigt mit „jetzt“ die Veröffentlichung von Meistergaben-Reparatur, Anhänger-Halsketten, Dunklem Arkanhüter in Kristallmoor, Kartenreisen und breiterem Elara-Durchgang. Umsetzung und Regressionstests im Freigabepaket.

- 9.10.2026: PR-Aufräumen. Geschlossen: #11, #12, #13, #16 (schon in `main`),
  #30, #32 (anders umgesetzt), #58 (überholt durch GBA-Boden), #21 (doppelt
  zu #22). Gemergt: #55 (GitHub Actions auf Node 24). Ebenfalls geschlossen
  auf Angelos Wunsch, Funktionen werden nicht übernommen: #2 (FullFix V2),
  #3 (Beeren im Koop), #9 (Spielstand per Drag & Drop), #14 (Händler-Historie),
  #15 (Alma-Pfeilnavigation), #22 (Alma-Tisch, Fusions-Kodex).

- 9.10.2026: Live-Schaltungen (`[deploy]`) nur nach einmaliger Rückfrage und
  ausdrücklicher Bestätigung durch Angelo, jedes Mal. Sonst freie Hand.
- 9.10.2026: Neuer Code kommt in Module unter `components/`, nicht in
  `main.gd` (Regeln in `AGENTS.md`).
- 9.10.2026: Modularisierung nach vier Modulen (Inhalte, Netzwerk, Weltgeometrie,
  Gegenstände) pausiert. Weitere Teile nur herauslösen, wenn ohnehin dort
  gearbeitet wird. Schwerpunkt jetzt: Spielinhalte und Startbereich.
- 9.10.2026: Klangrichtung für alle Sounds: 16-Bit, märchenhaft
  (`docs/sound/KONZEPT.md`).

## 0. Rückmeldungen vom 9.10.2026

Konzept mit Befunden und Reihenfolge: `docs/konzepte/2026-10-09/KONZEPT.md`
(Fenna-Speicherfehler, Umhänge, Accessoires, Ascheberge-Tor, Kirche,
Wegsteine, orangene Ecken, Eingangswege, Hausaccessoires, Laternen, Patch
Notes, HUD, Fusionsregel). Von Angelo freigegeben. Paket 1 ist live,
Paket 2 (Patch Notes, HUD) ist seit 9.10.2026 live (Commit `391db84`).
Paket 3 (Fusionsregel D1, Limit 5, Sprünge bleiben) ist live. Ebenfalls live seit 9.10. abends (Commit `8664714`): Web-Ton, schlankes HUD mit eckiger Minimap, Rückfrage beim Verlassen, Menüklicks, Schritte je Untergrund (Schrittprobe), Busch-Rascheln überall, Teleport-Brummen, B4 orangene Grundstücksrahmen entfernt, Kapellenboden repariert. Den Arkanhüter hat PR #70 schon ins Kristallmoor versetzt. Als Nächstes aus Paket 4: das sichtbare Ascheberge-Tor.

## 0b. Wünsche vom 9.10.2026 (Abend)

Konzept, neu sortiert mit Reihenfolge und offenen Entscheidungen:
`docs/konzepte/2026-10-09-abend/KONZEPT.md`. Zuerst: Charakterwechsel
vermischt Fortschritt (A1), dann Reisen über die Karte, Vollbild, Tippgeräusch,
Start im Dunkeln. Großes Thema: neues Figuren-System mit 3D-Körpern, Ragdoll,
Treffer-Zonen und Rüstung pro Körperteil (Prototyp zuerst).

Stand 10.10. (Commit `3cbdd16`) live: A1, B3 Reisen über die Karte, B1
F11-Vollbild, B2 Tippgeräusch, C1 Start im Dunkeln, Kontofehler im Startmenü,
Ewige Pfeile, neue Wegsteine. Als Nächstes: A2 Schritte 1 und 3, Paket 4
Ascheberge-Tor, E2, E1, D2; Golem nach Angelos Antworten.

## 0c. Wünsche vom 9.10.2026 (spät)

- Hut des Jagdmeisters: „Ewige Pfeile“ (PR #86, live).
- Neue Wegsteine als Plateau mit Treppe (PR #87, live, Bilder in
  `docs/konzepte/2026-10-09-abend/wegsteine/`).
- Fehler: Startmenü zeigte fremde lokale Spielstände statt der Kontocharaktere
  (PR #85, live).
- Golem-Endgegner im Himmelsgarten: Konzept mit offenen Fragen in
  `docs/konzepte/2026-10-09-golem/KONZEPT.md`. Umsetzung erst nach Angelos
  Antworten.

## 0d. Gemerkt für später (Angelo, 10.10.2026, 02:18)

- **Krieger fertigstellen:** fehlende Anzeigen bei Animationen; er braucht sein
  geplantes Update.
- **High-Level-Mobs** an die Anfangsmobs angleichen: gleiche Sprite-Qualität,
  8 Bewegungsrichtungen, intelligenteres Verhalten.
- **Level-Cap 40 aufheben:** weiterleveln bis 100 im bestehenden XP-System, ab
  Level 100 jedes Level 4× schwerer.
- **Shop-Items** an das Level des Käufers anpassen.
- **Almas Shop** auf eine Seite beschränken: nur „Kochen“.
- **Pop-up beim ersten Betreten einer Map:** freigeschaltete Items mit Name und
  Bild.
- **Pfeiltreffer in der Umgebung:** passender Ton je nach getroffenem Objekt
  (Holz, Stein, Busch, Wasser …).
- **Golem-Endgegner:** umgesetzt am 10.10. (Branch `feature/dark-golem`,
  Umsetzung in `docs/konzepte/2026-10-10-golem/UMSETZUNG.md`). Offen: Angelos
  Hardtekk-Lied als `music/boss_golem.ogg`; echtes 3D-Modell mit Ragdoll
  später mit D2.

Noch offen aus der Nacht davor: Shop (Maus + Enter kaufen, Menge, Gesamtwert
beim Verkaufen) ist als PR #99 fertig. Konzept LV-40-Rüstungen:
`docs/konzepte/2026-10-10-ruestungen/KONZEPT.md`. Fusionen nach Relog (lokal
nicht nachstellbar, braucht Details).

## 1. Startbereich abrunden

Dorf → Blütenwiesen → erstes Waldstück einmal komplett durchspielen und alles
glätten, was dort hakt: Trefferflächen, Balance, Sounds und Übergänge. Die
ersten Spielminuten entscheiden, ob jemand weiterspielt.

## 2. Sounds

Neues Soundkonzept: `docs/sound/KONZEPT.md`. Erst Paket 1 (Kampfgefühl im
Startbereich), danach Oberfläche, Fähigkeiten, Atmosphäre und übrige Gegner.
Klangrichtung: 16-Bit, märchenhaft. Sounds entstehen überwiegend per Skript.
Paket 1 (Kampfgefühl im Startbereich) ist freigegeben. Nächstes Paket: 2 (Oberfläche und Fortschritt).

## 3. Schrittweise Modularisierung von `main.gd`

Pausiert (siehe Entscheidungen). Bereits ausgelagert: `game_content.gd`,
`network_codec.gd`, `world_geometry.gd`, `item_rules.gd`.
Vorgehen beim Herauslösen: `AGENTS.md`, Abschnitt 4.

Referenz: `docs/architecture/main-modularization.md`.

## Weitere bereits dokumentierte Ziele

Die folgenden Vorhaben sind aus vorhandenen Konzepten übernommen. Einige Teile
sind bereits umgesetzt; vor Arbeitsbeginn den aktuellen Live-Stand prüfen.

### Vollständige Pixelart-Spriteumstellung

**Für später: 3D-Waldschleim-Test** gemäß [gespeichertem Konzept](WALDSCHLEIM_3D_KONZEPT.md). Die Monsterumstellung wird jetzt nicht veröffentlicht.

**Waldmonster:** Waldschleim, Käfer, Pilz und Moosrolf sind erneuert und live
(siehe unten). Die [Designsammlung für alle 27 Monster](monster-design-v1/README.md)
bleibt die Vorlage für die übrigen 23 Monster, die Gebiet für Gebiet nach dem
gleichen Muster folgen. [Waldschleim-Entwurf v2](waldschleim-v2/README.md).

- Hochwertige Bitmap-Sprites für 18 Spieleridentitäten (3 Klassen × 3 Völker ×
  2 Erscheinungen), 27 Mobtypen und anschließend wichtige NPCs.
- Acht echte Blickrichtungen, konsistente Identität und vollständige Animationen.
- Golden-Pilot für menschlichen Krieger und Waldschleim ist vorhanden; Ausbau
  der Animationen und Übertragung auf die übrigen Figuren bleiben Folgearbeit.
- Ausrüstung und kosmetische Teile in passende sichtbare Layer überführen.

Referenzen: `docs/SPRITE_GOLDEN_PILOT.md` und die Übergabe
`WEITERARBEIT_SPRITES.md` in der übergeordneten lokalen Projektwurzel.

### Fenna: umfassende Gestaltung und Vorschau

- Gemeinsame Farbauswahl aus Gegenstands- und Tilefarben mit Materialbereichen.
- Farben getrennt pro Gegenstand speichern; alle Klassen und Völker unterstützen.
- Vorschau für Blickrichtungen, Stehen, Laufen, Sprinten und vorhandene Sprünge.
- Passende Umhangbewegung und vollständige Maus-/Tastaturbedienung.

Referenz: `design-entwurf/fenna/FENNA_KONZEPT.md` in der übergeordneten
lokalen Projektwurzel. Umhang- und Farbteile sind teilweise bereits vorhanden.

## Bereits erledigt und live

- 9.10.2026 live (Commit `2935228`, von Angelo vorab bestätigt): Sound-Paket 2
  (Oberfläche, Fortschritt, Welt, Regler „Oberfläche“), Busch-Rascheln und
  Konzept-Paket 1 (Fenna-Speicherverlust, Wegsteine, Laternen/Büsche,
  Eingangswege, Kapelle).
- 9.10.2026 live (Commit `678bc55`, von Angelo bestätigt): Sound-Paket 1
  (39 Klänge, Herzschlag-Warnung, Monsterlaute, Entfernungsdämpfung, Ducking)
  sowie die Module `game_content.gd`, `network_codec.gd`, `world_geometry.gd`
  und `item_rules.gd`.
- Arkanhalsketten (Commit `c721f7a`): sechs klassenübergreifende Halsketten,
  eigener Ausrüstungsplatz, Bossdrops, Umwandlung alter Kerne, Koop-Sync.
  Regeln und Prüfungen: `docs/arcane-necklaces/README.md`.
- Erste vier Waldmonster erneuert: Waldschleim, Käfer, Pilz und Moosrolf mit
  Sprites in acht Richtungen, vollständigen Posenzyklen, Drüsenschüssen,
  Giftstaub, Wolfssprung, dauerhafter Verfolgung mit Hindernis-Routing und
  Pilz-Giftzischen. Vorschauen: `docs/mob-erneuerung/`.

- Dorfplatz und Bodenflächen im vereinbarten Pixelstil; Sand durch Gras ersetzt.
- Verbundene Kopfsteinpflasterwege und passende Hauseingänge; breitere Arenawege.
- Baum- und Laternenplatzierung sowie zusätzliche Blumen und Blumenbüsche.
- Zwei Steinebenen und Treppen nur an der Kirche; keine erhöhten Sockel an
  Borins Haus oder der Schmiede.
- Natürliche Übergänge zwischen Kopfsteinpflaster und Spawnplatten ohne Karomuster.
