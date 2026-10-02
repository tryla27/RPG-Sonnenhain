extends RefCounted
const TILE := 32
const NAMES := ["Alma","Mira","Liora","Arven","Torvald","Fenna","Pip","Elara","Borin"]
const KINDS := ["inn","elder","elder","arena","smith","style","apprentice","healer","magic"]
const ROLES := [
	"Wirtin der Steinrose · Küche & Rezepte",
	"Älteste · alle Sonnenhain-Quests",
	"Forscherin · Wissen & Quest-Hinweise",
	"Arenameister · Endlose Prüfung",
	"Schmied · Waffenmeister",
	"Stilistin · Character Editor",
	"Borins Lehrling",
	"Heilerin · Tränke & Alchemie",
	"Skillzauberer · Fähigkeiten"
]

static func id_for_name(name:String)->int:
	return NAMES.find(name)

static func name_for_id(id:int)->String:
	return NAMES[id] if id>=0 and id<NAMES.size() else ""

static func kind_for_id(id:int)->String:
	return KINDS[id] if id>=0 and id<KINDS.size() else ""

static func role_for_id(id:int)->String:
	return ROLES[id] if id>=0 and id<ROLES.size() else ""

static func blocked(pos:Vector2,center:Vector2)->bool:
	var local:=pos-center
	if absf(local.x)>438.0 or absf(local.y)>246.0:return true
	# Back wall / counters / main furniture. Keep a generous walkable center aisle.
	if Rect2(center+Vector2(-438,-246),Vector2(876,70)).has_point(pos):return true
	for r in [
		Rect2(center+Vector2(-366,-118),Vector2(118,92)),
		Rect2(center+Vector2(248,-118),Vector2(118,92)),
		Rect2(center+Vector2(-358,68),Vector2(112,74)),
		Rect2(center+Vector2(246,68),Vector2(112,74))
	]:
		if r.has_point(pos):return true
	return false

