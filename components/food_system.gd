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
 {"name":"Moosbeeren","color":"6b8f63","heal":6,"regen":1.0,"duration":14,"price":6},
 {"name":"Waldbeer-Kompott","color":"b94d6f","heal":25,"regen":0.0,"duration":0,"price":42,"meal":true,"meal_hp_regen":2.0,"meal_duration":360},
 {"name":"Moosbeeren-Eintopf","color":"80945e","heal":20,"regen":0.0,"duration":0,"price":48,"meal":true,"meal_hp_regen":3.0,"meal_duration":360},
 {"name":"Steinbeeren-Riegel","color":"9c8c7c","heal":0,"regen":0.0,"duration":0,"price":52,"meal":true,"meal_hp_regen":2.0,"meal_duration":360,"buff":"armor","buff_value":0.05},
 {"name":"Kristallgelee","color":"72d7e5","heal":0,"regen":0.0,"duration":0,"price":58,"meal":true,"meal_hp_regen":3.0,"meal_duration":360,"buff":"cooldown","buff_value":0.05},
 {"name":"Nebelpflaumen-Tee","color":"9070ad","heal":0,"regen":0.0,"duration":0,"price":60,"meal":true,"meal_hp_regen":2.0,"meal_duration":360,"buff":"move","buff_value":0.05},
 {"name":"Daemmerhimmel-Torte","color":"bd8bc7","heal":0,"regen":0.0,"duration":0,"price":85,"meal":true,"meal_hp_regen":4.0,"meal_duration":360,"buff":"damage","buff_value":0.04},
 {"name":"Himmelsfrucht-Salat","color":"c9d9a3","heal":0,"regen":0.0,"duration":0,"price":92,"meal":true,"meal_hp_regen":3.0,"meal_duration":360,"buff":"gather","buff_value":0.04},
 {"name":"Quellbeeren-Brei","color":"b9d7cf","heal":0,"regen":0.0,"duration":0,"price":88,"meal":true,"meal_hp_regen":3.0,"meal_duration":360},
 {"name":"Bernstein-Marmelade","color":"d6a43e","heal":0,"regen":0.0,"duration":0,"price":96,"meal":true,"meal_hp_regen":2.0,"meal_duration":360,"buff":"armor","buff_value":0.05},
 {"name":"Heidelbeer-Pfannkuchen","color":"6c78bc","heal":0,"regen":0.0,"duration":0,"price":104,"meal":true,"meal_hp_regen":3.0,"meal_duration":360,"buff":"gather","buff_value":0.04},
 {"name":"Schimmerbeeren-Suppe","color":"4ba6df","heal":0,"regen":0.0,"duration":0,"price":110,"meal":true,"meal_mana_regen":4.0,"meal_duration":360},
 {"name":"Blauer Mondkuchen","color":"547bd1","heal":0,"regen":0.0,"duration":0,"price":135,"meal":true,"meal_mana_regen":6.0,"meal_duration":360}
]
const BUSHES=[Vector2(510,880),Vector2(360,1180),Vector2(1300,750),Vector2(1580,1660),Vector2(430,1720)]
const TREES=[Vector2(170,510),Vector2(970,440),Vector2(1500,610),Vector2(360,1050),Vector2(150,1040),Vector2(1630,1680)]
const REGROW_SECONDS=300
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
   var p:Vector2=g.safe_world_teleport_destination(desired,region)
   if g.region_at(p) != region:
    p=bounds.get_center()
   plants.append({"point":p,"food":REGION_FOOD[region],"tree":false,"region":region})
   plant_foods[key(p)]=REGION_FOOD[region]
var regen_rate:=0.0
var regen_until:=0.0
var active_food_name:=""
var meal_hp_regen:=0.0
var meal_mana_regen:=0.0
var meal_until:=0.0
var buff_kind:=""
var buff_value:=0.0
var buff_until:=0.0
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
 var now:=Time.get_unix_time_from_system()
 if meal_until<=now:clear_meal()
 return {"plants":harvested.duplicate(),"regen_rate":regen_rate,"regen_until":regen_until,"active_food_name":active_food_name,"meal_hp_regen":meal_hp_regen,"meal_mana_regen":meal_mana_regen,"meal_until":meal_until,"buff_kind":buff_kind,"buff_value":buff_value,"buff_until":buff_until}
