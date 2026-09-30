extends RefCounted
## Individual transparent reference-style sprites, composed into the existing game world.
static var objects:Texture2D
static var props:Texture2D
static var terrain:Texture2D
static var art_initialized := false
static func init_art()->void:
	if art_initialized: return
	art_initialized = true
	if objects==null:objects=load("res://art/start32/objects-faithful.webp")
	if props==null:props=load("res://art/start32/props-faithful.webp")
	if terrain==null:terrain=load("res://art/start32/terrain_32.webp")
static func sprite(c:CanvasItem,texture:Texture2D,source:Rect2,target:Rect2)->void:
	if texture == null: return
	c.draw_texture_rect_region(texture,target,source,Color.WHITE,false,true)
static func house(c:CanvasItem,p:Vector2,kind:int=0)->void:
	init_art()
	sprite(c,objects,Rect2(kind*512+10,20,495,480),Rect2(p+Vector2(0,-32),Vector2(192,192)))
static func tree(c:CanvasItem,p:Vector2,_key:int)->void:
	init_art()
	sprite(c,objects,Rect2(5,510,550,495),Rect2(p+Vector2(-88,-176),Vector2(176,208)))
static func well(c:CanvasItem,p:Vector2)->void:
	init_art()
	sprite(c,objects,Rect2(565,520,430,470),Rect2(p+Vector2(-64,-96),Vector2(128,144)))
static func bush(c:CanvasItem,p:Vector2,_key:int)->void:
	init_art()
	sprite(c,props,Rect2(585,85,420,355),Rect2(p+Vector2(-46,-44),Vector2(92,78)))
static func barrel(c:CanvasItem,p:Vector2)->void:
	init_art()
	sprite(c,props,Rect2(1090,80,430,350),Rect2(p+Vector2(-24,-34),Vector2(48,42)))
static func lamp(c:CanvasItem,p:Vector2)->void:
	init_art()
	sprite(c,props,Rect2(160,460,220,520),Rect2(p+Vector2(-20,-88),Vector2(40,100)))
static func board(c:CanvasItem,p:Vector2)->void:
	init_art()
	sprite(c,props,Rect2(445,530,425,440),Rect2(p+Vector2(-48,-94),Vector2(96,100)))
static func cart(c:CanvasItem,p:Vector2,kind:String)->void:
	init_art()
	sprite(c,props,Rect2(0,30,580,410),Rect2(p+Vector2(-52,-68),Vector2(132,94)))
	# Real stock markers distinguish the existing merchant professions.
	var col:Color=Color("68dae2") if kind in ["alchemy","healer"] else Color("deb864")
	c.draw_rect(Rect2(p+Vector2(38,-22),Vector2(7,11)),col)
static func waystone(c:CanvasItem,p:Vector2,_active:bool)->void:
	init_art()
	sprite(c,objects,Rect2(1020,535,515,470),Rect2(p+Vector2(-78,-113),Vector2(156,156)))
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
