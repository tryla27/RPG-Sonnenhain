# Mooswolf: erste vollständige Animationsgrundlage

9. Oktober 2026. Die acht Standbilder werden durch 192 gezeichnete Posen ersetzt, ohne den Kampfablauf zu ändern.

## Bilder und Zustände

Pro Richtung: vier Ruheposen, acht Gangphasen, vier Bissposen, vier Sprungposen, zwei Treffer-/Erholungsposen und zwei Todesposen. Die Sprungfolge verwendet zusätzlich den leichten Biss-Vorbereitungsduck und die aufgerichtete Erholung, insgesamt sechs unterschiedliche Körperposen. Alle acht Richtungen haben eigene Bilder; Seitenansichten werden nicht aus einer Frontansicht gedreht.

Die Pfoten, Gelenke, Schnauze und der Schwanz wechseln ihre tatsächlich gezeichnete Stellung. Zusätzlicher Ganzkörper-Hop und künstlicher Vorstoß des alten Wolf-Renderers entfallen. Beim echten Sprung bleibt die bisherige berechnete Flughöhe bestehen; der Bodenschatten bleibt am Boden.

Der Biss öffnet die Kiefer im Ausholen und zeigt den Schnapp-Frame ab der tatsächlichen Trefferphase. Der Sprung beginnt mit leichtem und tiefem Ducken, zeigt Abstoß, Flug, eingeknickte Vorderbeine beim Landen und anschließendes Aufrichten. Trefferreaktionen haben Vorrang; Tod verwendet ein Zusammenbrechen und einen gefallenen Körper mit Ausblenden statt einer vertikalen Bildverformung.

Levelanzeige und Lebensbalken bleiben über dem Kopf und folgen beim Sprung der Bildhöhe, damit sie die neue Körperpose nicht verdecken.

## Bewegungsphase

Eine Gangrunde entspricht 84 Welteinheiten. Die Phase wächst nur mit tatsächlich zurückgelegter Bodenstrecke. Langsamer gewordene oder blockierte Wölfe treten daher nicht weiter im alten Takt. Im Mehrspielerbetrieb wird die Phase aus der interpolierten Bewegung fortgesetzt und bei neuen Snapshots nicht zurückgesetzt. Große Positionskorrekturen erzeugen keinen hektisch durchlaufenden Gang. Sprungstrecken zählen nicht als Gehstrecke.

Ruhebewegungen nutzen Zeit und den bestehenden individuellen Mob-Seed. Die Todesdarstellung dauert beim Wolf 0,95 Sekunden; Belohnung und tatsächlicher Tod erfolgen weiterhin sofort. Angriffe, Projektil-/Flächenregeln, Schaden, Reichweiten und Serverentscheidungen bleiben gleich.

## Generierung und Aufbereitung

Mit dem eingebauten Bildgenerierungswerkzeug und dem bisherigen Mooswolf als Identitätsreferenz. Die vollständigen Richtungs-Prompts stehen in `wolf-animation-prompts.json`.

Quellen: `art/sprites/mobs/wolf_v3/source/`, mit `.gdignore` vom Spielimport ausgeschlossen. Spielstreifen: je Richtung `art/sprites/mobs/wolf_v3/<richtung>.png`, 24 Rahmen von 128×128 Pixeln. Die Aufbereitung isoliert die zusammenhängenden Wolfsilhouetten, damit über nominale Rastergrenzen reichende Körperteile vollständig erhalten bleiben und keine Nachbarbildreste erscheinen. Ein Pixel Rand bewahrt die Alpha-Kontur. Pro Richtung gilt ein fester Maßstab aus den Ruheposen; einzelne Bewegungsbilder werden nicht separat auf gleiche Größe gestreckt.

## Prüfung und Erweiterung

`check_wolf_animation.gd` prüft alle 192 Rahmen, transparente Ränder, unterschiedliche Gangbilder, vollständige Wiedergabe, Biss-/Sprungphasen sowie Treffer- und Todesbilder. Die Spielintegration prüft außerdem, dass echte Bewegung die Gangphase fortsetzt und Betäubung sie stoppt. Vorhandene Angriffs- und echte WebSocket-Prüfungen bestätigen unveränderte Treffer und Synchronisierung.

`capture_wolf_animation.gd` rendert eine native 48-Bilder-Vorschau aller acht Richtungen für Ruhe, Gang, Biss und Sprung. `docs/mob-erneuerung/wolf-animationen.gif` ist die daraus erstellte Vorschau.

Diese Runde setzt den angekündigten ersten Schritt am Wolf um. Käfer, Pilzling und Schleim behalten zunächst ihre bisherige Bewegung; auf dieser Grundlage folgen deren artspezifische Posen.
