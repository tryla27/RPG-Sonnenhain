"""Entwürfe für die Klänge des Dunklen Golems (noch nicht im Spiel).

Angelo, 10.10.2026: „klar, brutal, brechend und schwer“. Drei Richtungen pro
Aktion zum Vergleichen, jeweils neben dem aktuellen Klang:
  A „Felsbruch“: trocken und nah. Harte Bruchkante vorne, dann ein kurzer,
     tiefer Schlag. Am klarsten, sehr direkt.
  B „Tonnengewicht“: Tiefe zuerst. Wuchtiger Unterbau, längerer Nachhall,
     rieselnder Schutt. Am schwersten.
  C „Zermalmen“: verzerrt und gepresst. Gesättigte Schläge und Mahlen,
     am brutalsten (passt zur Hardtekk-Musik).

Ausgabe: <ziel>/<aktion>_<a|b|c>.wav und <aktion>_jetzt.wav.
Aufruf: python3 tools/build_golem_sfx_draft.py <zielordner>
"""
import sys
import zlib
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
import build_sfx as b  # noqa: E402

SR = b.SR


# ------------------------------------------------------------------ Bausteine

def sat(x, drive=2.5):
    """Sättigung: macht Schläge dichter und brutaler, ohne zu matschen."""
    return np.tanh(x * drive) / np.tanh(drive)


def crack(rng, d, low=1400, high=7000, sharp=0.012):
    """Harte Bruchkante: sehr kurzer, heller Knall (Stein reißt)."""
    return b.bp(b.noise(d, rng), low, high) * b.env(d, 0.0004, sharp, 6)


def splinters(rng, d, count, start, spread, low=1800, high=8000):
    """Splitter direkt nach dem Bruch: mehrere winzige Knackser."""
    out = np.zeros(int(SR * d))
    for _ in range(count):
        t0 = start + rng.uniform(0, spread)
        s = b.bp(b.noise(0.006, rng), low, high) * b.env(0.006, 0.0002, 0.003)
        i0 = int(t0 * SR)
        seg = s[: max(0, len(out) - i0)]
        out[i0:i0 + len(seg)] += seg * rng.uniform(0.4, 1.0)
    return out


def rubble(rng, d, count, start, spread, low=900, high=5000):
    """Nachrieselnder Schutt: viele kleine Steine, leiser werdend."""
    out = np.zeros(int(SR * d))
    for k in range(count):
        t0 = start + spread * (k / max(1, count)) ** 0.7 + rng.uniform(-0.02, 0.02)
        length = rng.uniform(0.01, 0.03)
        s = b.bp(b.noise(length, rng), low, high) * b.env(length, 0.0005, length * 0.5)
        i0 = int(max(0.0, t0) * SR)
        seg = s[: max(0, len(out) - i0)]
        out[i0:i0 + len(seg)] += seg * rng.uniform(0.3, 1.0) * (1.0 - 0.6 * k / max(1, count))
    return out


def grind(rng, d, low, high, density):
    """Mahlen: dichte, gefilterte Knackser wie Stein auf Stein."""
    return b.lp(b.bp(b.noise(d, rng), low, high) * (rng.random(int(SR * d)) > density), high * 1.3) * 3.0


def sub(f0, f1, d, decay):
    """Tiefer Körper eines Einschlags."""
    return b.thump(f0, f1, d, decay)


def fin(x, **kw):
    kw.setdefault("low_cut", 26)
    return b.finish(x, **kw)


# ------------------------------------------------------------------ Schritt

def schritt_a(rng):
    d = 0.7
    return fin(b.mix((b.at(crack(rng, 0.05, 1200, 6000), 0, d), 0.8), (sub(85, 38, d, 0.22), 1.0),
                     (splinters(rng, d, 6, 0.01, 0.08), 0.5)))


def schritt_b(rng):
    d = 1.1
    boom = sub(58, 26, d, 0.5)
    quake = b.lp(b.noise(d, rng, "brown"), 90) * b.env(d, 0.01, 0.7, 2) * 1.4
    return fin(b.mix((boom, 1.0), (quake, 0.8), (b.at(crack(rng, 0.04, 900, 4000), 0, d), 0.4),
                     (rubble(rng, d, 10, 0.12, 0.6), 0.35)), echo_wet=0.14, echo_delay=0.11)


