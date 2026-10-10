extends SceneTree
# Bosshüte sind am Charakter sichtbar, an jeder Klasse und auch bei anderen
# Spielern (Netzwerk-Wert 3–5). Klassenhüte bleiben 0–2.

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("BOSS_HAT_VISUAL_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var g=load("res://main.gd").new()
	for boss in 3:
		for cls in 3:
			g.class_id=cls
			g.inventory.clear()
			var hat:Dictionary=g.class_boss_hat_item(boss)
			hat["uid"]=77
			g.inventory.append(hat)
			g.equipped_head_uid=77
			check(g.head_visual()==3+boss,"Bosshut %d an Klasse %d sichtbar (%d)" % [boss,cls,g.head_visual()])
			check(int(g.local_player_state()["head"])==3+boss,"Bosshut %d geht ans Netz" % boss)
	var normal:Dictionary=g.make_class_head(10)
	normal["uid"]=78
	g.inventory.append(normal)
	g.equipped_head_uid=78
	check(g.head_visual()==int(normal.get("head_class",-1)),"Klassenhut bleibt 0–2")
	g.free()
	if failures>0:
		print("BOSS_HAT_VISUAL_FAILED ",failures)
		quit(1)
		return
	print("BOSS_HAT_VISUAL_OK boss hats show on every class and over the network")
	quit()