func restore(raw:Variant)->void:
 harvested={};regen_rate=0;regen_until=0;clear_meal()
 if not raw is Dictionary:return
 var plants:Variant=raw.get("plants",{})
 if plants is Dictionary:
  for plant_key in plants:
   var value:Variant=plants[plant_key]
   if plant_key is String and plant_key.length()<32 and (value is float or value is int) and is_finite(float(value)):
    harvested[plant_key]=clampf(float(value),0,Time.get_unix_time_from_system()+REGROW_SECONDS)
 var now:=Time.get_unix_time_from_system()
 regen_rate=clampf(float(raw.get("regen_rate",0)),0,3)
 regen_until=clampf(float(raw.get("regen_until",0)),0,now+40)
 var candidate_name:=str(raw.get("active_food_name",""))
 var candidate:=by_name(candidate_name)
 var candidate_until:=clampf(float(raw.get("meal_until",0)),0,now+360)
 if not candidate.is_empty() and bool(candidate.get("meal",false)) and candidate_until>now:
  active_food_name=candidate_name
  meal_hp_regen=clampf(float(raw.get("meal_hp_regen",candidate.get("meal_hp_regen",0))),0,4)
  meal_mana_regen=clampf(float(raw.get("meal_mana_regen",candidate.get("meal_mana_regen",0))),0,6)
  meal_until=candidate_until
  var candidate_kind:=str(raw.get("buff_kind",candidate.get("buff","")))
  if candidate_kind in ["","armor","cooldown","move","damage","gather"]:
   buff_kind=candidate_kind
   buff_value=clampf(float(raw.get("buff_value",candidate.get("buff_value",0))),0,0.05)
   buff_until=meal_until if buff_kind!="" else 0
 prune(now)

func clear_meal()->void:
 active_food_name="";meal_hp_regen=0;meal_mana_regen=0;meal_until=0;buff_kind="";buff_value=0;buff_until=0

func meal_active()->bool:
 return active_food_name!="" and meal_until>Time.get_unix_time_from_system()

func meal_remaining()->int:
 return maxi(0,ceili(meal_until-Time.get_unix_time_from_system())) if meal_active() else 0

func meal_effect_text()->String:
 if not meal_active():return ""
 var parts:Array[String]=[]
 if meal_hp_regen>0:parts.append("+%.0f HP/s" % meal_hp_regen)
 if meal_mana_regen>0:parts.append("+%.0f Mana/s" % meal_mana_regen)
 var labels:={"armor":"+5% Resistenz","cooldown":"+5% Cooldown-Tempo","move":"+5% Bewegung","damage":"+4% Schaden","gather":"+4% Sammelchance"}
 if buff_kind!="":parts.append(str(labels.get(buff_kind,buff_kind)))
 return " · ".join(parts)
func nearest(g)->Dictionary:
 if g.konflux.active or g.arena_mode!="" or g.dungeon_id>=0 or g.interior_id>=0:return {}
 configure(g)
 var found:Dictionary={};var distance:=95.0
 var player_region:int=g.region_at(g.player_pos)
 for plant in plants:
  var p:Vector2=plant["point"]
  var plant_region:int=int(plant.get("region",g.region_at(p)))
  if plant_region!=player_region:continue
  var d:float=g.player_pos.distance_to(p+Vector2(0,20))
  if d<distance:
   found={"point":p,"food":plant["food"],"region":plant_region}
   distance=d
 return found
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
 if buff_active("gather") and randf()<buff_value:item["count"]=4
 if not g.can_add_item(item):
  g.message("Dein Inventar ist voll. Die Fruechte bleiben an der Pflanze.");return true
 if not g.add_item(item):return true
 harvested[key(p)]=now+REGROW_SECONDS
 g.message("%dx %s gepflueckt. Nachwachsen in 5 Minuten." % [int(item["count"]),info["name"]])
 g.play_sound("pickup");g.save_game();g.queue_redraw()
 return true
func eat(g,index:int)->bool:
 if index<0 or index>=g.inventory.size():return false
 var item:Dictionary=g.inventory[index]
 var info:=by_name(str(item.get("name","")))
 if item.get("icon")!="food" or info.is_empty() or g.hp<=0:return false
 var now:=Time.get_unix_time_from_system()
 g.hp=minf(g.max_hp(),g.hp+float(info.get("heal",0)))
 if bool(info.get("meal",false)):
  clear_meal()
  active_food_name=str(info["name"])
  meal_hp_regen=clampf(float(info.get("meal_hp_regen",0)),0,4)
  meal_mana_regen=clampf(float(info.get("meal_mana_regen",0)),0,6)
  meal_until=now+360.0
  buff_kind=str(info.get("buff",""))
  buff_value=clampf(float(info.get("buff_value",0)),0,0.05)
  buff_until=meal_until if buff_kind!="" else 0
 else:
  if regen_until<=now or float(info.get("regen",0))>=regen_rate:
   regen_rate=float(info.get("regen",0));regen_until=now+float(info.get("duration",0))
 if int(item.get("count",1))>1:
  item["count"]=int(item["count"])-1
  item["stack_value"]=maxi(0,g.item_sale_value(item)-int(item.get("value",0)))
 else:
  g.inventory.remove_at(index);g.selected_item=-1
 if bool(info.get("meal",false)):
  g.message("%s: %s fuer 6 Minuten. Ersetzt den vorherigen Essenseffekt." % [info["name"],meal_effect_text()])
 else:
  g.message("%s: +%d HP, %.1f HP/s fuer %ds." % [info["name"],int(info.get("heal",0)),float(info.get("regen",0)),int(info.get("duration",0))])
 g.play_sound("pickup");g.save_game()
 return true
