"""Entwürfe für Schrittgeräusche je Untergrund (noch nicht im Spiel).

Zwei Richtungen pro Untergrund zum Vergleichen:
  A „16-Bit klar“: kurze, tonale Anschläge wie auf dem SNES.
  B „weich & natürlich“: körniges Foley, gleiche Konsolen-Endstufe.
Jeder Schritt besteht aus Ferse und Abrollen (30–70 ms später). Ausgabe:
<ziel>/<untergrund>_<a|b>_NN.wav (4 Varianten) und <untergrund>_<a|b>_gang.wav
(8 Schritte im Lauftempo, wechselnde Varianten).

Aufruf: python3 tools/build_footsteps_draft.py <zielordner>
"""
import sys
import zlib
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
import build_sfx as b  # noqa: E402

SR = b.SR
STEP_RMS = 0.05       # gleiche gefühlte Lautheit für alle Entwürfe (fairer A/B-Vergleich)
STEP_PEAK = 0.6       # Obergrenze, damit Anschläge nicht übersteuern
WALK_INTERVAL = 0.34  # Sekunden zwischen zwei Schritten beim Gehen


def grains(d, rng, rate, low, high, length=0.004, gain=1.0, shape=None):
    """Körnige Einzelimpulse (Halme, Kies, Sandkörner) über die Dauer verteilt."""
    n = int(SR * d)
    out = np.zeros(n)
    count = max(1, int(rate * d))
    for _ in range(count):
        start = rng.uniform(0, d * 0.85)
        g = b.bp(b.noise(length, rng), low, high) * b.env(length, 0.0003, length * 0.4)
        i0 = int(start * SR)
        seg = g[: max(0, n - i0)]
        w = 1.0 if shape is None else shape[min(i0, n - 1)]
        out[i0:i0 + len(seg)] += seg * rng.uniform(0.4, 1.0) * w
    return out * gain


def modal(freqs, decays, d, amps=None):
    """Gedämpfte Eigenschwingungen (Holz, Stein) für einen klaren Anschlag."""
    t = b.t_axis(d)
    amps = amps or [1.0] * len(freqs)
    return sum(a * np.sin(2 * np.pi * f * t) * np.exp(-t / dc) for f, dc, a in zip(freqs, decays, amps))


def two_part(heel, toe, gap, d):
    return b.at(heel, 0.0, d) + b.at(toe, gap, d)


def fin(x, *, echo=0.0, delay=0.07, top=9000, bits=12):
    x = b.finish(x, echo_wet=echo, echo_delay=delay, echo_fb=0.18, peak_db=-3.0, top=top, bits=bits, low_cut=50)
    rms = float(np.sqrt(np.mean(x ** 2))) + 1e-9
    return x * min(STEP_RMS / rms, STEP_PEAK / (float(np.max(np.abs(x))) + 1e-9))


# ------------------------------------------------------------------ Gras
def gras_a(rng, v):
    d = 0.2
    heel = b.thump(150 + 8 * v, 90, 0.07, 0.025) * 0.7 + b.bp(b.noise(0.07, rng), 2500, 6000) * b.env(0.07, 0.002, 0.02) * 0.5
    toe = b.bp(b.noise(0.09, rng), 3200 + 200 * v, 7500) * b.env(0.09, 0.006, 0.03) * 0.45
    return fin(two_part(heel, toe, 0.055 + 0.006 * v, d), top=8500)


def gras_b(rng, v):
    d = 0.24
    shape = np.sin(np.pi * np.minimum(b.t_axis(d) / (d * 0.8), 1)) ** 1.5
    blades = grains(d, rng, 260, 2500, 8000, 0.003, 1.0, shape)
    press = b.lp(b.noise(d, rng), 260) * b.env(d, 0.004, 0.035) * 0.9
    swish = b.bp(b.noise(d, rng), 1200, 4200) * shape * 0.25
    return fin(b.mix((blades, 0.9), (press, 1.0), (swish, 0.6)), top=8000)


# ------------------------------------------------------------------ Waldboden / Laub
def laub_a(rng, v):
    d = 0.22
    heel = b.thump(130, 80, 0.07, 0.02) * 0.8
    crunch = grains(0.12, rng, 220, 1800, 5200, 0.005, 1.0)
    return fin(two_part(heel, b.pad(crunch, 0.12), 0.03 + 0.005 * v, d), top=8000)


