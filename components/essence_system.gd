extends RefCounted

const MAX_LEVEL:=40
const TREE_COUNT:=5
const TALENTS_PER_TREE:=5
const MAX_RANK:=4
const TREE_CAP:=TALENTS_PER_TREE*MAX_RANK
const TOTAL_CAP:=MAX_LEVEL

const TREE_NAMES:=["KAMPF","DURCHHALTEN","MAGIE","INTELLIGENZ","ELEKTRO"]
const TREE_ORIGINS:=["Kämpfer","Ork","Magier","Mensch","Roboter"]

const TALENTS:=[
	[
		{"name":"Kritischer Instinkt","desc":"Kritchance und auf Rang 4 zusätzlicher Kritschaden."},
		{"name":"Blutdurst","desc":"Lebensraub aus direktem Schaden."},
		{"name":"Brutale Hiebe","desc":"Stärkere Autoangriffe; Rang 4 verstärkt jeden vierten Treffer."},
		{"name":"Wachhaltung","desc":"Blockchance und stärkerer Gegenschlag nach Block."},
		{"name":"Blutrausch","desc":"Mehr Schaden bei niedrigen Lebenspunkten."}
	],
	[
		{"name":"Trollblut","desc":"Lebensregeneration, später auch im Kampf."},
		{"name":"Anker","desc":"Treffer bremsen deinen Sprint weniger stark ab."},
		{"name":"Überlebensinstinkt","desc":"Unter 19% HP startet ein stärkerer Notfallmodus."},
		{"name":"Unerschütterlich","desc":"Verkürzt die Sprintunterbrechung durch gegnerische Treffer."},
		{"name":"Zweiter Atem","desc":"Verstärkt eingehende Heilung und Schutzpuffer."}
	],
	[
		{"name":"Arkane Macht","desc":"Erhöht direkten Fähigkeitsschaden und magische Heilung."},
		{"name":"Elementare Meisterschaft","desc":"Verstärkt Feuer, Eis, Blitz, Gift und arkane Effekte aus allen Quellen."},
		{"name":"Flächenbeherrschung","desc":"Mehr AoE-Schaden; hohe Ränge vergrößern den Radius."},
		{"name":"Instabile Geschosse","desc":"Magier-Autoattack im Flug erneut auslösen, um ihn kontrolliert explodieren zu lassen."},
		{"name":"Arkane Resonanz","desc":"Magische Treffer laden Resonanz für den nächsten Zauber auf."}
	],
	[
		{"name":"Planung","desc":"Verringert Fähigkeits-Cooldowns."},
		{"name":"Flinkheit","desc":"Erhöht Bewegungstempo und Sprintbeschleunigung."},
		{"name":"Präzision","desc":"Mehr Schaden gegen unverwundete Ziele."},
		{"name":"Tarnkunst","desc":"Geringere Wahrnehmung und stärkerer erster Treffer."},
		{"name":"Hinterhältigkeit","desc":"Mehr Schaden von hinten; Rang 4 verstärkt den Kontrollimpuls."}
	],
	[
		{"name":"Kondensator","desc":"Mehr maximale Energie und Regeneration."},
		{"name":"Hochspannung","desc":"Mehr Blitz-/Elektroschaden."},
		{"name":"Kettenentladung","desc":"Elektrische Treffer können auf weitere Ziele springen."},
		{"name":"Automatisches System","desc":"Bei niedrigen HP entsteht automatisch ein Schutzschild."},
		{"name":"Überladung","desc":"Fähigkeiten bauen Ladung für einen verstärkten Folgetreffer auf."}
	]
]

var ranks:Array=[]
var selected_tree:=0

func _init()->void:
	reset()

func reset()->void:
	ranks=[]
	for _tree in TREE_COUNT:
		ranks.append([0,0,0,0,0])
	selected_tree=0

func total_for_level(level:int)->int:
	# Level 1 startet mit 1 Essenz; bis Level 40 entstehen exakt 40 Punkte.
	return clampi(level,1,MAX_LEVEL)

