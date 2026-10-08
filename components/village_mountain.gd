extends RefCounted
const Catalog=preload("res://components/terrain/terrain_catalog_32.gd")
const LEVELS:=6
const STEP_HEIGHT:=16.0
const CENTER:=Vector2(304,180)
const SUMMIT:=Vector2(248,170)
# Authored nested contours: broad lower spurs and a summit shifted northwest.
const TERRACES:=[
	[Vector2(56,144),Vector2(80,88),Vector2(160,52),Vector2(268,42),Vector2(360,66),Vector2(414,100),Vector2(494,128),Vector2(548,180),Vector2(522,224),Vector2(458,244),Vector2(414,280),Vector2(312,308),Vector2(244,292),Vector2(172,300),Vector2(124,252),Vector2(80,228),Vector2(44,188)],
	[Vector2(98,150),Vector2(104,108),Vector2(166,86),Vector2(242,76),Vector2(318,86),Vector2(356,112),Vector2(422,132),Vector2(482,174),Vector2(468,210),Vector2(406,226),Vector2(370,258),Vector2(302,280),Vector2(246,262),Vector2(190,272),Vector2(158,232),Vector2(110,214),Vector2(88,182)],
	[Vector2(136,154),Vector2(140,130),Vector2(178,110),Vector2(230,100),Vector2(298,106),Vector2(326,132),Vector2(384,146),Vector2(430,176),Vector2(416,206),Vector2(368,212),Vector2(338,238),Vector2(292,252),Vector2(248,232),Vector2(206,244),Vector2(178,210),Vector2(146,202),Vector2(128,174)],
	[Vector2(166,154),Vector2(172,138),Vector2(204,126),Vector2(240,124),Vector2(280,132),Vector2(308,146),Vector2(346,164),Vector2(368,190),Vector2(344,210),Vector2(306,218),Vector2(278,214),Vector2(250,202),Vector2(218,218),Vector2(200,190),Vector2(172,186),Vector2(160,170)],
	[Vector2(192,150),Vector2(206,144),Vector2(240,142),Vector2(270,150),Vector2(298,164),Vector2(314,182),Vector2(302,200),Vector2(274,202),Vector2(254,192),Vector2(228,202),Vector2(216,184),Vector2(196,178),Vector2(186,164)],
	[Vector2(214,156),Vector2(236,154),Vector2(256,156),Vector2(274,170),Vector2(284,184),Vector2(270,190),Vector2(252,182),Vector2(234,188),Vector2(226,176),Vector2(214,174),Vector2(208,166)]
]
const BOUNDS:=Rect2(24,-32,560,356)
static var contours:Array[PackedVector2Array]=[]
static var grass:Texture2D
static var texture:Texture2D
const TEXTURE_PATH:="res://art/terrain/gba_v1/village_mountain.png"
const TEXTURE_RECT:=Rect2(0,-64,600,432)

static func prepare()->void:
	if not contours.is_empty():return
	for points in TERRACES:contours.append(PackedVector2Array(points))

static func height_at(p:Vector2)->float:
	prepare()
	for level in range(LEVELS-1,-1,-1):
		if Geometry2D.is_point_in_polygon(p,contours[level]):return (level+1)*STEP_HEIGHT
	return 0.0

static func paint(c:CanvasItem)->void:
	if texture==null:texture=load(TEXTURE_PATH)
	c.draw_texture_rect(texture,TEXTURE_RECT,false)

