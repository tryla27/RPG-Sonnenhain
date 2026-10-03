extends SceneTree
const Houses=preload("res://components/village_house_tiles_32.gd")
const Scenery=preload("res://components/start_scenery_32.gd")

func _initialize()->void:
	assert(Houses.TILE==32)
	var source:=FileAccess.get_file_as_string("res://components/start_scenery_32.gd")
	var main:=FileAccess.get_file_as_string("res://main.gd")
	assert(source.find("houses_192.png")==-1)
	assert(main.find("houses_192.png")==-1)
	assert(source.find("VillageHouseTiles32.paint(c,p,kind)")>=0)
	assert(source.find('VillageHouseTiles32.paint(c,p,"borin")')>=0)
	assert(source.find('VillageHouseTiles32.paint(c,p,"arena")')>=0)
	# Footprints remain compatible with existing interaction/collision layout.
	assert(Vector2(6,5)*Houses.TILE==Vector2(192,160))
	assert(Vector2(8,7)*Houses.TILE==Vector2(256,224))
	assert(Vector2(12,7)*Houses.TILE==Vector2(384,224))
	print("MAP0_TILE_HOUSES_OK legacy atlas detached; normal/Borin/arena use native 32px composition")
	quit()
