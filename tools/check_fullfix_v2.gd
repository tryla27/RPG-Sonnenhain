extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var source := FileAccess.get_file_as_string("res://main.gd")
	assert(source.contains("const CHEST_RESPAWN_SECONDS := 360.0"))
	assert(source.contains("func ensure_dedicated_region_population()"))
	assert(source.contains("func safe_enemy_knockback"))
	assert(source.contains("func safe_drop_position"))
	assert(source.contains("func server_reward_fallback_peer"))
	assert(source.contains("NEUER REKORD · 99 % HIGH-END-LUCK"))
	assert(source.contains("ARVENS TOP 5"))
	assert(source.contains("for gy in range(-14,15)"))
	var game = load("res://main.gd").new()
	assert(is_equal_approx(game.CHEST_RESPAWN_SECONDS,360.0))
	game.class_id=1
	game.level=25
	for i in 128:
		var rarity:int=game.arena_reward_rarity(30,true)
		assert(rarity>=2 and rarity<=4)
	var boss={"uid":1,"type":12,"elite":0,"pos":Vector2(7000,5000)}
	var moved:Vector2=game.safe_enemy_knockback(boss,Vector2.RIGHT)
	assert(moved.distance_to(Vector2(boss["pos"]))<=3.1)
	print("FULLFIX_V2_OK chest=360 arena_record_luck=true tile_arena=true knockback_boss_limited=true")
	game.free()
	quit(0)
