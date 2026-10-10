extends RefCounted
## Geschmeidiger Waldschleim (Angelo 10.10.2026, Konzept „ikonischer erster Mob“).
##
## Laufen und Stehen zeichnen den Ruhekörper und das Blatt getrennt und verformen
## sie stufenlos statt acht Laufbilder hart zu wechseln: zusammendrücken →
## strecken → Flug → breit landen → zweimal nachfedern. Das Blatt schwingt
## verzögert mit, im Stand atmet der Schleim und das Blatt wiegt sich.
## Angriff, Treffer und Niederlage bleiben die gezeichneten Bilder
## (woodland_pose_animation.gd). Teile erzeugt tools/build_slime_parts.py.

const Sprites=preload("res://components/golden_sprite_runtime.gd")
const DIRECTIONS=["south","south_west","west","north_west","north","north_east","east","south_east"]
## Drehpunkt des Blatts im 128er-Bild je Richtung (Ausgabe von build_slime_parts.py).
const LEAF_PIVOTS:=[Vector2(64.0,58.0),Vector2(67.5,56.0),Vector2(65.5,54.0),Vector2(63.5,54.0),Vector2(63.5,51.0),Vector2(63.0,60.0),Vector2(64.0,55.0),Vector2(69.5,52.0)]
const FRAME:=128.0
const ANCHOR:=Vector2(64,104)
## Hüpfbogen: [Anteil des Sprungs, Breite, Höhe, Hub in px].
const HOP_KEYS:=[
	[0.00,1.00,1.00,0.0],
	[0.12,1.14,0.84,0.0],
	[0.24,0.90,1.14,3.0],
	[0.45,0.96,1.05,11.0],
	[0.62,0.98,1.02,4.0],
	[0.70,1.20,0.80,0.0],
	[0.80,0.94,1.07,0.0],
	[0.89,1.05,0.96,0.0],
	[1.00,1.00,1.00,0.0],
]

static func path(direction:int)->String:
	return "res://art/sprites/mobs/woodland_v3/forest_slime/parts/%s.png"%DIRECTIONS[posmod(direction,8)]

static func available(direction:int)->bool:
	return Sprites.texture(path(direction))!=null

## Breite, Höhe und Hub für den Sprunganteil t (0..1), weich interpoliert.
static func hop(t:float)->Vector3:
	t=fposmod(t,1.0)
	for i in range(HOP_KEYS.size()-1):
		var a:Array=HOP_KEYS[i]
		var b:Array=HOP_KEYS[i+1]
		if t>=float(a[0]) and t<=float(b[0]):
			var p0:Array=HOP_KEYS[maxi(0,i-1)]
			var p3:Array=HOP_KEYS[mini(HOP_KEYS.size()-1,i+2)]
			var u:=(t-float(a[0]))/maxf(0.0001,float(b[0])-float(a[0]))
			var out:=Vector3.ZERO
			for k in 3:
				out[k]=_catmull(float(p0[k+1]),float(a[k+1]),float(b[k+1]),float(p3[k+1]),u)
			out.z=maxf(0.0,out.z)
			return out
	return Vector3(1,1,0)

static func _catmull(p0:float,p1:float,p2:float,p3:float,u:float)->float:
	var u2:=u*u
	return 0.5*((2.0*p1)+(-p0+p2)*u+(2.0*p0-5.0*p1+4.0*p2-p3)*u2+(-p0+3.0*p1-3.0*p2+p3)*u2*u)

## Form im Moment: Breite, Höhe, Hub, Blattwinkel, Neigung.
static func shape(walking:bool,phase:float,clock:float,seed:float,look:Vector2)->Dictionary:
	if walking:
		var t:=fposmod(phase,TAU)/TAU
		var k:=hop(t)
		var lag:=hop(t-0.07)
		# Das Blatt folgt der Verformung verzögert (Höhe minus Breite = Streckung).
		var leaf:=(lag.y-lag.x)*1.4+(-0.25*look.x if absf(look.x)>0.3 else 0.0)*smoothstep(0.0,8.0,k.z)
		var lean:=-look.x*0.06*smoothstep(0.0,10.0,k.z)
		return {"sx":k.x,"sy":k.y,"lift":k.z,"leaf":leaf,"lean":lean}
	# Stehen: ruhiges Atmen, Blatt wiegt sich, ab und zu ein kurzes Zucken.
	var breath:=sin(clock*2.2+seed*3.0)
	var twitch:=pow(maxf(0.0,sin(clock*0.9+seed*5.0)),24.0)
	var leaf_idle:=sin(clock*1.7+seed)*0.08+twitch*0.35*sin(clock*24.0)
	return {"sx":1.0+breath*0.02,"sy":1.0-breath*0.025,"lift":0.0,"leaf":leaf_idle,"lean":0.0}

## Zeichnet Körper und Blatt. foot = Fußpunkt am Bildschirm, scale = Gesamtmaßstab.
static func draw(c:CanvasItem,foot:Vector2,direction:int,scale:Vector2,s:Dictionary,tint:Color)->bool:
	var tex:=Sprites.texture(path(direction))
	if tex==null:return false
	var sx:=float(s["sx"]);var sy:=float(s["sy"]);var lift:=float(s["lift"])
	var body_origin:=foot+Vector2(0,-lift)*scale
	var body_scale:=scale*Vector2(sx,sy)
	c.draw_set_transform(body_origin,float(s["lean"]),body_scale)
	c.draw_texture_rect_region(tex,Rect2(-ANCHOR,Vector2(FRAME,FRAME)),Rect2(0,0,FRAME,FRAME),tint)
	# Blatt am verformten Stiel, eigene Drehung, Verformung nur halb mitgenommen.
	var pivot:Vector2=LEAF_PIVOTS[posmod(direction,8)]
	var stem:=body_origin+((pivot-ANCHOR)*body_scale).rotated(float(s["lean"]))
	var leaf_scale:=scale*Vector2(1.0+(sx-1.0)*0.4,1.0+(sy-1.0)*0.4)
	c.draw_set_transform(stem,float(s["lean"])+float(s["leaf"]),leaf_scale)
	c.draw_texture_rect_region(tex,Rect2(-pivot,Vector2(FRAME,FRAME)),Rect2(FRAME,0,FRAME,FRAME),tint)
	return true
