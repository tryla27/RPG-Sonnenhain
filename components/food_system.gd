extends RefCounted
const PixelStyle32=preload("res://components/pixel_style_32.gd")
# One registry controls food names, visible fruit colours and nutrition.
const FOODS = [
 {"name":"Apfel","color":"c94a3d","heal":6,"regen":1.0,"duration":12,"price":5},
 {"name":"Birne","color":"bbca54","heal":7,"regen":1.0,"duration":14,"price":6},
 {"name":"Kirschen","color":"b83550","heal":5,"regen":1.0,"duration":10,"price":5},
 {"name":"Pflaume","color":"8350ad","heal":6,"regen":1.0,"duration":12,"price":5},
 {"name":"Pfirsich","color":"ec9962","heal":8,"regen":1.0,"duration":16,"price":7},
 {"name":"Aprikose","color":"e3a641","heal":6,"regen":1.0,"duration":12,"price":5},
 {"name":"Himbeeren","color":"cd526b","heal":4,"regen":1.0,"duration":8,"price":4},
 {"name":"Heidelbeeren","color":"557cce","heal":4,"regen":1.0,"duration":8,"price":4},
 {"name":"Brombeeren","color":"694c89","heal":5,"regen":1.0,"duration":10,"price":4},
 {"name":"Stachelbeeren","color":"b0bd58","heal":5,"regen":1.0,"duration":10,"price":4},
 {"name":"Johannisbeeren","color":"c8423b","heal":4,"regen":1.0,"duration":8,"price":4},
 {"name":"Brot","color":"c09c65","heal":10,"regen":1.5,"duration":20,"price":15},
 {"name":"Kaese","color":"dbbb61","heal":12,"regen":2.0,"duration":20,"price":20},
 {"name":"Honig","color":"d9a23c","heal":8,"regen":1.5,"duration":16,"price":12},
 {"name":"Nuesse","color":"98704b","heal":8,"regen":1.5,"duration":18,"price":12},
 {"name":"Karotte","color":"da873c","heal":6,"regen":1.0,"duration":12,"price":6},
 {"name":"Gebratener Fisch","color":"aaa795","heal":14,"regen":2.0,"duration":25,"price":25},
 {"name":"Gebratenes Fleisch","color":"ad6858","heal":18,"regen":2.5,"duration":30,"price":35},
 {"name":"Pilzpfanne","color":"bfa787","heal":12,"regen":2.0,"duration":24,"price":24},
 {"name":"Gemueseeintopf","color":"8da763","heal":16,"regen":2.5,"duration":30,"price":32},
 {"name":"Sonnenhain-Eintopf","color":"b88c52","heal":22,"regen":3.0,"duration":40,"price":48},
 {"name":"Milch","color":"e3ded0","heal":6,"regen":1.0,"duration":14,"price":8},
 {"name":"Gekochtes Ei","color":"e4d4a9","heal":8,"regen":1.5,"duration":18,"price":12},
 {"name":"Kristallbeeren","color":"62ccd4","heal":10,"regen":1.5,"duration":20,"price":12},
 {"name":"Nebelbeeren","color":"b6cfcc","heal":8,"regen":1.5,"duration":16,"price":10},
 {"name":"Bernsteinfrucht","color":"d6ad54","heal":12,"regen":2.0,"duration":22,"price":18},
 {"name":"Quellbeeren","color":"86bfc9","heal":12,"regen":2.0,"duration":24,"price":20},
 {"name":"Daemmerbeeren","color":"7d6b99","heal":14,"regen":2.5,"duration":26,"price":24},
 {"name":"Himmelsfrucht","color":"dcbadb","heal":18,"regen":3.0,"duration":32,"price":35},
 {"name":"Steinbeeren","color":"b3aaa0","heal":8,"regen":1.5,"duration":16,"price":10},
 {"name":"Moosbeeren","color":"6b8f63","heal":6,"regen":1.0,"duration":14,"price":6}
]
const BUSHES=[Vector2(510,880),Vector2(360,1180),Vector2(1300,750),Vector2(1580,1660),Vector2(430,1720)]
const TREES=[Vector2(170,510),Vector2(970,440),Vector2(1500,610),Vector2(360,1050),Vector2(150,1040),Vector2(1630,1680)]
const REGROW_SECONDS=300
const BODY_RADIUS=34.0
const REGION_FOOD=[-1,6,30,29,23,5,7,3,24,25,26,27,28]
var harvested:Dictionary={}
var plants:Array=[]
var plant_foods:Dictionary={}
func configure(g)->void:
 if not plants.is_empty():return
 for region in range(1,13):
  var bounds:Rect2=g.region_rect(region).intersection(Rect2(Vector2.ZERO,g.WORLD))
  for offset in [Vector2(-160,-140),Vector2(160,-140),Vector2(0,180)]:
   var desired:Vector2=bounds.get_center()+offset
   var p:Vector2=safe_plant_position(g,desired,region)
   plants.append({"point":p,"food":REGION_FOOD[region],"tree":false})
   plant_foods[key(p)]=REGION_FOOD[region]
