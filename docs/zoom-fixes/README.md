# Zoom: feste Menüs und vollständige Atmosphären

Lokal korrigiert, Veröffentlichung noch offen.

- ESC-Menü und andere Figuren-/Ausrüstungsansichten behalten ihre UI-Größe.
  Nach Figuren und lokalen Zeichenschritten wird die UI-Transformation wiederhergestellt.
- Mausradereignisse gehören entweder zur Weltkamera oder zum geöffneten Menü;
  Loslassen löst keinen zweiten Menü-Scroll aus.
- Dungeon-Dunkelheit und regionale Atmosphäre verwenden die gesamte sichtbare
  Weltfläche bei 100 %, 85 % und 70 %. Nebelwolken verteilen sich mit gleicher
  Dichte über den erweiterten Ausschnitt. Regionengrenzen bleiben berücksichtigt.

Prüfung: Kameraeingabe, HUD, Controller, Gameplay und Halsketten erfolgreich.
Grafischer Vergleich bestätigt pixelgleiche ESC-Schaltflächen bei allen drei
Zoomstufen und vollständige Abdeckung der äußeren Nebel-/Dungeonbereiche.
Web-Export erfolgreich.

- `tests/gameplay/check_camera_zoom.gd`
- `tools/check_zoom_overlays_render.gd` (mit Grafikrenderer ausführen)
