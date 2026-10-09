# Animationserweiterung: Schleim, Käfer und Pilzling

9. Oktober 2026. Fortsetzung der fertigen Mooswolf-Animationen.

## Umfang

Alle drei übrigen frühen Waldmobs erhalten je 192 eigene Posen: acht Blickrichtungen mit jeweils vier Ruhe-, acht Bewegungs-, acht Angriffs-/Erholungs-, zwei Treffer- und zwei Todesbildern. Rückansichten zeigen kein Frontgesicht. Die bisherige zusätzliche Bildverformung entfällt für die neuen Posen.

- Waldschleim: ruhiges Pulsieren, nachschwingender Spross und ein Hop-Zyklus mit Sammeln, Komprimieren, Strecken, Flug und Nachfedern. Der Körperstoß besitzt eigene Vorbereitungs-, Treffer- und Erholungsbilder.
- Blütenkäfer: wechselnde Bein- und Fühlerstellungen, mitbewegte Blüten, wachsende Drüsen vor dem Schuss und sichtbarer Rückstoß beim Entleeren.
- Pilzling: wechselnde Wurzelfüße, Gewichtsverlagerung und nachwippender Hut; vor dem Giftstaub wird Druck aufgebaut, beim Ausstoß hebt sich der Hut und macht seine Lamellen sichtbar. Der Stab bleibt in der rechten Hand.

Die Freisetzungspose beginnt exakt bei der bisherigen Treffer-/Freisetzungsgrenze der gemeinsamen Kampfzustände. Die Graphik erzeugt keinen weiteren Treffer und keinen zweiten Staubimpuls. Die vorhandenen Sekret-, Giftstaub- und Wolf-Angriffe bleiben unverändert.

## Laufphasen und Ende der Animation

Eine Bewegungsrunde entspricht 52 Welteinheiten beim Schleim, 64 beim Käfer und 56 beim Pilzling. Die Phase wird anhand echter zurückgelegter Strecke fortgeführt, auch bei der geglätteten Client-Bewegung. Verlangsamung reduziert die Animation entsprechend; Stillstand und Betäubung halten die Laufphase an. Große Positionskorrekturen laufen keine künstlichen Schrittfolgen durch.

Nur der Schleim besitzt eine kleine zusätzliche Flughöhe passend zum gezeichneten Hop; Käfer und Pilzling bleiben mit ihren Füßen am Boden. Ruhezyklen nutzen individuelle Mob-Seeds. Trefferbilder und das Zusammenbrechen ersetzen die alten geometrischen Reaktionen. Die gefallenen Körper blenden bis 0,95 Sekunden aus; Belohnung und tatsächlicher Tod bleiben sofort wirksam. Die Anzeige beim Pilzling sitzt oberhalb der bewegten Hutkontur.

## Assets und Herkunft

Mit dem eingebauten Bildgenerierungswerkzeug erstellt, anhand der vorhandenen freigegebenen Motive. Die vollständigen Prompts stehen in `woodland-animation-prompts.json`. Rohbilder liegen jeweils in `art/sprites/mobs/woodland_v3/<mob>/source/` und sind mit `.gdignore` vom Spielimport ausgeschlossen.

Die fertigen Streifen liegen in `art/sprites/mobs/woodland_v3/<mob>/<richtung>.png`: 24 Rahmen von 128×128 Pixeln. Die bewährte Wolfsilhouetten-Extraktion entfernt Nachbarbildreste und erhält eine kleine Alpha-Kontur. Ein fester Maßstab je Richtung bewahrt die Größenänderungen der tatsächlich gezeichneten Posen, statt jede Pose separat gleich groß zu strecken.

## Prüfung

`check_woodland_pose_animation.gd` prüft alle 576 Rahmen, Transparenz, unterschiedliche Bewegungsbilder, vollständige Zyklen und die Freisetzungsgrenze. Die Spielintegration prüft außerdem die reduzierte Gangphase bei Verlangsamung und deren Stillstand bei Betäubung. Die bestehenden Kampf- und echten WebSocket-Prüfungen prüfen weiterhin Sekret, Giftfläche, Wolfssprung und Gruppenschaden.

`capture_woodland_pose_animation.gd` rendert die native Pose-Darstellung für Ruhe, Bewegung, Angriff, Treffer und Tod sowie eine Übersicht aller Richtungen. Die animierte Vorschau liegt unter `docs/mob-erneuerung/woodland-animationen.gif`.
