"""Create Sonnenhain's original 16 px environment atlas. No external assets needed."""
from pathlib import Path
from PIL import Image, ImageDraw
import random

SIZE = 16
COLS = 8
atlas = Image.new("RGBA", (COLS * SIZE, 4 * SIZE), (0, 0, 0, 0))


def tile(index, base):
    im = Image.new("RGBA", (SIZE, SIZE), base)
    return im, ImageDraw.Draw(im), random.Random(index * 7781 + 29)


def flecks(d, rng, shades, count, bounds=(1, 1, 14, 14)):
    for _ in range(count):
        x = rng.randint(bounds[0], bounds[2]); y = rng.randint(bounds[1], bounds[3])
        d.rectangle((x, y, x + rng.choice([0, 0, 1]), y), fill=rng.choice(shades))


def stone(d, rng, ground=False, moss=False):
    dark, mid, light = ("#5e6570", "#818b94", "#a5abb0") if ground else ("#303945", "#566371", "#83919b")
    d.rectangle((0, 0, 15, 15), fill=dark)
    rows = [(0, 6), (8, 14)]
    for row, (top, bottom) in enumerate(rows):
        shift = 0 if row == 0 else -5
        for x in range(shift, 18, 10):
            if x >= 15: continue
            d.rectangle((max(x + 1, 0), top + 1, min(x + 9, 15), bottom - 1), fill=mid)
            d.line((max(x + 2, 0), top + 2, min(x + 7, 15), top + 2), fill=light)
            if rng.randrange(4) == 0:
                d.point((min(x + 5, 15), bottom - 2), fill=dark)
    if moss:
        for _ in range(5):
            x, y = rng.randrange(16), rng.choice([6, 7, 14, 15])
            d.rectangle((x, y, min(x + 2, 15), y), fill="#659477")


def cobble(d, rng, warm=True):
    dark, base, highlight = ("#8b735d", "#c2a67d", "#e4c999") if warm else ("#414851", "#697680", "#9aabb1")
    d.rectangle((0, 0, 15, 15), fill=dark)
    for y in (0, 6, 12):
        shift = 4 if y == 6 else 0
        for x in range(-shift, 17, 8):
            if x >= 16: continue
            d.rectangle((max(x + 1, 0), y + 1, min(x + 7, 15), min(y + 5, 15)), fill=base)
            d.point((min(max(x + 2, 0), 15), y + 1), fill=highlight)
            if rng.randrange(5) == 0: d.point((min(max(x + 5, 0), 15), y + 3), fill=dark)


def wood(d, rng, wall=False):
    d.rectangle((0, 0, 15, 15), fill="#4d342e" if wall else "#51372f")
    for y in (0, 5, 10):
        d.rectangle((0, y + 1, 15, min(y + 4, 15)), fill="#93674b" if not wall else "#b28a65")
        d.line((1, y + 2, 14, y + 2), fill="#bc8a5b" if not wall else "#d7ad7a")
        for x in (4 + (y % 3), 12):
            d.point((x, min(y + 3, 15)), fill="#62443a")
    if wall:
        d.rectangle((0, 0, 2, 15), fill="#654537")
        d.rectangle((13, 0, 15, 15), fill="#654537")


