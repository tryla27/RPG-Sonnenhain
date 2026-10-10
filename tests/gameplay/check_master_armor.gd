extends SceneTree
# Legendäre Rüstungen: Torvald ab Stufe 40, Werte, Aussehen und Wirkungen.

const MasterArmor=preload("res://components/master_armor.gd")

class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func save_game()->void:pass
	func play_sound(_n:String)->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("MASTER_ARMOR_FAIL "+label)

func _initialize()->void:call_deferred("run")

func wear(g,id:int)->void:
	g.inventory.clear()
	var item:Dictionary=g.master_armor_item(id)
	g.inventory.append(item)
	g.equipped_armor_uid=int(item["uid"])

func run()->void:
	var g:=Game.new()
	g.reset_class_skills();g.character_created=true
	g.level=39;g.refresh_shop_stock()
	var has_master:=func()->bool:
		for o in g.shop_stock["smith"]:
			if o.has("master_armor"):return true
		return false
	check(not has_master.call(),"unter Stufe 40 keine legendäre Rüstung bei Torvald")
	g.level=40;g.refresh_shop_stock()
	check(has_master.call(),"ab Stufe 40 bietet Torvald eine an")
	var offer:Dictionary={}
	for o in g.shop_stock["smith"]:
		if o.has("master_armor"):offer=o
	g.gold=99999;g.inventory.clear()
	check(g.buy_item(offer),"kaufbar")
	var bought:Dictionary=g.inventory[0]
	var id:=int(offer["master_armor"])
	check(MasterArmor.index(bought)==id and int(bought["power"])==int(MasterArmor.ARMORS[id]["power"]),"Werte übernommen")
	g.equipped_armor_uid=int(bought["uid"])
	check(g.armor_visual()==6+id,"eigenes Aussehen")
	check(MasterArmor.ARMORS[MasterArmor.GOLEM]["power"]==100,"Golem-Rüstung 100 Schutz")
	for i in MasterArmor.ARMORS.size():
		check(int(MasterArmor.ARMORS[i]["power"])<=100,"Golem-Rüstung ist die stärkste")

	# Arkanweber: Schild fängt 60 ab.
	wear(g,MasterArmor.ARKAN);g.hp=1000.0;g.arkan_shield_cooldown=0.0
	g.apply_player_damage(100)
	check(is_equal_approx(g.hp,1000.0-maxf(1,100-60-28)),"Arkanschild + Schutz (%s)" % g.hp)
	# Golem: Steinhaut unter 40 %.
	wear(g,MasterArmor.GOLEM);g.hp=g.max_hp()*0.45;g.golem_guard_cooldown=0.0
	var before:float=g.hp
	g.apply_player_damage(int(g.max_hp()*0.2)+100)
	check(g.golem_guard_timer>0.0,"Steinhaut ausgelöst")
	# Dornen.
	var enemy:Dictionary=g.make_enemy(0,Vector2(4000,3000));enemy["hp"]=500.0
	g.apply_master_thorns(enemy,100,MasterArmor.DORNEN)
	check(is_equal_approx(float(enemy["hp"]),470.0),"Dornen werfen 30 zurück")
	g.apply_master_thorns(enemy,100,MasterArmor.WIND)
	check(is_equal_approx(float(enemy["hp"]),470.0),"andere Rüstung: kein Rückwurf")
	# Blutmond: Lebensraub.
	wear(g,MasterArmor.BLUTMOND);g.hp=100.0
	g.enemies=[g.make_enemy(0,Vector2(4000,3000))];g.enemies[0]["hp"]=5000.0;g.enemies[0]["max_hp"]=5000.0
	g.damage_enemy(0,200,Vector2.ZERO)
	check(g.hp>100.0,"Blutmond heilt (%s)" % g.hp)
	# Sternenquell: Erholung nach 5 s.
	wear(g,MasterArmor.STERNENQUELL);g.hp=100.0;g.seconds_since_hit=6.0
	g.update_master_armor(1.0)
	check(g.hp>100.0,"Sternenquell erholt")
	check(MasterArmor.move_mult(MasterArmor.WIND)>1.0 and MasterArmor.move_mult(MasterArmor.GOLEM)<1.0,"Lauftempo")
	g.free()
	if failures>0:
		print("MASTER_ARMOR_FAILED ",failures)
		quit(1)
		return
	print("MASTER_ARMOR_OK smith from LV 40, stats, looks and effects")
	quit()
