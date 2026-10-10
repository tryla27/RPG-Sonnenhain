# Bestätigte Golem-Musik

Angelo hat am 10.10.2026 den Loop aus den ersten 24 Sekunden der letzten
Probe bestätigt. `../../boss_golem.wav` enthält genau diese Aufnahme,
fünfmal wiederholt: 120 Sekunden, 160 BPM. Nur die jeweils 3 ms an den
24-Sekunden-Grenzen sind zur Vermeidung von Knackern geglättet.

- `approved_first24.wav`: bestätigter Ausschnitt vor Grenzglättung.
- `repeat_first24.py`: baut die Spieldatei mit NumPy und Python neu.
- `compose_2min_v8.py`: bearbeitbare ursprüngliche Synthese mit Noten,
  Akkorden, Instrumenten und Aufbau; erzeugt die ältere vollständige Probe.
  Für die bestätigte Fassung ausschließlich die ersten 24 Sekunden verwenden.
- `validation.json`: technische Prüfung der bestätigten Fassung.

Die ersten zwölf Sekunden spielen das Bossmotiv mit ruhigem Bass. Ab
Sekunde zwölf kommen Hardtekk-Bass und Snare dazu. Nach 24 Sekunden beginnt
derselbe Abschnitt wieder; keine zusätzlichen Melodien oder Hooks.

Die Einblendung wird zur Laufzeit in `components/music_playback.gd`
gesteuert: beim Erscheinen des Golems über sechs Sekunden auf die eingestellte
Musiklautstärke. Kein Fade-out in der Audiodatei. Die vorhandene Erkennung
berücksichtigt auch die beiden Golem-Hälften und die Nähe zum Kampf.

Technisch geprüft: Dateilänge, fünf identische Abschnitte, Pegel und
Wellenformanschluss. Eine hörende Prüfung wird damit nicht behauptet.
