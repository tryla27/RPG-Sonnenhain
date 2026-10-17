extends SceneTree
## Felsen für das Architektur-Set v2 (ohne Blender, direkt in Godot gebaut):
## Moosfels (Blütenwiesen), Säulenbasalt (Ascheberge), salzverwitterter Fels
## (Mondküste), Schieferstapel (Dämmergrat). Kantige, flach schattierte Körper
## mit eigenem Felskorn (Moos mit der Krita-Moosstruktur), eingefärbt je Gebiet.
## Jedes Teil wird exakt auf die Begrenzung des bisherigen Modells gebracht
## (FIT, Godot-Koordinaten), damit Atlasplatz, Projektion, Sortierung und
## Kollision gleich bleiben.
## Aufruf: godot --headless --path . -s tools/art_pipeline/build_rocks.gd
## Danach importieren: godot --headless --path . --import
## Ausgabe: art/models/architecture_v2/<id>.glb

const OUT:="res://art/models/architecture_v2/"
const FIT:={
	"map01-obj05":[Vector3(-0.60,-0.04,-0.50),Vector3(0.93,0.67,0.96)],
	"map05-obj05":[Vector3(-0.55,-0.04,-0.56),Vector3(0.87,0.73,0.96)],
	"map06-obj04":[Vector3(-0.58,-0.04,-0.54),Vector3(0.92,0.80,0.97)],
	"map11-obj03":[Vector3(-0.58,-0.06,-0.52),Vector3(1.16,0.64,0.98)],
}

var rng:=RandomNumberGenerator.new()
## Teilflächen je Material: name -> [Farbe, Strukturbild, Dreiecke (PackedVector3Array)]
var surfaces:Dictionary={}
var moss_source:Image

func _initialize()->void:
	moss_source=Image.load_from_file(ProjectSettings.globalize_path("res://art/textures/quality_v1/moss_krita.png"))
	for id in FIT:
		surfaces={}
		rng.seed=hash(id)
		match id:
			"map01-obj05":meadow()
			"map05-obj05":basalt()
			"map06-obj04":coast()
			"map11-obj03":slate()
		var root:=build_scene(id)
		export_glb(root,id)
		root.free()
	print("ROCKS_OK ",FIT.size())
	quit()

# ------------------------------------------------------------ Materialien
func tinted(source:Image,color:Color)->ImageTexture:
	# Wie die Blender-Pipeline: Helligkeit der Vorlage, Farbe des Materials.
	var image:=source.duplicate() as Image
	image.convert(Image.FORMAT_RGBA8)
	var mean:=0.0
	for y in image.get_height():
		for x in image.get_width():mean+=image.get_pixel(x,y).get_luminance()
	mean/=float(image.get_width()*image.get_height())
	for y in image.get_height():
		for x in image.get_width():
			var k:=clampf(1.0+(image.get_pixel(x,y).get_luminance()-mean)*2.2,.55,1.35)
			image.set_pixel(x,y,Color(minf(1,color.r*k),minf(1,color.g*k),minf(1,color.b*k),1))
	return ImageTexture.create_from_image(image)

## Dreiecke anfügen; jedes wird so gedreht, dass es von center weg zeigt
## (Godot: Vorderseite im Uhrzeigersinn, Normale = (c-a)×(b-a)).
## Felskorn ohne Fugen (die Krita-Steinstruktur zeigt Mauerwerk): weiche
## Flecken aus zwei Rauschlagen und einzelne dunkle Poren.
func grain(color:Color,seed_value:int)->ImageTexture:
	var noise:=FastNoiseLite.new()
	noise.seed=seed_value;noise.frequency=.09;noise.fractal_octaves=2
	var image:=Image.create(32,32,false,Image.FORMAT_RGBA8)
	var pores:=RandomNumberGenerator.new();pores.seed=seed_value
	for y in 32:
		for x in 32:
			var k:=1.0+noise.get_noise_2d(x,y)*.22
			if pores.randf()<.04:k*=.78
			image.set_pixel(x,y,Color(minf(1,color.r*k),minf(1,color.g*k),minf(1,color.b*k),1))
	return ImageTexture.create_from_image(image)

func add_triangles(material:String,color:Color,texture:String,triangles:PackedVector3Array,center:Vector3)->void:
	if not surfaces.has(material):surfaces[material]=[color,texture,PackedVector3Array()]
	var out:PackedVector3Array=surfaces[material][2]
	for i in range(0,triangles.size(),3):
		var a:=triangles[i];var b:=triangles[i+1];var c:=triangles[i+2]
		var normal:=(c-a).cross(b-a)
		if normal.dot((a+b+c)/3.0-center)<0.0:out.append_array([a,c,b])
		else:out.append_array([a,b,c])
	surfaces[material][2]=out

