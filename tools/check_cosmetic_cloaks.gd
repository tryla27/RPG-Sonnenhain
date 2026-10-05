extends SceneTree

class TestGame:
	extends "res://main.gd"
	func save_game(): pass
	func announce_multiplayer_context(): pass

func _initialize(): call_deferred("run")

func half_pixel(value:float)->bool:
	return is_equal_approx(value*2.0,round(value*2.0))

func run():
	var g:=TestGame.new()
	assert(g.COSMETIC_ACCENTS.size()==20,"Atelier muss exakt 20 Farbtöne anbieten")
	assert(g.CLOAK_STYLES.size()==4,"Atelier muss vier Umhang-Auswahlen behalten")
	assert(not bool(g.cloak_style_metrics(0)["visible"]),"Umhang 1/4 bleibt die Auswahl ohne Umhang")
	for style in range(1,4):
		var metrics:Dictionary=g.cloak_style_metrics(style)
		assert(bool(metrics["visible"]))
		assert(float(metrics["length"])>0.0 and float(metrics["hem"])>0.0 and float(metrics["inertia"])>0.0)
	for accent_index in range(20):
		var accent:Color=g.COSMETIC_ACCENTS[accent_index]
		assert(accent.a>0.99,"Jeder Farbton muss deckend und darstellbar sein")

	var idle:Dictionary=g.cloak_motion_offsets(Vector2.DOWN,3,false,0.0,0.0,0.0,0.4)
	var walk:Dictionary=g.cloak_motion_offsets(Vector2.DOWN,3,true,0.0,0.0,0.0,0.4)
	var sprint:Dictionary=g.cloak_motion_offsets(Vector2.DOWN,3,true,1.0,0.0,0.0,0.4)
	var dash:Dictionary=g.cloak_motion_offsets(Vector2.DOWN,3,true,0.0,1.0,0.0,0.4)
	var jump:Dictionary=g.cloak_motion_offsets(Vector2.DOWN,3,true,0.0,0.0,1.0,0.4)
	assert(abs(float(sprint["tail"].y))>abs(float(walk["tail"].y)),"Sprint muss den Umhang stärker nach hinten ziehen")
	assert(abs(float(dash["tail"].y))>abs(float(sprint["tail"].y)),"Dash muss den stärksten Rückwärtszug erzeugen")
	assert(float(jump["lift"])>float(walk["lift"]),"Sprung muss den Saum sichtbar anheben")
	assert(g.cloak_motion_offsets(Vector2.LEFT,2,true,1.0,0.0,0.0,0.2)["tail"].x>0.0)
	assert(g.cloak_motion_offsets(Vector2.RIGHT,2,true,1.0,0.0,0.0,0.2)["tail"].x<0.0)
	assert(g.cloak_motion_offsets(Vector2.UP,2,true,1.0,0.0,0.0,0.2)["tail"].y>0.0)
	assert(g.cloak_motion_offsets(Vector2.DOWN,2,true,1.0,0.0,0.0,0.2)["tail"].y<0.0)
	for direction in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		for style in range(1,4):
			var motion:Dictionary=g.cloak_motion_offsets(direction,style,true,0.75,0.4,0.3,1.25)
			var tail:Vector2=motion["tail"]
			assert(half_pixel(tail.x) and half_pixel(tail.y) and half_pixel(float(motion["lift"])) and half_pixel(float(motion["flutter"])),"Umhangbewegung muss auf dem Pixelraster bleiben")
	print("COSMETIC_CLOAKS_OK 20 colors; 4 selections; idle/walk/sprint/dash/jump; pixel snapped")
	g.free()
	quit()
