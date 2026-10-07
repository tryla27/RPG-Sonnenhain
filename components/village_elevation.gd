extends RefCounted
const Layout=preload("res://components/village_layout.gd")
const Catalog=preload("res://components/terrain/terrain_catalog_32.gd")
const LEVEL_HEIGHT:=16.0
const STAIR_WIDTH:=128.0
const KINDS:=["healer"]
static var entries:Array[Dictionary]=[]
static var stone:Texture2D

static func lift(kind:String)->float:return 32.0 if kind in KINDS else 0.0

static func prepare()->void:
	if not entries.is_empty():return
	var buildings=load("res://components/village_buildings.gd")
	for shop in Layout.SHOPS:
		if shop.has("shared_with") or str(shop["kind"]) not in KINDS:continue
		var home:Vector2=shop["house"]
		var door:Vector2=buildings.door(home,shop["kind"])
		entries.append({"kind":shop["kind"],"home":home,"door":door,"upper":Rect2(home+Vector2(8,200),Vector2(432,door.y+16-home.y-200)),"lower":Rect2(Vector2(home.x,door.y+16),Vector2(448,16))})

static func height_at(p:Vector2)->float:
	prepare()
	for entry in entries:
		var door:Vector2=entry["door"]
		if absf(p.x-door.x)<=STAIR_WIDTH*0.5:
			if p.y>=door.y and p.y<door.y+16:return lerpf(32,16,(p.y-door.y)/16.0)
			if p.y>=door.y+24 and p.y<door.y+40:return lerpf(16,0,(p.y-door.y-24)/16.0)
		if Rect2(entry["upper"]).has_point(p):return 32
		if Rect2(entry["lower"]).has_point(p):return 16
	return 0

static func paved(p:Vector2)->bool:
	prepare()
	for entry in entries:
		if Rect2(entry["upper"]).has_point(p) or Rect2(entry["lower"]).has_point(p):return true
		var door:Vector2=entry["door"]
		if Rect2(door+Vector2(-64,0),Vector2(128,48)).has_point(p):return true
	return false

static func visual_bounds(home:Vector2,kind:String)->Rect2:
	if kind not in KINDS:return Rect2()
	prepare()
	for entry in entries:
		if entry["home"]!=home:continue
		var upper:Rect2=entry["upper"]
		var door:Vector2=entry["door"]
		return Rect2(Vector2(home.x,upper.position.y-32),Vector2(448,door.y+40-(upper.position.y-32)))
	return Rect2()

static func blocked(p:Vector2,origin:Vector2,radius:float)->bool:
	if absf(height_at(p)-height_at(origin))<0.01:return false
	for entry in entries:
		var door:Vector2=entry["door"]
		var lane:=Rect2(door+Vector2(-64+radius,-32),Vector2(128-radius*2,176))
		if lane.has_point(p) and lane.has_point(origin):return false
	return true

static func surface(c:CanvasItem,rect:Rect2,height:float)->void:
	if stone==null:stone=load(Catalog.GROUND_ATLAS)
	var target:=Rect2(rect.position-Vector2(0,height),rect.size)
	c.draw_rect(target,Color("767780"))
	for x in range(floori(target.position.x/32.0),ceili(target.end.x/32.0)):
		for y in range(floori(target.position.y/32.0),ceili(target.end.y/32.0)):
			var tile:=Rect2(Vector2(x,y)*32,Vector2(32,32))
			var clipped:=tile.intersection(target)
			var source:=Vector2(Catalog.atlas_coord("plaza_stone",Catalog.coherent_variant(Vector2i(x,y)))*32)
			c.draw_texture_rect_region(stone,clipped,Rect2(source+clipped.position-tile.position,clipped.size))
	c.draw_rect(target,Color("514d59"),false,1)
	# Vertical front riser with limited slate shades and crisp block joints.
	var face:=Rect2(target.position.x,target.end.y,target.size.x,16)
	c.draw_rect(face,Color("64616e"))
	c.draw_line(face.position,face.position+Vector2(face.size.x,0),Color("b3b0b4"),2)
	c.draw_line(face.position+Vector2(0,15),face.end,Color("453f4c"),2)
	for x in range(int(face.position.x)+16,int(face.end.x),32):c.draw_line(Vector2(x,face.position.y+2),Vector2(x,face.end.y-2),Color("453f4c"),1)

static func stairs(c:CanvasItem,door:Vector2,start_y:float,upper_height:float)->void:
	for step in 4:
		var y:=start_y+step*4.0
		var h:=upper_height-step*4.0
		var rect:=Rect2(door.x-64,door.y+y-h,128,8)
		c.draw_rect(rect,Color("929099") if step%2==0 else Color("86848e"))
		c.draw_line(rect.position,rect.position+Vector2(128,0),Color("cfccd0"),2)
		c.draw_line(rect.position+Vector2(0,6),rect.end-Vector2(0,2),Color("534e5b"),2)
		for x in [-32,0,32]:c.draw_line(Vector2(door.x+x,rect.position.y+2),Vector2(door.x+x,rect.end.y-2),Color("6b6673"),1)

static func paint(c:CanvasItem,home:Vector2,kind:String)->void:
	if kind not in KINDS:return
	prepare()
	for entry in entries:
		if entry["home"]!=home:continue
		surface(c,entry["lower"],16)
		surface(c,entry["upper"],32)
		stairs(c,entry["door"],0,32)
		stairs(c,entry["door"],24,16)
