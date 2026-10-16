extends SceneTree
const Decor=preload("res://components/homecoming_decor.gd")
const Effects=preload("res://components/quality_effect_frames.gd")
const Telegraph=preload("res://components/attack_telegraph.gd")
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:
	check(Decor.stage([],0,false)==0,"Neuer Charakter ohne Schmuck")
	check(Decor.stage([3,0,0,0],0,false)==1,"Tessas abgeschlossene Begegnung")
	check(Decor.stage([0,0,0,0],3,false)==2,"Blütenweiler-Belohnung abgeholt")
	check(Decor.stage([],0,true)==3,"Finale hat Vorrang")
	check(Decor.stage([],0,false)==0,"Charakterwechsel übernimmt keinen globalen Zustand")
	check(Effects.frame(-1).position.x==0 and Effects.frame(20).position.x==448,"Effektbilder begrenzen ungültige Zeiten")
	check(Effects.frame(.21).position.x==256,"Halbe Dauer entspricht fünftem Bild")
	var origin:=Vector2(30,40);var arc:=Telegraph.outline(origin,Vector2.RIGHT,{"range":100.0,"half_angle":.7})
	check(arc[0]==origin and arc.size()==18,"Warnfläche beginnt am echten Ursprung")
	for point in arc.slice(1):check(is_equal_approx(point.distance_to(origin),100.0),"Warnkante entspricht der tatsächlichen Reichweite")
	if failures>0:quit(1);return
	print("QUALITY_GAMEPLAY_OK persönlicher Storyschmuck, begrenzte Effektzeiten")
	quit()
