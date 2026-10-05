# Dorf, Arena, Atelier und Spell-Fusionen

## Umsetzung

Die vier neuesten Referenzgebäude stehen verteilt auf Map 0: Schmiede im Nordwesten, Heilkapelle am westlichen Dorfplatz, Steinrose im Südwesten und die große Arena im Südosten. Der Spawn-Schrein samt Plattform bleibt frei in der Dorfmitte und wird in der Übersicht vollständig mitgezeichnet. Die Ankunftsfläche und Wege zu allen Gebäuden sind erreichbar. Transparente PNGs ersetzen dort die bisherige Darstellung. Die bestehenden Gebäude für Fenna, Borin und die Ältesten bleiben erhalten und bekommen ausreichend hohe Türen. Richtwert: etwa 64 Weltpixel für den 2 m großen Helden, also 32 Pixel pro Meter. Die Referenzgebäude verwenden 448 × 448 Weltpixel, die Arena 1088 × 1088. Fassaden behalten ihre Perspektive und ihr Seitenverhältnis.

Die Arena-Kampffläche wächst von Radius 490 auf 640 Weltpixel und erhält ein neu gepixeltes Sand-/Stein-Asset mit Tribünen, Bannern und Toren. Arvens Eingangshalle wächst von 896 × 512 auf 1344 × 768, mit angepasstem Ausgang, Kamera und Möbelkollisionen. Die Dorfgrenzen und Ausgänge bleiben bestehen. Der südliche Dorfweg führt an der Arena vorbei. Gebäudegrafik, Tür, Zeichentiefe und Körper-/Geschosskollision benutzen gemeinsame Angaben in `village_buildings.gd`.

Umhänge hängen gegenüber der Blickrichtung. Die Seitenansichten besitzen einen stärkeren Versatz nach hinten. Rückenansichten zeichnen den Stoff über dem Rücken; Frontansichten verdecken ihn durch den Körper. Kosmetik folgt Rollen und Fallen um denselben Körperdrehpunkt. Ein bestehender Fehler bei gespiegelten Körpertransformationen ist behoben. Roboteraufsätze und Brustabzeichen werden über die vorhandenen Kosmetikfelder gespeichert und im Mehrspielerzustand übertragen.

Roboteraufsätze: Magnet +/−, Blitzantennen, Einzelantenne, Doppelantenne, Blitzableiter, Tesla-Spule, Radar, Energiekugel, mechanische Hörner, Elektrokontakte. Brustabzeichen: Sonne, Mond, Stern, Blatt, Flamme, Kristall, Schild, Rune, Krone, Zaubersiegel. Ohne-Varianten bleiben verfügbar. Abzeichen werden in Rückenansicht verdeckt.

Schwarzes Brett und fünf Laternen behalten ihre bisherigen Standorte und vorhandenen Funktionen. Das Brett erhält Holzmaserung und vier Papier-Aushänge. Die einheitlichen Laternen erhalten einen dynamischen warmen Lichtschein entsprechend dem bestehenden Tag-/Nachtrhythmus.

## Datenbasiertes Fusionssystem

`FusionRules.catalog` durchsucht alle Basisspells anhand der vorhandenen Metadaten. Nur Paare unterschiedlicher geeigneter Spells werden übernommen. Schlüssel sind immer `min(a,b):max(a,b)`. Passives, Ultimates, reine Ausweichbewegung und bereits fusionierte Outputs sind ausgeschlossen. Aktuell: 33 Zutaten, 528 eindeutige Rezepte.

Die vier handgeschriebenen Spezialfusionen behalten ihre IDs und ihre Effekte:

- Wirbelhieb + Feuerball → Flammenwirbel (40)
- Schildwall + Energieschild → Reaktorwall (41)
- Blitzlanze + Teslawelle → Blitzkern (42)
- Frostnova + Blitzlanze → Eisball (43)