func tick(g,delta:float)->void:
 configure(g)
 var now:=Time.get_unix_time_from_system()
 if meal_until<=now and active_food_name!="":clear_meal()
 if regen_until<=now:
  regen_rate=0
 elif g.hp>0 and g.character_created and not g.server_save.loading and g.death_timer<=0 and not g.konflux.active and g.arena_mode=="":
  g.hp=minf(g.max_hp(),g.hp+regen_rate*maxf(0,delta))
 if meal_active() and g.hp>0 and g.character_created and not g.server_save.loading and g.death_timer<=0 and not g.konflux.active and g.arena_mode=="":
  if meal_hp_regen>0:g.hp=minf(g.max_hp(),g.hp+meal_hp_regen*maxf(0,delta))
  if meal_mana_regen>0:g.energy=minf(g.max_energy(),g.energy+meal_mana_regen*maxf(0,delta))

func buff_active(kind:String="")->bool:
 if not meal_active() or buff_until<=Time.get_unix_time_from_system():return false
 return kind=="" or buff_kind==kind

func energy_regen_mult()->float:
 return 1.0

func damage_taken_mult()->float:
 return 1.0-buff_value if buff_active("armor") else 1.0

func cooldown_recovery_mult()->float:
 return 1.0+buff_value if buff_active("cooldown") else 1.0

func move_mult()->float:
 return 1.0+buff_value if buff_active("move") else 1.0

func damage_mult()->float:
 return 1.0+buff_value if buff_active("damage") else 1.0

func gather_mult()->float:
 return 1.0+buff_value if buff_active("gather") else 1.0

func buff_label()->String:
 if not meal_active():return ""
 return "%s · %02d:%02d" % [meal_effect_text(),meal_remaining()/60,meal_remaining()%60]
func regional_props(g)->Array:
 configure(g)
 var result:Array=[]
 for plant in plants:
  if plant["point"] not in BUSHES+TREES:
   result.append({"kind":"bush","point":plant["point"],"depth":plant["point"].y+20})
 return result
static func food_rect(c:CanvasItem,p:Vector2,s:float,x:float,y:float,w:float,h:float,col:Color)->void:
 PixelStyle32.rect(c,Rect2(p+Vector2(x,y)*s,Vector2(w,h)*s),col)
static func icon(c:CanvasItem,p:Vector2,id:int,s:float=1.0)->void:
 var info:Dictionary=FOODS[clampi(id,0,FOODS.size()-1)]
 var col:=Color(info["color"])
 var edge:=Color("263b37")
 if id>=31:
  match id:
   31,32:
    food_rect(c,p,s,4,15,24,11,edge)
    food_rect(c,p,s,6,13,20,11,Color("a66b48"))
    food_rect(c,p,s,8,12,16,8,col)
    for o in [Vector2(11,12),Vector2(18,14),Vector2(15,10)]:
     food_rect(c,p+o*s,s,0,0,3,3,col.lightened(.3))
   33:
    food_rect(c,p,s,5,12,24,12,edge)
    food_rect(c,p,s,7,10,20,12,col)
    for mark in 3:food_rect(c,p,s,10+mark*5,12,2,7,col.lightened(.25))
   34:
    food_rect(c,p,s,7,9,18,18,edge)
    food_rect(c,p,s,9,7,14,18,col)
    food_rect(c,p,s,11,9,4,8,col.lightened(.4))
    food_rect(c,p,s,6,25,20,3,Color("8ba49c"))
   35:
    food_rect(c,p,s,7,10,18,17,edge)
    food_rect(c,p,s,9,11,14,13,col)
    food_rect(c,p,s,23,14,7,9,edge)
    food_rect(c,p,s,11,7,2,5,Color("d8d4c1"))
    food_rect(c,p,s,16,5,2,6,Color("d8d4c1"))
   36:
    food_rect(c,p,s,6,18,22,9,edge)
    food_rect(c,p,s,8,11,18,14,col)
    food_rect(c,p,s,10,7,14,5,col.lightened(.25))
    for o in [Vector2(11,8),Vector2(18,9)]:food_rect(c,p+o*s,s,0,0,3,3,Color("ffe3a5"))
   37,38,39,40:
    food_rect(c,p,s,4,17,24,10,edge)
    food_rect(c,p,s,6,14,20,11,col)
    food_rect(c,p,s,9,11,14,6,col.lightened(.18))
   41:
    food_rect(c,p,s,5,15,24,12,edge)
    food_rect(c,p,s,7,12,20,13,Color("4a7cc8"))
    food_rect(c,p,s,10,10,14,7,col.lightened(.2))
    food_rect(c,p,s,13,7,2,4,Color("cdeaff"))
   42:
    food_rect(c,p,s,6,18,22,9,edge)
    food_rect(c,p,s,8,10,18,16,Color("4a69b7"))
    food_rect(c,p,s,10,7,14,6,col.lightened(.25))
    food_rect(c,p,s,14,5,6,3,Color("d8e7ff"))
 elif id in [6,7,8,9,10,23,24,26,27,29,30,2]:
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
