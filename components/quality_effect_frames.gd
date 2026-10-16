extends RefCounted
## Kleine Effektatlanten aus den bearbeitbaren Inkscape-/Krita-Quellen.
const FRAMES={
	"feuer":preload("res://art/ui/quality_v1/vfx_fire.png"),
	"eis":preload("res://art/ui/quality_v1/vfx_frost.png"),
	"gift":preload("res://art/ui/quality_v1/vfx_poison.png"),
	"hit":preload("res://art/ui/quality_v1/vfx_hit.png")}
static func frame(age:float,duration:float=.42)->Rect2:
	return Rect2(Vector2(clampi(int(age/maxf(.001,duration)*8),0,7)*64,0),Vector2(64,64))
static func paint(c:CanvasItem,p:Vector2,age:float,element:String)->void:
	var texture:Texture2D=FRAMES.get(element,FRAMES["hit"])
	c.draw_texture_rect_region(texture,Rect2(p-Vector2(32,32),Vector2(64,64)),frame(age))