Die weiteren 524 Fusionen kombinieren die tatsächlichen bestehenden Spell-Implementierungen bei einem gemeinsamen Einsatz. Beide Komponenten erhalten 72,5 % der gemeinsamen Grundkraft, zusammen 145 %. Abklingzeit: längere Quellen-Abklingzeit × 1,30. Energie: Summe beider Quellenkosten × 0,675. Voraussetzung: beide Spells gelernt, höheres Quellen-Mindestlevel erreicht, ausreichend Gold, Fusionsrang unter 4. Beide Quellen samt Stufen werden geopfert; der Output wird unmittelbar in einen aktiven Slot gelegt. Speichern/Laden stellt die geopferten Zutaten nicht erneut her. Der Host prüft die normalisierte Output-Identität und den gespeicherten Fusionsrang, bevor er die Komponenten ausführt.

Neue Output-IDs liegen ab 1000 in einem stabilen Dreiecksschema. Dadurch bleibt Platz für zusätzliche Basisspells, ohne bestehende Outputs umzunummerieren. Lookup-Tabellen verhindern wiederholte lineare Suchen im erweiterten Katalog. Die Speichergrenzen wachsen anhand des Registryschemas mit. Neue Zutaten werden in den vorhandenen Spell-Daten und `FusionRules.META` ergänzt; neue Spezialrezepte können im bestehenden Rezeptarray ergänzt werden.

Der Kristall zeigt alle Rezepte auf 132 Seiten. Herstellbare Einträge erhalten eine helle Umrandung; gesperrte Einträge werden abgedunkelt. Beide Zutaten, Ergebnis, Level, Gold, Rang und fehlende Voraussetzungen stehen direkt im Eintrag. „Nächste bereite“ springt zu einer Seite mit einer herstellbaren Fusion. Die vollständige Liste steht in [spell-fusionen.csv](spell-fusionen.csv).

## Dateien

Geändert: `main.gd`; `components/fusion_rules.gd`, `map0_ground_plan_32.gd`, `patch_notes.gd`, `rpg_hero.gd`, `server_save_store.gd`, `start_scenery_32.gd`, `start_tilemap_32.gd`, `village_house_tiles_32.gd`, `village_interiors_32.gd`, `village_layout.gd`; `tools/check_content.py`, `check_fusion_impact_rules.gd`, `check_map_logic.gd`, `check_start32_assets.gd`; `.github/workflows/ci.yml`.

Neu: `components/arena_interior.gd`, `character_adornments.gd`, `village_buildings.gd`, `village_fixtures.gd`; `tools/check_village_fusion_upgrade.gd`, `capture_village_upgrade.gd`; diese Dokumentation und `docs/spell-fusionen.csv`.

Neue PNGs mit Importmetadaten: `art/village/smith.png`, `chapel.png`, `tavern.png`, `arena.png`, `arena_interior.png`. Die 20 Kopfschmuck-/Abzeichenvarianten, Laterne, Brett und Eingangshalle werden modular im bestehenden Pixelrenderer gezeichnet; dafür entstehen keine doppelten Spriteatlanten.

## Prüfung und offene Punkte

Geprüft: alle 528 Rezeptidentitäten und Spell-Ausführungen; Kosten-/Level-Sperren; Heil-/Schutz- und Schaden-/Kontrollkombinationen; Opfer und erneutes Laden; Server-Save-Validierung; Mehrspieler-Identitäten; Umhangrichtung; Erreichbarkeit sämtlicher Gebäudetüren und des geöffneten Südausgangs mit tatsächlicher Körperkollision; transparente Assetecken. Vorhandene Tests für Fusionen, Runen, Speicherstände, Dorfübergänge und Steinrose bestehen weiterhin.

Gerenderte Übersichten zeigen acht Blickrichtungen, sämtliche zehn Aufsätze und Abzeichen sowie Bewegungs-, Angriffs-, Roll- und Fallphasen. Dorf, Arena, Eingangshalle und Fusionsübersicht wurden visuell geprüft. Die neue Fusions-/Navigationsprüfung läuft auch in CI.

Es wurden keine Platzhalter-Rezepte oder fehlenden Assetframes hinzugefügt. Die automatisch erzeugten Fusionen verwenden gemeinsame Namen und kombinierte vorhandene Effekte; sie benötigen keine handgezeichneten Einzelgrafiken für jedes Paar. Bestehende Rückfälle des Golden-Sprite-Piloten auf den prozeduralen Körperrenderer bleiben erhalten.
