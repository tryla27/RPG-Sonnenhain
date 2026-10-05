extends RefCounted
const TILE := 32
const ELARA_ID := 7
const ELARA_CONCEPT := "res://art/concepts/map0/elara_church_interior_32px.webp"
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

static func exit_offset(id:int)->Vector2:
	return Vector2(0,340) if id==3 else Vector2(0,210)

static func healing_field_pos(center:Vector2,id:int)->Vector2:
	return center+Vector2(0,-34) if id==ELARA_ID else Vector2(-100000,-100000)

static func furniture(id:int)->Array[Rect2]:
	# Physical objects only: carpets, healing fields and painted runes stay walkable.
	var items:Array[Rect2]=[]
	if id==3:
		for side in [-1,1]:
			for row in 6:items.append(Rect2(Vector2(side*590-42,-236+row*80),Vector2(84,32)))
		for x in [-160,160]:items.append(Rect2(x-10,-257,20,67))
		return items
	if id==ELARA_ID:
		items=[Rect2(-144,-180,288,64),Rect2(246,-124,132,154),Rect2(-366,-112,112,120)]
		for y in [72,136]:
			for x in [-330,104]:items.append(Rect2(x,y,226,46))
		return items
	items.append(Rect2(-280,-190,560,42))
	match kind_for_id(id):
		"inn":
			for y in [-40,80]:
				for x in [-270,60]:items.append(Rect2(x,y,210,46))
			items.append(Rect2(-364,-146,68,68))
		"elder":
			items.append(Rect2(-176,-18,352,70))
			for x in [-144,-48,48,144]:items.append(Rect2(x,58,48,30))
		"smith":
			items.append(Rect2(-300,-132,116,86))
			items.append(Rect2(-310,18,214,54))
			items.append(Rect2(172,-126,72,48))
		"style":
			for x in [-250,-170,170,250]:items.append(Rect2(x,-132,48,72))
			items.append(Rect2(-54,40,108,54))
		"apprentice":
			for x in [-220,-156,-92]:items.append(Rect2(x,-126,44,24))
			items.append(Rect2(160,-110,104,54))
		"magic":
			for x in [-224,-160,160,224]:items.append(Rect2(x-14,-132,28,28))
	return items

static func blocked(pos:Vector2,center:Vector2,id:int=-1,radius:float=16.0)->bool:
	var local:=pos-center
	if id==3:
		if absf(local.x)>650.0-radius or absf(local.y)>366.0-radius or local.y< -270.0+radius:return true
	else:
		if absf(local.x)>438.0-radius or absf(local.y)>246.0-radius:return true
		if local.y< -176.0+radius:return true
	for rect in furniture(id):
		if rect.grow(radius).has_point(local):return true
	return false