def laub_b(rng, v):
    d = 0.28
    shape = np.exp(-b.t_axis(d) / 0.09)
    crisp = grains(d, rng, 420, 1500, 6000, 0.006, 1.0, shape)
    twig = b.at(b.hp(b.noise(0.008, rng), 1800) * b.env(0.008, 0.0003, 0.003), 0.04 + 0.01 * v, d) * (0.8 if v % 2 == 0 else 0.0)
    press = b.lp(b.noise(d, rng), 300) * b.env(d, 0.003, 0.04)
    return fin(b.mix((crisp, 0.9), (twig, 0.6), (press, 0.9)), top=8000)


# ------------------------------------------------------------------ Erde / Weg
def erde_a(rng, v):
    d = 0.16
    heel = b.thump(120 + 6 * v, 70, 0.08, 0.02)
    grit = b.bp(b.noise(0.06, rng), 900, 2600) * b.env(0.06, 0.002, 0.015) * 0.5
    return fin(two_part(heel, grit, 0.045, d), top=7000)


def erde_b(rng, v):
    d = 0.2
    press = b.lp(b.noise(d, rng), 420) * b.env(d, 0.003, 0.03)
    pebbles = grains(0.1, rng, 120, 1400, 4200, 0.004, 0.9)
    scuff = b.bp(b.noise(0.08, rng), 700, 2200) * b.env(0.08, 0.01, 0.03) * 0.5
    return fin(b.mix((press, 1.0), (b.pad(pebbles, d), 0.7), (b.at(scuff, 0.06, d), 0.6)), top=7000)


# ------------------------------------------------------------------ Pflaster (Kopfstein)
def pflaster_a(rng, v):
    d = 0.18
    f = 520 + 40 * v
    heel = modal([f, f * 2.3, f * 3.9], [0.022, 0.012, 0.007], 0.09, [1.0, 0.5, 0.25])
    heel += b.pad(b.hp(b.noise(0.004, rng), 3000) * b.env(0.004, 0.0002, 0.0015) * 0.6, 0.09)
    toe = modal([f * 1.2, f * 2.7], [0.012, 0.007], 0.05, [0.5, 0.3])
    return fin(two_part(heel, toe, 0.06, d), top=9500)


def pflaster_b(rng, v):
    d = 0.18
    click = b.hp(b.noise(0.005, rng), 2200) * b.env(0.005, 0.0002, 0.0018)
    knock = b.bp(b.noise(0.05, rng), 500 + 60 * v, 1500) * b.env(0.05, 0.001, 0.012)
    grit = grains(0.08, rng, 160, 2500, 7000, 0.003, 0.5)
    toe = b.hp(b.noise(0.004, rng), 2600) * b.env(0.004, 0.0002, 0.0015) * 0.5
    return fin(b.mix((b.pad(click, d), 1.0), (b.pad(knock, d), 0.9), (b.at(grit, 0.02, d), 0.6), (b.at(toe, 0.065, d), 0.7)), top=9500)


# ------------------------------------------------------------------ Holz (Dielen innen)
def holz_a(rng, v):
    d = 0.22
    f = 190 + 10 * v
    heel = modal([f, f * 2.1, f * 3.4], [0.05, 0.025, 0.012], 0.18, [1.0, 0.5, 0.3])
    toe = modal([f * 1.1, f * 2.4], [0.03, 0.014], 0.1, [0.5, 0.3])
    return fin(two_part(heel, toe, 0.07, d), top=8000)


def holz_b(rng, v):
    d = 0.26
    knock = b.bp(b.noise(0.12, rng), 160, 650) * b.env(0.12, 0.001, 0.04)
    tap = b.hp(b.noise(0.005, rng), 1500) * b.env(0.005, 0.0002, 0.002)
    creak = b.at(b.osc(b.glide(420, 380, 0.09), 0.09, "saw") * b.env(0.09, 0.02, 0.05) * 0.06, 0.09, d) if v == 2 else 0
    return fin(b.mix((b.pad(knock, d), 1.0), (b.pad(tap, d), 0.6), (b.at(knock * 0.4, 0.075, d), 0.6)) + creak, top=8000)


