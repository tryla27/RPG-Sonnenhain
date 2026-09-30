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

Der Produktionsbetrieb ist auf zwei Ebenen abgesichert:

1. **systemd user service** (bevorzugt): `sonnenhain.service` läuft mit
   `Restart=always`. Mit aktiviertem systemd-Linger startet der Dienst auch
   nach einem VServer-Reboot ohne Benutzer-Login.
2. **Cron-Watchdog als Fallback**: Falls Linger nicht verfügbar ist, installiert
   der Deploy automatisch `ensure-sonnenhain-server.sh` als `@reboot`-Job
   und als minütlichen Health-/Restart-Check.

Zusätzlich prüft GitHub Actions den öffentlichen Endpunkt
`wss://multiplayer.sonnenhainrpg.de/` regelmäßig. Bei einem Ausfall wird der
Watchdog per SSH angestoßen und der öffentliche WebSocket-Endpunkt erneut
verifiziert.

Der Godot-Prozess lauscht nur lokal auf `127.0.0.1:27845`; Nginx übernimmt
TLS/WSS. Dadurch müssen Browser und Mobile-Clients ausschließlich
`wss://multiplayer.sonnenhainrpg.de/` verwenden.

Die Serverhost-Version wird bei jedem Server-Build als eigenes GitHub-Artefakt
`sonnenhain-server-host` erzeugt.
