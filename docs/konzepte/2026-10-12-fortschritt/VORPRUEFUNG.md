# Fortschritt – Vorprüfung für Arbeitspaket 2

Stand: 12. Oktober 2026. Codebasis: `1cf5348`. Noch keine Regeländerung umgesetzt. Grundlage ist das bestehende Konzept vom 11. Oktober; die Umsetzung folgt nach den wichtigeren Einstiegspunkten.

## Bestätigte Stellen

| Bereich | Befund | Folgerung |
|---|---|---|
| `main.gd`, `xp_required()` und `gain_xp()` | Kein fester Level-40-Stopp im normalen XP-Aufstieg; bisher quadratische XP-Kurve | Gemeinsame Regel einführen, bisherigen Verlauf bis Aufstieg auf 100 erhalten |
| `components/essence_system.gd`, `MAX_LEVEL`, `total_for_level()`, `network_ranks()` | Essenz und Netzwerkvalidierung auf 40 begrenzt | Fortschrittsbudget und Netzwerkvalidierung gemeinsam ändern, ausgegebene Ränge erhalten |
| `main.gd`, `apply_save_data()` | Testlevel auf 40 begrenzt | Testmodus und Laden konsistent an die neue Regel anbinden |
| `main.gd`, Spielerzustands-/Angriffsvalidierung | Mehrere Klemmen auf 99, unter anderem für Level, Runen und Schadensgrenzen | Server und Client müssen dieselben zulässigen Werte und Berechnungen verwenden |
| `components/server_save_store.gd`, `valid_data()` | XP muss numerisch sein, endlich und höchstens 2.147.483.647 | Alte Zahlen akzeptieren; neue große XP-Werte exakt und begrenzt validieren, bevor unbegrenzte Aufstiege aktiviert werden |
| `components/local_save_store.gd` / Server-JSON | JSON-Laden verwendet numerische Werte; große Zahlen benötigen eine exakte Darstellung | Dezimaltext oder explizite Ganzzahlblöcke prüfen, keine ungenauen Fließkomma-XP oder überlaufenden int-Werte |
| `main.gd`, `refresh_shop_stock()`; `components/shop_rotation.gd` | Rotation und behaltene Angebote sind bereits vorhanden | Neue Angebote am Käuferlevel erzeugen; alte Identität und Preis erhalten; Charakterwechsel und Relog prüfen |

## Größenordnung der vereinbarten XP-Auslegung

Das bestehende Konzept interpretiert den Wunsch so: 99 → 100 kostet 104.490 XP; 100 → 101 kostet viermal so viel, danach vervierfacht sich jeder weitere Aufstieg. Formel ab aktueller Stufe L ≥ 100: `417960 × 4^(L−100)`.

- 106 → 107 benötigt 1.711.964.160 XP, 107 → 108 bereits 6.847.856.640 XP.
- Ab 107 → 108 übersteigt der Bedarf die bisherige XP-Grenze des Servers. Schon vor Erreichen des Aufstiegs kann ein wachsender XP-Spielstand nicht mehr akzeptiert werden.
- 123 → 124 benötigt 29.411.320.316.496.445.440 XP und überschreitet damit auch eine vorzeichenbehaftete 64-Bit-Ganzzahl. Ein großer XP-Bedarf darf nicht zu negativen Werten oder kostenfreien Aufstiegen führen.

## Umsetzungsreihenfolge

1. Exakte große XP-Werte und gemeinsames Fortschrittsmodul festlegen; Migration alter Zahlen, Eingabegrößen und beschädigte Werte prüfen.
2. Aufstieg, Anzeigen, Speichern und serverseitige Validierung auf denselben Pfad umstellen.
3. Levelgrenzen im Testmodus, Runen-/Essenzbudget und Kampfvalidierung vereinheitlichen. Bisherige Investitionen bleiben erhalten; ausgereizte Talentbäume erhalten nicht automatisch zusätzliche Talentränge.
4. Händlerübergänge und neue Angebote prüfen, ohne bestehende Angebote nachträglich zu verteuern.
5. Verhalten an 40/41/99/100/101 und an großen gespeicherten XP-Werten, Relog und Koop testen; geänderte Balance in Patch Notes und PR ausdrücklich nennen.

Kein automatischer Live-Gang. Dieses Dokument hält Befunde fest; Zahlenrepräsentation und die endgültigen Grenzen werden im Implementierungsentwurf konkretisiert.
