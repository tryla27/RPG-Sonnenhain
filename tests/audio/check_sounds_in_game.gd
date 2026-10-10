extends SceneTree
# Spielt echte Spielabläufe durch und prüft, dass dabei die richtigen Klänge
# ausgelöst UND von der Soundbank tatsächlich abgespielt werden.

const Bank=preload("res://components/sound_bank.gd")

class Game:
	extends "res://main.gd"
	var heard:Array=[]
	func play_sound(name:String)->void:
		heard.append(name)
		super(name)
	func play_world_sound(name:String,pos:Vector2)->void:
		heard.append(name)
		super(name,pos)
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func announce_quest_state()->void:pass

var failures:=0
var g:Game

func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("SOUNDS_IN_GAME_FAIL "+label)

## Prüft, dass ein Klang gehört wurde und gerade über eine Stimme der Bank läuft.
func expect(name:String,label:String)->void:
	check(name in g.heard,"%s: '%s' nicht ausgelöst (gehört: %s)" % [label,name,g.heard])
	var playing:=false
	for i in g.sound_bank.players.size():
		if g.sound_bank.voice_info[i]["name"]==name:playing=true
	check(playing,"%s: '%s' nicht von der Soundbank abgespielt" % [label,name])
	g.heard.clear()
	# Ohne Audiogerät enden Klänge im Test nie; Pool leeren wie nach dem Ausklingen.
	for player in g.sound_bank.players:player.stop()

func _initialize()->void:call_deferred("run")

func run()->void:
	g=Game.new()
	for i in g.WORLD_EVENTS.size():
		g.event_states.append(0)
		g.event_progress.append(0)
	for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
	for i in g.BORIN_QUESTS.size():g.borin_quests.append({"state":0,"progress":0})
	g.character_created=true
	g.effects_volume=1.0
	g.ui_volume=1.0
	g.sound_bank.setup(root,16)
	g.player_pos=Vector2(2600,1500)
	g.reset_class_skills()

	# Angriffe je Klasse.
	for pair in [[0,"schwert_schwung"],[1,"stab_schwung"],[2,"bogen_schuss"]]:
		g.class_id=pair[0];g.attack_timer=0.0
		g.normal_attack()
		expect(pair[1],"Angriff Klasse %d" % pair[0])

	# Treffer nach Material, Besiegen mit eigenem Laut.
	g.enemies.clear()
	g.enemies.append(g.make_enemy(0,g.player_pos+Vector2(60,0)))
	g.damage_enemy(0,1,Vector2.ZERO)
	expect("treffer_weich","Treffer Waldschleim")
	g.damage_enemy(0,100000,Vector2.ZERO)
	expect("schleim_tod","Waldschleim besiegt")
	g.enemies.append(g.make_enemy(3,g.player_pos+Vector2(60,0)))
	g.damage_enemy(0,100000,Vector2.ZERO)
	expect("tod_fell","Mooswolf besiegt (Fell-Laut)")

	# Monsterlaute aus dem Angriffszustand.
	g.enemies.clear()
	var wolf:Dictionary=g.make_enemy(3,g.player_pos+Vector2(80,0))
	wolf["uid"]=4711
	wolf["attack_state"]={"id":1,"age":0.0,"fired":false,"ability":{"id":"sprung","shape":"leap"}}
	g.enemies.append(wolf)
	g.update_mob_voices()
	expect("wolf_knurren","Wolf holt aus")

	# Spieler: Schaden, Herzschlag unter 25 %, Niederlage.
	g.hp=g.max_hp();g.invulnerable=0.0;g.death_timer=0.0
	g.apply_player_damage(5)
	expect("spieler_schaden","Spieler nimmt Schaden")
	g.hp=g.max_hp()*0.2
	g.sound_bank.set_loop("spieler_warnung",g.low_health_alarm_active(),1.0)
	check(g.sound_bank.loop_players["spieler_warnung"].playing,"Herzschlag laeuft unter 25 %")
	g.hp=g.max_hp()
	g.sound_bank.set_loop("spieler_warnung",g.low_health_alarm_active(),1.0)
	check(not g.sound_bank.loop_players["spieler_warnung"].playing,"Herzschlag stoppt bei vollem Leben")
	g.hp=3.0;g.invulnerable=0.0
	g.apply_player_damage(100000)
	expect("spieler_tod","Niederlage")
	g.death_timer=0.0;g.hp=g.max_hp();g.panel=""

	# Beute.
	g.drops=[{"pos":g.player_pos,"gold":12,"life":30.0}]
	g.collect_drops()
	expect("beute_muenzen","Gold aufheben")
	var epic:=g.make_item("Testklinge","sword",3,10,0)
	g.drops=[{"pos":g.player_pos,"item":epic,"life":30.0}]
	g.collect_drops()
	expect("beute_episch","Epischer Fund")

	# Quest annehmen, Level-Aufstieg.
	g.level=1
	g.quest_dialogue("Mira")
	expect("quest_angenommen","Quest bei Mira annehmen")
	g.gain_xp(100000)
	expect("level_auf","Level-Aufstieg")

	# Händler: kaufen, zu wenig Gold, verkaufen.
	g.gold=10000
	g.buy_item({"name":"Heiltrank","icon":"potion","power":0,"price":35})
	expect("kaufen","Kaufen")
	g.gold=0
	g.buy_item({"name":"Heiltrank","icon":"potion","power":0,"price":35})
	expect("ui_fehler","Zu wenig Gold")
	g.inventory.append(g.make_item("Alter Ring","ring",0,3,10))
	g.sell_item(g.inventory.size()-1)
	expect("verkaufen","Verkaufen")

	# Fenster öffnen und schließen.
	g.panel="";g.last_sound_panel=""
	g.panel="inventory";g.update_panel_sounds()
	expect("ui_fenster_auf","Inventar öffnen")
	g.panel="";g.update_panel_sounds()
	expect("ui_fenster_zu","Inventar schließen")

	# Teleport-Brummen am Spawnstein ist entfernt (Angelo 10.10.2026).
	g.player_pos=g.WAYSTONES[0]+Vector2(60,0)
	check(g.spawn_hum_level()==0.0,"Spawngeräusch entfernt")
	g.sound_bank.set_loop("teleport_brummen",true,g.spawn_hum_level())
	check(not g.sound_bank.loop_players["teleport_brummen"].playing,"Brummen läuft am Spawnstein nicht mehr")
	g.player_pos=g.WAYSTONES[0]+Vector2(900,0)
	check(g.spawn_hum_level()==0.0,"Brummen weit weg still")
	g.sound_bank.set_loop("teleport_brummen",true,g.spawn_hum_level())
	check(not g.sound_bank.loop_players["teleport_brummen"].playing,"Brummen stoppt weit weg")
	g.player_pos=g.WAYSTONES[0]
	g.interior_id=1
	check(g.spawn_hum_level()==0.0,"Brummen drinnen still")
	g.interior_id=-1

	# Busch-Rascheln an einem Dorfbusch.
	check(g.foliage_at(g.VillageLayout.BUSHES[0]),"Dorfbusch erkannt")

	for p in g.sound_bank.players:
		p.stop();p.stream=null;p.free()
	for p in g.sound_bank.loop_players.values():
		p.stop();p.stream=null;p.free()
	g.free()
	if failures>0:
		print("SOUNDS_IN_GAME_FAILED ",failures)
		quit(1)
		return
	print("SOUNDS_IN_GAME_OK attacks, hits, deaths, mob voices, player, loot, quests, level, shop, windows")
	quit()
