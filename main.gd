extends Node2D

const NetworkManager = preload("res://scripts/network/network_manager.gd")
const MobCatalog = preload("res://scripts/enemies/mob_catalog.gd")
const MobAnimation = preload("res://scripts/enemies/mob_animation.gd")
const ItemProtection = preload("res://scripts/inventory/item_protection.gd")
const MinimapRenderer = preload("res://scripts/ui/minimap_renderer.gd")
const MovementRules = preload("res://scripts/player/movement_rules.gd")
const SaveMigrator = preload("res://scripts/save/save_migrator.gd")

# Sonnenhain: ein eigenständiger, erweiterbarer Godot-4-Prototyp.
const VIEW := Vector2(1152, 648)
const WORLD := Vector2(16000, 9600)
const GATE_HALF_WIDTH := 175.0
const GAME_VERSION := "v28.0"
const UFO_WRECK_POS := Vector2(1035, 8170)
const UFO_CHEST_POS := Vector2(1235, 8010)
const SAVE_PATH := "user://sonnenhain_save.json"
const CREATIVE_SAVE_PATH := "user://sonnenhain_testmodus.json"
const CONTROLS_PATH := "user://sonnenhain_tasten.json"
const BIND_ACTIONS := ["move_up", "move_down", "move_left", "move_right", "attack", "dodge", "interact", "waystone", "heal", "resource", "ability_1", "ability_2", "ability_3", "ability_4", "skills", "inventory", "journal", "map", "pause"]
const BIND_NAMES := ["Nach oben", "Nach unten", "Nach links", "Nach rechts", "Angriff", "Ausweichen", "Interagieren", "Wegstein", "Heiltrank", "Energie / Mana", "Fähigkeit 1", "Fähigkeit 2", "Fähigkeit 3", "Fähigkeit 4", "Skillbuch", "Inventar", "Questbuch", "Weltkarte", "Pause"]
const DEFAULT_BINDINGS := {"move_up":KEY_W, "move_down":KEY_S, "move_left":KEY_A, "move_right":KEY_D, "attack":-MOUSE_BUTTON_LEFT, "dodge":KEY_SPACE, "interact":KEY_E, "waystone":KEY_F, "heal":KEY_Q, "resource":KEY_R, "ability_1":KEY_1, "ability_2":KEY_2, "ability_3":KEY_3, "ability_4":KEY_4, "skills":KEY_K, "inventory":KEY_I, "journal":KEY_J, "map":KEY_M, "pause":KEY_ESCAPE}
const FONT_COLOR := Color("f7f0d0")
const INK := Color("26383c")
const RARITY_NAMES := ["Gewöhnlich", "Ungewöhnlich", "Selten", "Episch", "Legendär"]
const RARITY_COLORS := [Color("d9dfd6"), Color("75d891"), Color("72bafa"), Color("c995f1"), Color("f7c861")]
# Reihenfolge: Dorf, Blütenwiesen, Pilzwald, Ruinen, Kristallmoor, Ascheberge, Küste, Sternenbruch.
const REGION_LEVELS := [1, 1, 8, 15, 22, 29, 5, 36, 12, 19, 26, 33, 40]
const NEW_REGION_NAMES := ["Nebelheide", "Bernsteinforst", "Tiefenquell", "Dämmergrat", "Himmelsgarten"]
const PORTALS := [
	[Vector2(3690, 6810), Vector2(11850, 930), 8],
	[Vector2(7590, 2590), Vector2(11850, 2810), 9],
	[Vector2(7610, 6830), Vector2(11850, 4720), 10],
	[Vector2(10100, 2750), Vector2(11850, 6630), 11],
	[Vector2(9820, 6750), Vector2(11850, 8500), 12]
]
const SFX_NAMES := ["step", "swing", "hit", "dodge", "pickup", "level", "menu", "skill_0", "skill_1", "skill_2", "skill_3", "skill_4", "skill_5", "skill_6", "skill_7", "skill_8", "skill_12", "skill_13", "skill_14", "skill_15", "skill_16", "skill_17", "skill_18", "skill_19", "skill_20", "skill_21", "skill_22", "skill_23", "skill_24", "skill_25", "skill_26", "skill_27", "skill_28", "skill_29", "skill_30", "skill_31", "skill_32", "skill_33"]
const MUSIC_THEMES := ["dorf", "blumen", "pilzwald", "ruinen", "kristall", "asche", "kueste", "sternen", "nebel", "bernstein", "quelle", "daemmer", "himmel"]
const CUSTOM_MUSIC_THEMES := ["dorf", "blumen", "kueste", "pilzwald", "ruinen", "kristall", "asche", "sternen"]
const MUSIC_FADE_SECONDS := 1.35
var ENEMY_TYPES: Array = []
const ABILITIES := [
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
	{"name":"Arkaner Schritt", "desc":"Kurzer Teleport und Schutz", "cost":25, "cd":10.0, "req":15, "kind":19},
	{"name":"Sternenfunken", "desc":"Drei magische Geschosse", "cost":32, "cd":8.0, "req":18, "kind":20},
	{"name":"Eisschild", "desc":"Schützt und friert Angreifer", "cost":30, "cd":15.0, "req":23, "kind":21},
	{"name":"Meteorschauer", "desc":"Feuer trifft eine Fläche", "cost":44, "cd":18.0, "req":28, "kind":22},
	{"name":"Elementarwirbel", "desc":"Eis, Blitz und Feuer im Kreis", "cost":49, "cd":21.0, "req":34, "kind":23},
	{"name":"Arkaner Sturm", "desc":"Klassenfähigkeit: Elementarwellen", "cost":60, "cd":45.0, "req":20, "kind":24},
	{"name":"Präzisionsschuss", "desc":"Gezielter Schuss mit Durchschlag", "cost":22, "cd":5.0, "req":3, "kind":25},
	{"name":"Mehrfachschuss", "desc":"Drei Pfeile im Fächer", "cost":27, "cd":7.0, "req":8, "kind":26},
	{"name":"Rückwärtssprung", "desc":"Abstand gewinnen und ausweichen", "cost":23, "cd":9.0, "req":12, "kind":27},
	{"name":"Giftpfeil", "desc":"Giftiger Schuss mit Nachwirkung", "cost":29, "cd":8.0, "req":15, "kind":28},
	{"name":"Frostpfeil", "desc":"Eisiger Pfeil bremst Gegner", "cost":30, "cd":9.0, "req":18, "kind":29},
	{"name":"Blitzpfeil", "desc":"Springender Blitz am Ziel", "cost":34, "cd":10.0, "req":23, "kind":30},
	{"name":"Pfeilhagel", "desc":"Pfeile fallen im Zielbereich", "cost":44, "cd":17.0, "req":28, "kind":31},
	{"name":"Falkenruf", "desc":"Markiert Feinde und stärkt Treffer", "cost":37, "cd":20.0, "req":34, "kind":32},
	{"name":"Himmelshagel", "desc":"Klassenfähigkeit: großer Pfeilsturm", "cost":60, "cd":45.0, "req":20, "kind":33}
]
const CLASS_NAMES := ["Krieger", "Magier", "Bogenschütze"]
const CLASS_ADVANTAGES := [
	"+ Nahkampf · robust · Schild · Rolle",
	"+ Magie · Flächenzauber · 2 Ringe",
	"+ schnell · Fernkampf · starke Rolle"
]
const CLASS_DISADVANTAGES := [
	"- kurze Reichweite · weniger mobil",
	"- keine Rolle · schwächer im Nahkampf",
	"- weniger robust · Nahkampf schwächer"
]
const RACE_ADVANTAGES := [
	"+ ausgeglichene Werte",
	"+ 25% HP · starker Nahkampf/Handwaffen",
	"+ hohe Verteidigung · stabil"
]
const RACE_DISADVANTAGES := [
	"- keine extreme Spezialisierung",
	"- deutlich langsamer",
	"- etwas langsamer als Mensch"
]
const CLASS_SKILLS := [[0, 1, 2, 3, 5, 7, 12, 13, 14], [16, 17, 18, 19, 20, 21, 22, 23], [25, 26, 27, 28, 29, 30, 31, 32]]
const CLASS_ULTIMATES := [15, 24, 33]
const QUESTS := [
	{"title":"Schleime im Blütenwald", "npc":"Mira", "target":0, "count":8, "xp":60, "gold":75, "reward":"Waldklinge"},
	{"title":"Die Käferplage", "npc":"Mira", "target":1, "count":8, "xp":85, "gold":110, "reward":"Blütenanhänger"},
	{"title":"Pilze auf Beinen", "npc":"Liora", "target":2, "count":9, "xp":110, "gold":130, "reward":"Waldelixier"},
	{"title":"Wölfe im Pilzwald", "npc":"Borin", "target":3, "count":9, "xp":140, "gold":160, "reward":"Wolfszahn"},
	{"title":"Die alten Wächter", "npc":"Borin", "target":4, "count":9, "xp":190, "gold":220, "reward":"Wächterschild"},
	{"title":"Spuk in den Ruinen", "npc":"Mira", "target":5, "count":9, "xp":230, "gold":250, "reward":"Geisterklinge"},
	{"title":"Kristallfieber", "npc":"Liora", "target":6, "count":10, "xp":270, "gold":300, "reward":"Kristallherz"},
	{"title":"Splitter im Mondlicht", "npc":"Liora", "target":7, "count":10, "xp":320, "gold":360, "reward":"Splitterkrone"},
	{"title":"Asche vor den Toren", "npc":"Borin", "target":8, "count":11, "xp":380, "gold":420, "reward":"Aschenklinge"},
	{"title":"Herz aus Glut", "npc":"Borin", "target":9, "count":11, "xp":550, "gold":600, "reward":"Glutbrecher"},
	{"title":"Krabben am Strand", "npc":"Mira", "target":10, "count":8, "xp":110, "gold":140, "reward":"Muschelring"},
	{"title":"Stimmen im Wasser", "npc":"Liora", "target":11, "count":8, "xp":180, "gold":220, "reward":"Gezeitenstein"},
	{"title":"Der Turmwächter", "npc":"Borin", "target":12, "count":1, "xp":600, "gold":750, "reward":"Turmklinge"},
	{"title":"Hüter des Kristalls", "npc":"Liora", "target":13, "count":1, "xp":800, "gold":950, "reward":"Frostherz"},
	{"title":"Der Aschefürst", "npc":"Mira", "target":14, "count":1, "xp":1100, "gold":1300, "reward":"Fürstenklinge"},
	{"title":"Spuren im Nebel", "npc":"Liora", "target":17, "count":9, "xp":310, "gold":280, "reward":"Nebelamulett"},
	{"title":"Lichter ohne Namen", "npc":"Mira", "target":18, "count":9, "xp":360, "gold":325, "reward":"Lichtsplitter"},
	{"title":"Das goldene Harz", "npc":"Borin", "target":19, "count":10, "xp":610, "gold":490, "reward":"Harzpanzer"},
	{"title":"Wurzeln der Plage", "npc":"Liora", "target":20, "count":10, "xp":680, "gold":540, "reward":"Wurzelring"},
	{"title":"Die versunkene Quelle", "npc":"Mira", "target":21, "count":11, "xp":880, "gold":760, "reward":"Quellensiegel"},
	{"title":"Perlen im Dunkel", "npc":"Liora", "target":22, "count":11, "xp":960, "gold":820, "reward":"Perlenring"},
	{"title":"Ruf vom Dämmergrat", "npc":"Borin", "target":23, "count":12, "xp":1200, "gold":1080, "reward":"Greifenfeder"},
	{"title":"Ritter der letzten Nacht", "npc":"Mira", "target":24, "count":12, "xp":1380, "gold":1180, "reward":"Dämmerrüstung"},
	{"title":"Flügel über dem Garten", "npc":"Liora", "target":25, "count":13, "xp":1750, "gold":1500, "reward":"Himmelslicht"},
	{"title":"Die letzte Wache", "npc":"Borin", "target":26, "count":13, "xp":2100, "gold":1750, "reward":"Sternenring"}
]
const NPCS := [
	{"name":"Mira", "role":"Älteste · Quests", "pos":Vector2(1010, 1070), "color":Color("a77ccb"), "kind":"quest"},
	{"name":"Borin", "role":"Wächter · Quests", "pos":Vector2(1230, 890), "color":Color("6783bd"), "kind":"quest"},
	{"name":"Liora", "role":"Forscherin · Quests", "pos":Vector2(690, 1280), "color":Color("6bbba4"), "kind":"quest"},
	{"name":"Torvald", "role":"Schmied", "pos":Vector2(490, 930), "color":Color("ab6e60"), "kind":"smith"},
	{"name":"Fenna", "role":"Händlerin", "pos":Vector2(1080, 460), "color":Color("87a66b"), "kind":"merchant"},
	{"name":"Pip", "role":"Alchemist", "pos":Vector2(1360, 580), "color":Color("d3aa65"), "kind":"alchemy"},
	{"name":"Elara", "role":"Heilerin · Vollheilung", "pos":Vector2(830, 940), "color":Color("e2bc91"), "kind":"healer"},
	{"name":"Arven", "role":"Arenameister · Endlose Prüfung", "pos":Vector2(1240, 1290), "color":Color("a48cbd"), "kind":"arena"}
]
const SHOPS := {
	"smith": [{"name":"Frostklinge", "icon":"sword", "power":9, "price":320, "element":"eis"}, {"name":"Blitzsäbel", "icon":"sword", "power":17, "price":750, "element":"blitz"}, {"name":"Giftklinge", "icon":"sword", "power":25, "price":1300, "element":"gift"}],
	"alchemy": [{"name":"Heiltrank", "icon":"potion", "power":0, "price":35}, {"name":"Großer Heiltrank", "icon":"potion", "power":0, "price":85}, {"name":"Energietrank", "icon":"potion", "power":0, "price":45}],
	"merchant": [{"name":"Reisenderumhang", "icon":"armor", "power":4, "price":125}, {"name":"Wächterrüstung", "icon":"armor", "power":9, "price":520}, {"name":"Glücksring", "icon":"ring", "power":15, "price":240}]
}
const WAYSTONES := [Vector2(880, 1300), Vector2(3300, 1900), Vector2(3200, 6200), Vector2(6700, 1950), Vector2(6700, 6250), Vector2(9750, 3900), Vector2(1000, 6100), Vector2(13500, 950), Vector2(13500, 2850), Vector2(13500, 4750), Vector2(13500, 6650), Vector2(13500, 8550)]
const RESCUE_POS := Vector2(3150, 2350)
const RESCUE_GOAL := 20
const ARENA_CENTER := Vector2(8000, 4800)
const ARENA_RADIUS := 490.0
const DUNGEON_CENTER := Vector2(8000, 4800)
const DUNGEON_ENTRANCES := [2, 3, 8]
const DUNGEON_NAMES := ["Turmgewölbe", "Kristallgruft", "Versunkene Krypta"]
const DUNGEON_ENEMIES := [[4, 5], [6, 7], [21, 22]]
const TAVERN_HOUSE := Vector2(1180, 1510)
const INTERIOR_CENTER := Vector2(8000, 4800)
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
	[Vector2(900, 1050), Vector2(1270, 1110), Vector2(1780, 1120), Vector2(2250, 1280), Vector2(2600, 1740), Vector2(3150, 2350)],
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

var player_pos := Vector2(900, 1050)
var facing := Vector2.RIGHT
var camera_pos := Vector2.ZERO
var hp := 100.0
var energy := 100.0
var level := 1
var xp := 0
var gold := 55
var skill_points := 0
var class_id := 0
var pending_class := 0
var learned: Array = []
var skill_levels: Array = []
var slots: Array = [-1, -1, -1]
var selected_slot := 0
var cooldowns: Array = []
var inventory: Array = []
var equipped_uid := -1
var equipped_armor_uid := -1
var equipped_ring_uid := -1
var equipped_ring2_uid := -1
var next_uid := 1
var selected_item := -1
var inventory_page := 0
var quests: Array = []
var enemies: Array = []
var drops: Array = []
var effects: Array = []
var spell_visuals: Array = []
var poison_clouds: Array = []
var impact_zones: Array = []
var projectiles: Array = []
var enemy_projectiles: Array = []
var last_waystone := 1
var waystone_unlocked: Array = [true, false, false, false, false, false, false, false, false, false, false, false]
var shop_timer := 0.0
var shop_stock: Dictionary = {}
var previous_region := 0
var discovered_regions: Array = [true, false, false, false, false, false, false, false, false, false, false, false, false]
var opened_chests: Array = [false, false, false, false, false, false, false, false, false, false, false]
var ufo_chest_opened := false
var obstacle_cache: Dictionary = {}
var boss_cooldowns: Array = [0.0, 0.0, 0.0]
var bosses_defeated: Array = [false, false, false]
var final_completed := false
var final_countdown := -1.0
var arena_mode := ""
var arena_wave := 0
var arena_intermission := 0.0
var arena_reward_claimed := false
var arena_return_pos := Vector2(900, 1050)
var arena_leaderboard: Array = []
var arena_best := 0
var arena_reward_wave := 0
var arena_pending_loaded := false
var dungeon_id := -1
var dungeon_return_pos := Vector2(900, 1050)
var interior_id := -1
var interior_return_pos := Vector2(900, 1050)
var environment_tiles: Texture2D
var region_tiles: Texture2D
var weapon_sprites: Texture2D
var weapon_world_sprites: Texture2D
var character_sprites: Texture2D
var enemy_sprites: Texture2D
var skill_sprites: Texture2D
var npc_sprites: Texture2D
var vfx_sprites: Texture2D
var structure_tiles: Texture2D
var house_tiles: Texture2D
var dungeon_chests_opened: Array = [false, false, false]
var battle_zones: Array = []
var active_save_slot := 1
var selected_save_slot := 1
var save_slot_labels: Array = []
var rescue_state := 0 # 0: unbekannt, 1: Angriff, 2: gerettet, 3: Belohnung abgeholt
var rescue_kills := 0
var rescue_intro_timer := 0.0
var rescue_banner_timer := 0.0
var reward_scene_timer := 0.0
var attack_timer := 0.0
var swing_timer := 0.0
var dash_timer := 0.0
var dash_cooldown := 0.0
var invulnerable := 0.0
var shield_timer := 0.0
var rage_timer := 0.0
var drain_timer := 0.0
var poison_blade_timer := 0.0
var lightning_lines: Array = []
var dash_dir := Vector2.RIGHT
var spawn_timer := 0.0
var save_timer := 0.0
var notice := ""
var notice_timer := 0.0
var panel := ""
var bindings: Dictionary = {}
var awaiting_bind := ""
var controls_status := "Klicke eine Belegung an und drücke die gewünschte Taste."
var controls_return_panel := "pause"
var sell_all_confirm := false
var pending_purchase := -1
var pending_purchase_item: Dictionary = {}
var merchant_kind := ""
var menu_scroll := 0
var attack_anim := 0.0
var swing_duration := 0.24
var world_time := 0.0
var walk_phase := 0.0
var is_walking := false
var step_timer := 0.0
var music_player: AudioStreamPlayer
var music_incoming: AudioStreamPlayer
var music_theme := ""
var music_fading := false
var music_fade_elapsed := 0.0
var music_enabled := true
var music_volume := 0.90
var effects_volume := 0.75
var intro_timer := 0.0
var event_states: Array = []
var event_progress: Array = []
var creative_mode := false
var pause_status := "Das Spiel ist angehalten."
var sound_players: Array = []
var sound_streams: Dictionary = {}
var next_sound_player := 0
var font: Font

# v27: einmalige Charaktererstellung, Chat und Koop-Multiplayer.
var hero_name := ""
var hero_gender := 0 # 0 Mann, 1 Frau
var hero_race := 0 # 0 Mensch, 1 Ork, 2 Roboter
var pending_gender := 0
var pending_race := 0
var creation_name := ""
var character_created := false
var chat_open := false
var chat_input := ""
var chat_messages: Array = []
var chat_fade := 0.0
var mechanics_page := 0
var network_mode := "offline"
var network_status := "Offline"
var network_port := 27844
var network_server_url := "wss://game.sonnenhainrpg.de"
var dedicated_server := false
var invite_code := ""
var join_code := ""
var remote_players: Dictionary = {}
var local_peer_id := 1
var sync_timer := 0.0
var network_manager: Node
const GENDER_NAMES := ["Mann", "Frau"]
const RACE_NAMES := ["Mensch", "Ork", "Roboter"]
const RACE_PROFILE_PATHS := [
	"res://data/races/mensch.tres",
	"res://data/races/ork.tres",
	"res://data/races/roboter.tres"
]
const CLASS_PROFILE_PATHS := [
	"res://data/classes/krieger.tres",
	"res://data/classes/magier.tres",
	"res://data/classes/bogenschuetze.tres"
]

func _ready() -> void:
	dedicated_server = OS.has_feature("dedicated_server") or "--dedicated-server" in OS.get_cmdline_args()
	ENEMY_TYPES = MobCatalog.legacy_types()
	if ENEMY_TYPES.size() != 27:
		push_error("Mob-Katalog unvollständig: %d/27 Gegnerdaten geladen." % ENEMY_TYPES.size())
	if OS.is_debug_build():
		for mob_error in MobCatalog.validate():
			push_error(mob_error)
	font = ThemeDB.fallback_font
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	environment_tiles = load("res://art/sonnenhain_tiles.png")
	region_tiles = load("res://art/regions_16.png")
	weapon_sprites = load("res://art/weapons_32.png")
	weapon_world_sprites = load("res://art/weapons_world_32.png")
	character_sprites = load("res://art/characters_32.png")
	enemy_sprites = load("res://art/enemies_32.png")
	skill_sprites = load("res://art/skills_16.png")
	npc_sprites = load("res://art/npcs_32.png")
	vfx_sprites = load("res://art/vfx_16.png")
	structure_tiles = load("res://art/structures_16.png")
	house_tiles = load("res://art/houses_192.png")
	setup_network_manager()
	load_bindings()
	refresh_save_slot_labels()
	refresh_shop_stock()
	reset_class_skills()
	for i in QUESTS.size():
		quests.append({"state":0, "progress":0})
	for i in WORLD_EVENTS.size():
		event_states.append(0)
		event_progress.append(0)
	if FileAccess.file_exists(slot_save_path(1)): load_game()
	previous_region = region_at(player_pos)
	for i in 4:
		spawn_enemy()
	panel = "start"
	if dedicated_server:
		panel = ""
		music_enabled = false
		start_dedicated_server()
		return
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -80.0
	add_child(music_player)
	music_incoming = AudioStreamPlayer.new()
	music_incoming.volume_db = -80.0
	add_child(music_incoming)
	for name in SFX_NAMES:
		sound_streams[name] = load("res://audio/%s.wav" % name)
	for i in 8:
		var player := AudioStreamPlayer.new()
		player.volume_db = -15.0
		add_child(player)
		sound_players.append(player)
	update_music()

func reset_class_skills() -> void:
	learned.resize(ABILITIES.size())
	skill_levels.resize(ABILITIES.size())
	cooldowns.resize(ABILITIES.size())
	for i in ABILITIES.size():
		learned[i] = false
		skill_levels[i] = 0
		cooldowns[i] = 0.0
	slots = [-1, -1, -1]

func class_weapon_icon() -> String:
	return ["sword", "staff", "bow"][class_id]

func class_ultimate() -> int:
	return CLASS_ULTIMATES[class_id]

func setup_network_manager() -> void:
	network_manager = NetworkManager.new()
	network_manager.network_port = network_port
	network_manager.server_url = network_server_url
	network_manager.state_changed.connect(_on_network_state_changed)
	network_manager.peer_joined.connect(_on_network_peer_joined)
	network_manager.peer_left.connect(_on_network_peer_left)
	network_manager.connected_to_server.connect(_on_network_connected_to_server)
	network_manager.connection_failed.connect(_on_network_connection_failed)
	network_manager.server_disconnected.connect(_on_network_server_disconnected)
	add_child(network_manager)

func _on_network_state_changed(mode: String, status: String, code: String, peer_id: int) -> void:
	network_mode = mode
	network_status = status
	invite_code = code
	local_peer_id = peer_id

func _on_network_peer_joined(id: int) -> void:
	add_chat_line("SYSTEM", "Spieler %d verbunden" % id)
	if network_mode == "host":
		push_world_snapshot()

func _on_network_peer_left(id: int) -> void:
	remote_players.erase(id)
	add_chat_line("SYSTEM", "Spieler %d hat die Gruppe verlassen." % id)

func _on_network_connected_to_server() -> void:
	add_chat_line("SYSTEM", "Koop-Verbindung hergestellt.")
	push_player_state()

func _on_network_connection_failed() -> void:
	remote_players.clear()

func _on_network_server_disconnected() -> void:
	remote_players.clear()

func start_dedicated_server() -> void:
	network_manager.start_dedicated_server()

func join_dedicated_server() -> void:
	network_manager.join_dedicated_server()

func host_multiplayer() -> void:
	network_manager.host_lan()
	if network_mode == "host":
		add_chat_line("SYSTEM", "Koop-Host gestartet.")

func join_multiplayer_from_code(code: String) -> void:
	network_manager.join_lan_code(code)

func disconnect_multiplayer(show_message: bool = true) -> void:
	remote_players.clear()
	network_manager.disconnect_network(show_message)

func push_player_state() -> void:
	if network_mode == "offline" or multiplayer.multiplayer_peer == null: return
	var state := {"pos":[player_pos.x,player_pos.y], "facing":[facing.x,facing.y], "class":class_id, "race":hero_race, "gender":hero_gender, "name":hero_name, "level":level, "walking":is_walking, "weapon":equipped_weapon_design(), "region":region_at(player_pos)}
	rpc_player_state.rpc(state)
	if network_mode == "host" and int(world_time * 5.0) % 2 == 0: push_world_snapshot()

@rpc("any_peer", "call_remote", "unreliable", 0)
func rpc_player_state(state: Dictionary) -> void:
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0: return
	remote_players[sender] = state
	if network_mode == "host": rpc_relay_player_state.rpc(sender, state)

@rpc("authority", "call_remote", "unreliable", 0)
func rpc_relay_player_state(peer_id: int, state: Dictionary) -> void:
	if peer_id == multiplayer.get_unique_id(): return
	remote_players[peer_id] = state

func push_world_snapshot() -> void:
	if network_mode != "host": return
	var enemy_rows: Array = []
	for enemy in enemies:
		var enemy_facing: Vector2 = enemy.get("facing", Vector2.DOWN)
		enemy_rows.append({"uid":enemy.get("uid",0), "type":enemy.get("type",0), "pos":[enemy["pos"].x,enemy["pos"].y], "hp":enemy.get("hp",1.0), "max_hp":enemy.get("max_hp",1.0), "elite":enemy.get("elite",0), "flash":enemy.get("flash",0.0), "shot":enemy.get("shot",1.0), "hit":enemy.get("hit",0.0), "seed":enemy.get("seed",0.0), "stun":enemy.get("stun",0.0), "slow":enemy.get("slow",0.0), "poison":enemy.get("poison",0.0), "poison_tick":enemy.get("poison_tick",1.0), "marked":enemy.get("marked",0.0), "facing":[enemy_facing.x,enemy_facing.y], "walking":enemy.get("walking",false), "anim_time":enemy.get("anim_time",0.0), "attack_anim":enemy.get("attack_anim",0.0)})
	var shot_rows: Array = []
	for shot in enemy_projectiles:
		shot_rows.append({"pos":[shot["pos"].x,shot["pos"].y],"dir":[shot["dir"].x,shot["dir"].y],"speed":shot.get("speed",265.0),"life":shot.get("life",1.0),"damage":shot.get("damage",1),"type":shot.get("type",0)})
	rpc_world_snapshot.rpc({"enemies":enemy_rows,"shots":shot_rows})

@rpc("authority", "call_remote", "unreliable", 1)
func rpc_world_snapshot(snapshot: Dictionary) -> void:
	if network_mode != "client": return
	var rebuilt: Array = []
	for raw in snapshot.get("enemies", []):
		if not raw is Dictionary: continue
		var copy: Dictionary = raw.duplicate()
		var coords: Array = raw.get("pos", [0.0,0.0])
		copy["pos"] = Vector2(float(coords[0]),float(coords[1]))
		var face: Array = raw.get("facing", [0.0,1.0])
		copy["facing"] = Vector2(float(face[0]), float(face[1]))
		rebuilt.append(copy)
	enemies = rebuilt
	var rebuilt_shots: Array = []
	for raw in snapshot.get("shots", []):
		if not raw is Dictionary: continue
		var shot: Dictionary = raw.duplicate()
		var spos: Array = raw.get("pos", [0.0,0.0])
		var sdir: Array = raw.get("dir", [0.0,1.0])
		shot["pos"] = Vector2(float(spos[0]),float(spos[1]))
		shot["dir"] = Vector2(float(sdir[0]),float(sdir[1]))
		rebuilt_shots.append(shot)
	enemy_projectiles = rebuilt_shots

func add_chat_line(author: String, value: String) -> void:
	var clean := value.strip_edges().substr(0,120)
	if clean == "": return
	chat_messages.append({"author":author.substr(0,20), "text":clean})
	while chat_messages.size() > 8: chat_messages.pop_front()
	chat_fade = 7.0
	queue_redraw()

func is_web_platform() -> bool:
	return OS.has_feature("web")

func start_coop_world() -> void:
	if network_mode == "offline":
		network_status = "Starte zuerst einen Host oder verbinde dich mit einem Einladungscode."
		return
	active_save_slot = selected_save_slot
	if FileAccess.file_exists(slot_save_path(active_save_slot)):
		load_game()
		enemies.clear()
		drops.clear()
		battle_zones.clear()
		previous_region = region_at(player_pos)
		panel = ""
		if network_mode == "host": push_world_snapshot()
		message("Koop-Welt gestartet. Willkommen, %s!" % hero_name)
	else:
		begin_character_creation()

func send_chat_message(value: String) -> void:
	var clean := value.strip_edges().substr(0,120)
	if clean == "": return
	var author := hero_name if hero_name != "" else "Held"
	add_chat_line(author, clean)
	if network_mode != "offline": rpc_chat_message.rpc(author, clean)

@rpc("any_peer", "call_remote", "reliable")
func rpc_chat_message(author: String, value: String) -> void:
	add_chat_line(author, value)
	if network_mode == "host":
		var sender := multiplayer.get_remote_sender_id()
		for peer_id in multiplayer.get_peers():
			if int(peer_id) != sender: rpc_chat_relay.rpc_id(int(peer_id), author, value)

@rpc("authority", "call_remote", "reliable")
func rpc_chat_relay(author: String, value: String) -> void:
	add_chat_line(author, value)

func _exit_tree() -> void:
	if music_player != null:
		music_player.stop()
		music_player.stream = null
	if music_incoming != null:
		music_incoming.stop()
		music_incoming.stream = null
	for player in sound_players:
		player.stop()
		player.stream = null

func play_sound(name: String) -> void:
	if sound_players.is_empty() or not sound_streams.has(name): return
	var player: AudioStreamPlayer = sound_players[next_sound_player]
	next_sound_player = (next_sound_player + 1) % sound_players.size()
	player.stop()
	player.stream = sound_streams[name]
	player.volume_db = -80.0 if effects_volume <= 0.0 else ((-29.0 if name == "step" else -11.0) + linear_to_db(effects_volume))
	player.pitch_scale = 0.92 if name == "step" and next_sound_player % 2 == 0 else 1.0
	player.play()

func play_trade_sound(kind: String) -> void:
	if sound_players.is_empty() or not sound_streams.has("pickup"):
		return
	var player: AudioStreamPlayer = sound_players[next_sound_player]
	next_sound_player = (next_sound_player + 1) % sound_players.size()
	player.stop()
	player.stream = sound_streams["pickup"]
	player.volume_db = -80.0 if effects_volume <= 0.0 else (-9.0 + linear_to_db(effects_volume))
	if kind == "buy":
		player.pitch_scale = 1.18
	elif kind == "sell_all":
		player.pitch_scale = 0.78
	else:
		player.pitch_scale = 0.90
	player.play()

func update_music(delta: float = 0.0) -> void:
	if music_player == null or music_incoming == null: return
	if not music_enabled:
		music_player.stop()
		music_incoming.stop()
		music_fading = false
		music_theme = ""
		return
	var region: int = region_at(player_pos)
	var desired: String = "dorf" if panel == "start" or interior_id >= 0 else ("boss" if arena_mode != "" else (["ruinen", "kristall", "quelle"][dungeon_id] if dungeon_id >= 0 else MUSIC_THEMES[region]))
	if desired != music_theme:
		# Bei schnellem Hin- und Herreisen bleibt der gerade lautere Track erhalten.
		if music_fading:
			if music_fade_elapsed > MUSIC_FADE_SECONDS * 0.5:
				music_player.stop()
				var previous: AudioStreamPlayer = music_player
				music_player = music_incoming
				music_incoming = previous
			else:
				music_incoming.stop()
			music_fading = false
		var path: String = "res://music/%s.ogg" % desired if desired in CUSTOM_MUSIC_THEMES else "res://audio/%s.wav" % desired
		var stream: AudioStream = load(path)
		if stream == null: return
		if stream is AudioStreamOggVorbis: stream.loop = true
		if stream is AudioStreamWAV: stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music_theme = desired
		music_incoming.stop()
		music_incoming.stream = stream
		music_incoming.volume_db = -80.0
		music_incoming.play()
		music_fade_elapsed = 0.0
		music_fading = true
	var base_volume: float = -80.0 if music_volume <= 0.0 else ((-15.0 if panel == "pause" else -4.5) + linear_to_db(music_volume))
	if music_fading:
		music_fade_elapsed = minf(MUSIC_FADE_SECONDS, music_fade_elapsed + delta)
		var blend: float = music_fade_elapsed / MUSIC_FADE_SECONDS
		music_player.volume_db = base_volume + linear_to_db(maxf(0.001, cos(blend * PI * 0.5)))
		music_incoming.volume_db = base_volume + linear_to_db(maxf(0.001, sin(blend * PI * 0.5)))
		if blend >= 1.0:
			music_player.stop()
			var previous: AudioStreamPlayer = music_player
			music_player = music_incoming
			music_incoming = previous
			music_fading = false
	else:
		music_player.volume_db = move_toward(music_player.volume_db, base_volume, delta * 22.0)

func max_hp() -> float:
	var base_hp := 100.0 + float(level - 1) * 8.0 + float(skill_levels[10]) * 25.0 + equipment_power(equipped_ring_uid) + equipment_power(equipped_ring2_uid) + item_attribute("str") * (2 if class_id == 0 else 1)
	var race := current_race_profile()
	return base_hp * (1.0 if race == null else race.max_hp_multiplier)

func max_energy() -> float:
	return 100.0 + float(skill_levels[11]) * 25.0

func equipment_power(uid: int) -> int:
	for item in inventory:
		if int(item.get("uid", -1)) == uid:
			return int(item.get("power", 0))
	return 0

func item_attribute(key: String) -> int:
	var total := 0
	for item in inventory:
		if int(item.get("uid", -1)) in equipped_item_uids():
			total += int(item.get(key, 0))
	return total

func primary_attribute() -> int:
	return item_attribute(["str", "int", "agi"][class_id])

func xp_required() -> int:
	return 120 + (level - 1) * 85 + (level - 1) * (level - 1) * 10

func region_at(p: Vector2) -> int:
	if p.x >= 11000: return clampi(int(p.y / 1920.0) + 8, 8, 12)
	if p.x < 1780:
		return 0 if p.y < 2600 else 6
	if p.x < 5000:
		return 1 if p.y < 4200 else 2
	if p.x < 8500:
		return 3 if p.y < 4200 else 4
	return 5 if p.y < 4200 else 7

func region_name(region: int) -> String:
	if region >= 8: return NEW_REGION_NAMES[region - 8]
	return ["Sonnenhain", "Blütenwiesen", "Pilzwald", "Alte Ruinen", "Kristallmoor", "Ascheberge", "Mondküste", "Sternenbruch"][region]

func region_level(region: int) -> int:
	return int(REGION_LEVELS[region])

func enemy_damage(type: int) -> int:
	var region: int = int(ENEMY_TYPES[type]["region"])
	return ceili(float(ENEMY_TYPES[type]["damage"]) * (1.12 + 0.055 * region_level(region)))

func enemy_level(type: int) -> int:
	var region: int = int(ENEMY_TYPES[type]["region"])
	return region_level(region) + (2 if type in [12, 13, 14] else type % 3)

func _process(delta: float) -> void:
	update_music(delta)
	if panel == "pause":
		queue_redraw()
		return
	if panel == "intro":
		intro_timer -= delta
		if intro_timer <= 0.0: finish_intro()
	world_time += delta
	if chat_open: chat_fade = 7.0
	else: chat_fade = maxf(0.0, chat_fade - delta)
	if multiplayer.multiplayer_peer != null and network_mode != "offline" and not dedicated_server:
		sync_timer -= delta
		if sync_timer <= 0.0:
			sync_timer = 0.05
			push_player_state()
	if panel != "start":
		shop_timer += delta
		if shop_timer >= 420.0:
			shop_timer = 0.0
			refresh_shop_stock()
	attack_timer = maxf(0.0, attack_timer - delta)
	swing_timer = maxf(0.0, swing_timer - delta)
	dash_timer = maxf(0.0, dash_timer - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	invulnerable = maxf(0.0, invulnerable - delta)
	shield_timer = maxf(0.0, shield_timer - delta)
	rage_timer = maxf(0.0, rage_timer - delta)
	drain_timer = maxf(0.0, drain_timer - delta)
	poison_blade_timer = maxf(0.0, poison_blade_timer - delta)
	notice_timer = maxf(0.0, notice_timer - delta)
	rescue_intro_timer = maxf(0.0, rescue_intro_timer - delta)
	rescue_banner_timer = maxf(0.0, rescue_banner_timer - delta)
	reward_scene_timer = maxf(0.0, reward_scene_timer - delta)
	attack_anim = maxf(0.0, attack_anim - delta)
	step_timer = maxf(0.0, step_timer - delta)
	for i in cooldowns.size():
		cooldowns[i] = maxf(0.0, float(cooldowns[i]) - delta)
	for i in boss_cooldowns.size():
		boss_cooldowns[i] = maxf(0.0, float(boss_cooldowns[i]) - delta)
	if panel == "":
		energy = minf(max_energy(), energy + (4.0 if class_id == 1 else (5.0 if class_id == 0 else 6.0)) * delta)
		if not dedicated_server:
			update_player(delta)
		if arena_mode == "" and dungeon_id < 0 and interior_id < 0: update_rescue()
		update_battle_zones(delta)
		update_impact_zones(delta)
		update_poison_clouds(delta)
		if network_mode != "client": update_enemies(delta)
		if panel != "":
			queue_redraw()
			return
		update_projectiles(delta)
		update_enemy_projectiles(delta)
		if panel != "":
			queue_redraw()
			return
		collect_drops()
		if arena_mode == "" and dungeon_id < 0 and interior_id < 0:
			if network_mode != "client":
				spawn_nearby_boss()
				spawn_timer += delta
				if spawn_timer > 3.4 and enemies.size() < 10:
					spawn_enemy()
					spawn_timer = 0.0
			if final_countdown > 0.0:
				final_countdown -= delta
				if final_countdown <= 0.0: enter_arena("final")
		elif arena_mode != "":
			update_arena(delta)
	for i in range(effects.size() - 1, -1, -1):
		effects[i]["life"] = float(effects[i]["life"]) - delta
		if effects[i]["life"] <= 0:
			effects.remove_at(i)
	for i in range(spell_visuals.size() - 1, -1, -1):
		spell_visuals[i]["life"] = float(spell_visuals[i]["life"]) - delta
		if spell_visuals[i]["life"] <= 0: spell_visuals.remove_at(i)
	for i in range(lightning_lines.size() - 1, -1, -1):
		lightning_lines[i]["life"] = float(lightning_lines[i]["life"]) - delta
		if lightning_lines[i]["life"] <= 0: lightning_lines.remove_at(i)
	# Der Arenarand liegt außerhalb eines einzelnen Bildschirms; die Kamera begleitet den Helden.
	var camera_focus: Vector2 = ARENA_CENTER + (player_pos - ARENA_CENTER) * 0.88 if arena_mode != "" else player_pos
	camera_pos = camera_focus - VIEW * 0.5 if arena_mode != "" else (INTERIOR_CENTER - VIEW * 0.5 if interior_id >= 0 else (player_pos - VIEW * 0.5).clamp(Vector2.ZERO, WORLD - VIEW))
	save_timer += delta
	if save_timer > 15 and arena_mode == "" and panel != "start" and not dedicated_server:
		save_game()
		save_timer = 0.0
	queue_redraw()

func update_player(delta: float) -> void:
	var old_pos := player_pos
	var move := movement_vector()
	is_walking = move.length_squared() > 0.01 or dash_timer > 0
	if is_walking: walk_phase += delta * (19.0 if dash_timer > 0 else 11.0)
	var class_profile := current_class_profile()
	var race_profile := current_race_profile()
	var move_speed := MovementRules.effective_move_speed(205.0, race_profile, class_profile)
	var roll_speed := MovementRules.effective_roll_speed(580.0, class_profile)
	var target_pos := player_pos + (dash_dir * roll_speed if dash_timer > 0 else move * move_speed) * delta
	if not is_blocked(target_pos):
		player_pos = target_pos.clamp(Vector2(30, 30), WORLD - Vector2(30, 30))
	else:
		var axis_x := Vector2(target_pos.x, player_pos.y)
		var axis_y := Vector2(player_pos.x, target_pos.y)
		if not is_blocked(axis_x): player_pos.x = axis_x.x
		if not is_blocked(axis_y): player_pos.y = axis_y.y
	if player_pos.distance_to(old_pos) > 1 and step_timer <= 0:
		play_sound("step")
		step_timer = 0.43 if dash_timer <= 0 else 0.25
	var aim: Vector2 = get_global_mouse_position() + camera_pos - player_pos
	if aim.length() > 8: facing = aim.normalized()
	if arena_mode != "":
		if player_pos.distance_to(ARENA_CENTER) > ARENA_RADIUS - 26:
			player_pos = ARENA_CENTER + (player_pos - ARENA_CENTER).normalized() * (ARENA_RADIUS - 26)
		if panel == "" and binding_pressed("attack") and attack_timer <= 0: normal_attack()
		return
	if interior_id >= 0: return
	if dungeon_id >= 0:
		if panel == "" and binding_pressed("attack") and attack_timer <= 0: normal_attack()
		return
	var region: int = region_at(player_pos)
	if region != previous_region:
		previous_region = region
		if not discovered_regions[region]:
			discovered_regions[region] = true
			var whispers := ["", "Unter den Blüten liegt etwas Dunkles.", "Die Pilze leuchten, obwohl kein Sonnenstrahl hierher reicht.", "Der Turm bewacht ein vergessenes Versprechen.", "Im Kristall spiegelt sich ein Himmel ohne Sterne.", "Die Asche trägt Spuren eines alten Feuers.", "Das Meer flüstert Namen aus vergangenen Tagen.", "Jenseits des Bruchs wartet die Quelle des Unheils.", "Eine Glocke schlägt tief im Nebel.", "Goldenes Harz verschließt die Wunden des Waldes.", "Wasser steigt aus der Erde und singt eine Warnung.", "Am Grat verlischt das letzte Wachtfeuer.", "Über den Gärten sammelt sich das Licht der Morgenwache."]
			message("%s · %s" % [region_name(region), whispers[region]])
			save_game()
		message("Neues Gebiet: %s" % region_name(region))
		if region != 0:
			for i in 5: spawn_enemy()
	# Gedrückt halten löst nach jeder Abklingzeit den nächsten Hieb aus.
	if panel == "" and binding_pressed("attack") and attack_timer <= 0:
		normal_attack()

func is_blocked(pos: Vector2, from_pos: Vector2 = Vector2(-1, -1)) -> bool:
	if arena_mode != "": return pos.distance_to(ARENA_CENTER) > ARENA_RADIUS - 22.0
	if interior_id >= 0: return tavern_blocked(pos)
	if dungeon_id >= 0: return dungeon_blocked(pos)
	if pos.x < 26 or pos.y < 26 or pos.x > WORLD.x - 26 or pos.y > WORLD.y - 26:
		return true
	if pos.x < 11000 and pos.y > 8470: return true
	if pos.x >= 11000 and (pos.x < 11140 or int(pos.y / 1920.0) != int(from_pos.y / 1920.0) and from_pos.x >= 11000): return true
	# Mondküste/untere Map: frühere 7700-Grenze erzeugte eine unsichtbare Wand.
	if pos.x < 1780 and pos.y > 8440:
		return true
	if from_pos.x < 0: from_pos = player_pos
	# Die Kollisionsfläche folgt der gesamten gezeichneten Mauer (82 px breit),
	# nicht nur der unsichtbaren Gebietsgrenze in ihrer Mitte.
	if blocked_by_region_wall(pos): return true
	var from_region := region_at(from_pos)
	var to_region := region_at(pos)
	if from_region != to_region and not can_cross_gate(from_region, to_region, from_pos, pos):
		return true
	if region_at(pos) != 0:
		return terrain_blocked(pos)
	for house in house_positions():
		if Rect2(house + Vector2(9, 36), Vector2(160, 105)).grow(15).has_point(pos):
			return true
	return false

func blocked_by_region_wall(pos: Vector2) -> bool:
	var walls := [
		{"vertical":true,"axis":1780.0,"from":0.0,"to":2600.0,"gate":1120.0,"level":1,"boss":-1},
		{"vertical":true,"axis":1780.0,"from":2600.0,"to":8500.0,"gate":6200.0,"level":8,"boss":-1},
		{"vertical":false,"axis":2600.0,"from":0.0,"to":1780.0,"gate":875.0,"level":5,"boss":-1},
		{"vertical":false,"axis":4200.0,"from":1780.0,"to":5000.0,"gate":2900.0,"level":8,"boss":-1},
		{"vertical":true,"axis":5000.0,"from":0.0,"to":4200.0,"gate":1250.0,"level":15,"boss":-1},
		{"vertical":true,"axis":5000.0,"from":4200.0,"to":8500.0,"gate":6200.0,"level":22,"boss":0},
		{"vertical":false,"axis":4200.0,"from":5000.0,"to":8500.0,"gate":6600.0,"level":22,"boss":0},
		{"vertical":true,"axis":8500.0,"from":0.0,"to":4200.0,"gate":1900.0,"level":29,"boss":1},
		{"vertical":true,"axis":8500.0,"from":4200.0,"to":8500.0,"gate":6350.0,"level":36,"boss":1},
		{"vertical":false,"axis":4200.0,"from":8500.0,"to":11000.0,"gate":9750.0,"level":36,"boss":-1}
	]
	for wall in walls:
		var along: float = pos.y if wall["vertical"] else pos.x
		var across: float = pos.x if wall["vertical"] else pos.y
		if along < float(wall["from"]) - 20.0 or along > float(wall["to"]) + 20.0: continue
		if absf(across - float(wall["axis"])) > 51.0: continue
		var gate_open: bool = creative_mode or (level >= int(wall["level"]) and (int(wall["boss"]) < 0 or bosses_defeated[int(wall["boss"])]))
		if gate_open and absf(along - float(wall["gate"])) < GATE_HALF_WIDTH - 24.0: continue
		return true
	return false

func distance_to_trail(p: Vector2) -> float:
	var best := INF
	for trail in TRAILS:
		for i in range(trail.size() - 1):
			var a: Vector2 = trail[i]
			var b: Vector2 = trail[i + 1]
			var segment := b - a
			var t := clampf((p - a).dot(segment) / segment.length_squared(), 0.0, 1.0)
			best = minf(best, p.distance_to(a + segment * t))
	return best

func obstacle_in_cell(cx: int, cy: int) -> Dictionary:
	var cell := Vector2i(cx, cy)
	if obstacle_cache.has(cell): return obstacle_cache[cell]
	var obstacle := make_obstacle(cx, cy)
	obstacle_cache[cell] = obstacle
	return obstacle

func make_obstacle(cx: int, cy: int) -> Dictionary:
	var key := hash_cell(cx + 37, cy + 61)
	if key % 3 == 0: return {}
	var p := Vector2(cx * 250 + 55 + key % 130, cy * 250 + 45 + (key / 17) % 125)
	if p.x < 1900 and p.y < 2700: return {}
	if p.x < 80 or p.y < 80 or p.x > WORLD.x - 80 or p.y > WORLD.y - 80: return {}
	var zone := region_at(p)
	if zone == 0: return {}
	var radius := 43.0 + float(key % 4) * 9.0
	if p.distance_to(UFO_WRECK_POS) < radius + 250.0: return {}
	if p.distance_to(UFO_CHEST_POS) < radius + 120.0: return {}
	if distance_to_trail(p) < radius + 115.0: return {}
	for landmark in LANDMARKS:
		if p.distance_to(landmark["pos"]) < radius + 180.0: return {}
	for stone in WAYSTONES:
		if p.distance_to(stone) < radius + 110.0: return {}
	for portal in PORTALS:
		if p.distance_to(portal[0]) < radius + 150.0 or p.distance_to(portal[1]) < radius + 150.0: return {}
	return {"pos":p, "radius":radius, "zone":zone, "key":key}

func terrain_blocked(p: Vector2) -> bool:
	if p.distance_to(UFO_WRECK_POS) < 105.0: return true
	if region_at(p) == 1:
		for offset in [Vector2(-360, -160), Vector2(260, -190), Vector2(-330, 220), Vector2(280, 240)]:
			if Rect2(RESCUE_POS + offset - Vector2(73, 54), Vector2(146, 108)).grow(16).has_point(p): return true
	var cx := int(floorf(p.x / 250.0))
	var cy := int(floorf(p.y / 250.0))
	for x in range(cx - 1, cx + 2):
		for y in range(cy - 1, cy + 2):
			var obstacle := obstacle_in_cell(x, y)
			if not obstacle.is_empty() and p.distance_to(obstacle["pos"]) < float(obstacle["radius"]) + 17.0:
				return true
	return false

func can_cross_gate(from_region: int, to_region: int, start: Vector2, end: Vector2) -> bool:
	if from_region >= 8 or to_region >= 8: return false
	var a := mini(from_region, to_region)
	var b := maxi(from_region, to_region)
	var crossing := Vector2(-1, -1)
	var center := Vector2(-1, -1)
	var needed_boss := -1
	match Vector2i(a, b):
		Vector2i(0, 1): center = Vector2(1780, 1120)
		Vector2i(0, 6): center = Vector2(875, 2600)
		Vector2i(1, 2): center = Vector2(2900, 4200)
		Vector2i(1, 3): center = Vector2(5000, 1250)
		Vector2i(2, 4): center = Vector2(5000, 6200); needed_boss = 0
		Vector2i(2, 6): center = Vector2(1780, 6200)
		Vector2i(3, 4): center = Vector2(6600, 4200); needed_boss = 0
		Vector2i(3, 5): center = Vector2(8500, 1900); needed_boss = 1
		Vector2i(4, 7): center = Vector2(8500, 6350); needed_boss = 1
		Vector2i(5, 7): center = Vector2(9750, 4200)
		_: return false
	var vertical := Vector2i(a, b) in [Vector2i(0, 1), Vector2i(1, 3), Vector2i(2, 4), Vector2i(2, 6), Vector2i(3, 5), Vector2i(4, 7)]
	if vertical:
		var span_x := end.x - start.x
		if absf(span_x) < 0.001: return false
		var t := (center.x - start.x) / span_x
		crossing = start.lerp(end, clampf(t, 0.0, 1.0))
		if absf(crossing.y - center.y) >= GATE_HALF_WIDTH: return false
	else:
		var span_y := end.y - start.y
		if absf(span_y) < 0.001: return false
		var t := (center.y - start.y) / span_y
		crossing = start.lerp(end, clampf(t, 0.0, 1.0))
		if absf(crossing.x - center.x) >= GATE_HALF_WIDTH: return false
	if not creative_mode and level < region_level(to_region):
		message("%s ist ab Level %d zugänglich." % [region_name(to_region), region_level(to_region)])
		return false
	if not creative_mode and needed_boss >= 0 and not bosses_defeated[needed_boss]:
		message("Weg versiegelt! Besiege zuerst %s." % ENEMY_TYPES[12 + needed_boss]["name"])
		return false
	return true

func house_positions() -> Array:
	return [Vector2(220, 260), Vector2(495, 280), Vector2(1100, 240), Vector2(1440, 280), Vector2(210, 700), Vector2(1420, 890), Vector2(260, 1320), Vector2(590, 1570), Vector2(1180, 1510), Vector2(1460, 1760), Vector2(470, 2020), Vector2(990, 2100), Vector2(80, 1850), Vector2(360, 2250), Vector2(805, 2320), Vector2(1320, 2180)]

func load_bindings() -> void:
	bindings = DEFAULT_BINDINGS.duplicate()
	if not FileAccess.file_exists(CONTROLS_PATH): return
	var loaded: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONTROLS_PATH))
	if not loaded is Dictionary: return
	for action in BIND_ACTIONS:
		var value: Variant = loaded.get(action, 0)
		if (value is int or value is float) and (int(value) >= 0 or int(value) in [-MOUSE_BUTTON_LEFT, -MOUSE_BUTTON_RIGHT, -MOUSE_BUTTON_MIDDLE]):
			if int(value) != KEY_ESCAPE or action == "pause": bindings[action] = int(value)

func save_bindings() -> void:
	var file: FileAccess = FileAccess.open(CONTROLS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(bindings))
		file.close()

func binding_label(action: String) -> String:
	var code: int = int(bindings.get(action, 0))
	if code == 0: return "NICHT BELEGT"
	if code < 0: return "MAUS %d" % -code
	if code == KEY_SPACE: return "LEERTASTE"
	if code == KEY_ESCAPE: return "ESC"
	return OS.get_keycode_string(code).to_upper()

func binding_short(action: String) -> String:
	var code: int = int(bindings.get(action, 0))
	if code < 0: return "M%d" % -code
	if code == KEY_SPACE: return "LEER"
	return binding_label(action)

func binding_pressed(action: String) -> bool:
	var code: int = int(bindings.get(action, 0))
	if code < 0: return Input.is_mouse_button_pressed(-code)
	return code > 0 and Input.is_key_pressed(code)

func event_matches_binding(event: InputEvent, action: String) -> bool:
	var code: int = int(bindings.get(action, 0))
	if code > 0 and event is InputEventKey: return event.keycode == code
	if code < 0 and event is InputEventMouseButton: return event.button_index == -code
	return false

func movement_vector() -> Vector2:
	var direction := Vector2((1.0 if binding_pressed("move_right") else 0.0) - (1.0 if binding_pressed("move_left") else 0.0), (1.0 if binding_pressed("move_down") else 0.0) - (1.0 if binding_pressed("move_up") else 0.0))
	return direction.normalized()

func set_binding(action: String, code: int) -> void:
	if code == KEY_ESCAPE and action != "pause":
		controls_status = "ESC bleibt als sichere Rückkehr ins Pausenmenü reserviert."
		return
	var old_code: int = int(bindings[action])
	var swapped := false
	for other in BIND_ACTIONS:
		if other != action and int(bindings[other]) == code:
			bindings[other] = 0 if old_code == KEY_ESCAPE else old_code
			controls_status = "%s und %s wurden getauscht." % [BIND_NAMES[BIND_ACTIONS.find(action)], BIND_NAMES[BIND_ACTIONS.find(other)]]
			swapped = true
			break
	bindings[action] = code
	if not swapped: controls_status = "%s: %s" % [BIND_NAMES[BIND_ACTIONS.find(action)], binding_label(action)]
	save_bindings()

func reset_bindings() -> void:
	bindings = DEFAULT_BINDINGS.duplicate()
	awaiting_bind = ""
	controls_status = "Standardbelegung wiederhergestellt."
	save_bindings()

func _unhandled_input(event: InputEvent) -> void:
	if panel == "multiplayer" and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			panel = "start"
		elif event.keycode == KEY_BACKSPACE:
			if join_code.length() > 0: join_code = join_code.left(join_code.length()-1)
		elif event.keycode == KEY_ENTER:
			if is_web_platform():
				join_dedicated_server()
			elif join_code.length() > 4:
				join_multiplayer_from_code(join_code)
		elif event.unicode >= 32 and join_code.length() < 28:
			var code_char := String.chr(event.unicode).to_upper()
			if "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-".find(code_char) >= 0: join_code += code_char
		queue_redraw()
		return
	# Texteingabe für einmalige Charaktererstellung.
	if panel == "creation" and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_BACKSPACE:
			if creation_name.length() > 0: creation_name = creation_name.left(creation_name.length() - 1)
		elif event.keycode == KEY_ENTER:
			if creation_name.strip_edges().length() >= 2: start_new_game()
		elif event.unicode >= 32 and creation_name.length() < 16:
			var typed := String.chr(event.unicode)
			if "abcdefghijklmnopqrstuvwxyzäöüß0123456789 -_".find(typed.to_lower()) >= 0: creation_name += typed
		queue_redraw()
		return
	# Chat blockiert die Kampfsteuerung, solange geschrieben wird.
	if chat_open and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			chat_open = false
			chat_input = ""
		elif event.keycode == KEY_ENTER:
			send_chat_message(chat_input)
			chat_input = ""
			chat_open = false
		elif event.keycode == KEY_BACKSPACE:
			if chat_input.length() > 0: chat_input = chat_input.left(chat_input.length() - 1)
		elif event.unicode >= 32 and chat_input.length() < 120:
			chat_input += String.chr(event.unicode)
		queue_redraw()
		return
	if panel == "" and event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_T]:
		chat_open = true
		chat_input = ""
		queue_redraw()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_H:
		if panel == "mechanics": panel = ""
		elif panel == "": panel = "mechanics"
		queue_redraw()
		return
	if panel == "controls" and awaiting_bind != "":
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE: controls_status = "Belegung abgebrochen."
			else: set_binding(awaiting_bind, event.keycode)
			awaiting_bind = ""
			return
		if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			set_binding(awaiting_bind, -int(event.button_index))
			awaiting_bind = ""
			return
		return
	if panel == "intro":
		if event is InputEventKey and event.pressed and event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_SPACE, KEY_E]: finish_intro()
		elif event is InputEventMouseButton and event.pressed: finish_intro()
		return
	if panel == "pause" and event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		set_volume_from_mouse(event.position)
	if panel == "pause" and event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		save_game()
	var triggered := false
	if event is InputEventKey: triggered = event.pressed and not event.echo
	elif event is InputEventMouseButton: triggered = event.pressed
	if not triggered: return
	if event is InputEventMouseButton and panel != "":
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click and panel in ["inventory", "shop"] and try_toggle_item_protection_at(event.position):
				return
			handle_panel_click(event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and panel in ["skills", "journal"]:
			menu_scroll = mini(maxi(0, QUESTS.size() - 6) if panel == "journal" else 2, menu_scroll + 1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and panel in ["skills", "journal"]:
			menu_scroll = maxi(0, menu_scroll - 1)
		return
	if event is InputEventKey and event.keycode == KEY_ESCAPE or event_matches_binding(event, "pause"):
		if panel in ["arena_reward", "victory", "start"]: return
		if panel == "":
			panel = "pause"
			pause_status = "Das Spiel ist angehalten."
		elif panel == "controls": panel = controls_return_panel
		else: panel = ""
		return
	if panel in ["pause", "start", "controls", "arena_reward", "victory"]: return
	for action in ["skills", "inventory", "journal", "map"]:
		if event_matches_binding(event, action):
			toggle_panel(action)
			return
	if panel != "": return
	if event_matches_binding(event, "interact"): interact()
	elif event_matches_binding(event, "waystone"): use_waystone()
	elif event_matches_binding(event, "heal"): quick_potion(false)
	elif event_matches_binding(event, "resource"): quick_potion(true)
	elif event_matches_binding(event, "dodge") and dash_cooldown <= 0: dodge()
	elif interior_id < 0:
		for slot in 4:
			if event_matches_binding(event, "ability_%d" % (slot + 1)):
				use_ability(slot)
				break

func toggle_panel(which: String) -> void:
	panel = "" if panel == which else which
	menu_scroll = 0
	selected_item = -1
	inventory_page = 0
	sell_all_confirm = false

func dodge() -> void:
	var profile := current_class_profile()
	if not MovementRules.can_roll(profile):
		message("Magier können nicht rollen — nutze Arkaner Schritt für Mobilität.")
		return
	var dir := movement_vector()
	dash_dir = dir.normalized() if dir.length() > 0 else facing
	var distance_mult := MovementRules.effective_roll_distance(1.0, profile)
	dash_timer = 0.22 * distance_mult
	dash_cooldown = 1.25 * (1.0 if profile == null else profile.roll_cooldown_multiplier)
	invulnerable = 0.38
	effect(player_pos, "ROLLE", Color("d8f3ff"), 0.65)
	play_sound("dodge")

func weapon_power() -> int:
	return equipment_power(equipped_uid)

func equipped_weapon_variant() -> String:
	var design := equipped_weapon_design()
	if class_id == 0 and design % 3 == 2: return "axe"
	if class_id == 2 and design % 4 == 3: return "crossbow"
	return class_weapon_icon()

func current_race_profile() -> RaceProfile:
	if hero_race < 0 or hero_race >= RACE_PROFILE_PATHS.size():
		return null
	return load(RACE_PROFILE_PATHS[hero_race]) as RaceProfile

func current_class_profile() -> ClassProfile:
	if class_id < 0 or class_id >= CLASS_PROFILE_PATHS.size():
		return null
	return load(CLASS_PROFILE_PATHS[class_id]) as ClassProfile

func equipped_item_uids() -> Array:
	var ids: Array = [equipped_uid, equipped_armor_uid, equipped_ring_uid]
	if equipped_ring2_uid >= 0:
		ids.append(equipped_ring2_uid)
	return ids


func race_melee_multiplier() -> float:
	var profile := current_race_profile()
	if profile == null:
		return 1.0
	return profile.physical_damage_multiplier * profile.melee_damage_multiplier * profile.hand_weapon_damage_multiplier

func normal_attack_power() -> int:
	# Grundtreffer bleiben schwächer als Fähigkeiten, brauchen aber keine zähen Serien.
	var base := 7.0 + level * 1.6 + weapon_power() * 0.86 + int(skill_levels[9]) * 4.0
	var race_multiplier := race_melee_multiplier()
	return maxi(1, int(base * (1.0 + primary_attribute() * (0.015 if class_id == 0 else 0.019)) * race_multiplier))

func weapon_element() -> String:
	for item in inventory:
		if int(item.get("uid", -1)) == equipped_uid:
			return str(item.get("element", ""))
	return ""

func normal_attack() -> void:
	var variant := equipped_weapon_variant()
	attack_timer = 0.62 if variant == "axe" else (0.78 if variant == "crossbow" else (0.45 if class_id == 0 else (0.62 if class_id == 1 else 0.52)))
	swing_duration = 0.29 if variant == "axe" else (0.20 if variant == "crossbow" else (0.24 if class_id == 0 else 0.32))
	swing_timer = swing_duration
	attack_anim = swing_timer
	play_sound("swing")
	var power := normal_attack_power()
	if variant == "axe": power = int(power * 1.18)
	elif variant == "crossbow": power = int(power * 1.25)
	if rage_timer > 0: power = int(power * 1.45)
	if class_id == 0 and standing_in_battle_zone(): power = int(power * 1.32)
	var design := equipped_weapon_design()
	if network_mode == "client":
		rpc_client_normal_attack.rpc_id(1, [player_pos.x,player_pos.y], [facing.x,facing.y], class_id, design, power, weapon_element())
		if class_id != 0:
			projectiles.append({"pos":player_pos,"dir":facing,"speed":790.0 if variant=="crossbow" else (650.0 if class_id==2 else 520.0),"life":1.2,"damage":0,"kind":3 if class_id==2 else 2,"element":weapon_element(),"hits":[],"network_visual":true})
		return
	if class_id == 0:
		hit_arc(player_pos, facing, 116.0 if variant == "axe" else 100.0, 0.08 if variant == "axe" else 0.13, power, false, "gift" if poison_blade_timer > 0 else weapon_element())
	else:
		projectiles.append({"pos":player_pos, "dir":facing, "speed":790.0 if variant == "crossbow" else (650.0 if class_id == 2 else 520.0), "life":1.2, "damage":power, "kind":3 if class_id == 2 else 2, "element":weapon_element(), "hits":[]})

@rpc("any_peer", "call_remote", "reliable")
func rpc_client_normal_attack(origin_data: Array, dir_data: Array, remote_class: int, design: int, power: int, element: String) -> void:
	if network_mode != "host" or origin_data.size() < 2 or dir_data.size() < 2: return
	var origin := Vector2(float(origin_data[0]),float(origin_data[1]))
	var dir := Vector2(float(dir_data[0]),float(dir_data[1])).normalized()
	if remote_class == 0:
		var axe := design % 3 == 2
		hit_arc(origin,dir,116.0 if axe else 100.0,0.08 if axe else 0.13,power,false,element)
	else:
		var crossbow := remote_class == 2 and design % 4 == 3
		projectiles.append({"pos":origin,"dir":dir,"speed":790.0 if crossbow else (650.0 if remote_class==2 else 520.0),"life":1.2,"damage":power,"kind":3 if remote_class==2 else 2,"element":element,"hits":[]})

func hit_arc(origin: Vector2, direction: Vector2, reach: float, threshold: float, damage: int, stun: bool, element: String = "") -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		var offset: Vector2 = enemy["pos"] - origin
		if offset.length() <= reach and (offset.length() < 25 or direction.dot(offset.normalized()) > threshold):
			damage_enemy(i, damage, direction, stun, element)

func damage_enemy(index: int, amount: int, push: Vector2, stun: bool = false, element: String = "") -> void:
	if index < 0 or index >= enemies.size(): return
	play_sound("hit")
	var enemy: Dictionary = enemies[index]
	if float(enemy.get("marked", 0.0)) > 0.0:
		amount = int(amount * 1.22)
	match element:
		"feuer":
			amount += 5
			effect(enemy["pos"] + Vector2(0, -44), "FEUER", Color("ffb46e"), 0.8)
		"eis":
			enemy["slow"] = 3.0
			amount += 6
			effect(enemy["pos"] + Vector2(0, -44), "EIS", Color("a7eaff"), 0.8)
		"blitz":
			enemy["stun"] = 0.45
			amount += 10
			lightning_lines.append({"from":player_pos, "to":enemy["pos"], "life":0.25})
			# Blitzwaffen treffen zusätzlich einen Gegner in der Nähe.
			for j in enemies.size():
				if j != index and enemies[j]["pos"].distance_to(enemy["pos"]) < 105:
					enemies[j]["hp"] = float(enemies[j]["hp"]) - 7
					lightning_lines.append({"from":enemy["pos"], "to":enemies[j]["pos"], "life":0.25})
					break
		"gift":
			enemy["poison"] = 5.0
			enemy["poison_tick"] = 1.0
			effect(enemy["pos"] + Vector2(0, -44), "GIFT", Color("b7e885"), 0.8)
	enemy["hp"] = float(enemy["hp"]) - amount
	enemy["flash"] = 0.16
	enemy["pos"] = enemy["pos"] + push * 18.0
	if stun: enemy["stun"] = 1.2
	effect(enemy["pos"] + Vector2(0, -25), str(amount), Color("fff1a1"), 0.75)
	if drain_timer > 0: hp = minf(max_hp(), hp + minf(8.0, amount * 0.2))
	if enemy["hp"] <= 0: defeat_enemy(index)

@rpc("any_peer", "call_remote", "reliable")
func rpc_client_ability(id: int, pos_data: Array, dir_data: Array, power: int, rank: int) -> void:
	if network_mode != "host" or pos_data.size() < 2 or dir_data.size() < 2: return
	var origin := Vector2(float(pos_data[0]),float(pos_data[1]))
	var dir := Vector2(float(dir_data[0]),float(dir_data[1])).normalized()
	# Hostautoritäre Schadensauflösung für Koop-Spieler. Visuelle Spezialeffekte bleiben lokal bei jedem Spieler.
	var radial_ids := [0,5,17,22,23,24,31,33]
	if id in radial_ids:
		var radius := 165.0 + rank * 12.0
		for i in range(enemies.size()-1,-1,-1):
			if enemies[i]["pos"].distance_to(origin) <= radius: damage_enemy(i,power+10,dir,false)
	else:
		hit_arc(origin,dir,190.0,-0.15,power+8,false)

func use_ability(slot: int) -> void:
	if slot < 0 or slot > 3: return
	var id: int = class_ultimate() if slot == 3 else int(slots[slot])
	if id < 0 or id >= ABILITIES.size() or not learned[id]: return
	var ability: Dictionary = ABILITIES[id]
	if float(cooldowns[id]) > 0 or energy < float(ability["cost"]): return
	energy -= float(ability["cost"])
	var rank: int = int(skill_levels[id])
	cooldowns[id] = float(ability["cd"]) * (1.0 - 0.06 * (rank - 1))
	var power := int((17 + level * 2.4 + weapon_power() * 1.15 + (rank - 1) * 8) * (1.0 + primary_attribute() * 0.012))
	var cast_pos := player_pos
	var cast_dir := facing
	if network_mode == "client":
		rpc_client_ability.rpc_id(1, id, [cast_pos.x,cast_pos.y], [cast_dir.x,cast_dir.y], power, rank)
	match id:
		0:
			for i in range(enemies.size() - 1, -1, -1):
				var direction: Vector2 = enemies[i]["pos"] - player_pos
				if direction.length() < 155: damage_enemy(i, power + 13, direction.normalized(), false)
			effect(player_pos, "WIRBELHIEB", Color("fff6aa"), 0.8)
		1:
			shield_timer = 3.0 + (rank - 1) * 0.7
			battle_zones.append({"kind":"banner", "pos":player_pos, "radius":180.0 + rank * 12.0, "life":6.0 + rank, "max":6.0 + rank, "tick":0.0, "damage":0})
			effect(player_pos, "SCHILDWALL", Color("b5e6fb"), 0.8)
		2:
			var destination := player_pos + facing * (215 + (rank - 1) * 25)
			if not is_blocked(destination): player_pos = destination.clamp(Vector2(30, 30), WORLD - Vector2(30, 30))
			invulnerable = 0.5
			hit_arc(player_pos, facing, 100, -0.3, power + 12, true)
		3:
			projectiles.append({"pos":player_pos, "dir":facing, "speed":650.0, "life":0.9, "damage":power + 15, "kind":0, "pierce":true, "hits":[]})
		4:
			rage_timer = 6.0 + (rank - 1) * 1.0
			effect(player_pos, "KAMPFSCHREI", Color("ffd28c"), 0.8)
		5:
			hit_arc(player_pos, facing, 170, -0.25, power + 40, true)
			effect(player_pos + facing * 90, "ERDSPALTER", Color("ebd9a1"), 0.8)
		6:
			drain_timer = 8.0 + (rank - 1) * 1.0
			effect(player_pos, "LEBENSRAUB", Color("fbb2bc"), 0.8)
		7:
			for angle in [-0.24, 0.0, 0.24]:
				projectiles.append({"pos":player_pos, "dir":facing.rotated(angle), "speed":700.0, "life":0.8, "damage":power + 10, "kind":1, "hits":[]})
		8:
			var healing := 55 + (rank - 1) * 18
			hp = minf(max_hp(), hp + healing)
			shield_timer = 5.0 + (rank - 1) * 0.6
			effect(player_pos, "+%d LEBEN" % healing, Color("b6f5c5"), 0.9)
		12:
			hit_arc(player_pos, facing, 165, -0.1, power + 14, false, "eis")
			effect(player_pos + facing * 70, "FROSTSCHLAG", Color("b8f2ff"), 0.9)
		13:
			var origin := player_pos
			var hit_ids: Array = []
			for jump in 3:
				var best := -1
				var best_distance := 255.0 if jump == 0 else 190.0
				for i in enemies.size():
					if i in hit_ids: continue
					var dist: float = origin.distance_to(enemies[i]["pos"])
					if dist < best_distance:
						best = i
						best_distance = dist
				if best < 0: break
				hit_ids.append(best)
				var target: Vector2 = enemies[best]["pos"]
				lightning_lines.append({"from":origin, "to":target, "life":0.35})
				enemies[best]["stun"] = 0.8
				enemies[best]["hp"] = float(enemies[best]["hp"]) - (power + 14 - jump * 5)
				effect(target + Vector2(0, -35), "BLITZ", Color("fff09d"), 0.7)
				origin = target
			for i in range(enemies.size() - 1, -1, -1):
				if enemies[i]["hp"] <= 0: defeat_enemy(i)
		14:
			poison_blade_timer = 8.0 + (rank - 1) * 1.5
			effect(player_pos, "GIFTKLINGE", Color("b7e885"), 0.8)
		15:
			shield_timer = 5.0 + rank
			for i in range(enemies.size() - 1, -1, -1):
				var delta_pos: Vector2 = enemies[i]["pos"] - player_pos
				if delta_pos.length() < 235.0: damage_enemy(i, power + 32, delta_pos.normalized(), true)
			effect(player_pos, ABILITIES[id]["name"], Color("ffdc8a"), 1.6)
		24:
			for wave in 3:
				impact_zones.append({"pos":player_pos, "delay":0.25 + wave * 0.38, "radius":130.0 + wave * 95.0, "damage":power + 20, "element":["eis", "blitz", "gift"][wave], "kind":id})
		33:
			for wave in 6:
				var point := player_pos + facing * 210.0 + Vector2.RIGHT.rotated(float(wave) * 2.4) * (35.0 + (wave % 3) * 65.0)
				impact_zones.append({"pos":point, "delay":0.3 + wave * 0.19, "radius":95.0, "damage":power + 28, "element":"", "kind":id})
		16, 18, 20, 25, 26, 28, 29, 30:
			var count := 3 if id in [20, 26] else 1
			for shot in count:
				var angle := (float(shot) - float(count - 1) * 0.5) * 0.24
				var speed := 920.0 if id in [18, 25] else (390.0 if id == 20 else (570.0 if id in [16, 29] else 720.0))
				var shot_power := int(power * (0.72 if id in [20, 26] else (0.68 if id == 16 else 1.0))) + (22 if id in [18, 25] else 7)
				projectiles.append({"pos":player_pos, "dir":facing.rotated(angle), "speed":speed, "life":1.65 if id == 20 else 1.25, "damage":shot_power, "kind":3 if class_id == 2 else 2, "element":"gift" if id == 28 else ("eis" if id == 29 else ("blitz" if id in [18, 30] else "")), "spell_id":id, "pierce":id in [18, 25], "hits":[], "trail":[]})
		17:
			for i in range(enemies.size() - 1, -1, -1):
				var delta_pos: Vector2 = enemies[i]["pos"] - player_pos
				if delta_pos.length() < 200.0:
					damage_enemy(i, int(power * 0.72) + 5, delta_pos.normalized(), true, "eis")
		23:
			for wave in 3:
				impact_zones.append({"pos":player_pos, "delay":0.12 + wave * 0.22, "radius":110.0 + wave * 47.0, "damage":int(power * 0.47), "element":["eis", "blitz", "feuer"][wave], "kind":id})
		22, 31:
			for wave in 4:
				var point := player_pos + facing * (185.0 if id == 22 else 245.0) + Vector2.RIGHT.rotated(float(wave) * 2.0) * (30.0 + (wave % 2) * 65.0)
				impact_zones.append({"pos":point, "delay":0.35 + wave * 0.25, "radius":105.0 if id == 22 else 85.0, "damage":power + (22 if id == 22 else 7), "element":"feuer" if id == 22 else "", "kind":id})
		19, 27:
			var direction := facing if id == 19 else -facing
			var destination := player_pos + direction * (210 + (rank - 1) * 15)
			if not is_blocked(destination): player_pos = destination
			invulnerable = 0.5
		21:
			shield_timer = 4.0 + rank * 0.5
		32:
			rage_timer = 7.0 + rank
			for enemy in enemies:
				if enemy["pos"].distance_to(player_pos) < 400: enemy["marked"] = rage_timer
	spell_visuals.append({"kind":id, "pos":cast_pos, "end":player_pos, "dir":cast_dir, "rank":rank, "life":0.65 if id not in [2, 5] else 0.85, "max":0.65 if id not in [2, 5] else 0.85})
	play_sound("skill_%d" % id)

func update_projectiles(delta: float) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var p: Dictionary = projectiles[i]
		var spell_id: int = int(p.get("spell_id", -1))
		if spell_id == 20:
			var nearest := 235.0
			for enemy in enemies:
				if int(enemy["uid"]) in p["hits"]: continue
				var distance: float = p["pos"].distance_to(enemy["pos"])
				if distance < nearest:
					nearest = distance
					var desired: Vector2 = (enemy["pos"] - p["pos"]).normalized()
					p["dir"] = p["dir"].lerp(desired, minf(1.0, delta * 5.5)).normalized()
		if p.has("trail"):
			p["trail"].append(p["pos"])
			if p["trail"].size() > 5: p["trail"].pop_front()
		p["life"] = float(p["life"]) - delta
		p["pos"] = p["pos"] + p["dir"] * float(p["speed"]) * delta
		if p["life"] <= 0 or is_blocked(p["pos"], p["pos"] - p["dir"] * 12.0):
			if spell_id == 16: explode_fireball(p)
			if spell_id == 28: create_poison_cloud(p["pos"], int(p["damage"]))
			projectiles.remove_at(i)
			continue
		var consumed := false
		for e in range(enemies.size() - 1, -1, -1):
			var uid: int = int(enemies[e]["uid"])
			if uid in p["hits"]: continue
			if p["pos"].distance_to(enemies[e]["pos"]) < 28:
				p["hits"].append(uid)
				var impact: Vector2 = enemies[e]["pos"]
				damage_enemy(e, int(p["damage"]), p["dir"], false, str(p.get("element", "")))
				match spell_id:
					25:
						for survivor in enemies:
							if int(survivor["uid"]) == uid: survivor["marked"] = 5.0
						spell_visuals.append({"kind":25, "pos":impact, "end":impact, "dir":p["dir"], "rank":1, "life":0.4, "max":0.4})
					28: create_poison_cloud(impact, int(p["damage"]))
					29: frost_burst(impact, int(p["damage"] * 0.32), uid)
					30: chain_spell(impact, int(p["damage"] * 0.55), uid, 2)
					18: spell_visuals.append({"kind":18, "pos":impact, "end":impact, "dir":p["dir"], "rank":1, "life":0.28, "max":0.28})
				if not bool(p.get("pierce", false)):
					if spell_id == 16: explode_fireball(p)
					consumed = true
					break
		if consumed: projectiles.remove_at(i)

func create_poison_cloud(center: Vector2, damage: int) -> void:
	poison_clouds.append({"pos":center, "life":3.4, "max":3.4, "tick":0.0, "damage":maxi(3, int(damage * 0.24))})

func update_poison_clouds(delta: float) -> void:
	for i in range(poison_clouds.size() - 1, -1, -1):
		var cloud: Dictionary = poison_clouds[i]
		cloud["life"] = float(cloud["life"]) - delta
		if cloud["life"] <= 0:
			poison_clouds.remove_at(i)
			continue
		cloud["tick"] = float(cloud["tick"]) - delta
		if cloud["tick"] > 0: continue
		cloud["tick"] = 0.75
		for e in range(enemies.size() - 1, -1, -1):
			if cloud["pos"].distance_to(enemies[e]["pos"]) < 86:
				damage_enemy(e, int(cloud["damage"]), Vector2.ZERO, false, "gift")

func frost_burst(center: Vector2, damage: int, main_uid: int) -> void:
	for e in range(enemies.size() - 1, -1, -1):
		if int(enemies[e]["uid"]) == main_uid: continue
		if center.distance_to(enemies[e]["pos"]) < 88:
			damage_enemy(e, damage, Vector2.ZERO, false, "eis")
	spell_visuals.append({"kind":29, "pos":center, "end":center, "dir":Vector2.RIGHT, "rank":1, "life":0.48, "max":0.48})

func chain_spell(center: Vector2, damage: int, main_uid: int, jumps: int) -> void:
	var seen: Array = [main_uid]
	var origin := center
	for jump in jumps:
		var best := -1
		var nearest := 160.0
		for e in enemies.size():
			if int(enemies[e]["uid"]) in seen: continue
			var distance: float = origin.distance_to(enemies[e]["pos"])
			if distance < nearest:
				best = e
				nearest = distance
		if best < 0: break
		var target: Vector2 = enemies[best]["pos"]
		seen.append(int(enemies[best]["uid"]))
		lightning_lines.append({"from":origin, "to":target, "life":0.3})
		damage_enemy(best, maxi(2, damage - jump * 5), Vector2.ZERO, true, "blitz")
		origin = target

func explode_fireball(shot: Dictionary) -> void:
	var center: Vector2 = shot["pos"]
	for i in range(enemies.size() - 1, -1, -1):
		var offset: Vector2 = enemies[i]["pos"] - center
		if offset.length() < 85.0 and int(enemies[i]["uid"]) not in shot["hits"]:
			damage_enemy(i, int(shot["damage"] * 0.5), offset.normalized(), false, "feuer")
	spell_visuals.append({"kind":16, "pos":center, "end":center, "dir":Vector2.RIGHT, "rank":1, "life":0.48, "max":0.48})
	create_burning_ground(center, maxi(3, int(shot["damage"] * 0.22)), 4.5)

func update_impact_zones(delta: float) -> void:
	for i in range(impact_zones.size() - 1, -1, -1):
		var zone: Dictionary = impact_zones[i]
		zone["delay"] = float(zone["delay"]) - delta
		if zone["delay"] > 0.0: continue
		for e in range(enemies.size() - 1, -1, -1):
			var offset: Vector2 = enemies[e]["pos"] - zone["pos"]
			if offset.length() < float(zone["radius"]):
				damage_enemy(e, int(zone["damage"]), offset.normalized(), false, str(zone["element"]))
		spell_visuals.append({"kind":int(zone["kind"]), "pos":zone["pos"], "end":zone["pos"], "dir":Vector2.RIGHT, "rank":1, "life":0.62, "max":0.62})
		if int(zone["kind"]) == 22: create_burning_ground(zone["pos"], int(zone["damage"] * 0.18), 5.0)
		impact_zones.remove_at(i)

func create_burning_ground(pos: Vector2, damage: int, duration: float) -> void:
	battle_zones.append({"kind":"fire", "pos":pos, "radius":88.0, "life":duration, "max":duration, "tick":0.15, "damage":maxi(2, damage)})

func standing_in_battle_zone() -> bool:
	for zone in battle_zones:
		if str(zone["kind"]) == "banner" and player_pos.distance_to(zone["pos"]) < float(zone["radius"]): return true
	return false

func update_battle_zones(delta: float) -> void:
	for i in range(battle_zones.size() - 1, -1, -1):
		var zone: Dictionary = battle_zones[i]
		zone["life"] = float(zone["life"]) - delta
		if zone["life"] <= 0.0:
			battle_zones.remove_at(i)
			continue
		if str(zone["kind"]) != "fire": continue
		zone["tick"] = float(zone["tick"]) - delta
		if zone["tick"] > 0.0: continue
		zone["tick"] = 0.65
		for e in range(enemies.size() - 1, -1, -1):
			if enemies[e]["pos"].distance_to(zone["pos"]) < float(zone["radius"]):
				damage_enemy(e, int(zone["damage"]), Vector2.ZERO, false, "feuer")

func enter_arena(mode: String) -> void:
	if arena_mode != "": return
	if mode == "survival" and inventory.size() >= 42:
		message("Für Arvens Truhe brauchst du einen freien Platz im Inventar.")
		return
	final_countdown = -1.0
	# Bossbeute am letzten Siegel soll durch die sofortige Reise nicht verloren gehen.
	if mode == "final":
		for i in range(drops.size() - 1, -1, -1):
			var prize: Dictionary = drops[i]
			if prize.has("item") and prize["pos"].distance_to(player_pos) < 450.0 and can_add_item(prize["item"]):
				add_item(prize["item"])
				drops.remove_at(i)
	save_game()
	arena_return_pos = player_pos
	arena_mode = mode
	arena_wave = 0
	arena_intermission = 2.5
	arena_reward_claimed = false
	player_pos = ARENA_CENTER
	enemies.clear()
	drops.clear()
	enemy_projectiles.clear()
	projectiles.clear()
	battle_zones.clear()
	hp = max_hp()
	energy = max_energy()
	message("%s · Die erste Welle naht!" % ("LETZTE WACHE" if mode == "final" else "ARENA DER EWIGEN WACHT"))
	play_sound("level")

func update_arena(delta: float) -> void:
	if not enemies.is_empty(): return
	if arena_mode == "final" and arena_wave >= 10:
		finish_final_arena()
		return
	if arena_intermission < 0.0:
		arena_intermission = 3.5
		message("Welle %d überstanden · Die nächste beginnt gleich." % arena_wave)
		return
	arena_intermission -= delta
	if arena_intermission <= 0.0:
		arena_wave += 1
		arena_intermission = -1.0
		var count := mini(24, 3 + arena_wave * 2)
		if arena_mode == "final": count = 3 + arena_wave * 2
		for i in count:
			var angle := (float(i) + randf_range(-0.16, 0.16)) * TAU / float(count)
			var pool: Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26]
			var type: int = int(pool[(i * 7 + arena_wave * 3) % pool.size()])
			var elite_kind := 2 if (arena_wave % 5 == 0 and i == count - 1) else (1 if i % 7 == 0 else 0)
			# Die Welle formiert sich rund um den aktuellen Standort, statt weit am unsichtbaren Rand zu warten.
			var spawn_center: Vector2 = player_pos.lerp(ARENA_CENTER, 0.24)
			var spawn_pos: Vector2 = spawn_center + Vector2.RIGHT.rotated(angle) * 355.0
			if spawn_pos.distance_to(ARENA_CENTER) > ARENA_RADIUS - 32.0:
				spawn_pos = ARENA_CENTER + (spawn_pos - ARENA_CENTER).normalized() * (ARENA_RADIUS - 32.0)
			var enemy: Dictionary = make_enemy(type, spawn_pos, elite_kind)
			var multiplier := 1.0 + arena_wave * (0.085 if arena_mode == "survival" else 0.055)
			enemy["hp"] = float(enemy["hp"]) * multiplier
			enemy["max_hp"] = enemy["hp"]
			enemy["arena_power"] = 1.0 + arena_wave * (0.075 if arena_mode == "survival" else 0.045)
			enemy["arena"] = true
			enemies.append(enemy)
		message("WELLE %d%s · %d Feinde!" % [arena_wave, "/10" if arena_mode == "final" else "", count])
		play_sound("menu")

func finish_final_arena() -> void:
	final_completed = true
	arena_return_pos = Vector2(900, 1050)
	panel = "victory"
	enemies.clear()
	play_sound("level")
	save_game()

func finish_survival_run() -> void:
	arena_reward_wave = maxi(1, arena_wave)
	arena_best = maxi(arena_best, arena_reward_wave)
	arena_leaderboard.append({"wave":arena_reward_wave, "level":level, "class":CLASS_NAMES[class_id]})
	arena_leaderboard.sort_custom(func(a, b): return int(a["wave"]) > int(b["wave"]))
	if arena_leaderboard.size() > 10: arena_leaderboard.resize(10)
	enemies.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	panel = "arena_reward"
	play_sound("level")
	save_game()

func claim_arena_chest() -> void:
	if arena_reward_claimed: return
	var tier := clampi(int(arena_reward_wave / 5.0), 0, 3)
	if arena_reward_wave >= 25 and level >= 30: tier = 4
	var reward := make_item("Truhe der Ewigen Wacht · Welle %d" % arena_reward_wave, class_weapon_icon(), tier, 6 + level * 2 + arena_reward_wave, 0, ["eis", "blitz", "gift"][arena_reward_wave % 3], level)
	if not can_add_item(reward):
		message("Inventar voll. Für die Arenabelohnung brauchst du einen freien Platz.")
		return
	add_item(reward)
	arena_reward_claimed = true
	message("Arenatruhe geöffnet: %s!" % reward["name"])
	save_game()

func leave_arena() -> void:
	if arena_mode == "survival" and not arena_reward_claimed: return
	arena_mode = ""
	player_pos = Vector2(900, 1050) if final_completed else arena_return_pos
	hp = max_hp()
	energy = max_energy()
	enemies.clear()
	enemy_projectiles.clear()
	battle_zones.clear()
	panel = ""
	previous_region = region_at(player_pos)
	message("Sonnenhain jubelt dir zu! Die Reise geht im freien Modus weiter." if final_completed else "Du bist aus der Arena zurückgekehrt.")
	save_game()

func dungeon_blocked(pos: Vector2) -> bool:
	if not Rect2(DUNGEON_CENTER - Vector2(660, 390), Vector2(1320, 780)).has_point(pos): return true
	for pillar in dungeon_pillars():
		if Rect2(pillar - Vector2(51, 55), Vector2(102, 110)).has_point(pos): return true
	return false

func dungeon_pillars() -> Array:
	var pillars: Array = []
	for offset in [Vector2(-330, -190), Vector2(-330, 190), Vector2(60, -150), Vector2(60, 150), Vector2(385, -200), Vector2(385, 200)]:
		pillars.append(DUNGEON_CENTER + offset)
	return pillars

func dungeon_torches() -> Array:
	var torches: Array = []
	for offset in [Vector2(-555, -300), Vector2(-555, 300), Vector2(-195, -310), Vector2(-195, 310), Vector2(220, -310), Vector2(220, 310), Vector2(555, -300), Vector2(555, 300)]:
		torches.append(DUNGEON_CENTER + offset)
	return torches

func tavern_blocked(pos: Vector2) -> bool:
	var local := pos - INTERIOR_CENTER
	if absf(local.x) > 445.0 or absf(local.y) > 245.0: return true
	if Rect2(INTERIOR_CENTER + Vector2(-265, -230), Vector2(530, 85)).has_point(pos): return true
	for offset in [Vector2(-295, -15), Vector2(285, -15), Vector2(-290, 135), Vector2(290, 135)]:
		if Rect2(INTERIOR_CENTER + offset - Vector2(49, 35), Vector2(98, 70)).has_point(pos): return true
	return false

func enter_tavern() -> void:
	interior_return_pos = TAVERN_HOUSE + Vector2(92, 205)
	save_game()
	interior_id = 0
	player_pos = INTERIOR_CENTER + Vector2(0, 178)
	enemies.clear()
	drops.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	battle_zones.clear()
	message("Zur Steinrose · Alma schenkt Reisenden einen Platz am Feuer. E: ansprechen oder hinausgehen.")
	play_sound("menu")

func leave_tavern() -> void:
	interior_id = -1
	player_pos = interior_return_pos
	previous_region = region_at(player_pos)
	message("Du trittst wieder auf die Gassen von Sonnenhain.")
	play_sound("menu")
	save_game()

func enter_dungeon(index: int) -> void:
	if dungeon_id >= 0 or arena_mode != "": return
	dungeon_return_pos = player_pos
	save_game()
	dungeon_id = index
	player_pos = DUNGEON_CENTER + Vector2(-555, 0)
	enemies.clear()
	drops.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	battle_zones.clear()
	for i in (8 + index * 2):
		var position := DUNGEON_CENTER + Vector2(-220 + (i % 4) * 180, (-1 if int(i / 4.0) % 2 == 0 else 1) * (95 + (i % 3) * 65))
		if dungeon_blocked(position): position.y = DUNGEON_CENTER.y + (85 if i % 2 == 0 else -85)
		enemies.append(make_enemy(int(DUNGEON_ENEMIES[index][i % 2]), position, 2 if i == 7 + index * 2 else (1 if i % 5 == 0 else 0)))
	message("%s · Die Fackeln weisen dir den Weg. E an der Tür führt hinaus." % DUNGEON_NAMES[index])
	play_sound("menu")

func leave_dungeon() -> void:
	dungeon_id = -1
	player_pos = dungeon_return_pos
	enemies.clear()
	drops.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	battle_zones.clear()
	previous_region = region_at(player_pos)
	message("Du kehrst ans Tageslicht zurück.")
	play_sound("dodge")
	save_game()

func open_dungeon_chest() -> void:
	if dungeon_id < 0 or dungeon_chests_opened[dungeon_id]: return
	if not enemies.is_empty():
		message("Die Gewölbetruhe bleibt versiegelt, solange Feinde hier lauern.")
		return
	var treasure := make_item("Relikt aus %s" % DUNGEON_NAMES[dungeon_id], class_weapon_icon(), 2 + int(dungeon_id > 0), 15 + region_level(int(ENEMY_TYPES[int(DUNGEON_ENEMIES[dungeon_id][0])]["region"])) * 2, 280 + dungeon_id * 190, ["blitz", "eis", "gift"][dungeon_id])
	if not can_add_item(treasure):
		message("Deine Tasche ist voll. Die Truhe wartet auf deine Rückkehr.")
		return
	add_item(treasure)
	dungeon_chests_opened[dungeon_id] = true
	play_sound("level")
	message("Gewölbe geräumt! %s erhalten." % treasure["name"])
	save_game()

func make_enemy(type: int, pos: Vector2, elite_kind: int = 0) -> Dictionary:
	var info: Dictionary = ENEMY_TYPES[type]
	var health: float = float(info["hp"]) * (1.2 + 0.11 * region_level(int(info["region"]))) * [1.0, 2.1, 4.2][elite_kind]
	return {"uid":randi(), "type":type, "pos":pos, "hp":health, "max_hp":health, "flash":0.0, "hit":0.0, "stun":0.0, "slow":0.0, "poison":0.0, "poison_tick":1.0, "shot":randf_range(0.7, 1.7), "seed":randf() * TAU, "elite":elite_kind, "facing":Vector2.DOWN, "walking":false, "anim_time":0.0, "attack_anim":0.0}

func spawn_position_allowed(p: Vector2, target_region: int) -> bool:
	if region_at(p) != target_region: return false
	if target_region == 0: return false
	# Keine Gegner auf Wegen, direkt an Wegsteinen, Portalen, Landmarken oder Häusern.
	if distance_to_trail(p) < 165.0: return false
	if is_blocked(p, p): return false
	for landmark in LANDMARKS:
		if p.distance_to(landmark["pos"]) < 235.0: return false
	for stone in WAYSTONES:
		if p.distance_to(stone) < 185.0: return false
	for portal in PORTALS:
		if p.distance_to(portal[0]) < 210.0 or p.distance_to(portal[1]) < 210.0: return false
	for npc in NPCS:
		if p.distance_to(npc["pos"]) < 170.0: return false
	if target_region == 1 and p.distance_to(RESCUE_POS) < 330.0: return false
	return true

func flee_from_safe_zone(enemy: Dictionary, delta: float) -> bool:
	if arena_mode != "" or dungeon_id >= 0: return false
	if region_at(player_pos) != 0: return false
	var ep: Vector2 = enemy["pos"]
	var away: Vector2 = ep - player_pos
	if away.length() > 920.0: return false
	if away.length() < 0.01: away = Vector2.RIGHT
	var next_pos: Vector2 = ep + away.normalized() * 155.0 * delta
	if region_at(next_pos) == region_at(ep) and not terrain_blocked(next_pos): enemy["pos"] = next_pos
	return true

func spawn_enemy() -> void:
	if dungeon_id >= 0 or arena_mode != "": return
	var region: int = region_at(player_pos)
	# Sonnenhain ist eine echte Sicherheitszone: dort entstehen keine normalen Gegner.
	if region == 0: return
	var target_region: int = region
	var candidates: Array = []
	for i in ENEMY_TYPES.size():
		if i not in [12, 13, 14] and int(ENEMY_TYPES[i]["region"]) == target_region: candidates.append(i)
	if candidates.is_empty(): return
	var type: int = int(candidates.pick_random())
	var p: Vector2 = Vector2.ZERO
	var found: bool = false
	# Mehrere Versuche verhindern Spawns auf Wegen, an Häusern oder Landmarken.
	for attempt in 14:
		p = player_pos + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(470.0, 820.0)
		if spawn_position_allowed(p, target_region) and p.distance_to(player_pos) >= 390.0:
			found = true
			break
	if not found: return
	var roll: float = randf()
	enemies.append(make_enemy(type, p, 2 if roll < 0.01 and target_region >= 3 else (1 if roll < 0.075 else 0)))

func spawn_nearby_boss() -> void:
	for i in 3:
		var site: Vector2 = LANDMARKS[i + 2]["pos"]
		if player_pos.distance_to(site) > 700 or boss_cooldowns[i] > 0 or region_at(player_pos) != region_at(site): continue
		var boss_type := 12 + i
		var exists := false
		for enemy in enemies:
			if enemy["type"] == boss_type:
				exists = true
				break
		if exists: continue
		var info: Dictionary = ENEMY_TYPES[boss_type]
		var boss_hp: float = float(info["hp"]) * (1.2 + 0.08 * region_level(int(info["region"])))
		enemies.append({"uid":randi(), "type":boss_type, "pos":site + Vector2(0, 125), "hp":boss_hp, "max_hp":boss_hp, "flash":0.0, "hit":0.0, "stun":0.0, "slow":0.0, "poison":0.0, "poison_tick":1.0, "shot":1.5, "seed":randf() * 6.28})
		message("Boss entdeckt: %s!" % info["name"])

func update_rescue() -> void:
	if rescue_state == 3 or player_pos.distance_to(RESCUE_POS) > 650: return
	if rescue_state == 0:
		rescue_state = 1
		rescue_intro_timer = 9.0
		rescue_banner_timer = 5.0
		effect(RESCUE_POS + Vector2(0, -210), "DORF IN GEFAHR", Color("ffcf72"), 5.0)
		message("Alarm! Blütenweiler wird angegriffen. Die Bewohner rufen um Hilfe!")
		play_sound("menu")
		save_game()
	if rescue_state != 1: return
	var active := 0
	for enemy in enemies:
		if bool(enemy.get("invasion", false)): active += 1
	var needed := mini(5, maxi(0, RESCUE_GOAL - rescue_kills - active))
	var positions := [Vector2(-250, -40), Vector2(230, -70), Vector2(-220, 140), Vector2(240, 130), Vector2(0, 310)]
	for n in needed:
		var spot: Vector2 = RESCUE_POS + positions[(rescue_kills + active + n) % positions.size()]
		var kind := (rescue_kills + active + n) % 2
		var info: Dictionary = ENEMY_TYPES[kind]
		var enemy_hp: float = float(info["hp"]) * 1.4
		var invader := make_enemy(kind, spot)
		invader["hp"] = enemy_hp
		invader["max_hp"] = enemy_hp
		invader["invasion"] = true
		enemies.append(invader)

func update_enemies(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		if float(enemy["hp"]) <= 0:
			defeat_enemy(i)
			continue
		if enemy["pos"].distance_to(player_pos) > 1250 and arena_mode == "":
			enemies.remove_at(i)
			continue
		enemy["flash"] = maxf(0.0, float(enemy["flash"]) - delta)
		enemy["hit"] = maxf(0.0, float(enemy["hit"]) - delta)
		enemy["stun"] = maxf(0.0, float(enemy["stun"]) - delta)
		enemy["slow"] = maxf(0.0, float(enemy["slow"]) - delta)
		enemy["marked"] = maxf(0.0, float(enemy.get("marked", 0.0)) - delta)
		enemy["attack_anim"] = maxf(0.0, float(enemy.get("attack_anim", 0.0)) - delta)
		enemy["walking"] = false
		if enemy["poison"] > 0:
			enemy["poison"] = maxf(0.0, float(enemy["poison"]) - delta)
			enemy["poison_tick"] = float(enemy["poison_tick"]) - delta
			if enemy["poison_tick"] <= 0:
				enemy["poison_tick"] = 1.0
				enemy["hp"] = float(enemy["hp"]) - 6
				effect(enemy["pos"] + Vector2(0, -28), "-6", Color("b7e885"), 0.6)
				if enemy["hp"] <= 0:
					defeat_enemy(i)
					continue
		enemy["shot"] = maxf(0.0, float(enemy["shot"]) - delta)
		var info: Dictionary = ENEMY_TYPES[int(enemy["type"])]
		var mob_data := info.get("mob_data", null) as MobData
		if flee_from_safe_zone(enemy, delta):
			if enemy["pos"].distance_to(player_pos) > 880.0:
				enemies.remove_at(i)
			continue
		var offset: Vector2 = player_pos - enemy["pos"]
		var distance := offset.length()
		if enemy["stun"] <= 0 and distance < (ARENA_RADIUS * 2.0 if arena_mode != "" else 390.0) and distance > 33 and (arena_mode != "" or region_at(player_pos) != 0):
			var speed: float = float(info["speed"]) * (0.45 if enemy["slow"] > 0 else 1.0) * (1.08 if int(enemy.get("elite", 0)) > 0 else 1.0) * delta
			for angle in [0.0, 0.75, -0.75, 1.4, -1.4]:
				var next_pos: Vector2 = enemy["pos"] + offset.normalized().rotated(angle) * speed
				var clear_world_path := not terrain_blocked(next_pos)
				if mob_data != null and mob_data.flying:
					clear_world_path = not blocked_by_region_wall(next_pos)
				if (arena_mode != "" and next_pos.distance_to(ARENA_CENTER) < ARENA_RADIUS - 16.0) or (dungeon_id >= 0 and not dungeon_blocked(next_pos)) or (arena_mode == "" and dungeon_id < 0 and region_at(next_pos) == region_at(enemy["pos"]) and clear_world_path):
					var movement: Vector2 = next_pos - enemy["pos"]
					enemy["pos"] = next_pos
					if movement.length_squared() > 0.001:
						enemy["facing"] = movement.normalized()
						enemy["walking"] = true
						enemy["anim_time"] = float(enemy.get("anim_time", 0.0)) + delta
					break
		if mob_data != null and mob_data.ranged and distance > mob_data.ranged_min_distance and distance < mob_data.ranged_max_distance and enemy["stun"] <= 0 and enemy["shot"] <= 0 and (arena_mode != "" or region_at(player_pos) != 0):
			enemy["shot"] = randf_range(mob_data.ranged_cooldown_min, mob_data.ranged_cooldown_max)
			enemy["attack_anim"] = 0.28
			enemy_projectiles.append({"pos":enemy["pos"], "dir":offset.normalized(), "speed":mob_data.projectile_speed, "life":2.0, "damage":int(enemy_damage(int(enemy["type"])) * [1.0, 1.25, 1.6][int(enemy.get("elite", 0))] * float(enemy.get("arena_power", 1.0))), "type":int(enemy["type"])})
		if distance < (mob_data.melee_range if mob_data != null else 43.0) and enemy["hit"] <= 0 and (arena_mode != "" or region_at(player_pos) != 0):
			enemy["hit"] = 1.0
			enemy["attack_anim"] = 0.24
			if invulnerable <= 0:
				apply_player_damage(int(enemy_damage(int(enemy["type"])) * [1.0, 1.25, 1.6][int(enemy.get("elite", 0))] * float(enemy.get("arena_power", 1.0))))
				if panel == "arena_reward" or (arena_mode == "" and enemies.is_empty()): return

func apply_player_damage(raw: int) -> void:
	if creative_mode: return
	var dealt := maxi(1, raw - equipment_power(equipped_armor_uid))
	if shield_timer > 0: dealt = maxi(1, int(dealt * 0.35))
	if class_id == 0 and standing_in_battle_zone(): dealt = maxi(1, int(dealt * 0.78))
	if class_id == 1 and shield_timer > 0 and learned[21]:
		for enemy in enemies:
			if enemy["pos"].distance_to(player_pos) < 95:
				enemy["slow"] = 3.5
				enemy["stun"] = 0.4
	hp -= dealt
	invulnerable = 0.5
	effect(player_pos + Vector2(0, -30), "-%d" % dealt, Color("ff888d"), 0.75)
	play_sound("hit")
	if hp <= 0: respawn()

func update_enemy_projectiles(delta: float) -> void:
	for i in range(enemy_projectiles.size() - 1, -1, -1):
		var shot: Dictionary = enemy_projectiles[i]
		shot["life"] = float(shot["life"]) - delta
		shot["pos"] = shot["pos"] + shot["dir"] * float(shot["speed"]) * delta
		if shot["life"] <= 0 or (arena_mode == "" and region_at(shot["pos"]) == 0):
			enemy_projectiles.remove_at(i)
			continue
		if shot["pos"].distance_to(player_pos) < 25:
			if invulnerable <= 0: apply_player_damage(int(shot["damage"]))
			if panel == "arena_reward" or enemy_projectiles.is_empty(): return
			enemy_projectiles.remove_at(i)

func respawn() -> void:
	if arena_mode == "survival":
		finish_survival_run()
		return
	if arena_mode == "final":
		arena_mode = ""
		player_pos = Vector2(900, 1050)
		enemies.clear()
		message("Die letzte Wache hält noch stand. Sprich mit Arven, um es erneut zu versuchen.")
		hp = max_hp()
		energy = max_energy()
		save_game()
		return
	if dungeon_id >= 0:
		dungeon_id = -1
		enemies.clear()
		enemy_projectiles.clear()
		drops.clear()
	player_pos = Vector2(900, 1050)
	hp = max_hp()
	energy = max_energy()
	gold = maxi(0, gold - 20)
	panel = ""
	message("Du wurdest im Dorf wiederbelebt. -20 Gold")
	save_game()

func defeat_enemy(index: int) -> void:
	var enemy: Dictionary = enemies[index]
	var invasion: bool = bool(enemy.get("invasion", false))
	var type: int = int(enemy["type"])
	var pos: Vector2 = enemy["pos"]
	enemies.remove_at(index)
	if arena_mode != "": return # Arenagegner geben weder Beute noch Erfahrung.
	for event_index in WORLD_EVENTS.size():
		if int(event_states[event_index]) != 1: continue
		if pos.distance_to(WORLD_EVENTS[event_index]["pos"]) > 560: continue
		event_progress[event_index] += 1
		if event_progress[event_index] >= int(WORLD_EVENTS[event_index]["goal"]):
			event_states[event_index] = 2
			message("%s ist in Sicherheit! Sprich erneut mit %s (E)." % [WORLD_EVENTS[event_index]["role"], WORLD_EVENTS[event_index]["name"]])
			play_sound("level")
	if invasion and rescue_state == 1:
		rescue_kills += 1
		if rescue_kills >= RESCUE_GOAL:
			rescue_state = 2
			rescue_banner_timer = 6.0
			rescue_intro_timer = 5.0
			effect(RESCUE_POS + Vector2(0, -210), "BLÜTENWEILER GERETTET", Color("a8edb5"), 5.0)
			message("Blütenweiler gerettet! Nela wartet am Dorfplatz auf dich (E).")
			play_sound("level")
			save_game()
		else:
			message("Blütenweiler verteidigt: %d/%d Dornenwesen besiegt." % [rescue_kills, RESCUE_GOAL])
	if type in [12, 13, 14]:
		boss_cooldowns[type - 12] = 90.0
		bosses_defeated[type - 12] = true
		var boss_element: String = ["blitz", "eis", "gift"][type - 12]
		var boss_item := make_item("%s · %s" % [ENEMY_TYPES[type]["name"], String(boss_element).capitalize()], class_weapon_icon(), 3 + int(type == 14), 28 + (type - 12) * 8, 700 + type * 35, boss_element)
		drops.append({"pos":pos + Vector2(25, 0), "item":boss_item, "life":120.0})
		message("%s besiegt! Ein neuer Weg ist offen." % ENEMY_TYPES[type]["name"])
		if bosses_defeated.count(true) == bosses_defeated.size() and not final_completed and final_countdown < 0.0:
			final_countdown = 8.0
			message("Alle Siegel sind gefallen! In Kürze öffnet sich die Arena der letzten Wache.")
	var area_level := region_level(int(ENEMY_TYPES[type]["region"]))
	var elite_kind: int = int(enemy.get("elite", 0))
	gain_xp(int((int(ENEMY_TYPES[type]["xp"]) + area_level * 3 + int(area_level * area_level * 0.15)) * [1.0, 1.55, 2.4][elite_kind]))
	var coins: int = randi_range(2, 7) * (1 + int(type / 3.0)) * int([1, 3, 7][elite_kind])
	drops.append({"pos":pos + Vector2(8, 12), "gold":coins, "life":80.0})
	for qindex in quests.size():
		var quest: Dictionary = quests[qindex]
		if quest["state"] == 1 and int(QUESTS[qindex]["target"]) == type:
			quest["progress"] = mini(int(QUESTS[qindex]["count"]), int(quest["progress"]) + 1)
			if quest["progress"] >= QUESTS[qindex]["count"]:
				quest["state"] = 2
				message("Questziel erreicht: %s. Kehre zurück!" % QUESTS[qindex]["title"])
	if randf() < (0.38 if elite_kind == 2 else (0.24 if elite_kind == 1 else 0.14)):
		var item: Dictionary = random_loot(type)
		drops.append({"pos":pos, "item":item, "life":90.0})
	if randf() < 0.03:
		drops.append({"pos":pos + Vector2(20, 0), "item":make_item("Heiltrank", "potion", 1, 0, 18), "life":90.0})
	if type in [12, 13, 14]: save_game()

func gain_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_required():
		xp -= xp_required()
		level += 1
		var earned_point := level % 2 == 0 or level in [3, 8, 12]
		if earned_point: skill_points += 1
		if level >= 20:
			learned[class_ultimate()] = true
			skill_levels[class_ultimate()] = mini(5, 1 + (level - 20) / 5)
		hp = max_hp()
		energy = max_energy()
		message("LEVEL %d! %s" % [level, "+1 Skillpunkt · öffne K." if earned_point else "Neue Stärke und Gesundheit."])
		play_sound("level")

func skill_rank_level(index: int, rank: int) -> int:
	return int(ABILITIES[index]["req"]) + [0, 3, 8, 15, 24][clampi(rank - 1, 0, 4)]

func make_item(name: String, icon: String, rarity: int, power: int, value: int, element: String = "", item_level: int = -1) -> Dictionary:
	var ilvl := maxi(1, level if item_level < 0 else item_level)
	var bonus: int = maxi(0, rarity + int(ilvl / 9.0))
	var strength: int = bonus if icon == "sword" else (int(bonus / 2.0) if icon in ["armor", "ring"] else 0)
	var agility: int = bonus if icon == "bow" else (int(bonus / 2.0) if icon in ["armor", "ring"] else 0)
	var intellect: int = bonus if icon == "staff" else (int(bonus / 2.0) if icon in ["armor", "ring"] else 0)
	var fair_value := value if icon == "potion" else 10 + ilvl * 4 + maxi(0, power) * (3 if icon in ["sword", "staff", "bow"] else 2) + rarity * rarity * 32 + (25 if element != "" else 0) + (strength + agility + intellect) * 5
	var item := {"uid":next_uid, "name":name, "icon":icon, "rarity":rarity, "power":power, "value":fair_value, "element":element, "level":ilvl, "str":strength, "agi":agility, "int":intellect, "count":1, "design":absi(hash(name)) % 4, "protected":false}
	next_uid += 1
	return item

func stack_limit(item: Dictionary) -> int:
	var icon: String = str(item.get("icon", ""))
	if icon == "potion": return 16
	if icon in ["gem", "herb", "essence"]: return 1000000000
	return 1

func stack_matches(a: Dictionary, b: Dictionary) -> bool:
	return a.get("icon") == b.get("icon") and a.get("name") == b.get("name") and a.get("rarity") == b.get("rarity") and a.get("element", "") == b.get("element", "") and ItemProtection.is_protected(a) == ItemProtection.is_protected(b)

func item_sale_value(item: Dictionary) -> int:
	return int(item.get("stack_value", int(item.get("value", 0)) * int(item.get("count", 1))))

func can_add_item(item: Dictionary) -> bool:
	var limit := stack_limit(item)
	var capacity := maxi(0, 42 - inventory.size()) * limit
	for owned in inventory:
		if limit > 1 and stack_matches(owned, item): capacity += limit - int(owned.get("count", 1))
	return capacity >= maxi(1, int(item.get("count", 1)))

func add_item(item: Dictionary) -> bool:
	if not can_add_item(item): return false
	var remaining := maxi(1, int(item.get("count", 1)))
	var remaining_value := item_sale_value(item)
	if stack_limit(item) > 1:
		for owned in inventory:
			if not stack_matches(owned, item): continue
			var space := stack_limit(item) - int(owned.get("count", 1))
			var moved := mini(space, remaining)
			if moved <= 0: continue
			var moved_value := int(round(float(remaining_value) * moved / remaining))
			owned["stack_value"] = item_sale_value(owned) + moved_value
			owned["count"] = int(owned.get("count", 1)) + moved
			remaining -= moved
			remaining_value -= moved_value
			if remaining <= 0: return true
	while remaining > 0 and inventory.size() < 42:
		var entry: Dictionary = item.duplicate(true)
		var amount := mini(remaining, stack_limit(item))
		var entry_value := int(round(float(remaining_value) * amount / remaining))
		entry["count"] = amount
		entry["stack_value"] = entry_value
		inventory.append(entry)
		remaining -= amount
		remaining_value -= entry_value
	return remaining == 0

func random_loot(type: int) -> Dictionary:
	var chance := randf()
	var rarity := 0
	var area_level := region_level(int(ENEMY_TYPES[type]["region"]))
	if area_level >= 30 and chance < 0.0008: rarity = 4
	elif area_level >= 16 and chance < 0.025: rarity = 3
	elif chance < 0.13: rarity = 2
	elif chance < 0.47: rarity = 1
	var name: String = ENEMY_TYPES[type]["name"]
	var rank: String = ["Alte", "Feine", "Seltene", "Epische", "Legendäre"][rarity]
	var icon: String = [class_weapon_icon(), "gem", "ring", "armor", "herb"][randi_range(0, 4)]
	var item_name: String = "%s %s" % [rank, {"sword":"Klinge", "staff":"Stab", "bow":"Bogen", "gem":"Essenz", "ring":"Ring", "armor":"Rüstung", "herb":"Kräuter"}[icon]]
	if rarity >= 3: item_name = "%s des %s" % [item_name, name]
	var strength: int = (3 + area_level * 2 + rarity * 5 if icon in ["sword", "staff", "bow"] else (1 + int(area_level / 5) + rarity * 2 if icon == "armor" else (8 + area_level + rarity * 4 if icon == "ring" else 0)))
	var element := ""
	if icon in ["sword", "staff", "bow"] and rarity >= 1 and randf() < 0.32:
		element = "gift" if type in [2, 3, 10] else ("eis" if type in [6, 7, 11] else ("blitz" if type in [5, 8, 9] else ["eis", "blitz", "gift"].pick_random()))
		item_name = "%s · %s" % [item_name, element.capitalize()]
	return make_item(item_name, icon, rarity, strength, 0, element, area_level)

func collect_drops() -> void:
	for i in range(drops.size() - 1, -1, -1):
		if drops[i]["pos"].distance_to(player_pos) < 36:
			if drops[i].has("gold"):
				var amount: int = int(drops[i]["gold"])
				gold += amount
				drops.remove_at(i)
				play_sound("pickup")
				effect(player_pos + Vector2(0, -36), "+%d Gold" % amount, Color("ffdb83"), 1.0)
				continue
			var item: Dictionary = drops[i]["item"]
			if not can_add_item(item):
				message("Inventar voll! Verkaufe Gegenstände im Dorf.")
				continue
			add_item(item)
			drops.remove_at(i)
			play_sound("pickup")
			message("Gefunden: %s · %s" % [item["name"], RARITY_NAMES[int(item["rarity"])]] )
			save_game()

func interact() -> void:
	if arena_mode != "": return
	if interior_id >= 0:
		if player_pos.distance_to(INTERIOR_CENTER + Vector2(0, 210)) < 95:
			leave_tavern()
		elif player_pos.distance_to(INTERIOR_CENTER + Vector2(0, -105)) < 130:
			var cost := 9 + level * 2
			if hp >= max_hp(): message("Alma: Willkommen, Reisender! Draußen riecht es wieder nach Regen und Abenteuer.")
			elif gold >= cost:
				gold -= cost
				hp = max_hp()
				play_trade_sound("buy")
				message("Alma stellt dir Eintopf hin. Du ruhst dich aus. Vollständig geheilt für %d Gold." % cost)
				save_game()
			else: message("Alma: Für eine warme Mahlzeit brauche ich %d Gold. Ruh dich am Feuer aus." % cost)
		return
	if dungeon_id >= 0:
		if player_pos.distance_to(DUNGEON_CENTER + Vector2(-570, 0)) < 110:
			leave_dungeon()
		elif player_pos.distance_to(DUNGEON_CENTER + Vector2(555, 0)) < 105:
			open_dungeon_chest()
		return
	if player_pos.distance_to(TAVERN_HOUSE + Vector2(91, 157)) < 112:
		enter_tavern()
		return
	for index in DUNGEON_ENTRANCES.size():
		var entrance: Vector2 = LANDMARKS[int(DUNGEON_ENTRANCES[index])]["pos"] + Vector2(-30, 70)
		if player_pos.distance_to(entrance) < 84:
			enter_dungeon(index)
			return
	for portal in PORTALS:
		var near_old: bool = player_pos.distance_to(portal[0]) < 112
		var near_new: bool = player_pos.distance_to(portal[1]) < 112
		if near_old or near_new:
			if near_old and not region_available(int(portal[2])):
				message("%s öffnet sich ab Level %d." % [region_name(int(portal[2])), region_level(int(portal[2]))])
				return
			player_pos = portal[1] + Vector2(0, 110) if near_old else portal[0] + Vector2(0, 110)
			enemies.clear()
			enemy_projectiles.clear()
			message("Der alte Torbogen führt nach %s." % region_name(region_at(player_pos)))
			play_sound("dodge")
			save_game()
			return
	if rescue_state >= 2 and player_pos.distance_to(RESCUE_POS + Vector2(0, 120)) < 120:
		if rescue_state == 2:
			if inventory.size() >= 42:
				message("Nela: Dein Beutel ist voll. Komm nach dem Verkauf wieder!")
				return
			var weapon_name: String = {"sword":"Klinge", "staff":"Stab", "bow":"Bogen"}[class_weapon_icon()]
			inventory.append(make_item("%s der Morgenwache · Blitz" % weapon_name, class_weapon_icon(), 2, 18, 260, "blitz"))
			gold += 80
			rescue_state = 3
			gain_xp(160)
			reward_scene_timer = 7.0
			play_sound("level")
			message("Nela: Danke! Die Dornen kamen aus den Alten Ruinen. +160 XP, +80 Gold und eine seltene Klassenwaffe.")
			save_game()
		else:
			message("Nela: Hinter dem Turm in den Ruinen liegt die Quelle der Plage. Sei vorsichtig!")
		return
	if not ufo_chest_opened and player_pos.distance_to(UFO_CHEST_POS) < 90:
		open_ufo_chest()
		return
	for i in LANDMARKS.size():
		if not opened_chests[i] and player_pos.distance_to(chest_position(i)) < 85:
			open_chest(i)
			return
	for i in WORLD_EVENTS.size():
		if player_pos.distance_to(WORLD_EVENTS[i]["pos"]) < 112:
			interact_world_event(i)
			return
	var closest: Dictionary = {}
	var distance := 115.0
	for npc in NPCS:
		var d: float = player_pos.distance_to(npc["pos"])
		if d < distance:
			closest = npc
			distance = d
	if closest.is_empty(): return
	play_sound("menu")
	if closest["kind"] == "quest":
		quest_dialogue(String(closest["name"]))
	elif closest["kind"] == "healer":
		visit_healer()
	elif closest["kind"] == "arena":
		panel = "arena_entry"
	else:
		merchant_kind = String(closest["kind"])
		panel = "shop"
		selected_item = -1
		menu_scroll = 0
		sell_all_confirm = false
		pending_purchase = -1
		pending_purchase_item = {}

func interact_world_event(index: int) -> void:
	var encounter: Dictionary = WORLD_EVENTS[index]
	var state: int = int(event_states[index])
	if state == 0:
		event_states[index] = 1
		message("%s: %s (%d Gegner in der Nähe)" % [encounter["name"], encounter["story"], encounter["goal"]])
	elif state == 1:
		message("%s: Halte durch! %d/%d Gegner vertrieben." % [encounter["name"], event_progress[index], encounter["goal"]])
	elif state == 2:
		event_states[index] = 3
		gain_xp(int(encounter["xp"]))
		gold += int(encounter["gold"])
		hp = minf(max_hp(), hp + 28.0)
		message("%s: %s +%d XP, +%d Gold, +28 HP." % [encounter["name"], encounter["after"], encounter["xp"], encounter["gold"]])
		play_sound("level")
	else:
		message("%s: %s" % [encounter["name"], encounter["after"]])
	save_game()

func healing_cost() -> int:
	return 8 + level * 3 + int(max_hp() / 50.0)

func visit_healer() -> void:
	if hp >= max_hp() - 0.5:
		message("Elara: Du bist bereits vollständig geheilt.")
		return
	var cost := healing_cost()
	if gold < cost:
		message("Elara: Die Heilung kostet %d Gold. Dir fehlen %d." % [cost, cost - gold])
		return
	gold -= cost
	hp = max_hp()
	play_trade_sound("buy")
	message("Elara hat deine Wunden geheilt. -%d Gold · HP vollständig." % cost)
	save_game()

func chest_position(index: int) -> Vector2:
	return LANDMARKS[index]["pos"] + Vector2(95, 65)

func open_chest(index: int) -> void:
	if opened_chests[index]: return
	if inventory.size() >= 42:
		message("Inventar voll — verkaufe erst etwas im Dorf.")
		return
	opened_chests[index] = true
	play_sound("pickup")
	var element: String = ["eis", "gift", "blitz"][index % 3]
	var region := region_at(chest_position(index))
	var rarity := 3 if region_level(region) >= 30 else 2
	var icon := class_weapon_icon()
	var item := make_item("%s von %s" % [{"sword":"Schatzklinge", "staff":"Schatzstab", "bow":"Schatzbogen"}[icon], LANDMARKS[index]["name"]], icon, rarity, 12 + region_level(region) * 2 + rarity * 3, 0, element, region_level(region))
	inventory.append(item)
	gold += 35 + region * 25
	message("Schatztruhe geöffnet: %s (%s)!" % [item["name"], RARITY_NAMES[rarity]])
	save_game()

func use_waystone() -> void:
	for i in WAYSTONES.size():
		if player_pos.distance_to(WAYSTONES[i]) < 105:
			if i == 0:
				panel = "travel"
				message("Wähle ein freigeschaltetes Ziel.")
			else:
				waystone_unlocked[i] = true
				last_waystone = i
				player_pos = WAYSTONES[0] + Vector2(0, 88)
				message("Wegstein %s aktiviert. Reise vom Dorf aus jederzeit zurück." % region_name(region_at(WAYSTONES[i])))
			enemy_projectiles.clear()
			save_game()
			return

func click_travel(mouse: Vector2) -> void:
	for i in range(1, WAYSTONES.size()):
		var col := (i - 1) % 3
		var row := (i - 1) / 3
		if Rect2(166 + col * 271, 175 + row * 96, 255, 79).has_point(mouse):
			if not waystone_unlocked[i] or not region_available(region_at(WAYSTONES[i])):
				message("Diesen Wegstein musst du zunächst vor Ort aktivieren.")
				return
			if dungeon_id >= 0: dungeon_id = -1
			player_pos = WAYSTONES[i] + Vector2(0, 112)
			last_waystone = i
			panel = ""
			enemies.clear()
			enemy_projectiles.clear()
			play_sound("dodge")
			message("Reise nach %s." % region_name(region_at(player_pos)))
			save_game()
			return

func quick_potion(restore_energy: bool) -> void:
	for i in inventory.size():
		var item: Dictionary = inventory[i]
		if item["icon"] != "potion": continue
		if (item["name"] in ["Energietrank", "Manatrank"]) == restore_energy:
			use_item(i)
			return
	message("Kein passender Trank im Inventar.")

func quest_dialogue(npc_name: String) -> void:
	for i in QUESTS.size():
		if QUESTS[i]["npc"] != npc_name: continue
		if quests[i]["state"] == 2:
			var reward_name: String = QUESTS[i]["reward"]
			var reward_icon := class_weapon_icon() if i in [0, 5, 8, 9, 12, 14] else ("armor" if i == 4 or "panzer" in reward_name.to_lower() or "rüstung" in reward_name.to_lower() else ("ring" if i == 10 or "ring" in reward_name.to_lower() or "amulett" in reward_name.to_lower() else "gem"))
			var reward_power := (6 + i * 3) if reward_icon in ["sword", "staff", "bow"] else (4 + int(i / 2.0) if reward_icon == "armor" else (12 + i * 2 if reward_icon == "ring" else 0))
			var reward_item := make_item(reward_name, reward_icon, mini(4, 1 + i / 3), reward_power, 75 + i * 30, "blitz" if i == 12 else ("gift" if i == 14 else ""))
			if not can_add_item(reward_item):
				message("Deine Tasche ist voll. Verkaufe erst etwas und hole dann die Questbelohnung ab.")
				return
			quests[i]["state"] = 3
			gold += int(QUESTS[i]["gold"])
			gain_xp(int(QUESTS[i]["xp"]))
			add_item(reward_item)
			message("Quest abgeschlossen: %s! +%d XP, +%d Gold" % [QUESTS[i]["title"], QUESTS[i]["xp"], QUESTS[i]["gold"]])
			save_game()
			return
	for i in QUESTS.size():
		if QUESTS[i]["npc"] == npc_name and quests[i]["state"] == 0 and level + 3 >= region_level(int(ENEMY_TYPES[int(QUESTS[i]["target"])]["region"])):
			quests[i]["state"] = 1
			message("%s: %s — besiege %d %s!" % [npc_name, QUESTS[i]["title"], QUESTS[i]["count"], ENEMY_TYPES[int(QUESTS[i]["target"])]["name"]])
			save_game()
			return
	message("%s: Deine Aufgaben stehen im Questbuch (J)." % npc_name)

func message(value: String) -> void:
	notice = value
	notice_timer = 5.0

func effect(pos: Vector2, value: String, color: Color, life: float) -> void:
	effects.append({"pos":pos, "text":value, "color":color, "life":life, "max":life})

func slot_save_path(index: int, testing: bool = false) -> String:
	if index == 1: return CREATIVE_SAVE_PATH if testing else SAVE_PATH
	return "user://sonnenhain_slot%d%s.json" % [index, "_testmodus" if testing else ""]

func refresh_save_slot_labels() -> void:
	save_slot_labels.clear()
	for index in range(1, 4):
		var path := slot_save_path(index)
		if not FileAccess.file_exists(path):
			save_slot_labels.append("LEER")
			continue
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if data is Dictionary:
			var id := clampi(int(data.get("class_id", 0)), 0, 2)
			save_slot_labels.append("%s · LV %d · %s" % [str(data.get("hero_name", "Held")), int(data.get("level", 1)), CLASS_NAMES[id]])
		else: save_slot_labels.append("BESCHÄDIGT")

func save_game() -> void:
	var safe_pos := arena_return_pos if arena_mode != "" else (dungeon_return_pos if dungeon_id >= 0 else (interior_return_pos if interior_id >= 0 else player_pos))
	var safe_hp := max_hp() if arena_mode != "" else hp
	var data := {"save_version":SaveMigrator.CURRENT_VERSION, "world_version":5, "discovered_regions":discovered_regions, "position":[safe_pos.x, safe_pos.y], "hp":safe_hp, "energy":energy, "level":level, "xp":xp, "gold":gold, "skill_points":skill_points, "learned":learned, "skill_levels":skill_levels, "slots":slots, "class_id":class_id, "hero_name":hero_name, "hero_gender":hero_gender, "hero_race":hero_race, "character_created":character_created, "inventory":inventory, "equipped_uid":equipped_uid, "equipped_armor_uid":equipped_armor_uid, "equipped_ring_uid":equipped_ring_uid, "equipped_ring2_uid":equipped_ring2_uid, "last_waystone":last_waystone, "waystone_unlocked":waystone_unlocked, "shop_timer":shop_timer, "shop_stock":shop_stock, "opened_chests":opened_chests, "ufo_chest_opened":ufo_chest_opened, "dungeon_chests_opened":dungeon_chests_opened, "bosses_defeated":bosses_defeated, "final_completed":final_completed, "arena_best":arena_best, "arena_leaderboard":arena_leaderboard, "arena_reward_pending":arena_mode == "survival" and panel == "arena_reward" and not arena_reward_claimed, "arena_reward_wave":arena_reward_wave, "next_uid":next_uid, "quests":quests, "music_enabled":music_enabled, "music_volume":music_volume, "effects_volume":effects_volume, "event_states":event_states, "event_progress":event_progress, "rescue_state":rescue_state, "rescue_kills":rescue_kills}
	var file: FileAccess = FileAccess.open(slot_save_path(active_save_slot, creative_mode), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))
		file.close()
		if not creative_mode: refresh_save_slot_labels()

func load_game() -> void:
	var path := slot_save_path(active_save_slot, creative_mode)
	if not FileAccess.file_exists(path): return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null: return
	var raw_save := file.get_as_text()
	file.close()
	var parsed_save: Variant = JSON.parse_string(raw_save)
	if not parsed_save is Dictionary:
		return
	SaveMigrator.backup_before_migration(path, parsed_save)
	var data: Dictionary = SaveMigrator.migrate(parsed_save)
	reset_class_skills()
	inventory.clear()
	quests.clear()
	for i in QUESTS.size(): quests.append({"state":0, "progress":0})
	for i in WORLD_EVENTS.size():
		event_states[i] = 0
		event_progress[i] = 0
	for i in bosses_defeated.size(): bosses_defeated[i] = false
	for i in opened_chests.size(): opened_chests[i] = false
	ufo_chest_opened = false
	dungeon_id = -1
	interior_id = -1
	for i in dungeon_chests_opened.size(): dungeon_chests_opened[i] = false
	waystone_unlocked = [true, false, false, false, false, false, false, false, false, false, false, false]
	discovered_regions = [true, false, false, false, false, false, false, false, false, false, false, false, false]
	final_completed = bool(data.get("final_completed", false))
	arena_best = maxi(0, int(data.get("arena_best", 0)))
	var stored_board: Variant = data.get("arena_leaderboard", [])
	arena_leaderboard = stored_board if stored_board is Array else []
	arena_mode = ""
	final_countdown = -1.0
	arena_reward_wave = maxi(0, int(data.get("arena_reward_wave", 0)))
	arena_pending_loaded = bool(data.get("arena_reward_pending", false))
	class_id = clampi(int(data.get("class_id", 0)), 0, 2)
	pending_class = class_id
	hero_name = str(data.get("hero_name", "Held"))
	hero_gender = clampi(int(data.get("hero_gender", 0)), 0, 1)
	hero_race = clampi(int(data.get("hero_race", 0)), 0, 2)
	character_created = bool(data.get("character_created", data.has("class_id")))
	pending_gender = hero_gender
	pending_race = hero_race
	var found_regions: Array = data.get("discovered_regions", [])
	for i in mini(found_regions.size(), discovered_regions.size()): discovered_regions[i] = bool(found_regions[i])
	rescue_state = clampi(int(data.get("rescue_state", 0)), 0, 3)
	rescue_kills = clampi(int(data.get("rescue_kills", 0)), 0, RESCUE_GOAL)
	var coords: Array = data.get("position", [900, 1050])
	if coords.size() >= 2:
		player_pos = Vector2(float(coords[0]), float(coords[1])).clamp(Vector2(30, 30), WORLD - Vector2(30, 30))
	# Alte Kartenkoordinaten passen nicht zu den neuen Gebietsgrenzen.
	if int(data.get("world_version", 1)) < 2 and region_at(player_pos) != 0:
		player_pos = Vector2(900, 1050)
	level = maxi(1, int(data.get("level", 1)))
	xp = maxi(0, int(data.get("xp", 0)))
	gold = maxi(0, int(data.get("gold", 55)))
	music_enabled = bool(data.get("music_enabled", true))
	music_volume = clampf(float(data.get("music_volume", 0.90)), 0.0, 1.0)
	effects_volume = clampf(float(data.get("effects_volume", 0.75)), 0.0, 1.0)
	if not music_enabled:
		music_volume = 0.0
		music_enabled = true
	var stored_events: Array = data.get("event_states", [])
	var stored_progress: Array = data.get("event_progress", [])
	for i in mini(WORLD_EVENTS.size(), stored_events.size()): event_states[i] = clampi(int(stored_events[i]), 0, 3)
	for i in mini(WORLD_EVENTS.size(), stored_progress.size()): event_progress[i] = maxi(0, int(stored_progress[i]))
	skill_points = maxi(0, int(data.get("skill_points", 0)))
	var stored_learned: Array = data.get("learned", [])
	if stored_learned.size() >= 12:
		for i in mini(ABILITIES.size(), stored_learned.size()): learned[i] = bool(stored_learned[i])
	elif data.has("skill_ranks"):
		for rank in data["skill_ranks"]:
			skill_points += maxi(0, int(rank))
	var stored_levels: Array = data.get("skill_levels", [])
	if stored_levels.size() > 0:
		for i in mini(ABILITIES.size(), stored_levels.size()):
			skill_levels[i] = clampi(int(stored_levels[i]), 0, 5)
			learned[i] = skill_levels[i] > 0
	else:
		for i in ABILITIES.size(): skill_levels[i] = 1 if learned[i] else 0
	var stored_slots: Array = data.get("slots", [])
	if stored_slots.size() == 3:
		for i in 3:
			var id := int(stored_slots[i])
			if id in CLASS_SKILLS[class_id] and learned[id]: slots[i] = id
	var stored_items: Variant = data.get("inventory", [])
	if stored_items is Array:
		inventory = []
		for raw_item in stored_items:
			if not raw_item is Dictionary: continue
			if raw_item.has("icon") and raw_item.has("uid"):
				add_item(raw_item)
				next_uid = maxi(next_uid, int(raw_item["uid"]) + 1)
			else:
				# Gegenstände aus dem ersten Prototyp in das neue Raster übernehmen.
				var old_name: String = str(raw_item.get("name", "Fundstück"))
				var old_icon := "sword" if "Schwert" in old_name or "Klinge" in old_name else "gem"
				add_item(make_item(old_name, old_icon, clampi(int(raw_item.get("rarity", 0)), 0, 4), 5 if old_icon == "sword" else 0, 20))
	equipped_uid = int(data.get("equipped_uid", -1))
	equipped_armor_uid = int(data.get("equipped_armor_uid", -1))
	equipped_ring_uid = int(data.get("equipped_ring_uid", -1))
	equipped_ring2_uid = int(data.get("equipped_ring2_uid", -1))
	if class_id != 1:
		equipped_ring2_uid = -1
	last_waystone = clampi(int(data.get("last_waystone", 1)), 1, WAYSTONES.size() - 1)
	var stored_stones: Array = data.get("waystone_unlocked", [])
	for i in mini(stored_stones.size(), WAYSTONES.size()): waystone_unlocked[i] = bool(stored_stones[i])
	if stored_stones.is_empty(): waystone_unlocked[last_waystone] = true
	shop_timer = clampf(float(data.get("shop_timer", 0.0)), 0.0, 419.0)
	var stored_shop: Variant = data.get("shop_stock", {})
	if stored_shop is Dictionary and stored_shop.has("smith"): shop_stock = stored_shop
	var stored_chests: Array = data.get("opened_chests", [])
	for i in mini(stored_chests.size(), LANDMARKS.size()): opened_chests[i] = bool(stored_chests[i])
	ufo_chest_opened = bool(data.get("ufo_chest_opened", false))
	var stored_dungeon_chests: Array = data.get("dungeon_chests_opened", [])
	for i in mini(stored_dungeon_chests.size(), dungeon_chests_opened.size()): dungeon_chests_opened[i] = bool(stored_dungeon_chests[i])
	var stored_bosses: Array = data.get("bosses_defeated", [])
	if stored_bosses.size() == bosses_defeated.size():
		for i in bosses_defeated.size(): bosses_defeated[i] = bool(stored_bosses[i])
	else:
		for i in 3:
			bosses_defeated[i] = int(quests[12 + i].get("state", 0)) >= 2
	next_uid = maxi(next_uid, int(data.get("next_uid", 1)))
	var stored_quests: Array = data.get("quests", [])
	if stored_quests.size() > 0:
		for i in mini(stored_quests.size(), QUESTS.size()):
			quests[i] = stored_quests[i]
		if stored_bosses.size() != bosses_defeated.size():
			for i in 3: bosses_defeated[i] = int(quests[12 + i].get("state", 0)) >= 2
	# Ältere Spielstände aus der ersten Version übernehmen.
	elif data.has("quest_state"):
		quests[0]["state"] = clampi(int(data["quest_state"]), 0, 3)
		quests[0]["progress"] = clampi(int(data.get("quest_kills", 0)), 0, 5)
	if is_blocked(player_pos) or (not creative_mode and level < region_level(region_at(player_pos))):
		player_pos = Vector2(900, 1050)
	if level < region_level(region_at(WAYSTONES[last_waystone])): last_waystone = 1
	if level >= 20:
		learned[class_ultimate()] = true
		skill_levels[class_ultimate()] = mini(5, 1 + (level - 20) / 5)
	hp = clampf(float(data.get("hp", 100)), 1, max_hp())
	energy = clampf(float(data.get("energy", 100)), 0, max_energy())

func handle_panel_click(mouse: Vector2) -> void:
	if panel == "start":
		if Rect2(855, 158, 130, 33).has_point(mouse):
			controls_return_panel = "start"
			panel = "controls"
			return
		for candidate in 3:
			if Rect2(168 + candidate * 273, 530, 260, 57).has_point(mouse):
				selected_save_slot = candidate + 1
				play_sound("menu")
				return
			if Rect2(174 + candidate * 273, 330, 250, 38).has_point(mouse) or Rect2(168 + candidate * 273, 202, 260, 127).has_point(mouse):
				pending_class = candidate
				play_sound("menu")
				return
		if Rect2(300, 378, 550, 54).has_point(mouse):
			play_sound("menu")
			active_save_slot = selected_save_slot
			begin_character_creation()
		elif Rect2(300, 448, 550, 54).has_point(mouse):
			if not FileAccess.file_exists(slot_save_path(selected_save_slot)):
				message("Noch kein Spielstand vorhanden. Wähle eine Klasse und starte ein neues Spiel.")
				return
			play_sound("menu")
			active_save_slot = selected_save_slot
			load_game()
			enemies.clear()
			drops.clear()
			battle_zones.clear()
			previous_region = region_at(player_pos)
			if arena_pending_loaded:
				arena_return_pos = player_pos
				arena_mode = "survival"
				player_pos = ARENA_CENTER
				panel = "arena_reward"
				arena_pending_loaded = false
			else: panel = ""
			message("Spielstand %d geladen. Willkommen zurück!" % active_save_slot)
		elif Rect2(860, 448, 125, 54).has_point(mouse):
			panel = "multiplayer"
			join_code = ""
			network_status = "Online-Server · bereit zum Verbinden" if is_web_platform() else "Offline · Host erstellen oder Einladungscode eingeben"
			play_sound("menu")
		return
	if panel == "creation":
		for i in 2:
			if Rect2(300 + i * 210, 300, 195, 40).has_point(mouse):
				pending_gender = i
				play_sound("menu")
		for i in 3:
			if Rect2(245 + i * 220, 365, 205, 44).has_point(mouse):
				pending_race = i
				play_sound("menu")
		if Rect2(300, 520, 550, 52).has_point(mouse) and creation_name.strip_edges().length() >= 2:
			start_new_game()
		elif Rect2(165, 520, 110, 52).has_point(mouse):
			panel = "start"
		return
	if panel == "multiplayer":
		if Rect2(205, 282, 340, 52).has_point(mouse):
			if is_web_platform():
				join_dedicated_server()
			else:
				host_multiplayer()
		elif Rect2(605, 282, 340, 52).has_point(mouse):
			if is_web_platform():
				join_dedicated_server()
			else:
				join_multiplayer_from_code(join_code)
		elif Rect2(205, 454, 740, 46).has_point(mouse):
			join_code = ""
		elif Rect2(205, 520, 200, 46).has_point(mouse):
			disconnect_multiplayer()
			panel = "start"
		elif Rect2(605, 520, 340, 46).has_point(mouse):
			start_coop_world()
		return
	if panel == "mechanics":
		for tab in 4:
			if Rect2(190 + tab * 195, 142, 180, 38).has_point(mouse):
				mechanics_page = tab
				play_sound("menu")
				return
		if Rect2(820, 548, 160, 38).has_point(mouse):
			panel = ""
			return
		return
	if panel == "pause":
		if set_volume_from_mouse(mouse):
			save_game()
		elif Rect2(860, 221, 130, 42).has_point(mouse):
			controls_return_panel = "pause"
			panel = "controls"
			play_sound("menu")
		elif Rect2(300, 221, 550, 42).has_point(mouse):
			play_sound("menu")
			panel = ""
		elif Rect2(860, 270, 130, 42).has_point(mouse):
			mechanics_page = 0
			panel = "mechanics"
			play_sound("menu")
		elif Rect2(300, 270, 550, 42).has_point(mouse):
			play_sound("menu")
			save_game()
			pause_status = "Teststand gespeichert." if creative_mode else "Spielstand gespeichert."
		elif Rect2(300, 432, 550, 42).has_point(mouse):
			play_sound("menu")
			toggle_creative_mode()
		elif Rect2(300, 563, 550, 35).has_point(mouse):
			if arena_mode != "":
				arena_mode = ""
				player_pos = arena_return_pos
				enemies.clear()
			if dungeon_id >= 0:
				dungeon_id = -1
				player_pos = dungeon_return_pos
				enemies.clear()
			if interior_id >= 0:
				interior_id = -1
				player_pos = interior_return_pos
			save_game()
			refresh_save_slot_labels()
			panel = "start"
			selected_save_slot = active_save_slot
			play_sound("menu")
		elif creative_mode:
			for index in 4:
				if Rect2(300 + index * 113, 510, 105, 38).has_point(mouse):
					set_creative_level(level + [-10, -1, 1, 10][index])
					return
			if Rect2(762, 510, 180, 38).has_point(mouse):
				panel = "travel"
		return
	if panel == "controls":
		if Rect2(965, 91, 41, 35).has_point(mouse):
			panel = controls_return_panel
			awaiting_bind = ""
			return
		for index in BIND_ACTIONS.size():
			var column := int(index / 10.0)
			var row := index % 10
			if Rect2(170 + column * 420, 195 + row * 34, 390, 30).has_point(mouse):
				awaiting_bind = BIND_ACTIONS[index]
				controls_status = "%s: neue Taste oder Maustaste drücken · ESC bricht ab." % BIND_NAMES[index]
				play_sound("menu")
				return
		if Rect2(175, 562, 385, 36).has_point(mouse):
			reset_bindings()
			play_sound("menu")
		elif Rect2(585, 562, 385, 36).has_point(mouse):
			panel = controls_return_panel
			awaiting_bind = ""
			play_sound("menu")
		return
	if panel == "arena_entry":
		if Rect2(307, 391, 260, 48).has_point(mouse):
			panel = ""
			enter_arena("survival")
		elif Rect2(585, 391, 260, 48).has_point(mouse) and bosses_defeated.count(true) == 3 and not final_completed:
			panel = ""
			enter_arena("final")
		return
	if panel == "arena_reward":
		if Rect2(307, 510, 260, 48).has_point(mouse): claim_arena_chest()
		elif Rect2(585, 510, 260, 48).has_point(mouse): leave_arena()
		return
	if panel == "victory":
		if Rect2(350, 491, 450, 54).has_point(mouse): leave_arena()
		return
	if Rect2(965, 91, 41, 35).has_point(mouse):
		panel = controls_return_panel if panel == "controls" else ""
		sell_all_confirm = false
		pending_purchase = -1
		return
	match panel:
		"skills": click_skills(mouse)
		"inventory": click_inventory(mouse)
		"shop": click_shop(mouse)
		"travel": click_travel(mouse)

func set_volume_from_mouse(mouse: Vector2) -> bool:
	if Rect2(300, 337, 550, 25).has_point(mouse):
		music_volume = clampf((mouse.x - 315.0) / 520.0, 0.0, 1.0)
		music_enabled = true
		update_music()
		return true
	if Rect2(300, 391, 550, 25).has_point(mouse):
		effects_volume = clampf((mouse.x - 315.0) / 520.0, 0.0, 1.0)
		return true
	return false

func begin_character_creation() -> void:
	creation_name = ""
	pending_gender = 0
	pending_race = 0
	character_created = false
	panel = "creation"
	play_sound("menu")

func start_new_game() -> void:
	creative_mode = false
	hero_name = creation_name.strip_edges().substr(0, 16) if creation_name.strip_edges() != "" else "Held"
	hero_gender = pending_gender
	hero_race = pending_race
	character_created = true
	var current_path := slot_save_path(active_save_slot)
	if FileAccess.file_exists(current_path):
		var old_save: String = FileAccess.get_file_as_string(current_path)
		var backup: FileAccess = FileAccess.open("user://sonnenhain_slot%d_backup.json" % active_save_slot, FileAccess.WRITE)
		if backup != null: backup.store_string(old_save)
	final_completed = false
	final_countdown = -1.0
	arena_mode = ""
	dungeon_id = -1
	interior_id = -1
	for i in dungeon_chests_opened.size(): dungeon_chests_opened[i] = false
	arena_wave = 0
	arena_best = 0
	arena_pending_loaded = false
	arena_leaderboard.clear()
	player_pos = Vector2(900, 1050)
	class_id = pending_class
	rescue_state = 0
	rescue_kills = 0
	rescue_intro_timer = 0.0
	intro_timer = 8.0
	for i in WORLD_EVENTS.size():
		event_states[i] = 0
		event_progress[i] = 0
	reward_scene_timer = 0.0
	previous_region = 0
	discovered_regions = [true, false, false, false, false, false, false, false, false, false, false, false, false]
	facing = Vector2.RIGHT
	is_walking = false
	walk_phase = 0.0
	hp = 100
	energy = 100
	level = 1
	xp = 0
	gold = 55
	skill_points = 0
	reset_class_skills()
	selected_slot = 0
	inventory_page = 0
	for i in cooldowns.size(): cooldowns[i] = 0.0
	inventory.clear()
	equipped_uid = -1
	equipped_armor_uid = -1
	equipped_ring_uid = -1
	equipped_ring2_uid = -1
	next_uid = 1
	selected_item = -1
	quests.clear()
	for i in QUESTS.size(): quests.append({"state":0, "progress":0})
	for i in opened_chests.size(): opened_chests[i] = false
	for i in boss_cooldowns.size(): boss_cooldowns[i] = 0.0
	last_waystone = 1
	waystone_unlocked = [true, false, false, false, false, false, false, false, false, false, false, false]
	shop_timer = 0.0
	refresh_shop_stock()
	for i in bosses_defeated.size(): bosses_defeated[i] = false
	enemies.clear()
	drops.clear()
	effects.clear()
	projectiles.clear()
	spell_visuals.clear()
	poison_clouds.clear()
	impact_zones.clear()
	battle_zones.clear()
	enemy_projectiles.clear()
	lightning_lines.clear()
	shield_timer = 0
	rage_timer = 0
	drain_timer = 0
	poison_blade_timer = 0
	panel = "intro"
	message("Willkommen in Sonnenhain! Rede mit Mira, Borin oder Liora.")
	save_game()

func finish_intro() -> void:
	if panel != "intro": return
	panel = ""
	intro_timer = 0.0
	message("Mira wartet am Dorfplatz. Sprich mit ihr (E).")

func toggle_creative_mode() -> void:
	if not creative_mode:
		save_game()
		var normal_save := FileAccess.get_file_as_string(slot_save_path(active_save_slot))
		var copy: FileAccess = FileAccess.open(slot_save_path(active_save_slot, true), FileAccess.WRITE)
		if copy == null:
			pause_status = "Testmodus konnte nicht angelegt werden."
			return
		copy.store_string(normal_save)
		copy.close()
		creative_mode = true
		load_game()
		gold = maxi(gold, 50000)
		skill_points = maxi(skill_points, 60)
		for i in waystone_unlocked.size(): waystone_unlocked[i] = true
		pause_status = "Testmodus aktiv · eigener Spielstand, alle Wege offen."
		save_game()
	else:
		creative_mode = false
		reset_class_skills()
		for i in WORLD_EVENTS.size():
			event_states[i] = 0
			event_progress[i] = 0
		quests.clear()
		for i in QUESTS.size(): quests.append({"state":0, "progress":0})
		load_game()
		enemies.clear()
		drops.clear()
		effects.clear()
		spell_visuals.clear()
		poison_clouds.clear()
		lightning_lines.clear()
		projectiles.clear()
		enemy_projectiles.clear()
		impact_zones.clear()
		for i in cooldowns.size(): cooldowns[i] = 0.0
		shield_timer = 0.0
		rage_timer = 0.0
		drain_timer = 0.0
		poison_blade_timer = 0.0
		previous_region = region_at(player_pos)
		camera_pos = (player_pos - VIEW * 0.5).clamp(Vector2.ZERO, WORLD - VIEW)
		pause_status = "Normaler Spielstand wiederhergestellt."

func set_creative_level(target: int) -> void:
	if not creative_mode: return
	level = clampi(target, 1, 40)
	xp = 0
	skill_points = maxi(skill_points, 60)
	if level >= 20:
		learned[class_ultimate()] = true
		skill_levels[class_ultimate()] = mini(5, 1 + int((level - 20) / 5.0))
	else:
		learned[class_ultimate()] = false
		skill_levels[class_ultimate()] = 0
	hp = max_hp()
	energy = max_energy()
	pause_status = "Testmodus: Level %d · volle HP und %s." % [level, "Mana" if class_id == 1 else "Energie"]
	save_game()

func click_skills(mouse: Vector2) -> void:
	for slot in 3:
		if Rect2(165 + slot * 204, 148, 193, 44).has_point(mouse):
			selected_slot = slot
			return
	for row in 7:
		var class_list: Array = CLASS_SKILLS[class_id]
		var list_index := row + menu_scroll
		if list_index >= class_list.size(): break
		var index: int = int(class_list[list_index])
		if Rect2(165, 215 + row * 44, 816, 40).has_point(mouse):
			if mouse.x >= 832 or not learned[index]:
				upgrade_skill(index)
			else:
				for slot in 3:
					if slots[slot] == index: slots[slot] = -1
				slots[selected_slot] = index
				message("%s auf Taste %d gelegt" % [ABILITIES[index]["name"], selected_slot + 1])
				save_game()
			return

func upgrade_skill(index: int) -> void:
	var next_rank: int = int(skill_levels[index]) + 1
	if not creative_mode and level < skill_rank_level(index, next_rank):
		message("Rang %d von %s ist ab Level %d verfügbar." % [next_rank, ABILITIES[index]["name"], skill_rank_level(index, next_rank)])
		return
	if int(skill_levels[index]) >= 5:
		message("%s ist bereits auf Rang 5." % ABILITIES[index]["name"])
		return
	if skill_points <= 0:
		message("Du brauchst einen Skillpunkt.")
		return
	skill_points -= 1
	skill_levels[index] = int(skill_levels[index]) + 1
	learned[index] = true
	hp = minf(max_hp(), hp + (25 if index == 10 else 0))
	energy = minf(max_energy(), energy + (25 if index == 11 else 0))
	message("%s auf Rang %d verbessert" % [ABILITIES[index]["name"], skill_levels[index]])
	save_game()

func toggle_item_protection(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return
	var item: Dictionary = inventory[index]
	var protected_now := ItemProtection.toggle(item)
	selected_item = index
	message(("%s ist jetzt geschützt." if protected_now else "%s ist wieder verkaufbar.") % item["name"])
	save_game()
	queue_redraw()

func try_toggle_item_protection_at(mouse: Vector2) -> bool:
	if panel == "inventory":
		for cell in 25:
			var col := cell % 5
			var row := int(cell / 5.0)
			if Rect2(641 + col * 65, 200 + row * 55, 54, 48).has_point(mouse):
				var index := inventory_page * 25 + cell
				if index < inventory.size():
					toggle_item_protection(index)
					return true
				return false
	elif panel == "shop":
		for index in inventory.size():
			var col := index % 11
			var row := int(index / 11.0)
			if Rect2(170 + col * 72, 397 + row * 40, 47, 37).has_point(mouse):
				toggle_item_protection(index)
				sell_all_confirm = false
				return true
	return false

func click_inventory(mouse: Vector2) -> void:
	if Rect2(850, 157, 32, 30).has_point(mouse):
		inventory_page = maxi(0, inventory_page - 1)
		selected_item = -1
		return
	if Rect2(931, 157, 32, 30).has_point(mouse):
		inventory_page = mini(1, inventory_page + 1)
		selected_item = -1
		return
	for cell in 25:
		var col := cell % 5
		var row := cell / 5
		if Rect2(641 + col * 65, 200 + row * 55, 54, 48).has_point(mouse):
			var index := inventory_page * 25 + cell
			selected_item = index if index < inventory.size() else -1
			return
	if selected_item >= 0 and selected_item < inventory.size() and Rect2(643, 538, 320, 42).has_point(mouse):
		use_item(selected_item)

func click_shop(mouse: Vector2) -> void:
	if pending_purchase >= 0:
		if Rect2(352, 391, 204, 45).has_point(mouse):
			buy_item(pending_purchase_item)
			pending_purchase = -1
			pending_purchase_item = {}
		elif Rect2(578, 391, 204, 45).has_point(mouse) or not Rect2(315, 210, 522, 247).has_point(mouse):
			pending_purchase = -1
			pending_purchase_item = {}
		return
	var stock: Array = shop_stock[merchant_kind]
	for i in stock.size():
		if Rect2(168 + i * 258, 210, 245, 125).has_point(mouse):
			sell_all_confirm = false
			pending_purchase = i
			pending_purchase_item = stock[i].duplicate(true)
			return
	for i in inventory.size():
		var col := i % 11
		var row := i / 11
		if Rect2(170 + col * 72, 397 + row * 40, 47, 37).has_point(mouse):
			selected_item = i
			sell_all_confirm = false
			return
	if Rect2(564, 562, 210, 39).has_point(mouse):
		if sell_all_confirm:
			sell_all_unequipped()
		else:
			sell_all_confirm = true
			message("Alle nicht ausgerüsteten Items verkaufen? Erneut klicken.")
		return
	if Rect2(786, 562, 183, 39).has_point(mouse) and selected_item >= 0:
		sell_all_confirm = false
		sell_item(selected_item)

func sell_all_unequipped() -> void:
	var total := 0
	var count := 0
	for i in range(inventory.size() - 1, -1, -1):
		var item: Dictionary = inventory[i]
		if int(item["uid"]) in equipped_item_uids(): continue
		if ItemProtection.is_protected(item): continue
		total += item_sale_value(item)
		count += int(item.get("count", 1))
		inventory.remove_at(i)
	gold += total
	if total > 0:
		play_trade_sound("sell_all")
	selected_item = -1
	sell_all_confirm = false
	message("%d Items verkauft: +%d Gold. Ausrüstung und geschützte Items behalten." % [count, total])
	save_game()

func use_item(index: int) -> void:
	var item: Dictionary = inventory[index]
	var name: String = item["name"]
	if item["icon"] == "potion":
		if name in ["Energietrank", "Manatrank"]: energy = minf(max_energy(), energy + 65)
		else: hp = minf(max_hp(), hp + (90 if name == "Großer Heiltrank" else 45))
		if int(item.get("count", 1)) > 1:
			item["count"] = int(item["count"]) - 1
			item["stack_value"] = maxi(0, item_sale_value(item) - int(item.get("value", 0)))
		else:
			inventory.remove_at(index)
			selected_item = -1
		message("%s verwendet" % name)
	elif item["icon"] in ["sword", "staff", "bow"]:
		if item["icon"] != class_weapon_icon():
			message("%s kann nur %s ausrüsten." % [CLASS_NAMES[class_id], {"sword":"Schwerter", "staff":"Stäbe", "bow":"Bögen"}[class_weapon_icon()]])
			return
		equipped_uid = int(item["uid"])
		message("Ausgerüstet: %s (+%d Schaden)" % [name, item["power"]])
	elif item["icon"] == "armor":
		equipped_armor_uid = int(item["uid"])
		message("Ausgerüstet: %s (%d weniger Schaden)" % [name, item["power"]])
	elif item["icon"] == "ring":
		var profile := current_class_profile()
		var max_rings := 1 if profile == null else maxi(1, profile.ring_slots)
		if equipped_ring_uid < 0 or int(item["uid"]) == equipped_ring_uid:
			equipped_ring_uid = int(item["uid"])
		elif max_rings >= 2 and (equipped_ring2_uid < 0 or int(item["uid"]) == equipped_ring2_uid):
			equipped_ring2_uid = int(item["uid"])
		elif max_rings >= 2:
			equipped_ring2_uid = int(item["uid"])
		else:
			equipped_ring_uid = int(item["uid"])
		hp = minf(max_hp(), hp + int(item["power"]))
		message("Ausgerüstet: %s (+%d maximales Leben)" % [name, item["power"]])
	else:
		message("%s ist ein wertvoller Fund. Du kannst ihn verkaufen." % name)
	save_game()

func refresh_shop_stock() -> void:
	var tier := maxi(1, level)
	var weapon := class_weapon_icon()
	var weapon_word: String = {"sword":"Klinge", "staff":"Stab", "bow":"Bogen"}[weapon]
	var suffix: String = ["der Wiesen", "des Nebels", "der Funken", "der Gezeiten", "des Morgenrots", "des Himmels"].pick_random()
	var rarity := 1 if tier < 12 else (2 if tier < 30 else 3)
	var elements := ["eis", "blitz", "gift"]
	var shop_element: String = elements.pick_random()
	shop_stock = {
		"smith":[
			{"name":"%s %s" % [weapon_word, suffix], "icon":weapon, "power":4 + tier * 2, "price":80 + tier * 20, "rarity":rarity, "level":tier},
			{"name":"%s · %s" % [weapon_word, shop_element.capitalize()], "icon":weapon, "power":7 + tier * 2, "price":135 + tier * 28, "rarity":rarity, "level":tier, "element":shop_element},
			{"name":"Meisterrüstung %s" % suffix, "icon":"armor", "power":5 + int(tier / 3.0), "price":520 + tier * 64, "rarity":mini(3, rarity + 1), "level":tier}],
		"alchemy":[
			{"name":"Heiltrank", "icon":"potion", "power":0, "price":35, "rarity":1},
			{"name":"Großer Heiltrank", "icon":"potion", "power":0, "price":85, "rarity":1},
			{"name":"Manatrank" if class_id == 1 else "Energietrank", "icon":"potion", "power":0, "price":45, "rarity":1}],
		"merchant":[
			{"name":"Reisendenring %s" % suffix, "icon":"ring", "power":8 + tier * 2, "price":80 + tier * 19, "rarity":rarity, "level":tier},
			{"name":"Umhang %s" % suffix, "icon":"armor", "power":1 + int(tier / 4.0), "price":65 + tier * 14, "rarity":rarity, "level":tier},
			{"name":"Meister-%s %s" % [weapon_word, suffix], "icon":weapon, "power":10 + tier * 3, "price":680 + tier * 83, "rarity":mini(3, rarity + 1), "level":tier, "element":shop_element}]
	}

func buy_item(stock_item: Dictionary) -> void:
	if gold < int(stock_item["price"]):
		message("Dafür fehlen dir %d Gold." % (int(stock_item["price"]) - gold))
		return
	var purchased := make_item(String(stock_item["name"]), String(stock_item["icon"]), int(stock_item.get("rarity", 1)), int(stock_item["power"]), int(stock_item["price"]) / 2, String(stock_item.get("element", "")), int(stock_item.get("level", level)))
	if not can_add_item(purchased):
		message("Dein Inventar ist voll.")
		return
	gold -= int(stock_item["price"])
	add_item(purchased)
	play_trade_sound("buy")
	message("Gekauft: %s" % stock_item["name"])
	save_game()

func sell_item(index: int) -> void:
	if index < 0 or index >= inventory.size(): return
	var item: Dictionary = inventory[index]
	if ItemProtection.is_protected(item):
		message("Geschützt: %s kann nicht verkauft werden. Doppelklick zum Entsperren." % item["name"])
		return
	if int(item["uid"]) == equipped_uid: equipped_uid = -1
	if int(item["uid"]) == equipped_armor_uid: equipped_armor_uid = -1
	if int(item["uid"]) == equipped_ring_uid:
		equipped_ring_uid = -1
		hp = minf(hp, max_hp())
	if int(item["uid"]) == equipped_ring2_uid:
		equipped_ring2_uid = -1
		hp = minf(hp, max_hp())
	var gain := int(round(float(item_sale_value(item)) / maxi(1, int(item.get("count", 1)))))
	gold += gain
	play_trade_sound("sell")
	message("Verkauft: %s für %d Gold" % [item["name"], gain])
	if int(item.get("count", 1)) > 1:
		item["count"] = int(item["count"]) - 1
		item["stack_value"] = maxi(0, item_sale_value(item) - gain)
	else:
		inventory.remove_at(index)
		selected_item = -1
	save_game()

func _draw() -> void:
	draw_set_transform(-camera_pos)
	draw_world()
	if arena_mode == "" and dungeon_id < 0 and interior_id < 0:
		draw_day_night_overlay()
	for drop in drops:
		if visible_world(drop["pos"], 45):
			var p: Vector2 = drop["pos"]
			if drop.has("gold"):
				draw_ground_gold(p, int(drop["gold"]))
			else:
				var item: Dictionary = drop["item"]
				var rarity_color: Color = RARITY_COLORS[int(item["rarity"])]
				draw_rect(Rect2(p + Vector2(-18, -22), Vector2(39, 39)), Color("192c32", 0.88))
				draw_rect(Rect2(p + Vector2(-18, -22), Vector2(39, 39)), rarity_color, false, 2)
				draw_item_icon(p + Vector2(-15, -19), String(item["icon"]), rarity_color, 1.0, weapon_visual_stage(item), item_design(item))
				if int(item["rarity"]) >= 2 and int(world_time * 2.0) % 2 == 0:
					draw_rect(Rect2(p + Vector2(17, -24), Vector2(4, 4)), rarity_color.lightened(0.3))
	for enemy in enemies:
		if visible_world(enemy["pos"], 55): draw_enemy(enemy)
	for cloud in poison_clouds:
		if visible_world(cloud["pos"], 110):
			var center: Vector2 = cloud["pos"]
			var fade: float = minf(1.0, float(cloud["life"]) * 0.65)
			draw_circle(center, 83, Color(0.32, 0.52, 0.23, 0.18 * fade))
			for bubble in 9:
				var angle := float(bubble) * TAU / 9.0 + world_time * (0.2 if bubble % 2 == 0 else -0.3)
				var point := center + Vector2.RIGHT.rotated(angle) * (19 + bubble % 4 * 16)
				draw_circle(point + Vector2(0, sin(world_time * 3.0 + bubble) * 6), 5 + bubble % 3, Color(0.62, 0.88, 0.35, 0.55 * fade))
	for shot in enemy_projectiles:
		if visible_world(shot["pos"], 45):
			var p: Vector2 = shot["pos"]
			var c := Color("b6e5fa") if shot["type"] == 11 else Color("d5acf3")
			draw_line(p - shot["dir"] * 16, p, c.darkened(0.3), 8)
			draw_vfx_sprite(1 if int(shot["type"]) in [11,13,22] else (0 if int(shot["type"]) in [14] else 4), p, 28.0)
	if arena_mode == "" and dungeon_id < 0 and interior_id < 0:
		for landmark in LANDMARKS:
			if visible_world(landmark["pos"], 540 if landmark["kind"] == "hamlet" else 150): draw_landmark(landmark)
		for index in DUNGEON_ENTRANCES.size():
			var entrance: Vector2 = LANDMARKS[int(DUNGEON_ENTRANCES[index])]["pos"] + Vector2(-30, 70)
			if visible_world(entrance, 135): draw_dungeon_entrance(entrance, index)
		for event_index in WORLD_EVENTS.size():
			if visible_world(WORLD_EVENTS[event_index]["pos"], 180): draw_event_scene(event_index)
		for i in LANDMARKS.size():
			if visible_world(chest_position(i), 80): draw_chest(chest_position(i), opened_chests[i])
		for i in WAYSTONES.size():
			if visible_world(WAYSTONES[i], 100): draw_waystone(WAYSTONES[i])
		for portal in PORTALS:
			if visible_world(portal[0], 100): draw_portal(portal[0], int(portal[2]))
			if visible_world(portal[1], 100): draw_portal(portal[1], int(portal[2]))
		for npc in NPCS:
			if visible_world(npc["pos"], 70): draw_npc(npc)
		if rescue_state >= 2 and visible_world(RESCUE_POS, 190):
			draw_npc({"name":"Nela", "role":"Bewohnerin", "pos":RESCUE_POS + Vector2(0, 120), "color":Color("bd8774"), "kind":"rescued"})
	for projectile in projectiles:
		if visible_world(projectile["pos"], 40):
			var p: Vector2 = projectile["pos"]
			var d: Vector2 = projectile["dir"]
			var side := d.rotated(PI * 0.5)
			var spell_id: int = int(projectile.get("spell_id", -1))
			var element: String = str(projectile.get("element", ""))
			var accent := element_color(element) if element != "" else (Color("ff9b4a") if spell_id in [16,22] else (Color("c5a8ff") if int(projectile["kind"]) == 2 else Color("ffe2a0")))
			if projectile.has("trail"):
				var trail: Array = projectile["trail"]
				for segment in range(1, trail.size()):
					var start: Vector2 = trail[segment - 1]
					var finish: Vector2 = trail[segment]
					draw_line(start, finish, Color(accent, float(segment) / float(trail.size()) * 0.5), 3 if spell_id in [18, 25] else 8)
			if spell_id == 16:
				var flame_tail := p - d * 15.0
				draw_circle(flame_tail, 18 + sin(world_time * 24) * 3, Color("d84d28", 0.42))
				draw_colored_polygon(PackedVector2Array([p-d*20-side*10,p+d*9-side*8,p+d*20,p+d*8+side*9,p-d*19+side*10]),Color("ed672f"))
				draw_circle(p, 12, Color("ff9a3f"))
				draw_circle(p + side * 3 - d * 2, 6, Color("fff0a6"))
			elif spell_id == 22:
				draw_line(p-d*28,p+d*14,Color("a83d26",0.55),14)
				draw_line(p-d*23,p+d*10,Color("ff7b32"),8)
				draw_colored_polygon(PackedVector2Array([p+d*25,p+side*8,p-d*24,p-side*8]),Color("ffad4d"))
				draw_circle(p-d*7,6,Color("fff0a6"))
			elif spell_id == 18:
				draw_line(p - d * 70, p + d * 31, Color("f5d56c", 0.6), 13)
				draw_line(p - d * 85, p + d * 32, Color("fff9d4"), 4)
				draw_circle(p + d * 32, 7, Color.WHITE)
			elif spell_id == 20:
				draw_circle(p, 15, Color("9e85e9", 0.35))
				for spark in 3:
					var ray := Vector2.RIGHT.rotated(world_time * 7 + float(spark) * TAU / 3.0)
					draw_rect(Rect2(p + ray * 14 - Vector2(4, 4), Vector2(8, 8)), Color("ddc8ff"))
				draw_circle(p, 6, Color.WHITE)
			elif spell_id == 25:
				draw_line(p - d * 58, p + d * 36, Color("f9e1a3", 0.4), 11)
				draw_line(p - d * 42, p + d * 20, Color("fff7d4"), 4)
				draw_colored_polygon(PackedVector2Array([p + d * 39, p + side * 9, p - side * 9]), Color("f6e3b0"))
			elif spell_id == 28:
				draw_line(p - d * 19, p + d * 12, Color("625b3a"), 5)
				draw_colored_polygon(PackedVector2Array([p + d * 22, p + side * 9, p - side * 9]), Color("c0eb69"))
				for drop in 3: draw_circle(p - d * (8 + drop * 10) + side * sin(world_time * 15 + drop) * 7, 4, Color("91cd5f", 0.72))
			elif spell_id == 29:
				draw_colored_polygon(PackedVector2Array([p + d * 30, p + side * 10, p - d * 25, p - side * 10]), Color("d4f9ff"))
				draw_line(p - d * 21, p + d * 18, Color("78c6eb"), 4)
				for shard in [-1, 1]: draw_rect(Rect2(p - d * 15 + side * shard * 13 - Vector2(3, 3), Vector2(6, 6)), Color("9ee6f4"))
			elif spell_id == 30:
				draw_line(p - d * 28, p + d * 13, Color("79613d"), 4)
				for zig in 3:
					var from_point := p - d * (zig * 13) + side * (6 if zig % 2 == 0 else -6)
					draw_line(from_point, from_point + d * 15 - side * (12 if zig % 2 == 0 else -12), Color("fff0a5"), 4)
			elif int(projectile["kind"]) == 2:
				draw_circle(p - d * 14, 15, Color(accent, 0.24))
				draw_circle(p, 12 + sin(world_time * 19) * 2, accent)
				draw_circle(p - d * 3, 5, Color.WHITE)
			elif int(projectile["kind"]) == 3:
				draw_line(p - d * 27, p + d * 16, Color("735a47"), 4)
				draw_colored_polygon(PackedVector2Array([p + d * 23, p + side * 7, p - side * 7]), accent)
				draw_line(p - d * 21 + side * 8, p - d * 25, Color("f3eee1"), 3)
				draw_line(p - d * 21 - side * 8, p - d * 25, Color("f3eee1"), 3)
			else:
				draw_line(p - d * 25, p - d * 58, Color(accent, 0.25), 13)
				draw_colored_polygon(PackedVector2Array([p + d * 24, p + side * 11, p - d * 18, p - side * 11]), accent)
				draw_line(p - d * 11, p + d * 16, Color.WHITE, 3)
			var vfx_kind := 5 if int(projectile["kind"]) == 3 else (0 if spell_id in [16,22] else (1 if spell_id in [17,29] else (2 if spell_id in [18,30] else (3 if spell_id in [28] else 4))))
			if spell_id >= 0: draw_vfx_sprite(vfx_kind, p, 24.0)
	for zone in impact_zones:
		if visible_world(zone["pos"], float(zone["radius"]) + 20.0):
			var c: Color = Color("ecaa75") if zone["element"] == "feuer" else (Color("aedbf0") if zone["element"] == "eis" else Color("f5dfa0"))
			var p: Vector2 = zone["pos"]
			var radius: float = float(zone["radius"])
			draw_circle(p, radius, Color(c, 0.08))
			draw_arc(p, radius, 0, TAU, 32, Color(c, 0.65), 4)
			for ray in 8:
				var angle := float(ray) * TAU / 8.0 + world_time
				draw_line(p + Vector2.RIGHT.rotated(angle) * (radius - 12), p + Vector2.RIGHT.rotated(angle) * radius, Color(c, 0.75), 3)
	for zone in battle_zones:
		var center: Vector2 = zone["pos"]
		var radius: float = float(zone["radius"])
		var fade := minf(1.0, float(zone["life"]) / 1.0)
		var tint := Color("ff873e") if str(zone["kind"]) == "fire" else Color("e7c574")
		draw_circle(center, radius, Color(tint, 0.18 * fade))
		draw_arc(center, radius, 0.0, TAU, 48, Color(tint, 0.87 * fade), 5)
		for rune in 12:
			var offset := Vector2.RIGHT.rotated(float(rune) * TAU / 12.0 + world_time * 0.15) * (radius * 0.72)
			var ember := 5.0 + sin(world_time * 6.0 + rune) * 2.0
			draw_rect(Rect2(center + offset - Vector2(ember * 0.5, ember * 0.5), Vector2(ember, ember)), tint.lightened(0.28))
	for arc_line in lightning_lines:
		var a: Vector2 = arc_line["from"]
		var b: Vector2 = arc_line["to"]
		var middle := a.lerp(b, 0.5) + (b - a).normalized().rotated(PI * 0.5) * 17
		draw_line(a, middle, Color("fff2a3", 0.55), 13)
		draw_line(middle, b, Color("fff2a3", 0.55), 13)
		draw_line(a, middle, Color.WHITE, 4)
		draw_line(middle, b, Color.WHITE, 4)
	for visual in spell_visuals:
		if visible_world(visual["pos"], 210) or visible_world(visual["end"], 210): draw_spell_visual(visual)
	if dungeon_id >= 0: draw_dungeon_atmosphere()
	elif arena_mode == "" and interior_id < 0: draw_overworld_atmosphere()
	draw_remote_players()
	draw_player()
	for e in effects:
		var p: Vector2 = e["pos"] + Vector2(0, (float(e["max"]) - float(e["life"])) * -40)
		text_at(p, String(e["text"]), 18, e["color"], HORIZONTAL_ALIGNMENT_CENTER, 180)
	draw_set_transform(Vector2.ZERO)
	draw_hud()
	draw_chat_overlay()
	if rescue_intro_timer > 0.0 or reward_scene_timer > 0.0: draw_rescue_alert()
	if panel != "": draw_panel()

func draw_day_night_overlay() -> void:
	# Ein ruhiger 12-Minuten-Rhythmus: warme Dämmerung, kühle Nacht, lesbarer Tag.
	var phase := fposmod(world_time, 720.0) / 720.0
	var daylight := (1.0 - cos(phase * TAU)) * 0.5
	var night := pow(1.0 - daylight, 1.65)
	var dusk := pow(absf(sin(phase * TAU)), 12.0)
	if night > 0.01:
		draw_rect(Rect2(camera_pos, VIEW), Color("172644", 0.22 * night))
	if dusk > 0.01:
		draw_rect(Rect2(camera_pos, VIEW), Color("df895b", 0.055 * dusk))

func draw_remote_players() -> void:
	if remote_players.is_empty(): return
	for peer_id in remote_players.keys():
		var state: Dictionary = remote_players[peer_id]
		var coords: Array = state.get("pos", [0.0,0.0])
		if coords.size() < 2: continue
		var rp := Vector2(float(coords[0]), float(coords[1]))
		if not visible_world(rp, 120): continue
		var dir_data: Array = state.get("facing", [0.0,1.0])
		var rdir := Vector2(float(dir_data[0]),float(dir_data[1])) if dir_data.size() >= 2 else Vector2.DOWN
		var race := clampi(int(state.get("race",0)),0,2)
		var gender := clampi(int(state.get("gender",0)),0,1)
		var cls := clampi(int(state.get("class",0)),0,2)
		draw_rect(Rect2(rp + Vector2(-19,24),Vector2(38,5)),Color(0.10,0.17,0.18,0.25))
		draw_character_sprite(rp, cls, bool(state.get("walking",false)), rdir, 1.0, false, race, gender)
		draw_weapon_world(rp + Vector2(0,-5), cls, clampi(int(state.get("weapon",0)),0,11), rdir, 1.0)
		text_at(rp + Vector2(-75,-57), "%s · LV %d" % [str(state.get("name","Freund")), int(state.get("level",1))], 13, Color('bfe7ff'), HORIZONTAL_ALIGNMENT_CENTER, 150)

func draw_chat_overlay() -> void:
	if not chat_open and (chat_messages.is_empty() or chat_fade <= 0.0): return
	var visible_count := mini(6, chat_messages.size())
	var height := 34.0 + visible_count * 24.0 + (42.0 if chat_open else 0.0)
	var box := Rect2(20, VIEW.y - height - 18, 520, height)
	var fade_alpha := 1.0 if chat_open else clampf(chat_fade / 1.25, 0.0, 1.0)
	draw_rect(box, Color(0.04,0.08,0.11,(0.84 if chat_open else 0.64) * fade_alpha))
	draw_rect(box, Color('718d88',0.8 * fade_alpha), false, 2)
	var start := maxi(0, chat_messages.size() - visible_count)
	for i in range(start, chat_messages.size()):
		var entry: Dictionary = chat_messages[i]
		var y := box.position.y + 24 + float(i-start) * 24.0
		text_at(Vector2(box.position.x+12,y), "%s:" % str(entry.get("author","?")), 14, Color('f1d18d', fade_alpha))
		text_at(Vector2(box.position.x+105,y), str(entry.get("text","")), 14, Color('e6efe8', fade_alpha), HORIZONTAL_ALIGNMENT_LEFT, 395)
	if chat_open:
		var input_rect := Rect2(box.position + Vector2(8, box.size.y-37), Vector2(box.size.x-16,29))
		draw_rect(input_rect, Color('17272e'))
		draw_rect(input_rect, Color('9cbeb5'), false, 1)
		text_at(input_rect.position + Vector2(8,20), "> " + chat_input + "_", 14, Color('fff0ce'), HORIZONTAL_ALIGNMENT_LEFT, int(input_rect.size.x-16))
	else:
		text_at(box.position + Vector2(12, box.size.y-8), "ENTER oder T · Chat", 11, Color('a9beb7', fade_alpha))

func draw_ground_gold(p: Vector2, amount: int) -> void:
	var pieces := 1 if amount < 12 else (2 if amount < 45 else 5)
	for i in pieces:
		var offset := Vector2((i % 3) * 10 - 10, int(i / 3.0) * -7 + (i % 2) * 3)
		draw_rect(Rect2(p + offset + Vector2(-6, -3), Vector2(13, 12)), Color("643b27"))
		draw_rect(Rect2(p + offset + Vector2(-5, -5), Vector2(11, 11)), Color("e5a632"))
		draw_rect(Rect2(p + offset + Vector2(-3, -3), Vector2(7, 7)), Color("ffdb62"))
		draw_rect(Rect2(p + offset + Vector2(-2, -3), Vector2(3, 2)), Color("fff2ab"))
	if amount >= 45: draw_rect(Rect2(p + Vector2(13, -17), Vector2(4, 4)), Color("fff1ad"))

func draw_rescue_alert() -> void:
	var danger := rescue_state == 1
	var reward := reward_scene_timer > 0.0
	var time_left := reward_scene_timer if reward else rescue_intro_timer
	var fade := clampf(time_left / 1.2, 0.0, 1.0) if time_left < 1.2 else 1.0
	var card := Rect2(278, 92, 596, 112)
	draw_rect(card, Color(0.11, 0.12, 0.15, 0.90 * fade))
	draw_rect(Rect2(card.position, Vector2(card.size.x, 4)), Color("e47768") if danger else Color("83d69b"))
	var title := "NELA · EIN GESCHENK FÜR DIE RETTUNG" if reward else ("BLÜTENWEILER WIRD ANGEGRIFFEN" if danger else "BLÜTENWEILER IST GERETTET")
	var subtitle := "Die Dornen kamen aus dem alten Turm. Nimm diese Waffe und finde ihre Quelle." if reward else ("Rauch hinter den Dächern. Jemand läutet die Alarmglocke." if danger and rescue_intro_timer > 6.0 else ("Halte die Dornen zurück · %d/%d besiegt." % [rescue_kills, RESCUE_GOAL] if danger else "Die Glocke schweigt. Nela wartet mit einer Gabe am Dorfplatz."))
	text_at(Vector2(304, 132), title, 24, Color("ffe7aa") if danger else Color("c8f4c8"), HORIZONTAL_ALIGNMENT_CENTER, 544)
	text_at(Vector2(304, 165), subtitle, 16, Color("f2eee0"), HORIZONTAL_ALIGNMENT_CENTER, 544)
	if reward:
		draw_item_icon(Vector2(304, 164), class_weapon_icon(), Color("f1cf83"), 0.75)
		text_at(Vector2(351, 190), "+160 XP · +80 Gold · seltene Klassenwaffe", 15, Color("f6e0a0"))
	elif danger:
		text_at(Vector2(304, 190), "FORTSCHRITT  %d / %d" % [rescue_kills, RESCUE_GOAL], 15, Color("ffb1a1"), HORIZONTAL_ALIGNMENT_CENTER, 544)
 

func draw_spell_visual(visual: Dictionary) -> void:
	var id: int = int(visual["kind"])
	var p: Vector2 = visual["pos"]
	var direction: Vector2 = visual["dir"]
	var progress := 1.0 - float(visual["life"]) / float(visual["max"])
	var alpha := 1.0 - progress
	var size := 1.0 + float(visual["rank"] - 1) * 0.08
	match id:
		0:
			for arc_index in 3:
				var angle := progress * TAU * 1.6 + float(arc_index) * TAU / 3.0
				draw_arc(p, 72 * size + progress * 45, angle, angle + 1.35, 16, Color("ffe6a4", alpha), 9)
		1:
			for i in 6:
				var a := float(i) * TAU / 6.0 + progress * 0.45
				var b := float(i + 1) * TAU / 6.0 + progress * 0.45
				draw_line(p + Vector2.RIGHT.rotated(a) * 47, p + Vector2.RIGHT.rotated(b) * 47, Color("9de6f4", alpha), 7)
		2:
			var end: Vector2 = visual["end"]
			for i in 4:
				var point := p.lerp(end, float(i + 1) / 5.0)
				draw_arc(point, 20 + i * 4, 0, TAU, 16, Color("f8dfad", alpha * 0.7), 5)
		3:
			draw_arc(p, 44 + progress * 60, direction.angle() - 0.65, direction.angle() + 0.65, 16, Color("fff2be", alpha), 8)
		4:
			draw_arc(p, 28 + progress * 130 * size, 0, TAU, 32, Color("ffbb70", alpha), 10)
			for i in 8:
				var ray := Vector2.RIGHT.rotated(float(i) * TAU / 8.0)
				draw_line(p + ray * 35, p + ray * (65 + progress * 75), Color("ffe6a0", alpha), 5)
		5:
			for i in 5:
				var center := p + direction * (40 + i * 32) * progress
				var side := direction.rotated(PI * 0.5) * (24 + i * 8)
				draw_line(center - side, center + side, Color("edc995", alpha), 6)
		6:
			for i in 7:
				var angle := float(i) * TAU / 7.0 + progress * 2.3
				var orb := p + Vector2.RIGHT.rotated(angle) * (35 + progress * 35)
				draw_circle(orb, 7 * alpha + 2, Color("f6a7cb", alpha))
		7:
			for i in [-1, 0, 1]:
				draw_line(p + direction.rotated(float(i) * 0.28) * 35, p + direction.rotated(float(i) * 0.28) * (80 + progress * 45), Color("c8b5ff", alpha), 5)
		8:
			draw_arc(p, 28 + progress * 85, 0, TAU, 32, Color("a8edc4", alpha), 8)
			for i in 4:
				var ray := Vector2.RIGHT.rotated(float(i) * TAU / 4.0 + progress)
				draw_rect(Rect2(p + ray * 48 - Vector2(5, 5), Vector2(10, 10)), Color("e6ffd4", alpha))
		12:
			for i in [-2, -1, 0, 1, 2]:
				var ray := direction.rotated(float(i) * 0.2)
				var tip := p + ray * (55 + progress * 115)
				draw_line(p + ray * 25, tip, Color("9ce6f7", alpha), 9)
				draw_circle(tip, 8 * alpha + 2, Color("f1ffff", alpha))
		13:
			draw_arc(p, 24 + progress * 65, 0, TAU, 16, Color("fff1a1", alpha), 5)
		14:
			for i in 8:
				var angle := float(i) * TAU / 8.0 + progress * 1.7
				var bubble := p + Vector2.RIGHT.rotated(angle) * (22 + progress * 56)
				draw_circle(bubble, 5 + float(i % 3), Color("a8e57a", alpha))
		16:
			for i in 6:
				var ray := Vector2.RIGHT.rotated(float(i) * TAU / 6.0 + world_time)
				var tip := p + ray * (19 + progress * 72)
				draw_line(p + ray * 12, tip, Color("ff964d", alpha), 6)
				draw_circle(tip, 5, Color("ffe6a2", alpha))
		17:
			var radius := 22 + progress * 190
			draw_arc(p, radius, 0, TAU, 40, Color("c2f5ff", alpha), 7)
			for shard in 12:
				var ray := Vector2.RIGHT.rotated(float(shard) * TAU / 12.0)
				var tip := p + ray * radius
				draw_line(tip - ray * 22, tip + ray * 14, Color("ecffff", alpha), 5)
				draw_line(tip, tip + ray.rotated(PI * 0.5) * 12, Color("89d8ed", alpha), 3)
		18:
			for i in 3:
				var point := p + direction * (12 + i * 25) * (1.0 + progress)
				draw_line(point - direction.rotated(PI * 0.5) * 13, point + direction.rotated(PI * 0.5) * 13, Color("fff4a5", alpha), 5)
			draw_circle(p, 18 + progress * 28, Color("ffec95", alpha * 0.14))
		19, 27:
			var finish: Vector2 = visual["end"]
			for echo in 4:
				var point: Vector2 = p.lerp(finish, float(echo + 1) / 5.0)
				draw_rect(Rect2(point - Vector2(12, 27), Vector2(24, 39)), Color("bda6ef", alpha * 0.25) if id == 19 else Color("e4d29d", alpha * 0.25))
				draw_arc(point, 18 + echo * 4, 0, TAU, 16, Color("d5c5ff", alpha) if id == 19 else Color("ffe7b2", alpha), 3)
		20:
			for orb in 3:
				var ray := Vector2.RIGHT.rotated(float(orb) * TAU / 3.0 + progress * 8)
				var point := p + ray * (25 + progress * 58)
				draw_circle(point, 9, Color("c4a8fa", alpha))
				draw_circle(point, 3, Color.WHITE)
		21:
			for facet in 6:
				var start := p + Vector2.RIGHT.rotated(float(facet) * TAU / 6.0) * 47
				var finish := p + Vector2.RIGHT.rotated(float(facet + 1) * TAU / 6.0) * 47
				draw_line(start, finish, Color("a9e8f3", alpha), 8)
				draw_line(p, start, Color("e0faff", alpha * 0.38), 2)
		22, 31, 33:
			var hue := Color("f9a26a") if id == 22 else Color("f5dda1")
			for arrow in 9:
				var offset := Vector2((arrow % 3 - 1) * 28, (arrow / 3 - 1) * 25)
				var top := p + offset + Vector2(0, -75 + progress * 95)
				draw_line(top - Vector2(0, 19), top + Vector2(0, 13), Color(hue, alpha), 4)
				draw_colored_polygon(PackedVector2Array([top + Vector2(-6, 8), top + Vector2(0, 20), top + Vector2(6, 8)]), Color(hue, alpha))
		23, 24:
			for ring in 3:
				var hue: Color = [Color("a9eafa"), Color("ffe7a0"), Color("b6e6a1")][ring]
				var radius := 44 + ring * 24 + progress * (35 if id == 23 else 150)
				draw_arc(p, radius, world_time * (1.4 + ring * 0.4) + ring * 2.0, world_time * (1.4 + ring * 0.4) + ring * 2.0 + 2.5, 20, Color(hue, alpha), 7)
		25:
			draw_arc(p, 28 + progress * 22, 0, TAU, 24, Color("f8e2ab", alpha), 3)
			for side in [-1.0, 1.0]:
				draw_line(p + direction * 42 + direction.rotated(PI * 0.5) * side * 16, p + direction * 64, Color("fff3c7", alpha), 4)
		26:
			for shot in [-1.0, 0.0, 1.0]:
				var ray := direction.rotated(shot * 0.27)
				draw_line(p + ray * 20, p + ray * (66 + progress * 45), Color("f5dfa8", alpha), 5)
		28:
			for bubble in 7:
				var ray := Vector2.RIGHT.rotated(float(bubble) * TAU / 7.0 + progress)
				draw_circle(p + ray * (20 + progress * 65), 5 + bubble % 3, Color("b7ed78", alpha))
		29:
			for shard in 8:
				var ray := Vector2.RIGHT.rotated(float(shard) * TAU / 8.0)
				var tip := p + ray * (23 + progress * 74)
				draw_line(tip - ray * 20, tip + ray * 12, Color("cbf9ff", alpha), 6)
		30:
			for zig in 4:
				var start := p + direction * (zig * 17) + direction.rotated(PI * 0.5) * (12 if zig % 2 == 0 else -12)
				var finish := p + direction * ((zig + 1) * 17) + direction.rotated(PI * 0.5) * (-12 if zig % 2 == 0 else 12)
				draw_line(start, finish, Color("fff1a1", alpha), 5)
		32:
			for wing in [-1.0, 1.0]:
				var tip := p + Vector2(wing * (48 + progress * 80), -64 * alpha)
				draw_line(p + Vector2(0, -20), tip, Color("e9dca2", alpha), 8)
			draw_circle(p + Vector2(0, -30), 10, Color("fff0bd", alpha))
		_:
			var hue := Color("efab74") if id in [16, 22] else (Color("a9e7f7") if id in [17, 21, 29] else (Color("f7e495") if id in [18, 24, 30, 33] else (Color("b6e599") if id in [28, 32] else Color("c8aef1"))))
			var rays := 3 if id in [20, 26, 31] else 8
			for i in rays:
				var angle := float(i) * TAU / float(rays) + progress * 2.8
				var source := p + Vector2.RIGHT.rotated(angle) * (14 + progress * 27)
				var target := p + Vector2.RIGHT.rotated(angle + 0.35) * (39 + progress * 105 * size)
				draw_line(source, target, Color(hue, alpha * 0.33), 11)
				draw_line(source, target, Color(hue, alpha), 3)
				draw_circle(target, 4 + 4 * alpha, Color("fff7e8", alpha))

func visible_world(pos: Vector2, margin: float = 100.0) -> bool:
	return pos.x > camera_pos.x - margin and pos.x < camera_pos.x + VIEW.x + margin and pos.y > camera_pos.y - margin and pos.y < camera_pos.y + VIEW.y + margin

func hash_cell(x: int, y: int) -> int:
	var n := x * 92821 + y * 68917 + x * y * 31
	return absi(n ^ (n >> 11)) % 997

func visual_region_at(p: Vector2) -> int:
	if p.x < 1580 and p.y < 2400: return region_at(p)
	var shifted := p + Vector2(sin(p.y / 290.0) * 92.0 + sin(p.y / 110.0) * 34.0, sin(p.x / 330.0) * 88.0 + sin(p.x / 145.0) * 30.0)
	return region_at(shifted.clamp(Vector2.ZERO, WORLD - Vector2.ONE))

func draw_pixel_tile(index: int, pos: Vector2, size: float = 48.0, tint: Color = Color.WHITE) -> void:
	if environment_tiles == null: return
	var source := Rect2(Vector2((index % 8) * 16, int(index / 8.0) * 16), Vector2(16, 16))
	draw_texture_rect_region(environment_tiles, Rect2(pos, Vector2(size, size)), source, tint)

func draw_region_tile(zone: int, variant: int, pos: Vector2, size: float = 64.0) -> void:
	if region_tiles == null: return
	var idx := clampi(zone, 0, 12) * 8 + (variant % 8)
	var src := Rect2(Vector2((idx % 16) * 16, int(idx / 16.0) * 16), Vector2(16, 16))
	draw_texture_rect_region(region_tiles, Rect2(pos, Vector2(size, size)), src)

func region_ground_color(zone: int, key: int, wet: bool = false) -> Color:
	# Ruhiger Untergrund wie im früheren Kartenstil: große Farbflächen,
	# während Pixel-Details gezielt Wegen und Objekten vorbehalten bleiben.
	var colors := [Color("a9d883"), Color("a1d77d"), Color("83bb8d"), Color("c7bea0"), Color("83b7bd"), Color("a48978"), Color("ecd6a0"), Color("777591"), Color("a4c5b6"), Color("c9b477"), Color("80b6b2"), Color("898ca5"), Color("b6accc")]
	var base: Color = colors[clampi(zone, 0, colors.size() - 1)]
	if zone == 6 and wet: base = Color("80bbd1")
	var shade := 0.012 if key % 11 == 0 else (0.006 if key % 5 == 0 else 0.0)
	return base.lightened(shade) if key % 3 == 0 else base.darkened(shade)

func cardinal_direction_index(dir: Vector2) -> int:
	if absf(dir.x) > absf(dir.y): return 2 if dir.x > 0.0 else 1
	return 0 if dir.y > 0.0 else 3

func draw_character_sprite(p: Vector2, visual_class: int, walking: bool, look: Vector2, scale_factor: float = 1.0, attack: bool = false, race_override: int = -1, gender_override: int = -1) -> void:
	if character_sprites == null: return
	var use_race := hero_race if race_override < 0 else race_override
	var use_gender := hero_gender if gender_override < 0 else gender_override
	var combo := ((clampi(use_race,0,2) * 2 + clampi(use_gender,0,1)) * 3 + clampi(visual_class,0,2))
	var direction := cardinal_direction_index(look)
	var frame := 3 if attack else (1 + int(world_time * 7.0) % 2 if walking else 0)
	var src := Rect2(Vector2(frame * 32, (combo * 4 + direction) * 32), Vector2(32,32))
	var size := Vector2(70,70) * scale_factor
	draw_texture_rect_region(character_sprites, Rect2(p - size * 0.5 + Vector2(0,-14*scale_factor), size), src)
	draw_character_detail_overlay(p, visual_class, look, scale_factor, use_race, use_gender)

func draw_character_detail_overlay(p: Vector2, visual_class: int, look: Vector2, scale_factor: float, race: int, gender: int) -> void:
	var accent: Color = [Color('e5bd77'),Color('8fcde6'),Color('91c787')][clampi(visual_class,0,2)]
	var face_y: float = -25.0 if look.y >= -0.4 else -28.0
	if race == 1:
		# Orks: markante Hauer und breitere Schulterakzente.
		draw_rect(Rect2(p+Vector2(-10,face_y+8)*scale_factor,Vector2(4,3)*scale_factor),Color('efe0bd'))
		draw_rect(Rect2(p+Vector2(6,face_y+8)*scale_factor,Vector2(4,3)*scale_factor),Color('efe0bd'))
	elif race == 2:
		# Roboter: leuchtender Sensor und Metallfugen.
		draw_rect(Rect2(p+Vector2(-6,face_y+2)*scale_factor,Vector2(12,3)*scale_factor),Color('8fe8ef'))
		draw_rect(Rect2(p+Vector2(-12,-8)*scale_factor,Vector2(24,2)*scale_factor),Color('b8c7ca',0.8))
	if visual_class == 0:
		draw_rect(Rect2(p+Vector2(-17,-15)*scale_factor,Vector2(34,4)*scale_factor),accent.darkened(0.18))
		draw_rect(Rect2(p+Vector2(-4,-13)*scale_factor,Vector2(8,7)*scale_factor),Color('dbe7e5'))
	elif visual_class == 1:
		# Kleiner Facettenstein am Kapuzenrand statt des unnatürlichen blauen Gesichtsstrichs.
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-35)*scale_factor,p+Vector2(4,-32)*scale_factor,p+Vector2(0,-28)*scale_factor,p+Vector2(-4,-32)*scale_factor]),Color('b992df'))
		draw_line(p+Vector2(-2,-32)*scale_factor,p+Vector2(0,-34)*scale_factor,Color('f0e5ff'),1.4*scale_factor)
	else:
		draw_line(p+Vector2(-14,-10)*scale_factor,p+Vector2(13,12)*scale_factor,Color('d6b879'),3*scale_factor)
		draw_rect(Rect2(p+Vector2(11,-3)*scale_factor,Vector2(5,17)*scale_factor),Color('7a5b45'))

func draw_enemy_sprite(type: int, p: Vector2, scale_factor: float = 1.0, flash: bool = false) -> void:
	if enemy_sprites == null: return
	var frame := 3 if flash else int(world_time * 5.0 + float(type)) % 3
	var src := Rect2(Vector2(frame * 32, clampi(type,0,26) * 32), Vector2(32,32))
	var size := Vector2(70,70) * scale_factor
	draw_texture_rect_region(enemy_sprites, Rect2(p - size * 0.5 + Vector2(0,-14*scale_factor), size), src)
	draw_enemy_detail_overlay(type, p, scale_factor, flash)

func draw_enemy_detail_overlay(type: int, p: Vector2, scale_factor: float, flash: bool) -> void:
	var info: Dictionary = ENEMY_TYPES[clampi(type,0,ENEMY_TYPES.size()-1)]
	var base: Color = info["color"]
	var pulse: float = 0.65 + sin(world_time*4.0+float(type))*0.22
	# Kleine, typabhängige Details erhöhen Material- und Rollenlesbarkeit ohne schwarze Sprite-Schatten.
	match type:
		0, 2, 17, 19, 21:
			draw_rect(Rect2(p+Vector2(-13,-17)*scale_factor,Vector2(6,3)*scale_factor),base.lightened(0.35))
			draw_rect(Rect2(p+Vector2(7,-13)*scale_factor,Vector2(5,3)*scale_factor),base.lightened(0.22))
		4, 7, 9, 16, 26:
			for side in [-1.0,1.0]: draw_rect(Rect2(p+Vector2(side*18-3,-18)*scale_factor,Vector2(6,15)*scale_factor),base.lightened(0.28))
			draw_rect(Rect2(p+Vector2(-5,-9)*scale_factor,Vector2(10,7)*scale_factor),Color('f4d27c') if type in [4,9,16] else Color('b7f2f6'))
		5, 18, 22:
			draw_circle(p+Vector2(0,-12)*scale_factor,5*scale_factor,Color('f2f4e8'))
			draw_circle(p+Vector2(0,-12)*scale_factor,2.2*scale_factor,Color('405b69'))
		8, 15, 23, 24, 25:
			for side in [-1.0,1.0]: draw_colored_polygon(PackedVector2Array([p+Vector2(side*9,-27)*scale_factor,p+Vector2(side*20,-39)*scale_factor,p+Vector2(side*18,-20)*scale_factor]),base.lightened(0.18))
		10, 6:
			for side in [-1.0,1.0]: draw_circle(p+Vector2(side*19,-2)*scale_factor,5*scale_factor,base.lightened(0.3))
		11, 20:
			draw_arc(p+Vector2(0,-7)*scale_factor,17*scale_factor,0,TAU,16,Color(base.lightened(0.42),0.45*pulse),2*scale_factor)
		12, 13, 14:
			draw_arc(p+Vector2(0,-5)*scale_factor,27*scale_factor,0,TAU,20,Color(base.lightened(0.35),0.38*pulse),3*scale_factor)
	if flash:
		draw_arc(p,25*scale_factor,0,TAU,18,Color('fff7df',0.72),2*scale_factor)

func npc_sprite_row(kind: String, name: String) -> int:
	if kind == "quest":
		if name == "Mira": return 0
		if name == "Borin": return 1
		if name == "Liora": return 2
	match kind:
		"smith": return 3
		"merchant": return 4
		"alchemy": return 5
		"healer": return 6
		"arena": return 7
		"innkeeper": return 8
		"rescued": return 9
		"event": return 10
		_: return 11

func draw_npc_sprite(p: Vector2, kind: String, name: String) -> void:
	if npc_sprites == null: return
	var row := npc_sprite_row(kind,name)
	var frame := int(world_time * 2.2 + float(absi(hash(name)) % 13)) % 3
	var src := Rect2(Vector2(frame*32,row*32),Vector2(32,32))
	draw_rect(Rect2(p+Vector2(-18,25),Vector2(36,5)),Color(0.10,0.16,0.17,0.22))
	draw_texture_rect_region(npc_sprites,Rect2(p-Vector2(32,44),Vector2(64,64)),src)

func draw_weapon_world(p: Vector2, family: int, design: int, look: Vector2, scale_factor: float = 1.0, attack_progress: float = -1.0) -> void:
	var dir: Vector2 = look.normalized() if look.length() > 0.01 else Vector2.DOWN
	dir = weapon_attack_look(dir, family, design, attack_progress)
	var side: Vector2 = dir.rotated(PI * 0.5)
	var hand: Vector2 = p + dir * 7.0 * scale_factor + side * 7.0 * scale_factor
	var variant: int = clampi(design, 0, 11) % 4
	var tier: int = clampi(int(design / 4.0), 0, 2)
	if family == 0:
		# Schwerter und Äxte: klare Silhouette, Metallkante, Griffwicklung und Schmuck.
		if design % 3 == 2:
			var haft_end: Vector2 = hand + dir * (39.0 + tier * 3.0) * scale_factor
			draw_line(hand - dir * 10.0 * scale_factor, haft_end, Color('4b342f'), 7.0 * scale_factor)
			draw_line(hand - dir * 8.0 * scale_factor, haft_end, Color('a8754d'), 3.0 * scale_factor)
			var head: Vector2 = haft_end + dir * 5.0 * scale_factor
			draw_colored_polygon(PackedVector2Array([head-side*4*scale_factor, head+side*18*scale_factor-dir*5*scale_factor, head+side*15*scale_factor+dir*13*scale_factor, head-side*3*scale_factor+dir*10*scale_factor]), Color('aebbc1'))
			draw_line(head+side*13*scale_factor-dir*3*scale_factor, head+side*11*scale_factor+dir*9*scale_factor, Color('f2eee2'), 2.0*scale_factor)
		else:
			var base: Vector2 = hand + dir * 9.0 * scale_factor
			var tip: Vector2 = base + dir * (49.0 + tier * 5.0 + variant * 2.0) * scale_factor
			draw_line(hand-dir*9*scale_factor, base, Color('533743'), 7.0*scale_factor)
			draw_line(base-side*(11+tier)*scale_factor, base+side*(11+tier)*scale_factor, Color('d6a95f'), 6.0*scale_factor)
			var metal: Color = [Color('c9d6da'),Color('c2d0dc'),Color('d7c5df'),Color('d0c1aa')][variant]
			draw_colored_polygon(PackedVector2Array([base-side*5*scale_factor, tip-dir*6*scale_factor-side*3*scale_factor, tip, tip-dir*6*scale_factor+side*3*scale_factor, base+side*5*scale_factor]), Color('33434a'))
			draw_colored_polygon(PackedVector2Array([base-side*3*scale_factor, tip-dir*7*scale_factor-side*1.5*scale_factor, tip-dir*2*scale_factor, tip-dir*7*scale_factor+side*1.5*scale_factor, base+side*3*scale_factor]), metal)
			draw_line(base+dir*7*scale_factor-side*1.4*scale_factor, tip-dir*10*scale_factor-side*1.4*scale_factor, Color('f8fbef',0.78), 1.5*scale_factor)
			draw_circle(base, (2.8+tier)*scale_factor, [Color('e9bb68'),Color('7fd4e3'),Color('d59be7')][tier])
	elif family == 1:
		# Magierstabb: gebundener Hartholzschaft, Metallringe und je Design eine andere Fantasy-Krone.
		var crown: Vector2 = hand + dir * (52.0 + tier * 6.0) * scale_factor
		var wood: Color = [Color('563b35'),Color('403c59'),Color('514b39'),Color('39464c')][variant]
		var wood_hi: Color = [Color('c18a50'),Color('9e86c9'),Color('a5a06b'),Color('83b6b2')][variant]
		draw_line(hand-dir*15*scale_factor,crown,Color('302b37'),9.0*scale_factor)
		draw_line(hand-dir*13*scale_factor,crown,wood,6.0*scale_factor)
		draw_line(hand-dir*9*scale_factor,crown-dir*12*scale_factor,wood_hi,2.0*scale_factor)
		for band in range(3):
			var band_pos := hand + dir * (float(band * 13) - 7.0) * scale_factor
			draw_line(band_pos-side*4*scale_factor,band_pos+side*4*scale_factor,Color('d2b978'),3.0*scale_factor)
		var gem: Color = [Color('62d9e5'),Color('c78af1'),Color('9bdb7d'),Color('ff9a54')][variant]
		var core := crown + dir * 9.0 * scale_factor
		match variant:
			0: # Drachenkrone
				for branch in [-1.0,1.0]:
					draw_line(core-dir*5*scale_factor,core+dir*12*scale_factor+side*branch*14*scale_factor,Color('607d68'),6*scale_factor)
					draw_line(core+dir*8*scale_factor+side*branch*8*scale_factor,core+dir*20*scale_factor+side*branch*15*scale_factor,Color('d1ab6f'),3*scale_factor)
			1: # Mondsichel mit eingeschlossenem Stern
				draw_arc(core,15*scale_factor,0.18,TAU-0.18,18,Color('dfd3b3'),5*scale_factor)
				draw_colored_polygon(PackedVector2Array([core+dir*2*scale_factor,core+side*5*scale_factor,core-dir*5*scale_factor,core-side*5*scale_factor]),gem)
			2: # Wurzelstab mit knorrigen Gabeln
				for branch in [-1.0,1.0]:
					draw_line(core-dir*5*scale_factor,core+dir*10*scale_factor+side*branch*12*scale_factor,wood_hi,6*scale_factor)
					draw_line(core+dir*8*scale_factor+side*branch*10*scale_factor,core+dir*19*scale_factor+side*branch*15*scale_factor,wood,4*scale_factor)
			3: # Runenlaterne
				var rim := core+dir*6*scale_factor
				draw_line(rim-side*12*scale_factor,rim+side*12*scale_factor,Color('c3d1d0'),4*scale_factor)
				draw_line(rim-dir*7*scale_factor,rim+dir*7*scale_factor,Color('dce8e4'),3*scale_factor)
				draw_rect(Rect2(core+dir*5*scale_factor-side*4*scale_factor,Vector2(8,8)*scale_factor),gem)
		draw_colored_polygon(PackedVector2Array([core+dir*3*scale_factor,core+side*5*scale_factor,core-dir*4*scale_factor,core-side*5*scale_factor]),gem.lightened(0.35))
		draw_rect(Rect2(core+dir*5*scale_factor-Vector2(2,2)*scale_factor,Vector2(4,4)*scale_factor),Color('fff4cf'))
	else:
		# Ein Recurvebogen bildet einen klaren Bogenkörper mit Sehne, Griff und angelegtem Pfeil.
		var wood: Color = [Color('a8764e'),Color('c08b5b'),Color('788f73'),Color('8a654d')][variant]
		if variant == 3:
			var center: Vector2 = hand + dir*19*scale_factor
			var recoil := 0.0
			if attack_progress >= 0.0: recoil = 5.0 * (1.0 - clampf(attack_progress, 0.0, 1.0))
			center -= dir * recoil * scale_factor
			draw_line(center-side*20*scale_factor, center+side*20*scale_factor, Color('3d3435'), 7*scale_factor)
			draw_line(center-side*19*scale_factor, center+side*19*scale_factor, wood, 4*scale_factor)
			draw_line(hand-dir*10*scale_factor, hand+dir*33*scale_factor, Color('7a5a43'), 6*scale_factor)
			draw_line(center-side*20*scale_factor, center+side*20*scale_factor, Color('e7e2cf'), 1.5*scale_factor)
			draw_colored_polygon(PackedVector2Array([hand+dir*38*scale_factor,hand+dir*30*scale_factor+side*4*scale_factor,hand+dir*30*scale_factor-side*4*scale_factor]),Color('edf1e6'))
		else:
			var center: Vector2 = hand + dir*16*scale_factor
			var limb: float = (21.0 + float(variant % 3) * 2.0 + float(tier) * 2.0) * scale_factor
			var upper := center + side*limb
			var lower := center - side*limb
			var outer_upper := upper + dir*(11.0 + tier*2.0)*scale_factor + side*3.0*scale_factor
			var outer_lower := lower + dir*(11.0 + tier*2.0)*scale_factor - side*3.0*scale_factor
			var bow_points := PackedVector2Array([upper,outer_upper,center+dir*18.0*scale_factor,outer_lower,lower])
			draw_polyline(bow_points,Color('332d34'),9.0*scale_factor,false)
			draw_polyline(bow_points,wood,5.0*scale_factor,false)
			draw_line(upper,lower,Color('f2e8d1'),1.8*scale_factor)
			var pull := 0.0
			if attack_progress >= 0.0: pull = 14.0 * sin(clampf(attack_progress, 0.0, 1.0) * PI)
			var draw_hand := center - dir*pull*scale_factor
			draw_line(upper,draw_hand,Color('f2e8d1'),1.7*scale_factor)
			draw_line(draw_hand,lower,Color('f2e8d1'),1.7*scale_factor)
			# Pfeilschaft liegt in der Sehne und wird beim Spannen sichtbar zurückgezogen.
			var arrow_start := center-dir*(7.0+pull)*scale_factor
			var arrow_tip := center+dir*30.0*scale_factor
			draw_line(arrow_start,arrow_tip,Color('4b3c35'),4.0*scale_factor)
			draw_line(arrow_start,arrow_tip,Color('d9b66f'),2.0*scale_factor)
			draw_colored_polygon(PackedVector2Array([arrow_tip+dir*7*scale_factor,arrow_tip-side*4*scale_factor,arrow_tip+side*4*scale_factor]),Color('f0f3e8'))
			for branch in [-1.0,1.0]:
				var rune: Vector2 = center+side*branch*8.0*scale_factor+dir*8.0*scale_factor
				draw_rect(Rect2(rune-Vector2(2,2)*scale_factor,Vector2(4,4)*scale_factor),Color('e2c477'))

func draw_skill_sprite(id: int, p: Vector2, size: float = 32.0) -> void:
	if skill_sprites == null: return
	var src := Rect2(Vector2((id % 16) * 16, int(id / 16.0) * 16), Vector2(16,16))
	draw_texture_rect_region(skill_sprites, Rect2(p, Vector2(size,size)), src)

func draw_vfx_sprite(kind: int, p: Vector2, size: float = 32.0, frame: int = -1) -> void:
	if vfx_sprites == null: return
	var use_frame := int(world_time * 10.0) % 4 if frame < 0 else frame % 4
	var src := Rect2(Vector2(use_frame*16,clampi(kind,0,7)*16),Vector2(16,16))
	draw_texture_rect_region(vfx_sprites,Rect2(p-Vector2(size*0.5,size*0.5),Vector2(size,size)),src)

func draw_structure_tile(index: int, p: Vector2, size: float = 32.0) -> void:
	if structure_tiles == null: return
	var src := Rect2(Vector2(clampi(index,0,7)*16,0),Vector2(16,16))
	draw_texture_rect_region(structure_tiles,Rect2(p,Vector2(size,size)),src)

func ground_tile_for_zone(zone: int, key: int, wet: bool = false) -> int:
	match zone:
		0: return 1 if key % 7 == 0 else 0
		1: return 1 if key % 5 == 0 else 0
		2: return 5 if key % 6 == 0 else (1 if key % 3 == 0 else 0)
		3: return 7 if key % 4 == 0 else (8 if key % 9 == 0 else 6)
		4: return 30 if key % 5 == 0 else (8 if key % 3 == 0 else 6)
		5: return 31 if key % 4 == 0 else 9
		6: return 30 if wet else (4 if key % 2 == 0 else 5)
		7: return 31 if key % 5 == 0 else 6
		8: return 30 if key % 6 == 0 else 0
		9: return 4 if key % 4 == 0 else 5
		10: return 30 if key % 4 == 0 else 8
		11: return 31 if key % 4 == 0 else 9
		12: return 30 if key % 3 == 0 else 31
		_: return 0

func ground_tint_for_zone(zone: int, key: int, wet: bool = false) -> Color:
	var drift := 0.04 if key % 7 == 0 else (0.025 if key % 5 == 0 else 0.0)
	match zone:
		0: return Color('ffffff')
		1: return Color('e4f3cf').darkened(0.025 - drift * 0.35)
		2: return Color('cfe1b8').darkened(0.055 - drift * 0.25)
		3: return Color('ddd3c1').darkened(0.07 - drift * 0.25)
		4: return Color('bfe9ed').darkened(0.045 - drift * 0.35)
		5: return Color('cda28f').darkened(0.095 - drift * 0.3)
		6:
			if wet: return Color('b7ecf1').darkened(0.04 - drift * 0.2)
			return Color('f3dfad').darkened(0.04 - drift * 0.2)
		7: return Color('c9c5e5').darkened(0.1 - drift * 0.28)
		8: return Color('c9e4db').darkened(0.04 - drift * 0.25)
		9: return Color('e8d290').darkened(0.06 - drift * 0.25)
		10: return Color('afe1e5').darkened(0.04 - drift * 0.25)
		11: return Color('c8c1dc').darkened(0.06 - drift * 0.22)
		12: return Color('e4d2f0').darkened(0.045 - drift * 0.22)
		_: return Color('ffffff')

func draw_world() -> void:
	if arena_mode != "":
		draw_arena_world()
		return
	if interior_id >= 0:
		draw_tavern_world()
		return
	if dungeon_id >= 0:
		draw_dungeon_world()
		return
	# Alle Regionen werden über dasselbe 16px-Raster aufgebaut und nur farblich variiert.
	var start_x := maxi(0, int(camera_pos.x / 64) - 2)
	var end_x := mini(int(WORLD.x / 64) + 1, int((camera_pos.x + VIEW.x) / 64) + 2)
	var start_y := maxi(0, int(camera_pos.y / 64) - 2)
	var end_y := mini(int(WORLD.y / 64) + 1, int((camera_pos.y + VIEW.y) / 64) + 2)
	for tx in range(start_x, end_x):
		for ty in range(start_y, end_y):
			var key := hash_cell(tx, ty)
			var tile_origin := Vector2(tx * 64, ty * 64)
			var center := tile_origin + Vector2(32, 32)
			var zone := visual_region_at(center)
			var wet := zone == 6 and center.y > 6850 + sin(center.x / 220.0) * 125.0
			draw_rect(Rect2(tile_origin, Vector2(64, 64)), region_ground_color(zone, key, wet))
			if zone in [4, 7, 10, 12] and key % 9 == 0:
				draw_rect(Rect2(tile_origin + Vector2(13, 17), Vector2(39, 21)), Color('edfaff', 0.12))
			elif zone == 5 and key % 8 == 0:
				draw_rect(Rect2(tile_origin + Vector2(8, 41), Vector2(44, 7)), Color('f0af71', 0.18))
			var p := Vector2(tx * 64 + (key % 23), ty * 64 + ((key / 23) % 25))
			if distance_to_trail(p) < 120.0: continue
			if zone == 0:
				if key % 6 == 0: draw_flower(p, key)
				elif key % 10 == 0: draw_grass(p)
			elif zone == 1:
				if key % 8 == 0: draw_tree(p, zone)
				elif key % 4 == 0: draw_bush_cluster(p, zone, key)
				elif key % 3 == 0: draw_flower(p, key)
				else: draw_grass(p)
			elif zone == 2:
				if key % 6 == 0: draw_tree(p, zone)
				elif key % 4 == 0: draw_mushroom(p, key)
				elif key % 3 == 0: draw_bush_cluster(p, zone, key)
				else: draw_grass(p)
			elif zone == 3:
				if key % 6 == 0: draw_ruin(p, key)
				elif key % 5 == 0: draw_tree(p, zone)
				elif key % 3 == 0: draw_bush_cluster(p, zone, key)
				else: draw_pebbles(p)
			elif zone == 4:
				if key % 4 == 0: draw_crystal(p, key)
				elif key % 7 == 0: draw_tree(p, zone)
				elif key % 3 == 0: draw_bush_cluster(p, zone, key)
				else: draw_grass(p)
			elif zone == 5:
				if key % 6 == 0: draw_lava(p)
				elif key % 4 == 0: draw_rock(p)
				else: draw_pebbles(p)
			elif zone == 6:
				if wet: draw_wave(p, key)
				elif key % 5 == 0: draw_shell(p)
				elif key % 3 == 0: draw_pebbles(p)
			elif zone == 7:
				if key % 4 == 0: draw_crystal(p, key)
				elif key % 5 == 0: draw_rock(p)
				else: draw_pebbles(p)
			elif zone >= 8:
				if zone in [8, 9] and key % 4 == 0: draw_tree(p, 2 if zone == 8 else 1)
				elif zone in [10, 12] and key % 5 == 0: draw_crystal(p, key)
				elif zone in [11] and key % 4 == 0: draw_rock(p)
				elif key % 7 == 0: draw_rock(p)
				elif key % 3 == 0: draw_flower(p, key)
				else: draw_grass(p)
	draw_trails()
	var cell_min_x := maxi(0, int(camera_pos.x / 250) - 2)
	var cell_max_x := mini(int(WORLD.x / 250) + 1, int((camera_pos.x + VIEW.x) / 250) + 2)
	var cell_min_y := maxi(0, int(camera_pos.y / 250) - 2)
	var cell_max_y := mini(int(WORLD.y / 250) + 1, int((camera_pos.y + VIEW.y) / 250) + 2)
	for cx in range(cell_min_x, cell_max_x):
		for cy in range(cell_min_y, cell_max_y):
			var obstacle := obstacle_in_cell(cx, cy)
			if not obstacle.is_empty() and visible_world(obstacle['pos'], 110): draw_obstacle(obstacle)
	if visible_world(UFO_WRECK_POS, 240): draw_ufo_wreck(UFO_WRECK_POS)
	if visible_world(UFO_CHEST_POS, 100): draw_chest(UFO_CHEST_POS, ufo_chest_opened)
	draw_village()
	draw_region_gates()
	draw_rect(Rect2(Vector2.ZERO, WORLD), Color('45726d'), false, 7)

func draw_tavern_world() -> void:
	draw_rect(Rect2(camera_pos, VIEW), Color("141e23"))
	var origin := INTERIOR_CENTER - Vector2(480, 288)
	for x in 20:
		for y in 12:
			var point := origin + Vector2(x * 48, y * 48)
			var edge := x == 0 or x == 19 or y == 0 or y == 11
			var code := hash_cell(x + 70, y + 42)
			draw_pixel_tile(9 if edge else (11 if code % 9 == 0 else 10), point)
	# Gemusterter Teppich führt vom Eingang zur warmen Theke.
	for x in 3:
		for y in 7: draw_pixel_tile(14, INTERIOR_CENTER + Vector2(-72 + x * 48, -96 + y * 48))
	for x in 20:
		draw_pixel_tile(13 if x % 4 == 0 else 12, origin + Vector2(x * 48, 0))
	for side in [0, 19]:
		for y in range(1, 12): draw_pixel_tile(9, origin + Vector2(side * 48, y * 48))
	# Hinter der langen Theke stehen Regale, Geschirr und ein Kamin.
	for x in range(-5, 6):
		draw_pixel_tile(13 if x % 3 == 0 else 24, INTERIOR_CENTER + Vector2(x * 48, -240))
	for x in range(-5, 6):
		draw_pixel_tile(22, INTERIOR_CENTER + Vector2(x * 48, -174))
	draw_pixel_tile(15, INTERIOR_CENTER + Vector2(-310, -240), 72.0)
	draw_circle(INTERIOR_CENTER + Vector2(-275, -195), 100, Color("f4a965", 0.06))
	for offset in [Vector2(-295, -15), Vector2(285, -15), Vector2(-290, 135), Vector2(290, 135)]:
		for x in 2:
			draw_pixel_tile(22, INTERIOR_CENTER + offset + Vector2(-48 + x * 48, -24))
		for x in [-75, 64]: draw_pixel_tile(23, INTERIOR_CENTER + offset + Vector2(x, -21))
		draw_pixel_tile(21, INTERIOR_CENTER + offset + Vector2(0, -75), 32.0)
	for pos in [Vector2(-408, 170), Vector2(383, 165), Vector2(350, -190)]:
		draw_pixel_tile(21, INTERIOR_CENTER + pos)
	for pos in [Vector2(-430, -110), Vector2(414, -110)]:
		draw_pixel_tile(29, INTERIOR_CENTER + pos)
		draw_circle(INTERIOR_CENTER + pos + Vector2(24, 13), 95, Color("ffba74", 0.055))
	draw_pixel_tile(20, INTERIOR_CENTER + Vector2(-24, 240))
	draw_npc({"name":"Alma", "role":"Wirtin · Eintopf & Rast", "pos":INTERIOR_CENTER + Vector2(0, -105), "color":Color("ba795e"), "kind":"innkeeper"})
	text_at(INTERIOR_CENTER + Vector2(-170, -269), "ZUR STEINROSE", 22, Color("fce5b2"), HORIZONTAL_ALIGNMENT_CENTER, 340)
	text_at(INTERIOR_CENTER + Vector2(-110, 215), "E · ZURÜCK NACH SONNENHAIN", 14, Color("ffefd0"), HORIZONTAL_ALIGNMENT_CENTER, 220)

func draw_dungeon_world() -> void:
	draw_rect(Rect2(camera_pos, VIEW), Color("101920"))
	var room := Rect2(DUNGEON_CENTER - Vector2(690, 420), Vector2(1380, 840))
	draw_rect(room.grow(24), Color("121a23"))
	for x in 29:
		for y in 18:
			var point := room.position + Vector2(x * 48, y * 48)
			var code := hash_cell(x + dungeon_id * 13, y + 71)
			var tile_id := 8 if code % 31 == 0 else (7 if code % 5 == 0 else 6)
			if y == 0 or y == 17 or x == 0 or x == 28: tile_id = 27 if code % 7 == 0 else 9
			if y in [8, 9] and x > 0 and x < 28: tile_id = 2 if code % 5 == 0 else 3
			draw_pixel_tile(tile_id, point, 48.0, Color("d4dce4") if dungeon_id == 1 else (Color("cbd8cb") if dungeon_id == 2 else Color.WHITE))
	for pillar in dungeon_pillars():
		for px in 2:
			for py in 2: draw_pixel_tile(26, pillar + Vector2(-48 + px * 48, -48 + py * 48))
		draw_rect(Rect2(pillar + Vector2(-50, -51), Vector2(100, 7)), Color("c5c9ac"))
		draw_rect(Rect2(pillar - Vector2(22, 10), Vector2(44, 6)), Color("b3a882", 0.55))
		for crack in [-18, 15]: draw_line(pillar + Vector2(crack, -34), pillar + Vector2(crack + 8, -18), Color("333f43"), 2)
	for torch_pos in dungeon_torches(): draw_torch(torch_pos, dungeon_id == 1, false)
	var door := DUNGEON_CENTER + Vector2(-630, 0)
	for dy in 2: draw_pixel_tile(20, door + Vector2(-32, -48 + dy * 48), 48.0)
	draw_rect(Rect2(door + Vector2(-38, -50), Vector2(60, 8)), Color("b4ae95"))
	var chest_pos := DUNGEON_CENTER + Vector2(555, 0)
	draw_rect(Rect2(chest_pos + Vector2(-43, -42), Vector2(86, 70)), Color("524f51"))
	draw_pixel_tile(28, chest_pos + Vector2(-32, -31), 64.0)
	draw_chest(chest_pos, dungeon_chests_opened[dungeon_id])
	if not enemies.is_empty() and not dungeon_chests_opened[dungeon_id]:
		draw_arc(chest_pos, 47, 0, TAU, 28, Color("adccd4", 0.75), 3)

func draw_dungeon_entrance(p: Vector2, index: int) -> void:
	draw_rect(Rect2(p + Vector2(-51, 19), Vector2(102, 13)), Color("586062"))
	draw_rect(Rect2(p + Vector2(-43, -35), Vector2(86, 57)), Color("454b52"))
	draw_rect(Rect2(p + Vector2(-33, -26), Vector2(66, 49)), Color("182a31"))
	draw_arc(p + Vector2(0, -24), 34, PI, TAU, 24, Color("aaaf9e"), 10)
	for stripe in [-37, 32]: draw_rect(Rect2(p + Vector2(stripe, -36), Vector2(5, 60)), Color("b2a686"))
	draw_rect(Rect2(p + Vector2(-29, 15), Vector2(58, 5)), Color("d7ba80"))
	draw_torch(p + Vector2(-58, -15), index == 1, true)
	draw_torch(p + Vector2(58, -15), index == 1, true)
	text_at(p + Vector2(-101, -70), DUNGEON_NAMES[index], 15, Color("fff0c6"), HORIZONTAL_ALIGNMENT_CENTER, 202)

func draw_torch(p: Vector2, blue: bool, flame: bool) -> void:
	draw_rect(Rect2(p + Vector2(-5, -5), Vector2(10, 30)), Color("4b3835"))
	draw_rect(Rect2(p + Vector2(-10, -9), Vector2(20, 7)), Color("bda270"))
	if not flame: return
	var flicker := sin(world_time * 9.0 + p.x * 0.011) * 3.0
	var light := Color("81e9f6") if blue else Color("ffb46c")
	# Gestaffelter Lichtschein statt eines einzelnen harten Leuchtkreises.
	for halo in range(3, 0, -1):
		var halo_radius := 18.0 + float(halo) * 23.0 + flicker * 0.7
		draw_circle(p + Vector2(0, -24), halo_radius, Color(light, 0.022 if halo == 3 else (0.036 if halo == 2 else 0.065)))
	draw_circle(p + Vector2(0, -24), 16 + flicker * 0.45, Color(light, 0.13))
	draw_colored_polygon(PackedVector2Array([p + Vector2(-7, -10), p + Vector2(0, -37 - flicker), p + Vector2(8, -10)]), light)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-3, -11), p + Vector2(2, -27 - flicker), p + Vector2(5, -11)]), Color("e8ffff") if blue else Color("fff2bf"))

func draw_dungeon_atmosphere() -> void:
	var shadow_color := Color("080f18") if dungeon_id != 2 else Color("0a1515")
	var torch_points := dungeon_torches()
	# Weiche, leicht unregelmäßige Vignette: vorn bleibt der Weg lesbar,
	# am unteren Bildrand schließt sich der Schatten wie im Pixelart-Vorbild.
	for gx in 24:
		for gy in 14:
			var point := camera_pos + Vector2(gx * 48 + 24, gy * 48 + 24)
			var offset := point - player_pos
			if offset.y > 0.0: offset.y *= 1.42
			else: offset.y *= 0.80
			var distance := offset.length() + sin(point.x * 0.021 + point.y * 0.013) * 11.0
			var t := clampf((distance - 128.0) / 302.0, 0.0, 1.0)
			var alpha := 0.065 + 0.905 * (t * t * (3.0 - 2.0 * t))
			for torch_pos in torch_points:
				var glow := clampf(1.0 - point.distance_to(torch_pos) / 235.0, 0.0, 1.0)
				if glow > 0.0:
					var torch_falloff := glow * glow * (3.0 - 2.0 * glow)
					alpha = minf(alpha, 0.97 - torch_falloff * 0.77)
			alpha = clampf(alpha + sin(world_time * 0.35 + gx * 0.21 + gy * 0.28) * 0.007, 0.06, 0.97)
			draw_rect(Rect2(camera_pos + Vector2(gx * 48, gy * 48), Vector2(48, 48)), Color(shadow_color, alpha))
	for torch_pos in torch_points:
		if visible_world(torch_pos, 50): draw_torch(torch_pos, dungeon_id == 1, true)
	for wisp in 11:
		var mist := DUNGEON_CENTER + Vector2(-590 + wisp * 116 + sin(world_time * 0.3 + wisp) * 30, (wisp % 3 - 1) * 205)
		if visible_world(mist, 90) and mist.distance_to(player_pos) < 420:
			draw_circle(mist, 28 + wisp % 4 * 8, Color("b2cbd0", 0.025))

func draw_overworld_atmosphere() -> void:
	var darkness := {2:0.27, 3:0.41, 4:0.39, 5:0.45, 7:0.56, 8:0.48, 10:0.49, 11:0.57, 12:0.44}
	var has_dark_area := false
	for corner in [camera_pos, camera_pos + Vector2(VIEW.x, 0), camera_pos + Vector2(0, VIEW.y), camera_pos + VIEW, player_pos]:
		if darkness.has(visual_region_at(corner)): has_dark_area = true
	if not has_dark_area: return
	var torches: Array = []
	for trail in TRAILS:
		for i in trail.size():
			if i % 2 == 0 and darkness.has(region_at(trail[i])) and visible_world(trail[i], 260): torches.append(trail[i] + Vector2(0, -28))
	for landmark in LANDMARKS:
		if landmark["kind"] in ["tower", "gate", "shrine"] and darkness.has(region_at(landmark["pos"])) and visible_world(landmark["pos"], 310):
			torches.append(landmark["pos"] + Vector2(-95, 42))
			torches.append(landmark["pos"] + Vector2(95, 42))
	for gx in 24:
		for gy in 14:
			var point := camera_pos + Vector2(gx * 48 + 24, gy * 48 + 24)
			var strength: float = float(darkness.get(visual_region_at(point), 0.0))
			if strength <= 0.0: continue
			var offset := point - player_pos
			if offset.y > 0.0: offset.y *= 1.13
			var distance := offset.length() + sin(point.x * 0.017 + point.y * 0.025) * 14.0
			var t := clampf((distance - 75.0) / 325.0, 0.0, 1.0)
			var shade := strength * (0.16 + 0.84 * (t * t * (3.0 - 2.0 * t)))
			for torch_pos in torches:
				shade = minf(shade, strength * clampf(point.distance_to(torch_pos) / 215.0, 0.11, 1.0))
			draw_rect(Rect2(camera_pos + Vector2(gx * 48, gy * 48), Vector2(48, 48)), Color("09131b", shade))
	for cloud in 13:
		var drift := Vector2(fmod(float(cloud * 157) + world_time * 12.0, VIEW.x + 180.0) - 90.0, float((cloud * 91) % 740) - 60.0)
		var fog_zone := visual_region_at(camera_pos + drift)
		if darkness.has(fog_zone): draw_circle(camera_pos + drift, 32 + cloud % 5 * 9, Color("c5ced3", 0.028 if fog_zone in [3, 7, 8, 10, 11] else 0.014))
	for torch_pos in torches:
		if visible_world(torch_pos, 55): draw_torch(torch_pos, region_at(torch_pos) == 4, true)

func draw_arena_world() -> void:
	draw_rect(Rect2(camera_pos, VIEW), Color("1b2632"))
	var center := ARENA_CENTER
	draw_circle(center, ARENA_RADIUS + 23.0, Color("493d4a"))
	draw_circle(center, ARENA_RADIUS + 10.0, Color("ba9564"))
	draw_circle(center, ARENA_RADIUS - 4.0, Color("45525a"))
	draw_circle(center, ARENA_RADIUS - 24.0, Color("66635b"))
	draw_circle(center, ARENA_RADIUS - 43.0, Color("74766f"))
	for ring in [92.0, 216.0, 345.0, 434.0]:
		draw_arc(center, ring, 0.0, TAU, 96, Color("c7ab76", 0.52), 3)
	for i in 40:
		var angle := float(i) * TAU / 40.0
		var direction := Vector2.RIGHT.rotated(angle)
		var edge := center + direction * (ARENA_RADIUS - 5.0)
		draw_line(edge - direction * 27.0, edge - direction * 7.0, Color("e0c282"), 7)
		if i % 5 == 0:
			draw_circle(edge + direction * 20.0, 13.0, Color("342f3a"))
			draw_rect(Rect2(edge + direction * 20.0 - Vector2(5, 16), Vector2(10, 11)), Color("e3a960"))
			draw_rect(Rect2(edge + direction * 20.0 - Vector2(3, 22), Vector2(6, 8)), Color("fff0ae"))
	for row in range(-8, 9):
		for column in range(-8, 9):
			var tile := center + Vector2(column * 58.0, row * 58.0)
			if tile.distance_to(center) > ARENA_RADIUS - 58.0: continue
			var code := hash_cell(column + 47, row + 91)
			draw_rect(Rect2(tile - Vector2(16, 10), Vector2(32, 20)), Color("858478", 0.43))
			if code % 4 == 0: draw_rect(Rect2(tile - Vector2(9, 4), Vector2(12, 4)), Color("dbc89a", 0.53))
			if code % 11 == 0: draw_rect(Rect2(tile + Vector2(11, 9), Vector2(6, 4)), Color("c3a074", 0.45))
	draw_arc(center, 38.0, 0.0, TAU, 32, Color("e1c98f"), 4)
	for i in 8:
		var rune := center + Vector2.RIGHT.rotated(float(i) * TAU / 8.0) * 28.0
		draw_rect(Rect2(rune - Vector2(3, 3), Vector2(6, 6)), Color("a6d7dc") if arena_mode == "final" else Color("f0c783"))

func _trail_theme(region: int) -> int:
	return 1 if region in [3,4,7,10,11,12] else (2 if region in [2,5,9] else (3 if region == 8 else 0))

func draw_trails() -> void:
	# Drei zusammenhängende Pixel-Farbflächen statt vieler gedrehter Texturquadrate.
	# Das vermeidet schwebende Kacheln, harte Kachelenden und unnötige Draw Calls.
	var edge_colors := [Color("665541"), Color("4e4a45"), Color("624d3b"), Color("45414f")]
	var mid_colors := [Color("927453"), Color("77736b"), Color("927555"), Color("716b7b")]
	var road_colors := [Color("b49a6b"), Color("a49b8c"), Color("b69b73"), Color("91899a")]
	for trail_index in TRAILS.size():
		var trail: Array = TRAILS[trail_index]
		var theme_for_trail := 0
		for point_index in trail.size():
			var point: Vector2 = trail[point_index]
			if point_index < trail.size() - 1: theme_for_trail = _trail_theme(region_at(point.lerp(trail[point_index + 1], 0.5)))
			if visible_world(point, 90.0):
				draw_circle(point, 58.0, edge_colors[theme_for_trail])
				draw_circle(point, 52.0, mid_colors[theme_for_trail])
				draw_circle(point, 45.0, road_colors[theme_for_trail])
		for i in range(trail.size() - 1):
			var a: Vector2 = trail[i]
			var b: Vector2 = trail[i + 1]
			if not Rect2(a.min(b) - Vector2(140,140), (b-a).abs() + Vector2(280,280)).intersects(Rect2(camera_pos, VIEW)): continue
			var region := region_at(a.lerp(b, 0.5))
			var theme := _trail_theme(region)
			var direction := (b-a).normalized()
			var side := direction.rotated(PI*0.5)
			var distance := a.distance_to(b)
			var detail_count := maxi(1, int(distance / 132.0))
			var start_detail := trail_index * 73 + i * 11
			# Natursteinrand, verdichteter Untergrund und warme, leicht unregelmäßige Fahrspur.
			draw_line(a, b, edge_colors[theme], 116.0, false)
			draw_line(a, b, mid_colors[theme], 104.0, false)
			draw_line(a, b, road_colors[theme], 90.0, false)
			for detail in range(1, detail_count + 1):
				var t := minf(0.94, float(detail) / float(detail_count + 1))
				var center := a.lerp(b, t)
				if not visible_world(center, 100.0): continue
				var code := hash_cell(trail_index * 17 + i, start_detail + detail)
				# Versetzte Fugen und zwei flache Fahrspuren, in großem Abstand gesetzt.
				if code % 3 != 0:
					draw_line(center - side * 34.0, center + side * 34.0, edge_colors[theme].lightened(0.16), 2.0, false)
				draw_line(center + side * 19.0 - direction * 16.0, center + side * 19.0 + direction * 16.0, mid_colors[theme].darkened(0.12), 2.0, false)
				draw_line(center - side * 19.0 - direction * 16.0, center - side * 19.0 + direction * 16.0, mid_colors[theme].lightened(0.08), 2.0, false)
				if detail % 3 == 0:
					var edge_point := center + side * (59.0 + float(code % 4) * 3.0)
					draw_rect(Rect2(edge_point - Vector2(3,2), Vector2(6,4)), mid_colors[theme].darkened(0.15))
					draw_rect(Rect2(edge_point + side * 6.0 - Vector2(1,1), Vector2(3,2)), road_colors[theme].lightened(0.16))
			if i % 2 == 0:
				var shoulder := a.lerp(b, 0.5) + side * 68.0
				if visible_world(shoulder, 100.0): draw_grass(shoulder)
				var other_shoulder := a.lerp(b, 0.5) - side * 68.0
				if visible_world(other_shoulder, 100.0) and (trail_index + i) % 3 == 0: draw_flower(other_shoulder, trail_index * 31 + i)

func draw_obstacle(obstacle: Dictionary) -> void:
	var p: Vector2 = obstacle["pos"]
	var r: float = obstacle["radius"]
	var zone: int = obstacle["zone"]
	var key: int = obstacle["key"]
	# Einheitlicher, weicher Bodenkontakt statt eingebrannter schwarzer Schatten.
	draw_circle(p + Vector2(3, 20), r * 0.72, Color(0.12, 0.20, 0.19, 0.12))
	match zone:
		1, 2:
			draw_rect(Rect2(p + Vector2(-11, -18), Vector2(22, 48)), Color("715c4c"))
			for offset in [Vector2(-r * 0.45, -37), Vector2(r * 0.42, -36), Vector2(0, -r * 0.9)]:
				draw_circle(p + offset, r * 0.66, Color("4d8070") if zone == 2 else Color("5cae79"))
				draw_circle(p + offset + Vector2(-10, -11), r * 0.34, Color("75b792") if zone == 2 else Color("83ce8a"))
			draw_bush_cluster(p + Vector2(r * 0.55, 8), zone, key)
			if zone == 2: draw_mushroom(p + Vector2(-r * 0.62, -6), key)
		3:
			# Zerbrochene Ruinenwand mit Pfeiler, Moos und lesbarer Steinstruktur.
			draw_rect(Rect2(p + Vector2(-r, -r * 0.35), Vector2(r * 1.75, r * 0.72)), Color("707b74"))
			for brick in 5:
				var bx := -r + 7 + brick * (r * 0.33)
				draw_rect(Rect2(p + Vector2(bx, -r * 0.26 + (brick % 2) * 12), Vector2(r * 0.28, 10)), Color("aeb09f"))
			draw_rect(Rect2(p + Vector2(-r * 0.82, -r * 0.9), Vector2(r * 0.34, r * 1.15)), Color("969d90"))
			draw_rect(Rect2(p + Vector2(-r * 0.91, -r * 0.95), Vector2(r * 0.52, 9)), Color("c7c1a8"))
			draw_rect(Rect2(p + Vector2(r * 0.22, -r * 0.08), Vector2(r * 0.48, 7)), Color("c4bca1"))
			draw_bush_cluster(p + Vector2(r * 0.35, r * 0.34), zone, key)
		4:
			# Kristallmoor: mehrere Facetten auf dunklem Grundstein.
			draw_circle(p + Vector2(0, 11), r * 0.72, Color("5a6b70"))
			for offset in [Vector2(-r * 0.46, 0), Vector2(r * 0.22, -14), Vector2(3, -r * 0.58)]:
				draw_crystal(p + offset, key + int(offset.x))
		5:
			draw_circle(p, r, Color("504247"))
			draw_colored_polygon(PackedVector2Array([p + Vector2(-r, 20), p + Vector2(-r * 0.45, -r * 0.8), p + Vector2(r * 0.35, -r), p + Vector2(r, 15)]), Color("795552"))
			for crack in [-0.45, 0.05, 0.42]:
				draw_line(p + Vector2(r * crack, -r * 0.4), p + Vector2(r * (crack + 0.18), r * 0.35), Color("f0a066"), 5)
		6:
			draw_circle(p, r, Color("bda579"))
			draw_circle(p + Vector2(-10, -12), r * 0.63, Color("ddc596"))
			draw_shell(p + Vector2(r * 0.2, 0))
			draw_line(p + Vector2(-r * 0.6, 18), p + Vector2(r * 0.7, -11), Color("7d624d"), 6)
		7:
			draw_circle(p, r, Color("514e61"))
			for i in 4:
				var shard := p + Vector2.RIGHT.rotated(i * TAU / 4.0) * r * 0.48
				draw_colored_polygon(PackedVector2Array([shard + Vector2(0,-28),shard + Vector2(10,5),shard + Vector2(-9,8)]), Color("c3b2e4"))
		8:
			draw_bush_cluster(p, zone, key)
			for twig in [-1.0, 1.0]: draw_line(p + Vector2(twig * 12, 9), p + Vector2(twig * 24, -22), Color("6c6256"), 5)
		9:
			draw_rect(Rect2(p + Vector2(-r * 0.78, -r * 0.28), Vector2(r * 1.55, r * 0.58)), Color("8e744b"))
			for drip in 4: draw_rect(Rect2(p + Vector2(-r * 0.55 + drip * 18, -r * 0.34 + drip % 2 * 5), Vector2(8, 14)), Color("d8ad4f"))
			draw_bush_cluster(p + Vector2(0, r * 0.32), zone, key)
		10:
			draw_circle(p, r, Color("5d777a"))
			for i in 5:
				var ray := Vector2.RIGHT.rotated(i * TAU / 5.0)
				draw_line(p + ray * 8, p + ray * r * 0.72, Color("a7d9d7"), 5)
			draw_circle(p, r * 0.25, Color("d9f1e8"))
		11:
			draw_colored_polygon(PackedVector2Array([p + Vector2(-r, 17), p + Vector2(-r * 0.45, -r), p + Vector2(r * 0.25, -r * 0.78), p + Vector2(r, 21)]), Color("5d5f72"))
			for ridge in 3: draw_line(p + Vector2(-r * 0.45 + ridge * r * 0.35, -r * 0.5), p + Vector2(-r * 0.2 + ridge * r * 0.35, 12), Color("a6a7b7"), 4)
		12:
			draw_circle(p, r, Color("675f78"))
			for i in 6:
				var shard := p + Vector2.RIGHT.rotated(i * TAU / 6.0) * r * 0.5
				draw_colored_polygon(PackedVector2Array([shard + Vector2(0,-24),shard + Vector2(8,5),shard + Vector2(-8,6)]), Color("d6c8ed"))
			draw_circle(p, 8, Color("fff1bb"))
		_:
			draw_circle(p, r, Color("53666c"))

func region_rect(id: int) -> Rect2:
	if id >= 8: return Rect2(11000, (id - 8) * 1920, 5000, 1920)
	match id:
		0: return Rect2(0, 0, 1780, 2600)
		1: return Rect2(1780, 0, 3220, 4200)
		2: return Rect2(1780, 4200, 3220, 4300)
		3: return Rect2(5000, 0, 3500, 4200)
		4: return Rect2(5000, 4200, 3500, 4300)
		5: return Rect2(8500, 0, 2500, 4200)
		6: return Rect2(0, 2600, 1780, 5900)
		_: return Rect2(8500, 4200, 2500, 4300)

func draw_region_gates() -> void:
	draw_line(Vector2(11070, 0), Vector2(11070, 9600), Color("536c70"), 145)
	draw_line(Vector2(11070, 0), Vector2(11070, 9600), Color("8da8a2"), 13)
	for border in [1920, 3840, 5760, 7680]:
		for segment in 25:
			var x := 11000.0 + segment * 200.0
			var next_x := x + 200.0
			var y: float = float(border) + sin(x / 350.0) * 21.0 + sin(x / 97.0) * 8.0
			var next_y: float = float(border) + sin(next_x / 350.0) * 21.0 + sin(next_x / 97.0) * 8.0
			draw_line(Vector2(x, y), Vector2(next_x, next_y), Color("52616e"), 111)
			draw_line(Vector2(x, y - 20.0), Vector2(next_x, next_y - 20.0), Color("a6b6ac", 0.6), 9)
	draw_gate_wall(Vector2(1780, 0), Vector2(1780, 2600), Vector2(1780, 1120), 1)
	draw_gate_wall(Vector2(1780, 2600), Vector2(1780, 8500), Vector2(1780, 6200), 8)
	draw_gate_wall(Vector2(0, 2600), Vector2(1780, 2600), Vector2(875, 2600), 5)
	draw_gate_wall(Vector2(1780, 4200), Vector2(5000, 4200), Vector2(2900, 4200), 8)
	draw_gate_wall(Vector2(5000, 0), Vector2(5000, 4200), Vector2(5000, 1250), 15)
	draw_gate_wall(Vector2(5000, 4200), Vector2(5000, 8500), Vector2(5000, 6200), 22, 0)
	draw_gate_wall(Vector2(5000, 4200), Vector2(8500, 4200), Vector2(6600, 4200), 22, 0)
	draw_gate_wall(Vector2(8500, 0), Vector2(8500, 4200), Vector2(8500, 1900), 29, 1)
	draw_gate_wall(Vector2(8500, 4200), Vector2(8500, 8500), Vector2(8500, 6350), 36, 1)
	draw_gate_wall(Vector2(8500, 4200), Vector2(11000, 4200), Vector2(9750, 4200), 36)

func draw_gate_wall(start: Vector2, finish: Vector2, gate: Vector2, required_level: int, boss_index: int = -1) -> void:
	var vertical := is_equal_approx(start.x, finish.x)
	var first := start.y if vertical else start.x
	var last := finish.y if vertical else finish.x
	var gap := gate.y if vertical else gate.x
	var dark := Color('3e4a4e')
	var mid := Color('65756f')
	var top := Color('98a297')
	var moss := Color('5f8b6d')
	var thickness := 82.0
	for part_value in [Vector2(first, gap-GATE_HALF_WIDTH), Vector2(gap+GATE_HALF_WIDTH,last)]:
		var part: Vector2 = part_value
		var length: float = part.y - part.x
		if length <= 0.0: continue
		var face := Rect2(start.x-thickness*0.5, part.x, thickness, length) if vertical else Rect2(part.x,start.y-thickness*0.5,length,thickness)
		if not face.grow(90).intersects(Rect2(camera_pos,VIEW)): continue
		draw_rect(face, dark)
		# breite sichtbare Oberseite + Vorderkante statt dünner Linie
		var crown := Rect2(face.position + (Vector2(8,0) if vertical else Vector2(0,8)), face.size - (Vector2(16,0) if vertical else Vector2(0,16)))
		draw_rect(crown, mid)
		var lip := Rect2(face.position + (Vector2(5,0) if vertical else Vector2(0,5)), Vector2(face.size.x-10,13) if vertical else Vector2(13,face.size.y-10))
		draw_rect(lip, top)
		# Die Textur liegt lückenlos über die komplette sichtbare Mauerbreite.
		var tile_count := ceili(length / 32.0)
		for tile_i in range(tile_count):
			var axis_tile: float = part.x + float(tile_i) * 32.0
			# 3 ganzzahlige Pixelstreifen decken 84 px Mauer ab (82 px Grundfläche).
			var strip := 28.0
			for band in 3:
				if vertical:
					draw_structure_tile((tile_i + band + required_level) % 4, Vector2(start.x - thickness * 0.5 + band * strip, axis_tile), strip)
				else:
					draw_structure_tile(4 + ((tile_i + band) % 4), Vector2(axis_tile, start.y - thickness * 0.5 + band * strip), strip)
		var blocks := ceili(length/46.0)
		for step in range(blocks+1):
			var axis := minf(part.y-4, part.x+float(step)*46.0)
			if vertical:
				draw_line(Vector2(start.x-thickness*.37,axis),Vector2(start.x+thickness*.37,axis),Color('4d5b59'),3)
			else:
				draw_line(Vector2(axis,start.y-thickness*.37),Vector2(axis,start.y+thickness*.37),Color('4d5b59'),3)
			if step % 3 == 0:
				var mp := Vector2(start.x+thickness*.25,axis+7) if vertical else Vector2(axis+7,start.y+thickness*.25)
				draw_rect(Rect2(mp-Vector2(5,3),Vector2(10,6)),moss)
	# massives Tor mit Säulen
	for side in [-1.0,1.0]:
		var post := gate + (Vector2(0,side*GATE_HALF_WIDTH) if vertical else Vector2(side*GATE_HALF_WIDTH,0))
		draw_rect(Rect2(post-Vector2(39,39),Vector2(78,78)),dark)
		draw_rect(Rect2(post-Vector2(30,30),Vector2(60,60)),mid)
		draw_rect(Rect2(post-Vector2(24,28),Vector2(48,13)),top)
		draw_rect(Rect2(post+Vector2(-9,8),Vector2(18,14)),Color('d8bb74'))
	var level_locked := level < required_level
	var boss_locked: bool = boss_index >= 0 and not bosses_defeated[boss_index]
	if level_locked or boss_locked:
		var seal := Rect2(gate + (Vector2(-26,-GATE_HALF_WIDTH+39) if vertical else Vector2(-GATE_HALF_WIDTH+39,-26)), Vector2(52,GATE_HALF_WIDTH*2-78) if vertical else Vector2(GATE_HALF_WIDTH*2-78,52))
		draw_rect(seal,Color('6e405b',0.94))
		draw_rect(seal.grow(-7),Color('b66486',0.84),false,4)
		text_at(gate+Vector2(-105,-52), "AB LEVEL %d" % required_level if level_locked else "BOSS-SIEG NÖTIG",16,Color('fff0bc'))
	else:
		text_at(gate+Vector2(-85,-52),"DURCHGANG",14,Color('fff0bc'))

func draw_grass(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(1, 8), Vector2(3, 8)), Color('5f9d67'))
	draw_rect(Rect2(p + Vector2(6, 4), Vector2(3, 12)), Color('72b670'))
	draw_rect(Rect2(p + Vector2(10, 7), Vector2(4, 10)), Color('80bf73'))
	draw_rect(Rect2(p + Vector2(15, 3), Vector2(3, 12)), Color('69ab67'))
	draw_rect(Rect2(p + Vector2(18, 9), Vector2(2, 7)), Color('8cca7b'))

func draw_flower(p: Vector2, key: int) -> void:
	var petals: Color = [Color('fff3a6'), Color('f5a4b9'), Color('c8b2f2'), Color('e8f5e6')][key % 4]
	draw_rect(Rect2(p + Vector2(9, 10), Vector2(3, 10)), Color('569a60'))
	for offset in [Vector2(-6, 0), Vector2(6, 0), Vector2(0, -6), Vector2(0, 6), Vector2(-4, -4), Vector2(4, 4)]:
		draw_rect(Rect2(p + Vector2(8, 7) + offset, Vector2(4, 4)), petals)
	draw_rect(Rect2(p + Vector2(8, 7), Vector2(5, 5)), Color('eec06e'))
	draw_rect(Rect2(p + Vector2(9, 9), Vector2(3, 3)), Color('fff7d0'))

func draw_bush_cluster(p: Vector2, zone: int, key: int) -> void:
	var leaf := Color("559668")
	if zone in [2, 8]: leaf = Color("486f68")
	elif zone in [3, 11]: leaf = Color("73876f")
	elif zone in [4, 10, 12]: leaf = Color("5a9791")
	elif zone == 5: leaf = Color("795f58")
	elif zone == 9: leaf = Color("9a8b53")
	var spread := 15 + key % 8
	for i in 5:
		var off := Vector2((i % 3 - 1) * spread, (i / 3) * 10 - 8 + (key + i * 5) % 5)
		draw_circle(p + off, 12 + (key + i) % 5, leaf.darkened(0.08 if i % 2 == 0 else 0.0))
		draw_rect(Rect2(p + off + Vector2(-6, -8), Vector2(7, 4)), leaf.lightened(0.18))
	if zone in [1, 9, 12] and key % 3 == 0:
		for berry in 4:
			var b := p + Vector2(-16 + berry * 11, -6 + (berry % 2) * 10)
			draw_rect(Rect2(b, Vector2(4, 4)), Color("e7aa79") if zone != 12 else Color("d4c4ff"))

func draw_tree(p: Vector2, zone: int) -> void:
	var seed := int(p.x * 0.17 + p.y * 0.11)
	var leaf := Color('5da875')
	var bark := Color('705a4e')
	if zone == 2:
		leaf = Color('477d72')
		bark = Color('65534b')
	elif zone == 3:
		leaf = Color('8ba376')
		bark = Color('736457')
	elif zone == 4:
		leaf = Color('58a6a8')
		bark = Color('5a605e')
	var crown := seed % 3
	draw_rect(Rect2(p + Vector2(18, 19), Vector2(11, 37)), bark)
	draw_rect(Rect2(p + Vector2(10, 51), Vector2(28, 7)), Color(0.2, 0.35, 0.3, 0.16))
	if crown == 0:
		draw_rect(Rect2(p + Vector2(2, -12), Vector2(46, 24)), leaf.darkened(0.08))
		draw_rect(Rect2(p + Vector2(-4, 5), Vector2(58, 21)), leaf)
		draw_rect(Rect2(p + Vector2(8, -22), Vector2(34, 17)), leaf.lightened(0.12))
		draw_rect(Rect2(p + Vector2(12, -3), Vector2(10, 7)), leaf.lightened(0.24))
	elif crown == 1:
		draw_rect(Rect2(p + Vector2(3, -7), Vector2(43, 43)), leaf.darkened(0.06))
		draw_rect(Rect2(p + Vector2(-5, 6), Vector2(57, 19)), leaf)
		draw_rect(Rect2(p + Vector2(12, -20), Vector2(25, 16)), leaf.lightened(0.16))
		draw_rect(Rect2(p + Vector2(26, -6), Vector2(9, 8)), leaf.lightened(0.24))
	else:
		draw_rect(Rect2(p + Vector2(4, -10), Vector2(18, 25)), leaf.darkened(0.1))
		draw_rect(Rect2(p + Vector2(24, -10), Vector2(18, 25)), leaf.darkened(0.1))
		draw_rect(Rect2(p + Vector2(-1, 7), Vector2(50, 20)), leaf)
		draw_rect(Rect2(p + Vector2(11, -20), Vector2(30, 16)), leaf.lightened(0.14))
	for sparkle in 3:
		var px := 5 + ((seed + sparkle * 9) % 30)
		var py := -8 + ((seed / 3 + sparkle * 11) % 20)
		draw_rect(Rect2(p + Vector2(px, py), Vector2(3, 3)), leaf.lightened(0.28))

func draw_mushroom(p: Vector2, key: int) -> void:
	draw_rect(Rect2(p + Vector2(15, 13), Vector2(11, 20)), Color('eee3c7'))
	var cap := Color('d4809d') if key % 2 == 0 else Color('eab477')
	draw_rect(Rect2(p + Vector2(5, 5), Vector2(31, 12)), cap.darkened(0.08))
	draw_rect(Rect2(p + Vector2(10, -1), Vector2(21, 10)), cap)
	for spot in [Vector2(13, 4), Vector2(20, 2), Vector2(25, 8)]:
		draw_rect(Rect2(p + spot, Vector2(4, 3)), Color('ffefdd'))

func draw_ruin(p: Vector2, key: int) -> void:
	var style := key % 4
	draw_rect(Rect2(p + Vector2(4, 31), Vector2(46, 8)), Color('8b8578'))
	if style == 0:
		draw_rect(Rect2(p + Vector2(7, 10), Vector2(40, 25)), Color('8f988e'))
		draw_rect(Rect2(p + Vector2(13, 1), Vector2(28, 24)), Color('b5b4a1'))
		draw_rect(Rect2(p + Vector2(18, 8), Vector2(5, 22)), Color('d9d1b4'))
		draw_rect(Rect2(p + Vector2(27, 8), Vector2(5, 22)), Color('7a8c83'))
	elif style == 1:
		draw_rect(Rect2(p + Vector2(7, 4), Vector2(12, 31)), Color('b7b39c'))
		draw_rect(Rect2(p + Vector2(31, 7), Vector2(11, 28)), Color('b0b1a1'))
		draw_rect(Rect2(p + Vector2(10, 19), Vector2(30, 4)), Color('dad0b0'))
	elif style == 2:
		draw_rect(Rect2(p + Vector2(8, 8), Vector2(34, 26)), Color('97a096'))
		draw_rect(Rect2(p + Vector2(13, 12), Vector2(8, 18)), Color('d5ceb0'))
		draw_rect(Rect2(p + Vector2(28, 12), Vector2(8, 18)), Color('d5ceb0'))
		draw_rect(Rect2(p + Vector2(18, 3), Vector2(13, 9)), Color('c3c19d'))
	else:
		draw_rect(Rect2(p + Vector2(9, 5), Vector2(30, 30)), Color('9a9f97'))
		draw_rect(Rect2(p + Vector2(5, 15), Vector2(39, 4)), Color('d7cfb5'))
		draw_rect(Rect2(p + Vector2(20, 0), Vector2(6, 31)), Color('78887d'))
	if key % 2 == 0: draw_rect(Rect2(p + Vector2(37, 26), Vector2(8, 5)), Color('607e66'))

func draw_crystal(p: Vector2, key: int) -> void:
	var c := Color('92ddea') if key % 2 == 0 else Color('c1a2ed')
	var c2 := c.lightened(0.3)
	draw_colored_polygon(PackedVector2Array([p + Vector2(20, -18), p + Vector2(35, 7), p + Vector2(18, 31), p + Vector2(3, 7)]), c)
	draw_colored_polygon(PackedVector2Array([p + Vector2(8, 6), p + Vector2(18, -9), p + Vector2(25, 10), p + Vector2(13, 24)]), c2)
	if key % 3 == 0: draw_colored_polygon(PackedVector2Array([p + Vector2(30, -4), p + Vector2(40, 10), p + Vector2(32, 25), p + Vector2(24, 10)]), c.darkened(0.08))
	draw_rect(Rect2(p + Vector2(15, -4), Vector2(5, 25)), Color('eefcff', 0.85))
	draw_rect(Rect2(p + Vector2(10, 25), Vector2(24, 6)), c.darkened(0.34))

func draw_lava(p: Vector2) -> void:
	draw_rect(Rect2(p, Vector2(52, 18)), Color('66433f'))
	draw_rect(Rect2(p + Vector2(4, 5), Vector2(39, 8)), Color('f19b5c'))
	draw_rect(Rect2(p + Vector2(16, 8), Vector2(14, 5)), Color('f4d079'))
	draw_rect(Rect2(p + Vector2(33, 6), Vector2(8, 4)), Color('ffcf88'))

func draw_rock(p: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([p + Vector2(2, 24), p + Vector2(15, 6), p + Vector2(31, 0), p + Vector2(45, 11), p + Vector2(47, 28), p + Vector2(19, 30)]), Color('6c6a6f'))
	draw_colored_polygon(PackedVector2Array([p + Vector2(15, 8), p + Vector2(29, 3), p + Vector2(36, 16), p + Vector2(22, 18)]), Color('97908a'))
	draw_rect(Rect2(p + Vector2(12, 19), Vector2(15, 4)), Color('b4a99a'))

func draw_pebbles(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(1, 10), Vector2(8, 4)), Color(0.40, 0.45, 0.42, 0.30))
	draw_rect(Rect2(p + Vector2(12, 18), Vector2(5, 3)), Color(0.46, 0.49, 0.44, 0.22))
	draw_rect(Rect2(p + Vector2(27, 23), Vector2(5, 4)), Color(0.4, 0.45, 0.42, 0.22))
	draw_rect(Rect2(p + Vector2(34, 8), Vector2(4, 3)), Color(0.58, 0.58, 0.53, 0.18))

func draw_wave(p: Vector2, key: int) -> void:
	draw_rect(Rect2(p + Vector2(2, 8), Vector2(26, 3)), Color('bce1e4', 0.55))
	draw_rect(Rect2(p + Vector2(9, 13), Vector2(20, 3)), Color('def3f2', 0.42))
	if key % 2 == 0: draw_rect(Rect2(p + Vector2(22, 6), Vector2(14, 3)), Color('d7ece4', 0.5))

func draw_shell(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(10, 12), Vector2(12, 9)), Color('f9ebd1'))
	draw_rect(Rect2(p + Vector2(12, 7), Vector2(8, 5)), Color('eebfad'))
	draw_rect(Rect2(p + Vector2(14, 14), Vector2(4, 4)), Color('fff7e8'))

func draw_village() -> void:
	if not Rect2(0, 0, 1780, 2600).intersects(Rect2(camera_pos, VIEW)): return
	# Handgezeichnete Pflasterkacheln bilden den Dorfplatz.
	draw_rect(Rect2(670, 780, 454, 444), Color("806a52"))
	for column in 9:
		for row in 9:
			var code := hash_cell(column + 80, row + 60)
			draw_pixel_tile(3 if code % 4 == 0 else 2, Vector2(681 + column * 48, 790 + row * 48))
	# Am Spawn: Steinrose, Himmelsrichtungen, ein kleines Willkommensschild.
	var arrival := Vector2(900, 1050)
	draw_circle(arrival, 78, Color("7f897c"))
	draw_circle(arrival, 70, Color("ead5a0"))
	draw_circle(arrival, 58, Color("aec4af"))
	for spoke in 8:
		var ray := Vector2.RIGHT.rotated(float(spoke) * TAU / 8.0)
		draw_line(arrival + ray * 23, arrival + ray * 54, Color("658e8a"), 5)
		draw_rect(Rect2(arrival + ray * 60 - Vector2(4, 4), Vector2(8, 8)), Color("f7e8bb"))
	draw_colored_polygon(PackedVector2Array([arrival + Vector2(0,-30),arrival + Vector2(14,0),arrival + Vector2(0,30),arrival + Vector2(-14,0)]), Color("487c79"))
	draw_rect(Rect2(arrival + Vector2(-33, -108), Vector2(66, 7)), Color("735b49"))
	text_at(arrival + Vector2(-94, -125), "WILLKOMMEN", 15, Color("385653"), HORIZONTAL_ALIGNMENT_CENTER, 188)
	for flower in 12:
		var petal := arrival + Vector2.RIGHT.rotated(float(flower) * TAU / 12.0) * 108
		draw_flower(petal, flower)
	# Kleine Verkaufsstände und Wäscheleinen geben den Gebäuden einen Zweck.
	for stall in [Vector2(425, 820), Vector2(1190, 710), Vector2(1340, 1280)]:
		draw_rect(Rect2(stall, Vector2(126, 13)), Color("795a46"))
		for post in [0, 116]: draw_rect(Rect2(stall + Vector2(post, -42), Vector2(9, 47)), Color("695648"))
		for stripe in 5:
			draw_rect(Rect2(stall + Vector2(stripe * 25, -52), Vector2(25, 16)), Color("e6ae79") if stripe % 2 == 0 else Color("fff0c1"))
		for basket in 4: draw_circle(stall + Vector2(18 + basket * 27, -7), 6, Color("a7bb72") if basket % 2 == 0 else Color("e1aa69"))
	for lantern in [Vector2(760, 705), Vector2(1055, 675), Vector2(625, 1150), Vector2(1250, 1160)]:
		draw_rect(Rect2(lantern, Vector2(8, 75)), Color("71584c"))
		draw_rect(Rect2(lantern + Vector2(-7, -11), Vector2(23, 20)), Color("625251"))
		draw_rect(Rect2(lantern + Vector2(-2, -7), Vector2(12, 12)), Color("f7d48c"))
		draw_circle(lantern + Vector2(4, 0), 19, Color(0.98, 0.80, 0.43, 0.11 + sin(world_time * 2.0) * 0.025))
	for i in 9:
		var x := 600 + i * 110
		for y in [580, 1370, 1900]:
			draw_rect(Rect2(x, y, 8, 28), Color("c5a977"))
			draw_rect(Rect2(x, y + 9, 90, 7), Color("dec58d"))
	for p in [Vector2(360, 1190), Vector2(1290, 1200), Vector2(390, 1830), Vector2(1260, 1980)]:
		draw_rect(Rect2(p, Vector2(150, 90)), Color("806e57"))
		for i in 5:
			draw_flower(p + Vector2(12 + i * 27, 25), i * 7)
	for h in house_positions():
		if visible_world(h, 200): draw_house(h)
	if visible_world(TAVERN_HOUSE, 200):
		text_at(TAVERN_HOUSE + Vector2(-75, -43), "ZUR STEINROSE · TAVERNE", 15, Color("fff0bd"), HORIZONTAL_ALIGNMENT_CENTER, 330)
		text_at(TAVERN_HOUSE + Vector2(12, 185), "E · EINTRETEN", 13, Color("fff2cd"), HORIZONTAL_ALIGNMENT_CENTER, 160)
	# Brunnen mit Wasser und Steinrand.
	draw_rect(Rect2(890, 860, 105, 95), Color("9eaaa2"))
	draw_rect(Rect2(900, 870, 85, 75), Color("77c8d7"))
	draw_rect(Rect2(925, 884, 29, 8), Color("c6eff0"))
	for p in [Vector2(685, 850), Vector2(1110, 900), Vector2(700, 1200), Vector2(1130, 1220)]:
		draw_rect(Rect2(p, Vector2(7, 38)), Color("6b5d52"))
		draw_rect(Rect2(p + Vector2(-8, -11), Vector2(23, 14)), Color("f4d58c"))
		for i in 2: draw_rect(Rect2(p + Vector2(-4 + i * 9, -6), Vector2(5, 5)), Color("fff3be"))
	if final_completed:
		for index in 10:
			var angle := TAU * float(index) / 10.0
			var citizen := arrival + Vector2(cos(angle) * 185, sin(angle) * 150)
			var coat: Color = [Color("9bc1a2"), Color("c8a1ad"), Color("95b8ca"), Color("e1bc87")][index % 4]
			draw_rect(Rect2(citizen + Vector2(-7, -18), Vector2(14, 22)), coat)
			draw_circle(citizen + Vector2(0, -24), 7, Color("eed0a3"))
			draw_line(citizen + Vector2(-6, -14), citizen + Vector2(-14, -27 - sin(world_time * 5 + index) * 6), coat.lightened(0.26), 3)
			draw_line(citizen + Vector2(6, -14), citizen + Vector2(14, -27 + sin(world_time * 5 + index) * 6), coat.lightened(0.26), 3)
			var spark := citizen + Vector2(12, -51 + fmod(world_time * 21 + index * 9, 46))
			draw_rect(Rect2(spark, Vector2(5, 5)), Color("f9e09d") if index % 2 == 0 else Color("b9e8d5"))
		for x in [710, 870, 1030]:
			draw_line(Vector2(x, 745), Vector2(x + 70, 745), Color("d2a96c"), 3)
			draw_colored_polygon(PackedVector2Array([Vector2(x + 18, 745), Vector2(x + 29, 768), Vector2(x + 40, 745)]), Color("edbd85"))
			draw_colored_polygon(PackedVector2Array([Vector2(x + 47, 745), Vector2(x + 58, 768), Vector2(x + 69, 745)]), Color("94c8b9"))
	text_at(Vector2(850, 750), "SONNENHAIN", 24, Color("415d55"), HORIZONTAL_ALIGNMENT_CENTER, 280)

func draw_house(p: Vector2) -> void:
	if house_tiles == null: return
	var design := posmod(int(p.x / 40.0) + int(p.y / 70.0), 4)
	var is_tavern := p == TAVERN_HOUSE
	var source := Rect2(Vector2(design * 192, 0), Vector2(192, 160))
	draw_texture_rect_region(house_tiles, Rect2(p + Vector2(-4, -2), Vector2(192, 160)), source)
	if is_tavern:
		for x in [3, 166]: draw_pixel_tile(29, p + Vector2(x, 110), 24.0)
		draw_rect(Rect2(p + Vector2(24, 37), Vector2(136, 20)), Color("493b36"))
		draw_rect(Rect2(p + Vector2(31, 41), Vector2(122, 12)), Color("725445"))
		text_at(p + Vector2(34, 52), "STEINROSE", 12, Color("ffe2a0"), HORIZONTAL_ALIGNMENT_CENTER, 116)

func draw_npc(npc: Dictionary) -> void:
	var p: Vector2 = npc["pos"]
	var kind: String = str(npc["kind"])
	var name: String = str(npc["name"])
	draw_npc_sprite(p,kind,name)
	var caption := name if kind == "quest" else "%s (%s)" % [name,npc["role"]]
	text_at(p + Vector2(-116,-47),caption,16,Color("ffebbb") if interior_id >= 0 else Color("253e3c"),HORIZONTAL_ALIGNMENT_CENTER,232)
	if kind == "quest":
		var marker_state := quest_marker_state(name)
		if marker_state != 0:
			var marker := "!" if marker_state == 1 else "?"
			var marker_color := Color("f6ce65") if marker_state in [1,3] else Color("a9b1ad")
			text_at(p + Vector2(-15,-77),marker,34,marker_color,HORIZONTAL_ALIGNMENT_CENTER,34)
			if marker_state == 2: text_at(p + Vector2(-62,-95),"OFFEN",11,Color("d2d8d1"),HORIZONTAL_ALIGNMENT_CENTER,124)
			elif marker_state == 3: text_at(p + Vector2(-72,-95),"ABGEBEN",11,Color("ffe18a"),HORIZONTAL_ALIGNMENT_CENTER,144)
	elif kind == "rescued" and rescue_state == 2:
		text_at(p + Vector2(-13,-69),"!",30,Color("f6ce65"),HORIZONTAL_ALIGNMENT_CENTER,30)

func draw_event_scene(index: int) -> void:
	var event: Dictionary = WORLD_EVENTS[index]
	var p: Vector2 = event["pos"]
	var state: int = int(event_states[index])
	# Kleine Reisestationen ändern sich nach der Rettung sichtbar.
	draw_rect(Rect2(p + Vector2(-74, 38), Vector2(147, 10)), Color("816b50"))
	for offset in [Vector2(-75, -34), Vector2(73, -34)]:
		draw_rect(Rect2(p + offset, Vector2(8, 75)), Color("685749"))
		draw_rect(Rect2(p + offset + Vector2(-4, -10), Vector2(16, 12)), Color("f1d093"))
	var flag: Color = Color("84c596") if state >= 2 else Color("dd876c")
	draw_colored_polygon(PackedVector2Array([p + Vector2(-70,-34), p + Vector2(0,-77), p + Vector2(70,-34)]), flag)
	draw_rect(Rect2(p + Vector2(-54, 27), Vector2(28, 18)), Color("936f4e"))
	draw_rect(Rect2(p + Vector2(35, 23), Vector2(23, 20)), Color("937a5a"))
	for fire in 4:
		var ember := p + Vector2(-65 + fire * 42, 55 + sin(world_time * 2 + fire) * 2)
		draw_rect(Rect2(ember, Vector2(4, 4)), Color("f4d592") if state >= 2 else Color("c77e69"))
	draw_npc({"name":event["name"], "role":event["role"], "pos":p, "color":Color("8d9cb4") if index % 2 == 0 else Color("bd9d7d"), "kind":"event"})
	var marker := "!" if state == 0 else ("?" if state == 2 else ("%d/%d" % [event_progress[index], event["goal"]] if state == 1 else "✓"))
	text_at(p + Vector2(-36,-88), marker, 23, Color("ffd977") if state in [0,2] else Color("d3eacb"), HORIZONTAL_ALIGNMENT_CENTER, 72)

func quest_marker_state(npc_name: String) -> int:
	# WoW-artige Marker: 1 = neue Quest, 2 = angenommen/läuft, 3 = abgabebereit.
	var has_active := false
	var has_available := false
	for i in QUESTS.size():
		if String(QUESTS[i]["npc"]) != npc_name: continue
		var state := int(quests[i]["state"])
		if state == 2: return 3
		if state == 1: has_active = true
		elif state == 0 and level + 3 >= region_level(int(ENEMY_TYPES[int(QUESTS[i]["target"])]["region"])): has_available = true
	if has_active: return 2
	if has_available: return 1
	return 0

func draw_directional_mob_sprite(enemy: Dictionary, p: Vector2, scale_factor: float = 1.0) -> bool:
	var type: int = int(enemy["type"])
	if type < 0 or type >= ENEMY_TYPES.size():
		return false
	var info: Dictionary = ENEMY_TYPES[type]
	var data := info.get("mob_data", null) as MobData
	if data == null or not data.supports_directions or data.directional_sprite == null:
		return false
	var direction := MobAnimation.direction_index(enemy.get("facing", Vector2.DOWN))
	var frame := MobAnimation.frame_for(data, enemy)
	var frame_size := Vector2(float(data.frame_size.x), float(data.frame_size.y))
	var source := Rect2(Vector2(frame * data.frame_size.x, direction * data.frame_size.y), frame_size)
	var size := Vector2(70, 70) * scale_factor
	draw_texture_rect_region(data.directional_sprite, Rect2(p - size * 0.5 + Vector2(0, -14 * scale_factor), size), source)
	return true

func draw_enemy(enemy: Dictionary) -> void:
	var p: Vector2 = enemy["pos"]
	var type: int = int(enemy["type"])
	var elite_kind: int = int(enemy.get("elite", 0))
	var mob_data := ENEMY_TYPES[type].get("mob_data", null) as MobData
	var boss := mob_data != null and mob_data.boss
	var bob := sin(world_time * (3.1 if type != 0 else 5.4) + float(enemy.get("seed",0.0))) * (4.0 if type in [0,5,7,11,18,22,25] else 2.0)
	var scale_factor := 1.38 if boss else (1.42 if elite_kind == 2 else (1.22 if elite_kind == 1 else 1.0))
	# Keine schwarzen Balken unter Gegnern: die Silhouette endet mit ihren eigenen Füßen.
	if elite_kind > 0:
		var aura := Color('f4d485',0.65) if elite_kind == 2 else Color('d99ce7',0.55)
		draw_arc(p + Vector2(0,4), 32*scale_factor, 0, TAU, 24, aura, 3)
	# Fernangriffe und schwere Nahkampfangriffe werden vor dem Treffer sichtbar angekündigt.
	var shot_left := float(enemy.get("shot", 9.0))
	if mob_data != null and mob_data.ranged and shot_left < 0.55:
		var aim_color := Color('c9a5f1',0.7) if type not in [11,13,22] else Color('a6e9f4',0.75)
		draw_arc(p, 38*scale_factor, 0, TAU, 28, aim_color, 4)
		draw_line(p, player_pos, Color(aim_color,0.22), 2)
	elif mob_data != null and mob_data.heavy_melee and float(enemy.get("hit",0.0)) < 0.22:
		draw_arc(p + Vector2(0,8), 42*scale_factor, 0, TAU, 24, Color('f2b07b',0.45), 4)
	var enemy_color: Color = ENEMY_TYPES[type]["color"]
	var model_pos := p + Vector2(0.0, bob)
	var stride := sin(world_time * 7.0 + float(enemy.get("seed", 0.0))) * 3.0
	var drew_directional := draw_directional_mob_sprite(enemy, model_pos, scale_factor)
	if not drew_directional:
		if boss:
			draw_boss_model(type, model_pos, enemy_color, stride)
		else:
			draw_enemy_model(type, model_pos, enemy_color, stride)
	if float(enemy.get("flash", 0.0)) > 0.0:
		draw_arc(model_pos, 37.0 * scale_factor, 0.0, TAU, 18, Color("fff7df", 0.72), 3.0)
	draw_enemy_level(p, type, boss, elite_kind)
	var fraction := clampf(float(enemy["hp"]) / float(enemy["max_hp"]), 0.0, 1.0)
	if boss:
		draw_rect(Rect2(p + Vector2(-53,-106),Vector2(106,9)),Color('382f35'))
		draw_rect(Rect2(p + Vector2(-51,-104),Vector2(102*fraction,5)),Color('f3a07e'))
	elif fraction < 1.0:
		draw_rect(Rect2(p + Vector2(-27,-55),Vector2(54,6)),Color('453f4b'))
		draw_rect(Rect2(p + Vector2(-26,-54),Vector2(52*fraction,4)),Color('f47d80'))

func draw_enemy_level(p: Vector2, type: int, boss: bool, elite_kind: int = 0) -> void:
	var y := -139.0 if boss else (-103.0 if elite_kind > 0 else -82.0)
	var level_text := "BOSS · LV %d" % enemy_level(type) if boss else ("CHAMPION · LV %d" % enemy_level(type) if elite_kind == 2 else ("ELITE · LV %d" % enemy_level(type) if elite_kind == 1 else "LV %d" % enemy_level(type)))
	var width := 134.0 if elite_kind == 2 else (108.0 if boss or elite_kind == 1 else 54.0)
	var bg := Rect2(p + Vector2(-width * 0.5, y), Vector2(width, 20))
	draw_rect(bg, Color("222b32", 0.92))
	draw_rect(bg, Color("e6b978") if boss or elite_kind == 2 else (Color("d69ae3") if elite_kind == 1 else (Color("d87878") if enemy_level(type) > level + 3 else Color("97be9d"))), false, 2)
	text_at(bg.position + Vector2(2, 15), level_text, 12, Color("fff1d2"), HORIZONTAL_ALIGNMENT_CENTER, int(width - 4))

func draw_enemy_model(type: int, p: Vector2, c: Color, stride: float) -> void:
	match type:
		0: # Schleim: gallertiger Körper mit Kern und Spritzrand.
			draw_circle(p + Vector2(0, 5), 27, c.darkened(0.32))
			draw_circle(p + Vector2(0, -6 + stride * 0.12), 23, c)
			draw_circle(p + Vector2(-7, -15), 7, c.lightened(0.42))
			draw_circle(p + Vector2(8, -10), 4, c.lightened(0.28))
			draw_rect(Rect2(p + Vector2(-10, -5), Vector2(5, 8)), INK)
			draw_rect(Rect2(p + Vector2(6, -5), Vector2(5, 8)), INK)
			draw_rect(Rect2(p + Vector2(-3, 7), Vector2(8, 5)), Color('ffe5aa'))
			draw_rect(Rect2(p + Vector2(-18, 14), Vector2(9, 4)), c.lightened(0.18))
			draw_rect(Rect2(p + Vector2(10, 13), Vector2(8, 4)), c.lightened(0.18))
		1: # Blütenkäfer: fliegender Blütenpanzer mit geöffneten/geschlossenen Flügeln.
			var wing_open := int(floor(world_time * 11.0)) % 2 == 0
			var hover := sin(world_time * 6.0) * 2.5
			var bp := p + Vector2(0, hover - 8.0)
			# Sechs Beine und Fühler hängen unter dem fliegenden Körper.
			for side in [-1.0, 1.0]:
				for leg in 3:
					draw_line(bp + Vector2(side * 10, 1 + leg * 7), bp + Vector2(side * (20 + leg * 2), 13 + leg * 7), Color("4e6545"), 3)
				draw_line(bp + Vector2(side * 7, -18), bp + Vector2(side * 18, -31), Color("6d6b45"), 2)
			# Flügelschlag: zwei klar getrennte Silhouetten.
			if wing_open:
				for side in [-1.0, 1.0]:
					draw_colored_polygon(PackedVector2Array([
						bp + Vector2(side * 7, -15), bp + Vector2(side * 31, -45),
						bp + Vector2(side * 47, -30), bp + Vector2(side * 29, -6)
					]), Color("ffe7c5", 0.78))
					draw_colored_polygon(PackedVector2Array([
						bp + Vector2(side * 6, -4), bp + Vector2(side * 42, -1),
						bp + Vector2(side * 36, 19), bp + Vector2(side * 13, 11)
					]), Color("f5bad0", 0.68))
			else:
				for side in [-1.0, 1.0]:
					draw_colored_polygon(PackedVector2Array([
						bp + Vector2(side * 5, -17), bp + Vector2(side * 18, -31),
						bp + Vector2(side * 24, -8), bp + Vector2(side * 13, 7)
					]), Color("ffe8cf", 0.74))
			# Rosa Blütenpanzer mit Blattakzenten.
			draw_circle(bp + Vector2(0, -5), 22, Color("d96b9a"))
			draw_colored_polygon(PackedVector2Array([
				bp + Vector2(-21, -8), bp + Vector2(-7, -28), bp + Vector2(1, -10), bp + Vector2(-3, 8)
			]), Color("ef9fbd"))
			draw_colored_polygon(PackedVector2Array([
				bp + Vector2(20, -9), bp + Vector2(8, -27), bp + Vector2(0, -10), bp + Vector2(4, 8)
			]), Color("f2b0c9"))
			draw_colored_polygon(PackedVector2Array([
				bp + Vector2(-10, -25), bp + Vector2(0, -37), bp + Vector2(11, -24), bp + Vector2(0, -18)
			]), Color("fff0d0"))
			draw_circle(bp + Vector2(0, 10), 13, Color("f6e4c7"))
			draw_circle(bp + Vector2(-5, 9), 4, Color("24382d"))
			draw_circle(bp + Vector2(6, 9), 4, Color("24382d"))
			draw_circle(bp + Vector2(0, -31), 4, Color("f1c75e"))

		2: # Pilzling mit Stiel, Hut und Sporenpunkten.
			draw_rect(Rect2(p + Vector2(-15, -7), Vector2(30, 32)), Color('e5d8b3'))
			draw_rect(Rect2(p + Vector2(-12, 20), Vector2(10, 10)), Color('9b755e'))
			draw_rect(Rect2(p + Vector2(3, 20), Vector2(10, 10)), Color('9b755e'))
			draw_colored_polygon(PackedVector2Array([p + Vector2(-33, -9), p + Vector2(-22, -31), p + Vector2(0, -42), p + Vector2(22, -31), p + Vector2(33, -9)]), Color('bd7882'))
			for dot in [Vector2(-15, -21), Vector2(5, -32), Vector2(19, -18)]: draw_circle(p + dot, 4, Color('fff2d2'))
			draw_rect(Rect2(p + Vector2(-8, 3), Vector2(4, 5)), INK)
			draw_rect(Rect2(p + Vector2(5, 3), Vector2(4, 5)), INK)
		3: # Wolf mit Schnauze, Ohren, Schwanz und laufenden Pfoten.
			draw_line(p + Vector2(-18, 2), p + Vector2(-41, -15 + stride), c.darkened(0.25), 11)
			for side in [-1.0, 1.0]:
				draw_rect(Rect2(p + Vector2(side * 16 - 5, 12 + stride * side), Vector2(9, 20)), c.darkened(0.27))
			draw_colored_polygon(PackedVector2Array([p + Vector2(-27, -5), p + Vector2(-17, -27), p + Vector2(17, -28), p + Vector2(29, -2), p + Vector2(20, 19), p + Vector2(-20, 19)]), c)
			for side in [-1.0, 1.0]:
				draw_colored_polygon(PackedVector2Array([p + Vector2(side * 13, -23), p + Vector2(side * 27, -43), p + Vector2(side * 29, -17)]), c.darkened(0.18))
				draw_rect(Rect2(p + Vector2(side * 9 - 2, -12), Vector2(5, 5)), Color('fff2a5'))
			draw_rect(Rect2(p + Vector2(-10, 1), Vector2(20, 11)), Color('c1bbaa'))
		4: # Steingolem als klarer Ruinenwächter.
			draw_rect(Rect2(p + Vector2(-20, 17 + stride * 0.25), Vector2(14, 18)), c.darkened(0.33))
			draw_rect(Rect2(p + Vector2(7, 17 - stride * 0.25), Vector2(14, 18)), c.darkened(0.33))
			draw_rect(Rect2(p + Vector2(-24, -26), Vector2(48, 50)), c.darkened(0.16))
			draw_rect(Rect2(p + Vector2(-16, -44), Vector2(32, 24)), c)
			draw_rect(Rect2(p + Vector2(-17, -35), Vector2(34, 6)), Color('dcc88f'))
			draw_rect(Rect2(p + Vector2(-31, -17), Vector2(15, 34)), Color('77726e'))
			draw_rect(Rect2(p + Vector2(22, -20), Vector2(8, 42)), Color('d6c493'))
			draw_line(p + Vector2(-6, -12), p + Vector2(6, -1), Color('8c8177'), 4)
			draw_rect(Rect2(p + Vector2(-10, -23), Vector2(6, 5)), Color('ffe0a1'))
			draw_rect(Rect2(p + Vector2(4, -23), Vector2(6, 5)), Color('ffe0a1'))
		5: # Beholder-artiger Ruinenwächter mit Stielaugen.
			draw_circle(p + Vector2(0, 2), 28, c.darkened(0.28))
			draw_circle(p + Vector2(0, -6), 26, c)
			draw_circle(p + Vector2(0, -6), 15, Color('efe7cf'))
			draw_circle(p + Vector2(0, -6), 8, Color('7d8791'))
			draw_circle(p + Vector2(0, -6), 4, Color('26383c'))
			for angle in [-1.9, -1.15, -0.35, 0.45, 1.2, 1.95]:
				var dir := Vector2.RIGHT.rotated(angle)
				draw_line(p + dir * 18 + Vector2(0, -6), p + dir * 34 + Vector2(0, -16 + sin(world_time * 4.0 + angle) * 3.0), c.lightened(0.08), 4)
				draw_circle(p + dir * 38 + Vector2(0, -18 + sin(world_time * 4.0 + angle) * 3.0), 6, Color('e9d9b8'))
				draw_circle(p + dir * 38 + Vector2(0, -18 + sin(world_time * 4.0 + angle) * 3.0), 2.5, Color('394c5d'))
			draw_arc(p + Vector2(0, 4), 17, 0.3, PI - 0.3, 12, Color('e9d4a8'), 3)
		6: # Krabbe mit kristallisiertem Panzer und Scheren.
			draw_crab_model(p, c, stride, true)
		7: # Kristallgolem: massiver Körper mit facettierten Schultern und Kern.
			for side in [-1.0, 1.0]:
				draw_rect(Rect2(p + Vector2(side * 27 - 9, -8 + stride * side * 0.2), Vector2(18, 39)), c.darkened(0.28))
				draw_colored_polygon(PackedVector2Array([p + Vector2(side * 22, -20), p + Vector2(side * 39, -39), p + Vector2(side * 43, -8), p + Vector2(side * 25, 5)]), Color('d9faff'))
			draw_colored_polygon(PackedVector2Array([p + Vector2(-28, 18), p + Vector2(-24, -28), p + Vector2(0, -44), p + Vector2(25, -28), p + Vector2(29, 18), p + Vector2(0, 34)]), c.darkened(0.12))
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -34), p + Vector2(15, -8), p + Vector2(0, 19), p + Vector2(-15, -8)]), Color('bcefff'))
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -27), p + Vector2(8, -7), p + Vector2(0, 9), p + Vector2(-8, -7)]), Color('f4ffff'))
			draw_rect(Rect2(p + Vector2(-12, -24), Vector2(6, 5)), Color('365f78'))
			draw_rect(Rect2(p + Vector2(6, -24), Vector2(6, 5)), Color('365f78'))
		8: # Schneller Ascheläufer mit glühender Spur und Hörnern.
			for side in [-1.0, 1.0]:
				draw_line(p + Vector2(side * 9, 11), p + Vector2(side * 19, 32 + stride * side), c.darkened(0.3), 8)
			draw_colored_polygon(PackedVector2Array([p + Vector2(-22, 13), p + Vector2(-15, -23), p + Vector2(15, -23), p + Vector2(23, 14)]), c.darkened(0.16))
			draw_colored_polygon(PackedVector2Array([p + Vector2(-12, -22), p + Vector2(-20, -43), p + Vector2(-2, -29), p + Vector2(10, -23), p + Vector2(19, -43), p + Vector2(17, -11)]), Color('e8a374'))
			draw_rect(Rect2(p + Vector2(-8, -18), Vector2(5, 6)), Color('ffe388'))
			draw_rect(Rect2(p + Vector2(5, -18), Vector2(5, 6)), Color('ffe388'))
			draw_line(p + Vector2(-22, 15), p + Vector2(-35, 25 + stride), Color('f7ab6a'), 5)
		9: # Lavagolem: weiterentwickelter Glutgolem mit schwerem Basaltkörper und Lavarissen.
			draw_rect(Rect2(p + Vector2(-31, -31), Vector2(62, 58)), Color('4f3f44'))
			draw_rect(Rect2(p + Vector2(-24, -45), Vector2(48, 25)), c)
			for side in [-1.0, 1.0]:
				draw_rect(Rect2(p + Vector2(side * 27 - 10, -11), Vector2(20, 39)), c.darkened(0.25))
				draw_rect(Rect2(p + Vector2(side * 14 - 5, 23), Vector2(12, 15)), Color('55464b'))
			draw_line(p + Vector2(-18, -9), p + Vector2(3, 12), Color('f5a76a'), 5)
			draw_line(p + Vector2(4, 12), p + Vector2(23, -8), Color('f5a76a'), 4)
			draw_line(p + Vector2(-7, -24), p + Vector2(-2, 12), Color('ffbf74'), 3)
			draw_line(p + Vector2(8, -24), p + Vector2(13, 8), Color('ffbf74'), 3)
			draw_rect(Rect2(p + Vector2(-10, -25), Vector2(6, 6)), Color('ffdb78'))
			draw_rect(Rect2(p + Vector2(4, -25), Vector2(6, 6)), Color('ffdb78'))
		10: # Strandkrabbe mit Sandpanzer.
			draw_crab_model(p, c, stride, false)
		11: # Wassergeist als Tropfen mit Wellenarmen.
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -46), p + Vector2(21, -16), p + Vector2(24, 15), p + Vector2(0, 29), p + Vector2(-24, 15), p + Vector2(-21, -16)]), Color(c, 0.8))
			for side in [-1.0, 1.0]:
				draw_arc(p + Vector2(side * 24, 0), 12, world_time, world_time + PI, 12, Color('d1f7f0'), 4)
			draw_circle(p + Vector2(-7, -8), 4, Color.WHITE)
			draw_circle(p + Vector2(8, -8), 4, Color.WHITE)
			draw_line(p + Vector2(-11, 12), p + Vector2(12, 12), Color('b6eaf5'), 3)
		15: # Sternenschatten: dunkle Gestalt mit schwebenden Sternsplittern.
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -45), p + Vector2(22, -19), p + Vector2(25, 20), p + Vector2(0, 31), p + Vector2(-26, 20), p + Vector2(-22, -19)]), c.darkened(0.36))
			for side in [-1.0, 1.0]:
				draw_colored_polygon(PackedVector2Array([p + Vector2(side * 30, -35 + stride), p + Vector2(side * 39, -19 + stride), p + Vector2(side * 27, -16 + stride)]), Color('e8d1ec'))
			draw_rect(Rect2(p + Vector2(-11, -19), Vector2(7, 5)), Color('fff1c3'))
			draw_rect(Rect2(p + Vector2(5, -19), Vector2(7, 5)), Color('fff1c3'))
		16: # Bruchwächter: Steinrüstung mit glühendem Kern.
			draw_rect(Rect2(p + Vector2(-27, -35), Vector2(54, 66)), c.darkened(0.48))
			for side in [-1.0, 1.0]:
				draw_rect(Rect2(p + Vector2(side * 30 - 8, -14), Vector2(17, 36)), c)
				draw_rect(Rect2(p + Vector2(side * 13 - 6, 28 + stride * side * 0.3), Vector2(13, 14)), Color('605e75'))
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -23), p + Vector2(13, -2), p + Vector2(0, 17), p + Vector2(-13, -2)]), Color('f9c49c'))
			draw_rect(Rect2(p + Vector2(-17, -40), Vector2(34, 12)), Color('a094a3'))
		17: # Nebelhirsch: langer Hals, vier Läufe und verzweigte Geweihkrone.
			for side in [-1.0,1.0]:
				draw_line(p+Vector2(side*12,4),p+Vector2(side*15,30+stride*side),c.darkened(0.38),7)
				draw_line(p+Vector2(side*5,-20),p+Vector2(side*14,-43),c.lightened(0.12),10)
				draw_line(p+Vector2(side*11,-39),p+Vector2(side*20,-53),Color('dfd4bd'),4)
				draw_line(p+Vector2(side*17,-48),p+Vector2(side*22,-61),Color('e8dec9'),3)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-26,10),p+Vector2(-23,-8),p+Vector2(-12,-20),p+Vector2(12,-20),p+Vector2(26,-5),p+Vector2(20,17),p+Vector2(-17,18)]),c.darkened(0.2))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-14,-17),p+Vector2(1,-28),p+Vector2(17,-18),p+Vector2(9,-2),p+Vector2(-10,-2)]),c.lightened(0.15))
			draw_rect(Rect2(p+Vector2(4,-22),Vector2(5,4)),Color('fff0bf'))
		18: # Irrlicht: leuchtender Kern in drei flatternden Schleiern.
			for side in [-1.0,1.0]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(0,-20),p+Vector2(side*28,-34+stride),p+Vector2(side*21,-4),p+Vector2(side*34,15+stride),p+Vector2(0,24)]),Color(c.lightened(0.15),0.72))
				draw_line(p+Vector2(side*9,12),p+Vector2(side*20,31+stride),Color(c.lightened(0.28),0.82),5)
			draw_circle(p+Vector2(0,-9),19,c.darkened(0.18))
			draw_circle(p+Vector2(0,-11),14,c.lightened(0.2))
			draw_circle(p+Vector2(0,-11),8,Color('f4ffff'))
			draw_circle(p+Vector2(0,-11),4,Color('70a9b1'))
		19: # Harzbestie: gepanzerter Waldkäfer mit bernsteinfarbenem Rücken.
			for side in [-1.0,1.0]:
				for leg in 3: draw_line(p+Vector2(side*13,-5+leg*9),p+Vector2(side*(29+leg*2),4+leg*10+stride*side),c.darkened(0.37),5)
				draw_line(p+Vector2(side*8,-17),p+Vector2(side*19,-34),c.darkened(0.24),5)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-22,9),p+Vector2(-20,-14),p+Vector2(-11,-27),p+Vector2(11,-27),p+Vector2(22,-13),p+Vector2(20,11),p+Vector2(0,21)]),c.darkened(0.32))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-16,-13),p+Vector2(-9,-29),p+Vector2(8,-31),p+Vector2(18,-13),p+Vector2(11,5),p+Vector2(-11,5)]),c)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-9,-17),p+Vector2(-5,-26),p+Vector2(1,-27),p+Vector2(5,-12),p+Vector2(0,-4)]),Color('f0d17c'))
			draw_line(p+Vector2(-14,-11),p+Vector2(12,-10),Color('fff0b0'),3)
			draw_rect(Rect2(p+Vector2(-9,2),Vector2(5,4)),Color('ffe7a0')); draw_rect(Rect2(p+Vector2(6,2),Vector2(5,4)),Color('ffe7a0'))
		20: # Wurzelhexe: knorrige Wurzelrobe, Blattkapuze und Runenstab.
			draw_colored_polygon(PackedVector2Array([p+Vector2(-29,25),p+Vector2(-20,-19),p+Vector2(-12,-36),p+Vector2(13,-36),p+Vector2(23,-16),p+Vector2(30,25),p+Vector2(15,18),p+Vector2(5,29),p+Vector2(-7,18),p+Vector2(-20,28)]),Color('515c43'))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-22,-22),p+Vector2(-16,-43),p+Vector2(0,-54),p+Vector2(17,-43),p+Vector2(23,-22)]),c.darkened(0.18))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-15,-22),p+Vector2(0,-43),p+Vector2(15,-22)]),c.lightened(0.13))
			draw_rect(Rect2(p+Vector2(-11,-19),Vector2(7,6)),Color('dff1b1')); draw_rect(Rect2(p+Vector2(5,-19),Vector2(7,6)),Color('dff1b1'))
			draw_line(p+Vector2(26,20),p+Vector2(36,-41),Color('674c37'),7); draw_line(p+Vector2(30,-33),p+Vector2(43,-47),Color('b0a16b'),4)
			draw_circle(p+Vector2(37,-46),5,Color('b7e38c'))
		21: # Quellkriecher: breiter Amphibienkörper, Sprungbeine und Wasserdrüsen.
			for side in [-1.0,1.0]:
				draw_line(p+Vector2(side*13,3),p+Vector2(side*30,18+stride*side),c.darkened(0.28),9)
				draw_line(p+Vector2(side*25,17+stride*side),p+Vector2(side*33,29+stride*side),c,5)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-27,-5),p+Vector2(-22,-21),p+Vector2(-12,-29),p+Vector2(9,-29),p+Vector2(23,-19),p+Vector2(28,-4),p+Vector2(20,13),p+Vector2(0,20),p+Vector2(-20,13)]),c.darkened(0.24))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-24,-6),p+Vector2(-18,-21),p+Vector2(-9,-25),p+Vector2(8,-25),p+Vector2(20,-17),p+Vector2(24,-4),p+Vector2(17,10),p+Vector2(0,16),p+Vector2(-18,10)]),c)
			for side in [-1.0,1.0]:
				draw_circle(p+Vector2(side*13,-25),8,c.lightened(0.2)); draw_circle(p+Vector2(side*13,-26),3,Color('f6efc6'))
			draw_line(p+Vector2(-15,-6),p+Vector2(14,-5),Color('c7f2df'),3)
		22: # Perlengeist: schwebende Muschelschichten um eine helle Perle.
			draw_arc(p+Vector2(0,2),27,0.1,PI-0.1,24,c.darkened(0.25),8)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-27,-1),p+Vector2(-21,-24),p+Vector2(-9,-36),p+Vector2(0,-27),p+Vector2(9,-36),p+Vector2(22,-22),p+Vector2(28,-1),p+Vector2(16,20),p+Vector2(0,28),p+Vector2(-17,20)]),Color(c,0.83))
			for side in [-1.0,1.0]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(0,-5),p+Vector2(side*21,-19),p+Vector2(side*17,9)]),c.lightened(0.3))
			draw_circle(p+Vector2(0,-4),10,Color('d3eff0')); draw_circle(p+Vector2(-3,-7),4,Color('fffef2'))
		23: # Gratgreif: gefiederte Flügel, Hakenschnabel und kräftige Läufe.
			for side in [-1.0,1.0]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(side*9,-21),p+Vector2(side*38,-44+stride),p+Vector2(side*34,-11),p+Vector2(side*23,4),p+Vector2(side*13,1)]),c.darkened(0.16))
				for feather in range(3): draw_line(p+Vector2(side*(17+feather*5),-25-feather*3),p+Vector2(side*(38-feather*3),-37+feather*9+stride),Color('d8d2df'),4)
				draw_line(p+Vector2(side*12,10),p+Vector2(side*15,30+stride*side),c.darkened(0.38),7)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-17,13),p+Vector2(-24,-7),p+Vector2(-12,-30),p+Vector2(12,-29),p+Vector2(24,-7),p+Vector2(18,14)]),c)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-9,-23),p+Vector2(1,-39),p+Vector2(15,-25),p+Vector2(8,-8)]),Color('d6c4a0'))
			draw_colored_polygon(PackedVector2Array([p+Vector2(15,-20),p+Vector2(34,-12),p+Vector2(16,-8)]),Color('e9c36f'))
		24: # Schattenritter: geschlossene Plattenrüstung, Visier, Schild und Runenklinge.
			for side in [-1.0,1.0]: draw_rect(Rect2(p+Vector2(side*14-7,18+stride*side*0.3),Vector2(14,20)),Color('393c4f'))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-25,16),p+Vector2(-22,-22),p+Vector2(0,-35),p+Vector2(23,-22),p+Vector2(25,16),p+Vector2(0,28)]),c.darkened(0.28))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-17,-22),p+Vector2(0,-37),p+Vector2(17,-22),p+Vector2(13,-2),p+Vector2(-13,-2)]),Color('5c5b75'))
			draw_rect(Rect2(p+Vector2(-12,-20),Vector2(24,6)),Color('292b3b')); draw_rect(Rect2(p+Vector2(-8,-19),Vector2(6,3)),Color('c5b8ff')); draw_rect(Rect2(p+Vector2(3,-19),Vector2(6,3)),Color('c5b8ff'))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-25,-9),p+Vector2(-40,-17),p+Vector2(-38,18),p+Vector2(-22,22)]),Color('77748f'))
			draw_line(p+Vector2(30,17),p+Vector2(44,-42),Color('d9e0e8'),7); draw_line(p+Vector2(31,4),p+Vector2(42,0),Color('c7b4ed'),3)
		25: # Himmelsfalter: vier geschichtete Flügel mit Augenzeichnung und Körperpelz.
			for side in [-1.0,1.0]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(side*3,-13),p+Vector2(side*31,-42+stride),p+Vector2(side*35,-8),p+Vector2(side*15,3)]),c.darkened(0.15))
				draw_colored_polygon(PackedVector2Array([p+Vector2(side*4,0),p+Vector2(side*30,5),p+Vector2(side*24,27),p+Vector2(side*7,16)]),c.lightened(0.16))
				draw_circle(p+Vector2(side*21,-19),6,Color('75618d')); draw_circle(p+Vector2(side*21,-19),3,Color('f5e7bf'))
				draw_line(p+Vector2(side*4,-24),p+Vector2(side*13,-43),Color('d7c6e3'),3)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-7,-20),p+Vector2(0,-29),p+Vector2(7,-20),p+Vector2(6,19),p+Vector2(0,27),p+Vector2(-6,19)]),Color('5a4c6d'))
			draw_line(p+Vector2(-3,-21),p+Vector2(-13,-37),Color('b8a1d4'),2); draw_line(p+Vector2(3,-21),p+Vector2(13,-37),Color('b8a1d4'),2)
		26: # Sternenwächterin: Elfenbeinrüstung, goldene Krone und leuchtender Sternkern.
			for side in [-1.0,1.0]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(side*18,-24),p+Vector2(side*35,-37),p+Vector2(side*39,-1),p+Vector2(side*23,10)]),Color('b6a97e'))
				draw_rect(Rect2(p+Vector2(side*14-6,17+stride*side*0.25),Vector2(12,19)),Color('75674e'))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-28,17),p+Vector2(-23,-26),p+Vector2(-11,-36),p+Vector2(11,-36),p+Vector2(23,-26),p+Vector2(28,17),p+Vector2(0,29)]),c.darkened(0.18))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-17,-19),p+Vector2(0,-31),p+Vector2(17,-19),p+Vector2(14,8),p+Vector2(0,20),p+Vector2(-14,8)]),Color('f1e8c5'))
			draw_colored_polygon(PackedVector2Array([p+Vector2(0,-15),p+Vector2(6,-4),p+Vector2(0,8),p+Vector2(-6,-4)]),Color('ffd777'))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-13,-35),p+Vector2(-15,-50),p+Vector2(-3,-41),p+Vector2(0,-58),p+Vector2(5,-41),p+Vector2(17,-50),p+Vector2(13,-35)]),Color('c7a762'))
		_:
			if type in [17, 19, 21, 23, 25]:
				for side in [-1.0, 1.0]:
					draw_line(p + Vector2(side * 13, 14), p + Vector2(side * 23, 29 + stride * side), c.darkened(0.4), 7)
					draw_line(p + Vector2(side * 16, -26), p + Vector2(side * 30, -49), c.lightened(0.15), 5)
				draw_colored_polygon(PackedVector2Array([p + Vector2(-27,4),p + Vector2(-20,-27),p + Vector2(0,-38),p + Vector2(22,-26),p + Vector2(28,6),p + Vector2(0,25)]), c)
			else:
				draw_colored_polygon(PackedVector2Array([p + Vector2(-23,18),p + Vector2(-26,-13),p + Vector2(-9,-36),p + Vector2(11,-36),p + Vector2(27,-13),p + Vector2(22,24),p + Vector2(0,13)]), Color(c,0.87))
				for side in [-1.0, 1.0]:
					draw_colored_polygon(PackedVector2Array([p + Vector2(side * 25,-14),p + Vector2(side * 38,-22 + stride),p + Vector2(side * 31,8)]), c.lightened(0.25))
			for side in [-1.0, 1.0]: draw_circle(p + Vector2(side * 9,-13), 4, Color('fff4d0'))
			draw_colored_polygon(PackedVector2Array([p + Vector2(0,-35),p + Vector2(6,-25),p + Vector2(0,-16),p + Vector2(-6,-25)]), c.lightened(0.5))

func draw_crab_model(p: Vector2, c: Color, stride: float, crystal: bool) -> void:
	for side in [-1.0, 1.0]:
		for leg in 3:
			draw_line(p + Vector2(side * 17, -8 + leg * 10), p + Vector2(side * (30 + leg * 5), 6 + leg * 9 + stride * side), c.darkened(0.26), 5)
		draw_line(p + Vector2(side * 22, -14), p + Vector2(side * 38, -27), c.darkened(0.22), 7)
		draw_circle(p + Vector2(side * 39, -28), 10, c.lightened(0.12))
	draw_circle(p, 23, c.darkened(0.28))
	draw_circle(p + Vector2(0, -5), 20, c)
	if crystal:
		draw_colored_polygon(PackedVector2Array([p + Vector2(-15, -12), p + Vector2(0, -33), p + Vector2(16, -11), p + Vector2(0, 6)]), Color("d2f7ff"))
	else:
		draw_rect(Rect2(p + Vector2(-14, -16), Vector2(28, 6)), Color("f7d5a1"))
	draw_rect(Rect2(p + Vector2(-10, -9), Vector2(5, 5)), INK)
	draw_rect(Rect2(p + Vector2(6, -9), Vector2(5, 5)), INK)

func draw_boss_model(type: int, p: Vector2, c: Color, stride: float) -> void:
	var aura := Color("e9c592") if type == 12 else (Color("a9eefa") if type == 13 else Color("f4a16f"))
	draw_arc(p, 58, 0, TAU, 32, Color(aura, 0.6), 5)
	match type:
		12: # Turmwächter: Ritter mit Helm, Schild und Zweihänder.
			for side in [-1.0, 1.0]:
				draw_rect(Rect2(p + Vector2(side * 20 - 10, 20 + stride * side * 0.3), Vector2(20, 21)), Color("59666a"))
			draw_rect(Rect2(p + Vector2(-35, -39), Vector2(70, 64)), c.darkened(0.25))
			draw_rect(Rect2(p + Vector2(-24, -37), Vector2(48, 54)), c)
			draw_rect(Rect2(p + Vector2(-23, -65), Vector2(46, 31)), Color("89989b"))
			draw_rect(Rect2(p + Vector2(-28, -70), Vector2(56, 12)), Color("dbc98f"))
			draw_rect(Rect2(p + Vector2(-19, -49), Vector2(38, 7)), Color("233b43"))
			draw_rect(Rect2(p + Vector2(-10, -48), Vector2(21, 5)), aura)
			draw_colored_polygon(PackedVector2Array([p + Vector2(-49, -35), p + Vector2(-26, -42), p + Vector2(-20, 12), p + Vector2(-43, 27)]), Color("6d8182"))
			draw_line(p + Vector2(42, 18), p + Vector2(59, -84), Color("eef0df"), 11)
			draw_line(p + Vector2(30, -7), p + Vector2(59, -4), Color("eac77b"), 8)
		13: # Kristallhüter: großer facettierter Körper mit schwebenden Splittern.
			for side in [-1.0, 1.0]:
				var shard := p + Vector2(side * 55, -35 + stride * side)
				draw_colored_polygon(PackedVector2Array([shard + Vector2(0, -33), shard + Vector2(20, 0), shard + Vector2(0, 33), shard + Vector2(-20, 0)]), Color("d9faff"))
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -81), p + Vector2(38, -37), p + Vector2(43, 13), p + Vector2(0, 39), p + Vector2(-43, 13), p + Vector2(-38, -37)]), c)
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -69), p + Vector2(22, -21), p + Vector2(0, 23), p + Vector2(-22, -21)]), Color("d5faff"))
			draw_rect(Rect2(p + Vector2(-22, -36), Vector2(9, 8)), Color("365f78"))
			draw_rect(Rect2(p + Vector2(13, -36), Vector2(9, 8)), Color("365f78"))
		14: # Aschefürst: hornbewehrte Rüstung, Feuerkrone und Lavaadern.
			for side in [-1.0, 1.0]:
				draw_rect(Rect2(p + Vector2(side * 19 - 10, 13 + stride * side * 0.2), Vector2(20, 30)), Color("564047"))
			draw_colored_polygon(PackedVector2Array([p + Vector2(-43, 23), p + Vector2(-34, -42), p + Vector2(0, -60), p + Vector2(34, -42), p + Vector2(43, 23)]), Color("6c4449"))
			draw_rect(Rect2(p + Vector2(-27, -33), Vector2(54, 51)), c)
			draw_colored_polygon(PackedVector2Array([p + Vector2(-27, -55), p + Vector2(-38, -88), p + Vector2(-10, -67), p + Vector2(10, -67), p + Vector2(38, -88), p + Vector2(27, -55)]), Color("e2a074"))
			draw_rect(Rect2(p + Vector2(-16, -51), Vector2(32, 8)), Color("2f333d"))
			draw_rect(Rect2(p + Vector2(-13, -50), Vector2(9, 6)), Color("ffdc82"))
			draw_rect(Rect2(p + Vector2(6, -50), Vector2(9, 6)), Color("ffdc82"))
			draw_line(p + Vector2(-20, -10), p + Vector2(7, 21), Color("ffc06e"), 6)
			draw_line(p + Vector2(7, 21), p + Vector2(23, -8), Color("ffc06e"), 5)

func draw_shadow(p: Vector2) -> void:
	for band in 3:
		var width := 42.0 - band * 8.0
		draw_rect(Rect2(p + Vector2(-width * 0.5, 23 + band), Vector2(width, 2)), Color(0.12, 0.20, 0.19, 0.10 - band * 0.018))

func draw_player() -> void:
	draw_shadow(player_pos)
	if invulnerable > 0 and Engine.get_process_frames() % 6 < 3: return
	draw_hero(player_pos, 1.0, is_walking, facing, true)
	if swing_timer > 0 and class_id == 0:
		var swing_progress := clampf(1.0 - swing_timer / maxf(0.01, swing_duration), 0.0, 1.0)
		var arc_angle := facing.angle() - 0.88 + swing_progress * 1.76
		var heavy_swing: bool = equipped_weapon_variant() == "axe"
		draw_arc(player_pos + facing * 32, 56.0 if heavy_swing else 48.0, arc_angle - 0.34, arc_angle + 0.34, 10, Color("fff1cd", 0.7 * (1.0 - swing_progress)), 7 if heavy_swing else 5)
	if shield_timer > 0: draw_arc(player_pos, 38, 0, TAU, 32, Color("a5e7f1", 0.55), 5)
	if rage_timer > 0: draw_arc(player_pos, 45, 0, TAU, 28, Color("f5aa72", 0.55), 4)
	if poison_blade_timer > 0: draw_arc(player_pos, 49, 0, TAU, 28, Color("addc78", 0.55), 4)

func draw_hero(p: Vector2, scale_factor: float, walking: bool, look: Vector2, in_world: bool = false, preview_class: int = -1) -> void:
	# v27: Figur selbst kommt aus einem pixelgenauen Sprite-Sheet. Rasse, Geschlecht und Klasse ändern die Silhouette.
	var visual_class := class_id if preview_class < 0 else preview_class
	var use_race := pending_race if panel == "creation" and preview_class >= 0 else hero_race
	var use_gender := pending_gender if panel == "creation" and preview_class >= 0 else hero_gender
	var attack_now := swing_timer > 0.0 and preview_class < 0
	draw_character_sprite(p, visual_class, walking, look, scale_factor, attack_now, use_race, use_gender)
	# Arm, Hand und Waffe folgen während des Angriffs derselben Bewegung.
	var design := equipped_weapon_design() if preview_class < 0 else visual_class * 4
	var weapon_family := visual_class
	var weapon_pos := p + Vector2(0, -5.0 * scale_factor)
	var base_look: Vector2 = look.normalized() if look.length() > 0.01 else Vector2.DOWN
	var progress := clampf(1.0 - swing_timer / maxf(0.01, swing_duration), 0.0, 1.0) if attack_now else -1.0
	var weapon_look := weapon_attack_look(base_look, weapon_family, design, progress)
	if attack_now and weapon_family == 0:
		weapon_pos += base_look * (5.0 + 6.0 * sin(progress * PI)) * scale_factor
	elif attack_now and weapon_family == 1:
		weapon_pos += Vector2(0, -7.0 * sin(progress * PI)) * scale_factor
	var side := weapon_look.rotated(PI * 0.5)
	# Schulter sitzt am seitlichen Ärmel des Sprites. Der Ärmel wird vom Körper
	# bis zur Hand durchgezogen, damit kein freischwebender Arm entsteht.
	var shoulder_side := -signf(base_look.y) if absf(base_look.y) > 0.2 else signf(base_look.x)
	if is_zero_approx(shoulder_side): shoulder_side = 1.0
	var arm_start := p + Vector2(shoulder_side * 14.0, -19.0) * scale_factor
	var grip := weapon_pos + weapon_look * 7.0 * scale_factor + side * 7.0 * scale_factor
	var arm_color: Color = [Color('6d8292'), Color('695b91'), Color('65775b')][clampi(visual_class, 0, 2)]
	var cuff_color: Color = [Color('c0c8c4'), Color('d4c1e8'), Color('ae9b70')][clampi(visual_class, 0, 2)]
	draw_line(arm_start, grip, Color('493d45'), 10.0 * scale_factor)
	draw_line(arm_start, grip, arm_color, 7.0 * scale_factor)
	draw_circle(arm_start, 5.5 * scale_factor, Color('493d45'))
	draw_circle(arm_start, 3.8 * scale_factor, arm_color.lightened(0.06))
	draw_line(arm_start.lerp(grip, 0.72) - side * 1.5 * scale_factor, grip, cuff_color, 4.0 * scale_factor)
	draw_weapon_world(weapon_pos, weapon_family, design, base_look, scale_factor, progress)
	if equipped_ring_uid >= 0 and preview_class < 0:
		draw_rect(Rect2(p + Vector2(-23,-2) * scale_factor, Vector2(5,3) * scale_factor), Color('f8d982'))

func weapon_attack_look(look: Vector2, family: int, design: int, progress: float) -> Vector2:
	if progress < 0.0: return look.normalized()
	var t := clampf(progress, 0.0, 1.0)
	var eased := t * t * (3.0 - 2.0 * t)
	if family == 0:
		var is_axe := design % 3 == 2
		var sweep := lerpf(-1.22, 1.22, eased) if is_axe else lerpf(-0.88, 0.88, eased)
		return look.rotated(sweep).normalized()
	if family == 1:
		return look.rotated(lerpf(-0.50, 0.44, eased)).normalized()
	if design % 4 == 3:
		return look.rotated(lerpf(-0.16, 0.10, eased)).normalized()
	return look.rotated(-0.08 * sin(t * PI)).normalized()

func equipped_armor_stage() -> int:
	for item in inventory:
		if int(item.get("uid",-1)) == equipped_armor_uid:
			return weapon_visual_stage(item)
	return 0

func draw_hero_sword(hand: Vector2, blade_dir: Vector2, preview: bool = false) -> void:
	var across := blade_dir.rotated(PI * 0.5)
	var stage := 0 if preview else equipped_weapon_stage()
	var design := 0 if preview else equipped_item_design(equipped_uid)
	var hilt := hand + blade_dir * 11
	var shoulder := hilt + blade_dir * 5
	var tip := shoulder + blade_dir * ((44 if preview else 76) + stage * 4 + (7 if design == 1 else 0))
	var rarity := 0
	for item in inventory:
		if not preview and int(item.get('uid', -1)) == equipped_uid:
			rarity = int(item.get('rarity', 0))
			break
	var metal: Color = element_color(weapon_element()) if not preview and weapon_element() != '' else (RARITY_COLORS[rarity] if not preview and equipped_uid >= 0 else Color('dee9e8'))
	draw_line(hand - blade_dir * 8, hilt, Color('5c4052'), 7)
	draw_rect(Rect2(hand - blade_dir * 10 - Vector2(3, 3), Vector2(6, 6)), Color('eac773'))
	if design == 1:
		draw_line(hilt - across * 6, hilt + across * 16, Color('4c3650'), 8)
		draw_line(hilt - across * 6, hilt + across * 16, Color('ddae68'), 5)
	elif design == 2:
		draw_line(hilt - across * 10, hilt + across * 10, Color('6b4d38'), 8)
		draw_line(hilt - across * 10, hilt + across * 10, Color('ddb46b'), 5)
	elif design == 3:
		draw_line(hilt - across * 16, hilt + across * 16, Color('a9c4c2'), 9)
		draw_circle(hilt - across * 16, 4, Color('e1b777'))
		draw_circle(hilt + across * 16, 4, Color('e1b777'))
	else:
		draw_line(hilt - across * (10 + stage), hilt + across * (10 + stage), Color('4c3650'), 8)
		draw_line(hilt - across * (10 + stage), hilt + across * (10 + stage), Color('ddae68'), 5)
	var width := 5 + stage * 0.9
	if design == 1:
		draw_colored_polygon(PackedVector2Array([shoulder + across * width, tip + across * 9, tip + across * 5 + blade_dir * 3, tip - blade_dir * 10 - across * 3, shoulder - across * width]), metal)
	elif design == 2: # Axtkopf
		var haft_end := shoulder + blade_dir * 55
		draw_line(shoulder, haft_end, Color('6b4d38'), 7)
		draw_line(shoulder, haft_end, Color('b68a5d'), 4)
		var axe_head := haft_end + blade_dir * 9
		draw_colored_polygon(PackedVector2Array([axe_head + across * 4, axe_head + across * 19 - blade_dir * 3, axe_head + across * 13 + blade_dir * 17, axe_head - across * 5 + blade_dir * 10, axe_head - across * 5 - blade_dir * 10]), metal)
		draw_colored_polygon(PackedVector2Array([axe_head - across * 4, axe_head - across * 16 - blade_dir * 3, axe_head - across * 11 + blade_dir * 12, axe_head + across * 1 + blade_dir * 7]), metal.darkened(0.12))
		draw_line(haft_end - across * 2, haft_end + across * 2, Color('f5efce'), 2)
	elif design == 3:
		draw_colored_polygon(PackedVector2Array([shoulder + across * width, tip - blade_dir * 10 + across * width, tip - across * 5, tip - blade_dir * 7, tip + across * 5, tip - blade_dir * 10 - across * width, shoulder - across * width]), metal)
	else:
		draw_colored_polygon(PackedVector2Array([shoulder + across * width, tip - blade_dir * 7, tip, tip - blade_dir * 7 - across * width, shoulder - across * width]), Color('354959'))
		draw_colored_polygon(PackedVector2Array([shoulder + across * (width - 2), tip - blade_dir * 8, tip - blade_dir * 2, shoulder - across * (width - 2)]), metal)
	if design != 2: draw_line(shoulder, tip - blade_dir * 5, Color('f8fcf2', 0.65), 2)
	if equipped_uid >= 0 and not preview:
		draw_circle(hilt, 3 + stage * 0.35, RARITY_COLORS[rarity])
		if stage >= 2 and design != 2:
			draw_line(shoulder + blade_dir * 10 - across * 3, shoulder + blade_dir * 22 - across * 3, Color('f8efd7', 0.6), 2)
		if stage >= 4:
			draw_circle(shoulder + blade_dir * 12, 3, element_color(weapon_element()))

func weapon_visual_stage(item: Dictionary) -> int:
	# Jede neue Ausrüstungsstufe verfeinert Form und Verzierung, nicht nur den Farbton.
	return clampi(int((int(item.get("level", 1)) + int(item.get("rarity", 0)) * 2) / 10.0), 0, 4)

func equipped_weapon_stage() -> int:
	for item in inventory:
		if int(item.get("uid", -1)) == equipped_uid:
			return weapon_visual_stage(item)
	return 0

func item_design(item: Dictionary) -> int:
	return clampi(int(item.get("design", absi(hash(String(item.get("name", "Ausrüstung")))) % 12)), 0, 11)

func equipped_item_design(uid: int) -> int:
	for item in inventory:
		if int(item.get("uid", -1)) == uid: return item_design(item)
	return 0

func equipped_weapon_design() -> int:
	if equipped_uid < 0: return class_id * 4
	return equipped_item_design(equipped_uid)

func draw_item_icon(origin: Vector2, kind: String, accent: Color, scale_factor: float = 1.0, stage: int = 0, design: int = 0) -> void:
	var p := origin
	var s := scale_factor
	if kind in ["sword", "staff", "bow"] and weapon_sprites != null:
		var family := ["sword", "staff", "bow"].find(kind)
		var src := Rect2(Vector2(clampi(design,0,11) * 32, family * 32), Vector2(32,32))
		draw_texture_rect_region(weapon_sprites, Rect2(p, Vector2(32,32) * s), src)
		if stage >= 3: draw_rect(Rect2(p + Vector2(25,3)*s, Vector2(4,4)*s), accent)
		return
	match kind:
		"sword":
			# Breite, abgeschrägte Klinge, Parierstange und Griff im Pixel-Art-Profil.
			var tip := p + Vector2(30 + (3 if design == 1 else 0), 1 + (4 if design == 1 else 0)) * s
			var base := p + Vector2(13, 19) * s
			var width := float(3 + mini(stage, 3) + (3 if design == 2 else 0))
			draw_colored_polygon(PackedVector2Array([base + Vector2(-width, -width) * s, p + Vector2(24, 3) * s, tip, p + Vector2(29, 9) * s, base + Vector2(width, width) * s]), Color("30283d"))
			draw_colored_polygon(PackedVector2Array([base + Vector2(-2, -2) * s, p + Vector2(25, 4) * s, tip - Vector2(2, 0) * s, base + Vector2(3, 2) * s]), accent if stage >= 3 else Color("cedee9"))
			if design == 1: draw_colored_polygon(PackedVector2Array([tip, p + Vector2(20, 4) * s, p + Vector2(18, 12) * s, p + Vector2(27, 9) * s]), accent)
			elif design == 2:
				draw_colored_polygon(PackedVector2Array([base, p + Vector2(18, 5) * s, p + Vector2(29, 1) * s, p + Vector2(26, 12) * s]), accent)
			elif design == 3:
				draw_line(p + Vector2(20, 6) * s, tip, Color("314452"), 3 * s)
				draw_rect(Rect2(p + Vector2(24, 1) * s, Vector2(3, 4) * s), Color("314452"))
			draw_line(base + Vector2(1, -1) * s, p + Vector2(27, 5) * s, Color("f5f8f0"), 2 * s)
			draw_line(p + Vector2(7, 16) * s, p + Vector2(17, 26) * s, Color("352a42"), 5 * s)
			draw_line(p + Vector2(7, 16) * s, p + Vector2(17, 26) * s, Color("dcb45e") if stage >= 1 else Color("aa8559"), 3 * s)
			draw_line(p + Vector2(3, 28) * s, base, Color("342b3e"), 6 * s)
			draw_line(p + Vector2(3, 28) * s, base, Color("694857"), 3 * s)
			draw_circle(p + Vector2(3, 28) * s, 3 * s, Color("d2a253"))
			if stage >= 2:
				draw_circle(base, 2.5 * s, accent)
			if design == 1: draw_line(p + Vector2(5, 17) * s, p + Vector2(18, 25) * s, Color("e6c37a"), 3 * s)
			elif design == 2:
				draw_line(p + Vector2(8, 13) * s, p + Vector2(22, 23) * s, Color("b9a8a1"), 4 * s)
			elif design == 3: draw_circle(base, 4 * s, accent)
			if stage >= 4:
				draw_line(p + Vector2(15, 11) * s, p + Vector2(25, 2) * s, Color("ffe89b"), 2 * s)
		"staff":
			draw_line(p + Vector2(8, 32) * s, p + Vector2(20, 8) * s, Color("352b41"), 7 * s)
			draw_line(p + Vector2(8, 32) * s, p + Vector2(20, 8) * s, Color("8d6048") if stage < 2 else Color("bca47a"), 4 * s)
			draw_line(p + Vector2(11, 27) * s, p + Vector2(16, 17) * s, Color("efcf83"), 2 * s)
			if stage >= 1:
				draw_line(p + Vector2(13, 15) * s, p + Vector2(27, 13) * s, Color("d9bb78"), 3 * s)
			if design == 1:
				draw_arc(p + Vector2(20, 7) * s, 9 * s, -PI * 0.8, PI * 0.55, 12, Color("e4c98b"), 4 * s)
			elif design == 2:
				for branch in [-1.0, 1.0]: draw_line(p + Vector2(18, 15) * s, p + Vector2(20 + branch * 12, 2) * s, Color("ad815e"), 3 * s)
			elif design == 3:
				for prong in [-1.0, 0.0, 1.0]: draw_line(p + Vector2(20 + prong * 8, 12) * s, p + Vector2(20 + prong * 8, 0) * s, Color("aebec2"), 3 * s)
			if stage >= 3 and design == 0:
				draw_colored_polygon(PackedVector2Array([p + Vector2(19, 8) * s, p + Vector2(11, 1) * s, p + Vector2(10, 11) * s]), Color("e8ce8a"))
				draw_colored_polygon(PackedVector2Array([p + Vector2(21, 8) * s, p + Vector2(29, 1) * s, p + Vector2(29, 11) * s]), Color("e8ce8a"))
			draw_circle(p + Vector2(20, 7) * s, (4 + mini(stage, 4)) * s, Color("302841"))
			draw_circle(p + Vector2(20, 7) * s, (3 + mini(stage, 4)) * s, accent)
			draw_circle(p + Vector2(18, 5) * s, 2 * s, Color("f7f6df"))
			if stage >= 4:
				draw_circle(p + Vector2(27, 20) * s, 2 * s, accent)
				draw_circle(p + Vector2(9, 12) * s, 2 * s, accent)
		"bow":
			if design == 3:
				draw_line(p + Vector2(5, 17) * s, p + Vector2(29, 17) * s, Color("8d674a"), 5 * s)
				draw_line(p + Vector2(5, 17) * s, p + Vector2(29, 17) * s, accent, 3 * s)
				draw_line(p + Vector2(17, 5) * s, p + Vector2(17, 29) * s, Color("efe7d0"), 2 * s)
				for horn in [-1.0,1.0]: draw_line(p+Vector2(10,17+horn*8)*s,p+Vector2(4,17+horn*12)*s,Color("e9d5b4"),3*s)
				draw_rect(Rect2(p+Vector2(13,13)*s,Vector2(9,9)*s),accent)
				draw_colored_polygon(PackedVector2Array([p + Vector2(31,17) * s, p + Vector2(25,14) * s, p + Vector2(25,20) * s]), Color("f6eedc"))
			else:
				draw_arc(p + Vector2(17, 17) * s, (14 + design * 1.5) * s, -PI * 0.62, PI * 0.62, 18, Color("aa764e") if design != 2 else Color("849b88"), 5 * s)
				if design == 1: draw_arc(p + Vector2(21,17) * s, 10 * s, -PI * 0.7, PI * 0.7, 16, Color("ead1a1"), 2 * s)
				elif design == 2:
					for horn in [-1.0,1.0]: draw_line(p+Vector2(14,17+horn*14)*s,p+Vector2(8,17+horn*17)*s,Color("e9d5b4"),3*s)
				draw_line(p + Vector2(12, 4) * s, p + Vector2(12, 30) * s, Color("efe7d0"), 2 * s)
				draw_line(p + Vector2(4, 17) * s, p + Vector2(28, 17) * s, accent, 3 * s)
				draw_colored_polygon(PackedVector2Array([p + Vector2(30,17) * s, p + Vector2(23,13) * s, p + Vector2(23,21) * s]), Color("f6eedc"))
		"potion":
			draw_rect(Rect2(p + Vector2(10, 1) * s, Vector2(12, 7) * s), Color("dac7a6"))
			draw_rect(Rect2(p + Vector2(5, 9) * s, Vector2(23, 23) * s), Color("f2e8da"))
			draw_rect(Rect2(p + Vector2(8, 17) * s, Vector2(17, 12) * s), accent)
			draw_rect(Rect2(p + Vector2(12, 11) * s, Vector2(4, 4) * s), Color.WHITE)
		"gem":
			draw_colored_polygon(PackedVector2Array([p + Vector2(15, 1) * s, p + Vector2(30, 15) * s, p + Vector2(15, 32) * s, p + Vector2(1, 15) * s]), accent)
			draw_rect(Rect2(p + Vector2(12, 7) * s, Vector2(5, 10) * s), Color("eefaf2"))
		"ring":
			draw_arc(p + Vector2(16, 21) * s, 10 * s, 0, TAU, 16, Color("e6bd75"), 6 * s)
			draw_rect(Rect2(p + Vector2(11, 4) * s, Vector2(10, 9) * s), accent)
		"armor":
			match class_id:
				0:
					draw_colored_polygon(PackedVector2Array([p+Vector2(5,3)*s,p+Vector2(13,8)*s,p+Vector2(20,8)*s,p+Vector2(28,3)*s,p+Vector2(28,27)*s,p+Vector2(16,33)*s,p+Vector2(4,27)*s]),Color("8fa6b0"))
					if design == 1: draw_rect(Rect2(p+Vector2(1,6)*s,Vector2(31,5)*s),Color("c5d0c7"))
					elif design == 2: draw_colored_polygon(PackedVector2Array([p+Vector2(8,8)*s,p+Vector2(16,1)*s,p+Vector2(24,8)*s]),Color("ecd099"))
					elif design == 3:
						for rib in [10,16,22]: draw_line(p+Vector2(rib,10)*s,p+Vector2(rib,26)*s,Color("5e7d8e"),2*s)
					draw_rect(Rect2(p+Vector2(8,10)*s,Vector2(17,15)*s),accent)
					draw_line(p+Vector2(9,13)*s,p+Vector2(22,24)*s,Color("f4e2ba"),2*s)
				1:
					draw_colored_polygon(PackedVector2Array([p+Vector2(10,3)*s,p+Vector2(22,3)*s,p+Vector2(29,31)*s,p+Vector2(16,26)*s,p+Vector2(3,31)*s]),Color("3e5a91"))
					if design == 1: draw_rect(Rect2(p+Vector2(2,4)*s,Vector2(27,4)*s),Color("e0d5af"))
					elif design == 2: draw_line(p+Vector2(16,5)*s,p+Vector2(16,28)*s,Color("edc998"),3*s)
					elif design == 3: draw_arc(p+Vector2(16,16)*s,8*s,0,TAU,12,Color("c0b0e2"),3*s)
					draw_rect(Rect2(p+Vector2(5,7)*s,Vector2(6,15)*s),accent)
					draw_rect(Rect2(p+Vector2(22,7)*s,Vector2(6,15)*s),accent)
					draw_circle(p+Vector2(16,14)*s,3*s,Color("9ee6ee"))
				2:
					draw_colored_polygon(PackedVector2Array([p+Vector2(7,3)*s,p+Vector2(25,3)*s,p+Vector2(28,27)*s,p+Vector2(16,33)*s,p+Vector2(4,27)*s]),Color("587d5e"))
					if design == 1: draw_colored_polygon(PackedVector2Array([p+Vector2(6,4)*s,p+Vector2(0,20)*s,p+Vector2(10,24)*s]),Color("d5bd80"))
					elif design == 2: draw_rect(Rect2(p+Vector2(4,11)*s,Vector2(24,5)*s),Color("ab8e61"))
					elif design == 3: draw_line(p+Vector2(4,20)*s,p+Vector2(28,7)*s,Color("e0c188"),4*s)
					draw_line(p+Vector2(7,8)*s,p+Vector2(24,26)*s,Color("d4b77b"),4*s)
					draw_rect(Rect2(p+Vector2(8,20)*s,Vector2(17,4)*s),Color("735646"))
			if stage >= 2:
				draw_circle(p+Vector2(16,18)*s,2*s,accent.lightened(0.4))
		"herb":
			draw_line(p + Vector2(16, 31) * s, p + Vector2(16, 4) * s, Color("597e5b"), 4 * s)
			draw_rect(Rect2(p + Vector2(4, 8) * s, Vector2(12, 9) * s), accent)
			draw_rect(Rect2(p + Vector2(16, 14) * s, Vector2(13, 8) * s), accent.lightened(0.2))
		_:
			draw_rect(Rect2(p + Vector2(5, 5) * s, Vector2(22, 22) * s), accent)

func text_at(p: Vector2, value: String, size: int = 17, color: Color = FONT_COLOR, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: int = -1) -> void:
	draw_string(font, p, value, alignment, width, size, color)

func bar(rect: Rect2, value: float, maximum: float, foreground: Color, label: String) -> void:
	draw_rect(rect, Color("19252f"))
	draw_rect(rect.grow(-2), Color("394047"))
	var filled := maxf(0.0, rect.size.x - 6) * clampf(value / maxf(1.0, maximum), 0.0, 1.0)
	draw_rect(Rect2(rect.position + Vector2(3, 3), Vector2(filled, rect.size.y - 6)), foreground.darkened(0.26))
	draw_rect(Rect2(rect.position + Vector2(3, 3), Vector2(filled, maxf(2.0, (rect.size.y - 6) * 0.35))), foreground.lightened(0.16))
	text_at(rect.position + Vector2(9, rect.size.y - 6), label, 14, Color("fff7e4"))

func ui_box(rect: Rect2, fill: Color = Color("304a4b")) -> void:
	draw_rect(rect, Color("1e272c"))
	draw_rect(rect.grow(-2), Color("b69a65"))
	draw_rect(rect.grow(-4), fill.darkened(0.30))
	draw_rect(Rect2(rect.position + Vector2(9, 7), Vector2(maxf(0.0, rect.size.x - 18), 2)), Color("e0c58b", 0.72))
	for corner in [rect.position + Vector2(4,4), rect.position + Vector2(rect.size.x-9,4), rect.position + Vector2(4,rect.size.y-9), rect.position + rect.size - Vector2(9,9)]:
		draw_rect(Rect2(corner, Vector2(5, 5)), Color("d4b777"))

func ui_button(rect: Rect2, label: String, enabled: bool = true, active: bool = false) -> void:
	var hovering := enabled and rect.has_point(get_viewport().get_mouse_position())
	var border := Color("ffe0a0") if active or hovering else Color("a78a59")
	draw_rect(rect, Color("18252e"))
	draw_rect(rect.grow(-2), border)
	draw_rect(rect.grow(-4), Color("657359") if active else (Color("586c63") if hovering else (Color("364f52") if enabled else Color("364145"))))
	draw_rect(Rect2(rect.position + Vector2(8, 6), Vector2(maxf(0.0, rect.size.x - 16), 2)), Color("dbc58d", 0.52))
	text_at(rect.position + Vector2(11, rect.size.y * 0.67), label, 16, Color("fff1ce") if enabled else Color("b5b4a7"))

func draw_hud() -> void:
	ui_box(Rect2(12, 10, 354, 112), Color("334a4b"))
	draw_rect(Rect2(24, 18, 5, 17), [Color("d9a06f"), Color("9bbce4"), Color("a7cd91")][class_id])
	text_at(Vector2(36, 34), "%s · %s · STUFE %d" % [hero_name if hero_name != "" else CLASS_NAMES[class_id].to_upper(), RACE_NAMES[hero_race], level], 15, Color("fff0c6"))
	if creative_mode:
		draw_rect(Rect2(303, 19, 46, 17), Color("806a4e"))
		text_at(Vector2(306, 32), "TEST", 12, Color("fff1cb"))
	bar(Rect2(25, 43, 325, 23), hp, max_hp(), Color("e9797a"), "HP  %d / %d" % [ceili(hp), ceili(max_hp())])
	bar(Rect2(25, 69, 325, 19), energy, max_energy(), Color("82b8e8") if class_id == 1 else Color("79caad"), "%s  %d / %d" % ["MANA" if class_id == 1 else "ENERGIE", ceili(energy), ceili(max_energy())])
	bar(Rect2(25, 92, 325, 16), float(xp), float(xp_required()), Color("dfc17b"), "XP %d/%d  ·  %d GOLD" % [xp, xp_required(), gold])
	ui_box(Rect2(12, 126, 354, 47), Color("3c5551"))
	text_at(Vector2(25, 146), "◆  AKTUELLES ZIEL", 13, Color("f4d59e"))
	text_at(Vector2(25, 163), tracked_quest().substr(0, 42), 14, Color("fff2d9"))
	draw_circle(Vector2(1040, 105), 88, Color("35494b"))
	for enemy in enemies:
		if int(enemy["type"]) in [12, 13, 14] and enemy["pos"].distance_to(player_pos) < 620:
			ui_box(Rect2(430, 10, 480, 64), Color("5b4547"))
			text_at(Vector2(446, 37), "BOSS · %s" % ENEMY_TYPES[int(enemy["type"])]["name"], 19, Color("ffe5b5"))
			bar(Rect2(446, 43, 447, 19), float(enemy["hp"]), float(enemy["max_hp"]), Color("eb866f"), "%d / %d" % [ceili(float(enemy["hp"])), ceili(float(enemy["max_hp"]))])
			break
	if arena_mode != "":
		draw_circle(Vector2(1040, 103), 64, Color("28373f"))
		draw_arc(Vector2(1040, 103), 64, 0, TAU, 48, Color("e4bf7c"), 5)
		text_at(Vector2(966, 98), "WELLE %d%s" % [arena_wave, "/10" if arena_mode == "final" else ""], 19, Color("ffecbc"), HORIZONTAL_ALIGNMENT_CENTER, 150)
		text_at(Vector2(970, 126), "%d Gegner" % enemies.size(), 15, Color("e4d3b0"), HORIZONTAL_ALIGNMENT_CENTER, 140)
	else:
		draw_minimap(Rect2(970, 35, 140, 140), true)
	text_at(Vector2(955, 31), ("LETZTE WACHE" if arena_mode == "final" else "ENDLOSE ARENA") if arena_mode != "" else ("ZUR STEINROSE" if interior_id >= 0 else (DUNGEON_NAMES[dungeon_id].to_upper() if dungeon_id >= 0 else "%s · LV %d" % [region_name(region_at(player_pos)), region_level(region_at(player_pos))])), 13, Color("fff0bf"))
	if network_mode != "offline":
		text_at(Vector2(925, 188), "KOOP %d/4" % (remote_players.size()+1), 12, Color("a9e8d0"), HORIZONTAL_ALIGNMENT_CENTER, 180)
	if notice_timer > 0:
		ui_box(Rect2(12, 549, 510, 36), Color("415f59"))
		var short_notice := notice.substr(0, 55) + ("…" if notice.length() > 55 else "")
		text_at(Vector2(23, 573), short_notice, 15, Color("fff3c3"))
	var nearest := ""
	for i in WAYSTONES.size():
		if player_pos.distance_to(WAYSTONES[i]) < 105:
			nearest = "F  ·  Wegstein: %s" % ("Reiseziele wählen" if i == 0 else ("zurück ins Dorf · aktiviert" if waystone_unlocked[i] else "aktivieren und zurück ins Dorf"))
			break
	for portal in PORTALS:
		if player_pos.distance_to(portal[0]) < 112 or player_pos.distance_to(portal[1]) < 112:
			nearest = "E  ·  Torbogen nach %s (LV %d)" % [region_name(int(portal[2])), region_level(int(portal[2]))]
			break
	for i in LANDMARKS.size():
		if not opened_chests[i] and player_pos.distance_to(chest_position(i)) < 85:
			nearest = "E  ·  Schatztruhe öffnen"
			break
	for npc in NPCS:
		if player_pos.distance_to(npc["pos"]) < 105:
			nearest = "E  ·  Elara · Vollheilung für %d Gold" % healing_cost() if npc["kind"] == "healer" else "E  ·  %s (%s)" % [npc["name"], npc["role"]]
			break
	if rescue_state >= 2 and player_pos.distance_to(RESCUE_POS + Vector2(0, 120)) < 120:
		nearest = "E  ·  Nela (Bewohnerin)"
	if dungeon_id >= 0:
		nearest = "E  ·  Gewölbe verlassen" if player_pos.distance_to(DUNGEON_CENTER + Vector2(-570, 0)) < 110 else ("E  ·  Versiegelte Truhe" if player_pos.distance_to(DUNGEON_CENTER + Vector2(555, 0)) < 105 and not dungeon_chests_opened[dungeon_id] else "")
	elif interior_id >= 0:
		nearest = "E  ·  Taverne verlassen" if player_pos.distance_to(INTERIOR_CENTER + Vector2(0, 210)) < 95 else ("E  ·  Alma ansprechen" if player_pos.distance_to(INTERIOR_CENTER + Vector2(0, -105)) < 130 else "")
	else:
		if player_pos.distance_to(TAVERN_HOUSE + Vector2(91, 157)) < 112: nearest = "E  ·  Zur Steinrose betreten"
		for index in DUNGEON_ENTRANCES.size():
			if player_pos.distance_to(LANDMARKS[int(DUNGEON_ENTRANCES[index])]["pos"] + Vector2(-30, 70)) < 84:
				nearest = "E  ·  %s betreten" % DUNGEON_NAMES[index]
				break
	if nearest != "":
		ui_box(Rect2(610, 549, 520, 36), Color("587767"))
		text_at(Vector2(623, 573), nearest.replace("E  ·", "%s  ·" % binding_short("interact")), 15, Color("fff4ca"))
	ui_box(Rect2(9, 592, 1134, 47), Color("354747"))
	text_at(Vector2(22, 615), "LAUFEN: %s/%s/%s/%s  ·  ANGRIFF: %s  ·  ROLLE: %s" % [binding_short("move_up"), binding_short("move_left"), binding_short("move_down"), binding_short("move_right"), binding_short("attack"), binding_short("dodge")], 12, Color("f0e4c5"))
	text_at(Vector2(22, 631), "%s Skills · %s Tasche · %s Quests · %s Karte · ENTER/T Chat" % [binding_short("skills"), binding_short("inventory"), binding_short("journal"), binding_short("map")], 11, Color("becfc6"))
	for slot in 4:
		var id: int = class_ultimate() if slot == 3 and level >= 20 else (int(slots[slot]) if slot < 3 else -1)
		var x := 694 + slot * 81
		ui_button(Rect2(x, 593, 75, 44), "", id >= 0, selected_slot == slot and panel == "skills")
		text_at(Vector2(x + 8, 629), binding_short("ability_%d" % (slot + 1)), 11, Color("ffe2a3") if id >= 0 else Color("a9aa9c"))
		if id >= 0:
			draw_skill_icon(Vector2(x + 24, 598), id, 30)
			if float(cooldowns[id]) > 0:
				draw_rect(Rect2(x + 3, 596, 68, 38), Color(0.1, 0.16, 0.2, 0.7))
				text_at(Vector2(x + 23, 620), "%.1f" % float(cooldowns[id]), 15)

func tracked_quest() -> String:
	if interior_id >= 0: return "Zur Steinrose · E an der Tür führt hinaus."
	if dungeon_id >= 0: return "%s · %d Feinde · Truhe am Ende" % [DUNGEON_NAMES[dungeon_id], enemies.size()]
	if rescue_state == 0: return "Mira: Folge dem östlichen Weg nach Blütenweiler."
	if rescue_state == 1: return "Blütenweiler retten · Dornenwesen %d/%d" % [rescue_kills, RESCUE_GOAL]
	if rescue_state == 2: return "Blütenweiler gerettet · Sprich mit Nela (E)."
	for i in QUESTS.size():
		if quests[i]["state"] == 2:
			return "%s · Abgabe bei %s" % [QUESTS[i]["title"], QUESTS[i]["npc"]]
	for i in QUESTS.size():
		if quests[i]["state"] == 1:
			return "%s · %d/%d" % [QUESTS[i]["title"], quests[i]["progress"], QUESTS[i]["count"]]
	return "Sprich mit Mira, Borin oder Liora im Dorf."

func draw_minimap(rect: Rect2, compact: bool) -> void:
	if compact:
		draw_local_minimap(rect)
		return
	draw_rect(rect, Color("283f44"))
	var inset := Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6))
	var sx := inset.size.x / WORLD.x
	var sy := inset.size.y / WORLD.y
	var palette := [Color("9bd783"), Color("9acf79"), Color("69aa81"), Color("b4ae90"), Color("68aab1"), Color("a5796d"), Color("dfca97"), Color("777591"), Color("a4c5b6"), Color("c9b477"), Color("80b6b2"), Color("898ca5"), Color("b6accc")]
	for zone in 13:
		var r := region_rect(zone)
		draw_rect(Rect2(inset.position + r.position * Vector2(sx, sy), r.size * Vector2(sx, sy)), palette[zone])
	draw_map_natural_edges(inset, palette)
	if not compact:
		for zone in 13:
			var center: Vector2 = inset.position + region_rect(zone).get_center() * Vector2(sx, sy)
			var color := Color("fff4cb") if region_available(zone) else Color("f9b4ca")
			var label_width := 82 if zone in [0, 6] else 160
			text_at(center + Vector2(-label_width / 2.0, -5), region_name(zone), 11 if zone in [0, 6] else 13, color, HORIZONTAL_ALIGNMENT_CENTER, label_width)
			text_at(center + Vector2(-label_width / 2.0, 12), "LV %d · %s" % [region_level(zone), "OFFEN" if region_available(zone) else "GESPERRT"], 10 if zone in [0, 6] else 12, color, HORIZONTAL_ALIGNMENT_CENTER, label_width)
		var gates := [Vector2(1780, 1120), Vector2(875, 2600), Vector2(1780, 6200), Vector2(2900, 4200), Vector2(5000, 1250), Vector2(5000, 6200), Vector2(6600, 4200), Vector2(8500, 1900), Vector2(8500, 6350), Vector2(9750, 4200)]
		var gate_levels := [1, 5, 8, 8, 15, 22, 22, 29, 36, 36]
		for gate_index in gates.size():
			var gate: Vector2 = gates[gate_index]
			var locked: bool = level < int(gate_levels[gate_index])
			if gate_index in [5, 6]: locked = locked or not bosses_defeated[0]
			if gate_index in [7, 8]: locked = locked or not bosses_defeated[1]
			var point: Vector2 = inset.position + gate * Vector2(sx, sy)
			draw_rect(Rect2(point - Vector2(4, 4), Vector2(8, 8)), Color("cf7795") if locked else Color("fff4bd"))
	else:
		pass

	for i in WAYSTONES.size():
		var point: Vector2 = inset.position + WAYSTONES[i] * Vector2(sx, sy)
		draw_rect(Rect2(point - Vector2(2, 2), Vector2(5, 5)), Color("94f3ed") if waystone_unlocked[i] else Color("68767a"))
	for portal in PORTALS:
		for end in [portal[0], portal[1]]:
			var point: Vector2 = inset.position + end * Vector2(sx, sy)
			draw_arc(point, 5, 0, TAU, 12, Color("f1d0f8") if region_available(int(portal[2])) else Color("a37178"), 2)
	if not compact:
		for landmark in LANDMARKS:
			var point: Vector2 = inset.position + landmark["pos"] * Vector2(sx, sy)
			draw_rect(Rect2(point - Vector2(3, 3), Vector2(6, 6)), Color("fff2c2"))
	for i in LANDMARKS.size():
		if not opened_chests[i]:
			var treasure_point: Vector2 = inset.position + chest_position(i) * Vector2(sx, sy)
			draw_rect(Rect2(treasure_point - Vector2(2, 2), Vector2(5, 5)), Color("ffe27b"))
	for npc in NPCS:
		var p: Vector2 = npc["pos"]
		draw_rect(Rect2(inset.position + p * Vector2(sx, sy) - Vector2(2, 2), Vector2(4, 4)), Color("fff1ac"))
	if rescue_state < 3:
		var rescue_marker: Vector2 = inset.position + RESCUE_POS * Vector2(sx, sy)
		draw_arc(rescue_marker, 6 if compact else 10, 0, TAU, 20, Color("ffb878"), 2)
	if not compact:
		for e in enemies:
			var p: Vector2 = e["pos"]
			draw_rect(Rect2(inset.position + p * Vector2(sx, sy) - Vector2(2, 2), Vector2(4, 4)), Color("e37c78"))
	var player_map := inset.position + player_pos * Vector2(sx, sy)
	draw_rect(Rect2(player_map - Vector2(4, 4), Vector2(8, 8)), Color.WHITE)
	for i in QUESTS.size():
		if quests[i]["state"] in [1, 2]:
			var target_pos: Vector2 = region_rect(int(ENEMY_TYPES[int(QUESTS[i]["target"])]["region"])).get_center() if quests[i]["state"] == 1 else npc_position(String(QUESTS[i]["npc"]))
			var marker: Vector2 = inset.position + target_pos * Vector2(sx, sy)
			draw_arc(marker, 6 if compact else 10, 0, TAU, 16, Color("ffdf7b"), 2)
			break
	if not compact:
		draw_rect(Rect2(inset.position + camera_pos * Vector2(sx, sy), VIEW * Vector2(sx, sy)), Color.WHITE, false, 2)

func region_available(zone: int) -> bool:
	if creative_mode: return true
	if level < region_level(zone): return false
	if zone == 4 and not bosses_defeated[0]: return false
	if zone == 5 and not bosses_defeated[1]: return false
	if zone == 7 and not bosses_defeated[1]: return false
	return true

func draw_local_minimap(rect: Rect2) -> void:
	if interior_id >= 0:
		var center := rect.get_center()
		draw_circle(center, 70, Color("c9a77a"))
		draw_circle(center, 64, Color("57443e"))
		draw_rect(Rect2(center + Vector2(-46, -43), Vector2(92, 85)), Color("927051"))
		draw_rect(Rect2(center + Vector2(-25, -35), Vector2(50, 8)), Color("c29b69"))
		var marker := center + (player_pos - INTERIOR_CENTER) * 0.09
		draw_circle(marker, 4, Color("ffefbd"))
		return
	if dungeon_id >= 0:
		draw_dungeon_minimap(rect)
		return
	MinimapRenderer.draw_world(self, rect)

func draw_dungeon_minimap(rect: Rect2) -> void:
	var center := rect.get_center()
	var radius := rect.size.x * 0.5 - 5.0
	draw_circle(center, radius + 4.0, Color("c2aa79"))
	draw_circle(center, radius, Color("16242e"))
	for gx in 13:
		for gy in 13:
			var tile := center + Vector2((gx - 6) * 10, (gy - 6) * 10)
			if tile.distance_to(center) > radius - 7.0: continue
			var world_point := player_pos + Vector2((gx - 6) * 65, (gy - 6) * 65)
			var seen := world_point.distance_to(player_pos) < 340
			for torch_pos in dungeon_torches():
				if world_point.distance_to(torch_pos) < 125: seen = true
			if seen:
				var tint := Color("687473") if not dungeon_blocked(world_point) else Color("394851")
				draw_rect(Rect2(tile - Vector2(5, 5), Vector2(10, 10)), tint)
	for enemy in enemies:
		if enemy["pos"].distance_to(player_pos) < 330:
			var enemy_point: Vector2 = center + (enemy["pos"] - player_pos) / 65.0 * 10.0
			if enemy_point.distance_to(center) < radius - 5.0: draw_circle(enemy_point, 2, Color("ed9b82"))
	for marker in [DUNGEON_CENTER + Vector2(-570, 0), DUNGEON_CENTER + Vector2(555, 0)]:
		if marker.distance_to(player_pos) < 350:
			var point: Vector2 = center + (marker - player_pos) / 65.0 * 10.0
			if point.distance_to(center) < radius - 5.0: draw_rect(Rect2(point - Vector2(3, 3), Vector2(6, 6)), Color("ffe0a0"))
	draw_circle(center, 4, Color.WHITE)
	draw_line(rect.get_center(), rect.get_center() + facing.normalized() * 10, Color("fff1ad"), 2)
	draw_arc(center, radius + 3.0, 0.0, TAU, 64, Color("f0d393"), 3)

func draw_portal(p: Vector2, region: int) -> void:
	var glow := Color("b6a5e9") if region_available(region) else Color("a76e73")
	draw_arc(p, 39, PI, TAU, 20, glow.darkened(0.45), 12)
	draw_arc(p, 34, PI, TAU, 20, glow, 5)
	draw_circle(p + Vector2(0, -14), 13 + sin(world_time * 2.0) * 2.0, Color(glow, 0.48))
	text_at(p + Vector2(-93, -59), "E · %s · LV %d" % [region_name(region), region_level(region)], 13, Color("fff0c7"), HORIZONTAL_ALIGNMENT_CENTER, 186)

func draw_map_natural_edges(inset: Rect2, palette: Array) -> void:
	var scale_map := inset.size / WORLD
	for boundary_x in [1780, 5000, 8500]:
		for y in range(0, 8500, 160):
			for dx in [-160, 0, 160]:
				var world_cell := Rect2(boundary_x + dx - 80, y, 160, 160)
				var zone := visual_region_at(world_cell.get_center())
				draw_rect(Rect2(inset.position + world_cell.position * scale_map, world_cell.size * scale_map), palette[zone])
	for boundary_y in [2600, 4200]:
		var end_x := 1780 if boundary_y == 2600 else 11000
		var start_x := 0 if boundary_y == 2600 else 1780
		for x in range(start_x, end_x, 160):
			for dy in [-160, 0, 160]:
				var world_cell := Rect2(x, boundary_y + dy - 80, 160, 160)
				var zone := visual_region_at(world_cell.get_center())
				draw_rect(Rect2(inset.position + world_cell.position * scale_map, world_cell.size * scale_map), palette[zone])

func npc_position(name: String) -> Vector2:
	for npc in NPCS:
		if npc["name"] == name: return npc["pos"]
	return Vector2(900, 1050)

func draw_panel() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.06, 0.11, 0.15, 0.76))
	draw_rect(Rect2(128, 72, 896, 544), Color("151e28"))
	ui_box(Rect2(135, 79, 882, 530), Color("40514d"))
	draw_rect(Rect2(164, 94, 824, 3), Color("c6a66e"))
	draw_rect(Rect2(164, 598, 824, 2), Color("9d845e"))
	for index in 7:
		draw_rect(Rect2(172 + index * 116, 101, 5, 5), Color("c6aa79", 0.6))
	if panel not in ["start", "creation", "multiplayer", "arena_reward", "victory"]: ui_button(Rect2(965, 91, 41, 35), "X")
	match panel:
		"start": draw_start_panel()
		"creation": draw_creation_panel()
		"multiplayer": draw_multiplayer_panel()
		"intro": draw_intro_panel()
		"pause": draw_pause_panel()
		"controls": draw_controls_panel()
		"skills": draw_skills_panel()
		"inventory": draw_inventory_panel()
		"shop": draw_shop_panel()
		"travel": draw_travel_panel()
		"journal": draw_journal_panel()
		"map": draw_map_panel()
		"mechanics": draw_mechanics_panel()
		"arena_entry": draw_arena_entry_panel()
		"arena_reward": draw_arena_reward_panel()
		"victory": draw_victory_panel()

func draw_mechanics_panel() -> void:
	text_at(Vector2(190,126), "MECHANIK-ÜBERSICHT", 28, Color('ffe1a0'))
	text_at(Vector2(770,126), "H · öffnen/schließen", 12, Color('aebfb9'))
	var labels: Array[String] = ["REGIONEN","QUESTS","SKILLS","KOOP & CHAT"]
	for tab in 4:
		ui_button(Rect2(190 + tab*195,142,180,38), labels[tab], true, mechanics_page == tab)
	if mechanics_page == 0:
		text_at(Vector2(190,211), "Regionen: Mindestlevel · typische Gegner · Freischaltung", 16, Color('e9cc90'))
		for i in 13:
			var col: int = int(i / 7.0)
			var row: int = i % 7
			var x: float = 190.0 + col*405.0
			var y: float = 242.0 + row*42.0
			var mob_text: String = ""
			for e in ENEMY_TYPES.size():
				if int(ENEMY_TYPES[e]["region"]) == i and e not in [12,13,14]:
					if mob_text != "": mob_text += ", "
					mob_text += str(ENEMY_TYPES[e]["name"])
			var status: String = "OFFEN" if region_available(i) else "GESPERRT"
			text_at(Vector2(x,y), "%02d  %s · LV %d · %s" % [i+1,region_name(i),region_level(i),status], 14, Color('dff0d9') if status == "OFFEN" else Color('d6a5a5'))
			text_at(Vector2(x+18,y+17), mob_text.substr(0,42), 11, Color('aebfb9'), HORIZONTAL_ALIGNMENT_LEFT, 370)
	elif mechanics_page == 1:
		text_at(Vector2(190,211), "Questablauf: NPC ansprechen → Ziel erfüllen → zurück zum NPC → Belohnung", 16, Color('e9cc90'))
		var states: Array[String] = ["NEU","AKTIV","ABGABE","FERTIG"]
		for i in mini(10, QUESTS.size()):
			var q: Dictionary = QUESTS[i]
			var st: int = int(quests[i]["state"]) if i < quests.size() else 0
			var prog: int = int(quests[i]["progress"]) if i < quests.size() else 0
			text_at(Vector2(190,246+i*31), "%02d · %s" % [i+1,str(q["title"])], 14, Color('f1e6c8'))
			text_at(Vector2(620,246+i*31), "%s · %d/%d · %s" % [states[clampi(st,0,3)],prog,int(q["count"]),str(q["npc"])], 13, Color('b9d9cf'))
		text_at(Vector2(190,575), "%d Quests insgesamt · Questbuch: J" % QUESTS.size(), 13, Color('aebfb9'))
	elif mechanics_page == 2:
		text_at(Vector2(190,211), "Skills: Freischalten mit Level + Skillpunkten · 3 Slots + Klassenfähigkeit auf 4", 16, Color('e9cc90'))
		var ids: Array = CLASS_SKILLS[class_id] + [CLASS_ULTIMATES[class_id]]
		for i in ids.size():
			var id: int = int(ids[i])
			var a: Dictionary = ABILITIES[id]
			var rank: int = int(skill_levels[id]) if id < skill_levels.size() else 0
			var col: int = int(i / 5.0)
			var row: int = i % 5
			var x: float = 190.0 + col*405.0
			var y: float = 250.0 + row*58.0
			draw_skill_sprite(id,Vector2(x,y-20),28)
			text_at(Vector2(x+38,y), "%s · Rang %d · ab LV %d" % [str(a["name"]),rank,int(a["req"])], 13, Color('e5ecd9'))
			text_at(Vector2(x+38,y+17), "%s" % str(a["desc"]), 11, Color('aebfb9'), HORIZONTAL_ALIGNMENT_LEFT, 345)
		text_at(Vector2(190,575), "Skillbuch: K · freie Skillpunkte: %d" % skill_points, 13, Color('ffe0a1'))
	else:
		text_at(Vector2(190,211), "Koop: 2–4 Spieler · Host erzeugt Einladungscode · Freund tritt mit Code bei", 16, Color('e9cc90'))
		text_at(Vector2(190,250), "Status: %s" % network_status, 14, Color('bfe7d4'), HORIZONTAL_ALIGNMENT_LEFT, 750)
		text_at(Vector2(190,286), "CHAT", 17, Color('ffe0a1'))
		text_at(Vector2(190,315), "ENTER oder T öffnet den Gruppenchat. ENTER sendet, ESC bricht ab.", 14, Color('e5ecd9'))
		text_at(Vector2(190,343), "Nachrichten zeigen den gespeicherten Charakternamen und werden an die Koop-Gruppe verteilt.", 13, Color('aebfb9'))
		text_at(Vector2(190,390), "SICHERHEITSZONE", 17, Color('ffe0a1'))
		text_at(Vector2(190,419), "Sonnenhain: keine normalen Spawns. Verfolgte Gegner ziehen sich zurück und verschwinden außerhalb.", 13, Color('dfe9dc'))
		text_at(Vector2(190,454), "SPAWNREGELN", 17, Color('ffe0a1'))
		text_at(Vector2(190,483), "Gegner erscheinen nicht auf Wegen, an NPCs, Wegsteinen, Portalen, Landmarken oder Gebäuden.", 13, Color('dfe9dc'))
		text_at(Vector2(190,512), "Normale Oberwelt: maximal 10 aktive Gegner, deutlich längeres Spawnintervall.", 13, Color('dfe9dc'))
	ui_button(Rect2(820,548,160,38), "SCHLIESSEN")

func draw_start_panel() -> void:
	text_at(Vector2(291, 151), "SONNENHAIN", 39, Color("ffe2aa"))
	text_at(Vector2(900, 148), GAME_VERSION, 16, Color("f4d7a3"))
	ui_button(Rect2(855, 158, 130, 33), "TASTEN")
	text_at(Vector2(295, 184), "Eine Reise durch die alten Reiche  ·  Wähle deinen Helden", 18, Color("dce7d8"))
	for i in 3:
		var card := Rect2(168 + i * 273, 202, 260, 170)
		ui_box(card, Color("545e5d") if pending_class == i else Color("3a4c4f"))
		draw_rect(Rect2(card.position + Vector2(10, 10), Vector2(240, 3)), [Color("d2a36e"), Color("9abce4"), Color("a5c88d")][i])
		text_at(card.position + Vector2(14, 35), CLASS_ADVANTAGES[i], 10, Color("9fe6ae"), HORIZONTAL_ALIGNMENT_LEFT, 232)
		text_at(card.position + Vector2(14, 52), CLASS_DISADVANTAGES[i], 10, Color("f0a09b"), HORIZONTAL_ALIGNMENT_LEFT, 232)
		draw_hero(Vector2(298 + i * 273, 286), 0.9, false, Vector2.DOWN, false, i)
		ui_button(Rect2(174 + i * 273, 330, 250, 38), CLASS_NAMES[i].to_upper(), true, pending_class == i)
	ui_button(Rect2(300, 378, 550, 54), "NEUES SPIEL  ·  Im gewählten Speicherplatz")
	ui_button(Rect2(300, 448, 550, 54), "GEWÄHLTEN SPIELSTAND LADEN", FileAccess.file_exists(slot_save_path(selected_save_slot)))
	ui_button(Rect2(860, 448, 125, 54), "KOOP")
	text_at(Vector2(168, 521), "SPEICHERPLATZ WÄHLEN", 14, Color("f6dfa9"))
	for index in 3:
		var card := Rect2(168 + index * 273, 530, 260, 57)
		ui_box(card, Color("627565") if selected_save_slot == index + 1 else Color("3a5251"))
		text_at(card.position + Vector2(11, 24), "SPIELSTAND %d" % (index + 1), 16, Color("fff0ce"))
		text_at(card.position + Vector2(11, 46), str(save_slot_labels[index]) if index < save_slot_labels.size() else "LEER", 14, Color("e0eacb"))

func draw_creation_panel() -> void:
	text_at(Vector2(270, 142), "CHARAKTER ERSTELLEN", 31, Color('ffe1a0'))
	text_at(Vector2(270, 172), "Name, Geschlecht und Rasse werden für diesen Spielstand fest gespeichert.", 15, Color('d8e6dc'))
	text_at(Vector2(270, 215), "NAME", 14, Color('e9cc90'))
	var name_box := Rect2(300, 228, 550, 48)
	draw_rect(name_box, Color('22363c'))
	draw_rect(name_box, Color('8ba49c'), false, 2)
	text_at(name_box.position + Vector2(14,31), (creation_name if creation_name != "" else "Name eingeben …") + ("_" if int(world_time*2.0)%2==0 else ""), 20, Color('fff0cf') if creation_name != "" else Color('9fb4ac'))
	text_at(Vector2(270, 292), "GESCHLECHT", 14, Color('e9cc90'))
	for i in 2:
		ui_button(Rect2(300 + i*210, 300, 195, 40), GENDER_NAMES[i].to_upper(), true, pending_gender == i)
	text_at(Vector2(270, 357), "RASSE", 14, Color('e9cc90'))
	for i in 3:
		ui_button(Rect2(245 + i*220, 365, 205, 44), RACE_NAMES[i].to_upper(), true, pending_race == i)
	ui_box(Rect2(905, 215, 220, 194), Color("34494b"))
	text_at(Vector2(918, 244), RACE_NAMES[pending_race].to_upper(), 16, Color("ffe1a0"))
	text_at(Vector2(918, 278), RACE_ADVANTAGES[pending_race], 11, Color("9fe6ae"), HORIZONTAL_ALIGNMENT_LEFT, 190)
	text_at(Vector2(918, 318), RACE_DISADVANTAGES[pending_race], 11, Color("f0a09b"), HORIZONTAL_ALIGNMENT_LEFT, 190)
	text_at(Vector2(918, 356), "Klasse: %s" % CLASS_NAMES[pending_class], 12, Color("d8e6dc"), HORIZONTAL_ALIGNMENT_LEFT, 190)
	# Vorschau der drei Klassen mit gewählter Rasse/Geschlecht.
	for cls in 3:
		var center := Vector2(350 + cls*225, 462)
		draw_character_sprite(center, cls, false, Vector2.DOWN, 1.0, false, pending_race, pending_gender)
		draw_weapon_world(center + Vector2(0,-5), cls, cls*4, Vector2.DOWN, 1.0)
		text_at(center + Vector2(-65,43), CLASS_NAMES[cls], 14, Color('eaf2df'), HORIZONTAL_ALIGNMENT_CENTER, 130)
	ui_button(Rect2(165, 520, 110, 52), "ZURÜCK")
	ui_button(Rect2(300, 520, 550, 52), "ABENTEUER STARTEN", creation_name.strip_edges().length() >= 2)
	text_at(Vector2(305, 592), "Rasse und Geschlecht verändern das Pixelmodell. Klasse wurde im Hauptmenü gewählt.", 12, Color('aebfb9'), HORIZONTAL_ALIGNMENT_CENTER, 540)

func draw_multiplayer_panel() -> void:
	text_at(Vector2(205, 150), "SONNENHAIN KOOP", 31, Color('ffe1a0'))
	var web_online := is_web_platform()
	if web_online:
		text_at(Vector2(205, 182), "Online-Multiplayer · Dedicated Server · Gruppenchat", 16, Color('d8e6dc'))
		text_at(Vector2(205, 215), "Freunde öffnen sonnenhainrpg.de und verbinden sich mit demselben Sonnenhain-Server.", 13, Color('b9cbc3'))
		ui_button(Rect2(205, 282, 740, 52), "MIT ONLINE-SERVER VERBINDEN", network_mode == "offline")
		text_at(Vector2(205, 365), "SERVER", 14, Color('e9cc90'))
		var server_box := Rect2(205, 378, 740, 56)
		draw_rect(server_box, Color('20343a'))
		draw_rect(server_box, Color('8ba49c'), false, 2)
		text_at(server_box.position + Vector2(14,36), network_server_url, 18, Color('fff0cf'))
		text_at(Vector2(205, 511), network_status, 13, Color('bfe7d4'), HORIZONTAL_ALIGNMENT_LEFT, 740)
		ui_button(Rect2(205, 520, 200, 46), "ZURÜCK")
		var can_join := network_mode == "client" and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
		ui_button(Rect2(605, 520, 340, 46), "WELT BEITRETEN", can_join)
		text_at(Vector2(205, 586), "Browser-Multiplayer läuft über WSS. Kein Spieler muss selbst hosten oder Ports freigeben.", 12, Color('aebfb9'), HORIZONTAL_ALIGNMENT_LEFT, 740)
		return
	text_at(Vector2(205, 182), "2–4 Spieler · Peer-to-Peer · Einladungscode · Gruppenchat", 16, Color('d8e6dc'))
	text_at(Vector2(205, 215), "Desktop-LAN/ENet bleibt für lokale Tests erhalten.", 13, Color('b9cbc3'))
	ui_button(Rect2(205, 282, 340, 52), "SPIEL HOSTEN")
	ui_button(Rect2(605, 282, 340, 52), "MIT CODE BEITRETEN", join_code.length() > 4)
	text_at(Vector2(205, 365), "EINLADUNGSCODE", 14, Color('e9cc90'))
	var code_box := Rect2(205, 378, 740, 56)
	draw_rect(code_box, Color('20343a'))
	draw_rect(code_box, Color('8ba49c'), false, 2)
	var shown := invite_code if network_mode == "host" and invite_code != "" else join_code
	text_at(code_box.position + Vector2(14,36), (shown if shown != "" else "SH-…  Code hier eintippen") + ("_" if network_mode != "host" and int(world_time*2.0)%2==0 else ""), 22, Color('fff0cf'))
	ui_button(Rect2(205, 454, 740, 46), "CODEFELD LEEREN")
	text_at(Vector2(205, 511), network_status, 13, Color('bfe7d4'), HORIZONTAL_ALIGNMENT_LEFT, 740)
	ui_button(Rect2(205, 520, 200, 46), "ZURÜCK")
	var can_start := network_mode == "host" or (network_mode == "client" and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED)
	ui_button(Rect2(605, 520, 340, 46), "WELT STARTEN" if network_mode == "host" else "WELT BEITRETEN", can_start)
	text_at(Vector2(205, 586), "LAN-Test: UDP %d. Online-Browser-Spieler nutzen den Dedicated Server.", 12, Color('aebfb9'), HORIZONTAL_ALIGNMENT_LEFT, 740)

func draw_pause_panel() -> void:
	text_at(Vector2(300, 158), "PAUSE", 35, Color("ffeda9"))
	text_at(Vector2(302, 190), "Level %d · %s · %d Gold" % [level, region_name(region_at(player_pos)), gold], 17, Color("e6f0dc"))
	ui_button(Rect2(300, 221, 550, 42), "FORTSETZEN")
	ui_button(Rect2(860, 221, 130, 42), "TASTEN")
	ui_button(Rect2(860, 270, 130, 42), "MECHANIK")
	ui_button(Rect2(300, 270, 550, 42), "TESTSTAND SPEICHERN" if creative_mode else "SPIEL SPEICHERN")
	draw_volume_slider(Vector2(300, 326), "MUSIK", music_volume, Color("d9b67b"))
	draw_volume_slider(Vector2(300, 380), "EFFEKTE", effects_volume, Color("9bcfd0"))
	ui_button(Rect2(300, 432, 550, 42), "TESTMODUS VERLASSEN" if creative_mode else "TESTMODUS STARTEN")
	if creative_mode:
		text_at(Vector2(302, 504), "LEVEL %d · %d Skillpunkte" % [level, skill_points], 14, Color("fff0bd"))
		for index in 4:
			ui_button(Rect2(300 + index * 113, 510, 105, 38), ["-10", "-1", "+1", "+10"][index])
		ui_button(Rect2(762, 510, 180, 38), "REISEN")
	text_at(Vector2(302, 488), pause_status, 13, Color("ffe5ab"), HORIZONTAL_ALIGNMENT_LEFT, 630)
	ui_button(Rect2(300, 563, 550, 35), "SPEICHERN & ZUM HAUPTMENÜ")

func draw_controls_panel() -> void:
	text_at(Vector2(170, 153), "TASTENBELEGUNG", 29, Color("ffdf9f"))
	text_at(Vector2(172, 179), "Belegung anklicken · Taste oder Maustaste drücken · ESC bricht die Auswahl ab", 14, Color("e3e9d8"))
	for index in BIND_ACTIONS.size():
		var column := int(index / 10.0)
		var row := index % 10
		var x := 170 + column * 420
		var y := 195 + row * 34
		var action: String = BIND_ACTIONS[index]
		var active := awaiting_bind == action
		draw_rect(Rect2(x, y, 390, 30), Color("607666") if active else (Color("354a4a") if row % 2 == 0 else Color("3c5250")))
		text_at(Vector2(x + 9, y + 21), BIND_NAMES[index], 15, Color("ffefd3"))
		draw_rect(Rect2(x + 234, y + 3, 155, 25), Color("ad8b53") if active else Color("89745a"))
		draw_rect(Rect2(x + 236, y + 5, 151, 21), Color("735b3d") if active else Color("253b3d"))
		text_at(Vector2(x + 240, y + 21), "DRÜCKEN …" if active else binding_label(action), 13, Color("ffe5a7") if active else Color("dbe9d5"), HORIZONTAL_ALIGNMENT_CENTER, 143)
	text_at(Vector2(174, 549), controls_status.substr(0, 105), 13, Color("ffe3a5"), HORIZONTAL_ALIGNMENT_LEFT, 810)
	ui_button(Rect2(175, 562, 385, 36), "STANDARD WIEDERHERSTELLEN")
	ui_button(Rect2(585, 562, 385, 36), "ZURÜCK")

func draw_arena_entry_panel() -> void:
	text_at(Vector2(263, 161), "ARVENS PRÜFUNG", 30, Color("ffe1a0"))
	text_at(Vector2(265, 201), "Endlose Wellen werden stärker und zahlreicher.", 18, Color("e5ebd8"))
	text_at(Vector2(265, 229), "Kein Gegner-Loot · Beim Tod erhältst du eine Belohnungskiste.", 16, Color("d7e6d2"))
	text_at(Vector2(265, 257), "Bestleistung: Welle %d" % arena_best, 17, Color("ffe3a7"))
	for index in mini(4, arena_leaderboard.size()):
		var record: Dictionary = arena_leaderboard[index]
		text_at(Vector2(270, 293 + index * 22), "%d.  Welle %d   ·   LV %d %s" % [index + 1, int(record["wave"]), int(record["level"]), str(record["class"])], 14, Color("ead9bb"))
	ui_button(Rect2(307, 391, 260, 48), "ENDLOSE ARENA")
	ui_button(Rect2(585, 391, 260, 48), "FINALE ERNEUT", bosses_defeated.count(true) == 3 and not final_completed)
	text_at(Vector2(265, 474), "Das Finale beginnt automatisch nach dem letzten Boss. Arven hilft bei einem neuen Versuch.", 14, Color("bcd2c9"), HORIZONTAL_ALIGNMENT_LEFT, 690)

func draw_arena_reward_panel() -> void:
	text_at(Vector2(255, 154), "DIE PRÜFUNG IST VORBEI", 28, Color("ffe0a2"))
	text_at(Vector2(260, 190), "Erreicht: Welle %d  ·  Bestleistung: %d" % [arena_reward_wave, arena_best], 19, Color("d9e8dd"))
	text_at(Vector2(260, 225), "Arvens Truhe wartet auf dich. Ihre Stärke folgt deinem Level und deiner Welle.", 16, Color("edddba"))
	draw_chest(Vector2(760, 321), arena_reward_claimed)
	text_at(Vector2(260, 266), "BESTENLISTE", 17, Color("f3d393"))
	for index in mini(10, arena_leaderboard.size()):
		var record: Dictionary = arena_leaderboard[index]
		text_at(Vector2(265, 290 + index * 19), "%d. Welle %d · LV %d %s" % [index + 1, int(record["wave"]), int(record["level"]), str(record["class"])], 13, Color("dce7d9"))
	ui_button(Rect2(307, 510, 260, 48), "TRUHE GEÖFFNET" if arena_reward_claimed else "TRUHE ÖFFNEN", not arena_reward_claimed)
	ui_button(Rect2(585, 510, 260, 48), "ZURÜCK INS DORF", arena_reward_claimed)

func draw_victory_panel() -> void:
	text_at(Vector2(284, 172), "SONNENHAIN IST GERETTET", 31, Color("ffdf96"))
	text_at(Vector2(285, 218), "Zehn Wellen. Ein letzter Widerstand. Die Siegel schweigen.", 18, Color("e8ecdb"))
	text_at(Vector2(285, 265), "Als du auf den Dorfplatz zurückkehrst, läuten die Glocken wieder.", 17, Color("e8ecdb"))
	text_at(Vector2(285, 297), "Mira, Borin, Liora und alle Bewohner jubeln dir zu.", 17, Color("e8ecdb"))
	for confetti in 26:
		var point := Vector2(235 + confetti * 27, 352 + sin(float(confetti) * 1.8 + world_time) * 29)
		draw_rect(Rect2(point, Vector2(6, 6)), [Color("f7d48b"), Color("a4ded3"), Color("eab0c7")][confetti % 3])
	text_at(Vector2(300, 421), "HAUPTGESCHICHTE ABGESCHLOSSEN", 22, Color("ffe2a7"))
	ui_button(Rect2(350, 491, 450, 54), "FREIEN MODUS BETRETEN")

func draw_volume_slider(origin: Vector2, label: String, value: float, tint: Color) -> void:
	text_at(origin, "%s  %d %%" % [label, roundi(value * 100)], 16, Color("f9ecd0"))
	var rail := Rect2(origin + Vector2(15, 12), Vector2(520, 11))
	draw_rect(rail.grow(3), Color("17232a"))
	draw_rect(rail, Color("586363"))
	draw_rect(Rect2(rail.position, Vector2(rail.size.x * value, rail.size.y)), tint)
	var knob := rail.position + Vector2(rail.size.x * value, rail.size.y * 0.5)
	draw_rect(Rect2(knob - Vector2(6, 12), Vector2(12, 24)), Color("fff0ce"))
	draw_rect(Rect2(knob - Vector2(3, 9), Vector2(6, 18)), tint.darkened(0.15))

func draw_intro_panel() -> void:
	var page := 0 if intro_timer > 5.3 else (1 if intro_timer > 2.7 else 2)
	var lines := [
		["SONNENHAIN", "Vor drei Nächten verstummten die Glocken im Blütenweiler."],
		["DER WEG NACH OSTEN", "Rauch steigt zwischen den Feldern auf. Niemand ist zurückgekehrt."],
		["DEINE REISE BEGINNT", "Mira wartet am Dorfplatz. Sie weiß, wo die ersten Spuren liegen."]]
	text_at(Vector2(230, 218), "KAPITEL I  ·  DIE STUMME GLOCKE", 21, Color("d9bc86"))
	text_at(Vector2(230, 287), String(lines[page][0]), 34, Color("fff1c8"))
	text_at(Vector2(230, 337), String(lines[page][1]), 18, Color("e4eadb"))
	draw_rect(Rect2(230, 365, 675, 3), Color("c3a673"))
	text_at(Vector2(230, 413), "E / Leertaste / Klick: Überspringen", 15, Color("c7d4ca"))

func draw_skills_panel() -> void:
	text_at(Vector2(165, 125), "%s · FÄHIGKEITEN" % CLASS_NAMES[class_id].to_upper(), 26, Color("ffeda9"))
	text_at(Vector2(670, 124), "%d SKILLPUNKTE" % skill_points, 20, Color("f6dc9a"))
	for slot in 3:
		var id: int = int(slots[slot])
		var name := "Frei" if id < 0 else String(ABILITIES[id]["name"])
		ui_button(Rect2(165 + slot * 204, 148, 193, 44), "%d: %s" % [slot + 1, name], true, selected_slot == slot)
	text_at(Vector2(169, 205), "Links: Fähigkeit ausrüsten · Rechts: Rang mit Skillpunkt verbessern (max. 5)", 15, Color("daebce"))
	for row in 7:
		var class_list: Array = CLASS_SKILLS[class_id]
		if row + menu_scroll >= class_list.size(): break
		var id: int = int(class_list[row + menu_scroll])
		var a: Dictionary = ABILITIES[id]
		var y := 215 + row * 44
		var unlocked: bool = learned[id]
		var requirement: int = a["req"]
		var selected := id in slots
		var can_upgrade: bool = skill_points > 0 and int(skill_levels[id]) < 5 and (creative_mode or level >= skill_rank_level(id, int(skill_levels[id]) + 1))
		ui_box(Rect2(165, y, 815, 40), Color("608273") if selected else (Color("496a61") if can_upgrade else Color("3c4d51")))
		draw_skill_icon(Vector2(174, y + 5), id, 29)
		text_at(Vector2(212, y + 25), String(a["name"]), 16, Color("fff1bc") if unlocked else Color("cbd8c9"), HORIZONTAL_ALIGNMENT_LEFT, 177)
		for star in 5:
			var lit := star < int(skill_levels[id])
			var star_color := (Color("8bdcf5") if class_id == 1 else Color("ffdc87")) if lit else Color("78858b")
			draw_skill_star(Vector2(396 + star * 16, y + 20), star_color, lit)
		text_at(Vector2(486, y + 25), String(a["desc"]), 13, Color("e4edd6") if unlocked else Color("bac6c2"), HORIZONTAL_ALIGNMENT_LEFT, 335)
		var state := "+ RANG" if unlocked else "+ LERNEN"
		var rank_level := skill_rank_level(id, int(skill_levels[id]) + 1)
		if not creative_mode and level < rank_level: state = "AB LV %d" % rank_level
		if int(skill_levels[id]) >= 5: state = "MAX"
		if skill_points == 0 and state.begins_with("+"): state = "PUNKT FEHLT"
		text_at(Vector2(838, y + 25), state, 13, Color("9de6c2") if can_upgrade else Color("afbec2"), HORIZONTAL_ALIGNMENT_LEFT, 135)
	text_at(Vector2(172, 572), "Ab Level 20: feste Klassenfähigkeit auf Taste 4 · %s" % ABILITIES[class_ultimate()]["name"], 15, Color("d9e6d5"))
	draw_skill_icon(Vector2(907, 110), class_ultimate(), 36)

func draw_skill_star(center: Vector2, tint: Color, lit: bool) -> void:
	if lit: draw_rect(Rect2(center - Vector2(7, 7), Vector2(14, 14)), Color(tint, 0.2))
	draw_rect(Rect2(center + Vector2(-2, -6), Vector2(5, 13)), tint)
	draw_rect(Rect2(center + Vector2(-6, -2), Vector2(13, 5)), tint)
	draw_rect(Rect2(center + Vector2(-4, -4), Vector2(9, 9)), tint.darkened(0.15))
	if lit: draw_rect(Rect2(center + Vector2(-2, -3), Vector2(3, 3)), Color("fff8da"))

func draw_inventory_panel() -> void:
	text_at(Vector2(165, 125), "INVENTAR", 26, Color("ffeda9"))
	text_at(Vector2(758, 125), "%d / 42  ·  %d GOLD" % [inventory.size(), gold], 17, Color("f6dc9a"))
	ui_box(Rect2(165, 153, 450, 426), Color("365b5d"))
	text_at(Vector2(183, 180), "DEIN HELD · LEVEL %d" % level, 19, Color("ffeda9"))
	# Die Figur steht groß zwischen genau drei Ausrüstungsplätzen.
	draw_rect(Rect2(296, 211, 195, 288), Color("294b52"))
	draw_rect(Rect2(302, 217, 183, 276), Color("55746c"))
	draw_rect(Rect2(337, 457, 113, 12), Color("1f3d43", 0.5))
	draw_hero(Vector2(395, 370), 2.0, false, Vector2.DOWN)
	draw_equipment_slot(Vector2(180, 275), "WAFFE", equipped_uid, class_weapon_icon())
	draw_equipment_slot(Vector2(501, 235), "RÜSTUNG", equipped_armor_uid, "armor")
	draw_equipment_slot(Vector2(501, 347), "RING 1", equipped_ring_uid, "ring")
	if class_id == 1:
		draw_equipment_slot(Vector2(501, 437), "RING 2", equipped_ring2_uid, "ring")
	text_at(Vector2(186, 534), "HP %d  ·  ANGRIFF %d  ·  SCHUTZ %d" % [int(max_hp()), normal_attack_power(), equipment_power(equipped_armor_uid)], 15, Color("e6efdd"))
	ui_box(Rect2(625, 153, 352, 426), Color("365b5d"))
	text_at(Vector2(644, 179), "TASCHE", 19, Color("ffeda9"))
	text_at(Vector2(807, 179), "%d/2" % (inventory_page + 1), 16)
	ui_button(Rect2(850, 157, 32, 30), "<", inventory_page > 0)
	ui_button(Rect2(931, 157, 32, 30), ">", inventory_page < 1)
	for cell in 25:
		var i := inventory_page * 25 + cell
		var col := cell % 5
		var row := cell / 5
		var pos := Vector2(641 + col * 65, 200 + row * 55)
		var is_equipped := i < inventory.size() and int(inventory[i]["uid"]) in equipped_item_uids()
		draw_rect(Rect2(pos, Vector2(54, 48)), Color("ffdda0") if is_equipped else (Color("e3c78c") if i == selected_item else Color("263f43")))
		draw_rect(Rect2(pos + Vector2(3, 3), Vector2(48, 42)), Color("496b62"))
		if i < inventory.size():
			var item: Dictionary = inventory[i]
			if ItemProtection.is_protected(item):
				var protect_glow := 0.72 + sin(world_time * 5.0) * 0.20
				draw_rect(Rect2(pos - Vector2(2, 2), Vector2(58, 52)), Color(1.0, 0.12, 0.18, protect_glow), false, 3.0)
			draw_rect(Rect2(pos + Vector2(3, 3), Vector2(48, 4)), RARITY_COLORS[int(item["rarity"])])
			draw_item_icon(pos + Vector2(11, 9), String(item["icon"]), RARITY_COLORS[int(item["rarity"])], 0.88, weapon_visual_stage(item), item_design(item))
			draw_item_signature(pos + Vector2(11, 9), item)
			if int(item.get("count", 1)) > 1:
				draw_rect(Rect2(pos + Vector2(19, 32), Vector2(32, 14)), Color("1d2d35"))
				text_at(pos + Vector2(20, 44), "×%d" % int(item["count"]), 12, Color("fff2ce"))
			if is_equipped: text_at(pos + Vector2(31, 42), "AN", 11, Color("fff2a6"))
	if selected_item >= 0 and selected_item < inventory.size():
		var item: Dictionary = inventory[selected_item]
		text_at(Vector2(643, 491), String(item["name"]), 17, RARITY_COLORS[int(item["rarity"])], HORIZONTAL_ALIGNMENT_LEFT, 310)
		var detail := "%s · %s · %d Gold" % [RARITY_NAMES[int(item["rarity"])], item_type(String(item["icon"])), item_sale_value(item)]
		if item["icon"] in ["sword", "staff", "bow", "armor", "ring"]: detail += " · +%d" % int(item["power"])
		if ItemProtection.is_protected(item): detail += " · GESCHÜTZT"
		text_at(Vector2(643, 518), detail, 13, Color("ff7c83") if ItemProtection.is_protected(item) else Color("e5eddd"), HORIZONTAL_ALIGNMENT_LEFT, 320)
		ui_button(Rect2(643, 538, 320, 42), "BENUTZEN / AUSRÜSTEN", item["icon"] in ["potion", class_weapon_icon(), "armor", "ring"])
	else:
		text_at(Vector2(643, 508), "Wähle einen Gegenstand aus der Tasche.", 14, Color("dbe8d5"))
	var mouse := get_viewport().get_mouse_position()
	for cell in 25:
		var index := inventory_page * 25 + cell
		if index < inventory.size() and Rect2(641 + cell % 5 * 65, 200 + int(cell / 5.0) * 55, 54, 48).has_point(mouse):
			draw_item_tooltip(inventory[index], Vector2(374, clampf(mouse.y - 35, 170, 374)))
			break

func draw_item_tooltip(item: Dictionary, pos: Vector2, purchase_price: int = -1) -> void:
	ui_box(Rect2(pos, Vector2(246, 190)), Color("354a4a"))
	draw_rect(Rect2(pos + Vector2(7, 7), Vector2(232, 3)), RARITY_COLORS[int(item["rarity"])])
	draw_item_icon(pos + Vector2(15, 22), String(item["icon"]), RARITY_COLORS[int(item["rarity"])], 1.0, weapon_visual_stage(item), item_design(item))
	draw_item_signature(pos + Vector2(15, 22), item)
	text_at(pos + Vector2(55, 38), String(item["name"]).substr(0, 19), 15, RARITY_COLORS[int(item["rarity"])])
	text_at(pos + Vector2(14, 66), "%s · %s · LV %d" % [RARITY_NAMES[int(item["rarity"])], item_type(String(item["icon"])), int(item.get("level", 1))], 13, Color("e2ebde"))
	var icon: String = item["icon"]
	var equipped := equipped_uid if icon in ["sword", "bow", "staff"] else (equipped_armor_uid if icon == "armor" else (equipped_ring_uid if icon == "ring" else -1))
	var current := equipment_power(equipped)
	var worn: Dictionary = {}
	for candidate in inventory:
		if int(candidate.get("uid", -1)) == equipped:
			worn = candidate
			break
	if icon in ["sword", "staff", "bow", "armor", "ring"]:
		var diff := int(item["power"]) - current
		var color := Color("83e4a0") if diff > 0 else (Color("ee8a86") if diff < 0 else Color("dfdcc3"))
		var stat_name := "Schaden" if icon in ["sword", "staff", "bow"] else ("Schutz" if icon == "armor" else "Leben")
		text_at(pos + Vector2(14, 93), "%s %d   %s%d" % [stat_name, int(item["power"]), "▲ +" if diff > 0 else ("▼ " if diff < 0 else "= "), diff], 14, color)
	if icon in ["potion", "gem", "herb", "essence"]:
		var effect_name: String = "%s +65" % ("Mana" if class_id == 1 else "Energie") if String(item["name"]) in ["Energietrank", "Manatrank"] else ("HP +90" if String(item["name"]) == "Großer Heiltrank" else ("HP +45" if icon == "potion" else "Wertvolles Material"))
		text_at(pos + Vector2(14, 120), effect_name, 14, Color("bfe4d8"))
		text_at(pos + Vector2(14, 145), "Im Stapel: %d / %s" % [int(item.get("count", 1)), "16" if icon == "potion" else "∞"], 13, Color("dfdcc3"))
	else:
		text_at(pos + Vector2(14, 120), "STÄ %d   BEW %d   INT %d" % [int(item.get("str", 0)), int(item.get("agi", 0)), int(item.get("int", 0))], 14, Color("bfe4d8"))
		var primary_key: String = ["str", "int", "agi"][class_id]
		var attribute_diff := int(item.get(primary_key, 0)) - int(worn.get(primary_key, 0))
		var arrow := "▲ +" if attribute_diff > 0 else ("▼ " if attribute_diff < 0 else "= ")
		text_at(pos + Vector2(14, 145), "%s für %s: %s%d" % [primary_key.to_upper(), CLASS_NAMES[class_id], arrow, attribute_diff], 13, Color("83e4a0") if attribute_diff > 0 else (Color("ee8a86") if attribute_diff < 0 else Color("dfdcc3")))
	var price_text := "Kaufpreis: %d Gold" % purchase_price if purchase_price >= 0 else "Verkauf: %d Gold" % item_sale_value(item)
	text_at(pos + Vector2(14, 171), price_text, 13, Color("f0d69b"))

func draw_item_signature(p: Vector2, item: Dictionary) -> void:
	var signature := absi(String(item["name"]).hash())
	var tint: Color = element_color(String(item.get("element", ""))) if str(item.get("element", "")) != "" else RARITY_COLORS[int(item["rarity"])]
	var center := p + Vector2(27, 25)
	match signature % 4:
		0: draw_circle(center, 4, tint)
		1: draw_colored_polygon(PackedVector2Array([center + Vector2(0,-6),center + Vector2(5,0),center + Vector2(0,6),center + Vector2(-5,0)]), tint)
		2:
			draw_line(center + Vector2(-5,-5), center + Vector2(5,5), tint, 3)
			draw_line(center + Vector2(-5,5), center + Vector2(5,-5), tint, 3)
		3: draw_arc(center, 5, 0, TAU, 12, tint, 3)

func draw_equipment_slot(p: Vector2, label: String, uid: int, icon: String) -> void:
	draw_rect(Rect2(p, Vector2(98, 77)), Color("e9cd90") if uid >= 0 else Color("294a4c"))
	draw_rect(Rect2(p + Vector2(3, 3), Vector2(92, 71)), Color("52756b"))
	var item: Dictionary = {}
	for candidate in inventory:
		if int(candidate.get("uid", -1)) == uid:
			item = candidate
			break
	if not item.is_empty():
		draw_item_icon(p + Vector2(33, 4), icon, RARITY_COLORS[int(item["rarity"])], 0.82, weapon_visual_stage(item), item_design(item))
		text_at(p + Vector2(5, 52), String(item["name"]).substr(0, 13), 11, RARITY_COLORS[int(item["rarity"])])
	else:
		text_at(p + Vector2(36, 35), "–", 19, Color("b6c8b9"))
		text_at(p + Vector2(8, 52), "Leer", 11, Color("b6c8b9"))
	text_at(p + Vector2(9, 66), label, 12, Color("fff0c3"))

func item_type(icon: String) -> String:
	match icon:
		"sword": return "Waffe"
		"staff": return "Stab"
		"bow": return "Bogen"
		"potion": return "Trank"
		"gem": return "Kristall"
		"ring": return "Schmuck"
		"armor": return "Rüstung"
		"herb": return "Kräuter"
		_: return "Gegenstand"

func element_color(element: String) -> Color:
	match element:
		"feuer": return Color("ff9147")
		"eis": return Color("a3e9fb")
		"blitz": return Color("ffe480")
		"gift": return Color("b3e978")
		_: return Color("f5e9cc")

func draw_skill_icon(p: Vector2, id: int, size: float) -> void:
	var box := Rect2(p, Vector2(size,size))
	draw_rect(box, Color('253b46'))
	if skill_sprites != null:
		draw_skill_sprite(id, p + Vector2(2,2), size - 4.0)
	else:
		draw_rect(box.grow(-3), Color('6b8190'))
	var border := Color('f2cf83') if id == class_ultimate() else Color('8fa7a3')
	draw_rect(box, border, false, 2)

func draw_shop_panel() -> void:
	var shop_name := "TORVALD (SCHMIED)" if merchant_kind == "smith" else ("PIP (ALCHEMIST)" if merchant_kind == "alchemy" else "FENNA (HÄNDLERIN)")
	text_at(Vector2(165, 125), shop_name, 25, Color("ffeda9"))
	text_at(Vector2(804, 126), "%d GOLD" % gold, 17, Color("f9dba0"))
	text_at(Vector2(169, 174), "KAUFEN · Neues Angebot in %d:%02d" % [int((420.0 - shop_timer) / 60.0), int(420.0 - shop_timer) % 60], 17, Color("e8f2de"))
	var stock: Array = shop_stock[merchant_kind]
	for i in stock.size():
		var item: Dictionary = stock[i]
		var pos := Vector2(168 + i * 258, 210)
		ui_box(Rect2(pos, Vector2(245, 125)), Color("4b6f64"))
		draw_item_icon(pos + Vector2(14, 31), String(item["icon"]), RARITY_COLORS[int(item.get("rarity", 1))], 1.18, weapon_visual_stage(item), item_design(item))
		draw_item_signature(pos + Vector2(14, 31), item)
		text_at(pos + Vector2(58, 52), String(item["name"]), 15, Color("fff1cf"), HORIZONTAL_ALIGNMENT_LEFT, 178)
		var stat_label := "Schaden" if item["icon"] in ["sword", "staff", "bow"] else ("Rüstung" if item["icon"] == "armor" else "Leben")
		if int(item["power"]) > 0: text_at(pos + Vector2(58, 77), "+%d %s" % [item["power"], stat_label], 14, Color("d3eacb"))
		if str(item.get("element", "")) != "": text_at(pos + Vector2(58, 96), "%s-Schaden" % str(item["element"]).capitalize(), 13, element_color(str(item["element"])))
		text_at(pos + Vector2(58, 119), "%d Gold%s" % [int(item["price"]), " · SPAREN" if int(item["price"]) > 500 + level * 50 else ""], 14, Color("f4d18c"))
	text_at(Vector2(169, 378), "VERKAUFEN · Gegenstand wählen, dann rechts unten bestätigen", 17, Color("e8f2de"))
	for i in inventory.size():
		var col := i % 11
		var row := i / 11
		var pos := Vector2(170 + col * 72, 397 + row * 40)
		draw_rect(Rect2(pos, Vector2(47, 37)), Color("dfbf83") if selected_item == i else Color("2c4749"))
		if ItemProtection.is_protected(inventory[i]):
			var protect_glow := 0.72 + sin(world_time * 5.0) * 0.20
			draw_rect(Rect2(pos - Vector2(2, 2), Vector2(51, 41)), Color(1.0, 0.12, 0.18, protect_glow), false, 3.0)
		draw_item_icon(pos + Vector2(10, 3), String(inventory[i]["icon"]), RARITY_COLORS[int(inventory[i]["rarity"])], 0.85, weapon_visual_stage(inventory[i]), item_design(inventory[i]))
		draw_item_signature(pos + Vector2(10, 3), inventory[i])
		if int(inventory[i].get("count", 1)) > 1:
			draw_rect(Rect2(pos + Vector2(16, 24), Vector2(31, 13)), Color("202e35"))
			text_at(pos + Vector2(17, 35), "×%d" % int(inventory[i]["count"]), 11, Color("fff1c8"))
	if selected_item >= 0 and selected_item < inventory.size():
		var chosen: Dictionary = inventory[selected_item]
		var chosen_label := "%s · %d Gold pro Stück" % [chosen["name"], int(chosen["value"])]
		if ItemProtection.is_protected(chosen): chosen_label += " · GESCHÜTZT"
		text_at(Vector2(171, 592), chosen_label, 16, Color("ff7c83") if ItemProtection.is_protected(chosen) else RARITY_COLORS[int(chosen["rarity"])])
	ui_button(Rect2(564, 562, 210, 39), "BESTÄTIGEN?" if sell_all_confirm else "ALLES VERKAUFEN")
	var can_sell_selected := selected_item >= 0 and selected_item < inventory.size() and not ItemProtection.is_protected(inventory[selected_item])
	ui_button(Rect2(786, 562, 183, 39), "VERKAUFEN", can_sell_selected)
	var mouse := get_viewport().get_mouse_position()
	for i in stock.size():
		if Rect2(168 + i * 258, 210, 245, 125).has_point(mouse):
			draw_item_tooltip(shop_preview_item(stock[i]), Vector2(clampf(mouse.x + 12, 170, 722), 348), int(stock[i]["price"]))
			break
	if pending_purchase >= 0:
		draw_rect(Rect2(135, 79, 882, 530), Color(0.07, 0.10, 0.13, 0.66))
		ui_box(Rect2(315, 210, 522, 247), Color("35454c"))
		text_at(Vector2(344, 250), "KAUF BESTÄTIGEN", 24, Color("ffe0a1"))
		var pending: Dictionary = shop_preview_item(pending_purchase_item)
		draw_item_icon(Vector2(346, 270), String(pending["icon"]), RARITY_COLORS[int(pending["rarity"])], 1.6, weapon_visual_stage(pending), item_design(pending))
		text_at(Vector2(413, 298), String(pending["name"]), 19, RARITY_COLORS[int(pending["rarity"])])
		text_at(Vector2(413, 326), "Preis: %d Gold   ·   Dein Gold: %d" % [int(pending_purchase_item["price"]), gold], 16, Color("f6dca1"))
		text_at(Vector2(345, 365), "Diesen Gegenstand wirklich kaufen?", 16, Color("f1ead6"))
		ui_button(Rect2(352, 391, 204, 45), "KAUFEN")
		ui_button(Rect2(578, 391, 204, 45), "ABBRECHEN")

func shop_preview_item(stock_item: Dictionary) -> Dictionary:
	var preview: Dictionary = stock_item.duplicate(true)
	var icon: String = String(stock_item["icon"])
	var rarity := int(stock_item.get("rarity", 1))
	var item_level := int(stock_item.get("level", level))
	var bonus := maxi(0, rarity + int(item_level / 9.0))
	preview["level"] = item_level
	preview["rarity"] = rarity
	preview["str"] = bonus if icon == "sword" else (int(bonus / 2.0) if icon in ["armor", "ring"] else 0)
	preview["agi"] = bonus if icon == "bow" else (int(bonus / 2.0) if icon in ["armor", "ring"] else 0)
	preview["int"] = bonus if icon == "staff" else (int(bonus / 2.0) if icon in ["armor", "ring"] else 0)
	preview["value"] = int(int(stock_item["price"]) / 2.0)
	preview["count"] = 1
	return preview

func draw_travel_panel() -> void:
	text_at(Vector2(165, 131), "WEGSTEINE · REISE VON SONNENHAIN", 24, Color("ffe5a2"))
	text_at(Vector2(168, 159), "Berühre einen Wegstein draußen und drücke F, um ihn dauerhaft zu aktivieren.", 15, Color("dcebdc"))
	for i in range(1, WAYSTONES.size()):
		var col := (i - 1) % 3
		var row := (i - 1) / 3
		var pos := Vector2(166 + col * 271, 175 + row * 96)
		var zone := region_at(WAYSTONES[i])
		var available: bool = waystone_unlocked[i] and region_available(zone)
		ui_box(Rect2(pos, Vector2(255, 79)), Color("59766b") if available else Color("405657"))
		draw_circle(pos + Vector2(25, 35), 12, Color("9cece7") if available else Color("8d9b9a"))
		text_at(pos + Vector2(48, 32), region_name(zone), 16, Color("fff1c4") if available else Color("b9c7c1"))
		text_at(pos + Vector2(48, 57), "LV %d · %s" % [region_level(zone), "REISEN" if available else "NICHT AKTIVIERT"], 13, Color("bfeee0") if available else Color("d2c0b6"))

func draw_journal_panel() -> void:
	text_at(Vector2(165, 125), "QUESTBUCH", 26, Color("ffeda9"))
	text_at(Vector2(690, 125), "Die Dornenplage", 17, Color("dbebd4"))
	ui_box(Rect2(165, 145, 815, 73), Color("675f55") if rescue_state == 1 else Color("527668"))
	var story: String = ["Mira sorgt sich um Blütenweiler. Folge dem Weg östlich von Sonnenhain.", "Das Dorf ist umzingelt. Besiege die Dornenwesen (%d/%d)." % [rescue_kills, RESCUE_GOAL], "Das Dorf ist sicher. Sprich mit Nela am Dorfplatz und hole deinen Lohn.", "Nela: Die Plage stammt aus dem Turm der Alten Ruinen. Suche dort die Quelle."][rescue_state]
	if rescue_state == 3 and bosses_defeated[0]: story = "Im Turm lag ein zerbrochenes Siegel. Der Kristallhüter bewacht sein Gegenstück."
	if rescue_state == 3 and bosses_defeated[1]: story = "Beide Siegel weisen zur Asche und weiter zu den Sternen. Folge dem alten Weg."
	if rescue_state == 3 and bosses_defeated[2]: story = "Der Aschefürst fiel. Hinter dem Sternenbruch glimmt noch die letzte Wache."
	text_at(Vector2(180, 173), "HAUPTGESCHICHTE · Blütenweiler", 19, Color("ffe6a7"))
	text_at(Vector2(180, 201), story, 16, Color("e7eedc"))
	for row in 6:
		var id := row + menu_scroll
		if id >= QUESTS.size(): break
		var q: Dictionary = QUESTS[id]
		var state: int = quests[id]["state"]
		var status: String = ["Noch verfügbar", "Aktiv", "Abgeben!", "Erledigt"][state]
		var required := region_level(int(ENEMY_TYPES[int(q["target"])]["region"]))
		if state == 0 and level + 3 < required: status = "Ab Level %d" % maxi(1, required - 3)
		var y := 226 + row * 57
		ui_box(Rect2(165, y, 815, 53), Color("577b69") if state == 2 else Color("45665f"))
		text_at(Vector2(180, y + 21), "%s  ·  %s" % [q["title"], q["npc"]], 17, Color("fff1bc"))
		text_at(Vector2(180, y + 42), "%s %d/%d  ·  %d XP / %d Gold" % [ENEMY_TYPES[int(q["target"])]["name"], quests[id]["progress"], q["count"], q["xp"], q["gold"]], 14, Color("d8e6d3"))
		text_at(Vector2(867, y + 29), status, 14, Color("fff0ad"))
	text_at(Vector2(170, 592), "Sprich mit dem Questgeber, um die nächste Aufgabe anzunehmen. Mausrad: scrollen.", 15, Color("d9e6d5"))

func draw_map_panel() -> void:
	text_at(Vector2(165, 125), "%s · EINGANG MARKIERT" % DUNGEON_NAMES[dungeon_id].to_upper() if dungeon_id >= 0 else "WELTKARTE · SONNENHAIN", 24, Color("ffe0a4"))
	draw_world_atlas(Rect2(167, 148, 800, 405))
	text_at(Vector2(168, 584), "◆ Du   ◆ Wegstein   ◇ Eingang / Gewölbe   ● Auftrag   ★ Boss   ·   Gold: offen / Rot: gesperrt", 14, Color("efe1bc"))

func draw_world_atlas(rect: Rect2) -> void:
	# Dunkler Kartentisch, 16-Pixel-Farbfelder und kontrastreiche Beschriftung.
	draw_rect(rect.grow(7), Color("261f29"))
	draw_rect(rect.grow(4), Color("b99860"))
	draw_rect(rect, Color("20393a"))
	var inset := rect.grow(-7)
	var map_scale := inset.size / WORLD
	var palette := [Color("628b62"), Color("71a65e"), Color("304c42"), Color("3c4249"), Color("26465d"), Color("60362f"), Color("a9a47a"), Color("36314b"), Color("47545a"), Color("8b6b37"), Color("294b52"), Color("3b4158"), Color("5b4a6a")]
	for col in 50:
		for row in 26:
			var cell := Rect2(inset.position + Vector2(col * inset.size.x / 50.0, row * inset.size.y / 26.0), inset.size / Vector2(50, 26) + Vector2(0.5, 0.5))
			var world_point := Vector2((col + 0.5) * WORLD.x / 50.0, (row + 0.5) * WORLD.y / 26.0)
			var region := visual_region_at(world_point)
			var texture := hash_cell(col, row)
			var tint: Color = palette[region]
			if texture % 7 == 0: tint = tint.lightened(0.075)
			if texture % 13 == 0: tint = tint.darkened(0.08)
			draw_rect(cell, tint)
			if texture % 9 == 0 and region != 6:
				var landmark_pos := cell.position + cell.size * 0.5
				match region:
					0, 1, 2, 8, 9: draw_atlas_tree(landmark_pos)
					3, 5, 11: draw_atlas_peak(landmark_pos)
					4, 10, 12: draw_atlas_crystal(landmark_pos)
					_: draw_rect(Rect2(landmark_pos, Vector2(2, 2)), Color("c8ad7d"))
	# Die sichtbaren Wege erklären die Verbindung der Regionen ohne ein Gitternetz.
	for trail in TRAILS:
		for index in range(1, trail.size()):
			var trail_start: Vector2 = trail[index - 1]
			var trail_end: Vector2 = trail[index]
			var a: Vector2 = inset.position + trail_start * map_scale
			var b: Vector2 = inset.position + trail_end * map_scale
			draw_line(a, b, Color("473d37", 0.85), 6)
			draw_line(a, b, Color("ccb689"), 3)
	# Plaques haben immer denselben dunklen Grund, unabhängig von der Gebietsfarbe.
	for region in 13:
		var center: Vector2 = inset.position + region_rect(region).get_center() * map_scale
		var width := 105.0 if region in [0, 6] else 130.0
		var plaque := Rect2(Vector2(clampf(center.x - width * 0.5, inset.position.x + 3, inset.end.x - width - 3), clampf(center.y - 22, inset.position.y + 3, inset.end.y - 47)), Vector2(width, 44))
		draw_rect(plaque, Color("222d35", 0.94))
		draw_rect(plaque, Color("c8a96d") if region_available(region) else Color("ad7676"), false, 2)
		var available := region_available(region)
		text_at(plaque.position + Vector2(3, 18), region_name(region), 12 if region in [0, 6] else 13, Color("fff0cf"), HORIZONTAL_ALIGNMENT_CENTER, int(width - 6))
		text_at(plaque.position + Vector2(3, 36), "LV %d · %s" % [region_level(region), "OFFEN" if available else "GESPERRT"], 10, Color("f6d48f") if available else Color("ffaca7"), HORIZONTAL_ALIGNMENT_CENTER, int(width - 6))
	for i in WAYSTONES.size():
		var point: Vector2 = inset.position + WAYSTONES[i] * map_scale
		draw_rect(Rect2(point - Vector2(4, 4), Vector2(8, 8)), Color("1d3540"))
		draw_rect(Rect2(point - Vector2(2, 2), Vector2(4, 4)), Color("9dece1") if waystone_unlocked[i] else Color("72878b"))
	for portal in PORTALS:
		if not region_available(int(portal[2])): continue
		for end in [portal[0], portal[1]]:
			var portal_end: Vector2 = end
			var point: Vector2 = inset.position + portal_end * map_scale
			draw_rect(Rect2(point - Vector2(4, 4), Vector2(8, 8)), Color("c6a4dc"), false, 2)
	for index in DUNGEON_ENTRANCES.size():
		var dungeon_entry: Vector2 = LANDMARKS[int(DUNGEON_ENTRANCES[index])]["pos"]
		if not region_available(region_at(dungeon_entry)): continue
		var entry_point: Vector2 = inset.position + dungeon_entry * map_scale
		draw_rect(Rect2(entry_point - Vector2(5, 5), Vector2(10, 10)), Color("f4d49b"), false, 2)
	for i in WORLD_EVENTS.size():
		if int(event_states[i]) == 3: continue
		if not region_available(int(WORLD_EVENTS[i]["region"])): continue
		var point: Vector2 = inset.position + WORLD_EVENTS[i]["pos"] * map_scale
		draw_circle(point, 5, Color("222e35"))
		draw_circle(point, 3, Color("ffe09a") if int(event_states[i]) in [0, 2] else Color("98d6c8"))
	for i in QUESTS.size():
		if int(quests[i]["state"]) in [1, 2]:
			var target: Vector2 = region_rect(int(ENEMY_TYPES[int(QUESTS[i]["target"])]["region"])).get_center() if int(quests[i]["state"]) == 1 else npc_position(String(QUESTS[i]["npc"]))
			var marker: Vector2 = inset.position + target * map_scale
			draw_circle(marker, 5, Color("f6d486"))
			break
	for boss_index in 3:
		var boss_pos: Vector2 = LANDMARKS[boss_index + 2]["pos"]
		if not region_available(region_at(boss_pos)): continue
		var marker: Vector2 = inset.position + boss_pos * map_scale
		draw_circle(marker, 8, Color("292d38"))
		draw_arc(marker, 7, 0.0, TAU, 16, Color("8fe2bf") if bosses_defeated[boss_index] else Color("ffaf83"), 2)
		text_at(marker + Vector2(-7, 4), "★", 12, Color("ddffe0") if bosses_defeated[boss_index] else Color("ffdb9f"), HORIZONTAL_ALIGNMENT_CENTER, 14)
	for npc in NPCS:
		if str(npc["kind"]) != "quest" or quest_marker_state(str(npc["name"])) == 0: continue
		if not region_available(region_at(npc["pos"])): continue
		var point: Vector2 = inset.position + npc["pos"] * map_scale
		draw_circle(point, 5, Color("263038"))
		text_at(point + Vector2(-5, 4), "!", 12, Color("ffda81"), HORIZONTAL_ALIGNMENT_CENTER, 10)
	var player_map := inset.position + (dungeon_return_pos if dungeon_id >= 0 else (interior_return_pos if interior_id >= 0 else player_pos)) * map_scale
	draw_arc(player_map, 9.0 + sin(world_time * 3.0) * 1.0, 0.0, TAU, 24, Color("ffffff"), 3)
	draw_colored_polygon(PackedVector2Array([player_map + Vector2(0,-7),player_map + Vector2(6,0),player_map + Vector2(0,7),player_map + Vector2(-6,0)]), Color("252b32"))
	draw_colored_polygon(PackedVector2Array([player_map + Vector2(0,-5),player_map + Vector2(4,0),player_map + Vector2(0,5),player_map + Vector2(-4,0)]), Color("ffffff"))
	draw_rect(rect, Color("ead6a9"), false, 2)

func draw_atlas_tree(point: Vector2) -> void:
	draw_rect(Rect2(point + Vector2(-1, 1), Vector2(3, 5)), Color("6d503e"))
	draw_rect(Rect2(point + Vector2(-4, -5), Vector2(9, 7)), Color("2f534d"))
	draw_rect(Rect2(point + Vector2(-2, -7), Vector2(5, 3)), Color("739775"))

func draw_atlas_peak(point: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([point + Vector2(-6,5),point + Vector2(0,-6),point + Vector2(7,5)]), Color("3f4a54"))
	draw_rect(Rect2(point + Vector2(-1,-5), Vector2(3,3)), Color("c7bdab"))

func draw_atlas_crystal(point: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([point + Vector2(0,-6),point + Vector2(4,0),point + Vector2(0,6),point + Vector2(-4,0)]), Color("b0d8dc"))
	draw_rect(Rect2(point + Vector2(-1,-4), Vector2(2,4)), Color("f6e9c7"))

func draw_waystone(p: Vector2) -> void:
	var active := false
	for i in WAYSTONES.size():
		if p == WAYSTONES[i]:
			active = bool(waystone_unlocked[i])
			break
	var shimmer := 0.58 + sin(world_time * 2.6 + p.x) * 0.18
	draw_circle(p + Vector2(0, 17), 72, Color("315e64", 0.28))
	draw_circle(p + Vector2(0, 13), 61, Color("a2a48b"))
	draw_circle(p + Vector2(0, 11), 52, Color("ced5b8"))
	for rune in 8:
		var ray := Vector2.RIGHT.rotated(float(rune) * TAU / 8.0)
		var rune_pos := p + Vector2(0, 12) + ray * 45
		draw_rect(Rect2(rune_pos - Vector2(4, 4), Vector2(8, 8)), Color("75c8cb") if active else Color("657e81"))
		draw_line(rune_pos, rune_pos + ray * 11, Color("edf5d1", 0.7), 2)
	draw_rect(Rect2(p + Vector2(-35, 21), Vector2(70, 15)), Color("596f6d"))
	draw_rect(Rect2(p + Vector2(-26, -40), Vector2(52, 63)), Color("667e7c"))
	draw_rect(Rect2(p + Vector2(-21, -47), Vector2(42, 12)), Color("a4b5a8"))
	draw_rect(Rect2(p + Vector2(-19, -34), Vector2(38, 51)), Color("b5c6b5"))
	draw_colored_polygon(PackedVector2Array([p + Vector2(0,-31),p + Vector2(15,-9),p + Vector2(0,13),p + Vector2(-15,-9)]), Color("67bbc6"))
	draw_colored_polygon(PackedVector2Array([p + Vector2(0,-25),p + Vector2(8,-9),p + Vector2(0,5),p + Vector2(-8,-9)]), Color("d8f8e7"))
	draw_rect(Rect2(p + Vector2(-3, -19), Vector2(6, 19)), Color("fff4cd"))
	for side in [-1.0, 1.0]:
		var column := p + Vector2(side * 55, -27)
		draw_rect(Rect2(column, Vector2(7, 60)), Color("735e52"))
		draw_colored_polygon(PackedVector2Array([column + Vector2(7,-48),column + Vector2(-9,-31),column + Vector2(7,-15)]), Color("e4b478"))
		draw_circle(column + Vector2(3, -31), 5, Color("fbe1a2", shimmer))
	text_at(p + Vector2(-79, -67), "WEGSTEIN", 16, Color("fff1c9"), HORIZONTAL_ALIGNMENT_CENTER, 158)

func draw_landmark(landmark: Dictionary) -> void:
	var p: Vector2 = landmark["pos"]
	var zone := region_at(p)
	var stone := Color("aaa696")
	var accent := Color("d7b778")
	if zone == 4:
		stone = Color("7b9fa7")
		accent = Color("a9eafa")
	elif zone == 5:
		stone = Color("765456")
		accent = Color("ef9a60")
	elif zone == 6:
		stone = Color("b9a57c")
		accent = Color("8fd4dc")
	elif zone in [7, 11, 12]:
		stone = Color("77748f")
		accent = Color("d4c2ef")
	elif zone == 9:
		stone = Color("9b8653")
		accent = Color("e1bd62")
	elif zone == 10:
		stone = Color("71989a")
		accent = Color("b7ece5")
	match landmark["kind"]:
		"hamlet":
			draw_hamlet(p)
		"camp":
			draw_colored_polygon(PackedVector2Array([p + Vector2(-66, 32), p + Vector2(0, -72), p + Vector2(69, 32)]), Color("e2ac7b"))
			draw_colored_polygon(PackedVector2Array([p + Vector2(-25, 30), p + Vector2(0, -24), p + Vector2(27, 30)]), Color("765d57"))
			draw_rect(Rect2(p + Vector2(-82, 34), Vector2(163, 9)), Color("946e61"))
			for offset in [-73, 74]:
				draw_rect(Rect2(p + Vector2(offset, -16), Vector2(8, 46)), Color("8a674f"))
			draw_circle(p + Vector2(0, 42), 18, Color("e99058", 0.25))
		"mushroom":
			for offset in [Vector2(-65, 23), Vector2(36, 37), Vector2(-12, -15)]: draw_mushroom(p + offset, 4 + int(offset.x))
			draw_bush_cluster(p + Vector2(75, 24), zone, 19)
			draw_rect(Rect2(p + Vector2(-76, 54), Vector2(164, 10)), Color("618f72"))
		"tower":
			# Gestufter Turm mit Zinnen, Eingang, Rissen und gebietstypischem Material.
			draw_rect(Rect2(p + Vector2(-54, -103), Vector2(108, 143)), stone.darkened(0.16))
			draw_rect(Rect2(p + Vector2(-45, -97), Vector2(90, 131)), stone)
			draw_rect(Rect2(p + Vector2(-62, -121), Vector2(124, 27)), stone.lightened(0.14))
			for offset in [-51, -18, 17, 50]: draw_rect(Rect2(p + Vector2(offset, -134), Vector2(19, 23)), stone.lightened(0.08))
			draw_rect(Rect2(p + Vector2(-14, -54), Vector2(28, 40)), Color("34434a"))
			draw_rect(Rect2(p + Vector2(-9, -49), Vector2(18, 8)), accent)
			draw_line(p + Vector2(-35, -79), p + Vector2(-11, -55), stone.darkened(0.35), 4)
			draw_line(p + Vector2(30, -5), p + Vector2(11, 16), stone.darkened(0.35), 4)
			draw_rect(Rect2(p + Vector2(-58, 34), Vector2(116, 10)), stone.darkened(0.22))
			if zone == 3: draw_bush_cluster(p + Vector2(55, 35), zone, 27)
		"shrine":
			for offset in [-59, 51]:
				draw_rect(Rect2(p + Vector2(offset, -50), Vector2(14, 87)), stone.darkened(0.12))
				draw_rect(Rect2(p + Vector2(offset - 4, -58), Vector2(22, 10)), stone.lightened(0.16))
			draw_rect(Rect2(p + Vector2(-65, -65), Vector2(135, 15)), stone.lightened(0.12))
			draw_crystal(p + Vector2(-22, -30), 1 + zone)
			draw_circle(p + Vector2(0, 5), 24, Color(accent, 0.12))
			draw_arc(p + Vector2(0, 5), 28, 0, TAU, 24, Color(accent, 0.65), 3)
			draw_rect(Rect2(p + Vector2(-70, 34), Vector2(145, 12)), stone.darkened(0.24))
		"gate":
			for offset in [-61, 41]:
				draw_rect(Rect2(p + Vector2(offset, -105), Vector2(20, 146)), stone.darkened(0.22))
				draw_rect(Rect2(p + Vector2(offset - 5, -115), Vector2(30, 14)), stone.lightened(0.12))
			draw_rect(Rect2(p + Vector2(-70, -113), Vector2(136, 25)), stone)
			draw_rect(Rect2(p + Vector2(-36, -80), Vector2(71, 19)), accent.darkened(0.18))
			draw_rect(Rect2(p + Vector2(-31, -74), Vector2(62, 5)), accent.lightened(0.18))
			for rune in [-22, 0, 22]: draw_rect(Rect2(p + Vector2(rune - 3, -72), Vector2(6, 6)), accent)
		"dock":
			draw_rect(Rect2(p + Vector2(-81, -12), Vector2(165, 20)), Color("765d49"))
			for plank in 8: draw_rect(Rect2(p + Vector2(-77 + plank * 20, -9), Vector2(16, 14)), Color("a27b57") if plank % 2 == 0 else Color("927056"))
			for offset in [-70, -20, 30, 72]: draw_rect(Rect2(p + Vector2(offset, 4), Vector2(9, 42)), Color("5e5049"))
			draw_rect(Rect2(p + Vector2(-24, -42), Vector2(48, 26)), Color("e4d6ad"))
			draw_line(p + Vector2(-42, 24), p + Vector2(-70, 55), Color("d6c49b"), 3)
	text_at(p + Vector2(-105, -143 if landmark["kind"] in ["tower", "gate"] else -85), String(landmark["name"]), 19, Color("fdf3cd"), HORIZONTAL_ALIGNMENT_CENTER, 210)

func draw_hamlet(p: Vector2) -> void:
	var safe := rescue_state >= 2
	if not safe:
		# Sichtbares Signal des Angriffs: Feuer, Rauch und rote Alarmfahnen.
		for fire_offset in [Vector2(-360, -160), Vector2(260, -190), Vector2(-330, 220), Vector2(280, 240)]:
			var fire_pos: Vector2 = p + fire_offset + Vector2(0, -78)
			draw_circle(fire_pos + Vector2(0, 18), 18, Color("d85f57", 0.40))
			draw_colored_polygon(PackedVector2Array([fire_pos + Vector2(0, -28), fire_pos + Vector2(13, 15), fire_pos + Vector2(-13, 15)]), Color("e66c50"))
			draw_colored_polygon(PackedVector2Array([fire_pos + Vector2(0, -16), fire_pos + Vector2(8, 12), fire_pos + Vector2(-8, 12)]), Color("ffdd78"))
			for smoke_i in 3:
				var smoke_pos := fire_pos + Vector2(sin(world_time * 1.3 + smoke_i) * 12, -36 - smoke_i * 24)
				draw_circle(smoke_pos, 14 + smoke_i * 3, Color(0.20, 0.23, 0.25, 0.24 - smoke_i * 0.045))
		# Alarmbanner am zentralen Weg, schon aus größerer Entfernung lesbar.
		draw_rect(Rect2(p + Vector2(-6, -185), Vector2(10, 135)), Color("684e50"))
		draw_colored_polygon(PackedVector2Array([p + Vector2(4, -178), p + Vector2(105, -158), p + Vector2(4, -138)]), Color("c95762"))
		text_at(p + Vector2(-92, -218), "HILFE!", 22, Color("ffd28b"), HORIZONTAL_ALIGNMENT_CENTER, 184)
	else:
		# Nach der Rettung bleibt ein sichtbarer Wiederaufbau zurück.
		for repair in [Vector2(-360, -160), Vector2(260, -190), Vector2(-330, 220), Vector2(280, 240)]:
			draw_circle(p + repair + Vector2(0, 72), 5 + int(world_time) % 2, Color("f3cf79", 0.7))
	for offset in [Vector2(-360, -160), Vector2(260, -190), Vector2(-330, 220), Vector2(280, 240)]:
		var h: Vector2 = p + offset
		draw_rect(Rect2(h + Vector2(-82, 46), Vector2(164, 15)), Color("526f56", 0.5))
		draw_rect(Rect2(h + Vector2(-72, -33), Vector2(144, 91)), Color("e0c799"))
		draw_rect(Rect2(h + Vector2(-77, -50), Vector2(154, 27)), Color("d67e64") if safe else Color("836b63"))
		draw_rect(Rect2(h + Vector2(-66, -63), Vector2(132, 16)), Color("ef9e78") if safe else Color("a07665"))
		for x in [-53, 36]:
			draw_rect(Rect2(h + Vector2(x, -8), Vector2(18, 22)), Color("83c8cc") if safe else Color("514d4e"))
			draw_rect(Rect2(h + Vector2(x + 8, -8), Vector2(3, 22)), Color("f9eac3"))
		draw_rect(Rect2(h + Vector2(-15, 10), Vector2(30, 48)), Color("8e6553"))
		draw_rect(Rect2(h + Vector2(6, 32), Vector2(4, 4)), Color("e8cb82"))
		if safe:
			for flower in [-82, -35, 41, 83]:
				draw_rect(Rect2(h + Vector2(flower, 68), Vector2(5, 5)), Color("ef9eb1"))
		else:
			draw_rect(Rect2(h + Vector2(64, -76), Vector2(6, 20)), Color("695e63", 0.6))
	if not safe:
		for offset in [Vector2(-360, -160), Vector2(260, -190), Vector2(-330, 220), Vector2(280, 240)]:
			var roof: Vector2 = p + offset + Vector2(32, -66)
			draw_colored_polygon(PackedVector2Array([roof + Vector2(-12, 7), roof + Vector2(0,-31 - sin(world_time * 8) * 5), roof + Vector2(15,7)]), Color("f38858", 0.85))
			draw_colored_polygon(PackedVector2Array([roof + Vector2(-5, 8), roof + Vector2(3,-17), roof + Vector2(9,8)]), Color("ffe083"))
			for i in 3:
				draw_circle(roof + Vector2(sin(world_time + i * 2.0) * 15, -46 - i * 22), 12 + i * 5, Color(0.25,0.27,0.28,0.22))
	for x in [-155, 140]:
		draw_rect(Rect2(p + Vector2(x, -50), Vector2(8, 110)), Color("917052"))
		draw_rect(Rect2(p + Vector2(x - 6, -60), Vector2(20, 13)), Color("cfa86b"))
	if safe:
		draw_rect(Rect2(p + Vector2(-153, -45), Vector2(298, 9)), Color("f1c77b"))
		text_at(p + Vector2(-91, -91), "BLÜTENWEILER", 18, Color("fff2bb"), HORIZONTAL_ALIGNMENT_CENTER, 182)

func draw_ufo_wreck(p: Vector2) -> void:
	# Schräg im seichten Wasser liegendes abgestürztes UFO.
	var bob := sin(world_time * 1.7) * 2.0
	var q := p + Vector2(0, bob)
	draw_colored_polygon(PackedVector2Array([
		q + Vector2(-112, 22), q + Vector2(-72, -22), q + Vector2(56, -45),
		q + Vector2(111, -6), q + Vector2(72, 34), q + Vector2(-55, 49)
	]), Color("63727a"))
	draw_colored_polygon(PackedVector2Array([
		q + Vector2(-84, 7), q + Vector2(-51, -18), q + Vector2(52, -34),
		q + Vector2(82, -8), q + Vector2(54, 19), q + Vector2(-50, 32)
	]), Color("aeb9bd"))
	draw_colored_polygon(PackedVector2Array([
		q + Vector2(-26, -18), q + Vector2(6, -43), q + Vector2(42, -32),
		q + Vector2(49, -9), q + Vector2(7, -3)
	]), Color("79b9c3", 0.78))
	draw_line(q + Vector2(-70, 6), q + Vector2(71, -18), Color("d6e0df"), 4)
	draw_line(q + Vector2(-38, 30), q + Vector2(62, 14), Color("45565f"), 5)
	draw_circle(q + Vector2(-73, 17), 8, Color("8defff", 0.75))
	draw_circle(q + Vector2(71, -4), 7, Color("ff9c73", 0.72))
	for offset in [-125.0, -92.0, 91.0, 123.0]:
		draw_arc(q + Vector2(offset, 42), 28, PI + 0.15, TAU - 0.15, 18, Color("8ad4dd", 0.46), 2)

func open_ufo_chest() -> void:
	if ufo_chest_opened:
		return
	if inventory.size() >= 42:
		message("Inventar voll — die fremdartige Truhe bleibt geschlossen.")
		return
	ufo_chest_opened = true
	var relic := make_item("Fremdartiger Sternenkern", "gem", 3, 0, 650, "blitz", maxi(level, 8))
	inventory.append(relic)
	gold += 120
	play_sound("level")
	message("UFO-Fund: Fremdartiger Sternenkern +120 Gold. Was ist hier abgestürzt?")
	save_game()

func draw_chest(p: Vector2, opened: bool) -> void:
	var lid_y := -30 if opened else -22
	draw_rect(Rect2(p + Vector2(-28, -11), Vector2(56, 35)), Color("392d38"))
	draw_rect(Rect2(p + Vector2(-25, -9), Vector2(50, 30)), Color("855d49"))
	for stripe in 5:
		draw_rect(Rect2(p + Vector2(-21 + stripe * 9, -7), Vector2(5, 26)), Color("986c52") if stripe % 2 == 0 else Color("705144"))
	draw_rect(Rect2(p + Vector2(-29, lid_y), Vector2(58, 16)), Color("4e3c44"))
	draw_rect(Rect2(p + Vector2(-26, lid_y + 2), Vector2(52, 12)), Color("ae7852"))
	for band in [-19, 16]:
		draw_rect(Rect2(p + Vector2(band, -11), Vector2(5, 34)), Color("e5bd73"))
		draw_rect(Rect2(p + Vector2(band, lid_y), Vector2(5, 16)), Color("e6c987"))
	draw_rect(Rect2(p + Vector2(-27, 17), Vector2(54, 5)), Color("d7a866"))
	if not opened:
		draw_rect(Rect2(p + Vector2(-6, -12), Vector2(12, 14)), Color("f3d58b"))
		draw_rect(Rect2(p + Vector2(-3, -9), Vector2(6, 7)), Color("74b7bd"))
		draw_rect(Rect2(p + Vector2(-31, lid_y + 3), Vector2(3, 6)), Color("fff3b8"))
		draw_rect(Rect2(p + Vector2(28, lid_y + 3), Vector2(3, 6)), Color("fff3b8"))
		text_at(p + Vector2(-50, -46), "SCHATZ", 15, Color("ffe9a2"), HORIZONTAL_ALIGNMENT_CENTER, 100)
	else:
		draw_rect(Rect2(p + Vector2(-16, -8), Vector2(32, 8)), Color("423747"))
