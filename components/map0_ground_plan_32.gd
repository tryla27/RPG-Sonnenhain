extends RefCounted
## Authoritative 32px ground plan for Map 0. Runtime and World Builder share this.
const TILE:=32
const BOUNDS:=Rect2(0,0,1780,2600)
const GRID:=Vector2i(56,82)

const CHUNKS:={
	"NW":{"name":"Nordwest","cells":Rect2i(0,0,28,27)},
	"NO":{"name":"Nordost","cells":Rect2i(28,0,28,27)},
	"MW":{"name":"Mitte West","cells":Rect2i(0,27,28,27)},
	"MO":{"name":"Mitte Ost","cells":Rect2i(28,27,28,27)},
	"SW":{"name":"Suedwest","cells":Rect2i(0,54,28,28)},
	"SO":{"name":"Suedost","cells":Rect2i(28,54,28,28)},
}
const CHUNK_ORDER:=["NW","MW","MO","NO","SW","SO"]

const PLAZA:=Rect2(384,608,896,832)
const CRYSTAL_PLAZA:=Rect2(1328,576,384,352)
const ARENA_YARD:=Rect2(544,1440,1088,1088)
const PROPERTY_PADS:=[
	Rect2(64,608,512,480),
	Rect2(64,1088,512,480),
	Rect2(64,1856,512,480),
	Rect2(64,128,512,480),
	Rect2(1216,32,512,480),
	Rect2(1056,928,480,480),
	Rect2(544,1440,1088,936)
]
const GARDENS:=[
	Rect2(416,640,192,192),
	Rect2(1056,640,192,192),
	Rect2(416,1216,224,192),
	Rect2(1024,1216,224,192)
]
const EAST_GATE:=Vector2(1780,1120)
const SOUTH_GATE:=Vector2(875,2600)

static func center(cell:Vector2i)->Vector2:
	# Edge cells are clipped by the non-multiple-of-32 Map-0 bounds.
	# Use the center of the visible cell fragment so the final row/column
	# remain inside BOUNDS instead of producing sample points outside the map.
	var tile_rect:Rect2=Rect2(Vector2(cell*TILE),Vector2.ONE*TILE)
	var clipped:Rect2=tile_rect.intersection(BOUNDS)
	return clipped.get_center() if clipped.has_area() else tile_rect.get_center()

static func chunk_id(cell:Vector2i)->String:
	for id in CHUNK_ORDER:
		if Rect2i(CHUNKS[id]["cells"]).has_point(cell):return id
	return ""

static func in_bounds(cell:Vector2i)->bool:
	return cell.x>=0 and cell.y>=0 and cell.x<GRID.x and cell.y<GRID.y

static func is_gate_corridor(cell:Vector2i)->bool:
	var p:=center(cell)
	var east:=Rect2(EAST_GATE-Vector2(224,128),Vector2(256,256))
	var south:=Rect2(SOUTH_GATE-Vector2(144,224),Vector2(288,256))
	return east.has_point(p) or south.has_point(p)

static func is_property(cell:Vector2i)->bool:
	var p:=center(cell)
	for rect in PROPERTY_PADS:
		if rect.has_point(p):return true
	return false

static func is_garden(cell:Vector2i)->bool:
	var p:=center(cell)
	for rect in GARDENS:
		if rect.has_point(p):return true
	return false

static func edge_distance(p:Vector2)->float:
	return minf(minf(p.x,p.y),minf(BOUNDS.end.x-p.x,BOUNDS.end.y-p.y))

static func seed_at(cell:Vector2i)->int:
	return posmod(cell.x*97+cell.y*173+cell.x*cell.y*13,8191)

static func material_for(cell:Vector2i,route_distance:float)->String:
	if not in_bounds(cell):return ""
	var p:=center(cell)
	var seed:=seed_at(cell)
	# Gate approaches are always readable, solid traffic axes.
	if is_gate_corridor(cell):
		return "village_stone" if route_distance<88.0 else "earth_path"
	# Special authored yards replace the old large overlay rectangles.
	if CRYSTAL_PLAZA.has_point(p):
		if seed%11==0:return "arcane_floor"
		if seed%4==0:return "old_cobble"
		return "village_stone"
	if ARENA_YARD.has_point(p):
		return "village_stone" if seed%5==0 else ("earth_path" if seed%4==0 else "old_cobble")
	if PLAZA.has_point(p) and not is_garden(cell):
		if route_distance<92.0:return "village_stone"
		return "old_cobble" if seed%7==0 else "village_stone"
	if is_property(cell):
		if route_distance<60.0:return "village_stone"
		return "old_cobble" if seed%4==0 else "earth_path"
	# Roads are native 32px materials, never legacy canvas fills.
	if route_distance<50.0:return "village_stone"
	if route_distance<88.0:return "earth_path"
	# Wall/nature bands and calm meadow clusters.
	var edge:=edge_distance(p)
	if edge<72.0:return "grass_moss"
	if edge<144.0 and seed%3!=0:return "forest_floor"
	if seed%29 in [0,1]:return "forest_floor"
	if seed%17 in [0,1,2]:return "grass_moss"
	return "grass_meadow"

static func legacy_overlay_expected()->int:
	# Ground pass is complete only when runtime no longer needs rectangle fills.
	return 0

static func chunk_summary(id:String)->Dictionary:
	if not CHUNKS.has(id):return {}
	var rect:Rect2i=CHUNKS[id]["cells"]
	return {"id":id,"name":CHUNKS[id]["name"],"cells":rect.size.x*rect.size.y,"rect":rect}
