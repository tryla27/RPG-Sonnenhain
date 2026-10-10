extends RefCounted
## Spielinhalte von Sonnenhain: Gegner, Fähigkeiten, Quests, NPCs, Händler,
## Weltereignisse, Wahrzeichen, Wege und Torbogen.
##
## Reine Daten ohne Laufzeitzustand. main.gd stellt alle Einträge weiterhin
## unter denselben Konstantennamen bereit (z. B. main.ENEMY_TYPES), damit
## bestehende Aufrufer und Tests unverändert funktionieren.
## Siehe docs/architecture/main-modularization.md, Schritt 1.

const RESCUE_POS := Vector2(3150, 2350)
const PORTALS := [
	[Vector2(3690, 6810), Vector2(11850, 930), 8],
	[Vector2(7590, 2590), Vector2(11850, 2810), 9],
	[Vector2(7610, 6830), Vector2(11850, 4720), 10],
	[Vector2(10100, 2750), Vector2(11850, 6630), 11],
	[Vector2(9820, 6750), Vector2(11850, 8500), 12],
	# Angelo 10.10.2026: zweiter Weg in die Nebelheide, oben rechts in den Aschebergen.
	[Vector2(10550, 600), Vector2(12300, 520), 8]
]
const ENEMY_TYPES := [
	{"name":"Waldschleim", "region":1, "hp":42, "damage":8, "speed":78, "xp":12, "color":Color("73cb88")},
	{"name":"Blütenkäfer", "region":1, "hp":32, "damage":6, "speed":113, "xp":11, "color":Color("e998b6")},
	{"name":"Pilzling", "region":2, "hp":65, "damage":11, "speed":65, "xp":19, "color":Color("e3ad77")},
	{"name":"Mooswolf", "region":2, "hp":72, "damage":14, "speed":132, "xp":24, "color":Color("789983")},
	{"name":"Steinwächter", "region":3, "hp":118, "damage":19, "speed":72, "xp":36, "color":Color("bea78c")},
	{"name":"Ruinenbeholder", "region":3, "hp":82, "damage":22, "speed":105, "xp":38, "color":Color("a8b9e9")},
	{"name":"Kristallkrabbe", "region":4, "hp":125, "damage":22, "speed":75, "xp":44, "color":Color("8de0eb")},
	{"name":"Kristallwächter", "region":4, "hp":165, "damage":29, "speed":66, "xp":58, "color":Color("92ddea")},
	{"name":"Ascheläufer", "region":5, "hp":145, "damage":29, "speed":138, "xp":57, "color":Color("dc835e")},
	{"name":"Lavawächter", "region":5, "hp":260, "damage":38, "speed":52, "xp":82, "color":Color("a75c52")},
	{"name":"Strandkrabbe", "region":6, "hp":57, "damage":9, "speed":93, "xp":15, "color":Color("e9a67e")},
	{"name":"Wassergeist", "region":6, "hp":90, "damage":16, "speed":117, "xp":26, "color":Color("76bfd2")},
	{"name":"Kriegsherr", "region":6, "hp":1800, "damage":46, "speed":96, "xp":520, "color":Color("c97b5e")},
	{"name":"Dunkler Arkanhüter", "region":4, "hp":2100, "damage":54, "speed":102, "xp":650, "color":Color("8caee8")},
	{"name":"Jagdmeister", "region":8, "hp":2350, "damage":58, "speed":118, "xp":760, "color":Color("8fbd72")},
	{"name":"Sternenschatten", "region":7, "hp":320, "damage":48, "speed":128, "xp":230, "color":Color("b5a3d9")},
	{"name":"Bruchwächter", "region":7, "hp":470, "damage":55, "speed":72, "xp":280, "color":Color("dfac91")},
	{"name":"Nebelhirsch", "region":8, "hp":91, "damage":17, "speed":123, "xp":28, "color":Color("b9cfcc")},
	{"name":"Irrlicht", "region":8, "hp":73, "damage":20, "speed":109, "xp":31, "color":Color("a6d8da")},
	{"name":"Harzbestie", "region":9, "hp":142, "damage":26, "speed":91, "xp":47, "color":Color("caac5a")},
	{"name":"Wurzelhexe", "region":9, "hp":111, "damage":30, "speed":117, "xp":52, "color":Color("a0b379")},
	{"name":"Quellkriecher", "region":10, "hp":190, "damage":35, "speed":112, "xp":68, "color":Color("8fbfc6")},
	{"name":"Perlengeist", "region":10, "hp":155, "damage":39, "speed":134, "xp":75, "color":Color("c5e0e4")},
	{"name":"Gratgreif", "region":11, "hp":250, "damage":45, "speed":150, "xp":96, "color":Color("a7a0b8")},
	{"name":"Schattenritter", "region":11, "hp":340, "damage":53, "speed":90, "xp":108, "color":Color("77748f")},
	{"name":"Himmelsfalter", "region":12, "hp":390, "damage":60, "speed":148, "xp":145, "color":Color("d9c6e8")},
	{"name":"Sternenwächterin", "region":12, "hp":560, "damage":69, "speed":85, "xp":180, "color":Color("e4d4b5")},
	# 27/28: Dunkler Golem und seine Hälften (components/golem_boss.gd); nur beschworen.
	{"name":"Dunkler Golem", "region":12, "hp":8640, "damage":95, "speed":40, "xp":1500, "color":Color("2a2730")},
	{"name":"Dunkler kleiner Golem", "region":12, "hp":4320, "damage":47, "speed":52, "xp":300, "color":Color("3d3945")}
]
const BASE_ABILITIES := [
	{"name":"Wirbelhieb", "desc":"Kreisender Nahkampfschlag", "cost":28, "cd":6.0, "req":3, "kind":0},
	{"name":"Schildwall", "desc":"Schutz für wenige Sekunden", "cost":24, "cd":12.0, "req":8, "kind":1},
	{"name":"Sturmsprung", "desc":"Sprung und Betäubung", "cost":30, "cd":9.0, "req":12, "kind":2},
	{"name":"Klingenwelle", "desc":"Geschoss durch Gegner", "cost":28, "cd":6.0, "req":15, "kind":3},
	{"name":"Kampfschrei", "desc":"Mehr Schaden für 6 Sekunden", "cost":24, "cd":14.0, "req":3, "kind":4},
	{"name":"Erdspalter", "desc":"Starker Schlag und Betäubung", "cost":34, "cd":10.0, "req":18, "kind":5},
	{"name":"Lebensraub", "desc":"Treffer heilen dich", "cost":30, "cd":13.0, "req":5, "kind":6},
	{"name":"Klingenregen", "desc":"Drei Klingen nach vorn", "cost":38, "cd":11.0, "req":23, "kind":7},
	{"name":"Eiserne Haut", "desc":"Heilung und Schutz", "cost":35, "cd":18.0, "req":7, "kind":8},
	{"name":"Klingenmeister", "desc":"Passiv: +5 Schwertschaden", "cost":0, "cd":0.0, "req":2, "kind":9},
	{"name":"Lebenskraft", "desc":"Passiv: +25 maximales Leben", "cost":0, "cd":0.0, "req":3, "kind":10},
	{"name":"Ausdauer", "desc":"Passiv: +25 maximale Energie", "cost":0, "cd":0.0, "req":4, "kind":11},
	{"name":"Frostschlag", "desc":"Eis: Schaden und Verlangsamung", "cost":28, "cd":7.0, "req":28, "kind":12},
	{"name":"Blitzkette", "desc":"Blitz: springt auf 3 Gegner", "cost":38, "cd":10.0, "req":34, "kind":13},
	{"name":"Giftklinge", "desc":"Gift: 8 Sek. vergiftete Hiebe", "cost":26, "cd":15.0, "req":35, "kind":14},
	{"name":"Avatar der Morgenwache", "desc":"Goldene Welle und Schutz", "cost":60, "cd":45.0, "req":20, "kind":15},
	{"name":"Feuerball", "desc":"Feuerprojektil mit Explosion", "cost":23, "cd":4.0, "req":3, "kind":16},
	{"name":"Frostnova", "desc":"Eiskreis verlangsamt Gegner", "cost":29, "cd":8.0, "req":8, "kind":17},
	{"name":"Blitzlanze", "desc":"Blitz durch mehrere Ziele", "cost":34, "cd":7.0, "req":12, "kind":18},
	{"name":"Rissnova", "desc":"Arkane Druckwelle um den Magier", "cost":27, "cd":9.0, "req":15, "kind":19},
	{"name":"Sternenfunken", "desc":"Drei magische Geschosse", "cost":32, "cd":8.0, "req":18, "kind":20},
	{"name":"Eisschild", "desc":"Schützt und friert Angreifer", "cost":30, "cd":15.0, "req":23, "kind":21},
	{"name":"Meteorschauer", "desc":"Feuer trifft eine Fläche", "cost":44, "cd":18.0, "req":28, "kind":22},
	{"name":"Elementarwirbel", "desc":"Eis, Blitz und Feuer im Kreis", "cost":49, "cd":21.0, "req":34, "kind":23},
	{"name":"Arkaner Sturm", "desc":"Ultimate ab Level 40: Elementarwellen", "cost":60, "cd":45.0, "req":40, "kind":24},
	{"name":"Präzisionsschuss", "desc":"Gezielter Schuss mit Durchschlag", "cost":22, "cd":5.0, "req":3, "kind":25},
	{"name":"Mehrfachschuss", "desc":"Drei Pfeile im Fächer", "cost":27, "cd":7.0, "req":8, "kind":26},
	{"name":"Rückwärtssprung", "desc":"Abstand gewinnen und ausweichen", "cost":23, "cd":9.0, "req":12, "kind":27},
	{"name":"Giftpfeil", "desc":"Giftiger Schuss mit Nachwirkung", "cost":29, "cd":8.0, "req":15, "kind":28},
	{"name":"Frostpfeil", "desc":"Eisiger Pfeil bremst Gegner", "cost":30, "cd":9.0, "req":18, "kind":29},
	{"name":"Blitzpfeil", "desc":"Springender Blitz am Ziel", "cost":34, "cd":10.0, "req":23, "kind":30},
	{"name":"Pfeilhagel", "desc":"Pfeile fallen im Zielbereich", "cost":44, "cd":17.0, "req":28, "kind":31},
	{"name":"Falkenruf", "desc":"Markiert Feinde und stärkt Treffer", "cost":37, "cd":20.0, "req":34, "kind":32},
	{"name":"Himmelshagel", "desc":"Klassenfähigkeit: großer Pfeilsturm", "cost":60, "cd":45.0, "req":20, "kind":33},
	{"name":"Impulsschuss", "desc":"Robotischer Energieschuss", "cost":24, "cd":5.0, "req":3, "kind":34},
	{"name":"Reparaturmodul", "desc":"Repariert sofort einen Teil deiner Lebenspunkte", "cost":30, "cd":16.0, "req":8, "kind":35},
	{"name":"Energieschild", "desc":"Technischer Schild reduziert eingehenden Schaden", "cost":32, "cd":15.0, "req":12, "kind":36},
	{"name":"Teslawelle", "desc":"Elektrische Welle trifft Gegner im Umkreis", "cost":36, "cd":10.0, "req":15, "kind":37},
	{"name":"Zielmatrix", "desc":"Überclockt Angriffe für kurze Zeit", "cost":28, "cd":18.0, "req":18, "kind":38},
	{"name":"EMP-Stoß", "desc":"Betäubt Gegner im Umkreis", "cost":42, "cd":18.0, "req":23, "kind":39},
	{"name":"Flammenwirbel", "desc":"Fusion aus Wirbelhieb und Feuerball", "cost":42, "cd":12.0, "req":15, "kind":40},
	{"name":"Reaktorwall", "desc":"Fusion aus Schildwall und Energieschild", "cost":38, "cd":20.0, "req":15, "kind":41},
	{"name":"Blitzkern", "desc":"Fusion aus Blitzlanze und Teslawelle", "cost":48, "cd":16.0, "req":23, "kind":42},
	{"name":"Eisball", "desc":"Fusion aus Frostnova und Blitzlanze · 4 Entwicklungsstufen", "cost":40, "cd":10.0, "req":12, "kind":43}
]
const QUESTS := [
	{"title":"Schleime im Blütenwald", "npc":"Mira", "target":0, "count":8, "xp":60, "gold":75, "reward":"Waldklinge"},
	{"title":"Die Käferplage", "npc":"Mira", "target":1, "count":8, "xp":85, "gold":110, "reward":"Blütenanhänger"},
	{"title":"Pilze auf Beinen", "npc":"Mira", "target":2, "count":9, "xp":110, "gold":130, "reward":"Waldelixier"},
	{"title":"Wölfe im Pilzwald", "npc":"Mira", "target":3, "count":9, "xp":140, "gold":160, "reward":"Wolfszahn"},
	{"title":"Die alten Wächter", "npc":"Mira", "target":4, "count":9, "xp":190, "gold":220, "reward":"Wächterschild"},
	{"title":"Spuk in den Ruinen", "npc":"Mira", "target":5, "count":9, "xp":230, "gold":250, "reward":"Geisterklinge"},
	{"title":"Kristallfieber", "npc":"Mira", "target":6, "count":10, "xp":270, "gold":300, "reward":"Kristallherz"},
	{"title":"Splitter im Mondlicht", "npc":"Mira", "target":7, "count":10, "xp":320, "gold":360, "reward":"Splitterkrone"},
	{"title":"Asche vor den Toren", "npc":"Mira", "target":8, "count":11, "xp":380, "gold":420, "reward":"Aschenklinge"},
	{"title":"Herz aus Glut", "npc":"Mira", "target":9, "count":11, "xp":550, "gold":600, "reward":"Glutbrecher"},
	{"title":"Krabben am Strand", "npc":"Mira", "target":10, "count":8, "xp":110, "gold":140, "reward":"Muschelring"},
	{"title":"Stimmen im Wasser", "npc":"Mira", "target":11, "count":8, "xp":180, "gold":220, "reward":"Gezeitenstein"},
	{"title":"Der Kriegsherr", "npc":"Mira", "target":12, "count":1, "xp":600, "gold":750, "reward":"Kampfsiegel"},
	{"title":"Der Dunkle Arkanhüter", "npc":"Mira", "target":13, "count":1, "xp":800, "gold":950, "reward":"Arkankern"},
	{"title":"Der Jagdmeister", "npc":"Mira", "target":14, "count":1, "xp":1100, "gold":1300, "reward":"Jagdzeichen"},
	{"title":"Spuren im Nebel", "npc":"Mira", "target":17, "count":9, "xp":310, "gold":280, "reward":"Nebelamulett"},
	{"title":"Lichter ohne Namen", "npc":"Mira", "target":18, "count":9, "xp":360, "gold":325, "reward":"Lichtsplitter"},
	{"title":"Das goldene Harz", "npc":"Mira", "target":19, "count":10, "xp":610, "gold":490, "reward":"Harzpanzer"},
	{"title":"Wurzeln der Plage", "npc":"Mira", "target":20, "count":10, "xp":680, "gold":540, "reward":"Wurzelring"},
	{"title":"Die versunkene Quelle", "npc":"Mira", "target":21, "count":11, "xp":880, "gold":760, "reward":"Quellensiegel"},
	{"title":"Perlen im Dunkel", "npc":"Mira", "target":22, "count":11, "xp":960, "gold":820, "reward":"Perlenring"},
	{"title":"Ruf vom Dämmergrat", "npc":"Mira", "target":23, "count":12, "xp":1200, "gold":1080, "reward":"Greifenfeder"},
	{"title":"Ritter der letzten Nacht", "npc":"Mira", "target":24, "count":12, "xp":1380, "gold":1180, "reward":"Dämmerrüstung"},
	{"title":"Flügel über dem Garten", "npc":"Mira", "target":25, "count":13, "xp":1750, "gold":1500, "reward":"Himmelslicht"},
	{"title":"Die letzte Wache", "npc":"Mira", "target":26, "count":13, "xp":2100, "gold":1750, "reward":"Sternenring"}
]
const BORIN_QUESTS := [
	{"title":"Borins erste Prüfung","req":3,"target":0,"count":6,"skill_points":1,"item_rarity":1,"item_power":9},
	{"title":"Borins Meisterprobe","req":20,"target":19,"count":8,"skill_points":2,"item_rarity":2,"item_power":30},
	{"title":"Borins letzte Lehre","req":39,"target":25,"count":10,"skill_points":3,"item_rarity":3,"item_power":58}
]
const NPCS := [
	{"name":"Mira", "role":"Älteste · alle Sonnenhain-Quests", "pos":Vector2(1312, 1394), "color":Color("a77ccb"), "kind":"quest"},
	{"name":"Borin", "role":"Skillzauberer · Fähigkeiten", "pos":Vector2(1472, 486), "color":Color("6783bd"), "kind":"quest"},
	{"name":"Liora", "role":"Forscherin · Wissen & Quest-Hinweise", "pos":Vector2(1312, 1394), "color":Color("6bbba4"), "kind":"quest"},
	{"name":"Torvald", "role":"Schmied · Waffenmeister", "pos":Vector2(374, 565), "color":Color("ab6e60"), "kind":"smith"},
	{"name":"Fenna", "role":"Stilistin · Character Editor", "pos":Vector2(240, 1043), "color":Color("c080aa"), "kind":"stylist"},
	{"name":"Pip", "role":"Borins Lehrling", "pos":Vector2(1472, 486), "color":Color("9f8bcc"), "kind":"apprentice"},
	{"name":"Elara", "role":"Heilerin · Tränke & Alchemie", "pos":Vector2(380, 1577), "color":Color("e2bc91"), "kind":"healer_alchemy"},
	{"name":"Arven", "role":"Arenameister · Endlose Prüfung", "pos":Vector2(1081,2460), "color":Color("a48cbd"), "kind":"arena"}
]
const SHOPS := {
	"smith": [{"name":"Frostklinge", "icon":"sword", "power":9, "price":320, "element":"eis"}, {"name":"Blitzsäbel", "icon":"sword", "power":17, "price":750, "element":"blitz"}, {"name":"Giftklinge", "icon":"sword", "power":25, "price":1300, "element":"gift"}],
	"alchemy": [{"name":"Heiltrank", "icon":"potion", "power":0, "price":35}, {"name":"Großer Heiltrank", "icon":"potion", "power":0, "price":85}, {"name":"Energietrank", "icon":"potion", "power":0, "price":45}],
	"merchant": [{"name":"Reisenderumhang", "icon":"armor", "power":4, "price":125}, {"name":"Wächterrüstung", "icon":"armor", "power":9, "price":520}, {"name":"Glücksring", "icon":"ring", "power":15, "price":240}]
}
const WORLD_EVENTS := [
	{"name":"Tessa", "role":"Botenläuferin", "pos":Vector2(2470, 1630), "region":1, "goal":3, "xp":90, "gold":40, "story":"Die Dornen folgen dem Rauch aus Blütenweiler. Halte den Weg frei!", "after":"Der Weg ist frei. Ich läute die Glocke im Dorf!"},
	{"name":"Odo", "role":"Fährmann", "pos":Vector2(1050, 4530), "region":6, "goal":3, "xp":170, "gold":75, "story":"Etwas zieht die Netze in die Tiefe. Beschütze den Anleger!", "after":"Die Netze sind sicher. Im Westen sah ich ein Licht unter dem Wasser."},
	{"name":"Rika", "role":"Pilzsammlerin", "pos":Vector2(4220, 1590), "region":1, "goal":4, "xp":230, "gold":95, "story":"Sporen kriechen aus dem Pilzwald. Hilf mir, die Lichtung zu halten!", "after":"Die Lichtung lebt wieder. Folge den violetten Sporen zum alten Turm."},
	{"name":"Serin", "role":"Ruinenkundiger", "pos":Vector2(5950, 1760), "region":3, "goal":4, "xp":490, "gold":160, "story":"Ich fand Siegelzeichen des Turmwächters. Vertreibe seine Streuner!", "after":"Das Siegel stammt vom Kristallaltar. Dort beginnt die nächste Spur."}
]
const LANDMARKS := [
	{"pos":RESCUE_POS, "name":"Blütenweiler", "kind":"hamlet"},
	{"pos":Vector2(3550, 6500), "name":"Pilzlichtung", "kind":"mushroom"},
	{"pos":Vector2(7150, 2200), "name":"Verfallener Turm", "kind":"tower"},
	{"pos":Vector2(7200, 6500), "name":"Kristallaltar", "kind":"shrine"},
	{"pos":Vector2(9700, 6500), "name":"Sternenbruchtor", "kind":"gate"},
	{"pos":Vector2(750, 6100), "name":"Alter Hafen", "kind":"dock"},
	{"pos":Vector2(14100, 1020), "name":"Schlafende Glocke", "kind":"shrine"},
	{"pos":Vector2(14300, 2970), "name":"Harzkönigsbaum", "kind":"mushroom"},
	{"pos":Vector2(14000, 4800), "name":"Versunkener Brunnen", "kind":"shrine"},
	{"pos":Vector2(14500, 6790), "name":"Wachtfeuer am Grat", "kind":"tower"},
	{"pos":Vector2(14400, 8710), "name":"Himmelskrone", "kind":"gate"}
]
const TRAILS := [
	[Vector2(900, 960), Vector2(1160, 960), Vector2(1450, 950), Vector2(1650, 1010), Vector2(1780, 1120), Vector2(2250, 1280), Vector2(2600, 1740), Vector2(3150, 2350)],
	[Vector2(3150, 2350), Vector2(3300, 1900), Vector2(3800, 1520), Vector2(4450, 1390), Vector2(5000, 1250), Vector2(5600, 1380), Vector2(6300, 1660), Vector2(6700, 1950), Vector2(7150, 2200), Vector2(7870, 1790), Vector2(8500, 1900), Vector2(9200, 1750), Vector2(9700, 1850)],
	[Vector2(3150, 2350), Vector2(2990, 2950), Vector2(2720, 3550), Vector2(2900, 4200), Vector2(3150, 4780), Vector2(3000, 5350), Vector2(3200, 6200), Vector2(3550, 6500), Vector2(4210, 6040), Vector2(5000, 6200), Vector2(5600, 5840), Vector2(6700, 6250), Vector2(7200, 6500), Vector2(7900, 6110), Vector2(8500, 6350)],
	[Vector2(900, 1300), Vector2(875, 2600), Vector2(1040, 3300), Vector2(820, 3950), Vector2(1080, 4770), Vector2(790, 5430), Vector2(750, 6100), Vector2(1170, 5980), Vector2(1780, 6200), Vector2(2350, 5920), Vector2(3200, 6200)],
	[Vector2(7150, 2200), Vector2(7020, 2940), Vector2(6550, 3510), Vector2(6600, 4200), Vector2(6830, 5060), Vector2(6700, 6250)],
	[Vector2(9700, 1850), Vector2(10100, 2650), Vector2(9750, 3900), Vector2(9340, 4650), Vector2(9500, 5600), Vector2(8500, 6350)],
	[Vector2(11850,930),Vector2(12200,720),Vector2(12800,1050),Vector2(13500,950),Vector2(14000,1320),Vector2(15000,1010)],
	[Vector2(11850,2810),Vector2(12300,3090),Vector2(13000,2720),Vector2(13500,2850),Vector2(14300,2970),Vector2(15100,2780)],
	[Vector2(11850,4720),Vector2(12500,4450),Vector2(13000,5100),Vector2(13500,4750),Vector2(14000,4800),Vector2(15000,4940)],
	[Vector2(11850,6630),Vector2(12500,6940),Vector2(13100,6320),Vector2(13500,6650),Vector2(14500,6790),Vector2(15100,6450)],
	[Vector2(11850,8500),Vector2(12500,8270),Vector2(13200,8860),Vector2(13500,8550),Vector2(14400,8710),Vector2(15200,8460)]
]
