extends RefCounted
## Equipment-only arcane effects. Per-attacker state; secondary damage never re-enters procs.
const IDS:=["frost","storm","venom","warlord","resonance","hunt","pendant"]
const NAMES:=["Frosthalskette","Gewitterhalskette","Giftdornhalskette","Halskette des Kriegsherrn","Halskette der Arkanresonanz","Halskette der Jagd"]
const COLORS:=["9fd8e5","68d4db","a0b65c","bf704b","b29cda","d4b96b","b7d294"]
const TEXT:=["Treffer: 20 % langsamer für 2 s. Alle 6 s.","Treffer: 25 % Angriff als Blitz. Alle 5 s.","Treffer: 40 % Angriff als Gift über 4 s. Alle 6 s.","Treffer: bis 5 Zorn, je +2 % Schaden. Verfällt nach 5 s.","Jede dritte Schadens-/Heilfähigkeit: +20 %, 20 % Kosten zurück.","Drei direkte Treffer auf ein Ziel in 6 s: 50 % Zusatztreffer.","Am Hals getragen. Die Werte wirken beim Anlegen."]
var states:Dictionary={}

static func index(item:Dictionary)->int:
	var id:=str(item.get("necklace_id",""))
	if id in IDS:return IDS.find(id)
	var name:=str(item.get("name",""))
	if name in NAMES:return NAMES.find(name)
	if pendant_name(name):return 6
	if name.begins_with("Arkankern") and str(item.get("icon",""))=="essence":
		return {"eis":0,"blitz":1,"gift":2}.get(str(item.get("element","")),-1)
	return -1

static func pendant_name(name:String)->bool:
	var lower:=name.to_lower()
	return "anhänger" in lower or "anhaenger" in lower or "amulett" in lower

static func normalize(item:Dictionary)->void:
	var i:=index(item)
	if i==6:
		item["icon"]="necklace";item["necklace_id"]="pendant";item["design"]=6
		item.erase("skill_unlock")
		return
	if i<0:
		if str(item.get("name","")) in ["Arkankern","Arkanhüter-Waffe"] and item.get("icon","") in ["sword","staff","bow"]:item["name"]="Dunkler-Arkanhüter-Waffe"
		return
	item["name"]=NAMES[i];item["icon"]="necklace";item["necklace_id"]=IDS[i]
	for key in ["power","str","agi","int"]:item[key]=0
	item["element"]="";item["tooltip"]=TEXT[i];item["design"]=i
	item.erase("skill_unlock")

func state(peer:int,id:int,now:int)->Dictionary:
	if not states.has(peer):states[peer]={"id":-1,"ready":0,"rage":0,"rage_until":0,"casts":0,"target":-1,"hits":0,"hunt_until":0}
	var s:Dictionary=states[peer]
	if int(s["id"])!=id:
		for key in ["rage","rage_until","casts","hits","hunt_until"]:s[key]=0
		s["target"]=-1;s["id"]=id
	if now>=int(s["rage_until"]):s["rage"]=0
	if now>=int(s["hunt_until"]):s["hits"]=0;s["target"]=-1
	return s

func reset_charges(peer:int,id:int,now:int)->void:
	var s:=state(peer,id,now)
	s["id"]=-2
	state(peer,id,now)

func direct_hit(id:int,peer:int,enemy:Dictionary,base:int,damage:int,now:int)->int:
	var s:=state(peer,id,now)
	var extra:=0
	if id==3:
		damage=maxi(1,roundi(damage*(1.0+int(s["rage"])*0.02)))
		s["rage"]=mini(5,int(s["rage"])+1);s["rage_until"]=now+5000
	elif id==5:
		var uid:=int(enemy.get("uid",-1))
		if int(s["target"])!=uid or int(s["hits"])==0:s["hits"]=0;s["target"]=uid;s["hunt_until"]=now+6000
		s["hits"]=int(s["hits"])+1
		if int(s["hits"])>=3:extra=maxi(1,roundi(base*0.5));s["hits"]=0;s["hunt_until"]=now+6000
	elif id>=0 and id<=2 and now>=int(s["ready"]):
		s["ready"]=now+(5000 if id==1 else 6000)
		if id==0:
			enemy["necklace_frost"]=2.0
			enemy["necklace_frost_owner"]=peer
			enemy["necklace_frost_mult"]=0.9 if int(enemy.get("type",0)) in [12,13,14] else 0.8
		elif id==1:extra=maxi(1,roundi(base*0.25))
		else:
			var dots:Array=enemy.get("necklace_dots",[])
			dots.append({"owner":peer,"remaining":4.0,"tick":1.0,"damage":maxf(0.0,base*0.1)})
			enemy["necklace_dots"]=dots
	return damage+extra

