extends RefCounted
## Echte räumliche Landschaftskörper; Materialtexturen sind je 64×64 Pixel.
const Idle=preload("res://components/world_obstacle_idle_3d.gd")
const FAMILIES=[
	["tree","bush","stump","log","rocks","fern"],
	["tree","mushrooms","fern","fungus_log","hollow_stump","root_rock"],
	["wall","column","rubble","arch","slab","root_tree"],
	["crystals","tree","grass","geode","wet_rocks","crystal_roots"],
	["lava_rocks","tree","lava_pool","ember_stump","rocks","bush"],
	["coast_rocks","tree","driftwood","rocks","grass","sand_rocks"],
	["crystals","tree","single_crystal","split_meteor","monolith","bush"],
	["bush","tree","rocks","log","grass","hollow_stump"],
	["resin_log","tree","fern","resin_stump","amber_rock","mushrooms"],
	["wet_rocks","tree","grass","trough","roots","water_pool"],
	["ridge","tree","rocks","column","roots","bush"],
	["geode","tree","grass","column","arch","fern_roots"]
]
const PALETTES=[
	["5b964b","76523a","788176","fff0c4"], ["46664c","594837","627268","bf737d"],
	["6b7852","655140","96978b","cac0a3"], ["689b89","666654","53666b","6dd6e2"],
	["70695c","493a32","49434c","f29748"], ["789b77","786248","aaa58e","e3cf9c"],
	["697a65","695844","59566b","b49bdd"], ["86a896","c2bdaa","717a70","cf9cbd"],
	["b0a351","78553b","766a54","cfa455"], ["6d9d9b","777d6e","657a7b","aacfd0"],
	["63647a","625750","646678","9ca0b0"], ["b3a3be","8a8179","b7b1ad","d7c4eb"]
]
var zone:=1
var motif:=1
var rng:=RandomNumberGenerator.new()
var materials:Dictionary={}
var root:Node3D
var moving:Node3D
var animated_part:Node3D
var family:=""

func color_for(role:String)->Color:
	var p:Array=PALETTES[zone-1]
	match role:
		"leaf":return Color(p[0])
		"leaf_light","moss":return Color(p[0]).lightened(.12) if role=="leaf_light" else Color(p[0]).darkened(.12)
		"wood":return Color(p[1])
		"stone":return Color(p[2])
		"accent","crystal":return Color(p[3])
		"cut":return Color("c6a575") if zone!=5 else Color("5a4437")
		"flower":return Color(p[3]).lightened(.12) if zone in [8,11] else Color("ede4c9")
		"fungus_under":return Color("ede4c9")
		"flower_center":return Color("c6a858")
		"fungus_top":return Color("bb6d75") if zone==2 else Color("c99c55")
		"amber":return Color("c39c4b")
		"water":return Color("569aaa")
		"shine":return Color("dce9df")
		"char":return Color("312d30")
	return Color(p[1]).lightened(.22)

func material(role:String)->StandardMaterial3D:
	var key:="%02d_%s" % [zone,role]
	if materials.has(key):return materials[key]
	var color:=color_for(role)
	var image:=Image.create(64,64,false,Image.FORMAT_RGBA8)
	var noise:=RandomNumberGenerator.new();noise.seed=hash(key)
	image.fill(color)
	for i in 150:
		var p:=Vector2i(noise.randi_range(0,62),noise.randi_range(0,62))
		var size:=Vector2i(noise.randi_range(2,5),noise.randi_range(2,6))
		if role=="wood":size=Vector2i(2,noise.randi_range(4,12))
		var tint:=color.lightened(noise.randf_range(.03,.12)) if i%3==0 else color.darkened(noise.randf_range(.03,.14))
		for x in range(p.x,mini(64,p.x+size.x)):
			for y in range(p.y,mini(64,p.y+size.y)):image.set_pixel(x,y,tint)
	if role in ["leaf","leaf_light","moss"]:
		for leaf in 64:
			var p:=Vector2i(noise.randi_range(3,60),noise.randi_range(3,60))
			var shade:=color.lightened(.18) if leaf%3==0 else color.darkened(.17)
			for dx in range(-3,4):
				for dy in range(-2,3):
					if abs(dx)+abs(dy)<4:image.set_pixel(p.x+dx,p.y+dy,shade)
	elif role=="wood":
		for line in 12:
			var x:=line*5+noise.randi_range(0,3)
			for y in 64:
				var px:=clampi(x+int(sin(y*.18+line)*1.5),0,63)
				image.set_pixel(px,y,color.darkened(.25))
		if zone==8:
			for mark in 30:
				var p:=Vector2i(noise.randi_range(0,55),noise.randi_range(0,62))
				for x in range(p.x,p.x+noise.randi_range(3,8)):image.set_pixel(x,p.y,Color("5b655f"))
	elif role=="stone":
		for crack in 6:
			var p:=Vector2i(noise.randi_range(4,58),noise.randi_range(4,40))
			for step in 14:
				p+=Vector2i(noise.randi_range(-1,1),1)
				if p.x>=0 and p.x<64 and p.y<64:image.set_pixel(p.x,p.y,color.darkened(.23))
	elif role=="crystal":
		for x in 64:
			for y in 64:
				var band:float=[.16,-.16,.08,-.22][mini(3,x/16)]
				image.set_pixel(x,y,color.lightened(band) if band>=0 else color.darkened(-band))
		for y in range(9,52):
			for x in [8,9,39]:image.set_pixel(x,y,color.lightened(.35))
	elif role=="fungus_under":
		for x in 64:
			for y in 64:
				var a:=atan2(y-32,x-32)
				if int((a+PI)*30.0)%5==0:image.set_pixel(x,y,color.darkened(.17))
	if role=="cut":
		for x in 64:
			for y in 64:
				var radius:=Vector2(x-32,y-32).length()
				var ring:=int(radius+sin(y*.3)*1.3)%7
				image.set_pixel(x,y,color.darkened(.22) if ring<2 else color)
	var texture:=ImageTexture.create_from_image(image)
	var mat:=StandardMaterial3D.new();mat.resource_name=key
	mat.albedo_texture=texture;mat.roughness=.94;mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	if role=="accent" and zone==5:mat.emission_enabled=true;mat.emission=color;mat.emission_energy_multiplier=.35
	if role in ["crystal","amber","water"]:mat.roughness=.32
	if role=="shine":mat.emission_enabled=true;mat.emission=color;mat.emission_energy_multiplier=.12
	materials[key]=mat
	return mat

