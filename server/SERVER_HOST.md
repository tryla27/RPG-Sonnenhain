# Sonnenhain Dedicated Server Host

Dies ist die eigenständige **Serverhost-Version** von Sonnenhain. Sie enthält
keine Spieleroberfläche und läuft headless auf Linux x86_64.

## Start

```bash
chmod +x sonnenhain-server.x86_64 start-server.sh
./start-server.sh
```

Intern lauscht der Godot-Server auf `127.0.0.1:27845`.

Für den öffentlichen Livebetrieb wird der Dienst über Nginx als
`wss://multiplayer.sonnenhainrpg.de/` bereitgestellt.

## Dauerbetrieb

Bevorzugt wird `sonnenhain.service` mit systemd und `Restart=always`.
Falls für den Deploy-Benutzer kein systemd-Linger verfügbar ist, kann
`ensure-sonnenhain-server.sh` als Watchdog verwendet werden.

Die Serverhost-Version wird bei jedem Server-Build als eigenes GitHub-Artefakt
`sonnenhain-server-host` erzeugt.
