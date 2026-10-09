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