func mesh_node(parent:Node3D,mesh:Mesh,pos:Vector3,role:String,name_hint:String="Part")->MeshInstance3D:
	var n:=MeshInstance3D.new();n.name=name_hint+str(parent.get_child_count());n.mesh=mesh;n.position=pos;n.material_override=material(role)
	parent.add_child(n);return n

func block(parent:Node3D,pos:Vector3,size:Vector3,role:String,name_hint:String="Stone")->MeshInstance3D:
	if role=="stone":return mesh_node(parent,beveled_block(size),pos,role,name_hint)
	var mesh:=BoxMesh.new();mesh.size=size
	return mesh_node(parent,mesh,pos,role,name_hint)

func cylinder(parent:Node3D,start:Vector3,end:Vector3,radius:float,role:String,top_ratio:float=.65)->MeshInstance3D:
	var mesh:=CylinderMesh.new();mesh.bottom_radius=radius;mesh.top_radius=radius*top_ratio;mesh.height=start.distance_to(end);mesh.radial_segments=8;mesh.rings=1
	var n:=mesh_node(parent,mesh,(start+end)*.5,role,"Branch")
	var direction:=(end-start).normalized()
	if direction.length()>.1:n.quaternion=Quaternion(Vector3.UP,direction)
	return n

func add_triangle(st:SurfaceTool,a:Vector3,b:Vector3,c:Vector3,size:Vector3,outward:Vector3=Vector3.ZERO)->void:
	var normal:=(b-a).cross(c-a).normalized()
	var direction:=(a+b+c)/3.0 if outward.is_zero_approx() else outward
	if normal.dot(direction)<0:normal=-normal
	for v in [a,b,c]:
		st.set_normal(normal);st.set_uv(Vector2(v.x/maxf(size.x,.01)+.5,v.y/maxf(size.y,.01)+.5));st.add_vertex(v)

func lump_mesh(size:Vector3,leaf:bool=false)->ArrayMesh:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings:Array=[]
	var segments:=10 if leaf else 8
	var shape:Array=[]
	for i in segments:shape.append(rng.randf_range(.83,1.12))
	for ring in 5:
		var ring_points:Array=[]
		var y:float=[-.46,-.26,.02,.31,.47][ring]*size.y
		var radius:=0.0
		var profile:Array=[.30,.85,1.0,.76,.18] if leaf else [.78,1.0,.95,.70,.37]
		radius=float(profile[ring])*.5
		for i in segments:
			var angle:=i*TAU/segments
			var uneven:float=shape[i]
			var tilt:float=sin(angle+.7)*.06*size.y
			ring_points.append(Vector3(cos(angle)*size.x*radius*uneven+(ring-2)*.02*size.x,y+tilt,sin(angle)*size.z*radius*uneven))
		rings.append(ring_points)
	for ring in 4:
		for i in segments:
			var j:=(i+1)%segments
			add_triangle(st,rings[ring][i],rings[ring+1][i],rings[ring+1][j],size)
			add_triangle(st,rings[ring][i],rings[ring+1][j],rings[ring][j],size)
	for i in segments:
		add_triangle(st,Vector3(0,size.y*.48,0),rings[4][i],rings[4][(i+1)%segments],size)
		add_triangle(st,Vector3(0,-size.y*.46,0),rings[0][(i+1)%segments],rings[0][i],size)
	return st.commit()

