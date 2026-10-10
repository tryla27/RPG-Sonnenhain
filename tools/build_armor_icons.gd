extends SceneTree
# Inventarbilder der sieben legendären Rüstungen, aus einfachen 3D-Modellen
# gerendert (Licht und Tiefe wie die 3D-Landschaft). Ergebnis: ein Streifen
# art/items/legendary_armor_64.png mit 7 Bildern à 64×64 (Reihenfolge wie
# MasterArmor.ARMORS). Eigene Entwürfe, keine Nachbauten.
#
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/build_armor_icons.gd -- [ausgabe.png] [vorschau.png]

const ICON:=64
const COUNT:=7

func _initialize()->void:call_deferred("build")

func mat(color:String,rough:float=0.75,metal:float=0.0,glow:String="",glow_energy:float=0.0)->StandardMaterial3D:
	var m:=StandardMaterial3D.new()
	m.albedo_color=Color(color)
	m.roughness=rough
	m.metallic=metal
	if glow!="":
		m.emission_enabled=true
		m.emission=Color(glow)
		m.emission_energy_multiplier=glow_energy
	return m

func box(parent:Node3D,size:Vector3,pos:Vector3,m:Material,rot:Vector3=Vector3.ZERO)->MeshInstance3D:
	var mesh:=BoxMesh.new();mesh.size=size
	var mi:=MeshInstance3D.new();mi.mesh=mesh;mi.material_override=m
	mi.position=pos;mi.rotation_degrees=rot
	parent.add_child(mi)
	return mi

func cyl(parent:Node3D,top:float,bottom:float,height:float,pos:Vector3,m:Material,rot:Vector3=Vector3.ZERO,sides:int=10)->MeshInstance3D:
	var mesh:=CylinderMesh.new();mesh.top_radius=top;mesh.bottom_radius=bottom;mesh.height=height;mesh.radial_segments=sides
	var mi:=MeshInstance3D.new();mi.mesh=mesh;mi.material_override=m
	mi.position=pos;mi.rotation_degrees=rot
	parent.add_child(mi)
	return mi

func cone(parent:Node3D,radius:float,height:float,pos:Vector3,m:Material,rot:Vector3)->void:
	cyl(parent,0.0,radius,height,pos,m,rot,6)

func sphere(parent:Node3D,radius:float,pos:Vector3,m:Material,segments:int=8)->void:
	var mesh:=SphereMesh.new();mesh.radius=radius;mesh.height=radius*2.0;mesh.radial_segments=segments;mesh.rings=segments/2
	var mi:=MeshInstance3D.new();mi.mesh=mesh;mi.material_override=m;mi.position=pos
	parent.add_child(mi)

## Grundform: Brustpanzer mit Schultern und Taille.
func cuirass(root:Node3D,body:Material,trim:Material,shoulder:Material=null)->void:
	box(root,Vector3(1.0,0.75,0.5),Vector3(0,0.28,0),body)
	box(root,Vector3(0.82,0.42,0.46),Vector3(0,-0.28,0),body)
	box(root,Vector3(0.86,0.08,0.5),Vector3(0,-0.04,0),trim)
	box(root,Vector3(0.9,0.08,0.5),Vector3(0,-0.5,0),trim)
	# Halsausschnitt
	box(root,Vector3(0.34,0.1,0.52),Vector3(0,0.62,0),trim)
	if shoulder!=null:
		for side in [-1,1]:
			box(root,Vector3(0.36,0.26,0.56),Vector3(side*0.6,0.52,0),shoulder,Vector3(0,0,-side*14))

