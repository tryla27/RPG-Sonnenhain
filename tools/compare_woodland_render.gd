extends SceneTree
## Referenzskript per Argument, z.B. res://build/woodland_mob_art_before.gd.
## Vergleicht 160 Posen direkt über die GPU, ohne Konto oder Spielstände.
class Preview extends Node2D:
	var renderer:Variant
	func _draw()->void:
		draw_rect(Rect2(0,0,2048,1280),Color("31454a"))
		for i in 160:
			var type:=i%4;var direction:=i/4%8;var state:=i/32
			var look:=Vector2(sin(direction*PI/4),cos(direction*PI/4))
			var visual:={"walking":state==1,"clock":7.3,"seed":.33,"hurt":.12 if state==3 else 0.0,"death":.6 if state==4 else -1.0}
			var color:Color=renderer.PALETTES[type]
			var pos:=Vector2(64+i%16*128,112+i/16*128)
			renderer.paint(self,pos,type,look,color,.7 if state==1 else 0.0,.5 if state==2 else -1.0,.75,Vector2.ONE,"sprungbiss" if type==3 and state==2 else "",visual)
func _initialize()->void:call_deferred("run")
func run()->void:
	var args:=OS.get_cmdline_user_args()
	if args.is_empty() or DisplayServer.get_name()=="headless":
		push_error("Referenzskript und echter Renderer nötig");quit(1);return
	var baseline:Variant=load(args[0])
	if baseline==null:quit(1);return
	var images:Array[Image]=[]
	for script in [baseline,preload("res://components/woodland_mob_art.gd")]:
		var vp:=SubViewport.new();vp.size=Vector2i(2048,1280);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(vp);var preview:=Preview.new();preview.renderer=script;vp.add_child(preview)
		await process_frame;RenderingServer.force_draw(false)
		images.append(vp.get_texture().get_image());vp.free()
	var before:=images[0].get_data();var after:=images[1].get_data();var different:=0;var largest:=0
	for i in before.size():
		var delta:=absi(int(before[i])-int(after[i]));largest=maxi(largest,delta)
		if delta>0:different+=1
	DirAccess.make_dir_recursive_absolute("res://docs/design/combat-followup")
	images[0].save_png("res://docs/design/combat-followup/woodland-before.png")
	images[1].save_png("res://docs/design/combat-followup/woodland-after.png")
	var report:={"poses":160,"largest_channel_difference":largest,"different_channels":different,"channels":before.size(),"adapter":RenderingServer.get_video_adapter_name()}
	var file:=FileAccess.open("res://docs/design/combat-followup/woodland-comparison.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"));file.close();print("WOODLAND_COMPARE ",JSON.stringify(report));quit(0 if largest==0 else 1)