func beveled_block(size:Vector3)->ArrayMesh:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bevel:=minf(size.x,minf(size.y,size.z))*.13
	var x:=size.x*.5;var z:=size.z*.5
	var contour:Array=[Vector2(-x+bevel,-z),Vector2(x-bevel,-z),Vector2(x,-z+bevel),Vector2(x,z-bevel),Vector2(x-bevel,z),Vector2(-x+bevel,z),Vector2(-x,z-bevel),Vector2(-x,-z+bevel)]
	var rings:Array=[]
	for row in 4:
		var y:float=[-size.y*.5,-size.y*.5+bevel,size.y*.5-bevel,size.y*.5][row]
		var points:Array=[]
		for p in contour:points.append(Vector3(p.x*(.89 if row in [0,3] else 1.0),y,p.y*(.89 if row in [0,3] else 1.0)))
		rings.append(points)
	for row in 3:
		for i in 8:
			var j:=(i+1)%8
			add_triangle(st,rings[row][i],rings[row+1][i],rings[row+1][j],size);add_triangle(st,rings[row][i],rings[row+1][j],rings[row][j],size)
	for i in 8:
		add_triangle(st,Vector3(0,size.y*.5,0),rings[3][i],rings[3][(i+1)%8],size)
		add_triangle(st,Vector3(0,-size.y*.5,0),rings[0][(i+1)%8],rings[0][i],size)
	return st.commit()

func lump(parent:Node3D,pos:Vector3,size:Vector3,role:String="stone",name_hint:String="Rock")->MeshInstance3D:
	return mesh_node(parent,lump_mesh(size,role.begins_with("leaf")),pos,role,name_hint)

func flower(parent:Node3D,pos:Vector3,scale_factor:float=.08)->void:
	for i in 5:
		var angle:=i*TAU/5.0
		lump(parent,pos+Vector3(cos(angle)*scale_factor*.65,0,sin(angle)*scale_factor*.65),Vector3(scale_factor,.025,scale_factor*.65),"flower","Petal")
	lump(parent,pos+Vector3(0,.012,0),Vector3(scale_factor*.45,.02,scale_factor*.45),"flower_center","FlowerHeart")

func bark_detail(parent:Node3D,start:Vector3,end:Vector3,radius:float,role:="wood")->void:
	var height:=start.distance_to(end)
	for i in 7:
		var angle:=i*TAU/7.0
		var p:=start.lerp(end,rng.randf_range(.2,.7))+Vector3(cos(angle)*radius,0,sin(angle)*radius)
		var strip:=block(parent,p,Vector3(.018,height*rng.randf_range(.12,.28),.027),role,"BarkFurrow")
		strip.rotation.y=-angle

func hanging_leaves(parent:Node3D,start:Vector3,length:float)->void:
	var bend:=start+Vector3(.03,-length*.45,.01)
	var end:=start+Vector3(.025,-length,.025)
	cylinder(parent,start,bend,.012,"wood",.6);cylinder(parent,bend,end,.007,"wood",.45)
	for i in 4:
		var p:=start.lerp(end,(i+1)*.19)
		lump(parent,p+Vector3((.035 if i%2 else -.035),0,0),Vector3(.08,.12,.05),"leaf_light","WillowLeaf")

func leaf_cluster(parent:Node3D,pos:Vector3,size:Vector3)->void:
	var main:=lump(parent,pos,size,"leaf","Leaves");main.rotation=Vector3(rng.randf_range(-.18,.18),rng.randf_range(-.5,.5),rng.randf_range(-.16,.16))
	for i in 7:
		var off:=Vector3(rng.randf_range(-.36,.36)*size.x,rng.randf_range(-.06,.24)*size.y,rng.randf_range(-.36,.36)*size.z)
		var pocket:=lump(parent,pos+off,size*rng.randf_range(.25,.43),"leaf_light" if i%3==0 else "leaf","LeafPocket");pocket.rotation=Vector3(rng.randf_range(-.3,.3),rng.randf_range(-.6,.6),rng.randf_range(-.2,.2))

func roots(parent:Node3D,center:=Vector3.ZERO)->void:
	for i in 5:
		var angle:=i*TAU/5.0+.4
		var middle:=center+Vector3(cos(angle)*.17,.13,sin(angle)*.17)
		var end:=center+Vector3(cos(angle)*.37,.015,sin(angle)*.34)
		cylinder(parent,center+Vector3(0,.25,0),middle,.095,"wood",.7)
		cylinder(parent,middle,end,.065,"wood",.3)

