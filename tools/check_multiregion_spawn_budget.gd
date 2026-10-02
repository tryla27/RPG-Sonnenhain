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

	# Five players on every world map => each region must independently reach 22 mobs.
	var peer := 1000
	for region in range(1,13):
		var center: Vector2 = g.safe_world_teleport_destination(g.region_rect(region).get_center(),region)
		assert(g.region_at(center) == region)
		for n in 5:
			g.remote_players[peer] = {
				"context":"world","instance_id":"world","konflux":false,"hp":100.0,
				"pos":[center.x + float(n%2)*24.0,center.y + float(n/2)*24.0]
			}
			peer += 1

	for tick in 20:
		g.spawn_dedicated_enemy()

	assert(g.normal_mob_count() == 264)
	for region in range(1,13):
		var count := g.server_region_normal_mob_count(region)
		assert(count == 22)
		for enemy in g.enemies:
			if g.region_at(Vector2(enemy["pos"])) != region: continue
			var type := int(enemy["type"])
			if type in [12,13,14] or bool(enemy.get("small_guardian",false)): continue
			assert(int(g.ENEMY_TYPES[type]["region"]) == region)
		print("MULTIREGION_SPAWN_OK region=",region," count=",count)

	# Inactive legacy and misplaced mobs must no longer block spawn capacity.
	var legacy := g.make_enemy(0,g.region_rect(1).get_center())
	legacy["context"]="world"
	legacy["instance_id"]="world"
	var wrong := g.make_enemy(0,g.region_rect(2).get_center())
	wrong["context"]="world"
	wrong["instance_id"]="world"
	wrong["spawned_at_ms"]=Time.get_ticks_msec()
	g.enemies.append(legacy)
	g.enemies.append(wrong)

	# Region 1 becomes inactive; region 2 remains active.
	var filtered := {}
	for id in g.remote_players.keys():
		var pos := g.network_player_position(int(id))
		if g.region_at(pos) != 1:
			filtered[id] = g.remote_players[id]
	g.remote_players = filtered
	g.server_cleanup_orphan_mobs()

	for enemy in g.enemies:
		var type := int(enemy.get("type",-1))
		if type in [12,13,14] or bool(enemy.get("small_guardian",false)) or bool(enemy.get("invasion",false)): continue
		var region := g.region_at(Vector2(enemy["pos"]))
		assert(int(g.ENEMY_TYPES[type]["region"]) == region)
		if region == 1:
			assert(enemy.has("spawned_at_ms"))

	print("MULTIREGION_SPAWN_MATRIX_OK all 12 maps independently reach 22 mobs; legacy/misplaced cleanup works")
	quit()