def schritt_c(rng):
    d = 0.8
    body = sat(sub(72, 32, d, 0.3) * 1.6, 3.0)
    crunch = sat(grind(rng, 0.25, 300, 2500, 0.8) * b.env(0.25, 0.001, 0.15, 3), 2.0)
    return fin(b.mix((body, 1.0), (b.at(crunch, 0, d), 0.6)))


# ------------------------------------------------------------------ Schild

def schild_a(rng):
    d = 1.2
    slams = b.at(sub(110, 45, 0.5, 0.18), 0, d) + b.at(sub(95, 40, 0.5, 0.2), 0.16, d)
    seal = b.at(crack(rng, 0.05, 1500, 7000), 0.16, d)
    hum = b.lp(b.osc(55, d, "saw"), 300) * np.minimum(b.t_axis(d) / 0.3, 1) * b.env(d, 0.3, 0.9, 2)
    return fin(b.mix((slams, 1.0), (seal, 0.6), (hum, 0.35), (splinters(rng, d, 8, 0.16, 0.12), 0.4)))


def schild_b(rng):
    d = 1.6
    t = b.t_axis(d)
    close = b.at(sub(70, 30, 1.0, 0.45), 0.05, d)
    grindin = grind(rng, d, 150, 900, 0.9) * np.minimum(t / 0.5, 1) * b.env(d, 0.4, 1.2, 2)
    drone = b.lp(b.osc(41, d, "saw") + b.osc(61.5, d), 220) * np.minimum(t / 0.4, 1) * b.env(d, 0.4, 1.4, 1.5)
    return fin(b.mix((close, 1.0), (grindin, 0.6), (drone, 0.5)), echo_wet=0.2, echo_delay=0.15, tail=0.2)


def schild_c(rng):
    d = 1.2
    t = b.t_axis(d)
    slams = sat((b.at(sub(100, 40, 0.4, 0.15), 0, d) + b.at(sub(90, 36, 0.4, 0.15), 0.12, d)) * 1.7, 3.0)
    lock = sat(grind(rng, d, 200, 1800, 0.82) * np.minimum(t / 0.2, 1) * b.env(d, 0.2, 0.8, 2), 2.2)
    return fin(b.mix((slams, 1.0), (lock, 0.6)))


# ------------------------------------------------------------------ Schaben

def schaben_a(rng):
    d = 1.0
    t = b.t_axis(d)
    shape = np.minimum(t / 0.08, 1) * np.minimum((d - t) / 0.1, 1)
    scrape = b.sweep_bp(b.noise(d, rng), b.glide(700, 2200, d, 1.0), q=3.0) * shape
    chips = splinters(rng, d, 30, 0.05, 0.85)
    return fin(b.mix((scrape, 0.8), (chips, 0.7), (b.lp(b.noise(d, rng, "brown"), 160) * shape, 0.5)))


def schaben_b(rng):
    d = 1.2
    t = b.t_axis(d)
    shape = np.minimum(t / 0.2, 1) * np.minimum((d - t) / 0.15, 1)
    drag = b.lp(b.noise(d, rng, "brown"), 140) * shape * 1.5
    grit = grind(rng, d, 250, 1600, 0.88) * shape
    return fin(b.mix((drag, 1.0), (grit, 0.7), (rubble(rng, d, 12, 0.2, 0.9), 0.4)), echo_wet=0.1)


def schaben_c(rng):
    d = 1.0
    t = b.t_axis(d)
    shape = np.minimum(t / 0.1, 1) * np.minimum((d - t) / 0.1, 1)
    saw = sat(b.sweep_bp(b.noise(d, rng), b.glide(400, 1600, d, 1.2), q=2.0) * shape * 2.0, 3.0)
    grit = sat(grind(rng, d, 500, 3000, 0.8) * shape, 2.0)
    return fin(b.mix((saw, 0.9), (grit, 0.7)))


# ------------------------------------------------------------------ Wurf

def wurf_a(rng):
    d = 0.7
    rip = b.at(crack(rng, 0.06, 1000, 5000, 0.02), 0, d)
    heave = sub(120, 50, 0.4, 0.15)
    whoosh = b.sweep_bp(b.noise(d, rng), b.glide(500, 2400, d, 0.5), q=2.0) * b.env(d, 0.05, 0.5, 2)
    return fin(b.mix((rip, 0.7), (heave, 1.0), (whoosh, 0.6), (splinters(rng, d, 6, 0.0, 0.06), 0.4)))


