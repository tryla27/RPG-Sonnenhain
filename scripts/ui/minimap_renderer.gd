class_name MinimapRenderer
extends RefCounted

const REGION_COLORS := [
	Color("6e9d72"), Color("86aa70"), Color("3f6655"), Color("62676b"),
	Color("3e6774"), Color("80564a"), Color("baa77b"), Color("514963"),
	Color("5d7776"), Color("aa9058"), Color("4f7d81"), Color("62667c"),
	Color("776d8b")
]

static func draw_world(game, rect: Rect2) -> void:
	var center := rect.get_center()
	var radius := minf(rect.size.x, rect.size.y) * 0.5 - 7.0
	var pulse := 0.72 + sin(float(game.world_time) * 4.0) * 0.18

	game.draw_circle(center, radius + 7.0, Color("5d4427"))
	game.draw_circle(center, radius + 4.0, Color("d8b66f"))
	game.draw_circle(center, radius, Color("17282d"))

	var inset := rect.grow(-7.0)
	var world_radius := 1200.0
	var scale_map := inset.size / (world_radius * 2.0)
	var start_world: Vector2 = game.player_pos - Vector2(world_radius, world_radius)
	var grid_x := 21
	var grid_y := 21
	var cell_size := inset.size / Vector2(grid_x, grid_y)

	for gx in grid_x:
		for gy in grid_y:
			var tile_center := inset.position + Vector2((gx + 0.5) * cell_size.x, (gy + 0.5) * cell_size.y)
			if tile_center.distance_to(center) > radius - 3.0:
				continue
			var point := start_world + Vector2(
				(gx + 0.5) * world_radius * 2.0 / grid_x,
				(gy + 0.5) * world_radius * 2.0 / grid_y
			)
			point = point.clamp(Vector2.ZERO, game.WORLD)
			var area := clampi(int(game.visual_region_at(point)), 0, REGION_COLORS.size() - 1)
			var tint: Color = REGION_COLORS[area]
			if float(game.distance_to_trail(point)) < 95.0:
				tint = Color("d2ba86")
			elif bool(game.is_blocked(point)):
				tint = Color("5d3b3a")
			if area < game.discovered_regions.size() and not bool(game.discovered_regions[area]):
				tint = tint.darkened(0.62)
			game.draw_rect(
				Rect2(inset.position + Vector2(gx * cell_size.x, gy * cell_size.y), cell_size + Vector2.ONE),
				tint
			)

	_draw_landmarks(game, center, radius, inset, start_world, scale_map)
	_draw_waystones(game, center, radius, inset, start_world, scale_map, pulse)
	_draw_portals(game, center, radius, inset, start_world, scale_map)
	_draw_dungeons(game, center, radius, inset, start_world, scale_map)
	_draw_events(game, center, radius, inset, start_world, scale_map)
	_draw_enemies(game, center, radius, inset, start_world, scale_map)
	_draw_quests(game, center, radius, inset, start_world, scale_map)
	_draw_player(game, center)
	_draw_compass(game, rect, center, radius)

	game.draw_arc(center, radius + 3.0, 0.0, TAU, 64, Color("f0d393"), 3.0)

static func _inside(point: Vector2, center: Vector2, radius: float, margin: float = 7.0) -> bool:
	return point.distance_to(center) < radius - margin

static func _map_point(world_pos: Vector2, inset: Rect2, start_world: Vector2, scale_map: Vector2) -> Vector2:
	return inset.position + (world_pos - start_world) * scale_map

static func _draw_landmarks(game, center: Vector2, radius: float, inset: Rect2, start_world: Vector2, scale_map: Vector2) -> void:
	for landmark in game.LANDMARKS:
		var point := _map_point(landmark["pos"], inset, start_world, scale_map)
		if _inside(point, center, radius):
			game.draw_rect(Rect2(point - Vector2(2.5, 2.5), Vector2(5, 5)), Color("e9c78a"))
	for npc in game.NPCS:
		var point := _map_point(npc["pos"], inset, start_world, scale_map)
		if _inside(point, center, radius):
			game.draw_circle(point, 2.2, Color("f6df8d"))

static func _draw_waystones(game, center: Vector2, radius: float, inset: Rect2, start_world: Vector2, scale_map: Vector2, pulse: float) -> void:
	for i in game.WAYSTONES.size():
		var point := _map_point(game.WAYSTONES[i], inset, start_world, scale_map)
		if not _inside(point, center, radius, 8.0):
			continue
		if bool(game.waystone_unlocked[i]):
			game.draw_circle(point, 6.0, Color(0.30, 0.88, 1.0, 0.22 + pulse * 0.35))
			game.draw_arc(point, 4.4, 0.0, TAU, 16, Color("8defff"), 2.0)
			game.draw_circle(point, 2.0, Color("d7fbff"))
		else:
			game.draw_arc(point, 4.0, 0.0, TAU, 12, Color("858d91"), 2.0)
			game.draw_circle(point, 1.8, Color("5c666a"))

