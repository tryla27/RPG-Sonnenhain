extends SceneTree
# Bildfolgen für die Fusionsregel D1: Wo zündet eine Fusion?
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_fusion_impact.gd -- <ausgabeordner>

const FusionRules=preload("res://components/fusion_rules.gd")
const EXAMPLES:=[[16,1,"Feuerball + Schildwall"],[3,17,"Durchschlagspfeil + Frostnova"],[2,19,"Sprungangriff + Rissnova"],[1,36,"Reaktorwall (zwei Schilde)"]]

class Game extends "res://main.gd":
	# Blickrichtung fest nach rechts, statt der Maus zu folgen.
	func mouse_world_position()->Vector2:return player_pos+Vector2(300,0)
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func fusion_id(g,a:int,b:int)->int:
	for fusion in g.BUILTIN_FUSIONS:
		if FusionRules.normalized_key(int(fusion["a"]),int(fusion["b"]))==FusionRules.normalized_key(a,b):return int(fusion["id"])
	return FusionRules.output_id(a,b)

func capture()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0] if args.size()>0 else "user://"
	DirAccess.make_dir_recursive_absolute(out)
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(1152,648)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var g:=Game.new()
	viewport.add_child(g)
	for i in 45:await process_frame
	g.panel=""
	g.character_created=true
	g.hero_name="Angelo"
	g.level=20
	# Freie Wiese in den Blütenwiesen, abseits von Ereignissen und Häusern.
	var spot:Vector2=g.region_rect(1).position+Vector2(520,g.region_rect(1).size.y-520)
	for n in EXAMPLES.size():
		var example:Array=EXAMPLES[n]
		g.player_pos=spot
		g.facing=Vector2.RIGHT
		g.enemies.clear()
		g.projectiles.clear()
		var dummy:Dictionary=g.make_enemy(0,spot+Vector2(260,0))
		dummy["hp"]=99999.0
		dummy["max_hp"]=99999.0
		dummy["speed"]=0.0
		g.enemies.append(dummy)
		for i in 90:await process_frame
		g.enemies=[dummy]
		dummy["pos"]=spot+Vector2(260,0)
		dummy["stun"]=999.0
		g.execute_ability_effects(fusion_id(g,int(example[0]),int(example[1])),3,90,g.player_pos,Vector2.RIGHT)
		for frame in 16:
			dummy["stun"]=999.0
			for i in 3:
				await process_frame
				await RenderingServer.frame_post_draw
			viewport.get_texture().get_image().save_png(out.path_join("fusion%d_%02d.png" % [n,frame]))
		print("CAPTURED ",example[2])
	quit()
