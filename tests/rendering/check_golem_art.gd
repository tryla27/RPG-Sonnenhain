extends SceneTree
# Golem v2 Optik: Sprite-Blatt (128 px, 3 Ansichten × 11 Bilder), Wahl von Bild
# und Ansicht, Steinformen mit fester Saat, 3D-Inventarbilder der legendären
# Rüstungen und Entwurf der Golem-Rüstung im Inventar.

const GolemDesign=preload("res://components/golem_design.gd")
const GolemBoss=preload("res://components/golem_boss.gd")
const ItemRules=preload("res://components/item_rules.gd")
const ItemStyle=preload("res://components/item_style_32.gd")
const MasterArmor=preload("res://components/master_armor.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("GOLEM_ART_FAIL "+label)

func _initialize()->void:
	var sheet:Texture2D=GolemDesign.SHEET
	check(sheet.get_width()==128*GolemDesign.FRAMES.size() and sheet.get_height()==128*3,"Sprite-Blatt 11 × 3 Bilder à 128 px (%dx%d)" % [sheet.get_width(),sheet.get_height()])
	check(GolemDesign.GLOW.get_size()==sheet.get_size(),"Leucht-Ebene gleich groß")
	check(is_equal_approx(GolemDesign.sprite_scale(GolemBoss.TYPE_BIG)*128.0,320.0),"großer Golem ≈ 320 px")
	check(is_equal_approx(GolemDesign.sprite_scale(GolemBoss.TYPE_HALF)*128.0,160.0),"halber Golem ≈ 160 px")
	check(GolemDesign.frame_index("shield",false,0.0)==GolemDesign.FRAMES.find("shield"),"Schild-Bild")
	check(GolemDesign.frame_index("scream_pause",false,0.0)==GolemDesign.FRAMES.find("scream"),"Schrei-Bild")
	var walk:={}
	for i in 16:walk[GolemDesign.frame_index("walk",true,i*0.25)]=true
	check(walk.size()==4,"vier Gehbilder")
	check(GolemDesign.view_row(Vector2.DOWN)==[0,false] and GolemDesign.view_row(Vector2.UP)==[2,false],"vorn und hinten")
	check(GolemDesign.view_row(Vector2.LEFT)==[1,true] and GolemDesign.view_row(Vector2.RIGHT)==[1,false],"Seite, links gespiegelt")
	# Beine etwa ein Drittel der Höhe: unterstes Drittel des Stehbilds gut gefüllt.
	var img:Image=sheet.get_image()
	var legs:=0
	for y in range(84,124):
		for x in range(20,108):
			if img.get_pixel(x,y).a>0.5:legs+=1
	check(legs>1400,"stämmige Beine (%d Pixel)" % legs)
	# Steine: gleiche Saat = gleiche Form, 9–12 Ecken.
	var a:=GolemDesign.stone_shape(42,40.0)
	check(a==GolemDesign.stone_shape(42,40.0) and a.size()>=9 and a.size()<=12,"Steinform fest und unregelmäßig (%d Ecken)" % a.size())
	check(a!=GolemDesign.stone_shape(43,40.0),"andere Saat, andere Form")
	# Inventarbilder.
	check(ItemStyle.LEGENDARY_ARMOR.get_width()==64*7 and ItemStyle.LEGENDARY_ARMOR.get_height()==64,"7 Rüstungsbilder à 64 px")
	var icons:Image=ItemStyle.LEGENDARY_ARMOR.get_image()
	for id in 7:
		var filled:=0
		for y in 64:
			for x in 64:
				if icons.get_pixel(id*64+x,y).a>0.5:filled+=1
		check(filled>900,"Bild %d gefüllt (%d)" % [id,filled])
	var item:={"name":"Golem-Rüstung","icon":"armor","master_armor":MasterArmor.GOLEM,"design":12}
	check(ItemRules.item_design(item)==12,"Golem-Rüstung behält Entwurf 12 im Inventar (%d)" % ItemRules.item_design(item))
	check(ItemRules.item_design({"name":"Wachtpanzer","icon":"armor","design":1})==1,"normale Rüstung unverändert")
	if failures>0:
		push_error("GOLEM_ART_FAILED %d" % failures);quit(1);return
	print("GOLEM_ART_OK")
	quit()
