extends SceneTree

const MobCombat=preload("res://components/mob_combat.gd")
const Kitchen=preload("res://components/steinrose_kitchen.gd")

class TestGame:
	extends "res://main.gd"
	var saves:=0
	func save_game():saves+=1
	func announce_multiplayer_context():pass
	func play_sound(_name:String):pass

class FakeKitchenGame:
	extends RefCounted
	var panel:="steinrose"
	func play_sound(_name:String):pass
	func queue_redraw():pass

func _initialize():call_deferred("run")

func run():
	var g:=TestGame.new()
	g.reset_class_skills()
	g.character_created=true
	g.class_id=2
	g.level=40
	g.inventory.clear()
	g.selected_item=-1

	# Inventory lock survives mass sell and Q-drop creates exactly one world drop.
	var locked:=g.make_item("Behalten","bow",2,20,100)
	var sellable:=g.make_item("Verkaufen","ring",1,4,40)
	g.inventory=[locked,sellable]
	g.toggle_item_lock(0)
	assert(bool(g.inventory[0].get("locked",false)))
	var before_gold:=g.gold
	g.sell_all_unequipped()
	assert(g.inventory.size()==1 and str(g.inventory[0]["name"])=="Behalten")
	assert(g.gold>before_gold)
	g.selected_item=0
	g.drops.clear()
	assert(g.drop_inventory_item(0))
	assert(g.inventory.is_empty() and g.drops.size()==1)

	# Boss loot is typed correctly; Kriegsherr heart explains its function.
	var helm:=g.class_boss_hat_item(0)
	var heart:=g.class_relic_item(0)
	assert(str(helm["icon"])=="head" and str(helm["name"]).contains("Kriegsherr"))
	assert(str(heart.get("tooltip","")).contains("WUT"))
	var net_helm:=g.sanitize_network_reward_item(g.network_reward_payload(helm))
	assert(str(net_helm["icon"])=="head" and bool(net_helm.get("boss_hat",false)))

	# Falcon rune can only be bound by ranger and marks/consumes on consecutive hits.
	var rune:=g.ranger_falcon_rune_item()
	g.inventory=[rune]
	g.use_item(0)
	assert(g.ranger_falcon_rune)
	var enemy:=g.make_enemy(0,g.player_pos+Vector2(50,0))
	enemy["hp"]=1000.0;enemy["max_hp"]=1000.0
	g.enemies=[enemy]
	g.damage_enemy(0,100,Vector2.ZERO)
	assert(float(g.enemies[0].get("falcon_mark",0.0))>0.0)
	var after_first:=float(g.enemies[0]["hp"])
	g.damage_enemy(0,100,Vector2.ZERO)
	assert(float(g.enemies[0]["hp"]) < after_first-100.0)
	assert(float(g.enemies[0].get("falcon_mark",0.0))==0.0)

	# Waystones unlock by proximity without teleporting the player.
	g.waystone_unlocked=[true,false,false,false,false,false,false,false,false,false,false,false]
	var original:=g.WAYSTONES[1]+Vector2(0,120)
	g.player_pos=original
	g.update_waystone_activation()
	assert(g.waystone_unlocked[1])
	assert(g.player_pos==original)

	# Dungeon transition reset is idempotent and never leaves attack state locked.
	for i in 50:
		g.attack_timer=3.0;g.attack_anim=2.0;g.swing_timer=2.0;g.dash_timer=1.0
		g.projectiles=[{"x":1}];g.enemy_projectiles=[{"x":1}];g.battle_zones=[{"x":1}]
		g.reset_combat_transition_state()
		assert(g.attack_timer==0.0 and g.attack_anim==0.0 and g.swing_timer==0.0 and g.dash_timer==0.0)
		assert(g.projectiles.is_empty() and g.enemy_projectiles.is_empty() and g.battle_zones.is_empty())

	# Borin only offers fusion when at least two active skills are learned.
	g.reset_class_skills()
	assert(g.available_fusions().is_empty())
	g.learned[0]=true
	assert(g.available_fusions().is_empty())
	g.learned[16]=true
	assert(not g.available_fusions().is_empty())

	# Warrior crit scales gently with level and stays capped.
	g.class_id=0
	assert(is_equal_approx(g.warrior_crit_chance(1),0.08))
	assert(g.warrior_crit_chance(40)>0.13 and g.warrior_crit_chance(40)<0.15)
	assert(g.warrior_crit_chance(99)<=0.20)
	assert(is_equal_approx(g.warrior_crit_multiplier(),1.75))

	# Auto-sort preserves UIDs, equipped items and sell locks while grouping sensibly.
	g.inventory.clear();g.equipped_uid=-1;g.equipped_armor_uid=-1
	var herb:=g.make_item("Kraut","herb",0,0,3)
	var armor:=g.make_item("Ruestung","armor",2,12,80)
	var sword:=g.make_item("Klinge","sword",3,18,120)
	var locked_ring:=g.make_item("Ring","ring",1,4,40);locked_ring["locked"]=true
	g.inventory=[herb,armor,locked_ring,sword]
	g.equipped_uid=int(sword["uid"])
	var sword_uid:=g.equipped_uid
	var locked_uid:=int(locked_ring["uid"])
	g.auto_sort_inventory()
	assert(g.equipped_uid==sword_uid)
	assert(int(g.inventory[0]["uid"])==sword_uid)
	assert(g.inventory.any(func(it):return int(it.get("uid",-1))==locked_uid and bool(it.get("locked",false))))

	# Save repair workshop applies only explicitly marked repair fields.
	g.level=7;g.xp=345;g.gold=120;g.skill_points=4
	g.player_pos=Vector2(1200,1200)
	g.waystone_unlocked=[true,false,false,false,false,false,false,false,false,false,false,false]
	g.begin_repair_session()
	assert(int(g.repair_targets["level"])==7 and int(g.repair_targets["xp"])==345)
	g.adjust_repair_value("level",5,1,40)
	g.adjust_repair_value("gold",880,0,99999999)
	g.level=39;g.xp=999999;g.gold=50000;g.skill_points=60 # simulate unrelated creative changes
	g.level=7;g.xp=345;g.gold=120;g.skill_points=4 # simulate reloaded normal save before patch
	g.apply_repair_patch()
	assert(g.level==12)
	assert(g.gold==1000)
	assert(g.xp==345 and g.skill_points==4)

	# Bosses have long pursuit ranges compared with ordinary mobs.
	for boss_type in [12,13,14]:
		var p:=MobCombat.profile(boss_type,g.ENEMY_TYPES[boss_type],40,int(g.ENEMY_TYPES[boss_type]["damage"]))
		assert(float(p["aggro_range"])>=1400.0)
		assert(float(p["leash_range"])>=3000.0)

	# Kitchen up/down input cycles learned recipes without loops.
	var kitchen:=Kitchen.new()
	kitchen.learned[0]=true;kitchen.learned[1]=true;kitchen.tab=3;kitchen.selected=0
	var fake:=FakeKitchenGame.new()
	var down:=InputEventKey.new();down.keycode=KEY_DOWN;down.pressed=true
	assert(kitchen.keyboard_input(fake,down))
	assert(kitchen.selected==1)
	var up:=InputEventKey.new();up.keycode=KEY_UP;up.pressed=true
	assert(kitchen.keyboard_input(fake,up))
	assert(kitchen.selected==0)

	print("GAMEPLAY_STABILITY_OK inventory lock/drop/sort; warrior crit; transactional save repair; boss loot; falcon rune; auto waystone; dungeon loop reset; fusion gate; boss leash; kitchen keys")
	g.free()
	quit()
