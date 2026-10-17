# Sonnenhain – flüssige Welt, feste Architektur, bessere Abenteuer

Stand: 16. Oktober 2026. Auftrag von Angelo: deutlich flüssigeres Spiel,
feste Gegenstände wie Mauern und ein Grafik-/Gameplaykonzept mit Blender,
Krita, Inkscape und ComfyUI. Status: Konzept, keine umgesetzte Optimierung.

## 1. Entscheidung für die nächste Entwicklungsphase

**Zuerst einen messbar flüssigen Landschaftsabschnitt bauen. Danach auf
dieser Grundlage Grafik und Begegnungen verbessern.**

Die Welt bekommt feste, wiederverwendbare Bauteile mit klaren Materialien
und verlässlichen Grenzen. Bewegung konzentriert sich auf Spieler, Gegner,
Angriffsankündigungen und wenige wirksame Details. Die bisherige Perspektive
und die räumliche Modellgestaltung bleiben Grundlage.

Ein unbewegliches Modell wird normalerweise weiterhin pro Bild gerendert.
Zusätzliche Mauern sparen nicht automatisch Rechenzeit und können sie sogar
erhöhen. Der Gewinn muss aus weniger Wiederaufbau, begrenzter Sichtmenge,
gemeinsam genutzten Ressourcen und wiederverwendeten Renderergebnissen kommen.

## 2. Ausgangsbefund aus dem lokalen Code

`world_obstacles_3d.gd` nutzt einen gemeinsamen 3D-Viewport mit 128-Pixel-
Atlaszellen. Bei einer aktualisierten Sammlung werden sichtbare Instanzen
entfernt/erzeugt, Plätze anhand der aktuellen Liste zugewiesen und die
Viewportgröße an deren Anzahl angepasst. Bei Kamerabewegung kann sich die
Signatur vor Ablauf der 0,25-Sekunden-Pause ändern. Im aktiven Zustand steht
der Viewport auf `UPDATE_ALWAYS`.

Modelle und Meshes werden bereits teilweise geteilt und Geometrie nach
Material zusammengeführt. Diese Optimierungen erhalten und gezielt ergänzen.
58 der 78 Landschaftsmotive haben laut Bestandsdokumentation seltene
Animationen. Auch eine seltene Animation kann ein laufendes Objektskript
haben; `world_obstacle_idle_3d.gd` prüft derzeit pro Prozessschritt ihren Timer.

Der dedizierte Server erzeugt über diesen Pfad keinen 3D-Viewport. Die
gemeldeten Online-Lags bleiben dennoch offen: Client-Stottern, verspätete
Nachrichtenverarbeitung, Netzwerkstau und Serversimulation getrennt messen.
Live-Version und Live-Logs wurden für dieses Konzept nicht geprüft.

## 3. Drei Objektklassen statt gleicher Behandlung für alles

| Klasse | Beispiele | Darstellung und Aktualisierung | Spielregeln |
|---|---|---|---|
| Fest | Mauer, Sockel, Fels, Säule, Hauskörper, Baumstamm | Keine eigenen Timer oder Animationen; Mesh/Material geteilt; feste Cacheplätze; nur bei tatsächlicher Änderung neu rendern | Vorhandene feste Kollisionsdaten |
| Zustandsabhängig | Tor offen/zu, Truhe leer/voll, umgeworfener Golem-Baum | Statische Zustandsbilder aus echten Modellen; bei Wechsel gezielt aktualisieren; Bewegung nur während des Übergangs | Gespeicherter bzw. maßgeblicher Serverzustand |
| Bewegt | Spieler, Gegner, Geschosse, Fähigkeitsanzeigen, wenige Flammen/Blätter | Getrennte dynamische Darstellung, nur relevante sichtbare Effekte; feste Obergrenzen | Bestehende Kampf-/Netzwerkregeln |

Ein Baum kann aus festem Stamm und separat bewegten Blättern bestehen.
Eine Laterne hat einen festen Körper und einen kleinen dynamischen Licht-
oder Flammeneffekt. Ganze Gegenstände müssen dafür nicht dauerhaft animieren.

## 4. Empfohlener Darstellungsweg für die bestehende Perspektive

### Statische 3D-Ergebnisse während des Spiels zwischenspeichern

