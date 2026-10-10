#!/usr/bin/env python3
"""Goldener Ritter (menschlicher Krieger) als vollständiges Sprite-Blatt.

Vorlage im Repo: das erste Bild jeder Sprung-Animation
(art/sprites/characters/golden_human_warrior/jump/jump-<richtung>-8f-v1.png)
zeigt den Ritter stehend in allen 8 Richtungen. Daraus entstehen hier alle
übrigen Bewegungen, damit der Krieger überall gleich aussieht (Angelo
10.10.2026: „vollständig auf den neuen Ritter anpassen, die Vorlagen müssen im
Repo sein“).

Ausgabe: art/sprites/characters/golden_human_warrior/knight_8dir.png
  Zelle 64×80 px, Fußpunkt bei y=76, Mitte x=32.
  Zeilen: Richtungen S, SW, W, NW, N, NE, O, SO (wie Hero.direction_index).
  Spalten: ANIMS unten (Stehen 4, Gehen 6, Laufen 6, Angriff 4, Treffer 2).
Waffe, Arm und Umhang zeichnet das Spiel weiterhin darüber.

Aufruf: python3 tools/build_golden_warrior.py [--preview vorschau.png]
"""
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "art/sprites/characters/golden_human_warrior/jump"
OUT = ROOT / "art/sprites/characters/golden_human_warrior/knight_8dir.png"
DIRS = ["south", "south-west", "west", "north-west", "north", "north-east", "east", "south-east"]
# Blickrichtung je Zeile in Bildschirmkoordinaten (x nach rechts, y nach unten).
FACING = [(0, 1), (-0.7, 0.7), (-1, 0), (-0.7, -0.7), (0, -1), (0.7, -0.7), (1, 0), (0.7, 0.7)]
CELL_W, CELL_H = 64, 80
FOOT_Y = 76
FIGURE_H = 70
ANIMS = [("idle", 4), ("walk", 6), ("run", 6), ("attack", 4), ("hit", 2)]
OUTLINE = (24, 18, 22, 255)


def standing(direction: str) -> Image.Image:
    """Erstes Sprungbild, freigestellt und auf Spielgröße gebracht."""
    strip = Image.open(SRC / f"jump-{direction}-8f-v1.png").convert("RGBA")
    fw = strip.width / 8
    frame = strip.crop((0, 0, int(round(fw)), strip.height))
    alpha = frame.getchannel("A").point(lambda v: 255 if v > 100 else 0)
    box = alpha.getbbox()
    fig = frame.crop(box)
    scale = FIGURE_H / fig.height
    size = (max(1, round(fig.width * scale)), FIGURE_H)
    # Erst weich verkleinern, dann Kanten härten (keine halbtransparenten Säume).
    small = fig.resize(size, Image.LANCZOS).filter(ImageFilter.UnsharpMask(radius=1, percent=60, threshold=2))
    arr = np.array(small)
    solid = arr[:, :, 3] > 110
    arr[:, :, 3] = np.where(solid, 255, 0)
    # 1-px-Umriss wie bei den übrigen Pixelfiguren.
    pad = np.pad(solid, 1)
    ring = (pad[:-2, 1:-1] | pad[2:, 1:-1] | pad[1:-1, :-2] | pad[1:-1, 2:]) & ~solid
    arr[ring] = OUTLINE
    return Image.fromarray(arr, "RGBA")


def place(fig: Image.Image) -> tuple:
    """Lage der Figur in der Zelle (Füße auf FOOT_Y, mittig)."""
    return (CELL_W - fig.width) // 2, FOOT_Y - fig.height


def split_legs(fig: Image.Image):
    """Teilt die Figur in Oberkörper und zwei Beine (an der Hüfte, mittig)."""
    arr = np.array(fig)
    h, w = arr.shape[:2]
    hip = int(h * 0.64)
    cols = np.nonzero(arr[hip:, :, 3].any(axis=0))[0]
    mid = int((cols.min() + cols.max()) / 2) if len(cols) else w // 2
    upper = arr.copy(); upper[hip:] = 0
    # Beine reichen 5 px unter den Oberkörper und 2 px über die Mitte, damit beim
    # Heben, Schreiten und Wippen keine Lücken entstehen (der Oberkörper liegt
    # darüber).
    top = max(0, hip - 5)
    left = np.zeros_like(arr); left[top:, :mid + 2] = arr[top:, :mid + 2]
    right = np.zeros_like(arr); right[top:, mid - 2:] = arr[top:, mid - 2:]
    to = lambda a: Image.fromarray(a, "RGBA")
    return to(upper), to(left), to(right)


