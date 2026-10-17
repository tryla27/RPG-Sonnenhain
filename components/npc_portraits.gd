extends RefCounted
## Pixel-Porträts zu Meldungen bekannter Figuren („Mira: …“).
## Quelle: tools/art_pipeline/pixel_portraits.py. Nur Darstellung, keine Regeln.
const PORTRAITS:={
	"Mira":preload("res://art/ui/portraits_px/mira.png"),
	"Fenna":preload("res://art/ui/portraits_px/fenna.png"),
	"Borin":preload("res://art/ui/portraits_px/borin.png"),
}
const SIZE:=48

## Sprechername am Anfang einer Meldung, falls ein Porträt existiert, sonst "".
static func speaker(text:String)->String:
	var colon:=text.find(":")
	if colon<=0 or colon>12:return ""
	var name:=text.substr(0,colon).strip_edges()
	return name if PORTRAITS.has(name) else ""

## Porträt links über dem Hinweisfeld zeichnen; gibt true zurück, wenn gezeichnet.
static func paint(canvas:CanvasItem,notice_rect:Rect2,text:String)->bool:
	var name:=speaker(text)
	if name=="":return false
	var at:=Vector2(notice_rect.position.x,notice_rect.position.y-SIZE-4)
	canvas.draw_texture_rect(PORTRAITS[name],Rect2(at,Vector2.ONE*SIZE),false)
	return true