func build_armor(root:Node3D,id:int)->void:
	match id:
		0: # Windläufer: helles Leder, Schärpe, Bänder.
			cuirass(root,mat("8a6a45"),mat("cfb47c",0.5,0.3),mat("6f5536"))
			box(root,Vector3(0.16,1.25,0.06),Vector3(0.02,0.0,0.27),mat("3f7a3a"),Vector3(0,0,38))
			box(root,Vector3(0.1,0.42,0.04),Vector3(0.42,-0.55,0.27),mat("5f9c4c"),Vector3(0,0,-18))
			box(root,Vector3(0.08,0.36,0.04),Vector3(0.52,-0.5,0.27),mat("8fbf5a"),Vector3(0,0,-30))
		1: # Arkanweber: lange Robe, Runen leuchten.
			cuirass(root,mat("3b2a6b"),mat("5fd6e0",0.4,0.2,"5fd6e0",0.4),mat("4a3a80"))
			cyl(root,0.42,0.62,0.6,Vector3(0,-0.72,0),mat("33245e"),Vector3.ZERO,12)
			cyl(root,0.63,0.63,0.06,Vector3(0,-1.0,0),mat("5fd6e0",0.4,0.2,"5fd6e0",0.4),Vector3.ZERO,12)
			for k in 4:box(root,Vector3(0.09,0.09,0.05),Vector3(0,0.42-k*0.3,0.27+k*0.03),mat("8fe6ff",0.3,0,"5fd6e0",1.0))
			for side in [-1,1]:box(root,Vector3(0.05,0.9,0.05),Vector3(side*0.24,0.0,0.27),mat("5b4a9b",0.5,0,"5fd6e0",0.3))
		2: # Dornenpanzer: grüne Platten, Dornen an Schultern.
			cuirass(root,mat("2f5a3a",0.6,0.2),mat("1d3a25"),mat("3d6e48",0.55,0.2))
			for side in [-1,1]:
				for k in 3:cone(root,0.07,0.32,Vector3(side*(0.48+k*0.12),0.72,0),mat("d6e2a8",0.5),Vector3(0,0,-side*(20+k*12)))
				cone(root,0.06,0.26,Vector3(side*0.3,0.1,0.28),mat("d6e2a8",0.5),Vector3(90,0,0))
		3: # Bollwerk: Silberplatte, wuchtige Schulterplatten, Goldkante.
			cuirass(root,mat("9aa4ad",0.35,0.8),mat("e0b85a",0.3,0.9),mat("8c96a0",0.35,0.8))
			box(root,Vector3(0.5,0.5,0.06),Vector3(0,0.2,0.27),mat("c3ccd4",0.3,0.85))
			box(root,Vector3(0.08,0.5,0.07),Vector3(0,0.2,0.29),mat("e0b85a",0.3,0.9))
		4: # Blutmond: tiefroter Mantel, silberne Mondschließe.
			cuirass(root,mat("4a2a30",0.7),mat("d9dde6",0.3,0.8),mat("5c1520",0.8))
			for side in [-1,1]:box(root,Vector3(0.34,1.35,0.12),Vector3(side*0.55,-0.12,-0.12),mat("7a1f2b",0.85),Vector3(0,side*-25,side*-6))
			box(root,Vector3(1.1,0.16,0.6),Vector3(0,0.62,-0.02),mat("7a1f2b",0.85))
			cyl(root,0.13,0.13,0.05,Vector3(0,0.44,0.3),mat("d9dde6",0.25,0.9),Vector3(90,0,0),16)
			cyl(root,0.09,0.09,0.06,Vector3(0.05,0.47,0.31),mat("5c1520",0.8),Vector3(90,0,0),16)
		5: # Sternenquell: helles Gewand, Sternfunken, blauer Gürtel.
			cuirass(root,mat("8fc3e6",0.6),mat("4a86b8",0.5),mat("b8dcf2",0.6))
			for pt in [Vector3(-0.22,0.38,0.27),Vector3(0.24,0.2,0.27),Vector3(-0.08,-0.15,0.25),Vector3(0.18,-0.3,0.25)]:
				sphere(root,0.05,pt,mat("f3f0c8",0.3,0,"f3f0c8",1.2),6)
		6: # Golem-Rüstung: Basaltplatten, lila Risse, schwebende Schultersteine.
			var basalt:=mat("2e2a35",0.9)
			var light:=mat("4a4454",0.85)
			var glow:=mat("b45cff",0.4,0,"b45cff",1.1)
			box(root,Vector3(0.5,0.42,0.5),Vector3(-0.24,0.38,0),basalt,Vector3(0,0,4))
			box(root,Vector3(0.5,0.42,0.5),Vector3(0.24,0.38,0),light,Vector3(0,0,-5))
			box(root,Vector3(0.46,0.36,0.48),Vector3(-0.2,-0.02,0),light,Vector3(0,0,-3))
			box(root,Vector3(0.46,0.36,0.48),Vector3(0.22,-0.02,0),basalt,Vector3(0,0,6))
			box(root,Vector3(0.84,0.3,0.46),Vector3(0,-0.38,0),basalt)
			# Risse: leuchtende Streifen in den Fugen.
			box(root,Vector3(0.04,0.4,0.04),Vector3(0.0,0.36,0.26),glow,Vector3(0,0,8))
			box(root,Vector3(0.3,0.035,0.04),Vector3(-0.15,0.16,0.26),glow,Vector3(0,0,-12))
			box(root,Vector3(0.04,0.32,0.04),Vector3(0.12,-0.2,0.25),glow,Vector3(0,0,-20))
			box(root,Vector3(0.22,0.035,0.04),Vector3(0.28,0.5,0.26),glow,Vector3(0,0,25))
			for side in [-1,1]:
				box(root,Vector3(0.36,0.3,0.5),Vector3(side*0.6,0.5,0),basalt,Vector3(8,0,-side*18))
				box(root,Vector3(0.16,0.14,0.16),Vector3(side*0.66,0.86,0.05),light,Vector3(20,30,side*25))
				box(root,Vector3(0.05,0.05,0.05),Vector3(side*0.66,0.86,0.14),glow)

