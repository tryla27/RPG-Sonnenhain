extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void: pass
	func _process(_delta:float)->void: pass
	func save_game()->void: pass
	func announce_multiplayer_context()->void: pass
	func play_sound(_key)->void: pass
	func message(_text)->void: pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var source:=FileAccess.get_file_as_string("res://main.gd")
	assert(source.find('elif interior_id < 0 or arena_mode != "":')>=0,"arena input must route ability keys")
	var g:=TestGame.new()
	g.reset_class_skills()
	g.level=20
	g.class_id=1
	g.learned[16]=true
	g.skill_levels[16]=1
	g.slots[0]=16
	g.cooldowns[16]=9.0
	g.energy=1.0
	g.stamina=1.0
	g.player_pos=Vector2(900,1050)
	g.enter_arena("survival")
	assert(g.arena_mode=="survival")
	assert(is_equal_approx(g.energy,g.max_energy()))
	assert(is_equal_approx(g.stamina,g.max_stamina()))
	assert(is_equal_approx(float(g.cooldowns[16]),0.0))
	g.cooldowns[16]=7.0
	g.energy=1.0
	g.arena_intermission=0.0
	g.update_arena(0.1)
	assert(is_equal_approx(g.energy,g.max_energy()))
	assert(is_equal_approx(float(g.cooldowns[16]),0.0))
	print("ARENA_SPELLS_OK ability input routes in arena; resources and cooldowns reset per wave")
	g.free()
	quit()
