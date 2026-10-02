# Release marker: Borin skill trees, class-boss relic masteries, shared world loot and current multiplayer fixes.
extends Node2D
const PatchNotice = preload("res://components/patch_notice.gd")
var patch_notice = PatchNotice.new()
const ExperienceRules = preload("res://components/experience_rules.gd")
const ControllerControls = preload("res://components/controller_controls.gd")
var controller = ControllerControls.new()
const QuestGuide = preload("res://components/quest_guide.gd")
var quest_guide = QuestGuide.new()
const ServerSaveStore = preload("res://components/server_save_store.gd")
const ServerSaveClient = preload("res://components/server_save_client.gd")
var server_save_store = ServerSaveStore.new()
var server_save = ServerSaveClient.new()
const KonfluxMap = preload("res://components/konflux_map.gd")
var konflux = KonfluxMap.new()
var konflux_preview_mode := false
const ReferenceHouse = preload("res://components/reference_house.gd")
const USE_VILLAGE_REFERENCE_BACKGROUND := false
const ReferenceScenery = preload("res://components/reference_scenery.gd")
const VillageLayout = preload("res://components/village_layout.gd")
const StartScenery32 = preload("res://components/start_scenery_32.gd")
const CombatFeedback=preload("res://components/combat_feedback.gd")
var combat_feedback=CombatFeedback.new()
var creation_class_selected:=false
var creation_replace_confirmed:=false
var last_vitals:Vector2=Vector2(-1,-1)
var teleport_serial:=0
var hurt_until:=0.0
var mob_deaths:Array=[]
var dead_mob_uids:Dictionary={}
const INVENTORY_HUD_RECT:=Rect2(584,590,98,42)
const MobCombat=preload("res://components/mob_combat.gd")
const MobDesign32=preload("res://components/monster_design_32.gd")
const ItemStyle32=preload("res://components/item_style_32.gd")
const PixelStyle32=preload("res://components/pixel_style_32.gd")
const SpawnPlatform32=preload("res://components/spawn_platform_32.gd")
const SpawnStoneBody=preload("res://components/spawn_stone_body.gd")
const Wagon32 = preload("res://components/wagon_32.gd")
const StartTileMap32 = preload("res://components/start_tilemap_32.gd")
var start_tilemap_32_attached := false
var live_reconnect_timer := 0.0
const REFERENCE_TREES := [Vector2(170,510),Vector2(970,440),Vector2(1500,610),Vector2(360,1050),Vector2(150,1040),Vector2(1630,1680),Vector2(190,1590),Vector2(1170,1880),Vector2(120,1910),Vector2(650,1930),Vector2(180,2240),Vector2(1600,2510)]
const REFERENCE_WELL := Vector2(1184, 832)

# Sonnenhain: ein eigenständiger, erweiterbarer Godot-4-Prototyp.
const VIEW := Vector2(1152, 648)
const WORLD := Vector2(16000, 9600)
const KONFLUX_MIN_LEVEL := 40
const GATE_HALF_WIDTH := 175.0
const VILLAGE_GATES := [Vector2(1780,1120), Vector2(875,2600)]
var opened_village_gates: Dictionary = {}
const SAVE_PATH := "user://sonnenhain_save.json"
const CREATIVE_SAVE_PATH := "user://sonnenhain_testmodus.json"
const CONTROLS_PATH := "user://sonnenhain_tasten.json"
const BIND_ACTIONS := ["move_up", "move_down", "move_left", "move_right", "attack", "dodge", "interact", "waystone", "heal", "resource", "ability_1", "ability_2", "ability_3", "ability_4", "skills", "inventory", "journal", "map", "pause", "chat", "mechanics", "online", "party"]
const BIND_NAMES := ["Nach oben", "Nach unten", "Nach links", "Nach rechts", "Angriff", "Ausweichen", "Öffnen / Interagieren", "Wegstein", "Heiltrank", "Energie / Mana", "Fähigkeit 1", "Fähigkeit 2", "Fähigkeit 3", "Fähigkeit 4", "Skillbuch", "Inventar", "Questbuch", "Weltkarte", "Pause", "Chat", "Spielhilfe", "Spielerliste", "Gruppe"]
const DEFAULT_BINDINGS := {"move_up":KEY_W, "move_down":KEY_S, "move_left":KEY_A, "move_right":KEY_D, "attack":-MOUSE_BUTTON_LEFT, "dodge":KEY_SPACE, "interact":KEY_E, "waystone":KEY_F, "heal":KEY_Q, "resource":KEY_R, "ability_1":KEY_1, "ability_2":KEY_2, "ability_3":KEY_3, "ability_4":KEY_4, "skills":KEY_K, "inventory":KEY_I, "journal":KEY_J, "map":KEY_M, "pause":KEY_ESCAPE, "chat":KEY_ENTER, "mechanics":KEY_H, "online":KEY_TAB, "party":KEY_P}
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
const ENEMY_TYPES := [
	{"name":"Waldschleim", "region":1, "hp":42, "damage":8, "speed":78, "xp":12, "color":Color("73cb88")},
	{"name":"Blütenkäfer", "region":1, "hp":32, "damage":6, "speed":113, "xp":11, "color":Color("e998b6")},
	{"name":"Pilzling", "region":2, "hp":65, "damage":11, "speed":65, "xp":19, "color":Color("e3ad77")},
	{"name":"Mooswolf", "region":2, "hp":72, "damage":14, "speed":132, "xp":24, "color":Color("789983")},
	{"name":"Steingolem", "region":3, "hp":118, "damage":19, "speed":72, "xp":36, "color":Color("bea78c")},
	{"name":"Ruinenbeholder", "region":3, "hp":82, "damage":22, "speed":105, "xp":38, "color":Color("a8b9e9")},
	{"name":"Kristallkrabbe", "region":4, "hp":125, "damage":22, "speed":75, "xp":44, "color":Color("8de0eb")},
	{"name":"Kristallgolem", "region":4, "hp":165, "damage":29, "speed":66, "xp":58, "color":Color("92ddea")},
	{"name":"Ascheläufer", "region":5, "hp":145, "damage":29, "speed":138, "xp":57, "color":Color("dc835e")},
	{"name":"Lavagolem", "region":5, "hp":260, "damage":38, "speed":52, "xp":82, "color":Color("a75c52")},
	{"name":"Strandkrabbe", "region":6, "hp":57, "damage":9, "speed":93, "xp":15, "color":Color("e9a67e")},
	{"name":"Wassergeist", "region":6, "hp":90, "damage":16, "speed":117, "xp":26, "color":Color("76bfd2")},
	{"name":"Kriegsherr", "region":6, "hp":1800, "damage":46, "speed":96, "xp":520, "color":Color("c97b5e")},
	{"name":"Arkanhüter", "region":7, "hp":2100, "damage":54, "speed":102, "xp":650, "color":Color("8caee8")},
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
	{"name":"Sternenwächterin", "region":12, "hp":560, "damage":69, "speed":85, "xp":180, "color":Color("e4d4b5")}
]
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
	{"name":"Arkaner Sprung", "desc":"Weiter arkaner Sprung und Schutz", "cost":25, "cd":10.0, "req":15, "kind":19},
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
	{"name":"Himmelshagel", "desc":"Klassenfähigkeit: großer Pfeilsturm", "cost":60, "cd":45.0, "req":20, "kind":33},
	{"name":"Impulsschuss", "desc":"Robotischer Energieschuss", "cost":24, "cd":5.0, "req":3, "kind":34},
	{"name":"Reparaturmodul", "desc":"Repariert sofort einen Teil deiner Lebenspunkte", "cost":30, "cd":16.0, "req":8, "kind":35},
	{"name":"Energieschild", "desc":"Technischer Schild reduziert eingehenden Schaden", "cost":32, "cd":15.0, "req":12, "kind":36},
	{"name":"Teslawelle", "desc":"Elektrische Welle trifft Gegner im Umkreis", "cost":36, "cd":10.0, "req":15, "kind":37},
	{"name":"Zielmatrix", "desc":"Überclockt Angriffe für kurze Zeit", "cost":28, "cd":18.0, "req":18, "kind":38},
	{"name":"EMP-Stoß", "desc":"Betäubt Gegner im Umkreis", "cost":42, "cd":18.0, "req":23, "kind":39},
	{"name":"Flammenwirbel", "desc":"Fusion aus Wirbelhieb und Feuerball", "cost":42, "cd":12.0, "req":15, "kind":40},
	{"name":"Reaktorwall", "desc":"Fusion aus Schildwall und Energieschild", "cost":38, "cd":20.0, "req":15, "kind":41},
	{"name":"Blitzkern", "desc":"Fusion aus Blitzlanze und Teslawelle", "cost":48, "cd":16.0, "req":23, "kind":42}
]
const CLASS_NAMES := ["Krieger", "Magier", "Bogenschütze"]
const CLASS_SKILLS := [[0, 1, 2, 3, 5, 7, 12, 13, 14], [16, 17, 18, 19, 20, 21, 22, 23], [25, 26, 27, 28, 29, 30, 31, 32]]
const CLASS_ULTIMATES := [15, 24, 33]
const SKILL_TREE_NAMES := ["KAMPF", "MAGIE", "ROBOTIK"]
const SKILL_TREES := [[0,1,2,3,4,5,6,7,8,12,13,14,25,26,27,28,29,30,31,32],[16,17,18,19,20,21,22,23],[34,35,36,37,38,39]]
const FUSIONS := [{"id":40,"a":0,"b":16,"gold":1200},{"id":41,"a":1,"b":36,"gold":2200},{"id":42,"a":18,"b":37,"gold":4200}]
const BORIN_CRYSTAL_POS := Vector2(1608,1970)
const CLASS_BOSS_SITES := [Vector2(430,6500),Vector2(9700,6500),Vector2(14300,1200)] # Map 06 / 07 / 08
const CLASS_BOSS_ARENA_RADIUS := 410.0
const CLASS_BOSS_ARENA_CLEAR_RADIUS := 475.0
const CLASS_RELIC_NAMES := ["Herz des Kriegsherrn","Arkansplitter","Herz der Jagd"]
const CLASS_RELIC_SKILLS := ["WUT + BLUTRAUSCH","ARKANER SCHRITT","JAGDRAUSCH + SCHATTENROLLE"]
const CLASS_RELIC_RESERVE_MS := 15000
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
	{"title":"Der Kriegsherr", "npc":"Borin", "target":12, "count":1, "xp":600, "gold":750, "reward":"Kampfsiegel"},
	{"title":"Der Arkanhüter", "npc":"Liora", "target":13, "count":1, "xp":800, "gold":950, "reward":"Arkankern"},
	{"title":"Der Jagdmeister", "npc":"Mira", "target":14, "count":1, "xp":1100, "gold":1300, "reward":"Jagdzeichen"},
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
	{"name":"Mira", "role":"Älteste · Quests", "pos":Vector2(316, 830), "color":Color("a77ccb"), "kind":"quest"},
	{"name":"Borin", "role":"Skillzauberer · Quests", "pos":Vector2(1486, 1970), "color":Color("6783bd"), "kind":"quest"},
	{"name":"Liora", "role":"Forscherin · Quests", "pos":Vector2(636, 640), "color":Color("6bbba4"), "kind":"quest"},
	{"name":"Torvald", "role":"Schmied", "pos":Vector2(316, 1420), "color":Color("ab6e60"), "kind":"smith"},
	{"name":"Fenna", "role":"Händlerin", "pos":Vector2(596, 1610), "color":Color("87a66b"), "kind":"merchant"},
	{"name":"Pip", "role":"Alchemist", "pos":Vector2(1206, 1560), "color":Color("d3aa65"), "kind":"alchemy"},
	{"name":"Elara", "role":"Heilerin · Vollheilung", "pos":Vector2(1536, 1480), "color":Color("e2bc91"), "kind":"healer"},
	{"name":"Arven", "role":"Arenameister · Endlose Prüfung", "pos":Vector2(1196, 630), "color":Color("a48cbd"), "kind":"arena"}
]
const SHOPS := {
	"smith": [{"name":"Frostklinge", "icon":"sword", "power":9, "price":320, "element":"eis"}, {"name":"Blitzsäbel", "icon":"sword", "power":17, "price":750, "element":"blitz"}, {"name":"Giftklinge", "icon":"sword", "power":25, "price":1300, "element":"gift"}],
	"alchemy": [{"name":"Heiltrank", "icon":"potion", "power":0, "price":35}, {"name":"Großer Heiltrank", "icon":"potion", "power":0, "price":85}, {"name":"Energietrank", "icon":"potion", "power":0, "price":45}],
	"merchant": [{"name":"Reisenderumhang", "icon":"armor", "power":4, "price":125}, {"name":"Wächterrüstung", "icon":"armor", "power":9, "price":520}, {"name":"Glücksring", "icon":"ring", "power":15, "price":240}]
}
const WAYSTONES := [Vector2(825, 915), Vector2(3300, 1900), Vector2(3200, 6200), Vector2(6700, 1950), Vector2(6700, 6250), Vector2(9750, 3900), Vector2(1000, 6100), Vector2(13500, 950), Vector2(13500, 2850), Vector2(13500, 4750), Vector2(13500, 6650), Vector2(13500, 8550)]
const RESCUE_POS := Vector2(3150, 2350)
const RESCUE_GOAL := 20
const ARENA_CENTER := Vector2(8000, 4800)
const ARENA_RADIUS := 490.0
const DUNGEON_CENTER := Vector2(8000, 4800)
const DUNGEON_ENTRANCES := [2, 3, 8]
const DUNGEON_NAMES := ["Turmgewölbe", "Kristallgruft", "Versunkene Krypta"]
const DUNGEON_ENEMIES := [[4, 5], [6, 7], [21, 22]]
const TAVERN_HOUSE := Vector2(1380, 700)
const VILLAGE_REF_ORIGIN := Vector2(0, 550)
const VILLAGE_REF_RECT := Rect2(0, 550, 1672, 840)
const VILLAGE_REF_SOLIDS := [Rect2(-40, 548, 1752, 112), Rect2(15, 805, 310, 140), Rect2(305, 1025, 310, 145), Rect2(1295, 1015, 365, 145), Rect2(12, 1012, 95, 95), Rect2(325, 825, 345, 30), Rect2(995, 825, 350, 30), Rect2(890, 870, 105, 45), Rect2(1625, 950, 50, 250)]
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

var player_pos := Vector2(825, 1020)
var facing := Vector2.RIGHT
var camera_pos := Vector2.ZERO
var camera_smooth := Vector2.ZERO
var camera_context := ""
const STATIC_CHUNK_SIZE := 512
const STATIC_CACHE_LIMIT := 32
var static_chunks: Dictionary = {}
var foreground_cache: Dictionary = {}
var static_renderer_script: Script
var static_draw_bounds := Rect2()
var performance_cache_enabled := true
var performance_draw_us := 0
var performance_draw_samples: Array = []
var performance_last_frame_ms := 0.0
var character_canvas_offset := Vector2.ZERO
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
var equipped_head_uid := -1
var death_timer := 0.0
var arcane_step_learned := false
var skill_tree_tab := 0
var class_mastery_unlocked := false
var warrior_rage := 0.0
var ranger_hunt_meter := 0.0
var ranger_hunt_buff := 0.0
var ranger_stealth_timer := 0.0
var robotics_overclock_timer := 0.0
const DEATH_DURATION := 1.15
var equipped_ring_uid := -1
var equipped_ring2_uid := -1
var next_uid := 1
var selected_item := -1
var inventory_page := 0
var last_inventory_click_uid := -1
var last_inventory_click_msec := -10000
var shop_page := 0
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
var chest_respawn_until: Array = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
const CHEST_RESPAWN_SECONDS := 360.0
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
var arena_reward_item:Dictionary={}
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
var village_bg: Texture2D
var dungeon_chests_opened: Array = [false, false, false]
var dungeon_chest_respawn_until: Array = [0.0,0.0,0.0]
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
var dodge_duration := 0.22
var dodge_start := Vector2.ZERO
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
var touch_enabled := false
var mobile_performance_mode := false
var touch_move_id := -1
var touch_move_vector := Vector2.ZERO
var touch_move_smoothed := Vector2.ZERO
var touch_move_base := Vector2(118, 526)
var touch_move_knob := Vector2(118, 526)
var touch_attack_ids: Dictionary = {}
var last_touch_msec := -10000
var touch_aim_id := -1
var touch_aim_base := Vector2(1032, 526)
var touch_aim_knob := Vector2(1032, 526)
var touch_aim_vector := Vector2.RIGHT
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
var online_list_open := false
var mechanics_page := 0
var network_mode := "offline"
var network_status := "Offline"
var network_port := 27844
var websocket_port := 27845
const LIVE_MULTIPLAYER_URL := "wss://multiplayer.sonnenhainrpg.de/"
const NETWORK_PROTOCOL_VERSION := 9
const PARTY_MAX_MEMBERS := 10
const PARTY_XP_RANGE := 850.0
const PARTY_BOSS_RANGE := 1100.0
const PARTY_BOSS_ACTIVITY_MS := 15000
const SERVER_WORLD_MOB_CAP := 264 # 12 Regionen × max. 22 normale Mobs; keine aktive Map nimmt einer anderen Spawnplaetze weg.
const WAYSTONE_SAFE_RADIUS := 220.0
const WAYSTONE_SPAWN_BLOCK_RADIUS := 285.0
var dedicated_server_mode := false
var invite_code := ""
var join_code := ""
var remote_players: Dictionary = {}
var local_peer_id := 1
var sync_timer := 0.0
var server_spawn_timer := 0.0
var server_status_timer := 0.0
var server_rescue_spawn_timer := 0.0
var server_next_mob_uid := 1
var server_next_drop_uid := 1
var world_drop_request_times: Dictionary = {}
var server_moving_mobs := 0
var server_party_of_peer: Dictionary = {}
var server_parties: Dictionary = {}
var server_party_invites: Dictionary = {}
var server_party_reconnect: Dictionary = {}
var server_next_party_id := 1
var server_action_times: Dictionary = {}
var server_pending_transactions: Dictionary = {}
var multiplayer_smoke_client_mode := false
var multiplayer_smoke_saw_attack:=false
var multiplayer_smoke_name := ""
var multiplayer_smoke_deadline := 0
var multiplayer_smoke_chat_timer := 0.0
var multiplayer_smoke_attack_timer := 0.0
var multiplayer_smoke_party_timer := 0.0
var multiplayer_smoke_inventory_checked := false
var multiplayer_smoke_success_since := 0
var multiplayer_smoke_mob_origins: Dictionary = {}
var multiplayer_smoke_mobs_moved := false
var server_sync_status: Dictionary = {}
var server_world_manifest: Dictionary = {}
var party_state: Dictionary = {}
var remote_combat_visuals: Array = []
var remote_player_render_positions: Dictionary = {}
var player_uuid := ""
var recent_players: Array = []
var save_notice_timer := 0.0
var save_notice_text := ""
var last_save_unix := 0
var server_save_timer := 5.0
var client_ping_timer := 0.0
var server_last_reply_ms := 0
var network_ping_ms := -1
var processed_server_transactions: Array = []
const FoodSystem = preload("res://components/food_system.gd")
var food_system = FoodSystem.new()
const SteinroseKitchen = preload("res://components/steinrose_kitchen.gd")
var steinrose = SteinroseKitchen.new()
const GENDER_NAMES := ["Mann", "Frau"]
const RACE_NAMES := ["Mensch", "Ork", "Roboter"]

func detect_touch_capability() -> bool:
	if not is_web_platform():return DisplayServer.is_touchscreen_available()
	var bridge=JavaScriptBridge.get_interface("SonnenhainBrowser")
	return bool(bridge.touchCapability()) if bridge!=null else DisplayServer.is_touchscreen_available()

func clear_touch_inputs() -> void:
	touch_attack_ids.clear()
	reset_touch_joystick()
	reset_touch_aim()

func _notification(what: int) -> void:
	if controller != null:
		if what == NOTIFICATION_APPLICATION_FOCUS_OUT: controller.focused = false
		elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
			controller.focused = true
			for action in controller.ACTIONS:
				var code: int = int(controller.bindings[action])
				if controller.code_pressed(code): controller.blocked_codes[code] = true
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if touch_enabled: clear_touch_inputs()
		if not dedicated_server_mode and character_created and panel not in ["start","creation"]:
			save_game()

func command_arg_value(prefix: String, fallback: String = "") -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(prefix):
			return arg.substr(prefix.length())
	return fallback

func server_patch_notice_path() -> String:
	var home_dir := OS.get_environment("HOME")
	return command_arg_value("--patch-notice-path=",home_dir.path_join("sonnenhain-server/data/patch-notice.txt") if home_dir != "" else "user://server_patch_notice.txt")

func server_check_patch_notice() -> void:
	var path := server_patch_notice_path()
	if not FileAccess.file_exists(path): return
	var raw := FileAccess.get_file_as_string(path).strip_edges().left(80)
	if not patch_notice.consume(raw): return
	var message_text := "Server wird gepatcht."
	if raw.begins_with("done:"):
		message_text = "Patch abgeschlossen. Bitte die Seite neu laden (Strg+F5)."
	add_chat_line("SERVER",message_text)
	for peer_id in multiplayer.get_peers():
		rpc_chat_relay.rpc_id(int(peer_id),"SERVER",message_text)
	print("SERVER_PATCH_NOTICE_SENT ",patch_notice.last_token," message=",message_text)

func start_multiplayer_smoke_client() -> void:
	multiplayer_smoke_client_mode = true
	if not controller.self_test():
		print("CONTROLLER_SMOKE_FAIL")
		get_tree().quit(36)
		return
	print("CONTROLLER_SMOKE_OK deadzone=true trigger=true menu_focus=true")
	if not run_teleport_consistency_smoke():
		print("TELEPORT_SMOKE_FAIL")
		get_tree().quit(37)
		return
	if not run_inventory_consistency_smoke():
		print("INVENTORY_SMOKE_FAIL")
		get_tree().quit(33)
		return
	if not run_rescue_quest_consistency_smoke():
		print("RESCUE_SMOKE_FAIL")
		get_tree().quit(34)
		return
	if not run_generic_quest_sync_smoke():
		print("QUEST_SYNC_SMOKE_FAIL")
		get_tree().quit(35)
		return
	multiplayer_smoke_name = command_arg_value("--smoke-name=", "Smoke")
	hero_name = multiplayer_smoke_name
	player_uuid = "smoke-%s" % multiplayer_smoke_name.to_lower()
	character_created = true
	class_id = 0 if multiplayer_smoke_name.ends_with("A") else 2
	player_pos = Vector2(2200.0, 1000.0) if class_id == 0 else Vector2(2260.0, 1000.0)
	panel = ""
	var peer := WebSocketMultiplayerPeer.new()
	var smoke_url := command_arg_value("--smoke-url=", "ws://127.0.0.1:27845")
	var err := peer.create_client(smoke_url)
	if err != OK:
		print("MULTIPLAYER_SMOKE_FAIL connect_error=", err)
		get_tree().quit(31)
		return
	multiplayer.multiplayer_peer = peer
	network_mode = "client"
	multiplayer_smoke_deadline = Time.get_ticks_msec() + 30000
	print("MULTIPLAYER_SMOKE_CONNECT ", multiplayer_smoke_name, " url=", smoke_url)

func process_multiplayer_smoke(delta: float) -> void:
	if not multiplayer_smoke_client_mode:
		return
	multiplayer_smoke_chat_timer -= delta
	multiplayer_smoke_attack_timer -= delta
	multiplayer_smoke_party_timer -= delta
	if network_mode == "client" and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and multiplayer_smoke_party_timer <= 0.0:
		multiplayer_smoke_party_timer = 0.9
		var party_members: Array = party_state.get("members",[])
		if party_members.size() < 2:
			if multiplayer_smoke_name.ends_with("A"):
				var target_name := multiplayer_smoke_name.left(multiplayer_smoke_name.length()-1)+"B"
				rpc_party_command.rpc_id(1,{"action":"invite","name":target_name})
			elif int(party_state.get("invite_from",0)) > 0:
				rpc_party_command.rpc_id(1,{"action":"accept"})
	if network_mode == "client" and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and multiplayer_smoke_attack_timer <= 0.0:
		multiplayer_smoke_attack_timer = 0.85
		rpc_client_normal_attack.rpc_id(1,[player_pos.x,player_pos.y],[facing.x,facing.y],class_id,equipped_weapon_design(),5,weapon_element())
	if network_mode == "client" and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and multiplayer_smoke_chat_timer <= 0.0:
		multiplayer_smoke_chat_timer = 0.7
		send_chat_message("SMOKE:%s" % multiplayer_smoke_name)
	var saw_other_chat := false
	for entry in chat_messages:
		var text_value := str(entry.get("text", ""))
		if text_value.begins_with("SMOKE:") and text_value != "SMOKE:%s" % multiplayer_smoke_name:
			saw_other_chat = true
			break
	var visible_remote_count := 0
	var complete_remote_count := 0
	for raw_peer_id in remote_players.keys():
		var peer_id := int(raw_peer_id)
		var remote_pos := network_player_position(peer_id)
		if visible_world(remote_pos, 130):
			visible_remote_count += 1
		var remote_state: Dictionary = remote_players[raw_peer_id]
		var pos_data: Array = remote_state.get("pos", [])
		var facing_data: Array = remote_state.get("facing", [])
		if pos_data.size() >= 2 and facing_data.size() >= 2 and remote_state.has("class") and remote_state.has("race") and str(remote_state.get("name", "")).strip_edges() != "":
			complete_remote_count += 1
	var saw_remote_attack := remote_combat_visuals.size() >= 1 or multiplayer_smoke_saw_attack
	var party_ok := (party_state.get("members",[]) as Array).size() >= 2
	var ping_ok := network_ping_ms >= 0
	for enemy in enemies:
		var uid := int(enemy.get("uid",-1))
		var position: Vector2 = enemy["pos"]
		if not multiplayer_smoke_mob_origins.has(uid): multiplayer_smoke_mob_origins[uid] = position
		elif position.distance_to(multiplayer_smoke_mob_origins[uid]) > 4.0: multiplayer_smoke_mobs_moved = true
	# World-snapshot presence is deterministic here; actual mob movement/combat is covered by
	# check_spawn_network.gd and check_mob_combat_network.gd. Do not make this release smoke
	# depend on a random mob walking >4 px inside its short observation window.
	if remote_players.size() >= 1 and visible_remote_count >= 1 and complete_remote_count >= 1 and enemies.size() >= 1 and saw_other_chat and saw_remote_attack and party_ok and ping_ok and multiplayer_smoke_success_since == 0:
		multiplayer_smoke_success_since = Time.get_ticks_msec()
		multiplayer_smoke_deadline=maxi(multiplayer_smoke_deadline,multiplayer_smoke_success_since+4000)
		print("MULTIPLAYER_SMOKE_READY name=", multiplayer_smoke_name, " peers=", remote_players.size(), " visible=", visible_remote_count, " complete=", complete_remote_count, " enemies=", enemies.size(), " combat=", saw_remote_attack, " party=", party_ok, " ping=", network_ping_ms)
	# Sobald dieser Client den anderen Spieler, dessen Chat und den
	# Server-Snapshot gemeinsam gesehen hat, ist die Relay-Prüfung erfüllt.
	# Er bleibt nur noch kurz online, damit der Gegenclient dasselbe prüfen kann.
	if multiplayer_smoke_success_since > 0 and Time.get_ticks_msec() - multiplayer_smoke_success_since >= 2500:
		print("MULTIPLAYER_SMOKE_OK name=", multiplayer_smoke_name, " peers=", remote_players.size(), " visible=", visible_remote_count, " complete=", complete_remote_count, " enemies=", enemies.size(), " moving=",multiplayer_smoke_mobs_moved, " combat=", saw_remote_attack, " party=", party_ok, " ping=", network_ping_ms)
		get_tree().quit(0)
		return
	if multiplayer_smoke_deadline > 0 and Time.get_ticks_msec() > multiplayer_smoke_deadline:
		print("MULTIPLAYER_SMOKE_FAIL name=", multiplayer_smoke_name, " peers=", remote_players.size(), " visible=", visible_remote_count, " complete=", complete_remote_count, " enemies=", enemies.size(), " chat=", saw_other_chat, " combat=", saw_remote_attack, " party=", party_ok, " ping=", network_ping_ms)
		get_tree().quit(32)

func _ready() -> void:
	var spawn_body:StaticBody2D=SpawnStoneBody.attach(self,0)
	spawn_body.position=WAYSTONES[0]
	controller.setup()
	setup_multiplayer_signals()
	var user_args := OS.get_cmdline_user_args()
	dedicated_server_mode = OS.has_feature("dedicated_server") or "--dedicated-server" in user_args
	multiplayer_smoke_client_mode = "--multiplayer-smoke-client" in user_args
	if dedicated_server_mode:
		var notice_path := server_patch_notice_path()
		if FileAccess.file_exists(notice_path): patch_notice.last_token = FileAccess.get_file_as_string(notice_path).strip_edges().left(80)
		reset_class_skills()
		for i in QUESTS.size():
			quests.append({"state":0, "progress":0})
		for i in WORLD_EVENTS.size():
			event_states.append(0)
			event_progress.append(0)
		panel = ""
		start_websocket_server()
		return
	font = ThemeDB.fallback_font
	touch_enabled = detect_touch_capability()
	mobile_performance_mode = touch_enabled and is_web_platform()
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
	ensure_player_uuid()
	previous_region = region_at(player_pos)
	for i in 4:
		spawn_enemy()
	panel = "start"
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -80.0
	add_child(music_player)
	music_incoming = AudioStreamPlayer.new()
	music_incoming.volume_db = -80.0
	add_child(music_incoming)
	for name in SFX_NAMES:
		sound_streams[name] = load("res://audio/%s.wav" % name)
	sound_streams["arrow_break"]=CombatFeedback.break_sound(true)
	sound_streams["magic_break"]=CombatFeedback.break_sound(false)
	for i in 8:
		var player := AudioStreamPlayer.new()
		player.volume_db = -15.0
		add_child(player)
		sound_players.append(player)
	update_music()
	if multiplayer_smoke_client_mode:
		enemies.clear()
		projectiles.clear()
		enemy_projectiles.clear()
		start_multiplayer_smoke_client()
	if "--konflux-preview" in user_args:
		# Separate test save; ordinary character saves are never overwritten.
		konflux_preview_mode=true
		creative_mode=true
		hero_name="Konflux-Testheld"
		character_created=true
		level=40
		for id in CLASS_SKILLS[class_id]+[CLASS_ULTIMATES[class_id]]:
			learned[id]=true
			skill_levels[id]=1
		slots=CLASS_SKILLS[class_id].slice(0,3)
		arcane_step_learned=true
		konflux.enter(self)

func reset_class_skills() -> void:
	arcane_step_learned = false
	class_mastery_unlocked = false
	warrior_rage = 0.0
	ranger_hunt_meter = 0.0
	ranger_hunt_buff = 0.0
	ranger_stealth_timer = 0.0
	robotics_overclock_timer = 0.0
	learned.resize(ABILITIES.size())
	skill_levels.resize(ABILITIES.size())
	cooldowns.resize(ABILITIES.size())
	for i in ABILITIES.size():
		learned[i] = false
		skill_levels[i] = 0
		cooldowns[i] = 0.0
	slots = [-1, -1, -1]

func class_weapon_icon() -> String:
	return class_weapon_icon_for(class_id)

func class_ultimate() -> int:
	return CLASS_ULTIMATES[class_id]

func setup_multiplayer_signals() -> void:
	if not multiplayer.peer_connected.is_connected(_on_peer_connected): multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected): multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server): multiplayer.connected_to_server.connect(_on_connected_to_server)
	if not multiplayer.connection_failed.is_connected(_on_connection_failed): multiplayer.connection_failed.connect(_on_connection_failed)
	if not multiplayer.server_disconnected.is_connected(_on_server_disconnected): multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_peer_connected(id: int) -> void:
	network_status = "Spieler %d verbunden" % id
	add_chat_line("SYSTEM", network_status)
	if network_mode == "host":
		push_world_snapshot()
		if not dedicated_server_mode:
			var host_state := {"pos":[player_pos.x,player_pos.y], "facing":[facing.x,facing.y], "class":class_id, "race":hero_race, "gender":hero_gender, "name":hero_name, "level":level, "walking":is_walking, "weapon":equipped_weapon_design(), "armor":armor_visual(),"head":head_visual(),"rings":ring_visual(), "element":weapon_element(), "region":region_at(player_pos)}
			rpc_receive_player_state.rpc_id(id, 1, host_state)
		for peer_id in remote_players.keys():
			if int(peer_id) != id:
				rpc_receive_player_state.rpc_id(id, int(peer_id), remote_players[peer_id])

func _on_connected_to_server() -> void:
	server_last_reply_ms = Time.get_ticks_msec()
	server_sync_status.clear()
	client_ping_timer = 0.0
	if konflux.active:
		konflux.active=false
		player_pos=konflux.return_position
		message("Neu verbunden. Betritt Konflux erneut durch das Tor.")
	local_peer_id = multiplayer.get_unique_id()
	live_reconnect_timer = 0.0
	network_status = "Online · Peer %d" % local_peer_id
	add_chat_line("SYSTEM", "Mit dem Sonnenhain-Live-Server verbunden.")
	if character_created:
		rpc_player_presence.rpc_id(1, local_player_state())
		push_player_state()
		server_save.begin(self)

func _on_connection_failed() -> void:
	network_status = "Live-Server momentan nicht erreichbar · neuer Versuch …"
	disconnect_multiplayer(false)
	if character_created and not creative_mode and not multiplayer_smoke_client_mode:
		live_reconnect_timer = 2.0

func _on_server_disconnected() -> void:
	server_save.disconnected()
	network_status = "Live-Server-Verbindung unterbrochen · verbinde neu …"
	remote_players.clear()
	network_mode = "offline"
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	if character_created and not creative_mode and not multiplayer_smoke_client_mode:
		live_reconnect_timer = 2.0

func to_base36(value: int) -> String:
	var chars := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var n := maxi(0, value)
	if n == 0: return "0"
	var out := ""
	while n > 0:
		out = chars.substr(n % 36, 1) + out
		n = int(n / 36)
	return out

func from_base36(value: String) -> int:
	var chars := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var out := 0
	for i in value.length():
		var ch := value.to_upper().substr(i, 1)
		var idx := chars.find(ch)
		if idx < 0: return -1
		out = out * 36 + idx
	return out

func ipv4_to_int(address: String) -> int:
	var parts := address.split(".")
	if parts.size() != 4: return -1
	var result := 0
	for part in parts:
		var octet := int(part)
		if octet < 0 or octet > 255: return -1
		result = (result << 8) | octet
	return result

func int_to_ipv4(value: int) -> String:
	return "%d.%d.%d.%d" % [(value >> 24) & 255, (value >> 16) & 255, (value >> 8) & 255, value & 255]

func make_invite_code(address: String, port: int) -> String:
	var packed := ipv4_to_int(address)
	if packed < 0: return ""
	return "SH-%s-%s" % [to_base36(packed), to_base36(port)]

func decode_invite_code(code: String) -> Dictionary:
	var cleaned := code.strip_edges().to_upper()
	var parts := cleaned.split("-")
	if parts.size() != 3 or parts[0] != "SH": return {}
	var packed := from_base36(parts[1])
	var port := from_base36(parts[2])
	if packed < 0 or port <= 0 or port > 65535: return {}
	return {"address":int_to_ipv4(packed), "port":port}

func preferred_host_address() -> String:
	# UPnP liefert bei unterstützten Routern direkt die öffentliche IPv4-Adresse und richtet UDP-Portweiterleitung ein.
	var upnp := UPNP.new()
	var discover_result := upnp.discover(1600, 2, "InternetGatewayDevice")
	if discover_result == UPNP.UPNP_RESULT_SUCCESS and upnp.get_gateway() != null and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(network_port, network_port, "Sonnenhain Koop", "UDP", 0)
		var public_ip := upnp.query_external_address()
		if public_ip != "": return public_ip
	for address in IP.get_local_addresses():
		if "." in address and not address.begins_with("127.") and not address.begins_with("169.254."):
			return address
	return "127.0.0.1"

func start_websocket_server() -> void:
	var home_dir := OS.get_environment("HOME")
	var save_dir := command_arg_value("--save-dir=",home_dir.path_join("sonnenhain-server/data/player-saves") if home_dir != "" else "user://server-player-saves")
	if server_save_store.configure(save_dir) != OK:
		push_error("Server-Speicherverzeichnis konnte nicht geöffnet werden")
	websocket_port = clampi(int(command_arg_value("--server-port=", "27845")), 1024, 65535)
	disconnect_multiplayer(false)
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_server(websocket_port, "127.0.0.1")
	if err != OK:
		network_status = "Dedicated Server konnte nicht starten · Fehler %d" % err
		push_error(network_status)
		return
	multiplayer.multiplayer_peer = peer
	network_mode = "host"
	local_peer_id = 1
	network_status = "Dedicated WebSocket Server aktiv · Port %d" % websocket_port
	print(network_status)

func join_live_multiplayer() -> void:
	if network_mode == "client" and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		return
	disconnect_multiplayer(false)
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_client(command_arg_value("--test-server-url=", "ws://127.0.0.1:31879") if "--local-test" in OS.get_cmdline_user_args() else LIVE_MULTIPLAYER_URL)
	if err != OK:
		network_status = "Online-Server konnte nicht kontaktiert werden · Fehler %d" % err
		return
	multiplayer.multiplayer_peer = peer
	network_mode = "client"
	network_status = "Verbinde mit Sonnenhain Live-Server …"
	live_reconnect_timer = 0.0

func host_multiplayer() -> void:
	disconnect_multiplayer(false)
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(network_port, 4)
	if err != OK:
		network_status = "Host konnte nicht gestartet werden · Fehler %d" % err
		return
	multiplayer.multiplayer_peer = peer
	network_mode = "host"
	local_peer_id = 1
	var address := preferred_host_address()
	invite_code = make_invite_code(address, network_port)
	network_status = "Host aktiv · Einladungscode %s" % invite_code
	add_chat_line("SYSTEM", "Koop-Host gestartet.")

func join_multiplayer_from_code(code: String) -> void:
	var endpoint := decode_invite_code(code)
	if endpoint.is_empty():
		network_status = "Ungültiger Einladungscode."
		return
	disconnect_multiplayer(false)
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(str(endpoint["address"]), int(endpoint["port"]))
	if err != OK:
		network_status = "Verbindung konnte nicht gestartet werden · Fehler %d" % err
		return
	multiplayer.multiplayer_peer = peer
	network_mode = "client"
	network_status = "Verbinde mit %s …" % str(endpoint["address"])

func disconnect_multiplayer(show_message: bool = true) -> void:
	server_save.disconnected()
	if network_mode != "offline" and multiplayer.multiplayer_peer != null: multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	remote_players.clear()
	network_mode = "offline"
	invite_code = ""
	if show_message: network_status = "Offline"

func server_action_allowed(peer_id: int, action_key: String, cooldown_ms: int) -> bool:
	if peer_id <= 0: return false
	var now := Time.get_ticks_msec()
	var key := "%d:%s" % [peer_id, action_key]
	var previous := int(server_action_times.get(key, 0))
	if now - previous < cooldown_ms: return false
	server_action_times[key] = now
	return true

@rpc("authority", "call_remote", "reliable")
func rpc_server_damage(amount: int) -> void:
	if network_mode != "client": return
	if invulnerable <= 0.0:
		apply_player_damage(clampi(amount, 1, 500))

@rpc("authority", "call_remote", "reliable")
func rpc_server_combat_reward(tx_id: String, enemy_type: int, xp_reward: int, gold_reward: int, item_rewards: Array) -> void:
	if network_mode != "client": return
	tx_id = tx_id.substr(0,96)
	if not remember_server_transaction(tx_id):
		ack_server_transaction(tx_id)
		return
	enemy_type = clampi(enemy_type, 0, ENEMY_TYPES.size() - 1)
	if enemy_type in [12,13,14]: register_boss_defeat(enemy_type-12,false)
	xp_reward = clampi(xp_reward, 0, 100000)
	gold_reward = clampi(gold_reward, 0, 100000)
	if xp_reward > 0:
		gain_xp(xp_reward)
	if gold_reward > 0:
		gold += gold_reward
	for raw_item in item_rewards:
		if not raw_item is Dictionary: continue
		var item: Dictionary = sanitize_network_reward_item(raw_item)
		if not add_item(item):
			var compensation := maxi(1, item_sale_value(item))
			gold += compensation
			message("Inventar voll · Beute automatisch für %d Gold verkauft." % compensation)
	if xp_reward > 0 or gold_reward > 0 or not item_rewards.is_empty():
		play_sound("pickup")
		message("+%d XP · +%d Gold%s" % [xp_reward, gold_reward, " · Beute erhalten" if not item_rewards.is_empty() else ""])
		save_game()
	ack_server_transaction(tx_id)

func push_player_state() -> void:
	if network_mode == "offline" or multiplayer.multiplayer_peer == null or dedicated_server_mode: return
	if not multiplayer_smoke_client_mode and (panel != "" or not character_created):
		return
	if network_mode == "client" and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	var state := local_player_state()
	if network_mode == "client":
		rpc_player_state.rpc_id(1, state)
	elif network_mode == "host":
		for peer_id in multiplayer.get_peers():
			rpc_receive_player_state.rpc_id(int(peer_id), 1, state)
	if network_mode == "host" and int(world_time * 5.0) % 2 == 0: push_world_snapshot()

@rpc("any_peer", "call_remote", "unreliable", 0)
func rpc_player_state(state: Dictionary,reliable_vitals:bool=false) -> void:
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0: return
	var pos_data: Array = state.get("pos", [])
	var facing_data: Array = state.get("facing", [])
	if pos_data.size() < 2 or facing_data.size() < 2: return
	var incoming_pos := Vector2(float(pos_data[0]), float(pos_data[1]))
	if not incoming_pos.is_finite(): return
	var in_konflux: bool = konflux.fighter_stats.has(sender)
	var room_id: int = int(konflux.fighter_stats[sender]["room"]) if in_konflux else -1
	incoming_pos = incoming_pos.clamp(Vector2(30, 30), (KonfluxMap.SIZE if in_konflux else WORLD) - Vector2(30, 30))
	var protocol := int(state.get("protocol",-1))
	if protocol != NETWORK_PROTOCOL_VERSION: return
	var context := str(state.get("context","world"))
	if context not in ["world","tavern","dungeon","arena"]: context = "world"
	var instance_id := str(state.get("instance_id","world")).substr(0,24)
	if context == "world": instance_id = "world"
	if in_konflux:
		context = "konflux"
		instance_id = str(room_id)
	var teleported:=false
	var context_changed := false
	if network_mode == "host" and remote_players.has(sender):
		context_changed = str(remote_players[sender].get("context","world")) != context or str(remote_players[sender].get("instance_id","world")) != instance_id
	if network_mode=="host" and remote_players.has(sender):
		var previous:Dictionary=remote_players[sender]
		var old_data:Array=previous.get("pos",[incoming_pos.x,incoming_pos.y])
		teleported=int(state.get("teleport_serial",0))>int(previous.get("teleport_serial",0)) and valid_network_teleport(Vector2(float(old_data[0]),float(old_data[1])),incoming_pos,previous,context)
	if network_mode == "host" and remote_players.has(sender) and not context_changed and not teleported:
		var old_data: Array = remote_players[sender].get("pos", [incoming_pos.x, incoming_pos.y])
		var old_pos := Vector2(float(old_data[0]), float(old_data[1]))
		if incoming_pos.distance_to(old_pos) > 95.0:
			incoming_pos = old_pos + (incoming_pos - old_pos).limit_length(95.0)
		if in_konflux:
			var step_count := maxi(1,ceili(incoming_pos.distance_to(old_pos)/12.0))
			var accepted := old_pos
			for step in range(1,step_count+1):
				var target := old_pos.lerp(incoming_pos,float(step)/step_count)
				if KonfluxMap.blocked(target,accepted,room_id): break
				accepted=target
			incoming_pos=accepted
		elif context=="world" and (region_at(old_pos)==0 or region_at(incoming_pos)==0):
			var radius:float=[15.0,18.0,16.0][clampi(int(state.get("race",0)),0,2)]-(1.0 if int(state.get("gender",0))==1 else 0.0)
			incoming_pos=WAYSTONES[0]+SpawnStoneBody.accepted_move(old_pos-WAYSTONES[0],incoming_pos-WAYSTONES[0],radius)
	if in_konflux and incoming_pos.distance_to(Vector2(float(pos_data[0]),float(pos_data[1])))>20:
		rpc_konflux_correct.rpc_id(sender,[incoming_pos.x,incoming_pos.y])
	var clean_facing := Vector2(float(facing_data[0]), float(facing_data[1]))
	if not clean_facing.is_finite() or clean_facing.length_squared() < 0.01: clean_facing = Vector2.DOWN
	clean_facing = clean_facing.normalized()
	var clean := {
		"protocol":NETWORK_PROTOCOL_VERSION,
		"uuid":str(state.get("uuid","")).strip_edges().substr(0,64),
		"context":context,
		"instance_id":instance_id,
		"rescue_state":clampi(int(state.get("rescue_state",0)),0,3),
		"rescue_kills":clampi(int(state.get("rescue_kills",0)),0,RESCUE_GOAL),
		"active_quests":sanitize_active_quest_rows(state.get("active_quests",[])),
		"active_events":sanitize_active_event_rows(state.get("active_events",[])),
		"pos":[incoming_pos.x,incoming_pos.y],
		"facing":[clean_facing.x,clean_facing.y],
		"class":clampi(int(state.get("class",0)),0,2),
		"race":clampi(int(state.get("race",0)),0,2),
		"gender":clampi(int(state.get("gender",0)),0,1),
		"name":str(state.get("name","Held")).strip_edges().substr(0,16),
		"level":clampi(int(state.get("level",1)),1,99),
		"hp":clampf(float(state.get("hp",1.0)),0.0,100000.0),
		"max_hp":clampf(float(state.get("max_hp",1.0)),1.0,100000.0),
		"walking":bool(state.get("walking",false)),
		"weapon":clampi(int(state.get("weapon",0)),0,32),
		"armor":clampi(int(state.get("armor",-1)),-1,32),
		"head":clampi(int(state.get("head",-1)),-1,2),"rings":clampi(int(state.get("rings",0)),0,3),
		"element":str(state.get("element","")) if str(state.get("element","")) in ["","feuer","eis","blitz","gift"] else "",
		"region":region_at(incoming_pos),
		"stealth":bool(state.get("stealth",false)) and clampi(int(state.get("class",0)),0,2)==2
	}
	clean["teleport_serial"]=int(state.get("teleport_serial",0)) if teleported or context_changed or not remote_players.has(sender) else int(remote_players[sender].get("teleport_serial",0))
	clean["state_tick"]=Time.get_ticks_msec()
	clean["death_progress"]=clampf(float(state.get("death_progress",0)),0,1) if float(clean["hp"])<=0 else -1.0
	clean["konflux"] = in_konflux
	clean["room"] = room_id
	remote_players[sender] = clean
	if context_changed:
		send_server_session_status(sender)
	if network_mode == "host":
		for peer_id in multiplayer.get_peers():
			if int(peer_id) != sender:
				if reliable_vitals:rpc_receive_player_vitals.rpc_id(int(peer_id),sender,clean)
				else:rpc_receive_player_state.rpc_id(int(peer_id), sender, clean)

@rpc("authority", "call_remote", "unreliable", 0)
func rpc_receive_player_state(peer_id: int, state: Dictionary) -> void:
	if peer_id == multiplayer.get_unique_id(): return
	var previous:Dictionary=remote_players.get(peer_id,{})
	if int(state.get("state_tick",0))<int(previous.get("state_tick",0)):return
	if float(state.get("hp",1))<float(previous.get("hp",state.get("hp",1))):state["hurt_until"]=combat_feedback.clock+.18
	else:state["hurt_until"]=previous.get("hurt_until",0.0)
	remote_players[peer_id] = state
	var coords: Array = state.get("pos",[])
	if coords.size() >= 2 and (not remote_player_render_positions.has(peer_id) or int(state.get("teleport_serial",0))!=int(previous.get("teleport_serial",0)) or str(state.get("context","world"))!=str(previous.get("context","world")) or str(state.get("instance_id","world"))!=str(previous.get("instance_id","world"))):
		remote_player_render_positions[peer_id] = Vector2(float(coords[0]),float(coords[1]))
		for index in range(remote_combat_visuals.size()-1,-1,-1):
			if int(remote_combat_visuals[index].get("peer_id",-1))==peer_id:remote_combat_visuals.remove_at(index)
	queue_redraw()

func push_world_snapshot() -> void:
	if network_mode != "host": return
	var enemy_rows: Array = []
	for enemy in enemies:
		var state:Dictionary=enemy.get("attack_state",{}).duplicate(true)
		if state.has("dir"):state["dir"]=[state["dir"].x,state["dir"].y]
		var face:Vector2=enemy.get("facing",Vector2.DOWN)
		enemy_rows.append({"attack_state":state,"attack_wait":enemy.get("attack_wait",0.0),"target_peer":enemy.get("target_peer",-1),"facing":[face.x,face.y],"walking":enemy.get("walking",false),"guardian_of":enemy.get("guardian_of",-1),"small_guardian":enemy.get("small_guardian",false),"uid":enemy.get("uid",0), "context":"world", "instance_id":"world", "region":region_at(enemy["pos"]), "type":enemy.get("type",0), "pos":[enemy["pos"].x,enemy["pos"].y], "hp":enemy.get("hp",1.0), "max_hp":enemy.get("max_hp",1.0), "elite":enemy.get("elite",0), "flash":enemy.get("flash",0.0), "shot":enemy.get("shot",1.0), "hit":enemy.get("hit",0.0), "seed":enemy.get("seed",0.0), "stun":enemy.get("stun",0.0), "slow":enemy.get("slow",0.0), "poison":enemy.get("poison",0.0), "poison_tick":enemy.get("poison_tick",1.0), "marked":enemy.get("marked",0.0)})
	var shot_rows: Array = []
	for shot in enemy_projectiles:
		shot_rows.append({"pos":[shot["pos"].x,shot["pos"].y],"dir":[shot["dir"].x,shot["dir"].y],"speed":shot.get("speed",265.0),"life":shot.get("life",1.0),"damage":shot.get("damage",1),"type":shot.get("type",0),"hit_radius":shot.get("hit_radius",14.0)})
	var drop_rows:Array=[]
	for drop in drops:
		if not drop.has("drop_uid") or not drop.has("item"):continue
		var dp:Vector2=drop["pos"]
		drop_rows.append({"drop_uid":int(drop["drop_uid"]),"pos":[dp.x,dp.y],"item":drop["item"],"life":float(drop.get("life",0.0)),"reserved_class":int(drop.get("reserved_class",-1)),"reserve_ms":maxi(0,int(drop.get("reserve_until_ms",0))-Time.get_ticks_msec())})
	var snapshot := {"protocol":NETWORK_PROTOCOL_VERSION,"context":"world","instance_id":"world","mobs":enemy_rows.size(),"enemies":enemy_rows,"shots":shot_rows,"drops":drop_rows}
	for peer_id in multiplayer.get_peers():
		var state: Dictionary = remote_players.get(int(peer_id),{})
		if str(state.get("context","world")) == "world":
			rpc_world_snapshot.rpc_id(int(peer_id),snapshot)

@rpc("authority", "call_remote", "unreliable", 1)
func rpc_world_snapshot(snapshot: Dictionary) -> void:
	if network_mode != "client" or multiplayer_context() != "world": return
	if int(snapshot.get("protocol",-1)) != NETWORK_PROTOCOL_VERSION: return
	if str(snapshot.get("context","world")) != "world": return
	server_last_reply_ms = Time.get_ticks_msec()
	var previous_by_uid: Dictionary = {}
	for existing in enemies:
		previous_by_uid[int(existing.get("uid",-1))] = existing
	var rebuilt: Array = []
	for raw in snapshot.get("enemies", []):
		if not raw is Dictionary: continue
		var copy: Dictionary = raw.duplicate()
		var coords: Array = raw.get("pos", [0.0,0.0])
		var target := Vector2(float(coords[0]),float(coords[1]))
		var uid := int(raw.get("uid",-1))
		if dead_mob_uids.has(uid) and combat_feedback.clock-float(dead_mob_uids[uid])<6:continue
		var attack:Dictionary=copy.get("attack_state",{})
		if attack.has("dir"):
			var aim:Array=attack["dir"]
			attack["dir"]=Vector2(float(aim[0]),float(aim[1]))
		var face:Array=raw.get("facing",[0.0,1.0])
		copy["facing"]=Vector2(float(face[0]),float(face[1]))
		copy["net_target_pos"] = target
		if previous_by_uid.has(uid):
			var old: Dictionary = previous_by_uid[uid]
			copy["pos"] = old.get("pos",target)
			copy["flash"]=maxf(float(copy.get("flash",0)),float(old.get("flash",0)))
			if float(copy.get("hp",1))<float(old.get("hp",1)):copy["flash"]=.18
		else:
			copy["pos"] = target
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
	var rebuilt_drops:Array=[]
	for raw in snapshot.get("drops",[]):
		if not raw is Dictionary:continue
		var coords:Array=raw.get("pos",[])
		if coords.size()<2:continue
		var item_raw:Variant=raw.get("item",{})
		if not item_raw is Dictionary:continue
		var drop:Dictionary=raw.duplicate(true)
		drop["pos"]=Vector2(float(coords[0]),float(coords[1]))
		drop["item"]=sanitize_network_reward_item(item_raw)
		drop["reserve_until_ms"]=Time.get_ticks_msec()+maxi(0,int(raw.get("reserve_ms",0)))
		rebuilt_drops.append(drop)
	drops=rebuilt_drops

@rpc("any_peer","call_remote","reliable")
func rpc_request_world_drop_pickup(drop_uid:int) -> void:
	if network_mode!="host" or not dedicated_server_mode:return
	var sender:=multiplayer.get_remote_sender_id()
	if sender<=0 or not remote_players.has(sender) or not server_action_allowed(sender,"pickup:%d" % drop_uid,180):return
	for i in range(drops.size()-1,-1,-1):
		var drop:Dictionary=drops[i]
		if int(drop.get("drop_uid",-1))!=drop_uid:continue
		if network_player_position(sender).distance_to(Vector2(drop["pos"]))>72.0:return
		var player_class:=clampi(int(remote_players[sender].get("class",0)),0,2)
		if class_relic_locked_for_player(drop,player_class):
			rpc_world_drop_denied.rpc_id(sender,drop_uid,"Dieses Relikt ist noch für %s reserviert." % CLASS_NAMES[int(drop.get("reserved_class",0))])
			return
		var payload:Dictionary=drop["item"].duplicate(true)
		drops.remove_at(i)
		rpc_world_drop_granted.rpc_id(sender,drop_uid,payload)
		push_world_snapshot()
		return

@rpc("authority","call_remote","reliable")
func rpc_world_drop_granted(drop_uid:int,raw_item:Dictionary) -> void:
	if network_mode!="client":return
	var item:=sanitize_network_reward_item(raw_item)
	if not add_item(item):
		message("Inventar voll · der Fund konnte nicht aufgenommen werden.")
		return
	play_sound("pickup")
	message("Aufgehoben: %s · %s" % [item["name"],RARITY_NAMES[int(item["rarity"])]])
	world_drop_request_times.erase(drop_uid)
	save_game()

@rpc("authority","call_remote","reliable")
func rpc_world_drop_denied(drop_uid:int,reason:String) -> void:
	if network_mode!="client":return
	world_drop_request_times[drop_uid]=Time.get_ticks_msec()+900
	message(reason.substr(0,120))

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
	if clean.to_lower().begins_with("/invite "):
		var target_name := clean.substr(8).strip_edges()
		if network_mode == "client" and target_name != "":
			rpc_party_command.rpc_id(1,{"action":"invite","name":target_name})
		elif network_mode != "client":
			add_chat_line("GRUPPE","Gruppenbefehle benötigen den Live-Server.")
		return
	if clean.to_lower() == "/accept":
		if network_mode == "client": rpc_party_command.rpc_id(1,{"action":"accept"})
		return
	if clean.to_lower() == "/decline":
		if network_mode == "client": rpc_party_command.rpc_id(1,{"action":"decline"})
		return
	if clean.to_lower() == "/leave":
		if network_mode == "client": rpc_party_command.rpc_id(1,{"action":"leave"})
		return
	var author := hero_name.strip_edges().substr(0,20) if hero_name.strip_edges() != "" else "Held"
	add_chat_line(author, clean)
	if network_mode == "client":
		rpc_chat_message.rpc_id(1, author, clean)
	elif network_mode == "host":
		for peer_id in multiplayer.get_peers():
			rpc_chat_relay.rpc_id(int(peer_id), author, clean)

@rpc("any_peer", "call_remote", "reliable")
func rpc_chat_message(_author: String, value: String) -> void:
	if network_mode != "host": return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0: return
	var safe_author := "Held"
	if remote_players.has(sender):
		safe_author = str(remote_players[sender].get("name","Held")).strip_edges().substr(0,20)
	var clean := value.strip_edges().substr(0,120)
	if clean == "": return
	add_chat_line(safe_author, clean)
	for peer_id in multiplayer.get_peers():
		if int(peer_id) != sender:
			rpc_chat_relay.rpc_id(int(peer_id), safe_author, clean)

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

func desired_music_theme() -> String:
	if konflux.active: return "dorf" if KonfluxMap.safe(player_pos,konflux.room) else "konflux-pvp"
	var region:int=region_at(player_pos)
	return "dorf" if panel=="start" or interior_id>=0 else ("boss" if arena_mode!="" else (["ruinen","kristall","quelle"][dungeon_id] if dungeon_id>=0 else MUSIC_THEMES[region]))

func update_music(delta: float = 0.0) -> void:
	if music_player == null or music_incoming == null: return
	if not music_enabled:
		music_player.stop()
		music_incoming.stop()
		music_fading = false
		music_theme = ""
		return
	var desired:String=desired_music_theme()
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
		var path: String = "res://music/%s.ogg" % desired if (desired in CUSTOM_MUSIC_THEMES or desired=="konflux-pvp") else "res://audio/%s.wav" % desired
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
	return 100.0 + float(level - 1) * 8.0 + float(skill_levels[10]) * 25.0 + equipment_power(equipped_ring_uid) + (equipment_power(equipped_ring2_uid) if class_id == 1 and equipped_ring2_uid != equipped_ring_uid else 0) + item_attribute("str") * (2 if class_id == 0 else 1)

func max_energy() -> float:
	return 100.0 + float(skill_levels[11]) * 25.0

func equipment_power(uid: int) -> int:
	for item in inventory:
		if int(item.get("uid", -1)) == uid:
			return int(item.get("power", 0))
	return 0

func equipped_item_uids() -> Array:
	var ids := [equipped_uid,equipped_armor_uid,equipped_head_uid,equipped_ring_uid]
	if class_id == 1 and equipped_ring2_uid >= 0 and equipped_ring2_uid != equipped_ring_uid: ids.append(equipped_ring2_uid)
	return ids

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
	return ceili(float(ENEMY_TYPES[type]["damage"]) * (1.12 + 0.055 * (region_level(region)+(5 if type in [12,13,14] else 0))))

func enemy_level(type: int) -> int:
	var region: int = int(ENEMY_TYPES[type]["region"])
	return region_level(region) + (7 if type in [12, 13, 14] else type % 3)

func update_connection_health(delta: float) -> void:
	if network_mode != "client" or multiplayer.multiplayer_peer == null: return
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED: return
	client_ping_timer = maxf(0.0,client_ping_timer-delta)
	if client_ping_timer <= 0.0:
		client_ping_timer = 2.0
		rpc_client_ping.rpc_id(1,Time.get_ticks_msec())
	if server_last_reply_ms > 0 and Time.get_ticks_msec()-server_last_reply_ms > 12000:
		disconnect_multiplayer(false)
		server_sync_status.clear()
		network_ping_ms = 0
		network_status = "Keine Serverantwort · verbinde neu. Bei erneutem Fehler Spielseite aktualisieren."
		add_chat_line("SYSTEM",network_status)
		live_reconnect_timer = 1.0

func enemy_xp_reward(type: int, elite_kind: int, recipient_level: int) -> int:
	type = clampi(type, 0, ENEMY_TYPES.size()-1)
	var area_level := region_level(int(ENEMY_TYPES[type]["region"]))
	var base_xp := float(int(ENEMY_TYPES[type]["xp"]) + area_level * 3 + int(area_level * area_level * 0.15)) * float([1.0,1.55,2.4][clampi(elite_kind,0,2)])
	return ExperienceRules.reward(base_xp, recipient_level, enemy_level(type))

func _process(delta: float) -> void:
	combat_feedback.step(delta)
	if character_created and Vector2(hp,max_hp())!=last_vitals:push_vital_state()
	if not dedicated_server_mode: food_system.tick(self,delta)
	update_connection_health(delta)
	server_save.update(self)
	if not dedicated_server_mode: controller.update(self, delta)
	if death_timer > 0.0:
		death_timer = maxf(0.0,death_timer-delta)
		if death_timer <= 0.0:
			panel = ""
			respawn()
		queue_redraw()
		return
	if dedicated_server_mode:
		process_dedicated_server(delta)
		return
	if konflux.active:
		konflux.update(self,delta)
		return
	if server_save.loading:
		queue_redraw()
		return
	if character_created and panel not in ["start","creation"]:
		server_save_timer -= delta
		if server_save_timer <= 0:
			server_save_timer = 5.0
			save_game()
	process_multiplayer_smoke(delta)
	update_music(delta)
	if panel == "pause":
		queue_redraw()
		return
	if panel == "intro":
		intro_timer -= delta
		if intro_timer <= 0.0: finish_intro()
	world_time += delta
	save_notice_timer = maxf(0.0,save_notice_timer-delta)
	update_network_interpolation(delta)
	if chat_open: chat_fade = 7.0
	else: chat_fade = maxf(0.0, chat_fade - delta)
	if character_created and not creative_mode and not multiplayer_smoke_client_mode and network_mode == "offline" and panel not in ["start", "creation"]:
		live_reconnect_timer = maxf(0.0, live_reconnect_timer - delta)
		if live_reconnect_timer <= 0.0:
			live_reconnect_timer = 3.0
			ensure_live_multiplayer()
	if multiplayer.multiplayer_peer != null and network_mode != "offline":
		sync_timer -= delta
		if sync_timer <= 0.0:
			# Mobile Web muss nicht 20 Statuspakete pro Sekunde senden. 12.5 Hz
			# senkt CPU-/Netzlast deutlich, ohne dass Bewegung sichtbar stottert.
			sync_timer = 0.08 if mobile_performance_mode else 0.05
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
	ranger_hunt_buff = maxf(0.0, ranger_hunt_buff - delta)
	ranger_stealth_timer = maxf(0.0, ranger_stealth_timer - delta)
	robotics_overclock_timer = maxf(0.0, robotics_overclock_timer - delta)
	notice_timer = maxf(0.0, notice_timer - delta)
	rescue_intro_timer = maxf(0.0, rescue_intro_timer - delta)
	rescue_banner_timer = maxf(0.0, rescue_banner_timer - delta)
	reward_scene_timer = maxf(0.0, reward_scene_timer - delta)
	attack_anim = maxf(0.0, attack_anim - delta)
	step_timer = maxf(0.0, step_timer - delta)
	for i in cooldowns.size():
		cooldowns[i] = maxf(0.0, float(cooldowns[i]) - delta * food_system.cooldown_recovery_mult())
	for i in boss_cooldowns.size():
		boss_cooldowns[i] = maxf(0.0, float(boss_cooldowns[i]) - delta)
	if panel == "":
		energy = minf(max_energy(), energy + (4.0 if class_id == 1 else (5.0 if class_id == 0 else 6.0)) * food_system.energy_regen_mult() * delta)
		update_player(delta)
		if arena_mode == "" and dungeon_id < 0 and interior_id < 0: update_rescue()
		update_battle_zones(delta)
		update_impact_zones(delta)
		update_poison_clouds(delta)
		if not uses_server_world(): update_enemies(delta)
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
			if not uses_server_world():
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
	while effects.size() > (24 if mobile_performance_mode else 80): effects.pop_front()
	while spell_visuals.size() > (18 if mobile_performance_mode else 48): spell_visuals.pop_front()
	while lightning_lines.size() > (12 if mobile_performance_mode else 32): lightning_lines.pop_front()
	if mobile_performance_mode:
		# Rein visuelle Effekte dürfen auf Mobilgeräten begrenzt werden. Das
		# verändert keine Trefferlogik, Gegner oder Projektile.
		while effects.size() > 24: effects.pop_front()
		while spell_visuals.size() > 18: spell_visuals.pop_front()
		while lightning_lines.size() > 12: lightning_lines.pop_front()
	for i in range(remote_combat_visuals.size()-1,-1,-1):
		remote_combat_visuals[i]["life"] = float(remote_combat_visuals[i].get("life",0.0))-delta
		if remote_combat_visuals[i]["life"] <= 0.0:
			remote_combat_visuals.remove_at(i)
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
	var target_camera: Vector2 = camera_focus - VIEW * 0.5 if arena_mode != "" else (INTERIOR_CENTER - VIEW * 0.5 if interior_id >= 0 else (player_pos - VIEW * 0.5).clamp(Vector2.ZERO, WORLD - VIEW))
	var context := "%s:%d:%d" % [arena_mode,interior_id,dungeon_id]
	if context != camera_context or camera_smooth.distance_to(target_camera) > 450.0:
		camera_smooth = target_camera
		camera_context = context
	else:
		camera_smooth = camera_smooth.lerp(target_camera,1.0-exp(-14.0*delta))
	camera_pos = camera_smooth.round()
	performance_last_frame_ms = delta*1000.0
	update_static_cache()
	update_foreground_cache()
	save_timer += delta
	var autosave_interval := 30.0 if mobile_performance_mode else 15.0
	if save_timer > autosave_interval and arena_mode == "" and panel != "start":
		save_game()
		save_timer = 0.0
	queue_redraw()

func network_player_position(peer_id: int) -> Vector2:
	if not remote_players.has(peer_id): return Vector2(-10000, -10000)
	var row: Dictionary = remote_players[peer_id]
	var coords: Array = row.get("pos", [])
	if coords.size() < 2: return Vector2(-10000, -10000)
	if network_mode == "client" and remote_player_render_positions.has(peer_id):
		return remote_player_render_positions[peer_id]
	return Vector2(float(coords[0]), float(coords[1]))

func server_active_region_peers() -> Dictionary:
	var regions: Dictionary = {}
	for raw_peer in remote_players.keys():
		var peer_id := int(raw_peer)
		var state: Dictionary = remote_players[raw_peer]
		if str(state.get("context","world")) != "world" or bool(state.get("konflux",false)) or konflux.fighter_stats.has(peer_id):
			continue
		var pos := network_player_position(peer_id)
		if pos.x < -9000.0: continue
		var region := region_at(pos)
		if region == 0: continue
		if not regions.has(region): regions[region] = []
		regions[region].append(peer_id)
	return regions

func server_region_target_mobs(player_count: int) -> int:
	if player_count <= 0: return 0
	if player_count == 1: return 8
	if player_count == 2: return 12
	if player_count <= 4: return 16
	return 22

func server_region_normal_mob_count(region: int) -> int:
	var count := 0
	for enemy in enemies:
		if int(enemy.get("type",-1)) in [12,13,14] or bool(enemy.get("small_guardian",false)): continue
		if str(enemy.get("context","world")) != "world": continue
		if region_at(Vector2(enemy["pos"])) == region: count += 1
	return count

func server_spawn_enemy_for_region(target_region: int, peers: Array) -> bool:
	if target_region == 0 or peers.is_empty() or normal_mob_count() >= SERVER_WORLD_MOB_CAP: return false
	var candidates: Array = []
	for i in ENEMY_TYPES.size():
		if i not in [12,13,14] and int(ENEMY_TYPES[i]["region"]) == target_region:
			candidates.append(i)
	if candidates.is_empty(): return false
	var peer_id := int(peers[randi() % peers.size()])
	var center := network_player_position(peer_id)
	if center.x < -9000.0: return false
	var type := int(candidates.pick_random())
	var chosen := Vector2(-10000,-10000)
	for attempt in 18:
		var pos := center + Vector2.RIGHT.rotated(randf()*TAU) * randf_range(520.0,820.0)
		if spawn_position_allowed(pos,target_region) and pos.distance_to(center) >= 420.0:
			chosen = pos
			break
	if chosen.x < -9000.0:
		for step in 12:
			var distance := 580.0 + float(step % 3) * 90.0
			var pos := center + Vector2.RIGHT.rotated((TAU/12.0)*float(step)) * distance
			if spawn_position_allowed(pos,target_region) and pos.distance_to(center) >= 420.0:
				chosen = pos
				break
	if chosen.x < -9000.0: return false
	var roll := randf()
	var mob := make_enemy(type,chosen,2 if roll < 0.01 and target_region >= 3 else (1 if roll < 0.075 else 0))
	mob["uid"] = server_next_mob_uid
	mob["context"] = "world"
	mob["instance_id"] = "world"
	mob["spawned_at_ms"] = Time.get_ticks_msec()
	server_next_mob_uid += 1
	enemies.append(mob)
	return true

func spawn_dedicated_enemy() -> void:
	var regions := server_active_region_peers()
	for raw_region in regions.keys():
		var region := int(raw_region)
		var peers: Array = regions[raw_region]
		var target := server_region_target_mobs(peers.size())
		var missing := maxi(0,target-server_region_normal_mob_count(region))
		for n in mini(2,missing):
			if not server_spawn_enemy_for_region(region,peers): break

func server_cleanup_orphan_mobs() -> void:
	var active := server_active_region_peers()
	var now := Time.get_ticks_msec()
	for i in range(enemies.size()-1,-1,-1):
		var enemy: Dictionary = enemies[i]
		var type := int(enemy.get("type",-1))
		if type in [12,13,14] or bool(enemy.get("small_guardian",false)) or bool(enemy.get("invasion",false)): continue
		var region := region_at(Vector2(enemy["pos"]))
		# Alte/falsch platzierte Weltmobs aus frueheren Builds duerfen keinen
		# Regionsbestand und keinen globalen Spawnplatz blockieren.
		if type < 0 or type >= ENEMY_TYPES.size() or int(ENEMY_TYPES[type]["region"]) != region:
			enemies.remove_at(i)
			continue
		if active.has(region): continue
		# Altbestand ohne Spawn-Zeit stammt aus Builds vor dem regionalen
		# Server-Spawner. Wenn dort niemand mehr ist, sofort entfernen.
		if not enemy.has("spawned_at_ms"):
			enemies.remove_at(i)
			continue
		if now-int(enemy["spawned_at_ms"]) < 30000: continue
		enemies.remove_at(i)

func mob_profile(enemy:Dictionary)->Dictionary:
	var type:int=int(enemy["type"])
	var damage:int=roundi(enemy_damage(type)*[1.0,1.15,1.3][clampi(int(enemy.get("elite",0)),0,2)]*float(enemy.get("arena_power",1.0)))
	var profile:Dictionary=MobCombat.profile(type,ENEMY_TYPES[type],enemy_level(type),damage)
	var reach_scale:float=1.3 if type==12 else (.65 if bool(enemy.get("small_guardian",false)) else 1.0)
	profile["attack_range"]*=reach_scale
	for ability in profile["abilities"]:ability["range"]*=reach_scale
	return profile

func mob_targets(enemy:Dictionary,server:bool)->Array:
	var result:Array=[]
	if server:
		for peer in remote_players:
			var state:Dictionary=remote_players[peer]
			if str(state.get("context","world"))!="world" or bool(state.get("konflux",false)) or bool(state.get("stealth",false)) or konflux.fighter_stats.has(peer) or float(state.get("hp",1.0))<=0:continue
			var pos:=network_player_position(int(peer))
			if region_at(pos)==0 or region_at(pos)!=region_at(enemy["pos"]) or waystone_safe_at(pos):continue
			result.append({"id":int(peer),"pos":pos,"hp":float(state.get("hp",1.0)),"max_hp":float(state.get("max_hp",1.0))})
	elif hp>0 and death_timer<=0 and ranger_stealth_timer<=0.0 and (arena_mode!="" or dungeon_id>=0 or region_at(player_pos)!=0):
		if (arena_mode!="" or dungeon_id>=0 or region_at(player_pos)==region_at(enemy["pos"])) and not waystone_safe_at(player_pos):
			result.append({"id":0,"pos":player_pos,"hp":hp,"max_hp":maxf(1.0,hp)})
	return result

func advance_mob(enemy:Dictionary,delta:float,server:bool)->bool:
	if float(enemy.get("stun",0.0))>0.0:
		MobCombat.cancel(enemy)
		for index in range(enemy_projectiles.size()-1,-1,-1):
			if int(enemy_projectiles[index].get("owner_uid",-2))==int(enemy.get("uid",-1)):enemy_projectiles.remove_at(index)
	for key in ["flash","hit","stun","slow","marked","shot"]:
		enemy[key]=maxf(0.0,float(enemy.get(key,0.0))-delta)
	if float(enemy.get("poison",0))>0:
		enemy["poison"]=maxf(0,float(enemy["poison"])-delta)
		enemy["poison_tick"]=float(enemy.get("poison_tick",1.0))-delta
		if float(enemy["poison_tick"])<=0:
			enemy["poison_tick"]=1.0
			enemy["hp"]=float(enemy["hp"])-6
			var poison_owner := int(enemy.get("poison_owner_peer",0))
			if poison_owner > 0:
				enemy["last_hit_peer"] = poison_owner
				var damage_by_peer: Dictionary = enemy.get("damage_by_peer",{})
				damage_by_peer[poison_owner] = int(damage_by_peer.get(poison_owner,0))+6
				enemy["damage_by_peer"] = damage_by_peer
				var damage_at: Dictionary = enemy.get("damage_at_by_peer",{})
				damage_at[poison_owner] = Time.get_ticks_msec()
				enemy["damage_at_by_peer"] = damage_at
	if float(enemy["hp"])<=0:
		MobCombat.cancel(enemy);return false
	var profile:=mob_profile(enemy)
	var targets:=mob_targets(enemy,server)
	var action:=MobCombat.step(enemy,profile,targets,delta)
	var moved:=false
	var movement:Vector2=action["move"]
	if movement.length_squared()>.001:
		var speed:float=float(profile["movement_speed"])*(.45 if float(enemy.get("slow",0))>0 else 1.0)
		var origin:Vector2=enemy["pos"]
		var separation:=Vector2.ZERO
		for other in enemies:
			if other==enemy:continue
			var away:Vector2=origin-Vector2(other["pos"])
			var spacing:float=mob_hit_radius(enemy)+mob_hit_radius(other)+8
			if away.length_squared()>.01 and away.length()<spacing:separation+=away.normalized()*(spacing-away.length())/spacing
		if separation.length_squared()>.01:movement=(movement+separation.normalized()*.6).normalized()
		for angle in [0.0,.52,-.52,.92,-.92,1.35,-1.35,PI]:
			var next:Vector2=origin+movement.rotated(angle)*speed*delta
			var valid:bool=not terrain_blocked(next,mob_hit_radius(enemy)) and not blocked_by_region_wall(next) and region_at(next)==region_at(origin)
			if server or (arena_mode=="" and dungeon_id<0): valid = valid and not waystone_safe_at(next)
			if not server and arena_mode!="":valid=next.distance_to(ARENA_CENTER)<ARENA_RADIUS-16
			elif not server and dungeon_id>=0:valid=not dungeon_blocked(next)
			if valid:
				enemy["pos"]=next
				enemy["walking"]=true
				moved=true;break
	else:enemy["walking"]=false
	# Klassenbosse dürfen sich weder aus ihrer Kampflichtung ziehen lassen noch
	# dauerhaft an prozeduralen Kanten festfahren.
	if int(enemy["type"]) in [12,13,14]:
		var arena_center:Vector2=CLASS_BOSS_SITES[int(enemy["type"])-12]
		if Vector2(enemy["pos"]).distance_to(arena_center)>CLASS_BOSS_ARENA_RADIUS-38.0:
			var inward:Vector2=(arena_center-Vector2(enemy["pos"])).normalized()
			var correction:=Vector2(enemy["pos"])+inward*minf(150.0,Vector2(enemy["pos"]).distance_to(arena_center)-(CLASS_BOSS_ARENA_RADIUS-70.0))
			if class_boss_arena_walkable(correction,mob_hit_radius(enemy)):enemy["pos"]=correction
		var previous_probe:Vector2=Vector2(enemy.get("stuck_probe_pos",enemy["pos"]))
		var intended:=movement.length_squared()>.001
		if intended and Vector2(enemy["pos"]).distance_to(previous_probe)<2.0:
			enemy["stuck_time"]=float(enemy.get("stuck_time",0.0))+delta
		else:
			enemy["stuck_time"]=maxf(0.0,float(enemy.get("stuck_time",0.0))-delta*2.0)
		enemy["stuck_probe_pos"]=enemy["pos"]
		if float(enemy.get("stuck_time",0.0))>=.8:
			enemy["pos"]=class_boss_recovery_point(enemy)
			enemy["stuck_time"]=0.0
			MobCombat.cancel(enemy,.35)
	for event in action["events"]:
		if event["kind"]=="projectile":
			enemy_projectiles.append({"pos":enemy["pos"],"dir":event["dir"],"speed":profile["projectile_speed"],"life":2.3,"damage":event["damage"],"type":enemy["type"],"owner_uid":enemy.get("uid",-1),"hit_radius":profile["hit_radius"],"source_region":region_at(enemy["pos"])})
		elif event["kind"]=="boss_move":
			var move_dir:Vector2=Vector2(event.get("dir",Vector2.ZERO)).normalized()
			var desired:Vector2=Vector2(enemy["pos"])+move_dir*float(event.get("distance",0.0))
			if (int(enemy["type"]) not in [12,13,14] or class_boss_arena_walkable(desired,mob_hit_radius(enemy))) and region_at(desired)==region_at(enemy["pos"]) and not terrain_blocked(desired,mob_hit_radius(enemy)) and not blocked_by_region_wall(desired) and not waystone_safe_at(desired):
				enemy["pos"]=desired
				enemy["walking"]=true
		elif server:
			rpc_server_damage.rpc_id(int(event["target"]),int(event["damage"]))
		elif invulnerable<=0:
			apply_player_damage(int(event["damage"]))
	return moved

func update_dedicated_enemies(delta:float)->void:
	server_moving_mobs=0
	for i in range(enemies.size()-1,-1,-1):
		var enemy:Dictionary=enemies[i]
		if float(enemy.get("hp",0))<=0:
			MobCombat.cancel(enemy)
			defeat_enemy(i,int(enemy.get("last_hit_peer",0)));continue
		if advance_mob(enemy,delta,true):server_moving_mobs+=1
		if float(enemy.get("hp",0))<=0:defeat_enemy(i,int(enemy.get("last_hit_peer",0)))


func mob_shot_cancelled(shot:Dictionary)->bool:
	if not shot.has("owner_uid"):return false
	for enemy in enemies:
		if int(enemy.get("uid",-2))==int(shot["owner_uid"]):
			return float(enemy.get("hp",0))<=0 or float(enemy.get("stun",0))>0
	return true

func mob_shot_blocked(a:Vector2,b:Vector2,server:bool)->bool:
	var count:int=maxi(1,ceili(a.distance_to(b)/16.0))
	for n in range(1,count+1):
		var p:Vector2=a.lerp(b,float(n)/count)
		if not server and dungeon_id>=0:
			if dungeon_blocked(p):return true
		elif not server and arena_mode!="":
			if p.distance_to(ARENA_CENTER)>ARENA_RADIUS:return true
		elif terrain_blocked(p):return true
		if (server or (arena_mode=="" and dungeon_id<0)) and waystone_safe_at(p):return true
	return false

func advance_mob_shots(delta:float,server:bool)->void:
	for i in range(enemy_projectiles.size()-1,-1,-1):
		if i>=enemy_projectiles.size():continue
		var shot:Dictionary=enemy_projectiles[i]
		var previous:Vector2=shot["pos"]
		shot["life"]=float(shot.get("life",0))-delta
		shot["pos"]=previous+Vector2(shot["dir"])*float(shot.get("speed",265))*delta
		var unsafe:bool=(server or (arena_mode=="" and dungeon_id<0)) and (region_at(shot["pos"])==0 or region_at(shot["pos"])!=int(shot.get("source_region",region_at(previous))) or waystone_safe_at(shot["pos"]))
		var collision:=projectile_collision(previous,shot["pos"],server)
		if float(shot["life"])<=0 or mob_shot_cancelled(shot) or unsafe or collision["hit"]:
			if collision["hit"]:projectile_break(collision["pos"],shot["dir"],2,"",false)
			enemy_projectiles.remove_at(i);continue
		var candidates:Array=[]
		if server:
			for peer in remote_players:
				var state:Dictionary=remote_players[peer]
				var pos:=network_player_position(int(peer))
				if str(state.get("context","world"))=="world" and not bool(state.get("konflux",false)) and not konflux.fighter_stats.has(peer) and float(state.get("hp",1))>0 and region_at(pos)==int(shot.get("source_region",region_at(previous))) and region_at(pos)!=0 and not waystone_safe_at(pos):
					candidates.append({"id":int(peer),"pos":pos})
		elif hp>0 and death_timer<=0 and not waystone_safe_at(player_pos):candidates.append({"id":0,"pos":player_pos})
		var nearest:Dictionary={}
		var distance:float=INF
		for candidate in candidates:
			if MobCombat.shot_hits(previous,shot["pos"],candidate["pos"],float(shot.get("hit_radius",14))+10):
				var along:float=previous.distance_squared_to(candidate["pos"])
				if along<distance:nearest=candidate;distance=along
		if not nearest.is_empty():
			var damage:int=int(shot["damage"])
			enemy_projectiles.remove_at(i)
			if server:rpc_server_damage.rpc_id(int(nearest["id"]),damage)
			elif invulnerable<=0:apply_player_damage(damage)
			if not server and panel=="arena_reward":return

func update_dedicated_enemy_projectiles(delta:float)->void:
	advance_mob_shots(delta,true)


func update_dedicated_player_projectiles(delta: float) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var shot: Dictionary = projectiles[i]
		var previous:Vector2=shot["pos"]
		if int(shot.get("spell_id",-1))==20:steer_homing_shot(shot,delta)
		shot["life"] = float(shot.get("life",0.0)) - delta
		shot["pos"] = Vector2(shot["pos"]) + Vector2(shot["dir"]) * float(shot.get("speed",520.0)) * delta
		var collision:=projectile_collision(previous,shot["pos"],true)
		if shot["life"] <= 0.0 or collision["hit"]:
			if collision["hit"]:
				shot["pos"]=collision["pos"]
				projectile_break(shot["pos"],shot["dir"],int(shot.get("kind",2)),str(shot.get("element","")))
				if int(shot.get("spell_id",-1))==16:server_fireball_impact(shot)
			projectiles.remove_at(i)
			continue
		var consumed := false
		for e in range(enemies.size() - 1, -1, -1):
			if e>=enemies.size():continue
			var uid:int=int(enemies[e]["uid"])
			if uid in shot.get("hits",[]):continue
			if MobCombat.shot_hits(previous,shot["pos"],enemies[e]["pos"],mob_hit_radius(enemies[e])+4):
				if not shot.has("hits"):shot["hits"]=[]
				shot["hits"].append(uid)
				damage_enemy(e, int(shot.get("damage",1)), Vector2(shot["dir"]), false, str(shot.get("element","")), int(shot.get("owner_peer",0)))
				consumed = not bool(shot.get("pierce",false))
				if consumed:
					if int(shot.get("spell_id",-1))==16:server_fireball_impact(shot)
					break
		if consumed:
			projectiles.remove_at(i)

func process_dedicated_server(delta: float) -> void:
	for i in boss_cooldowns.size():boss_cooldowns[i]=maxf(0,boss_cooldowns[i]-delta)
	konflux.time += delta
	konflux.authority_update(self,delta)
	world_time += delta
	if network_mode != "host": return
	server_spawn_timer += delta
	server_status_timer += delta
	server_rescue_spawn_timer += delta
	if server_status_timer >= 1.0:
		server_check_patch_notice()
		server_status_timer = 0.0
		cleanup_party_reconnects()
		var now_tx := Time.get_ticks_msec()
		for tx_key in server_pending_transactions.keys():
			if int(server_pending_transactions[tx_key]) < now_tx:
				server_pending_transactions.erase(tx_key)
		for peer_id in multiplayer.get_peers():
			send_server_session_status(int(peer_id))
	if server_rescue_spawn_timer >= 0.8:
		server_rescue_spawn_timer = 0.0
		update_dedicated_rescue_spawns()
		spawn_dedicated_bosses()
	if server_spawn_timer >= 0.8:
		server_spawn_timer = 0.0
		spawn_dedicated_enemy()
		server_cleanup_orphan_mobs()
	update_dedicated_enemies(delta)
	update_server_world_drops(delta)
	update_dedicated_player_projectiles(delta)
	update_dedicated_enemy_projectiles(delta)
	sync_timer -= delta
	if sync_timer <= 0.0:
		sync_timer = 0.10
		push_world_snapshot()

func update_player(delta: float) -> void:
	var old_pos := player_pos
	if touch_enabled:
		var accel := 10.5 if touch_move_vector.length_squared() > 0.001 else 14.0
		touch_move_smoothed = touch_move_smoothed.move_toward(touch_move_vector, delta * accel)
	var move := movement_vector()
	is_walking = move.length_squared() > 0.01 or dash_timer > 0
	if is_walking: walk_phase += delta * (19.0 if dash_timer > 0 else 11.0)
	var displacement := (dash_dir * (650.0 if class_id == 1 else 580.0) if dash_timer > 0 else move * 205.0 * food_system.move_mult())*delta
	if konflux.active and dash_timer<=0 and konflux.slow>0: displacement*=0.55
	move_with_collision(displacement)
	if player_pos.distance_to(old_pos) > 1 and step_timer <= 0:
		play_sound("step")
		step_timer = 0.43 if dash_timer <= 0 else 0.25
	if controller.used:
		var stick_aim: Vector2 = controller.stick(true)
		if stick_aim.length_squared() > 0.0: facing = stick_aim.normalized()
		elif move.length_squared() > 0.0: facing = move.normalized()
	elif touch_enabled:
		if touch_aim_id >= 0 and touch_aim_vector.length_squared() > 0.01:
			facing = facing.slerp(touch_aim_vector.normalized(), minf(1.0, delta * 18.0)).normalized()
		elif move.length() > 0.15:
			facing = facing.slerp(move.normalized(), minf(1.0, delta * 14.0)).normalized()
	else:
		var aim: Vector2 = get_global_mouse_position() + camera_pos - player_pos + Vector2(0,KonfluxMap.height_at(player_pos) if konflux.active and konflux.room<0 else 0.0)
		if aim.length() > 8: facing = aim.normalized()
	if konflux.active:
		if panel=="" and attack_input_active() and attack_timer<=0: normal_attack()
		return
	if arena_mode != "":
		if player_pos.distance_to(ARENA_CENTER) > ARENA_RADIUS - 26:
			player_pos = ARENA_CENTER + (player_pos - ARENA_CENTER).normalized() * (ARENA_RADIUS - 26)
		if panel == "" and attack_input_active() and attack_timer <= 0: normal_attack()
		return
	if interior_id >= 0: return
	if dungeon_id >= 0:
		if panel == "" and attack_input_active() and attack_timer <= 0: normal_attack()
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
	if panel == "" and attack_input_active() and attack_timer <= 0:
		normal_attack()

func move_with_collision(displacement: Vector2) -> void:
	# Sweep in small steps so a slow frame cannot jump over a wall or facade.
	var steps := maxi(1,ceili(displacement.length()/12.0))
	var step := displacement/steps
	for i in steps:
		var origin := player_pos
		var target := origin+step
		if not is_blocked(target,origin): player_pos = target.clamp(Vector2(30,30),(KonfluxMap.SIZE if konflux.active else WORLD)-Vector2(30,30))
		else:
			var axis_x := Vector2(target.x,player_pos.y)
			if not is_blocked(axis_x,player_pos): player_pos.x = axis_x.x
			var axis_y := Vector2(player_pos.x,target.y)
			if not is_blocked(axis_y,player_pos): player_pos.y = axis_y.y

func hero_collision_radius() -> float:
	return [15.0,18.0,16.0][clampi(hero_race,0,2)]-(1.0 if hero_gender==1 else 0.0)

func is_blocked(pos: Vector2, from_pos: Vector2 = Vector2(-1, -1)) -> bool:
	if konflux.active: return KonfluxMap.blocked(pos,player_pos if from_pos.x<0 else from_pos,konflux.room,hero_collision_radius())
	if arena_mode != "": return pos.distance_to(ARENA_CENTER) > ARENA_RADIUS - 22.0
	if interior_id >= 0: return tavern_blocked(pos)
	if dungeon_id >= 0: return dungeon_blocked(pos)
	if pos.x < 26 or pos.y < 26 or pos.x > WORLD.x - 26 or pos.y > WORLD.y - 26:
		return true
	if pos.x < 11000 and pos.y > 8470: return true
	if pos.x >= 11000 and (pos.x < 11140 or int(pos.y / 1920.0) != int(from_pos.y / 1920.0) and from_pos.x >= 11000): return true
	if pos.x < 1780 and pos.y > 7700:
		return true
	if from_pos.x < 0: from_pos = player_pos
	# Die Kollisionsfläche folgt der gesamten gezeichneten Mauer (82 px breit),
	# nicht nur der unsichtbaren Gebietsgrenze in ihrer Mitte.
	if blocked_by_region_wall(pos): return true
	var from_region := region_at(from_pos)
	var to_region := region_at(pos)
	if from_region != to_region and not can_cross_gate(from_region, to_region, from_pos, pos):
		return true
	for stone in WAYSTONES:
		if stone==WAYSTONES[0]:
			if SpawnStoneBody.blocks(pos-stone,0,hero_collision_radius()):return true
			continue
		if Rect2(stone+Vector2(-58,-82),Vector2(116,142)).grow(12).has_point(pos): return true
	if region_at(pos) != 0:
		return terrain_blocked(pos)
	for shop in VillageLayout.SHOPS:
		if Rect2(shop["cart"]+Vector2(-45,-24),Vector2(110,49)).grow(10).has_point(pos): return true
	for tree in REFERENCE_TREES:
		if pos.distance_to(tree) < 18.0: return true
	if Rect2(REFERENCE_WELL + Vector2(-44, -22), Vector2(88, 54)).grow(12).has_point(pos): return true
	if Rect2(Vector2(596,1248),Vector2(74,22)).grow(10).has_point(pos):return true
	for origin in [Vector2(350,1700),Vector2(1050,1900),Vector2(1320,2230)]:
		if Rect2(origin+Vector2(-6,-4),Vector2(112,12)).grow(12).has_point(pos):return true
	for house in house_positions():
		if Rect2(house + Vector2(8, 73), Vector2(176, 75)).grow(hero_collision_radius()).has_point(pos):
			return true
	for solid in (VILLAGE_REF_SOLIDS if USE_VILLAGE_REFERENCE_BACKGROUND else []):
		if solid.has_point(pos):
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
		var gate_open: bool = creative_mode or int(wall["boss"]) < 0 or bosses_defeated[int(wall["boss"])]
		if wall["vertical"] and float(wall["axis"]) == 1780.0 and float(wall["gate"]) == 1120.0: gate_open = gate_open and opened_village_gates.has(Vector2(1780,1120))
		if not wall["vertical"] and float(wall["axis"]) == 2600.0: gate_open = gate_open and opened_village_gates.has(Vector2(875,2600))
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

func class_boss_arena_index_at(p:Vector2,extra:float=0.0) -> int:
	for i in CLASS_BOSS_SITES.size():
		if p.distance_to(CLASS_BOSS_SITES[i]) <= CLASS_BOSS_ARENA_RADIUS+extra:return i
	return -1

func class_boss_arena_walkable(p:Vector2,radius:float=0.0) -> bool:
	var index:=class_boss_arena_index_at(p,0.0)
	if index<0:return false
	var center:Vector2=CLASS_BOSS_SITES[index]
	if p.distance_to(center)>CLASS_BOSS_ARENA_RADIUS-radius:return false
	if region_at(p)!=6+index:return false
	if waystone_safe_at(p):return false
	return true

func class_boss_recovery_point(enemy:Dictionary) -> Vector2:
	var type:=int(enemy.get("type",-1))
	if type not in [12,13,14]:return Vector2(enemy.get("home",enemy.get("pos",Vector2.ZERO)))
	var center:Vector2=CLASS_BOSS_SITES[type-12]
	var facing:Vector2=Vector2(enemy.get("facing",Vector2.DOWN)).normalized()
	if facing.length_squared()<.01:facing=Vector2.DOWN
	var candidates:Array=[center,center-facing*90.0,center+facing.rotated(PI*.5)*120.0,center+facing.rotated(-PI*.5)*120.0]
	for point in candidates:
		if class_boss_arena_walkable(point,mob_hit_radius(enemy)) and not terrain_blocked(point,mob_hit_radius(enemy)):return point
	return center

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
	if class_boss_arena_index_at(p,65.0)>=0:return {}
	if p.x < 1900 and p.y < 2700: return {}
	if p.x < 80 or p.y < 80 or p.x > WORLD.x - 80 or p.y > WORLD.y - 80: return {}
	var zone := region_at(p)
	if zone == 0: return {}
	var radius := 43.0 + float(key % 4) * 9.0
	if not region_rect(zone).grow(-52).encloses(Rect2(p-Vector2(radius*1.4,radius*1.8),Vector2(radius*2.8,radius*2.8))): return {}
	if distance_to_trail(p) < radius + 115.0: return {}
	for landmark in LANDMARKS:
		if p.distance_to(landmark["pos"]) < radius + 180.0: return {}
	for stone in WAYSTONES:
		if p.distance_to(stone) < radius + 110.0: return {}
	for portal in PORTALS:
		if p.distance_to(portal[0]) < radius + 150.0 or p.distance_to(portal[1]) < radius + 150.0: return {}
	return {"pos":p, "radius":radius, "zone":zone, "key":key}

func decorative_tree_in_cell(tx:int,ty:int) -> Dictionary:
	var key := hash_cell(tx,ty)
	var tile_origin := Vector2(tx*64,ty*64)
	var center := tile_origin+Vector2(32,32)
	var zone := visual_region_at(center)
	if zone == 0: return {}
	var wet := zone==6 and center.y>6850+sin(center.x/220.0)*125.0
	var point := Vector2(tx*64+(key%23),ty*64+((key/23)%25))
	if class_boss_arena_index_at(point+Vector2(24,42),70.0)>=0:return {}
	if not region_rect(zone).grow(-45).encloses(Rect2(point-Vector2(100,160),Vector2(200,210))): return {}
	if distance_to_trail(point)<120.0:return {}
	var tree := false
	match zone:
		1: tree = key%8==0
		2: tree = key%6==0
		3: tree = key%6!=0 and key%5==0
		4: tree = key%4!=0 and key%7==0
		5: tree = key%13==0
		6: tree = not wet and key%11==0
		7: tree = key%11==0
		8,9: tree = key%4==0
		10: tree = key%9==0
		11: tree = key%7==0
		12: tree = key%6==0
	if not tree:return {}
	var trunk_radius := 18.0 if zone in [1,6,8,10] else (23.0 if zone in [2,3,7,9,11] else 27.0)
	return {"point":point+Vector2(24,42),"radius":trunk_radius,"zone":zone}

func terrain_blocked(p: Vector2,radius:float=-1.0) -> bool:
	if radius<0:radius=hero_collision_radius()
	if region_at(p) == 1:
		for offset in [Vector2(-360, -160), Vector2(260, -190), Vector2(-330, 220), Vector2(280, 240)]:
			if Rect2(RESCUE_POS + offset - Vector2(73, 54), Vector2(146, 108)).grow(16).has_point(p): return true
	# Nur Stamm/Wurzel blockieren; die Krone bleibt begehbar.
	var tree_tx := int(floorf(p.x/64.0))
	var tree_ty := int(floorf(p.y/64.0))
	for tx in range(tree_tx-1,tree_tx+2):
		for ty in range(tree_ty-1,tree_ty+2):
			var tree := decorative_tree_in_cell(tx,ty)
			if not tree.is_empty() and p.distance_to(tree["point"]) < float(tree["radius"])+radius: return true
	var cx := int(floorf(p.x / 250.0))
	var cy := int(floorf(p.y / 250.0))
	for x in range(cx - 1, cx + 2):
		for y in range(cy - 1, cy + 2):
			var obstacle := obstacle_in_cell(x, y)
			if not obstacle.is_empty() and p.distance_to(obstacle["pos"]) < float(obstacle["radius"]) + radius+2.0:
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
	if center in VILLAGE_GATES and not opened_village_gates.has(center): return false
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
	if not creative_mode and needed_boss >= 0 and not bosses_defeated[needed_boss]:
		message("Weg versiegelt! Besiege zuerst %s." % ENEMY_TYPES[12 + needed_boss]["name"])
		return false
	return true

func house_positions() -> Array:
	var homes: Array = [Vector2(220,260),Vector2(700,200),Vector2(1440,280),TAVERN_HOUSE,Vector2(250,1760),Vector2(450,2020),Vector2(1100,2110),Vector2(340,2280),Vector2(1370,2300)]
	for shop in VillageLayout.SHOPS: homes.append(shop["house"])
	return homes

func load_bindings() -> void:
	bindings = DEFAULT_BINDINGS.duplicate()
	if not FileAccess.file_exists(CONTROLS_PATH): return
	var loaded: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONTROLS_PATH))
	if not loaded is Dictionary: return
	for action in BIND_ACTIONS:
		var value: Variant = loaded.get(action, DEFAULT_BINDINGS[action])
		if (value is int or value is float) and (int(value) >= 0 or int(value) in [-MOUSE_BUTTON_LEFT, -MOUSE_BUTTON_RIGHT, -MOUSE_BUTTON_MIDDLE]):
			if int(value) != KEY_ESCAPE or action == "pause": bindings[action] = int(value)

	var used_codes := {}
	for action in BIND_ACTIONS:
		var code: int = int(bindings[action])
		if code == 0: continue
		if used_codes.has(code): bindings[action] = 0
		else: used_codes[code] = true

func save_bindings() -> void:
	invalidate_static_cache()
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
	if controller.used and controller.device >= 0 and controller.bindings.has(action): return controller.label(int(controller.bindings[action]))
	var code: int = int(bindings.get(action, 0))
	if code < 0: return "M%d" % -code
	if code == KEY_SPACE: return "LEER"
	return binding_label(action)

func binding_pressed(action: String) -> bool:
	if controller.pressed(action): return true
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
	if touch_enabled:
		direction = touch_move_smoothed
	if controller.stick().length_squared() > 0.0: direction = controller.stick()
	return direction.normalized() if direction.length() > 1.0 else direction

func attack_input_active() -> bool:
	if controller.used and controller.pressed("attack"): return true
	# Mobile Browser erzeugen aus Touches oft zusätzlich synthetische
	# Mausklicks. Deshalb darf auf Touch-Geräten ausschließlich der echte
	# Angriffsbutton einen Angriff halten/auslösen.
	if touch_enabled:
		return touch_attack_held()
	return binding_pressed("attack")

func touch_button_at(pos: Vector2) -> String:
	if pos.distance_to(Vector2(1032, 526)) <= 67.0: return "attack"
	if pos.distance_to(Vector2(916, 550)) <= 43.0: return "dodge"
	if pos.distance_to(Vector2(967, 447)) <= 43.0: return "interact"
	if Rect2(866, 300, 86, 50).has_point(pos): return "chat"
	if Rect2(960, 300, 86, 50).has_point(pos): return "online"
	for slot in 4:
		if Rect2(424 + slot * 76, 548, 68, 70).has_point(pos): return "ability_%d" % (slot + 1)
	if Rect2(735, 557, 66, 54).has_point(pos): return "heal"
	if Rect2(807, 557, 66, 54).has_point(pos): return "resource"
	return ""

func update_touch_joystick(pos: Vector2) -> void:
	const MAX_RADIUS := 82.0
	const DEADZONE := 14.0
	var delta := pos - touch_move_base
	var distance := delta.length()
	if distance > MAX_RADIUS:
		# Follow-Joystick: die Basis wandert mit, damit der Daumen nicht an einer
		# festen Bildschirmposition "hängen bleibt".
		touch_move_base += delta.normalized() * (distance - MAX_RADIUS)
		delta = pos - touch_move_base
		distance = delta.length()
	if distance <= DEADZONE:
		touch_move_vector = Vector2.ZERO
		touch_move_knob = touch_move_base
		return
	var strength := clampf((distance - DEADZONE) / (MAX_RADIUS - DEADZONE), 0.0, 1.0)
	touch_move_vector = delta.normalized() * strength
	touch_move_knob = touch_move_base + delta.normalized() * minf(distance, 52.0)

func reset_touch_joystick() -> void:
	touch_move_id = -1
	touch_move_vector = Vector2.ZERO
	touch_move_base = Vector2(118, 526)
	touch_move_knob = touch_move_base

func update_touch_aim(pos: Vector2) -> void:
	const MAX_RADIUS := 94.0
	const DEADZONE := 10.0
	var delta := pos - touch_aim_base
	var distance := delta.length()
	if distance > MAX_RADIUS:
		touch_aim_base += delta.normalized() * (distance - MAX_RADIUS)
		delta = pos - touch_aim_base
		distance = delta.length()
	if distance <= DEADZONE:
		touch_aim_knob = touch_aim_base
		return
	touch_aim_vector = delta.normalized()
	touch_aim_knob = touch_aim_base + touch_aim_vector * minf(distance, 58.0)

func begin_touch_aim(index: int, pos: Vector2) -> void:
	touch_aim_id = index
	touch_aim_base = Vector2(clampf(pos.x, 850.0, 1080.0), clampf(pos.y, 390.0, 555.0))
	touch_aim_knob = touch_aim_base
	touch_aim_vector = facing.normalized() if facing.length_squared() > 0.01 else Vector2.RIGHT
	touch_attack_ids[index] = "attack"

func reset_touch_aim(index: int = -1) -> void:
	if index >= 0:
		touch_attack_ids.erase(index)
	else:
		for key in touch_attack_ids.keys():
			if touch_attack_ids[key] == "attack":
				touch_attack_ids.erase(key)
	touch_aim_id = -1
	touch_aim_base = Vector2(1032, 526)
	touch_aim_knob = touch_aim_base

func handle_touch_event(event: InputEvent) -> bool:
	if not touch_enabled: return false
	if event is InputEventScreenTouch:
		last_touch_msec = Time.get_ticks_msec()
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		var pos: Vector2 = touch_event.position

		# Releases müssen immer anhand der Finger-ID aufgeräumt werden. Vorher
		# blieb z. B. "attack" aktiv, wenn der Daumen außerhalb des Buttons
		# losgelassen wurde.
		if not touch_event.pressed:
			touch_attack_ids.erase(touch_event.index)
			if touch_event.index == touch_move_id:
				reset_touch_joystick()
			if touch_event.index == touch_aim_id:
				reset_touch_aim(touch_event.index)
			queue_redraw()
			return true

		if panel != "":
			handle_panel_click(pos)
			queue_redraw()
			return true

		if INVENTORY_HUD_RECT.has_point(pos):
			toggle_panel("inventory")
			return true
		if party_widget_rect().has_point(pos) and (int(party_state.get("invite_from",0)) > 0 or not (party_state.get("members",[]) as Array).is_empty()):
			panel = "party"
			play_sound("menu")
			queue_redraw()
			return true

		# Aktionsbuttons haben Vorrang und erhalten eine eigene Finger-ID.
		var action: String = touch_button_at(pos)
		if action != "":
			if action == "attack":
				begin_touch_aim(touch_event.index, pos)
				if attack_timer <= 0.0: normal_attack()
				queue_redraw()
				return true
			touch_attack_ids[touch_event.index] = action
			match action:
				"dodge":
					if dash_cooldown <= 0.0: dodge()
				"interact": interact()
				"chat": open_mobile_chat()
				"online":
					online_list_open = not online_list_open
				"heal": quick_potion(false)
				"resource": quick_potion(true)
				_:
					if action.begins_with("ability_"):
						use_ability(int(action.get_slice("_", 1)) - 1)
			queue_redraw()
			return true

		# Moderner Floating/Follow-Joystick: die linke Bildschirmhälfte ist die
		# Bewegungszone, die Basis entsteht direkt unter dem Daumen.
		if touch_move_id == -1 and pos.x <= 390.0 and pos.y >= 260.0:
			touch_move_id = touch_event.index
			touch_move_base = Vector2(clampf(pos.x, 82.0, 300.0), clampf(pos.y, 350.0, 555.0))
			touch_move_knob = touch_move_base
			touch_move_vector = Vector2.ZERO
			queue_redraw()
			return true
	elif event is InputEventScreenDrag:
		last_touch_msec = Time.get_ticks_msec()
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if drag_event.index == touch_move_id:
			update_touch_joystick(drag_event.position)
			queue_redraw()
			return true
		if drag_event.index == touch_aim_id:
			update_touch_aim(drag_event.position)
			queue_redraw()
			return true
	return false

func touch_attack_held() -> bool:
	for action in touch_attack_ids.values():
		if action == "attack": return true
	return false

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

func mobile_text_prompt(title: String, current: String, max_length: int) -> String:
	if not is_web_platform():
		DisplayServer.virtual_keyboard_show(current)
		return current
	var result = JavaScriptBridge.get_interface("window").prompt(title,current)
	if result == null:
		return current
	return str(result).strip_edges().substr(0, max_length)

func open_mobile_chat() -> void:
	if is_web_platform() and touch_enabled:
		clear_touch_inputs()
		var entered := mobile_text_prompt("Nachricht an die Gruppe", chat_input, 120)
		chat_open = false
		chat_input = ""
		if entered.strip_edges() != "":
			send_chat_message(entered)
	else:
		chat_open = true
		DisplayServer.virtual_keyboard_show(chat_input)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if server_save.loading: return
	if controller.handle(self, event): return
	if event is InputEventMouseMotion: controller.used = false
	if panel == "controller" and event is InputEventKey and event.pressed and event.keycode == KEY_DELETE and controller.awaiting != "":
		controller.assign(controller.awaiting,-1)
		return
	if panel == "controller" and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if controller.awaiting != "": controller.awaiting = ""
		else: panel = "pause"
		return
	if death_timer > 0.0: return
	if awaiting_bind == "" and event_matches_binding(event, "online"):
		online_list_open = event.pressed
		queue_redraw()
		return
	if handle_touch_event(event): return
	# Mobile Browser senden nach einem Touch oft noch einen künstlichen
	# Mausklick. Den nur kurz nach echtem Touch unterdrücken, damit Buttons
	# nicht doppelt auslösen; eine echte Maus funktioniert danach weiterhin.
	if is_web_platform() and touch_enabled and event is InputEventMouseButton and Time.get_ticks_msec() - last_touch_msec < 900:
		return
	if panel == "multiplayer" and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			panel = "start"
		elif event.keycode == KEY_BACKSPACE:
			if join_code.length() > 0: join_code = join_code.left(join_code.length()-1)
		elif event.keycode == KEY_ENTER and join_code.length() > 4 and not is_web_platform():
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
			if creation_name.strip_edges().length() >= 2 and creation_class_selected: review_character_creation()
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
	if panel == "" and event.is_pressed() and not (event is InputEventKey and event.echo) and event_matches_binding(event, "chat"):
		chat_open = true
		chat_input = ""
		queue_redraw()
		return
	if awaiting_bind == "" and event.is_pressed() and not (event is InputEventKey and event.echo) and event_matches_binding(event, "mechanics"):
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and panel == "" and INVENTORY_HUD_RECT.has_point(event.position):
		toggle_panel("inventory")
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and panel == "" and Rect2(10,118,348,46).has_point(event.position):
		quest_guide.open(self,quest_guide.current_id(self),"")
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and panel == "" and party_widget_rect().has_point(event.position) and (int(party_state.get("invite_from",0)) > 0 or not (party_state.get("members",[]) as Array).is_empty()):
		panel = "party"
		play_sound("menu")
		queue_redraw()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and panel == "" and (event.position.distance_to(Vector2(1035,116)) <= 90.0 or (touch_enabled and Rect2(984,16,145,105).has_point(event.position))):
		panel = "map"
		menu_scroll = 0
		return
	if event is InputEventMouseButton and panel != "":
		if event.button_index == MOUSE_BUTTON_LEFT: handle_panel_click(event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and panel in ["skills", "journal"]:
			var skill_scroll_max := maxi(0, ceili(float(SKILL_TREES[skill_tree_tab].size()-6)/3.0)) if panel=="skills" else 0
			menu_scroll = mini(maxi(0, QUESTS.size() - 6) if panel == "journal" else skill_scroll_max, menu_scroll + 1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and panel in ["skills", "journal"]:
			menu_scroll = maxi(0, menu_scroll - 1)
		return
	if event is InputEventKey and event.keycode == KEY_ESCAPE or event_matches_binding(event, "pause"):
		if panel in ["arena_reward", "victory", "start"]: return
		if panel == "":
			panel = "pause"
			pause_status = "Konflux läuft online weiter." if konflux.active else "Das Spiel ist angehalten."
		elif panel == "controls": panel = controls_return_panel
		elif panel == "controller": panel = "pause"
		elif panel == "quest_details": panel = quest_guide.return_panel
		else: panel = ""
		return
	if panel in ["pause", "start", "controls", "arena_reward", "victory"]: return
	for action in ["skills", "inventory", "journal", "map", "party"]:
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

func near_borin() -> bool:
	return interior_id < 0 and dungeon_id < 0 and arena_mode == "" and player_pos.distance_to(Vector2(1486,1970)) < 150.0

func toggle_panel(which: String) -> void:
	if which == "skills" and panel != "skills" and not near_borin():
		message("Fähigkeiten kannst du nur beim Skillzauberer Borin ändern.")
		return
	panel = "" if panel == which else which
	menu_scroll = 0
	selected_item = -1
	inventory_page = 0
	sell_all_confirm = false

func learn_arcane_step() -> bool:
	if class_id != 1 or not class_mastery_unlocked or arcane_step_learned: return false
	arcane_step_learned = true
	save_game()
	return true

func dodge() -> void:
	var arcane := class_id == 1 and arcane_step_learned
	var dir := movement_vector()
	dash_dir = dir.normalized() if dir.length() > 0 else facing.normalized()
	if dash_dir.length_squared() < 0.01: dash_dir = Vector2.DOWN
	dodge_start = player_pos
	dodge_duration = 0.20 if arcane else (0.24 if class_id == 0 else 0.22)
	dash_timer = dodge_duration
	dash_cooldown = 1.25
	invulnerable = 0.38
	if class_id == 2 and class_mastery_unlocked: ranger_stealth_timer = dodge_duration + 0.4
	if konflux.active:
		if network_mode=="client": rpc_konflux_dodge.rpc_id(1)
		elif konflux.fighter_stats.has(1):
			konflux.fighter_stats[1]["dodge"]=0.38
			konflux.fighter_stats[1]["dodge_cd"]=1.25
	effect(player_pos+Vector2(0,-60), "ARKANER SCHRITT" if arcane else ("SCHATTENROLLE" if class_id == 2 and class_mastery_unlocked else "ROLLE"), Color("c7b5ff") if arcane else Color("d8f3ff"), 0.65)
	play_sound("dodge")

func weapon_power() -> int:
	return equipment_power(equipped_uid)

func equipped_weapon_variant() -> String:
	var design := equipped_weapon_design()
	if class_id == 0 and design % 3 == 2: return "axe"
	if class_id == 2 and design % 4 == 3: return "crossbow"
	return class_weapon_icon()

func normal_attack_power() -> int:
	# Grundtreffer bleiben schwächer als Fähigkeiten, brauchen aber keine zähen Serien.
	var base := 7.0 + level * 1.6 + weapon_power() * 0.86 + int(skill_levels[9]) * 4.0
	var mastery_mult := 1.0 + (0.30 * warrior_rage / 100.0 if class_id == 0 and class_mastery_unlocked else 0.0)
	return maxi(1, int(base * (1.0 + primary_attribute() * (0.015 if class_id == 0 else 0.019)) * food_system.damage_mult() * mastery_mult))

func weapon_element() -> String:
	for item in inventory:
		if int(item.get("uid", -1)) == equipped_uid:
			return str(item.get("element", ""))
	return ""

func normal_attack() -> void:
	if konflux.active:
		konflux.attack(self)
		return
	if waystone_safe_at(player_pos):
		message("Wegstein-Schutz: Hier sind Angriffe deaktiviert.")
		attack_timer = 0.25
		return
	var variant := equipped_weapon_variant()
	attack_timer = 0.62 if variant == "axe" else (0.78 if variant == "crossbow" else (0.45 if class_id == 0 else (0.62 if class_id == 1 else 0.52)))
	if class_id == 2 and ranger_hunt_buff > 0.0: attack_timer /= 1.25
	if robotics_overclock_timer > 0.0: attack_timer /= 1.18
	if class_mastery_unlocked and class_id == 0: warrior_rage = minf(100.0, warrior_rage + 8.0)
	if class_mastery_unlocked and class_id == 2 and ranger_hunt_buff <= 0.0:
		ranger_hunt_meter = minf(100.0, ranger_hunt_meter + 10.0)
		if ranger_hunt_meter >= 100.0:
			ranger_hunt_meter = 0.0
			ranger_hunt_buff = 60.0
			effect(player_pos+Vector2(0,-70),"JAGDRAUSCH · 60 SEK.",Color("ffe29a"),1.1)
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
	if uses_server_world():
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
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0 or not remote_players.has(sender): return
	if not server_action_allowed(sender, "normal", 140): return
	var state: Dictionary = remote_players[sender]
	if str(state.get("context","world")) != "world": return
	var state_pos: Array = state.get("pos", [])
	if state_pos.size() < 2: return
	var requested_origin := Vector2(float(origin_data[0]),float(origin_data[1]))
	var origin := Vector2(float(state_pos[0]),float(state_pos[1]))
	if requested_origin.distance_to(origin) > 125.0 or waystone_safe_at(origin): return
	var dir := Vector2(float(dir_data[0]),float(dir_data[1]))
	if not dir.is_finite() or dir.length_squared() < 0.01: return
	dir = dir.normalized()
	remote_class = clampi(int(state.get("class",0)),0,2)
	design = clampi(int(state.get("weapon",0)),0,32)
	element = str(state.get("element",""))
	server_relay_combat_visual(sender,{"kind":"normal","pos":[origin.x,origin.y],"dir":[dir.x,dir.y],"class":remote_class,"weapon":design,"element":element})
	var level_cap := clampi(int(state.get("level",1)),1,99)
	power = clampi(power,1,80 + level_cap * 20)
	if remote_class == 0:
		var axe := design % 3 == 2
		hit_arc(origin,dir,116.0 if axe else 100.0,0.08 if axe else 0.13,power,false,element,sender)
	else:
		var crossbow := remote_class == 2 and design % 4 == 3
		projectiles.append({"pos":origin,"dir":dir,"speed":790.0 if crossbow else (650.0 if remote_class==2 else 520.0),"life":1.2,"damage":power,"kind":3 if remote_class==2 else 2,"element":element,"hits":[],"owner_peer":sender})

func hit_arc(origin: Vector2, direction: Vector2, reach: float, threshold: float, damage: int, stun: bool, element: String = "", source_peer: int = 0) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if i>=enemies.size():continue
		var enemy: Dictionary = enemies[i]
		var offset: Vector2 = enemy["pos"] - origin
		if offset.length() <= reach and (offset.length() < 25 or direction.dot(offset.normalized()) > threshold):
			damage_enemy(i, damage, direction, stun, element, source_peer)

func move_enemy_with_collision(enemy: Dictionary, displacement: Vector2) -> void:
	if displacement.length_squared() <= 0.001: return
	var steps := maxi(1,ceili(displacement.length()/6.0))
	var step := displacement/steps
	for n in steps:
		var origin: Vector2 = enemy["pos"]
		var next := origin+step
		var valid := not terrain_blocked(next,mob_hit_radius(enemy)) and not blocked_by_region_wall(next) and region_at(next)==region_at(origin)
		if arena_mode != "": valid = next.distance_to(ARENA_CENTER)<ARENA_RADIUS-16
		elif dungeon_id >= 0: valid = not dungeon_blocked(next)
		elif waystone_safe_at(next): valid = false
		if not valid: break
		enemy["pos"]=next

func damage_enemy(index: int, amount: int, push: Vector2, stun: bool = false, element: String = "", source_peer: int = 0) -> void:
	if index < 0 or index >= enemies.size(): return
	play_sound("hit")
	var enemy: Dictionary = enemies[index]
	if source_peer > 0:
		enemy["last_hit_peer"] = source_peer
		var damage_by_peer: Dictionary = enemy.get("damage_by_peer",{})
		damage_by_peer[source_peer] = int(damage_by_peer.get(source_peer,0)) + maxi(0,amount)
		enemy["damage_by_peer"] = damage_by_peer
		var damage_at: Dictionary = enemy.get("damage_at_by_peer",{})
		damage_at[source_peer] = Time.get_ticks_msec()
		enemy["damage_at_by_peer"] = damage_at
	if uses_server_world():
		enemy["flash"] = 0.16
		effect(enemy["pos"] + Vector2(0, -25), str(maxi(0, amount)), Color("fff1a1"), 0.55)
		return
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
					if source_peer > 0: enemies[j]["last_hit_peer"] = source_peer
					lightning_lines.append({"from":enemy["pos"], "to":enemies[j]["pos"], "life":0.25})
					break
		"gift":
			enemy["poison"] = 5.0
			enemy["poison_tick"] = 1.0
			if source_peer > 0: enemy["poison_owner_peer"] = source_peer
			effect(enemy["pos"] + Vector2(0, -44), "GIFT", Color("b7e885"), 0.8)
	enemy["hp"] = float(enemy["hp"]) - amount
	enemy["flash"] = 0.16
	if source_peer > 0 and network_mode == "host":
		server_broadcast_hit_confirm(source_peer,enemy,amount)
	move_enemy_with_collision(enemy,push*18.0)
	if stun: enemy["stun"] = 1.2
	effect(enemy["pos"] + Vector2(0, -25), str(amount), Color("fff1a1"), 0.75)
	if drain_timer > 0: hp = minf(max_hp(), hp + minf(8.0, amount * 0.2))
	if enemy["hp"] <= 0: defeat_enemy(index, int(enemy.get("last_hit_peer", source_peer)))

@rpc("any_peer", "call_remote", "reliable")
func rpc_client_ability(id: int, pos_data: Array, dir_data: Array, power: int, rank: int) -> void:
	if network_mode != "host" or pos_data.size() < 2 or dir_data.size() < 2: return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0 or not remote_players.has(sender): return
	if id < 0 or id >= ABILITIES.size(): return
	var server_cd_ms := maxi(250, int(float(ABILITIES[id]["cd"]) * 850.0))
	if not server_action_allowed(sender, "ability_%d" % id, server_cd_ms): return
	var state: Dictionary = remote_players[sender]
	if str(state.get("context","world")) != "world": return
	var state_pos: Array = state.get("pos", [])
	if state_pos.size() < 2: return
	var requested_origin := Vector2(float(pos_data[0]),float(pos_data[1]))
	var origin := Vector2(float(state_pos[0]),float(state_pos[1]))
	if requested_origin.distance_to(origin) > 145.0 or waystone_safe_at(origin): return
	var dir := Vector2(float(dir_data[0]),float(dir_data[1]))
	if not dir.is_finite() or dir.length_squared() < 0.01: return
	dir = dir.normalized()
	var remote_class := clampi(int(state.get("class",0)),0,2)
	var allowed_ids: Array = all_slot_skills()
	allowed_ids.append(CLASS_ULTIMATES[remote_class])
	if id not in allowed_ids: return
	rank = clampi(rank,1,5)
	server_relay_combat_visual(sender,{"kind":"ability","ability":id,"pos":[origin.x,origin.y],"dir":[dir.x,dir.y],"class":remote_class,"weapon":int(state.get("weapon",0)),"element":str(state.get("element",""))})
	var level_cap := clampi(int(state.get("level",1)),1,99)
	power = clampi(power,1,140 + level_cap * 30)
	if id in [3,7,16,18,20,25,26,28,29,30]:
		for shot in ability_projectiles(id,origin,dir,remote_class,power):
			shot["owner_peer"]=sender
			projectiles.append(shot)
		return
	# Host löst den Schaden aus; der Client behält nur seine lokale Animation.
	var radial_ids := [0,5,17,22,23,24,31,33,37,39,40,41,42]
	if id in radial_ids:
		var radius := 165.0 + rank * 12.0
		for i in range(enemies.size()-1,-1,-1):
			if enemies[i]["pos"].distance_to(origin) <= radius: damage_enemy(i,power+10,dir,false,"",sender)
	else:
		hit_arc(origin,dir,190.0,-0.15,power+8,false,"",sender)

func use_ability(slot: int) -> void:
	if slot < 0 or slot > 3: return
	var id: int = class_ultimate() if slot == 3 else int(slots[slot])
	if id < 0 or id >= ABILITIES.size() or not learned[id]: return
	var ability: Dictionary = ABILITIES[id]
	if float(ability["cd"]) <= 0.0: return
	if float(cooldowns[id]) > 0 or energy < float(ability["cost"]): return
	if konflux.active:
		if KonfluxMap.safe(player_pos,konflux.room):
			message("Keine Angriffe im geschützten Spawnkreis.")
			return
		energy -= float(ability["cost"])
		cooldowns[id] = float(ability["cd"])
		konflux.attack(self,id)
		return
	if waystone_safe_at(player_pos):
		message("Wegstein-Schutz: Hier sind Fähigkeiten deaktiviert.")
		return
	energy -= float(ability["cost"])
	var rank: int = int(skill_levels[id])
	cooldowns[id] = float(ability["cd"]) * (1.0 - 0.06 * (rank - 1))
	var power := int((17 + level * 2.4 + weapon_power() * 1.15 + (rank - 1) * 8) * (1.0 + primary_attribute() * 0.012) * food_system.damage_mult())
	var cast_pos := player_pos
	var cast_dir := facing
	if uses_server_world():
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
			move_with_collision(destination-player_pos)
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
		34:
			projectiles.append({"pos":player_pos,"dir":facing,"speed":760.0,"life":1.0,"damage":power+12,"kind":2,"element":"blitz","hits":[]})
		35:
			hp=minf(max_hp(),hp+55.0);effect(player_pos,"REPARATUR +55",Color("8ee8d0"),0.8)
		36:
			shield_timer=5.0;effect(player_pos,"ENERGIESCHILD",Color("8edcff"),0.8)
		37:
			for i in range(enemies.size()-1,-1,-1):
				if enemies[i]["pos"].distance_to(player_pos)<185.0: damage_enemy(i,power+14,(enemies[i]["pos"]-player_pos).normalized(),false,"blitz")
			effect(player_pos,"TESLAWELLE",Color("fff0a5"),0.9)
		38:
			robotics_overclock_timer=8.0;effect(player_pos,"ZIELMATRIX",Color("9de9ff"),0.8)
		39:
			for i in range(enemies.size()-1,-1,-1):
				if enemies[i]["pos"].distance_to(player_pos)<175.0: enemies[i]["stun"]=maxf(float(enemies[i].get("stun",0.0)),1.8);damage_enemy(i,power,(enemies[i]["pos"]-player_pos).normalized(),false,"blitz")
			effect(player_pos,"EMP",Color("b7e9ff"),0.9)
		40:
			for i in range(enemies.size()-1,-1,-1):
				if enemies[i]["pos"].distance_to(player_pos)<190.0: damage_enemy(i,power+30,(enemies[i]["pos"]-player_pos).normalized(),false,"feuer")
			effect(player_pos,"FLAMMENWIRBEL",Color("ff9858"),1.0)
		41:
			shield_timer=7.0
			for i in range(enemies.size()-1,-1,-1):
				if enemies[i]["pos"].distance_to(player_pos)<150.0: damage_enemy(i,power+12,(enemies[i]["pos"]-player_pos).normalized(),false,"blitz")
			effect(player_pos,"REAKTORWALL",Color("8fdcff"),1.0)
		42:
			for i in range(enemies.size()-1,-1,-1):
				if enemies[i]["pos"].distance_to(player_pos)<230.0: damage_enemy(i,power+24,(enemies[i]["pos"]-player_pos).normalized(),false,"blitz")
			effect(player_pos,"BLITZKERN",Color("fff0a5"),1.0)
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
			move_with_collision(destination-player_pos)
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
		var previous:Vector2=p["pos"]
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
		var collision:=projectile_collision(previous,p["pos"],false)
		if p["life"] <= 0 or collision["hit"]:
			if collision["hit"]:
				p["pos"]=collision["pos"]
				if not uses_server_world():projectile_break(p["pos"],p["dir"],int(p.get("kind",2)),str(p.get("element","")))
			if spell_id == 16 and not bool(p.get("network_visual",false)): explode_fireball(p)
			if spell_id == 28 and not bool(p.get("network_visual",false)): create_poison_cloud(p["pos"], int(p["damage"]))
			projectiles.remove_at(i)
			continue
		var consumed := false
		for e in range(enemies.size() - 1, -1, -1):
			if e>=enemies.size():continue
			var uid: int = int(enemies[e]["uid"])
			if uid in p["hits"]: continue
			if MobCombat.shot_hits(previous,p["pos"],enemies[e]["pos"],mob_hit_radius(enemies[e])+4):
				p["hits"].append(uid)
				var impact: Vector2 = enemies[e]["pos"]
				if not bool(p.get("network_visual",false)):damage_enemy(e, int(p["damage"]), p["dir"], false, str(p.get("element", "")))
				match (-1 if bool(p.get("network_visual",false)) else spell_id):
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
	arena_reward_item.clear()
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
	announce_multiplayer_context()

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

func arena_new_weapon_chance(wave:int) -> float:
	if wave<5:return 0.0
	if wave<10:return .20
	if wave<20:return .35
	if wave<30:return .50
	return .65

func make_arena_weapon(wave:int) -> Dictionary:
	var names:Array=[["Wächterklinge","Blutdornenaxt","Runenhammer","Sturmklinge","Glutspalter"],["Glutstab","Frostzweig","Blitzleiter","Quellstab","Sternenwacht"],["Dornenbogen","Falkenbogen","Windsehne","Splitterarmbrust","Jägerzeichen"]]
	var choice:int=randi_range(0,4)
	var item:Dictionary=make_item(names[class_id][choice],class_weapon_icon(),mini(4,2+int(wave/20)),6+level*2+wave,0,"",level)
	item["new_weapon_id"]=class_id*5+choice
	item["design"]=2 if class_id==0 and choice in [1,2] else (3 if class_id==2 and choice==3 else choice%4)
	return item

func claim_arena_chest() -> void:
	if arena_reward_claimed: return
	var tier := clampi(int(arena_reward_wave / 5.0), 0, 3)
	if arena_reward_wave >= 25 and level >= 30: tier = 4
	if arena_reward_item.is_empty():
		arena_reward_item = make_item("Truhe der Ewigen Wacht · Welle %d" % arena_reward_wave, class_weapon_icon(), tier, 6 + level * 2 + arena_reward_wave, 0, ["eis", "blitz", "gift"][arena_reward_wave % 3], level)
		var roll:float=randf()
		var head_chance:float=0.0 if arena_reward_wave<5 else minf(.08,.02+floorf(arena_reward_wave/10.0)*.02)
		if roll<head_chance:arena_reward_item=make_class_head(level)
		elif roll<head_chance+arena_new_weapon_chance(arena_reward_wave):arena_reward_item=make_arena_weapon(arena_reward_wave)
		save_game()
	var reward:Dictionary=arena_reward_item
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
	announce_multiplayer_context()

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
	interior_return_pos = TAVERN_HOUSE + Vector2(126, 205)
	save_game()
	interior_id = 0
	player_pos = INTERIOR_CENTER + Vector2(0, 178)
	enemies.clear()
	drops.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	battle_zones.clear()
	message("Zur Steinrose · Alma kocht aus deinen mitgebrachten Fruechten. E: Rezepte, Vorrat und Kueche.")
	play_sound("menu")
	announce_multiplayer_context()

func leave_tavern() -> void:
	interior_id = -1
	player_pos = interior_return_pos
	previous_region = region_at(player_pos)
	message("Du trittst wieder auf die Gassen von Sonnenhain.")
	play_sound("menu")
	save_game()
	announce_multiplayer_context()

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
	announce_multiplayer_context()

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
	announce_multiplayer_context()

func open_dungeon_chest() -> void:
	if dungeon_id < 0: return
	if not dungeon_chest_ready(dungeon_id):
		message("Die Gewoelbetruhe erscheint nach 6 Minuten erneut.")
		return
	if not enemies.is_empty():
		message("Die Gewölbetruhe bleibt versiegelt, solange Feinde hier lauern.")
		return
	var treasure := make_item("Relikt aus %s" % DUNGEON_NAMES[dungeon_id], class_weapon_icon(), 2 + int(dungeon_id > 0), 15 + region_level(int(ENEMY_TYPES[int(DUNGEON_ENEMIES[dungeon_id][0])]["region"])) * 2, 280 + dungeon_id * 190, ["blitz", "eis", "gift"][dungeon_id])
	if rare_head_reward("dungeon",dungeon_id,.10):treasure=make_class_head(level)
	if not can_add_item(treasure):
		message("Dein Inventar ist voll. Die Truhe wartet auf deine Rückkehr.")
		return
	add_item(treasure)
	dungeon_chests_opened[dungeon_id] = true
	dungeon_chest_respawn_until[dungeon_id] = Time.get_unix_time_from_system()+CHEST_RESPAWN_SECONDS
	play_sound("level")
	message("Gewölbe geräumt! %s erhalten." % treasure["name"])
	save_game()

func make_enemy(type: int, pos: Vector2, elite_kind: int = 0) -> Dictionary:
	var info: Dictionary = ENEMY_TYPES[type]
	var health: float = float(info["hp"]) * (1.2 + 0.11 * region_level(int(info["region"]))) * [1.0, 2.1, 4.2][elite_kind]
	return {"uid":randi(), "type":type, "pos":pos, "home":pos, "facing":Vector2.DOWN, "hp":health, "max_hp":health, "flash":0.0, "hit":0.0, "stun":0.0, "slow":0.0, "poison":0.0, "poison_tick":1.0, "shot":randf_range(0.7, 1.7), "seed":randf() * TAU, "elite":elite_kind}

func spawn_position_allowed(p: Vector2, target_region: int) -> bool:
	if region_at(p) != target_region: return false
	if target_region == 0: return false
	# Keine Gegner auf Wegen, direkt an Wegsteinen, Portalen, Landmarken oder Häusern.
	if distance_to_trail(p) < 165.0: return false
	if is_blocked(p, p): return false
	for landmark in LANDMARKS:
		if p.distance_to(landmark["pos"]) < 235.0: return false
	for stone in WAYSTONES:
		if p.distance_to(stone) < WAYSTONE_SPAWN_BLOCK_RADIUS: return false
	for portal in PORTALS:
		if p.distance_to(portal[0]) < 210.0 or p.distance_to(portal[1]) < 210.0: return false
	for npc in NPCS:
		if p.distance_to(npc["pos"]) < 170.0: return false
	if target_region == 1 and p.distance_to(RESCUE_POS) < 330.0: return false
	return true

func waystone_safe_at(p: Vector2) -> bool:
	if arena_mode != "" or dungeon_id >= 0 or interior_id >= 0: return false
	for stone in WAYSTONES:
		if p.distance_to(stone) <= WAYSTONE_SAFE_RADIUS: return true
	return false

func nearest_waystone(p: Vector2) -> Vector2:
	var best := WAYSTONES[0]
	var best_distance := INF
	for stone in WAYSTONES:
		var distance := p.distance_to(stone)
		if distance < best_distance:
			best_distance = distance
			best = stone
	return best

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
	if uses_server_world() or normal_mob_count()>=10:return
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

func boss_max_hp(type:int)->float:
	return float(ENEMY_TYPES[type]["hp"])*(1.2+0.08*(region_level(int(ENEMY_TYPES[type]["region"]))+5))

func spawn_dedicated_bosses()->void:
	for i in 3:
		if boss_cooldowns[i]>0:continue
		var site:Vector2=CLASS_BOSS_SITES[i]
		var type:int=12+i
		var nearby:=false
		for peer in remote_players:
			var state:Dictionary=remote_players[peer]
			if str(state.get("context","world"))=="world" and network_player_position(int(peer)).distance_to(site)<=700:nearby=true
		if not nearby:continue
		var exists:=false
		for mob in enemies:
			if int(mob["type"])==type:exists=true
		if exists:continue
		var boss:=make_enemy(type,site)
		boss["uid"]=server_next_mob_uid;server_next_mob_uid+=1
		boss["hp"]=boss_max_hp(type);boss["max_hp"]=boss["hp"]
		boss["context"]="world";boss["instance_id"]="world"
		enemies.append(boss)
		spawn_tower_guardians(boss)

func spawn_nearby_boss() -> void:
	if uses_server_world():return
	for i in 3:
		var site: Vector2 = CLASS_BOSS_SITES[i]
		if player_pos.distance_to(site) > 700 or boss_cooldowns[i] > 0 or region_at(player_pos) != region_at(site): continue
		var boss_type := 12 + i
		var exists := false
		for enemy in enemies:
			if enemy["type"] == boss_type:
				exists = true
				break
		if exists: continue
		var info: Dictionary = ENEMY_TYPES[boss_type]
		var boss_hp: float = boss_max_hp(boss_type)
		enemies.append({"uid":randi(), "type":boss_type, "pos":site, "home":site, "facing":Vector2.DOWN, "hp":boss_hp, "max_hp":boss_hp, "flash":0.0, "hit":0.0, "stun":0.0, "slow":0.0, "poison":0.0, "poison_tick":1.0, "shot":1.5, "seed":randf() * 6.28})
		spawn_tower_guardians(enemies.back())
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
		if uses_server_world():
			announce_multiplayer_context()
	if rescue_state != 1: return
	# Im Live-Multiplayer gehören die Verteidigungsgegner dem Dedicated Server.
	# Lokales Spawnen würde beim nächsten World-Snapshot überschrieben.
	if uses_server_world(): return
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

func update_enemies(delta:float)->void:
	for i in range(enemies.size()-1,-1,-1):
		if i>=enemies.size():continue
		var enemy:Dictionary=enemies[i]
		if float(enemy.get("hp",0))<=0:
			MobCombat.cancel(enemy);defeat_enemy(i);continue
		if enemy["pos"].distance_to(player_pos)>1250 and arena_mode=="":
			enemies.remove_at(i);continue
		advance_mob(enemy,delta,false)
		if panel=="arena_reward":return
		if float(enemy.get("hp",0))<=0 and i<enemies.size():defeat_enemy(i)


func apply_player_damage(raw: int) -> void:
	if creative_mode or death_timer > 0.0: return
	var dealt := maxi(1, int((raw - equipment_power(equipped_armor_uid)) * food_system.damage_taken_mult()))
	if shield_timer > 0: dealt = maxi(1, int(dealt * 0.35))
	if class_id == 0 and standing_in_battle_zone(): dealt = maxi(1, int(dealt * 0.78))
	if class_id == 1 and shield_timer > 0 and learned[21]:
		for enemy in enemies:
			if enemy["pos"].distance_to(player_pos) < 95:
				enemy["slow"] = 3.5
				enemy["stun"] = 0.4
	hp -= dealt
	hurt_until=combat_feedback.clock+.18
	invulnerable = 0.5
	effect(player_pos + Vector2(0, -30), "-%d" % dealt, Color("ff888d"), 0.75)
	play_sound("hit")
	if hp <= 0:
		hp = 0
		death_timer = DEATH_DURATION
		panel = "death"
		dash_timer = 0.0
		attack_anim = 0.0
		swing_timer = 0.0
		is_walking = false

func update_enemy_projectiles(delta:float)->void:
	if not uses_server_world():advance_mob_shots(delta,false)


func respawn() -> void:
	if konflux.active:
		death_timer=0.0
		dash_timer=0.0
		hp=max_hp()
		energy=max_energy()
		konflux.room=-1
		player_pos=KonfluxMap.CENTER
		panel=""
		camera_smooth=player_pos-VIEW*0.5
		camera_pos=camera_smooth
		if network_mode!="client": konflux.register_fighter(1,true,-1)
		return
	death_timer = 0.0
	dash_timer = 0.0
	invulnerable = 1.0
	if arena_mode == "survival":
		finish_survival_run()
		return
	if arena_mode == "final":
		arena_mode = ""
		player_pos = Vector2(825, 1020)
		mark_network_teleport()
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
	player_pos = Vector2(825, 1020)
	mark_network_teleport()
	hp = max_hp()
	energy = max_energy()
	gold = maxi(0, gold - 20)
	panel = ""
	message("Du wurdest im Dorf wiederbelebt. -20 Gold")
	save_game()

func class_relic_item(boss_index:int) -> Dictionary:
	boss_index=clampi(boss_index,0,2)
	var item:=make_item(CLASS_RELIC_NAMES[boss_index],"gem",4,0,2500+boss_index*1250)
	item["class_relic"]=true
	item["mastery_class"]=boss_index
	item["mastery_skill"]=CLASS_RELIC_SKILLS[boss_index]
	return item

func class_boss_hat_item(boss_index:int) -> Dictionary:
	boss_index=clampi(boss_index,0,2)
	var names:=["Helm des Kriegsherrn","Hut des Arkanhüters","Hut des Jagdmeisters"]
	var item:=make_item(names[boss_index],"head",4,18+boss_index*4,1800+boss_index*500,"",maxi(1,region_level(6+boss_index)))
	item["head_class"]=boss_index
	item["design"]=boss_index
	item[["str","int","agi"][boss_index]]=18+boss_index*2
	item["boss_hat"]=true
	return item

func server_spawn_world_drop(item:Dictionary,pos:Vector2,reserved_class:int=-1,life:float=180.0) -> int:
	var uid:=server_next_drop_uid
	server_next_drop_uid+=1
	drops.append({"drop_uid":uid,"pos":safe_drop_position(pos),"item":network_reward_payload(item),"life":life,"reserved_class":reserved_class,"reserve_until_ms":Time.get_ticks_msec()+CLASS_RELIC_RESERVE_MS if reserved_class>=0 else 0})
	return uid

func update_server_world_drops(delta:float) -> void:
	for i in range(drops.size()-1,-1,-1):
		drops[i]["life"]=float(drops[i].get("life",0.0))-delta
		if float(drops[i]["life"])<=0.0:drops.remove_at(i)

func class_relic_locked_for_player(drop:Dictionary,player_class:int) -> bool:
	var reserved:=int(drop.get("reserved_class",-1))
	return reserved>=0 and reserved!=player_class and int(drop.get("reserve_until_ms",0))>Time.get_ticks_msec()

func safe_drop_position(origin: Vector2, offset: Vector2 = Vector2.ZERO) -> Vector2:
	var wanted := origin+offset
	var origin_region := region_at(origin)
	var candidates: Array = [wanted,origin]
	for radius in [24.0,40.0,56.0,76.0,96.0]:
		for n in 8:
			candidates.append(origin+Vector2.RIGHT.rotated(float(n)*TAU/8.0)*radius)
	for candidate in candidates:
		var p: Vector2 = candidate
		if region_at(p)!=origin_region: continue
		if blocked_by_region_wall(p) or terrain_blocked(p,12.0): continue
		if waystone_safe_at(p): continue
		return p
	return origin

func defeat_enemy(index: int, source_peer: int = 0) -> void:
	var enemy: Dictionary = enemies[index]
	announce_mob_death(enemy)
	var invasion: bool = bool(enemy.get("invasion", false))
	var type: int = int(enemy["type"])
	var pos: Vector2 = enemy["pos"]
	enemies.remove_at(index)
	if type==12:
		for j in range(enemies.size()-1,-1,-1):
			if int(enemies[j].get("guardian_of",-1))==int(enemy["uid"]):enemies.remove_at(j)
	if dedicated_server_mode:
		if type in [12,13,14]:boss_cooldowns[type-12]=90.0
		source_peer = resolve_enemy_reward_peer(enemy,source_peer)
		send_server_enemy_reward(source_peer, enemy)
		return
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
		apply_rescue_progress(1,false)
	if type in [12, 13, 14]:
		boss_cooldowns[type - 12] = 90.0
		bosses_defeated[type - 12] = true
		var relic:=class_relic_item(type-12)
		drops.append({"pos":safe_drop_position(pos,Vector2(25,0)),"item":relic,"life":180.0,"reserved_class":type-12,"reserve_until_ms":Time.get_ticks_msec()+CLASS_RELIC_RESERVE_MS})
		drops.append({"pos":safe_drop_position(pos,Vector2(-25,8)),"item":class_boss_hat_item(type-12),"life":180.0,"reserved_class":type-12,"reserve_until_ms":Time.get_ticks_msec()+CLASS_RELIC_RESERVE_MS})
		message("%s besiegt! %s und sein Klassenhut liegen als Beute am Boden." % [ENEMY_TYPES[type]["name"],CLASS_RELIC_NAMES[type-12]])
		if bosses_defeated.count(true) == bosses_defeated.size() and not final_completed and final_countdown < 0.0:
			final_countdown = 8.0
			message("Alle Siegel sind gefallen! In Kürze öffnet sich die Arena der letzten Wache.")
	var area_level := region_level(int(ENEMY_TYPES[type]["region"]))
	var elite_kind: int = int(enemy.get("elite", 0))
	gain_xp(enemy_xp_reward(type, elite_kind, level))
	var coins: int = randi_range(2, 7) * (1 + int(type / 3.0)) * int([1, 3, 7][elite_kind])
	drops.append({"pos":safe_drop_position(pos,Vector2(8,12)), "gold":coins, "life":80.0})
	for qindex in quests.size():
		var quest: Dictionary = quests[qindex]
		if quest["state"] == 1 and int(QUESTS[qindex]["target"]) == type:
			quest["progress"] = mini(int(QUESTS[qindex]["count"]), int(quest["progress"]) + 1)
			if quest["progress"] >= QUESTS[qindex]["count"]:
				quest["state"] = 2
				message("Questziel erreicht: %s. Kehre zurück!" % QUESTS[qindex]["title"])
	if randf() < (0.38 if elite_kind == 2 else (0.24 if elite_kind == 1 else 0.14)):
		var item: Dictionary = random_loot(type)
		drops.append({"pos":safe_drop_position(pos), "item":item, "life":90.0})
	if randf() < 0.03:
		drops.append({"pos":safe_drop_position(pos,Vector2(20,0)), "item":make_item("Heiltrank", "potion", 1, 0, 18), "life":90.0})
	if type in [12, 13, 14]: save_game()

func register_boss_defeat(boss_index:int,shared:bool=false)->bool:
	if boss_index<0 or boss_index>=bosses_defeated.size() or bosses_defeated[boss_index]:return false
	bosses_defeated[boss_index]=true
	boss_cooldowns[boss_index]=90.0
	message(("Gruppe · " if shared else "")+ENEMY_TYPES[12+boss_index]["name"]+" besiegt! Ein neuer Weg ist offen.")
	if bosses_defeated.count(true)==bosses_defeated.size() and not final_completed and final_countdown<0:
		final_countdown=8.0
	save_game()
	return true

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
	var item := {"uid":next_uid, "name":name, "icon":icon, "rarity":rarity, "power":power, "value":fair_value, "element":element, "level":ilvl, "str":strength, "agi":agility, "int":intellect, "count":1, "design":absi(hash(name)) % 4}
	if icon == "food":
		item["value"] = value
		item["design"] = maxi(0,FoodSystem.index_for(name))
	next_uid += 1
	return item

func stack_limit(item: Dictionary) -> int:
	var icon: String = str(item.get("icon", ""))
	if icon == "food": return 30
	if icon == "potion": return 16
	if icon in ["gem", "herb", "essence"]: return 1000000000
	return 1

func stack_matches(a: Dictionary, b: Dictionary) -> bool:
	return a.get("icon") == b.get("icon") and a.get("name") == b.get("name") and a.get("rarity") == b.get("rarity") and a.get("element", "") == b.get("element", "")

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
		var requested_uid := int(entry.get("uid",-1))
		if requested_uid < 0 or inventory_uid_exists(requested_uid):
			assign_fresh_item_uid(entry)
		else:
			next_uid = maxi(next_uid,requested_uid+1)
		inventory.append(entry)
		remaining -= amount
		remaining_value -= entry_value
	return remaining == 0

func random_loot(type: int, loot_class: int = -1) -> Dictionary:
	var chance := randf()
	var rarity := 0
	var area_level := region_level(int(ENEMY_TYPES[type]["region"]))
	if area_level >= 30 and chance < 0.0008: rarity = 4
	elif area_level >= 16 and chance < 0.025: rarity = 3
	elif chance < 0.13: rarity = 2
	elif chance < 0.47: rarity = 1
	var name: String = ENEMY_TYPES[type]["name"]
	var rank: String = ["Alte", "Feine", "Seltene", "Epische", "Legendäre"][rarity]
	var loot_weapon := class_weapon_icon_for(loot_class) if loot_class >= 0 else class_weapon_icon()
	var icon: String = [loot_weapon, "gem", "ring", "armor", "herb"][randi_range(0, 4)]
	var item_name: String = "%s %s" % [rank, {"sword":"Klinge", "staff":"Stab", "bow":"Bogen", "gem":"Essenz", "ring":"Ring", "armor":"Rüstung", "herb":"Kräuter"}[icon]]
	if icon=="herb":
		var herb_info:Dictionary=FoodSystem.herb_for_region(int(ENEMY_TYPES[type]["region"]))
		if not herb_info.is_empty():item_name=str(herb_info["name"])
	elif rarity >= 3:
		item_name = "%s des %s" % [item_name, name]
	var strength: int = (3 + area_level * 2 + rarity * 5 if icon in ["sword", "staff", "bow"] else (1 + int(area_level / 5) + rarity * 2 if icon == "armor" else (8 + area_level + rarity * 4 if icon == "ring" else 0)))
	var element := ""
	if icon in ["sword", "staff", "bow"] and rarity >= 1 and randf() < 0.32:
		element = "gift" if type in [2, 3, 10] else ("eis" if type in [6, 7, 11] else ("blitz" if type in [5, 8, 9] else ["eis", "blitz", "gift"].pick_random()))
		item_name = "%s · %s" % [item_name, element.capitalize()]
	return make_item(item_name, icon, rarity, strength, 0, element, area_level)

func collect_drops() -> void:
	for i in range(drops.size() - 1, -1, -1):
		if Vector2(drops[i]["pos"]).distance_to(player_pos) >= 36:continue
		if uses_server_world() and drops[i].has("drop_uid"):
			var uid:=int(drops[i]["drop_uid"])
			if class_relic_locked_for_player(drops[i],class_id):continue
			var item:Dictionary=drops[i]["item"]
			if not can_add_item(item):continue
			if Time.get_ticks_msec()<int(world_drop_request_times.get(uid,0)):continue
			world_drop_request_times[uid]=Time.get_ticks_msec()+700
			rpc_request_world_drop_pickup.rpc_id(1,uid)
			continue
		if drops[i].has("gold"):
			var amount: int = int(drops[i]["gold"])
			gold += amount
			drops.remove_at(i)
			play_sound("pickup")
			effect(player_pos + Vector2(0, -36), "+%d Gold" % amount, Color("ffdb83"), 1.0)
			continue
		var item: Dictionary = drops[i]["item"]
		if class_relic_locked_for_player(drops[i],class_id):continue
		if not can_add_item(item):
			message("Inventar voll! Verkaufe Gegenstände im Dorf.")
			continue
		add_item(item)
		drops.remove_at(i)
		play_sound("pickup")
		message("Gefunden: %s · %s" % [item["name"], RARITY_NAMES[int(item["rarity"])]])
		save_game()

func interact() -> void:
	if arena_mode == "" and dungeon_id < 0 and interior_id < 0 and player_pos.distance_to(BORIN_CRYSTAL_POS) < 95.0:
		panel="fusion";play_sound("menu");return
	if konflux.active:
		konflux.interact(self)
		return
	if arena_mode=="" and dungeon_id<0 and interior_id<0 and player_pos.distance_to(KonfluxMap.ENTRANCE)<170:
		if not can_enter_konflux():
			message("KONFLUX öffnet sich ab Level %d." % KONFLUX_MIN_LEVEL)
			return
		konflux.enter(self)
		return
	if interior_id < 0 and dungeon_id < 0 and arena_mode == "":
		for gate in VILLAGE_GATES:
			if player_pos.distance_to(gate) < 245:
				opened_village_gates[gate] = true
				message("Tor geöffnet. Gebietslevel sind nur noch Empfehlungen.")
				save_game()
				return
	if arena_mode != "": return
	if interior_id >= 0:
		if player_pos.distance_to(INTERIOR_CENTER + Vector2(0, 210)) < 95:
			leave_tavern()
		elif player_pos.distance_to(INTERIOR_CENTER + Vector2(0, -105)) < 130:
			steinrose.open(self)
		return
	if dungeon_id >= 0:
		if player_pos.distance_to(DUNGEON_CENTER + Vector2(-570, 0)) < 110:
			leave_dungeon()
		elif player_pos.distance_to(DUNGEON_CENTER + Vector2(555, 0)) < 105:
			open_dungeon_chest()
		return
	# Wenn das HUD eine Fruchtpflanze anbietet, muss dieselbe E-Interaktion
	# auch wirklich diese Pflanze ernten. So werden Portale, Truhen oder NPCs
	# in der Naehe nicht versehentlich vor die sichtbare Pflanzenaktion gesetzt.
	if food_system.harvest(self):
		return
	if player_pos.distance_to(TAVERN_HOUSE + Vector2(126, 157)) < 112:
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
				var needed_boss:=region_required_boss(int(portal[2]))
				message("Weg versiegelt! Besiege zuerst %s." % boss_gate_name(needed_boss))
				return
			var desired: Vector2 = portal[1]+Vector2(0,110) if near_old else portal[0]+Vector2(0,110)
			var expected_region := int(portal[2]) if near_old else region_at(portal[0])
			player_pos = safe_world_teleport_destination(desired,expected_region)
			mark_network_teleport()
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
			announce_quest_state()
		else:
			message("Nela: Hinter dem Turm in den Ruinen liegt die Quelle der Plage. Sei vorsichtig!")
		return
	for i in LANDMARKS.size():
		if chest_ready(i) and player_pos.distance_to(chest_position(i)) < 85:
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
	if closest.is_empty():
		food_system.harvest(self)
		return
	play_sound("menu")
	if closest["kind"] == "quest":
		if String(closest["name"])=="Borin": panel="skills";skill_tree_tab=0;menu_scroll=0
		else: quest_dialogue(String(closest["name"]))
	elif closest["kind"] == "healer":
		visit_healer()
	elif closest["kind"] == "arena":
		panel = "arena_entry"
	else:
		merchant_kind = String(closest["kind"] )
		shop_page = 0
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
	announce_quest_state()

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
	play_sound("level")
	message("Elara hat deine Wunden geheilt. -%d Gold · HP vollständig." % cost)
	save_game()

func chest_position(index: int) -> Vector2:
	return LANDMARKS[index]["pos"] + Vector2(95, 65)

func chest_ready(index: int) -> bool:
	if index < 0 or index >= opened_chests.size(): return false
	var now := Time.get_unix_time_from_system()
	if bool(opened_chests[index]) and now >= float(chest_respawn_until[index]):
		opened_chests[index] = false
		chest_respawn_until[index] = 0.0
	return not bool(opened_chests[index])

func chest_cooldown_seconds(index: int) -> int:
	if chest_ready(index): return 0
	return maxi(0,ceili(float(chest_respawn_until[index])-Time.get_unix_time_from_system()))

func dungeon_chest_ready(index: int) -> bool:
	if index < 0 or index >= dungeon_chests_opened.size(): return false
	var now := Time.get_unix_time_from_system()
	if bool(dungeon_chests_opened[index]) and now >= float(dungeon_chest_respawn_until[index]):
		dungeon_chests_opened[index] = false
		dungeon_chest_respawn_until[index] = 0.0
	return not bool(dungeon_chests_opened[index])

func open_chest(index: int) -> void:
	if not chest_ready(index):
		message("Die Truhe erscheint in %ds erneut." % chest_cooldown_seconds(index))
		return
	if inventory.size() >= 42:
		message("Inventar voll — verkaufe erst etwas im Dorf.")
		return
	opened_chests[index] = true
	chest_respawn_until[index] = Time.get_unix_time_from_system()+CHEST_RESPAWN_SECONDS
	play_sound("pickup")
	var element: String = ["eis", "gift", "blitz"][index % 3]
	var region := region_at(chest_position(index))
	var rarity := 3 if region_level(region) >= 30 else 2
	var icon := class_weapon_icon()
	var item := make_item("%s von %s" % [{"sword":"Schatzklinge", "staff":"Schatzstab", "bow":"Schatzbogen"}[icon], LANDMARKS[index]["name"]], icon, rarity, 12 + region_level(region) * 2 + rarity * 3, 0, element, region_level(region))
	if rare_head_reward("chest",index,.04):item=make_class_head(region_level(region))
	inventory.append(item)
	gold += 35 + region * 25
	message("Schatztruhe geöffnet: %s (%s)!" % [item["name"], RARITY_NAMES[rarity]])
	save_game()

func waystone_arrival(index: int) -> Vector2:
	var safe_index := clampi(index, 0, WAYSTONES.size() - 1)
	var stone: Vector2 = WAYSTONES[safe_index]
	var region := region_at(stone)
	var base := stone + Vector2(0, 180)
	var offsets := [
		Vector2.ZERO, Vector2(-70,0), Vector2(70,0), Vector2(0,-70),
		Vector2(-70,-70), Vector2(70,-70), Vector2(0,70),
		Vector2(-140,0), Vector2(140,0), Vector2(-140,-70), Vector2(140,-70),
		Vector2(0,-140), Vector2(-70,-140), Vector2(70,-140), Vector2(0,140)
	]
	for offset in offsets:
		var candidate: Vector2 = (base + offset).clamp(Vector2(30,30), WORLD - Vector2(30,30))
		if region_at(candidate) != region: continue
		if is_blocked(candidate, candidate): continue
		return candidate
	return safe_world_teleport_destination(base, region)

func use_waystone() -> void:
	if konflux.active:
		if konflux.room<0 and player_pos.distance_to(KonfluxMap.CENTER)<185: konflux.leave(self, true)
		else: message("Der Spawnwegstein im Zentrum bringt dich nach Sonnenhain zurück.")
		return
	for i in WAYSTONES.size():
		if player_pos.distance_to(WAYSTONES[i]) < 185:
			if i == 0:
				panel = "travel"
				message("Wähle ein freigeschaltetes Ziel.")
			else:
				waystone_unlocked[i] = true
				last_waystone = i
				player_pos = waystone_arrival(0)
				mark_network_teleport()
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
			player_pos = waystone_arrival(i)
			mark_network_teleport()
			last_waystone = i
			panel = ""
			enemies.clear()
			enemy_projectiles.clear()
			play_sound("dodge")
			message("Reise nach %s." % region_name(region_at(player_pos)))
			save_game()
			return

func quick_potion(restore_energy: bool) -> void:
	if konflux.active:
		message("Arena: Erholung im geschützten Spawnkreis, keine Inventartränke.")
		return
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
				message("Dein Inventar ist voll. Verkaufe erst etwas und hole dann die Questbelohnung ab.")
				return
			quests[i]["state"] = 3
			gold += int(QUESTS[i]["gold"])
			gain_xp(int(QUESTS[i]["xp"]))
			add_item(reward_item)
			message("Quest abgeschlossen: %s! +%d XP, +%d Gold" % [QUESTS[i]["title"], QUESTS[i]["xp"], QUESTS[i]["gold"]])
			save_game()
			announce_quest_state()
			return
	for i in QUESTS.size():
		if QUESTS[i]["npc"] == npc_name and quests[i]["state"] == 0 and level + 3 >= region_level(int(ENEMY_TYPES[int(QUESTS[i]["target"])]["region"])):
			quests[i]["state"] = 1
			message("%s: %s — besiege %d %s!" % [npc_name, QUESTS[i]["title"], QUESTS[i]["count"], ENEMY_TYPES[int(QUESTS[i]["target"])]["name"]])
			save_game()
			announce_quest_state()
			return
	message("%s: Deine Aufgaben stehen im Questbuch (J)." % npc_name)

func message(value: String) -> void:
	notice = value
	notice_timer = 5.0

func effect(pos: Vector2, value: String, color: Color, life: float) -> void:
	effects.append({"pos":pos, "text":value, "color":color, "life":life, "max":life})

func slot_save_path(index: int, testing: bool = false) -> String:
	if "--local-test" in OS.get_cmdline_user_args():
		var isolated_dir := command_arg_value("--test-save-dir=", "user://local-test")
		DirAccess.make_dir_recursive_absolute(isolated_dir)
		return isolated_dir.path_join("slot%d%s.json" % [index, "_creative" if testing else ""])
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

func capture_save_data() -> Dictionary:
	var safe_pos: Vector2 = konflux.return_position if konflux.active else (arena_return_pos if arena_mode != "" else (dungeon_return_pos if dungeon_id >= 0 else (interior_return_pos if interior_id >= 0 else player_pos)))
	var safe_hp: float = konflux.hp_before if konflux.active else (max_hp() if arena_mode != "" else hp)
	var data := {"world_version":8, "player_uuid":player_uuid, "recent_players":recent_players, "processed_server_transactions":processed_server_transactions, "discovered_regions":discovered_regions, "position":[safe_pos.x, safe_pos.y], "hp":safe_hp, "energy":energy, "level":level, "xp":xp, "gold":gold, "skill_points":skill_points, "learned":learned, "skill_levels":skill_levels, "slots":slots, "class_id":class_id, "hero_name":hero_name, "hero_gender":hero_gender, "hero_race":hero_race, "character_created":character_created, "inventory":inventory, "equipped_uid":equipped_uid, "equipped_armor_uid":equipped_armor_uid,"equipped_head_uid":equipped_head_uid, "equipped_ring_uid":equipped_ring_uid, "equipped_ring2_uid":equipped_ring2_uid, "last_waystone":last_waystone, "waystone_unlocked":waystone_unlocked, "shop_timer":shop_timer, "shop_stock":shop_stock, "opened_chests":opened_chests, "chest_respawn_until":chest_respawn_until, "dungeon_chests_opened":dungeon_chests_opened, "dungeon_chest_respawn_until":dungeon_chest_respawn_until, "bosses_defeated":bosses_defeated, "final_completed":final_completed, "arena_best":arena_best, "arena_leaderboard":arena_leaderboard, "arena_reward_pending":arena_mode == "survival" and panel == "arena_reward" and not arena_reward_claimed, "arena_reward_wave":arena_reward_wave,"arena_reward_item":arena_reward_item, "next_uid":next_uid, "quests":quests, "tracked_quest_id":quest_guide.tracked_id, "music_enabled":music_enabled, "music_volume":music_volume, "effects_volume":effects_volume, "event_states":event_states, "event_progress":event_progress, "rescue_state":rescue_state, "rescue_kills":rescue_kills}
	data["arcane_step_learned"] = arcane_step_learned
	data["class_mastery_unlocked"] = class_mastery_unlocked
	data["warrior_rage"] = warrior_rage
	data["ranger_hunt_meter"] = ranger_hunt_meter
	data["ranger_hunt_buff"] = ranger_hunt_buff
	data["village_gates"] = [opened_village_gates.has(VILLAGE_GATES[0]),opened_village_gates.has(VILLAGE_GATES[1])]
	data["food_state"] = food_system.snapshot()
	data["steinrose_state"] = steinrose.snapshot()
	return data.duplicate(true)

func save_game() -> void:
	if dedicated_server_mode or konflux_preview_mode or multiplayer_smoke_client_mode: return
	var data := capture_save_data()
	server_save.queue(self,data)
	write_local_save(data if creative_mode else server_save.decorate(data))

func write_local_save(data: Dictionary) -> void:
	if dedicated_server_mode or konflux_preview_mode or multiplayer_smoke_client_mode: return
	var result:Error=preload("res://components/local_save_store.gd").write(slot_save_path(active_save_slot,creative_mode),data)
	if result!=OK:
		pause_status="Lokales Speichern fehlgeschlagen. Vorherige Sicherung bleibt erhalten."
		message(pause_status)
		return
	pause_status="Lokal gesichert ✓" if creative_mode else ("Server gespeichert ✓" if not server_save.dirty else "Lokal gesichert ✓ · Serverbestätigung ausstehend")
	last_save_unix = int(Time.get_unix_time_from_system())
	save_notice_text = "LOKAL GESICHERT" if creative_mode or server_save.dirty else "SERVER GESPEICHERT ✓"
	save_notice_timer = 2.8
	if not creative_mode: refresh_save_slot_labels()

func preserve_save_conflict(data: Dictionary) -> void:
	var file := FileAccess.open(slot_save_path(active_save_slot).trim_suffix(".json")+"_conflict_%d.json" % int(Time.get_unix_time_from_system()),FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))
		file.flush()
		file.close()

func load_game() -> void:
	konflux.active=false
	konflux.room=-1
	var path := slot_save_path(active_save_slot, creative_mode)
	var data:Dictionary=preload("res://components/local_save_store.gd").read(path)
	if data.is_empty():return
	apply_save_data(data)
	if server_save.connected(self): server_save.begin(self)

func apply_save_data(data: Dictionary, from_server: bool=false) -> void:
	opened_village_gates.clear()
	var saved_gates: Array = data.get("village_gates",[])
	for gate_index in mini(saved_gates.size(),VILLAGE_GATES.size()):
		if bool(saved_gates[gate_index]): opened_village_gates[VILLAGE_GATES[gate_index]] = true
	dash_timer = 0.0
	invulnerable = 0.0
	reset_class_skills()
	inventory.clear()
	food_system.restore({})
	quests.clear()
	for i in QUESTS.size(): quests.append({"state":0, "progress":0})
	for i in WORLD_EVENTS.size():
		event_states[i] = 0
		event_progress[i] = 0
	for i in bosses_defeated.size(): bosses_defeated[i] = false
	for i in opened_chests.size(): opened_chests[i] = false
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
	player_uuid = str(data.get("player_uuid",""))
	ensure_player_uuid()
	if not from_server and not creative_mode: server_save.restore(data)
	food_system.restore(data.get("food_state",{}))
	steinrose.restore(data.get("steinrose_state",{}))
	var stored_recent: Variant = data.get("recent_players",[])
	recent_players = stored_recent if stored_recent is Array else []
	while recent_players.size() > 12: recent_players.pop_back()
	var stored_transactions: Variant = data.get("processed_server_transactions",[])
	processed_server_transactions = stored_transactions if stored_transactions is Array else []
	while processed_server_transactions.size() > 256: processed_server_transactions.pop_front()
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
		player_pos = Vector2(825, 1020)
	mark_network_teleport()
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
			if is_slot_skill(id) and learned[id]: slots[i] = id
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
	equipped_head_uid = int(data.get("equipped_head_uid", -1))
	arena_reward_item=data.get("arena_reward_item",{}).duplicate(true) if data.get("arena_reward_item",{}) is Dictionary else {}
	class_mastery_unlocked = bool(data.get("class_mastery_unlocked", false))
	arcane_step_learned = bool(data.get("arcane_step_learned", false)) if class_id == 1 else false
	if class_id == 1 and class_mastery_unlocked: arcane_step_learned = true
	warrior_rage = clampf(float(data.get("warrior_rage",0.0)),0.0,100.0)
	ranger_hunt_meter = clampf(float(data.get("ranger_hunt_meter",0.0)),0.0,100.0)
	ranger_hunt_buff = clampf(float(data.get("ranger_hunt_buff",0.0)),0.0,60.0)
	equipped_ring_uid = int(data.get("equipped_ring_uid", -1))
	equipped_ring2_uid = int(data.get("equipped_ring2_uid", -1)) if class_id == 1 else -1
	last_waystone = clampi(int(data.get("last_waystone", 1)), 1, WAYSTONES.size() - 1)
	var stored_stones: Array = data.get("waystone_unlocked", [])
	for i in mini(stored_stones.size(), WAYSTONES.size()): waystone_unlocked[i] = bool(stored_stones[i])
	if stored_stones.is_empty(): waystone_unlocked[last_waystone] = true
	shop_timer = clampf(float(data.get("shop_timer", 0.0)), 0.0, 419.0)
	var stored_shop: Variant = data.get("shop_stock", {})
	if stored_shop is Dictionary and stored_shop.has("smith"): shop_stock = stored_shop
	append_new_equipment()
	var stored_chests: Array = data.get("opened_chests", [])
	var stored_chest_until: Array = data.get("chest_respawn_until", [])
	for i in opened_chests.size():
		opened_chests[i] = bool(stored_chests[i]) if i < stored_chests.size() and i < stored_chest_until.size() else false
		chest_respawn_until[i] = clampf(float(stored_chest_until[i]),0.0,Time.get_unix_time_from_system()+CHEST_RESPAWN_SECONDS) if i < stored_chest_until.size() else 0.0
		chest_ready(i)
	var stored_dungeon_chests: Array = data.get("dungeon_chests_opened", [])
	var stored_dungeon_until: Array = data.get("dungeon_chest_respawn_until", [])
	for i in dungeon_chests_opened.size():
		dungeon_chests_opened[i] = bool(stored_dungeon_chests[i]) if i < stored_dungeon_chests.size() and i < stored_dungeon_until.size() else false
		dungeon_chest_respawn_until[i] = clampf(float(stored_dungeon_until[i]),0.0,Time.get_unix_time_from_system()+CHEST_RESPAWN_SECONDS) if i < stored_dungeon_until.size() else 0.0
		dungeon_chest_ready(i)
	var stored_bosses: Array = data.get("bosses_defeated", [])
	if stored_bosses.size() == bosses_defeated.size():
		for i in bosses_defeated.size(): bosses_defeated[i] = bool(stored_bosses[i])
	else:
		for i in 3:
			bosses_defeated[i] = int(quests[12 + i].get("state", 0)) >= 2
	next_uid = maxi(next_uid, int(data.get("next_uid", 1)))
	quest_guide.tracked_id = int(data.get("tracked_quest_id",QuestGuide.AUTO))
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
	# Older multiplayer saves may contain completed boss quests but missing boss flags.
	for q in mini(quests.size(),QUESTS.size()):
		var target:int=int(QUESTS[q]["target"])
		if target in [12,13,14] and int(quests[q].get("state",0))>=2:bosses_defeated[target-12]=true
	if is_blocked(player_pos) or (not creative_mode and level < region_level(region_at(player_pos))):
		player_pos = Vector2(825, 1020)
	mark_network_teleport()
	if level < region_level(region_at(WAYSTONES[last_waystone])): last_waystone = 1
	if level >= 20:
		learned[class_ultimate()] = true
		skill_levels[class_ultimate()] = mini(5, 1 + (level - 20) / 5)
	hp = clampf(float(data.get("hp", 100)), 1, max_hp())
	energy = clampf(float(data.get("energy", 100)), 0, max_energy())
	validate_equipment_slots()

func handle_panel_click(mouse: Vector2) -> void:
	if panel == "steinrose":
		steinrose.click(self,mouse)
		return
	if panel == "controller":
		controller.click(self, mouse)
		return
	if panel == "pause" and Rect2(860,319,130,42).has_point(mouse):
		panel = "controller"
		return
	if panel == "start":
		for candidate in 3:
			if Rect2(168 + candidate * 273, 530, 260, 57).has_point(mouse):
				selected_save_slot = candidate + 1
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
			ensure_live_multiplayer()
			message("Spielstand %d geladen. Willkommen zurück!" % active_save_slot)
		return
	if panel == "creation_review":
		if Rect2(190,540,180,44).has_point(mouse):
			creation_replace_confirmed=false
			panel="creation"
		elif Rect2(590,540,365,44).has_point(mouse):
			if FileAccess.file_exists(slot_save_path(active_save_slot)) and not creation_replace_confirmed:
				creation_replace_confirmed=true
				play_sound("menu")
			else:
				start_new_game()
		return
	if panel == "creation":
		for cls in 3:
			if Rect2(245+cls*225,414,205,100).has_point(mouse):
				pending_class=cls
				creation_class_selected=true
				play_sound("menu")
				queue_redraw()
				return
		if Rect2(300, 228, 550, 48).has_point(mouse):
			if touch_enabled: creation_name = mobile_text_prompt("Name deines Helden", creation_name, 16)
			queue_redraw()
			return
		for i in 2:
			if Rect2(300 + i * 210, 300, 195, 40).has_point(mouse):
				pending_gender = i
				play_sound("menu")
		for i in 3:
			if Rect2(245 + i * 220, 365, 205, 44).has_point(mouse):
				pending_race = i
				play_sound("menu")
		if Rect2(300, 520, 550, 52).has_point(mouse) and creation_name.strip_edges().length() >= 2 and creation_class_selected:
			review_character_creation()
		elif Rect2(165, 520, 110, 52).has_point(mouse):
			panel = "start"
		return
	if panel == "multiplayer":
		if Rect2(205, 282, 340, 52).has_point(mouse):
			join_live_multiplayer()
		elif Rect2(605, 282, 340, 52).has_point(mouse) and not is_web_platform():
			host_multiplayer()
		elif Rect2(205, 396, 740, 46).has_point(mouse) and not is_web_platform():
			join_multiplayer_from_code(join_code)
		elif Rect2(205, 454, 740, 46).has_point(mouse):
			join_code = ""
		elif Rect2(205, 520, 200, 46).has_point(mouse):
			disconnect_multiplayer()
			panel = "start"
		elif Rect2(605, 520, 340, 46).has_point(mouse):
			start_coop_world()
		return
	if panel == "party":
		var invite_from := int(party_state.get("invite_from",0))
		if invite_from > 0 and Rect2(205,285,335,48).has_point(mouse):
			if network_mode == "client": rpc_party_command.rpc_id(1,{"action":"accept"})
			return
		if invite_from > 0 and Rect2(575,285,335,48).has_point(mouse):
			if network_mode == "client": rpc_party_command.rpc_id(1,{"action":"decline"})
			return
		if Rect2(205,510,335,46).has_point(mouse) and not (party_state.get("members",[]) as Array).is_empty():
			if network_mode == "client": rpc_party_command.rpc_id(1,{"action":"leave"})
			panel = ""
			return
		if Rect2(750,548,160,38).has_point(mouse):
			panel = ""
			return
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
		if Rect2(190,485,300,36).has_point(mouse):
			panel="patches"
			return
		if Rect2(540,512,410,42).has_point(mouse):
			save_game()
			play_sound("menu")
			return
		var destinations:Array=["","inventory","skills","journal","map","party","settings"]
		for i in destinations.size():
			if Rect2(540,155+i*51,410,42).has_point(mouse):
				if destinations[i]=="skills" and not near_borin():
					message("Skillwechsel nur bei Borin.")
					return
				panel=destinations[i]
				play_sound("menu")
				return
		if Rect2(190,540,300,44).has_point(mouse):
			save_game()
			refresh_save_slot_labels()
			disconnect_multiplayer(false)
			panel="start"
		return
	if panel == "settings":
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

		elif Rect2(300, 432, 550, 42).has_point(mouse):
			play_sound("menu")
			toggle_creative_mode()
		elif not creative_mode and Rect2(300,480,260,38).has_point(mouse):
			export_save_backup()
		elif not creative_mode and Rect2(590,480,260,38).has_point(mouse):
			import_save_backup()
		elif Rect2(300, 563, 550, 35).has_point(mouse):
			if is_web_platform():
				save_game()
				JavaScriptBridge.get_interface("window").location.assign("/")
				return
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
			var column := int(index / 12.0)
			var row := index % 12
			if Rect2(170 + column * 420, 195 + row * 29, 390, 30).has_point(mouse):
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
		panel = controls_return_panel if panel == "controls" else (quest_guide.return_panel if panel == "quest_details" else "")
		sell_all_confirm = false
		pending_purchase = -1
		return
	match panel:
		"skills": click_skills(mouse)
		"fusion": click_fusion(mouse)
		"inventory": click_inventory(mouse)
		"shop": click_shop(mouse)
		"travel": click_travel(mouse)
		"journal": quest_guide.click_journal(self,mouse)
		"quest_details": quest_guide.click_details(self,mouse)

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
	creation_replace_confirmed=false
	creation_class_selected=false
	creation_name = ""
	pending_gender = 0
	pending_race = 0
	character_created = false
	panel = "creation"
	play_sound("menu")

func start_new_game() -> void:
	arena_reward_item.clear()
	equipped_head_uid=-1
	quest_guide.tracked_id = QuestGuide.AUTO
	creative_mode = false
	opened_village_gates.clear()
	dash_timer = 0.0
	invulnerable = 0.0
	hero_name = creation_name.strip_edges().substr(0, 16) if creation_name.strip_edges() != "" else "Held"
	player_uuid = ""
	ensure_player_uuid()
	recent_players.clear()
	hero_gender = pending_gender
	hero_race = pending_race
	character_created = true
	var current_path := slot_save_path(active_save_slot)
	if FileAccess.file_exists(current_path):
		var old_save: String = FileAccess.get_file_as_string(current_path)
		var backup: FileAccess = FileAccess.open(current_path.trim_suffix(".json")+"_backup_%d.json" % Time.get_ticks_usec(), FileAccess.WRITE)
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
	player_pos = Vector2(825, 1020)
	mark_network_teleport()
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
	ensure_live_multiplayer()
	message("Willkommen in Sonnenhain! Rede mit Mira, Borin oder Liora.")
	save_game()
	if server_save.connected(self): server_save.begin(self)

func finish_intro() -> void:
	if panel != "intro": return
	panel = ""
	intro_timer = 0.0
	if is_web_platform():
		ensure_live_multiplayer()
		if network_mode == "client" and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
			rpc_player_presence.rpc_id(1, local_player_state())
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

func all_slot_skills() -> Array:
	var out:Array=[]
	for tree in SKILL_TREES:
		for id in tree:
			if id not in out: out.append(id)
	for fusion in FUSIONS: out.append(int(fusion["id"]))
	return out

func is_slot_skill(index:int) -> bool:
	return index in all_slot_skills()

func skill_point_cost(index:int) -> int:
	if index < 0 or index >= ABILITIES.size(): return 999
	var req:int=int(ABILITIES[index]["req"])
	return 1 if req <= 12 else (2 if req <= 23 else 3)

func skill_choices() -> Array:
	if skill_tree_tab < 0 or skill_tree_tab >= SKILL_TREES.size(): return []
	var out:Array=[]
	for id in SKILL_TREES[skill_tree_tab]:
		if not learned[id] and level >= int(ABILITIES[id]["req"]) and skill_points >= skill_point_cost(id): out.append(id)
	return out.slice(0,mini(3,out.size()))

func buy_skill(index:int) -> bool:
	if index < 0 or index >= ABILITIES.size() or index not in all_slot_skills(): return false
	if learned[index]: return false
	if level < int(ABILITIES[index]["req"]): message("%s benötigt Level %d." % [ABILITIES[index]["name"],ABILITIES[index]["req"]]);return false
	var price:=skill_point_cost(index)
	if skill_points < price: message("Du brauchst %d Skillpunkte." % price);return false
	skill_points -= price;learned[index]=true;skill_levels[index]=1
	message("%s gelernt · %d Skillpunkte" % [ABILITIES[index]["name"],price]);save_game();return true

func fusion_skill_cost(fusion:Dictionary) -> int:
	return (skill_point_cost(int(fusion["a"])) + skill_point_cost(int(fusion["b"]))) * 2

func can_fuse(fusion:Dictionary) -> bool:
	var a:=int(fusion["a"]);var b:=int(fusion["b"]);var id:=int(fusion["id"])
	return not learned[id] and learned[a] and learned[b] and level >= int(ABILITIES[id]["req"]) and skill_points >= fusion_skill_cost(fusion) and gold >= int(fusion["gold"])

func buy_fusion(index:int) -> bool:
	if index < 0 or index >= FUSIONS.size(): return false
	var fusion:Dictionary=FUSIONS[index]
	if not can_fuse(fusion): return false
	var id:=int(fusion["id"]);var sp:=fusion_skill_cost(fusion)
	skill_points-=sp;gold-=int(fusion["gold"]);learned[id]=true;skill_levels[id]=1
	message("%s verschmolzen · -%d SP · -%d Gold" % [ABILITIES[id]["name"],sp,int(fusion["gold"])]);save_game();return true

func click_skills(mouse: Vector2) -> void:
	for tab in 3:
		if Rect2(165+tab*180,145,168,38).has_point(mouse): skill_tree_tab=tab;menu_scroll=0;play_sound("menu");return
	if Rect2(718,145,118,38).has_point(mouse): quest_dialogue("Borin");return
	for slot in 3:
		if Rect2(165+slot*204,190,193,40).has_point(mouse):selected_slot=slot;return
	var ids:Array=SKILL_TREES[skill_tree_tab];var start:=menu_scroll*3
	for card in mini(6,maxi(0,ids.size()-start)):
		var id:int=ids[start+card];var col:=card%3;var row:=int(card/3.0)
		if Rect2(165+col*275,250+row*132,265,118).has_point(mouse):
			if learned[id]:
				for s in 3:
					if slots[s]==id:slots[s]=-1
				slots[selected_slot]=id;save_game()
			else: buy_skill(id)
			return

func upgrade_skill(index: int) -> void:
	buy_skill(index)

func click_inventory(mouse: Vector2) -> void:
	if Rect2(180,205,98,60).has_point(mouse) and equipped_head_uid>=0:
		unequip_slot("head")
		return
	if Rect2(180,275,98,77).has_point(mouse) and equipped_uid >= 0:
		unequip_slot("weapon")
		return
	if Rect2(501,235,98,77).has_point(mouse) and equipped_armor_uid >= 0:
		unequip_slot("armor")
		return
	if class_id == 1 and Rect2(405,440,98,77).has_point(mouse) and equipped_ring2_uid >= 0:
		unequip_slot("ring2")
		return
	if Rect2(300,440,98,77).has_point(mouse) and equipped_ring_uid >= 0:
		unequip_slot("ring")
		return
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
			if selected_item >= 0:
				var uid := int(inventory[selected_item].get("uid",-1))
				var now := Time.get_ticks_msec()
				if uid == last_inventory_click_uid and now-last_inventory_click_msec <= 420:
					last_inventory_click_uid = -1
					last_inventory_click_msec = -10000
					use_item(selected_item)
				else:
					last_inventory_click_uid = uid
					last_inventory_click_msec = now
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
	if Rect2(760,145,80,40).has_point(mouse):
		shop_page = maxi(0,shop_page-1)
		return
	if Rect2(850,145,100,40).has_point(mouse):
		shop_page = mini(int((shop_stock[merchant_kind].size()-1)/3),shop_page+1)
		return
	var stock: Array = shop_stock[merchant_kind].slice(shop_page*3,shop_page*3+3)
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
		total += item_sale_value(item)
		count += int(item.get("count", 1))
		inventory.remove_at(i)
	gold += total
	selected_item = -1
	sell_all_confirm = false
	message("%d Items verkauft: +%d Gold. Ausrüstung behalten." % [count, total])
	save_game()

func use_item(index: int) -> void:
	if index < 0 or index >= inventory.size(): return
	if food_system.eat(self,index): return
	var item: Dictionary = inventory[index]
	var name: String = item["name"]
	if bool(item.get("class_relic",false)):
		var required:=clampi(int(item.get("mastery_class",-1)),0,2)
		if class_id!=required:
			message("%s kann nur von %s verwendet werden." % [name,CLASS_NAMES[required]])
			return
		if class_mastery_unlocked:
			message("%s bereits freigeschaltet." % CLASS_RELIC_SKILLS[class_id])
			return
		class_mastery_unlocked=true
		arcane_step_learned=class_id==1
		inventory.remove_at(index);selected_item=-1
		message("%s freigeschaltet: %s" % [CLASS_NAMES[class_id],CLASS_RELIC_SKILLS[class_id]])
		play_sound("level");save_game();return
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
	elif item["icon"] in ["sword", "staff", "bow", "armor", "ring", "head"]:
		toggle_equipment_item(index)
		return
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
	append_new_equipment()

func append_food_stock() -> void:
	if not shop_stock.has("merchant"): shop_stock["merchant"]=[]
	for nutrition in FoodSystem.FOODS.slice(11,23):
		var exists:=false
		for offer in shop_stock["merchant"]:
			if offer.get("name")==nutrition["name"]: exists=true
		if not exists: shop_stock["merchant"].append({"name":nutrition["name"],"icon":"food","power":0,"price":nutrition["price"],"rarity":0,"level":1})

func append_new_equipment() -> void:
	append_food_stock()
	if not shop_stock.has("merchant"): return
	for offer in [
		{"name":"Reisendenleder", "icon":"armor", "power":2, "price":95, "rarity":0, "level":1},
		{"name":"Wachtpanzer", "icon":"armor", "power":5, "price":230, "rarity":1, "level":3},
		{"name":"Arkanrobe", "icon":"armor", "power":4, "price":220, "rarity":1, "level":3},
		{"name":"Waldläufermantel", "icon":"armor", "power":4, "price":210, "rarity":1, "level":3},
		{"name":"Sonnenrüstung", "icon":"armor", "power":9, "price":580, "rarity":2, "level":8},
		{"name":"Kristallharnisch", "icon":"armor", "power":13, "price":960, "rarity":3, "level":12},
		{"name":"Bernsteinring", "icon":"ring", "power":10, "price":165, "rarity":1, "level":2},
		{"name":"Runenring", "icon":"ring", "power":20, "price":390, "rarity":2, "level":6}
	]:
		var exists := false
		for old in shop_stock["merchant"]:
			if old["name"] == offer["name"]: exists = true
		if not exists: shop_stock["merchant"].append(offer)

func buy_item(stock_item: Dictionary) -> void:
	var price := maxi(0,int(stock_item.get("price",0)))
	if gold < price:
		message("Dafür fehlen dir %d Gold." % (price-gold))
		return
	var icon := str(stock_item.get("icon","gem"))
	if icon not in ["sword","staff","bow","armor","ring","potion","gem","herb","essence","food","head"]:
		message("Dieses Angebot ist ungültig.")
		return
	var purchased := make_item(String(stock_item.get("name","Fundstück")), icon, clampi(int(stock_item.get("rarity",1)),0,4), maxi(0,int(stock_item.get("power",0))), int(price/2.0), String(stock_item.get("element","")), maxi(1,int(stock_item.get("level",level))))
	if not can_add_item(purchased):
		message("Dein Inventar ist voll.")
		return
	var gold_before := gold
	gold -= price
	if not add_item(purchased):
		gold = gold_before
		message("Kauf abgebrochen · Inventar konnte nicht aktualisiert werden.")
		return
	validate_equipment_slots()
	message("Gekauft: %s" % stock_item.get("name","Fundstück"))
	save_game()

func sell_item(index: int) -> void:
	if index < 0 or index >= inventory.size(): return
	var item: Dictionary = inventory[index]
	if is_equipped_uid(int(item.get("uid",-1))):
		message("Ausgerüstete Gegenstände können nicht verkauft werden. Erst ausziehen.")
		return
	var gain := int(round(float(item_sale_value(item)) / maxi(1, int(item.get("count", 1)))))
	gold += gain
	message("Verkauft: %s für %d Gold" % [item["name"], gain])
	if int(item.get("count", 1)) > 1:
		item["count"] = int(item["count"]) - 1
		item["stack_value"] = maxi(0, item_sale_value(item) - gain)
	else:
		inventory.remove_at(index)
		selected_item = -1
	save_game()

func _draw() -> void:
	if panel in ["start","creation","creation_review"] and not dedicated_server_mode:
		character_canvas_offset=Vector2.ZERO
		draw_set_transform(Vector2.ZERO)
		draw_rect(Rect2(Vector2.ZERO,VIEW),Color("071321"))
		for i in 18:
			var x:float=i*72
			draw_line(Vector2(x,0),Vector2(x-240,648),Color("152b3b"),1)
		draw_panel()
		return
	if dedicated_server_mode or DisplayServer.get_name() == "headless": return
	if konflux.active:
		var started:=Time.get_ticks_usec()
		konflux.draw(self)
		performance_draw_us=Time.get_ticks_usec()-started
		return
	var draw_started := Time.get_ticks_usec()
	character_canvas_offset = -camera_pos
	draw_set_transform(-camera_pos)
	draw_world()
	if arena_mode=="" and dungeon_id<0 and interior_id<0 and visible_world(BORIN_CRYSTAL_POS,90): draw_fusion_crystal()
	if arena_mode=="" and dungeon_id<0 and interior_id<0 and visible_world(KonfluxMap.ENTRANCE,260):
		StartScenery32.gate(self,KonfluxMap.ENTRANCE,false,camera_pos)
		var konflux_gate_text := "E · KONFLUX · PvP-Welt · LV %d" % KONFLUX_MIN_LEVEL
		text_at(KonfluxMap.ENTRANCE+Vector2(-230,55),konflux_gate_text,20,Color("ffe2a3") if can_enter_konflux() else Color("c89b8d"),HORIZONTAL_ALIGNMENT_CENTER,460)
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
				if bool(item.get("class_relic",false)):
					var reserved:=int(drop.get("reserved_class",-1))
					var label:="E · %s" % item["name"]
					if class_relic_locked_for_player(drop,class_id):label="🔒 %s · für %s reserviert" % [item["name"],CLASS_NAMES[reserved]]
					text_at(p+Vector2(-105,-34),label,11,Color("fff1bd"),HORIZONTAL_ALIGNMENT_CENTER,210)
	draw_sorted_world_objects()
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
			if visible_world(chest_position(i), 80): draw_chest(chest_position(i), not chest_ready(i))
		for portal in PORTALS:
			if visible_world(portal[0], 100): draw_portal(portal[0], int(portal[2]))
			if visible_world(portal[1], 100): draw_portal(portal[1], int(portal[2]))
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
		if not Rect2(a.min(arc_line["to"])-Vector2(32,32),(arc_line["to"]-a).abs()+Vector2(64,64)).intersects(Rect2(camera_pos,VIEW)): continue
		var b: Vector2 = arc_line["to"]
		var middle := a.lerp(b, 0.5) + (b - a).normalized().rotated(PI * 0.5) * 17
		draw_line(a, middle, Color("fff2a3", 0.55), 13)
		draw_line(middle, b, Color("fff2a3", 0.55), 13)
		draw_line(a, middle, Color.WHITE, 4)
		draw_line(middle, b, Color.WHITE, 4)
	for visual in spell_visuals:
		if visible_world(visual["pos"], 210) or visible_world(visual["end"], 210): draw_spell_visual(visual)
	draw_remote_combat_visuals()
	if dungeon_id >= 0: draw_dungeon_atmosphere()
	elif arena_mode == "" and interior_id < 0: draw_overworld_atmosphere()
	for e in effects:
		if not visible_world(e["pos"],180): continue
		var p: Vector2 = e["pos"] + Vector2(0, (float(e["max"]) - float(e["life"])) * -40)
		text_at(p, String(e["text"]), 18, e["color"], HORIZONTAL_ALIGNMENT_CENTER, 180)
	if arena_mode == "" and dungeon_id < 0 and interior_id < 0: draw_day_night_overlay()
	draw_set_transform(Vector2.ZERO)
	draw_hud()
	character_canvas_offset = Vector2.ZERO
	draw_chat_overlay()
	draw_online_list()
	draw_party_widget()
	draw_multiplayer_debug_overlay()
	if rescue_intro_timer > 0.0 or reward_scene_timer > 0.0: draw_rescue_alert()
	if panel != "": draw_panel()
	performance_draw_us = Time.get_ticks_usec()-draw_started
	performance_draw_samples.append(performance_draw_us)
	if performance_draw_samples.size()>180: performance_draw_samples.pop_front()

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

func draw_online_list() -> void:
	if not online_list_open: return
	var names: Array[String] = []
	var own_name := hero_name.strip_edges() if hero_name.strip_edges() != "" else "Held"
	names.append(own_name + "  (Du)")
	for peer_id in remote_players.keys():
		var state: Dictionary = remote_players[peer_id]
		var remote_name := str(state.get("name","Held")).strip_edges()
		if remote_name == "": remote_name = "Held"
		names.append(remote_name)
	var width := 360.0
	var row_h := 34.0
	var height := 76.0 + row_h * names.size()
	var box := Rect2((VIEW.x - width) * 0.5, 70, width, height)
	draw_rect(box, Color(0.04,0.08,0.11,0.94))
	draw_rect(box, Color("c6a66e"), false, 2)
	text_at(box.position + Vector2(18,31), "ONLINE", 21, Color("ffe1a0"))
	text_at(box.position + Vector2(width-105,30), "%d" % names.size(), 16, Color("bfe7d4"), HORIZONTAL_ALIGNMENT_RIGHT, 80)
	var y := box.position.y + 63.0
	for i in names.size():
		var row := Rect2(box.position.x + 12, y - 22, width - 24, 30)
		draw_rect(row, Color("17272e", 0.9) if i % 2 == 0 else Color("203239", 0.9))
		text_at(Vector2(row.position.x + 12, row.position.y + 21), names[i], 15, Color("fff0ce"))
		y += row_h
	text_at(box.position + Vector2(18,height-14), "ONLINE antippen zum Schließen" if touch_enabled else "TAB gedrückt halten", 11, Color("9fb4ac"))

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
		text_at(box.position + Vector2(12, box.size.y-8), ("CHAT · Gruppenchat" if touch_enabled else "ENTER oder T · Chat"), 11, Color('a9beb7', fade_alpha))

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
	var origin: Vector2=visual["pos"]
	var local: Dictionary=visual.duplicate()
	local["pos"]=Vector2.ZERO
	local["end"]=Vector2(visual["end"])-origin
	draw_set_transform(origin+character_canvas_offset)
	draw_spell_local(local)
	draw_set_transform(character_canvas_offset)

func draw_spell_local(visual: Dictionary) -> void:
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

func current_static_bounds() -> Rect2:
	return static_draw_bounds if static_draw_bounds.has_area() else Rect2(camera_pos,VIEW)

func visible_world(pos: Vector2, margin: float = 100.0) -> bool:
	if static_draw_bounds.has_area(): return static_draw_bounds.grow(margin).has_point(pos)
	return pos.x > camera_pos.x - margin and pos.x < camera_pos.x + VIEW.x + margin and pos.y > camera_pos.y - margin and pos.y < camera_pos.y + VIEW.y + margin

func hash_cell(x: int, y: int) -> int:
	var n := x * 92821 + y * 68917 + x * y * 31
	return absi(n ^ (n >> 11)) % 997

func visual_region_at(p: Vector2) -> int:
	return region_at(p)

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

func armor_visual() -> int:
	for item in inventory:
		if int(item.get("uid",-1)) == equipped_armor_uid:
			var title := str(item.get("name","")).to_lower()
			for key in ["reis", "wacht", "arkan", "wald", "sonnen", "kristall"]:
				if key in title: return ["reis", "wacht", "arkan", "wald", "sonnen", "kristall"].find(key)
			return clampi(int(item.get("design",0)),0,5)
	return -1

func draw_character_sprite(p: Vector2, visual_class: int, walking: bool, look: Vector2, scale_factor: float = 1.0, _attack: bool = false, race_override: int = -1, gender_override: int = -1, armor_override: int=-2, death_override: float=-1.0, hurt:float=0.0,head_override:int=-2,rings_override:int=-2) -> void:
	var local := race_override < 0 or (p == player_pos and scale_factor == 1.0)
	var roll := 1.0-dash_timer/dodge_duration if local and dash_timer > 0 else -1.0
	var death := 1.0-death_timer/DEATH_DURATION if local and death_timer > 0 else death_override
	var outfit := armor_visual() if armor_override == -2 else armor_override
	if panel in ["creation","creation_review"]: outfit = -1
	var head:int=head_visual() if head_override==-2 else head_override
	if panel in ["creation","creation_review"]:head=-1
	var rings:int=ring_visual() if rings_override==-2 else rings_override
	if panel in ["creation","creation_review"]:rings=0
	ReferenceScenery.Hero.paint(self,p,visual_class,hero_race if race_override < 0 else race_override,hero_gender if gender_override < 0 else gender_override,look,(walk_phase if local else world_time*10.0) if walking else 0.0,scale_factor,character_canvas_offset,roll,dash_dir,outfit,death,maxf(hurt,clampf((hurt_until-combat_feedback.clock)/.18,0,1) if local else 0),head,rings)

func draw_character_detail_overlay(p: Vector2, visual_class: int, look: Vector2, scale_factor: float, race: int, gender: int) -> void:
	var accent: Color = [Color('e5bd77'),Color('8fcde6'),Color('91c787')][clampi(visual_class,0,2)]
	var face_y: float = -25.0 if look.y >= -0.4 else -28.0
	if race == 1:
		# Orks: markante Hauer und breitere Schulterakzente.
		PixelStyle32.rect(self,Rect2(p+Vector2(-10,face_y+8)*scale_factor,Vector2(4,3)*scale_factor),Color('efe0bd'))
		PixelStyle32.rect(self,Rect2(p+Vector2(6,face_y+8)*scale_factor,Vector2(4,3)*scale_factor),Color('efe0bd'))
	elif race == 2:
		# Roboter: leuchtender Sensor und Metallfugen.
		PixelStyle32.rect(self,Rect2(p+Vector2(-6,face_y+2)*scale_factor,Vector2(12,3)*scale_factor),Color('8fe8ef'))
		PixelStyle32.rect(self,Rect2(p+Vector2(-12,-8)*scale_factor,Vector2(24,2)*scale_factor),Color('b8c7ca',0.8))
	if visual_class == 0:
		PixelStyle32.rect(self,Rect2(p+Vector2(-17,-15)*scale_factor,Vector2(34,4)*scale_factor),accent.darkened(0.18))
		PixelStyle32.rect(self,Rect2(p+Vector2(-4,-13)*scale_factor,Vector2(8,7)*scale_factor),Color('dbe7e5'))
	elif visual_class == 1:
		# Kleiner Facettenstein am Kapuzenrand statt des unnatürlichen blauen Gesichtsstrichs.
		PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(0,-35)*scale_factor,p+Vector2(4,-32)*scale_factor,p+Vector2(0,-28)*scale_factor,p+Vector2(-4,-32)*scale_factor]),Color('b992df'))
		PixelStyle32.line(self,p+Vector2(-2,-32)*scale_factor,p+Vector2(0,-34)*scale_factor,Color('f0e5ff'),1.4*scale_factor)
	else:
		PixelStyle32.line(self,p+Vector2(-14,-10)*scale_factor,p+Vector2(13,12)*scale_factor,Color('d6b879'),3*scale_factor)
		PixelStyle32.rect(self,Rect2(p+Vector2(11,-3)*scale_factor,Vector2(5,17)*scale_factor),Color('7a5b45'))

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
			PixelStyle32.rect(self,Rect2(p+Vector2(-13,-17)*scale_factor,Vector2(6,3)*scale_factor),base.lightened(0.35))
			PixelStyle32.rect(self,Rect2(p+Vector2(7,-13)*scale_factor,Vector2(5,3)*scale_factor),base.lightened(0.22))
		4, 7, 9, 16, 26:
			for side in [-1.0,1.0]: PixelStyle32.rect(self,Rect2(p+Vector2(side*18-3,-18)*scale_factor,Vector2(6,15)*scale_factor),base.lightened(0.28))
			PixelStyle32.rect(self,Rect2(p+Vector2(-5,-9)*scale_factor,Vector2(10,7)*scale_factor),Color('f4d27c') if type in [4,9,16] else Color('b7f2f6'))
		5, 18, 22:
			PixelStyle32.circle(self,p+Vector2(0,-12)*scale_factor,5*scale_factor,Color('f2f4e8'))
			PixelStyle32.circle(self,p+Vector2(0,-12)*scale_factor,2.2*scale_factor,Color('405b69'))
		8, 15, 23, 24, 25:
			for side in [-1.0,1.0]: PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(side*9,-27)*scale_factor,p+Vector2(side*20,-39)*scale_factor,p+Vector2(side*18,-20)*scale_factor]),base.lightened(0.18))
		10, 6:
			for side in [-1.0,1.0]: PixelStyle32.circle(self,p+Vector2(side*19,-2)*scale_factor,5*scale_factor,base.lightened(0.3))
		11, 20:
			PixelStyle32.arc(self,p+Vector2(0,-7)*scale_factor,17*scale_factor,0,TAU,16,Color(base.lightened(0.42),0.45*pulse),2*scale_factor)
		12, 13, 14:
			PixelStyle32.arc(self,p+Vector2(0,-5)*scale_factor,27*scale_factor,0,TAU,20,Color(base.lightened(0.35),0.38*pulse),3*scale_factor)
	if flash:
		PixelStyle32.arc(self,p,25*scale_factor,0,TAU,18,Color('fff7df',0.72),2*scale_factor)

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
	ReferenceScenery.person(self,p,npc_sprite_row(kind,name),0,1 if name in ["Mira","Liora","Fenna","Elara"] else 0,Vector2.DOWN,0.0,1.0,-camera_pos)

func draw_weapon_world(p: Vector2, family: int, design: int, look: Vector2, scale_factor: float = 1.0, attack_progress: float = -1.0) -> void:
	# Keep small polygons near zero: triangulation loses precision at 80k.
	draw_set_transform(p+character_canvas_offset)
	draw_weapon_local(Vector2.ZERO,family,design,look,scale_factor,attack_progress)
	draw_set_transform(character_canvas_offset)

func draw_weapon_local(p: Vector2, family: int, design: int, look: Vector2, scale_factor: float = 1.0, attack_progress: float = -1.0) -> void:
	var base_dir: Vector2 = look.normalized() if look.length() > 0.01 else Vector2.DOWN
	var dir: Vector2 = weapon_attack_look(base_dir, family, design, attack_progress)
	var side: Vector2 = dir.rotated(PI * 0.5)
	var hand_side: Vector2 = base_dir.rotated(-PI * 0.5)
	var hand: Vector2 = p + (weapon_hand_offset(base_dir)+dir*3.0)*scale_factor
	var variant: int = clampi(design, 0, 11) % 4
	var tier: int = clampi(int(design / 4.0), 0, 2)
	if family == 0:
		# Schwerter und Äxte: klare Silhouette, Metallkante, Griffwicklung und Schmuck.
		if design % 3 == 2:
			var haft_end: Vector2 = hand + dir * (39.0 + tier * 3.0) * scale_factor
			PixelStyle32.line(self,hand - dir * 10.0 * scale_factor, haft_end, Color('4b342f'), 7.0 * scale_factor)
			PixelStyle32.line(self,hand - dir * 8.0 * scale_factor, haft_end, Color('a8754d'), 3.0 * scale_factor)
			var head: Vector2 = haft_end + dir * 5.0 * scale_factor
			PixelStyle32.polygon(self,PackedVector2Array([head-side*4*scale_factor, head+side*18*scale_factor-dir*5*scale_factor, head+side*15*scale_factor+dir*13*scale_factor, head-side*3*scale_factor+dir*10*scale_factor]), Color('aebbc1'))
			PixelStyle32.line(self,head+side*13*scale_factor-dir*3*scale_factor, head+side*11*scale_factor+dir*9*scale_factor, Color('f2eee2'), 2.0*scale_factor)
		else:
			var base: Vector2 = hand + dir * 9.0 * scale_factor
			var tip: Vector2 = base + dir * (49.0 + tier * 5.0 + variant * 2.0) * scale_factor
			PixelStyle32.line(self,hand-dir*9*scale_factor, base, Color('533743'), 7.0*scale_factor)
			PixelStyle32.line(self,base-side*(11+tier)*scale_factor, base+side*(11+tier)*scale_factor, Color('d6a95f'), 6.0*scale_factor)
			var metal: Color = [Color('c9d6da'),Color('c2d0dc'),Color('d7c5df'),Color('d0c1aa')][variant]
			PixelStyle32.polygon(self,PackedVector2Array([base-side*5*scale_factor, tip-dir*6*scale_factor-side*3*scale_factor, tip, tip-dir*6*scale_factor+side*3*scale_factor, base+side*5*scale_factor]), Color('33434a'))
			PixelStyle32.polygon(self,PackedVector2Array([base-side*3*scale_factor, tip-dir*7*scale_factor-side*1.5*scale_factor, tip-dir*2*scale_factor, tip-dir*7*scale_factor+side*1.5*scale_factor, base+side*3*scale_factor]), metal)
			PixelStyle32.line(self,base+dir*7*scale_factor-side*1.4*scale_factor, tip-dir*10*scale_factor-side*1.4*scale_factor, Color('f8fbef',0.78), 1.5*scale_factor)
			PixelStyle32.circle(self,base, (2.8+tier)*scale_factor, [Color('e9bb68'),Color('7fd4e3'),Color('d59be7')][tier])
	elif family == 1:
		# Magierstabb: gebundener Hartholzschaft, Metallringe und je Design eine andere Fantasy-Krone.
		var crown: Vector2 = hand + dir * (52.0 + tier * 6.0) * scale_factor
		var wood: Color = [Color('563b35'),Color('403c59'),Color('514b39'),Color('39464c')][variant]
		var wood_hi: Color = [Color('c18a50'),Color('9e86c9'),Color('a5a06b'),Color('83b6b2')][variant]
		PixelStyle32.line(self,hand-dir*15*scale_factor,crown,Color('302b37'),9.0*scale_factor)
		PixelStyle32.line(self,hand-dir*13*scale_factor,crown,wood,6.0*scale_factor)
		PixelStyle32.line(self,hand-dir*9*scale_factor,crown-dir*12*scale_factor,wood_hi,2.0*scale_factor)
		for band in range(3):
			var band_pos := hand + dir * (float(band * 13) - 7.0) * scale_factor
			PixelStyle32.line(self,band_pos-side*4*scale_factor,band_pos+side*4*scale_factor,Color('d2b978'),3.0*scale_factor)
		var gem: Color = [Color('62d9e5'),Color('c78af1'),Color('9bdb7d'),Color('ff9a54')][variant]
		var core := crown + dir * 9.0 * scale_factor
		match variant:
			0: # Drachenkrone
				for branch in [-1.0,1.0]:
					PixelStyle32.line(self,core-dir*5*scale_factor,core+dir*12*scale_factor+side*branch*14*scale_factor,Color('607d68'),6*scale_factor)
					PixelStyle32.line(self,core+dir*8*scale_factor+side*branch*8*scale_factor,core+dir*20*scale_factor+side*branch*15*scale_factor,Color('d1ab6f'),3*scale_factor)
			1: # Mondsichel mit eingeschlossenem Stern
				PixelStyle32.arc(self,core,15*scale_factor,0.18,TAU-0.18,18,Color('dfd3b3'),5*scale_factor)
				PixelStyle32.polygon(self,PackedVector2Array([core+dir*2*scale_factor,core+side*5*scale_factor,core-dir*5*scale_factor,core-side*5*scale_factor]),gem)
			2: # Wurzelstab mit knorrigen Gabeln
				for branch in [-1.0,1.0]:
					PixelStyle32.line(self,core-dir*5*scale_factor,core+dir*10*scale_factor+side*branch*12*scale_factor,wood_hi,6*scale_factor)
					PixelStyle32.line(self,core+dir*8*scale_factor+side*branch*10*scale_factor,core+dir*19*scale_factor+side*branch*15*scale_factor,wood,4*scale_factor)
			3: # Runenlaterne
				var rim := core+dir*6*scale_factor
				PixelStyle32.line(self,rim-side*12*scale_factor,rim+side*12*scale_factor,Color('c3d1d0'),4*scale_factor)
				PixelStyle32.line(self,rim-dir*7*scale_factor,rim+dir*7*scale_factor,Color('dce8e4'),3*scale_factor)
				PixelStyle32.rect(self,Rect2(core+dir*5*scale_factor-side*4*scale_factor,Vector2(8,8)*scale_factor),gem)
		PixelStyle32.polygon(self,PackedVector2Array([core+dir*3*scale_factor,core+side*5*scale_factor,core-dir*4*scale_factor,core-side*5*scale_factor]),gem.lightened(0.35))
		PixelStyle32.rect(self,Rect2(core+dir*5*scale_factor-Vector2(2,2)*scale_factor,Vector2(4,4)*scale_factor),Color('fff4cf'))
	else:
		# Ein Recurvebogen bildet einen klaren Bogenkörper mit Sehne, Griff und angelegtem Pfeil.
		var wood: Color = [Color('a8764e'),Color('c08b5b'),Color('788f73'),Color('8a654d')][variant]
		if variant == 3:
			var center: Vector2 = hand + dir*19*scale_factor
			var recoil := 0.0
			if attack_progress >= 0.0: recoil = 5.0 * (1.0 - clampf(attack_progress, 0.0, 1.0))
			center -= dir * recoil * scale_factor
			PixelStyle32.line(self,center-side*20*scale_factor, center+side*20*scale_factor, Color('3d3435'), 7*scale_factor)
			PixelStyle32.line(self,center-side*19*scale_factor, center+side*19*scale_factor, wood, 4*scale_factor)
			PixelStyle32.line(self,hand-dir*10*scale_factor, hand+dir*33*scale_factor, Color('7a5a43'), 6*scale_factor)
			PixelStyle32.line(self,center-side*20*scale_factor, center+side*20*scale_factor, Color('e7e2cf'), 1.5*scale_factor)
			PixelStyle32.polygon(self,PackedVector2Array([hand+dir*38*scale_factor,hand+dir*30*scale_factor+side*4*scale_factor,hand+dir*30*scale_factor-side*4*scale_factor]),Color('edf1e6'))
		else:
			# The midpoint of the wooden limbs is the same grip as the arm.
			var center: Vector2 = hand - dir*18*scale_factor
			var limb: float = (21.0 + float(variant % 3) * 2.0 + float(tier) * 2.0) * scale_factor
			var upper := center + side*limb
			var lower := center - side*limb
			var outer_upper := upper + dir*(11.0 + tier*2.0)*scale_factor + side*3.0*scale_factor
			var outer_lower := lower + dir*(11.0 + tier*2.0)*scale_factor - side*3.0*scale_factor
			var bow_points := PackedVector2Array([upper,outer_upper,center+dir*18.0*scale_factor,outer_lower,lower])
			draw_polyline(bow_points,Color('332d34'),9.0*scale_factor,false)
			draw_polyline(bow_points,wood,5.0*scale_factor,false)
			PixelStyle32.line(self,hand-side*5*scale_factor,hand+side*5*scale_factor,Color('654331'),6*scale_factor)
			PixelStyle32.line(self,upper,lower,Color('f2e8d1'),1.8*scale_factor)
			var pull := 0.0
			if attack_progress >= 0.0: pull = 14.0 * sin(clampf(attack_progress, 0.0, 1.0) * PI)
			var draw_hand := center - dir*pull*scale_factor
			PixelStyle32.line(self,upper,draw_hand,Color('f2e8d1'),1.7*scale_factor)
			PixelStyle32.line(self,draw_hand,lower,Color('f2e8d1'),1.7*scale_factor)
			# Pfeilschaft liegt in der Sehne und wird beim Spannen sichtbar zurückgezogen.
			var arrow_start := center-dir*(7.0+pull)*scale_factor
			var arrow_tip := center+dir*30.0*scale_factor
			PixelStyle32.line(self,arrow_start,arrow_tip,Color('4b3c35'),4.0*scale_factor)
			PixelStyle32.line(self,arrow_start,arrow_tip,Color('d9b66f'),2.0*scale_factor)
			PixelStyle32.polygon(self,PackedVector2Array([arrow_tip+dir*7*scale_factor,arrow_tip-side*4*scale_factor,arrow_tip+side*4*scale_factor]),Color('f0f3e8'))
			for branch in [-1.0,1.0]:
				var rune: Vector2 = center+side*branch*8.0*scale_factor+dir*8.0*scale_factor
				PixelStyle32.rect(self,Rect2(rune-Vector2(2,2)*scale_factor,Vector2(4,4)*scale_factor),Color('e2c477'))

func draw_skill_sprite(id: int, p: Vector2, size: float = 32.0) -> void:
	if id >= 34:
		var s:float=size/32.0
		var center:=p+Vector2(16,16)*s
		var tint:=Color("78d8e6") if id<=39 else Color("c999ff")
		draw_rect(Rect2(p+Vector2(5,5)*s,Vector2(22,22)*s),Color(tint,0.18))
		draw_arc(center,10*s,0,TAU,16,tint,3*s)
		if id in [34,37,39,42]:
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(17,3)*s,p+Vector2(8,17)*s,p+Vector2(15,17)*s,p+Vector2(12,29)*s,p+Vector2(25,13)*s,p+Vector2(19,13)*s]),Color("fff0a0"))
		elif id in [35,36,41]:
			draw_rect(Rect2(center-Vector2(3,10)*s,Vector2(6,20)*s),tint)
			draw_rect(Rect2(center-Vector2(10,3)*s,Vector2(20,6)*s),tint)
		else:
			for a in 4: draw_line(center,center+Vector2.RIGHT.rotated(float(a)*PI/2.0)*11*s,tint,3*s)
		return
	if id in [16,17,18]:
		var s:float=size/32.0
		if id==16:
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(5,25)*s,p+Vector2(5,17)*s,p+Vector2(11,10)*s,p+Vector2(13,3)*s,p+Vector2(22,13)*s,p+Vector2(26,8)*s,p+Vector2(28,22)*s,p+Vector2(22,29)*s,p+Vector2(11,29)*s]),Color("ef783d"))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(11,25)*s,p+Vector2(16,14)*s,p+Vector2(23,25)*s,p+Vector2(18,29)*s]),Color("ffe39b"))
		elif id==17:
			for angle in [0.0,PI/3,2*PI/3]:
				var d:Vector2=Vector2.from_angle(angle)*12*s
				PixelStyle32.line(self,p+Vector2(16,16)*s-d,p+Vector2(16,16)*s+d,Color("a9eff5"),3*s)
			PixelStyle32.rect(self,Rect2(p+Vector2(12,12)*s,Vector2(8,8)*s),Color("efffff"))
		else:
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(17,2)*s,p+Vector2(7,18)*s,p+Vector2(15,18)*s,p+Vector2(12,30)*s,p+Vector2(27,12)*s,p+Vector2(19,12)*s,p+Vector2(24,2)*s]),Color("ffe799"))
		return
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
	if not draw_cached_overworld():
		draw_static_overworld(Rect2(camera_pos,VIEW))
	draw_class_boss_arenas()
	draw_region_gates()

func draw_class_boss_arenas() -> void:
	for i in CLASS_BOSS_SITES.size():
		var center:Vector2=CLASS_BOSS_SITES[i]
		if not visible_world(center,CLASS_BOSS_ARENA_RADIUS+80.0):continue
		var accent:Color=[Color("b65c48"),Color("8062c7"),Color("6f9f56")][i]
		# Der Boden bleibt vollständig begehbar; Steine/Runen zeigen nur den Kampfraum.
		draw_circle(center,CLASS_BOSS_ARENA_RADIUS,Color(accent,.055))
		draw_arc(center,CLASS_BOSS_ARENA_RADIUS,0,TAU,64,Color(accent,.55),5)
		draw_arc(center,CLASS_BOSS_ARENA_RADIUS-26,0,TAU,64,Color(accent,.20),2)
		for rune in 12:
			var angle:=float(rune)*TAU/12.0
			var pos:=center+Vector2.RIGHT.rotated(angle)*(CLASS_BOSS_ARENA_RADIUS-18.0)
			var tangent:=Vector2.RIGHT.rotated(angle+PI*.5)
			draw_line(pos-tangent*10.0,pos+tangent*10.0,Color(accent,.72),3)
		text_at(center+Vector2(-140,-CLASS_BOSS_ARENA_RADIUS+42),["KRIEGSHERR","ARKANHÜTER","JAGDMEISTER"][i],14,accent.lightened(.35),HORIZONTAL_ALIGNMENT_CENTER,280)

func draw_static_overworld(bounds: Rect2) -> void:
	if not start_tilemap_32_attached and bounds.intersects(StartTileMap32.BOUNDS):
		StartTileMap32.paint(self,bounds,Callable(self,"distance_to_trail"))
	# Alle Regionen werden über dasselbe 16px-Raster aufgebaut und nur farblich variiert.
	var start_x := maxi(0, int(bounds.position.x / 64) - 2)
	var end_x := mini(int(WORLD.x / 64) + 1, int((bounds.end.x) / 64) + 2)
	var start_y := maxi(0, int(bounds.position.y / 64) - 2)
	var end_y := mini(int(WORLD.y / 64) + 1, int((bounds.end.y) / 64) + 2)
	for tx in range(start_x, end_x):
		for ty in range(start_y, end_y):
			var key := hash_cell(tx, ty)
			var tile_origin := Vector2(tx * 64, ty * 64)
			var center := tile_origin + Vector2(32, 32)
			var zone := visual_region_at(center)
			var wet := zone == 6 and center.y > 6850 + sin(center.x / 220.0) * 125.0
			var tile_rect := Rect2(tile_origin,Vector2(64,64))
			if zone == 0 and region_rect(0).encloses(tile_rect): continue
			if not region_rect(zone).encloses(tile_rect):
				for border_zone in 13:
					var part := region_rect(border_zone).intersection(tile_rect)
					if part.has_area() and border_zone != 0: draw_rect(part,region_ground_color(border_zone,key,border_zone == 6 and wet))
				continue
			if USE_VILLAGE_REFERENCE_BACKGROUND and VILLAGE_REF_RECT.grow(150).has_point(center):
				draw_rect(Rect2(tile_origin, Vector2(64, 64)), Color("6d8043"))
				if VILLAGE_REF_RECT.grow(20).has_point(center):
					continue
				if key % 9 == 0:
					draw_flower(tile_origin + Vector2(14, 20), key)
				continue
			if zone == 0:
				ReferenceScenery.ground(self, tile_origin, key)
			else:
				draw_rect(Rect2(tile_origin, Vector2(64, 64)), region_ground_color(zone, key, wet))
			if zone in [4, 7, 10, 12] and key % 9 == 0:
				draw_rect(Rect2(tile_origin + Vector2(13, 17), Vector2(39, 21)), Color('edfaff', 0.12))
			elif zone == 5 and key % 8 == 0:
				draw_rect(Rect2(tile_origin + Vector2(8, 41), Vector2(44, 7)), Color('f0af71', 0.18))
			var p := Vector2(tx * 64 + (key % 23), ty * 64 + ((key / 23) % 25))
			if class_boss_arena_index_at(p,55.0)>=0:continue
			if not region_rect(zone).grow(-45).encloses(Rect2(p-Vector2(100,160),Vector2(200,210))): continue
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
				if key % 13 == 0: draw_tree(p,zone)
				elif key % 6 == 0: draw_lava(p)
				elif key % 4 == 0: draw_rock(p)
				else: draw_pebbles(p)
			elif zone == 6:
				if wet: draw_wave(p, key)
				elif key % 11 == 0: draw_tree(p,zone)
				elif key % 5 == 0: draw_shell(p)
				elif key % 3 == 0: draw_pebbles(p)
			elif zone == 7:
				if key % 11 == 0: draw_tree(p,zone)
				elif key % 4 == 0: draw_crystal(p, key)
				elif key % 5 == 0: draw_rock(p)
				else: draw_pebbles(p)
			elif zone >= 8:
				if zone in [8,9] and key % 4 == 0: draw_tree(p,zone)
				elif zone == 10 and key % 9 == 0: draw_tree(p,zone)
				elif zone == 11 and key % 7 == 0: draw_tree(p,zone)
				elif zone == 12 and key % 6 == 0: draw_tree(p,zone)
				elif zone in [10,12] and key % 5 == 0: draw_crystal(p, key)
				elif zone == 11 and key % 4 == 0: draw_rock(p)
				elif key % 7 == 0: draw_rock(p)
				elif key % 3 == 0: draw_flower(p, key)
				else: draw_grass(p)
	draw_trails()
	var cell_min_x := maxi(0, int(bounds.position.x / 250) - 2)
	var cell_max_x := mini(int(WORLD.x / 250) + 1, int((bounds.end.x) / 250) + 2)
	var cell_min_y := maxi(0, int(bounds.position.y / 250) - 2)
	var cell_max_y := mini(int(WORLD.y / 250) + 1, int((bounds.end.y) / 250) + 2)
	for cx in range(cell_min_x, cell_max_x):
		for cy in range(cell_min_y, cell_max_y):
			var obstacle := obstacle_in_cell(cx, cy)
			if not obstacle.is_empty() and class_boss_arena_index_at(obstacle['pos'],65.0)<0 and visible_world(obstacle['pos'], 110): draw_obstacle(obstacle)
	
	draw_village_ground()
	if bounds.intersects(Rect2(WAYSTONES[0]-Vector2(280,280),Vector2(560,560))):SpawnPlatform32.platform(self,WAYSTONES[0])
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
	draw_npc({"name":"Alma", "role":"Wirtin der Steinrose · Kueche & Rezepte", "pos":INTERIOR_CENTER + Vector2(0, -105), "color":Color("ba795e"), "kind":"innkeeper"})
	text_at(INTERIOR_CENTER + Vector2(-170, -269), "ZUR STEINROSE", 22, Color("fce5b2"), HORIZONTAL_ALIGNMENT_CENTER, 340)
	text_at(INTERIOR_CENTER + Vector2(-110, 215), ("%s · ZURÜCK NACH SONNENHAIN" % ("AKTION" if touch_enabled else binding_short("interact"))), 14, Color("ffefd0"), HORIZONTAL_ALIGNMENT_CENTER, 220)

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
	draw_chest(chest_pos, not dungeon_chest_ready(dungeon_id))
	if not enemies.is_empty() and dungeon_chest_ready(dungeon_id):
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
	var edge_colors := [Color("7b6443"), Color("4e4a45"), Color("624d3b"), Color("45414f")]
	var mid_colors := [Color("927453"), Color("77736b"), Color("927555"), Color("716b7b")]
	var road_colors := [Color("c6aa73"), Color("a49b8c"), Color("b69b73"), Color("91899a")]
	for trail_index in TRAILS.size():
		var trail: Array = TRAILS[trail_index]
		var theme_for_trail := 0
		for point_index in trail.size():
			var point: Vector2 = trail[point_index]
			if point_index < trail.size() - 1: theme_for_trail = _trail_theme(region_at(point.lerp(trail[point_index + 1], 0.5)))
			if region_at(point)!=0 and visible_world(point, 90.0):
				draw_circle(point, 58.0, edge_colors[theme_for_trail])
				draw_circle(point, 52.0, mid_colors[theme_for_trail])
				draw_circle(point, 45.0, road_colors[theme_for_trail])
		for i in range(trail.size() - 1):
			var a: Vector2 = trail[i]
			var b: Vector2 = trail[i + 1]
			if not Rect2(a.min(b) - Vector2(140,140), (b-a).abs() + Vector2(280,280)).intersects(current_static_bounds()): continue
			var region := region_at(a.lerp(b, 0.5))
			if region == 0: continue
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
	var dark := Color("354346")
	var mid := Color("66776f")
	var light := Color("aab09c")
	var mortar := Color("495956")
	var moss := Color("5f8f69")
	var thickness := 92.0

	for part_value in [Vector2(first,gap-GATE_HALF_WIDTH),Vector2(gap+GATE_HALF_WIDTH,last)]:
		var part: Vector2 = part_value
		var length := part.y-part.x
		if length <= 0.0: continue
		var face := Rect2(start.x-thickness*0.5,part.x,thickness,length) if vertical else Rect2(part.x,start.y-thickness*0.5,length,thickness)
		if not face.grow(120).intersects(current_static_bounds()): continue

		# Solider, texturunabhängiger Mauerkörper.
		draw_rect(face,dark)
		var inset := Rect2(face.position+(Vector2(8,0) if vertical else Vector2(0,8)),face.size-(Vector2(16,0) if vertical else Vector2(0,16)))
		draw_rect(inset,mid)
		# Helle Mauerkrone auf der dem Dorf zugewandten Seite.
		var crown := Rect2(face.position+(Vector2(7,0) if vertical else Vector2(0,7)),Vector2(face.size.x-14,15) if vertical else Vector2(15,face.size.y-14))
		draw_rect(crown,light)

		# Versetzte Steinblöcke, vollständig prozedural.
		var stone_len := 44.0
		var rows := 3
		var count := ceili(length/stone_len)+1
		for row in rows:
			for stone in count:
				var stagger := stone_len*0.5 if row%2==1 else 0.0
				var axis := part.x+stone*stone_len-stagger
				if axis >= part.y: continue
				var axis_end := minf(axis+stone_len-3.0,part.y)
				if axis_end <= part.x: continue
				if vertical:
					var band_x := start.x-thickness*0.5+10.0+row*24.0
					draw_rect(Rect2(Vector2(band_x,maxf(axis,part.x)+2),Vector2(20,axis_end-maxf(axis,part.x)-3)),mid.lightened(0.04 if (stone+row)%2==0 else -0.02))
					draw_line(Vector2(band_x,maxf(axis,part.x)),Vector2(band_x+20,maxf(axis,part.x)),mortar,2)
				else:
					var band_y := start.y-thickness*0.5+10.0+row*24.0
					draw_rect(Rect2(Vector2(maxf(axis,part.x)+2,band_y),Vector2(axis_end-maxf(axis,part.x)-3,20)),mid.lightened(0.04 if (stone+row)%2==0 else -0.02))
					draw_line(Vector2(maxf(axis,part.x),band_y),Vector2(maxf(axis,part.x),band_y+20),mortar,2)

		# Moos und kleine Schäden, damit die Mauer wieder lesbar und lebendig wirkt.
		var marks := ceili(length/72.0)
		for mark in marks:
			var axis := part.x+20.0+mark*72.0
			if axis >= part.y-8.0: continue
			if mark%3==0:
				var mp := Vector2(start.x+thickness*0.22,axis) if vertical else Vector2(axis,start.y+thickness*0.22)
				draw_rect(Rect2(mp-Vector2(7,3),Vector2(14,6)),moss)
			if mark%4==1:
				if vertical:
					draw_line(Vector2(start.x-17,axis),Vector2(start.x+9,axis+14),Color("2f3b3c"),2)
				else:
					draw_line(Vector2(axis,start.y-17),Vector2(axis+14,start.y+9),Color("2f3b3c"),2)

	# Massive Torpfeiler sind immer sichtbar, unabhängig vom Torzustand.
	for side in [-1.0,1.0]:
		var post := gate+(Vector2(0,side*GATE_HALF_WIDTH) if vertical else Vector2(side*GATE_HALF_WIDTH,0))
		draw_rect(Rect2(post-Vector2(43,43),Vector2(86,86)),dark)
		draw_rect(Rect2(post-Vector2(34,34),Vector2(68,68)),mid)
		draw_rect(Rect2(post-Vector2(38,39),Vector2(76,15)),light)
		draw_rect(Rect2(post+Vector2(-11,7),Vector2(22,16)),Color("d8bb74"))

	var village_gate := gate in VILLAGE_GATES
	var gate_open := village_gate and opened_village_gates.has(gate)
	if village_gate:
		if not gate_open:
			var door := Rect2(gate+(Vector2(-24,-150) if vertical else Vector2(-150,-24)),Vector2(48,300) if vertical else Vector2(300,48))
			draw_rect(door,Color("3f2d24"))
			for n in range(15):
				var plank := Rect2(door.position+(Vector2(5,n*20+2) if vertical else Vector2(n*20+2,5)),Vector2(38,16) if vertical else Vector2(16,38))
				draw_rect(plank,Color("9a7148") if n%2 else Color("805a3b"))
			if vertical:
				draw_line(gate+Vector2(-29,-142),gate+Vector2(29,142),Color("c3a06c"),6)
				draw_line(gate+Vector2(29,-142),gate+Vector2(-29,142),Color("c3a06c"),6)
			else:
				draw_line(gate+Vector2(-142,-29),gate+Vector2(142,29),Color("c3a06c"),6)
				draw_line(gate+Vector2(-142,29),gate+Vector2(142,-29),Color("c3a06c"),6)
			text_at(gate+Vector2(-105,-82),"E · TOR ÖFFNEN",16,Color("fff0bc"))
		else:
			text_at(gate+Vector2(-85,-82),"TOR OFFEN",14,Color("fff0bc"))

	var boss_locked: bool = boss_index >= 0 and not bosses_defeated[boss_index]
	if boss_locked:
		var seal := Rect2(gate+(Vector2(-28,-GATE_HALF_WIDTH+39) if vertical else Vector2(-GATE_HALF_WIDTH+39,-28)),Vector2(56,GATE_HALF_WIDTH*2-78) if vertical else Vector2(GATE_HALF_WIDTH*2-78,56))
		draw_rect(seal,Color("6e405b",0.94))
		draw_rect(seal.grow(-8),Color("c37598",0.9),false,4)
		draw_line(seal.position,seal.end,Color("e3a1bf",0.7),3)
		draw_line(Vector2(seal.end.x,seal.position.y),Vector2(seal.position.x,seal.end.y),Color("e3a1bf",0.7),3)
		text_at(gate+Vector2(-145,-62),"BOSS-SIEG NÖTIG",14,Color("fff0bc"),HORIZONTAL_ALIGNMENT_CENTER,290)
		text_at(gate+Vector2(-145,-42),boss_gate_name(boss_index).to_upper(),13,Color("ffd0d0"),HORIZONTAL_ALIGNMENT_CENTER,290)
	elif not village_gate or gate_open:
		text_at(gate+Vector2(-120,-52),"DURCHGANG · EMPF. LV %d" % required_level,12,Color("fff0bc"),HORIZONTAL_ALIGNMENT_CENTER,240)

func draw_grass(p: Vector2) -> void:
	if region_at(p) == 0:
		ReferenceScenery.grass(self, p, int(p.x+p.y))
		return
	draw_rect(Rect2(p + Vector2(1, 8), Vector2(3, 8)), Color('5f9d67'))
	draw_rect(Rect2(p + Vector2(6, 4), Vector2(3, 12)), Color('72b670'))
	draw_rect(Rect2(p + Vector2(10, 7), Vector2(4, 10)), Color('80bf73'))
	draw_rect(Rect2(p + Vector2(15, 3), Vector2(3, 12)), Color('69ab67'))
	draw_rect(Rect2(p + Vector2(18, 9), Vector2(2, 7)), Color('8cca7b'))

func draw_flower(p: Vector2, key: int) -> void:
	if region_at(p) == 0:
		ReferenceScenery.flower(self, p, key)
		return
	var petals: Color = [Color('fff3a6'), Color('f5a4b9'), Color('c8b2f2'), Color('e8f5e6')][key % 4]
	draw_rect(Rect2(p + Vector2(9, 10), Vector2(3, 10)), Color('569a60'))
	for offset in [Vector2(-6, 0), Vector2(6, 0), Vector2(0, -6), Vector2(0, 6), Vector2(-4, -4), Vector2(4, 4)]:
		draw_rect(Rect2(p + Vector2(8, 7) + offset, Vector2(4, 4)), petals)
	draw_rect(Rect2(p + Vector2(8, 7), Vector2(5, 5)), Color('eec06e'))
	draw_rect(Rect2(p + Vector2(9, 9), Vector2(3, 3)), Color('fff7d0'))

func draw_bush_cluster(p: Vector2, zone: int, key: int) -> void:
	if zone == 0:
		ReferenceScenery.bush(self, p, key)
		return
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
	# Dekobuesche tragen absichtlich keine Fruechte. Sichtbare Frucht = FoodSystem-Interaktion.

func draw_tree(p: Vector2, zone: int) -> void:
	if zone == 0:
		ReferenceScenery.tree(self, p, int(p.x+p.y))
		return
	var seed := int(p.x * 0.17 + p.y * 0.11)
	var leaf := Color('5da875')
	var bark := Color('705a4e')
	if zone == 2:
		leaf = Color('477d72') # Mooskrone
		bark = Color('65534b')
	elif zone == 3:
		leaf = Color('8ba376') # Ruinenfeige / Steineiche
		bark = Color('736457')
	elif zone == 4:
		leaf = Color('58a6a8') # Kristallweide
		bark = Color('5a605e')
	elif zone == 5:
		leaf = Color('80665e') # Aschekiefer
		bark = Color('493d3d')
	elif zone == 6:
		leaf = Color('6f9f8a') # Quellweide / Sumpferle
		bark = Color('665744')
	elif zone == 7:
		leaf = Color('76806b') # Steineiche / Windgrat-Kiefer
		bark = Color('625b52')
	elif zone == 8:
		leaf = Color('7faaa2') # Nebelbirke
		bark = Color('b9b7aa')
	elif zone == 9:
		leaf = Color('a58d52') # Bernsteinulme
		bark = Color('72523c')
	elif zone == 10:
		leaf = Color('6fa6a0') # Quellweide / Perlenbaum
		bark = Color('65756e')
	elif zone == 11:
		leaf = Color('66677b') # Daemmerzypresse
		bark = Color('514b58')
	elif zone == 12:
		leaf = Color('aaa0c5') # Himmelsbaum / Sternenbaum
		bark = Color('7c7489')
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
	if region_at(p) == 0:
		ReferenceScenery.rock(self,p)
		return
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

func draw_village_ground() -> void:
	return

func draw_village_ground_legacy() -> void:
	for i in range(16):
		var pos := Vector2(660+(i%8)*42,1200+(i/8)*140)
		if pos.x<=1010 and visible_world(pos,40): ReferenceScenery.flower(self,pos,i)

func draw_village() -> void:
	for prop in village_props()+food_system.regional_props(self):
		if visible_world(prop["point"],250): paint_village_prop(prop)

func draw_house(p: Vector2) -> void:
	var house_kind:int=2 if p==TAVERN_HOUSE else 0
	for shop in VillageLayout.SHOPS:
		if shop["house"]==p and shop["kind"]=="healer":house_kind=1
	StartScenery32.house(self,p,house_kind)
	if p==TAVERN_HOUSE:StartScenery32.sign(self,p,"STEINROSE",font)
func draw_npc(npc: Dictionary) -> void:
	var p: Vector2 = npc["pos"]
	var kind: String = str(npc["kind"])
	var name: String = str(npc["name"])
	var baked := USE_VILLAGE_REFERENCE_BACKGROUND and panel == "" and VILLAGE_REF_RECT.has_point(p) and (name == "Mira" or name == "Liora" or name == "Arven")
	if baked:
		if kind == "quest":
			var baked_state := quest_marker_state(name)
			if baked_state != 0:
				var baked_marker := "!" if baked_state == 1 else "?"
				var baked_color := Color("f6ce65") if baked_state in [1,3] else Color("a9b1ad")
				text_at(p + Vector2(-15,-152),baked_marker,34,baked_color,HORIZONTAL_ALIGNMENT_CENTER,34)
				if baked_state == 2: text_at(p + Vector2(-62,-170),"OFFEN",11,Color("d2d8d1"),HORIZONTAL_ALIGNMENT_CENTER,124)
				elif baked_state == 3: text_at(p + Vector2(-72,-170),"ABGEBEN",11,Color("ffe18a"),HORIZONTAL_ALIGNMENT_CENTER,144)
		return
	draw_npc_sprite(p,kind,name)
	var caption := name if kind == "quest" or (interior_id < 0 and region_at(p) == 0) else "%s (%s)" % [name,npc["role"]]
	if interior_id < 0 and region_at(p)==0:
		var label_width:float=clampf(font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x+12,70,232)
		draw_rect(Rect2(p+Vector2(-label_width/2,-63),Vector2(label_width,20)),Color("192d2a",0.86))
		text_at(p+Vector2(-label_width/2,-48),caption,14,Color("ffedc5"),HORIZONTAL_ALIGNMENT_CENTER,label_width)
	else:
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

func draw_class_boss_actor(enemy:Dictionary,p:Vector2,look:Vector2,scale_factor:float,attack_progress:float) -> void:
	var boss_index:=clampi(int(enemy["type"])-12,0,2)
	var walking:=bool(enemy.get("walking",false))
	var hurt:=clampf(float(enemy.get("flash",0.0))/.18,0.0,1.0)
	var stride:=world_time*(8.5 if boss_index==2 else (6.8 if boss_index==1 else 5.8)) if walking else 0.0
	# Eigener humanoider Bosskörper: alle vier Richtungen, Schrittanimation,
	# Trefferblitz und die jeweilige Klassen-Kopfbedeckung sind Teil des Körpers.
	ReferenceScenery.Hero.paint(self,p,boss_index,0,0,look,stride,scale_factor,character_canvas_offset,-1.0,look,-1,-1.0,hurt,boss_index,0)
	var weapon_design:int=int([3,7,11][boss_index])
	if boss_index==0:
		draw_weapon_world(p+Vector2(0,-5),0,weapon_design,look,scale_factor,attack_progress)
	elif boss_index==1:
		draw_weapon_world(p+Vector2(0,-5),1,weapon_design,look,scale_factor,attack_progress)
	else:
		draw_weapon_world(p+Vector2(0,-5),2,weapon_design,look,scale_factor,attack_progress)
	# Phasen-Aura macht sofort sichtbar, dass der Boss unter 68/38 Prozent neue Skills erhält.
	var ratio:=float(enemy.get("hp",1.0))/maxf(1.0,float(enemy.get("max_hp",1.0)))
	if ratio<=.68:
		var aura_color:Color=[Color("f2685f",.36),Color("a477ff",.38),Color("87dc73",.36)][boss_index]
		PixelStyle32.arc(self,p+Vector2(0,4),34*scale_factor,0,TAU,24,aura_color,2.5*scale_factor)
	if ratio<=.38:
		PixelStyle32.arc(self,p+Vector2(0,4),42*scale_factor,0,TAU,24,[Color("ff5c4d",.48),Color("cf73ff",.5),Color("b7f16d",.48)][boss_index],3.5*scale_factor)

func draw_enemy(enemy: Dictionary) -> void:
	var p: Vector2 = enemy["pos"]
	var type: int = int(enemy["type"])
	var elite_kind: int = int(enemy.get("elite", 0))
	var boss := type in [12,13,14]
	var bob := sin(world_time * (3.1 if type != 0 else 5.4) + float(enemy.get("seed",0.0))) * (4.0 if type in [0,5,7,11,18,22,25] else 2.0)
	var scale_factor:float=mob_visual_scale(enemy)
	# Keine schwarzen Balken unter Gegnern: die Silhouette endet mit ihren eigenen Füßen.
	if elite_kind > 0:
		var aura := Color('f4d485',0.65) if elite_kind == 2 else Color('d99ce7',0.55)
		draw_arc(p + Vector2(0,4), 32*scale_factor, 0, TAU, 24, aura, 3)
	var profile:=mob_profile(enemy)
	var state:Dictionary=enemy.get("attack_state",{})
	var aim:Vector2=enemy.get("facing",Vector2.DOWN)
	var animation:float=-1.0
	if not state.is_empty():
		aim=state.get("dir",aim)
		animation=MobCombat.visual_progress(state,profile)
		if float(state.get("age",0))<float(profile["windup"]):
			var ability:Dictionary=state["ability"]
			var warn:Color=[Color("f36f5d",.72),Color("ba7cff",.72),Color("9cdd72",.72)][type-12] if boss else Color("efd49a",.6)
			if ability["shape"]=="line":
				PixelStyle32.line(self,p,p+aim*float(ability["range"]),Color(warn,.25),20)
			elif ability["shape"]=="arc":
				PixelStyle32.arc(self,p,float(ability["range"]),aim.angle()-float(ability["half_angle"]),aim.angle()+float(ability["half_angle"]),18,warn,2)
			else:PixelStyle32.line(self,p,p+aim*float(ability["range"]),Color(warn,.3),2)
	var enemy_color:Color=ENEMY_TYPES[type]["color"]
	var model_pos:Vector2=p
	var stride:float=world_time*(3.5 if bool(profile["heavy"]) else 7.0) if bool(enemy.get("walking",false)) else 0.0
	draw_set_transform(Vector2.ZERO)
	var motion:=Vector2.ONE
	if type==0:
		var creep:=sin(world_time*6+float(enemy.get("seed",0)))
		motion=Vector2(1+creep*.1,1-creep*.08)
	if type==1:
		model_pos.y-=9+sin(world_time*7+float(enemy.get("seed",0)))*3
		stride=world_time*18
	if boss:
		draw_class_boss_actor(enemy,model_pos,aim,scale_factor,animation)
	else:
		MobDesign32.paint(self,model_pos+character_canvas_offset,type,enemy_level(type),aim,enemy_color.lerp(Color("fff3de"),clampf(float(enemy.get("flash",0))/.18,0,1)*.7),stride,animation,scale_factor,motion)
	draw_set_transform(character_canvas_offset)
	if float(enemy.get("flash", 0.0)) > 0.0:
		draw_arc(model_pos, 37.0 * scale_factor, 0.0, TAU, 18, Color("fff7df", 0.72), 3.0)
	draw_enemy_level(p, type, boss, elite_kind)
	combat_feedback.health(self,"mob:%d"%int(enemy["uid"]),p+Vector2(0,-135 if type==12 else (-104 if boss else -54)),float(enemy["hp"]),float(enemy["max_hp"]),106 if boss else 54)

func draw_enemy_level(p: Vector2, type: int, boss: bool, elite_kind: int = 0) -> void:
	var y := (-170.0 if type==12 else -139.0) if boss else (-103.0 if elite_kind > 0 else -82.0)
	var level_text := "BOSS · LV %d" % enemy_level(type) if boss else ("CHAMPION · LV %d" % enemy_level(type) if elite_kind == 2 else ("ELITE · LV %d" % enemy_level(type) if elite_kind == 1 else "LV %d" % enemy_level(type)))
	var width := 134.0 if elite_kind == 2 else (108.0 if boss or elite_kind == 1 else 54.0)
	var bg := Rect2(p + Vector2(-width * 0.5, y), Vector2(width, 20))
	draw_rect(bg, Color("222b32", 0.92))
	draw_rect(bg, Color("e6b978") if boss or elite_kind == 2 else (Color("d69ae3") if elite_kind == 1 else (Color("d87878") if enemy_level(type) > level + 3 else Color("97be9d"))), false, 2)
	text_at(bg.position + Vector2(2, 15), level_text, 12, Color("fff1d2"), HORIZONTAL_ALIGNMENT_CENTER, int(width - 4))

func draw_enemy_model(type: int, p: Vector2, c: Color, stride: float) -> void:
	match type:
		0: # Schleim: gallertiger Körper mit Kern und Spritzrand.
			PixelStyle32.circle(self,p + Vector2(0, 5), 27, c.darkened(0.32))
			PixelStyle32.circle(self,p + Vector2(0, -6 + stride * 0.12), 23, c)
			PixelStyle32.circle(self,p + Vector2(-7, -15), 7, c.lightened(0.42))
			PixelStyle32.circle(self,p + Vector2(8, -10), 4, c.lightened(0.28))
			PixelStyle32.rect(self,Rect2(p + Vector2(-10, -5), Vector2(5, 8)), INK)
			PixelStyle32.rect(self,Rect2(p + Vector2(6, -5), Vector2(5, 8)), INK)
			PixelStyle32.rect(self,Rect2(p + Vector2(-3, 7), Vector2(8, 5)), Color('ffe5aa'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-18, 14), Vector2(9, 4)), c.lightened(0.18))
			PixelStyle32.rect(self,Rect2(p + Vector2(10, 13), Vector2(8, 4)), c.lightened(0.18))
		1: # Käfer mit Fühlern, sechs Beinen und zwei Flügeldecken.
			for side in [-1.0, 1.0]:
				for leg in 3:
					PixelStyle32.line(self,p + Vector2(side * 12, -12 + leg * 12), p + Vector2(side * 32, -18 + leg * 16 + stride * side), c.darkened(0.38), 4)
				PixelStyle32.line(self,p + Vector2(side * 6, -25), p + Vector2(side * 20, -46), Color('574951'), 3)
				PixelStyle32.circle(self,p + Vector2(side * 11, -6), 17, c.lightened(0.16))
				PixelStyle32.circle(self,p + Vector2(side * 11, -11), 4, Color('fff2d4'))
			PixelStyle32.circle(self,p + Vector2(0, -14), 12, Color('593f55'))
			PixelStyle32.circle(self,p + Vector2(-5, -17), 3, Color('fff1a7'))
			PixelStyle32.circle(self,p + Vector2(5, -17), 3, Color('fff1a7'))
		2: # Pilzling mit Stiel, Hut und Sporenpunkten.
			PixelStyle32.rect(self,Rect2(p + Vector2(-15, -7), Vector2(30, 32)), Color('e5d8b3'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-12, 20), Vector2(10, 10)), Color('9b755e'))
			PixelStyle32.rect(self,Rect2(p + Vector2(3, 20), Vector2(10, 10)), Color('9b755e'))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-33, -9), p + Vector2(-22, -31), p + Vector2(0, -42), p + Vector2(22, -31), p + Vector2(33, -9)]), Color('bd7882'))
			for dot in [Vector2(-15, -21), Vector2(5, -32), Vector2(19, -18)]: PixelStyle32.circle(self,p + dot, 4, Color('fff2d2'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-8, 3), Vector2(4, 5)), INK)
			PixelStyle32.rect(self,Rect2(p + Vector2(5, 3), Vector2(4, 5)), INK)
		3: # Wolf mit Schnauze, Ohren, Schwanz und laufenden Pfoten.
			PixelStyle32.line(self,p + Vector2(-18, 2), p + Vector2(-41, -15 + stride), c.darkened(0.25), 11)
			for side in [-1.0, 1.0]:
				PixelStyle32.rect(self,Rect2(p + Vector2(side * 16 - 5, 12 + stride * side), Vector2(9, 20)), c.darkened(0.27))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-27, -5), p + Vector2(-17, -27), p + Vector2(17, -28), p + Vector2(29, -2), p + Vector2(20, 19), p + Vector2(-20, 19)]), c)
			for side in [-1.0, 1.0]:
				PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(side * 13, -23), p + Vector2(side * 27, -43), p + Vector2(side * 29, -17)]), c.darkened(0.18))
				PixelStyle32.rect(self,Rect2(p + Vector2(side * 9 - 2, -12), Vector2(5, 5)), Color('fff2a5'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-10, 1), Vector2(20, 11)), Color('c1bbaa'))
		4: # Steingolem als klarer Ruinenwächter.
			PixelStyle32.rect(self,Rect2(p + Vector2(-20, 17 + stride * 0.25), Vector2(14, 18)), c.darkened(0.33))
			PixelStyle32.rect(self,Rect2(p + Vector2(7, 17 - stride * 0.25), Vector2(14, 18)), c.darkened(0.33))
			PixelStyle32.rect(self,Rect2(p + Vector2(-24, -26), Vector2(48, 50)), c.darkened(0.16))
			PixelStyle32.rect(self,Rect2(p + Vector2(-16, -44), Vector2(32, 24)), c)
			PixelStyle32.rect(self,Rect2(p + Vector2(-17, -35), Vector2(34, 6)), Color('dcc88f'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-31, -17), Vector2(15, 34)), Color('77726e'))
			PixelStyle32.rect(self,Rect2(p + Vector2(22, -20), Vector2(8, 42)), Color('d6c493'))
			PixelStyle32.line(self,p + Vector2(-6, -12), p + Vector2(6, -1), Color('8c8177'), 4)
			PixelStyle32.rect(self,Rect2(p + Vector2(-10, -23), Vector2(6, 5)), Color('ffe0a1'))
			PixelStyle32.rect(self,Rect2(p + Vector2(4, -23), Vector2(6, 5)), Color('ffe0a1'))
		5: # Beholder-artiger Ruinenwächter mit Stielaugen.
			PixelStyle32.circle(self,p + Vector2(0, 2), 28, c.darkened(0.28))
			PixelStyle32.circle(self,p + Vector2(0, -6), 26, c)
			PixelStyle32.circle(self,p + Vector2(0, -6), 15, Color('efe7cf'))
			PixelStyle32.circle(self,p + Vector2(0, -6), 8, Color('7d8791'))
			PixelStyle32.circle(self,p + Vector2(0, -6), 4, Color('26383c'))
			for angle in [-1.9, -1.15, -0.35, 0.45, 1.2, 1.95]:
				var dir := Vector2.RIGHT.rotated(angle)
				PixelStyle32.line(self,p + dir * 18 + Vector2(0, -6), p + dir * 34 + Vector2(0, -16 + sin(world_time * 4.0 + angle) * 3.0), c.lightened(0.08), 4)
				PixelStyle32.circle(self,p + dir * 38 + Vector2(0, -18 + sin(world_time * 4.0 + angle) * 3.0), 6, Color('e9d9b8'))
				PixelStyle32.circle(self,p + dir * 38 + Vector2(0, -18 + sin(world_time * 4.0 + angle) * 3.0), 2.5, Color('394c5d'))
			PixelStyle32.arc(self,p + Vector2(0, 4), 17, 0.3, PI - 0.3, 12, Color('e9d4a8'), 3)
		6: # Krabbe mit kristallisiertem Panzer und Scheren.
			draw_crab_model(p, c, stride, true)
		7: # Kristallgolem: massiver Körper mit facettierten Schultern und Kern.
			for side in [-1.0, 1.0]:
				PixelStyle32.rect(self,Rect2(p + Vector2(side * 27 - 9, -8 + stride * side * 0.2), Vector2(18, 39)), c.darkened(0.28))
				PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(side * 22, -20), p + Vector2(side * 39, -39), p + Vector2(side * 43, -8), p + Vector2(side * 25, 5)]), Color('d9faff'))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-28, 18), p + Vector2(-24, -28), p + Vector2(0, -44), p + Vector2(25, -28), p + Vector2(29, 18), p + Vector2(0, 34)]), c.darkened(0.12))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(0, -34), p + Vector2(15, -8), p + Vector2(0, 19), p + Vector2(-15, -8)]), Color('bcefff'))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(0, -27), p + Vector2(8, -7), p + Vector2(0, 9), p + Vector2(-8, -7)]), Color('f4ffff'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-12, -24), Vector2(6, 5)), Color('365f78'))
			PixelStyle32.rect(self,Rect2(p + Vector2(6, -24), Vector2(6, 5)), Color('365f78'))
		8: # Schneller Ascheläufer mit glühender Spur und Hörnern.
			for side in [-1.0, 1.0]:
				PixelStyle32.line(self,p + Vector2(side * 9, 11), p + Vector2(side * 19, 32 + stride * side), c.darkened(0.3), 8)
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-22, 13), p + Vector2(-15, -23), p + Vector2(15, -23), p + Vector2(23, 14)]), c.darkened(0.16))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-12, -22), p + Vector2(-20, -43), p + Vector2(-2, -29), p + Vector2(10, -23), p + Vector2(19, -43), p + Vector2(17, -11)]), Color('e8a374'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-8, -18), Vector2(5, 6)), Color('ffe388'))
			PixelStyle32.rect(self,Rect2(p + Vector2(5, -18), Vector2(5, 6)), Color('ffe388'))
			PixelStyle32.line(self,p + Vector2(-22, 15), p + Vector2(-35, 25 + stride), Color('f7ab6a'), 5)
		9: # Lavagolem: weiterentwickelter Glutgolem mit schwerem Basaltkörper und Lavarissen.
			PixelStyle32.rect(self,Rect2(p + Vector2(-31, -31), Vector2(62, 58)), Color('4f3f44'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-24, -45), Vector2(48, 25)), c)
			for side in [-1.0, 1.0]:
				PixelStyle32.rect(self,Rect2(p + Vector2(side * 27 - 10, -11), Vector2(20, 39)), c.darkened(0.25))
				PixelStyle32.rect(self,Rect2(p + Vector2(side * 14 - 5, 23), Vector2(12, 15)), Color('55464b'))
			PixelStyle32.line(self,p + Vector2(-18, -9), p + Vector2(3, 12), Color('f5a76a'), 5)
			PixelStyle32.line(self,p + Vector2(4, 12), p + Vector2(23, -8), Color('f5a76a'), 4)
			PixelStyle32.line(self,p + Vector2(-7, -24), p + Vector2(-2, 12), Color('ffbf74'), 3)
			PixelStyle32.line(self,p + Vector2(8, -24), p + Vector2(13, 8), Color('ffbf74'), 3)
			PixelStyle32.rect(self,Rect2(p + Vector2(-10, -25), Vector2(6, 6)), Color('ffdb78'))
			PixelStyle32.rect(self,Rect2(p + Vector2(4, -25), Vector2(6, 6)), Color('ffdb78'))
		10: # Strandkrabbe mit Sandpanzer.
			draw_crab_model(p, c, stride, false)
		11: # Wassergeist als Tropfen mit Wellenarmen.
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(0, -46), p + Vector2(21, -16), p + Vector2(24, 15), p + Vector2(0, 29), p + Vector2(-24, 15), p + Vector2(-21, -16)]), Color(c, 0.8))
			for side in [-1.0, 1.0]:
				PixelStyle32.arc(self,p + Vector2(side * 24, 0), 12, world_time, world_time + PI, 12, Color('d1f7f0'), 4)
			PixelStyle32.circle(self,p + Vector2(-7, -8), 4, Color.WHITE)
			PixelStyle32.circle(self,p + Vector2(8, -8), 4, Color.WHITE)
			PixelStyle32.line(self,p + Vector2(-11, 12), p + Vector2(12, 12), Color('b6eaf5'), 3)
		15: # Sternenschatten: dunkle Gestalt mit schwebenden Sternsplittern.
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(0, -45), p + Vector2(22, -19), p + Vector2(25, 20), p + Vector2(0, 31), p + Vector2(-26, 20), p + Vector2(-22, -19)]), c.darkened(0.36))
			for side in [-1.0, 1.0]:
				PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(side * 30, -35 + stride), p + Vector2(side * 39, -19 + stride), p + Vector2(side * 27, -16 + stride)]), Color('e8d1ec'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-11, -19), Vector2(7, 5)), Color('fff1c3'))
			PixelStyle32.rect(self,Rect2(p + Vector2(5, -19), Vector2(7, 5)), Color('fff1c3'))
		16: # Bruchwächter: Steinrüstung mit glühendem Kern.
			PixelStyle32.rect(self,Rect2(p + Vector2(-27, -35), Vector2(54, 66)), c.darkened(0.48))
			for side in [-1.0, 1.0]:
				PixelStyle32.rect(self,Rect2(p + Vector2(side * 30 - 8, -14), Vector2(17, 36)), c)
				PixelStyle32.rect(self,Rect2(p + Vector2(side * 13 - 6, 28 + stride * side * 0.3), Vector2(13, 14)), Color('605e75'))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(0, -23), p + Vector2(13, -2), p + Vector2(0, 17), p + Vector2(-13, -2)]), Color('f9c49c'))
			PixelStyle32.rect(self,Rect2(p + Vector2(-17, -40), Vector2(34, 12)), Color('a094a3'))
		17: # Nebelhirsch: langer Hals, vier Läufe und verzweigte Geweihkrone.
			for side in [-1.0,1.0]:
				PixelStyle32.line(self,p+Vector2(side*12,4),p+Vector2(side*15,30+stride*side),c.darkened(0.38),7)
				PixelStyle32.line(self,p+Vector2(side*5,-20),p+Vector2(side*14,-43),c.lightened(0.12),10)
				PixelStyle32.line(self,p+Vector2(side*11,-39),p+Vector2(side*20,-53),Color('dfd4bd'),4)
				PixelStyle32.line(self,p+Vector2(side*17,-48),p+Vector2(side*22,-61),Color('e8dec9'),3)
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-26,10),p+Vector2(-23,-8),p+Vector2(-12,-20),p+Vector2(12,-20),p+Vector2(26,-5),p+Vector2(20,17),p+Vector2(-17,18)]),c.darkened(0.2))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-14,-17),p+Vector2(1,-28),p+Vector2(17,-18),p+Vector2(9,-2),p+Vector2(-10,-2)]),c.lightened(0.15))
			PixelStyle32.rect(self,Rect2(p+Vector2(4,-22),Vector2(5,4)),Color('fff0bf'))
		18: # Irrlicht: leuchtender Kern in drei flatternden Schleiern.
			for side in [-1.0,1.0]:
				PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(0,-20),p+Vector2(side*28,-34+stride),p+Vector2(side*21,-4),p+Vector2(side*34,15+stride),p+Vector2(0,24)]),Color(c.lightened(0.15),0.72))
				PixelStyle32.line(self,p+Vector2(side*9,12),p+Vector2(side*20,31+stride),Color(c.lightened(0.28),0.82),5)
			PixelStyle32.circle(self,p+Vector2(0,-9),19,c.darkened(0.18))
			PixelStyle32.circle(self,p+Vector2(0,-11),14,c.lightened(0.2))
			PixelStyle32.circle(self,p+Vector2(0,-11),8,Color('f4ffff'))
			PixelStyle32.circle(self,p+Vector2(0,-11),4,Color('70a9b1'))
		19: # Harzbestie: gepanzerter Waldkäfer mit bernsteinfarbenem Rücken.
			for side in [-1.0,1.0]:
				for leg in 3: PixelStyle32.line(self,p+Vector2(side*13,-5+leg*9),p+Vector2(side*(29+leg*2),4+leg*10+stride*side),c.darkened(0.37),5)
				PixelStyle32.line(self,p+Vector2(side*8,-17),p+Vector2(side*19,-34),c.darkened(0.24),5)
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-22,9),p+Vector2(-20,-14),p+Vector2(-11,-27),p+Vector2(11,-27),p+Vector2(22,-13),p+Vector2(20,11),p+Vector2(0,21)]),c.darkened(0.32))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-16,-13),p+Vector2(-9,-29),p+Vector2(8,-31),p+Vector2(18,-13),p+Vector2(11,5),p+Vector2(-11,5)]),c)
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-9,-17),p+Vector2(-5,-26),p+Vector2(1,-27),p+Vector2(5,-12),p+Vector2(0,-4)]),Color('f0d17c'))
			PixelStyle32.line(self,p+Vector2(-14,-11),p+Vector2(12,-10),Color('fff0b0'),3)
			PixelStyle32.rect(self,Rect2(p+Vector2(-9,2),Vector2(5,4)),Color('ffe7a0')); PixelStyle32.rect(self,Rect2(p+Vector2(6,2),Vector2(5,4)),Color('ffe7a0'))
		20: # Wurzelhexe: knorrige Wurzelrobe, Blattkapuze und Runenstab.
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-29,25),p+Vector2(-20,-19),p+Vector2(-12,-36),p+Vector2(13,-36),p+Vector2(23,-16),p+Vector2(30,25),p+Vector2(15,18),p+Vector2(5,29),p+Vector2(-7,18),p+Vector2(-20,28)]),Color('515c43'))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-22,-22),p+Vector2(-16,-43),p+Vector2(0,-54),p+Vector2(17,-43),p+Vector2(23,-22)]),c.darkened(0.18))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-15,-22),p+Vector2(0,-43),p+Vector2(15,-22)]),c.lightened(0.13))
			PixelStyle32.rect(self,Rect2(p+Vector2(-11,-19),Vector2(7,6)),Color('dff1b1')); PixelStyle32.rect(self,Rect2(p+Vector2(5,-19),Vector2(7,6)),Color('dff1b1'))
			PixelStyle32.line(self,p+Vector2(26,20),p+Vector2(36,-41),Color('674c37'),7); PixelStyle32.line(self,p+Vector2(30,-33),p+Vector2(43,-47),Color('b0a16b'),4)
			PixelStyle32.circle(self,p+Vector2(37,-46),5,Color('b7e38c'))
		21: # Quellkriecher: breiter Amphibienkörper, Sprungbeine und Wasserdrüsen.
			for side in [-1.0,1.0]:
				PixelStyle32.line(self,p+Vector2(side*13,3),p+Vector2(side*30,18+stride*side),c.darkened(0.28),9)
				PixelStyle32.line(self,p+Vector2(side*25,17+stride*side),p+Vector2(side*33,29+stride*side),c,5)
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-27,-5),p+Vector2(-22,-21),p+Vector2(-12,-29),p+Vector2(9,-29),p+Vector2(23,-19),p+Vector2(28,-4),p+Vector2(20,13),p+Vector2(0,20),p+Vector2(-20,13)]),c.darkened(0.24))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-24,-6),p+Vector2(-18,-21),p+Vector2(-9,-25),p+Vector2(8,-25),p+Vector2(20,-17),p+Vector2(24,-4),p+Vector2(17,10),p+Vector2(0,16),p+Vector2(-18,10)]),c)
			for side in [-1.0,1.0]:
				PixelStyle32.circle(self,p+Vector2(side*13,-25),8,c.lightened(0.2)); PixelStyle32.circle(self,p+Vector2(side*13,-26),3,Color('f6efc6'))
			PixelStyle32.line(self,p+Vector2(-15,-6),p+Vector2(14,-5),Color('c7f2df'),3)
		22: # Perlengeist: schwebende Muschelschichten um eine helle Perle.
			PixelStyle32.arc(self,p+Vector2(0,2),27,0.1,PI-0.1,24,c.darkened(0.25),8)
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-27,-1),p+Vector2(-21,-24),p+Vector2(-9,-36),p+Vector2(0,-27),p+Vector2(9,-36),p+Vector2(22,-22),p+Vector2(28,-1),p+Vector2(16,20),p+Vector2(0,28),p+Vector2(-17,20)]),Color(c,0.83))
			for side in [-1.0,1.0]:
				PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(0,-5),p+Vector2(side*21,-19),p+Vector2(side*17,9)]),c.lightened(0.3))
			PixelStyle32.circle(self,p+Vector2(0,-4),10,Color('d3eff0')); PixelStyle32.circle(self,p+Vector2(-3,-7),4,Color('fffef2'))
		23: # Gratgreif: gefiederte Flügel, Hakenschnabel und kräftige Läufe.
			for side in [-1.0,1.0]:
				PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(side*9,-21),p+Vector2(side*38,-44+stride),p+Vector2(side*34,-11),p+Vector2(side*23,4),p+Vector2(side*13,1)]),c.darkened(0.16))
				for feather in range(3): PixelStyle32.line(self,p+Vector2(side*(17+feather*5),-25-feather*3),p+Vector2(side*(38-feather*3),-37+feather*9+stride),Color('d8d2df'),4)
				PixelStyle32.line(self,p+Vector2(side*12,10),p+Vector2(side*15,30+stride*side),c.darkened(0.38),7)
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-17,13),p+Vector2(-24,-7),p+Vector2(-12,-30),p+Vector2(12,-29),p+Vector2(24,-7),p+Vector2(18,14)]),c)
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-9,-23),p+Vector2(1,-39),p+Vector2(15,-25),p+Vector2(8,-8)]),Color('d6c4a0'))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(15,-20),p+Vector2(34,-12),p+Vector2(16,-8)]),Color('e9c36f'))
		24: # Schattenritter: geschlossene Plattenrüstung, Visier, Schild und Runenklinge.
			for side in [-1.0,1.0]: PixelStyle32.rect(self,Rect2(p+Vector2(side*14-7,18+stride*side*0.3),Vector2(14,20)),Color('393c4f'))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-25,16),p+Vector2(-22,-22),p+Vector2(0,-35),p+Vector2(23,-22),p+Vector2(25,16),p+Vector2(0,28)]),c.darkened(0.28))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-17,-22),p+Vector2(0,-37),p+Vector2(17,-22),p+Vector2(13,-2),p+Vector2(-13,-2)]),Color('5c5b75'))
			PixelStyle32.rect(self,Rect2(p+Vector2(-12,-20),Vector2(24,6)),Color('292b3b')); PixelStyle32.rect(self,Rect2(p+Vector2(-8,-19),Vector2(6,3)),Color('c5b8ff')); PixelStyle32.rect(self,Rect2(p+Vector2(3,-19),Vector2(6,3)),Color('c5b8ff'))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-25,-9),p+Vector2(-40,-17),p+Vector2(-38,18),p+Vector2(-22,22)]),Color('77748f'))
			PixelStyle32.line(self,p+Vector2(30,17),p+Vector2(44,-42),Color('d9e0e8'),7); PixelStyle32.line(self,p+Vector2(31,4),p+Vector2(42,0),Color('c7b4ed'),3)
		25: # Himmelsfalter: vier geschichtete Flügel mit Augenzeichnung und Körperpelz.
			for side in [-1.0,1.0]:
				PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(side*3,-13),p+Vector2(side*31,-42+stride),p+Vector2(side*35,-8),p+Vector2(side*15,3)]),c.darkened(0.15))
				PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(side*4,0),p+Vector2(side*30,5),p+Vector2(side*24,27),p+Vector2(side*7,16)]),c.lightened(0.16))
				PixelStyle32.circle(self,p+Vector2(side*21,-19),6,Color('75618d')); PixelStyle32.circle(self,p+Vector2(side*21,-19),3,Color('f5e7bf'))
				PixelStyle32.line(self,p+Vector2(side*4,-24),p+Vector2(side*13,-43),Color('d7c6e3'),3)
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-7,-20),p+Vector2(0,-29),p+Vector2(7,-20),p+Vector2(6,19),p+Vector2(0,27),p+Vector2(-6,19)]),Color('5a4c6d'))
			PixelStyle32.line(self,p+Vector2(-3,-21),p+Vector2(-13,-37),Color('b8a1d4'),2); PixelStyle32.line(self,p+Vector2(3,-21),p+Vector2(13,-37),Color('b8a1d4'),2)
		26: # Sternenwächterin: Elfenbeinrüstung, goldene Krone und leuchtender Sternkern.
			for side in [-1.0,1.0]:
				PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(side*18,-24),p+Vector2(side*35,-37),p+Vector2(side*39,-1),p+Vector2(side*23,10)]),Color('b6a97e'))
				PixelStyle32.rect(self,Rect2(p+Vector2(side*14-6,17+stride*side*0.25),Vector2(12,19)),Color('75674e'))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-28,17),p+Vector2(-23,-26),p+Vector2(-11,-36),p+Vector2(11,-36),p+Vector2(23,-26),p+Vector2(28,17),p+Vector2(0,29)]),c.darkened(0.18))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-17,-19),p+Vector2(0,-31),p+Vector2(17,-19),p+Vector2(14,8),p+Vector2(0,20),p+Vector2(-14,8)]),Color('f1e8c5'))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(0,-15),p+Vector2(6,-4),p+Vector2(0,8),p+Vector2(-6,-4)]),Color('ffd777'))
			PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(-13,-35),p+Vector2(-15,-50),p+Vector2(-3,-41),p+Vector2(0,-58),p+Vector2(5,-41),p+Vector2(17,-50),p+Vector2(13,-35)]),Color('c7a762'))
		_:
			if type in [17, 19, 21, 23, 25]:
				for side in [-1.0, 1.0]:
					PixelStyle32.line(self,p + Vector2(side * 13, 14), p + Vector2(side * 23, 29 + stride * side), c.darkened(0.4), 7)
					PixelStyle32.line(self,p + Vector2(side * 16, -26), p + Vector2(side * 30, -49), c.lightened(0.15), 5)
				PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-27,4),p + Vector2(-20,-27),p + Vector2(0,-38),p + Vector2(22,-26),p + Vector2(28,6),p + Vector2(0,25)]), c)
			else:
				PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-23,18),p + Vector2(-26,-13),p + Vector2(-9,-36),p + Vector2(11,-36),p + Vector2(27,-13),p + Vector2(22,24),p + Vector2(0,13)]), Color(c,0.87))
				for side in [-1.0, 1.0]:
					PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(side * 25,-14),p + Vector2(side * 38,-22 + stride),p + Vector2(side * 31,8)]), c.lightened(0.25))
			for side in [-1.0, 1.0]: PixelStyle32.circle(self,p + Vector2(side * 9,-13), 4, Color('fff4d0'))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(0,-35),p + Vector2(6,-25),p + Vector2(0,-16),p + Vector2(-6,-25)]), c.lightened(0.5))

func draw_crab_model(p: Vector2, c: Color, stride: float, crystal: bool) -> void:
	for side in [-1.0, 1.0]:
		for leg in 3:
			PixelStyle32.line(self,p + Vector2(side * 17, -8 + leg * 10), p + Vector2(side * (30 + leg * 5), 6 + leg * 9 + stride * side), c.darkened(0.26), 5)
		PixelStyle32.line(self,p + Vector2(side * 22, -14), p + Vector2(side * 38, -27), c.darkened(0.22), 7)
		PixelStyle32.circle(self,p + Vector2(side * 39, -28), 10, c.lightened(0.12))
	PixelStyle32.circle(self,p, 23, c.darkened(0.28))
	PixelStyle32.circle(self,p + Vector2(0, -5), 20, c)
	if crystal:
		PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-15, -12), p + Vector2(0, -33), p + Vector2(16, -11), p + Vector2(0, 6)]), Color("d2f7ff"))
	else:
		PixelStyle32.rect(self,Rect2(p + Vector2(-14, -16), Vector2(28, 6)), Color("f7d5a1"))
	PixelStyle32.rect(self,Rect2(p + Vector2(-10, -9), Vector2(5, 5)), INK)
	PixelStyle32.rect(self,Rect2(p + Vector2(6, -9), Vector2(5, 5)), INK)

func draw_boss_model(type: int, p: Vector2, c: Color, stride: float) -> void:
	var aura := Color("e9c592") if type == 12 else (Color("a9eefa") if type == 13 else Color("f4a16f"))
	PixelStyle32.arc(self,p, 58, 0, TAU, 32, Color(aura, 0.6), 5)
	match type:
		12: # Turmwächter: Ritter mit Helm, Schild und Zweihänder.
			for side in [-1.0, 1.0]:
				PixelStyle32.rect(self,Rect2(p + Vector2(side * 20 - 10, 20 + stride * side * 0.3), Vector2(20, 21)), Color("59666a"))
			PixelStyle32.rect(self,Rect2(p + Vector2(-35, -39), Vector2(70, 64)), c.darkened(0.25))
			PixelStyle32.rect(self,Rect2(p + Vector2(-24, -37), Vector2(48, 54)), c)
			PixelStyle32.rect(self,Rect2(p + Vector2(-23, -65), Vector2(46, 31)), Color("89989b"))
			PixelStyle32.rect(self,Rect2(p + Vector2(-28, -70), Vector2(56, 12)), Color("dbc98f"))
			PixelStyle32.rect(self,Rect2(p + Vector2(-19, -49), Vector2(38, 7)), Color("233b43"))
			PixelStyle32.rect(self,Rect2(p + Vector2(-10, -48), Vector2(21, 5)), aura)
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-49, -35), p + Vector2(-26, -42), p + Vector2(-20, 12), p + Vector2(-43, 27)]), Color("6d8182"))
			PixelStyle32.line(self,p + Vector2(42, 18), p + Vector2(59, -84), Color("eef0df"), 11)
			PixelStyle32.line(self,p + Vector2(30, -7), p + Vector2(59, -4), Color("eac77b"), 8)
		13: # Kristallhüter: großer facettierter Körper mit schwebenden Splittern.
			for side in [-1.0, 1.0]:
				var shard := p + Vector2(side * 55, -35 + stride * side)
				PixelStyle32.polygon(self,PackedVector2Array([shard + Vector2(0, -33), shard + Vector2(20, 0), shard + Vector2(0, 33), shard + Vector2(-20, 0)]), Color("d9faff"))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(0, -81), p + Vector2(38, -37), p + Vector2(43, 13), p + Vector2(0, 39), p + Vector2(-43, 13), p + Vector2(-38, -37)]), c)
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(0, -69), p + Vector2(22, -21), p + Vector2(0, 23), p + Vector2(-22, -21)]), Color("d5faff"))
			PixelStyle32.rect(self,Rect2(p + Vector2(-22, -36), Vector2(9, 8)), Color("365f78"))
			PixelStyle32.rect(self,Rect2(p + Vector2(13, -36), Vector2(9, 8)), Color("365f78"))
		14: # Aschefürst: hornbewehrte Rüstung, Feuerkrone und Lavaadern.
			for side in [-1.0, 1.0]:
				PixelStyle32.rect(self,Rect2(p + Vector2(side * 19 - 10, 13 + stride * side * 0.2), Vector2(20, 30)), Color("564047"))
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-43, 23), p + Vector2(-34, -42), p + Vector2(0, -60), p + Vector2(34, -42), p + Vector2(43, 23)]), Color("6c4449"))
			PixelStyle32.rect(self,Rect2(p + Vector2(-27, -33), Vector2(54, 51)), c)
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(-27, -55), p + Vector2(-38, -88), p + Vector2(-10, -67), p + Vector2(10, -67), p + Vector2(38, -88), p + Vector2(27, -55)]), Color("e2a074"))
			PixelStyle32.rect(self,Rect2(p + Vector2(-16, -51), Vector2(32, 8)), Color("2f333d"))
			PixelStyle32.rect(self,Rect2(p + Vector2(-13, -50), Vector2(9, 6)), Color("ffdc82"))
			PixelStyle32.rect(self,Rect2(p + Vector2(6, -50), Vector2(9, 6)), Color("ffdc82"))
			PixelStyle32.line(self,p + Vector2(-20, -10), p + Vector2(7, 21), Color("ffc06e"), 6)
			PixelStyle32.line(self,p + Vector2(7, 21), p + Vector2(23, -8), Color("ffc06e"), 5)

func draw_shadow(p: Vector2) -> void:
	for band in 3:
		var width := 42.0 - band * 8.0
		draw_rect(Rect2(p + Vector2(-width * 0.5, 23 + band), Vector2(width, 2)), Color(0.12, 0.20, 0.19, 0.10 - band * 0.018))

func draw_player() -> void:
	draw_shadow(player_pos)
	if invulnerable > 0: draw_arc(player_pos+Vector2(0,12),31,0,TAU,16,Color("b7e5ee",0.35),2)
	if ranger_stealth_timer > 0 and class_id == 2:
		draw_arc(player_pos+Vector2(0,10),34,0,TAU,24,Color("d8f3ff",0.28),4)
	if dash_timer > 0 and class_id == 1 and arcane_step_learned:
		var progress := 1.0-dash_timer/dodge_duration
		draw_line(dodge_start+Vector2(0,10),player_pos+Vector2(0,10),Color("a491e4",0.3),18)
		for ring in 2:
			draw_arc(player_pos+Vector2(0,10),25+ring*13,progress*TAU+ring*PI,progress*TAU+ring*PI+PI,16,Color("d9caff",0.8),3)
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
	if in_world and (death_timer > 0 or (dash_timer > 0 and class_id != 1)): return
	# Arm, Hand und Waffe folgen während des Angriffs derselben Bewegung.
	var design := equipped_weapon_design() if preview_class < 0 else visual_class * 4
	var weapon_family := visual_class
	var weapon_pos := p + Vector2(0, -5.0 * scale_factor)
	var raw_look: Vector2 = look.normalized() if look.length() > 0.01 else Vector2.DOWN
	var direction_index := cardinal_direction_index(raw_look)
	var base_look: Vector2 = [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP][direction_index]
	var progress := clampf(1.0 - swing_timer / maxf(0.01, swing_duration), 0.0, 1.0) if attack_now else -1.0
	var weapon_look := weapon_attack_look(base_look, weapon_family, design, progress)
	if attack_now and weapon_family == 0:
		weapon_pos += base_look * (5.0 + 6.0 * sin(progress * PI)) * scale_factor
	elif attack_now and weapon_family == 1:
		weapon_pos += Vector2(0, -7.0 * sin(progress * PI)) * scale_factor
	# Feste Waffenhand: Schulter und Griff bleiben während des gesamten Schlages
	# auf derselben Körperseite. Nur Unterarm und Waffe schwingen.
	var hand_side := base_look.rotated(-PI * 0.5)
	var hand_offset := weapon_hand_offset(base_look)
	var arm_start := p + Vector2(signf(hand_offset.x)*18.0,-5.0)*scale_factor
	var grip := weapon_pos + (hand_offset + weapon_look*3.0)*scale_factor
	var side := weapon_look.rotated(PI * 0.5)
	var arm_color: Color = [Color('6d8292'), Color('695b91'), Color('65775b')][clampi(visual_class, 0, 2)]
	var cuff_color: Color = [Color('c0c8c4'), Color('d4c1e8'), Color('ae9b70')][clampi(visual_class, 0, 2)]
	draw_line(arm_start, grip, Color('493d45'), 10.0 * scale_factor)
	draw_line(arm_start, grip, arm_color, 7.0 * scale_factor)
	draw_circle(arm_start, 5.5 * scale_factor, Color('493d45'))
	draw_circle(arm_start, 3.8 * scale_factor, arm_color.lightened(0.06))
	draw_line(arm_start.lerp(grip, 0.72) - side * 1.5 * scale_factor, grip, cuff_color, 4.0 * scale_factor)
	draw_weapon_world(weapon_pos, weapon_family, design, base_look, scale_factor, progress)
	if weapon_family == 2:
		var hand_color: Color = [Color('e7b995'),Color('91a56d'),Color('a0bbc0')][clampi(use_race,0,2)]
		draw_circle(grip,4.3*scale_factor,Color('493d45'))
		draw_circle(grip,2.8*scale_factor,hand_color)
	# Facing north: the body masks the rear arm and weapon across the head.
	if base_look == Vector2.UP:
		draw_character_sprite(p,visual_class,walking,look,scale_factor,attack_now,use_race,use_gender)


func weapon_attack_look(look: Vector2, family: int, design: int, progress: float) -> Vector2:
	if progress < 0.0: return look.normalized()
	var t := clampf(progress, 0.0, 1.0)
	var eased := t * t * (3.0 - 2.0 * t)
	if family == 0:
		var is_axe := design % 3 == 2
		var sweep := lerpf(-0.95, 0.82, eased) if is_axe else lerpf(-0.64, 0.72, eased)
		return look.rotated(sweep).normalized()
	if family == 1:
		return look.rotated(lerpf(-0.30, 0.34, eased)).normalized()
	if design % 4 == 3:
		return look.rotated(lerpf(-0.16, 0.10, eased)).normalized()
	return look.rotated(-0.08 * sin(t * PI)).normalized()

func weapon_hand_offset(look: Vector2) -> Vector2:
	return Vector2(-22,6) if look.x < -0.5 or look.y < -0.5 else Vector2(22,6)

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
	if item.get("icon") == "food": return maxi(0,FoodSystem.index_for(str(item.get("name",""))))
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
	if kind=="head":
		PixelStyle32.rect(self,Rect2(p+Vector2(3,22)*s,Vector2(28,6)*s),accent)
		PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(7,22)*s,p+Vector2(16,2)*s,p+Vector2(25,22)*s]),[Color("718d9b"),Color("796292"),Color("658956")][clampi(design,0,2)])
		return
	if kind in ["armor","essence"]:
		ItemStyle32.paint(self,origin,kind,accent,scale_factor,design)
		return
	if kind == "food":
		FoodSystem.icon(self,origin,design,scale_factor)
		return
	match kind:
		"sword":
			# Breite, abgeschrägte Klinge, Parierstange und Griff im Pixel-Art-Profil.
			var tip := p + Vector2(30 + (3 if design == 1 else 0), 1 + (4 if design == 1 else 0)) * s
			var base := p + Vector2(13, 19) * s
			var width := float(3 + mini(stage, 3) + (3 if design == 2 else 0))
			PixelStyle32.polygon(self,PackedVector2Array([base + Vector2(-width, -width) * s, p + Vector2(24, 3) * s, tip, p + Vector2(29, 9) * s, base + Vector2(width, width) * s]), Color("30283d"))
			PixelStyle32.polygon(self,PackedVector2Array([base + Vector2(-2, -2) * s, p + Vector2(25, 4) * s, tip - Vector2(2, 0) * s, base + Vector2(3, 2) * s]), accent if stage >= 3 else Color("cedee9"))
			if design == 1: PixelStyle32.polygon(self,PackedVector2Array([tip, p + Vector2(20, 4) * s, p + Vector2(18, 12) * s, p + Vector2(27, 9) * s]), accent)
			elif design == 2:
				PixelStyle32.polygon(self,PackedVector2Array([base, p + Vector2(18, 5) * s, p + Vector2(29, 1) * s, p + Vector2(26, 12) * s]), accent)
			elif design == 3:
				PixelStyle32.line(self,p + Vector2(20, 6) * s, tip, Color("314452"), 3 * s)
				PixelStyle32.rect(self,Rect2(p + Vector2(24, 1) * s, Vector2(3, 4) * s), Color("314452"))
			PixelStyle32.line(self,base + Vector2(1, -1) * s, p + Vector2(27, 5) * s, Color("f5f8f0"), 2 * s)
			PixelStyle32.line(self,p + Vector2(7, 16) * s, p + Vector2(17, 26) * s, Color("352a42"), 5 * s)
			PixelStyle32.line(self,p + Vector2(7, 16) * s, p + Vector2(17, 26) * s, Color("dcb45e") if stage >= 1 else Color("aa8559"), 3 * s)
			PixelStyle32.line(self,p + Vector2(3, 28) * s, base, Color("342b3e"), 6 * s)
			PixelStyle32.line(self,p + Vector2(3, 28) * s, base, Color("694857"), 3 * s)
			PixelStyle32.circle(self,p + Vector2(3, 28) * s, 3 * s, Color("d2a253"))
			if stage >= 2:
				PixelStyle32.circle(self,base, 2.5 * s, accent)
			if design == 1: PixelStyle32.line(self,p + Vector2(5, 17) * s, p + Vector2(18, 25) * s, Color("e6c37a"), 3 * s)
			elif design == 2:
				PixelStyle32.line(self,p + Vector2(8, 13) * s, p + Vector2(22, 23) * s, Color("b9a8a1"), 4 * s)
			elif design == 3: PixelStyle32.circle(self,base, 4 * s, accent)
			if stage >= 4:
				PixelStyle32.line(self,p + Vector2(15, 11) * s, p + Vector2(25, 2) * s, Color("ffe89b"), 2 * s)
		"staff":
			PixelStyle32.line(self,p + Vector2(8, 32) * s, p + Vector2(20, 8) * s, Color("352b41"), 7 * s)
			PixelStyle32.line(self,p + Vector2(8, 32) * s, p + Vector2(20, 8) * s, Color("8d6048") if stage < 2 else Color("bca47a"), 4 * s)
			PixelStyle32.line(self,p + Vector2(11, 27) * s, p + Vector2(16, 17) * s, Color("efcf83"), 2 * s)
			if stage >= 1:
				PixelStyle32.line(self,p + Vector2(13, 15) * s, p + Vector2(27, 13) * s, Color("d9bb78"), 3 * s)
			if design == 1:
				PixelStyle32.arc(self,p + Vector2(20, 7) * s, 9 * s, -PI * 0.8, PI * 0.55, 12, Color("e4c98b"), 4 * s)
			elif design == 2:
				for branch in [-1.0, 1.0]: PixelStyle32.line(self,p + Vector2(18, 15) * s, p + Vector2(20 + branch * 12, 2) * s, Color("ad815e"), 3 * s)
			elif design == 3:
				for prong in [-1.0, 0.0, 1.0]: PixelStyle32.line(self,p + Vector2(20 + prong * 8, 12) * s, p + Vector2(20 + prong * 8, 0) * s, Color("aebec2"), 3 * s)
			if stage >= 3 and design == 0:
				PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(19, 8) * s, p + Vector2(11, 1) * s, p + Vector2(10, 11) * s]), Color("e8ce8a"))
				PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(21, 8) * s, p + Vector2(29, 1) * s, p + Vector2(29, 11) * s]), Color("e8ce8a"))
			PixelStyle32.circle(self,p + Vector2(20, 7) * s, (4 + mini(stage, 4)) * s, Color("302841"))
			PixelStyle32.circle(self,p + Vector2(20, 7) * s, (3 + mini(stage, 4)) * s, accent)
			PixelStyle32.circle(self,p + Vector2(18, 5) * s, 2 * s, Color("f7f6df"))
			if stage >= 4:
				PixelStyle32.circle(self,p + Vector2(27, 20) * s, 2 * s, accent)
				PixelStyle32.circle(self,p + Vector2(9, 12) * s, 2 * s, accent)
		"bow":
			if design == 3:
				PixelStyle32.line(self,p + Vector2(5, 17) * s, p + Vector2(29, 17) * s, Color("8d674a"), 5 * s)
				PixelStyle32.line(self,p + Vector2(5, 17) * s, p + Vector2(29, 17) * s, accent, 3 * s)
				PixelStyle32.line(self,p + Vector2(17, 5) * s, p + Vector2(17, 29) * s, Color("efe7d0"), 2 * s)
				for horn in [-1.0,1.0]: PixelStyle32.line(self,p+Vector2(10,17+horn*8)*s,p+Vector2(4,17+horn*12)*s,Color("e9d5b4"),3*s)
				PixelStyle32.rect(self,Rect2(p+Vector2(13,13)*s,Vector2(9,9)*s),accent)
				PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(31,17) * s, p + Vector2(25,14) * s, p + Vector2(25,20) * s]), Color("f6eedc"))
			else:
				PixelStyle32.arc(self,p + Vector2(17, 17) * s, (14 + design * 1.5) * s, -PI * 0.62, PI * 0.62, 18, Color("aa764e") if design != 2 else Color("849b88"), 5 * s)
				if design == 1: PixelStyle32.arc(self,p + Vector2(21,17) * s, 10 * s, -PI * 0.7, PI * 0.7, 16, Color("ead1a1"), 2 * s)
				elif design == 2:
					for horn in [-1.0,1.0]: PixelStyle32.line(self,p+Vector2(14,17+horn*14)*s,p+Vector2(8,17+horn*17)*s,Color("e9d5b4"),3*s)
				PixelStyle32.line(self,p + Vector2(12, 4) * s, p + Vector2(12, 30) * s, Color("efe7d0"), 2 * s)
				PixelStyle32.line(self,p + Vector2(4, 17) * s, p + Vector2(28, 17) * s, accent, 3 * s)
				PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(30,17) * s, p + Vector2(23,13) * s, p + Vector2(23,21) * s]), Color("f6eedc"))
		"potion":
			PixelStyle32.rect(self,Rect2(p + Vector2(10, 1) * s, Vector2(12, 7) * s), Color("dac7a6"))
			PixelStyle32.rect(self,Rect2(p + Vector2(5, 9) * s, Vector2(23, 23) * s), Color("f2e8da"))
			PixelStyle32.rect(self,Rect2(p + Vector2(8, 17) * s, Vector2(17, 12) * s), accent)
			PixelStyle32.rect(self,Rect2(p + Vector2(12, 11) * s, Vector2(4, 4) * s), Color.WHITE)
		"gem":
			PixelStyle32.polygon(self,PackedVector2Array([p + Vector2(15, 1) * s, p + Vector2(30, 15) * s, p + Vector2(15, 32) * s, p + Vector2(1, 15) * s]), accent)
			PixelStyle32.rect(self,Rect2(p + Vector2(12, 7) * s, Vector2(5, 10) * s), Color("eefaf2"))
		"ring":
			PixelStyle32.arc(self,p + Vector2(16, 21) * s, 10 * s, 0, TAU, 16, Color("e6bd75"), 6 * s)
			PixelStyle32.rect(self,Rect2(p + Vector2(11, 4) * s, Vector2(10, 9) * s), accent)
		"armor":
			match class_id:
				0:
					PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(5,3)*s,p+Vector2(13,8)*s,p+Vector2(20,8)*s,p+Vector2(28,3)*s,p+Vector2(28,27)*s,p+Vector2(16,33)*s,p+Vector2(4,27)*s]),Color("8fa6b0"))
					if design == 1: PixelStyle32.rect(self,Rect2(p+Vector2(1,6)*s,Vector2(31,5)*s),Color("c5d0c7"))
					elif design == 2: PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(8,8)*s,p+Vector2(16,1)*s,p+Vector2(24,8)*s]),Color("ecd099"))
					elif design == 3:
						for rib in [10,16,22]: PixelStyle32.line(self,p+Vector2(rib,10)*s,p+Vector2(rib,26)*s,Color("5e7d8e"),2*s)
					PixelStyle32.rect(self,Rect2(p+Vector2(8,10)*s,Vector2(17,15)*s),accent)
					PixelStyle32.line(self,p+Vector2(9,13)*s,p+Vector2(22,24)*s,Color("f4e2ba"),2*s)
				1:
					PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(10,3)*s,p+Vector2(22,3)*s,p+Vector2(29,31)*s,p+Vector2(16,26)*s,p+Vector2(3,31)*s]),Color("3e5a91"))
					if design == 1: PixelStyle32.rect(self,Rect2(p+Vector2(2,4)*s,Vector2(27,4)*s),Color("e0d5af"))
					elif design == 2: PixelStyle32.line(self,p+Vector2(16,5)*s,p+Vector2(16,28)*s,Color("edc998"),3*s)
					elif design == 3: PixelStyle32.arc(self,p+Vector2(16,16)*s,8*s,0,TAU,12,Color("c0b0e2"),3*s)
					PixelStyle32.rect(self,Rect2(p+Vector2(5,7)*s,Vector2(6,15)*s),accent)
					PixelStyle32.rect(self,Rect2(p+Vector2(22,7)*s,Vector2(6,15)*s),accent)
					PixelStyle32.circle(self,p+Vector2(16,14)*s,3*s,Color("9ee6ee"))
				2:
					PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(7,3)*s,p+Vector2(25,3)*s,p+Vector2(28,27)*s,p+Vector2(16,33)*s,p+Vector2(4,27)*s]),Color("587d5e"))
					if design == 1: PixelStyle32.polygon(self,PackedVector2Array([p+Vector2(6,4)*s,p+Vector2(0,20)*s,p+Vector2(10,24)*s]),Color("d5bd80"))
					elif design == 2: PixelStyle32.rect(self,Rect2(p+Vector2(4,11)*s,Vector2(24,5)*s),Color("ab8e61"))
					elif design == 3: PixelStyle32.line(self,p+Vector2(4,20)*s,p+Vector2(28,7)*s,Color("e0c188"),4*s)
					PixelStyle32.line(self,p+Vector2(7,8)*s,p+Vector2(24,26)*s,Color("d4b77b"),4*s)
					PixelStyle32.rect(self,Rect2(p+Vector2(8,20)*s,Vector2(17,4)*s),Color("735646"))
			if stage >= 2:
				PixelStyle32.circle(self,p+Vector2(16,18)*s,2*s,accent.lightened(0.4))
		"herb":
			PixelStyle32.line(self,p + Vector2(16, 31) * s, p + Vector2(16, 4) * s, Color("597e5b"), 4 * s)
			PixelStyle32.rect(self,Rect2(p + Vector2(4, 8) * s, Vector2(12, 9) * s), accent)
			PixelStyle32.rect(self,Rect2(p + Vector2(16, 14) * s, Vector2(13, 8) * s), accent.lightened(0.2))
		_:
			PixelStyle32.rect(self,Rect2(p + Vector2(5, 5) * s, Vector2(22, 22) * s), accent)

func text_at(p: Vector2, value: String, size: int = 17, color: Color = FONT_COLOR, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: int = -1) -> void:
	draw_string(font, p, value, alignment, width, size, color)

func bar(rect: Rect2, value: float, maximum: float, foreground: Color, label: String) -> void:
	draw_rect(rect, Color("19252f"))
	draw_rect(rect.grow(-2), Color("394047"))
	var filled := maxf(0.0, rect.size.x - 6) * clampf(value / maxf(1.0, maximum), 0.0, 1.0)
	draw_rect(Rect2(rect.position + Vector2(3, 3), Vector2(filled, rect.size.y - 6)), foreground.darkened(0.26))
	draw_rect(Rect2(rect.position + Vector2(3, 3), Vector2(filled, maxf(2.0, (rect.size.y - 6) * 0.35))), foreground.lightened(0.16))
	text_at(rect.position + Vector2(9, rect.size.y - 6), label, 14, Color("fff7e4"))

func draw_ref_panel(rect: Rect2) -> void:
	draw_rect(rect, Color("0e1626"))
	draw_rect(rect.grow(-2), Color("c9a45e"))
	draw_rect(rect.grow(-4), Color("131e2e"))
	draw_rect(Rect2(rect.position + Vector2(9, 6), Vector2(maxf(0.0, rect.size.x - 18), 2)), Color("e6c87a", 0.6))
	for corner in [rect.position + Vector2(4,4), rect.position + Vector2(rect.size.x-9,4), rect.position + Vector2(4,rect.size.y-9), rect.position + rect.size - Vector2(9,9)]:
		draw_rect(Rect2(corner, Vector2(5, 5)), Color("d8b96f"))

func ui_box(rect: Rect2, fill: Color = Color("304a4b")) -> void:
	draw_rect(rect, Color("1e272c"))
	draw_rect(rect.grow(-2), Color("c9a45e"))
	draw_rect(rect.grow(-4), Color("0b2033").lerp(Color("1b3b54"),fill.get_luminance()*0.45))
	draw_rect(Rect2(rect.position + Vector2(9, 7), Vector2(maxf(0.0, rect.size.x - 18), 2)), Color("e0c58b", 0.72))
	for corner in [rect.position + Vector2(4,4), rect.position + Vector2(rect.size.x-9,4), rect.position + Vector2(4,rect.size.y-9), rect.position + rect.size - Vector2(9,9)]:
		draw_rect(Rect2(corner, Vector2(5, 5)), Color("e3c077"))

func ui_button(rect: Rect2, label: String, enabled: bool = true, active: bool = false) -> void:
	var hovering := enabled and rect.has_point(get_viewport().get_mouse_position())
	var border := Color("ffe0a0") if active or hovering else Color("c9a45e")
	draw_rect(rect, Color("18252e"))
	draw_rect(rect.grow(-2), border)
	draw_rect(rect.grow(-4), Color("25475c") if active else (Color("203c53") if hovering else (Color("10283c") if enabled else Color("14202c"))))
	draw_rect(Rect2(rect.position + Vector2(8, 6), Vector2(maxf(0.0, rect.size.x - 16), 2)), Color("dbc58d", 0.52))
	text_at(rect.position + Vector2(11, rect.size.y * 0.67), label, 16, Color("fff1ce") if enabled else Color("b5b4a7"))

func draw_hud() -> void:
	var nearby_food := food_system.nearest(self)
	if not nearby_food.is_empty():
		var food_info:Dictionary=FoodSystem.FOODS[int(nearby_food["food"])]
		var ripe:bool=food_system.ready_at(nearby_food["point"],Time.get_unix_time_from_system())
		draw_ref_panel(Rect2(362,540,405,32))
		text_at(Vector2(374,562),binding_short("interact")+" · "+(food_info["name"]+" pfluecken" if ripe else "Nachwachsen: %ds" % ceili(float(food_system.harvested.get(FoodSystem.key(nearby_food["point"]),0))-Time.get_unix_time_from_system())),14,Color(food_info["color"]))
	draw_ref_panel(Rect2(10, 8, 348, 104))
	draw_rect(Rect2(22, 16, 5, 17), [Color("d9a06f"), Color("9bbce4"), Color("a7cd91")][class_id])
	text_at(Vector2(34, 32), "%s · %s · STUFE %d" % [hero_name if hero_name != "" else CLASS_NAMES[class_id].to_upper(), RACE_NAMES[hero_race], level], 15, Color("ffe9b8"))
	if creative_mode:
		draw_rect(Rect2(301, 17, 46, 17), Color("806a4e"))
		text_at(Vector2(304, 30), "TEST", 12, Color("fff1cb"))
	bar(Rect2(23, 40, 324, 21), hp, max_hp(), Color("d94f4f"), "HP  %d / %d" % [ceili(hp), ceili(max_hp())])
	bar(Rect2(23, 65, 324, 17), energy, max_energy(), Color("3f7fd9") if class_id == 1 else Color("35b381"), "%s  %d / %d" % ["MANA" if class_id == 1 else "ENERGIE", ceili(energy), ceili(max_energy())])
	bar(Rect2(23, 86, 324, 14), float(xp), float(xp_required()), Color("d9932e"), "XP %d/%d  ·  %d GOLD" % [xp, xp_required(), gold])
	if class_mastery_unlocked and class_id==0: text_at(Vector2(365,30),"WUT %.0f%%" % warrior_rage,12,Color("efaa75"))
	elif class_mastery_unlocked and class_id==2: text_at(Vector2(365,30),"JAGD %.0f%%%s" % [ranger_hunt_meter," · %.0fs" % ranger_hunt_buff if ranger_hunt_buff>0 else ""],12,Color("f3d68e"))
	elif class_mastery_unlocked and class_id==1: text_at(Vector2(365,30),"LEERTASTE · ARKANER SCHRITT",12,Color("cdbaff"))
	draw_ref_panel(Rect2(10, 118, 348, 46))
	text_at(Vector2(23, 137), "◆  AKTUELLES ZIEL · DETAILS ›", 13, Color("f0cf92"))
	text_at(Vector2(23, 155), tracked_quest().substr(0, 44), 14, Color("fff2d9"))
	if food_system.meal_active():
		var food_index:int=FoodSystem.index_for(food_system.active_food_name)
		draw_ref_panel(Rect2(10,168,348,58))
		if food_index>=0: FoodSystem.icon(self,Vector2(18,174),food_index,0.95)
		var remain:int=food_system.meal_remaining()
		text_at(Vector2(58,188),food_system.active_food_name,12,Color("ffe5b5"))
		text_at(Vector2(58,205),food_system.meal_effect_text(),10,Color("bde8bd"))
		text_at(Vector2(300,188),"%02d:%02d" % [int(remain/60),remain%60],11,Color("d8e7ff"))
		var progress:float=clampf(float(remain)/360.0,0.0,1.0)
		draw_rect(Rect2(58,212,276,5),Color("1b2f35"))
		draw_rect(Rect2(58,212,276*progress,5),Color("6fbf79") if food_system.meal_mana_regen<=0 else Color("4f8bd8"))
	elif food_system.regen_rate>0 and food_system.regen_until>Time.get_unix_time_from_system():
		draw_ref_panel(Rect2(10,168,348,30))
		text_at(Vector2(23,188),"SNACK · +%.1f HP/s · %ds" % [food_system.regen_rate,ceili(food_system.regen_until-Time.get_unix_time_from_system())],10,Color("aed48c"))
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
		var map_center := Vector2(1035, 116)
		draw_ref_panel(Rect2(918, 8, 234, 30))
		text_at(Vector2(935, 29), ("KONFLUX · "+(KonfluxMap.BIOMES[konflux.room] if konflux.room>=0 else KonfluxMap.BIOMES[KonfluxMap.biome(player_pos)])) if konflux.active else (("LETZTE WACHE" if arena_mode == "final" else "ENDLOSE ARENA") if arena_mode != "" else ("ZUR STEINROSE" if interior_id >= 0 else (DUNGEON_NAMES[dungeon_id].to_upper() if dungeon_id >= 0 else "%s · LV %d" % [region_name(region_at(player_pos)), region_level(region_at(player_pos))]))), 13, Color("fff0bf"), HORIZONTAL_ALIGNMENT_CENTER, 200)
		draw_minimap(Rect2(980, 61, 110, 110), true)
		draw_arc(map_center, 70, 0, TAU, 64, Color("0b1220"), 16)
		draw_arc(map_center, 70, 0, TAU, 64, Color("c9a45e"), 4)
		draw_circle(map_center + Vector2(0, -76), 13, Color("0e1626"))
		draw_arc(map_center + Vector2(0, -76), 13, 0, TAU, 20, Color("c9a45e"), 2)
		text_at(map_center + Vector2(-8, -69), "N", 13, Color("ffe9b0"))
		draw_circle(map_center + Vector2(0, 76), 13, Color("0e1626"))
		draw_arc(map_center + Vector2(0, 76), 13, 0, TAU, 20, Color("c9a45e"), 2)
		text_at(map_center + Vector2(-6, 81), "+", 14, Color("ffe9b0"))
	if network_mode != "offline":
		var ping_text := " · %d ms" % network_ping_ms if network_ping_ms >= 0 else ""
		text_at(Vector2(925, 188), "KOOP %d/4%s" % [remote_players.size()+1,ping_text], 12, Color("a9e8d0"), HORIZONTAL_ALIGNMENT_CENTER, 180)
	if character_created and not creative_mode:
		var save_status_y:float=239.0 if food_system.meal_active() else (207.0 if food_system.regen_rate>0 and food_system.regen_until>Time.get_unix_time_from_system() else 181.0)
		text_at(Vector2(14,save_status_y),server_save.status,10,Color("c9f0c4") if not server_save.dirty and server_save.ready else Color("ffe498"))
	if save_notice_timer > 0.0:
		text_at(Vector2(925, 205), save_notice_text, 10, Color("c9f0c4"), HORIZONTAL_ALIGNMENT_CENTER, 180)
	if notice_timer > 0:
		ui_box(Rect2(12, 549, 510, 36), Color("415f59"))
		var short_notice := notice.substr(0, 55) + ("…" if notice.length() > 55 else "")
		text_at(Vector2(23, 573), short_notice, 15, Color("fff3c3"))
	var nearest := ""
	for i in WAYSTONES.size():
		if player_pos.distance_to(WAYSTONES[i]) < 185:
			nearest = "F  ·  Wegstein: %s" % ("Reiseziele wählen" if i == 0 else ("zurück ins Dorf · aktiviert" if waystone_unlocked[i] else "aktivieren und zurück ins Dorf"))
			break
	for portal in PORTALS:
		if player_pos.distance_to(portal[0]) < 112 or player_pos.distance_to(portal[1]) < 112:
			nearest = "E  ·  Torbogen nach %s (LV %d)" % [region_name(int(portal[2])), region_level(int(portal[2]))]
			break
	for i in LANDMARKS.size():
		if chest_ready(i) and player_pos.distance_to(chest_position(i)) < 85:
			nearest = "E  ·  Schatztruhe öffnen"
			break
	if player_pos.distance_to(BORIN_CRYSTAL_POS)<95: nearest="E  ·  Kristall der Verschmelzung"
	for npc in NPCS:
		if player_pos.distance_to(npc["pos"]) < 105:
			nearest = "E  ·  Elara · Vollheilung für %d Gold" % healing_cost() if npc["kind"] == "healer" else "E  ·  %s (%s)" % [npc["name"], npc["role"]]
			break
	if rescue_state >= 2 and player_pos.distance_to(RESCUE_POS + Vector2(0, 120)) < 120:
		nearest = "E  ·  Nela (Bewohnerin)"
	if dungeon_id >= 0:
		nearest = "E  ·  Gewölbe verlassen" if player_pos.distance_to(DUNGEON_CENTER + Vector2(-570, 0)) < 110 else ("E  ·  Versiegelte Truhe" if player_pos.distance_to(DUNGEON_CENTER + Vector2(555, 0)) < 105 and dungeon_chest_ready(dungeon_id) else "")
	elif interior_id >= 0:
		nearest = "E  ·  Taverne verlassen" if player_pos.distance_to(INTERIOR_CENTER + Vector2(0, 210)) < 95 else ("E  ·  Alma ansprechen" if player_pos.distance_to(INTERIOR_CENTER + Vector2(0, -105)) < 130 else "")
	else:
		if player_pos.distance_to(TAVERN_HOUSE + Vector2(126, 157)) < 112: nearest = "E  ·  Zur Steinrose betreten"
		for index in DUNGEON_ENTRANCES.size():
			if player_pos.distance_to(LANDMARKS[int(DUNGEON_ENTRANCES[index])]["pos"] + Vector2(-30, 70)) < 84:
				nearest = "E  ·  %s betreten" % DUNGEON_NAMES[index]
				break
	if nearest != "":
		if touch_enabled:
			var mobile_hint := Rect2(386, 474, 380, 38)
			ui_box(mobile_hint, Color("587767"))
			text_at(Vector2(398, 500), nearest.replace("E  ·", "AKTION  ·"), 14, Color("fff4ca"), HORIZONTAL_ALIGNMENT_CENTER, 356)
		else:
			ui_box(Rect2(610, 549, 520, 36), Color("587767"))
			text_at(Vector2(623, 573), nearest.replace("E  ·", "%s  ·" % binding_short("interact")), 15, Color("fff4ca"))
	if not touch_enabled:
		ui_button(INVENTORY_HUD_RECT,"INVENTAR")
	if touch_enabled:
		draw_touch_controls()
	else:
		draw_ref_panel(Rect2(9, 586, 1134, 53))
		text_at(Vector2(22, 609), ("LINKER STICK: Laufen · RECHTER STICK: Zielen · " if controller.used else "LAUFEN: %s/%s/%s/%s · " % [binding_short("move_up"),binding_short("move_left"),binding_short("move_down"),binding_short("move_right")]) + "ANGRIFF: " + binding_short("attack") + " · AUSWEICHEN: " + binding_short("dodge"), 11, Color("f0e4c5"), HORIZONTAL_ALIGNMENT_LEFT, 550)
		text_at(Vector2(22, 626), controller.label(int(controller.bindings["pause"]))+": Einstellungen / Belegung" if controller.used else "%s Skills · %s Inventar · %s Quests · %s Karte · %s Chat · %s Hilfe · %s Gruppe" % [binding_short("skills"), binding_short("inventory"), binding_short("journal"), binding_short("map"), binding_short("chat"), binding_short("mechanics"), binding_short("party")], 11, Color("becfc6"), HORIZONTAL_ALIGNMENT_LEFT, 550)
		ui_button(INVENTORY_HUD_RECT,"INVENTAR")
		for slot in 4:
			var id: int = class_ultimate() if slot == 3 and level >= 20 else (int(slots[slot]) if slot < 3 else -1)
			var x := 694 + slot * 81
			draw_rect(Rect2(x,593,75,44),Color("d0b67d",0.45 if id>=0 else 0.18),false,1)
			text_at(Vector2(x + 8, 629), binding_short("ability_%d" % (slot + 1)), 11, Color("ffe2a3") if id >= 0 else Color("a9aa9c"))
			if id >= 0:
				draw_skill_icon(Vector2(x + 24, 598), id, 30)
				if float(cooldowns[id]) > 0:
					draw_rect(Rect2(x + 3, 596, 68, 38), Color(0.1, 0.16, 0.2, 0.7))
					text_at(Vector2(x + 23, 620), "%.1f" % float(cooldowns[id]), 15)

func draw_touch_controls() -> void:
	# Klassisches Mobile-Layout: Bewegung links, Skills unten mittig,
	# Interaktion/Ausweichen/Angriff rechts.
	var base := touch_move_base
	var active_alpha := 0.82 if touch_move_id >= 0 else 0.42
	draw_circle(base, 82, Color(0.07, 0.12, 0.14, active_alpha))
	draw_arc(base, 82, 0, TAU, 40, Color("a9c4b8", active_alpha), 3)
	draw_circle(touch_move_knob, 34, Color("5d756b", 0.92 if touch_move_id >= 0 else 0.62))
	draw_arc(touch_move_knob, 34, 0, TAU, 32, Color("e7d5a3", 0.92 if touch_move_id >= 0 else 0.62), 3)
	text_at(base + Vector2(-50, 108), "BEWEGEN", 12, Color("d9e5dc", active_alpha), HORIZONTAL_ALIGNMENT_CENTER, 100)

	for slot in 4:
		var id: int = class_ultimate() if slot == 3 and level >= 20 else (int(slots[slot]) if slot < 3 else -1)
		var rect := Rect2(424 + slot * 76, 548, 68, 70)
		draw_rect(rect, Color("152228", 0.88))
		draw_rect(rect, Color("b99b63", 0.82), false, 2)
		text_at(rect.position + Vector2(7, 64), str(slot + 1), 11, Color("ffe3a5"))
		if id >= 0:
			draw_skill_icon(rect.position + Vector2(19, 9), id, 32)
			if float(cooldowns[id]) > 0:
				draw_rect(rect.grow(-3), Color(0.08, 0.12, 0.16, 0.72))
				text_at(rect.position + Vector2(19, 43), "%.1f" % float(cooldowns[id]), 14, Color("fff1c7"))
		else:
			text_at(rect.position + Vector2(14, 38), "–", 22, Color("83918b"))

	var attack_base := touch_aim_base if touch_aim_id >= 0 else Vector2(1032,526)
	var attack_knob := touch_aim_knob if touch_aim_id >= 0 else attack_base
	draw_circle(attack_base, 64.0, Color("725047",0.58 if touch_aim_id < 0 else 0.88))
	draw_arc(attack_base, 64.0, 0, TAU, 36, Color("f0daa3",0.86), 3)
	draw_circle(attack_knob, 28.0, Color("9a675b",0.92))
	draw_arc(attack_knob, 28.0, 0, TAU, 28, Color("fff0c8",0.88), 2)
	if touch_aim_id >= 0 and touch_aim_vector.length_squared() > 0.01:
		draw_line(attack_base, attack_base + touch_aim_vector.normalized() * 78.0, Color("ffe2a8",0.82), 4)
	text_at(attack_base + Vector2(-48, 5), "ANGRIFF", 11, Color("fff2cf"), HORIZONTAL_ALIGNMENT_CENTER, 96)

	for data in [
		{"p":Vector2(916,550),"r":39.0,"label":("SCHRITT" if class_id == 1 else "ROLLE"),"fill":Color("3f5c62",0.90)},
		{"p":Vector2(967,447),"r":39.0,"label":"AKTION","fill":Color("556b4f",0.90)}
	]:
		draw_circle(data["p"], data["r"], data["fill"])
		draw_arc(data["p"], data["r"], 0, TAU, 32, Color("f0daa3",0.82), 3)
		text_at(data["p"] + Vector2(-45,5), data["label"], 11, Color("fff2cf"), HORIZONTAL_ALIGNMENT_CENTER, 90)

	var chat_rect := Rect2(866, 300, 86, 50)
	draw_rect(chat_rect, Color("223338",0.92))
	draw_rect(chat_rect, Color("c7aa70",0.88), false, 2)
	text_at(chat_rect.position + Vector2(5,32), "CHAT", 13, Color("fff0c8"), HORIZONTAL_ALIGNMENT_CENTER, int(chat_rect.size.x-10))
	var online_rect := Rect2(960, 300, 86, 50)
	draw_rect(online_rect, Color("223338",0.92))
	draw_rect(online_rect, Color("8eb6a5",0.88), false, 2)
	text_at(online_rect.position + Vector2(5,32), "ONLINE", 11, Color("e1fff1"), HORIZONTAL_ALIGNMENT_CENTER, int(online_rect.size.x-10))

	for pair in [[Rect2(735,557,66,54),"HP"],[Rect2(807,557,66,54),"MANA" if class_id == 1 else "ENERGIE"]]:
		draw_rect(pair[0], Color("223338",0.90))
		draw_rect(pair[0], Color("9b8660",0.8), false, 2)
		text_at(pair[0].position + Vector2(4,34), pair[1], 10, Color("ffe7b0"), HORIZONTAL_ALIGNMENT_CENTER, int(pair[0].size.x-8))

func tracked_quest() -> String:
	return quest_guide.summary(self)

func draw_minimap(rect: Rect2, compact: bool) -> void:
	if konflux.active:
		konflux.draw_map(self,rect,compact)
		return
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
		if chest_ready(i):
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
	quest_guide.draw_on_map(self,inset,Vector2(sx,sy))
	if not compact:
		draw_rect(Rect2(inset.position + camera_pos * Vector2(sx, sy), VIEW * Vector2(sx, sy)), Color.WHITE, false, 2)

func region_required_boss(zone:int)->int:
	match zone:
		4: return 0
		5,7: return 1
	return -1

func boss_gate_name(boss_index:int)->String:
	if boss_index<0 or 12+boss_index>=ENEMY_TYPES.size(): return ""
	return str(ENEMY_TYPES[12+boss_index]["name"])

func region_available(zone: int) -> bool:
	if creative_mode: return true
	var needed_boss:=region_required_boss(zone)
	return needed_boss<0 or bosses_defeated[needed_boss]

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
	var circle_center := rect.get_center()
	var circle_radius := minf(rect.size.x, rect.size.y) * 0.5 - 5.0
	draw_circle(circle_center, circle_radius + 4.0, Color("c5a46e"))
	draw_circle(circle_center, circle_radius, Color("1e343a"))
	var inset := rect.grow(-4)
	var radius := 1500.0
	var scale_map := inset.size / (radius * 2.0)
	var start := player_pos - Vector2(radius, radius)
	for gx in 17:
		for gy in 13:
			var tile_center := inset.position + Vector2((gx + 0.5) * inset.size.x / 17.0, (gy + 0.5) * inset.size.y / 13.0)
			if tile_center.distance_to(circle_center) > circle_radius - 6.0: continue
			var point := start + Vector2((gx + 0.5) * radius * 2.0 / 17.0, (gy + 0.5) * radius * 2.0 / 13.0)
			var area := visual_region_at(point)
			var tint: Color = [Color("699b73"), Color("7da66b"), Color("365b50"), Color("535b61"), Color("355a68"), Color("755045"), Color("b7a578"), Color("48415c"), Color("52696a"), Color("a48a52"), Color("477579"), Color("575b73"), Color("6e6384")][area]
			if area == 0:
				var ground_kind := StartTileMap32.kind_at(point)
				if ground_kind == 2: tint = Color("a4aa91")
				elif ground_kind == 1: tint = Color("a0b47d")
			elif distance_to_trail(point) < 110: tint = Color("d2ba86")
			draw_rect(Rect2(inset.position + Vector2(gx * inset.size.x / 17.0, gy * inset.size.y / 13.0), inset.size / Vector2(17, 13) + Vector2.ONE), tint)
	for stone in WAYSTONES:
		var p: Vector2 = inset.position + (stone - start) * scale_map
		if p.distance_to(circle_center) < circle_radius - 5.0: draw_circle(p, 3, Color("8af0e9"))
	for portal in PORTALS:
		for end in [portal[0], portal[1]]:
			var p: Vector2 = inset.position + (end - start) * scale_map
			if p.distance_to(circle_center) < circle_radius - 5.0 and region_available(int(portal[2])): draw_circle(p, 3, Color("efccfa"))
	for index in DUNGEON_ENTRANCES.size():
		var entrance: Vector2 = LANDMARKS[int(DUNGEON_ENTRANCES[index])]["pos"]
		if not region_available(region_at(entrance)): continue
		var mark: Vector2 = inset.position + (entrance - start) * scale_map
		if mark.distance_to(circle_center) < circle_radius - 6.0:
			draw_rect(Rect2(mark - Vector2(3, 3), Vector2(6, 6)), Color("f5d6aa"), false, 2)
	if rescue_state < 3:
		var rescue: Vector2 = inset.position + (RESCUE_POS - start) * scale_map
		if rescue.distance_to(circle_center) < circle_radius - 7.0: draw_arc(rescue, 6, 0, TAU, 18, Color("ffae78"), 2)
	for i in WORLD_EVENTS.size():
		if int(event_states[i]) == 3: continue
		var encounter: Vector2 = inset.position + (WORLD_EVENTS[i]["pos"] - start) * scale_map
		if encounter.distance_to(circle_center) < circle_radius - 5.0 and region_available(int(WORLD_EVENTS[i]["region"])):
			draw_circle(encounter, 4, Color("293e46"))
			draw_circle(encounter, 2, Color("ffe399") if int(event_states[i]) in [0, 2] else Color("a7d2c3"))
	for enemy in enemies:
		var p: Vector2 = inset.position + (enemy["pos"] - start) * scale_map
		if p.distance_to(circle_center) < circle_radius - 4.0: draw_circle(p, 2, Color("ef8584"))
	for member in (party_state.get("members",[]) as Array):
		if not member is Dictionary or str(member.get("uuid","")) == player_uuid: continue
		if str(member.get("context","world")) != "world": continue
		var member_data: Array = member.get("pos",[])
		if member_data.size() < 2: continue
		var member_world := Vector2(float(member_data[0]),float(member_data[1]))
		var member_mark := inset.position + (member_world-start)*scale_map
		if member_mark.distance_to(circle_center) < circle_radius-4.0:
			draw_circle(member_mark,4,Color("8ff1c1"))
			draw_arc(member_mark,5,0.0,TAU,14,Color("eaffd9"),1)
	quest_guide.draw_on_minimap(self,circle_center,circle_radius,scale_map,start)
	draw_circle(rect.get_center(), 4, Color.WHITE)
	draw_line(rect.get_center(), rect.get_center() + facing.normalized() * 10, Color("fff1ad"), 2)
	draw_arc(circle_center, circle_radius + 3.0, 0.0, TAU, 64, Color("f0d393"), 3)

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
	text_at(p + Vector2(-105, -59), "%s · %s · EMPF. LV %d" % ["AKTION" if touch_enabled else binding_short("interact"), region_name(region), region_level(region)], 12, Color("fff0c7"), HORIZONTAL_ALIGNMENT_CENTER, 210)

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
	draw_rect(Rect2(128, 72, 896, 544), Color("061525"))
	ui_box(Rect2(135, 79, 882, 530), Color("40514d"))
	draw_rect(Rect2(164, 94, 824, 3), Color("c6a66e"))
	draw_rect(Rect2(164, 598, 824, 2), Color("9d845e"))
	for index in 7:
		draw_rect(Rect2(172 + index * 116, 101, 5, 5), Color("c6aa79", 0.6))
	if panel not in ["start", "creation", "multiplayer", "arena_reward", "victory"]: ui_button(Rect2(965, 91, 41, 35), "X")
	match panel:
		"start": draw_start_panel()
		"creation": draw_creation_panel()
		"creation_review": draw_creation_review_panel()
		"multiplayer": draw_multiplayer_panel()
		"intro": draw_intro_panel()
		"patches": preload("res://components/patch_notes.gd").draw(self)
		"pause": draw_game_menu()
		"settings": draw_pause_panel()
		"controls": draw_controls_panel()
		"controller": controller.draw(self)
		"skills": draw_skills_panel()
		"fusion": draw_fusion_panel()
		"inventory": draw_inventory_panel()
		"steinrose": steinrose.draw(self)
		"shop": draw_shop_panel()
		"travel": draw_travel_panel()
		"journal": draw_journal_panel()
		"quest_details": quest_guide.draw_details(self)
		"map": draw_map_panel()
		"mechanics": draw_mechanics_panel()
		"party": draw_party_panel()
		"arena_entry": draw_arena_entry_panel()
		"arena_reward": draw_arena_reward_panel()
		"victory": draw_victory_panel()

	controller.draw_cursor(self)

func draw_mechanics_panel() -> void:
	text_at(Vector2(190,126), "MECHANIK-ÜBERSICHT", 28, Color('ffe1a0'))
	text_at(Vector2(770,126), binding_short("mechanics")+" · öffnen/schließen", 12, Color('aebfb9'))
	var labels: Array[String] = ["REGIONEN","QUESTS","SKILLS","KOOP & CHAT"]
	for tab in 4:
		ui_button(Rect2(190 + tab*195,142,180,38), labels[tab], true, mechanics_page == tab)
	if mechanics_page == 0:
		text_at(Vector2(190,211), "Regionen: empfohlenes Level · typische Gegner · Bossfreischaltung", 16, Color('e9cc90'))
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
			text_at(Vector2(x,y), "%02d  %s · EMPF. LV %d · %s" % [i+1,region_name(i),region_level(i),status], 14, Color('dff0d9') if status == "OFFEN" else Color('d6a5a5'))
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
		text_at(Vector2(190,211), "Borin: Kampf · Magie · Robotik sind für jede Rasse und Klasse offen.", 16, Color('e9cc90'))
		text_at(Vector2(190,250), "Skillpunkte bleiben beim normalen Leveln unverändert. Skills werden gezielt bei Borin gekauft.", 13, Color('e5ecd9'))
		text_at(Vector2(190,282), "Drei aktive Slots werden nur bei Borin kostenlos umbelegt. Taste 4 bleibt die Klassen-Ultimate.", 13, Color('e5ecd9'))
		text_at(Vector2(190,328), "KRISTALL DER VERSCHMELZUNG", 17, Color('d9c8ff'))
		text_at(Vector2(190,356), "Neben Borin: zwei gelernte Skills + viel Gold + doppelte Grund-SP-Kosten → Fusionsskill.", 13, Color('cbd9da'))
		text_at(Vector2(190,405), "MEISTERGABE NACH DEM FINALE", 17, Color('ffe0a1'))
		text_at(Vector2(190,434), "Krieger: Wut · Magier: Arkaner Schritt · Bogenschütze: Jagdrausch + Schattenrolle.", 13, Color('e5ecd9'))
		text_at(Vector2(190,468), "Bogenschütze: volle Jagdleiste = 60 Sek. +25% Angriffstempo; Rolle tarnt bis 0,4 Sek. danach.", 12, Color('aebfb9'))
		text_at(Vector2(190,575), "Freie Skillpunkte: %d · Lernen und Build ändern: bei Borin" % skill_points, 13, Color('ffe0a1'))
	else:
		text_at(Vector2(190,211), "Online: Gruppen mit bis zu 10 Spielern · Browser und Desktop verbinden sich mit dem gemeinsamen Live-Server.", 16, Color('e9cc90'))
		text_at(Vector2(190,250), "Status: %s" % network_status, 14, Color('bfe7d4'), HORIZONTAL_ALIGNMENT_LEFT, 750)
		text_at(Vector2(190,286), "CHAT", 17, Color('ffe0a1'))
		text_at(Vector2(190,315), ("CHAT antippen öffnet die Smartphone-Tastatur." if touch_enabled else "ENTER oder T öffnet den Gruppenchat. ENTER sendet, ESC bricht ab."), 14, Color('e5ecd9'))
		text_at(Vector2(190,343), "Nachrichten zeigen den gespeicherten Charakternamen und werden an die Koop-Gruppe verteilt.", 13, Color('aebfb9'))
		text_at(Vector2(190,390), "SICHERHEITSZONE", 17, Color('ffe0a1'))
		text_at(Vector2(190,419), "Sonnenhain: keine normalen Spawns. Verfolgte Gegner ziehen sich zurück und verschwinden außerhalb.", 13, Color('dfe9dc'))
		text_at(Vector2(190,454), "SPAWNREGELN", 17, Color('ffe0a1'))
		text_at(Vector2(190,483), "Gegner erscheinen nicht auf Wegen, an NPCs, Wegsteinen, Portalen, Landmarken oder Gebäuden.", 13, Color('dfe9dc'))
		text_at(Vector2(190,512), "Normale Oberwelt: maximal 10 aktive Gegner, deutlich längeres Spawnintervall.", 13, Color('dfe9dc'))
	ui_button(Rect2(820,548,160,38), "SCHLIESSEN")

func draw_start_panel() -> void:
	text_at(Vector2(300, 210), "SONNENHAIN", 42, Color("ffe2aa"))
	text_at(Vector2(300, 248), "Deine Reise beginnt hier.", 18, Color("dce7d8"))
	text_at(Vector2(300, 320), "Lade deinen Spielstand oder erschaffe einen neuen Charakter.", 16, Color("dce7d8"), HORIZONTAL_ALIGNMENT_LEFT, 550)
	ui_button(Rect2(300, 378, 550, 54), "NEUEN CHARAKTER ERSTELLEN")
	ui_button(Rect2(300, 448, 550, 54), "SPIELSTAND LADEN", FileAccess.file_exists(slot_save_path(selected_save_slot)))
	text_at(Vector2(168, 521), "SPEICHERPLATZ WÄHLEN", 14, Color("f6dfa9"))
	for index in 3:
		var card := Rect2(168 + index * 273, 530, 260, 57)
		ui_box(card, Color("627565") if selected_save_slot == index + 1 else Color("3a5251"))
		text_at(card.position + Vector2(11, 24), "SPIELSTAND %d" % (index + 1), 16, Color("fff0ce"))
		text_at(card.position + Vector2(11, 46), str(save_slot_labels[index]) if index < save_slot_labels.size() else "LEER", 14, Color("e0eacb"))

func draw_creation_panel() -> void:
	text_at(Vector2(270, 142), "CHARAKTER ERSTELLEN", 31, Color('ffe1a0'))
	text_at(Vector2(270, 172), "Wähle Name, Rasse und Geschlecht. Klicke danach deine Klassenfigur an.", 15, Color('d8e6dc'))
	text_at(Vector2(270, 215), "NAME", 14, Color('e9cc90'))
	var name_box := Rect2(300, 228, 550, 48)
	draw_rect(name_box, Color('22363c'))
	draw_rect(name_box, Color('8ba49c'), false, 2)
	text_at(name_box.position + Vector2(14,31), (creation_name if creation_name != "" else ("Antippen zum Eingeben …" if touch_enabled else "Name eingeben …")) + ("_" if int(world_time*2.0)%2==0 and not touch_enabled else ""), 20, Color('fff0cf') if creation_name != "" else Color('9fb4ac'))
	text_at(Vector2(270, 292), "GESCHLECHT", 14, Color('e9cc90'))
	for i in 2:
		ui_button(Rect2(300 + i*210, 300, 195, 40), GENDER_NAMES[i].to_upper(), true, pending_gender == i)
	text_at(Vector2(270, 357), "RASSE", 14, Color('e9cc90'))
	for i in 3:
		ui_button(Rect2(245 + i*220, 365, 205, 44), RACE_NAMES[i].to_upper(), true, pending_race == i)
	# Vorschau der drei Klassen mit gewählter Rasse/Geschlecht.
	for cls in 3:
		var center := Vector2(278 + cls*225, 470)
		var figure_rect:=Rect2(245+cls*225,414,205,100)
		ui_box(figure_rect,Color("3a4c4f"))
		if figure_rect.has_point(get_viewport().get_mouse_position()):draw_rect(figure_rect.grow(-3),Color("90b3c1"),false,2)
		if creation_class_selected and pending_class==cls:draw_rect(Rect2(245+cls*225,414,205,100),Color("e5c783"),false,3)
		draw_character_sprite(center, cls, false, Vector2.DOWN, 1.0, false, pending_race, pending_gender)
		draw_weapon_world(center + Vector2(0,-5), cls, cls*4, Vector2.DOWN, 1.0)
		text_at(Vector2(255+cls*225,434), CLASS_NAMES[cls], 14, Color('ffe2aa'))
		var descriptions := [["Nahkampf · Energie", "Hiebe und Schutz", "Attribut: Stärke"], ["Fernkampf · Mana", "Feuer, Eis und Blitz", "Intelligenz · 2 Ringe"], ["Fernkampf · Energie", "Pfeile und Ausweichen", "Attribut: Beweglichkeit"]]
		for line in 3:
			text_at(Vector2(312+cls*225,456+line*18), descriptions[cls][line], 10, Color('d8e6dc'), HORIZONTAL_ALIGNMENT_LEFT, 135)
	ui_button(Rect2(165, 520, 110, 52), "ZURÜCK")
	ui_button(Rect2(300, 520, 550, 52), "VORSCHAU & FÄHIGKEITEN", creation_name.strip_edges().length() >= 2 and creation_class_selected)
	text_at(Vector2(305, 592), "Figur anklicken, dann Auswahl bestätigen. Rasse und Geschlecht bestimmen dein Modell.", 12, Color('aebfb9'), HORIZONTAL_ALIGNMENT_CENTER, 540)

func review_character_creation() -> void:
	if creation_name.strip_edges().length()<2 or not creation_class_selected: return
	creation_replace_confirmed=false
	panel="creation_review"

func draw_creation_review_panel() -> void:
	text_at(Vector2(190,145), "DEIN CHARAKTER", 30, Color("ffe2aa"))
	ui_box(Rect2(190,175,300,330),Color("31474e"))
	draw_character_sprite(Vector2(330,310),pending_class,false,Vector2.DOWN,2.2,false,pending_race,pending_gender)
	text_at(Vector2(215,395),creation_name.strip_edges(),24,Color("fff0ce"))
	text_at(Vector2(215,422),"%s · %s" % [RACE_NAMES[pending_race],GENDER_NAMES[pending_gender]],16,Color("d8e6dc"))
	text_at(Vector2(215,450),CLASS_NAMES[pending_class],19,Color("ffe2aa"))
	text_at(Vector2(215,483),"Rasse bestimmt dein Aussehen",12,Color("b8cbc5"))
	text_at(Vector2(520,198),"DREI KLASSENFÄHIGKEITEN",19,Color("ffe2aa"))
	for i in 3:
		var id:int=int(preload("res://components/class_spell_preview.gd").ids(pending_class)[i])
		var y:float=224+i*75
		draw_skill_sprite(id,Vector2(520,y),36)
		preload("res://components/class_spell_preview.gd").draw(self,id,Rect2(800,y-3,155,65))
		text_at(Vector2(568,y+17),str(ABILITIES[id]["name"]),16,Color("fff0ce"))
		text_at(Vector2(568,y+36),str(ABILITIES[id]["desc"]),12,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,225)
		text_at(Vector2(568,y+54),"Vorschau · beim Skillen freischalten",11,Color("b8cbc5"))
	var occupied:=FileAccess.file_exists(slot_save_path(active_save_slot))
	text_at(Vector2(520,472),"Speicherplatz %d · %s" % [active_save_slot,"BELEGT" if occupied else "FREI"],16,Color("ffe2aa"))
	text_at(Vector2(520,498),"Alter Stand wird gesichert und ersetzt." if occupied else "Dein Abenteuer beginnt auf Level 1.",12,Color("edb8a0") if occupied else Color("b8cbc5"))
	ui_button(Rect2(190,540,180,44),"ZURÜCK")
	ui_button(Rect2(590,540,365,44),"ERSETZEN BESTÄTIGEN" if creation_replace_confirmed else ("SPIELSTAND ERSETZEN?" if occupied else "CHARAKTER ERSTELLEN"))

func draw_multiplayer_panel() -> void:
	text_at(Vector2(205, 150), "SONNENHAIN ONLINE", 31, Color('ffe1a0'))
	text_at(Vector2(205, 182), "2–4 Spieler · gemeinsamer Live-Server · Gruppenchat", 16, Color('d8e6dc'))
	text_at(Vector2(205, 215), "Browser und Desktop verbinden sich über den verschlüsselten Sonnenhain-Server.", 13, Color('b9cbc3'))
	ui_button(Rect2(205, 282, 340, 52), "ONLINE-SERVER")
	if not is_web_platform():
		ui_button(Rect2(605, 282, 340, 52), "DESKTOP-HOST (LEGACY)")
		text_at(Vector2(205, 365), "LEGACY-EINLADUNGSCODE", 14, Color('e9cc90'))
		var code_box := Rect2(205, 378, 740, 56)
		draw_rect(code_box, Color('20343a'))
		draw_rect(code_box, Color('8ba49c'), false, 2)
		var shown := invite_code if network_mode == "host" and invite_code != "" else join_code
		text_at(code_box.position + Vector2(14,36), (shown if shown != "" else "SH-…  Code hier eintippen") + ("_" if network_mode != "host" and int(world_time*2.0)%2==0 else ""), 22, Color('fff0cf'))
		ui_button(Rect2(205, 396, 740, 46), "MIT LEGACY-CODE BEITRETEN", join_code.length() > 4)
		ui_button(Rect2(205, 454, 740, 46), "CODEFELD LEEREN")
	else:
		text_at(Vector2(205, 365), "Kein Portforwarding nötig. Die Verbindung läuft über WSS/HTTPS.", 14, Color('e9cc90'))
		text_at(Vector2(205, 405), "Der Online-Server wird automatisch über sonnenhainrpg.de erreicht.", 13, Color('b9cbc3'))
	text_at(Vector2(205, 511), network_status, 13, Color('bfe7d4'), HORIZONTAL_ALIGNMENT_LEFT, 740)
	ui_button(Rect2(205, 520, 200, 46), "ZURÜCK")
	var can_start := network_mode == "host" or (network_mode == "client" and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED)
	ui_button(Rect2(605, 520, 340, 46), "WELT STARTEN" if network_mode == "host" else "WELT BEITRETEN", can_start)
	text_at(Vector2(205, 586), "Online: wss://multiplayer.sonnenhainrpg.de/ · Desktop-Legacy bleibt zusätzlich verfügbar.", 12, Color('aebfb9'), HORIZONTAL_ALIGNMENT_LEFT, 740)

func draw_game_menu() -> void:
	text_at(Vector2(190,145),"SPIELMENÜ",30,Color("ffe2aa"))
	ui_box(Rect2(190,175,300,335),Color("243b48"))
	draw_character_sprite(Vector2(340,310),class_id,false,Vector2.DOWN,2.0,false,hero_race,hero_gender)
	text_at(Vector2(215,360),hero_name,23,Color("fff0ce"))
	text_at(Vector2(215,389),"%s · Level %d" % [CLASS_NAMES[class_id],level],16,Color("d8e6dc"))
	text_at(Vector2(215,425),region_name(region_at(player_pos)),14,Color("d8e6dc"))
	text_at(Vector2(215,463),"Online: Welt läuft weiter" if network_mode!="offline" else "Spiel pausiert",12,Color("b8cbc5"))
	var labels:Array=["WEITERSPIELEN","INVENTAR","FÄHIGKEITEN","QUESTBUCH","WELTKARTE","GRUPPE","EINSTELLUNGEN & TESTMODUS"]
	for i in labels.size():ui_button(Rect2(540,155+i*51,410,42),labels[i])
	ui_button(Rect2(190,485,300,36),"NEUE PATCHES")
	ui_button(Rect2(540,512,410,42),"SPIEL SPEICHERN")
	text_at(Vector2(540,578),pause_status,12,Color("ffe5ab"),HORIZONTAL_ALIGNMENT_LEFT,410)
	ui_button(Rect2(190,540,300,44),"SPEICHERN & HAUPTMENÜ")

func draw_pause_panel() -> void:
	ui_button(Rect2(860,319,130,42), "CONTROLLER")
	ui_button(Rect2(300, 135, 550, 42), "PAUSE", true, true)
	text_at(Vector2(302, 205), "Level %d · %s · %d Gold" % [level, "Konflux" if konflux.active else region_name(region_at(player_pos)), gold], 17, Color("e6f0dc"))
	ui_button(Rect2(300, 221, 550, 42), "FORTSETZEN")
	ui_button(Rect2(860, 221, 130, 42), "TOUCH" if touch_enabled else "TASTEN")
	ui_button(Rect2(860, 270, 130, 42), "MECHANIK")
	ui_button(Rect2(300, 270, 550, 42), "TESTSTAND SPEICHERN" if creative_mode else "SPIEL SPEICHERN")
	draw_volume_slider(Vector2(300, 326), "MUSIK", music_volume, Color("d9b67b"))
	draw_volume_slider(Vector2(300, 380), "EFFEKTE", effects_volume, Color("9bcfd0"))
	ui_button(Rect2(300, 432, 550, 42), "TESTMODUS VERLASSEN" if creative_mode else "TESTMODUS STARTEN")
	if not creative_mode:
		ui_button(Rect2(300, 480, 260, 38), "BACKUP EXPORT")
		ui_button(Rect2(590, 480, 260, 38), "BACKUP IMPORT")
	if creative_mode:
		text_at(Vector2(302, 504), "LEVEL %d · %d Skillpunkte" % [level, skill_points], 14, Color("fff0bd"))
		for index in 4:
			ui_button(Rect2(300 + index * 113, 510, 105, 38), ["-10", "-1", "+1", "+10"][index])
		ui_button(Rect2(762, 510, 180, 38), "REISEN")
	text_at(Vector2(302, 538 if not creative_mode else 488), pause_status, 13, Color("ffe5ab"), HORIZONTAL_ALIGNMENT_LEFT, 630)
	ui_button(Rect2(300, 563, 550, 35), "SPEICHERN & ZUR STARTSEITE" if is_web_platform() else "SPEICHERN & ZUM HAUPTMENÜ")

func draw_controls_panel() -> void:
	if touch_enabled:
		text_at(Vector2(185, 153), "MOBILE STEUERUNG", 29, Color("ffdf9f"))
		text_at(Vector2(187, 184), "Touch-Version · keine Tastaturbelegung nötig", 14, Color("b9cbc3"))
		var rows := [
			["BEWEGEN", "Linke Bildschirmseite antippen und ziehen · Floating-Joystick"],
			["ZIELEN & ANGRIFF", "Rechten Angriffsstick halten und intuitiv in Angriffsrichtung ziehen"],
			["ROLLE", "ROLLE antippen · Richtung kommt vom linken Bewegungsstick"],
			["AKTION", "AKTION für NPCs, Türen, Wegsteine und Interaktionen"],
			["SKILLS", "Die vier Skillfelder unten direkt antippen"],
			["HEILUNG", "HP sowie MANA/ENERGIE unten rechts direkt antippen"],
			["CHAT", "CHAT öffnet die Smartphone-Tastatur"],
			["ONLINE", "ONLINE zeigt die aktuell verbundenen Spielernamen"]
		]
		for i in rows.size():
			var y := 225.0 + i * 39.0
			draw_rect(Rect2(185, y - 23, 780, 33), Color("354a4a") if i % 2 == 0 else Color("3c5250"))
			text_at(Vector2(198, y), str(rows[i][0]), 14, Color("ffe6b1"), HORIZONTAL_ALIGNMENT_LEFT, 175)
			text_at(Vector2(385, y), str(rows[i][1]), 13, Color("dbe9d5"), HORIZONTAL_ALIGNMENT_LEFT, 560)
		text_at(Vector2(187, 548), "PC-Tasten werden in der Mobile-Version bewusst nicht eingeblendet.", 13, Color("aebfb9"))
		ui_button(Rect2(585, 562, 385, 36), "ZURÜCK")
		return

	text_at(Vector2(170, 153), "TASTENBELEGUNG", 29, Color("ffdf9f"))
	text_at(Vector2(172, 179), "Belegung anklicken · Taste oder Maustaste drücken · ESC bricht die Auswahl ab", 14, Color("e3e9d8"))
	for index in BIND_ACTIONS.size():
		var column := int(index / 12.0)
		var row := index % 12
		var x := 170 + column * 420
		var y := 195 + row * 29
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
	text_at(Vector2(230, 413), binding_short("interact")+" / Leertaste / Klick: Überspringen", 15, Color("c7d4ca"))

func draw_skills_panel() -> void:
	text_at(Vector2(165,125),"BORIN · SKILLZAUBERER",25,Color("ffeda9"))
	text_at(Vector2(650,124),"LV %d · %d SP · %d GOLD" % [level,skill_points,gold],16,Color("f6dc9a"))
	for tab in 3: ui_button(Rect2(165+tab*180,145,168,38),SKILL_TREE_NAMES[tab],true,skill_tree_tab==tab)
	ui_button(Rect2(718,145,118,38),"QUESTS")
	for slot in 3:
		var sid:int=slots[slot];ui_button(Rect2(165+slot*204,190,193,40),"%d · %s" % [slot+1,"FREI" if sid<0 else ABILITIES[sid]["name"]],true,selected_slot==slot)
	var ids:Array=SKILL_TREES[skill_tree_tab];var start:=menu_scroll*3
	for card in mini(6,maxi(0,ids.size()-start)):
		var id:int=ids[start+card];var col:=card%3;var row:=int(card/3.0);var x:=165+col*275;var y:=250+row*132
		ui_box(Rect2(x,y,265,118),Color("314b54") if learned[id] else Color("243944"));draw_skill_icon(Vector2(x+12,y+12),id,30)
		text_at(Vector2(x+50,y+31),ABILITIES[id]["name"],15,Color("fff1bc"),HORIZONTAL_ALIGNMENT_LEFT,198);text_at(Vector2(x+12,y+57),ABILITIES[id]["desc"],11,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,240)
		var req:=int(ABILITIES[id]["req"]);var price:=skill_point_cost(id)
		text_at(Vector2(x+12,y+88),"GELERNT · SLOT %d" % (selected_slot+1) if learned[id] else ("KAUFEN · %d SP" % price if level>=req else "GESPERRT · LV %d" % req),12,Color("9de6c2") if learned[id] or level>=req else Color("c98d84"))
	text_at(Vector2(165,530),"Gelernte Skills anklicken → ausgewählten Slot belegen · Wechsel bei Borin kostenlos.",13,Color("d9e6d5"))
	text_at(Vector2(165,554),"Verschmelzungen gibt es nur am Kristall neben Borin.",13,Color("b9d9cf"))
	var mastery:String=str(["Wut: %.0f/100" % warrior_rage,"Arkaner Schritt: %s" % ("bereit" if arcane_step_learned else "gesperrt"),"Jagd: %.0f/100%s" % [ranger_hunt_meter," · %.0fs Buff" % ranger_hunt_buff if ranger_hunt_buff>0 else ""]][class_id])
	if not class_mastery_unlocked:
		mastery = "Relikt von Map %02d · %s" % [6+class_id,ENEMY_TYPES[12+class_id]["name"]]
	text_at(Vector2(165,578),"Klassenbonus · "+mastery,13,Color("ffe2aa"))

func draw_fusion_crystal() -> void:
	var p:=BORIN_CRYSTAL_POS
	draw_circle(p,34,Color("5e53a8",0.22));draw_colored_polygon(PackedVector2Array([p+Vector2(0,-48),p+Vector2(25,-8),p+Vector2(15,40),p+Vector2(-18,40),p+Vector2(-27,-8)]),Color("8f7de8"));draw_colored_polygon(PackedVector2Array([p+Vector2(0,-39),p+Vector2(13,-5),p+Vector2(6,25),p+Vector2(-9,24),p+Vector2(-14,-6)]),Color("d8ccff"))
	text_at(p+Vector2(-62,68),"VERSCHMELZEN",12,Color("e7dcff"),HORIZONTAL_ALIGNMENT_CENTER,124)

func draw_fusion_panel() -> void:
	text_at(Vector2(165,125),"KRISTALL DER VERSCHMELZUNG",25,Color("d9c8ff"));text_at(Vector2(720,124),"%d SP · %d GOLD" % [skill_points,gold],16,Color("f6dc9a"));text_at(Vector2(165,160),"Beide Ausgangsskills bleiben erhalten.",13,Color("cbd9da"))
	for i in FUSIONS.size():
		var f:Dictionary=FUSIONS[i];var id:=int(f["id"]);var a:=int(f["a"]);var b:=int(f["b"]);var y:=195+i*118
		ui_box(Rect2(165,y,800,104),Color("342f51") if learned[id] else Color("263647"));text_at(Vector2(185,y+27),ABILITIES[id]["name"],17,Color("fff1bc"));text_at(Vector2(185,y+51),"%s %s  +  %s %s" % [ABILITIES[a]["name"],"✓" if learned[a] else "✗",ABILITIES[b]["name"],"✓" if learned[b] else "✗"],13,Color("cde5d5"));text_at(Vector2(185,y+78),"%d Skillpunkte · %d Gold" % [fusion_skill_cost(f),int(f["gold"])],13,Color("f4d49b"));ui_button(Rect2(745,y+28,190,45),"GELERNT" if learned[id] else ("VERSCHMELZEN" if can_fuse(f) else "GESPERRT"),can_fuse(f),learned[id])

func click_fusion(mouse:Vector2) -> void:
	for i in FUSIONS.size():
		if Rect2(745,223+i*118,190,45).has_point(mouse): buy_fusion(i);return

func draw_skill_star(center: Vector2, tint: Color, lit: bool) -> void:
	if lit: draw_rect(Rect2(center - Vector2(7, 7), Vector2(14, 14)), Color(tint, 0.2))
	draw_rect(Rect2(center + Vector2(-2, -6), Vector2(5, 13)), tint)
	draw_rect(Rect2(center + Vector2(-6, -2), Vector2(13, 5)), tint)
	draw_rect(Rect2(center + Vector2(-4, -4), Vector2(9, 9)), tint.darkened(0.15))
	if lit: draw_rect(Rect2(center + Vector2(-2, -3), Vector2(3, 3)), Color("fff8da"))

func draw_inventory_panel() -> void:
	text_at(Vector2(165, 125), "INVENTAR", 26, Color("ffeda9"))
	text_at(Vector2(758, 125), "%d / 42  ·  %d GOLD" % [inventory.size(), gold], 17, Color("f6dc9a"))
	ui_box(Rect2(165, 153, 450, 426), Color("16344b"))
	text_at(Vector2(183, 180), "DEIN HELD · LEVEL %d" % level, 19, Color("ffeda9"))
	# Die Figur steht groß zwischen genau drei Ausrüstungsplätzen.
	draw_rect(Rect2(296, 211, 195, 288), Color("16344b"))
	draw_rect(Rect2(302, 217, 183, 276), Color("16344b"))
	draw_rect(Rect2(337, 457, 113, 12), Color("1f3d43", 0.5))
	draw_character_sprite(Vector2(385,365),class_id,false,Vector2.DOWN,1.8)
	draw_weapon_world(Vector2(438,390),class_id,equipped_weapon_design(),Vector2.UP,1.15)
	draw_equipment_slot(Vector2(180,205),"KOPF",equipped_head_uid,"head")
	draw_equipment_slot(Vector2(180, 275), "WAFFE", equipped_uid, class_weapon_icon())
	draw_equipment_slot(Vector2(501, 235), "RÜSTUNG", equipped_armor_uid, "armor")
	draw_equipment_slot(Vector2(300, 440), "RING 1" if class_id == 1 else "RING", equipped_ring_uid, "ring")
	if class_id == 1: draw_equipment_slot(Vector2(405,440),"RING 2",equipped_ring2_uid,"ring")
	text_at(Vector2(186, 534), "HP %d  ·  ANGRIFF %d  ·  SCHUTZ %d" % [int(max_hp()), normal_attack_power(), equipment_power(equipped_armor_uid)], 15, Color("e6efdd"))
	ui_box(Rect2(625, 153, 352, 426), Color("16344b"))
	text_at(Vector2(644, 179), "INVENTAR · Doppelklick", 12, Color("ffeda9"))
	text_at(Vector2(807, 179), "%d/2" % (inventory_page + 1), 16)
	ui_button(Rect2(850, 157, 32, 30), "<", inventory_page > 0)
	ui_button(Rect2(931, 157, 32, 30), ">", inventory_page < 1)
	for cell in 25:
		var i := inventory_page * 25 + cell
		var col := cell % 5
		var row := cell / 5
		var pos := Vector2(641 + col * 65, 200 + row * 55)
		var is_equipped := i < inventory.size() and int(inventory[i]["uid"]) in equipped_item_uids()
		draw_rect(Rect2(pos, Vector2(54, 48)), Color("ffdda0") if is_equipped else (Color("e3c78c") if i == selected_item else Color("16344b")))
		draw_rect(Rect2(pos + Vector2(3, 3), Vector2(48, 42)), Color("16344b"))
		if i < inventory.size():
			var item: Dictionary = inventory[i]
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
		if item["icon"] in ["sword", "staff", "bow", "armor", "ring", "head"]: detail += " · +%d" % int(item["power"])
		text_at(Vector2(643, 518), detail, 13, Color("e5eddd"), HORIZONTAL_ALIGNMENT_LEFT, 320)
		var action_label := "MEISTERGABE NUTZEN" if bool(item.get("class_relic",false)) else ("ESSEN" if item["icon"] == "food" else "BENUTZEN")
		if item["icon"] in ["sword","staff","bow","armor","ring"]:
			action_label = "AUSZIEHEN" if is_equipped_uid(int(item.get("uid",-1))) else "AUSRÜSTEN"
		ui_button(Rect2(643, 538, 320, 42), action_label, bool(item.get("class_relic",false)) or item["icon"] in ["potion", "food", class_weapon_icon(), "armor", "ring"])
	else:
		text_at(Vector2(643, 508), "Wähle einen Gegenstand aus dem Inventar.", 14, Color("dbe8d5"))
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
	var equipped := equipped_uid if icon in ["sword", "bow", "staff"] else (equipped_head_uid if icon=="head" else (equipped_armor_uid if icon == "armor" else (equipped_ring_uid if icon == "ring" else -1)))
	if icon == "ring" and class_id == 1:
		var uid := int(item.get("uid",-1))
		if uid == equipped_ring2_uid: equipped = equipped_ring2_uid
		elif uid != equipped_ring_uid: equipped = -1 if equipped_ring_uid < 0 else equipped_ring2_uid
	var current := equipment_power(equipped)
	var worn: Dictionary = {}
	for candidate in inventory:
		if int(candidate.get("uid", -1)) == equipped:
			worn = candidate
			break
	if icon in ["sword", "staff", "bow", "armor", "ring", "head"]:
		var diff := int(item["power"]) - current
		var color := Color("83e4a0") if diff > 0 else (Color("ee8a86") if diff < 0 else Color("dfdcc3"))
		var stat_name := "Schaden" if icon in ["sword", "staff", "bow"] else ("Schutz" if icon == "armor" else "Leben")
		text_at(pos + Vector2(14, 93), "%s %d   %s%d" % [stat_name, int(item["power"]), "▲ +" if diff > 0 else ("▼ " if diff < 0 else "= "), diff], 14, color)
	if icon in ["potion", "gem", "herb", "essence", "food"]:
		var effect_name: String = "%s +65" % ("Mana" if class_id == 1 else "Energie") if String(item["name"]) in ["Energietrank", "Manatrank"] else ("HP +90" if String(item["name"]) == "Großer Heiltrank" else ("HP +45" if icon == "potion" else "Wertvolles Material"))
		if icon == "food":
			var nutrition := FoodSystem.by_name(str(item["name"]))
			effect_name = "+%d HP, %.1f HP/s (%ds)" % [nutrition.get("heal",0),nutrition.get("regen",0),nutrition.get("duration",0)]
		text_at(pos + Vector2(14, 120), effect_name, 14, Color("bfe4d8"))
		text_at(pos + Vector2(14, 145), "Im Stapel: %d / %s" % [int(item.get("count", 1)), "30" if icon == "food" else ("16" if icon == "potion" else "∞")], 13, Color("dfdcc3"))
	else:
		text_at(pos + Vector2(14, 120), "STÄ %d   BEW %d   INT %d" % [int(item.get("str", 0)), int(item.get("agi", 0)), int(item.get("int", 0))], 14, Color("bfe4d8"))
		var primary_key: String = ["str", "int", "agi"][class_id]
		var attribute_diff := int(item.get(primary_key, 0)) - int(worn.get(primary_key, 0))
		var arrow := "▲ +" if attribute_diff > 0 else ("▼ " if attribute_diff < 0 else "= ")
		text_at(pos + Vector2(14, 145), "%s für %s: %s%d" % [primary_key.to_upper(), CLASS_NAMES[class_id], arrow, attribute_diff], 13, Color("83e4a0") if attribute_diff > 0 else (Color("ee8a86") if attribute_diff < 0 else Color("dfdcc3")))
	var price_text := "Kaufpreis: %d Gold" % purchase_price if purchase_price >= 0 else "Verkauf: %d Gold" % item_sale_value(item)
	text_at(pos + Vector2(14, 171), price_text, 13, Color("f0d69b"))

func draw_item_signature(p: Vector2, item: Dictionary) -> void:
	if item.get("icon") == "food": return
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
	draw_rect(Rect2(p, Vector2(98, 77)), Color("e9cd90") if uid >= 0 else Color("8e774c"))
	draw_rect(Rect2(p + Vector2(3, 3), Vector2(92, 71)), Color("203c53"))
	var item: Dictionary = {}
	for candidate in inventory:
		if int(candidate.get("uid", -1)) == uid:
			item = candidate
			break
	if not item.is_empty():
		var actual_icon := str(item.get("icon",icon))
		draw_item_icon(p + Vector2(33, 4), actual_icon, RARITY_COLORS[int(item["rarity"])], 0.82, weapon_visual_stage(item), item_design(item))
		text_at(p + Vector2(5, 52), String(item["name"]).substr(0, 13), 11, RARITY_COLORS[int(item["rarity"])])
	else:
		text_at(p + Vector2(36, 35), "–", 19, Color("bacbd6"))
		text_at(p + Vector2(8, 52), "Leer", 11, Color("bacbd6"))
	text_at(p + Vector2(9, 66), label, 12, Color("fff0c3"))

func item_type(icon: String) -> String:
	match icon:
		"sword": return "Waffe"
		"staff": return "Stab"
		"bow": return "Bogen"
		"food": return "Nahrung"
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
	if skill_sprites != null:
		draw_skill_sprite(id, p + Vector2(2,2), size - 4.0)
	else:
		draw_rect(box.grow(-3), Color('6b8190'))
	var border := Color('f2cf83') if id == class_ultimate() else Color('8fa7a3')
	draw_rect(box, Color(border,0.35), false, 1)

func draw_shop_panel() -> void:
	var shop_name := "TORVALD (SCHMIED)" if merchant_kind == "smith" else ("PIP (ALCHEMIST)" if merchant_kind == "alchemy" else "FENNA (HÄNDLERIN)")
	text_at(Vector2(165, 125), shop_name, 25, Color("ffeda9"))
	text_at(Vector2(804, 126), "%d GOLD" % gold, 17, Color("f9dba0"))
	text_at(Vector2(169, 174), "KAUFEN · Neues Angebot in %d:%02d" % [int((420.0 - shop_timer) / 60.0), int(420.0 - shop_timer) % 60], 17, Color("e8f2de"))
	ui_button(Rect2(760,145,80,40),"<",shop_page>0)
	ui_button(Rect2(850,145,100,40),str(shop_page+1)+" / "+str(int((shop_stock[merchant_kind].size()+2)/3)),(shop_page+1)*3 < shop_stock[merchant_kind].size())
	var stock: Array = shop_stock[merchant_kind].slice(shop_page*3,shop_page*3+3)
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
		draw_item_icon(pos + Vector2(10, 3), String(inventory[i]["icon"]), RARITY_COLORS[int(inventory[i]["rarity"])], 0.85, weapon_visual_stage(inventory[i]), item_design(inventory[i]))
		draw_item_signature(pos + Vector2(10, 3), inventory[i])
		if int(inventory[i].get("count", 1)) > 1:
			draw_rect(Rect2(pos + Vector2(16, 24), Vector2(31, 13)), Color("202e35"))
			text_at(pos + Vector2(17, 35), "×%d" % int(inventory[i]["count"]), 11, Color("fff1c8"))
	if selected_item >= 0 and selected_item < inventory.size():
		var chosen: Dictionary = inventory[selected_item]
		text_at(Vector2(171, 592), "%s · %d Gold pro Stück" % [chosen["name"], int(chosen["value"])], 16, RARITY_COLORS[int(chosen["rarity"])])
	ui_button(Rect2(564, 562, 210, 39), "BESTÄTIGEN?" if sell_all_confirm else "ALLES VERKAUFEN")
	ui_button(Rect2(786, 562, 183, 39), "VERKAUFEN", selected_item >= 0)
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
		text_at(pos + Vector2(48, 57), "EMPF. LV %d · %s" % [region_level(zone), "REISEN" if available else "NICHT AKTIVIERT"], 13, Color("bfeee0") if available else Color("d2c0b6"))

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
		var group_suffix := " · GRUPPE" if not (party_state.get("members",[]) as Array).is_empty() and state == 1 else ""
		text_at(Vector2(180, y + 42), "%s %d/%d  ·  %d XP / %d Gold%s" % [ENEMY_TYPES[int(q["target"])]["name"], quests[id]["progress"], q["count"], q["xp"], q["gold"],group_suffix], 14, Color("d8e6d3"))
		text_at(Vector2(867, y + 29), status, 14, Color("fff0ad"))
	text_at(Vector2(170, 592), "Klicke eine Quest für Details. Mausrad / Pfeile: scrollen.", 15, Color("d9e6d5"))

	ui_button(Rect2(855,558,55,36),"↑")
	ui_button(Rect2(920,558,55,36),"↓")

func draw_map_panel() -> void:
	if konflux.active:
		text_at(Vector2(165,125),"KONFLUX · ARENAKARTE",24,Color("ffe0a4"))
		konflux.draw_map(self,Rect2(170,148,420,420),true)
		text_at(Vector2(610,175),"80.000 × 80.000 · vier Biome",17,Color("ffe0a4"))
		text_at(Vector2(610,205),"Cyan: geschützter Spawn",14,Color("a8f0dc"))
		text_at(Vector2(610,230),"Gold: betretbare Gebäude",14,Color("ffe4ad"))
		text_at(Vector2(610,255),"Orange: aktive Runenpunkte",14,Color("ffbe67"))
		text_at(Vector2(610,280),"Blau: Fluss · Linien: Brücken",14,Color("9bd0eb"))
		text_at(Vector2(610,305),"Konturen: erhöhte Terrassen",14,Color("e6d697"))
		for i in 4: text_at(Vector2(610,347+i*24),KonfluxMap.BIOMES[i]+" · "+KonfluxMap.NAMES[KonfluxMap.BUILDING_IDS[i]],12,KonfluxMap.COLORS[i].lightened(0.5))
		text_at(Vector2(610,475),"Spawnwegstein: Map 0",16,Color("ffe0a4"))
		text_at(Vector2(610,500),binding_short("interact")+" / "+binding_short("waystone")+": am Stein zurückreisen",12,Color("efe1bc"))
		text_at(Vector2(170,584),"Weiß: deine Position · Innenräume gehören zur Konflux-Karte",13,Color("efe1bc"))
		return
	text_at(Vector2(165, 125), "%s · EINGANG MARKIERT" % DUNGEON_NAMES[dungeon_id].to_upper() if dungeon_id >= 0 else "WELTKARTE · SONNENHAIN", 24, Color("ffe0a4"))
	draw_world_atlas(Rect2(167, 148, 800, 405))
	text_at(Vector2(168, 579),"Gelb blinkend: Questziel · Weiß: Du · Cyan: Wegstein · Stern: Boss",13,Color("efe1bc"))
	var quest_target: Dictionary = quest_guide.target(self)
	if not quest_target.is_empty(): text_at(Vector2(168,602),String(quest_target["label"]),14,Color("ffe34b"))

func draw_world_atlas(rect: Rect2) -> void:
	if konflux.active:
		konflux.draw_map(self,rect)
		return
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
		text_at(plaque.position + Vector2(3, 36), "EMPF. LV %d · %s" % [region_level(region), "OFFEN" if available else "BOSS-GESPERRT"], 10, Color("f6d48f") if available else Color("ffaca7"), HORIZONTAL_ALIGNMENT_CENTER, int(width - 6))
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

	for boss_index in 3:
		var boss_pos: Vector2 = CLASS_BOSS_SITES[boss_index]
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
	var party_members: Array = party_state.get("members",[])
	for member in party_members:
		if not member is Dictionary: continue
		if str(member.get("uuid","")) == player_uuid: continue
		if str(member.get("context","world")) != "world": continue
		var member_pos_data: Array = member.get("pos",[])
		if member_pos_data.size() < 2: continue
		var member_pos := Vector2(float(member_pos_data[0]),float(member_pos_data[1]))
		var party_marker := inset.position + member_pos*map_scale
		draw_circle(party_marker,6,Color("273740"))
		draw_arc(party_marker,5,0.0,TAU,16,Color("8ff1c1"),2)
	quest_guide.draw_on_map(self,inset,map_scale)
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
	if p==WAYSTONES[0]:
		SpawnPlatform32.core(self,p-Vector2(0,16))
		return
	var active := false
	for i in WAYSTONES.size():
		if p == WAYSTONES[i]: active = bool(waystone_unlocked[i])
	# Regionale Wegsteine sind bewusst fast so praesent wie der Spawn-Schrein.
	draw_set_transform(p-camera_pos,0,Vector2.ONE*2.05)
	draw_waystone_model(Vector2.ZERO,p)
	draw_set_transform(-camera_pos)
	# Sichtbarer Schutzring: dieselbe Flaeche wird serverseitig fuer Mob-Schutz genutzt.
	draw_arc(p-camera_pos+Vector2(0,10),WAYSTONE_SAFE_RADIUS,0,TAU,64,Color("8fe6df",0.18),3.0)
	text_at(p+Vector2(-160,-205),"WEGSTEIN · SCHUTZZONE",16,Color("fff1c9"),HORIZONTAL_ALIGNMENT_CENTER,320)

func draw_waystone_model(p: Vector2, stone_position: Vector2) -> void:
	var active := false
	for i in WAYSTONES.size():
		if stone_position == WAYSTONES[i]:
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

func static_chunk_keys(bounds: Rect2) -> Array:
	var keys: Array = []
	var first := Vector2i(floori(bounds.position.x/STATIC_CHUNK_SIZE),floori(bounds.position.y/STATIC_CHUNK_SIZE))
	var last := Vector2i(floori((bounds.end.x-1)/STATIC_CHUNK_SIZE),floori((bounds.end.y-1)/STATIC_CHUNK_SIZE))
	for x in range(maxi(0,first.x),last.x+1):
		for y in range(maxi(0,first.y),last.y+1): keys.append(Vector2i(x,y))
	return keys

func update_static_cache() -> void:
	if DisplayServer.get_name() == "headless": return
	if not performance_cache_enabled or arena_mode != "" or interior_id >= 0 or dungeon_id >= 0: return
	var needed := static_chunk_keys(Rect2(camera_pos,VIEW))
	var ahead := static_chunk_keys(Rect2(camera_pos,VIEW).grow(160))
	for key in ahead:
		if not needed.has(key): needed.append(key)
	var created := 0
	for key in needed:
		if static_chunks.has(key):
			static_chunks[key]["used"] = Engine.get_process_frames()
			continue
		if created >= 1: break
		if static_renderer_script == null: static_renderer_script = load("res://components/static_world_renderer.gd")
		var viewport := SubViewport.new()
		viewport.size = Vector2i(STATIC_CHUNK_SIZE,STATIC_CHUNK_SIZE)
		viewport.disable_3d = true
		viewport.gui_disable_input = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		var renderer = static_renderer_script.new()
		renderer.static_draw_bounds = Rect2(Vector2(key)*STATIC_CHUNK_SIZE,Vector2.ONE*STATIC_CHUNK_SIZE)
		renderer.camera_pos = renderer.static_draw_bounds.position
		renderer.font = font
		renderer.environment_tiles = environment_tiles
		renderer.region_tiles = region_tiles
		renderer.structure_tiles = structure_tiles
		renderer.touch_enabled = touch_enabled
		renderer.bindings = bindings.duplicate()
		viewport.add_child(renderer)
		add_child(viewport)
		static_chunks[key] = {"viewport":viewport,"texture":viewport.get_texture(),"created":Engine.get_process_frames(),"used":Engine.get_process_frames()}
		created += 1
	while static_chunks.size() > STATIC_CACHE_LIMIT:
		var oldest = null
		for key in static_chunks:
			if needed.has(key): continue
			if oldest == null or static_chunks[key]["used"] < static_chunks[oldest]["used"]: oldest = key
		if oldest == null: break
		static_chunks[oldest]["viewport"].queue_free()
		static_chunks.erase(oldest)

func draw_cached_overworld() -> bool:
	if not performance_cache_enabled: return false
	var keys := static_chunk_keys(Rect2(camera_pos,VIEW))
	for key in keys:
		if not static_chunks.has(key) or Engine.get_process_frames()-int(static_chunks[key]["created"]) < 2: return false
	for key in keys:
		draw_texture_rect(static_chunks[key]["texture"],Rect2(Vector2(key)*STATIC_CHUNK_SIZE,Vector2.ONE*STATIC_CHUNK_SIZE),false)
	return true

func invalidate_static_cache() -> void:
	for entry in static_chunks.values(): entry["viewport"].queue_free()
	static_chunks.clear()
	for entry in foreground_cache.values(): entry["viewport"].queue_free()
	for entry in foreground_cache.values(): entry["source"].queue_free()
	foreground_cache.clear()

func village_props() -> Array:
	var props: Array = []
	for house in house_positions(): props.append({"kind":"house","point":house,"depth":house.y+155})
	for tree in REFERENCE_TREES: props.append({"kind":"tree","point":tree,"depth":tree.y+9})
	props.append({"kind":"well","point":REFERENCE_WELL,"depth":REFERENCE_WELL.y+32})
	props.append({"kind":"board","point":Vector2(630,1250),"depth":1272.0})
	for p in [Vector2(350,1700),Vector2(1050,1900),Vector2(1320,2230)]: props.append({"kind":"fence","point":p,"depth":p.y+12})
	for p in [Vector2(544,1056),Vector2(1120,1056),Vector2(1305,1200),Vector2(1430,1200),Vector2(480,1530)]: props.append({"kind":"lamp","point":p,"depth":p.y+8})
	for p in [Vector2(460,940),Vector2(1220,1290),Vector2(520,1660),Vector2(1470,1215)]: props.append({"kind":"barrel","point":p,"depth":p.y+17})
	for p in [Vector2(510,880),Vector2(360,1180),Vector2(1300,750),Vector2(1580,1660),Vector2(430,1720)]: props.append({"kind":"bush","point":p,"depth":p.y+28})
	for shop in VillageLayout.SHOPS: props.append({"kind":"cart","point":shop["cart"],"depth":shop["cart"].y+24,"goods":shop["kind"]})
	return props

func prop_bounds(prop: Dictionary) -> Rect2:
	var p: Vector2 = prop["point"]
	match prop["kind"]:
		"house": return Rect2(p+Vector2(-16,-64),Vector2(224,256))
		"tree": return Rect2(p+Vector2(-88,-176),Vector2(176,208))
		"lamp": return Rect2(p+Vector2(-20,-88),Vector2(40,112))
		"barrel": return Rect2(p+Vector2(-24,-40),Vector2(48,80))
		"cart": return Rect2(p+Vector2(-52,-68),Vector2(132,108))
		"fence": return Rect2(p+Vector2(-16,-48),Vector2(144,80))
		"board": return Rect2(p+Vector2(-48,-94),Vector2(96,128))
		"well": return Rect2(p+Vector2(-64,-96),Vector2(128,144))
		_: return Rect2(p+Vector2(-64,-48),Vector2(128,96))

func paint_village_prop(prop: Dictionary) -> void:
	var p: Vector2 = prop["point"]
	match prop["kind"]:
		"house":
			draw_house(p)
			for shop in VillageLayout.SHOPS:
				if shop["house"] == p: StartScenery32.sign(self,p,shop["sign"],font)
		"tree":
			StartScenery32.tree(self,p,int(p.x+p.y))
			food_system.fruit(self,p,true)
		"well": StartScenery32.well(self,p)
		"board": StartScenery32.board(self,p)
		"lamp": StartScenery32.lamp(self,p)
		"barrel": StartScenery32.barrel(self,p)
		"fence": StartScenery32.fence(self,p,p+Vector2(100,0))
		"bush": food_system.bush(self,p)
		"cart": Wagon32.paint(self,p,prop["goods"])

func prop_cache_key(prop: Dictionary) -> String:
	return "%s:%d:%d" % [prop["kind"],prop["point"].x,prop["point"].y]

func update_foreground_cache() -> void:
	# Dorfobjekte werden direkt gezeichnet. Der frühere SubViewport-Cache konnte
	# bei WebGL transparente/fehlende Texturen festhalten und dadurch Häuser,
	# Händlerstände und weitere Props komplett verschwinden lassen.
	return
	var ahead := Rect2(camera_pos,VIEW).grow(200)
	var created := 0
	for prop in village_props():
		var bounds := prop_bounds(prop)
		if not bounds.intersects(ahead): continue
		var key := prop_cache_key(prop)
		if foreground_cache.has(key): continue
		if created >= 1: break
		if static_renderer_script == null: static_renderer_script = load("res://components/static_world_renderer.gd")
		var viewport := SubViewport.new()
		viewport.size = Vector2i(bounds.size)
		viewport.disable_3d = true
		viewport.gui_disable_input = true
		viewport.transparent_bg = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		var renderer = static_renderer_script.new()
		renderer.static_draw_bounds = bounds
		renderer.camera_pos = bounds.position
		renderer.font = font
		renderer.prop = prop
		viewport.add_child(renderer)
		add_child(viewport)
		var converted := SubViewport.new()
		converted.size = viewport.size
		converted.disable_3d = true
		converted.gui_disable_input = true
		converted.transparent_bg = true
		converted.render_target_update_mode = SubViewport.UPDATE_ONCE
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.texture = viewport.get_texture()
		var material := ShaderMaterial.new()
		material.shader = preload("res://components/cache_unpremultiply.gdshader")
		sprite.material = material
		converted.add_child(sprite)
		add_child(converted)
		foreground_cache[key] = {"source":viewport,"viewport":converted,"texture":converted.get_texture(),"bounds":bounds,"created":Engine.get_process_frames()}
		created += 1

func draw_cached_prop(prop: Dictionary) -> void:
	paint_village_prop(prop)

func draw_sorted_world_objects() -> void:
	var entries: Array = []
	if arena_mode == "" and dungeon_id < 0 and interior_id < 0:
		for prop in village_props():
			if prop_bounds(prop).intersects(current_static_bounds()): entries.append({"kind":"prop","depth":prop["depth"],"data":prop})
		# Die gezeichneten Fruchtpflanzen SIND die interaktiven FoodSystem-Punkte.
		for food_prop in food_system.regional_props(self):
			var food_point: Vector2 = food_prop["point"]
			if visible_world(food_point,140): entries.append({"kind":"food_plant","depth":food_prop["depth"],"data":food_prop})
		for npc in NPCS:
			if visible_world(npc["pos"],130): entries.append({"kind":"npc","depth":npc["pos"].y+24,"data":npc})
		for stone in WAYSTONES:
			if visible_world(stone,220): entries.append({"kind":"stone","depth":stone.y+70,"point":stone})
		if rescue_state >= 2:
			var p := RESCUE_POS+Vector2(0,120)
			if visible_world(p,130): entries.append({"kind":"npc","depth":p.y+24,"data":{"name":"Nela","role":"Bewohnerin","pos":p,"color":Color("bd8774"),"kind":"rescued"}})
	for enemy in enemies:
		if visible_world(enemy["pos"],100): entries.append({"kind":"enemy","depth":enemy["pos"].y+24,"data":enemy})
	for peer_id in remote_players:
		var state: Dictionary = remote_players[peer_id]
		if not state_matches_local_context(state): continue
		var p := network_player_position(peer_id)
		if visible_world(p,130): entries.append({"kind":"remote","depth":p.y+24,"peer":peer_id})
	entries.append({"kind":"player","depth":player_pos.y+24})
	entries.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return float(a["depth"])<float(b["depth"]))
	for entry in entries:
		match entry["kind"]:
			"prop": draw_cached_prop(entry["data"])
			"food_plant":
				var food_point: Vector2 = entry["data"]["point"]
				var plant_kind:=str(entry["data"].get("kind","fruit"))
				if plant_kind=="herb":
					var herb_name:=str(entry["data"].get("name","Kraut"))
					var herb_color:=str(entry["data"].get("color","8dbb78"))
					food_system.herb_bush(self,food_point,herb_name,herb_color)
					if player_pos.distance_to(food_point+Vector2(0,20)) < 120.0:
						text_at(food_point+Vector2(-105,42),"E · %s ernten" % herb_name,13,Color("d9f0b7"),HORIZONTAL_ALIGNMENT_CENTER,210)
				else:
					food_system.bush(self,food_point)
					if player_pos.distance_to(food_point+Vector2(0,20)) < 120.0:
						var food_id := int(food_system.plant_foods.get(FoodSystem.key(food_point),-1))
						if food_id >= 0:
							var food_name := str(FoodSystem.FOODS[food_id]["name"])
							text_at(food_point+Vector2(-95,42),"E · %s pfluecken" % food_name,13,Color("fff0b8"),HORIZONTAL_ALIGNMENT_CENTER,190)
			"npc": draw_npc(entry["data"])
			"stone": draw_waystone(entry["point"])
			"enemy": draw_enemy(entry["data"])
			"remote": draw_spawn_elevated_actor(int(entry["peer"]))
			"player": draw_spawn_elevated_actor(-1)

func class_weapon_icon_for(value: int) -> String:
	return ["sword", "staff", "bow"][clampi(value, 0, 2)]



func ensure_live_multiplayer() -> void:
	if dedicated_server_mode or creative_mode or konflux_preview_mode or multiplayer_smoke_client_mode or not character_created:
		return
	if network_mode == "client" and multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		return
	join_live_multiplayer()


@rpc("any_peer", "call_remote", "reliable")
func rpc_player_presence(state: Dictionary) -> void:
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0 or network_mode != "host": return
	var pos_data: Array = state.get("pos", [])
	var facing_data: Array = state.get("facing", [])
	if pos_data.size() < 2 or facing_data.size() < 2: return
	var incoming_pos := Vector2(float(pos_data[0]), float(pos_data[1]))
	if not incoming_pos.is_finite(): return
	var in_konflux: bool = konflux.fighter_stats.has(sender)
	var room_id: int = int(konflux.fighter_stats[sender]["room"]) if in_konflux else -1
	incoming_pos = incoming_pos.clamp(Vector2(30, 30), (KonfluxMap.SIZE if in_konflux else WORLD) - Vector2(30, 30))
	var protocol := int(state.get("protocol",-1))
	if protocol != NETWORK_PROTOCOL_VERSION: return
	var context := str(state.get("context","world"))
	if context not in ["world","tavern","dungeon","arena"]: context = "world"
	var instance_id := str(state.get("instance_id","world")).substr(0,24)
	if context == "world": instance_id = "world"
	if in_konflux:
		context = "konflux"
		instance_id = str(room_id)
	var clean_facing := Vector2(float(facing_data[0]), float(facing_data[1]))
	if not clean_facing.is_finite() or clean_facing.length_squared() < 0.01: clean_facing = Vector2.DOWN
	clean_facing = clean_facing.normalized()
	var clean := {
		"protocol":NETWORK_PROTOCOL_VERSION,
		"uuid":str(state.get("uuid","")).strip_edges().substr(0,64),
		"context":context,
		"instance_id":instance_id,
		"rescue_state":clampi(int(state.get("rescue_state",0)),0,3),
		"rescue_kills":clampi(int(state.get("rescue_kills",0)),0,RESCUE_GOAL),
		"active_quests":sanitize_active_quest_rows(state.get("active_quests",[])),
		"active_events":sanitize_active_event_rows(state.get("active_events",[])),
		"pos":[incoming_pos.x,incoming_pos.y],
		"facing":[clean_facing.x,clean_facing.y],
		"class":clampi(int(state.get("class",0)),0,2),
		"race":clampi(int(state.get("race",0)),0,2),
		"gender":clampi(int(state.get("gender",0)),0,1),
		"name":str(state.get("name","Held")).strip_edges().substr(0,16),
		"level":clampi(int(state.get("level",1)),1,99),
		"hp":clampf(float(state.get("hp",1.0)),0.0,100000.0),
		"max_hp":clampf(float(state.get("max_hp",1.0)),1.0,100000.0),
		"walking":bool(state.get("walking",false)),
		"weapon":clampi(int(state.get("weapon",0)),0,32),
		"armor":clampi(int(state.get("armor",-1)),-1,32),
		"head":clampi(int(state.get("head",-1)),-1,2),"rings":clampi(int(state.get("rings",0)),0,3),
		"element":str(state.get("element","")) if str(state.get("element","")) in ["","feuer","eis","blitz","gift"] else "",
		"region":region_at(incoming_pos),
		"stealth":bool(state.get("stealth",false)) and clampi(int(state.get("class",0)),0,2)==2
	}
	clean["konflux"] = in_konflux
	clean["room"] = room_id
	remote_players[sender] = clean
	server_restore_party_reconnect(sender)
	send_server_session_status(sender)
	send_server_world_manifest(sender)
	for peer_id in multiplayer.get_peers():
		if int(peer_id) != sender:
			rpc_receive_player_presence.rpc_id(int(peer_id), sender, clean)
	for existing_id in remote_players.keys():
		if int(existing_id) != sender:
			rpc_receive_player_presence.rpc_id(sender, int(existing_id), remote_players[existing_id])


@rpc("authority", "call_remote", "reliable")
func rpc_receive_player_presence(peer_id: int, state: Dictionary) -> void:
	if peer_id == multiplayer.get_unique_id(): return
	remote_players[peer_id] = state
	var coords: Array = state.get("pos",[])
	if coords.size() >= 2 and not remote_player_render_positions.has(peer_id):
		remote_player_render_positions[peer_id] = Vector2(float(coords[0]),float(coords[1]))
	remember_recent_player(state)
	queue_redraw()

@rpc("any_peer","call_remote","reliable")
func rpc_konflux_room(enabled: bool,target_room: int,to_start: bool = false) -> void:
	if network_mode!="host": return
	var peer:=multiplayer.get_remote_sender_id()
	if not remote_players.has(peer) or target_room < -1 or target_room>3: return
	var existing: Dictionary=remote_players[peer]
	var old: Vector2=network_player_position(peer)
	var was_in: bool=konflux.fighter_stats.has(peer)
	var old_room: int=int(konflux.fighter_stats[peer]["room"]) if was_in else -1
	var destination:=KonfluxMap.CENTER
	if enabled:
		if not was_in and int(existing.get("level",1)) < KONFLUX_MIN_LEVEL: return
		if not was_in and old.distance_to(KonfluxMap.ENTRANCE)>240: return
		if target_room>=0:
			if not was_in or old_room>=0 or old.distance_to(KonfluxMap.LOCATIONS[KonfluxMap.BUILDING_IDS[target_room]]+Vector2(0,50))>200: return
			destination=KonfluxMap.CENTER+Vector2(0,190)
		elif was_in and old_room>=0:
			if old.distance_to(KonfluxMap.CENTER+Vector2(0,215))>150: return
			destination=KonfluxMap.LOCATIONS[KonfluxMap.BUILDING_IDS[old_room]]+Vector2(0,110)
		elif was_in and not bool(konflux.fighter_stats[peer]["dead"]): return
	else:
		var exit_point := KonfluxMap.CENTER if to_start else KonfluxMap.CENTER+Vector2(0,360)
		if not was_in or old_room>=0 or old.distance_to(exit_point)>(185.0 if to_start else 240.0): return
		destination=WAYSTONES[0]+Vector2(0,105) if to_start else safe_world_teleport_destination(KonfluxMap.ENTRANCE,region_at(KonfluxMap.ENTRANCE))
	if was_in and enabled:
		konflux.fighter_stats[peer]["room"]=target_room
	else: konflux.register_fighter(peer,enabled,target_room)
	existing["pos"]=[destination.x,destination.y]
	existing["konflux"]=enabled
	existing["room"]=target_room
	existing["context"]="konflux" if enabled else "world"
	existing["instance_id"]=str(target_room) if enabled else "world"
	remote_players[peer]=existing
	rpc_konflux_transition.rpc_id(peer,enabled,target_room,[destination.x,destination.y])
	for other in multiplayer.get_peers():
		if int(other)!=peer: rpc_receive_player_presence.rpc_id(int(other),peer,existing)

@rpc("authority","call_remote","reliable")
func rpc_konflux_transition(enabled: bool,target_room: int,coords: Array) -> void:
	if coords.size()!=2 or target_room < -1 or target_room >= KonfluxMap.BUILDING_IDS.size(): return
	var destination := Vector2(float(coords[0]),float(coords[1]))
	if not destination.is_finite(): return
	if enabled:
		if destination.x < 20 or destination.y < 20 or destination.x > KonfluxMap.SIZE.x-20 or destination.y > KonfluxMap.SIZE.y-20: return
	else:
		if destination.x < 20 or destination.y < 20 or destination.x > WORLD.x-20 or destination.y > WORLD.y-20: return
	if enabled and not konflux.active:
		konflux.return_position=player_pos
		hp=max_hp()
		energy=max_energy()
	konflux.active=enabled
	konflux.room=target_room
	player_pos=destination
	camera_smooth=player_pos-VIEW*0.5
	camera_pos=camera_smooth
	push_player_state()

@rpc("any_peer","call_remote","reliable")
func rpc_konflux_attack(id: int,dir_data: Array) -> void:
	if network_mode!="host" or dir_data.size()!=2 or id < -1 or id>=ABILITIES.size(): return
	var peer:=multiplayer.get_remote_sender_id()
	if not remote_players.has(peer) or not konflux.fighter_stats.has(peer): return
	var state: Dictionary=remote_players[peer]
	var cls:=int(state.get("class",0))
	if id>=0 and (id not in CLASS_SKILLS[cls]+[CLASS_ULTIMATES[cls],4,6,8] or int(state.get("level",1))<int(ABILITIES[id]["req"])): return
	konflux.server_attack(self,peer,id,Vector2(dir_data[0],dir_data[1]),cls)

@rpc("any_peer","call_remote","reliable")
func rpc_konflux_dodge() -> void:
	if network_mode!="host": return
	var peer:=multiplayer.get_remote_sender_id()
	if not remote_players.has(peer) or not konflux.fighter_stats.has(peer): return
	var state: Dictionary=remote_players[peer]
	if int(state.get("class",0))==1 and int(state.get("level",1))<4: return
	var stats: Dictionary=konflux.fighter_stats[peer]
	if stats["dodge_cd"]>0 or stats["dead"]: return
	stats["dodge"]=0.38
	stats["dodge_cd"]=1.25

@rpc("authority","call_remote","reliable")
func rpc_konflux_health(value: float) -> void:
	if not konflux.active: return
	if max_hp()*clampf(value,0,100)/100<hp:hurt_until=combat_feedback.clock+.18
	hp=max_hp()*clampf(value,0,100)/100
	konflux.capture_id=-1
	if hp<=0:
		death_timer=DEATH_DURATION
		panel="death"
		dash_timer=0
		konflux.deaths+=1

@rpc("authority","call_remote","reliable")
func rpc_konflux_respawn() -> void:
	if not konflux.active: return
	konflux.room=-1
	player_pos=KonfluxMap.CENTER
	hp=max_hp()
	energy=max_energy()
	death_timer=0
	panel=""
	camera_smooth=player_pos-VIEW*0.5
	camera_pos=camera_smooth
	push_player_state()

@rpc("authority","call_remote","unreliable",1)
func rpc_konflux_snapshot(rows: Array,stats: Dictionary,arena_time: float,areas: Array,casts: Array) -> void:
	if not konflux.active: return
	konflux.time=arena_time
	konflux.fighter_stats=stats
	for target_peer in stats:
		if not remote_players.has(target_peer):continue
		var state:Dictionary=remote_players[target_peer]
		var target:Dictionary=stats[target_peer]
		var value:float=float(state.get("max_hp",1))*float(target.get("hp",100))/100
		if value<float(state.get("hp",value)):state["hurt_until"]=combat_feedback.clock+.18
		state["hp"]=value
		state["death_progress"]=clampf(1-float(target.get("respawn",DEATH_DURATION))/DEATH_DURATION,0,1) if bool(target.get("dead",false)) else -1.0
	konflux.shots.clear()
	for raw in rows:
		var row: Dictionary=raw.duplicate()
		row["pos"]=Vector2(row["pos"][0],row["pos"][1])
		row["dir"]=Vector2(row["dir"][0],row["dir"][1])
		konflux.shots.append(row)
	var peer:=multiplayer.get_unique_id()
	konflux.impacts.clear()
	for raw in areas:
		var area: Dictionary=raw.duplicate()
		area["pos"]=Vector2(area["pos"][0],area["pos"][1])
		konflux.impacts.append(area)
	konflux.cast_visuals.clear()
	for raw in casts:
		if int(raw.get("owner",-1))==peer: continue
		var cast: Dictionary=raw.duplicate()
		for key in ["pos","end","dir"]: cast[key]=Vector2(cast[key][0],cast[key][1])
		konflux.cast_visuals.append(cast)
	if stats.has(peer):
		konflux.kills=int(stats[peer].get("score",0))
		konflux.score=int(stats[peer].get("score",0))
		konflux.slow=float(stats[peer].get("slow",0))
		konflux.capture_id=int(stats[peer].get("capture",-1))
		konflux.capture_progress=float(stats[peer].get("capture_time",0))
		if not bool(stats[peer].get("dead",false)): hp=max_hp()*float(stats[peer]["hp"])/100.0

@rpc("any_peer","call_remote","reliable")
func rpc_konflux_capture(id: int) -> void:
	if network_mode!="host" or id<0 or id>=KonfluxMap.LOCATIONS.size() or id in KonfluxMap.BUILDING_IDS: return
	var peer:=multiplayer.get_remote_sender_id()
	if not konflux.fighter_stats.has(peer): return
	var stats: Dictionary=konflux.fighter_stats[peer]
	if stats["dead"] or stats["room"]>=0 or not konflux.active_event(id) or network_player_position(peer).distance_to(KonfluxMap.LOCATIONS[id])>260: return
	stats["capture"]=id
	stats["capture_time"]=0.0

@rpc("authority","call_remote","unreliable",2)
func rpc_konflux_correct(coords: Array) -> void:
	if not konflux.active or coords.size()!=2: return
	var target:=Vector2(coords[0],coords[1])
	if target.is_finite(): player_pos=target

func multiplayer_context() -> String:
	if konflux.active: return "konflux"
	if arena_mode != "": return "arena"
	if dungeon_id >= 0: return "dungeon"
	if interior_id >= 0: return "tavern"
	return "world"

func multiplayer_instance_id() -> String:
	if konflux.active: return str(konflux.room)
	match multiplayer_context():
		"arena": return arena_mode
		"dungeon": return str(dungeon_id)
		"tavern": return str(interior_id)
		_: return "world"

func uses_server_world() -> bool:
	if konflux.active: return false
	return network_mode == "client" and multiplayer_context() == "world"

func state_matches_local_context(state: Dictionary) -> bool:
	return str(state.get("context","world")) == multiplayer_context() and str(state.get("instance_id","world")) == multiplayer_instance_id()

func announce_multiplayer_context() -> void:
	if network_mode != "client" or multiplayer.multiplayer_peer == null or not character_created: return
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED: return
	rpc_player_presence.rpc_id(1, local_player_state())

func build_world_manifest() -> Dictionary:
	var entities: Array = []
	for i in NPCS.size():
		var npc: Dictionary = NPCS[i]
		var quest_ids: Array = []
		for q in QUESTS.size():
			if str(QUESTS[q].get("npc","")) == str(npc.get("name","")):
				quest_ids.append(q)
		entities.append({
			"id":"npc_%02d" % i,
			"type":"npc",
			"name":str(npc.get("name","")),
			"role":str(npc.get("role","")),
			"kind":str(npc.get("kind","")),
			"pos":[npc["pos"].x,npc["pos"].y],
			"quest_ids":quest_ids
		})
	for i in WORLD_EVENTS.size():
		var event: Dictionary = WORLD_EVENTS[i]
		entities.append({
			"id":"event_%02d" % i,
			"type":"quest_event",
			"name":str(event.get("name","")),
			"role":str(event.get("role","")),
			"kind":"quest",
			"pos":[event["pos"].x,event["pos"].y],
			"region":int(event.get("region",0))
		})
	return {"protocol":NETWORK_PROTOCOL_VERSION,"context":"world","entities":entities,"npc_count":NPCS.size(),"event_count":WORLD_EVENTS.size(),"quest_count":QUESTS.size()}

func server_party_members(peer_id: int) -> Array:
	if server_party_of_peer.has(peer_id):
		var party_id := int(server_party_of_peer[peer_id])
		if server_parties.has(party_id):
			return server_parties[party_id].duplicate()
	return [peer_id]

func server_party_member_rows(party_id: int) -> Array:
	var rows: Array = []
	if not server_parties.has(party_id): return rows
	for raw_peer in server_parties[party_id]:
		var peer_id := int(raw_peer)
		if not remote_players.has(peer_id): continue
		var state: Dictionary = remote_players[peer_id]
		rows.append({
			"peer_id":peer_id,
			"name":str(state.get("name","Held")),
			"class":int(state.get("class",0)),
			"level":int(state.get("level",1)),
			"uuid":str(state.get("uuid","")),
			"pos":state.get("pos",[0.0,0.0]),
			"hp":float(state.get("hp",1.0)),
			"max_hp":float(state.get("max_hp",1.0)),
			"context":str(state.get("context","world")),
			"instance_id":str(state.get("instance_id","world"))
		})
	return rows

func server_party_notice(peer_id: int, value: String) -> void:
	if peer_id > 0 and peer_id in multiplayer.get_peers():
		rpc_party_notice.rpc_id(peer_id,value.substr(0,120))

func server_send_party_state(peer_id: int) -> void:
	if peer_id <= 0 or peer_id not in multiplayer.get_peers(): return
	var payload := {"party_id":0,"leader":0,"members":[],"invite_from":0,"invite_name":""}
	if server_party_of_peer.has(peer_id):
		var party_id := int(server_party_of_peer[peer_id])
		var members := server_party_member_rows(party_id)
		payload["party_id"] = party_id
		payload["members"] = members
		payload["leader"] = int(server_parties[party_id][0]) if server_parties.has(party_id) and not server_parties[party_id].is_empty() else 0
	if server_party_invites.has(peer_id):
		var invite: Dictionary = server_party_invites[peer_id]
		if int(invite.get("expires",0)) >= Time.get_ticks_msec() and remote_players.has(int(invite.get("from",0))):
			var inviter := int(invite["from"])
			payload["invite_from"] = inviter
			payload["invite_name"] = str(remote_players[inviter].get("name","Held"))
		else:
			server_party_invites.erase(peer_id)
	rpc_party_state.rpc_id(peer_id,payload)

func server_broadcast_party(party_id: int) -> void:
	if not server_parties.has(party_id): return
	for raw_peer in server_parties[party_id]:
		server_send_party_state(int(raw_peer))

func server_find_peer_by_name(value: String) -> int:
	var wanted := value.strip_edges().to_lower()
	if wanted == "": return 0
	var found := 0
	for raw_peer in remote_players.keys():
		var peer_id := int(raw_peer)
		if str(remote_players[raw_peer].get("name","")).strip_edges().to_lower() == wanted:
			if found != 0: return -1
			found = peer_id
	return found

func server_remove_peer_from_party(peer_id: int) -> void:
	if not server_party_of_peer.has(peer_id):
		server_send_party_state(peer_id)
		return
	var party_id := int(server_party_of_peer[peer_id])
	server_party_of_peer.erase(peer_id)
	if not server_parties.has(party_id): return
	var members: Array = server_parties[party_id]
	members.erase(peer_id)
	if members.size() <= 1:
		if members.size() == 1:
			var remaining := int(members[0])
			server_party_of_peer.erase(remaining)
			server_party_notice(remaining,"Gruppe aufgelöst.")
			server_send_party_state(remaining)
		server_parties.erase(party_id)
	else:
		server_parties[party_id] = members
		server_broadcast_party(party_id)
	server_send_party_state(peer_id)

func server_relay_combat_visual(sender: int, payload: Dictionary) -> void:
	if network_mode != "host" or not remote_players.has(sender): return
	var source: Dictionary = remote_players[sender]
	var context := str(source.get("context","world"))
	var instance_id := str(source.get("instance_id","world"))
	var clean := payload.duplicate(true)
	clean["protocol"] = NETWORK_PROTOCOL_VERSION
	clean["server_time"] = Time.get_ticks_msec()
	for raw_peer in multiplayer.get_peers():
		var peer_id := int(raw_peer)
		if peer_id == sender or not remote_players.has(peer_id): continue
		var target: Dictionary = remote_players[peer_id]
		if str(target.get("context","world")) != context or str(target.get("instance_id","world")) != instance_id: continue
		rpc_remote_combat_visual.rpc_id(peer_id,sender,clean)

@rpc("any_peer","call_remote","reliable")
func rpc_party_command(command: Dictionary) -> void:
	if network_mode != "host": return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0 or not remote_players.has(sender): return
	var action := str(command.get("action",""))
	if action == "invite":
		var target_name := str(command.get("name","")).strip_edges().substr(0,16)
		var target := server_find_peer_by_name(target_name)
		if target == -1:
			server_party_notice(sender,"Mehrere Spieler haben diesen Namen.")
			return
		if target <= 0:
			server_party_notice(sender,"Spieler '%s' ist nicht online." % target_name)
			return
		if target == sender:
			server_party_notice(sender,"Du kannst dich nicht selbst einladen.")
			return
		if server_party_of_peer.has(target):
			server_party_notice(sender,"%s ist bereits in einer Gruppe." % str(remote_players[target].get("name","Held")))
			return
		if server_party_of_peer.has(sender):
			var existing_party := int(server_party_of_peer[sender])
			if server_parties.has(existing_party) and server_parties[existing_party].size() >= PARTY_MAX_MEMBERS:
				server_party_notice(sender,"Deine Gruppe ist bereits voll.")
				return
		server_party_invites[target] = {"from":sender,"expires":Time.get_ticks_msec()+30000}
		server_party_notice(sender,"Einladung an %s gesendet." % str(remote_players[target].get("name","Held")))
		server_party_notice(target,"%s lädt dich in eine Gruppe ein." % str(remote_players[sender].get("name","Held")))
		server_send_party_state(target)
	elif action == "accept":
		if not server_party_invites.has(sender):
			server_party_notice(sender,"Keine offene Gruppeneinladung.")
			return
		var invite: Dictionary = server_party_invites[sender]
		server_party_invites.erase(sender)
		if int(invite.get("expires",0)) < Time.get_ticks_msec():
			server_party_notice(sender,"Die Gruppeneinladung ist abgelaufen.")
			server_send_party_state(sender)
			return
		var inviter := int(invite.get("from",0))
		if inviter <= 0 or not remote_players.has(inviter):
			server_party_notice(sender,"Der einladende Spieler ist nicht mehr online.")
			server_send_party_state(sender)
			return
		var party_id := 0
		if server_party_of_peer.has(inviter):
			party_id = int(server_party_of_peer[inviter])
		else:
			party_id = server_next_party_id
			server_next_party_id += 1
			server_parties[party_id] = [inviter]
			server_party_of_peer[inviter] = party_id
		if not server_parties.has(party_id) or server_parties[party_id].size() >= PARTY_MAX_MEMBERS:
			server_party_notice(sender,"Die Gruppe ist inzwischen voll.")
			server_send_party_state(sender)
			return
		server_parties[party_id].append(sender)
		server_party_of_peer[sender] = party_id
		server_party_notice(sender,"Gruppe beigetreten. XP und Quest-Kills werden geteilt.")
		server_party_notice(inviter,"%s ist der Gruppe beigetreten." % str(remote_players[sender].get("name","Held")))
		server_broadcast_party(party_id)
	elif action == "decline":
		server_party_invites.erase(sender)
		server_party_notice(sender,"Gruppeneinladung abgelehnt.")
		server_send_party_state(sender)
	elif action == "leave":
		server_remove_peer_from_party(sender)

@rpc("authority","call_remote","reliable")
func rpc_party_state(state: Dictionary) -> void:
	party_state = state.duplicate(true)
	queue_redraw()

@rpc("authority","call_remote","reliable")
func rpc_party_notice(value: String) -> void:
	add_chat_line("GRUPPE",value)
	message(value)

@rpc("authority","call_remote","reliable")
func rpc_server_party_progress(payload: Dictionary) -> void:
	if network_mode != "client": return
	var tx_id := str(payload.get("tx","")).substr(0,96)
	if not remember_server_transaction(tx_id):
		ack_server_transaction(tx_id)
		return
	var xp_reward := clampi(int(payload.get("xp",0)),0,100000)
	var gold_reward := clampi(int(payload.get("gold",0)),0,100000)
	if xp_reward > 0: gain_xp(xp_reward)
	if gold_reward > 0: gold += gold_reward
	if xp_reward > 0 or gold_reward > 0:
		var reward_text:="+%d XP%s · Gruppenbelohnung" % [xp_reward," · +%d Gold" % gold_reward if gold_reward>0 else ""]
		message(reward_text);add_chat_line("GRUPPE",reward_text);save_game()
	ack_server_transaction(tx_id)

@rpc("authority","call_remote","reliable")
func rpc_remote_combat_visual(peer_id: int, payload: Dictionary) -> void:
	if multiplayer_smoke_client_mode:multiplayer_smoke_saw_attack=true
	if int(payload.get("protocol",-1)) != NETWORK_PROTOCOL_VERSION: return
	if peer_id == multiplayer.get_unique_id(): return
	if remote_players.has(peer_id) and not state_matches_local_context(remote_players[peer_id]): return
	var pos_data: Array = payload.get("pos",[])
	var dir_data: Array = payload.get("dir",[])
	if pos_data.size() < 2 or dir_data.size() < 2: return
	var pos := Vector2(float(pos_data[0]),float(pos_data[1]))
	var dir := Vector2(float(dir_data[0]),float(dir_data[1]))
	if not pos.is_finite() or not dir.is_finite() or dir.length_squared() < 0.01: return
	dir = dir.normalized()
	var remote_class:int=clampi(int(payload.get("class",0)),0,2)
	if str(payload.get("kind","normal"))=="ability" and int(payload.get("ability",-1)) in [3,7,16,18,20,25,26,28,29,30]:
		for shot in ability_projectiles(int(payload["ability"]),pos,dir,remote_class,0):
			shot["damage"]=0;shot["network_visual"]=true;shot["remote_owner"]=peer_id
			projectiles.append(shot)
		return
	if str(payload.get("kind","normal"))=="normal" and remote_class!=0:
		projectiles.append({"pos":pos,"dir":dir,"speed":650.0 if remote_class==2 else 520.0,"life":1.2,"damage":0,"kind":3 if remote_class==2 else 2,"element":str(payload.get("element","")),"hits":[],"network_visual":true,"remote_owner":peer_id})
		return
	remote_combat_visuals.append({
		"peer_id":peer_id,
		"kind":str(payload.get("kind","normal")),
		"ability":int(payload.get("ability",-1)),
		"class":clampi(int(payload.get("class",0)),0,2),
		"weapon":clampi(int(payload.get("weapon",0)),0,32),
		"element":str(payload.get("element","")),
		"pos":pos,
		"dir":dir,
		"life":0.42,
		"max":0.42
	})
	while remote_combat_visuals.size() > 40: remote_combat_visuals.pop_front()
	queue_redraw()

func send_server_session_status(peer_id: int) -> void:
	if network_mode != "host" or peer_id <= 0: return
	var state: Dictionary = remote_players.get(peer_id,{})
	rpc_server_session_status.rpc_id(peer_id,{
		"protocol":NETWORK_PROTOCOL_VERSION,
		"peer_id":peer_id,
		"online":remote_players.size(),
		"mobs":enemies.size(),
		"moving_mobs":server_moving_mobs,
		"context":str(state.get("context","world")),
		"instance_id":str(state.get("instance_id","world")),
		"npc_count":NPCS.size(),
		"event_count":WORLD_EVENTS.size(),
		"quest_count":QUESTS.size(),
		"party_size":server_party_members(peer_id).size() if server_party_of_peer.has(peer_id) else 1,
		"server_time":Time.get_ticks_msec()
	})

func send_server_world_manifest(peer_id: int) -> void:
	if network_mode != "host" or peer_id <= 0: return
	rpc_server_world_manifest.rpc_id(peer_id, build_world_manifest())

@rpc("authority", "call_remote", "reliable")
func rpc_server_session_status(status: Dictionary) -> void:
	server_last_reply_ms = Time.get_ticks_msec()
	server_sync_status = status.duplicate(true)
	var protocol := int(status.get("protocol",-1))
	if protocol != NETWORK_PROTOCOL_VERSION:
		network_status = "Protokollfehler · Client v%d / Server v%d" % [NETWORK_PROTOCOL_VERSION,protocol]
	else:
		network_status = "Online · Peer %d · %s:%s · %d online" % [int(status.get("peer_id",local_peer_id)),str(status.get("context","world")),str(status.get("instance_id","world")),int(status.get("online",1))]
	queue_redraw()

@rpc("authority", "call_remote", "reliable")
func rpc_server_world_manifest(manifest: Dictionary) -> void:
	if int(manifest.get("protocol",-1)) != NETWORK_PROTOCOL_VERSION: return
	server_world_manifest = manifest.duplicate(true)
	queue_redraw()

func draw_remote_combat_visuals() -> void:
	combat_feedback.draw(self)
	draw_mob_deaths()
	for visual in remote_combat_visuals:
		var pos: Vector2 = visual["pos"]
		var dir: Vector2 = visual["dir"]
		if not visible_world(pos,280): continue
		var life := float(visual.get("life",0.0))
		var max_life := maxf(0.01,float(visual.get("max",0.42)))
		var progress := 1.0-clampf(life/max_life,0.0,1.0)
		var cls := clampi(int(visual.get("class",0)),0,2)
		var accent: Color = [Color("ffd18a"),Color("b9b4ff"),Color("bce89e")][cls]
		var element := str(visual.get("element",""))
		if element != "": accent = element_color(element)
		if str(visual.get("kind","normal")) == "normal":
			if cls == 0:
				var angle := dir.angle()
				draw_arc(pos,68.0,angle-0.82,angle+0.82,18,Color(accent,0.85*(1.0-progress)),6.0)
				draw_line(pos+dir*18.0,pos+dir*83.0,Color.WHITE,3.0)
			else:
				var p := pos+dir*(35.0+progress*230.0)
				draw_line(p-dir*34.0,p+dir*12.0,Color(accent,0.85),6.0)
				draw_circle(p,7.0,Color.WHITE)
		else:
			var radius := 28.0+progress*96.0
			draw_circle(pos,radius,Color(accent,0.10*(1.0-progress)))
			draw_arc(pos,radius,0.0,TAU,28,Color(accent,0.88*(1.0-progress)),4.0)
			draw_line(pos,pos+dir*(70.0+progress*70.0),Color(accent,0.72*(1.0-progress)),7.0)

func party_widget_rect() -> Rect2:
	return Rect2((VIEW.x-300.0)*0.5,12.0,300.0,42.0)

func draw_party_widget() -> void:
	var invite_from := int(party_state.get("invite_from",0))
	var members: Array = party_state.get("members",[])
	if invite_from <= 0 and members.is_empty(): return
	var box := party_widget_rect()
	draw_rect(box,Color(0.03,0.08,0.10,0.88))
	draw_rect(box,Color("8bc7ad"),false,2.0)
	if invite_from > 0:
		text_at(box.position+Vector2(10,17),"GRUPPENEINLADUNG",12,Color("ffe0a1"))
		text_at(box.position+Vector2(10,34),"%s · klicken zum Antworten" % str(party_state.get("invite_name","Spieler")),12,Color("e7f2e8"))
	else:
		var member_names: Array[String] = []
		for row in members:
			if row is Dictionary: member_names.append(str(row.get("name","Held")))
		text_at(box.position+Vector2(10,17),"GRUPPE · %d/%d" % [members.size(),PARTY_MAX_MEMBERS],12,Color("ffe0a1"))
		text_at(box.position+Vector2(10,34),", ".join(member_names).substr(0,42),11,Color("e7f2e8"))

func draw_multiplayer_debug_overlay() -> void:
	if not is_web_platform() or network_mode == "offline" or not character_created: return
	var peer_id := multiplayer.get_unique_id() if multiplayer.multiplayer_peer != null else local_peer_id
	var box := Rect2(VIEW.x-265.0,8.0,253.0,39.0)
	draw_rect(box,Color(0.02,0.05,0.07,0.62))
	draw_rect(box,Color("78c7d9",0.55),false,1.0)
	text_at(box.position+Vector2(7,15),"NET v%d · #%d · %d online · %dms" % [NETWORK_PROTOCOL_VERSION,peer_id,int(server_sync_status.get("online",0)),maxi(0,network_ping_ms)],10,Color("d9f7ff"))
	text_at(box.position+Vector2(7,31),"%d Mobs · %d bewegen · Remote %d" % [int(server_sync_status.get("mobs",enemies.size())),int(server_sync_status.get("moving_mobs",0)),remote_players.size()],10,Color("d5dfb8"))

func draw_party_panel() -> void:
	text_at(Vector2(205,150),"GRUPPE",31,Color("ffe1a0"))
	text_at(Vector2(205,181),"XP und aktive Kill-Questfortschritte werden serverseitig geteilt.",13,Color("b9cbc3"))
	var invite_from := int(party_state.get("invite_from",0))
	var members: Array = party_state.get("members",[])
	if invite_from > 0:
		text_at(Vector2(205,235),"%s lädt dich in eine Gruppe ein." % str(party_state.get("invite_name","Spieler")),20,Color("e8efdc"))
		ui_button(Rect2(205,285,335,48),"ANNEHMEN")
		ui_button(Rect2(575,285,335,48),"ABLEHNEN")
	else:
		text_at(Vector2(205,225),"MITGLIEDER · %d/%d" % [members.size(),PARTY_MAX_MEMBERS],17,Color("e9cc90"))
		for i in members.size():
			var row: Dictionary = members[i]
			var y := 265.0+i*54.0
			draw_rect(Rect2(205,y-25,705,43),Color("203239",0.88))
			var cls := clampi(int(row.get("class",0)),0,2)
			var mhp := maxf(1.0,float(row.get("max_hp",1.0)))
			var hp_pct := int(clampf(float(row.get("hp",0.0))/mhp,0.0,1.0)*100.0)
			text_at(Vector2(220,y),"%s · %s · LV %d · HP %d%%" % [str(row.get("name","Held")),CLASS_NAMES[cls],int(row.get("level",1)),hp_pct],15,Color("fff0ce"))
			text_at(Vector2(650,y),"%s:%s" % [str(row.get("context","world")),str(row.get("instance_id","world"))],12,Color("a9beb7"),HORIZONTAL_ALIGNMENT_RIGHT,240)
		if members.size() > 0:
			ui_button(Rect2(205,510,335,46),"GRUPPE VERLASSEN")
		else:
			text_at(Vector2(205,285),"Im Chat: /invite Spielername",18,Color("dfe9dc"))
			text_at(Vector2(205,316),"Alternativ: /accept · /decline · /leave",13,Color("a9beb7"))
			text_at(Vector2(205,360),"ZULETZT GETROFFEN",14,Color("e9cc90"))
			for i in mini(4,recent_players.size()):
				var recent: Dictionary = recent_players[i]
				text_at(Vector2(220,388+i*24),"%s · %s · LV %d" % [str(recent.get("name","Held")),CLASS_NAMES[clampi(int(recent.get("class",0)),0,2)],int(recent.get("level",1))],12,Color("cfe2d9"))
	ui_button(Rect2(750,548,160,38),"SCHLIESSEN")

func _on_peer_disconnected(id: int) -> void:
	server_save_store.release(id)
	konflux.fighter_stats.erase(id)
	if network_mode == "host":
		server_reserve_party_reconnect(id)
		server_party_invites.erase(id)
		for target in server_party_invites.keys():
			if int(server_party_invites[target].get("from",0)) == id:
				server_party_invites.erase(target)
	remote_players.erase(id)
	remote_player_render_positions.erase(id)
	var action_prefix := "%d:" % id
	for key in server_action_times.keys():
		if str(key).begins_with(action_prefix):
			server_action_times.erase(key)
	add_chat_line("SYSTEM", "Spieler %d hat die Gruppe verlassen." % id)

func nearest_network_player(origin: Vector2, max_distance: float = INF, required_region: int = -1) -> Dictionary:
	var best_peer := 0
	var best_pos := Vector2.ZERO
	var best_distance := max_distance
	for raw_peer in remote_players.keys():
		var peer_id := int(raw_peer)
		if konflux.fighter_stats.has(peer_id): continue
		var state: Dictionary = remote_players[raw_peer]
		if str(state.get("context","world")) != "world": continue
		var pos := network_player_position(peer_id)
		if pos.x < -9000.0: continue
		if required_region >= 0 and region_at(pos) != required_region: continue
		var distance := origin.distance_to(pos)
		if distance < best_distance:
			best_distance = distance
			best_peer = peer_id
			best_pos = pos
	return {"peer":best_peer, "pos":best_pos, "distance":best_distance}

func draw_remote_players(only_peer: int=-1) -> void:
	if remote_players.is_empty(): return
	for peer_id in remote_players.keys():
		if only_peer >= 0 and peer_id != only_peer: continue
		var state: Dictionary = remote_players[peer_id]
		if state.get("konflux",false): continue
		if not state_matches_local_context(state): continue
		var coords: Array = state.get("pos", [0.0,0.0])
		if coords.size() < 2: continue
		var rp := network_player_position(int(peer_id))
		if not visible_world(rp, 120): continue
		var dir_data: Array = state.get("facing", [0.0,1.0])
		var rdir := Vector2(float(dir_data[0]),float(dir_data[1])) if dir_data.size() >= 2 else Vector2.DOWN
		var race := clampi(int(state.get("race",0)),0,2)
		var gender := clampi(int(state.get("gender",0)),0,1)
		var cls := clampi(int(state.get("class",0)),0,2)
		draw_circle(rp + Vector2(0, 10), 30.0, Color("76d7ff", 0.16))
		draw_arc(rp + Vector2(0, 10), 30.0, 0.0, TAU, 24, Color("8ee7ff", 0.82), 2.0)
		draw_rect(Rect2(rp + Vector2(-19,24),Vector2(38,5)),Color(0.10,0.17,0.18,0.25))
		draw_character_sprite(rp, cls, bool(state.get("walking",false)), rdir, 1.0, false, race, gender, int(state.get("armor",-1)),float(state.get("death_progress",-1.0)),clampf((float(state.get("hurt_until",0))-combat_feedback.clock)/.18,0,1),int(state.get("head",-1)),int(state.get("rings",0)))
		if float(state.get("hp",1))>0:draw_weapon_world(rp + Vector2(0,-5), cls, clampi(int(state.get("weapon",0)),0,11), rdir, 1.0)
		combat_feedback.health(self,"peer:%d"%int(peer_id),rp+Vector2(0,-43),float(state.get("hp",1)),float(state.get("max_hp",1)),60,Color("79caa3"))
		var party_peer_ids := local_party_peer_ids()
		var name_color := Color("ffe0a1") if int(peer_id) in party_peer_ids else Color("bfe7ff")
		text_at(rp + Vector2(-75,-57), "%s · LV %d" % [str(state.get("name","Freund")), int(state.get("level",1))], 13, name_color, HORIZONTAL_ALIGNMENT_CENTER, 150)

func ensure_player_uuid() -> void:
	if player_uuid != "": return
	player_uuid = "%08x-%08x-%08x" % [int(Time.get_unix_time_from_system()) & 0xffffffff, int(Time.get_ticks_usec()) & 0xffffffff, randi() & 0xffffffff]

func remember_recent_player(state: Dictionary) -> void:
	var uuid := str(state.get("uuid","")).strip_edges()
	if uuid == "" or uuid == player_uuid: return
	var row := {
		"uuid":uuid,
		"name":str(state.get("name","Held")).substr(0,16),
		"class":clampi(int(state.get("class",0)),0,2),
		"level":clampi(int(state.get("level",1)),1,99),
		"seen":int(Time.get_unix_time_from_system())
	}
	for i in range(recent_players.size()-1,-1,-1):
		if str(recent_players[i].get("uuid","")) == uuid:
			recent_players.remove_at(i)
	recent_players.push_front(row)
	while recent_players.size() > 12:
		recent_players.pop_back()

func update_network_interpolation(delta: float) -> void:
	if network_mode != "client": return
	var blend := 1.0-exp(-18.0*delta)
	for raw_peer in remote_players.keys():
		var peer_id := int(raw_peer)
		var state: Dictionary = remote_players[raw_peer]
		var coords: Array = state.get("pos",[])
		if coords.size() < 2: continue
		var target := Vector2(float(coords[0]),float(coords[1]))
		var current: Vector2 = remote_player_render_positions.get(peer_id,target)
		current = target if current.distance_to(target) > 320.0 else current.lerp(target,blend)
		remote_player_render_positions[peer_id] = current
	if uses_server_world():
		var mob_blend := 1.0-exp(-15.0*delta)
		for enemy in enemies:
			enemy["flash"]=maxf(0,float(enemy.get("flash",0))-delta)
			var attack:Dictionary=enemy.get("attack_state",{})
			if not attack.is_empty():attack["age"]=float(attack.get("age",0))+delta
			if not enemy.has("net_target_pos"): continue
			var target: Vector2 = enemy["net_target_pos"]
			var current: Vector2 = enemy["pos"]
			enemy["pos"] = target if current.distance_to(target) > 360.0 else current.lerp(target,mob_blend)

func export_save_backup() -> void:
	if not character_created: return
	save_game()
	var path := slot_save_path(active_save_slot,creative_mode)
	if not FileAccess.file_exists(path): return
	var payload := FileAccess.get_file_as_string(path)
	if is_web_platform():
		var filename := "sonnenhain_slot%d%s.json" % [active_save_slot,"_test" if creative_mode else ""]
		var bridge=JavaScriptBridge.get_interface("SonnenhainBrowser")
		if bridge==null or not bool(bridge.downloadBackup(payload,filename)):
			pause_status="Backup-Download konnte nicht gestartet werden."
			return
		pause_status = "Backup heruntergeladen."
	else:
		DisplayServer.clipboard_set(payload)
		pause_status = "Spielstand als JSON in die Zwischenablage kopiert."

func import_save_backup() -> void:
	if creative_mode:
		pause_status = "Import im Testmodus deaktiviert."
		return
	var raw := ""
	if is_web_platform():
		var result = JavaScriptBridge.get_interface("window").prompt("Sonnenhain-Backup JSON hier einfügen:","")
		if result == null: return
		raw = str(result).strip_edges()
	else:
		raw = DisplayServer.clipboard_get().strip_edges()
	if raw == "": return
	var parsed: Variant = JSON.parse_string(raw)
	if not parsed is Dictionary or not parsed.has("class_id") or not parsed.has("hero_name"):
		pause_status = "Ungültiges Sonnenhain-Backup."
		return
	var file := FileAccess.open(slot_save_path(active_save_slot),FileAccess.WRITE)
	if file == null:
		pause_status = "Backup konnte nicht importiert werden."
		return
	file.store_string(JSON.stringify(parsed))
	file.close()
	load_game()
	pause_status = "Backup importiert · %s · LV %d" % [hero_name,level]
	save_game()

func run_inventory_consistency_smoke() -> bool:
	var old_inventory := inventory.duplicate(true)
	var old_weapon := equipped_uid
	var old_armor := equipped_armor_uid
	var old_ring := equipped_ring_uid
	var old_ring2 := equipped_ring2_uid
	var old_next := next_uid
	inventory = []
	equipped_uid = -1
	equipped_armor_uid = -1
	equipped_ring_uid = -1
	equipped_ring2_uid = -1
	next_uid = 1
	var armor := make_item("Smoke Rüstung","armor",1,4,10)
	var ring := make_item("Smoke Ring","ring",1,8,10)
	var weapon := make_item("Smoke Waffe",class_weapon_icon(),1,7,10)
	if not add_item(armor) or not add_item(ring) or not add_item(weapon):
		return false
	var armor_index := 0
	toggle_equipment_item(armor_index)
	if equipped_armor_uid != int(inventory[armor_index].get("uid",-1)): return false
	toggle_equipment_item(armor_index)
	if equipped_armor_uid != -1: return false
	# Server-Loot mit absichtlich kollidierender UID muss lokal eine neue UID erhalten.
	var fake_server := weapon.duplicate(true)
	fake_server["uid"] = int(inventory[0].get("uid",-1))
	var sanitized := sanitize_network_reward_item(fake_server)
	if not add_item(sanitized): return false
	var seen: Dictionary = {}
	for item in inventory:
		var uid := int(item.get("uid",-1))
		if uid < 0 or seen.has(uid): return false
		seen[uid] = true
	# Shop-Kauf muss Gold exakt abbuchen und ein lokales, eindeutiges Item erzeugen.
	var old_gold := gold
	gold = 1000
	var before_count := inventory.size()
	var offer := {"name":"Smoke Kauf-Rüstung","icon":"armor","rarity":2,"power":9,"price":175,"level":5}
	buy_item(offer)
	if gold != 825 or inventory.size() != before_count+1: return false
	var bought_index := inventory.size()-1
	var bought_uid := int(inventory[bought_index].get("uid",-1))
	if bought_uid < 0: return false
	for j in inventory.size():
		if j != bought_index and int(inventory[j].get("uid",-1)) == bought_uid: return false
	toggle_equipment_item(bought_index)
	if equipped_armor_uid != bought_uid: return false
	var count_before_sell := inventory.size()
	var gold_before_sell := gold
	sell_item(bought_index)
	if inventory.size() != count_before_sell or gold != gold_before_sell: return false
	# Ausgerüstetes Item muss im Netzwerkstate als Rüstungsvisual auftauchen.
	var smoke_state := local_player_state()
	if int(smoke_state.get("armor",-1)) != armor_visual(): return false
	toggle_equipment_item(bought_index)
	if equipped_armor_uid != -1: return false
	sell_item(bought_index)
	if inventory.size() != count_before_sell-1: return false
	gold = old_gold
	inventory = old_inventory
	equipped_uid = old_weapon
	equipped_armor_uid = old_armor
	equipped_ring_uid = old_ring
	equipped_ring2_uid = old_ring2
	next_uid = old_next
	validate_equipment_slots()
	print("INVENTORY_SMOKE_OK unique_uids=true toggle_armor=true buy=true equipped_sell_block=true server_loot_local_uid=true loadout_state=true tx_dedupe=persistent")
	return true

func server_reserve_party_reconnect(peer_id: int) -> void:
	if not server_party_of_peer.has(peer_id): return
	var party_id := int(server_party_of_peer[peer_id])
	var uuid := str(remote_players.get(peer_id,{}).get("uuid",""))
	server_party_of_peer.erase(peer_id)
	if server_parties.has(party_id):
		var members: Array = server_parties[party_id]
		members.erase(peer_id)
		server_parties[party_id] = members
	if uuid != "":
		server_party_reconnect[uuid] = {"party_id":party_id,"expires":Time.get_ticks_msec()+45000}
	if server_parties.has(party_id):
		server_broadcast_party(party_id)

func server_restore_party_reconnect(peer_id: int) -> void:
	if not remote_players.has(peer_id): return
	var uuid := str(remote_players[peer_id].get("uuid",""))
	if uuid == "" or not server_party_reconnect.has(uuid): return
	var reservation: Dictionary = server_party_reconnect[uuid]
	if int(reservation.get("expires",0)) < Time.get_ticks_msec():
		server_party_reconnect.erase(uuid)
		return
	var party_id := int(reservation.get("party_id",0))
	if party_id <= 0 or not server_parties.has(party_id) or server_parties[party_id].size() >= PARTY_MAX_MEMBERS:
		server_party_reconnect.erase(uuid)
		return
	server_parties[party_id].append(peer_id)
	server_party_of_peer[peer_id] = party_id
	server_party_reconnect.erase(uuid)
	server_party_notice(peer_id,"Gruppe nach Reconnect wiederhergestellt.")
	server_broadcast_party(party_id)

func cleanup_party_reconnects() -> void:
	var now := Time.get_ticks_msec()
	for uuid in server_party_reconnect.keys():
		if int(server_party_reconnect[uuid].get("expires",0)) < now:
			server_party_reconnect.erase(uuid)
	for party_id in server_parties.keys():
		var members: Array = server_parties[party_id]
		var has_reservation := false
		for reservation in server_party_reconnect.values():
			if int(reservation.get("party_id",0)) == int(party_id):
				has_reservation = true
				break
		if members.is_empty() and not has_reservation:
			server_parties.erase(party_id)
		elif members.size() == 1 and not has_reservation:
			var remaining := int(members[0])
			server_party_of_peer.erase(remaining)
			server_parties.erase(party_id)
			server_party_notice(remaining,"Gruppe aufgelöst.")
			server_send_party_state(remaining)

@rpc("any_peer","call_remote","unreliable")
func rpc_client_ping(client_stamp: int) -> void:
	if network_mode != "host": return
	var sender := multiplayer.get_remote_sender_id()
	if sender > 0:
		rpc_server_pong.rpc_id(sender,client_stamp)

@rpc("authority","call_remote","unreliable")
func rpc_server_pong(client_stamp: int) -> void:
	server_last_reply_ms = Time.get_ticks_msec()
	network_ping_ms = clampi(Time.get_ticks_msec()-client_stamp,0,9999)
	queue_redraw()

@rpc("authority","call_remote","reliable")
func rpc_server_hit_confirm(payload: Dictionary) -> void:
	var pos_data: Array = payload.get("pos",[])
	if pos_data.size() < 2: return
	var pos := Vector2(float(pos_data[0]),float(pos_data[1]))
	var uid := int(payload.get("uid",-1))
	for enemy in enemies:
		if int(enemy.get("uid",-2)) == uid:
			enemy["flash"] = 0.18
			enemy["hp"]=clampf(float(payload.get("hp",enemy["hp"])),0,float(enemy["max_hp"]))
			break
	effect(pos+Vector2(0,-30),"-%d" % int(payload.get("damage",0)),Color("fff1a1"),0.55)

func server_broadcast_hit_confirm(source_peer: int, enemy: Dictionary, damage: int) -> void:
	if network_mode != "host": return
	var payload := {"uid":int(enemy.get("uid",-1)),"pos":[enemy["pos"].x,enemy["pos"].y],"damage":damage,"hp":maxf(0.0,float(enemy.get("hp",0.0)))}
	for raw_peer in multiplayer.get_peers():
		var peer_id := int(raw_peer)
		if remote_players.has(peer_id) and str(remote_players[peer_id].get("context","world")) == "world":
			rpc_server_hit_confirm.rpc_id(peer_id,payload)

func inventory_uid_exists(uid: int) -> bool:
	if uid < 0: return false
	for owned in inventory:
		if int(owned.get("uid",-1)) == uid:
			return true
	return false

func assign_fresh_item_uid(item: Dictionary) -> void:
	while inventory_uid_exists(next_uid):
		next_uid += 1
	item["uid"] = next_uid
	next_uid += 1

func item_icon_for_uid(uid: int) -> String:
	if uid < 0: return ""
	for item in inventory:
		if int(item.get("uid",-1)) == uid:
			return str(item.get("icon",""))
	return ""

func validate_equipment_slots() -> void:
	if head_visual()!=class_id:equipped_head_uid=-1
	var weapon_icon := item_icon_for_uid(equipped_uid)
	if equipped_uid >= 0 and (weapon_icon == "" or weapon_icon != class_weapon_icon()):
		equipped_uid = -1
	if equipped_armor_uid >= 0 and item_icon_for_uid(equipped_armor_uid) != "armor":
		equipped_armor_uid = -1
	if equipped_ring_uid >= 0 and item_icon_for_uid(equipped_ring_uid) != "ring":
		equipped_ring_uid = -1
	if class_id != 1 or item_icon_for_uid(equipped_ring2_uid) != "ring" or equipped_ring2_uid == equipped_ring_uid: equipped_ring2_uid = -1
	hp = minf(hp,max_hp())

func is_equipped_uid(uid: int) -> bool:
	return uid >= 0 and uid in equipped_item_uids()

func head_visual() -> int:
	for item in inventory:
		if int(item.get("uid",-1))==equipped_head_uid and str(item.get("icon",""))=="head":
			return int(item.get("head_class",-1))
	return -1

func rare_head_reward(source:String,index:int,chance:float) -> bool:
	var rng:=RandomNumberGenerator.new()
	rng.seed=abs((player_uuid+":"+source+":"+str(index)).hash())
	return rng.randf()<chance

func make_class_head(item_level:int) -> Dictionary:
	var names:Array=["Helm der Morgenwacht","Hut des Erzmagiers","Haube des Falken"]
	var item:Dictionary=make_item(names[class_id],"head",4,0,0,"",maxi(1,item_level))
	item["head_class"]=class_id
	item[["str","int","agi"][class_id]]=12+int(item_level/4)
	item["design"]=class_id
	return item

func toggle_equipment_item(index: int) -> bool:
	if index < 0 or index >= inventory.size(): return false
	var item: Dictionary = inventory[index]
	var uid := int(item.get("uid",-1))
	var icon := str(item.get("icon",""))
	if icon=="head":
		if int(item.get("head_class",-1))!=class_id:
			message("Diese Kopfbedeckung gehört einer anderen Klasse.")
			return true
		equipped_head_uid=-1 if equipped_head_uid==uid else uid
		validate_equipment_slots()
		save_game()
		announce_multiplayer_context()
		return true
	if icon in ["sword","staff","bow"]:
		if icon != class_weapon_icon():
			message("%s kann nur %s ausrüsten." % [CLASS_NAMES[class_id], {"sword":"Schwerter","staff":"Stäbe","bow":"Bögen"}[class_weapon_icon()]])
			return true
		if equipped_uid == uid:
			equipped_uid = -1
			message("Ausgezogen: %s" % str(item.get("name","Waffe")))
		else:
			equipped_uid = uid
			message("Ausgerüstet: %s (+%d Schaden)" % [str(item.get("name","Waffe")),int(item.get("power",0))])
		save_game()
		announce_multiplayer_context()
		return true
	if icon == "armor":
		if equipped_armor_uid == uid:
			equipped_armor_uid = -1
			message("Ausgezogen: %s" % str(item.get("name","Rüstung")))
		else:
			equipped_armor_uid = uid
			message("Ausgerüstet: %s (%d Schutz)" % [str(item.get("name","Rüstung")),int(item.get("power",0))])
		save_game()
		announce_multiplayer_context()
		return true
	if icon == "ring":
		var old_max := max_hp()
		var removing := uid in [equipped_ring_uid,equipped_ring2_uid]
		if equipped_ring_uid == uid: equipped_ring_uid = -1
		elif equipped_ring2_uid == uid: equipped_ring2_uid = -1
		elif equipped_ring_uid < 0: equipped_ring_uid = uid
		elif class_id == 1: equipped_ring2_uid = uid
		else: equipped_ring_uid = uid
		validate_equipment_slots()
		hp = minf(max_hp(),hp+maxf(0,max_hp()-old_max))
		message(("Ausgezogen: " if removing else "Ausgerüstet: ")+str(item.get("name","Ring")))
		save_game()
		announce_multiplayer_context()
		return true
	return false

func unequip_slot(slot: String) -> void:
	match slot:
		"weapon": equipped_uid = -1
		"head": equipped_head_uid = -1
		"armor": equipped_armor_uid = -1
		"ring2": equipped_ring2_uid = -1
		"ring":
			equipped_ring_uid = -1
			hp = minf(hp,max_hp())
	validate_equipment_slots()
	save_game()
	announce_multiplayer_context()

func sanitize_network_reward_item(raw: Dictionary) -> Dictionary:
	var item: Dictionary = raw.duplicate(true)
	item.erase("uid")
	var icon := str(item.get("icon","gem"))
	if icon not in ["sword","staff","bow","armor","ring","potion","gem","herb","essence","food"]:
		item["icon"] = "gem"
	item["rarity"] = clampi(int(item.get("rarity",0)),0,4)
	item["power"] = clampi(int(item.get("power",0)),0,10000)
	item["count"] = clampi(int(item.get("count",1)),1,stack_limit(item))
	item["name"] = str(item.get("name","Fundstück")).substr(0,48)
	item["element"] = str(item.get("element","")) if str(item.get("element","")) in ["","feuer","eis","blitz","gift"] else ""
	if bool(item.get("class_relic",false)):
		item["class_relic"]=true
		item["mastery_class"]=clampi(int(item.get("mastery_class",-1)),0,2)
		item["mastery_skill"]=CLASS_RELIC_SKILLS[int(item["mastery_class"])]
	else:
		item.erase("mastery_class");item.erase("mastery_skill")
	if bool(item.get("boss_hat",false)):
		item["boss_hat"]=true
		item["head_class"]=clampi(int(item.get("head_class",-1)),0,2)
		item["design"]=int(item["head_class"])
	return item

func apply_rescue_progress(amount: int, shared: bool = false) -> void:
	if rescue_state != 1 or amount <= 0: return
	rescue_kills = mini(RESCUE_GOAL,rescue_kills+amount)
	if rescue_kills >= RESCUE_GOAL:
		rescue_state = 2
		rescue_banner_timer = 6.0
		rescue_intro_timer = 5.0
		effect(RESCUE_POS+Vector2(0,-210),"BLÜTENWEILER GERETTET",Color("a8edb5"),5.0)
		message(("Gemeinsam gerettet! " if shared else "")+"Blütenweiler gerettet! Nela wartet am Dorfplatz auf dich (E).")
		play_sound("level")
	else:
		message("%sBlütenweiler verteidigt: %d/%d Dornenwesen besiegt." % ["Gruppe · " if shared else "",rescue_kills,RESCUE_GOAL])
	save_game()
	if network_mode == "client":
		announce_multiplayer_context()

@rpc("authority","call_remote","reliable")
func rpc_server_rescue_progress(amount: int, shared: bool) -> void:
	if network_mode != "client": return
	apply_rescue_progress(clampi(amount,0,RESCUE_GOAL),shared)

func run_rescue_quest_consistency_smoke() -> bool:
	var old_state := rescue_state
	var old_kills := rescue_kills
	var old_network := network_mode
	rescue_state = 1
	rescue_kills = RESCUE_GOAL-1
	network_mode = "offline"
	apply_rescue_progress(1,true)
	var ok := rescue_state == 2 and rescue_kills == RESCUE_GOAL
	rescue_state = old_state
	rescue_kills = old_kills
	network_mode = old_network
	if ok:
		print("RESCUE_SMOKE_OK transition=19_to_20 group_progress=true")
	return ok

func network_reward_payload(item: Dictionary) -> Dictionary:
	var payload: Dictionary = item.duplicate(true)
	payload.erase("uid")
	# Identität eines Inventargegenstands gehört ausschließlich dem Browser-Save.
	payload.erase("stack_value")
	return payload

func server_rescue_active_peers() -> Array:
	var peers: Array = []
	for raw_peer in remote_players.keys():
		var peer_id := int(raw_peer)
		var state: Dictionary = remote_players[raw_peer]
		if str(state.get("context","world")) != "world": continue
		if int(state.get("rescue_state",0)) != 1: continue
		var pos := network_player_position(peer_id)
		if pos.x < -9000.0 or pos.distance_to(RESCUE_POS) > 850.0: continue
		peers.append(peer_id)
	return peers

func update_dedicated_rescue_spawns() -> void:
	if network_mode != "host": return
	var peers := server_rescue_active_peers()
	if peers.is_empty(): return
	var active := 0
	for enemy in enemies:
		if bool(enemy.get("invasion",false)): active += 1
	if active >= 5: return
	var min_kills := RESCUE_GOAL
	for raw_peer in peers:
		min_kills = mini(min_kills,int(remote_players[int(raw_peer)].get("rescue_kills",0)))
	var needed := mini(5-active,maxi(0,RESCUE_GOAL-min_kills-active))
	if needed <= 0: return
	var positions := [Vector2(-250,-40),Vector2(230,-70),Vector2(-220,140),Vector2(240,130),Vector2(0,310)]
	for n in needed:
		var spot: Vector2 = RESCUE_POS+positions[(min_kills+active+n)%positions.size()]
		if terrain_blocked(spot): continue
		var kind := (min_kills+active+n)%2
		var info: Dictionary = ENEMY_TYPES[kind]
		var mob := make_enemy(kind,spot)
		var enemy_hp := float(info["hp"])*1.4
		mob["hp"] = enemy_hp
		mob["max_hp"] = enemy_hp
		mob["invasion"] = true
		mob["context"] = "world"
		mob["instance_id"] = "world"
		mob["uid"] = server_next_mob_uid
		server_next_mob_uid += 1
		enemies.append(mob)

func server_send_rescue_progress(killer_peer: int, enemy: Dictionary) -> void:
	if not bool(enemy.get("invasion",false)) or killer_peer <= 0: return
	var recipients := server_party_members(killer_peer)
	for raw_peer in recipients:
		var peer_id := int(raw_peer)
		if not remote_players.has(peer_id) or not server_party_member_eligible(peer_id,killer_peer,enemy): continue
		var state: Dictionary = remote_players[peer_id]
		if int(state.get("rescue_state",0)) != 1: continue
		if str(state.get("context","world")) != "world": continue
		rpc_server_rescue_progress.rpc_id(peer_id,1,peer_id != killer_peer)

func local_player_state() -> Dictionary:
	ensure_player_uuid()
	return {"protocol":NETWORK_PROTOCOL_VERSION, "uuid":player_uuid, "context":multiplayer_context(), "instance_id":multiplayer_instance_id(), "rescue_state":rescue_state, "rescue_kills":rescue_kills, "active_quests":active_quest_sync_rows(), "active_events":active_event_sync_rows(), "pos":[player_pos.x,player_pos.y], "facing":[facing.x,facing.y], "class":class_id, "race":hero_race, "gender":hero_gender, "name":hero_name, "level":level, "hp":hp, "max_hp":max_hp(), "teleport_serial":teleport_serial,"death_progress":1.0-death_timer/DEATH_DURATION if hp<=0 else -1.0, "walking":is_walking, "weapon":equipped_weapon_design(), "armor":armor_visual(), "head":head_visual(),"rings":ring_visual(), "element":weapon_element(), "region":region_at(player_pos), "stealth":class_id==2 and class_mastery_unlocked and ranger_stealth_timer>0.0, "konflux":konflux.active, "room":konflux.room}

@rpc("authority","call_remote","reliable")
func rpc_server_quest_progress(payload: Dictionary) -> void:
	if network_mode != "client": return
	apply_server_quest_progress(payload)

func active_quest_sync_rows() -> Array:
	var rows: Array = []
	for i in mini(QUESTS.size(),quests.size()):
		var row: Dictionary = quests[i]
		if int(row.get("state",0)) == 1:
			rows.append([i,clampi(int(row.get("progress",0)),0,int(QUESTS[i]["count"]))])
	return rows

func active_event_sync_rows() -> Array:
	var rows: Array = []
	for i in mini(WORLD_EVENTS.size(),event_states.size()):
		if int(event_states[i]) == 1:
			rows.append([i,clampi(int(event_progress[i]),0,int(WORLD_EVENTS[i]["goal"]))])
	return rows

func sanitize_active_quest_rows(raw: Variant) -> Array:
	var out: Array = []
	if not raw is Array: return out
	var seen: Dictionary = {}
	for entry in raw:
		if not entry is Array or entry.size() < 2: continue
		var quest_id := int(entry[0])
		if quest_id < 0 or quest_id >= QUESTS.size() or seen.has(quest_id): continue
		seen[quest_id] = true
		out.append([quest_id,clampi(int(entry[1]),0,int(QUESTS[quest_id]["count"]))])
	return out

func sanitize_active_event_rows(raw: Variant) -> Array:
	var out: Array = []
	if not raw is Array: return out
	var seen: Dictionary = {}
	for entry in raw:
		if not entry is Array or entry.size() < 2: continue
		var event_id := int(entry[0])
		if event_id < 0 or event_id >= WORLD_EVENTS.size() or seen.has(event_id): continue
		seen[event_id] = true
		out.append([event_id,clampi(int(entry[1]),0,int(WORLD_EVENTS[event_id]["goal"]))])
	return out

func server_transaction_seen(tx_id: String) -> bool:
	return tx_id != "" and tx_id in processed_server_transactions

func remember_server_transaction(tx_id: String) -> bool:
	if tx_id == "" or server_transaction_seen(tx_id): return false
	processed_server_transactions.append(tx_id)
	while processed_server_transactions.size() > 256:
		processed_server_transactions.pop_front()
	return true

func ack_server_transaction(tx_id: String) -> void:
	if tx_id == "" or network_mode != "client" or multiplayer.multiplayer_peer == null: return
	if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		rpc_client_transaction_ack.rpc_id(1,tx_id.substr(0,96))

func server_register_transaction(peer_id: int, tx_id: String) -> void:
	if peer_id <= 0 or tx_id == "": return
	server_pending_transactions["%d:%s" % [peer_id,tx_id]] = Time.get_ticks_msec()+15000

@rpc("any_peer","call_remote","reliable")
func rpc_client_transaction_ack(tx_id: String) -> void:
	if network_mode != "host": return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0: return
	server_pending_transactions.erase("%d:%s" % [sender,tx_id.substr(0,96)])

func announce_quest_state() -> void:
	if network_mode == "client":
		announce_multiplayer_context()

func apply_server_quest_progress(payload: Dictionary) -> bool:
	var tx_id := str(payload.get("tx","")).substr(0,96)
	if not remember_server_transaction(tx_id):
		ack_server_transaction(tx_id)
		return false
	var changed := false
	var shared := bool(payload.get("shared",false))
	if payload.has("boss"): changed=register_boss_defeat(int(payload["boss"]),shared)
	for raw_id in (payload.get("quests",[]) as Array):
		var quest_id := int(raw_id)
		if quest_id < 0 or quest_id >= quests.size(): continue
		var quest: Dictionary = quests[quest_id]
		if int(quest.get("state",0)) != 1: continue
		quest["progress"] = mini(int(QUESTS[quest_id]["count"]),int(quest.get("progress",0))+1)
		changed = true
		if int(quest["progress"]) >= int(QUESTS[quest_id]["count"]):
			quest["state"] = 2
			message("%sQuestziel erreicht: %s. Kehre zurück!" % ["Gruppe · " if shared else "",QUESTS[quest_id]["title"]])
		changed = true
	for raw_id in (payload.get("events",[]) as Array):
		var event_id := int(raw_id)
		if event_id < 0 or event_id >= event_states.size(): continue
		if int(event_states[event_id]) != 1: continue
		event_progress[event_id] = mini(int(WORLD_EVENTS[event_id]["goal"]),int(event_progress[event_id])+1)
		changed = true
		if int(event_progress[event_id]) >= int(WORLD_EVENTS[event_id]["goal"]):
			event_states[event_id] = 2
			message("%s%s ist in Sicherheit! Sprich erneut mit %s (E)." % ["Gruppe · " if shared else "",WORLD_EVENTS[event_id]["role"],WORLD_EVENTS[event_id]["name"]])
			play_sound("level")
		changed = true
	if bool(payload.get("rescue",false)):
		apply_rescue_progress(1,shared)
		changed = true
	if changed:
		save_game()
		announce_quest_state()
	ack_server_transaction(tx_id)
	return changed

func run_generic_quest_sync_smoke() -> bool:
	if quests.is_empty() or event_states.is_empty(): return false
	var old_quests := quests.duplicate(true)
	var old_event_states := event_states.duplicate()
	var old_event_progress := event_progress.duplicate()
	var old_rescue_state := rescue_state
	var old_rescue_kills := rescue_kills
	var old_tx := processed_server_transactions.duplicate()
	var old_network := network_mode
	network_mode = "offline"
	quests[0] = {"state":1,"progress":0}
	event_states[0] = 1
	event_progress[0] = 0
	rescue_state = 1
	rescue_kills = 0
	processed_server_transactions = []
	var payload := {"tx":"smoke:quest:1","quests":[0],"events":[0],"rescue":true,"shared":true}
	var first := apply_server_quest_progress(payload)
	var q1 := int(quests[0]["progress"])
	var e1 := int(event_progress[0])
	var r1 := rescue_kills
	var duplicate := apply_server_quest_progress(payload)
	var ok := first and not duplicate and q1 == 1 and e1 == 1 and r1 == 1 and int(quests[0]["progress"]) == 1 and int(event_progress[0]) == 1 and rescue_kills == 1
	quests = old_quests
	event_states = old_event_states
	event_progress = old_event_progress
	rescue_state = old_rescue_state
	rescue_kills = old_rescue_kills
	processed_server_transactions = old_tx
	network_mode = old_network
	if ok:
		print("QUEST_SYNC_SMOKE_OK all_quests=true events=true rescue=true duplicate_tx_blocked=true ack_protocol=true")
	return ok

func server_send_all_quest_progress(killer_peer: int, enemy: Dictionary) -> void:
	if killer_peer <= 0: return
	var enemy_type := clampi(int(enemy.get("type",0)),0,ENEMY_TYPES.size()-1)
	var enemy_pos: Vector2 = enemy.get("pos",Vector2.ZERO)
	var mob_uid := int(enemy.get("uid",-1))
	var recipients := server_party_members(killer_peer)
	for raw_peer in recipients:
		var peer_id := int(raw_peer)
		if not remote_players.has(peer_id): continue
		var state: Dictionary = remote_players[peer_id]
		if str(state.get("context","world")) != "world": continue
		var matched_quests: Array = []
		for entry in (state.get("active_quests",[]) as Array):
			if not entry is Array or entry.size() < 1: continue
			var quest_id := int(entry[0])
			if quest_id >= 0 and quest_id < QUESTS.size() and int(QUESTS[quest_id]["target"]) == enemy_type:
				matched_quests.append(quest_id)
		var matched_events: Array = []
		for entry in (state.get("active_events",[]) as Array):
			if not entry is Array or entry.size() < 1: continue
			var event_id := int(entry[0])
			if event_id >= 0 and event_id < WORLD_EVENTS.size() and enemy_pos.distance_to(WORLD_EVENTS[event_id]["pos"]) <= 560.0:
				matched_events.append(event_id)
		var rescue_match := bool(enemy.get("invasion",false)) and int(state.get("rescue_state",0)) == 1
		var boss_index:int=enemy_type-12 if enemy_type in [12,13,14] else -1
		if matched_quests.is_empty() and matched_events.is_empty() and not rescue_match and boss_index<0: continue
		var uuid := str(state.get("uuid","peer%d" % peer_id))
		var tx := "quest:%d:%s" % [mob_uid,uuid]
		server_register_transaction(peer_id,tx)
		rpc_server_quest_progress.rpc_id(peer_id,{"tx":tx,"quests":matched_quests,"events":matched_events,"rescue":rescue_match,"shared":peer_id != killer_peer,"boss":boss_index})

func server_party_member_xp(type: int, elite_kind: int, member: int) -> int:
	if not remote_players.has(member): return 0
	return enemy_xp_reward(type,elite_kind,int(remote_players[member].get("level",1)))

func server_party_member_eligible(member: int, killer: int, enemy: Dictionary) -> bool:
	if member <= 0 or not remote_players.has(member) or not remote_players.has(killer): return false
	var state: Dictionary = remote_players[member]
	var killer_state: Dictionary = remote_players[killer]
	if str(state.get("context","world")) != str(killer_state.get("context","world")): return false
	if str(state.get("instance_id","world")) != str(killer_state.get("instance_id","world")): return false
	var enemy_pos: Vector2 = enemy.get("pos",Vector2.ZERO)
	var member_pos := network_player_position(member)
	if member_pos.x < -9000.0: return false
	var is_boss := int(enemy.get("type",-1)) in [12,13,14]
	var max_range := PARTY_BOSS_RANGE if is_boss else PARTY_XP_RANGE
	if member_pos.distance_to(enemy_pos) > max_range: return false
	if is_boss and member != killer:
		var contributed := int((enemy.get("damage_by_peer",{}) as Dictionary).get(member,0)) > 0
		var recent_at := int((enemy.get("damage_at_by_peer",{}) as Dictionary).get(member,0))
		if not contributed or Time.get_ticks_msec()-recent_at > PARTY_BOSS_ACTIVITY_MS: return false
	return true

func resolve_enemy_reward_peer(enemy: Dictionary, requested: int) -> int:
	if requested > 0 and remote_players.has(requested): return requested
	var last := int(enemy.get("last_hit_peer",0))
	if last > 0 and remote_players.has(last): return last
	var best_peer := 0
	var best_damage := -1
	for raw_peer in (enemy.get("damage_by_peer",{}) as Dictionary).keys():
		var peer := int(raw_peer)
		var damage := int((enemy.get("damage_by_peer",{}) as Dictionary)[raw_peer])
		if remote_players.has(peer) and damage > best_damage:
			best_peer = peer
			best_damage = damage
	if best_peer > 0: return best_peer
	var enemy_pos: Vector2 = enemy.get("pos",Vector2.ZERO)
	var region := region_at(enemy_pos)
	var nearest := nearest_network_player(enemy_pos,1400.0,region)
	return int(nearest.get("peer",0))

func send_server_enemy_reward(peer_id: int, enemy: Dictionary) -> void:
	if not dedicated_server_mode or peer_id <= 0 or not remote_players.has(peer_id): return
	server_send_all_quest_progress(peer_id,enemy)
	var player_state: Dictionary = remote_players[peer_id]
	var reward_class := clampi(int(player_state.get("class", 0)), 0, 2)
	var type := clampi(int(enemy.get("type", 0)), 0, ENEMY_TYPES.size() - 1)
	var elite_kind := clampi(int(enemy.get("elite", 0)), 0, 2)
	var is_boss:=type in [12,13,14]
	var party_members := server_party_members(peer_id)
	var eligible_party: Array = []
	for raw_member in party_members:
		var member := int(raw_member)
		if not remote_players.has(member):continue
		if is_boss:
			var state:Dictionary=remote_players[member]
			if str(state.get("context","world"))=="world" and str(state.get("instance_id","world"))=="world":eligible_party.append(member)
		elif server_party_member_eligible(member,peer_id,enemy):eligible_party.append(member)
	if peer_id not in eligible_party: eligible_party.append(peer_id)
	var group_bonus := minf(0.15,maxf(0.0,float(eligible_party.size()-1)*0.02))
	var xp_reward := roundi(float(enemy_xp_reward(type, elite_kind, int(player_state.get("level",1))))*(1.0+group_bonus))
	var gold_reward := randi_range(2, 7) * (1 + int(type / 3.0)) * int([1, 3, 7][elite_kind])
	# Beute gehört der gemeinsamen Welt: genau ein Relikt pro Klassenboss und
	# auch normale Itemdrops können von jedem Spieler aufgehoben werden.
	if is_boss:
		server_spawn_world_drop(class_relic_item(type-12),Vector2(enemy["pos"])+Vector2(25,0),type-12,180.0)
		server_spawn_world_drop(class_boss_hat_item(type-12),Vector2(enemy["pos"])+Vector2(-25,8),type-12,180.0)
	if randf() < (0.38 if elite_kind == 2 else (0.24 if elite_kind == 1 else 0.14)):
		server_spawn_world_drop(random_loot(type,reward_class),Vector2(enemy["pos"]),-1,90.0)
	if randf() < 0.03:
		server_spawn_world_drop(make_item("Heiltrank","potion",1,0,18),Vector2(enemy["pos"])+Vector2(20,0),-1,90.0)
	var mob_uid := int(enemy.get("uid",-1))
	var killer_uuid := str(player_state.get("uuid","peer%d" % peer_id))
	var reward_tx := "reward:%d:%s" % [mob_uid,killer_uuid]
	server_register_transaction(peer_id,reward_tx)
	rpc_server_combat_reward.rpc_id(peer_id,reward_tx,type,xp_reward,gold_reward,[])
	for raw_member in eligible_party:
		var member := int(raw_member)
		if member == peer_id or member <= 0 or not remote_players.has(member): continue
		var member_uuid := str(remote_players[member].get("uuid","peer%d" % member))
		var party_tx := "partyxp:%d:%s" % [mob_uid,member_uuid]
		server_register_transaction(member,party_tx)
		var member_xp := roundi(float(server_party_member_xp(type,elite_kind,member))*(1.0+group_bonus))
		rpc_server_party_progress.rpc_id(member,{"tx":party_tx,"xp":member_xp,"gold":gold_reward if is_boss else 0})

func can_enter_konflux() -> bool:
	return creative_mode or level >= KONFLUX_MIN_LEVEL

func safe_world_teleport_destination(base: Vector2, expected_region: int = -1) -> Vector2:
	var region := expected_region if expected_region >= 0 else region_at(base)
	var offsets := [
		Vector2.ZERO,Vector2(0,70),Vector2(0,-70),Vector2(70,0),Vector2(-70,0),
		Vector2(70,70),Vector2(-70,70),Vector2(70,-70),Vector2(-70,-70),
		Vector2(0,140),Vector2(140,0),Vector2(-140,0),Vector2(0,-140)
	]
	for offset in offsets:
		var candidate: Vector2 = (base+offset).clamp(Vector2(30,30),WORLD-Vector2(30,30))
		if region_at(candidate) != region: continue
		if terrain_blocked(candidate): continue
		if blocked_by_region_wall(candidate): continue
		var occupied := false
		for stone in WAYSTONES:
			if Rect2(stone+Vector2(-41,-59),Vector2(82,101)).grow(18).has_point(candidate):
				occupied = true
				break
		if occupied: continue
		return candidate
	return base.clamp(Vector2(30,30),WORLD-Vector2(30,30))

func run_teleport_consistency_smoke() -> bool:
	var old_level := level
	var old_creative := creative_mode
	creative_mode = false
	level = KONFLUX_MIN_LEVEL-1
	var low_blocked := not can_enter_konflux()
	level = KONFLUX_MIN_LEVEL
	var high_allowed := can_enter_konflux()
	var entrance_target := safe_world_teleport_destination(KonfluxMap.ENTRANCE,region_at(KonfluxMap.ENTRANCE))
	var entrance_ok := region_at(entrance_target) == region_at(KonfluxMap.ENTRANCE) and not terrain_blocked(entrance_target)
	var center_ok := not KonfluxMap.blocked(KonfluxMap.CENTER,KonfluxMap.CENTER,-1,hero_collision_radius())
	var rooms_ok := true
	for room_id in range(KonfluxMap.BUILDING_IDS.size()):
		var inside := KonfluxMap.CENTER+Vector2(0,190)
		var outside: Vector2 = KonfluxMap.LOCATIONS[KonfluxMap.BUILDING_IDS[room_id]]+Vector2(0,110)
		if KonfluxMap.blocked(inside,inside,room_id,hero_collision_radius()) or KonfluxMap.blocked(outside,outside,-1,hero_collision_radius()):
			rooms_ok = false
	var portals_ok := true
	for portal in PORTALS:
		var target_region := int(portal[2])
		var forward := safe_world_teleport_destination(portal[1]+Vector2(0,110),target_region)
		var back_region := region_at(portal[0])
		var backward := safe_world_teleport_destination(portal[0]+Vector2(0,110),back_region)
		if region_at(forward) != target_region or terrain_blocked(forward) or region_at(backward) != back_region or terrain_blocked(backward):
			portals_ok = false
	level = old_level
	creative_mode = old_creative
	var ok := low_blocked and high_allowed and entrance_ok and center_ok and rooms_ok and portals_ok
	if ok:
		print("TELEPORT_SMOKE_OK konflux_lv40=true entrance=true center=true rooms=true portals=true")
	return ok


@rpc("any_peer","call_remote","reliable")
func rpc_zz_save_open(token: String, uuid: String) -> void:
	if not dedicated_server_mode or network_mode != "host": return
	var peer := multiplayer.get_remote_sender_id()
	if not server_action_allowed(peer,"save_open",500): return
	var response: Dictionary = server_save_store.open(peer,token,uuid)
	response["uuid"] = uuid
	rpc_zz_save_reply.rpc_id(peer,response)

@rpc("any_peer","call_remote","reliable")
func rpc_zz_save_put(token: String, uuid: String, revision: int, request: String, data: Dictionary) -> void:
	if not dedicated_server_mode or network_mode != "host": return
	var peer := multiplayer.get_remote_sender_id()
	if peer <= 0: return
	if not server_action_allowed(peer,"save_put",200):
		rpc_zz_save_reply.rpc_id(peer,{"ok":false,"uuid":uuid,"error":"retry"})
		return
	rpc_zz_save_reply.rpc_id(peer,server_save_store.put(peer,token,uuid,revision,request,data))

@rpc("authority","call_remote","reliable")
func rpc_zz_save_reply(response: Dictionary) -> void:
	if network_mode != "client": return
	server_last_reply_ms = Time.get_ticks_msec()
	server_save.reply(self,response)

func mob_visual_scale(enemy:Dictionary)->float:
	var type:int=int(enemy["type"])
	if bool(enemy.get("small_guardian",false)):return .48
	var factor:float=1.3 if type==12 else (.48 if type in [0,1,18,25] else (.6 if type in [2,6,10] else .8))
	if type in [13,14]:factor=1.0
	return factor*(1.42 if int(enemy.get("elite",0))==2 else (1.22 if int(enemy.get("elite",0))==1 else 1.0))

func spawn_tower_guardians(boss:Dictionary)->void:
	if int(boss["type"])!=12:return
	for side in [-1,1]:
		var pos:Vector2=boss["home"]+Vector2(side*100,40)
		var guard:=make_enemy(4,pos)
		guard["guardian_of"]=int(boss["uid"]);guard["small_guardian"]=true
		guard["hp"]*=.6;guard["max_hp"]=guard["hp"]
		if dedicated_server_mode:
			guard["uid"]=server_next_mob_uid;server_next_mob_uid+=1
		guard["context"]="world";guard["instance_id"]="world"
		enemies.append(guard)

func projectile_collision(a:Vector2,b:Vector2,server:bool,context:String="",room:int=-1,height:float=0)->Dictionary:
	var count:int=maxi(1,ceili(a.distance_to(b)/8.0))
	var previous:=a
	for n in range(1,count+1):
		var point:Vector2=a.lerp(b,float(n)/count)
		var blocked:bool=projectile_world_blocked(point) if server else is_blocked(point,previous)
		if context=="konflux":blocked=(KonfluxMap.safe(point,room) or KonfluxMap.solid(point,4) or KonfluxMap.height_at(point)>height+20 or not Rect2(Vector2.ZERO,KonfluxMap.SIZE).has_point(point)) if room<0 else KonfluxMap.blocked(point,previous,room,4)
		if blocked:return {"hit":true,"pos":previous}
		previous=point
	return {"hit":false,"pos":b}

func projectile_break(pos:Vector2,dir:Vector2,kind:int,element:String,player_shot:bool=true,context:String="",instance:String="")->void:
	var where:String=("world" if dedicated_server_mode else multiplayer_context()) if context=="" else context
	var room:String=("world" if dedicated_server_mode else multiplayer_instance_id()) if instance=="" else instance
	if not dedicated_server_mode:
		combat_feedback.burst(pos,dir,kind,element)
		if pos.distance_to(player_pos)<850:play_sound("arrow_break" if kind==3 else "magic_break")
	if network_mode=="host":
		var payload:Dictionary={"pos":[pos.x,pos.y],"dir":[dir.x,dir.y],"kind":kind,"element":element,"context":where,"instance_id":room}
		for peer in multiplayer.get_peers():
			var state:Dictionary=remote_players.get(int(peer),{})
			if str(state.get("context","world"))==where and str(state.get("instance_id","world"))==room:
				rpc_projectile_break.rpc_id(int(peer),payload)

@rpc("authority","call_remote","reliable")
func rpc_projectile_break(payload:Dictionary)->void:
	if str(payload.get("context","world"))!=multiplayer_context() or str(payload.get("instance_id","world"))!=multiplayer_instance_id():return
	var raw:Array=payload.get("pos",[])
	var facing_data:Array=payload.get("dir",[])
	if raw.size()!=2 or facing_data.size()!=2:return
	var pos:=Vector2(float(raw[0]),float(raw[1]))
	if not pos.is_finite() or pos.distance_to(player_pos)>900:return
	combat_feedback.burst(pos,Vector2(float(facing_data[0]),float(facing_data[1])),int(payload.get("kind",2)),str(payload.get("element","")))
	play_sound("arrow_break" if int(payload.get("kind",2))==3 else "magic_break")

func projectile_world_blocked(point:Vector2)->bool:
	if point.x<26 or point.y<26 or point.x>WORLD.x-26 or point.y>WORLD.y-26:return true
	if blocked_by_region_wall(point) or terrain_blocked(point):return true
	if region_at(point)==0:
		for home in house_positions():
			if Rect2(home+Vector2(8,73),Vector2(176,75)).has_point(point):return true
		for stone in WAYSTONES:
			if stone==WAYSTONES[0]:
				if SpawnStoneBody.blocks(point-stone,0):return true
				continue
			if Rect2(stone+Vector2(-41,-59),Vector2(82,101)).has_point(point):return true
	return false

func mark_network_teleport()->void:
	teleport_serial+=1
	camera_smooth=player_pos-VIEW*.5
	camera_pos=camera_smooth
	if network_mode=="client" and multiplayer.multiplayer_peer!=null:push_vital_state()

func valid_network_teleport(origin:Vector2,target:Vector2,previous:Dictionary,context:String)->bool:
	if context!="world":return false
	if float(previous.get("hp",1))<=0 and target.distance_to(Vector2(825,1020))<80:return true
	for stone in WAYSTONES:
		if origin.distance_to(stone)>210:continue
		for destination_index in WAYSTONES.size():
			if target.distance_to(waystone_arrival(destination_index))<95:return true
	for portal in PORTALS:
		if origin.distance_to(portal[0])<160 and target.distance_to(portal[1])<280:return true
		if origin.distance_to(portal[1])<160 and target.distance_to(portal[0])<280:return true
	return false

func mob_hit_radius(enemy:Dictionary)->float:
	return maxf(8,28*mob_visual_scale(enemy))

func ability_projectiles(id:int,origin:Vector2,dir:Vector2,cls:int,power:int)->Array:
	var result:Array=[]
	var count:int=3 if id in [7,20,26] else 1
	for n in count:
		var speed:float=650 if id==3 else (700 if id==7 else (920 if id in [18,25] else (390 if id==20 else (570 if id in [16,29] else 720))))
		var damage:int=power+15 if id==3 else (power+10 if id==7 else int(power*(.72 if id in [20,26] else (.68 if id==16 else 1.0)))+(22 if id in [18,25] else 7))
		result.append({"pos":origin,"dir":dir.rotated((n-(count-1)*.5)*.24),"speed":speed,"life":.9 if id==3 else (.8 if id==7 else (1.65 if id==20 else 1.25)),"damage":damage,"kind":0 if id==3 else (1 if id==7 else (3 if cls==2 else 2)),"element":"gift" if id==28 else ("eis" if id==29 else ("blitz" if id in [18,30] else ("feuer" if id==16 else ""))),"spell_id":id,"pierce":id in [3,18,25],"hits":[],"trail":[]})
	return result

func steer_homing_shot(shot:Dictionary,delta:float)->void:
	var nearest:=235.0
	for enemy in enemies:
		if int(enemy["uid"]) in shot.get("hits",[]):continue
		var distance:float=shot["pos"].distance_to(enemy["pos"])
		if distance<nearest:
			nearest=distance
			shot["dir"]=Vector2(shot["dir"]).lerp((Vector2(enemy["pos"])-Vector2(shot["pos"])).normalized(),minf(1,delta*5.5)).normalized()

func server_fireball_impact(shot:Dictionary)->void:
	for i in range(enemies.size()-1,-1,-1):
		if i>=enemies.size():continue
		if Vector2(shot["pos"]).distance_to(enemies[i]["pos"])<85 and int(enemies[i]["uid"]) not in shot.get("hits",[]) and not projectile_collision(shot["pos"],enemies[i]["pos"],true)["hit"]:
			damage_enemy(i,int(shot["damage"]*.5),Vector2.ZERO,false,"feuer",int(shot.get("owner_peer",0)))

func push_vital_state()->void:
	if network_mode!="client" or multiplayer.multiplayer_peer==null:return
	if multiplayer.multiplayer_peer.get_connection_status()!=MultiplayerPeer.CONNECTION_CONNECTED:return
	last_vitals=Vector2(hp,max_hp())
	rpc_player_vital_state.rpc_id(1,local_player_state())

@rpc("any_peer","call_remote","reliable")
func rpc_player_vital_state(state:Dictionary)->void:
	rpc_player_state(state,true)

@rpc("authority","call_remote","reliable")
func rpc_receive_player_vitals(peer_id:int,state:Dictionary)->void:
	rpc_receive_player_state(peer_id,state)

func announce_mob_death(enemy:Dictionary)->void:
	var payload:Dictionary={"uid":enemy["uid"],"type":enemy["type"],"pos":[enemy["pos"].x,enemy["pos"].y],"scale":mob_visual_scale(enemy),"context":"world","instance_id":"world"}
	if not dedicated_server_mode:receive_mob_death(payload)
	if network_mode=="host":
		for peer in multiplayer.get_peers():
			var state:Dictionary=remote_players.get(int(peer),{})
			if str(state.get("context","world"))=="world":rpc_mob_death.rpc_id(int(peer),payload)

@rpc("authority","call_remote","reliable")
func rpc_mob_death(payload:Dictionary)->void:
	if multiplayer_context()!="world":return
	receive_mob_death(payload)
	for i in range(enemies.size()-1,-1,-1):
		if int(enemies[i]["uid"])==int(payload.get("uid",-1)):enemies.remove_at(i)

func receive_mob_death(payload:Dictionary)->void:
	var uid:int=int(payload.get("uid",-1))
	if dead_mob_uids.has(uid):return
	dead_mob_uids[uid]=combat_feedback.clock
	var row:Dictionary=payload.duplicate()
	row["at"]=combat_feedback.clock
	mob_deaths.append(row)
	while mob_deaths.size()>24:mob_deaths.pop_front()
	for key in dead_mob_uids.keys():
		if combat_feedback.clock-float(dead_mob_uids[key])>15:dead_mob_uids.erase(key)

func draw_mob_deaths()->void:
	for i in range(mob_deaths.size()-1,-1,-1):
		var row:Dictionary=mob_deaths[i]
		var age:float=combat_feedback.clock-float(row["at"])
		if age>.45:mob_deaths.remove_at(i);continue
		var raw:Array=row["pos"];var p:=Vector2(float(raw[0]),float(raw[1]))
		if not visible_world(p,150):continue
		var type:int=int(row["type"])
		MobDesign32.paint(self,p+character_canvas_offset,type,enemy_level(type),Vector2.DOWN,ENEMY_TYPES[type]["color"].darkened(age*.9),0,-1,float(row["scale"])*(1-age*.75),Vector2(1,1-age*1.6))
		draw_set_transform(character_canvas_offset)

func normal_mob_count()->int:
	var count:=0
	for enemy in enemies:
		if int(enemy["type"]) not in [12,13,14] and not bool(enemy.get("small_guardian",false)):count+=1
	return count

func ring_visual()->int:
	return (1 if equipped_ring_uid>=0 else 0)|(2 if class_id==1 and equipped_ring2_uid>=0 else 0)

func local_party_peer_ids() -> Array:
	var ids: Array = []
	for row in (party_state.get("members",[]) as Array):
		if row is Dictionary: ids.append(int(row.get("peer_id",0)))
	return ids

func draw_local_player_label() -> void:
	if not character_created: return
	var label := hero_name.strip_edges() if hero_name.strip_edges() != "" else "Held"
	text_at(player_pos+Vector2(-80,-58),"%s · LV %d" % [label,level],13,Color("fff0b8"),HORIZONTAL_ALIGNMENT_CENTER,160)

func draw_spawn_elevated_actor(peer:int)->void:
	var point:Vector2=player_pos if peer<0 else network_player_position(peer)
	var height:float=SpawnPlatform32.height_at(point,WAYSTONES[0]) if multiplayer_context()=="world" else 0
	var old_offset:Vector2=character_canvas_offset
	character_canvas_offset=old_offset-Vector2(0,height)
	draw_set_transform(character_canvas_offset)
	if peer<0:
		draw_player()
		draw_local_player_label()
	else:draw_remote_players(peer)
	character_canvas_offset=old_offset
	draw_set_transform(old_offset)
