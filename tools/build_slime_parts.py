#!/usr/bin/env python3
"""Waldschleim in Körper und Blatt zerlegen (für geschmeidiges Hüpfen).

Vorlage: das Ruhebild (Bild 0) jeder Richtung aus
art/sprites/mobs/woodland_v3/forest_slime/<richtung>.png.
Das Blatt sitzt oben auf einem schmalen Stiel; die schmalste Zeile zwischen
Blatt und Kuppel ist der Schnitt. Darüber: Blatt, darunter: Körper.

Ausgabe: art/sprites/mobs/woodland_v3/forest_slime/parts/<richtung>.png
  zwei Bilder à 128×128 nebeneinander: [Körper, Blatt].
Die Drehpunkte der Blätter druckt das Werkzeug als GDScript-Konstante aus
(components/forest_slime_motion.gd, LEAF_PIVOTS).

Aufruf: python3 tools/build_slime_parts.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "art/sprites/mobs/woodland_v3/forest_slime"
OUT = SRC / "parts"
DIRS = ["south", "south_west", "west", "north_west", "north", "north_east", "east", "south_east"]


def split(frame: np.ndarray):
    alpha = frame[:, :, 3] > 100
    rows = [y for y in range(frame.shape[0]) if alpha[y].any()]
    top = rows[0]
    widths = {y: int(alpha[y].sum()) for y in rows}
    # Blattbreite: größte Breite in den obersten 18 Zeilen; der Stiel ist die
    # schmalste Zeile danach, bevor die Kuppel breiter als das Blatt wird.
    leaf_peak = max(range(top, top + 18), key=lambda y: widths.get(y, 0))
    cut = leaf_peak
    for y in range(leaf_peak, top + 40):
        if widths.get(y, 0) <= widths.get(cut, 999):
            cut = y
        if widths.get(y, 0) > widths[leaf_peak] + 6:
            break
    cols = np.nonzero(alpha[cut])[0]
    pivot = (float(cols.mean()), float(cut))
    body = frame.copy()
    body[:cut] = 0
    leaf = frame.copy()
    leaf[cut:] = 0
    return body, leaf, pivot


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    pivots = []
    for d in DIRS:
        strip = np.array(Image.open(SRC / f"{d}.png").convert("RGBA"))
        frame = strip[:, :128]
        body, leaf, pivot = split(frame)
        out = np.zeros((128, 256, 4), dtype=np.uint8)
        out[:, :128] = body
        out[:, 128:] = leaf
        Image.fromarray(out, "RGBA").save(OUT / f"{d}.png")
        pivots.append(pivot)
    print("const LEAF_PIVOTS:=[" + ",".join("Vector2(%.1f,%.1f)" % p for p in pivots) + "]")


if __name__ == "__main__":
    main()
