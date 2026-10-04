extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func play_sound(_name:String)->void:pass
	func announce_multiplayer_context()->void:pass

func _initialize()->void:call_deferred("run")

func run()->void:
	var store=preload("res://components/server_save_store.gd").new()
	for hero_class in 3:
		for race in 3:
			for gender in 2:
				var g=TestGame.new()
				root.add_child(g)
				g.class_id=hero_class;g.hero_race=race;g.hero_gender=gender
				g.character_created=true;g.player_uuid="spells-runes-test"
				g.level=20;g.skill_level_points_granted=19;g.skill_points=10
				g.reset_class_skills()
				for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
				for i in g.BORIN_QUESTS.size():g.borin_quests.append({"state":0,"progress":0})
				for i in g.WORLD_EVENTS.size():g.event_states.append(0);g.event_progress.append(0)
				for tree in g.EssenceSystem.TREE_COUNT:
					g.essence.selected_tree=tree
					g.click_essence(Vector2(910,260))
					assert(g.essence.rank(tree,0)==1)
				assert(g.skill_points==10)
				var runes=g.essence.snapshot()
				for map_id in range(9):
					g.player_pos=g.region_rect(map_id).get_center()
					g.panel=""
					g.toggle_panel("skills")
					assert(g.panel=="skills" and g.skill_tree_tab==hero_class)
					g.toggle_panel("skills")
					assert(g.panel=="")
				g.player_pos=Vector2(9000,7000)
				g.skill_tree_tab=1
				var spell=int(g.SKILL_TREES[1][0])
				g.click_skills(Vector2(200,270))
				assert(g.learned[spell] and g.skill_levels[spell]==1)
				g.click_skills(Vector2(320,340))
				assert(g.skill_levels[spell]==2)
				assert(g.skill_points==8)
				assert(g.essence.snapshot()==runes)
				g.click_skills(Vector2(200,270))
				assert(g.slots[0]==spell)
				g.interact_interior_owner("Borin")
				assert(g.panel=="essence")
				runes=g.essence.snapshot()
				var save=g.capture_save_data()
				assert(store.valid_data(save,g.player_uuid))
				g.essence.reset();g.reset_class_skills()
				g.apply_save_data(JSON.parse_string(JSON.stringify(save)),true)
				assert(g.essence.snapshot()==runes)
				assert(g.learned[spell] and g.skill_levels[spell]==2 and g.slots[0]==spell)
				assert(g.skill_points==8)
				g.free()
	print("SPELLS_RUNES_SEPARATION_OK 18 characters; maps 0-8; learn/upgrade anywhere; distinct point pools; rune and spell save reload")
	quit()