# ------------------------------------------------------------ Formen
## Ikosaeder, n-mal unterteilt, als Liste von Eckpunkten und Dreiecks-Indizes.
func icosphere(subdivisions:int)->Array:
	var t:=(1.0+sqrt(5.0))*.5
	var vertices:=PackedVector3Array([Vector3(-1,t,0),Vector3(1,t,0),Vector3(-1,-t,0),Vector3(1,-t,0),Vector3(0,-1,t),Vector3(0,1,t),Vector3(0,-1,-t),Vector3(0,1,-t),Vector3(t,0,-1),Vector3(t,0,1),Vector3(-t,0,-1),Vector3(-t,0,1)])
	for i in vertices.size():vertices[i]=vertices[i].normalized()
	var faces:=[[0,11,5],[0,5,1],[0,1,7],[0,7,10],[0,10,11],[1,5,9],[5,11,4],[11,10,2],[10,7,6],[7,1,8],[3,9,4],[3,4,2],[3,2,6],[3,6,8],[3,8,9],[4,9,5],[2,4,11],[6,2,10],[8,6,7],[9,8,1]]
	for level in subdivisions:
		var cache:={}
		var next:=[]
		for f in faces:
			var m:=[]
			for e in [[f[0],f[1]],[f[1],f[2]],[f[2],f[0]]]:
				var key:=Vector2i(mini(e[0],e[1]),maxi(e[0],e[1]))
				if not cache.has(key):
					vertices.append(((vertices[e[0]]+vertices[e[1]])*.5).normalized());cache[key]=vertices.size()-1
				m.append(cache[key])
			next+=[[f[0],m[0],m[2]],[f[1],m[1],m[0]],[f[2],m[2],m[1]],[m[0],m[1],m[2]]]
		faces=next
	return [vertices,faces]

## Kantiger Brocken: verschobene Ikosphäre, unten flach, optional flache Kappe.
## Gibt die Dreiecke der Kappe getrennt zurück (für Moos/Salz/hellere Oberseite).
func boulder(center:Vector3,size:Vector3,material:String,color:Color,cap_material:String="",cap_color:=Color.WHITE,cap_texture:="stone",subdivisions:=1,roughness:=.22,flat_top:=0.0)->void:
	var mesh:=icosphere(subdivisions)
	var vertices:PackedVector3Array=mesh[0]
	var turn:=rng.randf_range(-PI,PI)
	for i in vertices.size():
		var v:=vertices[i]*(1.0+rng.randf_range(-roughness,roughness))
		v=Vector3(v.x*size.x,v.y*size.y,v.z*size.z)
		if v.y<0:v.y*=.25
		var limit:=size.y*(1.0-flat_top)
		if flat_top>0.0 and v.y>limit:v.y=limit+(v.y-limit)*.15
		vertices[i]=center+v.rotated(Vector3.UP,turn)
	var body:=PackedVector3Array();var cap:=PackedVector3Array()
	for f in mesh[1]:
		var a:=vertices[f[0]];var b:=vertices[f[1]];var c:=vertices[f[2]]
		var normal:=(b-a).cross(c-a).normalized()
		# Godot: Dreiecke im Uhrzeigersinn von außen gesehen.
		var tri:=PackedVector3Array([a,c,b])
		if cap_material!="" and normal.y>.82 and (a.y+b.y+c.y)/3.0>center.y+size.y*.45:cap.append_array(tri)
		else:body.append_array(tri)
	add_triangles(material,color,"stone",body,center+Vector3(0,size.y*.3,0))
	if not cap.is_empty():add_triangles(cap_material,cap_color,cap_texture,cap,center)

## Prisma mit n Seiten (Basaltsäule oder Platte), unten bei center.y.
func prism(center:Vector3,radius:Vector2,height:float,sides:int,material:String,color:Color,top_material:String,top_color:Color,tilt:=0.05)->void:
	var turn:=rng.randf_range(0,TAU)
	var lean:=Vector3(rng.randf_range(-tilt,tilt),0,rng.randf_range(-tilt,tilt))
	var bottom:=PackedVector3Array();var top:=PackedVector3Array()
	for i in sides:
		var angle:=turn+TAU*i/sides
		var offset:=Vector3(cos(angle)*radius.x*rng.randf_range(.9,1.08),0,sin(angle)*radius.y*rng.randf_range(.9,1.08))
		bottom.append(center+offset)
		top.append(center+offset*.92+Vector3(0,height*rng.randf_range(.94,1.0),0)+lean*height)
	var sides_tri:=PackedVector3Array();var cap:=PackedVector3Array()
	var top_center:=Vector3.ZERO
	for p in top:top_center+=p
	top_center/=sides
	for i in sides:
		var j:=(i+1)%sides
		sides_tri.append_array([bottom[i],top[i],top[j],bottom[i],top[j],bottom[j]])
		cap.append_array([top_center,top[j],top[i]])
	var middle:=(center+top_center)*.5
	add_triangles(material,color,"stone",sides_tri,middle)
	add_triangles(top_material,top_color,"stone",cap,middle)

