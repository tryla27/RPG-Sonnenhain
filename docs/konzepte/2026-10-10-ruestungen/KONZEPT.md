# Konzept: Neue LV-40-Rüstungen

Stand: 10.10.2026. Entwurf zur Abstimmung mit Angelo.

## Wunsch (Angelo, 10.10.2026, 01:15)

> Ergänze fette neue LV-40-Rüstungen mit entweder AGI-Boosts oder Magie-Boost
> oder Dornen usw., mache ein Konzept.

Dazu kommt aus dem Golem-Konzept die **Golem-Rüstung mit 100 Verteidigung**
als Beute des Dunklen Golems.

## Ausgangslage

- **Eine Rüstung hat heute nur Schutz.** Jeder Treffer wird um den Schutzwert
  verringert (`Schaden − Schutz`, mindestens 1).
- **Dazu kommen kleine Attributwerte:** Stärke, Beweglichkeit und Intelligenz,
  je die Hälfte des Bonus.
- **Die stärksten Rüstungen heute:**
  - Torvalds „Meisterrüstung“ auf LV 40 hat etwa **18 Schutz**.
  - Beute auf LV 40 liegt bei etwa 10–20 Schutz.
  - Gegner im Himmelsgarten treffen mit etwa 150–230 Schaden.
- **Aussehen am Charakter:** sechs Rüstungsbilder (Reise, Wacht, Arkan, Wald,
  Sonne, Kristall).
- **Spezialwirkungen gibt es bei Rüstungen noch keine.** Für Spezialwirkungen
  gibt es bisher nur Halsketten und Runen.

## Idee

Sechs **Meisterrüstungen** ab Stufe 40, jede mit einer **eigenen Wirkung** und
einem **eigenen Aussehen**, dazu die Golem-Rüstung als Krönung. Sie sind
deutlich stärker als alles bisher („fett“). Jede hat eine klare Rolle, damit
die Wahl spannend ist.

| Rüstung | Rolle | Schutz | Attribute | Wirkung |
|---|---|---|---|---|
| **Windläufer-Harnisch** | Beweglichkeit | 34 | BEW +24 | +8 % Lauftempo, Ausweichrolle kostet 25 % weniger Ausdauer, nach einer Rolle 2 s lang +15 % Angriffstempo |
| **Arkanweber-Robe** | Magie | 28 | INT +26 | +15 % Zauberschaden, −10 % Mana-/Energiekosten, alle 8 s ein Arkanschild (fängt 60 Schaden) |
| **Dornenpanzer** | Dornen | 40 | STÄ +14 | Wirft 30 % des Nahkampfschadens auf den Angreifer zurück, bei Treffern 15 % Chance auf 1 s Dornenwurzeln |
| **Bollwerk des Wächters** | Verteidigung | 52 | STÄ +18 | 12 % Chance, einen Treffer ganz zu blocken; unter 30 % Leben +20 Schutz |
| **Blutmond-Mantel** | Lebensraub | 30 | STÄ +10, BEW +10 | 6 % des verursachten Schadens heilt dich, Treffer gegen Elite und Bosse 10 % |
| **Sternenquell-Gewand** | Erholung | 30 | INT +12, BEW +12 | +4 Leben/s außerhalb des Kampfes, Tränke heilen 25 % mehr |
| **Golem-Rüstung** (Boss-Beute) | Fels | **100** | STÄ +20 | Steinhaut: −10 % Lauftempo, Rückstoß wirkt nicht; unter 40 % Leben 5 s lang −50 % Schaden (Abklingzeit 60 s) |

Alle Zahlen sind ein **erster Vorschlag** und werden nach dem Testen
angepasst.

**Zur Golem-Rüstung:** Mit 100 Schutz zieht sie von jedem Treffer 100 ab. Bei
Gegnern mit 150–230 Schaden halbiert sie fast jeden Treffer. Das ist bewusst
die stärkste Rüstung im Spiel, als Belohnung für den schwersten Kampf. Wenn
später die Stufe auf 100 steigt (Merkliste), wachsen die Gegner mit, und die
Rüstung bleibt stark, aber nicht unbesiegbar.

