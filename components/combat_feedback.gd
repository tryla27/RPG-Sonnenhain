extends RefCounted
## Presentation only: authoritative HP and projectile damage remain untouched.
var bars:Dictionary={}
var breaks:Array=[]
var clock:=0.0
func step(delta:float)->void:
	clock+=delta
	for i in range(breaks.size()-1,-1,-1):
		breaks[i]["life"]-=delta
		if breaks[i]["life"]<=0:breaks.remove_at(i)
	for key in bars.keys():
		if clock-float(bars[key]["seen"])>8:bars.erase(key)
func health(c:CanvasItem,key:String,p:Vector2,hp:float,maximum:float,width:float=54,color:Color=Color("e57578"))->void:
	var value:=clampf(hp/maxf(maximum,1),0,1)
	var row:Dictionary=bars.get(key,{"hp":value,"trail":value,"hit":-10.0,"seen":clock})
	if value<float(row["hp"]):row["hit"]=clock
	var dt:float=maxf(0,clock-float(row["seen"]))
	row["hp"]=value;row["seen"]=clock
	var age:float=clock-float(row["hit"])
	if age>.25:row["trail"]=move_toward(float(row["trail"]),value,dt*1.8)
	row["trail"]=maxf(float(row["trail"]),value)
	bars[key]=row
	var r:=Rect2(p-Vector2(width*.5,0),Vector2(width,8))
	c.draw_rect(r.grow(1),Color("0d1b2a"))
	c.draw_rect(r,Color("443b43"))
	c.draw_rect(Rect2(r.position+Vector2.ONE,r.size-Vector2.ONE*2),Color("443b43"))
	c.draw_rect(Rect2(r.position+Vector2.ONE,Vector2((width-2)*float(row["trail"]),6)),Color("e9bb78"))
	c.draw_rect(Rect2(r.position+Vector2.ONE,Vector2((width-2)*value,6)),color)
	if age<.18:c.draw_rect(r,Color(1,.93,.8,(1-age/.18)*.45))
func burst(p:Vector2,direction:Vector2,kind:int,element:String)->void:
	breaks.append({"pos":p,"dir":direction,"kind":kind,"element":element,"life":.42})
	while breaks.size()>48:breaks.pop_front()
func draw(c:CanvasItem)->void:
	for hit in breaks:
		var age:float=.42-float(hit["life"])
		var fade:float=float(hit["life"])/.42
		var arrow:bool=int(hit["kind"])==3
		var tint:=Color("d2ad77") if arrow else Color("b9c9ff")
		match str(hit["element"]):
			"feuer":tint=Color("ffb061")
			"eis":tint=Color("a3edff")
			"blitz":tint=Color("fff3a1")
			"gift":tint=Color("aed37d")
		for n in (5 if arrow else 8):
			var direction:Vector2=Vector2(hit["dir"]).rotated(PI*.6+n*.71)
			var p:Vector2=hit["pos"]+direction*(3+age*(35+n*7))+Vector2(0,age*age*100)
			if arrow:c.draw_line(p,p+direction*(4+n%3),Color(tint,fade),2)
			else:c.draw_rect(Rect2(p.round(),Vector2.ONE*(3 if n%2 else 2)),Color(tint,fade))
		if not arrow:c.draw_arc(hit["pos"],3+age*31,0,TAU,12,Color(tint,fade*.5),2)
static func break_sound(arrow:bool)->AudioStreamWAV:
	var rate:=22050
	var count:=roundi(rate*.16)
	var data:=PackedByteArray();data.resize(count*2)
	var random:=RandomNumberGenerator.new();random.seed=412 if arrow else 817
	var prior:=0.0
	for n in count:
		var t:=float(n)/rate
		var noise:=random.randf_range(-1,1)
		prior=lerpf(prior,noise,.65 if arrow else .3)
		var envelope:=pow(1.0-float(n)/count,3)
		var value:float=(prior*.65+sin(TAU*(1600 if arrow else 820)*t)*.22)*envelope*.45
		data.encode_s16(n*2,roundi(clampf(value,-1,1)*32767))
	var stream:=AudioStreamWAV.new();stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=rate;stream.data=data
	return stream
