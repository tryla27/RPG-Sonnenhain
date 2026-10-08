extends SceneTree

func _initialize()->void:
	var game=load("res://main.gd").new()
	var forecourts=preload("res://components/village_forecourts.gd")
	for shop in game.VillageLayout.SHOPS:
		if shop.has("shared_with"):continue
		var count:=0
		for item in forecourts.ITEMS:
			if item["owner"]==shop["kind"]:count+=1
		assert(count>=1 and count<=2,"each unique house needs one or two themed objects")
		var door:Vector2=game.village_house_door(shop)
		assert(not forecourts.blocked(door+Vector2(0,48),18),"exterior objects must leave the doorway clear")
	for item in forecourts.ITEMS:assert(game.is_blocked(item["point"],item["point"]),"exterior object is missing collision")
	var houses:Array[Rect2]=[]
	for prop in game.village_props():
		if prop["kind"]=="house":houses.append(game.prop_bounds(prop))
	for prop in game.village_props():
		if prop["kind"]=="house":continue
		if prop["kind"]=="forecourt":
			# Large building PNGs include transparent space above their roof silhouettes.
			# Forecourt objects must clear their own facade and every physical building floor.
			for item in forecourts.ITEMS:
				if item["point"]!=prop["point"]:continue
				for shop in game.VillageLayout.SHOPS:
					if shop.has("shared_with"):continue
					assert(not game.prop_bounds(prop).intersects(game.VillageBuildings.solid(shop["house"],shop["kind"])),"Forecourt overlaps building footprint")
					if shop["kind"]==item["owner"]:assert(not game.prop_bounds(prop).intersects(game.VillageBuildings.bounds(shop["house"],shop["kind"])),"Object overlaps its own facade")
			continue
		if prop["kind"]=="mountain":
			# The hill is a backdrop behind roofs; its physical ground must remain clear of buildings.
			game.VillageElevation.Mountain.prepare()
			for shop in game.VillageLayout.SHOPS:
				if shop.has("shared_with"):continue
				var floor_rect:Rect2=game.VillageBuildings.solid(shop["house"],shop["kind"])
				var footprint:=PackedVector2Array([floor_rect.position,Vector2(floor_rect.end.x,floor_rect.position.y),floor_rect.end,Vector2(floor_rect.position.x,floor_rect.end.y)])
				assert(Geometry2D.intersect_polygons(game.VillageElevation.Mountain.contours[0],footprint).is_empty(),"Mountain overlaps building footprint")
			continue
		if prop["kind"]=="lamp":
			for shop in game.VillageLayout.SHOPS:
				if shop.has("shared_with"):continue
				assert(not game.VillageBuildings.solid(shop["house"],shop["kind"]).intersects(Rect2(prop["point"]+Vector2(-10,2),Vector2(20,8))),"Lantern base overlaps solid building")
			continue
		for house in houses:assert(not game.prop_bounds(prop).intersects(house),"Tree art overlaps house art")
	var spawn:Rect2=game.SpawnPlatform32.bounds(game.WAYSTONES[0])
	for prop in game.village_props():
		assert(not game.prop_bounds(prop).intersects(spawn),"Dorfobjekt überlappt Spawn: %s" % str(prop))
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
		if id==8:
			assert(reached.has(Vector2i(((game.VillageInteriors32.link_offset(8)+Vector2(64,0))/8).round())),"Pip's side door is unreachable")
	game.free()
	print("VILLAGE_COLLISIONS_OK all tree/house bounds disjoint; nine rooms, furniture, body radius, swept movement, exits and NPC routes")
	quit()
