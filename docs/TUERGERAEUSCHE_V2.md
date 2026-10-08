# Türgeräusche v2

Erstellt mit dem Runway-Soundeffekt-Werkzeug für die Holzhaustüren von Sonnenhain. Keine Musik und keine Stimmen. Originale bleiben in `audio/source-v2/`; das Spiel verwendet `audio/door_open_v2.wav` und `audio/door_close_v2.wav`. Rohdateien sind durch `.gdignore` vom Godot-Export ausgeschlossen.

## Bildunabhängige Klangbeschreibungen

Öffnen: Single close-miked foley of a sturdy medieval oak door opening: one small iron latch clicks, followed immediately by a short natural wooden hinge creak as the heavy door swings open, gently settling. Warm dry intimate sound, no metallic squeal, no scary atmosphere, no room ambience, no music, no voices, no repeated actions. Clean game interaction sound; action begins immediately.

Schließen: Single close-miked foley of a sturdy medieval oak door closing gently but firmly: a very brief wooden hinge movement, then a warm low wooden thud as the thick door meets its frame, immediately followed by a small iron latch clicking into place. Dry compact intimate sound, natural wood resonance, no loud slam, no metallic squeal, no scary atmosphere, no ambience, no music or voices. One action only, begins immediately.

## Aufbereitung und technische Prüfung

Mono, 44.100 Hz, 16-Bit-PCM. Vorlaufstille entfernt, kurzer Ein-/Ausblendrand gegen digitale Klicks, Spitzenpegel −4 dBFS, keine geclippten Samples. Öffnen 0,883 s; Schließen 0,543 s. Im Spiel gilt weiter die vorhandene Effekte-Lautstärke. `tools/prepare_door_audio.py` reproduziert die Aufbereitung mit NumPy und SoundFile.

Diese Messungen belegen Dateiintegrität und Pegel, keine hörende Klangabnahme. Die Hörproben sind für Nutzerfeedback verfügbar.
