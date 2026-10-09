extends RefCounted
# Spell-Grenze und Spell-Abgabe bei Borin (Wunsch 10.10.2026).
#
# - Ein Charakter kennt höchstens MAX_KNOWN Spells (Attacken für die Leiste,
#   ohne Ultimates und Klassen-Grundfähigkeiten). Neue Spells lassen sich erst
#   lernen, wenn ein Platz frei ist; Fusionen sind erlaubt (aus zwei wird eins).
# - Bei Borin gibt man Spells ab. Er nimmt sie mit einem lockeren Spruch.
#   Skillpunkte gibt es dafür nicht zurück.
#
# Hier liegen Regeln, Sprüche, Zeichnen und Klicks des Panels "spell_return".
# Der Spielzustand (learned, skill_levels, slots, Fusionen) gehört main.gd.

const MAX_KNOWN:=4
const FULL_MESSAGE:="Du kennst schon %d Spells. Gib bei Borin einen ab, um Platz zu schaffen."

const QUIPS:=[
	"Borin: „Her damit. Den hab ich eh schon immer besser gezaubert.“",
	"Borin: „Weg ist er. Keine Sorge, ich hebe ihn nicht für dich auf.“",
	"Borin: „Ein Spell weniger im Kopf, ein Gedanke mehr fürs Mittagessen.“",
	"Borin: „Den werf ich ins Runenfass. Da klappert er so schön.“",
	"Borin: „Gute Wahl. Der hat eh nur Funken gesprüht, wo er nicht sollte.“",
	"Borin: „Abgabe angenommen. Quittung gibt’s nicht, Rückgabe auch nicht.“",
	"Borin: „Hm, riecht noch warm. Den hast du fleißig benutzt.“",
	"Borin: „Platz geschaffen! Dein Kopf dankt es dir, deine Gegner weniger.“",
	"Borin: „Ich leg ihn zu den anderen. Die streiten sich gleich wieder.“",
	"Borin: „So, erledigt. Und jetzt raus, bevor ich dir noch einen andrehe.“",
]

const LIST_RECT:=Rect2(165,200,420,330)
const ROW_H:=54.0
const ROWS:=6
const INFO_RECT:=Rect2(600,200,380,330)
const GIVE_BUTTON:=Rect2(600,540,230,40)
const BACK_BUTTON:=Rect2(840,540,140,40)
const OPEN_BUTTON:=Rect2(820,148,160,36)

static func count(known:Array)->int:
	return known.size()

static func can_learn_more(known:Array)->bool:
	return known.size()<MAX_KNOWN

static func quip(index:int)->String:
	return str(QUIPS[posmod(index,QUIPS.size())])

## Panel-Zustand liegt in main.gd: spell_return_selected, spell_return_confirm,
## spell_return_quip, menu_scroll.
static func draw(g)->void:
	var known:Array=g.learned_loadout_skills()
	g.text_at(Vector2(165,124),"BORIN · SPELLS ABGEBEN",25,Color("ffeda9"))
	g.text_at(Vector2(700,124),"SPELLS %d/%d" % [known.size(),MAX_KNOWN],16,Color("f6dc9a") if known.size()<=MAX_KNOWN else Color("ff9f8f"))
	g.text_at(Vector2(165,176),"Du kannst höchstens %d Spells kennen. Gib hier welche ab, um Platz zu schaffen. Skillpunkte gibt es nicht zurück." % MAX_KNOWN,12,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,815)
	if known.is_empty():
		g.text_at(Vector2(180,240),"Du kennst gerade keine Spells, die du abgeben kannst.",15,Color("c8d8d2"))
	var start:int=clampi(int(g.menu_scroll),0,maxi(0,known.size()-ROWS))
	for row in mini(ROWS,known.size()-start):
		var id:int=int(known[start+row])
		var r:=Rect2(LIST_RECT.position+Vector2(0,row*ROW_H),Vector2(LIST_RECT.size.x,ROW_H-6))
		var selected:bool=id==int(g.spell_return_selected)
		g.ui_box(r,Color("4c6a6e") if selected else Color("2c444c"))
		if selected:g.draw_rect(r,Color("f2cf83"),false,2)
		g.draw_skill_icon(r.position+Vector2(8,7),id,34)
		g.text_at(r.position+Vector2(52,22),str(g.ABILITIES[id]["name"]),15,Color("fff1bc"),HORIZONTAL_ALIGNMENT_LEFT,250)
		var tags:="STUFE %d/4" % clampi(int(g.skill_levels[id]),1,4)
		if not g.fusion_definition_by_id(id).is_empty():tags+=" · FUSION"
		var slot:int=g.slots.find(id)
		if slot>=0:tags+=" · SLOT %d" % (slot+1)
		g.text_at(r.position+Vector2(52,41),tags,11,Color("9de6c2"))
	if known.size()>ROWS:
		g.text_at(Vector2(165,536),"Mausrad: weitere Spells (%d–%d von %d)" % [start+1,mini(start+ROWS,known.size()),known.size()],11,Color("b9d9cf"))
	draw_info(g,int(g.spell_return_selected))
	var can_give:bool=int(g.spell_return_selected)>=0 and known.has(int(g.spell_return_selected))
	g.ui_button(GIVE_BUTTON,"WIRKLICH ABGEBEN?" if bool(g.spell_return_confirm) else "ABGEBEN",can_give,bool(g.spell_return_confirm))
	g.ui_button(BACK_BUTTON,"ZURÜCK")
	if str(g.spell_return_quip)!="":
		g.text_at(Vector2(165,590),str(g.spell_return_quip),13,Color("ffe2aa"),HORIZONTAL_ALIGNMENT_LEFT,815)

