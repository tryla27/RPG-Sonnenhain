#!/usr/bin/env python3
"""Einzelbilder (frame_000.png …) zu einer GIF zusammenfügen.
Aufruf: python3 tools/make_gif.py <ordner> <ausgabe.gif> [ms_pro_bild] [skalierung]"""
import sys
from pathlib import Path
from PIL import Image

folder = Path(sys.argv[1])
out = sys.argv[2]
ms = int(sys.argv[3]) if len(sys.argv) > 3 else 33
scale = float(sys.argv[4]) if len(sys.argv) > 4 else 1.0
frames = [Image.open(p).convert("RGB") for p in sorted(folder.glob("frame_*.png"))]
if scale != 1.0:
    frames = [f.resize((int(f.width * scale), int(f.height * scale)), Image.LANCZOS) for f in frames]
frames = [f.quantize(colors=128, method=Image.MEDIANCUT) for f in frames]
frames[0].save(out, save_all=True, append_images=frames[1:], duration=ms, loop=0, optimize=True)
print("GIF", out, len(frames))
