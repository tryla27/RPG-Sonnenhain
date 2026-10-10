#!/usr/bin/env python3
"""Pixel-Sprite des Dunklen Golems (Golem v2, 10.10.2026).

Eigener Entwurf: gebückter Koloss aus kantigen Basaltblöcken mit lila
Elixier-Rissen, stämmigen Beinen (etwa ein Drittel der Höhe), riesigen Fäusten,
tief sitzendem Kopf mit zwei glühenden Spalten und schwebenden Steinen.

Ausgabe (je Bild 128×128 px, Füße bei y=124, Mitte x=64):
  art/monsters/golem/golem_sheet.png  – Körper
  art/monsters/golem/golem_glow.png   – nur Risse/Augen (im Spiel pulsierend)
  Zeilen: 0 vorn, 1 Seite (nach rechts), 2 hinten, 3 Seite (nach links,
  gespiegelt; im Spiel wird nicht mit negativer Breite gespiegelt, das zeichnet
  Godot bei Ausschnitten nicht)
  Spalten: FRAMES (siehe unten)
Mit --preview <datei.png> zusätzlich ein beschriftetes Vorschaublatt (3×).

Aufruf: python3 tools/build_golem_art.py [--preview out.png]
"""
import math
import random
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "art" / "monsters" / "golem"
SIZE = 128
FEET = 124
CX = 64
FRAMES = ["idle0", "idle1", "walk0", "walk1", "walk2", "walk3", "shield", "scrape", "stomp", "scream", "rise"]
VIEWS = ["front", "side", "back"]

OUTLINE = (16, 14, 20, 255)
DARK = (30, 27, 37, 255)
BASE = (46, 42, 54, 255)
MID = (62, 57, 72, 255)
LIGHT = (86, 79, 98, 255)
HIGH = (122, 113, 135, 255)
SPECK = (55, 51, 64, 255)
CRACK = (180, 92, 255, 255)
CRACK_GLOW = (227, 184, 255, 110)
EYE = (240, 210, 255, 255)


