# Sonnenhain – nächste Ziele

Stand: 8. Oktober 2026. Arkanhalsketten lokal umgesetzt und geprüft; Veröffentlichung noch offen.
Die zuletzt bestätigten Nutzerentscheidungen haben Vorrang vor älteren Konzepten.

## 1. Arkanhalsketten – umgesetzt, Veröffentlichung offen

### Verbindliche Regeln

- Arkankerne werden zu Arkanhalsketten.
- Jede Klasse kann jede normale und jede Bosshalskette tragen. Keine Klassenbeschränkung.
- Eigener Halskettenplatz; höchstens eine Halskette gleichzeitig ausgerüstet.
- Eine Halskette hat ausschließlich ihren besonderen Effekt. Keine zusätzlichen
  Grundwerte wie maximale HP/Energie, Bewegungstempo oder allgemeiner Schaden.
- Der besondere Effekt wirkt nur beim Tragen. Ablegen beendet ihn, die Kette
  wird nicht verbraucht. Inventaraktionen: ANLEGEN, ABLEGEN, WECHSELN.
- Die getragene Halskette wird als passender Pixelart-Anhänger am Charakter
  dargestellt, in allen vorhandenen Blickrichtungen und Animationen sowie im Koop.
- Keine Ränge oder Duplikatverbesserungen in der ersten Umsetzung.

### Normale Halsketten bei Pip

Die Zahlen sind Konzept-Startwerte und müssen im Spiel geprüft werden.

| Halskette | Einziger besonderer Effekt |
|---|---|
| Frosthalskette | Direkter Treffer verlangsamt das Ziel um 20 % für 2 Sekunden; höchstens einmal alle 6 Sekunden. |
| Gewitterhalskette | Direkter Treffer verursacht zusätzlich Blitzschaden in Höhe von 25 % eines normalen Angriffs; höchstens einmal alle 5 Sekunden. |
| Giftdornhalskette | Direkter Treffer vergiftet für 4 Sekunden; insgesamt 40 % eines normalen Angriffs als Giftschaden; höchstens einmal alle 6 Sekunden. |

### Besondere Halsketten der drei Klassenbosse

Jeder erfolgreiche Abschluss lässt die zugehörige Halskette garantiert fallen.
Der Herkunftsboss bestimmt den Namen, nicht die erlaubte Trägerklasse.

| Boss / Halskette | Einziger besonderer Effekt – für jede Klasse |
|---|---|
| Kriegsherr / Halskette des Kriegsherrn | Direkte Treffer bauen bis zu 5 Zorn auf; jeweils +2 % Schaden als bedingter Zorneffekt. Nach 5 Sekunden ohne Treffer verfällt der Zorn. |
| Arkanhüter / Halskette der Arkanresonanz | Jede dritte erfolgreiche Schadens- oder Heilfähigkeit erhält +20 % direkten Schaden oder Heilung und erstattet 20 % ihrer Energiekosten. |
| Jagdmeister / Halskette der Jagd | Drei direkte Treffer auf dasselbe Ziel innerhalb von 6 Sekunden lösen einen Zusatztreffer mit 50 % eines normalen Angriffs aus. Schwert, Stab, Bogen und Fähigkeiten zählen. |

### Verhalten und Übernahme vorhandener Gegenstände

- Schaden über Zeit und Halsketten-Zusatztreffer lösen keine weiteren
  Halsketteneffekte aus. Bossverlangsamung wird reduziert.
- Beim Wechsel werden Kampfaufladungen zurückgesetzt. Wechseln darf eine
  laufende Abklingzeit nicht umgehen.
- Vorhandene Eis-, Blitz- und Giftkerne werden in die entsprechenden Halsketten
  umgewandelt; Gegenstandsidentität und vorhandene Sperrmarkierungen erhalten.
- Bereits durch einen Blitzkern gelernte Blitzlanze bleibt erhalten. Halsketten
  schalten künftig keine Fähigkeiten frei.
- Der bisher als Klassenwaffe erzeugte Questgegenstand „Arkankern“ erhält einen
  passenden Waffennamen und behält seine Werte. Die neue Bosshalskette ist ein
  eigenständiger Drop; bestehende Waffen nicht stillschweigend ersetzen.
- Ausrüstung wird gespeichert und geladen. Im Koop werden Wirkung und sichtbare
  Halskette konsistent übertragen. Keine Heilung durch wiederholtes Anlegen.
- Effektdetails und aktuelle Aufladung sind im Charakterfenster verständlich sichtbar.

### Umsetzungsschritte

1. Halskettenkatalog, eigener Ausrüstungsplatz und Übernahme alter Kerne.
2. Drei normale Effekte und Inventarbedienung für alle Klassen.
3. Drei Bosshalsketten und garantierte Drops.
4. Sichtbare Anhänger für vorhandene Figuren, Blickrichtungen und Animationen.
5. Speichern/Laden, Koop und Prüfung auf Effektketten oder Wechselmissbrauch.

## Weitere bereits dokumentierte Ziele

Die folgenden Vorhaben sind aus vorhandenen Konzepten übernommen. Einige Teile
sind bereits umgesetzt; vor Arbeitsbeginn den aktuellen Live-Stand prüfen.

### Vollständige Pixelart-Spriteumstellung

Aktueller Arbeitsschritt: [vollständige Designsammlung für alle 27 Monster](monster-design-v1/README.md). Drei Designtafeln und ein Katalog mit stabilen Monster-IDs, Gebieten, Silhouetten, Paletten, Größen und Animationsmotiven. Nach der visuellen Abstimmung folgen die Richtungs- und Animationssprites.

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

### Schrittweise Modularisierung

Gameplay, Kampf, Speichern, Multiplayer, UI und Weltlogik schrittweise aus
`main.gd` in klar abgegrenzte Komponenten überführen. Bestehende Schnittstellen
und Verhalten erhalten; Tests auf Verhalten statt reine Textsuche ausrichten.

Referenz: `docs/architecture/main-modularization.md`.

## In diesem Chat bereits erledigt und live

- Dorfplatz und Bodenflächen im vereinbarten Pixelstil; Sand durch Gras ersetzt.
- Verbundene Kopfsteinpflasterwege und passende Hauseingänge; breitere Arenawege.
- Baum- und Laternenplatzierung sowie zusätzliche Blumen und Blumenbüsche.
- Zwei Steinebenen und Treppen nur an der Kirche; keine erhöhten Sockel an
  Borins Haus oder der Schmiede.
- Natürliche Übergänge zwischen Kopfsteinpflaster und Spawnplatten ohne Karomuster.