def wurf_b(rng):
    d = 0.9
    heave = sub(80, 35, 0.6, 0.25)
    whoosh = b.lp(b.sweep_bp(b.noise(d, rng), b.glide(200, 1200, d, 0.6), q=1.2), 2000) * b.env(d, 0.12, 0.7, 2)
    return fin(b.mix((heave, 1.0), (whoosh, 0.8)), echo_wet=0.1)


def wurf_c(rng):
    d = 0.7
    heave = sat(sub(110, 45, 0.4, 0.15) * 1.8, 3.0)
    whoosh = sat(b.sweep_bp(b.noise(d, rng), b.glide(300, 2000, d, 0.5), q=1.6) * b.env(d, 0.04, 0.5, 2) * 1.5, 2.0)
    return fin(b.mix((heave, 1.0), (whoosh, 0.7)))


# ------------------------------------------------------------------ Brocken landet / Stampfer

def landen_a(rng):
    d = 1.0
    hit = b.at(crack(rng, 0.06, 1200, 7000, 0.015), 0, d)
    boom = sub(75, 30, d, 0.35)
    return fin(b.mix((hit, 0.9), (boom, 1.0), (splinters(rng, d, 14, 0.0, 0.15), 0.6),
                     (rubble(rng, d, 14, 0.15, 0.6), 0.35)))


def landen_b(rng):
    d = 1.5
    boom = sub(55, 24, d, 0.6)
    quake = b.lp(b.noise(d, rng, "brown"), 80) * b.env(d, 0.005, 1.0, 2) * 1.6
    return fin(b.mix((boom, 1.0), (quake, 0.9), (b.at(crack(rng, 0.05, 800, 4000), 0, d), 0.45),
                     (rubble(rng, d, 24, 0.2, 1.0), 0.45)), echo_wet=0.18, echo_delay=0.13, tail=0.15)


def landen_c(rng):
    d = 1.0
    body = sat(sub(70, 28, d, 0.35) * 2.0, 3.5)
    burst = sat(b.at(grind(rng, 0.35, 300, 3500, 0.7) * b.env(0.35, 0.001, 0.2, 3), 0, d), 2.5)
    return fin(b.mix((body, 1.0), (burst, 0.7), (rubble(rng, d, 10, 0.2, 0.5), 0.3)))


# ------------------------------------------------------------------ Steinhagel

def hagel_a(rng):
    d = 0.3
    return fin(b.mix((b.at(crack(rng, 0.04, 1500, 7500, 0.01), 0, d), 0.9), (sub(170, 70, d, 0.08), 0.8),
                     (splinters(rng, d, 5, 0.0, 0.05), 0.5)))


def hagel_b(rng):
    d = 0.5
    return fin(b.mix((sub(120, 50, d, 0.15), 1.0), (b.at(crack(rng, 0.04, 900, 4000), 0, d), 0.5),
                     (rubble(rng, d, 6, 0.05, 0.3), 0.4)))


def hagel_c(rng):
    d = 0.3
    return fin(b.mix((sat(sub(160, 60, d, 0.08) * 1.8, 3.0), 1.0),
                     (sat(grind(rng, 0.12, 600, 4000, 0.7) * b.env(0.12, 0.001, 0.06, 3), 2.0), 0.6)))


# ------------------------------------------------------------------ Schrei

def schrei_a(rng):
    d = 1.6
    t = b.t_axis(d)
    roar = b.voice(b.glide(120, 85, d, 1.0), d, ((500, 140, 1.0), (1100, 200, 0.6), (2600, 300, 0.3)), breath=0.25, rng=rng)
    crackle = splinters(rng, d, 40, 0.05, 1.3, 1200, 6000)
    shape = np.minimum(t / 0.06, 1) * b.env(d, 0.06, 1.4, 1.6)
    return fin(b.mix((roar, 1.0), (crackle, 0.4)) * shape, echo_wet=0.2, echo_delay=0.14)


