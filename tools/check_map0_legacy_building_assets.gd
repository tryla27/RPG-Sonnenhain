extends SceneTree

const Well=preload("res://components/village_well_tiles_32.gd")

func _initialize()->void:
	assert(Well.TILE==32)
	var scenery:=FileAccess.get_file_as_string("res://components/start_scenery_32.gd")
	var houses:=FileAccess.get_file_as_string("res://components/village_house_tiles_32.gd")
	var main:=FileAccess.get_file_as_string("res://main.gd")
	assert(scenery.find('"brunnen":{')>=0)
	assert(ResourceLoader.exists("res://art/village/objects/brunnen.png"))
	assert(scenery.find('sprite(c,objects,Rect2(565,520,430,470)')==-1)
	assert(main.find('houses_192.png')==-1)
	assert(scenery.find('houses_192.png')==-1)
	assert(houses.find('const TILE:=32')>=0)
	print("MAP0_LEGACY_BUILDINGS_REMOVED_OK houses and well use current village assets")
	quit()