func safe_plant_position(g,desired:Vector2,region:int)->Vector2:
 var offsets=[Vector2.ZERO,Vector2(96,0),Vector2(-96,0),Vector2(0,96),Vector2(0,-96),Vector2(96,96),Vector2(-96,96),Vector2(96,-96),Vector2(-96,-96),Vector2(192,0),Vector2(-192,0),Vector2(0,192),Vector2(0,-192)]
 for offset in offsets:
  var candidate:Vector2=(desired+offset).clamp(Vector2(64,64),g.WORLD-Vector2(64,64))
  if g.region_at(candidate)!=region or g.terrain_blocked(candidate) or g.blocked_by_region_wall(candidate):continue
  var occupied:=false
  for stone in g.WAYSTONES:
   if candidate.distance_to(stone)<260.0:occupied=true;break
  if occupied:continue
  for landmark in g.LANDMARKS:
   if candidate.distance_to(landmark["pos"])<190.0:occupied=true;break
  if occupied:continue
  for plant in plants:
   if candidate.distance_to(plant["point"])<110.0:occupied=true;break
  if not occupied:return candidate
 return g.safe_world_teleport_destination(desired,region)
var regen_rate:=0.0
var regen_until:=0.0
static func by_name(food_name:String)->Dictionary:
 for entry in FOODS:
  if entry["name"]==food_name:return entry
 return {}
static func index_for(food_name:String)->int:
 for i in FOODS.size():
  if FOODS[i]["name"]==food_name:return i
 return -1
static func at_plant(p:Vector2,tree:bool)->int:
 return REGION_FOOD[0] if (p in TREES if tree else p in BUSHES) else -1
static func key(p:Vector2)->String:return "%d:%d" % [int(p.x),int(p.y)]
func ready_at(p:Vector2,now:float)->bool:return now>=float(harvested.get(key(p),0))
func prune(now:float)->void:
 for plant in harvested.keys():
  if float(harvested[plant])<=now:harvested.erase(plant)
func snapshot()->Dictionary:
 prune(Time.get_unix_time_from_system())
 return {"plants":harvested.duplicate(),"regen_rate":regen_rate,"regen_until":regen_until}
func restore(raw:Variant)->void:
 harvested={};regen_rate=0;regen_until=0
 if not raw is Dictionary:return
 var plants:Variant=raw.get("plants",{})
 if plants is Dictionary:
  for plant_key in plants:
   var value:Variant=plants[plant_key]
   if plant_key is String and plant_key.length()<32 and (value is float or value is int) and is_finite(float(value)):
    harvested[plant_key]=clampf(float(value),0,Time.get_unix_time_from_system()+REGROW_SECONDS)
 regen_rate=clampf(float(raw.get("regen_rate",0)),0,3)
 regen_until=clampf(float(raw.get("regen_until",0)),0,Time.get_unix_time_from_system()+40)
 prune(Time.get_unix_time_from_system())
func nearest(g)->Dictionary:
 if g.konflux.active or g.arena_mode!="" or g.dungeon_id>=0 or g.interior_id>=0:return {}
 configure(g)
 var found:Dictionary={};var distance:=95.0
 for plant in plants:
  var p:Vector2=plant["point"]
  var d:float=g.player_pos.distance_to(p+Vector2(0,20))
  if d<distance:
   found={"point":p,"food":plant["food"]}
   distance=d
 return found
func plant_by_key(g,plant_key:String)->Dictionary:
 configure(g)
 for plant in plants:
  if key(plant["point"])==plant_key:return plant
 return {}
func blocks(g,p:Vector2,radius:float=0.0)->bool:
 configure(g)
 for plant in plants:
  var center:Vector2=plant["point"]+Vector2(0,8)
  if p.distance_to(center)<BODY_RADIUS+maxf(0.0,radius):return true
 return false
