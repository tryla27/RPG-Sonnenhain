extends RefCounted
## Shared pixel-art geometry. Tiles are 32 world units; detail pixels are 2.
const TILE_SIZE=32
const STEP=2.0
const OUTLINE=Color("182830")
static func snap(p:Vector2)->Vector2:
	return (p/STEP).round()*STEP
static func rect(c:CanvasItem,r:Rect2,col:Color,filled:bool=true,width:float=-1.0,_aa:bool=false)->void:
	var a=snap(r.position)
	var b=snap(r.end)
	var rr=Rect2(a,Vector2(maxf(STEP,b.x-a.x),maxf(STEP,b.y-a.y)))
	c.draw_rect(rr,col,filled,maxf(STEP,width) if not filled else -1.0,false)
static func line(c:CanvasItem,a:Vector2,b:Vector2,col:Color,width:float=-1.0,_aa:bool=false)->void:
	var start=snap(a)
	var finish=snap(b)
	var steps=maxi(1,ceili(maxf(absf(finish.x-start.x),absf(finish.y-start.y))/STEP))
	var size=maxf(STEP,roundf(maxf(STEP,width)/STEP)*STEP)
	for i in steps+1:
		c.draw_rect(Rect2(snap(start.lerp(finish,float(i)/steps))-Vector2.ONE*size*.5,Vector2.ONE*size),col)
static func circle(c:CanvasItem,p:Vector2,radius:float,col:Color,filled:bool=true,width:float=-1.0,_aa:bool=false)->void:
	var center=snap(p)
	var rad=maxf(STEP,roundf(radius/STEP)*STEP)
	if not filled:
		arc(c,center,rad,0,TAU,24,col,width)
		return
	for row in range(-int(rad),int(rad)+1,2):
		var half=floorf(sqrt(maxf(0,rad*rad-float(row*row)))/STEP)*STEP
		c.draw_rect(Rect2(center+Vector2(-half,row),Vector2(maxf(STEP,half*2),STEP)),col)
static func polygon(c:CanvasItem,points:PackedVector2Array,col:Color,_uv:PackedVector2Array=PackedVector2Array(),_texture:Texture2D=null)->void:
	var vertices=PackedVector2Array()
	for point in points:
		var v=snap(point)
		if vertices.is_empty() or vertices[-1]!=v:vertices.append(v)
	if vertices.size()>1 and vertices[0]==vertices[-1]:vertices.remove_at(vertices.size()-1)
	if vertices.size()>=3 and not Geometry2D.triangulate_polygon(vertices).is_empty():
		c.draw_colored_polygon(vertices,col)
static func arc(c:CanvasItem,p:Vector2,radius:float,start:float,finish:float,count:int,col:Color,width:float=1.0,_aa:bool=false)->void:
	var segments=maxi(8,count)
	for i in segments:
		var a=p+Vector2.from_angle(lerpf(start,finish,float(i)/segments))*radius
		var b=p+Vector2.from_angle(lerpf(start,finish,float(i+1)/segments))*radius
		line(c,a,b,col,width)
