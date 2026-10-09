extends SceneTree
const Relics=preload("res://components/boss_relics.gd")
const Neck=preload("res://components/arcane_necklaces.gd")
const Store=preload("res://components/server_save_store.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
func _initialize()->void:call_deferred("run")
func configured()->Game:
	var g:=Game.new();g.level=40;g.character_created=true;g.player_uuid="boss-pendant-test";g.hero_name="Test";g.konflux_preview_mode=true
	g.reset_class_skills()
	for q in g.QUESTS:g.quests.append({"state":0,"progress":0})
	for e in g.WORLD_EVENTS:g.event_states.append(0);g.event_progress.append(0)
	for q in g.BORIN_QUESTS:g.borin_quests.append({"state":0,"progress":0})
	return g
func run()->void:
	var g:=configured()
	for source in 3:
		g.class_id=source;g.reset_class_skills();g.inventory.clear()
		var item={"uid":220+source,"name":Relics.NAMES[source],"icon":"gem","mastery_class":(source+1)%3,"rarity":4,"power":0,"value":100,"count":2,"level":20}
		assert(g.add_item(item))
		assert(Relics.index(g.inventory[0])==source and g.inventory[0]["icon"]=="essence")
		var points:=g.skill_points
		g.use_item(0)
		assert(g.class_mastery_unlocked and g.arcane_step_learned==(source==1) and g.skill_points==points)
		assert(g.inventory.size()==1 and g.inventory[0]["count"]==1,"only one stacked gift consumed")
		g.use_item(0);assert(g.inventory.size()==1,"duplicate does not consume another gift")
		var data:=g.capture_save_data();var restored:=configured();restored.apply_save_data(data)
		assert(restored.class_mastery_unlocked and restored.class_id==source)
		if source==1:assert(restored.mage_rift_blink_unlocked())
		restored.free()
	# Name and stable identity survive missing metadata and reward transport.
	for source in 3:
		var item={"name":Relics.NAMES[source],"icon":"gem","rarity":4,"power":0,"count":1}
		var clean:=g.sanitize_network_reward_item(item)
		assert(clean["mastery_class"]==source and clean["class_relic_id"]==Relics.IDS[source])
	var invalid={"name":"Unbekannte Gabe","class_relic":true,"mastery_class":-1,"icon":"gem"}
	Relics.normalize(invalid);assert(not invalid["class_relic"] and Relics.index(invalid)==-1)
	g.class_id=1;g.reset_class_skills();g.class_mastery_unlocked=true;g.arcane_step_learned=false;g.inventory.clear()
	g.add_item(g.class_relic_item(1));g.use_item(0)
	assert(g.arcane_step_learned and g.inventory.size()==1,"repair incomplete mage unlock without consuming duplicate")
	for cls in 3:
		g.class_id=cls;g.reset_class_skills();g.inventory.clear();g.equipped_necklace_uid=-1;g.equipped_ring_uid=-1;g.equipped_ring2_uid=-1
		var base_hp:=g.max_hp()
		var pendant:=g.make_item("Blütenanhänger","gem",1,0,100)
		assert(pendant["name"]=="Blütenanhänger" and pendant["icon"]=="necklace" and Neck.index(pendant)==6)
		g.add_item(pendant);g.use_item(0)
		assert(g.necklace_visual()==6 and g.inventory.size()==1 and g.max_hp()==base_hp)
		g.unequip_slot("necklace");assert(g.necklace_visual()==-1)
		g.inventory.clear()
		var old:=g.make_item("Nebelamulett","ring",2,46,100)
		old["icon"]="ring";old.erase("necklace_id")
		g.inventory=[old];g.equipped_ring_uid=int(old["uid"])
		g.validate_equipment_slots()
		assert(g.equipped_necklace_uid==int(old["uid"]) and g.equipped_ring_uid==-1)
		assert(g.max_hp()>=base_hp+46 and old["power"]==46,"old amulet keeps health and attributes")
		g.hp=g.max_hp();g.use_item(0)
		assert(g.hp<=g.max_hp() and g.necklace_visual()==-1,"removing pendant clamps health")
		g.use_item(0);assert(g.necklace_visual()==6)
		var saved:=g.capture_save_data()
		assert(Store.new().valid_data(saved,g.player_uuid),"server accepts ordinary pendant bonuses")
		var restored:=configured();restored.apply_save_data(saved)
		assert(restored.necklace_visual()==6 and restored.inventory[0]["power"]==46)
		restored.free()
	var enemy={"uid":1,"type":0,"hp":100.0}
	assert(Neck.new().direct_hit(6,0,enemy,100,10,1)==10,"ordinary pendant has no invented arcane proc")
	assert(g.ENEMY_TYPES[13]["name"]=="Dunkler Arkanhüter" and g.region_at(g.CLASS_BOSS_SITES[1])==4)
	g.free();print("BOSS_RELIC_PENDANTS_OK all three gifts / old identity repair / save + reward transport / no invalid class fallback / stacked consumption / necklace slot / existing pendant stats / relocated boss")
	quit()
