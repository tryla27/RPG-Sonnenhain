extends RefCounted

static var texture:Texture2D
# Authored floor has a clear sand circle at 25% of its canvas width.
static func paint(c:CanvasItem,center:Vector2,radius:float)->void:
	if texture==null:texture=load("res://art/village/arena_interior.png")
	var half:=radius/0.50
	c.draw_texture_rect(texture,Rect2(center-Vector2.ONE*half,Vector2.ONE*half*2.0),false)

static func lobby(c:CanvasItem,center:Vector2,font:Font,interact_label:String)->void:
	var origin:=center-Vector2(672,384)
	for row in 24:
		for column in 42:
			var point:=origin+Vector2(column,row)*32
			var edge:=row==0 or column==0 or row==23 or column==41
			c.draw_rect(Rect2(point,Vector2(32,32)),Color("615b53") if edge else Color("c99d62") if (row+column)%3==0 else Color("d6ae70"))
			c.draw_rect(Rect2(point+Vector2(2,2),Vector2(28,2)),Color("9b7e52") if edge else Color("e6c18a"))
	c.draw_rect(Rect2(center+Vector2(-640,-352),Vector2(1280,64)),Color("4e4842"))
	for x in range(-600,601,120):
		c.draw_rect(Rect2(center+Vector2(x,-342),Vector2(48,68)),Color("79282c"))
		c.draw_rect(Rect2(center+Vector2(x+4,-338),Vector2(40,7)),Color("dcad57"))
		c.draw_rect(Rect2(center+Vector2(x+18,-322),Vector2(12,24)),Color("efa94f"))
	for side in [-1,1]:
		for row in 6:
			var p:=center+Vector2(side*590,-220+row*80)
			c.draw_rect(Rect2(p-Vector2(42,16),Vector2(84,32)),Color("49372d"))
			c.draw_rect(Rect2(p-Vector2(40,14),Vector2(80,8)),Color("a77846"))
			c.draw_rect(Rect2(p+Vector2(-35,10),Vector2(70,4)),Color("714e35"))
	for x in [-160,160]:
		c.draw_rect(Rect2(center+Vector2(x-4,-240),Vector2(8,50)),Color("414048"))
		c.draw_rect(Rect2(center+Vector2(x-10,-250),Vector2(20,16)),Color("ed873c"))
		c.draw_rect(Rect2(center+Vector2(x-4,-257),Vector2(8,19)),Color("ffe78b"))
	c.draw_rect(Rect2(center+Vector2(-40,330),Vector2(80,54)),Color("49332c"))
	c.draw_rect(Rect2(center+Vector2(-32,334),Vector2(64,50)),Color("855b38"))
	c.draw_string(font,center+Vector2(-480,-305),"ARENA · ARVEN · EINGANGSHALLE",HORIZONTAL_ALIGNMENT_CENTER,960,20,Color("ffe8b4"))
	c.draw_string(font,center+Vector2(-160,364),"%s · ZURÜCK INS DORF" % interact_label,HORIZONTAL_ALIGNMENT_CENTER,320,13,Color("fff0c9"))
