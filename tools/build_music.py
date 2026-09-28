"""Recreate the eight zone Ogg loops from the bundled MIDI originals.

Requires numpy and ffmpeg. Example: python3 tools/build_music.py
"""
from pathlib import Path
from subprocess import run
from tempfile import TemporaryDirectory

from render_midi import render

root = Path(__file__).resolve().parents[1]
names = ("dorf", "blumen", "kueste", "pilzwald", "ruinen", "kristall", "asche", "sternen")

with TemporaryDirectory(prefix="sonnenhain-music-") as temp:
    for name in names:
        wav = Path(temp) / f"{name}.wav"
        render(root / "music" / "source" / f"{name}.mid", wav)
        run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(wav),
             "-c:a", "libvorbis", "-q:a", "4", str(root / "music" / f"{name}.ogg")], check=True)
        print(f"{name}.ogg fertig", flush=True)
