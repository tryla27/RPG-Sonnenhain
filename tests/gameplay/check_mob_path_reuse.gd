extends SceneTree
## Gegner-Wegsuche: Ein vollständiger Weg zu einem kaum bewegten Ziel wird
## weiterbenutzt, solange der nächste Abschnitt frei ist. Ein bewegtes Ziel
## oder ein versperrter Abschnitt führt zu einer neuen Suche.
const Nav=preload("res://components/mob_navigation.gd")
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("MOB_PATH_REUSE_FAIL "+label)
func _initialize()->void:call_deferred("run")
func run()->void:
	# Kurze Wand bei x=100 (y -80 bis 80): der Weg führt um sie herum.
	var wall:=[true]
	var walkable:=func(p:Vector2)->bool:return not (wall[0] and absf(p.x-100.0)<20.0 and absf(p.y)<80.0)
	var enemy:={"uid":3,"pos":Vector2.ZERO}
	var target:=Vector2(260,0)
	Nav.routes_left=-1
	var dir:=Nav.direction(enemy,target,.016,walkable)
	var first:Array=enemy["nav_path"].duplicate()
	check(dir.length()>.9,"Richtung vorhanden")
	check(first.size()>1 and Vector2(first.back()).distance_to(target)<1.0,"vollständiger Umweg gefunden")
	check(bool(enemy.get("nav_complete",false)),"Weg als vollständig markiert")
	# Wartezeit abgelaufen, Ziel unverändert, kein Suchkontingent: alter Weg bleibt
	# und wird nicht bis zum nächsten Bild verschoben.
	enemy["nav_wait"]=0.0;Nav.routes_left=0
	Nav.direction(enemy,target+Vector2(20,0),.016,walkable)
	check(enemy["nav_path"]==first,"Weg weiterbenutzt")
	check(float(enemy["nav_wait"])>=.6,"nächste Prüfung erst später")
	check(Nav.routes_left==0,"kein Kontingent verbraucht")
	# Ziel weit bewegt: neue Suche (mit Kontingent).
	Nav.routes_left=1;enemy["nav_wait"]=5.0
	Nav.direction(enemy,Vector2(0,300),.016,walkable)
	check(Nav.routes_left==0,"bewegtes Ziel sucht neu")
	check(Vector2(enemy["nav_path"].back()).distance_to(Vector2(0,300))<1.0,"neuer Weg zum neuen Ziel")
	# Versperrter nächster Abschnitt: kein Weiterbenutzen.
	var blocked_enemy:={"uid":4,"pos":Vector2.ZERO,"nav_path":[Vector2(140,0),Vector2(260,0)],"nav_target":Vector2(260,0),"nav_complete":true,"nav_wait":0.0}
	Nav.routes_left=1
	Nav.direction(blocked_enemy,Vector2(260,0),.016,walkable)
	check(Nav.routes_left==0,"versperrter Weg sucht neu")
	check(Vector2(blocked_enemy["nav_path"][0]).x<80.0,"neuer Weg umgeht die Wand")
	# Unvollständiger Weg wird nie einfach weiterbenutzt.
	var partial:={"uid":5,"pos":Vector2.ZERO,"nav_path":[Vector2(40,0)],"nav_target":Vector2(260,0),"nav_complete":false,"nav_wait":0.0}
	Nav.routes_left=0
	Nav.direction(partial,Vector2(260,0),.016,walkable)
	check(float(partial["nav_wait"])==0.0,"unvollständiger Weg wartet auf neue Suche")
	Nav.routes_left=-1
	if failures>0:quit(1);return
	print("MOB_PATH_REUSE_OK")
	quit()