static func paint(c:CanvasItem,center:Vector2,id:int,font:Font,touch_enabled:bool,interact_label:String)->void:
	var kind:=kind_for_id(id)
	var accent:Color={
		"inn":Color("b56f52"),"elder":Color("8d78a9"),"research":Color("668da0"),
		"arena":Color("a76252"),"smith":Color("b06448"),"style":Color("b47aa0"),
		"apprentice":Color("8b7dbd"),"healer":Color("69a98b"),"magic":Color("665ca8")
	}.get(kind,Color("7d8f83"))
	var origin:=center-Vector2(448,256)
	# True 32 px floor/wall grid.
	for tx in 28:
		for ty in 16:
			var p:=origin+Vector2(tx*TILE,ty*TILE)
			var edge:=tx==0 or tx==27 or ty==0 or ty==15
			var col:=Color("3e4546") if edge else (Color("8e7657") if (tx+ty)%2==0 else Color("967e5e"))
			if kind in ["magic","research","apprentice"]: col=Color("667174") if edge else (Color("736c7f") if (tx+ty)%2==0 else Color("7e7689"))
			elif kind=="healer": col=Color("536a5f") if edge else (Color("8a8568") if (tx+ty)%2==0 else Color("938d70"))
			c.draw_rect(Rect2(p,Vector2(TILE,TILE)),col)
			c.draw_rect(Rect2(p,Vector2(TILE,TILE)),Color("252f31",0.25),false,1)
	# Back counter / shelves.
	c.draw_rect(Rect2(center+Vector2(-280,-190),Vector2(560,42)),accent.darkened(0.35))
	for x in range(-256,257,64):
		c.draw_rect(Rect2(center+Vector2(x,-180),Vector2(42,12)),accent.lightened(0.22))
	# Theme props, kept on 32px rhythm.
	match kind:
		"magic":
			for x in [-224,-160,160,224]: c.draw_circle(center+Vector2(x,-118),12,Color("8fe9ff"))
			c.draw_arc(center+Vector2(0,32),74,0,TAU,32,Color("c1a9ff"),5)
		"apprentice":
			for x in [-220,-156,-92]: c.draw_rect(Rect2(center+Vector2(x,-126),Vector2(44,24)),Color("6d5aa6"))
			c.draw_rect(Rect2(center+Vector2(160,-110),Vector2(104,54)),Color("4b3b51"))
		"healer":
			for x in [-220,-160,-100,100,160,220]:
				c.draw_rect(Rect2(center+Vector2(x,-128),Vector2(18,30)),[Color("83c79c"),Color("8ec8d3"),Color("d8959f")][absi(int(x/60))%3])
			for x in [-208,-144,144,208]: c.draw_circle(center+Vector2(x,96),16,Color("6f9e62"))
		"style":
			for x in [-250,-170,170,250]:
				c.draw_rect(Rect2(center+Vector2(x,-132),Vector2(48,72)),Color("5a4654"))
				c.draw_rect(Rect2(center+Vector2(x+7,-124),Vector2(34,48)),accent.lightened(0.28))
			c.draw_rect(Rect2(center+Vector2(-54,40),Vector2(108,54)),Color("cab493"))
		"smith":
			# Torvalds Verkauf ist klar links gebündelt: Esse, Verkaufstisch und Waffenständer.
			c.draw_rect(Rect2(center+Vector2(-300,-132),Vector2(116,86)),Color("533d37"))
			c.draw_circle(center+Vector2(-242,-88),30,Color("ef8c4c"))
			c.draw_rect(Rect2(center+Vector2(-310,18),Vector2(214,54)),Color("4d382f"))
			c.draw_rect(Rect2(center+Vector2(-302,24),Vector2(198,12)),accent.lightened(0.18))
			for x in [-276,-230,-184,-138]:
				c.draw_line(center+Vector2(x,6),center+Vector2(x+18,-38),Color("d5d9ce"),5)
				c.draw_line(center+Vector2(x-5,-14),center+Vector2(x+15,-8),Color("d4aa66"),3)
			c.draw_rect(Rect2(center+Vector2(172,-112),Vector2(72,24)),Color("3e484c"))
			c.draw_line(center+Vector2(184,-126),center+Vector2(224,-78),Color("d6b46f"),6)
		"research":
			for x in [-246,-182,-118,118,182,246]: c.draw_rect(Rect2(center+Vector2(x,-132),Vector2(40,76)),Color("4b4d55"))
			c.draw_circle(center+Vector2(0,54),42,Color("5a6f7a"))
			c.draw_arc(center+Vector2(0,54),34,0,TAU,24,Color("b9e4e7"),3)
		"elder":
			c.draw_rect(Rect2(center+Vector2(-176,-18),Vector2(352,70)),Color("5b493e"))
			for x in [-144,-48,48,144]: c.draw_rect(Rect2(center+Vector2(x,58),Vector2(48,30)),Color("684f42"))
		"arena":
			for x in [-240,-180,180,240]:
				c.draw_line(center+Vector2(x,-122),center+Vector2(x+24,-68),Color("c9cfc6"),5)
			c.draw_rect(Rect2(center+Vector2(-170,52),Vector2(340,22)),Color("6d4a37"))
		"inn":
			for y in [-40,80]:
				c.draw_rect(Rect2(center+Vector2(-270,y),Vector2(210,46)),Color("684e3b"))
				c.draw_rect(Rect2(center+Vector2(60,y),Vector2(210,46)),Color("684e3b"))
			c.draw_circle(center+Vector2(-330,-112),34,Color("ef9855",0.8))
	# Exit door.
	c.draw_rect(Rect2(center+Vector2(-32,202),Vector2(64,54)),Color("3d3029"))
	c.draw_rect(Rect2(center+Vector2(-26,208),Vector2(52,48)),accent.darkened(0.45))
	var title:="Mira & Liora · Ratshaus · Quests & Wissen" if name_for_id(id) in ["Mira","Liora"] else "%s · %s" % [name_for_id(id),role_for_id(id)]
	c.draw_string(font,center+Vector2(-320,-220),title,HORIZONTAL_ALIGNMENT_CENTER,640,18,Color("ffe8b4"))
	c.draw_string(font,center+Vector2(-130,238),("%s · ZURÜCK" % ("AKTION" if touch_enabled else interact_label)),HORIZONTAL_ALIGNMENT_CENTER,260,13,Color("fff0c9"))
