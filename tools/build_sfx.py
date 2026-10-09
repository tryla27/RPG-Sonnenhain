"""Erzeugt die Sonnenhain-Soundeffekte im Stil "16-Bit, märchenhaft".

Aufruf:  python3 tools/build_sfx.py            (alle Sounds neu erzeugen)
         python3 tools/build_sfx.py wolf        (nur Namen, die "wolf" enthalten)

Jeder Sound ist ein Rezept aus Klangbausteinen (gezupfte Saite, Glocke,
gefiltertes Rauschen, Tonhöhenverlauf). Danach läuft dieselbe Veredelung über
alle Sounds: 32-kHz-Konsolencharakter, weich gedeckte Höhen, leichte
Bitreduktion, SNES-artiges Echo, Pegel auf -3 dBFS.

Die Erzeugung ist deterministisch (feste Saat pro Sound und Variante).
Ausgabe: audio/sfx/<bereich>/<name>_<nn>.wav, 44,1 kHz, 16 Bit, mono.
Konzept: docs/sound/KONZEPT.md
"""
from __future__ import annotations

import sys
import wave
import zlib
from pathlib import Path

import numpy as np
from scipy import signal

SR = 44100
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "audio" / "sfx"

# D-Dur, damit melodische Akzente zur Musik passen.
NOTE = {"D3": 146.83, "A3": 220.0, "D4": 293.66, "E4": 329.63, "F#4": 369.99, "G4": 392.0,
        "A4": 440.0, "B4": 493.88, "C#5": 554.37, "D5": 587.33, "E5": 659.26, "F#5": 739.99,
        "G5": 783.99, "A5": 880.0, "B5": 987.77, "C#6": 1108.73, "D6": 1174.66, "F#6": 1479.98,
        "A6": 1760.0, "D7": 2349.32, "F4": 349.23, "A2": 110.0, "D2": 73.42}


# ----------------------------------------------------------------- Bausteine

def t_axis(seconds: float) -> np.ndarray:
    return np.arange(int(SR * seconds)) / SR


def env(seconds: float, attack: float = 0.004, decay: float = 0.2, curve: float = 4.0) -> np.ndarray:
    """Schneller Anstieg, exponentieller Ausklang über 'decay' Sekunden."""
    t = t_axis(seconds)
    a = np.clip(t / max(attack, 1e-4), 0, 1)
    d = np.exp(-curve * np.maximum(t - attack, 0) / max(decay, 1e-4))
    return a * d


def glide(start: float, end: float, seconds: float, shape: float = 1.0) -> np.ndarray:
    """Frequenzverlauf von start nach end (exponentiell, shape>1 = später)."""
    x = np.linspace(0, 1, int(SR * seconds)) ** shape
    return start * (end / start) ** x


def osc(freq, seconds: float, kind: str = "sine", phase: float = 0.0) -> np.ndarray:
    n = int(SR * seconds)
    f = np.full(n, float(freq)) if np.isscalar(freq) else np.asarray(freq)[:n]
    ph = 2 * np.pi * np.cumsum(f) / SR + phase
    if kind == "sine":
        return np.sin(ph)
    if kind == "tri":
        return 2 / np.pi * np.arcsin(np.sin(ph))
    if kind == "square":  # weich: nur ungerade Obertöne bis 5
        return np.sin(ph) + np.sin(3 * ph) / 3 + np.sin(5 * ph) / 5
    if kind == "saw":
        return sum(np.sin(k * ph) / k for k in range(1, 9))
    raise ValueError(kind)


