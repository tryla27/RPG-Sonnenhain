extends SceneTree
const Neck=preload("res://components/arcane_necklaces.gd")
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func play_sound(_name:String)->void:pass

func _initialize()->void:call_deferred("run")
func run()->void:
	var g:=Game.new()
	g.level=40;g.reset_class_skills();g.player_pos=Vector2(5000,3000)
	for i in g.WORLD_EVENTS.size():g.event_states.append(0);g.event_progress.append(0)
	for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
	for i in g.BORIN_QUESTS.size():g.borin_quests.append({"state":0,"progress":0})
	# Every class can wear every necklace, without changing base stats or consuming it.
	for cls in 3:
		g.class_id=cls;g.inventory.clear();g.equipped_necklace_uid=-1
		var hp:=g.max_hp();var energy:=g.max_energy();var attack:=g.normal_attack_power()
		for i in 6:
			var item:=g.make_item(Neck.NAMES[i],"necklace",3,999,100,"blitz")
			g.inventory.append(item);g.use_item(i)
			assert(g.necklace_visual()==i and g.equipped_necklace_uid==int(item["uid"]))
			assert(g.max_hp()==hp and g.max_energy()==energy and g.normal_attack_power()==attack)
			assert(item["power"]==0 and item["str"]==0 and item["agi"]==0 and item["int"]==0)
		assert(g.inventory.size()==6)
		g.unequip_slot("necklace");assert(g.necklace_visual()==-1)
	# Reload retains necklace and learned skill, including old stock and stacked cores.
	g.player_uuid="necklace-test";g.hero_name="Kettentest";g.character_created=true
	g.class_id=1;g.reset_class_skills();g.learned[18]=true;g.skill_levels[18]=1
	g.inventory.clear();g.equipped_necklace_uid=-1
	g.add_item(g.make_item(Neck.NAMES[1],"necklace",2,0,10));g.use_item(0)
	g.shop_stock={"smith":[],"arcane":[{"name":"Arkankern · Eis","icon":"essence","element":"eis","power":0,"price":200,"rarity":1}],"alchemy":[],"merchant":[]}
	var save:=g.capture_save_data()
	var restored:=Game.new();restored.konflux_preview_mode=true
	for i in g.WORLD_EVENTS.size():restored.event_states.append(0);restored.event_progress.append(0)
	restored.apply_save_data(save)
	assert(restored.necklace_visual()==1 and restored.learned[18])
	assert(restored.shop_stock["arcane"][0]["name"]==Neck.NAMES[0])
	restored.free()
	# Actual accepted healing casts: only the third gains 20 % and refunds cost.
	g.inventory.clear();g.equipped_necklace_uid=-1
	g.add_item(g.make_item(Neck.NAMES[4],"necklace",3,0,10));g.use_item(0)
	g.slots[0]=35;g.learned[35]=true;g.skill_levels[35]=1;g.hp=1;g.energy=g.max_energy()
	for i in 3:
		g.cooldowns[35]=0
		var hp_before:=g.hp;var energy_before:=g.energy
		g.use_ability(0)
		assert(is_equal_approx(g.hp-hp_before,66.0 if i==2 else 55.0))
		assert(is_equal_approx(energy_before-g.energy,float(g.ABILITIES[35]["cost"])*(0.8 if i==2 else 1.0)))
	assert(g.necklaces.state(0,4,Time.get_ticks_msec())["casts"]==0)
	var legacy={"uid":543,"name":"Arkankern · Blitz","icon":"essence","element":"blitz","power":50,"skill_unlock":18,"locked":true,"count":3}
	Neck.normalize(legacy)
	assert(legacy["uid"]==543 and legacy["locked"] and legacy["count"]==3)
	assert(legacy["name"]==Neck.NAMES[1] and not legacy.has("skill_unlock"))
	var weapon={"name":"Arkankern","icon":"staff","power":42,"element":"blitz"}
	Neck.normalize(weapon);assert(weapon["name"]=="Arkanhüter-Waffe" and weapon["power"]==42)
	var n:=Neck.new();var enemy={"uid":101,"type":0,"hp":1000.0}
	assert(n.direct_hit(0,0,enemy,100,10,1000)==10 and enemy["necklace_frost_mult"]==0.8)
	var boss={"uid":102,"type":13,"hp":1000.0}
	n.direct_hit(0,1,boss,100,10,1000);assert(boss["necklace_frost_mult"]==0.9)
	assert(n.direct_hit(1,0,enemy,100,10,1001)==10,"switch must not bypass cooldown")
	assert(n.direct_hit(1,0,enemy,100,10,7000)==35)
	assert(n.direct_hit(1,0,enemy,100,10,7001)==10)
	assert(n.direct_hit(1,2,enemy,100,10,7001)==35,"each attacker has an independent cooldown")
	n.direct_hit(2,3,enemy,100,10,1000)
	n.tick_enemy(enemy,4.0);assert(is_equal_approx(float(enemy["hp"]),960.0))
	assert(enemy["necklace_dots"].is_empty())
	# Removing a necklace ends lingering frost and poison immediately.
	var worn_enemy={"uid":99,"type":0,"hp":1000.0}
	var wear:=Neck.new();wear.direct_hit(2,0,worn_enemy,100,10,1000)
	wear.tick_enemy(worn_enemy,1.0,func(_peer):return -1)
	assert(worn_enemy["hp"]==1000 and worn_enemy["necklace_dots"].is_empty())
	wear.direct_hit(0,1,worn_enemy,100,10,1000)
	wear.tick_enemy(worn_enemy,0.1,func(_peer):return -1)
	assert(worn_enemy["necklace_frost"]==0)
	var h:=Neck.new()
	assert(h.direct_hit(5,0,enemy,100,10,1000)==10)
	assert(h.direct_hit(5,0,enemy,100,10,2000)==10)
	assert(h.direct_hit(5,0,enemy,100,10,3000)==60)
	h.direct_hit(5,0,enemy,100,10,4000)
	assert(h.direct_hit(5,0,boss,100,10,4001)==10 and int(h.state(0,5,4001)["hits"])==1)
	assert(not h.cast(4,0,5000) and not h.cast(4,0,5001) and h.cast(4,0,5002))
	h.cast(4,0,5003);h.reset_charges(0,4,5004)
	assert(h.state(0,4,5004)["casts"]==0,"same-type necklace switch resets charges")
	var r:=Neck.new()
	for i in 5:r.direct_hit(3,0,enemy,100,100,1000+i)
	assert(r.direct_hit(3,0,enemy,100,100,1010)==110)
	assert(r.direct_hit(3,0,enemy,100,100,7000)==100)
	# Real combat integration: secondary damage cannot retrigger necklace procs.
	g.class_id=1;g.inventory.clear();g.equipped_necklace_uid=-1
	g.inventory.append(g.make_item(Neck.NAMES[5],"necklace",3,0,10));g.use_item(0)
	g.enemies=[g.make_enemy(0,Vector2(5000,3000))];g.enemies[0]["hp"]=10000.0
	g.damage_enemy(0,10,Vector2.ZERO,false,"",0,false)
	assert(int(g.necklaces.state(0,5,Time.get_ticks_msec())["hits"])==0)
	g.damage_enemy(0,10,Vector2.ZERO)
	assert(int(g.necklaces.state(0,5,Time.get_ticks_msec())["hits"])==1)
	assert(g.local_player_state()["necklace"]==5)
	var payload:=g.sanitize_network_reward_item(g.boss_necklace_item(2))
	assert(payload["icon"]=="necklace" and payload["power"]==0)
	for boss_index in 3:
		g.enemies=[g.make_enemy(12+boss_index,Vector2(5000,3000))];g.drops.clear()
		g.defeat_enemy(0)
		var found:=0
		for drop in g.drops:
			if drop.has("item") and Neck.index(drop["item"])==boss_index+3:
				found+=1;assert(not drop.has("reserved_class"))
		assert(found==1,"each boss guarantees one unrestricted necklace")
	print("ARCANE_NECKLACES_OK all classes, migration, no base bonuses, six effects, cooldowns, secondary-hit isolation, independent attackers and boss drops")
	g.free();quit()