def schrei_b(rng):
    d = 1.8
    t = b.t_axis(d)
    roar = b.voice(b.glide(80, 55, d, 1.0), d, ((350, 120, 1.0), (750, 160, 0.6), (1900, 260, 0.2)), breath=0.4, rng=rng)
    growl = b.lp(b.osc(b.glide(42, 33, d), d, "saw") * (1 + 0.6 * np.sin(2 * np.pi * 19 * t)), 500)
    quake = b.lp(b.noise(d, rng, "brown"), 70) * 1.8
    shape = np.minimum(t / 0.2, 1) * b.env(d, 0.2, 1.6, 1.3)
    return fin(b.mix((roar, 1.0), (growl, 0.7), (quake, 0.8)) * shape, echo_wet=0.3, echo_delay=0.19, echo_fb=0.35, tail=0.2)


def schrei_c(rng):
    d = 1.6
    t = b.t_axis(d)
    roar = b.voice(b.glide(100, 70, d, 1.0), d, ((420, 120, 1.0), (900, 160, 0.7), (2400, 300, 0.35)), breath=0.35, rng=rng)
    growl = b.osc(b.glide(48, 38, d), d, "saw") * (1 + 0.7 * np.sin(2 * np.pi * 27 * t))
    shape = np.minimum(t / 0.1, 1) * b.env(d, 0.1, 1.4, 1.4)
    return fin(sat(b.mix((roar, 1.0), (b.lp(growl, 800), 0.8)) * shape * 2.2, 3.5), echo_wet=0.15)


# ------------------------------------------------------------------ Zerfall

def zerfall_a(rng):
    d = 1.6
    parts = []
    for off in (0.0, 0.2, 0.42, 0.7, 1.0):
        parts.append(b.at(crack(rng, 0.05, 1200, 7000, 0.015), off, d) * 0.8)
        parts.append(b.at(sub(rng.uniform(65, 100), 32, 0.5, 0.2), off, d))
    return fin(b.mix((sum(parts), 1.0), (splinters(rng, d, 30, 0.0, 1.2), 0.5), (rubble(rng, d, 30, 0.2, 1.3), 0.4)))


def zerfall_b(rng):
    d = 1.7
    breaks = sum(b.at(sub(rng.uniform(45, 75), 22, 0.9, 0.4), off, d) for off in (0.0, 0.3, 0.75))
    quake = b.lp(b.noise(d, rng, "brown"), 70) * b.env(d, 0.01, 1.6, 1.5) * 1.6
    return fin(b.mix((breaks, 1.0), (quake, 0.8), (rubble(rng, d, 45, 0.15, 1.4), 0.5)), echo_wet=0.2, echo_delay=0.15)


def zerfall_c(rng):
    d = 1.6
    breaks = sat(sum(b.at(sub(rng.uniform(60, 90), 28, 0.5, 0.2), off, d) for off in (0.0, 0.18, 0.4, 0.66, 0.95)) * 1.8, 3.0)
    crush = sat(grind(rng, d, 250, 3000, 0.8) * b.env(d, 0.01, 1.2, 1.6), 2.2)
    return fin(b.mix((breaks, 1.0), (crush, 0.7), (rubble(rng, d, 20, 0.3, 1.1), 0.35)))



# ================================================================== Runde 2
# Angelos Rückmeldung (10.10.2026, Klangprobe Runde 1):
#  Wurf: „viel krasser, als würde ein Meteorit geworfen und dann einschlagen“
#  Steinhagel: „so lang wie der Hagel (~8 s), Regen aus großen Felsbrocken,
#    die sehr oft einschlagen“
#  Zerfall: „wie jetzt, aber weniger synthetisch, brechender, verzerrter“
#  Schild: „wie B, aber so lang wie der Schild (8 s)“

def fracture(rng, d, low=300, high=6000, drive=2.0):
    """Echter wirkender Bruch: mehrere gestapelte Rauschrisse statt reiner
    Sinus-Schläge, leicht verzerrt."""
    out = np.zeros(int(SR * d))
    t0 = 0.0
    for k in range(int(rng.integers(3, 6))):
        length = rng.uniform(0.02, 0.07)
        band = b.bp(b.noise(length, rng), rng.uniform(low, low * 2), rng.uniform(high * 0.6, high))
        piece = band * b.env(length, 0.0003, length * 0.35, 4)
        i0 = int(t0 * SR)
        seg = piece[: max(0, len(out) - i0)]
        out[i0:i0 + len(seg)] += seg * rng.uniform(0.6, 1.0)
        t0 += rng.uniform(0.006, 0.03)
    return sat(out * 1.5, drive)