func build()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0] if args.size()>0 else "res://art/items/legendary_armor_64.png"
	var preview:String=args[1] if args.size()>1 else ""
	var strip:=Image.create(ICON*COUNT,ICON,false,Image.FORMAT_RGBA8)
	for id in COUNT:
		var vp:=SubViewport.new()
		vp.size=Vector2i(ICON*4,ICON*4)
		vp.transparent_bg=true
		vp.msaa_3d=Viewport.MSAA_4X
		vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		vp.own_world_3d=true
		root.add_child(vp)
		var env:=Environment.new()
		env.background_mode=Environment.BG_CLEAR_COLOR
		env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color=Color("8a8fb0")
		env.ambient_light_energy=0.55
		var we:=WorldEnvironment.new();we.environment=env;vp.add_child(we)
		var sun:=DirectionalLight3D.new()
		sun.rotation_degrees=Vector3(-40,-35,0)
		sun.light_energy=1.35
		vp.add_child(sun)
		var rim:=DirectionalLight3D.new()
		rim.rotation_degrees=Vector3(-15,150,0)
		rim.light_energy=0.5
		rim.light_color=Color("b8c8ff")
		vp.add_child(rim)
		var cam:=Camera3D.new()
		cam.projection=Camera3D.PROJECTION_ORTHOGONAL
		cam.size=1.85
		cam.position=Vector3(0,0.12,4)
		vp.add_child(cam)
		var model:=Node3D.new()
		model.rotation_degrees=Vector3(10,-22,0)
		vp.add_child(model)
		build_armor(model,id)
		for i in 4:await process_frame
		await RenderingServer.frame_post_draw
		var img:=vp.get_texture().get_image()
		img.convert(Image.FORMAT_RGBA8)
		img.resize(ICON,ICON,Image.INTERPOLATE_LANCZOS)
		# Dunkler 1-px-Umriss wie bei den Pixel-Symbolen.
		var outlined:=img.duplicate()
		for y in ICON:
			for x in ICON:
				if img.get_pixel(x,y).a>0.4:continue
				var near:=false
				for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
					var q:Vector2i=Vector2i(x,y)+d
					if q.x>=0 and q.y>=0 and q.x<ICON and q.y<ICON and img.get_pixelv(q).a>0.6:near=true
				if near:outlined.set_pixel(x,y,Color("121016"))
		strip.blit_rect(outlined,Rect2i(0,0,ICON,ICON),Vector2i(id*ICON,0))
		vp.queue_free()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out.get_base_dir()) if out.begins_with("res://") else out.get_base_dir())
	strip.save_png(out)
	print("ARMOR_ICONS ",out)
	if preview!="":
		var big:=Image.create(ICON*COUNT*3+40,ICON*3+40,false,Image.FORMAT_RGBA8)
		big.fill(Color("2c3a40"))
		var scaled:=strip.duplicate()
		scaled.resize(ICON*COUNT*3,ICON*3,Image.INTERPOLATE_NEAREST)
		big.blend_rect(scaled,Rect2i(0,0,ICON*COUNT*3,ICON*3),Vector2i(20,20))
		big.save_png(preview)
		print("ARMOR_PREVIEW ",preview)
	quit()
