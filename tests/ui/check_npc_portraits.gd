extends SceneTree
## Porträts erscheinen nur bei Meldungen bekannter Figuren.
const Portraits=preload("res://components/npc_portraits.gd")
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:
	check(Portraits.speaker("Mira: Deine Aufgaben stehen im Questbuch (J).")=="Mira","Mira erkannt")
	check(Portraits.speaker("Borin: Gute Klinge!")=="Borin","Borin erkannt")
	check(Portraits.speaker("Fenna:Hallo")=="Fenna","ohne Leerzeichen")
	check(Portraits.speaker("Liora: Mira verwaltet die Aufgaben")=="","kein Porträt für Liora")
	check(Portraits.speaker("+12 XP · +3 Gold")=="","normale Meldung ohne Porträt")
	check(Portraits.speaker("Inventar voll: Mira hilft")=="","Name nicht am Anfang")
	for name in Portraits.PORTRAITS:
		var texture:Texture2D=Portraits.PORTRAITS[name]
		check(texture.get_width()==Portraits.SIZE and texture.get_height()==Portraits.SIZE,"48 px: "+name)
	if failures>0:quit(1);return
	print("NPC_PORTRAITS_OK")
	quit()
