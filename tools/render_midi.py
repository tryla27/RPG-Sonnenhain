"""Render the supplied standard MIDI compositions to portable 22.05 kHz WAV.

This small built-in synthesizer keeps the notes, tempo and channel dynamics.
It does not require a system soundfont; timbres are approximate GM families.
Run: python3 tools/render_midi.py input.mid output.wav
"""
import math
import struct
import sys
import wave
from collections import defaultdict
from pathlib import Path

import numpy as np

RATE = 22050


def variable(data, pos):
    value = 0
    while True:
        byte = data[pos]
        pos += 1
        value = (value << 7) | (byte & 127)
        if byte < 128:
            return value, pos


def read_midi(path):
    data = Path(path).read_bytes()
    if data[:4] != b"MThd":
        raise ValueError("Not a standard MIDI file")
    header_size = int.from_bytes(data[4:8], "big")
    _, tracks, division = struct.unpack(">HHH", data[8:14])
    if division & 0x8000:
        raise ValueError("SMPTE timebase unsupported")
    pos = 8 + header_size
    events = []
    for track in range(tracks):
        if data[pos:pos + 4] != b"MTrk":
            raise ValueError(f"Missing track {track}")
        size = int.from_bytes(data[pos + 4:pos + 8], "big")
        pos += 8
        end = pos + size
        tick, running = 0, None
        while pos < end:
            delta, pos = variable(data, pos)
            tick += delta
            status = data[pos]
            if status & 0x80:
                pos += 1
                if status < 0xF0:
                    running = status
            else:
                if running is None:
                    raise ValueError("Running status without previous event")
                status = running
            if status == 0xFF:
                kind = data[pos]
                pos += 1
                count, pos = variable(data, pos)
                payload = data[pos:pos + count]
                pos += count
                if kind == 0x51 and count == 3:
                    events.append((tick, 0, track, "tempo", int.from_bytes(payload, "big")))
            elif status in (0xF0, 0xF7):
                count, pos = variable(data, pos)
                pos += count
            else:
                kind, channel = status & 0xF0, status & 0x0F
                count = 1 if kind in (0xC0, 0xD0) else 2
                args = data[pos:pos + count]
                pos += count
                if kind in (0x80, 0x90, 0xB0, 0xC0):
                    events.append((tick, 1, track, kind, channel, *args))
        pos = end
    events.sort(key=lambda e: (e[0], e[1], e[2]))
    tempo, last_tick, seconds = 500000, 0, 0.0
    timed = []
    for event in events:
        seconds += (event[0] - last_tick) * tempo / (division * 1000000)
        last_tick = event[0]
        if event[3] == "tempo":
            tempo = event[4]
        else:
            timed.append((seconds, *event[3:]))
    return timed


def notes_from_events(events):
    active = defaultdict(list)
    program = [0] * 16
    volume = [1.0] * 16
    expression = [1.0] * 16
    pan = [0.5] * 16
    notes = []
    last_time = 0.0
    for timestamp, kind, channel, *args in events:
        last_time = max(last_time, timestamp)
        if kind == 0xC0:
            program[channel] = args[0]
        elif kind == 0xB0:
            control, value = args
            if control == 7:
                volume[channel] = value / 127
            elif control == 11:
                expression[channel] = value / 127
            elif control == 10:
                pan[channel] = value / 127
        elif kind == 0x90 and args[1] > 0:
            pitch, velocity = args
            active[channel, pitch].append((timestamp, velocity, program[channel], volume[channel] * expression[channel], pan[channel]))
        elif kind in (0x80, 0x90):
            pitch = args[0]
            if active[channel, pitch]:
                start, velocity, patch, level, position = active[channel, pitch].pop(0)
                duration = max(0.05, timestamp - start)
                notes.append((start, duration, channel, pitch, velocity, patch, level, position))
    for (channel, pitch), stack in active.items():
        for start, velocity, patch, level, position in stack:
            notes.append((start, min(2.0, last_time - start), channel, pitch, velocity, patch, level, position))
    return notes


