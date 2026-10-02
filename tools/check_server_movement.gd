extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var g = load("res://main.gd").new()
	root.add_child(g)
	g.konflux_preview_mode = true
	g.panel = ""
	g.network_mode = "host"
	var failures := 0
	# Sprintdynamik: gestufter Anlauf, Kurvenverlust und Klassenunterschiede.
	if g.sprint_speed_curve(0.25) >= g.sprint_speed_curve(0.75): failures += 1
	if g.sprint_turn_retention(Vector2.RIGHT,Vector2.LEFT) >= 0.5: failures += 1
	if g.sprint_turn_retention(Vector2.RIGHT,Vector2(1,0.15)) < 0.8: failures += 1
	g.class_id=0
	var warrior_drain:=g.sprint_drain_rate()
	var warrior_accel:=g.sprint_acceleration()
	g.class_id=2
	if g.sprint_drain_rate() <= warrior_drain: failures += 1
	if g.sprint_acceleration() <= warrior_accel: failures += 1
	if g.sprint_stamina_mult(1.0) <= g.sprint_stamina_mult(0.1): failures += 1
	var origin := Vector2(2050,900)
	g.remote_players = {
		2:{"context":"world","pos":[1770.0,900.0]},
		3:{"context":"world","pos":[2450.0,900.0]},
		4:{"context":"tavern","pos":[2051.0,900.0]}
	}
	if g.region_at(origin) == 0: failures += 1
	var target = g.nearest_network_player(origin,1300,g.region_at(origin))
	if int(target["peer"]) != 3: failures += 1
	var enemy_type := 0
	for i in g.ENEMY_TYPES.size():
		if int(g.ENEMY_TYPES[i]["region"]) == g.region_at(origin):
			enemy_type = i
			break
	g.enemies = [g.make_enemy(enemy_type,origin)]
	for frame in 60: g.update_dedicated_enemies(1.0/60.0)
	var finish: Vector2 = g.enemies[0]["pos"]
	if finish.x <= origin.x or absf(finish.y-origin.y) > 0.01: failures += 1
	if g.server_moving_mobs != 1: failures += 1
	g.remote_players.erase(3)
	if int(g.nearest_network_player(origin,1300,g.region_at(origin))["peer"]) != 0: failures += 1
	print("SERVER_MOVEMENT_CHECK failures=",failures," · sprint momentum / turn loss / class pacing / same-region targeting / interior excluded / straight pursuit / moving counter")
	g.queue_free()
	await process_frame
	quit(1 if failures else 0)
