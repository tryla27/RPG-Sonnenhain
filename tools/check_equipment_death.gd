extends SceneTree
class TestGame:
	extends "res://main.gd"
	var revivals := 0
	func respawn() -> void:
		revivals += 1
		hp = 100
	func save_game() -> void: pass
func _initialize() -> void:
	var game := TestGame.new()
	game.refresh_shop_stock()
	assert(game.shop_stock["merchant"].filter(func(item):return item.get("icon","")!="food").size()==11)
	game.append_new_equipment()
	assert(game.shop_stock["merchant"].filter(func(item):return item.get("icon","")!="food").size()==11)
	var names := ["Reisendenleder","Wachtpanzer","Arkanrobe","Waldläufermantel","Sonnenrüstung","Kristallharnisch"]
	for i in names.size():
		var item: Dictionary = game.make_item(names[i],"armor",1,4,100)
		game.inventory = [item]
		game.equipped_armor_uid = item["uid"]
		assert(game.armor_visual()==i)
	game.death_timer = game.DEATH_DURATION
	game.panel = "death"
	game.hp = 0
	game._process(0.5)
	assert(game.revivals==0 and game.hp==0 and game.panel=="death")
	game._process(0.7)
	assert(game.revivals==1 and game.panel=="")
	game.class_id = 1
	game.reset_class_skills()
	game.player_uuid="equipment-test"
	game.level = 3
	game.skill_points = 2
	assert(not game.learn_arcane_step())
	game.dodge()
	assert(game.dash_timer>0.0 and not game.arcane_step_learned)
	game.dash_timer=0.0;game.dash_cooldown=0.0
	assert(not game.claim_class_mastery())
	game.quests.clear()
	for i in game.QUESTS.size(): game.quests.append({"state":0,"progress":0})
	game.final_completed=true
	assert(not game.claim_class_mastery()) # altes Arena-Finale reicht nicht mehr
	game.quests[game.CLASS_MASTERY_QUEST_INDEX]["state"]=3
	var points_before:int=game.skill_points
	assert(game.claim_class_mastery() and game.arcane_step_learned)
	assert(game.skill_points==points_before)
	assert(not game.learn_arcane_step())
	game.dodge()
	assert(game.dash_timer>0.0)
	game.panel = ""
	var click := InputEventMouseButton.new()
	click.position = Vector2(1035,116)
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	game._unhandled_input(click)
	assert(game.panel=="map")
	game.free()
	print("EQUIPMENT_DEATH_OK six visible armors; merchant pagination stock; delayed revival; Map-8 mage mastery dodge")
	quit()
