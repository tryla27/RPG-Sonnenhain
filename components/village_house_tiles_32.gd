extends RefCounted
## Native Map-0 village building renderer.
## Every visible part is assembled on the 32px grid; no full-house sprite atlas is used.
const TILE:=32

const WALL_DARK:=Color("4c4034")
const WALL:=Color("8b765b")
const PLASTER:=Color("d2c49f")
const TIMBER:=Color("5b432f")
const ROOF_DARK:=Color("74362d")
const ROOF:=Color("a84c35")
const ROOF_LIGHT:=Color("c96a48")
const STONE:=Color("7c7869")
const STONE_LIGHT:=Color("a6a08a")
const WINDOW:=Color("85d3da")
const WINDOW_GLOW:=Color("f0cf78")
const DOOR:=Color("543d2f")
const GOLD:=Color("d0ad68")

static func tile_rect(c:CanvasItem,p:Vector2i,size:Vector2i,color:Color,border:Color=Color.TRANSPARENT)->void:
	var r:=Rect2(Vector2(p*TILE),Vector2(size*TILE))
	c.draw_rect(r,color)
	if border.a>0.0:c.draw_rect(r,border,false,2.0)

static func local_tile(c:CanvasItem,origin:Vector2,x:int,y:int,w:int,h:int,color:Color,border:Color=Color.TRANSPARENT)->void:
	var r:=Rect2(origin+Vector2(x,y)*TILE,Vector2(w,h)*TILE)
	c.draw_rect(r,color)
	if border.a>0.0:c.draw_rect(r,border,false,2.0)

static func beam(c:CanvasItem,origin:Vector2,x:int,y:int,w:int=1,h:int=1)->void:
	local_tile(c,origin,x,y,w,h,TIMBER)

static func window_tile(c:CanvasItem,origin:Vector2,x:int,y:int,lit:bool=false)->void:
	var p:=origin+Vector2(x,y)*TILE
	c.draw_rect(Rect2(p+Vector2(7,6),Vector2(18,22)),TIMBER)
	c.draw_rect(Rect2(p+Vector2(10,9),Vector2(12,16)),WINDOW_GLOW if lit else WINDOW)
	c.draw_rect(Rect2(p+Vector2(15,9),Vector2(2,16)),TIMBER)
	c.draw_rect(Rect2(p+Vector2(10,16),Vector2(12,2)),TIMBER)

static func door_tile(c:CanvasItem,origin:Vector2,x:int,y:int,double_door:bool=false)->void:
	# 72 px = 2.25 m at the hero's scale; the former 31 px door was too short.
	var p:=origin+Vector2(x,y)*TILE+Vector2(0,-24)
	var width:=58.0 if double_door else 26.0
	var left:=p.x-13.0 if double_door else p.x+3.0
	c.draw_rect(Rect2(Vector2(left,p.y+1),Vector2(width,72)),TIMBER)
	c.draw_rect(Rect2(Vector2(left+3,p.y+4),Vector2(width-6,66)),DOOR)
	if double_door:
		c.draw_rect(Rect2(Vector2(p.x+15,p.y+4),Vector2(3,66)),TIMBER)
	c.draw_circle(Vector2(left+width-7,p.y+42),2.5,GOLD)

static func roof_row(c:CanvasItem,origin:Vector2,y:int,x0:int,x1:int,accent:Color)->void:
	for x in range(x0,x1):
		var p:=origin+Vector2(x,y)*TILE
		var color:=ROOF if (x+y)%2==0 else ROOF_DARK
		c.draw_rect(Rect2(p,Vector2(TILE,TILE)),color)
		c.draw_rect(Rect2(p+Vector2(0,24),Vector2(TILE,8)),accent)
		for sx in [4,15,26]:c.draw_rect(Rect2(p+Vector2(sx,5),Vector2(3,16)),ROOF_LIGHT)