def boulder_hit(rng, size=1.0, bright=1.0):
    """Ein großer Felsbrocken schlägt ein (für den Hagel-Regen)."""
    d = 0.5 + 0.3 * size
    body = sub(rng.uniform(55, 90) / (0.7 + 0.3 * size), 26, d, 0.15 + 0.15 * size)
    br = fracture(rng, 0.25, 600 * bright, 6500 * bright, 1.8)
    return b.mix((body, 1.0), (b.at(br, 0, d), 0.7 * bright), (rubble(rng, d, 5, 0.05, 0.3), 0.25))


def scatter(rng, total, rate, maker, start=0.0, fade_in=0.4, fade_out=0.8):
    """Viele Einschläge über `total` Sekunden verteilt (Poisson)."""
    out = np.zeros(int(SR * total))
    t = start
    while t < total - 0.3:
        x = maker(rng)
        i0 = int(t * SR)
        seg = x[: max(0, len(out) - i0)]
        g = min(1.0, (t + 0.05) / fade_in) * min(1.0, (total - t) / fade_out)
        pan_gain = rng.uniform(0.45, 1.0)
        out[i0:i0 + len(seg)] += seg * g * pan_gain
        t += rng.exponential(1.0 / rate)
    return out


# ------------------------------------------------------------ Wurf (Meteor)

def wurf2_a(rng):
    """Meteor A: Felsen reißt heraus, dann heulender, steigender Flug."""
    d = 1.4
    t = b.t_axis(d)
    rip = b.at(fracture(rng, 0.2, 400, 6000, 2.2), 0, d)
    heave = sub(95, 38, 0.6, 0.25)
    roar = b.sweep_bp(b.noise(d, rng), b.glide(180, 1400, d, 0.7), q=1.1) * np.minimum(t / 0.15, 1) * b.env(d, 0.15, 1.1, 1.4)
    rumble = b.lp(b.noise(d, rng, "brown"), 120) * np.minimum(t / 0.1, 1) * b.env(d, 0.1, 1.2, 1.4)
    return fin(b.mix((rip, 0.8), (heave, 1.0), (roar, 0.9), (rumble, 0.9)))


def wurf2_b(rng):
    """Meteor B: tiefer Ruck, dann brennender Felsbrocken mit Knistern und Dröhnen."""
    d = 1.5
    t = b.t_axis(d)
    heave = sat(sub(80, 30, 0.7, 0.3) * 1.5, 2.5)
    roar = b.lp(b.sweep_bp(b.noise(d, rng), b.glide(120, 900, d, 0.8), q=0.9), 2500) * np.minimum(t / 0.1, 1) * b.env(d, 0.1, 1.3, 1.3)
    crackle = splinters(rng, d, 60, 0.1, 1.2, 1500, 7000) * np.minimum(t / 0.3, 1)
    drone = b.lp(b.osc(b.glide(55, 40, d), d, "saw"), 300) * b.env(d, 0.1, 1.3, 1.3)
    return fin(b.mix((heave, 1.0), (roar, 1.0), (crackle, 0.45), (drone, 0.5)))


def wurf2_c(rng):
    """Meteor C: maximal verzerrt, Doppelschlag beim Abwurf, gepresstes Heulen."""
    d = 1.4
    t = b.t_axis(d)
    slams = sat((b.at(sub(110, 40, 0.4, 0.15), 0, d) + b.at(sub(90, 35, 0.5, 0.2), 0.09, d)) * 2.0, 3.5)
    howl = sat(b.sweep_bp(b.noise(d, rng), b.glide(250, 1800, d, 0.6), q=1.4) * np.minimum(t / 0.1, 1) * b.env(d, 0.1, 1.1, 1.3) * 2.0, 3.0)
    return fin(b.mix((slams, 1.0), (howl, 0.8), (b.at(fracture(rng, 0.2, 500, 6000, 3.0), 0, d), 0.6)))


# ------------------------------------------------------------ Steinhagel (lang)
HAIL_SECONDS = 12.0  # so lange dauert das Steinhagel-Feld im Spiel

def hagel2_a(rng):
    """Felsregen A: dichte, harte Einschläge, klar voneinander zu hören."""
    d = HAIL_SECONDS
    hits = scatter(rng, d, 6.0, lambda r: boulder_hit(r, r.uniform(0.6, 1.2), 1.0))
    bed = b.lp(b.noise(d, rng, "brown"), 100) * 0.25
    return fin(b.mix((hits, 1.0), (bed, 0.5)))


