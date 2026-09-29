# Sonnenhain Live-Server Vorbereitung

Diese Dateien sind Vorlagen für einen echten, dauerhaft laufenden Game-Server.

## Vorgesehene Architektur

- Website: `https://sonnenhainrpg.de/`
- Browser-Spiel: `https://sonnenhainrpg.de/game/`
- Multiplayer: `wss://sonnenhainrpg.de/multiplayer`
- Godot headless intern: `127.0.0.1:27845`
- 2–4 Spieler pro Session in der ersten Ausbaustufe

## Wichtig

Der derzeitige Spielcode nutzt ENet/UDP für Desktop-Koop. Für Browser-Multiplayer muss der Transport auf WebSocket oder WebRTC umgestellt werden. Die Dateien hier aktivieren deshalb noch keinen öffentlichen Multiplayer-Server.

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