Die 3D-Modelle bleiben die Quelle. Ihre Projektion wird bei Bedarf im Spiel
gerendert und auf der GPU weiterverwendet. Das ist eine vorgeschlagene
Weiterentwicklung des bisherigen laufenden 3D-Atlas, kein bereits beschlossener
Wechsel zu vorab erzeugten Spritebildern für alle Landschaftskörper.

1. Objektdefinitionen erhalten stabile IDs und klare Angaben zu Modell,
   Materialvariante, Orientierung, Maßstab, Zustand, Ursprung und Sortierung.
2. Sichtbare Weltbereiche verwenden feste Rasterabschnitte. Startwert zum
   Vergleich: 512 gegen 1024 Welteinheiten; endgültige Größe nach Messung.
   Nachbarbereiche vorladen, entfernte Bereiche über einen begrenzten Cache halten.
3. Statische Projektionen bekommen stabile Plätze auf festen Atlasseiten.
   Ein Objekt beim Laufen aus der Sicht zu verlieren verschiebt nicht die
   Plätze aller anderen. Zusätzliche Seiten statt ständigen Größenwechseln.
4. Rendern nur bei erstmaligem Laden, neuer Darstellung oder Zustandswechsel.
   Godots `SubViewport.UPDATE_ONCE` aktualisiert einmal und schaltet danach
   ab. Die Textur bleibt ohne CPU-Bildrücklesen zur Darstellung verfügbar.
5. Eine Änderung markiert nur betroffene Seiten als ungültig. Der erste
   Prototyp rendert jeweils eine vollständige feste Seite neu; partielle
   GPU-Updates nicht voraussetzen. Kleine Seiten begrenzen die Änderungskosten.
6. Statische und dynamische Objekte verwenden getrennte Renderziele. Ein
   laufender Wolf oder eine Flamme erzwingt kein Neurendern aller Mauern.
7. Unveränderte Ansichten teilen sich nach Möglichkeit eine Projektion.
   Cache-Schlüssel enthalten Form, Rotation, Material, Skalierung, Zustand
   und Lichtprofil. Abweichende Ansichten nie versehentlich gleichsetzen.
8. Sichtbare 2D-Projektionen werden weiterhin mit Figuren nach Fußpunkt
   sortiert. Lange Mauern bleiben dafür in passende Abschnitte zerlegt.

**Abnahmeregel:** Reine Kameraverschiebung innerhalb bereits vorbereiteter
Bereiche löst keine Neuerzeugung unveränderter Meshes und kein Neurendern
unveränderter statischer Atlasseiten aus. Die fertigen Projektionen müssen
weiter pro Bild zusammengesetzt werden; völlig kostenlos werden sie nicht.

### Licht, Sortierung und Speicher begrenzen

Globale Tageszeit kann über eine gemeinsame Farbanpassung laufen. Wirkliche
Lichtrichtungswechsel benötigen ein neues Lichtprofil oder einen anderen
Darstellungsweg. Örtliche Effekte separat zeichnen. Zunächst bestehendes
Licht erhalten; keine großen neuen Echtzeitschatten versprechen.

Ein Atlas aus RGBA8 mit 2048 × 2048 Pixeln benötigt allein für die Farbe
16 MiB; Tiefenpuffer, weitere Renderziele und mögliche Mipmaps kommen hinzu.
Atlasanzahl und tatsächlichen Grafikspeicher messen und begrenzen. Für den
ersten Test höchstens zwei statische Seiten dieser Größe als Kandidat;
kleinere Seiten bei Bedarf vergleichen. 128-Pixel-Zellen, Beschnitt und
hohe Körper zunächst anhand der bestehenden Größen prüfen.

Durchgehende Wände dürfen die Figuren nicht falsch überdecken. Keine ganze
Map samt Mauern zu einem einzigen Vordergrundbild zusammenkleben. Ränder,
Tore, vertikale Abschnitte und Golem-Baumzustände ausdrücklich prüfen.

### Alternative, falls der Cachepfad optisch nicht genügt

Persistente echte 3D-Instanzen mit festen Atlasplätzen weiter live rendern,
aber Wiederaufbau, Materialwechsel und Instanzerzeugung reduzieren. Das
behält dynamisches Licht leichter bei, spart jedoch weniger Renderarbeit.
Beide Varianten mit gleicher Kamera und Szene vergleichen. Der Cachepfad
ist die bevorzugte Hypothese für feste Körper, kein garantierter Sieger.

