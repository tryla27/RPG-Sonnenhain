# Sonnenhain – Fusionssystem

## Autoritative Grundregel

Eine Fusion darf niemals den Charakter ihrer Ausgangsfähigkeiten ersetzen. Sie muss beide Fähigkeiten sichtbar, spielerisch und akustisch weiterführen und daraus genau **eine** zusätzliche Synergie erzeugen.

## Identität

Jede Kombination besitzt einen normalisierten Schlüssel:

`fusion_key = min(source_a, source_b) + ":" + max(source_a, source_b)`

Damit sind `17:18` und `18:17` dieselbe Fusion. Save und Multiplayer speichern bzw. prüfen Key, Ergebnis-ID und Rang serverseitig.

## Zulässige Zutaten

Phase 1 verwendet 33 aktive Grundskills. Ausgeschlossen sind:

- Passives: 9, 10, 11
- Ultimates/Klassenfähigkeiten: 15, 24, 33
- reine Bewegung: 27
- bestehende Fusionsoutputs: 40–43

Die Runtime-Regel steht in `components/fusion_rules.gd`.

## Position des Sekundäreffekts (verbindlich seit 9.10.2026)

Fusionseffekte zünden **immer am Trefferpunkt, nie beim Spieler**
(Konzept `docs/konzepte/2026-10-09/KONZEPT.md`, D1). Umsetzung:
`components/fusion_cast.gd`, Test `tests/fusion/check_fusion_impact_origin.gd`.

1. Jede Fusion hat einen Träger, der trifft. Ihr Effekt zündet am ersten
   getroffenen Gegner, sonst am Hindernis, sonst am Ende der Reichweite.
2. Ist keine der beiden Fähigkeiten ein Angriff, fliegt ein kurzer
   Träger-Impuls in Zielrichtung; der Effekt zündet an dessen Einschlag.
3. Sprungfusionen zünden dort, wo der Sprung trifft. Als Zweitfähigkeit
   bewegt der Sprung den Spieler nicht, nur sein Landeschlag zündet.
4. Schutzschilde, Heilung und Buffs gelten weiter für den Spieler.
   Alles Sichtbare und Schadende entsteht am Trefferort.
5. Mehrfachtreffer (Fächer, Durchschlag, Kette): höchstens drei Zündungen
   pro Wirken, je Geschoss am ersten Treffer. Zonen zünden einmal.
6. Erlaubte Zündorte: `DAMAGE_IMPACT_POSITION`, `IMPULSE_IMPACT_POSITION`,
   `TARGET_POSITION`, `ATTACKER_POSITION`. Spieler- und Landeposition sind
   verboten.

| Träger | Trigger | Spawn |
|---|---|---|
| Angriff (Projektil, Strahl, Nahkampf, Zone, Kette, Sprung) | ON_HIT | DAMAGE_IMPACT_POSITION |
| keine Angriffsfähigkeit im Paar | ON_IMPULSE_HIT | IMPULSE_IMPACT_POSITION |

Wenn ein Schadensskill mit einem Supportskill fusioniert wird, transportiert der Schadensskill die Fusion. Beispiel: Feuerball + Schildwall erzeugt die Schutzwirkung am tatsächlichen Feuerball-Impact.

## Datenvorlage

```yaml
fusion:
  key: "0:16"
  source_a: 0
  source_b: 16

  carrier:
    spell_id: 16
    form: projectile

  secondary:
    spell_id: 0
    signature: wirbel

  trigger: ON_HIT
  spawn_position: DAMAGE_IMPACT_POSITION

  inherits:
    a_element: physisch
    a_signature: wirbel
    b_element: feuer
    b_signature: explosion

  fusion_reaction: SIGNATURE_INFUSION

  trigger_limits:
    internal_cooldown: 0.5
    max_active: 2
    first_hit_only: false

  balance:
    energy_multiplier: 1.35
    cooldown_multiplier: 1.30
    power_multiplier: 1.45

  ranks:
    1: Grundfusion beider Signaturen
    2: Signatur von Quelle A verstärkt
    3: Signatur von Quelle B verstärkt
    4: Einzigartige Fusionsreaktion
```

## Bestehende feste Fusionen

- 0 + 16 → 40 Flammenwirbel: Feuerball ist Carrier; Wirbel und Brandfläche entstehen am Trefferpunkt.
- 1 + 36 → 41 Reaktorwall: Schild schützt sofort den Spieler; ein Träger-Impuls trägt die Reaktorwand zum Einschlag.
- 18 + 37 → 42 Blitzkern: Blitzlanze ist Carrier; Teslawelle entsteht am tatsächlichen Trefferpunkt.
- 17 + 18 → 43 Eisball: impactgebunden; Slow, Blitzkette, Blitzstun, Rang 4 Eiswirbel.

## Nicht-Schadensfälle

Paare ohne Angriff (Schild, Buff, Heilung, Markierung, Reaktion) senden einen
Träger-Impuls. Schild, Heilung und Buffs wirken beim Einschlag auf den Spieler,
ihre Sichtbarkeit und Felder entstehen am Einschlag.

## Multiplayer

Der Client meldet nur die Fähigkeit/Fusionsidentität. Der Server prüft bekannte Fusion, normalisierten Key und gespeicherten Rang. Er wirkt den Träger und zündet den Sekundärschaden ebenfalls am Trefferpunkt (`cast_fusion_at_impact` mit `server_peer`). Sekundärschaden behält den `owner_peer`, damit Treffer, XP und Kill-Zuordnung beim verursachenden Spieler bleiben.

## Build-Erkennung

Production-Workflows schreiben den exakten GitHub-Commit in `components/build_info.gd`. Das Patchfenster zeigt den Kurz-Hash an. So ist im laufenden Webgame direkt sichtbar, welcher Commit geladen wurde.
