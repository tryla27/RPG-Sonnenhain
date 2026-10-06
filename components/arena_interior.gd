extends RefCounted

static var texture:Texture2D
# Authored floor has a clear sand circle at 25% of its canvas width.
static func paint(c:CanvasItem,center:Vector2,radius:float)->void:
	if texture==null:texture=load("res://art/village/arena_interior.png")
	var half:=radius/0.50
	c.draw_texture_rect(texture,Rect2(center-Vector2.ONE*half,Vector2.ONE*half*2.0),false)

static func lobby(c:CanvasItem,center:Vector2,font:Font,interact_label:String)->void:
	preload("res://components/village_interiors_32.gd").paint(c,center,3,font,false,interact_label)