func tree()->void:
	var lean:=.25 if zone in [5,6,7] else (.07 if zone!=2 else -.12)
	var middle:=Vector3(-.05,.52,.04)
	var upper:=Vector3(lean*.6,.91,-.035)
	var top:=Vector3(lean,1.24,.015)
	var bark_role:="char" if zone==5 else "wood"
	cylinder(root,Vector3.ZERO,middle,.18,bark_role,.83);cylinder(root,middle,upper,.15,bark_role,.79);cylinder(root,upper,top,.12,bark_role,.58)
	wind_bark(middle,upper)
	roots(root);moving.position=Vector3(lean*.4,.63,0)
	if zone==11:
		for i in 6:
			var w:=.88-i*.105
			leaf_cluster(moving,Vector3(0,.40+i*.19,0),Vector3(w,.47,w*.78))
	elif zone in [5,7]:
		for i in 7:
			var angle:=i*TAU/7.0
			var end:=Vector3(cos(angle)*(.65-i*.035)+lean*.35,.55+(i%3)*.19,sin(angle)*.46)
			cylinder(root,upper,end+moving.position,.043,bark_role,.4)
			if zone==7 or i%3!=0:leaf_cluster(moving,end,Vector3(.58,.25,.38))
		if zone==7:leaf_cluster(moving,Vector3(.15,1.09,0),Vector3(.66,.38,.5))
	else:
		var airy:=zone in [8,12]
		var willow:=zone in [4,6,10]
		var count:=7 if not airy else 6
		for i in count:
			var angle:=i*TAU/count+.12
			var spread:=.44 if not airy else .49
			var end:=Vector3(cos(angle)*spread,.55+rng.randf_range(-.2,.17)-(i%2)*.04,sin(angle)*spread*.86)
			if willow:end.x+=lean*.3;end.y-=.10
			var mid:=upper.lerp(end+moving.position,.55)+Vector3(0,.06,0)
			cylinder(root,upper,mid,.052,bark_role,.7);cylinder(root,mid,end+moving.position,.035,bark_role,.5)
			var size:=Vector3(.79,.61,.67) if not airy else Vector3(.64,.46,.55)
			leaf_cluster(moving,end,size*rng.randf_range(.85,1.12))
			if willow:hanging_leaves(moving,end+Vector3(.15,0,.18),.5+rng.randf_range(-.1,.12))
		leaf_cluster(moving,Vector3(.02,.96,-.055),Vector3(.95,.66,.79) if not airy else Vector3(.74,.53,.66))
	if zone in [1,12]:
		for i in 4:
			var p:=Vector3(rng.randf_range(-.4,.4),.035,rng.randf_range(-.35,.35))
			flower(root,p,.05)
	if zone==2:
		mushrooms(root,Vector3(-.25,.02,.2),.42)
		for i in 4:hanging_leaves(moving,Vector3((i-1.5)*.2,.55,.15),.48)
	if zone==9:
		for i in 4:lump(root,Vector3(.13+sin(i)*.02,.35+i*.14,.13),Vector3(.035,.055,.035),"amber","ResinDrop")
	animated_part=moving

func wind_bark(start:Vector3,end:Vector3)->void:
	bark_detail(root,start,end,.12,"char" if zone==5 else "wood")

func bush()->void:
	var bloom_points:Array=[]
	for i in 6:
		var angle:=i*TAU/6.0
		var end:=Vector3(cos(angle)*.42,.38+rng.randf_range(-.08,.15),sin(angle)*.35)
		cylinder(root,Vector3.ZERO,end,.022,"wood")
		if zone!=5:leaf_cluster(moving,end,Vector3(.55,.36,.48))
		bloom_points.append(end+Vector3(.04,.22,.10))
	if zone==5:
		for i in 8:cylinder(moving,Vector3.ZERO,Vector3(rng.randf_range(-.55,.55),rng.randf_range(.25,.7),rng.randf_range(-.4,.4)),.02,"wood")
	if zone in [1,8,11,12]:
		for point in bloom_points:flower(moving,point,.045 if zone!=1 else .065)
	animated_part=moving

func grasses(fern:bool=false)->void:
	for i in 12:
		var angle:=i*TAU/12.0
		var start:=Vector3(cos(angle)*.07,0,sin(angle)*.07)
		var end:=Vector3(cos(angle)*.4,rng.randf_range(.45,.83),sin(angle)*.35)
		var bend:=start.lerp(end,.56)+Vector3(0,.06,0)
		var leaf:=block(moving,(start+bend)*.5,Vector3(.04,start.distance_to(bend),.016),"leaf","Blade")
		leaf.quaternion=Quaternion(Vector3.UP,(bend-start).normalized())
		var tip:=block(moving,(bend+end)*.5,Vector3(.024,bend.distance_to(end),.012),"leaf_light","BladeTip");tip.quaternion=Quaternion(Vector3.UP,(end-bend).normalized())
		if fern:
			for j in 4:
				var p:=start.lerp(end,(j+1)*.18)
				for side in [-1,1]:
					var l:=block(moving,p+Vector3(cos(angle+.9)*.08*side,.02,sin(angle+.9)*.08*side),Vector3(.2,.035,.07),"leaf","Frond")
					l.rotation.y=-angle+.3*side
		elif zone in [4,10]:cylinder(moving,end-Vector3(0,.15,0),end+Vector3(0,.04,0),.031,"cut",.8)
		elif zone in [1,6,8,12] and i%3==0:flower(moving,end,.032)
	animated_part=moving

