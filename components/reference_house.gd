extends Node2D
## Original procedural house, inspired by the reference's material palette.
## Local footprint 192 x 160 world units. No image textures required.
@export var roof_color := Color("a7422d")
@export var window_light := Color("ffd482")
@export var door_open := false:
	set(value):
		door_open = value
		queue_redraw()

func _ready() -> void:
	var body := StaticBody2D.new()
	body.name = "HouseCollision"
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(176, 75)
	shape.shape = rectangle
	shape.position = Vector2(96, 110.5)
	body.add_child(shape)
	add_child(body)

func _draw() -> void:
	paint(self, Vector2.ZERO, roof_color, window_light, door_open)

func get_door_position() -> Vector2:
	return to_global(Vector2(96, 158))

static func box(c: CanvasItem, p: Vector2, r: Rect2, color: String) -> void:
	c.draw_rect(Rect2(p + r.position, r.size), Color(color))

static func poly(c: CanvasItem, p: Vector2, points: Array, color: Color) -> void:
	var vertices := PackedVector2Array()
	for point in points:
		vertices.append(p + Vector2(point[0], point[1]))
	c.draw_colored_polygon(vertices, color)

static func paint(c: CanvasItem, p: Vector2, roof: Color = Color("a7422d"), light: Color = Color("ffd482"), opened: bool = false) -> void:
	# Shadow and stepped stone foundation.
	c.draw_rect(Rect2(p + Vector2(9, 149), Vector2(184, 12)), Color(0.08, 0.12, 0.08, 0.28))
	box(c,p,Rect2(12,140,170,15),"514a40")
	box(c,p,Rect2(16,140,163,5),"b5aa8d")
	for row in range(2):
		for column in range(9):
			var x: int = 17 + column * 18 + (8 if row == 1 else 0)
			if x < 171:
				box(c,p,Rect2(x,146+row*5,15,4),"8c8b78" if (column+row)%3 else "a5a08a")
	# Warm plaster with inset walls and timber beams.
	box(c,p,Rect2(17,67,159,75),"443128")
	box(c,p,Rect2(23,73,147,65),"c9b591")
	box(c,p,Rect2(26,75,140,5),"ecd8ac")
	box(c,p,Rect2(24,126,145,11),"aa9272")
	for chip in 12:
		var cx: int = 29+posmod(chip*31,133)
		var cy: int = 91+posmod(chip*17,37)
		box(c,p,Rect2(cx,cy,4,2),"dfcbaa" if chip%2 else "b29c7b")
	for x in [22,74,115,166]:
		box(c,p,Rect2(x,72,7,69),"51392a")
		box(c,p,Rect2(x,73,2,64),"8b6240")
	box(c,p,Rect2(20,82,154,7),"5e412e")
	box(c,p,Rect2(22,85,150,2),"966944")
	box(c,p,Rect2(21,132,152,7),"51392a")
	for beam in [22,74,115,166]:
		for grain in 4:
			box(c,p,Rect2(beam+3,91+grain*11,1,7),"ad7d4e")
	for x in [29,124]:
		poly(c,p,[[x,89],[x+5,89],[x+36,115],[x+36,120]],Color("725036"))
	# Large terracotta roof, staggered individual tiles, stepped silhouette.
	poly(c,p,[[5,76],[11,67],[18,67],[18,57],[28,57],[28,47],[40,47],[40,37],[55,37],[55,27],[72,27],[72,17],[90,17],[90,7],[103,7],[103,17],[120,17],[120,27],[138,27],[138,37],[153,37],[153,47],[166,47],[166,57],[177,57],[177,67],[187,67],[190,78]],Color("4e3028"))
	for row in range(7):
		var y: int = 14 + row*9
		var half: int = 12 + row*12
		var left: int = 96-half
		var right: int = 96+half
		for x in range(left,right,14):
			var w: int = mini(13,right-x)
			var shade: float = 0.94 + float(posmod(row*7+x,5))*0.055
			c.draw_rect(Rect2(p+Vector2(x,y),Vector2(w,8)),roof*Color(shade,shade,shade,1))
			box(c,p,Rect2(x+1,y,w-1,2),"dd7850")
			box(c,p,Rect2(x,y+6,w,2),"783b2a")
			if w>5:
				box(c,p,Rect2(x+w-2,y+2,2,4),"8c3829")
	# Left roof plane softly shaded; ridge and eaves have thickness.
	poly(c,p,[[96,12],[96,76],[12,76]],Color(0.22,0.07,0.04,0.13))
	box(c,p,Rect2(7,77,182,7),"55372b")
	box(c,p,Rect2(9,77,179,2),"b57648")
	# Front gable extends over the roof with gold-brown framing.
	poly(c,p,[[44,82],[96,35],[148,82]],Color("422c23"))
	poly(c,p,[[53,78],[96,42],[139,78]],Color("bc9b70"))
	for y in range(56,80,6):
		var span: int = int((y-42)*1.15)
		box(c,p,Rect2(96-span,y,span*2,2),"987751")
	poly(c,p,[[42,81],[96,32],[99,37],[49,84]],Color("a27449"))
	poly(c,p,[[96,32],[151,81],[144,85],[95,39]],Color("795037"))
	box(c,p,Rect2(93,44,6,38),"67452e")
	box(c,p,Rect2(45,81,104,5),"523728")
	# Small glowing attic window.
	box(c,p,Rect2(84,57,24,24),"4b3226")
	c.draw_rect(Rect2(p+Vector2(87,60),Vector2(18,17)),light)
	box(c,p,Rect2(95,60,3,18),"80552d")
	box(c,p,Rect2(87,68,18,3),"80552d")
	box(c,p,Rect2(82,79,28,4),"9e784b")
	# Chimney: square cap and shaded masonry, no baked smoke.
	box(c,p,Rect2(137,28,15,31),"4e4840")
	box(c,p,Rect2(138,29,11,28),"a29b86")
	box(c,p,Rect2(136,25,18,6),"cdc4a6")
	box(c,p,Rect2(139,25,11,3),"534e46")
	for y in [36,44,52]:
		box(c,p,Rect2(138,y,11,2),"777568")
	# Front door and visible doorstep.
	box(c,p,Rect2(80,92,33,49),"3e2b23")
	box(c,p,Rect2(83,95,27,43),"a97542" if not opened else "201f23")
	if not opened:
		for x in [88,96,104]:
			box(c,p,Rect2(x,97,1,38),"79502e")
		box(c,p,Rect2(87,99,18,15),"60432b")
		box(c,p,Rect2(89,101,14,11),"d4a85b")
		box(c,p,Rect2(103,122,3,3),"f4d17a")
	box(c,p,Rect2(77,139,39,5),"c1b99d")
	box(c,p,Rect2(74,144,45,6),"9c9b88")
	box(c,p,Rect2(71,150,51,5),"c4baa0")
	# Two shuttered windows and hand-built flower boxes.
	for x in [34,128]:
		box(c,p,Rect2(x,95,27,27),"423127")
		c.draw_rect(Rect2(p+Vector2(x+4,98),Vector2(19,19)),light)
		box(c,p,Rect2(x+12,98,3,20),"80552e")
		box(c,p,Rect2(x+4,107,19,3),"80552e")
		box(c,p,Rect2(x-4,96,5,24),"6e7859")
		box(c,p,Rect2(x+27,96,5,24),"6e7859")
		box(c,p,Rect2(x-3,123,34,7),"6e432b")
		box(c,p,Rect2(x-2,123,32,2),"ab7645")
		for j in range(6):
			var fx: int = x+j*5
			box(c,p,Rect2(fx,118-j%2*3,4,6),"4c7540")
			box(c,p,Rect2(fx+1,116-j%2*3,3,3),"f3d88b" if j%2 else "d57cb0")
	# Small lamp hung beside entrance.
	box(c,p,Rect2(117,92,8,3),"483b2d")
	box(c,p,Rect2(120,95,2,5),"483b2d")
	box(c,p,Rect2(118,100,7,10),"59442b")
	box(c,p,Rect2(120,102,3,6),"ffe1a2")
