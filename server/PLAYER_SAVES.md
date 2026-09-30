# Spielstände auf dem Server

Normale Charaktere synchronisieren Inventar, Ausrüstung (einschließlich zweitem Magierring), Quests, Fortschritt, Werte und sichere Weltposition mit dem Dedicated Server. Änderungen werden direkt angefordert; zusätzlich erfolgt alle fünf Sekunden ein Snapshot. Testmodus und Vorschau werden nicht hochgeladen.

Der Client zeigt den Zustand unter dem Questziel. Nur eine bestätigte, auf die Festplatte geschriebene Revision zählt als Server gespeichert. Bei Verbindungsverlust bleibt eine lokale Wiederherstellung erhalten. Erneute Anfragen sind idempotent; veraltete Revisionen überschreiben keine neueren Daten. Zwei Fenster dürfen denselben Charakter nicht gleichzeitig schreiben.

Die Dateien liegen dauerhaft außerhalb des Release-Verzeichnisses in ~/sonnenhain-server/data/player-saves. --save-dir= überschreibt den Pfad für isolierte Tests. Jede Datei besitzt eine Prüfsumme und eine Sicherung der vorherigen Generation. Beschädigte Dateien werden nicht blind überschrieben. Dieses Verzeichnis regelmäßig extern sichern; beide Generationen berücksichtigen.

Jeder Charakter erhält einen zufälligen privaten Zugriffsschlüssel. Er bleibt im lokalen Spielstand und im exportierten Backup, wird nicht in der öffentlichen Spieler-Präsenz gesendet und dient dem Abruf des Serverstands. Für einen anderen Browser oder Rechner das bestehende Backup importieren. Es gibt noch keine Kontoanmeldung oder Wiederherstellung eines verlorenen Zugriffsschlüssels. Backups deshalb privat aufbewahren.

Snapshots werden auf Struktur und Grenzen geprüft. Dies ist sichere Persistenz des bestehenden Spiels; die bisherigen clientseitigen Inventar- und Progressionsregeln sind keine vollständige serverseitige Cheat-Prüfung.

Automatische Tests prüfen Ringslots, dauerhafte Speicherung, doppelte und veraltete Anfragen, fremde Identitäten, ungültige Daten, Dateibeschädigung, Sicherungsrückfall, Schreibfehler und reale WebSocket-Kommunikation einschließlich Wiederverbindung und Serverneustart.
