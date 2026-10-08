extends SceneTree

class TestGame extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass

func _initialize()->void:
	call_deferred("run")

func approx_vec(a:Vector2,b:Vector2)->bool:
	return a.distance_to(b)<0.02

func run()->void:
	var g:=TestGame.new()
	root.add_child(g)
	assert(g.CAMERA_ZOOM_LEVELS==[1.0,0.85,0.70])
	assert(g.camera_zoom_index==0 and is_equal_approx(g.camera_zoom,1.0))
	assert(approx_vec(g.camera_view_size(),g.VIEW))

	g.set_camera_zoom_index(1,false)
	assert(g.camera_zoom_index==1 and is_equal_approx(g.camera_zoom,0.85))
	assert(approx_vec(g.camera_view_size(),g.VIEW/0.85))
	assert(g.camera_view_size().x>g.VIEW.x and g.camera_view_size().y>g.VIEW.y)

	g.set_camera_zoom_index(2,false)
	assert(g.camera_zoom_index==2 and is_equal_approx(g.camera_zoom,0.70))
	assert(approx_vec(g.camera_world_rect().size,g.VIEW/0.70))
	assert(g.camera_world_rect().size.x>1600.0 and g.camera_world_rect().size.y>900.0)

	g.set_camera_zoom_index(99,false)
	assert(g.camera_zoom_index==2)
	g.set_camera_zoom_index(-99,false)
	assert(g.camera_zoom_index==0 and is_equal_approx(g.camera_zoom,1.0))

	g.camera_pos=Vector2(400,250)
	g.set_camera_zoom_index(0,false)
	assert(approx_vec(g.screen_to_world(Vector2(576,324)),Vector2(976,574)))
	g.set_camera_zoom_index(1,false)
	assert(approx_vec(g.screen_to_world(Vector2(576,324)),Vector2(400,250)+Vector2(576,324)/0.85))
	g.set_camera_zoom_index(2,false)
	assert(approx_vec(g.screen_to_world(Vector2(576,324)),Vector2(400,250)+Vector2(576,324)/0.70))

	g.set_camera_zoom_index(2,false)
	g.world_builder.active=true
	assert(is_equal_approx(g.effective_camera_zoom(),1.0))
	assert(approx_vec(g.camera_view_size(),g.VIEW))
	g.world_builder.active=false
	assert(is_equal_approx(g.effective_camera_zoom(),0.70))

	# Menus own wheel input; a release cannot scroll a second time.
	var wheel:=InputEventMouseButton.new();wheel.button_index=MOUSE_BUTTON_WHEEL_DOWN;wheel.pressed=true
	g.panel="pause";g.set_camera_zoom_index(1,false);g._unhandled_input(wheel)
	assert(g.camera_zoom_index==1 and g.panel=="pause")
	g.panel="journal";g.menu_scroll=0;g._unhandled_input(wheel)
	assert(g.camera_zoom_index==1 and g.menu_scroll==1)
	wheel.pressed=false;g._unhandled_input(wheel);assert(g.menu_scroll==1)
	g.panel="";wheel.pressed=true;g._unhandled_input(wheel)
	assert(g.camera_zoom_index==2)
	print("CAMERA_ZOOM_OK levels=100/85/70 expanded_view=true mouse_aim_world_space=true builder_safe=true")
	g.queue_free()
	quit()
