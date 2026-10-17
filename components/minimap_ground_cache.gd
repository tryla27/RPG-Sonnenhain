extends RefCounted
## Feste Geländefarben der Minimap. Das 21×21-Feld wird als kleines Bild
## gezeichnet und nur neu gefüllt, wenn sich Ausschnitt oder Nebel ändern
## (vorher 441 Rechtecke und Nebelabfragen je Bild). Marker bleiben ungecacht.
const Ground=preload("res://components/start_tilemap_32.gd")
const CELL:=64.0
const LIMIT:=4096
const PALETTE=[Color("699b73"),Color("7da66b"),Color("365b50"),Color("535b61"),Color("355a68"),Color("755045"),Color("b7a578"),Color("48415c"),Color("52696a"),Color("a48a52"),Color("477579"),Color("575b73"),Color("6e6384")]
var colors:Dictionary={}
var evaluations:=0
const GRID:=21
var image:Image
var texture:ImageTexture
var painted_key:Array=[]
## Wie oft das Feld neu gefüllt wurde (Prüfwerkzeuge).
var refills:=0

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
	var fog_version:Variant=g.world_fog.get("version")
	var key:=[start,radius,fog_version]
	if texture==null or key!=painted_key or fog_version==null:
		if image==null:image=Image.create(GRID,GRID,false,Image.FORMAT_RGBA8)
		for gx in GRID:
			for gy in GRID:
				image.set_pixel(gx,gy,visible_color(g,start+Vector2(gx+.5,gy+.5)*radius*2.0/GRID))
		if texture==null:texture=ImageTexture.create_from_image(image)
		else:texture.update(image)
		painted_key=key;refills+=1
	# Gleiche Zellgrenzen wie die früheren Einzelrechtecke (Pixelfilter).
	g.draw_texture_rect(texture,inset,false)