# ------------------------------------------------------------------ Stein innen (Kapelle, Gewölbe)
def stein_a(rng, v):
    d = 0.32
    f = 680 + 50 * v
    heel = modal([f, f * 2.6, f * 4.2], [0.02, 0.01, 0.006], 0.08, [1.0, 0.45, 0.2])
    toe = modal([f * 1.15], [0.01], 0.04, [0.45])
    return fin(two_part(heel, toe, 0.06, d), echo=0.28, delay=0.09, top=10000)


def stein_b(rng, v):
    d = 0.34
    click = b.hp(b.noise(0.005, rng), 2400) * b.env(0.005, 0.0002, 0.002)
    knock = b.bp(b.noise(0.04, rng), 700, 2400) * b.env(0.04, 0.001, 0.01)
    scuff = b.bp(b.noise(0.05, rng), 2000, 6000) * b.env(0.05, 0.005, 0.015) * 0.4
    return fin(b.mix((b.pad(click, d), 1.0), (b.pad(knock, d), 0.8), (b.at(scuff, 0.05, d), 0.6)), echo=0.3, delay=0.085, top=10000)


# ------------------------------------------------------------------ Sand (Mondküste, Arena)
def sand_a(rng, v):
    d = 0.22
    heel = b.thump(110, 70, 0.08, 0.03) * 0.6
    hiss = b.bp(b.noise(0.16, rng), 2600 + 150 * v, 7000) * b.env(0.16, 0.02, 0.05, 2.5) * 0.6
    return fin(b.mix((b.pad(heel, d), 1.0), (b.at(hiss, 0.01, d), 0.8)), top=8000)


def sand_b(rng, v):
    d = 0.26
    t = b.t_axis(d)
    shape = np.sin(np.pi * np.minimum(t / 0.2, 1)) ** 2
    grains_ = grains(d, rng, 900, 2500, 9000, 0.002, 1.0, shape)
    squish = b.lp(b.noise(d, rng), 600) * shape * 0.6
    return fin(b.mix((grains_, 0.9), (squish, 1.0)), top=8500)


# ------------------------------------------------------------------ Moor / seichtes Wasser (Kristallmoor)
def moor_a(rng, v):
    d = 0.26
    splash = b.bp(b.noise(0.12, rng), 900, 4000) * b.env(0.12, 0.003, 0.04)
    blip = sum(b.at(b.osc(b.glide(500 + 120 * i + 30 * v, 1100 + 150 * i, 0.03), 0.03, "sine") * b.env(0.03, 0.002, 0.012) * 0.4, 0.04 + 0.04 * i, d) for i in range(2))
    return fin(b.mix((b.pad(splash, d), 1.0), (blip, 0.8)), top=8000)


def moor_b(rng, v):
    d = 0.3
    suck = b.lp(b.noise(0.18, rng), 500) * b.env(0.18, 0.02, 0.06) * 0.9
    slosh = b.sweep_bp(b.noise(0.2, rng), b.glide(700, 2200, 0.2, 0.7), q=2.5) * b.env(0.2, 0.004, 0.06)
    bubbles = sum(b.at(b.osc(b.glide(f, f * 1.8, 0.02), 0.02) * b.env(0.02, 0.001, 0.008) * 0.3, rng.uniform(0.06, 0.2), d) for f in rng.uniform(600, 1400, 3))
    return fin(b.mix((b.pad(suck, d), 0.9), (b.pad(slosh, d), 0.8), (bubbles, 0.7)), top=8000)


# ------------------------------------------------------------------ Asche / Kies (Ascheberge)
def asche_a(rng, v):
    d = 0.2
    heel = b.thump(140, 85, 0.06, 0.02) * 0.7
    gravel = grains(0.1, rng, 300, 1200, 4500, 0.004, 1.0)
    return fin(two_part(heel, b.pad(gravel, 0.1), 0.015, d), top=7500)


def asche_b(rng, v):
    d = 0.26
    shape = np.exp(-b.t_axis(d) / 0.08)
    crunch = grains(d, rng, 650, 900, 4000, 0.005, 1.0, shape)
    dust = b.bp(b.noise(d, rng), 1500, 5000) * b.env(d, 0.01, 0.06) * 0.3
    press = b.lp(b.noise(d, rng), 280) * b.env(d, 0.003, 0.03) * 0.8
    return fin(b.mix((crunch, 0.9), (dust, 0.6), (press, 0.9)), top=7500)