func spent()->int:
	var result:=0
	for tree in ranks:
		for rank in tree:result+=clampi(int(rank),0,MAX_RANK)
	return result

func available(level:int)->int:
	return maxi(0,total_for_level(level)-spent())

func tree_spent(tree:int)->int:
	var result:=0
	for rank in ranks[clampi(tree,0,TREE_COUNT-1)]:result+=clampi(int(rank),0,MAX_RANK)
	return result

func rank(tree:int,talent:int)->int:
	return clampi(int(ranks[clampi(tree,0,TREE_COUNT-1)][clampi(talent,0,TALENTS_PER_TREE-1)]),0,MAX_RANK)

func can_invest(level:int,tree:int,talent:int)->bool:
	tree=clampi(tree,0,TREE_COUNT-1);talent=clampi(talent,0,TALENTS_PER_TREE-1)
	var current:=rank(tree,talent)
	if available(level)<=0 or current>=MAX_RANK:return false
	var next:=current+1
	# Tiefe Ränge brauchen echte Spezialisierung, damit Rang-4-Effekte nicht überall gepickt werden.
	if next==3 and tree_spent(tree)<5:return false
	if next==4 and tree_spent(tree)<10:return false
	return true

func invest(level:int,tree:int,talent:int)->bool:
	if not can_invest(level,tree,talent):return false
	ranks[tree][talent]=rank(tree,talent)+1
	return true

func snapshot()->Dictionary:
	return {"ranks":ranks.duplicate(true),"selected_tree":selected_tree}

static func network_ranks(raw:Variant,level:int)->Array:
	# All five universal rune trees travel together; class/race never filters them.
	if not raw is Array or raw.size()!=TREE_COUNT:return []
	var clean:Array=[]
	var total:=0
	for row in raw:
		if not row is Array or row.size()!=TALENTS_PER_TREE:return []
		var values:Array=[]
		for value in row:
			if not (value is int or value is float) or not is_finite(float(value)) or float(value)!=floorf(float(value)) or int(value)<0 or int(value)>MAX_RANK:return []
			values.append(int(value));total+=int(value)
		clean.append(values)
	return clean if total<=clampi(level,1,MAX_LEVEL) else []

func restore(raw:Variant)->void:
	reset()
	if raw is not Dictionary:return
	var stored:Variant=raw.get("ranks",[])
	if stored is Array:
		for tree in mini(TREE_COUNT,stored.size()):
			if stored[tree] is not Array:continue
			for talent in mini(TALENTS_PER_TREE,stored[tree].size()):
				ranks[tree][talent]=clampi(int(stored[tree][talent]),0,MAX_RANK)
	selected_tree=clampi(int(raw.get("selected_tree",0)),0,TREE_COUNT-1)

func ability_power_mult()->float:
	return 1.0+0.04*rank(2,0)

func element_power_mult()->float:
	return 1.0+0.05*rank(2,1)

func aoe_damage_mult()->float:
	return 1.0+0.05*rank(2,2)

func aoe_radius_mult()->float:
	var r:=rank(2,2)
	return 1.0+(0.05 if r>=3 else 0.0)+(0.05 if r>=4 else 0.0)

func unstable_projectile_rank()->int:
	return rank(2,3)

func unstable_projectile_damage_mult()->float:
	return [0.0,0.60,0.75,0.90,1.00][unstable_projectile_rank()]

func unstable_projectile_radius()->float:
	return [0.0,70.0,82.0,94.0,108.0][unstable_projectile_rank()]

func resonance_rank()->int:
	return rank(2,4)

func cooldown_mult()->float:
	return 1.0-0.05*rank(3,0)

func movement_mult()->float:
	return 1.0+0.04*rank(3,1)

func healing_mult()->float:
	return 1.0+0.08*rank(1,4)

func energy_mult()->float:
	return 1.0+0.10*rank(4,0)

func regeneration_rate(in_combat:bool)->float:
	var r:=rank(1,0)
	return float(r)*(0.5 if in_combat and r>=3 else (0.0 if in_combat else 1.0))
