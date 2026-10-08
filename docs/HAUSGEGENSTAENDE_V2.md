# Hausgegenstände v2

Verbindliche Stilreferenzen: `art/village/atelier.png` und `art/village/objects/brunnen.png`. Warme, detaillierte Fantasy-Pixelart, orthografische Dreiviertelansicht, Licht von links oben, klare Holz-, Stein-, Metall- und Stoffschattierungen.

Erzeugt mit dem eingebauten ImageGen-Werkzeug. Transparente Originale: `art/village/forecourts/source-v2/`. Spielfertige Versionen: `art/village/forecourts/v2/`. Originale bleiben unverändert erhalten; `source-v2/.gdignore` hält sie aus dem Spiel-Export heraus.

## Gemeinsame Bildbeschreibung

Use case: stylized-concept. Asset type: one transparent production game sprite for Sonnenhain RPG. Images are STYLE REFERENCES ONLY, do not reproduce the building or well. Match their warm detailed fantasy pixel art, 3/4 top-down orthographic view, visible top surfaces, straight front-facing horizontal edges (NOT isometric diamond axes). Hard nearest-neighbor pixel clusters, rich but restrained light from upper left, carved warm oak, shaded natural materials, depth, no flat vector rectangles. Whole isolated object centered, full base visible, no ground tile or scene, no people, no legible text, no watermark, no diffuse shadow. Transparent alpha outside silhouette. Occupy about 80% of square canvas, generous margin. Designed to downsample cleanly to roughly 70-100 world pixels, strong silhouette, deliberate details. Subject: 

## Einzelmotive

- mannequin: a tailor's wooden dressmaker mannequin on a sturdy carved four-foot wooden stand, wearing an elegant plum-purple dress with cream sleeves, small golden sash and gentle cloth folds, no living person or face.
- cloth: a broad compact oak tailor's worktable, draped with neatly folded plum, blue and cream fabrics, a large wooden spool and tiny brass scissors. Front-facing table with visible tabletop and sturdy legs. No canopy.
- anvil: a chunky dark forged-steel anvil with a recognisable tapered horn, polished upper edge, sitting on a substantial oak stump with iron band, a small forging hammer resting on its side. Robust detailed shaded metal and endgrain.
- logs: a compact stack of split firewood under a low timber storage frame, rounded log ends with clearly drawn growth rings, bark, irregular stacked shapes. Low broad silhouette.
- herbs: a raised carved oak herb planter with lush leafy medicinal herbs, lavender flower spikes and small terracotta pots, a sturdy rectangular trough and short feet. Rich leafy silhouette, natural variations.
- offering: a compact pale grey stone offering pedestal for a friendly village chapel, golden sun emblem inset on its front, small candle holders and a simple bowl on its bevelled top. Detailed stone joints, subtle moss, warm cream candles. No flame glow outside silhouette.
- books: a sturdy compact dark oak outdoor scholar's lectern with one open cream-paged book on an angled top, several blue and burgundy books on its lower shelf, tiny brass corner fittings. Clear book and furniture silhouette.
- scrolls: a compact oak scroll storage cabinet with open cubbies, rolled parchment bound with muted red ties, one map spread on a small top shelf, brass hinges. Readable parchment cylinders, dark wood depth.
- notices: a small village notice board on two stout carved oak posts, a modest red-tile rain cap, several pinned parchment notices with abstract tiny ink marks (no legible text), small sun insignia. Warm wood grain and metal nails.
- bench: a welcoming sturdy carved oak bench with curved armrests, slatted back, thick legs and small worn brass brackets. Three-quarter top-down orthographic, straight front edge, no cushions, no people.
- barrels: a compact pair of oak ale barrels, one upright and one smaller barrel beside it, realistic stylized curved staves, dark iron hoops and a small wooden tap. Both barrels form one coherent compact object, warm highlights.
- dummy: a substantial medieval practice dummy: burlap-and-straw torso strapped to a thick wooden upright and sturdy cross base, round red-and-cream target on chest, tied rope, two short straw arms, simple cloth wrapped head. Friendly training equipment, no living character.
- weapons: a compact stout oak weapon rack with three clearly visible medieval training weapons: steel sword, rounded axe and wooden spear, aligned upright leaning slightly back in slots, dark iron brackets and brass details. Full rack base visible, shaded metal and wood.

## Einbau

Pro Haus bleiben es zwei Gegenstände. Ihre Fußanker liegen dicht vor den Fassaden und neben den Türwegen. Sichtbare Sprites dürfen in der Dreiviertelansicht vor einer Wand stehen; die physischen Standflächen bleiben außerhalb der Gebäudekollision. Eingangslinien und NPC-Positionen werden geprüft. Bildränder werden vor Nearest-Neighbor-Verkleinerung von halbtransparenten Fransen befreit. Renderprüfung: komplette Dorfansicht und Übersicht der 14 platzierten Objekte.