def compose(fig, upper, left, right, body=(0, 0), lft=(0, 0), rgt=(0, 0)):
    cell = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
    x, y = place(fig)
    # Hinteres Bein zuerst: das mit dem größeren Hub (in der Luft) liegt vorn.
    order = [(left, lft), (right, rgt)]
    order.sort(key=lambda item: -item[1][1])
    for img, (dx, dy) in order:
        cell.alpha_composite(img, (x + dx, y + dy))
    cell.alpha_composite(upper, (x + body[0], y + body[1]))
    return cell


def frames_for(row: int) -> list:
    fig = standing(DIRS[row])
    upper, left, right = split_legs(fig)
    fx, fy = FACING[row]
    side = abs(fx) > 0.5            # Seitenansicht: Beine schreiten vor/zurück
    out = []
    # Stehen: ruhiges Atmen (Oberkörper 1 px).
    for k in range(4):
        breath = [0, 0, 1, 1][k]
        out.append(compose(fig, upper, left, right, body=(0, breath)))
    # Gehen und Laufen: Beine abwechselnd heben, bei Seitenansicht schreiten.
    for kind, count, lift, stride, bob, lean in (("walk", 6, 3, 2, 1, 0), ("run", 6, 5, 4, 2, 2)):
        for k in range(count):
            t = k / count * math.tau
            l_up = max(0.0, math.sin(t)) * lift
            r_up = max(0.0, math.sin(t + math.pi)) * lift
            l_dx = math.cos(t) * stride * (1 if side else 0.4) * (fx if side else 1)
            r_dx = -l_dx
            body_dy = round(abs(math.sin(t)) * -bob)
            body_dx = round(fx * lean)
            out.append(compose(fig, upper, left, right,
                               body=(body_dx, body_dy),
                               lft=(round(l_dx), -round(l_up)),
                               rgt=(round(r_dx), -round(r_up))))
    # Angriff: Ausholen, Ausfallschritt in Blickrichtung, zurück.
    for k, push in enumerate([-1, 2, 4, 1]):
        dx, dy = round(fx * push), round(fy * push * 0.6)
        out.append(compose(fig, upper, left, right, body=(dx, dy), lft=(round(dx * 0.5), round(dy * 0.5)), rgt=(round(dx * 0.5), round(dy * 0.5))))
    # Treffer: kurz nach hinten.
    for k, back in enumerate([2, 1]):
        dx, dy = round(-fx * back), round(-fy * back * 0.6)
        out.append(compose(fig, upper, left, right, body=(dx, dy - 1), lft=(dx, dy), rgt=(dx, dy)))
    return out


def build() -> Image.Image:
    cols = sum(n for _, n in ANIMS)
    sheet = Image.new("RGBA", (CELL_W * cols, CELL_H * len(DIRS)), (0, 0, 0, 0))
    for row in range(len(DIRS)):
        for col, cell in enumerate(frames_for(row)):
            sheet.alpha_composite(cell, (col * CELL_W, row * CELL_H))
    return sheet


def preview(sheet: Image.Image, out: str) -> None:
    scale = 3
    cols = sum(n for _, n in ANIMS)
    img = Image.new("RGBA", (CELL_W * cols * scale, CELL_H * len(DIRS) * scale + 50), (122, 150, 104, 255))
    d = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 22)
    except OSError:
        font = ImageFont.load_default()
    col = 0
    for name, n in ANIMS:
        d.text((col * CELL_W * scale + 6, 12), {"idle": "Stehen", "walk": "Gehen", "run": "Laufen", "attack": "Angriff", "hit": "Treffer"}[name], fill=(255, 243, 207, 255), font=font)
        col += n
    big = sheet.resize((sheet.width * scale, sheet.height * scale), Image.NEAREST)
    img.alpha_composite(big, (0, 50))
    img.convert("RGB").save(out)


def main() -> None:
    sheet = build()
    sheet.save(OUT)
    if "--preview" in sys.argv:
        preview(sheet, sys.argv[sys.argv.index("--preview") + 1])
    print("knight sheet:", OUT, sheet.size)


if __name__ == "__main__":
    main()
