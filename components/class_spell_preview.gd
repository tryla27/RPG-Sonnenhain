extends RefCounted
## Read-only miniatures use the same spell-effect renderer as actual combat.
const ICONIC=[[0,1,2],[16,17,18],[25,26,28]]
static func ids(cls:int)->Array:return ICONIC[clampi(cls,0,2)]
static func draw(g,id:int,rect:Rect2)->void:
	g.draw_rect(rect,Color("102c3c"));g.draw_rect(rect,Color("627479"),false,1)
	var t:float=fmod(Time.get_ticks_msec()/1000.0+id*.17,2.4)/2.4
	var origin:Vector2=rect.position+Vector2(15,rect.size.y*.5)
	g.draw_set_transform(origin,0,Vector2(.22,.22))
	var source:Vector2=Vector2.ZERO;var target:Vector2=Vector2(390,0)
	g.draw_rect(Rect2(target+Vector2(-8,-28),Vector2(16,40)),Color("778c7a"))
	var fx:Dictionary={"kind":id,"pos":Vector2(170,0),"end":target,"dir":Vector2.RIGHT,"rank":1,"life":1-t,"max":1.0}
	if id in [16,25,26,28]:
		if t<.72:
			var pos:Vector2=source.lerp(target,t/.72)
			if id==16:g.draw_vfx_sprite(0,pos,36)
			else:
				for spread in ([-1,0,1] if id==26 else [0]):
					var tip:Vector2=pos+Vector2(0,float(spread)*t*70)
					var color:Color=Color("b7e88a") if id==28 else Color("ffe2aa")
					g.draw_line(tip-Vector2(34,0),tip,color,5)
					g.draw_line(tip-Vector2(10,7),tip,color,5);g.draw_line(tip-Vector2(10,-7),tip,color,5)
		else:
			fx["pos"]=target;fx["life"]=1-(t-.72)/.28;g.draw_spell_local(fx)
	elif id==18:
		if t<.7:
			g.draw_line(source,target,Color("fff4a5",1-t),9)
			g.draw_line(source,target,Color("ffffff",1-t),3)
			g.draw_spell_local(fx)
	else:
		if id==2:fx["pos"]=source
		g.draw_spell_local(fx)
	g.draw_set_transform(Vector2.ZERO)