## Infos zum ausgewählten Spell (wie Gegenstandsinfos im Inventar).
static func draw_info(g,id:int)->void:
	g.ui_box(INFO_RECT,Color("243944"))
	if id<0 or id>=g.ABILITIES.size():
		g.text_at(INFO_RECT.position+Vector2(16,32),"Wähle links einen Spell.",14,Color("c8d8d2"))
		return
	var info:Dictionary=g.ABILITIES[id]
	var p:=INFO_RECT.position
	g.draw_skill_icon(p+Vector2(14,14),id,44)
	g.text_at(p+Vector2(70,34),str(info["name"]),18,Color("fff1bc"),HORIZONTAL_ALIGNMENT_LEFT,290)
	g.text_at(p+Vector2(70,56),"Stufe %d/4" % clampi(int(g.skill_levels[id]),1,4),12,Color("9de6c2"))
	var lines:Array=[]
	lines.append(str(info.get("desc","")))
	var resource:="Mana" if int(g.class_id)==1 else "Energie"
	lines.append("Kosten: %d %s · Abklingzeit: %.1f s" % [int(info.get("cost",0)),resource,float(info.get("cd",0.0))])
	lines.append("Lernbar ab Level %d" % int(info.get("req",1)))
	var fusion:Dictionary=g.fusion_definition_by_id(id)
	if not fusion.is_empty():
		var a:int=int(fusion.get("a",-1));var b:int=int(fusion.get("b",-1))
		if a>=0 and b>=0:lines.append("Fusion aus %s + %s" % [g.ABILITIES[a]["name"],g.ABILITIES[b]["name"]])
	var slot:int=g.slots.find(id)
	lines.append("Liegt auf Taste %d" % (slot+1) if slot>=0 else "Auf keiner Taste")
	var y:=p.y+92
	for line in lines:
		g.text_at(Vector2(p.x+16,y),str(line),12,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,350)
		y+=22 if str(line).length()<52 else 38
	g.text_at(p+Vector2(16,312),"Abgeben entfernt den Spell und seine Stufen.",11,Color("e7b8a8"),HORIZONTAL_ALIGNMENT_LEFT,350)

## Gibt true zurück, wenn der Klick verarbeitet wurde.
static func click(g,mouse:Vector2)->bool:
	var known:Array=g.learned_loadout_skills()
	if BACK_BUTTON.has_point(mouse):
		g.panel="essence";g.spell_return_confirm=false;g.play_sound("ui_klick");return true
	var start:int=clampi(int(g.menu_scroll),0,maxi(0,known.size()-ROWS))
	for row in mini(ROWS,known.size()-start):
		var r:=Rect2(LIST_RECT.position+Vector2(0,row*ROW_H),Vector2(LIST_RECT.size.x,ROW_H-6))
		if r.has_point(mouse):
			g.spell_return_selected=int(known[start+row]);g.spell_return_confirm=false
			g.play_sound("ui_klick");return true
	if GIVE_BUTTON.has_point(mouse):
		var id:int=int(g.spell_return_selected)
		if id<0 or not known.has(id):return true
		if not bool(g.spell_return_confirm):
			g.spell_return_confirm=true;g.play_sound("ui_klick");return true
		g.give_back_spell(id)
		return true
	return false
