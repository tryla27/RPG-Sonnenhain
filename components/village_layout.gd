extends RefCounted
const H = preload("res://components/reference_house.gd")
# Replacement art is ready: compact crowns stay outside all building rectangles.
const TREES := [Vector2(672,320),Vector2(1056,208),Vector2(48,736),Vector2(64,1776),Vector2(384,2544)]
const BUSHES := [Vector2(1232,848),Vector2(1552,944)]
const FLOWER_BUSHES := [Vector2(64,80),Vector2(208,112),Vector2(416,96),Vector2(144,1728),Vector2(288,1760),Vector2(416,1728),Vector2(80,2544),Vector2(192,2496),Vector2(1712,48),Vector2(1552,48),Vector2(1408,48),Vector2(1744,656),Vector2(1488,864)]
const FENCES := [Vector2(350,1700),Vector2(1256,2576),Vector2(1460,2576)]
const BOARD := Vector2(688,1248)
# 32px-Top-down-Dorf: Gebäude liegen in klaren Grundstücksblöcken um den
# zentralen Platz. Die größeren Abstände orientieren sich am neuen World-Board,
# ohne die bestehende Regionsgrenze oder Hausrenderer umzubauen.
const SHOPS := [
	{"name":"Liora","house":Vector2(1088,960),"kind":"elder","sign":"RATSHALLE","cart":Vector2(1498,1376),"shared_with":"Mira"},
	{"name":"Fenna","house":Vector2(96,640),"kind":"style","sign":"ATELIER","cart":Vector2(288,896)},
	{"name":"Elara","house":Vector2(96,1152),"kind":"healer","sign":"HEILHAUS","cart":Vector2(288,1376)},
	{"name":"Alma","house":Vector2(96,1888),"kind":"innkeeper","sign":"STEINROSE","cart":Vector2(288,1824)},
	{"name":"Mira","house":Vector2(1088,960),"kind":"elder","sign":"RAT & QUESTS","cart":Vector2(1498,1376)},
	{"name":"Pip","house":Vector2(1248,64),"kind":"apprentice","sign":"GEHILFE","cart":Vector2(1440,608),"shared_with":"Borin"},
	{"name":"Torvald","house":Vector2(96,160),"kind":"smith","sign":"SCHMIEDE","cart":Vector2(672,528)},
	{"name":"Arven","house":Vector2(544,1440),"kind":"arena","sign":"ARENA","cart":Vector2(1480,2500),"large":true},
	{"name":"Borin","house":Vector2(1248,64),"kind":"borin","sign":"BORINS SKILLHAUS","cart":Vector2(1440,608)}
]
static func plaza(c: CanvasItem) -> void:
	c.draw_rect(Rect2(384,608,896,832),Color("697563"))
	c.draw_rect(Rect2(400,624,864,800),Color("b2ae90"))
	for row in 26:
		for col in 27:
			var x: int = 406+col*32+(16 if row%2 else 0)
			if x>1240: continue
			var y: int = 630+row*31
			var key: int = (row*13+col*7)%5
			c.draw_rect(Rect2(x,y,30,28),Color(["a7ab8f","b4b69a","c1bda1","a1a58b","b8b398"][key]))
			c.draw_rect(Rect2(x+1,y,28,2),Color("d4c9aa"))
			if key==0: c.draw_line(Vector2(x+8,y+7),Vector2(x+13,y+15),Color("90977c"),1)

