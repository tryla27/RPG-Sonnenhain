# Dorf, Innenräume und Runen · abgestimmter Entwurf

Dieser Teil ist ein Systementwurf; das veröffentlichte Patch-Update enthält noch keine neuen Innenräume, Koch- oder Runenlogik.

## Dorf und Rollen
Der Spawnkristall bleibt in der Dorfmitte. Wege führen zwischen Häusern und bleiben frei. Die Mauer ist die Grenze von Map 0; nur geöffnete Tore lassen den Wechsel zu. Wohnhäuser und bestehende Läden bekommen eindeutige Türen und Namen.

Elara ist die einzige Trankhändlerin und bietet weiterhin Heilung an. Torvald verkauft Waffen und Rüstung. Fenna verkauft Reiseausrüstung. Pip bietet Kräuter, Essenzen und Alchemiezutaten an, keine fertigen Tränke. Arven verwaltet die Arena. Mira, Borin und Liora geben ausschließlich Quests; maximal drei feste Aufgaben pro Questgeber. Für die vorhandenen 25 Quests braucht es insgesamt mindestens neun Questgeber: sechs weitere regional passende Personen werden ergänzt, ohne Quest-IDs oder Fortschritt zu löschen. Die Namen und Standorte sind noch zu entwerfen.

E öffnet eine nahe Haustür. Jeder Innenraum hat seinen NPC und eine verständliche Ausgangstür. Ein Innenraum wird erst beim Betreten geladen und bekommt ein eigenes Layout. Im Save stehen die Haus-ID und die sichere Rückkehrposition; nach Laden steht die Figur vor der Tür. Multiplayer benötigt zusätzlich eine Innenraum-ID, damit Personen in unterschiedlichen Häusern einander nicht sehen oder treffen.

## Alma und Kochen
Alma in der Taverne kocht mit mitgebrachten Zutaten. Der Rezeptdialog zeigt benötigte, vorhandene und fehlende Mengen, Kochgebühr und Ergebnis vor dem Bestätigen. Zutaten und Gold werden erst nach einer erfolgreichen Platz-/Kostenprüfung gemeinsam verbraucht; das Essen wird ins Inventar gelegt.

Startrezepte: Kräutersuppe (3 Kräuter, kleine Heilung), Wandermahl (Kräuter plus Pilze, Energieregeneration), Arkaner Tee (Kräuter plus Essenz, Manaregeneration). Pilze und weitere Nahrungszutaten benötigen neue Sammel-/Beuteeinträge. Grundregel: ein Nahrungsbonus gleichzeitig, klare Dauer, keine unbegrenzte Stapelung. Das endgültige Zahlenbalancing folgt Spieltests.

## Vier Runendisziplinen, Stufe 1–100
Die Disziplinstufen sind getrennt vom derzeitigen Charakterlevel. Klassen haben bevorzugte Disziplinen; Robotik ist eine technische Disziplin und steht auch Menschen und Orks offen. Roboter können ebenso Magier oder Schützen sein.

| Disziplin | Schwerpunkt | Beispiele |
|---|---|---|
| Magie | Zauberkontrolle, Mana, Elemente | Funkenrune, Frostsiegel, Arkankern |
| Kampf | Nahkampf, Schutz, Ausweichen | Eisenrune, Klingenzeichen, Wächtermarke |
| Schütze | Präzision, Projektilkontrolle | Falkenauge, Windfeder, Jagdzeichen |
| Robotik | Technik, Wärme, Systeme | Energiekern, Servorune, Schutzschaltung |

Freischaltungen bei 1, 10, 25, 50, 75 und 100. Vorgeschlagene Erfahrung bis zur nächsten Stufe: `100 + 20*(Stufe-1) + 2*(Stufe-1)^2`; Stufe 100 ist die feste Grenze. Fortschritt entsteht durch tatsächliche Kampfbeiträge und einmalige Aufgabenbelohnungen, keine Erfahrung durch Zaubern ins Leere. Im Koop bestätigt der Server die Vergabe.

Drei aktive Runenplätze: Angriff, Schutz und Utility. Eine Rune pro Platz; weitere Runen bleiben im Besitz. Effekte zeigen Wert, Bedingung und Abklingzeit. Keine Multiplikationsketten zwischen Runen. Stufe 100 soll ein neues Verhalten freischalten, keine unkontrollierte Schadenssteigerung. Rüstung, Waffen und Ring bleiben die drei bestehenden Ausrüstungsplätze; Runen werden in einem eigenen Menü verwaltet.

## Praktisches HUD
Kompakte HP-/Ressourcenanzeige oben links; darunter genau ein verfolgtes Ziel. Die Minimap oben rechts ist anklickbar und öffnet die Weltkarte. Unten eine kleine transparente Fähigkeitsleiste mit Nummer, Symbol und Abklingzeit. Hinweise erscheinen nur in Interaktionsnähe. Inventar, Quests, Runen und Karte öffnen getrennte große Ansichten, damit das Spielfeld nicht verdeckt wird.

## Reihenfolge
1. Häuser und sichere Innenraumwechsel, Elara/Questrollen.
2. Alma-Rezepte, Zutaten, Transaktionen und Save-Migration.
3. Runenfortschritt und drei Runenplätze; erst danach einzelne Effekte und Balancing.
