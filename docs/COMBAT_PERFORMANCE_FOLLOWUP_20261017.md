# Kampfleistung: Weiterarbeit nach PR #136 · 17.10.2026

Arbeitsbasis: `e572894` auf `main`, nach dem von Claude ergänzten und
zusammengeführten PR #136. Der ursprüngliche lokale Checkout auf C: bleibt
erhalten. Das Folgepaket entsteht in einem eigenen Checkout und Branch.
Für dieses Folgepaket wurde keine Live-Schaltung ausgelöst.

## Vollständige Browser-Prüfroute

Bei der Übernahme fiel eine Abweichung im Browser-Messwerkzeug auf:
`web_benchmark.gd` startete bei Bild −30 und beendete jede Route bereits bei
210. Dadurch fehlten die letzten 30 Bilder des Rückwegs. Außerdem wurde
der Bericht vor Abschluss des zuletzt eingeplanten Bildes geschrieben.
Der native Vergleich fährt dagegen die vollständigen Bilder 0 bis 239.

Die Browserprüfung fährt nun dieselben 240 Bilder und wertet die vollständig
abgeschlossenen Bilder 30 bis 239 aus. Pro Route bleiben 210 Messwerte.
Berichte erhalten `schema: 2`, `frames_per_route: 240` und
`discarded_frames: 30`. Mindest-, Höchst- und mittlere Gegnerzahl stehen
ebenfalls im Bericht, damit ein leerer Abschnitt nicht versehentlich als
beschleunigter Kampf ausgegeben wird.

Die älteren Browser-Vorher-/Nachherwerte beziehen sich auf den damaligen
verkürzten Ablauf. Vergleiche mit dem neuen Bericht brauchen einen neuen
Ausgangslauf mit derselben vollständigen Route. Diese Korrektur verändert
keine normale Spielführung, Wegsuche, Gegnerzahlen oder Kampfregeln.

Verhaltenstest: `tests/rendering/check_web_benchmark_route.gd` prüft alle
vier Routen einschließlich Aufwärmrunde, die 240 Positionen der Wiesenroute,
den vollständigen Rückweg, den Abschluss erst nach dem letzten Bild und
die Gegnerzählung im gesonderten Kampfmodus.

## Waldgegner: unbenutzte Posenberechnung vermeiden

`woodland_mob_art.gd` berechnete bei jedem Zeichnen zunächst eine prozedurale
Pose. Bei vorhandenen Animationsbildern wurde diese sofort überschrieben;
beim geschmeidigen Schleim wurde sie überhaupt nicht verwendet.
Die Berechnung findet jetzt ausschließlich im tatsächlichen Rückfallpfad
statt. Das Aufwärmen der Animationsbilder über die Verfügbarkeitsprüfung
bleibt erhalten, damit der erste Angriff keinen zusätzlichen Import verschiebt.

GPU-Bildvergleich: vier Waldgegner, acht Blickrichtungen und fünf Zustände
(Stehen, Laufen, Angriff, Treffer, Niederlage), insgesamt 160 Posen. Vorher
und nachher sind auf der RTX 3060 alle 10.485.760 Farbkanäle identisch.
[Vergleichsdaten](design/combat-followup/woodland-comparison.json),
[vorher](design/combat-followup/woodland-before.png),
[nachher](design/combat-followup/woodland-after.png).

Die native gemischte Szene mit 25 Gegnern ergab in einzelnen lokalen Läufen
rund 2,9 ms Gegnerzeichnen vorher und 2,8 ms nachher. Das ist kein belastbarer
Nachweis einer Gesamtbeschleunigung und keine neue FPS-Zusage. Die Prüfsumme
der Gegnerpositionen und Angriffszustände blieb gleich. Die großen Gewinne
aus PR #136 werden diesem kleinen Folgepaket nicht erneut zugeschrieben.

## Wiederholen

Die Referenz für den Bildvergleich lässt sich aus dem Ausgangscommit holen.
Beispiel PowerShell im Projektordner, mit Godot 4.7.2:

```powershell
New-Item -ItemType Directory -Force build | Out-Null
git show e572894:components/woodland_mob_art.gd | Set-Content -Encoding utf8 build/woodland_mob_art_before.gd
& $godotBin --path . --script res://tools/compare_woodland_render.gd -- res://build/woodland_mob_art_before.gd
& $godotBin --headless --path . --script res://tests/rendering/check_web_benchmark_route.gd
```

Für neue Browsermessungen Webexport lokal mit `tools/web_bench_server.py`
ausliefern und `index.html?bench=1` oder `index.html?bench=1&ai=1` öffnen.
Browser, Auflösung, Zoom, GPU, Gegnerzahlen, Schema und parallele Last
festhalten. Die sichtbare Spielausgabe und ein fertiger JSON-Bericht ersetzen
keinen Live-Koop-Test.

## Abgeschlossene Prüfungen

- Vollständige Windows-Prüfauswahl einschließlich Inhaltsprüfung: **151
  bestanden, 0 fehlgeschlagen**. Import und Webexport erfolgreich.
- GPU-Bildvergleich nach der abschließenden Änderung erneut identisch:
  160 Posen, kein abweichender Farbkanal.
- Vollständiger Kampf-Browserlauf in Chromium 155 im sichtbaren App-Browser,
  RTX 3060, gemeldeter Spiel-Viewport 1152 × 648. Alle vier Routen meldeten
  je 210 abgeschlossene Messbilder; `schema: 2`, `variant: ai`.
  [JSON-Bericht](design/combat-followup/browser-ai-schema2.json),
  [abgeschlossene Vorschau](design/combat-followup/browser-ai-finished.jpg).

| Route | Gegner min–max | P50 | P95 | P99 | Bilder > 50 ms |
|---|---|---:|---:|---:|---:|
| Wiese | 25–25 | 20,65 ms | 26,67 ms | 32,84 ms | 0 |
| Mauertor | 1–2 | 16,66 ms | 17,07 ms | 24,79 ms | 1 |
| Pilzwald | 5–6 | 16,49 ms | 29,05 ms | 43,64 ms | 1 |

Dies ist eine aktuelle Zustandsmessung, kein kontrollierter Vorher-/Nachher-
Nachweis für die kleine Posenbereinigung. Die unterschiedlichen Gegnerzahlen
verbieten es, die drei Routen als denselben Kampf zu vergleichen. Brave,
Edge und Live-Koop wurden in diesem Folgepaket nicht erneut geprüft.
