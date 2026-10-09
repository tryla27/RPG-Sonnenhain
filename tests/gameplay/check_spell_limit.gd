extends SceneTree
# Höchstens 4 Spells; Borin nimmt Spells (auch Fusionen) dauerhaft zurück,
# mit 10 verschiedenen Sprüchen.

const SpellReturn=preload("res://components/spell_return.gd")

class Game extends "res://main.gd":
	var last_error:=""
	func save_game()->void:pass
	func play_sound(_n:String)->void:pass
	func message_error(v:String)->void:last_error=v

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("SPELL_LIMIT_FAIL "+label)

func _initialize()->void:call_deferred("run")

func prep()->Game:
	var g:=Game.new()
	g.class_id=0
	g.reset_class_skills()
	for i in g.WORLD_EVENTS.size():g.event_states.append(0);g.event_progress.append(0)
	for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
	for i in g.BORIN_QUESTS.size():g.borin_quests.append({"state":0,"progress":0})
	g.level=40;g.skill_points=99;g.character_created=true;g.player_uuid="limit"
	return g

func run()->void:
	var g:=prep()
	var tree:Array=[]
	for id in g.SKILL_TREES[0]:
		if id not in g.CLASS_ULTIMATES and id not in [9,10,11] and g.fusion_definition_by_id(id).is_empty():tree.append(id)
	check(tree.size()>=6,"genug Spells im Baum")
	for k in 4:check(g.buy_skill(tree[k]),"Spell %d lernbar" % (k+1))
	check(g.learned_loadout_skills().size()==4,"4 Spells gelernt")
	check(not g.buy_skill(tree[4]),"5. Spell gesperrt")
	check(not g.learned[tree[4]] and g.last_error.contains("Borin"),"Hinweis auf Borin")
	# Skill-Gegenstand ist ebenfalls gesperrt.
	var book:={"name":"Testbuch","icon":"essence","skill_unlock":tree[5],"uid":5,"rarity":1,"power":0}
	g.inventory.append(book)
	g.use_item(g.inventory.size()-1)
	check(not g.learned[tree[5]],"Skill-Gegenstand lernt keinen 5. Spell")

	# Borin: auswählen, bestätigen, abgeben.
	g.slots[0]=tree[0]
	g.panel="spell_return"
	var known:Array=g.learned_loadout_skills()
	var row_point:=SpellReturn.LIST_RECT.position+Vector2(20,20)
	check(SpellReturn.click(g,row_point) and g.spell_return_selected==int(known[0]),"Spell auswählen")
	SpellReturn.click(g,SpellReturn.GIVE_BUTTON.get_center())
	check(g.learned[tree[0]],"erster Klick fragt nur nach")
	SpellReturn.click(g,SpellReturn.GIVE_BUTTON.get_center())
	check(not g.learned[tree[0]] and int(g.slots[0])==-1,"Spell weg, Taste frei")
	check(g.spell_return_quip.begins_with("Borin:"),"Borin sagt etwas")
	check(g.buy_skill(tree[4]),"danach wieder lernbar")

	# Fusion abgeben bleibt auch nach dem Laden weg.
	var h:=prep()
	for id in h.SKILL_TREES[0]:
		h.learned[id]=true;h.skill_levels[id]=4
	var offers:Array=h.available_fusions()
	var f:Dictionary=offers[0]
	h.reset_class_skills()
	h.learned[int(f["a"])]=true;h.skill_levels[int(f["a"])]=4
	h.learned[int(f["b"])]=true;h.skill_levels[int(f["b"])]=4
	h.gold=999999
	var index:=-1
	for k in h.available_fusions().size():
		if int(h.available_fusions()[k]["id"])==int(f["id"]):index=k
	check(index>=0 and h.buy_fusion(index),"Fusion gelernt")
	var fid:=int(f["id"])
	check(h.give_back_spell(fid),"Fusion abgegeben")
	var data:Dictionary=JSON.parse_string(JSON.stringify(h.capture_save_data()))
	var r:=prep()
	r.apply_save_data(data)
	check(not r.learned[fid],"abgegebene Fusion kommt nach dem Laden nicht zurück")

	var seen:={}
	for k in 10:seen[SpellReturn.quip(k)]=true
	check(seen.size()==10,"10 verschiedene Sprüche")
	g.free();h.free();r.free()
	if failures>0:
		print("SPELL_LIMIT_FAILED ",failures)
		quit(1)
		return
	print("SPELL_LIMIT_OK max 4 spells, item unlock blocked, Borin takes spells and fusions back for good, 10 quips")
	quit()
