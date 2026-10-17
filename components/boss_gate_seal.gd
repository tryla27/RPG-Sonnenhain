extends RefCounted
## Siegeltor an bossgesperrten Gebietstoren: Fallgitter mit leuchtendem
## Siegelmedaillon (Quelle art/source/inkscape/gates/boss_seal.svg, mit Inkscape
## gerendert). Nur Darstellung; die Sperre selbst bleibt in blocked_by_region_wall.
const TEXTURE:=preload("res://art/ui/gates/boss_seal.png")

## Zeichnet das Siegel quer über die Toröffnung (wie das bisherige Rechteck).
## Ohne draw_set_transform, damit die Kameraverschiebung des Aufrufers bleibt.
static func paint(canvas:CanvasItem,gate:Vector2,vertical:bool,half_width:float,clock:float)->void:
	var length:=half_width*2.0-78.0
	var pulse:=.88+.12*sin(clock*2.4)
	var along:=Vector2(0,1) if vertical else Vector2(1,0)
	var across:=Vector2(-1,0) if vertical else Vector2(0,1)
	var a:=along*length*.5;var b:=across*28.0
	var points:=PackedVector2Array([gate-a-b,gate+a-b,gate+a+b,gate-a+b])
	var uvs:=PackedVector2Array([Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)])
	var tint:=Color(1,1,1,pulse)
	canvas.draw_polygon(points,PackedColorArray([tint,tint,tint,tint]),uvs,TEXTURE)
