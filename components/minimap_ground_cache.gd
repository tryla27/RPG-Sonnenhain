extends RefCounted
## Feste Geländefarben der Minimap; Nebel und Marker bleiben ungecacht.
const Ground=preload("res://components/start_tilemap_32.gd")
const CELL:=64.0
const LIMIT:=4096
const PALETTE=[Color("699b73"),Color("7da66b"),Color("365b50"),Color("535b61"),Color("355a68"),Color("755045"),Color("b7a578"),Color("48415c"),Color("52696a"),Color("a48a52"),Color("477579"),Color("575b73"),Color("6e6384")]
var colors:Dictionary={}
var evaluations:=0

func color_at(g,point:Vector2)->Color:
	var cell:=Vector2i(floori(point.x/CELL),floori(point.y/CELL))
	if colors.has(cell):return colors[cell]
	# Dasselbe feste 64px-Weltraster wie die vorhandene Geländeaufteilung.
	var center:=(Vector2(cell)+Vector2.ONE*.5)*CELL
	var area:int=g.visual_region_at(center)
	var tint:Color=PALETTE[clampi(area,0,12)]
	if area==0:
		var kind:int=Ground.kind_at(center)
		if kind==2:tint=Color("a4aa91")
		elif kind==1:tint=Color("a0b47d")
	elif g.distance_to_trail(center)<110:tint=Color("d2ba86")
	if colors.size()>=LIMIT:colors.erase(colors.keys()[0])
	colors[cell]=tint;evaluations+=1
	return tint

func visible_color(g,point:Vector2)->Color:
	return color_at(g,point) if g.world_fog.explored_world(point) else Color("0b1218")

func paint(g,inset:Rect2,start:Vector2,radius:float)->void:
	for gx in 21:
		for gy in 21:
			var point:=start+Vector2(gx+.5,gy+.5)*radius*2.0/21.0
			g.draw_rect(Rect2(inset.position+Vector2(gx,gy)*inset.size/21.0,inset.size/21.0+Vector2.ONE),visible_color(g,point))
