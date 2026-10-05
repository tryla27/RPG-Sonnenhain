extends SceneTree

func _initialize()->void:
	var game=load("res://main.gd").new()
	var houses:Array[Rect2]=[]
	for prop in game.village_props():
		if prop["kind"]=="house":houses.append(game.prop_bounds(prop))
	for prop in game.village_props():
		if prop["kind"] not in ["tree","magic_tree"]:continue
		for house in houses:assert(not game.prop_bounds(prop).intersects(house),"Tree art overlaps house art")
	for i in houses.size():
		for j in range(i+1,houses.size()):assert(not houses[i].intersects(houses[j]),"Buildings overlap")
	for id in 9:
		game.interior_id=id
		var radius:float=game.hero_collision_radius()
		var center:Vector2=game.INTERIOR_CENTER
		var entry:Vector2=center+game.VillageInteriors32.exit_offset(id)-Vector2(0,40)
		assert(not game.is_blocked(entry),"Blocked room entrance")
		assert(not game.is_blocked(center+game.VillageInteriors32.exit_offset(id)),"Blocked exit")
		for rect in game.VillageInteriors32.furniture(id):
			assert(game.is_blocked(center+rect.get_center()),"Furniture lacks collision")
			assert(game.is_blocked(center+Vector2(rect.get_center().x,rect.end.y+radius-1)),"Body radius missing")
			# A single long movement must not tunnel through a table, cabinet or bench.
			var start:Vector2=center+Vector2(rect.get_center().x,rect.end.y+radius+2)
			if not game.is_blocked(start):
				game.player_pos=start
				game.move_with_collision(Vector2(0,-rect.size.y-radius*2-32))
				assert(game.player_pos.y>=center.y+rect.end.y+radius-0.1,"Movement tunneled through furniture")
		var queue:Array[Vector2i]=[Vector2i(((entry-center)/8).round())]
		var reached:Dictionary={queue[0]:true}
		var cursor:=0
		while cursor<queue.size():
			var cell:=queue[cursor];cursor+=1
			for step in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
				var next:Vector2i=cell+step
				if reached.has(next) or game.is_blocked(center+Vector2(next)*8):continue
				reached[next]=true;queue.append(next)
		for actor in game.interior_actors():
			assert(not game.is_blocked(actor["pos"]),"NPC embedded in furniture")
			var reachable:=false
			for cell in reached:
				if (center+Vector2(cell)*8).distance_to(actor["pos"])<40:reachable=true;break
			assert(reachable,"Room NPC inaccessible from entrance")
	game.free()
	print("VILLAGE_COLLISIONS_OK all tree/house bounds disjoint; nine rooms, furniture, body radius, swept movement, exits and NPC routes")
	quit()
