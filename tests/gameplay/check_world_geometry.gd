extends SceneTree
# Verhaltenstest für components/world_geometry.gd und die Weiterleitungen in main.gd.

const Geo=preload("res://components/world_geometry.gd")
const Content=preload("res://components/game_content.gd")

func _initialize()->void:
	# 13 Gebiete: jedes Rechteck gehört genau zu seinem Gebiet, ohne Lücken.
	var total_area:=0.0
	for id in 13:
		var rect:=Geo.region_rect(id)
		total_area+=rect.get_area()
		assert(Geo.region_at(rect.get_center())==id)
		assert(Geo.region_at(rect.position)==id)
		assert(Geo.region_at(rect.end-Vector2(1,1))==id)
	assert(is_equal_approx(total_area,11000.0*8500.0+5000.0*9600.0))
	# Grenzen gehören zum nächsten Gebiet; außerhalb wird sicher geklemmt.
	assert(Geo.region_at(Vector2(1779.9,100))==0 and Geo.region_at(Vector2(1780,100))==1)
	assert(Geo.region_at(Vector2(100,2600))==6)
	assert(Geo.region_at(Vector2(12000,-500))==8 and Geo.region_at(Vector2(12000,99999))==12)

	# Wegabstand: Wegpunkte liegen auf dem Weg, Abstand senkrecht zum Segment stimmt.
	for trail in Content.TRAILS:
		for point in trail:
			assert(is_zero_approx(Geo.distance_to_trail(point)))
	var a:Vector2=Content.TRAILS[4][4]
	var b:Vector2=Content.TRAILS[4][5]
	var mid:=(a+b)*0.5
	var normal:=(b-a).orthogonal().normalized()
	assert(Geo.distance_to_trail(mid+normal*30.0)<=30.0+0.01)

	# Wegsteine: jeder Stein ist sein eigener nächster Stein.
	assert(Geo.WAYSTONES.size()==12)
	for stone in Geo.WAYSTONES:
		assert(Geo.nearest_waystone(stone+Vector2(5,5))==stone)

	# Klassenboss-Arenen und -Häuser.
	for i in Geo.CLASS_BOSS_SITES.size():
		assert(Geo.class_boss_arena_index_at(Geo.CLASS_BOSS_SITES[i])==i)
		assert(Geo.class_boss_arena_index_at(Geo.CLASS_BOSS_SITES[i]+Vector2(Geo.CLASS_BOSS_ARENA_RADIUS+10,0))==-1)
		assert(Geo.class_boss_arena_index_at(Geo.CLASS_BOSS_SITES[i]+Vector2(Geo.CLASS_BOSS_ARENA_RADIUS+10,0),20.0)==i)
		var house:=Geo.class_boss_house_rect(i)
		assert(house.size==Geo.CLASS_BOSS_HOUSE_SIZE)
		assert(Geo.point_near_class_boss_house(house.get_center()))
		assert(not Geo.point_near_class_boss_house(house.position-Vector2(10,10)))
		assert(Geo.point_near_class_boss_house(house.position-Vector2(10,10),20.0))
	assert(Geo.class_boss_house_rect(-5)==Geo.class_boss_house_rect(0))
	assert(Geo.class_boss_house_rect(9)==Geo.class_boss_house_rect(2))

	# hash_cell ist deterministisch und bleibt im Bereich 0..996.
	for x in range(-40,40,3):
		for y in range(-40,40,7):
			var h:=Geo.hash_cell(x,y)
			assert(h>=0 and h<997 and h==Geo.hash_cell(x,y))

	# main.gd leitet weiterhin unter den alten Namen weiter.
	var game=load("res://main.gd").new()
	assert(game.region_at(Vector2(13000,5000))==Geo.region_at(Vector2(13000,5000)))
	assert(game.WAYSTONES==Geo.WAYSTONES)
	assert(game.distance_to_trail(Vector2(4000,3000))==Geo.distance_to_trail(Vector2(4000,3000)))
	game.free()
	print("WORLD_GEOMETRY_OK regions, trails, waystones and class boss sites")
	quit()
