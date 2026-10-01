extends RefCounted
## Reference-inspired environment rendered as geometry, with no image assets.
const House = preload("res://components/reference_house.gd")
const PixelStyle32=preload("res://components/pixel_style_32.gd")
const Hero = preload("res://components/rpg_hero.gd")
static func rect(c: CanvasItem, p: Vector2, x: float, y: float, w: float, h: float, color: String) -> void:
	PixelStyle32.rect(c,Rect2(p+Vector2(x,y),Vector2(w,h)),Color(color))

static func ground(c: CanvasItem, p: Vector2, seed_value: int) -> void:
	rect(c,p,0,0,64,64,"659349")
	for i in range(28):
		var x: int = posmod(seed_value+i*37,61)
		var y: int = posmod(seed_value/7+i*23,61)
		rect(c,p,x,y,2+posmod(i,3),2,["729f4f","587e40","88aa54","608947"][i%4])
	for i in range(3):
		var q := p+Vector2(posmod(seed_value+i*19,48),posmod(seed_value/11+i*13,48))
		grass(c,q,seed_value+i)

static func grass(c: CanvasItem, p: Vector2, key: int = 0) -> void:
	for i in range(5):
		var h: int = 3+posmod(key+i*7,7)
		rect(c,p,i*3,9-h,2,h,["456b36","709b47","96b956"][i%3])
		rect(c,p,i*3-1,8-h,2,2,"b1c76b" if i%2==0 else "789f4b")

static func flower(c: CanvasItem, p: Vector2, key: int) -> void:
	for i in range(3):
		var q := p+Vector2(i*8, posmod(key+i*3,7))
		rect(c,q,0,2,2,12,"456d39")
		rect(c,q,-4,8,5,2,"87a452")
		var col: String = ["eee6b3","d9a3c4","9e8ec1","eab35e"][posmod(key+i,4)]
		rect(c,q,-5,-2,12,3,col)
		rect(c,q,-2,-5,5,10,col)
		rect(c,q,0,-1,3,3,"f5d97b")

static func bush(c: CanvasItem, p: Vector2, key: int) -> void:
	for i in range(5):
		var q := p+Vector2((i%3-1)*15,(i/3)*11)
		House.poly(c,q,[[-17,0],[-13,-13],[-5,-18],[9,-16],[17,-6],[18,8],[6,14],[-12,10]],Color("315c3d"))
		for j in range(12):
			var x: int = posmod(key+j*17+i*11,27)-13
			var y: int = posmod(key/3+j*13,22)-13
			rect(c,q,x,y,5,3,["43784a","5c944b","87b357"][j%3])

static func tree(c: CanvasItem, p: Vector2, key: int) -> void:
	c.draw_rect(Rect2(p+Vector2(-30,4),Vector2(67,12)),Color(0.07,0.13,0.07,0.22))
	House.poly(c,p,[[-18,9],[-10,-4],[-8,-69],[10,-69],[13,-4],[24,9],[9,6],[1,0],[-7,7]],Color("593f2e"))
	rect(c,p,-5,-61,5,58,"986b3b")
	rect(c,p,3,-47,3,40,"b48c50")
	for off in [Vector2(-28,-73),Vector2(25,-84),Vector2(-3,-111),Vector2(-10,-65)]:
		var q: Vector2 = p+off
		House.poly(c,q,[[-34,-10],[-27,-32],[-13,-39],[10,-40],[31,-26],[38,-6],[29,18],[8,29],[-20,24],[-36,7]],Color("244e37"))
		for j in range(40):
			var x: int = posmod(key+j*23,57)-27
			var y: int = posmod(key/5+j*17,47)-29
			rect(c,q,x,y,5+posmod(j,3),4,["346744","4a8249","619b4d","88ad54"][j%4])
		for j in range(5):
			rect(c,q,-19+j*8,-27+posmod(j*7+key,13),7,3,"a6bf62")

static func barrel(c: CanvasItem,p:Vector2) -> void:
	House.poly(c,p,[[-13,-25],[13,-25],[17,-17],[17,10],[12,17],[-12,17],[-17,10],[-17,-17]],Color("543b2a"))
	rect(c,p,-12,-20,24,32,"936b3d")
	for x in [-9,-3,4,10]: rect(c,p,x,-20,2,34,"bd9154")
	for y in [-16,5]: rect(c,p,-16,y,32,5,"4b5351")
	rect(c,p,-10,-25,20,4,"caab70")

static func lamp(c: CanvasItem,p:Vector2) -> void:
	rect(c,p,-7,-6,14,8,"78694a")
	rect(c,p,-3,-61,6,58,"474336")
	rect(c,p,-1,-57,2,47,"b19d62")
	rect(c,p,-8,-82,16,23,"493e2d")
	rect(c,p,-5,-77,10,14,"dba55c")
	rect(c,p,-2,-76,4,12,"ffe3a1")
	House.poly(c,p,[[-10,-82],[0,-91],[10,-82]],Color("746344"))