# ------------------------------------------------------------ Teile
func meadow()->void:
	var a:=Color("8b9286");var b:=Color("767e72");var moss:=Color("7d9a58")
	boulder(Vector3(-.1,0,-.1),Vector3(.42,.52,.38),"rock_a",a,"moss",moss,"moss",1,.22,.12)
	boulder(Vector3(.25,0,.22),Vector3(.28,.32,.26),"rock_b",b,"moss",moss.darkened(.15),"moss",1,.22,.1)
	boulder(Vector3(-.36,0,.3),Vector3(.17,.18,.15),"rock_a",a)
	for i in 4:boulder(Vector3(rng.randf_range(-.45,.45),0,rng.randf_range(.35,.48)),Vector3(.06,.05,.05),"moss",moss,"",Color.WHITE,"moss",0,.15)

func basalt()->void:
	var a:=Color("57505a");var b:=Color("6a626a");var top:=Color("8a8187")
	for column in [[-.18,-.1,.62],[.12,-.14,.5],[0,.16,.38],[.3,.12,.26],[-.36,.12,.3]]:
		prism(Vector3(column[0],0,column[1]),Vector2(.15,.15),column[2],6,"basalt_a" if rng.randf()<.5 else "basalt_b",a if rng.randf()<.5 else b,"basalt_top",top)
	for i in 3:boulder(Vector3(rng.randf_range(-.4,.4),0,rng.randf_range(.32,.42)),Vector3(.09,.07,.08),"basalt_b",b)

func coast()->void:
	var a:=Color("a39d88");var b:=Color("8f8a76");var salt:=Color("d8d4c4")
	boulder(Vector3(0,0,-.05),Vector3(.42,.62,.38),"coast_a",a,"salt",salt,"stone",2,.12,.06)
	boulder(Vector3(.3,0,.26),Vector3(.2,.22,.18),"coast_b",b,"salt",salt,"stone",2,.14,.05)

func slate()->void:
	var a:=Color("8a8794");var b:=Color("77737f");var top:=Color("9d9aa6")
	var y:=0.0
	for layer in 6:
		var h:=rng.randf_range(.07,.11)
		var w:=1.0-layer*.11+rng.randf_range(-.04,.04);var d:=.8-layer*.07
		prism(Vector3(rng.randf_range(-.06,.06),y,rng.randf_range(-.05,.05)),Vector2(w*.62,d*.62),h,4 if layer%2==0 else 5,"slate_a" if layer%2==0 else "slate_b",a if layer%2==0 else b,"slate_top",top,.02)
		y+=h
	for i in 3:boulder(Vector3(rng.randf_range(-.5,.5),0,rng.randf_range(.32,.45)),Vector3(.12,.05,.09),"slate_b",b,"",Color.WHITE,"stone",0,.1)

# ------------------------------------------------------------ Szene und Export
func build_scene(id:String)->Node3D:
	# Gesamtbegrenzung bestimmen und auf FIT abbilden.
	var lo:=Vector3(INF,INF,INF);var hi:=-lo
	for name in surfaces:
		for p in surfaces[name][2]:lo=lo.min(p);hi=hi.max(p)
	var want_pos:Vector3=FIT[id][0];var want_size:Vector3=FIT[id][1]
	var scale:=want_size/(hi-lo)
	var root:=Node3D.new();root.name=id.replace("-","_")
	var mesh:=ArrayMesh.new()
	var names:=surfaces.keys();names.sort()
	for name in names:
		var color:Color=surfaces[name][0];var texture:String=surfaces[name][1];var tris:PackedVector3Array=surfaces[name][2]
		var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(0,tris.size(),3):
			var p:=[want_pos+(tris[i]-lo)*scale,want_pos+(tris[i+1]-lo)*scale,want_pos+(tris[i+2]-lo)*scale]
			var normal:Vector3=(p[2]-p[0]).cross(p[1]-p[0]).normalized()
			for v in p:
				# Flächenprojektion nach Hauptachse: Struktur ohne Verzerrung.
				var uv:=Vector2(v.x,v.z) if absf(normal.y)>.6 else (Vector2(v.z,v.y) if absf(normal.x)>absf(normal.z) else Vector2(v.x,v.y))
				st.set_normal(normal);st.set_uv(uv*1.6);st.add_vertex(v)
		var material:=StandardMaterial3D.new()
		material.resource_name="SH2_"+name
		material.albedo_texture=tinted(moss_source,color) if texture=="moss" else grain(color,hash(id+name))
		material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
		material.roughness=.9
		st.set_material(material)
		st.commit(mesh)
	var instance:=MeshInstance3D.new();instance.name=root.name;instance.mesh=mesh
	root.add_child(instance);instance.owner=root
	return root

func export_glb(root:Node3D,id:String)->void:
	var doc:=GLTFDocument.new();var state:=GLTFState.new()
	var error:=doc.append_from_scene(root,state)
	if error==OK:error=doc.write_to_filesystem(state,ProjectSettings.globalize_path(OUT+id+".glb"))
	print("ROCK ",id," ",error_string(error))
