extends RefCounted
const P=preload("res://components/pixel_style_32.gd")
static func platform(c:CanvasItem,center:Vector2)->void:
	var start:Vector2=(center-Vector2(256,256)).snapped(Vector2(32,32))
	for stage in 3:
		var a:int=stage;var b:int=15-stage
		var tint:Color=[Color("647469"),Color("7b8a7b"),Color("92a08d")][stage]
		for y in range(a,b+1):
			for x in range(a,b+1):
				var q:Vector2=start+Vector2(x,y)*32-Vector2(0,stage*8)
				P.rect(c,Rect2(q+Vector2(0,26),Vector2(32,14)),tint.darkened(.3))
				P.rect(c,Rect2(q,Vector2(32,28)),tint.darkened(.15))
				P.rect(c,Rect2(q+Vector2(2,2),Vector2(28,24)),tint)
				P.rect(c,Rect2(q+Vector2(4,2),Vector2(24,2)),tint.lightened(.18))
				for n in 4:
					var key:int=x+y*13+n*7
					P.rect(c,Rect2(q+Vector2(4+posmod(key,11)*2,6+posmod(key*3,7)*2),Vector2(4,2)),tint.lightened(.1) if n%2 else tint.darkened(.14))
				if (x+y*3)%7==0:P.rect(c,Rect2(q+Vector2(2,22),Vector2(8,4)),Color("638557"))
	# Four-tile stair approach on the south side.
	for step in 3:
		for x in range(6,10):
			var q:Vector2=start+Vector2(x,15-step)*32-Vector2(0,step*8)
			P.rect(c,Rect2(q,Vector2(32,28)),Color("a3af96"))
			P.rect(c,Rect2(q+Vector2(2,2),Vector2(28,2)),Color("d1d3ad"))
			P.rect(c,Rect2(q+Vector2(0,28),Vector2(32,10)),Color("63715f"))
static func core(c:CanvasItem,p:Vector2)->void:
	for side in [-1,1]:
		var q:Vector2=p+Vector2(side*96,12)
		P.rect(c,Rect2(q+Vector2(-18,-54),Vector2(36,64)),Color("40565a"))
		P.rect(c,Rect2(q+Vector2(-12,-50),Vector2(24,54)),Color("89978a"))
		P.rect(c,Rect2(q+Vector2(-20,-58),Vector2(40,8)),Color("c9ac71"))
		P.rect(c,Rect2(q+Vector2(-4,-42),Vector2(8,24)),Color("7adbdc"))
	P.polygon(c,PackedVector2Array([p+Vector2(-48,18),p+Vector2(0,34),p+Vector2(48,18),p+Vector2(32,-12),p+Vector2(-32,-12)]),Color("334f56"))
	P.polygon(c,PackedVector2Array([p+Vector2(0,-146),p+Vector2(-40,-54),p+Vector2(-30,10),p+Vector2(0,28),p+Vector2(30,10),p+Vector2(40,-54)]),Color("49bad0"))
	P.polygon(c,PackedVector2Array([p+Vector2(0,-146),p+Vector2(-40,-54),p+Vector2(-30,10),p+Vector2(0,-12)]),Color("347e98"))
	P.polygon(c,PackedVector2Array([p+Vector2(0,-146),p+Vector2(40,-54),p+Vector2(0,-26)]),Color("a2eee7"))
	P.line(c,p+Vector2(0,-134),p+Vector2(0,14),Color("d9fff0"),4)
	P.polygon(c,PackedVector2Array([p+Vector2(0,-12),p+Vector2(22,10),p+Vector2(0,32),p+Vector2(-22,10)]),Color("dbbd78"))
	P.polygon(c,PackedVector2Array([p+Vector2(0,-4),p+Vector2(12,10),p+Vector2(0,24),p+Vector2(-12,10)]),Color("4a96ad"))

static func height_at(pos:Vector2,center:Vector2)->float:
	var start:Vector2=(center-Vector2(256,256)).snapped(Vector2(32,32))
	var cell:Vector2i=Vector2i((pos-start)/32.0)
	if not Rect2(start,Vector2(512,512)).has_point(pos):return 0
	var inset:int=mini(mini(cell.x,cell.y),mini(15-cell.x,15-cell.y))
	return float(clampi(inset,0,2)*8)
