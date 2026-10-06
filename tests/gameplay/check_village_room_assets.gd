extends SceneTree

class TestGame extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func _draw()->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	root.add_child(g)
	g.reset_class_skills()
	for quest in g.QUESTS:g.quests.append({"state":0,"progress":0})
	var assets:Dictionary={}
	for id in 9:
		var spec:Dictionary=g.VillageInteriors32.room(id)
		var asset:String=spec["asset"]
		assets[asset]=true
		assert(ResourceLoader.exists("res://art/village/interiors/%s.png" % asset))
		for race in 3:
			for gender in 2:
				g.hero_race=race;g.hero_gender=gender;g.interior_id=id
				assert(not g.is_blocked(g.INTERIOR_CENTER+g.VillageInteriors32.exit_offset(id)-Vector2(0,40)))
				assert(g.is_blocked(g.INTERIOR_CENTER+g.VillageInteriors32.room_size(id)*.5))
	assert(assets.size()==8 and g.VillageInteriors32.room(1)==g.VillageInteriors32.room(2))
	g.hero_race=0;g.hero_gender=0
	g.enter_village_house("Borin")
	var outside:Vector2=g.interior_return_pos
	g.player_pos=g.INTERIOR_CENTER+g.VillageInteriors32.link_offset(8)+Vector2(64,0)
	g.interact()
	assert(g.interior_id==6 and not g.is_blocked(g.player_pos))
	assert(g.interior_actors()[0]["name"]=="Pip")
	g.pip_loan_received=true;g.pip_loan_level=g.level
	g.player_pos=g.interior_actors()[0]["pos"]+Vector2(0,50)
	g.interact()
	assert(g.panel=="shop" and g.merchant_kind=="arcane")
	g.panel="";g.player_pos=g.INTERIOR_CENTER+g.VillageInteriors32.exit_offset(6)
	g.interact()
	assert(g.interior_id==8 and not g.is_blocked(g.player_pos) and g.interior_return_pos==outside)
	g.player_pos=g.INTERIOR_CENTER+g.VillageInteriors32.exit_offset(8)
	g.interact()
	assert(g.interior_id==-1 and g.player_pos==outside and not g.is_blocked(outside,outside))
	g.enter_village_house("Elara")
	g.player_pos=g.elara_healing_field_pos()
	assert(not g.is_blocked(g.player_pos))
	g.hp=5;g.energy=0;g.interact()
	assert(g.hp==g.max_hp() and g.energy==g.max_energy())
	g.enter_village_house("Arven")
	g.player_pos=g.INTERIOR_CENTER+Vector2(0,-164)
	assert(not g.is_blocked(g.player_pos))
	g.interact()
	assert(g.panel=="arena_entry")
	for name in g.StartScenery32.SCENERY:
		var texture:Texture2D=g.StartScenery32.scenery_texture(name)
		var image:=texture.get_image()
		for byte in range(3,image.get_data().size(),4):
			assert(image.get_data()[byte] in [0,255],"Scenery must not have translucent halos")
	print("VILLAGE_ROOM_ASSETS_OK eight backgrounds; every body size; Pip return and shop; healing; arena entrance; opaque pixel cutouts")
	g.queue_free();quit()