func stump(hollow:bool=false)->void:
	if hollow:
		var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var outer_bottom:Array=[];var outer_top:Array=[];var inner_top:Array=[];var inner_bottom:Array=[]
		for i in 12:
			var a:=i*TAU/12.0;var h:=.59+.05*sin(a*3)+rng.randf_range(-.025,.025)
			outer_bottom.append(Vector3(cos(a)*.31,.015,sin(a)*.31));outer_top.append(Vector3(cos(a)*.28,h,sin(a)*.28))
			inner_top.append(Vector3(cos(a)*.19,h-.025,sin(a)*.19));inner_bottom.append(Vector3(cos(a)*.13,.16,sin(a)*.13))
		for i in 12:
			var j:=(i+1)%12;var a:float=i*TAU/12.0;var direction:=Vector3(cos(a),0,sin(a));var size:=Vector3(.65,.62,.65)
			add_triangle(st,outer_bottom[i],outer_top[i],outer_top[j],size,direction);add_triangle(st,outer_bottom[i],outer_top[j],outer_bottom[j],size,direction)
			add_triangle(st,outer_top[i],inner_top[i],inner_top[j],size,Vector3.UP);add_triangle(st,outer_top[i],inner_top[j],outer_top[j],size,Vector3.UP)
			add_triangle(st,inner_bottom[i],inner_top[j],inner_top[i],size,-direction);add_triangle(st,inner_bottom[i],inner_bottom[j],inner_top[j],size,-direction)
			add_triangle(st,Vector3(0,.16,0),inner_bottom[i],inner_bottom[j],size,Vector3.UP)
			add_triangle(st,Vector3(0,.015,0),outer_bottom[j],outer_bottom[i],size,Vector3.DOWN)
		mesh_node(root,st.commit(),Vector3.ZERO,"char" if zone==5 else "wood","HollowBark")
	else:
		cylinder(root,Vector3.ZERO,Vector3(0,.55,0),.29,"wood",.95)
		cylinder(root,Vector3(0,.55,0),Vector3(0,.575,0),.265,"cut",1)
	roots(root)
	bark_detail(root,Vector3(0,.03,0),Vector3(0,.55,0),.28,"char" if zone==5 else "wood")
	leaf_cluster(moving,Vector3(-.28,.05,.25),Vector3(.32,.08,.25))
	if zone==2:mushrooms(root,Vector3(.25,0,.23),.3)
	if family=="resin_stump":
		for i in 3:lump(root,Vector3(.12,.27+i*.075,.26),Vector3(.06,.07,.035),"amber","SolidResin")
	animated_part=moving

func log_body()->void:
	cylinder(root,Vector3(-.7,.2,0),Vector3(-.18,.22,.015),.22,"wood",.97)
	cylinder(root,Vector3(-.18,.22,.015),Vector3(.3,.19,.045),.213,"wood",.92)
	cylinder(root,Vector3(.3,.19,.045),Vector3(.7,.18,.06),.196,"wood",.91)
	cylinder(root,Vector3(-.704,.2,0),Vector3(-.72,.2,0),.196,"cut",1)
	cylinder(root,Vector3(.703,.18,.06),Vector3(.72,.18,.06),.167,"cut",1)
	cylinder(root,Vector3(.15,.28,0),Vector3(.55,.58,-.18),.07,"wood")
	leaf_cluster(moving,Vector3(.28,.25,-.22),Vector3(.4,.17,.25))
	if family=="fungus_log":mushrooms(root,Vector3(-.2,.35,.05),.42)
	if family=="driftwood":
		cylinder(root,Vector3(-.55,.09,.4),Vector3(.35,.09,.25),.095,"wood")
		shell(root,Vector3(.52,.07,.32),.20)
	animated_part=moving

func rock_group(count:int=4)->void:
	for i in count:
		var height:=rng.randf_range(.40,.67)
		var angle:=i*TAU/maxi(1,count)+.25
		var pos:=Vector3(cos(angle)*.30,height*.48,sin(angle)*.23)
		if i==0:pos.x=0;pos.z=-.08;height*=1.18;pos.y=height*.48
		if zone==11:
			for layer in 3:
				var stone:=lump(root,pos+Vector3(layer*.035,(layer-1)*.15,0),Vector3(.72-layer*.06,.21,.6-layer*.05));stone.rotation.z=.07;stone.rotation.y=.16
		else:
			var stone:=lump(root,pos,Vector3(rng.randf_range(.60,.82),height,rng.randf_range(.52,.70)));stone.rotation=Vector3(.05*float(i%2),rng.randf_range(-.3,.3),.08*float(i%3-1))
		if zone not in [5,7,11]:
			for patch in 3:lump(root,pos+Vector3(rng.randf_range(-.17,.17),height*.43,rng.randf_range(-.13,.13)),Vector3(.15,.045,.13),"moss","MossPatch")
	for i in 4:lump(root,Vector3(rng.randf_range(-.55,.55),.025,rng.randf_range(-.42,.42)),Vector3(.10,.065,.085),"stone","Pebble")

func shell(parent:Node3D,pos:Vector3,size:float)->void:
	var dome:=lump(parent,pos,Vector3(size,size*.42,size*.82),"flower","Shell")
	dome.rotation.z=.12
	for i in 5:
		var angle:float=-.75+i*.35
		cylinder(parent,pos+Vector3(0,size*.12,-size*.22),pos+Vector3(sin(angle)*size*.43,size*.20,cos(angle)*size*.35),.005,"cut",1)

