extends RefCounted
const Hero = preload("res://components/rpg_hero.gd")
const Mobs = preload("res://components/monster_design_32.gd")
static func background(c: CanvasItem) -> void:
	# Wide painted landscape inside the existing window frame.
	c.draw_rect(Rect2(140, 110, 872, 484), Color("223e48"))
	c.draw_rect(Rect2(140, 190, 872, 150), Color("50695e"))
	c.draw_rect(Rect2(140, 295, 872, 299), Color("47664b"))
	for cloud in [Vector2(175, 152), Vector2(402, 136), Vector2(675, 163)]:
		c.draw_rect(Rect2(cloud, Vector2(95, 9)), Color("87927c"))
		c.draw_rect(Rect2(cloud + Vector2(16,-7), Vector2(50, 8)), Color("87927c"))
	c.draw_rect(Rect2(876, 143, 74, 55), Color("dfbc72"))
	c.draw_rect(Rect2(886, 133, 54, 75), Color("dfbc72"))
	c.draw_rect(Rect2(895, 148, 36, 43), Color("f5d896"))
	for ray in [Vector2(912,119),Vector2(912,217),Vector2(864,169),Vector2(961,169)]:
		c.draw_rect(Rect2(ray,Vector2(7,9)),Color("d3ba77"))
	# Distant forest silhouettes, rolling fields, and the road to Sonnenhain.
	for i in range(24):
		var x := 145.0 + i * 36.0
		var height := 25.0 + float((i * 17) % 38)
		c.draw_rect(Rect2(x,295-height,29,height+38),Color("304d45"))
		c.draw_rect(Rect2(x+6,286-height,17,12),Color("304d45"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(550,302),Vector2(595,302),Vector2(750,594),Vector2(344,594)]),Color("a7976d"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(564,302),Vector2(584,302),Vector2(686,594),Vector2(440,594)]),Color("c0af7c"))
	# A timbered tavern on the right with lit windows.
	c.draw_rect(Rect2(865,287,105,105),Color("bbab7b"))
	c.draw_rect(Rect2(859,273,117,23),Color("674536"))
	c.draw_rect(Rect2(875,259,85,17),Color("85543a"))
	for x in [870,914,961]:c.draw_rect(Rect2(x,296,7,96),Color("594d36"))
	c.draw_rect(Rect2(866,339,104,7),Color("594d36"))
	for x in [881,937]:
		c.draw_rect(Rect2(x,309,21,24),Color("f3cc72"))
		c.draw_rect(Rect2(x+9,309,3,24),Color("594d36"))
	c.draw_rect(Rect2(913,355,23,37),Color("473d30"))
	# Foreground trees frame the menu without obscuring it.
	for tree in [Vector2(161,252),Vector2(931,409),Vector2(163,435)]:
		c.draw_rect(Rect2(tree+Vector2(25,48),Vector2(13,78)),Color("69533a"))
		c.draw_rect(Rect2(tree+Vector2(8,4),Vector2(58,50)),Color("2c553e"))
		c.draw_rect(Rect2(tree+Vector2(0,20),Vector2(76,37)),Color("2c553e"))
		c.draw_rect(Rect2(tree+Vector2(13,8),Vector2(34,13)),Color("60815a"))
	for i in range(32):
		var point := Vector2(151 + (i*79)%844, 370 + (i*37)%215)
		c.draw_rect(Rect2(point,Vector2(3,4)),Color("ddc580") if i%3==0 else Color("799366"))
	Hero.paint(c,Vector2(222,403),0,0,0,Vector2.DOWN,0.0,1.1,Vector2.ZERO)
	Hero.paint(c,Vector2(904,468),1,0,1,Vector2.DOWN,0.0,1.05,Vector2.ZERO)
	Hero.paint(c,Vector2(217,504),2,0,0,Vector2.DOWN,0.0,.95,Vector2.ZERO)
	Mobs.paint(c,Vector2(176,423),0,1,Vector2.DOWN,Color("73cb88"),0.0,-1.0,.72)
	Mobs.paint(c,Vector2(975,407),1,2,Vector2.DOWN,Color("bda37a"),0.0,-1.0,.67)
	# Gentle overall shade and calm areas beneath readable text.
	c.draw_rect(Rect2(140,110,872,484),Color(0.025,0.07,0.10,.24))
	c.draw_rect(Rect2(286,166,576,173),Color(0.035,0.10,0.14,.83))
	c.draw_rect(Rect2(159,508,832,82),Color(0.035,0.10,0.14,.78))
