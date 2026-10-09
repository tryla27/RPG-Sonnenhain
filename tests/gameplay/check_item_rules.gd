extends SceneTree
# Verhaltenstest für components/item_rules.gd und die Weiterleitungen in main.gd.

const Rules=preload("res://components/item_rules.gd")
const Content=preload("res://components/game_content.gd")

func _initialize()->void:
	# Gegenstandsbau: Attribute folgen der Klasse der Waffe, Wert steigt mit Seltenheit.
	var sword:=Rules.build_item(10,"Waldklinge","sword",2,9,0,"",18)
	assert(sword["uid"]==10 and sword["level"]==18 and sword["count"]==1 and not sword["locked"])
	assert(sword["str"]==4 and sword["agi"]==0 and sword["int"]==0)
	assert(Rules.build_item(1,"Stab","staff",2,9,0,"",18)["int"]==4)
	assert(Rules.build_item(1,"Bogen","bow",2,9,0,"",18)["agi"]==4)
	var ring:=Rules.build_item(1,"Ring","ring",2,9,0,"",18)
	assert(ring["str"]==2 and ring["agi"]==2 and ring["int"]==2)
	assert(Rules.build_item(1,"X","sword",4,9,0,"",18)["value"]>sword["value"])
	assert(Rules.build_item(1,"X","sword",2,9,0,"eis",18)["value"]==Rules.build_item(1,"X","sword",2,9,0,"",18)["value"]+25)
	assert(Rules.build_item(1,"X","sword",0,0,0,"",0)["level"]==1)
	# Tränke und Nahrung behalten ihren festen Preis.
	assert(Rules.build_item(1,"Heiltrank","potion",0,0,35,"",30)["value"]==35)
	assert(Rules.build_item(1,"Apfel","food",0,0,7,"",30)["value"]==7)

	# Stapel und Verkaufswert.
	assert(Rules.stack_limit({"icon":"potion"})==16)
	assert(Rules.stack_limit({"icon":"food"})==30)
	assert(Rules.stack_limit({"icon":"herb"})>1000000)
	assert(Rules.stack_limit({"icon":"sword"})==1)
	assert(Rules.item_sale_value({"value":12,"count":3})==36)
	assert(Rules.item_sale_value({"value":12,"count":3,"stack_value":50})==50)

	# Beute: gültige Werte für alle Gegner; gleiche Saat ergibt gleiche Beute.
	var seen_rarities:={}
	for type in Content.ENEMY_TYPES.size():
		for s in 40:
			seed(s*97+type)
			var spec:=Rules.roll_loot(type,22,"staff")
			seed(s*97+type)
			assert(Rules.roll_loot(type,22,"staff")==spec)
			assert(spec["icon"] in ["staff","gem","ring","armor","herb"])
			assert(spec["rarity"]>=0 and spec["rarity"]<=3)
			assert(spec["level"]==22 and spec["power"]>=0)
			assert(spec["element"]=="" or spec["icon"]=="staff")
			seen_rarities[spec["rarity"]]=true
	assert(seen_rarities.has(0) and seen_rarities.has(1))
	# Legendär nur ab Gebietsstufe 30.
	for s in 3000:
		seed(s)
		assert(Rules.roll_loot(0,29,"sword")["rarity"]<4)

	# Anzeige- und Hilfswerte.
	assert(Rules.item_type("head")=="Kopfausrüstung" and Rules.item_type("??")=="Gegenstand")
	assert(Rules.element_color("feuer")==Color("ff9147"))
	assert(Rules.class_weapon_icon_for(-3)=="sword" and Rules.class_weapon_icon_for(9)=="bow")
	assert(Rules.weapon_visual_stage({"level":40,"rarity":4})==4 and Rules.weapon_visual_stage({})==0)
	assert(Rules.item_design({"name":"Waldklinge","design":99})==11)
	assert(Rules.item_skill_unlock_id({"name":"Arkankern","element":"Blitz"})==18)
	assert(Rules.item_skill_unlock_id({"name":"X","skill_unlock":5})==5)

	# main.gd vergibt fortlaufende UIDs und nutzt die Heldenstufe als Standard.
	var game=load("res://main.gd").new()
	game.level=12
	game.next_uid=40
	var a:Dictionary=game.make_item("A","sword",1,5,0)
	var b:Dictionary=game.make_item("B","ring",1,5,0,"",30)
	assert(a["uid"]==40 and b["uid"]==41 and game.next_uid==42)
	assert(a["level"]==12 and b["level"]==30)
	seed(5)
	var loot:Dictionary=game.random_loot(3)
	assert(loot["uid"]==42 and game.next_uid==43)
	game.free()
	print("ITEM_RULES_OK item building, loot rolls, stacks and display helpers")
	quit()