static func paint(c:CanvasItem,center:Vector2,id:int,font:Font,touch_enabled:bool,interact_label:String)->void:
	if id==3:
		preload("res://components/arena_interior.gd").lobby(c,center,font,"AKTION" if touch_enabled else interact_label)
		return
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
			elif kind=="healer":
				if edge: col=Color("394b49")
				elif tx>=11 and tx<=16: col=Color("c6b78f") if (tx+ty)%2==0 else Color("b9aa83")
				else: col=Color("8f866d") if (tx+ty)%2==0 else Color("989078")
			c.draw_rect(Rect2(p,Vector2(TILE,TILE)),col)
			c.draw_rect(Rect2(p,Vector2(TILE,TILE)),Color("252f31",0.25),false,1)
	# Back counter / shelves. Elara has a dedicated chapel apse instead.
	if kind!="healer":
		c.draw_rect(Rect2(center+Vector2(-280,-190),Vector2(560,42)),accent.darkened(0.35))
		for x in range(-256,257,64):
			c.draw_rect(Rect2(center+Vector2(x,-180),Vector2(42,12)),accent.lightened(0.22))
	# Theme props, kept on 32px rhythm.
	match kind:
		"magic":
			for rect in furniture(id).slice(1):c.draw_rect(Rect2(center+rect.position,rect.size),Color("4b3b51"))
			for x in [-224,-160,160,224]: c.draw_circle(center+Vector2(x,-118),12,Color("8fe9ff"))
			c.draw_arc(center+Vector2(0,32),74,0,TAU,32,Color("c1a9ff"),5)
		"apprentice":
			for x in [-220,-156,-92]: c.draw_rect(Rect2(center+Vector2(x,-126),Vector2(44,24)),Color("6d5aa6"))
			c.draw_rect(Rect2(center+Vector2(160,-110),Vector2(104,54)),Color("4b3b51"))
		"healer":
			# Elara-Kapelle nach art/concepts/map0/elara_church_interior_32px.webp.
			# Apsis und zweistufiges Podest auf echtem 32px-Rhythmus.
			c.draw_rect(Rect2(center+Vector2(-192,-208),Vector2(384,32)),Color("53645b"))
			c.draw_rect(Rect2(center+Vector2(-160,-176),Vector2(320,32)),Color("a79775"))
			c.draw_rect(Rect2(center+Vector2(-128,-144),Vector2(256,32)),Color("baa982"))
			for x in range(-128,129,32):
				c.draw_rect(Rect2(center+Vector2(x,-143),Vector2(31,31)),Color("c7b992") if int(x/32)%2==0 else Color("b8aa84"))
			# Altar mit Tuch, Heilstein und Kerzen.
			c.draw_rect(Rect2(center+Vector2(-80,-184),Vector2(160,52)),Color("5a5044"))
			c.draw_rect(Rect2(center+Vector2(-72,-180),Vector2(144,38)),Color("d9d0b5"))
			c.draw_rect(Rect2(center+Vector2(-18,-174),Vector2(36,30)),Color("8bd8cf"))
			c.draw_colored_polygon(PackedVector2Array([
				center+Vector2(0,-176),center+Vector2(18,-159),center+Vector2(0,-142),center+Vector2(-18,-159)
			]),Color("b6f2e7"))
			for x in [-62,62]:
				c.draw_rect(Rect2(center+Vector2(x-3,-200),Vector2(6,20)),Color("d3b46d"))
				c.draw_circle(center+Vector2(x,-204),7,Color("ffd98a",0.92))
				c.draw_circle(center+Vector2(x,-204),22,Color("ffd98a",0.08))
			# Heilungsfeld direkt vor dem Altar.
			var field:=healing_field_pos(center,id)
			c.draw_circle(field,58,Color("75d8c2",0.09))
			c.draw_arc(field,58,0,TAU,40,Color("91ead4",0.70),3)
			c.draw_arc(field,42,0,TAU,32,Color("d8fff2",0.42),2)
			for a in 8:
				var dir:=Vector2.RIGHT.rotated(float(a)*TAU/8.0)
				c.draw_rect(Rect2(field+dir*50-Vector2(4,4),Vector2(8,8)),Color("b8f4df",0.82))
			c.draw_rect(Rect2(field+Vector2(-4,-24),Vector2(8,48)),Color("e8fff6",0.78))
			c.draw_rect(Rect2(field+Vector2(-24,-4),Vector2(48,8)),Color("e8fff6",0.78))
			# Linke Alchemie-Nische.
			c.draw_rect(Rect2(center+Vector2(-366,-112),Vector2(112,120)),Color("4c5d55"))
			for y in [-94,-58,-22]:
				c.draw_rect(Rect2(center+Vector2(-354,y),Vector2(88,8)),Color("7a674f"))
			for p in [Vector2(-338,-106),Vector2(-306,-106),Vector2(-338,-70),Vector2(-306,-70),Vector2(-338,-34),Vector2(-306,-34)]:
				c.draw_rect(Rect2(center+p,Vector2(14,20)),Color("77b991"))
				c.draw_rect(Rect2(center+p+Vector2(3,-5),Vector2(8,7)),Color("d8d2a8"))
			# Rechtes Lager: Regal, Kisten, Fässer und Vorräte.
			c.draw_rect(Rect2(center+Vector2(246,-124),Vector2(132,154)),Color("48564f"))
			for y in [-106,-62,-18]:
				c.draw_rect(Rect2(center+Vector2(256,y),Vector2(110,9)),Color("80664a"))
			for p in [Vector2(260,-98),Vector2(310,-98),Vector2(260,-54),Vector2(310,-54)]:
				c.draw_rect(Rect2(center+p,Vector2(38,30)),Color("8b6545"))
				c.draw_rect(Rect2(center+p+Vector2(5,5),Vector2(28,4)),Color("b88a55"))
			for x in [268,334]:
				c.draw_circle(center+Vector2(x,13),18,Color("6e533c"))
				c.draw_rect(Rect2(center+Vector2(x-17,5),Vector2(34,5)),Color("a78054"))
			# Zwei Kirchenbank-Reihen, Mittelgang bleibt frei.
			for y in [72,136]:
				for x in [-330,104]:
					c.draw_rect(Rect2(center+Vector2(x,y),Vector2(226,20)),Color("6c543e"))
					c.draw_rect(Rect2(center+Vector2(x+8,y+4),Vector2(210,5)),Color("a17b53"))
					for leg in [18,190]:
						c.draw_rect(Rect2(center+Vector2(x+leg,y+20),Vector2(8,26)),Color("4d3b31"))
			# Wandkerzen entlang der Apsis.
			for x in [-224,-160,160,224]:
				c.draw_rect(Rect2(center+Vector2(x-3,-156),Vector2(6,18)),Color("806b50"))
				c.draw_circle(center+Vector2(x,-162),6,Color("ffd18a",0.9))
				c.draw_circle(center+Vector2(x,-162),20,Color("ffd18a",0.05))
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
	var title:="Mira & Liora · Rathaus · Quests & Wissen" if name_for_id(id) in ["Mira","Liora"] else ("%s · Kapelle der Heilung · Tränke & Alchemie" % name_for_id(id) if id==ELARA_ID else "%s · %s" % [name_for_id(id),role_for_id(id)])
	c.draw_string(font,center+Vector2(-320,-220),title,HORIZONTAL_ALIGNMENT_CENTER,640,18,Color("ffe8b4"))
	c.draw_string(font,center+Vector2(-130,238),("%s · ZURÜCK" % ("AKTION" if touch_enabled else interact_label)),HORIZONTAL_ALIGNMENT_CENTER,260,13,Color("fff0c9"))
