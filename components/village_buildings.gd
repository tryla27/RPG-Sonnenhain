extends RefCounted

# Hero body ≈64 world pixels = 2 m. Doors stay larger than the hero.
const PIXELS_PER_METRE:=32.0
const SPECS:={
	"smith":{"asset":"smith","size":Vector2(448,448),"door":Vector2(214,397),"solid":Rect2(24,220,400,154)},
	"healer":{"asset":"chapel","size":Vector2(448,448),"door":Vector2(220,417),"solid":Rect2(44,240,340,150)},
	"innkeeper":{"asset":"tavern","size":Vector2(448,448),"door":Vector2(225,394),"solid":Rect2(32,220,352,152)},
	"style":{"asset":"atelier","size":Vector2(448,448),"door":Vector2(224,414),"solid":Rect2(32,220,384,174)},
	"borin":{"asset":"skillhaus","size":Vector2(448,448),"door":Vector2(224,414),"solid":Rect2(32,220,384,174)},
	"elder":{"asset":"ratshalle","size":Vector2(448,448),"door":Vector2(224,414),"solid":Rect2(44,250,360,144)},
	"arena":{"asset":"arena","size":Vector2(1088,1088),"door":Vector2(537,980),"solid":Rect2(64,320,960,618)}
}
static var textures:Dictionary={}

static func door(p:Vector2,kind:String)->Vector2:
	if SPECS.has(kind):return p+Vector2(SPECS[kind]["door"])
	return p+Vector2(128,240) if kind=="borin" else p+Vector2(96,180)

static func bounds(p:Vector2,kind:String)->Rect2:
	if SPECS.has(kind):return Rect2(p,SPECS[kind]["size"])
	return Rect2(p+Vector2(-16,-64),Vector2(288,320) if kind=="borin" else Vector2(224,256))

static func solid(p:Vector2,kind:String)->Rect2:
	var local:Rect2=SPECS[kind]["solid"] if SPECS.has(kind) else (Rect2(12,105,232,110) if kind=="borin" else Rect2(8,73,176,75))
	return Rect2(p+local.position,local.size)

static func depth(p:Vector2,kind:String)->float:
	return solid(p,kind).end.y

static func paint(c:CanvasItem,p:Vector2,kind:String)->bool:
	if not SPECS.has(kind):return false
	if not textures.has(kind):textures[kind]=load("res://art/village/%s.png" % SPECS[kind]["asset"])
	c.draw_texture_rect(textures[kind],bounds(p,kind),false)
	return true