func crystal(parent:Node3D,pos:Vector3,height:float=.85,radius:float=.16)->Node3D:
	var pivot:=Node3D.new();pivot.name="CrystalPivot"+str(parent.get_child_count());parent.add_child(pivot);pivot.position=pos
	var mesh:=CylinderMesh.new();mesh.top_radius=0;mesh.bottom_radius=radius;mesh.height=height*.34;mesh.radial_segments=5
	mesh_node(pivot,mesh,Vector3(0,height*.83,0),"crystal","CrystalTip")
	var shaft:=CylinderMesh.new();shaft.top_radius=radius;shaft.bottom_radius=radius*.77;shaft.height=height*.66;shaft.radial_segments=5;shaft.rings=1
	mesh_node(pivot,shaft,Vector3(0,height*.33,0),"crystal","CrystalFace")
	return pivot

func crystal_group(single:bool=false,geode:bool=false)->void:
	rock_group(2 if not geode else 1)
	if geode:
		for i in 6:
			var angle:=PI+i*PI/5.0
			lump(root,Vector3(cos(angle)*.49,.36,sin(angle)*.4),Vector3(.39,.73,.35))
	var count:=1 if single else (5 if geode else 3)
	for i in count:
		var pos:=Vector3((i-(count-1)*.5)*.23,.15,rng.randf_range(-.17,.17))
		var part:=crystal(root,pos,rng.randf_range(.48,.85) if geode else rng.randf_range(.60,1.1),.11 if geode else .16)
		part.rotation=Vector3(rng.randf_range(-.17,.17),rng.randf_range(-.4,.4),rng.randf_range(-.23,.23))
		if i==0:effect(pos+Vector3(0,.7,.13),"shine")

func mushrooms(parent:Node3D,pos:Vector3=Vector3.ZERO,scale_factor:float=1.0)->void:
	for i in 3:
		var p:=pos+Vector3((i-1)*.35,0,(-.1 if i==1 else .15))*scale_factor
		var h:float=[.43,.73,.37][i]*scale_factor
		cylinder(parent,p,p+Vector3(.015*scale_factor,h-.05*scale_factor,0),.077*scale_factor,"fungus_under",.77)
		var cap_size:=Vector3(.60,.25,.54)*scale_factor
		lump(parent,p+Vector3(0,h,0),cap_size,"fungus_top","MushroomCap")
		cylinder(parent,p+Vector3(0,h-.085*scale_factor,0),p+Vector3(0,h-.07*scale_factor,0),.24*scale_factor,"fungus_under",1)
		for j in 5:
			var a:=j*TAU/5.0;var r:=.115*scale_factor
			lump(parent,p+Vector3(cos(a)*r,h+.122*scale_factor,sin(a)*r),Vector3(.065,.016,.055)*scale_factor,"flower","CapSpot")

func wall()->void:
	for row in 3:
		for col in 4-row:
			var n:=block(root,Vector3((col-1.5)*.3+(row%2)*.13,.15+row*.25,0),Vector3(.29,.24,.28),"stone");n.rotation.y=rng.randf_range(-.03,.03)
	column(Vector3(-.7,0,0),.9)

func common_wall()->void:
	if family=="gate_pair":
		column(Vector3(-.72,0,0),1.28);column(Vector3(.72,0,0),1.28)
		return
	for row in 3:
		for col in 4:
			if family=="wall_end" and col>2-row/2:continue
			var pos:=Vector3((col-1.5)*.28,.13+row*.24,0)
			if family=="wall_vertical":pos=Vector3(0,pos.y,pos.x)
			var size:=Vector3(.27,.23,.3) if family!="wall_vertical" else Vector3(.3,.23,.27)
			block(root,pos,size,"stone")
	if family=="wall_end":
		for i in 3:lump(root,Vector3(.24+i*.08,.06,.17+i*.04),Vector3(.15,.13,.12),"stone","FallenStone")
	if family in ["wall_outer","wall_inner"]:
		for row in 3:
			for col in 3:block(root,Vector3(.42 if family=="wall_outer" else -.42,.13+row*.24,.28+col*.28),Vector3(.3,.23,.27),"stone")

func column(pos:=Vector3.ZERO,height:float=1.05)->void:
	block(root,pos+Vector3(0,.08,0),Vector3(.45,.16,.45),"stone")
	cylinder(root,pos+Vector3(0,.16,0),pos+Vector3(0,height,0),.19,"stone",.94)
	lump(root,pos+Vector3(0,height+.06,0),Vector3(.43,.16,.4))
	for i in 6:
		var angle:=i*TAU/6.0
		cylinder(root,pos+Vector3(cos(angle)*.18,.2,sin(angle)*.18),pos+Vector3(cos(angle)*.18,height-.1,sin(angle)*.18),.013,"stone",1)
	if not family=="gate_pair":
		for i in 3:lump(root,pos+Vector3(rng.randf_range(-.21,.21),height+.10,rng.randf_range(-.17,.17)),Vector3(.06,.035,.045),"moss","MossPatch")

func arch()->void:
	for side in [-1,1]:
		for i in 3:block(root,Vector3(side*.53,.15+i*.25,0),Vector3(.29,.24,.33),"stone")
	for i in 7:
		var angle:=i*PI/6.0
		var n:=block(root,Vector3(cos(angle)*.53,.71+sin(angle)*.4,0),Vector3(.28,.24,.33),"stone");n.rotation.z=angle-PI*.5
	leaf_cluster(moving,Vector3(-.55,.75,.14),Vector3(.2,.14,.19));animated_part=moving

