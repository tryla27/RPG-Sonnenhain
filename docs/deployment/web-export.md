# Sonnenhain im Browser hosten

Das Projekt enthält ein vorbereitetes Godot-Web-Exportprofil. Der Browserexport ist ein statisches Paket und kann nach dem Export auf einer Domain bzw. einem statischen Webhost abgelegt werden.

## Export

1. Das Projekt in **Godot 4.3 oder neuer** öffnen.
2. Unter **Editor → Manage Export Templates** die Exportvorlagen für genau diese Godot-Version installieren.
3. **Projekt → Exportieren → Web → Export Project** wählen.
4. Als Ziel `build/web/index.html` verwenden. Godot erzeugt dazugehörige `.wasm`, `.pck` und JavaScript-Dateien.
5. Den gesamten Inhalt von `build/web/` zusammen auf den Webhost laden. Nicht nur die HTML-Datei hochladen.

Der Webhost muss Dateien über HTTPS ausliefern und die Standard-MIME-Typen für HTML, JavaScript, WebAssembly (`application/wasm`) und binäre Dateien bereitstellen. Das Spiel nutzt lokale Browser-Speicherstände; ein Deploy auf der Domain speichert jeden Spielstand im Browser des jeweiligen Spielers.

## Koop-Hinweis

Der vorhandene Koop-Modus nutzt Godot ENet über UDP. Browser können diesen Transport nicht verwenden. Deshalb ist Koop im Webexport deaktiviert und das Menü verweist auf den Windows-Build. Für Koop im Browser wäre ein separater WebSocket-Relay-Dienst nötig; die gekaufte Domain allein stellt diesen Server nicht bereit.

## Build-Status dieser Lieferung

Das Exportprofil und diese Anleitung liegen im Projekt. Ein fertiges `index.html`-Build benötigt Godots Web-Exportvorlagen; in der aktuellen Arbeitsumgebung ist kein Godot-Editor bzw. Exportprogramm installiert. Nach Installation der Vorlagen kann der Export direkt über das Profil **Web** erstellt werden.
