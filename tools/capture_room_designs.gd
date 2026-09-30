extends SceneTree
class Rooms:
 extends "res://main.gd"
 var titles=["01  HANDELSHAUS","02  ALCHEMIE / TRAENKE","03  HEILHAUS","04  SCHMIEDE","05  ARCHIV","06  RATSHALLE","07  KAEMPFERGILDE","08  WACHHAUS","09  GASTHAUS STEINROSE","10  KUECHE","11  KRAEUTERSTUBE","12  AUSRUESTUNG","13  FISCHHAENDLER","14  PROVIANTLADEN","15  WOHNHAUS"]
 var subtitles=["Verkaufen und einkaufen","Heiltrank, Mana, Energie","Heilerin und Ruheplatz","Waffen und Ruestungen","Buecher und Forschung","Quests und Bewohner","Arena und Kampftraining","Borin und Reisehinweise","Eintopf und Rast","Nahrung und Mahlzeiten","Kraeuter und Zutaten","Waffen, Ringe, Ruestung","Fisch als Nahrung","Brot, Kaese, Obst","Wohnbereich mit Bett"]
 func _ready():
  font=ThemeDB.fallback_font
  environment_tiles=load("res://art/sonnenhain_tiles.png")
 func _process(_delta):pass
 func person(p:Vector2):
  draw_rect(Rect2(p+Vector2(9,2),Vector2(14,14)),Color("c6a275"))
  draw_rect(Rect2(p+Vector2(6,16),Vector2(20,18)),Color("657b83"))
  draw_rect(Rect2(p+Vector2(8,34),Vector2(6,8)),Color("434954"))
  draw_rect(Rect2(p+Vector2(19,34),Vector2(6,8)),Color("434954"))
 func _draw():
  draw_rect(Rect2(0,0,1104,1770),Color("0d1c2c"))
  draw_string(font,Vector2(24,36),"SONNENHAIN | 15 INNENRAUM-ENTWUERFE",HORIZONTAL_ALIGNMENT_LEFT,-1,27,Color("dfc88e"))
  draw_string(font,Vector2(24,64),"Godot-Render mit vorhandenen Spieltiles: 32px Raster, 10 x 8 Tiles je Musterraum.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("bccbc8"))
  for id in 15:
   var base:=Vector2(20+(id%3)*360,90+(id/3)*330)
   draw_rect(Rect2(base,Vector2(344,320)),Color("b89c62"),false,2)
   draw_string(font,base+Vector2(12,26),titles[id],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e5cd96"))
   var o:=base+Vector2(12,38)
   for y in 8:
    for x in 10:
     var tile:=9 if x==0 or x==9 or y==0 or y==7 else (11 if (x*7+y*3+id)%9==0 else 10)
     if y==7 and x in [4,5]:tile=20
     draw_pixel_tile(tile,o+Vector2(x,y)*32,32)
   for x in [4,5]:
    for y in range(3,7):draw_pixel_tile(14,o+Vector2(x,y)*32,32,Color("bac7bd") if id in [2,10] else Color.WHITE)
   for x in range(1,9):
    draw_pixel_tile(13 if x%3==0 else 24,o+Vector2(x,1)*32,32)
   # Furniture stays clear of the central 64px entry aisle.
   var variant:=id%3
   if variant==0:
    for x in range(2,8):draw_pixel_tile(22,o+Vector2(x,2)*32,32)
    for pos in [Vector2(1,4),Vector2(7,5)]:draw_pixel_tile(21,o+pos*32,32)
   elif variant==1:
    for y in range(2,6):draw_pixel_tile(22,o+Vector2(2,y)*32,32)
    for pos in [Vector2(7,3),Vector2(7,5)]:draw_pixel_tile(23,o+pos*32,32)
   else:
    for x in range(2,8):draw_pixel_tile(22,o+Vector2(x,2)*32,32)
    for pos in [Vector2(1,5),Vector2(7,5)]:draw_pixel_tile(23,o+pos*32,32)
   person(o+Vector2(4.5,3.1)*32)
   if id in [1,2,10]:
    for x in 3:draw_item_icon(o+Vector2(3+x,1.95)*32,"potion",[Color("cc635d"),Color("65a5cc"),Color("94b575")][x],0.55)
   elif id in [9,12,13]:
    for x in 3:FoodSystem.icon(self,o+Vector2(3+x,1.95)*32,[11,16,20][x],0.55)
   elif id in [3,6,11]:
    for x in 3:draw_item_icon(o+Vector2(3+x,1.95)*32,["sword","ring","armor"][x],Color("c4b789"),0.55)
   elif id in [4,5,7]:
    for x in 3:draw_rect(Rect2(o+Vector2(3+x,2)*32,Vector2(10,14)),[Color("baa97b"),Color("7c879e"),Color("96727e")][x])
   elif id==14:
    draw_rect(Rect2(o+Vector2(1,3)*32,Vector2(64,64)),Color("775844"))
    draw_rect(Rect2(o+Vector2(1,3)*32+Vector2(4,4),Vector2(56,48)),Color("798b92"))
    draw_rect(Rect2(o+Vector2(1,3)*32+Vector2(4,4),Vector2(56,14)),Color("d3c8ac"))
   draw_pixel_tile(15,o+Vector2(1,1)*32,32)
   draw_string(font,base+Vector2(12,310),subtitles[id],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("bfd0c6"))
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1152,648)
 var vp=SubViewport.new();vp.size=Vector2i(1104,1770);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 root.add_child(vp);vp.add_child(Rooms.new())
 await process_frame;await RenderingServer.frame_post_draw
 await process_frame;await RenderingServer.frame_post_draw
 var error=vp.get_texture().get_image().save_png("D:/SonnenhainRPG-Audio/innenraum-entwuerfe/15-innenraeume.png")
 print("ROOM_DESIGNS_RENDERED_15 result=",error);quit(error)