## Woher man sie bekommt

- **Torvald (Schmied):** ab Stufe 40 je Rotation 1 Meisterrüstung im Angebot,
  teuer (etwa 6000–8000 Gold).
- **Beute:** In den Gebieten ab Stufe 33 (Dämmergrat, Himmelsgarten) haben
  Elite-Gegner und Truhen eine kleine Chance (2 %).
- **Klassenbosse:** Jeder Klassenboss hat eine 10-%-Chance auf die Rüstung, die
  zur Klasse passt: Krieger → Bollwerk, Magier → Arkanweber, Schütze →
  Windläufer.
- **Golem-Rüstung:** nur vom Dunklen Golem, jeder Beteiligte bekommt eine (wie
  beim Bosshut).
- **Klassenbindung:** Alle Klassen können jede Rüstung tragen. Die Wirkungen
  passen aber spürbar besser zu bestimmten Klassen.

## Aussehen

Jede Rüstung bekommt am Charakter ein eigenes Bild in allen Richtungen, im
gleichen Pixelstil wie die bisherigen sechs:
- **Windläufer:** helles Leder, grüne Bänder, flatternde Schärpe
- **Arkanweber:** lange violette Robe mit leuchtenden Runennähten
- **Dornenpanzer:** dunkelgrüne Platten mit Dornen an Schultern und Armen
- **Bollwerk:** schwere Stahlplatten, breiter Schulterschild, Goldkante
- **Blutmond:** tiefroter Mantel mit silbernem Mond auf dem Rücken
- **Sternenquell:** hellblaues Gewand mit kleinen Sternfunken
- **Golem-Rüstung:** schwarze Basaltplatten mit lila Elixier-Rissen, wie der
  Golem selbst

Im Inventar zeigt der Tooltip die Wirkung in einer eigenen goldenen Zeile, wie
bei den Halsketten. Vor dem Bau bekommst du **Vorschaubilder aller
Rüstungen** an allen drei Klassen.

## Technik

- `components/armor_effects.gd`: Liste der Meisterrüstungen (Name, Schutz,
  Attribute, Wirkung) und die Wirkungsregeln als zustandslose Funktionen, also
  Schadensreduktion, Dornenrückwurf, Lebensraub und Blockchance.
- Wirkungen greifen an den bestehenden Stellen: Schaden nehmen
  (`apply_player_damage`), Schaden machen (`damage_enemy`), Laufen, Ausweichen,
  Tränke.
- **Mehrspieler:** Der Server kennt die getragene Rüstung schon über den
  Spielerzustand (`armor`). Dornen und Lebensraub rechnet er selbst, damit
  niemand schummeln kann.
- **Spielstand:** Die Rüstung trägt ihre Kennung (`master_armor`), der Server
  prüft sie wie Halsketten und Bosshüte.
- **Tests:** jede Wirkung einzeln, Server-Prüfung, Tooltip.
- **Ausblick auf D4** (Rüstung pro Körperteil): Diese Rüstungen werden dann
  zum Brustteil eines Sets. Die Wirkungen bleiben.

## Umfang

Mittel bis groß. Vorschlag:
1. Aussehen aller 7 Rüstungen als Bilder zur Abnahme
2. Werte und Wirkungen mit Tests, Torvald-Angebot
3. Beute (Elite, Truhen, Klassenbosse), Golem-Rüstung kommt mit dem Golem

## Fragen an dich

1. Passen die sechs Rollen (Beweglichkeit, Magie, Dornen, Verteidigung,
   Lebensraub, Erholung), oder fehlt eine, zum Beispiel Feuer-/Eis-Resistenz
   oder Tempo?
2. Sollen die Meisterrüstungen frei für alle Klassen sein (Vorschlag), oder
   klassengebunden wie Klassenhüte?
3. Soll man sie bei Torvald kaufen können, oder nur als Beute?
4. Die Golem-Rüstung mit 100 Schutz halbiert fast jeden Treffer. Soll das so
   stark bleiben?
