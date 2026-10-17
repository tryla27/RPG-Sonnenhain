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

static var _single_color:=PackedColorArray([Color.WHITE])
static var _no_uv:=PackedVector2Array()

## Gefülltes Polygon wie draw_colored_polygon. Dreiecke und konvexe Vierecke
## gehen ohne Zerlegung direkt als Primitiv (~1,2 statt ~5,5 µs); alles andere
## (Fünfeck und mehr, nicht konvex, entartet) bleibt beim bisherigen Aufruf.
static func polygon(c:CanvasItem,points:PackedVector2Array,color:Color)->void:
	var count:=points.size()
	if count==3 or (count==4 and _convex_quad(points)):
		_single_color[0]=color
		c.draw_primitive(points,_single_color,_no_uv)
	else:
		c.draw_colored_polygon(points,color)

static func _convex_quad(p:PackedVector2Array)->bool:
	var sign:=0.0
	for i in 4:
		var a:=p[i];var b:=p[(i+1)%4];var d:=p[(i+2)%4]
		var cross:=(b-a).cross(d-b)
		if is_zero_approx(cross):return false
		if sign==0.0:sign=signf(cross)
		elif signf(cross)!=sign:return false
	return true