# ------------------------------------------------------------------ Runde 2 (9.10.): neue Ansätze
# für Gras, Pflaster, Holz, Sand und Moor. Beide in der natürlichen Richtung (B gefiel),
# C eher dumpf und nah, D heller mit mehr Material-Detail.
def gras_c(rng, v):
    d = 0.22
    t = b.t_axis(d)
    env_ = np.exp(-t / 0.06) * (1 - np.exp(-t / 0.004))
    crush = b.bp(b.noise(d, rng), 600, 2400) * env_
    blades = grains(0.12, rng, 180, 3000, 7000, 0.003, 0.5)
    thud = b.lp(b.noise(d, rng), 180) * b.env(d, 0.003, 0.03)
    return fin(b.mix((crush, 1.0), (b.pad(blades, d), 0.5), (thud, 1.0)), top=6500)


def gras_d(rng, v):
    d = 0.26
    t = b.t_axis(d)
    heel = b.bp(b.noise(0.1, rng), 1800, 6000) * b.env(0.1, 0.008, 0.03)
    roll = b.bp(b.noise(0.12, rng), 2500 + 200 * v, 8000) * b.env(0.12, 0.02, 0.04) * 0.7
    snap = grains(0.06, rng, 90, 4000, 9000, 0.002, 0.6)
    return fin(b.mix((b.pad(heel, d), 1.0), (b.at(roll, 0.06, d), 0.8), (b.at(snap, 0.02, d), 0.6), (b.lp(b.noise(d, rng), 220) * b.env(d, 0.003, 0.025), 0.8)), top=8500)


def pflaster_c(rng, v):
    d = 0.2
    heel = b.lp(b.noise(0.06, rng), 900) * b.env(0.06, 0.001, 0.014)
    clack = b.bp(b.noise(0.03, rng), 1400 + 100 * v, 3200) * b.env(0.03, 0.0005, 0.006)
    toe = b.bp(b.noise(0.04, rng), 1000, 2600) * b.env(0.04, 0.001, 0.008) * 0.6
    sand = grains(0.06, rng, 120, 3000, 7000, 0.002, 0.25)
    return fin(b.mix((b.pad(heel, d), 1.0), (b.pad(clack, d), 0.8), (b.at(toe, 0.07, d), 0.8), (b.at(sand, 0.075, d), 0.6)), top=8500)


def pflaster_d(rng, v):
    d = 0.22
    heel = b.bp(b.noise(0.05, rng), 300, 1200) * b.env(0.05, 0.001, 0.012)
    stone = b.bp(b.noise(0.025, rng), 2200, 5000) * b.env(0.025, 0.0003, 0.004)
    scrape = b.bp(b.noise(0.06, rng), 2500, 6500) * b.env(0.06, 0.01, 0.02) * 0.35
    return fin(b.mix((b.pad(heel, d), 1.0), (b.pad(stone, d), 0.6), (b.at(heel * 0.6, 0.075, d), 0.9), (b.at(scrape, 0.08, d), 0.7)), top=9000)


def holz_c(rng, v):
    d = 0.26
    body = b.bp(b.noise(0.14, rng), 110, 380) * b.env(0.14, 0.002, 0.05)
    board = b.bp(b.noise(0.05, rng), 600 + 50 * v, 1500) * b.env(0.05, 0.001, 0.012) * 0.6
    return fin(b.mix((b.pad(body, d), 1.0), (b.pad(board, d), 0.7), (b.at(body * 0.5, 0.08, d), 0.7)), top=7000)


def holz_d(rng, v):
    d = 0.3
    knock = b.bp(b.noise(0.1, rng), 200, 900) * b.env(0.1, 0.001, 0.03)
    tap = b.bp(b.noise(0.01, rng), 1500, 4000) * b.env(0.01, 0.0003, 0.003)
    creak = b.at(b.sweep_bp(b.noise(0.12, rng), b.glide(700, 520, 0.12), q=8.0) * b.env(0.12, 0.03, 0.05) * 0.5, 0.1, d) if v in (1, 3) else 0
    return fin(b.mix((b.pad(knock, d), 1.0), (b.pad(tap, d), 0.6), (b.at(knock * 0.55, 0.075, d), 0.7)) + creak, top=8000)


def sand_c(rng, v):
    d = 0.3
    t = b.t_axis(d)
    shape = np.minimum(t / 0.05, 1) * np.exp(-np.maximum(t - 0.05, 0) / 0.08)
    give = b.lp(b.noise(d, rng), 900) * shape
    crunch = grains(d, rng, 500, 1500, 5000, 0.003, 0.7, shape)
    return fin(b.mix((give, 1.0), (crunch, 0.7)), top=7000)


