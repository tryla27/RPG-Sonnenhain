extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void: pass
	func _process(_delta:float)->void: pass
	func save_game()->void: pass
	func announce_multiplayer_context()->void: pass
	func play_sound(_key:String)->void: pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	root.add_child(g)
	g.class_id=1
	g.bindings=g.DEFAULT_BINDINGS.duplicate()
	g.reset_class_skills()
	g.interior_id=0
	g.arena_mode="survival"
	g.panel=""
	g.player_pos=g.ARENA_CENTER
	g.facing=Vector2.RIGHT
	g.learned[16]=true
	g.skill_levels[16]=1
	g.slots[0]=16
	g.energy=100.0
	g.cooldowns[16]=0.0

	var key:=InputEventKey.new()
	key.keycode=KEY_1
	key.pressed=true
	g._unhandled_input(key)
	assert(g.energy<100.0,"arena must route ability keys even when entered from an interior")
	assert(float(g.cooldowns[16])>0.0,"arena spell must start its cooldown")

	g.cooldowns[16]=5.0
	g.arena_mode=""
	g.enter_arena("survival")
	assert(float(g.cooldowns[16])==0.0,"arena entry must reset skill cooldowns")
	assert(g.energy==g.max_energy(),"arena entry must refill energy")
	print("ARENA_SPELL_INPUT_OK ability 1 works from interior arena context; entry resets cooldowns")
	g.queue_free()
	quit()
