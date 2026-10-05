extends RefCounted

const HEAD_NAMES:=["Ohne","Magnet +/−","Blitzantennen","Einzelantenne","Doppelantenne","Blitzableiter","Tesla-Spule","Radar","Energiekugel","Mechanische Hörner","Elektrokontakte"]
const BADGE_NAMES:=["Ohne","Sonne","Mond","Stern","Blatt","Flamme","Kristall","Schild","Rune","Krone","Zaubersiegel"]

class Brush:
	extends RefCounted
	var canvas:CanvasItem
	var origin:Vector2
	var factor:Vector2
	func _init(target:CanvasItem,position:Vector2,scale_value:Vector2)->void:
		canvas=target;origin=position;factor=scale_value
	func draw_rect(r:Rect2,color:Color)->void:
		canvas.draw_rect(Rect2((origin+r.position*factor).round(),(r.size*factor).round()),color)
	func draw_line(a:Vector2,b:Vector2,color:Color,width:float)->void:
		canvas.draw_line((origin+a*factor).round(),(origin+b*factor).round(),color,width*factor.y)
	func draw_colored_polygon(points:PackedVector2Array,color:Color)->void:
		var transformed:=PackedVector2Array()
		for point in points:transformed.append((origin+point*factor).round())
		canvas.draw_colored_polygon(transformed,color)

static func pixel(c:Brush,p:Vector2,size:Vector2,color:Color)->void:
	c.draw_rect(Rect2(p.round(),size),color)

static func head(target:CanvasItem,p:Vector2,look:Vector2,size:float,variant:int,color:Color)->void:
	if variant<=0:return
	var c:=Brush.new(target,p,Vector2.ONE*size)
	var q:=Vector2(look.x*2,-54)
	var metal:=Color("59616d")
	var bright:=color.lightened(0.4)
	pixel(c,q+Vector2(-8,-2),Vector2(16,3),metal)
	match variant:
		1:
			pixel(c,q+Vector2(-8,-13),Vector2(4,13),color)
			pixel(c,q+Vector2(4,-13),Vector2(4,13),Color("e87959"))
			pixel(c,q+Vector2(-8,-2),Vector2(16,4),metal)
			pixel(c,q+Vector2(-9,-17),Vector2(6,5),bright)
			pixel(c,q+Vector2(3,-17),Vector2(6,5),bright)
			pixel(c,q+Vector2(-7,-16),Vector2(2,3),metal)
			pixel(c,q+Vector2(-8,-15),Vector2(4,1),metal)
			pixel(c,q+Vector2(4,-15),Vector2(4,1),metal)
		2:
			for side in [-1,1]:
				var x:int=side*7
				for step in 4:pixel(c,q+Vector2(x+side*(step%2)*3,-5-step*5),Vector2(3,6),bright)
		3,4:
			for x in ([0] if variant==3 else [-6,6]):
				pixel(c,q+Vector2(x-1,-16),Vector2(3,16),metal)
				pixel(c,q+Vector2(x-3,-20),Vector2(7,5),bright)
		5:
			pixel(c,q+Vector2(-1,-25),Vector2(3,25),metal)
			pixel(c,q+Vector2(-7,-17),Vector2(15,3),color)
			pixel(c,q+Vector2(-4,-25),Vector2(9,3),bright)
		6:
			pixel(c,q+Vector2(-3,-20),Vector2(7,21),metal)
			for y in [-5,-10,-15]:pixel(c,q+Vector2(-7,y),Vector2(15,3),color)
			pixel(c,q+Vector2(-8,-24),Vector2(17,5),bright)
		7:
			pixel(c,q+Vector2(-2,-10),Vector2(4,11),metal)
			c.draw_colored_polygon(PackedVector2Array([q+Vector2(-12,-21),q+Vector2(12,-21),q+Vector2(5,-11),q+Vector2(-5,-11)]),color)
			pixel(c,q+Vector2(-1,-23),Vector2(3,14),bright)
		8:
			pixel(c,q+Vector2(-2,-9),Vector2(4,10),metal)
			pixel(c,q+Vector2(-6,-20),Vector2(13,11),color)
			pixel(c,q+Vector2(-4,-22),Vector2(9,15),color)
			pixel(c,q+Vector2(-3,-19),Vector2(4,4),bright)
		9:
			for side in [-1,1]:
				pixel(c,q+Vector2(side*8-2,-9),Vector2(5,10),metal)
				pixel(c,q+Vector2(side*12-2,-15),Vector2(5,9),color)
				pixel(c,q+Vector2(side*15-1,-19),Vector2(3,8),bright)
		10:
			for x in [-8,0,8]:
				pixel(c,q+Vector2(x-2,-12),Vector2(5,13),metal)
				for y in [-12,-8,-4]:pixel(c,q+Vector2(x-3,y),Vector2(7,2),color)