static func paint_generated(c:CanvasItem)->void:
	prepare()
	if grass==null:grass=load(Catalog.GROUND_ATLAS)
	for level in LEVELS:
		var top:=PackedVector2Array()
		var bottom:=PackedVector2Array()
		for p:Vector2 in contours[level]:
			top.append(p-Vector2(0,(level+1)*STEP_HEIGHT))
			bottom.append(p-Vector2(0,level*STEP_HEIGHT))
		c.draw_colored_polygon(bottom,Color("675b48"))
		c.draw_colored_polygon(top,Color("718047"))
		var min_y:=INF
		var max_y:=-INF
		for p:Vector2 in top:min_y=minf(min_y,p.y);max_y=maxf(max_y,p.y)
		# Existing grass pixels are clipped into the terrace, without interpolation.
		for y in range(int(min_y),int(max_y)):
			var hits:Array[float]=[]
			for i in top.size():
				var a:=top[i];var b:=top[(i+1)%top.size()]
				if (a.y<=y+0.5 and b.y>y+0.5) or (b.y<=y+0.5 and a.y>y+0.5):hits.append(a.x+(y+0.5-a.y)*(b.x-a.x)/(b.y-a.y))
			hits.sort()
			for pair in range(0,hits.size()-1,2):
				var x:=ceili(hits[pair]);var end:=floori(hits[pair+1])
				while x<end:
					var world:=Vector2i(x,y+int((level+1)*STEP_HEIGHT))
					var width:=mini(end-x,32-posmod(x,32))
					c.draw_texture_rect_region(grass,Rect2(x,y,width,1),Rect2(Vector2(Catalog.pixel_coord("village_grass",world)),Vector2(width,1)))
					x+=width
		for i in top.size():
			var a:=top[i];var b:=top[(i+1)%top.size()]
			if b.x<a.x:
				c.draw_colored_polygon(PackedVector2Array([a,b,b+Vector2(0,16),a+Vector2(0,16)]),Color("75654f") if i%3 else Color("665744"))
				# Broken rock strata, small fissures and hanging grass replace continuous rings.
				var count:=maxi(1,int(a.distance_to(b)/12))
				for detail in count:
					var p:=a.lerp(b,(detail+0.5)/float(count)).snapped(Vector2(2,2))
					var seed:=i*19+detail*11+level*7
					if seed%3!=0:
						c.draw_rect(Rect2(p+Vector2(-3,2),Vector2(8+seed%5,3)),Color("93836a"))
						c.draw_line(p+Vector2(-2,10),p+Vector2(7,12),Color("514b3b"),2,false)
					if seed%4==0:c.draw_line(p+Vector2(3,4),p+Vector2(1,11),Color("4c493c"),2,false)
					if seed%3==0:
						c.draw_rect(Rect2(p-Vector2(4,2),Vector2(10,4)),Color("819550"))
						c.draw_rect(Rect2(p+Vector2(-2,2),Vector2(4,4+seed%4)),Color("637b43"))
		# A few authored stone outcrops break the turf without covering the whole slope.
		for point:Vector2 in [contours[level][2].lerp(contours[level][3],0.5),contours[level][7].lerp(contours[level][8],0.4)]:
			rock(c,point-Vector2(0,(level+1)*STEP_HEIGHT)+Vector2(0,-3),8+level%3*2)
	for point in [Vector2(58,246),Vector2(112,280),Vector2(430,304),Vector2(530,250),Vector2(568,204)]:
		rock(c,point,5)
		c.draw_line(point+Vector2(-8,0),point+Vector2(-10,-5),Color("687e42"),2,false)
		c.draw_line(point+Vector2(-5,0),point+Vector2(-4,-8),Color("899b50"),2,false)

static func rock(c:CanvasItem,p:Vector2,size:float)->void:
	p=p.snapped(Vector2(2,2))
	var outline:=PackedVector2Array([p+Vector2(-size,2),p+Vector2(-size+2,-5),p+Vector2(-3,-size),p+Vector2(size-3,-size+2),p+Vector2(size,0),p+Vector2(size-2,4),p+Vector2(-size+3,5)])
	c.draw_colored_polygon(outline,Color("5c6053"))
	c.draw_colored_polygon(PackedVector2Array([outline[1],outline[2],outline[3],p+Vector2(4,-1),p+Vector2(-5,0)]),Color("9b9e83"))
	c.draw_line(p+Vector2(-5,2),p+Vector2(size-3,2),Color("737b60"),2,false)
