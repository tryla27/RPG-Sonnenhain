"""Pixel-Porträts für Spielmeldungen aus den ComfyUI-/Krita-Porträts.

Aufruf: python tools/art_pipeline/pixel_portraits.py
Quelle: art/ui/quality_v1/portrait_<name>.png (192 px, gemalt)
Ziel:   art/ui/portraits_px/<name>.png (48 px: 44 px Bild, 2 px Rahmen)
Verkleinern, auf 20 Farben ohne Dithering reduzieren, Rahmen in Spielfarben.
"""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art/ui/quality_v1"
OUT = ROOT / "art/ui/portraits_px"
OUT.mkdir(parents=True, exist_ok=True)

for name in ["mira", "fenna", "borin"]:
    src = Image.open(SOURCE / f"portrait_{name}.png").convert("RGB").crop((8, 8, 184, 184))
    small = src.resize((44, 44), Image.LANCZOS).quantize(colors=20, method=Image.MEDIANCUT, dither=Image.NONE).convert("RGBA")
    framed = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    draw = ImageDraw.Draw(framed)
    draw.rectangle((0, 0, 47, 47), fill=(34, 52, 48, 255))
    draw.rectangle((1, 1, 46, 46), outline=(214, 186, 112, 255))
    framed.paste(small, (2, 2))
    framed.save(OUT / f"{name}.png")
    print("PORTRAIT", name)
