extends "res://main.gd"
var frames := 0

func _ready() -> void:
	super._ready()
	konflux_preview_mode = true
	panel = ""
	class_id = 2

func _process(_delta: float) -> void:
	frames += 1
	queue_redraw()
	if frames == 8:
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("D:/SonnenhainRPG-Audio/game-v28-review/pvp-design/bogen-griff-pruefung.png")
		print("BOW_VISUAL_OK six bodies, four directions, idle/walking/attack")
		get_tree().quit()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW),Color("32423b"))
	text_at(Vector2(24,34),"BOGEN · HANDGRIFF · ALLE KÖRPER UND RICHTUNGEN",24,Color("ffe0a4"))
	for row in 6:
		hero_race = int(row/2.0)
		hero_gender = row%2
		text_at(Vector2(12,90+row*87),["Mensch","Ork","Roboter"][hero_race]+(" M" if hero_gender==0 else " W"),13)
		for col in 12:
			var direction: Vector2 = [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN][col%4]
			walk_phase = float(col)*0.7
			swing_duration = 0.24
			swing_timer = 0.13 if col >= 8 else 0.0
			draw_hero(Vector2(155+col*80,112+row*87),0.85,col>=4,direction)