def hagel2_b(rng):
    """Felsregen B: schwere, tiefe Brocken, Boden bebt durchgehend."""
    d = HAIL_SECONDS
    hits = scatter(rng, d, 4.5, lambda r: boulder_hit(r, r.uniform(1.0, 1.6), 0.7))
    t = b.t_axis(d)
    quake = b.lp(b.noise(d, rng, "brown"), 70) * (0.6 + 0.4 * np.sin(2 * np.pi * 0.7 * t) ** 2) * np.minimum(t / 0.6, 1) * np.minimum((d - t) / 1.0, 1)
    return fin(b.mix((hits, 1.0), (quake, 0.7), (rubble(rng, d, 120, 0.3, d - 1.0), 0.2)), echo_wet=0.12, echo_delay=0.13)


def hagel2_c(rng):
    """Felsregen C: sehr dicht und verzerrt, wie ein Bombardement."""
    d = HAIL_SECONDS
    hits = scatter(rng, d, 8.0, lambda r: sat(boulder_hit(r, r.uniform(0.7, 1.3), 1.0) * 1.8, 2.8))
    bed = sat(b.lp(b.noise(d, rng, "brown"), 120) * 0.6, 2.0)
    return fin(b.mix((hits, 1.0), (bed, 0.4)))


# ------------------------------------------------------------ Zerfall (brechender)

def _zerfall_base(rng, d, offs, drive, layers):
    parts = np.zeros(int(SR * d))
    for off in offs:
        size = rng.uniform(0.8, 1.4)
        hit = b.mix((sub(rng.uniform(50, 85), 25, 0.6, 0.22 * size), 0.8), (fracture(rng, 0.3, 300, 6500, drive), 1.0))
        parts += b.at(hit, off, d)[: len(parts)]
    return parts


def zerfall2_a(rng):
    """Zerfall A: wie jetzt, aber jeder Schlag ist ein echter Bruch."""
    d = 1.7
    breaks = _zerfall_base(rng, d, (0.0, 0.18, 0.4, 0.68, 0.95), 2.0, 1)
    grind_ = grind(rng, d, 200, 2800, 0.84) * b.env(d, 0.01, 1.3, 1.6)
    return fin(b.mix((breaks, 1.0), (grind_, 0.6), (rubble(rng, d, 30, 0.3, 1.3), 0.4)), echo_wet=0.18, echo_delay=0.14)


def zerfall2_b(rng):
    """Zerfall B: lauter, verzerrter, mehr Splitter dazwischen."""
    d = 1.7
    breaks = _zerfall_base(rng, d, (0.0, 0.15, 0.33, 0.55, 0.8, 1.05), 3.0, 1)
    shards = splinters(rng, d, 60, 0.0, 1.4, 1500, 8000)
    return fin(sat(b.mix((breaks, 1.0), (shards, 0.5), (rubble(rng, d, 40, 0.3, 1.3), 0.4)) * 1.6, 2.2))


def zerfall2_c(rng):
    """Zerfall C: tiefer Kern bricht zuerst, dann reißt alles nacheinander."""
    d = 1.8
    core = sat(sub(48, 22, 1.0, 0.45) * 1.8, 2.5)
    breaks = _zerfall_base(rng, d, (0.12, 0.3, 0.52, 0.78, 1.05), 2.6, 1)
    quake = b.lp(b.noise(d, rng, "brown"), 80) * b.env(d, 0.01, 1.5, 1.5)
    return fin(b.mix((core, 1.0), (breaks, 0.9), (quake, 0.6), (rubble(rng, d, 40, 0.4, 1.3), 0.4)), echo_wet=0.15)


# ------------------------------------------------------------ Schild (8 s)
SHIELD_SECONDS = 8.0