def noise(seconds: float, rng: np.random.Generator, color: str = "white") -> np.ndarray:
    n = int(SR * seconds)
    x = rng.standard_normal(n)
    if color == "pink":
        b, a = signal.butter(1, 400 / (SR / 2), "low")
        x = 0.5 * x + 2.0 * signal.lfilter(b, a, x)
    if color == "brown":
        x = np.cumsum(x)
        x = x - signal.savgol_filter(x, 2001 if n > 2001 else (n // 2) * 2 - 1, 1) if n > 9 else x
    return x / (np.max(np.abs(x)) + 1e-9)


def bp(x: np.ndarray, low: float, high: float, order: int = 2) -> np.ndarray:
    low = max(20.0, low)
    high = min(SR / 2 - 100, high)
    sos = signal.butter(order, [low / (SR / 2), high / (SR / 2)], "band", output="sos")
    return signal.sosfilt(sos, x)


def lp(x: np.ndarray, cutoff: float, order: int = 2) -> np.ndarray:
    sos = signal.butter(order, min(cutoff, SR / 2 - 100) / (SR / 2), "low", output="sos")
    return signal.sosfilt(sos, x)


def hp(x: np.ndarray, cutoff: float, order: int = 2) -> np.ndarray:
    sos = signal.butter(order, max(cutoff, 20) / (SR / 2), "high", output="sos")
    return signal.sosfilt(sos, x)


def sweep_bp(x: np.ndarray, centers: np.ndarray, q: float = 2.0, block: int = 256) -> np.ndarray:
    """Bandpass mit wanderndem Zentrum (blockweise, mit Filterzustand)."""
    out = np.zeros_like(x)
    zi = None
    for start in range(0, len(x), block):
        c = float(centers[min(start, len(centers) - 1)])
        bw = c / q
        lo, hi = max(40.0, c - bw / 2), min(SR / 2 - 200, c + bw / 2)
        sos = signal.butter(2, [lo / (SR / 2), hi / (SR / 2)], "band", output="sos")
        if zi is None:
            zi = np.zeros((sos.shape[0], 2))
        out[start:start + block], zi = signal.sosfilt(sos, x[start:start + block], zi=zi)
    return out


def pluck(freq: float, seconds: float, rng: np.random.Generator, bright: float = 0.5, damp: float = 0.996) -> np.ndarray:
    """Karplus-Strong: Harfe, Bogensehne, Glöckchen-Anschlag."""
    n = int(SR * seconds)
    period = max(2, int(SR / freq))
    buf = rng.uniform(-1, 1, period)
    buf = lp(buf, 800 + bright * 9000, 1) if period > 12 else buf
    out = np.zeros(n)
    for i in range(n):
        j = i % period
        out[i] = buf[j]
        buf[j] = damp * 0.5 * (buf[j] + buf[(j + 1) % period])
    return out / (np.max(np.abs(out)) + 1e-9)


def bell(freq: float, seconds: float, decay: float = 0.6, partials=((1, 1.0), (2.76, 0.45), (5.4, 0.22), (8.93, 0.1))) -> np.ndarray:
    """Glockenspiel/Kristall: unharmonische Teiltöne, höhere klingen schneller ab."""
    t = t_axis(seconds)
    out = np.zeros_like(t)
    for ratio, amp in partials:
        out += amp * np.sin(2 * np.pi * freq * ratio * t) * np.exp(-t * (1.0 + ratio) / decay)
    return out * np.clip(t / 0.002, 0, 1)


def thump(freq_start: float, freq_end: float, seconds: float, decay: float = 0.12) -> np.ndarray:
    return osc(glide(freq_start, freq_end, seconds, 0.6), seconds) * env(seconds, 0.002, decay)


def pad(x: np.ndarray, seconds: float) -> np.ndarray:
    n = int(SR * seconds)
    return np.pad(x, (0, max(0, n - len(x))))[:n]


def at(x: np.ndarray, offset: float, total: float) -> np.ndarray:
    """Baustein x um offset Sekunden versetzt in eine Spur der Länge total."""
    n = int(SR * total)
    out = np.zeros(n)
    s = int(SR * offset)
    seg = x[: max(0, n - s)]
    out[s:s + len(seg)] = seg
    return out


def mix(*layers) -> np.ndarray:
    length = max(len(layer) for layer, _ in layers)
    out = np.zeros(length)
    for layer, gain in layers:
        out[: len(layer)] += gain * layer
    return out


def vibrato(base: np.ndarray, rate: float, depth: float) -> np.ndarray:
    t = np.arange(len(base)) / SR
    return base * (1 + depth * np.sin(2 * np.pi * rate * t))


def voice(f0, seconds: float, formants, breath: float = 0.12, rng=None) -> np.ndarray:
    """Stimmähnlicher Laut: obertonreicher Puls durch Formantfilter (für Ächzen, Winseln)."""
    pulse = lp(osc(f0, seconds, "saw"), 3800)
    out = np.zeros_like(pulse)
    for freq, width, gain in formants:
        out += gain * bp(pulse, freq - width / 2, freq + width / 2, 2)
    if breath > 0 and rng is not None:
        out += breath * bp(noise(seconds, rng), formants[0][0] * 0.8, formants[0][0] * 3)
    return out / (np.max(np.abs(out)) + 1e-9)


# ------------------------------------------------------------- 16-Bit-Finish

def console(x: np.ndarray, bits: int = 12, rate: int = 32000, top: float = 11500) -> np.ndarray:
    """32-kHz-Haltestufe, leichte Bitreduktion, weich gedeckte Höhen."""
    step = SR / rate
    idx = (np.floor(np.arange(len(x)) / step) * step).astype(int)
    held = x[np.clip(idx, 0, len(x) - 1)]
    peak = np.max(np.abs(held)) + 1e-9
    levels = 2 ** (bits - 1)
    crushed = np.round(held / peak * levels) / levels * peak
    # Bitreduktion nur dezent beimischen, damit leise Ausklänge nicht rauschen.
    return lp(0.7 * held + 0.3 * crushed, top, 2)


def echo(x: np.ndarray, delay: float = 0.11, feedback: float = 0.3, wet: float = 0.25, tone: float = 3200, tail: float = 0.0) -> np.ndarray:
    """SNES-artiges Echo: Verzögerung mit Rückkopplung und Tiefpass in der Schleife."""
    if wet <= 0:
        return x
    n = len(x) + int(SR * tail)
    dry = np.pad(x, (0, n - len(x)))
    d = int(SR * delay)
    out = dry.copy()
    buf = np.zeros(n)
    b, a = signal.butter(1, tone / (SR / 2), "low")
    z = np.zeros(1)
    for start in range(0, n, d):
        src = (dry[start - d:start] if start >= d else np.zeros(0))
        prev = buf[start - d:start] if start >= d else np.zeros(0)
        if len(src) == 0:
            continue
        seg = src + feedback * prev
        seg, z = signal.lfilter(b, a, seg, zi=z)
        end = min(n, start + len(seg))
        buf[start:end] = seg[: end - start]
    return out + wet * buf


def finish(x: np.ndarray, *, echo_wet: float = 0.0, echo_delay: float = 0.11, echo_fb: float = 0.3,
           tail: float = 0.0, peak_db: float = -3.0, bits: int = 12, top: float = 11500, low_cut: float = 60) -> np.ndarray:
    x = hp(x, low_cut, 2)
    x = console(x, bits=bits, top=top)
    x = echo(x, echo_delay, echo_fb, echo_wet, tail=tail)
    # Stille am Anfang entfernen (höchstens 2 ms Vorlauf), sanft ein- und ausblenden.
    thresh = np.max(np.abs(x)) * 0.02
    first = int(np.argmax(np.abs(x) > thresh))
    x = x[max(0, first - int(SR * 0.002)):]
    last = len(x) - int(np.argmax(np.abs(x[::-1]) > thresh * 0.25))
    x = x[: min(len(x), last + int(SR * 0.01))]
    fade_in = min(len(x), int(SR * 0.0015))
    fade_out = min(len(x), int(SR * 0.03))
    x[:fade_in] *= np.linspace(0, 1, fade_in)
    x[-fade_out:] *= np.linspace(1, 0, fade_out) ** 2
    return x / (np.max(np.abs(x)) + 1e-9) * 10 ** (peak_db / 20)


# ------------------------------------------------------------------ Rezepte
# Jedes Rezept: (rng, v) -> Signal; v ist die Variantennummer (0..n-1).

def r_schwert_schwung(rng, v):
    # Klinge schlitzt durch die Luft: tiefer, weicher Luftzug, kurzer Klingenschliff, kein Pfeifton.
    d = 0.2 + 0.015 * v
    whoosh = sweep_bp(noise(d, rng), glide(420 + 60 * v, 1600 + 90 * v, d, 0.6), q=1.2) * env(d, 0.025, 0.07, 3)
    scrape = at(bp(noise(0.06, rng), 2100, 4000) * env(0.06, 0.002, 0.022), 0.028 + 0.004 * v, d) * 0.32
    air = lp(noise(d, rng), 650) * env(d, 0.02, 0.05) * 0.35
    return finish(mix((whoosh, 1.0), (scrape, 1.0), (air, 1.0)), top=7000)


def r_stab_schwung(rng, v):
    # Zauberei und Alchemie: wirbelnder Luftzug, blubbernde Tinktur, funkelnde Glöckchen, schwebender Schimmer.
    d = 0.62
    swirl = sweep_bp(noise(d, rng), glide(300, 1100, d, 0.7), q=2.5) * env(d, 0.05, 0.25, 2)
    bubbles = np.zeros(int(SR * d))
    for k in range(6):
        f = rng.uniform(380, 820)
        bubbles += at(osc(glide(f, f * 1.9, 0.05), 0.05) * env(0.05, 0.003, 0.03), rng.uniform(0.02, 0.32), d)
    scale = [NOTE["D6"], NOTE["E5"] * 2, NOTE["F#6"], NOTE["A6"], NOTE["B5"] * 2]
    sparkle = np.zeros(int(SR * d))
    for k in range(4):
        sparkle += at(bell(scale[int(rng.integers(0, len(scale)))], 0.3, 0.12), 0.08 + 0.07 * k + rng.uniform(0, 0.03), d) * (0.5 - 0.08 * k)
    t = t_axis(d)
    shimmer = osc(NOTE["A5"] * (1 + 0.004 * v), d, "tri") * (0.5 + 0.5 * np.sin(2 * np.pi * 17 * t)) * np.sin(np.pi * t / d) * 0.12
    return finish(mix((swirl, 0.7), (bubbles, 0.45), (sparkle, 0.7), (shimmer, 1.0)), echo_wet=0.22, echo_delay=0.09)


def r_bogen_spannen(rng, v):
    # Holz und Sehne knarzen beim Spannen: dichter werdende kleine Reibeklicks, kein Ton.
    d = 0.45
    out = np.zeros(int(SR * d))
    t = 0.01
    while t < d - 0.02:
        click = bp(noise(0.007, rng), 700, 2600) * env(0.007, 0.0004, 0.0025)
        wood = bp(noise(0.012, rng), 260, 620) * env(0.012, 0.0008, 0.005)
        out += at(mix((click, 1.0), (wood, 0.6)), t, d) * (0.4 + 0.6 * t / d)
        t += 1.0 / (24 + 60 * (t / d)) * rng.uniform(0.7, 1.3)
    stretch = bp(noise(d, rng), 1100, 3200) * np.linspace(0, 1, int(SR * d)) ** 2 * 0.12
    return finish(mix((out, 1.0), (stretch, 1.0)), peak_db=-6, top=9000)


def r_bogen_schuss(rng, v):
    # Natürlich und trocken: Sehnenschlag, kurzes Holz-Thump, Pfeil zischt davon. Kein Hall.
    d = 0.17 + 0.01 * (v % 3)
    slap = thump(170 + 12 * (v % 4), 85, d, 0.03 + 0.004 * (v % 3))
    snap = bp(noise(0.02, rng), 300 + 40 * v, 1500 + 60 * v) * env(0.02, 0.0005, 0.008)
    string = pluck(105 + 9 * v, d, rng, 0.25, 0.985) * env(d, 0.001, 0.035, 3) * 0.25
    hiss = sweep_bp(noise(d, rng), glide(1900 + 70 * v, 650 + 30 * v, d), q=1.8) * env(d, 0.015, 0.09, 2.5)
    return finish(mix((slap, 0.8), (pad(snap, d), 0.7), (string, 1.0), (hiss, 1.6 + 0.08 * (v % 4))), bits=14, top=9000)


def r_krit(rng, v):
    # Rüstung bricht: harter Knacks, kurzes Metallscheppern, dann herabfallende Splitter.
    d = 0.6
    crack = hp(noise(0.03, rng), 1500) * env(0.03, 0.0005, 0.01)
    clang = bell(330 + 45 * v, 0.35, 0.11, ((1, 1), (1.53, 0.7), (2.31, 0.5), (3.17, 0.3)))
    crunch = bp(noise(0.12, rng), 800, 3500) * (rng.random(int(SR * 0.12)) > 0.75) * env(0.12, 0.001, 0.05)
    shards = np.zeros(int(SR * d))
    for k in range(7):
        f = rng.uniform(2000, 4600)
        shards += at(bell(f, 0.08, 0.05, ((1, 1), (1.7, 0.4))), 0.05 + 0.045 * k + rng.uniform(0, 0.02), d) * (0.4 - 0.045 * k)
    return finish(mix((pad(crack, d), 1.0), (pad(clang, d), 0.55), (pad(crunch, d), 0.8), (shards, 0.6)), echo_wet=0.06, top=10000)


def _hit_base(rng, v, body_from, body_to, decay, noise_band, noise_gain, length=0.22):
    """Treffer = Anschlag-Klick + kurzer Körper mit Tonhöhenfall + Materialrauschen."""
    d = length
    click = hp(noise(0.004, rng), 1500) * env(0.004, 0.0002, 0.0015)
    body = thump(body_from * (1 + 0.06 * (v - 1)), body_to, d, decay * 0.55)
    grit = bp(noise(d, rng), *noise_band) * env(d, 0.0008, decay * 0.7, 3)
    return mix((pad(click, d), 0.7), (body, 0.85), (grit, noise_gain * 1.6))


def r_treffer_weich(rng, v):
    d = 0.24
    base = _hit_base(rng, v, 210, 70, 0.1, (300, 1600), 0.6, d)
    squelch = sweep_bp(noise(d, rng), glide(1400, 300, d), q=4) * env(d, 0.004, 0.09) * 0.9
    return finish(mix((base, 1.0), (squelch, 1.0)), echo_wet=0.04)


def r_treffer_chitin(rng, v):
    d = 0.18
    base = _hit_base(rng, v, 520, 180, 0.05, (2200, 7000), 0.9, d)
    clicks = sum(at(hp(noise(0.006, rng), 3000) * env(0.006, 0.0003, 0.002), 0.012 * k, d) for k in range(3))
    return finish(mix((base, 1.0), (clicks, 0.7)), echo_wet=0.03)


def r_treffer_fell(rng, v):
    d = 0.2
    base = _hit_base(rng, v, 180, 60, 0.08, (500, 2400), 0.7, d)
    return finish(base, echo_wet=0.03)


def r_treffer_stein(rng, v):
    d = 0.3
    base = _hit_base(rng, v, 140, 45, 0.11, (900, 4000), 1.1, d)
    crunch = bp(noise(d, rng), 1500, 5000) * (rng.random(int(SR * d)) > 0.86) * env(d, 0.001, 0.12)
    return finish(mix((base, 1.0), (crunch, 0.8)), echo_wet=0.06)


def r_treffer_geist(rng, v):
    # Wie ein Schlag auf Pappe: dumpfe, hohle Schachtel ohne Klingen.
    d = 0.14
    box = bp(noise(d, rng), 230 + 30 * v, 880 + 40 * v) * env(d, 0.0008, 0.05, 2.5)
    hollow = thump(230 + 15 * v, 150, d, 0.04)
    paper = bp(noise(d, rng), 2500, 6000) * env(d, 0.0005, 0.007)
    return finish(mix((box, 1.0), (hollow, 0.6), (paper, 0.35)), top=9000)


def r_treffer_metall(rng, v):
    d = 0.4
    clang = bell(410 + 37 * v, d, 0.18, ((1, 1), (1.47, 0.7), (2.09, 0.5), (2.56, 0.35), (3.9, 0.2)))
    base = _hit_base(rng, v, 200, 80, 0.06, (1800, 6000), 0.6, d)
    return finish(mix((clang, 0.7), (base, 1.0)), echo_wet=0.1)


def r_tod(material):
    def recipe(rng, v):
        d = 0.6
        notes = {"weich": (330, 110), "chitin": (900, 300), "fell": (260, 90), "stein": (160, 50),
                 "geist": (880, 440), "metall": (520, 180)}[material]
        fall = osc(glide(notes[0], notes[1], d, 0.8), d, "square") * env(d, 0.004, 0.3) * 0.5
        poof = lp(noise(d, rng, "pink"), 1800) * env(d, 0.006, 0.18)
        sparkle = at(bell(NOTE["D6"], 0.5, 0.2), 0.12, d) * (0.4 if material == "geist" else 0.15)
        return finish(mix((fall, 1.0), (poof, 0.8), (sparkle, 1.0)), echo_wet=0.18)
    return recipe


def r_schaden(rng, v):
    # Kurzes, stimmhaftes "Uff" mit Schlag: sofort verständlich, nicht piepsig.
    d = 0.22
    f0 = glide(185 + 18 * v, 115 + 8 * v, d, 0.7)
    oof = voice(f0, d, [(450, 160, 1.0), (850, 200, 0.55), (2500, 300, 0.12)], 0.1, rng) * env(d, 0.008, 0.09, 2.5)
    punch = thump(150, 60, d, 0.04)
    click = pad(hp(noise(0.008, rng), 1500) * env(0.008, 0.0004, 0.003), d)
    return finish(mix((oof, 1.0), (punch, 0.7), (click, 0.35)), top=8000)


def r_spieler_tod(rng, v):
    d = 1.6
    seq = [NOTE["A4"], NOTE["F4"], NOTE["D4"], NOTE["A3"]]
    line = sum(at(pluck(f, 0.7, rng, 0.4, 0.997) * env(0.7, 0.002, 0.5, 2), 0.22 * i, d) for i, f in enumerate(seq))
    low = at(thump(110, 55, 0.8, 0.5), 0.66, d) * 0.5
    return finish(mix((line, 1.0), (low, 1.0)), echo_wet=0.35, echo_delay=0.16, echo_fb=0.35, tail=0.5)


def r_ausweichen(rng, v):
    d = 0.26
    whoosh = sweep_bp(noise(d, rng), glide(500 + 150 * v, 2400, d, 0.6), q=1.5) * env(d, 0.03, 0.1, 3)
    cloth = lp(noise(d, rng), 900) * env(d, 0.01, 0.06) * 0.4
    return finish(mix((whoosh, 1.0), (cloth, 1.0)), echo_wet=0.04)


def r_trank(rng, v):
    # Nur Trinken: drei Schlucke, ohne Glöckchen.
    d = 0.72
    out = np.zeros(int(SR * d))
    for k, start in enumerate((0.0, 0.22, 0.45)):
        g = 0.1
        gulp = sweep_bp(noise(g, rng), glide(950 - 60 * k, 340, g, 0.6), q=6) * env(g, 0.006, 0.05)
        body = thump(190 - 10 * k, 95, g, 0.03)
        bubble = at(osc(glide(500, 900, 0.03), 0.03) * env(0.03, 0.002, 0.015), 0.06, g)
        out += at(mix((gulp, 1.0), (body, 0.6), (bubble, 0.2)), start, d)
    return finish(out, top=8000)


def r_wiederbeleben(rng, v):
    d = 1.4
    seq = [NOTE["D4"], NOTE["F#4"], NOTE["A4"], NOTE["D5"], NOTE["F#5"], NOTE["A5"], NOTE["D6"]]
    harp = sum(at(pluck(f, 0.8, rng, 0.6, 0.998) * env(0.8, 0.001, 0.6, 2), 0.06 * i, d) for i, f in enumerate(seq))
    return finish(harp, echo_wet=0.35, echo_delay=0.13, tail=0.4)


def r_warnung(rng, v):
    # Herzschlag als nahtlose Schleife (Lub-Dub, 0,95 s). Läuft, solange das Leben unter 25 % liegt.
    d = 0.95
    beat = at(thump(72, 44, 0.2, 0.07), 0.0, d) + at(thump(64, 40, 0.2, 0.06), 0.27, d) * 0.7
    beat += at(lp(noise(0.05, rng), 220) * env(0.05, 0.002, 0.02), 0.0, d) * 0.3
    beat = lp(hp(beat, 30, 2), 900, 2)
    beat[-int(SR * 0.02):] *= np.linspace(1, 0, int(SR * 0.02))
    return beat / (np.max(np.abs(beat)) + 1e-9) * 10 ** (-6 / 20)


def r_schleim_huepfen(rng, v):
    d = 0.28
    boing = osc(glide(140 + 25 * v, 420 + 40 * v, d, 0.35), d) * env(d, 0.004, 0.15)
    boing = vibrato(boing, 22, 0.25)
    wet = sweep_bp(noise(d, rng), glide(500, 1600, d), q=5) * env(d, 0.003, 0.05) * 0.7
    return finish(mix((boing, 1.0), (wet, 1.0)), echo_wet=0.05)


def r_schleim_tod(rng, v):
    d = 0.7
    splat = lp(noise(d, rng), 1300) * env(d, 0.002, 0.08) * 1.2
    blops = sum(at(osc(glide(700 - 120 * k, 260 - 30 * k, 0.09), 0.09) * env(0.09, 0.003, 0.05), 0.08 + 0.1 * k, d) for k in range(4))
    return finish(mix((splat, 1.0), (blops, 0.8)), echo_wet=0.12)


def r_kaefer_zirpen(rng, v):
    d = 0.32
    carrier = osc(glide(3100 + 300 * v, 3500 + 300 * v, d), d, "tri")
    trem = (0.5 + 0.5 * np.sign(np.sin(2 * np.pi * (38 + 6 * v) * t_axis(d)))) * env(d, 0.01, 0.25, 2)
    clicks = bp(noise(d, rng), 4000, 9000) * trem * 0.4
    return finish(mix((carrier * trem, 0.6), (clicks, 1.0)), peak_db=-5, top=10500)


def r_kaefer_schuss(rng, v):
    d = 0.22
    spit = sweep_bp(noise(d, rng), glide(900, 3000, d, 0.5), q=3) * env(d, 0.002, 0.07)
    tone = osc(glide(380, 900, d, 0.4), d, "square") * env(d, 0.002, 0.06) * 0.35
    return finish(mix((spit, 1.0), (tone, 1.0)), echo_wet=0.05)


def r_kaefer_sekret(rng, v):
    d = 0.3
    splat = sweep_bp(noise(d, rng), glide(1800, 400, d), q=3) * env(d, 0.002, 0.08)
    hiss = hp(noise(d, rng), 3500) * env(d, 0.02, 0.15) * 0.3
    return finish(mix((splat, 1.0), (hiss, 1.0), (thump(300, 120, d, 0.04), 0.4)))


def r_kaefer_tod(rng, v):
    d = 0.55
    crunch = bp(noise(0.12, rng), 2000, 7000) * (rng.random(int(SR * 0.12)) > 0.7) * env(0.12, 0.001, 0.05)
    squeak = osc(glide(2600, 900, 0.4, 0.7), 0.4, "tri") * env(0.4, 0.01, 0.18) * 0.5
    return finish(mix((pad(crunch, d), 1.0), (at(squeak, 0.04, d), 1.0)), echo_wet=0.12)


def r_pilz_ankuendigung(rng, v):
    d = 0.7
    swell = lp(noise(d, rng, "pink"), glide(400, 1800, d)[0] + 600) * np.linspace(0, 1, int(SR * d)) ** 2
    tone = osc(glide(110, 165, d, 1.5), d, "tri") * np.linspace(0, 0.5, int(SR * d)) ** 1.5
    puff = at(lp(noise(0.25, rng), 1400) * env(0.25, 0.004, 0.1), 0.62, d + 0.1)
    return finish(mix((pad(swell, d + 0.1), 0.7), (pad(tone, d + 0.1), 1.0), (puff, 0.8)), echo_wet=0.1)


def r_pilz_tod(rng, v):
    d = 0.8
    poof = lp(noise(d, rng, "pink"), 1600) * env(d, 0.004, 0.16)
    deflate = osc(glide(240, 70, 0.6, 0.6), 0.6, "tri") * env(0.6, 0.02, 0.4) * 0.6
    spores = at(bell(NOTE["B5"], 0.5, 0.2), 0.15, d) * 0.15
    return finish(mix((poof, 1.0), (pad(deflate, d), 1.0), (spores, 1.0)), echo_wet=0.15)


def r_wolf_knurren(rng, v):
    d = 0.6
    jitter = 1 + 0.5 * lp(rng.standard_normal(int(SR * d)), 18, 1)
    base = osc(glide(92 + 10 * v, 78 + 8 * v, d) * jitter, d, "saw")
    # Unregelmäßiges Flattern der Stimmlippen: Pulse mit zufälligem Abstand.
    flutter = np.abs(lp(rng.standard_normal(int(SR * d)), 35 + 6 * v, 2))
    flutter = flutter / (flutter.max() + 1e-9)
    rasp = bp(noise(d, rng), 220, 1600) * (0.25 + flutter)
    growl = lp(base * 0.45 * (0.4 + flutter) + rasp * 1.0, 1300) * env(d, 0.06, 0.45, 1.6)
    return finish(growl, peak_db=-4, top=9000)


def r_wolf_sprung(rng, v):
    d = 0.45
    whoosh = sweep_bp(noise(d, rng), glide(400, 2200, d, 0.6), q=1.5) * env(d, 0.05, 0.2, 3)
    bark = lp(osc(glide(420, 260, 0.14), 0.14, "saw") * env(0.14, 0.004, 0.08), 1600)
    return finish(mix((whoosh, 0.9), (pad(bark, d), 0.8)), echo_wet=0.05)


def r_wolf_biss(rng, v):
    d = 0.22
    snap1 = hp(noise(0.015, rng), 1500) * env(0.015, 0.0004, 0.005)
    snap2 = at(hp(noise(0.02, rng), 1200) * env(0.02, 0.0004, 0.008), 0.05, d)
    crunch = at(bp(noise(0.1, rng), 600, 3500) * env(0.1, 0.002, 0.04), 0.05, d)
    return finish(mix((pad(snap1, d), 1.0), (snap2, 1.0), (crunch, 0.8), (at(thump(200, 80, 0.12, 0.04), 0.05, d), 0.6)))


def r_wolf_landung(rng, v):
    # Pfoten landen im Gras: weicher Plumps und raschelnde Halme.
    d = 0.32
    thud = thump(110, 50, d, 0.05)
    crackle = bp(noise(d, rng), 1500, 6000) * (rng.random(int(SR * d)) > 0.62) * env(d, 0.004, 0.2, 2)
    rustle = lp(noise(d, rng), 2600) * env(d, 0.006, 0.14, 2)
    return finish(mix((thud, 0.6), (crackle, 1.3), (rustle, 0.9)), top=9000)


def r_wolf_tod(rng, v):
    # Natürliches Winseln: zwei kurze Jauler, dann ein leiser, abfallender Klagelaut und ein Plumps.
    d = 1.0
    formants = [(900, 260, 1.0), (1700, 320, 0.45)]
    yelp1 = voice(glide(780, 610, 0.12), 0.12, formants, 0.08, rng) * env(0.12, 0.005, 0.06)
    yelp2 = voice(glide(720, 520, 0.14), 0.14, formants, 0.08, rng) * env(0.14, 0.005, 0.07)
    whine = voice(vibrato(glide(560, 320, 0.6, 0.8), 6, 0.03), 0.6, [(800, 220, 1.0), (1500, 260, 0.4)], 0.1, rng) * env(0.6, 0.03, 0.35, 2)
    fall = thump(100, 45, 0.3, 0.1)
    out = mix((at(yelp1, 0.0, d), 1.0), (at(yelp2, 0.16, d), 0.85), (at(whine, 0.34, d), 0.7), (at(fall, 0.55, d), 0.45))
    return finish(out, echo_wet=0.06, top=8000)


def r_muenzen(rng, v):
    d = 0.6
    pairs = [(NOTE["D6"], NOTE["A6"]), (NOTE["E5"] * 2, NOTE["A6"]), (NOTE["F#6"], NOTE["D7"])]
    a, b = pairs[v % 3]
    c = at(bell(a, 0.4, 0.12, ((1, 1), (2.0, 0.3), (3.0, 0.15))), 0, d) + at(bell(b, 0.5, 0.2, ((1, 1), (2.0, 0.3), (3.0, 0.15))), 0.065, d)
    return finish(c, echo_wet=0.2, echo_delay=0.09, peak_db=-5)


def r_aufheben(rng, v):
    d = 0.3
    blip = osc(glide(520 + 60 * v, 880 + 60 * v, 0.1, 0.5), 0.1, "tri") * env(0.1, 0.002, 0.07)
    tick = at(bell(NOTE["A5"] + 40 * v, 0.2, 0.1), 0.06, d) * 0.5
    return finish(mix((pad(blip, d), 1.0), (tick, 1.0)), echo_wet=0.12, peak_db=-5)


def _arp(rng, notes, spacing, length, tail, echo_wet, chord=False):
    d = spacing * len(notes) + length
    line = sum(at(bell(f, length, 0.35) * 0.6 + pluck(f, length, rng, 0.7, 0.998) * env(length, 0.001, length * 0.8, 2) * 0.6,
                  spacing * i, d) for i, f in enumerate(notes))
    if chord:
        chord_sig = sum(osc(f, length + 0.4, "tri") * env(length + 0.4, 0.15, 0.6, 1.5) for f in (NOTE["D5"], NOTE["F#5"], NOTE["A5"]))
        line = mix((line, 1.0), (at(chord_sig, spacing * len(notes) * 0.6, d + 0.4), 0.35))
    return finish(line, echo_wet=echo_wet, echo_delay=0.12, echo_fb=0.32, tail=tail)


def r_beute_selten(rng, v):
    return _arp(rng, [NOTE["D5"], NOTE["F#5"], NOTE["A5"]], 0.07, 0.45, 0.25, 0.25)


def r_beute_episch(rng, v):
    return _arp(rng, [NOTE["D5"], NOTE["F#5"], NOTE["A5"], NOTE["D6"], NOTE["F#6"]], 0.065, 0.6, 0.35, 0.3)


def r_beute_legendaer(rng, v):
    return _arp(rng, [NOTE["A4"], NOTE["D5"], NOTE["F#5"], NOTE["A5"], NOTE["D6"], NOTE["F#6"], NOTE["A6"]], 0.07, 0.9, 0.5, 0.35, chord=True)


# Name -> (Bereich, Rezept, Varianten)
SOUNDS = {
    "schwert_schwung": ("kampf", r_schwert_schwung, 4),
    "stab_schwung": ("kampf", r_stab_schwung, 3),
    "bogen_spannen": ("kampf", r_bogen_spannen, 1),
    "bogen_schuss": ("kampf", r_bogen_schuss, 10),
    "krit": ("kampf", r_krit, 2),
    "treffer_weich": ("treffer", r_treffer_weich, 3),
    "treffer_chitin": ("treffer", r_treffer_chitin, 3),
    "treffer_fell": ("treffer", r_treffer_fell, 3),
    "treffer_stein": ("treffer", r_treffer_stein, 3),
    "treffer_geist": ("treffer", r_treffer_geist, 3),
    "treffer_metall": ("treffer", r_treffer_metall, 3),
    "tod_weich": ("treffer", r_tod("weich"), 1),
    "tod_chitin": ("treffer", r_tod("chitin"), 1),
    "tod_fell": ("treffer", r_tod("fell"), 1),
    "tod_stein": ("treffer", r_tod("stein"), 1),
    "tod_geist": ("treffer", r_tod("geist"), 1),
    "tod_metall": ("treffer", r_tod("metall"), 1),
    "spieler_schaden": ("spieler", r_schaden, 3),
    "spieler_tod": ("spieler", r_spieler_tod, 1),
    "spieler_ausweichen": ("spieler", r_ausweichen, 2),
    "spieler_trank": ("spieler", r_trank, 1),
    "spieler_wiederbeleben": ("spieler", r_wiederbeleben, 1),
    "spieler_warnung": ("spieler", r_warnung, 1),
    "schleim_huepfen": ("mobs", r_schleim_huepfen, 3),
    "schleim_tod": ("mobs", r_schleim_tod, 1),
    "kaefer_zirpen": ("mobs", r_kaefer_zirpen, 2),
    "kaefer_schuss": ("mobs", r_kaefer_schuss, 1),
    "kaefer_sekret": ("mobs", r_kaefer_sekret, 1),
    "kaefer_tod": ("mobs", r_kaefer_tod, 1),
    "pilz_ankuendigung": ("mobs", r_pilz_ankuendigung, 1),
    "pilz_tod": ("mobs", r_pilz_tod, 1),
    "wolf_knurren": ("mobs", r_wolf_knurren, 2),
    "wolf_sprung": ("mobs", r_wolf_sprung, 1),
    "wolf_biss": ("mobs", r_wolf_biss, 1),
    "wolf_landung": ("mobs", r_wolf_landung, 1),
    "wolf_tod": ("mobs", r_wolf_tod, 1),
    "beute_muenzen": ("beute", r_muenzen, 3),
    "beute_aufheben": ("beute", r_aufheben, 2),
    "beute_selten": ("beute", r_beute_selten, 1),
    "beute_episch": ("beute", r_beute_episch, 1),
    "beute_legendaer": ("beute", r_beute_legendaer, 1),
}


def write_wav(path: Path, x: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    data = np.clip(np.round(x * 32767), -32768, 32767).astype("<i2")
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


def build(filter_text: str = "") -> list[Path]:
    written = []
    for name, (group, recipe, variants) in SOUNDS.items():
        if filter_text and filter_text not in name:
            continue
        for v in range(variants):
            rng = np.random.default_rng(zlib.crc32(f"{name}:{v}".encode()))
            x = recipe(rng, v)
            assert np.all(np.isfinite(x)), name
            path = OUT / group / f"{name}_{v + 1:02d}.wav"
            write_wav(path, x)
            written.append(path)
    return written


if __name__ == "__main__":
    files = build(sys.argv[1] if len(sys.argv) > 1 else "")
    print(f"{len(files)} Sounds geschrieben nach {OUT.relative_to(ROOT)}/")
