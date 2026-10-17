extends SceneTree
## Vorher-/Nachher-Bilder des Architektur-Sets v2 an echten Spielorten:
## Mauertor, lange Mauer, Mauerecke, Ruinen, Ostgrenze, Dämmergrat, Himmelsgarten
## und die Felsen (Blütenwiesen, Ascheberge, Mondküste, Dämmergrat).
## Mit "-- <ordner> felsen" nur die Felsorte.
## Aufruf: godot --path . -s tools/capture_architecture.gd -- <Ausgabeordner>
## Schreibt je Ort <ort>_alt.png (Klötzchenmodelle) und <ort>_neu.png (Blender)
## sowie architecture_compare.png. Kein Konto, keine Spielstände.
const Kit=preload("res://components/architecture_kit.gd")
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass

const SPOTS:=[["mauertor",Vector2(5000,1250)],["mauer_lang",Vector2(5000,2500)],["mauerecke",Vector2(5000,4200)],
	["ruinen",Vector2(6600,2100)],["ostgrenze",Vector2(11300,1920)],["daemmergrat",Vector2(13500,6700)],["himmelsgarten",Vector2(13500,8600)]]
const ROCK_SPOTS:=[["fels_wiese",Vector2(2180,2300)],["fels_asche",Vector2(9900,800)],["fels_kueste",Vector2(900,4400)],["fels_grat",Vector2(13400,7060)]]

func _initialize()->void:call_deferred("run")

func shoot(g,vp:SubViewport,pos:Vector2)->Image:
	g.world_obstacles_3d.signature="";g.world_obstacles_3d.collection_clock=0.0
	g.player_pos=pos;g.camera_pos=pos-g.VIEW*.5;g.camera_smooth=g.camera_pos
	for frame in 24:
		g.world_obstacles_3d.update(g,1.0/60.0);g.update_static_cache();g.queue_redraw()
		await process_frame
	RenderingServer.force_draw(false)
	return vp.get_texture().get_image()

func run()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0] if not args.is_empty() else "res://docs/design/architecture-v2"
	DirAccess.make_dir_recursive_absolute(out)
	var shots:Array=[]
	var spots:Array=ROCK_SPOTS if args.size()>1 and args[1]=="felsen" else SPOTS+ROCK_SPOTS
	for variant in [false,true]:
		Kit.enabled=variant
		var vp:=SubViewport.new();vp.size=Vector2i(1152,648)
		vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
		var g:=Game.new();vp.add_child(g)
		for frame in 8:await process_frame
		g.set_process(false);g.panel="";g.character_created=true;g.hero_name="Vorschau"
		g.level=40;g.enemies.clear();g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
		g.bosses_defeated.fill(true)
		for spot in spots:
			var image:Image=await shoot(g,vp,spot[1])
			image.save_png(out.path_join("%s_%s.png"%[spot[0],"neu" if variant else "alt"]))
			shots.append(image)
		g.free();vp.free()
		await process_frame
	# Übersicht: links alt, rechts neu, halbe Größe.
	var rows:=spots.size()
	var sheet:=Image.create(1152,324*rows,false,Image.FORMAT_RGBA8)
	for index in rows:
		for variant in 2:
			var image:Image=shots[variant*rows+index].duplicate()
			image.convert(Image.FORMAT_RGBA8)
			image.resize(576,324,Image.INTERPOLATE_BILINEAR)
			sheet.blit_rect(image,Rect2i(0,0,576,324),Vector2i(variant*576,index*324))
	sheet.save_png(out.path_join("rocks_compare.png" if spots==ROCK_SPOTS else "architecture_compare.png"))
	Kit.enabled=true
	print("ARCHITECTURE_CAPTURE_OK ",out);quit()