def place(index, im):
    atlas.paste(im, ((index % COLS) * SIZE, (index // COLS) * SIZE))


for index in range(32):
    im, d, rng = tile(index, "#426d48")
    if index in (0, 1):
        d.rectangle((0, 0, 15, 15), fill="#548458" if index == 0 else "#4e7c51")
        flecks(d, rng, ["#3d714d", "#74a86b", "#8cb676"], 38)
        for x, y in ((3, 5), (12, 10)) if index == 1 else ((8, 11),):
            d.point((x, y), fill="#fff0b8")
            d.point((x - 1, y), fill="#e99aae")
            d.point((x + 1, y), fill="#e99aae")
    elif index in (2, 3):
        cobble(d, rng, True)
        if index == 3:
            d.line((8, 8, 10, 9, 9, 11), fill="#8b735d")
    elif index in (4, 5):
        d.rectangle((0, 0, 15, 15), fill="#9d805d" if index == 4 else "#9d8867")
        flecks(d, rng, ["#c0a177", "#705b4c", "#b99c72"], 24)
        if index == 5:
            for x in (2, 13): d.line((x, 0, x, 15), fill="#786449", width=1)
    elif index in (6, 7, 8):
        cobble(d, rng, False)
        if index == 7: d.line((2, 13, 6, 10, 8, 11, 12, 7), fill="#36434b")
        if index == 8:
            d.rectangle((5, 5, 10, 10), outline="#addbd3")
            d.point((7, 7), fill="#d9f1dc")
    elif index in (9, 27):
        stone(d, rng, False, index == 27)
    elif index in (10, 11):
        wood(d, rng)
        if index == 11: d.line((2, 12, 9, 12), fill="#b98458")
    elif index == 12:
        d.rectangle((0, 0, 15, 15), fill="#ccb18a")
        flecks(d, rng, ["#d9c39d", "#af9679"], 13)
        d.rectangle((0, 0, 1, 15), fill="#694c38")
    elif index == 13: wood(d, rng, True)
    elif index == 14:
        d.rectangle((0, 0, 15, 15), fill="#914b43")
        d.rectangle((2, 2, 13, 13), outline="#e0b471", width=1)
        for x, y in ((8, 4), (4, 8), (12, 8), (8, 12)):
            d.rectangle((x, y, x + 1, y + 1), fill="#d7b37a")
    elif index == 15:
        d.rectangle((0, 0, 15, 15), fill="#332f35")
        d.rectangle((2, 1, 13, 14), fill="#68504a")
        for y in range(3, 13, 4): d.line((3, y, 12, y), fill="#b97443")
        d.polygon([(7, 13), (4, 9), (8, 3), (9, 9), (12, 6), (10, 13)], fill="#f5aa4d")
        d.rectangle((7, 9, 9, 12), fill="#ffe2a0")
    elif index in (16, 17):
        dark, base, light = ("#6d3e45", "#aa5650", "#d57c64") if index == 16 else ("#374f63", "#547b82", "#88a9a0")
        d.rectangle((0, 0, 15, 15), fill=dark)
        for row in (0, 5, 10):
            for x in range(-3 if row == 5 else 0, 16, 8):
                d.rectangle((max(x + 1, 0), row + 1, min(x + 7, 15), row + 4), fill=base)
                d.line((max(x + 2, 0), row + 1, min(x + 6, 15), row + 1), fill=light)
    elif index == 18: wood(d, rng, True)
    elif index == 19:
        d.rectangle((0, 0, 15, 15), fill="#704d39")
        d.rectangle((2, 2, 13, 13), fill="#b1d4c7")
        d.rectangle((3, 3, 7, 6), fill="#e9e3ad")
        d.line((8, 2, 8, 13), fill="#674632", width=2)
        d.line((2, 8, 13, 8), fill="#674632", width=2)
    elif index == 20:
        wood(d, rng, True)
        d.rectangle((3, 1, 12, 15), fill="#654433")
        d.line((5, 2, 5, 14), fill="#b48258")
        d.point((11, 9), fill="#f0cf88")
    elif index == 21:
        d.rectangle((0, 0, 15, 15), fill="#674834")
        d.ellipse((2, 2, 13, 13), fill="#9a6844", outline="#49382f")
        d.arc((4, 4, 11, 11), 20, 250, fill="#d2a064")
        d.line((3, 7, 12, 7), fill="#5d5c57", width=2)
    elif index == 22:
        d.rectangle((0, 0, 15, 15), fill="#604437")
        d.rounded_rectangle((1, 2, 14, 13), radius=2, fill="#ae7b55", outline="#4b3831")
        d.line((2, 4, 12, 4), fill="#dbab70")
        d.point((4, 11), fill="#dcbb89")
    elif index == 23:
        wood(d, rng)
        d.rectangle((3, 3, 12, 10), fill="#b78a5e", outline="#674a3b")
        d.rectangle((5, 11, 10, 13), fill="#694938")
    elif index == 24:
        wood(d, rng, True)
        for x in (3, 8, 12):
            d.rectangle((x, 4, x + 2, 10), fill="#86a891" if x == 8 else "#bd895c")
        d.line((2, 12, 13, 12), fill="#e0ad71", width=2)
    elif index == 25:
        d.rectangle((0, 0, 15, 15), fill="#674835")
        d.rectangle((1, 2, 14, 13), fill="#8b746a")
        d.rectangle((2, 3, 13, 5), fill="#dfd2b3")
        d.rectangle((2, 7, 13, 12), fill="#7999a0")
    elif index == 26:
        stone(d, rng)
        d.rectangle((2, 1, 13, 14), fill="#303d49", outline="#a2a69a")
        d.rectangle((4, 2, 11, 13), fill="#79898b")
        d.line((5, 3, 10, 3), fill="#c0c2a9")
    elif index == 28:
        wood(d, rng)
        d.rectangle((2, 3, 13, 12), fill="#a26a40", outline="#3b3332")
        d.line((2, 6, 13, 6), fill="#dab57c", width=2)
        d.rectangle((7, 7, 9, 10), fill="#e8cc88")
    elif index == 29:
        d.rectangle((0, 0, 15, 15), fill="#4b4644")
        d.rectangle((7, 6, 8, 15), fill="#a88358")
        d.polygon([(8, 1), (4, 7), (10, 9), (12, 5)], fill="#f3a653")
        d.point((8, 6), fill="#fff2b2")
    elif index == 30:
        d.rectangle((0, 0, 15, 15), fill="#537b82")
        for y in (4, 11): d.line((1, y, 7, y), fill="#a8d0c3")
    else:
        d.rectangle((0, 0, 15, 15), fill="#463a44")
        for x in range(0, 16, 4): d.line((x, 0, x + 2, 15), fill="#65505b")
    place(index, im)

out = Path(__file__).resolve().parent.parent / "art" / "sonnenhain_tiles.png"
out.parent.mkdir(parents=True, exist_ok=True)
atlas.save(out)
print(out)
