# Sonnenhain RPG · Patch v28.2 · 30.09.2026

## Im Spiel umgesetzt
- Dorfhäuser, Warenkutschen, NPC-Zuordnung und größere Spawn-Plaza, ohne Gebäude auf Wegen.
- Mauern begrenzen Gelände und Dekoration. Tore werden mit E geöffnet.
- Korrekte Tiefensortierung: Figuren hinter Häusern werden verdeckt; Hauskörper passen zur Fassade.
- Größere Wegsteine; der Spawnkristall übernimmt den Dorf-Wegstein.
- Einheitliche prozedurale Figuren für drei Rassen, zwei Geschlechter und drei Klassen in allen Gebieten.
- Vier Blickrichtungen mit Seitenprofilen, Laufanimation, sechs sichtbare Rüstungen sowie Klassenkleidung.
- Körperproportionen nach Rasse/Geschlecht/Klasse; Lauf- und Projektilradien nach Rasse/Geschlecht.
- Sichtbare Ausweichanimation; Magier: Arkaner Schritt auf Leertaste. Bestehende stärkere Sprungfähigkeit bleibt erhalten.
- Sterbeanimation vor Wiederbelebung, mit derselben Kleidung; keine Steuerung während des Todes.
- Acht neue Händlerangebote: sechs Rüstungen und zwei Ringe. Händlerangebot ist seitenweise erreichbar.
- Umgebung und Vordergrund werden zwischengespeichert; weichere Kamera, unveränderte Kampfobjekte.
- Fähigkeiten respektieren geschlossene Wände; passive Fähigkeiten lassen sich nicht versehentlich auslösen.
- Vorhandene GitHub-Fixes für Koop, Chat und klassenbezogene Beute übernommen.

## Entwürfe, noch kein Spielinhalt
- Sechs animierte Spell-Ideen, Farbkarte und zehn alternative Grasentwürfe.
- Betretbare Häuser mit getrennten Innenräumen. Elara verkauft alle Tränke; Quest-NPCs verkaufen nichts und haben höchstens drei Quests pro NPC. Die übrigen vorhandenen Quests werden für diesen Ausbau auf weitere Questgeber verteilt.

## Prüfung
Godot 4.7.2: Parser, Map-Kollision/Tore, 31 aktive Fähigkeiten auf Rang 1 und 5 sowie drei passive Fähigkeiten; Ausrüstungszuordnung, vollständiges Händlerangebot und verzögerte einmalige Wiederbelebung. Bildübersichten: 18 Figuren × vier Richtungen × sieben Kleidungsvarianten und vier Todesphasen.

Die Performance-Messung betrifft die CPU-Zeit für die Zeichnung der Umgebung, keine garantierte Browser-FPS. Mehrspieler, sämtliche Spielstände und alle Geräte benötigen weitere Spieltests.