static func badge(target:CanvasItem,p:Vector2,look:Vector2,size:float,variant:int,color:Color)->void:
	if variant<=0 or look.y< -0.45:return
	var sideways:=absf(look.x)>0.7
	var c:=Brush.new(target,p+Vector2(look.x*4,-9)*size,Vector2(0.65 if sideways else 1.0,1.0)*size)
	pixel(c,Vector2(-5,-5),Vector2(11,11),Color("343843"))
	var bright:=color.lightened(0.45)
	match variant:
		1:
			pixel(c,Vector2(-2,-2),Vector2(5,5),bright)
			for q in [Vector2(-1,-5),Vector2(-1,4),Vector2(-5,-1),Vector2(4,-1)]:pixel(c,q,Vector2(2,2),color)
		2:
			pixel(c,Vector2(-3,-4),Vector2(6,9),bright)
			pixel(c,Vector2(0,-3),Vector2(4,6),Color("343843"))
		3:
			for row in 5:pixel(c,Vector2(-4+row,-4+row),Vector2(9-row*2,1),bright)
			pixel(c,Vector2(-1,-5),Vector2(3,10),color)
		4:
			c.draw_colored_polygon(PackedVector2Array([Vector2(-4,3),Vector2(-3,-3),Vector2(4,-4),Vector2(3,2)]),color)
			c.draw_line(Vector2(-3,3),Vector2(3,-3),bright,1)
		5:
			c.draw_colored_polygon(PackedVector2Array([Vector2(-4,3),Vector2(-3,-2),Vector2(0,0),Vector2(2,-5),Vector2(4,2),Vector2(2,4)]),Color("ef873d"))
			pixel(c,Vector2(-1,1),Vector2(3,3),Color("ffdf6a"))
		6:
			c.draw_colored_polygon(PackedVector2Array([Vector2(0,-5),Vector2(4,0),Vector2(0,5),Vector2(-4,0)]),color)
			pixel(c,Vector2(-1,-3),Vector2(2,6),bright)
		7:
			c.draw_colored_polygon(PackedVector2Array([Vector2(-4,-4),Vector2(4,-4),Vector2(3,2),Vector2(0,5),Vector2(-3,2)]),color)
			pixel(c,Vector2(-1,-3),Vector2(2,6),bright)
		8:
			pixel(c,Vector2(-1,-4),Vector2(2,9),bright)
			for y in [-3,1]:c.draw_line(Vector2(0,y),Vector2(4,y+2),color,2)
		9:
			pixel(c,Vector2(-4,1),Vector2(9,3),bright)
			for x in [-4,0,4]:pixel(c,Vector2(x,-3),Vector2(2,5),color)
		10:
			for q in [Vector2(-3,-4),Vector2(2,-4),Vector2(-4,-1),Vector2(3,-1),Vector2(-3,3),Vector2(2,3)]:pixel(c,q,Vector2(2,2),color)
			pixel(c,Vector2(-1,-1),Vector2(3,3),bright)
