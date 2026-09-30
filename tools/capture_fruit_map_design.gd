extends SceneTree
class MapBoard:
 extends "res://main.gd"
 var palette=["547452","6b8454","435e4e","7d8078","468e98","86594c","5b8f9a","70627f","718e87","9a8145","52818e","625770","9d829d"]
 func _ready():font=ThemeDB.fallback_font
 func _process(_delta):pass
 func _draw():
  draw_rect(Rect2(0,0,1320,1370),Color("0d1c2c"))
  draw_string(font,Vector2(20,34),"SONNENHAIN | STARTGEBIETE UND REGIONALE FRUECHTE",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color("dfc88e"))
  draw_string(font,Vector2(20,61),"Gebietsgrenzen aus dem Spielcode. Map 0 ohne Fruechte. Nachwachsen: 05:00 nach jeder Ernte.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("c3d0c8"))
  var origin:=Vector2(20,82)
  for region in 13:
   var r:=region_rect(region).intersection(Rect2(Vector2.ZERO,WORLD))
   var box:=Rect2(origin+r.position*0.08,r.size*0.08)
   draw_rect(box,Color(palette[region]))
   draw_rect(box,Color("b5a070"),false,2)
   var center:=box.get_center()
   draw_string(font,center+Vector2(-box.size.x*0.45,-26),"%d  %s" % [region,region_name(region)],HORIZONTAL_ALIGNMENT_CENTER,box.size.x*0.9,15,Color("f1e8cf"))
   var food_id:int=FoodSystem.REGION_FOOD[region]
   if food_id>=0:
    FoodSystem.icon(self,center+Vector2(-16,-14),food_id)
    draw_string(font,center+Vector2(-box.size.x*0.45,43),FoodSystem.FOODS[food_id]["name"],HORIZONTAL_ALIGNMENT_CENTER,box.size.x*0.9,13,Color("fff2cf"))
   else:
    draw_string(font,center+Vector2(-box.size.x*0.45,20),"KEINE FRUECHTE",HORIZONTAL_ALIGNMENT_CENTER,box.size.x*0.9,11,Color("fff2cf"))
  for gate in VILLAGE_GATES:
   draw_circle(origin+gate*0.08,5,Color("f1d46f"))
  for region in 13:
   var p:=Vector2(20+(region%3)*430,876+(region/3)*94)
   draw_rect(Rect2(p,Vector2(418,82)),Color("172b3b"))
   draw_rect(Rect2(p,Vector2(418,82)),Color("a58e5f"),false,1)
   draw_string(font,p+Vector2(12,23),"%02d  %s · LV %d" % [region,region_name(region),region_level(region)],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("dfc88e"))
   var food_id:int=FoodSystem.REGION_FOOD[region]
   if food_id>=0:
    FoodSystem.icon(self,p+Vector2(12,35),food_id)
    draw_string(font,p+Vector2(54,54),FoodSystem.FOODS[food_id]["name"],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color(FoodSystem.FOODS[food_id]["color"]).lightened(0.3))
    draw_string(font,p+Vector2(54,74),"Pfluecken · Essen · Regeneration · 05:00",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("bccbc6"))
   else:
    draw_string(font,p+Vector2(12,53),"Startdorf: keine Fruechte an Pflanzen",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("bccbc6"))
    draw_string(font,p+Vector2(12,74),"Osten: Map 1 · Sueden: Map 6",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("bccbc6"))
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1152,648)
 var vp=SubViewport.new();vp.size=Vector2i(1320,1370);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 root.add_child(vp);vp.add_child(MapBoard.new())
 await process_frame;await RenderingServer.frame_post_draw
 await process_frame;await RenderingServer.frame_post_draw
 var error=vp.get_texture().get_image().save_png("D:/SonnenhainRPG-Audio/innenraum-entwuerfe/maps-und-fruechte.png")
 print("REGIONAL_FRUIT_MAP_RENDERED_13 result=",error);quit(error)
