extends RefCounted
const P=preload("res://components/pixel_style_32.gd")
static func r(c:CanvasItem,p:Vector2,s:float,x:float,y:float,w:float,h:float,col:Color)->void:
	P.rect(c,Rect2(p+Vector2(x,y)*s,Vector2(w,h)*s),col)
## Legendäre Rüstungen (Entwurf 6–12): aus 3D-Modellen gerenderte Bilder,
## 64×64 je Rüstung (tools/build_armor_icons.gd).
const LEGENDARY_ARMOR:=preload("res://art/items/legendary_armor_64.png")
const LEGENDARY_BASE:=6

static func paint(c:CanvasItem,p:Vector2,kind:String,accent:Color,s:float,design:int)->void:
	var outline=Color("182830")
	if kind=="armor" and design>=LEGENDARY_BASE and design<LEGENDARY_BASE+7:
		var id:=design-LEGENDARY_BASE
		c.draw_texture_rect_region(LEGENDARY_ARMOR,Rect2(p,Vector2(32,32)*s),Rect2(id*64,0,64,64))
		return
	match kind:
		"armor":
			var col:Color=[Color("95734e"),Color("536d86"),Color("674e8c"),Color("426b55"),Color("963f40"),Color("a7aeb0")][clampi(design,0,5)]
			r(c,p,s,3,7,26,10,outline)
			r(c,p,s,8,6,16,22,outline)
			r(c,p,s,5,8,6,8,col.darkened(.15));r(c,p,s,21,8,6,8,col.darkened(.15))
			r(c,p,s,10,8,12,18,col)
			r(c,p,s,10,8,12,3,col.lightened(.25))
			r(c,p,s,13,8,6,4,Color("273c43"))
			r(c,p,s,10,22,12,3,Color("5a4939"))
			r(c,p,s,14,22,4,3,Color("d9b964"))
		"essence":
			r(c,p,s,10,2,12,5,outline)
			r(c,p,s,12,3,8,3,Color("b89859"))
			r(c,p,s,6,9,20,20,outline)
			r(c,p,s,8,9,16,18,Color("5a7a86"))
			r(c,p,s,10,13,12,12,accent.darkened(.2))
			r(c,p,s,12,15,8,8,accent.lightened(.25))
			r(c,p,s,9,10,3,10,Color("d2f3ed"))
		_:
			r(c,p,s,8,8,16,16,accent)
