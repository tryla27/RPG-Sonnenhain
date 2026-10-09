#!/usr/bin/env python3
"""Baut die Pixelgrafik der neuen Wegstein-Plateaus (Wunsch 9.10.2026).

Ein erhöhtes Steinplateau mit Treppe, Mauerwerk und eingelassenem Runenkreis,
dazu ein behauener Obelisk. Ein Grafikpixel entspricht 2 Weltpixeln (wie die
32-px-Bodenkacheln mit 16-px-Details). Leuchten, Kristall und Animation zeichnet
das Spiel selbst (components/waystone_shrine_32.gd), damit aktiv/inaktiv und
das Schweben ohne zweite Grafik gehen.

Ausgabe:
  art/village/objects/wegstein-plateau.png   Plateau, Mauer, Treppe (Boden)
  art/village/objects/wegstein-obelisk.png   Obelisk (tiefensortiert)

Aufruf: python3 tools/build_waystone_art.py
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "art" / "village" / "objects"

# Maße in Grafikpixeln (1 Grafikpixel = 2 Weltpixel). Ursprung = Wegstein.
# Muss zu components/waystone_shrine_32.gd passen.
LEFT, RIGHT = -84, 84          # Plateau x
TOP_Y, FRONT_Y = -50, 20       # Oberfläche y (hinten, Vorderkante)
WALL_H = 24                    # sichtbare Mauerhöhe (= 40 Weltpixel Höhenunterschied)
CUT = 14                       # abgeschrägte Ecken
STAIR_HALF = 20                # Treppe halbe Breite
STAIR_STEPS = 3
STAIR_DEPTH = 8                # Tiefe je Stufe
RUNE_CENTER = (0, -16)
RUNE_R = 32

# Bildausschnitt des Plateaus (Grafikpixel relativ zum Wegstein)
PX0, PY0 = -92, -58
PW, PH = 184, 132

PAL = {
    "outline": (38, 36, 34),
    "mortar": (66, 62, 56),
    "deep": (84, 80, 72),
    "dark": (112, 106, 95),
    "mid": (146, 140, 125),
    "light": (182, 176, 158),
    "hi": (211, 206, 186),
    "rim": (196, 190, 170),
    "moss_d": (74, 104, 58),
    "moss": (104, 138, 70),
    "moss_l": (146, 176, 92),
    "groove": (70, 74, 76),
    "socket": (92, 108, 112),
    "shadow": (20, 30, 28),
}

rng = np.random.default_rng(927)


def top_polygon_contains(x: float, y: float) -> bool:
    """Draufsicht der Plateau-Oberfläche (Achteck mit abgeschrägten Ecken)."""
    if not (LEFT <= x <= RIGHT and TOP_Y <= y <= FRONT_Y):
        return False
    dx_left = x - LEFT
    dx_right = RIGHT - x
    dy_top = y - TOP_Y
    dy_front = FRONT_Y - y
    for dx in (dx_left, dx_right):
        for dy in (dy_top, dy_front):
            if dx + dy < CUT:
                return False
    return True


def in_stairs(x: float, y: float) -> bool:
    return abs(x) < STAIR_HALF and FRONT_Y - 2 <= y < FRONT_Y + STAIR_STEPS * STAIR_DEPTH


class Canvas:
    def __init__(self, w: int, h: int, ox: int, oy: int):
        self.w, self.h, self.ox, self.oy = w, h, ox, oy
        self.rgba = np.zeros((h, w, 4), dtype=np.uint8)

    def put(self, x: int, y: int, color, alpha: int = 255) -> None:
        px, py = x - self.ox, y - self.oy
        if 0 <= px < self.w and 0 <= py < self.h:
            if alpha >= 255 or self.rgba[py, px, 3] == 0:
                self.rgba[py, px, :3] = color
                self.rgba[py, px, 3] = max(alpha, int(self.rgba[py, px, 3]))
            else:
                a = alpha / 255.0
                base = self.rgba[py, px, :3].astype(float)
                self.rgba[py, px, :3] = (base * (1 - a) + np.array(color) * a).astype(np.uint8)

    def get(self, x: int, y: int):
        px, py = x - self.ox, y - self.oy
        if 0 <= px < self.w and 0 <= py < self.h:
            return self.rgba[py, px]
        return None

    def save(self, path: Path, scale: int = 1) -> None:
        img = Image.fromarray(self.rgba, "RGBA")
        if scale != 1:
            img = img.resize((self.w * scale, self.h * scale), Image.NEAREST)
        path.parent.mkdir(parents=True, exist_ok=True)
        img.save(path)


def shade(color, amount: float):
    return tuple(int(max(0, min(255, c * amount))) for c in color)


def build_plateau() -> Canvas:
    c = Canvas(PW, PH, PX0, PY0)

    # 1) Schlagschatten auf dem Boden (rechts unten, weich gestuft).
    for y in range(TOP_Y, FRONT_Y + WALL_H + 8):
        for x in range(LEFT, RIGHT + 9):
            sx, sy = x - 6, y - WALL_H - 4
            if top_polygon_contains(sx, min(sy, FRONT_Y)) and sy > TOP_Y - 4:
                c.put(x, y, PAL["shadow"], 70)

    # 2) Mauer: Extrusion der Oberfläche um WALL_H nach unten.
    for x in range(LEFT, RIGHT + 1):
        # unterste Oberflächenkante in dieser Spalte
        edge = None
        for y in range(FRONT_Y, TOP_Y - 1, -1):
            if top_polygon_contains(x, y):
                edge = y
                break
        if edge is None:
            continue
        for d in range(1, WALL_H + 1):
            y = edge + d
            if in_stairs(x, y) and abs(x) < STAIR_HALF:
                continue
            # Mauerwerk: Reihen zu 5 Pixeln, versetzte Steine
            row = d // 5
            course_off = (row * 7) % 12
            stone_id = (x + 200 + course_off) // 12
            in_mortar_row = d % 5 == 0
            in_mortar_col = (x + 200 + course_off) % 12 == 0
            tone = 0.88 + ((stone_id * 37 + row * 11) % 7) * 0.035
            depth = 1.0 - d / (WALL_H * 2.6)          # unten dunkler
            if in_mortar_row or in_mortar_col:
                col = PAL["mortar"]
            else:
                base = PAL["dark"] if (stone_id + row) % 3 else PAL["mid"]
                col = shade(base, tone * depth)
                # Oberkante jedes Steins heller
                if d % 5 == 1:
                    col = shade(col, 1.12)
            # Seiten der abgeschrägten Ecken etwas dunkler (Licht von links oben)
            if x > RIGHT - CUT - 2:
                col = shade(col, 0.82)
            c.put(x, y, col)
        # Fuß: dunkle Kante zum Boden
        c.put(x, edge + WALL_H + 1, PAL["outline"])

    # 3) Oberfläche: große, unregelmäßige Bodenplatten (heller als die Mauer,
    #    feine Fugen), damit die Fläche als Boden und nicht als Wand liest.
    rows = []
    y = TOP_Y
    while y <= FRONT_Y:
        h = int(rng.integers(10, 14))
        cuts = []
        x = LEFT - int(rng.integers(0, 12))
        while x <= RIGHT:
            cuts.append(x)
            x += int(rng.integers(13, 23))
        cuts.append(x)
        rows.append((y, y + h, cuts, [0.92 + rng.random() * 0.12 for _ in cuts]))
        y += h
    joint = shade(PAL["mid"], 0.9)
    for (y0, y1, cuts, tones) in rows:
        for y in range(y0, min(y1, FRONT_Y + 1)):
            for x in range(LEFT, RIGHT + 1):
                if not top_polygon_contains(x, y):
                    continue
                k = 0
                while k + 1 < len(cuts) and cuts[k + 1] <= x:
                    k += 1
                if y == y0 or x == cuts[k]:
                    color = joint
                else:
                    color = shade(PAL["light"], tones[k])
                    if y == y0 + 1 or x == cuts[k] + 1:
                        color = shade(color, 1.06)
                    elif y == y1 - 1:
                        color = shade(color, 0.95)
                    if rng.random() < 0.025:
                        color = shade(color, 0.9)
                c.put(x, y, color)

    # Randsteine (Brüstung) an der Kante, mit Schattenlinie innen.
    for y in range(TOP_Y, FRONT_Y + 1):
        for x in range(LEFT, RIGHT + 1):
            if not top_polygon_contains(x, y):
                continue
            near_edge = any(
                not top_polygon_contains(x + dx, y + dy)
                for dx, dy in ((-2, 0), (2, 0), (0, -2), (0, 2), (-2, -2), (2, 2), (2, -2), (-2, 2))
            )
            if near_edge:
                c.put(x, y, PAL["rim"] if (x + y) % 11 else PAL["mortar"])
                if not any(not top_polygon_contains(x + dx, y + dy) for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1))):
                    pass
            elif any(not top_polygon_contains(x + dx, y + dy) for dx, dy in ((0, -3), (-3, 0))):
                c.put(x, y, shade(PAL["mid"], 0.92))
    # Äußere Kontur oben
    for y in range(TOP_Y - 1, FRONT_Y + 2):
        for x in range(LEFT - 1, RIGHT + 2):
            if top_polygon_contains(x, y):
                continue
            if any(top_polygon_contains(x + dx, y + dy) for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1))):
                if y <= FRONT_Y - 4 or abs(x) > RIGHT - CUT:
                    c.put(x, y, PAL["outline"])

    # 4) Runenkreis eingelassen.
    rx, ry = RUNE_CENTER
    for y in range(ry - RUNE_R - 2, ry + RUNE_R + 3):
        for x in range(rx - RUNE_R - 2, rx + RUNE_R + 3):
            # leicht gestaucht (Draufsicht 3/4)
            d = ((x - rx) ** 2 + ((y - ry) * 1.35) ** 2) ** 0.5
            if RUNE_R - 2.2 <= d <= RUNE_R:
                c.put(x, y, PAL["groove"])
            elif RUNE_R - 3.2 <= d < RUNE_R - 2.2:
                c.put(x, y, PAL["hi"])
            elif 15 <= d <= 16.4:
                c.put(x, y, PAL["groove"])
            elif d < 15 and c.get(x, y) is not None:
                # Innenfläche: ein einziger runder Stein
                c.put(x, y, shade(PAL["light"], 1.04 - d / 120))
    # Acht Runen-Fassungen auf dem Ring
    for k in range(8):
        ang = k * np.pi / 4 + np.pi / 8
        sx = rx + int(round(np.cos(ang) * (RUNE_R - 8)))
        sy = ry + int(round(np.sin(ang) * (RUNE_R - 8) / 1.35))
        for dy in range(-2, 3):
            for dx in range(-2, 3):
                if abs(dx) + abs(dy) <= 3:
                    c.put(sx + dx, sy + dy, PAL["socket"] if abs(dx) + abs(dy) < 3 else PAL["groove"])
    # Linien vom Innenkreis zu den Fassungen
    for k in range(4):
        ang = k * np.pi / 2
        for t in range(16, RUNE_R - 10):
            c.put(rx + int(round(np.cos(ang) * t)), ry + int(round(np.sin(ang) * t / 1.35)), PAL["groove"])

    # 5) Treppe.
    for s in range(STAIR_STEPS):
        y0 = FRONT_Y + s * STAIR_DEPTH
        for y in range(y0, y0 + STAIR_DEPTH):
            for x in range(-STAIR_HALF + 1, STAIR_HALF):
                local = y - y0
                if local < 3:
                    col = shade(PAL["hi"], 1.0 - s * 0.05)          # Trittfläche
                elif local == 3:
                    col = PAL["mortar"]
                else:
                    col = shade(PAL["mid"], 0.86 - s * 0.04)        # Setzstufe
                if (x + 40) % 13 == 0 and local >= 3:
                    col = PAL["mortar"]
                c.put(x, y, col)
        # Wangen links/rechts
        for y in range(y0, y0 + STAIR_DEPTH):
            for side in (-1, 1):
                for w in range(3):
                    x = side * (STAIR_HALF + w)
                    c.put(x, y, shade(PAL["dark"], 0.85 + 0.05 * w) if w else PAL["outline"])
    # Treppenwangen oben als Pfostenköpfe
    for side in (-1, 1):
        for dy in range(-3, 3):
            for dx in range(0, 5):
                x = side * (STAIR_HALF + dx) - (4 if side < 0 else 0) + (0 if side < 0 else 0)
                c.put(side * (STAIR_HALF + 1) + (dx - 2), FRONT_Y + dy - 1, PAL["hi"] if dy < 0 else PAL["light"])

    # 6) Moos: an der Mauerkrone und am Fuß, zufällig.
    for x in range(LEFT, RIGHT + 1):
        if abs(x) < STAIR_HALF + 3:
            continue
        edge = None
        for y in range(FRONT_Y, TOP_Y - 1, -1):
            if top_polygon_contains(x, y):
                edge = y
                break
        if edge is None:
            continue
        r = rng.random()
        if r < 0.22:
            drip = 1 + int(rng.random() * 5)
            for d in range(1, drip + 1):
                c.put(x, edge + d, PAL["moss"] if d < drip else PAL["moss_d"])
            c.put(x, edge, PAL["moss_l"])
        if rng.random() < 0.3:
            h = 1 + int(rng.random() * 3)
            for d in range(h):
                c.put(x, edge + WALL_H - d, PAL["moss_d"] if d else PAL["moss"])
    # Moosflecken auf den Platten
    for _ in range(26):
        x = int(rng.integers(LEFT + 8, RIGHT - 8))
        y = int(rng.integers(TOP_Y + 6, FRONT_Y - 4))
        if not top_polygon_contains(x, y):
            continue
        d = ((x - rx) ** 2 + ((y - ry) * 1.35) ** 2) ** 0.5
        if d < RUNE_R + 3:
            continue
        for dy in range(-1, 2):
            for dx in range(-2, 3):
                if rng.random() < 0.6:
                    c.put(x + dx, y + dy, PAL["moss"] if rng.random() < 0.7 else PAL["moss_l"], 200)

    # 7) Zwei Menhire an den hinteren Ecken (Teil des Bodens, selten verdeckt).
    for side in (-1, 1):
        bx = side * (RIGHT - 26)
        by = TOP_Y + 12
        for y in range(by - 22, by + 1):
            half = 4 if y > by - 18 else 3 - (by - 18 - y) // 2
            for x in range(bx - half, bx + half + 1):
                if half < 0:
                    continue
                edge = x in (bx - half, bx + half) or y == by - 22
                col = PAL["outline"] if edge else (PAL["hi"] if x < bx else PAL["mid"])
                c.put(x, y, col)
        # Rune im Menhir
        for y in range(by - 15, by - 7):
            c.put(bx, y, PAL["groove"])
        c.put(bx - 1, by - 12, PAL["groove"])
        c.put(bx + 1, by - 10, PAL["groove"])
        for x in range(bx - 6, bx + 7):
            c.put(x, by + 1, PAL["shadow"], 90)

    # 8) Steine und Grasbüschel am Fuß.
    for _ in range(18):
        x = int(rng.integers(LEFT - 4, RIGHT + 4))
        if abs(x) < STAIR_HALF + 4:
            continue
        y = FRONT_Y + WALL_H + int(rng.integers(1, 5))
        if rng.random() < 0.5:
            c.put(x, y, PAL["mid"])
            c.put(x + 1, y, PAL["dark"])
            c.put(x, y + 1, PAL["deep"])
        else:
            for d in range(3):
                c.put(x + (d - 1), y - (1 if d == 1 else 0), PAL["moss_l"] if d == 1 else PAL["moss"])
    return c


# Obelisk: eigenes Bild, Fußpunkt = Wegstein + (0, OB_BASE_Y) Grafikpixel.
OB_W, OB_H = 36, 76
OB_BASE_Y = -14


def build_obelisk() -> Canvas:
    c = Canvas(OB_W, OB_H, -OB_W // 2, -OB_H)
    # Sockel (zwei Stufen)
    for y in range(-10, 0):
        half = 15 if y >= -5 else 12
        for x in range(-half, half + 1):
            edge = abs(x) == half or y in (-10, -5)
            col = PAL["outline"] if edge else (PAL["light"] if x < 0 else PAL["mid"])
            if y in (-9, -4) and not edge:
                col = PAL["hi"]
            c.put(x, y, col)
    # Schaft, verjüngt
    top = -66
    for y in range(top, -10):
        t = (y - top) / (-10 - top)
        half = int(round(6 + 3 * t))
        for x in range(-half, half + 1):
            if abs(x) == half:
                col = PAL["outline"]
            elif x < -1:
                col = PAL["light"] if x > -half + 1 else PAL["hi"]
            elif x > 1:
                col = PAL["mid"] if x < half - 1 else PAL["dark"]
            else:
                col = PAL["groove"]                      # Runenrinne (leuchtet im Spiel)
            if (y - top) % 12 == 0 and abs(x) < half:
                col = PAL["mortar"] if abs(x) > 1 else PAL["groove"]
            c.put(x, y, col)
    # Spitze (Pyramide)
    for y in range(top - 6, top + 1):
        half = (y - (top - 6))
        for x in range(-half, half + 1):
            edge = abs(x) == half
            c.put(x, y, PAL["outline"] if edge else (PAL["hi"] if x <= 0 else PAL["mid"]))
    return c


def main() -> None:
    build_plateau().save(OUT / "wegstein-plateau.png", scale=2)
    build_obelisk().save(OUT / "wegstein-obelisk.png", scale=2)
    print("Wegstein-Grafik geschrieben nach", OUT.relative_to(ROOT))


if __name__ == "__main__":
    main()
