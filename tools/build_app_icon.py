#!/usr/bin/env python3
"""Symbol der Android-App: Sonne über dem Hain (Angelo 11.10.2026).

Pixelbild im Stil des Spiels auf 108×108 Punkten, vierfach auf 432 px
vergrößert. Hintergrund (Himmel, Hügel) und Vordergrund (Sonne, Bäume) sind
getrennt, damit Android daraus ein „adaptives“ Symbol schneiden kann; die
wichtigen Teile liegen im sicheren Mittelkreis (zwei Drittel).

Ausgabe in art/app_icon/: background_432.png, foreground_432.png, main_192.png.
Aufruf: python3 tools/build_app_icon.py
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parents[1] / "art/app_icon"
N = 108
SKY = [(0.00, (23, 52, 84)), (0.45, (70, 98, 130)), (0.70, (222, 150, 96)), (1.00, (247, 205, 120))]
HILL_FAR = (62, 112, 84)
HILL_NEAR = (44, 88, 62)
SUN = (255, 214, 102)
SUN_LIGHT = (255, 240, 176)
SUN_EDGE = (232, 150, 60)
LEAF = [(34, 82, 58), (48, 108, 72), (74, 142, 88)]
TRUNK = (84, 56, 40)
OUTLINE = (20, 36, 40)


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def sky(y: float):
    for (p0, c0), (p1, c1) in zip(SKY, SKY[1:]):
        if y <= p1:
            return lerp(c0, c1, (y - p0) / (p1 - p0))
    return SKY[-1][1]


def background() -> Image.Image:
    img = Image.new("RGBA", (N, N))
    px = img.load()
    for y in range(N):
        band = sky(round(y / 6) * 6 / N)          # Himmel in Stufen, wie gemalt
        for x in range(N):
            px[x, y] = band + (255,)
    d = ImageDraw.Draw(img)
    # ferne und nahe Hügel
    for x in range(N):
        far = 78 + round(5 * math.sin(x / 13.0 + 0.6))
        near = 90 + round(4 * math.sin(x / 9.0 + 2.0))
        d.line([(x, far), (x, N)], fill=HILL_FAR)
        d.line([(x, near), (x, N)], fill=HILL_NEAR)
    return img


def tree(d: ImageDraw.ImageDraw, cx: int, base: int, r: int) -> None:
    d.rectangle([cx - 1, base - r - 2, cx + 1, base], fill=TRUNK)
    top = base - 2 * r - 2
    d.ellipse([cx - r - 1, top - 1, cx + r + 1, top + 2 * r + 1], fill=OUTLINE)
    d.ellipse([cx - r, top, cx + r, top + 2 * r], fill=LEAF[0])
    d.ellipse([cx - r + 1, top + 1, cx + r - 2, top + 2 * r - 3], fill=LEAF[1])
    d.ellipse([cx - r + 3, top + 2, cx + 1, top + r], fill=LEAF[2])


def foreground() -> Image.Image:
    img = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy, r = 54, 46, 17
    # Strahlen: zwölf Keile
    for k in range(12):
        a = k * math.tau / 12
        inner, outer = r + 4, r + (13 if k % 2 == 0 else 8)
        w = 0.17
        pts = [(cx + math.cos(a - w) * inner, cy + math.sin(a - w) * inner),
               (cx + math.cos(a) * outer, cy + math.sin(a) * outer),
               (cx + math.cos(a + w) * inner, cy + math.sin(a + w) * inner)]
        d.polygon(pts, fill=SUN_EDGE)
    d.ellipse([cx - r - 1, cy - r - 1, cx + r + 1, cy + r + 1], fill=OUTLINE)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=SUN)
    d.ellipse([cx - r + 3, cy - r + 3, cx + r - 5, cy + r - 5], fill=SUN_LIGHT)
    # Hain: drei Bäume, mittlerer größer
    tree(d, 36, 82, 8)
    tree(d, 72, 83, 9)
    tree(d, 54, 86, 11)
    return img


def up(img: Image.Image) -> Image.Image:
    return img.resize((432, 432), Image.NEAREST)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    bg, fg = background(), foreground()
    up(bg).save(OUT / "background_432.png")
    up(fg).save(OUT / "foreground_432.png")
    full = bg.copy()
    full.alpha_composite(fg)
    up(full).resize((192, 192), Image.LANCZOS).save(OUT / "main_192.png")
    print("icons:", sorted(p.name for p in OUT.iterdir()))


if __name__ == "__main__":
    main()
