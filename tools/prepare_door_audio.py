"""Prepare generated dry door foley for in-game playback; preserve source MP3s."""
from pathlib import Path
import sys
import json
import numpy as np

root = Path(__file__).resolve().parents[1]
dependency_path = root / '.cache' / 'audio-python'
if dependency_path.exists():
    sys.path.insert(0, str(dependency_path))
import soundfile as sf

report = {}
for action in ('open', 'close'):
    samples, rate = sf.read(root / 'audio' / 'source-v2' / f'door_{action}.mp3', always_2d=True)
    mono = samples.mean(axis=1)
    assert np.isfinite(mono).all() and len(mono) > rate // 4
    peak = float(np.max(np.abs(mono)))
    assert peak > 0.01, 'Silent source'
    active = np.flatnonzero(np.abs(mono) > peak * 0.008)
    start = max(0, int(active[0]) - int(rate * 0.008))
    end = min(len(mono), int(active[-1]) + int(rate * 0.035))
    mono = mono[start:end].copy()
    mono -= mono.mean()
    fade_in = min(int(rate * 0.003), len(mono) // 8)
    fade_out = min(int(rate * 0.025), len(mono) // 8)
    mono[:fade_in] *= np.linspace(0, 1, fade_in)
    mono[-fade_out:] *= np.linspace(1, 0, fade_out)
    mono *= 10 ** (-4 / 20) / np.max(np.abs(mono))
    target = root / 'audio' / f'door_{action}_v2.wav'
    sf.write(target, mono, rate, subtype='PCM_16')
    checked, checked_rate = sf.read(target)
    assert checked_rate == rate and np.max(np.abs(checked)) < 0.7
    assert checked[0] == 0 and checked[-1] == 0
    report[action] = {
        'seconds': round(len(checked) / rate, 3), 'sample_rate': rate,
        'peak_dbfs': round(20 * np.log10(np.max(np.abs(checked))), 2),
        'rms_dbfs': round(20 * np.log10(np.sqrt(np.mean(checked ** 2))), 2),
        'clipped_samples': int(np.count_nonzero(np.abs(checked) >= 0.999)),
    }
print(json.dumps(report))
