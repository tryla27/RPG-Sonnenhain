extends SceneTree
func _initialize():
	var game=load("res://main.gd").new()
	var map=load("res://components/start_tilemap_32.gd")
	map.prepare(Callable(game,"distance_to_trail"))
	assert(map.BOUNDS==game.region_rect(0))
	assert(map.EAST_EXIT==game.VILLAGE_GATES[0] and map.SOUTH_EXIT==game.VILLAGE_GATES[1])
	assert(game.BORIN_HOUSE_POS.x>game.WAYSTONES[0].x and game.BORIN_HOUSE_POS.y<game.WAYSTONES[0].y,"Borin house must stay right-above Map 0 spawn")
	assert(game.BORIN_MAGIC_TREE_POS.x>game.BORIN_HOUSE_POS.x and game.BORIN_MAGIC_TREE_POS.y<game.WAYSTONES[0].y,"Borin magic tree must stay beside the house above spawn")
	assert(game.BORIN_CRYSTAL_POS.y<game.WAYSTONES[0].y,"Fusion crystal must stay in Borin's upper spawn area")
	assert(game.region_at(map.EAST_EXIT+Vector2.RIGHT)==1)
	assert(game.region_at(map.SOUTH_EXIT+Vector2.DOWN)==6)
	var start:=Vector2i(floori(game.WAYSTONES[0].x/32),floori((game.WAYSTONES[0].y+180)/32))
	var queue:Array[Vector2i]=[start];var reached:Dictionary={start:true};var cursor:=0
	while cursor<queue.size():
		var cell:=queue[cursor];cursor+=1
		for step in [Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]:
			var neighbor:Vector2i=cell+step
			if not reached.has(neighbor) and int(map.terrain.get(neighbor,0))>0:
				reached[neighbor]=true;queue.append(neighbor)
	for gate in game.VILLAGE_GATES:
		var inside:Vector2=gate-Vector2(1,0) if gate.x==1780 else gate-Vector2(0,1)
		var cell:=Vector2i(floori(inside.x/32),floori(inside.y/32))
		assert(map.material_at(inside) in ["village_stone","earth_path"],"Gate path must use native road material")
		assert(int(map.terrain[cell])>0,"Gate path must remain traversable")
		assert(reached.has(cell),"Exit has no continuous path from spawn")
	for home in game.house_positions():
		var house:Dictionary={}
		for candidate in game.VillageLayout.SHOPS:
			if Vector2(candidate["house"])==Vector2(home):
				house=candidate
				break
		assert(not house.is_empty(),"Missing village house metadata: "+str(home))
		var door:Vector2=game.village_house_door(house)
		var cell:=Vector2i(floori(door.x/32),floori(door.y/32))
		assert(reached.has(cell),"Disconnected live house path: "+str(home))
	assert(map.terrain.size()==56*82)
	game.free()
	print("MAP0_TRANSITIONS_OK unchanged exits, native gate roads, continuous spawn routes and all live houses including Borin")
	quit()
