extends RefCounted
## Individual transparent reference-style sprites, composed into the existing game world.
const ReferenceHouse = preload("res://components/reference_house.gd")
static var objects:Texture2D
static var props:Texture2D
static var terrain:Texture2D
static var houses:Texture2D
static var art_initialized := false
static func init_art()->void:
	if art_initialized: return
	art_initialized = true
	# Verified reference textures; procedural shapes remain a fallback.
	if objects==null: objects=load("res://art/start32/objects-faithful.webp")
	if props==null: props=load("res://art/start32/props-faithful.webp")
	if houses==null: houses=load("res://art/houses_192.png")
	if terrain==null: terrain=load("res://art/start32/terrain_32.webp")
static func sprite(c:CanvasItem,texture:Texture2D,source:Rect2,target:Rect2)->void:
	if texture == null: return
	c.draw_texture_rect_region(texture,target,source,Color.WHITE,false,true)
static func house(c:CanvasItem,p:Vector2,kind:int=0)->void:
	init_art()
	if objects != null:
		sprite(c,objects,Rect2(kind*512+10,20,495,480),Rect2(p+Vector2(0,-32),Vector2(192,192)))
		return
	if houses != null:
		# houses_192.png enthält die drei robust exportierbaren Hausvarianten.
		c.draw_texture_rect_region(houses,Rect2(p,Vector2(192,160)),Rect2(kind*192,0,192,160),Color.WHITE,false,true)
	else:
		var roof: Color = [Color("a7422d"),Color("87563d"),Color("6f5540")][clampi(kind,0,2)]
		ReferenceHouse.paint(c,p,roof,Color("ffd482"),false)

# Themed village houses: same 32px-compatible base sprite, with profession-specific
# roof/accent props so every resident has a readable home silhouette.
static func themed_house(c:CanvasItem,p:Vector2,kind:String)->void:
	var base_kind:=2 if kind=="innkeeper" else (1 if kind=="healer" else 0)
	house(c,p,base_kind)
	var accent:Color={
		"research":Color("6f91ad"),"style":Color("b77aa6"),"healer":Color("6da987"),
		"innkeeper":Color("b47755"),"elder":Color("8a78a4"),"apprentice":Color("897bb7"),
		"smith":Color("a65e47"),"arena":Color("a15d4e")
	}.get(kind,Color("8f765b"))
	# Tile-sized trim and sign-like roof marks.
	for i in 5:
		c.draw_rect(Rect2(p+Vector2(16+i*32,20),Vector2(24,7)),accent if i%2==0 else accent.lightened(.18))
	match kind:
		"research":
			c.draw_circle(p+Vector2(154,42),18,Color("415c67"))
			c.draw_arc(p+Vector2(154,42),14,0,TAU,18,Color("b9e8ec"),3)
			c.draw_line(p+Vector2(154,24),p+Vector2(170,5),Color("c7c0a1"),3)
		"style":
			c.draw_rect(Rect2(p+Vector2(19,113),Vector2(35,48)),Color("71566c"))
			c.draw_rect(Rect2(p+Vector2(137,113),Vector2(35,48)),Color("71566c"))
			for x in [33,151]: c.draw_circle(p+Vector2(x,104),6,Color("f0c8df"))
		"healer":
			c.draw_rect(Rect2(p+Vector2(146,105),Vector2(8,30)),Color("e7ead5"))
			c.draw_rect(Rect2(p+Vector2(135,116),Vector2(30,8)),Color("e7ead5"))
			for x in [25,52,79]: c.draw_circle(p+Vector2(x,153),6,Color("75a96c"))
		"innkeeper":
			c.draw_rect(Rect2(p+Vector2(18,140),Vector2(156,12)),Color("6f4d37"))
			for x in [35,67,99,131]: c.draw_circle(p+Vector2(x,151),5,Color("d49a58"))
		"elder":
			c.draw_colored_polygon(PackedVector2Array([p+Vector2(96,18),p+Vector2(111,40),p+Vector2(96,34),p+Vector2(81,40)]),accent.lightened(.35))
		"apprentice":
			for x in [28,58,128,158]:
				c.draw_colored_polygon(PackedVector2Array([p+Vector2(x,115),p+Vector2(x+6,103),p+Vector2(x+12,115),p+Vector2(x+6,128)]),Color("8bdfff"))
		"smith":
			c.draw_rect(Rect2(p+Vector2(143,34),Vector2(24,48)),Color("5b4b49"))
			c.draw_circle(p+Vector2(155,27),11,Color("6d6b69",.55))
			c.draw_line(p+Vector2(22,143),p+Vector2(54,115),Color("d2b06e"),5)
		"arena":
			for x in [34,152]:
				c.draw_line(p+Vector2(x,145),p+Vector2(x+18,112),Color("d6d9cf"),4)
				c.draw_line(p+Vector2(x-4,132),p+Vector2(x+17,138),Color("d4a85e"),3)