static func fence(c:CanvasItem,a:Vector2,b:Vector2) -> void:
	var n:int=maxi(1,ceili(a.distance_to(b)/40.0))
	c.draw_line(a+Vector2(0,-23),b+Vector2(0,-23),Color("60412b"),8)
	c.draw_line(a+Vector2(0,-21),b+Vector2(0,-21),Color("bc9152"),2)
	c.draw_line(a+Vector2(0,-8),b+Vector2(0,-8),Color("775432"),6)
	for i in range(n+1):
		var q:Vector2=a.lerp(b,float(i)/n)
		rect(c,q,-5,-32,10,37,"62452c")
		rect(c,q,-3,-31,3,33,"ac7d43")
		rect(c,q,-6,-34,12,4,"c49b5b")

static func well(c:CanvasItem,p:Vector2) -> void:
	for row in range(3):
		var pts:=PackedVector2Array()
		for i in range(16):pts.append(p+Vector2(cos(i*TAU/16.0)*42,sin(i*TAU/16.0)*23+12-row*8))
		c.draw_colored_polygon(pts,Color(["5b625b","929689","b7b6a0"][row]))
	var water:=PackedVector2Array()
	for i in range(16):water.append(p+Vector2(cos(i*TAU/16.0)*28,sin(i*TAU/16.0)*14-4))
	c.draw_colored_polygon(water,Color("334c51"))
	for i in range(6):rect(c,p,-34+i*13,6,2,17,"6e766b")
	for side in [-1,1]:
		rect(c,p,side*33-4,-66,8,76,"60452e")
		rect(c,p,side*33-2,-65,2,65,"b58b54")
	c.draw_line(p+Vector2(-37,-65),p+Vector2(37,-42),Color("74502e"),9)
	c.draw_line(p+Vector2(-37,-68),p+Vector2(37,-45),Color("c7a165"),3)
	rect(c,p,0,-55,2,44,"bfa478")
	rect(c,p,-6,-18,14,16,"846847")
	rect(c,p,-5,-19,12,3,"b8a689")

static func board(c:CanvasItem,p:Vector2) -> void:
	for x in [-32,28]:rect(c,p,x,-51,7,70,"6a482f")
	rect(c,p,-37,-59,79,50,"553b2b")
	rect(c,p,-31,-52,67,37,"ab8855")
	rect(c,p,-43,-66,89,10,"937044")
	rect(c,p,-41,-66,85,3,"d3ac68")
	for i in range(3):
		var q:=p+Vector2(-25+i*21,-46+(i%2)*5)
		rect(c,q,0,0,16,24,"e2cf98")
		for y in [5,10,15]:rect(c,q,3,y,10,2,"a88d64")

static func rock(c:CanvasItem,p:Vector2) -> void:
	House.poly(c,p,[[-20,4],[-15,-14],[-1,-22],[15,-16],[23,4],[12,16],[-12,15]],Color("717565"))
	House.poly(c,p,[[-14,-12],[-1,-18],[13,-14],[6,2],[-10,0]],Color("a9aa8b"))
	rect(c,p,-14,9,9,3,"608048")

static func wall(c:CanvasItem,face:Rect2) -> void:
	c.draw_rect(face,Color("4b5147"))
	var cols:int=ceili(face.size.x/24.0)
	var rows:int=ceili(face.size.y/16.0)
	for row in range(rows):
		for col in range(cols):
			var x:float=col*24.0
			var y:float=row*16.0
			var w:float=minf(22,face.size.x-x)
			var h:float=minf(14,face.size.y-y)
			var key:int=posmod(int(face.position.x+face.position.y)+row*7+col*13,4)
			rect(c,face.position,x,y,w,h,["8d907c","a3a08a","777e6c","929782"][key])
			rect(c,face.position,x+1,y+1,maxf(1,w-2),2,"b7b49b")
			if key==0 and w>8: rect(c,face.position,x+3,y+9,7,3,"608044")

static func gatepost(c:CanvasItem,p:Vector2) -> void:
	wall(c,Rect2(p-Vector2(39,39),Vector2(78,78)))
	rect(c,p,-43,-45,86,13,"b5ad93")
	rect(c,p,-28,-27,56,67,"294e75")
	rect(c,p,-28,-27,3,65,"e2b965")
	rect(c,p,25,-27,3,65,"e2b965")
	c.draw_circle(p+Vector2(0,0),10,Color("e8bc58"))
	for i in range(8):
		var ray:Vector2=Vector2.RIGHT.rotated(i*TAU/8.0)
		c.draw_line(p+ray*15,p+ray*22,Color("e8bc58"),3)

