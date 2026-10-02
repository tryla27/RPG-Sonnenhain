extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready() -> void: pass
	func _process(_delta: float) -> void: pass
	func _draw() -> void: pass
	func save_game() -> void: pass

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var g = TestGame.new()
	root.add_child(g)
	g.konflux_preview_mode = true
	g.network_mode = "host"
	g.dedicated_server_mode = true
	g.character_created = true
	for region in range(1,13):
		var center: Vector2 = g.safe_world_teleport_destination(g.region_rect(region).get_center(),region)
		assert(g.region_at(center) == region)
		var peer_id := 1000 + region
		g.remote_players = {peer_id:{
			"context":"world","instance_id":"world","konflux":false,"hp":100.0,
			"pos":[center.x,center.y]
		}}
		g.enemies.clear()
		var pool: Array = []
		for type in range(g.ENEMY_TYPES.size()):
			if type not in [12,13,14] and int(g.ENEMY_TYPES[type]["region"]) == region:
				pool.append(type)
		assert(pool.size() >= 2)
		var successes := 0
		for attempt in 16:
			if g.server_spawn_enemy_for_region(region,[peer_id]):
				successes += 1
		assert(successes >= 2)
		for enemy in g.enemies:
			var type := int(enemy["type"])
			var pos: Vector2 = enemy["pos"]
			assert(type in pool)
			assert(int(g.ENEMY_TYPES[type]["region"]) == region)
			assert(g.region_at(pos) == region)
			assert(pos.distance_to(center) >= 420.0)
			assert(not g.waystone_safe_at(pos))
		print("REGION_SPAWN_OK region=",region," pool=",pool," spawned=",successes)
	print("REGION_SPAWN_MATRIX_OK regions1-12 matching monster pools and safe spawn positions")
	quit()