func roots_only()->void:
	for i in 5:
		var angle:=i*TAU/5.0
		var end:=Vector3(cos(angle)*.65,.02,sin(angle)*.5)
		cylinder(root,Vector3(-.07,.35,.03),end,.09,"wood",.25)
	cylinder(root,Vector3.ZERO,Vector3(.17,.8,-.06),.15,"wood",.3)
	leaf_cluster(moving,Vector3(.4,.07,.12),Vector3(.4,.13,.3));animated_part=moving

func lava(pool:bool=false)->void:
	if pool:
		for i in 8:
			var angle:=i*TAU/8.0
			lump(root,Vector3(cos(angle)*.48,.15,sin(angle)*.38),Vector3(.37,.3,.33))
		lump(root,Vector3(0,.06,0),Vector3(.68,.04,.52),"accent","LavaSurface")
	else:
		rock_group(5)
		for i in 3:
			var n:=block(root,Vector3((i-1)*.27,.32,.43),Vector3(.021,.47,.017),"accent","Seam");n.rotation.z=.18*(i-1)
			block(root,Vector3((i-1)*.27+.05,.41,.43),Vector3(.10,.018,.016),"accent","SeamBranch")
	effect(Vector3(0,.27,.3),"bubble")

func water_pool(trough:bool=false)->void:
	if trough:
		for z in [-.19,.19]:block(root,Vector3(0,.16,z),Vector3(1.25,.32,.13),"stone")
		for x in [-.6,.6]:block(root,Vector3(x,.15,0),Vector3(.12,.3,.5),"stone")
		block(root,Vector3(0,.05,0),Vector3(1.2,.08,.38),"water","Water")
	else:
		for i in 8:
			var a:=i*TAU/8.0
			lump(root,Vector3(cos(a)*.43,.14,sin(a)*.34),Vector3(.32,.28,.27))
		lump(root,Vector3(0,.055,0),Vector3(.6,.025,.43),"water","Water")
	effect(Vector3(0,.1,.05),"ripple")

func effect(pos:Vector3,kind:String)->void:
	var node:=Node3D.new();node.name="EventPivot";root.add_child(node);node.position=pos;node.set_meta("event_kind",kind)
	if kind=="ripple":
		var mesh:=TorusMesh.new();mesh.inner_radius=.075;mesh.outer_radius=.091;mesh.rings=12;mesh.ring_segments=4
		var n:=mesh_node(node,mesh,Vector3.ZERO,"shine","Ripple");n.scale=Vector3(1,.15,1)
	else:
		var role:="shine"
		if kind=="spore":role="fungus_under"
		elif kind=="drop":role="amber" if family.begins_with("resin") else "water"
		elif kind in ["bubble","ember"]:role="accent"
		var n:=lump(node,Vector3.ZERO,Vector3(.048,.06,.03),role,"DetailEffect")
		if kind=="bubble":n.scale=Vector3(1.5,1,1.5)
	animated_part=node;node.scale=Vector3.ONE*.0001

func build(data:Dictionary)->Node3D:
	zone=int(data["map"]);motif=int(data["motif"]);rng.seed=zone*7919+motif*173;family=str(data.get("family",FAMILIES[zone-1][motif-1]))
	root=Node3D.new();root.name=str(data["id"]).replace("-","_")
	moving=Node3D.new();moving.name="MovingParts";root.add_child(moving);animated_part=null
	match family:
		"tree":tree()
		"bush":bush()
		"fern":grasses(true)
		"grass":grasses()
		"stump","hollow_stump","resin_stump","ember_stump":
			stump(family!="stump")
			if family in ["resin_stump","ember_stump"]:effect(Vector3(.26,.35,.16),"ember" if family=="ember_stump" else "drop")
		"log","fungus_log","driftwood","resin_log":
			log_body()
			if family=="resin_log":
				for i in 3:lump(root,Vector3((i-1)*.3,.40,.15),Vector3(.17,.07,.12),"amber","Amber")
				effect(Vector3(.15,.2,.22),"drop")
		"rocks","wet_rocks","coast_rocks","sand_rocks","ridge":
			rock_group(5 if family=="ridge" else 3)
			if family=="wet_rocks":effect(Vector3(.18,.4,.28),"drop")
			if family=="coast_rocks":cylinder(root,Vector3(-.45,.04,.43),Vector3(.6,.12,.31),.08,"wood");shell(root,Vector3(.28,.055,.44),.18)
			if family=="sand_rocks":lump(root,Vector3(0,.055,0),Vector3(1.1,.18,.85),"cut","SandRise")
		"root_rock":rock_group(3);roots_only()
		"root_tree":rock_group(2);tree()
		"wall":wall();leaf_cluster(moving,Vector3(.25,.3,.18),Vector3(.3,.15,.21));animated_part=moving
		"wall_horizontal","wall_vertical","wall_outer","wall_inner","wall_end","gate_pair":common_wall()
		"column":column()
		"rubble":
			for i in 7:
				var n:=block(root,Vector3(rng.randf_range(-.5,.5),.12+rng.randf_range(0,.25),rng.randf_range(-.3,.3)),Vector3(.28,.24,.27),"stone");n.rotation=Vector3(0,rng.randf_range(-.5,.5),rng.randf_range(-.12,.12))
		"arch":arch()
		"slab":
			for i in 3:
				var n:=block(root,Vector3((i-1)*.335,.09,0),Vector3(.322,.18,.68),"stone");n.rotation.y=.015*(i-1)
		"crystals","single_crystal","geode":crystal_group(family=="single_crystal",family=="geode")
		"mushrooms":mushrooms(root);effect(Vector3(.04,.65,.15),"spore")
		"crystal_roots":roots_only();crystal(root,Vector3(.3,.06,.13),.4);effect(Vector3(.3,.4,.22),"shine")
		"lava_rocks","lava_pool":lava(family=="lava_pool")
		"split_meteor":
			lump(root,Vector3(-.32,.3,0),Vector3(.5,.7,.55));lump(root,Vector3(.32,.2,0),Vector3(.5,.48,.55));crystal(root,Vector3(0,.03,0),.32,.08);effect(Vector3(0,.2,.2),"shine")
		"monolith":lump(root,Vector3(0,.55,0),Vector3(.55,1.18,.36))
		"amber_rock":rock_group(3);lump(root,Vector3(.14,.31,.37),Vector3(.26,.22,.08),"amber","AmberInclusion");effect(Vector3(.14,.38,.42),"shine")
		"trough","water_pool":water_pool(family=="trough")
		"roots","fern_roots":roots_only();if family=="fern_roots":grasses(true)
	add_animation(data)
	var visibility:=VisibleOnScreenNotifier3D.new();visibility.name="Visibility";visibility.aabb=AABB(Vector3(-1,0,-1),Vector3(2,3,2));root.add_child(visibility)
	combine_geometry(root)
	root.set_meta("asset_version",2)
	set_owners(root)
	return root

