extends RefCounted
## Individual transparent reference-style sprites, composed into the existing game world.
const VillageHouseTiles32 = preload("res://components/village_house_tiles_32.gd")
static var objects:Texture2D
static var props:Texture2D
static var terrain:Texture2D
static var art_initialized := false
const SCENERY := {
	"dorfeiche":{"source":Rect2(20,69,1082,1266),"size":Vector2(192,224),"offset":Vector2(-96,-208)},
	"ahorn":{"source":Rect2(86,70,983,1273),"size":Vector2(176,224),"offset":Vector2(-88,-208)},
	"tanne":{"source":Rect2(190,109,745,1197),"size":Vector2(96,160),"offset":Vector2(-48,-144)},
	"borin-runenbaum":{"source":Rect2(72,97,991,1217),"size":Vector2(192,224),"offset":Vector2(-96,-208)},
	"brunnen":{"source":Rect2(281,153,780,983),"size":Vector2(128,160),"offset":Vector2(-64,-128)},
	"busch-oliv":{"source":Rect2(339,335,771,515),"size":Vector2(96,64),"offset":Vector2(-48,-48)},
	"busch-herbst":{"source":Rect2(273,205,937,674),"size":Vector2(96,64),"offset":Vector2(-48,-48)},
	"busch-blumen":{"source":Rect2(255,208,936,672),"size":Vector2(96,64),"offset":Vector2(-48,-48)}
}
static var scenery_textures:Dictionary={}

static func tree_variant(p:Vector2)->String:
	if p.x<160:return "tanne"
	return "ahorn" if p.x>1000 else "dorfeiche"

static func bush_variant(p:Vector2)->String:
	return ["busch-oliv","busch-herbst","busch-blumen"][posmod(int(p.x+p.y)/10,3)]

static func scenery_bounds(p:Vector2,asset:String)->Rect2:
	var spec:Dictionary=SCENERY[asset]
	return Rect2(p+Vector2(spec["offset"]),Vector2(spec["size"]))

static func scenery_texture(asset:String)->Texture2D:
	if not scenery_textures.has(asset):
		var original:Texture2D=load("res://art/village/objects/%s.png" % asset)
		var image:Image=original.get_image()
		if image.is_compressed():image.decompress()
		image=image.get_region(Rect2i(SCENERY[asset]["source"]))
		image.resize(int(SCENERY[asset]["size"].x),int(SCENERY[asset]["size"].y),Image.INTERPOLATE_NEAREST)
		image.convert(Image.FORMAT_RGBA8)
		# Runtime cutout: keep source PNGs intact, suppress generated translucent
		# fringes before nearest-neighbour rendering on the village floor.
		var pixels:PackedByteArray=image.get_data()
		for i in range(3,pixels.size(),4):pixels[i]=255 if pixels[i]>=230 else 0
		image=Image.create_from_data(image.get_width(),image.get_height(),false,Image.FORMAT_RGBA8,pixels)
		scenery_textures[asset]=ImageTexture.create_from_image(image)
	return scenery_textures[asset]

static func scenery(c:CanvasItem,p:Vector2,asset:String)->void:
	c.draw_texture_rect(scenery_texture(asset),scenery_bounds(p,asset),false)
static func init_art()->void:
	if art_initialized: return
	art_initialized = true
	# Verified reference textures; procedural shapes remain a fallback.
	if objects==null: objects=load("res://art/start32/objects-faithful.webp")
	if props==null: props=load("res://art/start32/props-faithful.webp")
	if terrain==null: terrain=load("res://art/start32/terrain_32.webp")
static func sprite(c:CanvasItem,texture:Texture2D,source:Rect2,target:Rect2)->void:
	if texture == null: return
	c.draw_texture_rect_region(texture,target,source,Color.WHITE,false,true)
static func house(c:CanvasItem,p:Vector2,kind:int=0)->void:
	# Legacy API kept for callers outside Map 0, but village houses never use a full-house sprite.
	var mapped:String=["home","healer","innkeeper"][clampi(kind,0,2)]
	VillageHouseTiles32.paint(c,p,mapped)

static func themed_house(c:CanvasItem,p:Vector2,kind:String)->void:
	if not preload("res://components/village_buildings.gd").paint(c,p,kind):VillageHouseTiles32.paint(c,p,kind)

static func borin_house(c:CanvasItem,p:Vector2)->void:
	if not preload("res://components/village_buildings.gd").paint(c,p,"borin"):VillageHouseTiles32.paint(c,p,"borin")

static func arena_building(c:CanvasItem,p:Vector2)->void:
	preload("res://components/village_buildings.gd").paint(c,p,"arena")

static func tree(c:CanvasItem,p:Vector2,_key:int)->void:
	scenery(c,p,tree_variant(p))

# Eigener Zauberbaum fuer Borins Skillbereich: groesser, blau-violett und mit Runen.
static func magic_tree(c:CanvasItem,p:Vector2)->void:
	scenery(c,p,"borin-runenbaum")

