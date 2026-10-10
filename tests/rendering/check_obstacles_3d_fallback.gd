extends SceneTree
# Rückfall: Bleibt das 3D-Bild leer (manche Browser/Treiber), zeigt das Spiel
# wieder die 2D-Landschaft mit Bäumen, Büschen, Felsen und Mauern.
const World=preload("res://components/world_obstacles_3d.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("OBSTACLES_FALLBACK_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var empty:=Image.create(64,64,false,Image.FORMAT_RGBA8)
	check(World.visible_pixels(empty)==0,"leeres Bild hat keine Pixel")
	var drawn:=Image.create(64,64,false,Image.FORMAT_RGBA8)
	drawn.fill_rect(Rect2i(8,8,32,32),Color(0.2,0.5,0.2,1.0))
	check(World.visible_pixels(drawn)>=World.PROBE_MIN_PIXELS,"gezeichnetes Bild erkannt (%d)" % World.visible_pixels(drawn))
	check(World.visible_pixels(null)==0,"kein Bild = leer")
	check(World.active and World.replaces_static(3) and World.replaces_wall(Vector2(11000,0),Vector2(11000,1920)),"3D ist Standard")
	World.active=false
	check(not World.replaces_static(3) and not World.replaces_static(12),"Rückfall: 2D-Landschaft")
	check(not World.replaces_wall(Vector2(11000,0),Vector2(11000,1920)),"Rückfall: 2D-Mauern")
	World.active=true
	if failures>0:
		push_error("OBSTACLES_FALLBACK_FAILED %d" % failures);quit(1);return
	print("OBSTACLES_FALLBACK_OK")
	quit()
