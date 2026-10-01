extends RefCounted
# Coarse pixel geometry: one logical pixel = two game pixels, footprint 128x96.
static func box(c:CanvasItem,o:Vector2,r:Rect2,col:Color)->void:
 c.draw_rect(Rect2(o+r.position*2,r.size*2),col)
static func face(c:CanvasItem,o:Vector2,points:Array,col:Color)->void:
 var vertices=PackedVector2Array()
 for point in points:vertices.append(o+Vector2(point)*2)
 c.draw_colored_polygon(vertices,col)
static func wheel(c:CanvasItem,o:Vector2,p:Vector2,far:bool=false)->void:
 var radius:=4 if far else 6
 face(c,o,[p+Vector2(-radius,-2),p+Vector2(-2,-radius),p+Vector2(3,-radius),p+Vector2(radius,-2),p+Vector2(radius,3),p+Vector2(2,radius),p+Vector2(-3,radius),p+Vector2(-radius,2)],Color("30363a"))
 box(c,o,Rect2(p-Vector2(3,3),Vector2(7,7)),Color("8d6846"))
 box(c,o,Rect2(p-Vector2(1,1),Vector2(3,3)),Color("cbc09b"))
static func paint(c:CanvasItem,p:Vector2,kind:String)->void:
 var o:=p+Vector2(-52,-68)
 var wood:=Color("92744c");var shade:=Color("5c4b39");var trim:=Color("b39362")
 face(c,o,[Vector2(8,39),Vector2(56,39),Vector2(63,45),Vector2(13,45)],Color("223527",0.32))
 wheel(c,o,Vector2(55,32),true)
 box(c,o,Rect2(12,34,46,4),Color("3b3834"))
 # Open load floor, broad front wall and darker right end give an actual box body.
 face(c,o,[Vector2(9,23),Vector2(48,23),Vector2(60,29),Vector2(21,29)],Color("b39466"))
 face(c,o,[Vector2(21,29),Vector2(60,29),Vector2(60,38),Vector2(21,38)],wood)
 face(c,o,[Vector2(9,23),Vector2(21,29),Vector2(21,38),Vector2(9,32)],shade)
 box(c,o,Rect2(21,29,39,2),trim)
 for y in [33,36]:box(c,o,Rect2(22,y,37,1),shade)
 for x in [24,55]:box(c,o,Rect2(x,30,2,8),Color("5b6262"))
 # Goods are large, readable shapes sitting INSIDE the body on the load floor.
 match kind:
  "alchemy","healer":
   for n in 3:
    var col:Color=[Color("b96661"),Color("6cabc0"),Color("91ae6b")][n]
    box(c,o,Rect2(24+n*10,21,6,7),col)
    box(c,o,Rect2(26+n*10,18,2,4),Color("d0c7a1"))
  "smith":
   box(c,o,Rect2(24,22,15,4),Color("8c969b"))
   box(c,o,Rect2(28,25,7,3),Color("555f68"))
   for n in 3:box(c,o,Rect2(43+n*4,23-n,4,4),Color("acb3af"))
  "research","quest":
   for n in 4:
    box(c,o,Rect2(23+n*7,21-n%2,5,7),[Color("798e9d"),Color("b09866"),Color("986f73")][n%3])
    box(c,o,Rect2(24+n*7,22-n%2,1,5),Color("d3c6a3"))
  "arena","watch":
   box(c,o,Rect2(24,19,8,10),Color("6d8293"))
   box(c,o,Rect2(27,21,2,6),Color("c6b370"))
   for n in 2:
    box(c,o,Rect2(39+n*8,16,2,12),Color("8c795c"))
    box(c,o,Rect2(38+n*8,15,4,3),Color("a7b2b2"))
  _:
   for n in 3:
    box(c,o,Rect2(23+n*10,21,8,7),Color("a48257"))
    box(c,o,Rect2(24+n*10,23,6,1),shade)
    box(c,o,Rect2(26+n*10,21,1,7),trim)
 # Uprights and a clearly separated sloping canvas roof.
 for x in [18,54]:box(c,o,Rect2(x,13,2,16),shade)
 face(c,o,[Vector2(10,6),Vector2(49,6),Vector2(61,12),Vector2(22,12)],Color("c8bea0"))
 face(c,o,[Vector2(22,12),Vector2(61,12),Vector2(61,17),Vector2(22,17)],Color("ab9f82"))
 face(c,o,[Vector2(10,6),Vector2(22,12),Vector2(22,17),Vector2(10,11)],Color("ded0aa"))
 for x in [29,41,53]:box(c,o,Rect2(x,12,1,5),Color("8c846f"))
 box(c,o,Rect2(14,35,5,2),shade)
 face(c,o,[Vector2(2,39),Vector2(15,32),Vector2(16,34),Vector2(4,41)],wood)
 wheel(c,o,Vector2(25,40))
 wheel(c,o,Vector2(53,40))
 box(c,o,Rect2(37,29,8,8),Color("254356"))
 box(c,o,Rect2(40,31,2,4),Color("c1ab71"))