MultiMesh ist ein möglicher weiterer Test für viele identische Teile, kein
pauschaler erster Umbau: pro Weltbereich aufteilen, denn einzelne Instanzen
eines MultiMesh werden nicht individuell ausgeblendet. In der jetzigen
Atlasanordnung entspricht 3D-Sichtbarkeit außerdem nicht der Weltsichtbarkeit.
Auch Mauern erzeugen dort nicht automatisch Verdeckungsoptimierung.

## 5. Kollision, Navigation und Server bleiben eine eigene Schicht

- Sichtbare Wand und tatsächliche Sperre müssen übereinstimmen. Vorhandene
  `world_geometry`-/Kollisionsabfragen bleiben zunächst maßgeblich; nicht
  zusätzlich für jeden Renderbaustein einen zweiten Physikkörper erzeugen.
- Server braucht Daten über Wege, Sperren und Zustandswechsel, keine
  Texturen, Shader, Animations-Timer oder Renderatlasseiten.
- Feste Mauern werden nicht dauernd synchronisiert. Gemeinsame Definitionen
  und stabile Objekt-IDs; Änderungen wie Toröffnung zuverlässig über den
  vorhandenen Serverpfad. Beitritt/Reconnect erhält den aktuellen Zustand.
- Umgeworfene Golem-Bäume bleiben mit vorhandenen Kampf- und Navigationsdaten
  verbunden. Eine Cacheoptimierung darf keinen unsichtbaren Baum zurücklassen.
- Ressourcen- und Modulabhängigkeiten vor Exportänderungen prüfen. Keine
  aggressive Entfernung von Serverressourcen, die noch vorab geladen werden.
- Netzwerk-/Serveroptimierung nach Messbefund separat bearbeiten. Sinkende
  Renderzeit beweist keine Verbesserung der Server-Tickzeit oder des Pings.

## 6. Bessere Architektur mit den vier Programmen

Erstes Bauset für einen bestehenden Außenbereich, zunächst keine neuen
Kollisionsgrenzen: gerade Wand in beiden Achsen, Innen-/Außenecke, Endstück,
Torpfosten, Torbogen sowie ein Fels. Vorhandene sechs Mauermotive als Ausgang
nehmen. Sockel, Moos, Bruchkanten und Farben machen die Teile hochwertiger,
während gemeinsame Materialien die Varianten zusammenhalten.

| Werkzeug | Konkrete Produktion | Prüfergebnis |
|---|---|---|
| Blender | Feste Module mit gemeinsamem Raster, wenigen Materialien, sauberen Ursprüngen; GLB-Exporte, einfache Silhouetten und Detailvarianten | Module schließen ohne Spalt; keine überflüssigen verdeckten Flächen; Maßstab und Perspektive stimmen |
| Krita | Nahtlose Stein-/Holz-/Moosflächen, Pixelkorrektur, Farbpalette und dezente Materialdetails | Textur funktioniert auch mehrfach nebeneinander und bei normalem Zoom |
| Inkscape | Maßhaltiger Bauplan, Modulkennungen, Tor-/Questzeichen, Bodenmarkierungen und Icons | Lesbare Formen, konsistentes Raster, PNG-Exporte passen zum Spiel |
| ComfyUI | Begrenzte Konzeptvarianten für märchenhafte Steinarchitektur und Ruinen aus eigenen Referenzen | Eine ausgewählte Stilrichtung; Workflow/Modelle/Eingaben dokumentiert; in Krita bereinigte Referenzen |

ComfyUI läuft im Produktionsprozess, nicht auf dem Spielserver oder in einer
laufenden Spielsession. KI-Bilder definieren keine Kollisionen. Die vier
Programme sind bislang als Installer heruntergeladen; Installation,
Importprobe und ComfyUI-Modelleinrichtung sind noch notwendige Schritte.
Bei der Einrichtung große Modelle auf ein geeignetes Laufwerk legen.

Bearbeitbare Quellen und Runtime-Exporte gemäß [Werkzeugplan](NEXT_LEVEL_PLAN.md)
trennen. Große BLEND-/KRA-Dateien gemäß bestehender Speicherstrategie
verwalten. Exporte ohne unnötige Quell- und Modellgewichte ausliefern.