func cast(id:int,peer:int,now:int)->bool:
	var s:=state(peer,id,now)
	if id!=4:return false
	s["casts"]=int(s["casts"])+1
	if int(s["casts"])<3:return false
	s["casts"]=0
	return true

func tick_enemy(enemy:Dictionary,delta:float,active:Callable=Callable())->void:
	if active.is_valid() and int(active.call(int(enemy.get("necklace_frost_owner",0))))!=0:enemy["necklace_frost"]=0.0
	enemy["necklace_frost"]=maxf(0.0,float(enemy.get("necklace_frost",0.0))-delta)
	var dots:Array=enemy.get("necklace_dots",[])
	for i in range(dots.size()-1,-1,-1):
		var dot:Dictionary=dots[i]
		if active.is_valid() and int(active.call(int(dot["owner"])))!=2:
			dots.remove_at(i);continue
		var dt:=minf(maxf(0.0,delta),float(dot["remaining"]))
		dot["remaining"]=float(dot["remaining"])-dt
		dot["tick"]=float(dot["tick"])-dt
		while float(dot["tick"])<=0.0001:
			dot["tick"]=float(dot["tick"])+1.0
			enemy["hp"]=float(enemy["hp"])-float(dot["damage"])
			var owner:=int(dot["owner"])
			if owner>0:
				enemy["last_hit_peer"]=owner
				var damage:Dictionary=enemy.get("damage_by_peer",{})
				damage[owner]=float(damage.get(owner,0))+float(dot["damage"])
				enemy["damage_by_peer"]=damage
				var times:Dictionary=enemy.get("damage_at_by_peer",{})
				times[owner]=Time.get_ticks_msec();enemy["damage_at_by_peer"]=times
		if float(dot["remaining"])<=0.0001:dots.remove_at(i)
	enemy["necklace_dots"]=dots

func progress(id:int,peer:int,now:int)->String:
	if id==6:return "Anhänger angelegt"
	var s:=state(peer,id,now)
	if id==3:return "Zorn %d/5" % int(s["rage"])
	if id==4:return "Resonanz %d/3" % int(s["casts"])
	if id==5:return "Jagd %d/3" % int(s["hits"])
	return "Bereit" if now>=int(s["ready"]) else "Bereit in %.1f s" % ((int(s["ready"])-now)/1000.0)

static func paint_actor(c:CanvasItem,p:Vector2,look:Vector2,id:int,scale:float,phase:float=0.0)->void:
	if id<0 or id>=IDS.size():return
	var tint:=Color(COLORS[id]);var metal:=Color("bd9c64");var outline:=Color("493e49")
	var bob:=roundf(sin(phase)*1.0)
	var origin:=(p+Vector2(0,-23+bob)*scale).round()
	var back:=look.y< -0.4
	var side:=absf(look.x)>0.75
	if back:
		c.draw_rect(Rect2(origin+Vector2(-4,-3)*scale,Vector2(8,1)*scale),metal)
		return
	var shift:=Vector2(3*signf(look.x) if side else 0,0)*scale
	origin+=shift
	c.draw_rect(Rect2(origin+Vector2(-4,-4)*scale,Vector2(1,4)*scale),metal)
	c.draw_rect(Rect2(origin+Vector2(3,-4)*scale,Vector2(1,4)*scale),metal)
	c.draw_rect(Rect2(origin+Vector2(-3,0)*scale,Vector2(6,1)*scale),metal)
	c.draw_rect(Rect2(origin+Vector2(-2,0)*scale,Vector2(3 if side else 5,5)*scale),outline)
	c.draw_rect(Rect2(origin+Vector2(-1,1)*scale,Vector2(1 if side else 3,3)*scale),tint)
	c.draw_rect(Rect2(origin+Vector2(-1,1)*scale,Vector2.ONE*scale),tint.lightened(0.3))
	if not side and id>=3:
		var mark:=Vector2(0,2) if id==3 else (Vector2(0,3) if id==4 else Vector2(1,2))
		c.draw_rect(Rect2(origin+mark*scale,Vector2.ONE*scale),metal)