static func waystone(c:CanvasItem,p:Vector2,active:bool) -> void:
	for step in range(3):
		var radius:float=75-step*5
		var pts:=PackedVector2Array()
		for i in range(16):pts.append(p+Vector2(cos(i*TAU/16.0)*radius,sin(i*TAU/16.0)*radius*0.62+22-step*4))
		c.draw_colored_polygon(pts,Color(["555f5e","8d9690","c1c4ac"][step]))
	for i in range(12):
		var ray:=Vector2(cos(i*TAU/12.0),sin(i*TAU/12.0)*0.62)
		c.draw_line(p+ray*39+Vector2(0,14),p+ray*67+Vector2(0,14),Color("78847c"),2)
	rect(c,p,-26,-7,52,31,"4a6266")
	rect(c,p,-20,-11,40,30,"819b9b")
	House.poly(c,p,[[0,-68],[22,-34],[0,4],[-22,-34]],Color("458a9c"))
	House.poly(c,p,[[0,-62],[14,-33],[0,-4],[-14,-33]],Color("77dbea" if active else "83bdc1"))
	House.poly(c,p,[[0,-57],[0,-9],[-10,-33]],Color("d5ffed"))
	for side in [-1,1]:lamp(c,p+Vector2(side*58,13))

static func person(c:CanvasItem,p:Vector2,kind:int,race:int,gender:int,look:Vector2,phase:float,scale_factor:float=1.0,camera_offset:Vector2=Vector2.ZERO,roll:float=-1.0,roll_dir:Vector2=Vector2.RIGHT) -> void:
	if kind <= 2:
		Hero.paint(c,p,kind,race,gender,look,phase,scale_factor,camera_offset,roll,roll_dir)
		return
	var skin:String=["d5a576","80a168","9eaeb2"][clampi(race,0,2)]
	var outfit:String=["68859a","74659c","58814b","87614b","a9825a","557f7a","d9c39a","716087"][posmod(kind,8)]
	# Preserve the caller's existing attack/weapon code; this paints the body only.
	var q:Vector2=p+Vector2(-24,-38)*scale_factor
	c.draw_set_transform(q+camera_offset,0,Vector2.ONE*scale_factor)
	var stride:int=int(sin(phase)*3)
	rect(c,Vector2.ZERO,10,44+stride,11,13,"4b3b34")
	rect(c,Vector2.ZERO,27,44-stride,11,13,"4b3b34")
	rect(c,Vector2.ZERO,8,53+stride,14,5,"716048")
	rect(c,Vector2.ZERO,27,53-stride,15,5,"716048")
	House.poly(c,Vector2.ZERO,[[9,25],[38,25],[43,45],[36,48],[12,48],[5,44]],Color(outfit))
	rect(c,Vector2.ZERO,12,28,7,17,Color(outfit).lightened(0.2).to_html(false))
	rect(c,Vector2.ZERO,10,44,28,4,"795b38")
	rect(c,Vector2.ZERO,23,44,5,4,"dfbb69")
	rect(c,Vector2.ZERO,2,27-stride,8,15,outfit)
	rect(c,Vector2.ZERO,39,27+stride,8,15,outfit)
	rect(c,Vector2.ZERO,3,39-stride,7,6,skin)
	rect(c,Vector2.ZERO,39,39+stride,7,6,skin)
	rect(c,Vector2.ZERO,10,6,28,22,"4b392e")
	rect(c,Vector2.ZERO,12,10,24,19,skin)
	rect(c,Vector2.ZERO,12,10,24,5,"bd8b58" if race==0 else skin)
	if look.y< -0.5:
		rect(c,Vector2.ZERO,10,7,28,22,"785236")
	else:
		var dx:int=3 if look.x>0.5 else (-3 if look.x< -0.5 else 0)
		rect(c,Vector2.ZERO,17+dx,19,3,4,"302e31")
		rect(c,Vector2.ZERO,28+dx,19,3,4,"302e31")
		rect(c,Vector2.ZERO,22+dx,25,6,2,"8e6048")
	if kind==1 or kind==7:
		House.poly(c,Vector2.ZERO,[[3,12],[14,2],[24,-2],[37,4],[45,12]],Color(outfit))
		rect(c,Vector2.ZERO,2,12,45,5,outfit)
		rect(c,Vector2.ZERO,17,8,18,3,"b3a2c1")
	elif kind==0:
		rect(c,Vector2.ZERO,9,4,30,9,"87989c")
		rect(c,Vector2.ZERO,13,2,22,4,"b4c2bd")
		rect(c,Vector2.ZERO,23,4,5,8,"d7b86b")
	else:
		rect(c,Vector2.ZERO,7,7,34,7,outfit)
		rect(c,Vector2.ZERO,12,3,25,6,outfit)
	if gender==1:rect(c,Vector2.ZERO,8,19,4,17,"895d38")
	c.draw_set_transform(camera_offset)