def sand_d(rng, v):
    d = 0.32
    t = b.t_axis(d)
    shape = np.sin(np.pi * np.minimum(t / 0.24, 1)) ** 1.5
    shh = b.bp(b.noise(d, rng), 3000, 9000) * shape * 0.5
    squeak = b.at(b.osc(b.glide(900 + 60 * v, 1300, 0.05), 0.05, "tri") * b.env(0.05, 0.01, 0.02) * 0.08, 0.03, d)
    press = b.lp(b.noise(d, rng), 400) * shape
    return fin(b.mix((shh, 0.8), (press, 1.0)) + squeak, top=9000)


def moor_c(rng, v):
    d = 0.34
    t = b.t_axis(d)
    squelch = b.sweep_bp(b.noise(d, rng), b.glide(300, 900, d, 0.6), q=3.0) * b.env(d, 0.01, 0.08)
    suck = b.at(b.lp(b.noise(0.12, rng), 350) * b.env(0.12, 0.04, 0.03), 0.16, d)
    drip = sum(b.at(b.osc(b.glide(f, f * 1.5, 0.015), 0.015) * b.env(0.015, 0.001, 0.006) * 0.25, rng.uniform(0.18, 0.3), d) for f in rng.uniform(800, 1500, 2))
    return fin(b.mix((squelch, 1.0), (suck, 0.8), (drip, 0.6)), top=7000)


def moor_d(rng, v):
    d = 0.32
    splash = b.bp(b.noise(0.14, rng), 1500, 6000) * b.env(0.14, 0.002, 0.04)
    body = b.lp(b.noise(0.14, rng), 600) * b.env(0.14, 0.003, 0.05)
    spray = grains(0.15, rng, 200, 3000, 9000, 0.002, 0.6, None)
    return fin(b.mix((b.pad(splash, d), 0.9), (b.pad(body, d), 1.0), (b.at(spray, 0.03, d), 0.7)), top=9000)


# ------------------------------------------------------------------ Runde 3 (9.10.)
# Gras soll „grasig streichend“ klingen: längeres Durchstreifen der Halme statt
# kurzem Anschlag. Sand: C (dumpf) war gut, aber heller.
def gras_e(rng, v):
    d = 0.34
    t = b.t_axis(d)
    shape = np.sin(np.pi * np.minimum(t / (d * 0.92), 1)) ** 1.3
    brush = b.sweep_bp(b.noise(d, rng), b.glide(1600 + 120 * v, 4200, d, 0.7), q=1.3) * shape
    blades = grains(d, rng, 380, 3500, 9000, 0.002, 0.6, shape)
    press = b.lp(b.noise(d, rng), 200) * b.env(d, 0.004, 0.03) * 0.5
    return fin(b.mix((brush, 1.0), (blades, 0.6), (press, 0.6)), top=9500)


def gras_f(rng, v):
    d = 0.38
    t = b.t_axis(d)
    # Zwei Streichbewegungen: Fuß hinein (lauter) und wieder heraus (leiser).
    into = np.sin(np.pi * np.clip(t / 0.18, 0, 1)) ** 1.5
    out = np.sin(np.pi * np.clip((t - 0.16) / 0.2, 0, 1)) ** 1.5 * 0.6
    brush_in = b.sweep_bp(b.noise(d, rng), b.glide(2200, 3600, d, 1.0), q=1.6) * into
    brush_out = b.sweep_bp(b.noise(d, rng), b.glide(3800, 2600, d, 1.0), q=1.6) * out
    blades = grains(d, rng, 300, 4000, 9500, 0.002, 0.5, into + out)
    return fin(b.mix((brush_in, 1.0), (brush_out, 0.9), (blades, 0.5)), top=10000)


def sand_e(rng, v):
    d = 0.3
    t = b.t_axis(d)
    shape = np.minimum(t / 0.05, 1) * np.exp(-np.maximum(t - 0.05, 0) / 0.08)
    give = b.lp(b.noise(d, rng), 1500) * shape
    crunch = grains(d, rng, 600, 2500, 7500, 0.003, 0.8, shape)
    hiss = b.bp(b.noise(d, rng), 3500, 8500) * shape * 0.25
    return fin(b.mix((give, 1.0), (crunch, 0.8), (hiss, 0.6)), top=9000)