## 7. Das neue Gameplay nutzt die feste Welt

Die Gestaltung gewinnt durch klare Räume, sichtbare Ziele und bewusste
Begegnungen. Erst vorhandene Wände und Zugänge verbessern; neue Grenzen
anschließend als eigenes geprüftes Inhaltspaket.

| Bauteil / Ort | Verbesserung für Spieler | Grenze des ersten Pakets |
|---|---|---|
| Mauertor | Ein sichtbarer Übergang kündigt das nächste Gebiet und seinen Freischaltgrund an | Vorhandene Freischaltregel übernehmen |
| Fels und Ruinenecke | Gegnerkombination erhält einen lesbaren Raum mit freiem Fluchtweg | Bestehende Wegsuche und Kollisionsregeln nutzen |
| Kleiner Hof hinter einem Tor | Kurze Herausforderung mit erkennbarem Abschluss | Vorhandene Gegner statt neuem Kampfsystem |
| Nebenpfad am Wahrzeichen | Freiwilliger Fund als Belohnung für Erkundung | Einmaligkeit und Charaktertrennung prüfen |
| Steinrose bei der Heimkehr | Sichtbare Reaktion auf einen persönlichen Erfolg | Rein optisch, keine gemeinsamen Sperren verändern |

Mauern bieten erst dann echte Deckung vor Geschossen, wenn die vorhandene
Projektilprüfung diese Sperre berücksichtigt. Darstellung allein reicht
nicht. Erst bestehendes Verhalten prüfen; neue Deckungsregeln gegebenenfalls
getrennt mit Nah-/Fernkampf, allen Klassen und Servervalidierung umsetzen.

Gegner behalten klare Angriffsankündigungen. Dichte Dekoration darf weder
Trefferflächen noch Bodenwarnungen verdecken. Neue Engstellen nicht als
Vorwand verwenden, hinter Mauern ungeprüft Gegner zu deaktivieren; auch
andere Koop-Spieler und die Serversimulation müssen berücksichtigt werden.

## 8. Erster Pilot und Messung

Eine feste Route auf einer betroffenen Außenmap wählen: offene Landschaft,
lange Mauer, Ecke, Tor, Blick vor/hinter Körper und kurzer Kampf. Map 0
dient zusätzlich als Kontrolle, ihr Aussehen bleibt erhalten. Separater
Belastungstest mit Golem und zustandsabhängigen Bäumen.

Drei technische Varianten vergleichen: aktueller Stand, persistente feste
Instanzen, statischer Cache plus getrennte Dynamik. Gleiche Positionen,
Kollisionen, Gegner, Auflösung, Zoom und Hardware verwenden. Je Variante
Laden beim ersten Besuch und wiederholtes Laufen nach dem Vorladen messen.

| Messung | Ziel / Bedeutung |
|---|---|
| Client-Bildzeit | Ziel 60 FPS; 16,7 ms entspricht dem Bildbudget. P50/P95/P99 und Zahl der Bilder über 33/50 ms erfassen, nicht nur Durchschnitts-FPS |
| Bewegungsstottern | Ziel: mindestens 30 % bessere P95-Bildzeit im reproduzierten problematischen Fall; bei bereits flüssiger Basis stattdessen Budget einhalten |
| Cacheverhalten | Beim Stillstand unveränderter Landschaft keine wiederholten statischen 3D-Renderupdates; keine Atlas-Neuordnung bei normalem Scrollen |
| Speicher | Atlas-/Objektzahl bleibt nach wiederholter Route begrenzt; kein dauerhaftes Wachstum nach Gebietswechseln |
| Server | Tick-Abstände, CPU-Zeit einschließlich Spitzen, Paket-/Kodierungsaufwand und Warteschlangen getrennt erfassen |
| Netzwerk | Antwortzeiten, Jitter und verspätete Zustände unter denselben Bedingungen; Client-Blockaden nicht als reine Leitungslatenz ausgeben |
| Spielregeln | Alle Klassen, Solo, zwei und vier Spieler, Tore, Rückreise, Relog, Golem-Baumzustände und Browser-Rückfall funktionieren |

Die 30 % sind ein Abnahmeziel, kein gemessener Gewinn. Während des Ladens
einzelne teure Modell-/Shaderaufbauten separat zeigen. Vorladen begrenzen;
eine einzelne schwere Erstellung wird durch einen Zeitplan nicht automatisch
unterbrechbar. Falls nötig Assets beim Laden vorwärmen oder vereinfachen.