func accepted_move(g,from_pos:Vector2,to_pos:Vector2,radius:float)->Vector2:
 configure(g)
 var distance:=from_pos.distance_to(to_pos)
 var steps:=maxi(1,ceili(distance/10.0))
 var accepted:=from_pos
 for step in range(1,steps+1):
  var target:=from_pos.lerp(to_pos,float(step)/steps)
  if blocks(g,target,radius):break
  accepted=target
 return accepted
func harvest(g)->bool:
 var plant:=nearest(g)
 if plant.is_empty():return false
 var p:Vector2=plant["point"]
 var now:=Time.get_unix_time_from_system()
 if not ready_at(p,now):
  g.message("Hier wachsen neue Fruechte nach (%ds)." % ceili(float(harvested[key(p)])-now));return true
 var info:Dictionary=FOODS[int(plant["food"])]
 var item:Dictionary=g.make_item(info["name"],"food",0,0,int(info["price"]), "",1)
 item["count"]=3
 if not g.can_add_item(item):
  g.message("Dein Inventar ist voll. Die Fruechte bleiben an der Pflanze.");return true
 if g.network_mode=="client":
  g.request_server_food_harvest(key(p))
  return true
 if not g.add_item(item):return true
 harvested[key(p)]=now+REGROW_SECONDS
 g.message("3x %s gepflueckt. Nachwachsen in 5 Minuten." % info["name"])
 g.play_sound("pickup");g.save_game();g.queue_redraw()
 return true
func eat(g,index:int)->bool:
 if index<0 or index>=g.inventory.size():return false
 var item:Dictionary=g.inventory[index]
 var info:=by_name(str(item.get("name","")))
 if item.get("icon")!="food" or info.is_empty() or g.hp<=0:return false
 var now:=Time.get_unix_time_from_system()
 g.hp=minf(g.max_hp(),g.hp+float(info["heal"]))
 # Refresh only the same or stronger food; weak snacks cannot prolong a strong meal.
 if regen_until<=now or float(info["regen"])>=regen_rate:
  regen_rate=float(info["regen"]);regen_until=now+float(info["duration"])
 if int(item.get("count",1))>1:
  item["count"]=int(item["count"])-1
  item["stack_value"]=maxi(0,g.item_sale_value(item)-int(item.get("value",0)))
 else:
  g.inventory.remove_at(index);g.selected_item=-1
 g.message("%s: +%d HP, %.1f HP/s fuer %ds." % [info["name"],info["heal"],info["regen"],info["duration"]])
 g.play_sound("pickup");g.save_game()
 return true
func tick(g,delta:float)->void:
 configure(g)
 if regen_until<=Time.get_unix_time_from_system():regen_rate=0;return
 if g.hp>0 and g.character_created and not g.server_save.loading and g.death_timer<=0 and not g.konflux.active and g.arena_mode=="":
  g.hp=minf(g.max_hp(),g.hp+regen_rate*maxf(0,delta))
func regional_props(g)->Array:
 configure(g)
 var result:Array=[]
 for plant in plants:
  result.append({"kind":"bush","point":plant["point"],"depth":plant["point"].y+20,"plant_key":key(plant["point"])})
 return result
static func food_rect(c:CanvasItem,p:Vector2,s:float,x:float,y:float,w:float,h:float,col:Color)->void:
 PixelStyle32.rect(c,Rect2(p+Vector2(x,y)*s,Vector2(w,h)*s),col)