# Borins Haus ist bewusst groesser als die normalen 192x160-Dorfhaeuser.
# Der Anker bleibt links oben, damit Wege, NPC und Interaktion stabil positionierbar sind.
static func borin_house(c:CanvasItem,p:Vector2)->void:
	init_art()
	if objects != null:
		sprite(c,objects,Rect2(10,20,495,480),Rect2(p,Vector2(256,240)))
	else:
		ReferenceHouse.paint(c,p,Color("465e86"),Color("ffe0a1"),false)
		ReferenceHouse.paint(c,p+Vector2(64,28),Color("3f577c"),Color("ffe0a1"),false)
	c.draw_rect(Rect2(p+Vector2(18,205),Vector2(220,12)),Color("51483b"))
	c.draw_rect(Rect2(p+Vector2(24,207),Vector2(208,5)),Color("b8aa87"))
	for i in 5:
		var q:=p+Vector2(30+i*43,220)
		c.draw_circle(q,6,Color("7165ba",0.42))
		c.draw_circle(q,3,Color("cfc5ff"))

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
	init_art()
	if objects != null:
		sprite(c,objects,Rect2(565,520,430,470),Rect2(p+Vector2(-64,-96),Vector2(128,144)))
		return
	c.draw_circle(p+Vector2(0,12),42,Color("6b6659"))
	c.draw_circle(p+Vector2(0,7),31,Color("26383c"))
	c.draw_rect(Rect2(p+Vector2(-48,-48),Vector2(10,62)),Color("6a5038"))
	c.draw_rect(Rect2(p+Vector2(38,-48),Vector2(10,62)),Color("6a5038"))
	c.draw_rect(Rect2(p+Vector2(-50,-54),Vector2(100,9)),Color("9a7650"))
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
	init_art()
	if props != null:
		sprite(c,props,Rect2(160,460,220,520),Rect2(p+Vector2(-20,-88),Vector2(40,100)))
		return
	c.draw_rect(Rect2(p+Vector2(-3,-70),Vector2(6,78)),Color("45413c"))
	c.draw_rect(Rect2(p+Vector2(-11,-72),Vector2(22,5)),Color("6d6250"))
	c.draw_rect(Rect2(p+Vector2(-8,-65),Vector2(16,18)),Color("f2c96f"))
static func board(c:CanvasItem,p:Vector2)->void:
	init_art()
	if props != null:
		sprite(c,props,Rect2(445,530,425,440),Rect2(p+Vector2(-48,-94),Vector2(96,100)))
		return
	c.draw_rect(Rect2(p+Vector2(-4,-55),Vector2(8,70)),Color("574737"))
	c.draw_rect(Rect2(p+Vector2(-42,-72),Vector2(84,44)),Color("9a784f"))
	c.draw_rect(Rect2(p+Vector2(-38,-68),Vector2(76,36)),Color("c39b63"))
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