## A small native pixel illustration for the title screen.
static func paint(canvas: CanvasItem, origin: Vector2) -> void:
	var gold := Color("d5b776")
	var shadow := Color("162c36")
	canvas.draw_rect(Rect2(origin + Vector2(4, 4), Vector2(120, 136)), Color("091b29"))
	canvas.draw_rect(Rect2(origin, Vector2(120, 136)), shadow)
	canvas.draw_rect(Rect2(origin, Vector2(120, 136)), gold, false, 2)
	canvas.draw_rect(Rect2(origin + Vector2(5, 5), Vector2(110, 126)), Color("45605a"), false, 1)
	# Stepped sun disc and eight square rays.
	canvas.draw_rect(Rect2(origin + Vector2(43, 25), Vector2(34, 25)), Color("f0c977"))
	canvas.draw_rect(Rect2(origin + Vector2(48, 20), Vector2(24, 35)), Color("f0c977"))
	canvas.draw_rect(Rect2(origin + Vector2(51, 26), Vector2(18, 20)), Color("ffe3a0"))
	for ray in [Vector2(58, 10), Vector2(58, 61), Vector2(32, 35), Vector2(83, 35), Vector2(36, 17), Vector2(80, 17), Vector2(36, 55), Vector2(80, 55)]:
		canvas.draw_rect(Rect2(origin + ray, Vector2(4, 6)), gold)
	# Layered wooded hills and a warm path toward the sun.
	canvas.draw_rect(Rect2(origin + Vector2(8, 92), Vector2(104, 30)), Color("294e47"))
	canvas.draw_rect(Rect2(origin + Vector2(16, 86), Vector2(88, 13)), Color("386359"))
	canvas.draw_rect(Rect2(origin + Vector2(48, 108), Vector2(24, 16)), Color("a79668"))
	canvas.draw_rect(Rect2(origin + Vector2(53, 94), Vector2(14, 16)), Color("c2b383"))
	for tree in [Vector2(22, 72), Vector2(88, 78), Vector2(35, 90)]:
		canvas.draw_rect(Rect2(origin + tree + Vector2(7, 13), Vector2(6, 23)), Color("6c573c"))
		canvas.draw_rect(Rect2(origin + tree + Vector2(3, 2), Vector2(22, 18)), Color("326a50"))
		canvas.draw_rect(Rect2(origin + tree + Vector2(0, 8), Vector2(28, 12)), Color("326a50"))
		canvas.draw_rect(Rect2(origin + tree + Vector2(5, 3), Vector2(12, 6)), Color("62946a"))
	# Tiny flowers and corner studs echo the existing golden UI border.
	for flower in [Vector2(14, 111), Vector2(86, 116), Vector2(99, 103)]:
		canvas.draw_rect(Rect2(origin + flower, Vector2(3, 3)), Color("eacb8c"))
	for corner in [Vector2(0, 0), Vector2(116, 0), Vector2(0, 132), Vector2(116, 132)]:
		canvas.draw_rect(Rect2(origin + corner, Vector2(4, 4)), Color("ffe0a0"))
	# The same character and creature renderers used in the actual game.
	Mobs.paint(canvas, origin + Vector2(18, 118), 0, 1, Vector2.DOWN, Color("73cb88"), 0.0, -1.0, 0.34)
	Mobs.paint(canvas, origin + Vector2(100, 118), 1, 2, Vector2.DOWN, Color("bda37a"), 0.0, -1.0, 0.30)
	Hero.paint(canvas, origin + Vector2(42, 118), 0, 0, 0, Vector2.DOWN, 0.0, 0.38, Vector2.ZERO)
	Hero.paint(canvas, origin + Vector2(61, 119), 1, 0, 1, Vector2.DOWN, 0.0, 0.38, Vector2.ZERO)
	Hero.paint(canvas, origin + Vector2(80, 118), 2, 0, 0, Vector2.DOWN, 0.0, 0.38, Vector2.ZERO)