class Canvas:
    def __init__(self):
        self.body = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
        self.glow = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)

    # --- Masken ---------------------------------------------------------
    @staticmethod
    def poly_mask(points):
        img = Image.new("L", (SIZE, SIZE), 0)
        ImageDraw.Draw(img).polygon([(round(x), round(y)) for x, y in points], fill=255)
        return np.array(img) > 0

    @staticmethod
    def shift(mask, dx, dy):
        out = np.zeros_like(mask)
        h, w = mask.shape
        xs, xd = (slice(0, w - dx), slice(dx, w)) if dx >= 0 else (slice(-dx, w), slice(0, w + dx))
        ys, yd = (slice(0, h - dy), slice(dy, h)) if dy >= 0 else (slice(-dy, h), slice(0, h + dy))
        out[yd, xd] = mask[ys, xs]
        return out

    def put(self, mask, color, layer=None):
        layer = self.body if layer is None else layer
        layer[mask] = color

    # --- Steinblock mit Fase, Licht oben links ---------------------------
    def stone(self, points, seed, tone=0, crease=True):
        rnd = random.Random(seed)
        m = self.poly_mask(points)
        if not m.any():
            return m
        outline = m | self.shift(m, 1, 0) | self.shift(m, -1, 0) | self.shift(m, 0, 1) | self.shift(m, 0, -1)
        self.put(outline & ~m, OUTLINE)
        base, mid, light, high, dark = BASE, MID, LIGHT, HIGH, DARK
        if tone < 0:  # Teile im Hintergrund dunkler
            base, mid, light, high, dark = DARK, BASE, MID, LIGHT, OUTLINE
        self.put(m, base)
        # Oberseite des Blocks heller (drei Flächen: oben, vorn, unten).
        ys_all, xs_all = np.nonzero(m)
        top_y = ys_all.min()
        height = ys_all.max() - top_y + 1
        face = m.copy()
        face[top_y + max(2, int(height * 0.28)):, :] = False
        self.put(face, mid)
        # Licht: obere/linke Kante, Schatten: untere/rechte Kante.
        top1 = m & ~self.shift(m, 0, 1)
        left1 = m & ~self.shift(m, 1, 0)
        top2 = m & ~self.shift(m, 0, 2) & ~top1
        bottom1 = m & ~self.shift(m, 0, -1)
        right1 = m & ~self.shift(m, -1, 0)
        bottom2 = m & ~self.shift(m, 0, -2) & ~bottom1
        self.put(top2, light)
        self.put(top1 | left1, high)
        self.put(bottom2, mid if tone >= 0 else base)
        self.put(bottom1 | right1, dark)
        # Körnung: helle und dunkle Sprenkel im Inneren.
        ys, xs = np.nonzero(m & ~top1 & ~top2 & ~bottom1 & ~bottom2 & ~left1 & ~right1)
        for i in range(len(xs) // 45):
            k = rnd.randrange(len(xs))
            self.body[ys[k], xs[k]] = SPECK if rnd.random() < 0.6 else dark
        # Fasenlinie quer durch den Block (bricht die Fläche).
        if crease and len(xs) > 60:
            minx, maxx, miny, maxy = xs.min(), xs.max(), ys.min(), ys.max()
            y0 = miny + (maxy - miny) * rnd.uniform(0.35, 0.65)
            pts = []
            for x in range(minx + 2, maxx - 1):
                y = int(round(y0 + (x - minx) * rnd.uniform(-0.25, 0.25)))
                if 0 <= y < SIZE and m[y, x] and m[min(SIZE - 1, y + 1), x]:
                    pts.append((x, y))
            for x, y in pts:
                self.body[y, x] = dark
                if y + 1 < SIZE and m[y + 1, x]:
                    self.body[y + 1, x] = mid
        return m

    # --- Risse (Rille im Körper + Leuchten im Glow-Layer) -----------------
    def crack(self, points, mask=None, seed=None):
        rnd = random.Random(seed if seed is not None else int(points[0][0] * 31 + points[0][1] * 7))
        # Unregelmäßig: jede Strecke in kleine, seitlich versetzte Stücke teilen,
        # dazu ab und zu ein kurzer Seitenast.
        jag = [points[0]]
        branches = []
        for (x0, y0), (x1, y1) in zip(points, points[1:]):
            n = max(2, int(math.hypot(x1 - x0, y1 - y0) / 3))
            for k in range(1, n + 1):
                t = k / n
                x = x0 + (x1 - x0) * t + (rnd.uniform(-1.4, 1.4) if k < n else 0)
                y = y0 + (y1 - y0) * t + (rnd.uniform(-1.4, 1.4) if k < n else 0)
                jag.append((x, y))
                if k < n and rnd.random() < 0.12:
                    a = math.atan2(y1 - y0, x1 - x0) + rnd.choice([-1, 1]) * rnd.uniform(0.6, 1.2)
                    l = rnd.uniform(3, 6)
                    branches.append([(x, y), (x + math.cos(a) * l, y + math.sin(a) * l)])
        img = Image.new("L", (SIZE, SIZE), 0)
        dr = ImageDraw.Draw(img)
        dr.line([(round(x), round(y)) for x, y in jag], fill=255, width=1)
        for b in branches:
            dr.line([(round(x), round(y)) for x, y in b], fill=255, width=1)
        line = np.array(img) > 0
        if mask is not None:
            line &= mask
        halo = (self.shift(line, 1, 0) | self.shift(line, -1, 0) | self.shift(line, 0, 1) | self.shift(line, 0, -1)) & ~line
        if mask is not None:
            halo &= mask
        self.put(line, OUTLINE)
        self.put(halo, CRACK_GLOW, self.glow)
        self.put(line, CRACK, self.glow)

    def eyes(self, points):
        for (x, y) in points:
            for dx in range(-3, 4):
                self.glow[y, x + dx] = CRACK if abs(dx) == 3 else EYE
                self.body[y, x + dx] = OUTLINE
            for dx in range(-2, 3):
                self.glow[y - 1, x + dx] = CRACK_GLOW
                self.glow[y + 1, x + dx] = CRACK_GLOW


def rect_poly(x0, y0, x1, y1, cut=3):
    """Kantiger Block: Rechteck mit abgeschrägten Ecken."""
    return [(x0 + cut, y0), (x1 - cut, y0), (x1, y0 + cut), (x1, y1 - cut), (x1 - cut, y1), (x0 + cut, y1), (x0, y1 - cut), (x0, y0 + cut)]


def boulder_poly(cx, cy, rx, ry, seed, n=9):
    rnd = random.Random(seed)
    pts = []
    for k in range(n):
        a = k * math.tau / n + rnd.uniform(-0.18, 0.18)
        r = rnd.uniform(0.82, 1.05)
        pts.append((cx + math.cos(a) * rx * r, cy + math.sin(a) * ry * r))
    return pts


# --- Pose je Ansicht und Zustand --------------------------------------------

def pose(view, frame):
    """Parameter der Teile: Versatz in Pixeln."""
    p = {"bob": 0, "crouch": 0, "legL": (0, 0), "legR": (0, 0), "armL": (0, 0), "armR": (0, 0),
         "fistL": None, "fistR": None, "head": (0, 0), "stones": 0, "mouth": False}
    if frame.startswith("idle"):
        p["stones"] = 0 if frame == "idle0" else 1
    elif frame.startswith("walk"):
        k = int(frame[-1])
        phase = [0, 1, 0, -1][k]
        p["bob"] = [0, -1, 0, -1][k]
        p["legL"] = (phase * 3, -max(0, phase) * 3)
        p["legR"] = (-phase * 3, -max(0, -phase) * 3)
        p["armL"] = (0, -phase * 2)
        p["armR"] = (0, phase * 2)
        p["stones"] = k % 2
    elif frame == "shield":
        p["crouch"] = 6
        p["fistL"] = (-14, 38)
        p["fistR"] = (14, 34)
    elif frame == "scrape":
        p["fistR"] = (44, 110) if view != "side" else (38, 112)
        p["crouch"] = 3
    elif frame == "stomp":
        p["fistR"] = (30, 16) if view != "side" else (18, 15)
    elif frame == "scream":
        p["fistL"] = (-48, 20)
        p["fistR"] = (48, 20)
        p["head"] = (0, -4)
        p["mouth"] = True
    elif frame == "rise":
        p["crouch"] = 16
        p["legL"] = (-4, 0)
        p["legR"] = (4, 0)
        p["fistL"] = (-46, 114)
        p["fistR"] = (46, 114)
    return p


def draw_front(c, p, back=False):
    dy = p["crouch"] + p["bob"]
    # Beine: stämmig, Oberschenkel + Schienbein mit breitem Fuß.
    for side, key in ((-1, "legL"), (1, "legR")):
        ox, lift = p[key]
        x = CX + side * 18 + ox
        x = CX + side * 19 + ox
        c.stone(rect_poly(x - 15, 82 + dy * 0.5 + lift, x + 15, 104 + lift, 4), 11 + side)
        c.stone(rect_poly(x - 17, 98 + lift, x + 17, FEET + lift, 4), 21 + side)
        c.stone(boulder_poly(x + side * 2, 99 + lift, 9, 6, 25 + side, 8), 25 + side, crease=False)  # Kniestein
        c.stone(rect_poly(x - 19, FEET - 7 + lift, x + 19, FEET + lift, 2), 31 + side, crease=False)
    # Hüfte
    c.stone(rect_poly(CX - 26, 74 + dy, CX + 26, 92 + dy * 0.6, 4), 40)
    # Rumpf: breite Brust, schmalere Taille.
    chest = [(CX - 34, 40 + dy), (CX - 22, 32 + dy), (CX + 22, 32 + dy), (CX + 34, 40 + dy), (CX + 30, 70 + dy), (CX + 20, 82 + dy), (CX - 20, 82 + dy), (CX - 30, 70 + dy)]
    torso = c.stone(chest, 50)
    if not back:
        c.stone([(CX - 18, 44 + dy), (CX + 18, 44 + dy), (CX + 14, 64 + dy), (CX - 14, 64 + dy)], 51, crease=False)
        c.crack([(CX - 22, 46 + dy), (CX - 12, 56 + dy), (CX - 18, 66 + dy), (CX - 8, 78 + dy)], torso)
        c.crack([(CX + 20, 44 + dy), (CX + 12, 56 + dy), (CX + 22, 70 + dy)], torso)
    else:
        for k in range(4):
            c.stone(rect_poly(CX - 6, 36 + dy + k * 11, CX + 6, 45 + dy + k * 11, 2), 55 + k, crease=False)
        c.crack([(CX - 26, 50 + dy), (CX - 14, 60 + dy), (CX - 24, 74 + dy)], torso)
        c.crack([(CX + 24, 48 + dy), (CX + 16, 66 + dy)], torso)
    # Kopf tief zwischen den Schultern.
    hx, hy = p["head"]
    if not back:
        head = c.stone(rect_poly(CX - 13 + hx, 20 + dy + hy, CX + 13 + hx, 44 + dy + hy, 4), 60)
        c.stone(rect_poly(CX - 15 + hx, 24 + dy + hy, CX + 15 + hx, 30 + dy + hy, 2), 61, crease=False)  # Stirnplatte
        c.eyes([(CX - 6 + hx, 34 + dy + hy), (CX + 6 + hx, 34 + dy + hy)])
        c.crack([(CX - 9 + hx, 22 + dy + hy), (CX + 2 + hx, 27 + dy + hy), (CX + 8 + hx, 22 + dy + hy)], head)
        if p["mouth"]:
            for x in range(CX - 5 + hx, CX + 6 + hx):
                c.glow[40 + dy + hy, x] = CRACK
                c.body[40 + dy + hy, x] = OUTLINE
    else:
        c.stone(rect_poly(CX - 12, 22 + dy, CX + 12, 40 + dy, 4), 62)
    # Schultern: große Brocken.
    for side in (-1, 1):
        c.stone(boulder_poly(CX + side * 38, 38 + dy, 17, 14, 70 + side, 10), 70 + side)
        if not back:
            c.crack([(CX + side * 30, 34 + dy), (CX + side * 40, 40 + dy), (CX + side * 46, 36 + dy)])
    # Arme und Fäuste.
    for side, key, fkey in ((-1, "armL", "fistL"), (1, "armR", "fistR")):
        ax, ay = p[key]
        fist = p[fkey]
        if fist is None:
            fx, fy = CX + side * 46 + ax, 84 + dy + ay
        else:
            fx, fy = CX + fist[0], min(fist[1], FEET - 14)
        sx, sy = CX + side * 44, 48 + dy
        # Oberarm als schräger Block zwischen Schulter und Faust.
        mx, my = (sx + fx) / 2, (sy + fy) / 2
        ang = math.atan2(fy - sy, fx - sx)
        length = math.hypot(fx - sx, fy - sy) * 0.5 + 6
        nx, ny = -math.sin(ang) * 9, math.cos(ang) * 9
        ux, uy = math.cos(ang) * length, math.sin(ang) * length
        c.stone([(mx - ux + nx, my - uy + ny), (mx + ux + nx, my + uy + ny), (mx + ux - nx, my + uy - ny), (mx - ux - nx, my - uy - ny)], 80 + side, tone=0 if fist is None else 0)
        f = c.stone(rect_poly(fx - 14, fy - 13, fx + 14, fy + 13, 5), 90 + side)
        c.crack([(fx - 9 * side, fy - 8), (fx + 2 * side, fy + 1), (fx + 7 * side, fy + 9)], f)
    # Schwebende Steine über den Schultern.
    for k, (sx, sy) in enumerate([(-44, 12), (44, 10), (-24, 4), (26, 2)]):
        off = (1 if (k + p["stones"]) % 2 == 0 else -1) * 2
        s = c.stone(boulder_poly(CX + sx, sy + off + dy * 0.5, 6, 5, 100 + k, 7), 100 + k, crease=False)
        c.crack([(CX + sx - 2, sy + off + dy * 0.5), (CX + sx + 2, sy + off + dy * 0.5)], s)


def draw_side(c, p):
    dy = p["crouch"] + p["bob"]
    # Hinteres Bein (dunkler), dann hinterer Arm.
    ox, lift = p["legR"]
    x = CX - 4 + ox
    c.stone(rect_poly(x - 12, 86 + dy * 0.5 + lift, x + 12, 106 + lift, 3), 12, tone=-1)
    c.stone(rect_poly(x - 13, 100 + lift, x + 16, FEET + lift, 3), 22, tone=-1)
    back_fist = p["fistL"]
    bfx, bfy = (CX - 6 + p["armL"][1], 88 + dy) if back_fist is None else (CX + back_fist[0] * 0.3, min(back_fist[1], FEET - 14))
    c.stone(rect_poly(CX - 10, 46 + dy, CX + 8, 70 + dy, 3), 81, tone=-1)
    c.stone(rect_poly(bfx - 13, bfy - 12, bfx + 13, bfy + 12, 5), 91, tone=-1)
    # Vorderes Bein.
    ox, lift = p["legL"]
    x = CX + 6 + ox
    c.stone(rect_poly(x - 12, 86 + dy * 0.5 + lift, x + 12, 106 + lift, 3), 11)
    c.stone(rect_poly(x - 13, 100 + lift, x + 17, FEET + lift, 3), 21)
    c.stone(rect_poly(x - 14, FEET - 6 + lift, x + 19, FEET + lift, 2), 31, crease=False)
    # Hüfte und gebückter Rumpf (nach vorn geneigt).
    c.stone(rect_poly(CX - 18, 74 + dy, CX + 20, 92 + dy * 0.6, 4), 40)
    body = [(CX - 26, 44 + dy), (CX - 10, 30 + dy), (CX + 18, 30 + dy), (CX + 30, 40 + dy), (CX + 24, 72 + dy), (CX + 14, 82 + dy), (CX - 16, 82 + dy), (CX - 26, 66 + dy)]
    torso = c.stone(body, 50)
    c.crack([(CX - 18, 46 + dy), (CX - 8, 58 + dy), (CX - 16, 72 + dy)], torso)
    c.crack([(CX + 12, 40 + dy), (CX + 4, 54 + dy), (CX + 14, 66 + dy)], torso)
    # Rückenbuckel mit Brocken.
    c.stone(boulder_poly(CX - 12, 36 + dy, 16, 13, 71, 10), 71)
    # Kopf vorn unten.
    hx, hy = p["head"]
    head = c.stone(rect_poly(CX + 16 + hx, 32 + dy + hy, CX + 38 + hx, 52 + dy + hy, 4), 60)
    c.stone(rect_poly(CX + 16 + hx, 34 + dy + hy, CX + 40 + hx, 39 + dy + hy, 2), 61, crease=False)
    c.eyes([(CX + 32 + hx, 44 + dy + hy)])
    c.crack([(CX + 20 + hx, 34 + dy + hy), (CX + 26 + hx, 40 + dy + hy)], head)
    if p["mouth"]:
        for x in range(CX + 28 + hx, CX + 37 + hx):
            c.glow[49 + dy + hy, x] = CRACK
    # Schulter und vorderer Arm mit Faust.
    c.stone(boulder_poly(CX + 6, 40 + dy, 15, 13, 72, 10), 72)
    fist = p["fistR"]
    if fist is None:
        fx, fy = CX + 26 + p["armR"][1], 86 + dy
    else:
        fx, fy = CX + fist[0], min(fist[1], FEET - 14)
    sx, sy = CX + 12, 46 + dy
    mx, my = (sx + fx) / 2, (sy + fy) / 2
    ang = math.atan2(fy - sy, fx - sx)
    length = math.hypot(fx - sx, fy - sy) * 0.5 + 6
    nx, ny = -math.sin(ang) * 7, math.cos(ang) * 7
    ux, uy = math.cos(ang) * length, math.sin(ang) * length
    c.stone([(mx - ux + nx, my - uy + ny), (mx + ux + nx, my + uy + ny), (mx + ux - nx, my + uy - ny), (mx - ux - nx, my - uy - ny)], 82)
    f = c.stone(rect_poly(fx - 14, fy - 13, fx + 14, fy + 13, 5), 92)
    c.crack([(fx - 9, fy - 8), (fx + 2, fy + 1), (fx + 7, fy + 9)], f)
    for k, (sx2, sy2) in enumerate([(-30, 10), (-6, 4), (16, 8)]):
        off = (1 if (k + p["stones"]) % 2 == 0 else -1) * 2
        s = c.stone(boulder_poly(CX + sx2, sy2 + off + dy * 0.5, 6, 5, 110 + k, 7), 110 + k, crease=False)
        c.crack([(CX + sx2 - 2, sy2 + off + dy * 0.5), (CX + sx2 + 2, sy2 + off + dy * 0.5)], s)


def render(view, frame):
    c = Canvas()
    p = pose(view, frame)
    if view == "side":
        draw_side(c, p)
    else:
        draw_front(c, p, back=(view == "back"))
    return Image.fromarray(c.body, "RGBA"), Image.fromarray(c.glow, "RGBA")


def build():
    sheet = Image.new("RGBA", (SIZE * len(FRAMES), SIZE * (len(VIEWS) + 1)), (0, 0, 0, 0))
    glow = Image.new("RGBA", sheet.size, (0, 0, 0, 0))
    for r, view in enumerate(VIEWS):
        for col, frame in enumerate(FRAMES):
            b, g = render(view, frame)
            sheet.paste(b, (col * SIZE, r * SIZE))
            glow.paste(g, (col * SIZE, r * SIZE))
            if view == "side":
                row = len(VIEWS)
                sheet.paste(b.transpose(Image.FLIP_LEFT_RIGHT), (col * SIZE, row * SIZE))
                glow.paste(g.transpose(Image.FLIP_LEFT_RIGHT), (col * SIZE, row * SIZE))
    return sheet, glow


def preview(sheet, glow, out):
    scale = 3
    pad = 24
    w = SIZE * len(FRAMES) * scale
    h = (SIZE * scale + pad) * len(VIEWS) + 60
    img = Image.new("RGBA", (w, h), (143, 174, 122, 255))
    d = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 22)
    except OSError:
        font = ImageFont.load_default()
    d.text((12, 12), "Dunkler Golem v2 · 128×128 px je Bild (im Spiel 2,5× ≈ 320 px) · Zeilen: vorn, Seite, hinten", fill=(255, 243, 207, 255), font=font)
    combined = Image.alpha_composite(sheet, glow)
    for r, view in enumerate(VIEWS):
        y0 = 60 + r * (SIZE * scale + pad)
        for col, frame in enumerate(FRAMES):
            cell = combined.crop((col * SIZE, r * SIZE, (col + 1) * SIZE, (r + 1) * SIZE)).resize((SIZE * scale, SIZE * scale), Image.NEAREST)
            x0 = col * SIZE * scale
            d.ellipse((x0 + 64 * scale - 150, y0 + FEET * scale - 18, x0 + 64 * scale + 150, y0 + FEET * scale + 22), fill=(0, 0, 0, 70))
            img.alpha_composite(cell, (x0, y0))
            if r == 0:
                d.text((x0 + 10, y0 + 6), frame, fill=(255, 243, 207, 255), font=font)
    img.convert("RGB").save(out)


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    sheet, glow = build()
    sheet.save(OUT_DIR / "golem_sheet.png")
    glow.save(OUT_DIR / "golem_glow.png")
    if "--preview" in sys.argv:
        preview(sheet, glow, sys.argv[sys.argv.index("--preview") + 1])
    print("golem art:", OUT_DIR)


if __name__ == "__main__":
    main()