def synth_note(pitch, seconds, patch, drum, velocity):
    count = max(1, int(seconds * RATE))
    t = np.arange(count, dtype=np.float32) / RATE
    freq = 440 * 2 ** ((pitch - 69) / 12)
    if drum:
        rng = np.random.default_rng(pitch * 113 + count)
        noise = rng.standard_normal(count).astype(np.float32)
        if pitch < 48:
            tone = np.sin(2 * math.pi * (freq * 0.65 * t - 0.12 * t * t))
            sound = tone * 0.65 + noise * 0.25
            env = np.exp(-t * 20)
        else:
            sound = noise * 0.6 + np.sin(2 * math.pi * freq * t) * 0.15
            env = np.exp(-t * 35)
    else:
        family = patch // 8
        phase = 2 * math.pi * freq * t
        if family in (0, 1, 10):
            sound = np.sin(phase) + 0.34 * np.sin(phase * 2) + 0.17 * np.sin(phase * 3)
            env = np.exp(-t * (1.2 if family == 0 else 2.0))
        elif family in (5, 6, 11):
            vibrato = 0.004 * np.sin(2 * math.pi * 5.0 * t)
            sound = np.sin(phase * (1 + vibrato)) + 0.19 * np.sin(phase * 2)
            env = np.minimum(1, t * 35) * np.exp(-t * 0.27)
        elif family in (8, 9, 12, 13):
            sound = np.sin(phase) + 0.24 * np.sin(phase * 3) + 0.12 * np.sin(phase * 5)
            env = np.minimum(1, t * 40) * np.exp(-t * 0.32)
        elif family in (2, 3):
            sound = np.sin(phase) + 0.22 * np.sin(phase * 2)
            env = np.minimum(1, t * 70) * np.exp(-t * 0.52)
        else:
            sound = np.sin(phase) + 0.21 * np.sin(phase * 2) + 0.11 * np.sin(phase * 4)
            env = np.minimum(1, t * 60) * np.exp(-t * 0.7)
    release = min(count, int(RATE * (0.08 if drum else 0.2)))
    env[-release:] *= np.linspace(1, 0, release, dtype=np.float32)
    return (sound * env * ((velocity / 127) ** 1.4)).astype(np.float32)


def render(input_path, output_path):
    notes = notes_from_events(read_midi(input_path))
    duration = max((start + length for start, length, *_ in notes), default=0) + 0.5
    left = np.zeros(int(duration * RATE), dtype=np.float32)
    right = np.zeros_like(left)
    print(f"{Path(input_path).name}: {len(notes)} notes, {duration:.1f}s", flush=True)
    for start, length, channel, pitch, velocity, patch, level, position in notes:
        waveform = synth_note(pitch, min(length + 0.14, 7.0), patch, channel == 9, velocity)
        first = int(start * RATE)
        last = min(len(left), first + len(waveform))
        if last <= first:
            continue
        gain = 0.075 * level
        left[first:last] += waveform[:last - first] * gain * math.sqrt(1.0 - position * 0.7)
        right[first:last] += waveform[:last - first] * gain * math.sqrt(0.3 + position * 0.7)
    # Very small hall reflections make long pad notes blend without obscuring attacks.
    for delay, gain in ((0.11, 0.08), (0.23, 0.05)):
        samples = int(RATE * delay)
        left[samples:] += right[:-samples] * gain
        right[samples:] += left[:-samples] * gain
    peak = max(float(np.max(np.abs(left))), float(np.max(np.abs(right))), 0.001)
    master = min(1.0, 0.89 / peak)
    stereo = np.column_stack((np.tanh(left * master), np.tanh(right * master)))
    pcm = (stereo * 32767).astype('<i2')
    with wave.open(str(output_path), 'wb') as out:
        out.setnchannels(2)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(pcm.tobytes())


if __name__ == '__main__':
    render(sys.argv[1], sys.argv[2])