static func details(c: CanvasItem, shop: Dictionary, font: Font, include_cart: bool=true) -> void:
	var p: Vector2 = shop["house"]
	var kind: String = shop["kind"]
	var color: Color = Color("527d75") if kind in ["healer","alchemy","research"] else Color("956343")
	for stripe in 8:
		c.draw_rect(Rect2(p+Vector2(22+stripe*18,87),Vector2(18,11)),color if stripe%2 else Color("e2cfa4"))
	c.draw_rect(Rect2(p+Vector2(32,86),Vector2(129,18)),Color("3d3930"))
	c.draw_rect(Rect2(p+Vector2(34,88),Vector2(125,14)),Color("6a523c"))
	c.draw_string(font,p+Vector2(39,99),shop["sign"],HORIZONTAL_ALIGNMENT_CENTER,116,10,Color("f3deb0"))
	if kind == "smith":
		for brick in 4: c.draw_rect(Rect2(p+Vector2(137,24+brick*8),Vector2(18,7)),Color("695452"))
		c.draw_rect(Rect2(p+Vector2(124,126),Vector2(34,10)),Color("303d45"))
		c.draw_line(p+Vector2(133,117),p+Vector2(151,129),Color("c9ab6b"),4)
	elif kind == "healer":
		c.draw_rect(Rect2(p+Vector2(135,105),Vector2(8,26)),Color("eae6c8"))
		c.draw_rect(Rect2(p+Vector2(126,114),Vector2(26,8)),Color("eae6c8"))
	elif kind == "alchemy":
		for bottle in 3:
			c.draw_rect(Rect2(p+Vector2(128+bottle*9,112),Vector2(7,11)),Color(["91c87b","cb7881","89c6d6"][bottle]))
	if include_cart: cart(c,shop["cart"],kind)

static func cart(c: CanvasItem,p: Vector2,kind: String) -> void:
	c.draw_rect(Rect2(p+Vector2(-47,16),Vector2(99,9)),Color(0.1,0.15,0.1,0.22))
	for side in [-1,1]:
		c.draw_circle(p+Vector2(side*35,12),12,Color("343c37"))
		c.draw_circle(p+Vector2(side*35,12),8,Color("a4824e"))
		c.draw_line(p+Vector2(side*35-7,12),p+Vector2(side*35+7,12),Color("5c4832"),2)
		c.draw_line(p+Vector2(side*35,5),p+Vector2(side*35,19),Color("5c4832"),2)
	c.draw_rect(Rect2(p+Vector2(-44,-21),Vector2(88,34)),Color("58432f"))
	for plank in 7:
		c.draw_rect(Rect2(p+Vector2(-40+plank*12,-18),Vector2(10,27)),Color("a27a43") if plank%2 else Color("b58b50"))
	c.draw_rect(Rect2(p+Vector2(-46,-23),Vector2(92,5)),Color("d1af71"))
	c.draw_line(p+Vector2(43,8),p+Vector2(68,23),Color("755839"),5)
	for item in 4:
		var q := p+Vector2(-32+item*20,-24)
		match kind:
			"alchemy","healer":
				c.draw_rect(Rect2(q+Vector2(4,-17),Vector2(6,5)),Color("cdb894"))
				c.draw_rect(Rect2(q+Vector2(2,-12),Vector2(11,18)),Color("79b5a9") if kind=="healer" else Color(["bd656c","8eba6b","6da8c6","bb95bf"][item]))
				c.draw_rect(Rect2(q+Vector2(4,-9),Vector2(3,9)),Color("d7ecd2"))
			"smith","arena","watch":
				c.draw_line(q+Vector2(4,4),q+Vector2(12,-27),Color("d5dcce"),4)
				c.draw_line(q+Vector2(0,-2),q+Vector2(13,3),Color("cfac66"),3)
				c.draw_line(q+Vector2(2,4),q+Vector2(0,12),Color("664939"),4)
			"merchant":
				c.draw_rect(Rect2(q+Vector2(0,-16),Vector2(16,26)),Color(["929978","bc9975","7e9aa2","9a7e9f"][item]))
				c.draw_rect(Rect2(q+Vector2(3,-16),Vector2(10,4)),Color("d8c295"))
				c.draw_line(q+Vector2(0,-2),q+Vector2(16,-2),Color("624b34"),2)
			_:
				c.draw_rect(Rect2(q+Vector2(0,-15),Vector2(15,24)),Color("e0cf9a"))
				for line in 4: c.draw_rect(Rect2(q+Vector2(3,-11+line*4),Vector2(9,1)),Color("927c50"))