Browserexport in Brave und einem weiteren Chromium-Browser tatsächlich
prüfen, zusätzlich nativer Vergleich. Referenzgerät mit GPU, Auflösung,
Browser-/Treiberstand und Spielversion dokumentieren. Android bleibt ein
späterer separater Geräte-/Auslieferungstest.

## 9. Umsetzungsreihenfolge

1. Lag-Fall reproduzieren, aktuelle Versionen abgleichen und Messroute erfassen.
2. Werkzeuge einrichten; Blender-/Krita-/Inkscape-Exportprobe und Stilblatt.
3. Vorhandene Mauern ohne optische Änderung technisch in feste und dynamische
   Anteile trennen; stabile Atlasplätze und Wiederverwendung testen.
4. Cachevariante isoliert daneben bauen. Tor, vertikale Mauer und Baumzustand
   als harte Gegenproben. Erst nach Vergleich den Darstellungsweg auswählen.
5. Das kleine Architekturset mit den neuen Werkzeugen gestalten; identische
   Platzierung und Regeln beibehalten. Vorher-/Nachher-Spielbilder erstellen.
6. Erst danach den Tor-/Hof-/Nebenpfad-Piloten ausarbeiten, einschließlich
   verständlicher Ziele, Gegnerrollen und Heimkehrreaktion.
7. Betroffene Verhaltenstests, gesamte Projektprüfung, Browser- und Kooptests
   abschließen; Ergebnis und Restpunkte dokumentieren.
8. Konkretes Paket zur Veröffentlichung vorlegen. Nach Freigabe ausliefern
   und gemeldeten Online-Fall erneut prüfen. Erst dann gebietsweise ausrollen.

Bestätigte P0-Fehler unterbrechen die Arbeit. Dieses Leistungspaket rückt
vor weitere breite Figuren-/Landschafts-Upgrades. Fortschritts-/Speicherregeln
bleiben eigene wichtige Pakete; keine gemeinsame Großbaustelle eröffnen.

## 10. Verbindlicher Rahmen des Konzepts

Neue Logik in passende Module unter `components/`, keine Vergrößerung von
`main.gd` um den Renderer. Bestehende Grafikentscheidungen werden durch diesen
Entwurf noch nicht stillschweigend ersetzt: Der Cachepfad wird sichtbar und
messbar beurteilt. Ein vollständiger Offline-Sprite-Umbau, neue Kameraführung
und neuer Renderer sind nicht Bestandteil des ersten Piloten.

Umsetzungsstand 17.10.2026: Schritte 1–3 erledigt, Architekturset (Schritt 5)
mit Felsen umgesetzt, Schritt 6 umgesetzt (Gebietsbanner und Siegeltor am
Mauertor, Ruinenhof hinter dem Mauertor, verborgene Funde an Nebenpfaden,
Heimkehrschmuck). Messungen siehe Umsetzungsbericht.

Umsetzungsstand 16.10.2026: Werkzeuge eingerichtet, erste Modellserie und
Grafikpipeline erstellt, Atlas-/Minimap-Caches und erste Kampf-/Storygrafik
lokal eingebaut. Messungen, Vorschaubilder und offene Abnahmen stehen im
[Umsetzungsbericht](QUALITY_V1_UMSETZUNG.md). Online-Lags weiterhin offen.

## Technische Grundlagen

- [Godot: SubViewport und Aktualisierungsmodi](https://docs.godotengine.org/en/stable/classes/class_subviewport.html) – einmaliges Aktualisieren ist möglich; die konkrete Cachearchitektur ist unser Vorschlag.
- [Godot: MultiMesh](https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html) – gemeinsames Zeichnen mit Grenzen bei individueller Sichtbarkeitsprüfung.
- [Krita: nahtlose Texturen](https://docs.krita.org/en/tutorials/common_workflows.html) – Wrap-around-Modus unterstützt die Materialproduktion.

Projektbezug: [Lag-Fehler](SERVER_LAGS_3D.md),
[Arbeitsplan](ARBEITSPLAN.md), [Spielkonzept](VERBESSERUNGSKONZEPT.md),
[Werkzeugplan](NEXT_LEVEL_PLAN.md).
