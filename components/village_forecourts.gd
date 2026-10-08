extends RefCounted
## Small themed exterior objects; foot anchors leave each door approach open.
const ITEMS:=[
	{"owner":"style","item":"mannequin","point":Vector2(128,1088)},
	{"owner":"style","item":"cloth","point":Vector2(352,1088)},
	{"owner":"smith","item":"anvil","point":Vector2(64,608)},
	{"owner":"smith","item":"logs","point":Vector2(400,628)},
	{"owner":"healer","item":"herbs","point":Vector2(208,1760)},
	{"owner":"healer","item":"offering","point":Vector2(432,1760)},
	{"owner":"borin","item":"books","point":Vector2(1360,576)},
	{"owner":"borin","item":"scrolls","point":Vector2(1584,576)},
	{"owner":"elder","item":"notices","point":Vector2(1184,1480)},
	{"owner":"elder","item":"bench","point":Vector2(1438,1480)},
	{"owner":"innkeeper","item":"barrels","point":Vector2(208,2432)},
	{"owner":"innkeeper","item":"bench","point":Vector2(432,2432)},
	{"owner":"arena","item":"dummy","point":Vector2(944,2584)},
	{"owner":"arena","item":"weapons","point":Vector2(1168,2584)}
]
static func bounds(p:Vector2,kind:String="")->Rect2:
	if kind=="logs":return Rect2(p+Vector2(-28,-16),Vector2(56,24))
	return Rect2(p+Vector2(-32,-56),Vector2(64,64))
static func solid(p:Vector2)->Rect2:return Rect2(p+Vector2(-24,-8),Vector2(48,16))
static func blocked(p:Vector2,radius:float)->bool:
	for item in ITEMS:
		if solid(item["point"]).grow(radius).has_point(p):return true
	return false
static func box(c:CanvasItem,p:Vector2,r:Rect2,color:String)->void:
	c.draw_rect(Rect2(p+r.position,r.size),Color(color))
static func paint(c:CanvasItem,p:Vector2,kind:String)->void:
	box(c,p,Rect2(-26,0,52,6),"52603d")
	match kind:
		"logs":
			for row in 2:
				box(c,p,Rect2(-24+row*4,-14+row*7,46-row*4,6),"77543a")
				box(c,p,Rect2(-22+row*4,-13+row*7,42-row*4,2),"bf955f")
				box(c,p,Rect2(-24+row*4,-14+row*7,6,6),"d3b47a")
		"mannequin","dummy":
			box(c,p,Rect2(-20,0,40,6),"725338")
			box(c,p,Rect2(-3,-42,6,44),"ac8655")
			box(c,p,Rect2(-22,-32,44,6),"b49564")
			box(c,p,Rect2(-8,-54,16,14),"bfa783")
			box(c,p,Rect2(-14,-38,28,26),"917055" if kind=="dummy" else "654477")
			box(c,p,Rect2(-10,-36,8,22),"c0a87a" if kind=="dummy" else "ab789e")
			if kind=="dummy":
				c.draw_circle(p+Vector2(2,-24),8,Color("a95843"))
				c.draw_circle(p+Vector2(2,-24),4,Color("d5b07a"))
			else:box(c,p,Rect2(-19,-16,38,7),"654477")
		"anvil":
			box(c,p,Rect2(-20,-22,40,24),"765438")
			box(c,p,Rect2(-15,-24,30,5),"b38a58")
			box(c,p,Rect2(-10,-39,22,14),"545c60")
			box(c,p,Rect2(-25,-44,52,7),"a4ac9e")
			box(c,p,Rect2(-28,-42,10,4),"8d9892")
			box(c,p,Rect2(15,-30,4,20),"b29565")
			box(c,p,Rect2(11,-32,14,6),"b8beb0")
		"barrels":
			for x in [-25,3]:
				box(c,p,Rect2(x,-34,22,34),"755239")
				box(c,p,Rect2(x+3,-33,7,32),"b58a52")
				for y in [-28,-8]:box(c,p,Rect2(x,y,22,4),"495556")
				box(c,p,Rect2(x+2,-36,18,4),"c2a16a")
		"weapons":
			for x in [-24,22]:box(c,p,Rect2(x,-48,4,50),"876243")
			box(c,p,Rect2(-24,-39,50,5),"b2905e")
			for x in [-13,1,15]:
				box(c,p,Rect2(x,-49,4,32),"b4bdac")
				box(c,p,Rect2(x-3,-18,10,3),"c7a75d")
				box(c,p,Rect2(x,-15,4,11),"594334")
		"notices":
			for x in [-24,20]:box(c,p,Rect2(x,-48,4,50),"6c4c34")
			box(c,p,Rect2(-28,-52,56,34),"926b44")
			for x in [-20,-2,14]:
				box(c,p,Rect2(x,-46,12,21),"ddcca0")
				box(c,p,Rect2(x+2,-40,8,2),"8a7050")
		"offering":
			box(c,p,Rect2(-22,-24,44,26),"747c75")
			box(c,p,Rect2(-28,-30,56,8),"b0b2a1")
			box(c,p,Rect2(-16,-41,4,10),"e1cb92")
			box(c,p,Rect2(12,-39,4,8),"e1cb92")
			box(c,p,Rect2(-2,-19,4,14),"d1b469")
			box(c,p,Rect2(-7,-15,14,4),"d1b469")
		"herbs":
			box(c,p,Rect2(-28,-20,56,22),"795436")
			box(c,p,Rect2(-28,-22,56,4),"b49560")
			for x in [-18,0,18]:
				box(c,p,Rect2(x-2,-42,4,22),"657c43")
				box(c,p,Rect2(x-9,-37,8,6),"8caa60")
				box(c,p,Rect2(x+1,-33,8,6),"648b4c")
				box(c,p,Rect2(x-3,-45,6,5),"c6b4cd")
		_:
			# Low wooden table/bench, with individually readable goods.
			for x in [-24,20]:box(c,p,Rect2(x,-18,4,20),"694b34")
			box(c,p,Rect2(-28,-24,56,8),"b08a58")
			if kind=="bench":
				box(c,p,Rect2(-28,-40,56,8),"98724a")
				for x in [-24,20]:box(c,p,Rect2(x,-38,4,16),"694b34")
			elif kind=="cloth":
				for i in 3:box(c,p,Rect2(-22+i*16,-32-i%2*4,14,8),["ad789b","7b99aa","d0ae69"][i])
			elif kind=="books":
				for i in 3:
					box(c,p,Rect2(-22+i*16,-40+i%2*4,12,16),["647d8a","805c77","9b794a"][i])
					box(c,p,Rect2(-20+i*16,-38+i%2*4,2,12),"d8c49b")
			elif kind=="scrolls":
				for i in 3:
					box(c,p,Rect2(-22+i*16,-35,12,10),"ddcfaa")
					box(c,p,Rect2(-24+i*16,-36,4,12),"a9946a")
