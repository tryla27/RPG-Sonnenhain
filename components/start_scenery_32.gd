extends RefCounted
## Individual transparent reference-style sprites, composed into the existing game world.
const VillageHouseTiles32 = preload("res://components/village_house_tiles_32.gd")
const VillageWellTiles32 = preload("res://components/village_well_tiles_32.gd")
static var objects:Texture2D
static var props:Texture2D
static var terrain:Texture2D
static var art_initialized := false
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
	init_art()
	if objects != null:
		sprite(c,objects,Rect2(5,510,550,495),Rect2(p+Vector2(-88,-176),Vector2(176,208)))
		return
	c.draw_rect(Rect2(p+Vector2(-8,-54),Vector2(16,66)),Color("5c4634"))
	c.draw_circle(p+Vector2(0,-83),44,Color("406b49"))
	c.draw_circle(p+Vector2(-28,-62),30,Color("4d7b52"))
	c.draw_circle(p+Vector2(28,-60),29,Color("4a7550"))

# Eigener Zauberbaum fuer Borins Skillbereich: groesser, blau-violett und mit Runen.
static func magic_tree(c:CanvasItem,p:Vector2)->void:
	init_art()
	if objects != null:
		sprite(c,objects,Rect2(5,510,550,495),Rect2(p+Vector2(-104,-216),Vector2(208,248)))
	else:
		c.draw_rect(Rect2(p+Vector2(-10,-76),Vector2(20,92)),Color("574035"))
		c.draw_circle(p+Vector2(0,-120),56,Color("76599b"))
		c.draw_circle(p+Vector2(-38,-91),38,Color("8b66ad"))
		c.draw_circle(p+Vector2(39,-90),37,Color("6654a1"))
	for i in 4:
		var rune:=p+Vector2(0,-58-i*24)
		c.draw_circle(rune,8,Color("5ed7ff",0.22),false,3.0)
		c.draw_line(rune+Vector2(-5,0),rune+Vector2(5,0),Color("9be9ff"),2)
	for side in [-1,1]:
		for i in 3:
			var lamp:=p+Vector2(side*(38+i*13),-116+i*28)
			c.draw_line(lamp-Vector2(0,14),lamp,Color("69548e"),2)
			c.draw_colored_polygon(PackedVector2Array([lamp+Vector2(0,-6),lamp+Vector2(5,0),lamp+Vector2(0,9),lamp+Vector2(-5,0)]),Color("8be6ff"))
	c.draw_circle(p+Vector2(0,8),38,Color("6d64be",0.16))
	c.draw_arc(p+Vector2(0,8),31,0,TAU,24,Color("91e7ff"),3)

static func well(c:CanvasItem,p:Vector2)->void:
	VillageWellTiles32.paint(c,p)

static func bush(c:CanvasItem,p:Vector2,_key:int)->void:
	init_art()
	if props != null:
		sprite(c,props,Rect2(585,85,420,355),Rect2(p+Vector2(-46,-44),Vector2(92,78)))
		return
	c.draw_circle(p+Vector2(-22,0),25,Color("4f7d4f"))
	c.draw_circle(p+Vector2(6,-10),31,Color("5a8a57"))
	c.draw_circle(p+Vector2(29,2),23,Color("477548"))
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
