extends SceneTree
# Dunkler Golem: Altar, Schild, Steinhagel-Feld, Brockenwurf, Bäume, Schrei,
# Zerfall in zwei Hälften, Sieg mit Golem-Rüstung, Netzpaket und Speichern.

const GolemBoss=preload("res://components/golem_boss.gd")
const MasterArmor=preload("res://components/master_armor.gd")

class Game extends "res://main.gd":
	var sounds:Array=[]
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func save_game()->void:pass
	func play_sound(n:String)->void:sounds.append(n)
	func play_world_sound(n:String,_p:Vector2)->void:sounds.append(n)

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("DARK_GOLEM_FAIL "+label)

func _initialize()->void:call_deferred("run")

func food(g,name:String,count:int)->Dictionary:
	var item:Dictionary=g.make_item(name,"food",0,0,10,"",1)
	item["count"]=count
	return item

func the_golem(g)->Dictionary:
	for e in g.enemies:
		if GolemBoss.is_golem(e):return e
	return {}

func run()->void:
	var g:=Game.new()
	g.reset_class_skills();g.character_created=true;g.level=40
	g.hp=g.max_hp()
	g.quests.clear();g.borin_quests.clear()
	for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
	for i in g.BORIN_QUESTS.size():g.borin_quests.append({"state":0,"progress":0})
	g.event_states=[];g.event_progress=[]
	for i in g.WORLD_EVENTS.size():
		g.event_states.append(0);g.event_progress.append(0)
	check(g.region_at(GolemBoss.ALTAR)==12,"Altar liegt im Himmelsgarten")
	check(not g.is_blocked(GolemBoss.ALTAR+Vector2(0,90),GolemBoss.ALTAR+Vector2(0,100)),"Platz vor dem Altar ist begehbar")
	# Geplante Opfergaben (später aktiv): Prüfung der Mengen.
	var planned:=GolemBoss.PLANNED_SUMMON_COST
	check(GolemBoss.missing_offerings({"Steinbeeren":30,"Rotkuchen":1,"Blaukuchen":1},planned)=="","alle Opfergaben da")
	check(GolemBoss.missing_offerings({"Steinbeeren":12},planned).contains("18× Steinbeeren"),"fehlende Gaben genannt")
	# Vorerst ohne Opfergaben: E am Altar reicht, Inventar bleibt unberührt.
	check(GolemBoss.SUMMON_COST.is_empty(),"vorerst keine Opfergaben")
	g.player_pos=GolemBoss.ALTAR+Vector2(0,60)
	g.inventory.clear();g.enemies.clear()
	g.inventory.append(food(g,"Steinbeeren",34))
	g.golem_world.boulders.append([GolemBoss.ALTAR.x+900,GolemBoss.ALTAR.y])
	g.interact()
	var golem:=the_golem(g)
	check(not golem.is_empty() and int(golem["type"])==GolemBoss.TYPE_BIG,"Golem ohne Opfergaben beschworen")
	check(g.steinrose.inventory_count(g,"Steinbeeren")==34,"nichts abgezogen")
	# Golem-Rüstung gibt es nirgends zu kaufen.
	check(MasterArmor.GOLEM not in MasterArmor.SHOP_IDS and MasterArmor.GOLEM not in MasterArmor.CLASS_BOSS_ARMOR,"Golem-Rüstung nicht im Laden, nicht von Klassenbossen")
	for rotation in 12:
		check(int(MasterArmor.smith_offer(40,rotation).get("master_armor",-1))!=MasterArmor.GOLEM,"Torvald verkauft sie in keiner Rotation (%d)" % rotation)
	g.level=40
	for rotation in 12:
		g.refresh_shop_stock()
		for key in g.shop_stock:
			for offer in g.shop_stock[key]:
				check(int(offer.get("master_armor",-1))!=MasterArmor.GOLEM,"kein Golem-Angebot im Laden")
	check(g.golem_world.boulders.is_empty(),"alte Brocken verschwinden beim neuen Golem")
	check(is_equal_approx(g.mob_visual_scale(golem),4.0),"Golem 4× so groß gezeichnet (5× Spieler)")
	check(g.active_class_boss_music_theme()=="boss_golem","eigene Bossmusik")
	g.interact()
	check(g.golem_world.alive_golems(g.enemies).size()==1,"kein zweiter Golem")

	# Aufstehen, dann Schild + Feld.
	g.player_pos=Vector2(golem["pos"])+Vector2(0,400)
	for i in 30:g.golem_world.update_golem(g,golem,g.golem_targets(),0.1)
	check(str(golem["golem"]["state"])=="walk" or str(golem["golem"]["state"])=="shield","nach dem Aufstehen aktiv")
	golem["golem"]["shield_cd"]=0.0;golem["golem"]["state"]="walk"
	g.golem_world.update_golem(g,golem,g.golem_targets(),0.05)
	check(str(golem["golem"]["state"])=="shield","Schild aktiv")
	check(g.golem_world.fields.size()==1,"Steinhagel-Feld entsteht mit dem Schild")
	var hp_before:float=float(golem["hp"])
	var index:=g.enemies.find(golem)
	g.damage_enemy(index,1000,Vector2.ZERO)
	check(float(golem["hp"])>=hp_before-30.0,"Schild hält 99 Prozent ab (%s)" % (hp_before-float(golem["hp"])))
	check(is_equal_approx(GolemBoss.incoming_mult(golem),0.01),"−99 % Schaden")
	# Im Feld schneller.
	golem["golem"]["state"]="walk";golem["golem"]["throw_cd"]=99.0;golem["golem"]["shield_cd"]=99.0
	var start:Vector2=golem["pos"]
	g.golem_world.update_golem(g,golem,g.golem_targets(),0.5)
	var moved:=Vector2(golem["pos"]).distance_to(start)
	check(absf(moved-GolemBoss.SPEED*1.3*0.5)<1.0,"im Feld +30 Prozent Tempo (%s)" % moved)
	# Hagel trifft den Spieler.
	g.hp=g.max_hp();g.invulnerable=0.0
	g.golem_world.hail.append({"pos":[g.player_pos.x,g.player_pos.y],"delay":0.01,"damage":45})
	g.golem_world.update_world(g,0.05,true)
	check(g.hp<g.max_hp(),"Steinhagel macht Schaden")

	# Brockenwurf: Spieler wird mitgerissen, Brocken bleibt liegen.
	g.golem_world.fields.clear();g.golem_world.hail.clear()
	golem["golem"]["state"]="walk";golem["golem"]["throw_cd"]=0.0;golem["golem"]["shield_cd"]=99.0
	g.player_pos=Vector2(golem["pos"])+Vector2(0,240)
	g.golem_world.update_golem(g,golem,g.golem_targets(),0.05)
	check(str(golem["golem"]["state"])=="scrape","schabt vor dem Wurf")
	for i in 12:g.golem_world.update_golem(g,golem,g.golem_targets(),0.1)
	check(g.golem_world.throws.size()==1,"Brocken fliegt")
	g.hp=g.max_hp();g.invulnerable=0.0;g.golem_push_velocity=Vector2.ZERO
	var minion:=g.make_enemy(25,Vector2(golem["pos"])+Vector2(0,300))
	g.enemies.append(minion)
	var minion_start:Vector2=minion["pos"]
	for i in 40:g.golem_world.update_world(g,0.05,true)
	check(g.hp<g.max_hp() and g.golem_push_velocity.y>0.0,"Brocken trifft und stößt den Spieler")
	check(Vector2(minion["pos"]).y>minion_start.y,"Brocken reißt Gegner mit")
	check(g.golem_world.boulders.size()==1,"Brocken bleibt liegen")
	var b:Array=g.golem_world.boulders[0]
	var dist:=Vector2(b[0],b[1]).distance_to(Vector2(golem["pos"])+Vector2(0,20))
	check(dist>GolemBoss.THROW_FLIGHT-40.0 and dist<=GolemBoss.THROW_FLIGHT+GolemBoss.THROW_ROLL+20.0,"15 m Flug + Rollen (%s)" % dist)
	check(g.is_blocked(Vector2(b[0],b[1]),Vector2(b[0],b[1])+Vector2(0,120)),"Brocken blockiert den Weg")

	# Stampfer: 0,6 s Ansage mit Ring, wer herausgeht, nimmt nichts; 4 s Abklingzeit.
	g.golem_world.boulders.clear();g.golem_world.throws.clear();g.golem_world.fields.clear();g.golem_world.hail.clear()
	golem["golem"]["state"]="walk";golem["golem"]["throw_cd"]=99.0;golem["golem"]["shield_cd"]=99.0;golem["golem"]["melee_cd"]=0.0
	g.player_pos=Vector2(golem["pos"])+Vector2(0,100)
	g.hp=g.max_hp();g.invulnerable=0.0;g.golem_push_velocity=Vector2.ZERO
	g.golem_world.update_golem(g,golem,g.golem_targets(),0.05)
	check(str(golem["golem"]["state"])=="stomp","Stampfer wird angesagt")
	check(g.hp==g.max_hp(),"Ansage macht noch keinen Schaden")
	check(is_equal_approx(float(golem["golem"]["melee_cd"]),GolemBoss.MELEE_COOLDOWN) and GolemBoss.MELEE_COOLDOWN==4.0,"4 s Abklingzeit")
	g.player_pos=Vector2(golem["pos"])+Vector2(0,-260)
	for i in 8:g.golem_world.update_golem(g,golem,g.golem_targets(),0.1)
	check(str(golem["golem"]["state"])!="stomp" and g.hp==g.max_hp(),"ausgewichen: kein Schaden")
	golem["golem"]["state"]="walk";golem["golem"]["melee_cd"]=0.0
	g.player_pos=Vector2(golem["pos"])+Vector2(0,100)
	g.golem_world.update_golem(g,golem,g.golem_targets(),0.05)
	for i in 8:g.golem_world.update_golem(g,golem,g.golem_targets(),0.1)
	var stomp_raw:=roundi(GolemBoss.base_damage(g)*GolemBoss.MELEE_DAMAGE)
	check(g.hp<g.max_hp() and g.max_hp()-g.hp<=stomp_raw,"stehengeblieben: Treffer (%s von %s)" % [g.max_hp()-g.hp,stomp_raw])

	# Bäume: umgeworfen, nach 10 Minuten wieder da.
	g.golem_world.knocked_trees["5:5"]=Time.get_unix_time_from_system()+GolemBoss.TREE_REGROW_SECONDS
	check(g.golem_world.tree_knocked(Vector2i(5,5)),"Baum liegt")
	check(not g.golem_world.tree_knocked(Vector2i(5,5),Time.get_unix_time_from_system()+601.0),"nach 10 Minuten steht er wieder")
	var found:=false
	for tx in range(int(GolemBoss.ALTAR.x/64)-30,int(GolemBoss.ALTAR.x/64)+30):
		for ty in range(int(GolemBoss.ALTAR.y/64)-30,int(GolemBoss.ALTAR.y/64)+30):
			var tree:Dictionary=g.decorative_tree_in_cell(tx,ty)
			if tree.is_empty():continue
			g.golem_world.knock_trees_between(g,Vector2(tree["point"])-Vector2(40,0),Vector2(tree["point"])+Vector2(40,0))
			check(g.decorative_tree_in_cell(tx,ty).is_empty(),"getroffener Baum fällt um")
			found=true
			break
		if found:break
	check(found,"Bäume rund um den Altar vorhanden")

	# Schrei unter 40 %: trifft jeden im Himmelsgarten.
	g.golem_world.boulders.clear()
	golem["golem"]["state"]="walk";golem["hp"]=float(golem["max_hp"])*0.39
	for far in [Vector2(-1500,0),Vector2(0,-1100),Vector2(-1100,-600),Vector2(1200,-500),Vector2(-1300,400)]:
		g.player_pos=GolemBoss.ALTAR+far
		if g.region_at(g.player_pos)==12 and not g.waystone_safe_at(g.player_pos):break
	g.hp=g.max_hp();g.invulnerable=0.0
	g.golem_world.update_golem(g,golem,g.golem_targets(),0.05)
	check(str(golem["golem"]["state"])=="scream_pause","pausiert vor dem Schrei")
	for i in 20:g.golem_world.update_golem(g,golem,g.golem_targets(),0.1)
	check(g.golem_world.scream_at>=0.0 and g.hp<g.max_hp(),"Schrei trifft auch weit entfernt (Region %d, %s, scream %s, inv %s, targets %s)" % [g.region_at(g.player_pos),g.hp,g.golem_world.scream_at,g.invulnerable,g.golem_targets().size()])
	check(bool(golem["golem"]["screamed"]),"nur einmal")

	# Himmelsfalter-Wellen.
	g.enemies=[golem]
	g.golem_minion_spawn(25,10)
	var minions:=0
	for e in g.enemies:
		if bool(e.get("golem_minion",false)) and int(e["type"])==25:minions+=1
	check(minions>=1,"Himmelsfalter erscheinen (%d)" % minions)

	# Netzpaket hin und zurück.
	g.golem_world.fields.append({"pos":[1,2],"life":3.0,"next":0.1,"mult":1.0})
	g.golem_world.boulders.append([10.0,20.0])
	var snap:Dictionary=g.golem_world.snapshot(g.world_time)
	var copy:=GolemBoss.new()
	copy.apply_snapshot(JSON.parse_string(JSON.stringify(snap)),g.world_time)
	check(copy.fields.size()==g.golem_world.fields.size() and copy.boulders.size()==1 and copy.fight_active,"Netzpaket überträgt den Kampf")
	var stored:=GolemBoss.new()
	stored.load_state(JSON.parse_string(JSON.stringify(g.golem_world.save_state())))
	check(stored.boulders.size()==1,"Brocken bleiben gespeichert")

	# Tod: zwei halbe Golems, dann Sieg mit Golem-Rüstung.
	g.enemies=[golem];g.drops.clear()
	index=0;golem["golem"]["state"]="walk"
	g.damage_enemy(index,999999,Vector2.ZERO)
	var halves:Array=[]
	for e in g.enemies:
		if int(e["type"])==GolemBoss.TYPE_HALF:halves.append(e)
	check(halves.size()==2,"zerfällt in zwei Hälften")
	check(halves.size()==2 and is_equal_approx(float(halves[0]["max_hp"]),float(golem["max_hp"])*0.5),"halb so stark")
	check(halves.size()==2 and is_equal_approx(g.mob_visual_scale(halves[0]),2.0),"halb so groß")
	var armor_dropped:=func()->bool:
		for d in g.drops:
			if d.has("item") and MasterArmor.index(d["item"])==MasterArmor.GOLEM:return true
		return false
	g.damage_enemy(g.enemies.find(halves[0]),999999,Vector2.ZERO)
	check(not armor_dropped.call(),"noch kein Sieg mit einer Hälfte")
	g.damage_enemy(g.enemies.find(halves[1]),999999,Vector2.ZERO)
	check(armor_dropped.call(),"Golem-Rüstung als Beute")
	check(not g.golem_world.fight_active,"Kampf vorbei")
	check(int(MasterArmor.ARMORS[MasterArmor.GOLEM]["power"])==100,"Golem-Rüstung 100 Schutz")

	g.free()
	if failures>0:
		push_error("DARK_GOLEM_FAILURES %d" % failures)
		quit(1)
		return
	print("DARK_GOLEM_OK")
	quit(0)
