extends RefCounted
## Vorgebaute Flächen für häufig gezeichnete Formen (Schatten, Kreise).
## draw_colored_polygon und draw_circle zerlegen eine Form bei jedem Aufruf neu
## in Dreiecke (gemessen ~5 µs je Aufruf); ein fertiges Netz über draw_mesh
## kostet ~0,6 µs und ergibt dieselbe Fläche. Nur Darstellung, keine Regeln.

static var _regular:Dictionary={}

## Regelmäßiges n-Eck mit Radius 1 um den Ursprung; Ecke i liegt bei Winkel
## i·TAU/n (wie die bisherigen Schattenumrisse). Fächer aus der Mitte.
static func regular(sides:int)->ArrayMesh:
	if _regular.has(sides):return _regular[sides]
	var vertices:=PackedVector2Array([Vector2.ZERO])
	for vertex in sides:vertices.append(Vector2(cos(vertex*TAU/sides),sin(vertex*TAU/sides)))
	var indices:=PackedInt32Array()
	for vertex in sides:indices.append_array([0,1+vertex,1+(vertex+1)%sides])
	var arrays:=[];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_INDEX]=indices
	var mesh:=ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	_regular[sides]=mesh
	return mesh

## Gefüllte Ellipse als n-Eck (Halbachsen radius) in color.
static func ellipse(c:CanvasItem,center:Vector2,radius:Vector2,color:Color,sides:int=12)->void:
	c.draw_mesh(regular(sides),null,Transform2D(Vector2(radius.x,0),Vector2(0,radius.y),center),color)

## Gefüllter Kreis wie draw_circle (64 Ecken, ohne Kantenglättung).
static func circle(c:CanvasItem,center:Vector2,radius:float,color:Color)->void:
	if not radius>0.0:return
	c.draw_mesh(regular(64),null,Transform2D(Vector2(radius,0),Vector2(0,radius),center),color)