static func normal_house(c:CanvasItem,p:Vector2,kind:String)->void:
	# 6x5 tiles = 192x160. Anchor stays identical to the old house footprint.
	var accent:Color={
		"research":Color("6f91ad"),"style":Color("b77aa6"),"healer":Color("6da987"),
		"innkeeper":Color("b47755"),"elder":Color("8a78a4"),"apprentice":Color("897bb7"),
		"smith":Color("a65e47"),"home":Color("8f765b")
	}.get(kind,Color("8f765b"))
	# Shadow and foundation.
	c.draw_rect(Rect2(p+Vector2(8,145),Vector2(176,15)),Color("202b2a",0.28))
	local_tile(c,p,0,3,6,2,WALL,WALL_DARK)
	local_tile(c,p,0,4,6,1,STONE,Color("555247"))
	# Plaster bays and timber frame.
	for x in range(6):
		local_tile(c,p,x,2,1,1,PLASTER)
	for x in [0,3,5]:beam(c,p,x,2)
	c.draw_rect(Rect2(p+Vector2(0,64),Vector2(192,6)),TIMBER)
	c.draw_rect(Rect2(p+Vector2(0,95),Vector2(192,6)),TIMBER)
	# Roof stepped in 32px tiles.
	roof_row(c,p,1,0,6,accent)
	roof_row(c,p,0,1,5,accent)
	c.draw_rect(Rect2(p+Vector2(64,-8),Vector2(64,8)),ROOF_DARK)
	# Windows / central door.
	window_tile(c,p,1,2,kind in ["innkeeper","healer"])
	window_tile(c,p,4,2,kind in ["innkeeper","style"])
	door_tile(c,p,2,3,true)
	# Profession accents are tile-scale, never overlaid full-house sprites.
	match kind:
		"style":
			local_tile(c,p,0,3,1,1,Color("71566c"))
			local_tile(c,p,5,3,1,1,Color("71566c"))
		"healer":
			c.draw_rect(Rect2(p+Vector2(155,106),Vector2(8,30)),Color("e7ead5"))
			c.draw_rect(Rect2(p+Vector2(144,117),Vector2(30,8)),Color("e7ead5"))
		"innkeeper":
			c.draw_rect(Rect2(p+Vector2(16,137),Vector2(160,10)),Color("6f4d37"))
			for x in [36,68,100,132,164]:c.draw_circle(p+Vector2(x,149),4,Color("d49a58"))
		"elder":
			c.draw_colored_polygon(PackedVector2Array([p+Vector2(96,15),p+Vector2(112,38),p+Vector2(96,31),p+Vector2(80,38)]),accent.lightened(.35))
		"apprentice":
			for x in [24,56,128,160]:
				c.draw_colored_polygon(PackedVector2Array([p+Vector2(x,118),p+Vector2(x+6,103),p+Vector2(x+12,118),p+Vector2(x+6,132)]),Color("8bdfff"))
		"smith":
			local_tile(c,p,4,1,1,2,Color("5b4b49"))
			c.draw_circle(p+Vector2(144,24),9,Color("73706e",.5))
			c.draw_line(p+Vector2(21,145),p+Vector2(52,116),Color("d2b06e"),5)

static func borin_house(c:CanvasItem,p:Vector2)->void:
	# 8x7.5-tile footprint, preserving the former 256x240 interaction footprint.
	var accent:=Color("685ca8")
	c.draw_rect(Rect2(p+Vector2(8,224),Vector2(240,16)),Color("202b2a",0.30))
	local_tile(c,p,0,3,8,4,Color("746b68"),Color("4f4a4a"))
	local_tile(c,p,0,6,8,1,STONE,Color("555247"))
	for x in range(8):local_tile(c,p,x,2,1,1,Color("b7aea4"))
	for x in [0,2,5,7]:beam(c,p,x,2)
	roof_row(c,p,1,0,8,accent)
	roof_row(c,p,0,1,7,accent)
	c.draw_rect(Rect2(p+Vector2(64,-8),Vector2(128,8)),Color("483d72"))
	window_tile(c,p,1,3,true);window_tile(c,p,6,3,true)
	window_tile(c,p,1,4,false);window_tile(c,p,6,4,false)
	door_tile(c,p,3,5,true)
	for x in [1,3,5]:
		local_tile(c,p,x,1,1,1,Color("61569a"))
		c.draw_rect(Rect2(p+Vector2(x*32+8,40),Vector2(16,8)),Color("a9dfff"))
	for i in 5:
		var q:=p+Vector2(34+i*44,218)
		c.draw_circle(q,6,Color("7165ba",.45));c.draw_circle(q,3,Color("cfc5ff"))

static func arena_building(c:CanvasItem,p:Vector2)->void:
	# 12x7.5 tiles = 384x240, matching the existing arena footprint.
	c.draw_rect(Rect2(p+Vector2(16,224),Vector2(352,16)),Color("202b2a",.32))
	for x in range(12):
		for y in range(3,7):
			local_tile(c,p,x,y,1,1,STONE if (x+y)%2==0 else WALL_DARK,Color("44413b"))
	roof_row(c,p,2,0,12,Color("793d45"))
	roof_row(c,p,1,1,11,Color("793d45"))
	roof_row(c,p,0,2,10,Color("793d45"))
	# Side towers.
	for x in [0,10]:
		local_tile(c,p,x,2,2,5,WALL_DARK)
		local_tile(c,p,x,3,2,4,STONE)
		local_tile(c,p,x,1,2,1,ROOF_DARK)
	# Central arched-looking gate built from tiles/rects.
	local_tile(c,p,4,3,4,4,WALL_DARK)
	c.draw_circle(p+Vector2(192,114),45,STONE_LIGHT)
	c.draw_circle(p+Vector2(192,120),31,Color("29292a"))
	c.draw_rect(Rect2(p+Vector2(161,120),Vector2(62,88)),Color("29292a"))
	door_tile(c,p,5,5,true)
	for x in [74,290]:
		c.draw_rect(Rect2(p+Vector2(x,94),Vector2(20,68)),Color("793d45"))
		c.draw_colored_polygon(PackedVector2Array([p+Vector2(x,162),p+Vector2(x+10,178),p+Vector2(x+20,162)]),Color("793d45"))
	c.draw_rect(Rect2(p+Vector2(112,78),Vector2(160,26)),Color("302f2c"))
	c.draw_rect(Rect2(p+Vector2(120,85),Vector2(144,12)),Color("70523d"))

static func paint(c:CanvasItem,p:Vector2,kind:String)->void:
	if kind=="borin":borin_house(c,p)
	elif kind=="arena":arena_building(c,p)
	else:normal_house(c,p,kind)