def schild2(rng, variant):
    d = SHIELD_SECONDS
    t = b.t_axis(d)
    close = b.at(sub(70, 30, 1.0, 0.45), 0.05, d)
    hold = np.minimum(t / 0.5, 1) * np.minimum((d - t) / 0.6, 1)
    grindin = grind(rng, d, 150, 900, 0.9) * hold
    drone = b.lp(b.osc(41, d, "saw") + b.osc(61.5, d), 220) * hold
    open_ = b.at(sub(85, 35, 0.6, 0.25), d - 0.55, d)
    if variant == "a":   # gleichmäßig: Mahlen und Dröhnen tragen durch
        mix = b.mix((close, 1.0), (grindin, 0.5), (drone, 0.5), (open_, 0.7))
    elif variant == "b":  # pulsierend: der Stein arbeitet in Wellen
        pulse = 0.55 + 0.45 * np.sin(2 * np.pi * 0.9 * t) ** 2
        mix = b.mix((close, 1.0), (grindin * pulse, 0.65), (drone * (0.7 + 0.3 * pulse), 0.5), (open_, 0.7))
    else:                 # knackend: unter Druck reißen immer wieder Risse
        cracks = scatter(rng, d, 1.6, lambda r: fracture(r, 0.25, 500, 6000, 2.0), start=0.5, fade_in=0.2, fade_out=0.8)
        mix = b.mix((close, 1.0), (grindin, 0.5), (drone, 0.45), (cracks, 0.5), (open_, 0.7))
    return fin(mix, echo_wet=0.12, echo_delay=0.15)


ROUND2 = {
    "golem_wurf": (wurf2_a, wurf2_b, wurf2_c),
    "steinhagel": (hagel2_a, hagel2_b, hagel2_c),
    "golem_zerfall": (zerfall2_a, zerfall2_b, zerfall2_c),
    "golem_schild": (lambda r: schild2(r, "a"), lambda r: schild2(r, "b"), lambda r: schild2(r, "c")),
}


def build_round2(target: Path) -> list:
    files = []
    for name, recipes in ROUND2.items():
        for tag, recipe in zip("abc", recipes):
            rng = np.random.default_rng(zlib.crc32(f"{name}:r2:{tag}".encode()))
            x = recipe(rng)
            assert np.all(np.isfinite(x)), (name, tag)
            path = target / f"r2_{name}_{tag}.wav"
            b.write_wav(path, x)
            files.append(path)
    # Wurf zusammen mit dem gewählten Einschlag (Brocken landet B) als Ablauf.
    land = landen_b(np.random.default_rng(zlib.crc32(b"brocken_landen:draft:b")))
    for tag, recipe in zip("abc", ROUND2["golem_wurf"]):
        throw = recipe(np.random.default_rng(zlib.crc32(f"golem_wurf:r2:{tag}".encode())))
        gap = int(0.8 * SR)
        seq = np.zeros(max(len(throw), gap + len(land)))
        seq[: len(throw)] += throw
        seq[gap:gap + len(land)] += land
        seq = seq / (np.max(np.abs(seq)) + 1e-9) * 10 ** (-3 / 20)
        path = target / f"r2_golem_wurf_{tag}_mit_einschlag.wav"
        b.write_wav(path, seq)
        files.append(path)
    return files

ACTIONS = {
    "golem_schritt": (schritt_a, schritt_b, schritt_c),
    "golem_schild": (schild_a, schild_b, schild_c),
    "golem_schaben": (schaben_a, schaben_b, schaben_c),
    "golem_wurf": (wurf_a, wurf_b, wurf_c),
    "brocken_landen": (landen_a, landen_b, landen_c),
    "steinhagel": (hagel_a, hagel_b, hagel_c),
    "golem_schrei": (schrei_a, schrei_b, schrei_c),
    "golem_zerfall": (zerfall_a, zerfall_b, zerfall_c),
}


def build(target: Path) -> list:
    files = []
    for name, recipes in ACTIONS.items():
        group, current, _ = b.SOUNDS[name]
        rng = np.random.default_rng(zlib.crc32(f"{name}:0".encode()))
        x = current(rng, 0)
        path = target / f"{name}_jetzt.wav"
        b.write_wav(path, x)
        files.append(path)
        for tag, recipe in zip("abc", recipes):
            rng = np.random.default_rng(zlib.crc32(f"{name}:draft:{tag}".encode()))
            x = recipe(rng)
            assert np.all(np.isfinite(x)), (name, tag)
            assert len(x) < SR * 2, (name, tag, len(x) / SR)
            path = target / f"{name}_{tag}.wav"
            b.write_wav(path, x)
            files.append(path)
    return files


if __name__ == "__main__":
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "build/golem_sfx_draft")
    written = build_round2(out) if "--runde2" in sys.argv else build(out)
    print(f"{len(written)} Dateien in {out}")
