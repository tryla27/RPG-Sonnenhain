# Sonnenhain Multiplayer / Live-Server Audit

Stand: 2026-09-29

## Zielbild

- Website auf sonnenhainrpg.de
- Browser-Spiel unter /game/
- PC: Tastatur + Maus
- Mobile Browser: Touch-Steuerung
- Online-Echtzeitspiel über einen dedizierten Server
- Kein Portforwarding beim Spieler nötig

## Aktueller Multiplayer-Stand

Der bestehende Koop verwendet Godot ENet über UDP Port 27844. Das funktioniert grundsätzlich für Desktop-Clients, ist aber nicht als Browser-Transport geeignet. Der Browser-Build ist deshalb aktuell absichtlich Singleplayer.

## Erkannte Probleme vor einem öffentlichen Live-Betrieb

1. **Browser-Kompatibilität**
   - ENet/UDP kann vom Godot-Webexport nicht direkt als normaler Browser-Transport verwendet werden.
   - Für Browser + Desktop gemeinsam ist ein WebSocket-/WebRTC-Transport nötig.

2. **Kein echter Dedicated-Server-Modus**
   - Der aktuelle Host ist gleichzeitig Spieler.
   - Gegner-KI zielt auf `player_pos` des Hosts.
   - Ein unsichtbarer headless Host wäre deshalb kein korrekter Spielserver.

3. **Client vertraut zu stark / Servervalidierung fehlt**
   - `rpc_player_state` übernimmt Position, Klasse, Level, Waffe und weitere Daten vom Client.
   - `rpc_client_normal_attack` akzeptiert vom Client Position, Klasse, Waffendesign, Schaden und Element.
   - `rpc_client_ability` akzeptiert vom Client Fähigkeit, Position, Schaden und Rang.
   - Ein veränderter Client könnte dadurch teleportieren oder unrealistische Schadenswerte senden.

4. **Fortschritt und Loot sind nicht sauber pro Spieler autoritativ**
   - Gegnersterben, XP, Questfortschritt und Drops laufen in großen Teilen im Host-Spielzustand.
   - Für einen dedizierten Server braucht jeder Peer eine eigene serverseitige Spieler-/Inventar-/Quest-Sicht.

5. **Enemy-Targeting ist nicht multiplayerfähig genug**
   - Gegner verwenden derzeit primär die lokale Hostposition als Ziel.
   - Nötig: nächster gültiger Spieler, Aggro-/Target-ID und serverseitige Zielwahl.

6. **Gegnerprojektile / Schaden**
   - Projektilkollisionen prüfen lokal gegen `player_pos`.
   - Für Dedicated Multiplayer muss der Server Treffer gegen jeden Spieler berechnen und Schaden gezielt an diesen Peer senden.

7. **World Snapshot unvollständig**
   - Synchronisiert werden derzeit hauptsächlich Gegner und Gegnerprojektile.
   - Drops, Weltzustände, Bosse, Events, temporäre Zonen und weitere relevante Zustände sind nicht vollständig abgedeckt.

8. **Snapshot-Takt**
   - Der Snapshot-Takt hängt indirekt an `world_time` und dem Player-State-Intervall.
   - Besser: eigener fester Server-Tick und definierte Snapshot-Rate.

9. **NAT / Einladungscode**
   - Aktuelle Desktop-Hostlösung setzt auf UPnP oder direkte IP.
   - Ein zentraler Server beseitigt Portforwarding beim Spieler und sollte feste Serveradressen statt Host-IP-Codes verwenden.

## Empfohlene Zielarchitektur

### Transport
- Browser + Desktop: WebSocket Secure (WSS) über `wss://sonnenhainrpg.de/multiplayer`.
- Reverse Proxy: HTTPS/WSS auf Port 443 zum lokalen Godot-Serverport.
- Optional ENet nur für lokale/Legacy-Desktop-Sessions behalten.

### Server
- Headless Godot 4.3 Serverprozess.
- Server ist Multiplayer Authority.
- Server verwaltet:
  - Spielerpositionen und erlaubte Geschwindigkeit
  - Gegner/KI
  - Treffer und Schaden
  - Cooldowns und Fähigkeiten
  - Drops
  - relevante Weltzustände
- Clients senden Eingaben/Absichten statt fertiger Schadenswerte.

### Sicherheitsregeln
- Positionen auf maximale Bewegung pro Tick prüfen.
- Schaden immer serverseitig berechnen.
- Fähigkeiten, Cooldowns und Skillränge serverseitig validieren.
- Chat-Länge und Rate begrenzen.
- RPC-Sender-ID immer gegen zugehörigen Spielerzustand prüfen.
- Verbindungs-/Session-Limits setzen.

## Reihenfolge zur Umsetzung

1. Web-/SSH-Deploy stabilisieren.
2. Prüfen, ob der Manitu-Zugang dauerhafte Prozesse und Ports erlaubt.
3. Falls ja: Headless-Server dort vorbereiten. Falls nein: separaten echten VPS/Cloud-Server für den Game-Server verwenden.
4. Server-State-Struktur pro Peer einführen.
5. WebSocket-Transport implementieren.
6. Gegner-KI auf mehrere Spieler umbauen.
7. Kampf-RPCs serverautoritativ machen.
8. Loot/Quests pro Spieler synchronisieren.
9. WSS-Reverse-Proxy + Service-Autostart.
10. Last-/Reconnect-/Disconnect-Tests mit 2–4 Spielern.
