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

## Position des Sekundäreffekts

| Träger | Trigger | Spawn |
|---|---|---|
| Schaden/Projektil/Beam/Melee/Zone | ON_HIT | DAMAGE_IMPACT_POSITION |
| Sprung mit Impact | ON_LAND | LANDING_POSITION |
| Ziel/Markierung | ON_TARGET | TARGET_POSITION |
| Reaktive Schutzwirkung | ON_BLOCK | ATTACKER_POSITION |
| Selbstbuff/Heilung/Schild | ON_CAST | PLAYER_POSITION |

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
- 1 + 36 → 41 Reaktorwall: Schutzfusion; ON_CAST am Spieler.
- 18 + 37 → 42 Blitzkern: Blitzlanze ist Carrier; Teslawelle entsteht am tatsächlichen Trefferpunkt.
- 17 + 18 → 43 Eisball: impactgebunden; Slow, Blitzkette, Blitzstun, Rang 4 Eiswirbel.

## Nicht-Schadensfälle

- Schutz/Buff/Heilung: PLAYER_POSITION
- Markierung/Zielkontrolle: TARGET_POSITION
- Sprung/Bewegungsimpact: LANDING_POSITION
- Reaktion auf eingehenden Treffer: ATTACKER_POSITION

## Multiplayer

Der Client meldet nur die Fähigkeit/Fusionsidentität. Der Server prüft bekannte Fusion, normalisierten Key und gespeicherten Rang. Sekundärschaden behält den `owner_peer`, damit Treffer, XP und Kill-Zuordnung beim verursachenden Spieler bleiben.

## Build-Erkennung

Production-Workflows schreiben den exakten GitHub-Commit in `components/build_info.gd`. Das Patchfenster zeigt den Kurz-Hash an. So ist im laufenden Webgame direkt sichtbar, welcher Commit geladen wurde.