func add_animation(data:Dictionary)->void:
	var spec:Dictionary=data["animation"]
	if int(spec["frames"])<=1:return
	if animated_part==null:effect(Vector3(.15,.3,.2),"shine")
	var player:=AnimationPlayer.new();player.name="AnimationPlayer";root.add_child(player)
	var anim:=Animation.new();anim.length=1.2
	var wind:=animated_part==moving
	var path:=str(root.get_path_to(animated_part))+":rotation" if wind else str(root.get_path_to(animated_part))+":scale"
	var track:=anim.add_track(Animation.TYPE_VALUE);anim.track_set_path(track,NodePath(path))
	for i in 7:
		var t:=i*.2
		var wave:=sin(t/1.2*TAU)
		var value:=Vector3(.02*wave,0,.025*wave) if wind else Vector3.ONE*maxf(.0001,sin(t/1.2*PI))
		anim.track_insert_key(track,t,value)
	if not wind:
		var base_position:Vector3=animated_part.position
		var kind:=str(animated_part.get_meta("event_kind","shine"))
		if kind in ["drop","spore","bubble","ember"]:
			var movement:=anim.add_track(Animation.TYPE_VALUE);anim.track_set_path(movement,NodePath(str(root.get_path_to(animated_part))+":position"))
			var offset:=Vector3(0,-.16 if kind=="drop" else (.22 if kind=="spore" else .08),0)
			anim.track_insert_key(movement,0.0,base_position);anim.track_insert_key(movement,1.0,base_position+offset);anim.track_insert_key(movement,1.2,base_position)
	var library:=AnimationLibrary.new();library.add_animation("rare_event",anim);player.add_animation_library("",library)
	root.set_script(Idle);root.set("idle_min",float(spec["idle_seconds"][0]));root.set("idle_max",float(spec["idle_seconds"][1]));root.set("motif_seed",zone*7919+motif*173)

func set_owners(node:Node)->void:
	for child in node.get_children():child.owner=root;set_owners(child)

func combine_geometry(parent:Node3D)->void:
	var groups:Dictionary={}
	for child in parent.get_children():
		if child is MeshInstance3D:
			var mat:Material=child.material_override
			if mat==null:continue
			var id:=mat.get_instance_id()
			if not groups.has(id):groups[id]={"material":mat,"nodes":[]}
			groups[id]["nodes"].append(child)
		elif child is Node3D and not child is CollisionObject3D:combine_geometry(child)
	for group in groups.values():
		var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);st.set_material(group["material"])
		for child in group["nodes"]:
			var xform:Transform3D=child.transform
			var normals_xform:=xform.basis.inverse().transposed()
			for surface in child.mesh.get_surface_count():
				var arrays:Array=child.mesh.surface_get_arrays(surface)
				var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
				var normals:PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
				var uvs:PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV]
				var indices:PackedInt32Array=arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX]!=null else PackedInt32Array()
				var count:=indices.size() if not indices.is_empty() else vertices.size()
				for step in count:
					var i:=indices[step] if not indices.is_empty() else step
					st.set_normal((normals_xform*normals[i]).normalized());st.set_uv(uvs[i]);st.add_vertex(xform*vertices[i])
		var combined:=MeshInstance3D.new();combined.name="Batched_"+group["material"].resource_name;combined.mesh=st.commit();parent.add_child(combined)
		for child in group["nodes"]:child.free()
