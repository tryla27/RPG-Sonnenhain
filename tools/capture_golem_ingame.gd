extends SceneTree
# Vorschau: der Dunkle Golem im echten Spielbild (Himmelsgarten am Altar),
# gezeichnet über draw_enemy wie im Spiel.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_golem_ingame.gd -- <datei.png>
const GolemBoss=preload("res://components/golem_boss.gd")
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 8:await process_frame
	g.character_created=true;g.level=42;g.panel=""
	g.player_pos=GolemBoss.ALTAR+Vector2(-260,260)
	g.enemies.clear()
	var golem:Dictionary=g.golem_world.summon(g,1)
	golem["pos"]=GolemBoss.ALTAR+Vector2(60,120);golem["golem"]["state"]="walk";golem["walking"]=true
	golem["facing"]=Vector2.LEFT
	g.enemies.append(golem)
	for i in 30:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