static func icon(c:CanvasItem,p:Vector2,id:int,s:float=1.0)->void:
 var info:Dictionary=FOODS[clampi(id,0,FOODS.size()-1)]
 var col:=Color(info["color"])
 var edge:=Color("263b37")
 if id in [6,7,8,9,10,23,24,26,27,29,30,2]:
  for off in [Vector2(6,15),Vector2(14,9),Vector2(19,18)]:
   food_rect(c,p+off*s,s,0,0,9,10,edge)
   food_rect(c,p+off*s,s,1,1,7,7,col)
   food_rect(c,p+off*s,s,2,1,2,2,col.lightened(.4))
  food_rect(c,p,s,14,3,2,7,Color("71513d"))
  food_rect(c,p,s,17,4,7,3,Color("729a53"))
 elif id in [11,12]:
  food_rect(c,p,s,4,12,24,16,edge)
  food_rect(c,p,s,6,10,20,15,col)
  for mark in 3:
   food_rect(c,p,s,9+mark*5,12,2,4,col.darkened(.25))
  food_rect(c,p,s,7,11,17,2,col.lightened(.3))
 elif id in [13,21]:
  food_rect(c,p,s,10,3,12,5,Color("a78f65"))
  food_rect(c,p,s,7,9,19,20,edge)
  food_rect(c,p,s,9,10,15,17,col)
  food_rect(c,p,s,10,11,3,11,col.lightened(.35))
  food_rect(c,p,s,9,17,15,6,Color("d8c496"))
 elif id==15:
  food_rect(c,p,s,14,3,3,8,Color("609548"))
  food_rect(c,p,s,9,5,7,3,Color("609548"))
  food_rect(c,p,s,10,11,12,9,col)
  food_rect(c,p,s,12,20,8,5,col)
  food_rect(c,p,s,14,25,4,4,col.darkened(.2))
 elif id==16:
  food_rect(c,p,s,7,11,18,12,col.darkened(.2))
  food_rect(c,p,s,8,12,14,8,col)
  food_rect(c,p,s,24,12,6,10,col)
  food_rect(c,p,s,10,13,2,2,edge)
  food_rect(c,p,s,14,21,5,3,col.lightened(.3))
 elif id in [18,19,20]:
  food_rect(c,p,s,3,16,26,10,edge)
  food_rect(c,p,s,5,18,22,6,Color("a89877"))
  food_rect(c,p,s,5,12,22,8,col)
  for off in [Vector2(9,12),Vector2(17,15),Vector2(21,11)]:
   food_rect(c,p+off*s,s,0,0,3,3,col.lightened(.3))
  food_rect(c,p,s,11,5,2,5,Color("a6b7ad"))
 elif id==17:
  food_rect(c,p,s,5,10,18,16,edge)
  food_rect(c,p,s,7,11,14,12,col)
  food_rect(c,p,s,9,12,5,3,col.lightened(.3))
  food_rect(c,p,s,21,17,7,4,Color("e5d8b6"))
 elif id in [14,22]:
  food_rect(c,p,s,10,7,12,20,col.darkened(.25))
  food_rect(c,p,s,8,11,16,14,col)
  food_rect(c,p,s,12,9,5,6,col.lightened(.25))
 else:
  food_rect(c,p,s,6,12,22,15,edge)
  food_rect(c,p,s,8,10,18,15,col.darkened(.2))
  food_rect(c,p,s,10,8,14,17,col)
  food_rect(c,p,s,11,10,4,5,col.lightened(.35))
  food_rect(c,p,s,16,3,2,6,Color("765238"))
  food_rect(c,p,s,19,4,7,3,Color("6f9145"))

func fruit(c:CanvasItem,p:Vector2,tree:bool)->void:
 var id:int=int(plant_foods.get(key(p),at_plant(p,tree)))
 if id<0 or not ready_at(p,Time.get_unix_time_from_system()):return
 var offsets=[Vector2(-42,-116),Vector2(12,-142),Vector2(38,-99),Vector2(-15,-83),Vector2(49,-133)] if tree else [Vector2(-29,-19),Vector2(-11,-35),Vector2(12,-29),Vector2(29,-12),Vector2(0,-10)]
 for offset in offsets:icon(c,p+offset,id,0.38 if tree else 0.3)
func bush(c:CanvasItem,p:Vector2)->void:
 if p in BUSHES:
  preload("res://components/start_scenery_32.gd").bush(c,p,int(p.x+p.y))
  return
 # 96x64 pixel silhouette aligned to the existing bush position.
 var dark:=Color("294f39");var leaf:=Color("527348")
 c.draw_rect(Rect2(p+Vector2(-40,-24),Vector2(80,40)),dark)
 c.draw_rect(Rect2(p+Vector2(-28,-40),Vector2(56,52)),leaf)
 c.draw_rect(Rect2(p+Vector2(-44,-12),Vector2(88,20)),leaf)
 for o in [Vector2(-24,-30),Vector2(2,-32),Vector2(22,-15)]:
  c.draw_rect(Rect2(p+o,Vector2(12,8)),Color("79934f"))
 fruit(c,p,false)
 if not ready_at(p,Time.get_unix_time_from_system()):
  var seconds:=maxi(0,ceili(float(harvested.get(key(p),0))-Time.get_unix_time_from_system()))
  c.draw_string(ThemeDB.fallback_font,p+Vector2(-22,30),"%02d:%02d" % [seconds/60,seconds%60],HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e4cf8b"))