static func _draw_portals(game, center: Vector2, radius: float, inset: Rect2, start_world: Vector2, scale_map: Vector2) -> void:
	for portal in game.PORTALS:
		for endpoint in [portal[0], portal[1]]:
			var point := _map_point(endpoint, inset, start_world, scale_map)
			if _inside(point, center, radius) and bool(game.region_available(int(portal[2]))):
				game.draw_arc(point, 4.0, 0.0, TAU, 14, Color("eac8ff"), 2.0)

static func _draw_dungeons(game, center: Vector2, radius: float, inset: Rect2, start_world: Vector2, scale_map: Vector2) -> void:
	for index in game.DUNGEON_ENTRANCES.size():
		var entrance: Vector2 = game.LANDMARKS[int(game.DUNGEON_ENTRANCES[index])]["pos"]
		if not bool(game.region_available(int(game.region_at(entrance)))):
			continue
		var point := _map_point(entrance, inset, start_world, scale_map)
		if _inside(point, center, radius, 8.0):
			game.draw_colored_polygon(PackedVector2Array([
				point + Vector2(0, -5),
				point + Vector2(-4, 4),
				point + Vector2(4, 4)
			]), Color("e8d0b0"))

static func _draw_events(game, center: Vector2, radius: float, inset: Rect2, start_world: Vector2, scale_map: Vector2) -> void:
	for i in game.WORLD_EVENTS.size():
		if int(game.event_states[i]) == 3:
			continue
		var point := _map_point(game.WORLD_EVENTS[i]["pos"], inset, start_world, scale_map)
		if _inside(point, center, radius) and bool(game.region_available(int(game.WORLD_EVENTS[i]["region"]))):
			game.draw_arc(point, 4.5, 0.0, TAU, 14, Color("ffe399"), 2.0)

static func _draw_enemies(game, center: Vector2, radius: float, inset: Rect2, start_world: Vector2, scale_map: Vector2) -> void:
	for enemy in game.enemies:
		var point := _map_point(enemy["pos"], inset, start_world, scale_map)
		if not _inside(point, center, radius, 5.0):
			continue
		var type_id := int(enemy.get("type", 0))
		var boss := false
		if type_id >= 0 and type_id < game.ENEMY_TYPES.size():
			var mob_data = game.ENEMY_TYPES[type_id].get("mob_data", null)
			boss = mob_data != null and bool(mob_data.boss)
		if boss:
			game.draw_circle(point, 4.2, Color("ff5c55"))
			game.draw_arc(point, 6.0, 0.0, TAU, 16, Color("ffb07a"), 2.0)
		else:
			game.draw_circle(point, 2.3, Color("ed7474"))

static func _draw_quests(game, center: Vector2, radius: float, inset: Rect2, start_world: Vector2, scale_map: Vector2) -> void:
	for i in game.QUESTS.size():
		if i >= game.quests.size():
			continue
		var state := int(game.quests[i].get("state", 0))
		if state not in [1, 2]:
			continue
		var target_pos: Vector2
		if state == 1:
			target_pos = game.region_rect(int(game.ENEMY_TYPES[int(game.QUESTS[i]["target"])]["region"])).get_center()
		else:
			target_pos = game.npc_position(String(game.QUESTS[i]["npc"]))
		var point := _map_point(target_pos, inset, start_world, scale_map)
		if _inside(point, center, radius, 8.0):
			game.draw_circle(point, 5.0, Color(1.0, 0.72, 0.15, 0.18))
			game.draw_arc(point, 4.0, 0.0, TAU, 16, Color("ffd65f"), 2.0)
			game.draw_circle(point, 1.6, Color("fff3ba"))

static func _draw_player(game, center: Vector2) -> void:
	var look: Vector2 = game.facing.normalized()
	if look.length_squared() < 0.001:
		look = Vector2.DOWN
	var side := look.rotated(PI * 0.5)
	var arrow := PackedVector2Array([
		center + look * 9.0,
		center - look * 5.0 + side * 5.0,
		center - look * 3.0,
		center - look * 5.0 - side * 5.0
	])
	game.draw_colored_polygon(arrow, Color("dffbff"))
	game.draw_polyline(PackedVector2Array([arrow[0], arrow[1], arrow[2], arrow[3], arrow[0]]), Color("3aaee8"), 1.7)

static func _draw_compass(game, rect: Rect2, center: Vector2, radius: float) -> void:
	var compass := center + Vector2(0, -radius - 2.0)
	game.draw_circle(compass, 9.0, Color("2a2520"))
	game.draw_arc(compass, 9.0, 0.0, TAU, 20, Color("e2c078"), 2.0)
	game.text_at(compass + Vector2(-5, 4), "N", 11, Color("fff1c0"))
	var label := str(game.region_name(int(game.region_at(game.player_pos))))
	game.text_at(Vector2(center.x - 65.0, rect.end.y + 13.0), label, 11, Color("f3db9a"), HORIZONTAL_ALIGNMENT_CENTER, 130)
