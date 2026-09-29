# Sonnenhain Live-Server Vorbereitung

Diese Dateien sind Vorlagen für einen echten, dauerhaft laufenden Game-Server.

## Vorgesehene Architektur

- Website: `https://sonnenhainrpg.de/`
- Browser-Spiel: `https://sonnenhainrpg.de/game/`
- Multiplayer: `wss://multiplayer.sonnenhainrpg.de/`
- Godot headless intern: `127.0.0.1:27845`
- 2–4 Spieler pro Session in der ersten Ausbaustufe

## Wichtig

Der Browser-Livepfad nutzt WebSocket. Der Dedicated Server lauscht intern auf `127.0.0.1:27845`; ein Reverse Proxy stellt ihn als `wss://multiplayer.sonnenhainrpg.de/` bereit.

Vor Aktivierung müssen die Punkte aus `MULTIPLAYER_AUDIT.md` abgearbeitet werden, insbesondere:

- Dedicated-Server-Spielzustand pro Peer
- Enemy-Targeting auf echte Spieler
- serverautoritatives Combat
- serverseitige Cooldown-/Skillvalidierung
- synchronisierte Drops/Quests/Weltzustände
- Reconnect/Disconnect-Handling

## Serveranforderungen

Für den finalen Live-Server wird ein Zugang benötigt, der mindestens Folgendes erlaubt:

- dauerhaft laufender Prozess
- eigener TCP-Port auf localhost
- Reverse Proxy / WebSocket Upgrade
- Autostart per systemd, supervisord oder vergleichbar

Der GitHub-Deploy prüft den aktuellen Manitu-SSH-Zugang auf verfügbare Serverfunktionen. Falls der Zugang nur klassischer Webspace ist, bleibt die Website dort und der Game-Server läuft auf einem separaten VPS.


## Live-Schaltung

Für den echten VServer werden in GitHub Actions benötigt:

- `VSERVER_HOST`: Hostname oder IP des VServers
- `VSERVER_USER`: SSH-Benutzer
- `VSERVER_SSH_KEY`: privater Deploy-Key, als OpenSSH-Key oder Base64
- `VSERVER_PORT`: optional, Standard 22

Zusätzlich muss DNS `multiplayer.sonnenhainrpg.de` auf den VServer zeigen. Auf dem VServer muss Nginx (oder ein gleichwertiger Reverse Proxy) Port 443 bedienen und zu `127.0.0.1:27845` weiterleiten. Die Vorlage liegt in `server/nginx-multiplayer.conf.example`.

Der GitHub-Workflow prüft nach einem Deploy, ob der Serverprozess läuft und ob TCP-Port 27845 lauscht.