static func well(c:CanvasItem,p:Vector2)->void:
	scenery(c,p,"brunnen")

static func bush(c:CanvasItem,p:Vector2,_key:int)->void:
	scenery(c,p,bush_variant(p))
static func barrel(c:CanvasItem,p:Vector2)->void:
	init_art()
	if props != null:
		sprite(c,props,Rect2(1090,80,430,350),Rect2(p+Vector2(-24,-34),Vector2(48,42)))
		return
	c.draw_rect(Rect2(p+Vector2(-18,-28),Vector2(36,42)),Color("8a6548"))
	for y in [-25,-5,11]: c.draw_rect(Rect2(p+Vector2(-20,y),Vector2(40,4)),Color("4d4540"))
static func lamp(c:CanvasItem,p:Vector2)->void:
	preload("res://components/village_fixtures.gd").lamp(c,p)

static func board(c:CanvasItem,p:Vector2)->void:
	preload("res://components/village_fixtures.gd").board(c,p)

static func cart(c:CanvasItem,p:Vector2,kind:String)->void:
	init_art()
	if props != null:
		sprite(c,props,Rect2(0,30,580,410),Rect2(p+Vector2(-52,-68),Vector2(132,94)))
		return
	c.draw_rect(Rect2(p+Vector2(-48,-35),Vector2(96,46)),Color("8d6845"))
	c.draw_rect(Rect2(p+Vector2(-42,-30),Vector2(84,31)),Color("b68758"))
	c.draw_circle(p+Vector2(-34,18),15,Color("4a4038"))
	c.draw_circle(p+Vector2(34,18),15,Color("4a4038"))
	# Real stock markers distinguish the existing merchant professions.
	var col:Color=Color("68dae2") if kind in ["alchemy","healer"] else Color("deb864")
	c.draw_rect(Rect2(p+Vector2(38,-22),Vector2(7,11)),col)
static func waystone(c:CanvasItem,p:Vector2,_active:bool)->void:
	init_art()
	if objects != null:
		sprite(c,objects,Rect2(1020,535,515,470),Rect2(p+Vector2(-78,-113),Vector2(156,156)))
		return
	c.draw_colored_polygon(PackedVector2Array([p+Vector2(0,-70),p+Vector2(34,-18),p+Vector2(24,48),p+Vector2(-24,48),p+Vector2(-34,-18)]),Color("657b7d"))
	c.draw_circle(p+Vector2(0,-12),13,Color("8fd9e1"))
	c.draw_circle(p+Vector2(0,-12),6,Color("d8ffff"))
static func wall(c:CanvasItem,face:Rect2)->void:
	init_art()
	for x in range(floori(face.position.x/32),ceili(face.end.x/32)):
		for y in range(floori(face.position.y/32),ceili(face.end.y/32)):
			var target:Rect2=Rect2(x*32,y*32,32,32).intersection(face)
			var offset:Vector2=target.position-Vector2(x*32,y*32)
			sprite(c,terrain,Rect2(Vector2(512+posmod(x,4)*32,posmod(y,4)*32)+offset,target.size),target)
static func gatepost(c:CanvasItem,p:Vector2)->void:
	init_art()
	sprite(c,props,Rect2(974,540,118,388),Rect2(p+Vector2(-39,-59),Vector2(78,96)))
static func sign(c:CanvasItem,p:Vector2,title:String,font:Font)->void:
	var plate:=Rect2(p+Vector2(21,-48),Vector2(150,16))
	c.draw_rect(plate,Color("40372d"))
	c.draw_rect(Rect2(plate.position+Vector2(1,1),plate.size-Vector2(2,2)),Color("786144"))
	c.draw_string(font,p+Vector2(24,-36),title,HORIZONTAL_ALIGNMENT_CENTER,144,10,Color("fff0bd"))
static func fence(c:CanvasItem,a:Vector2,b:Vector2)->void:
	var old=load("res://components/reference_scenery.gd")
	old.fence(c,a,b)
	for y in [-26,-9]:
		for x in range(4,int(b.x-a.x),13):
			c.draw_rect(Rect2(a+Vector2(x,y+3),Vector2(8,1)),Color("71512f"))
	for i in range(4):
		var p:=a.lerp(b,i/3.0)
		c.draw_rect(Rect2(p+Vector2(-6,0),Vector2(12,5)),Color("716e5a"))
		c.draw_rect(Rect2(p+Vector2(-4,0),Vector2(8,1)),Color("b2ae8f"))
static func gate(c:CanvasItem,p:Vector2,vertical:bool,camera:Vector2)->void:
	init_art()
	c.draw_set_transform(p-camera,PI/2 if vertical else 0)
	sprite(c,props,Rect2(895,535,615,420),Rect2(-225,-158,450,195))
	c.draw_set_transform(-camera)
