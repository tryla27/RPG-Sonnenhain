extends RefCounted
## Bitmap props with consistent foot anchors, placed against their owner's facade.
const ART_PATH:="res://art/village/forecourts/v2/"
const SPECS:={
	"mannequin":{"size":Vector2i(58,104),"foot":Vector2(38,18)},
	"cloth":{"size":Vector2i(108,72),"foot":Vector2(78,24)},
	"anvil":{"size":Vector2i(92,72),"foot":Vector2(54,24)},
	"logs":{"size":Vector2i(108,56),"foot":Vector2(64,22)},
	"herbs":{"size":Vector2i(94,74),"foot":Vector2(68,22)},
	"offering":{"size":Vector2i(82,82),"foot":Vector2(54,24)},
	"books":{"size":Vector2i(82,88),"foot":Vector2(54,24)},
	"scrolls":{"size":Vector2i(92,82),"foot":Vector2(62,24)},
	"notices":{"size":Vector2i(94,104),"foot":Vector2(60,20)},
	"bench":{"size":Vector2i(112,72),"foot":Vector2(84,22)},
	"barrels":{"size":Vector2i(90,80),"foot":Vector2(64,26)},
	"dummy":{"size":Vector2i(84,112),"foot":Vector2(42,22)},
	"weapons":{"size":Vector2i(100,104),"foot":Vector2(66,22)}
}
const ITEMS:=[
	{"owner":"style","item":"mannequin","point":Vector2(140,1020)},
	{"owner":"style","item":"cloth","point":Vector2(350,1020)},
	{"owner":"smith","item":"anvil","point":Vector2(176,592)},
	{"owner":"smith","item":"logs","point":Vector2(438,592)},
	{"owner":"healer","item":"herbs","point":Vector2(184,1624)},
	{"owner":"healer","item":"offering","point":Vector2(444,1624)},
	{"owner":"borin","item":"books","point":Vector2(1360,512)},
	{"owner":"borin","item":"scrolls","point":Vector2(1584,512)},
	{"owner":"elder","item":"notices","point":Vector2(1184,1398)},
	{"owner":"elder","item":"bench","point":Vector2(1440,1398)},
	{"owner":"innkeeper","item":"barrels","point":Vector2(196,2316)},
	{"owner":"innkeeper","item":"bench","point":Vector2(442,2316)},
	{"owner":"arena","item":"dummy","point":Vector2(944,2448)},
	{"owner":"arena","item":"weapons","point":Vector2(1224,2448)}
]
static var textures:Dictionary={}
static func sprite(kind:String)->Texture2D:
	if not textures.has(kind):textures[kind]=load(ART_PATH+kind+".png")
	return textures[kind]
static func bounds(p:Vector2,kind:String="mannequin")->Rect2:
	var texture:=sprite(kind)
	var size:=Vector2(texture.get_size())
	return Rect2(p+Vector2(-size.x*0.5,-size.y+4),size)
static func solid(p:Vector2,kind:String="mannequin")->Rect2:
	var foot:Vector2=SPECS[kind]["foot"]
	return Rect2(p+Vector2(-foot.x*0.5,-foot.y*0.5),foot)
static func blocked(p:Vector2,radius:float)->bool:
	for item in ITEMS:
		if solid(item["point"],item["item"]).grow(radius).has_point(p):return true
	return false
static func paint(c:CanvasItem,p:Vector2,kind:String)->void:
	c.draw_texture_rect(sprite(kind),bounds(p,kind),false)
