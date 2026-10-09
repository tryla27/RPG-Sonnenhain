# Mob-Erneuerung: Blütenwiesen und Pilzwald

9. Oktober 2026. Erste vier Typen: Waldschleim, Blütenkäfer, Pilzling, Mooswolf.

## Umsetzung

- Eigene transparente Pixelart, acht Ansichten in der festen Reihenfolge S, SW, W, NW, N, NO, O, SO.
- Ein Sprite bleibt während Stand, Bewegung und Angriff erhalten. Kein Wechsel zu den alten geometrischen Körpern.
- Bewegung verwendet zunächst leichte Körperbewegung; Schleim verformt sich beim Hüpfen, Käfer bleibt am Boden, Pilzling federt und Wolf stößt beim Angriff vor. Dies sind keine vollständig gezeichneten Bein- oder Waffenanimationszyklen.
- Die Bewegung folgt dem vorhandenen Angriffszustand; sie erzeugt keine Treffer und verändert keine Kampfwerte.
- Schadenblitz, Leichenausblendung und Elitegröße bleiben über die bestehende Darstellung erhalten.
- Rückansichten tragen kein Frontgesicht. Wolf-Seitenansichten werden als vollständige Silhouetten ausgeschnitten, weil Schwanz und Schnauze die nominellen Generierungszellen überschreiten.
- Rohbilder unter `art/sprites/mobs/woodland_v2/source/` werden nicht als Spielressourcen importiert; die fertigen Streifen haben 96×96 Pixel pro Richtung.

## Generierung

Mit dem eingebauten Bildgenerierungswerkzeug. Die erste Käfervorlage erhielt zusätzlich einen Durchgang zur Hintergrundentfernung. Nachbearbeitung ist ausschließlich Zuschneiden, einheitliches Skalieren mit nächstem Nachbar und transparentes Einpassen.

Gemeinsamer Prompt: Production game sprite sheet, handcrafted detailed warm pixel clusters, thin dark woodland outlines, top-down three-quarter overhead RPG camera, eight true anatomical directions, S SW W NW / N NE E SE in four columns and two rows, transparent RGBA, no scenery/glow/baked shadow/text, complete anatomy inside margins, consistent scale and upper-left light.

Motivvorgaben:
- Waldschleim: squat mossy green translucent mound, dark small eyes, neutral tiny mouth, two-leaf sprout, darker forest core, no face on rear views.
- Blütenkäfer: six short legs, dark olive head, green segmented wing casing, cream flower petals and gold pollen, antennae and mandibles.
- Pilzling: rose-red broad speckled cap, beige stalk body, root feet, short wooden spore staff in right hand, moss-green shoulders, no eyes on rear views.
- Mooswolf: lean quadruped wolf, gray-brown moss-green fur, fern tufts, pale muzzle, pointed ears, amber eyes, long bushy tail, no face on rear views.

## Prüfung

`tools/check_woodland_mobs.gd`: alle Richtungszellen belegt, transparente Ecken, vollständige Rahmengrößen, begrenzte visuelle Vorstöße und Rückkehr zum Bodenanker.

`tools/capture_woodland_mobs.gd`: native Darstellung in allen Richtungen, 16 Bewegungs- und 16 Angriffsbilder. Die Kampftests prüfen weiterhin alle 27 Profile und Netzwerkzustände.

Weitere 23 Gegnertypen verwenden weiterhin ihre bestehende Darstellung. Vollständige gezeichnete Bewegungs- und Angriffsframes sind eine weitere Ausbaustufe.

## Folgeupdate: artspezifische Angriffe

Der ausdrückliche Nutzerwunsch ersetzt für diese drei Mobs den früheren Angriffsplan:

| Mob | Angriff | Vorwarnung | Wirkung |
|---|---|---|---|
| Blütenkäfer | Drüsensekret | 0,7 s | Einzelnes grünes Projektil, 230 Einheiten/s, etwa 360 Einheiten Reichweite, keine zusätzliche Kontaktattacke. Drüsen leuchten beim Aufladen. |
| Pilzling | Giftstaub | 0,85 s | Stationäre Fläche mit 84 Einheiten Radius für 2,6 s; vier Impulse mit je rund einem Viertel des bisherigen Angriffsschadens, Abstand 0,65 s. Kein zusätzliches unsichtbares Projektil oder Nahkampftreffer. |
| Mooswolf | Biss | 0,65 s | Kurzer gerichteter Nahbiss mit 38 Einheiten Reichweite. |
| Mooswolf | Sprungbiss | 0,8 s | Ab 80 Einheiten Abstand: Sprung bis 165 Einheiten in 0,32 s, danach einmaliger gerichteter Biss am tatsächlichen Landeort. Eigene Erholung und Gesamtzyklus von 3,1 s. |

Der Staub schädigt innerhalb der Fläche; er verleiht keinen versteckten, nach dem Verlassen weiterlaufenden Giftstatus. Er wirkt durch keine Wände und entfällt bei Tod oder Betäubung seines Erzeugers. Die normalen Schutzfenster des Spielers bleiben wirksam.

Wolfsprünge prüfen den gesamten Weg in Schritten von höchstens acht Einheiten gegen Gelände, Gebietswände, sichere Zonen und Instanzgrenzen. Blickrichtung und Sprungdistanz werden bei Beginn des Sprungs festgelegt. Betäubung oder Tod verhindern den Landetreffer. Der Bodenschatten bleibt am aktuellen Bodenort, während die Bildhöhe den Sprung zeigt.

Beim Einbau wurde die unterschiedliche Richtungsreihenfolge des Helden-Renderers und der neuen Mob-Streifen korrigiert. Mob-Grafiken zeigen damit tatsächlich in die Angriffsrichtung.

Prüfungen: `check_woodland_attacks.gd` prüft konkrete Spielintegration, Drüsenursprung, Giftintervalle/Ablauf/Radius/Wände, Bisswahl, bewegten Sprung, große Zeitintervalle, Betäubung und einmaligen Landetreffer. `check_mob_combat_network.gd` prüft die neuen Fähigkeiten über echte WebSockets mit zwei Spielern: Flächensnapshot, Gruppenschaden pro Impuls, Verlassen der Fläche, Sprungbewegung und Landeschaden sowie Drüsenprojektil. `capture_woodland_attacks.gd` rendert die tatsächliche Gegnerdarstellung mit Warnungen und Effekten.