def sand_f(rng, v):
    d = 0.3
    t = b.t_axis(d)
    shape = np.minimum(t / 0.04, 1) * np.exp(-np.maximum(t - 0.04, 0) / 0.09)
    give = b.lp(b.noise(d, rng), 2200) * shape
    crunch = grains(d, rng, 800, 3000, 9000, 0.0025, 0.9, shape)
    return fin(b.mix((give, 0.9), (crunch, 1.0)), top=10000)


# ------------------------------------------------------------------ Runde 4 (9.10.): Gras
# Vorbild ist das freigegebene Busch-Rascheln: dichtes, leichtes Halmrascheln,
# kein Wusch und kein Aufstampfen. G: kurz und fein, H: etwas länger und voller.
def _halme(rng, d, rise, density, low, high):
    t = b.t_axis(d)
    shape = np.minimum(t / rise, 1) ** 0.8 * np.exp(-np.maximum(t - rise, 0) / (d * 0.32))
    crackle = b.bp(b.noise(d, rng), low, high) * (rng.random(int(SR * d)) > density) * shape
    soft = b.bp(b.noise(d, rng), 1800, 5500) * shape * 0.22
    return crackle, soft


def gras_g(rng, v):
    d = 0.26
    crackle, soft = _halme(rng, d, 0.05, 0.86, 2600, 8500)
    return fin(b.mix((crackle, 1.0), (soft, 0.8)), top=9500)


def gras_h(rng, v):
    d = 0.34
    crackle, soft = _halme(rng, d, 0.08, 0.82, 2000, 7500)
    tail, _ = _halme(rng, d, 0.04, 0.9, 3000, 9000)
    return fin(b.mix((crackle, 1.0), (soft, 1.0), (b.at(tail[: int(SR * 0.2)], 0.12, d), 0.5)), top=9000)


ROUND4 = {"gras": (gras_g, gras_h)}

ROUND3 = {"gras": (gras_e, gras_f), "sand": (sand_e, sand_f)}

ROUND2 = {"gras": (gras_c, gras_d), "pflaster": (pflaster_c, pflaster_d), "holz": (holz_c, holz_d),
          "sand": (sand_c, sand_d), "moor": (moor_c, moor_d)}

SURFACES = {
    "gras": (gras_a, gras_b), "laub": (laub_a, laub_b), "erde": (erde_a, erde_b),
    "pflaster": (pflaster_a, pflaster_b), "holz": (holz_a, holz_b), "stein": (stein_a, stein_b),
    "sand": (sand_a, sand_b), "moor": (moor_a, moor_b), "asche": (asche_a, asche_b),
}


def walk(steps: list) -> np.ndarray:
    """8 Schritte im Lauftempo, leicht unregelmäßig und links/rechts verschieden laut."""
    rng = np.random.default_rng(7)
    total = WALK_INTERVAL * 8 + 0.4
    out = np.zeros(int(total * SR))
    for i in range(8):
        s = steps[i % len(steps)] * (1.0 if i % 2 == 0 else 0.82)
        start = i * WALK_INTERVAL + rng.uniform(-0.012, 0.012)
        i0 = int(max(0, start) * SR)
        out[i0:i0 + len(s)] += s[: len(out) - i0]
    return out


def build(target: Path, round_no: int = 1) -> list:
    written = []
    table, tags = {1: (SURFACES, "ab"), 2: (ROUND2, "cd"), 3: (ROUND3, "ef"), 4: (ROUND4, "gh")}[round_no]
    for surface, recipes in table.items():
        for tag, recipe in zip(tags, recipes):
            steps = []
            for v in range(4):
                rng = np.random.default_rng(zlib.crc32(f"{surface}:{tag}:{v}".encode()))
                x = recipe(rng, v)
                assert np.all(np.isfinite(x)), surface
                steps.append(x)
                path = target / f"{surface}_{tag}_{v + 1:02d}.wav"
                b.write_wav(path, x)
                written.append(path)
            path = target / f"{surface}_{tag}_gang.wav"
            b.write_wav(path, walk(steps))
            written.append(path)
    return written


if __name__ == "__main__":
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "build/footsteps_draft")
    rounds = [n for n in (4, 3, 2) if f"--runde{n}" in sys.argv]
    files = build(out, rounds[0] if rounds else 1)
    print(f"{len(files)} Dateien in {out}")
