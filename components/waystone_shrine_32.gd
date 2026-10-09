extends RefCounted
# Neue Wegsteine (Wunsch 9.10.2026): erhöhtes Steinplateau mit Treppe, Runenkreis
# und Obelisk mit schwebendem Kristall. Gilt für alle regionalen Wegsteine,
# nicht für den Spawnstein (der hat spawn_platform_32.gd).
#
# Grafik: tools/build_waystone_art.py (Plateau als Boden, Obelisk tiefensortiert).
# Hier liegen Maße, Begehbarkeit, Höhe und das Zeichnen. Alle Angaben in
# Weltpixeln relativ zum Wegstein-Punkt.

## Oberfläche: Achteck. Vorderkante y=40, sichtbare Mauer 48 px (1,5 m).
const LEFT:=-168.0
const RIGHT:=168.0
const TOP_Y:=-100.0
const FRONT_Y:=40.0
const CUT:=28.0
const HEIGHT:=48.0
const STAIR_HALF:=40.0
const STAIR_END_Y:=88.0
## Begehbarer Bereich der Treppe (etwas schmaler als gezeichnet).
const STAIR_WALK_HALF:=30.0
const FOOTPRINT:=Rect2(LEFT,TOP_Y,RIGHT-LEFT,STAIR_END_Y-TOP_Y)
const OBELISK_SOLID:=Rect2(-30,-50,60,26)
const OBELISK_FOOT:=Vector2(0,-28)
const RUNE_CENTER:=Vector2(0,-32)
const RUNE_RADIUS:=64.0
const PLATEAU_RECT:=Rect2(-184,-116,368,264)
const OBELISK_RECT:=Rect2(-36,-28-152,72,152)

static var plateau_texture:Texture2D
static var obelisk_texture:Texture2D

static func init_art()->void:
	if plateau_texture==null:plateau_texture=load("res://art/village/objects/wegstein-plateau.png")
	if obelisk_texture==null:obelisk_texture=load("res://art/village/objects/wegstein-obelisk.png")

## Draufsicht der Oberfläche (lokal).
static func on_top(local:Vector2)->bool:
	if local.x<LEFT or local.x>RIGHT or local.y<TOP_Y or local.y>FRONT_Y:return false
	for dx in [local.x-LEFT,RIGHT-local.x]:
		for dy in [local.y-TOP_Y,FRONT_Y-local.y]:
			if dx+dy<CUT:return false
	return true

static func on_stairs(local:Vector2)->bool:
	return absf(local.x)<=STAIR_WALK_HALF and local.y>=FRONT_Y-6.0 and local.y<=STAIR_END_Y+4.0

## Die Grafik zeigt die Oberfläche schon erhöht: Begeh- und Bildkoordinaten
## sind gleich, Figuren werden oben nicht zusätzlich angehoben. HEIGHT ist nur
## die sichtbare Mauerhöhe.
## Ob ein Schritt von `from` nach `target` (beide lokal) gesperrt ist.
## Hinauf und hinunter nur über die Treppe; der Obelisk ist fest.
static func blocks(target:Vector2,from:Vector2)->bool:
	if OBELISK_SOLID.has_point(target):return true
	var from_up:=on_top(from) or on_stairs(from)
	var from_inside:=FOOTPRINT.has_point(from)
	# Wer (z. B. aus einem alten Spielstand) in der Mauer steht, darf heraus.
	if from_inside and not from_up and from!=target:return false
	if not FOOTPRINT.has_point(target):
		return on_top(from) and not on_stairs(from)
	if on_stairs(target):return false
	if on_top(target):return not from_up
	return true

## Für Server und Ankunftspunkte: Fläche, auf der niemand am Boden steht.
static func occupied(local:Vector2,margin:float=0.0)->bool:
	return FOOTPRINT.grow(margin).has_point(local)

## Bodenteil (Plateau, Mauer, Treppe, Runenkreis) im statischen Bodendurchgang.
static func draw_ground(c:CanvasItem,stone:Vector2)->void:
	init_art()
	if plateau_texture==null:return
	c.draw_texture_rect(plateau_texture,Rect2(stone+PLATEAU_RECT.position,PLATEAU_RECT.size),false)

## Obelisk, Kristall und Leuchten (tiefensortiert, animiert).
static func draw_upper(c:CanvasItem,stone:Vector2,active:bool,time:float)->void:
	init_art()
	var glow:=Color("8ff0e4") if active else Color("6d8a8e")
	var pulse:=0.55+0.25*sin(time*2.2+stone.x*0.01) if active else 0.0
	# Runenkreis und Fassungen leuchten auf dem Plateau.
	if active:
		var center:=stone+RUNE_CENTER
		var ring:=PackedVector2Array()
		for k in 49:
			var a:=float(k)/48.0*TAU
			ring.append(center+Vector2(cos(a)*(RUNE_RADIUS-2),sin(a)*(RUNE_RADIUS-2)/1.35))
		c.draw_polyline(ring,Color(glow,0.35+pulse*0.4),3.0)
		for k in 8:
			var a:=float(k)*TAU/8.0+TAU/16.0
			var p:=center+Vector2(cos(a)*(RUNE_RADIUS-16),sin(a)*(RUNE_RADIUS-16)/1.35)
			c.draw_rect(Rect2(p-Vector2(3,3),Vector2(6,6)),Color(glow,0.65+pulse*0.3))
	if obelisk_texture!=null:
		c.draw_texture_rect(obelisk_texture,Rect2(stone+OBELISK_RECT.position,OBELISK_RECT.size),false)
	# Leuchtende Runenrinne im Schaft.
	var top:=stone+OBELISK_FOOT+Vector2(0,-130)
	if active:
		c.draw_rect(Rect2(top+Vector2(-2,0),Vector2(4,108)),Color(glow,0.55+pulse*0.4))
	# Schwebender Kristall über der Spitze.
	var bob:=sin(time*1.7+stone.y*0.01)*4.0 if active else 0.0
	var crystal:=stone+OBELISK_FOOT+Vector2(0,-176+bob)
	if active:
		c.draw_circle(crystal,22.0,Color(glow,0.10+pulse*0.08))
		c.draw_circle(crystal,13.0,Color(glow,0.16+pulse*0.1))
	var body:=Color("5fc3cf") if active else Color("74878a")
	var face:=Color("d8fbf2") if active else Color("a9b6b4")
	c.draw_colored_polygon(PackedVector2Array([crystal+Vector2(0,-18),crystal+Vector2(10,-2),crystal+Vector2(0,16),crystal+Vector2(-10,-2)]),Color("26343a"))
	c.draw_colored_polygon(PackedVector2Array([crystal+Vector2(0,-15),crystal+Vector2(8,-2),crystal+Vector2(0,13),crystal+Vector2(-8,-2)]),body)
	c.draw_colored_polygon(PackedVector2Array([crystal+Vector2(0,-12),crystal+Vector2(-5,-2),crystal+Vector2(0,6)]),face)
	# Schatten des Kristalls auf der Spitze.
	c.draw_rect(Rect2(stone+OBELISK_FOOT+Vector2(-6,-150),Vector2(12,3)),Color(0,0,0,0.25))
