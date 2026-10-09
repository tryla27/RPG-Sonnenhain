extends SceneTree
# Prüft components/sound_bank.gd und die erzeugten Dateien unter audio/sfx/.

const Bank=preload("res://components/sound_bank.gd")
const Content=preload("res://components/game_content.gd")

var failures:=0

func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("SOUND_BANK_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	check_files()
	check_rules()
	check_voices()
	check_mob_voices()
	if failures>0:
		print("SOUND_BANK_FAILED ",failures)
		quit(1)
		return
	print("SOUND_BANK_OK %d sounds, files, levels, voices and mob voices" % Bank.CATALOG.size())
	quit()

## WAV-Kopf und Pegel direkt aus der Datei lesen.
func check_files()->void:
	for name in Bank.CATALOG:
		for variant in int(Bank.CATALOG[name]["variants"]):
			var path:=Bank.file_path(name,variant)
			check(load(path) is AudioStream,"%s laedt nicht" % path)
			var bytes:=FileAccess.get_file_as_bytes(path)
			check(bytes.size()>44,"%s leer" % path)
			if bytes.size()<=44:continue
			check(bytes.decode_u16(22)==1,"%s nicht mono" % path)
			check(bytes.decode_u32(24)==44100,"%s nicht 44,1 kHz" % path)
			check(bytes.decode_u16(34)==16,"%s nicht 16 Bit" % path)
			var peak:=0
			var first_loud:=-1
			var count:=(bytes.size()-44)/2
			for i in count:
				var sample:=absi(bytes.decode_s16(44+i*2))
				peak=maxi(peak,sample)
				if first_loud<0 and sample>655:first_loud=i
			check(peak<=int(32767*0.71)+2,"%s ueber -3 dBFS" % path)
			check(peak>int(32767*0.3),"%s zu leise" % path)
			check(first_loud>=0 and first_loud<441*3,"%s beginnt mit Stille" % path)
			check(count<44100*2,"%s laenger als 2 s" % path)

func check_rules()->void:
	check(Bank.ENEMY_MATERIAL.size()==Content.ENEMY_TYPES.size(),"Material fuer jeden Gegner")
	for type in Content.ENEMY_TYPES.size():
		check(Bank.CATALOG.has(Bank.hit_sound_for(type)),"Trefferlaut fuer Gegner %d" % type)
		check(Bank.CATALOG.has(Bank.death_sound_for(type)),"Todeslaut fuer Gegner %d" % type)
	check(Bank.death_sound_for(3)=="wolf_tod" and Bank.hit_sound_for(0)=="treffer_weich","Waldmonster")
	for rarity in range(-1,6):check(Bank.CATALOG.has(Bank.loot_sound_for(rarity)),"Beute %d" % rarity)
	check(Bank.distance_gain(0)==1.0 and Bank.distance_gain(Bank.HEARING)==0.0,"Entfernung Grenzen")
	var previous:=2.0
	for d in range(0,int(Bank.HEARING)+40,40):
		var g:=Bank.distance_gain(d)
		check(g<=previous,"Entfernung faellt monoton")
		previous=g
	var bank=Bank.new()
	var last:=-1
	for i in 200:
		var v:int=bank.pick_variant("schwert_schwung",4)
		check(v>=0 and v<4 and v!=last,"Variante ohne direkte Wiederholung")
		last=v

func check_voices()->void:
	var bank=Bank.new()
	bank.setup(root,4)
	check(AudioServer.get_bus_index(Bank.BUS_SFX)>=0 and AudioServer.get_bus_index(Bank.BUS_MUSIC)>=0,"Busse angelegt")
	check(bank.players.size()==4,"Stimmenpool")
	check(not bank.play("gibt_es_nicht"),"unbekannter Sound")
	check(not bank.play("wolf_biss",0.0),"stumm bei Lautstaerke 0")
	check(not bank.play("wolf_biss",1.0,Bank.HEARING+10),"zu weit entfernt")
	for i in 3:check(bank.play("wolf_biss"),"Biss %d" % i)
	var same:=0
	for i in bank.players.size():
		if bank.players[i].playing and bank.voice_info[i]["name"]=="wolf_biss":same+=1
	check(same<=2,"Limit gleichzeitiger Stimmen")
	check(bank.loop_players.has("spieler_warnung"),"Herzschlag als Schleife")
	var heart:AudioStreamWAV=bank.loop_players["spieler_warnung"].stream
	check(heart.loop_mode==AudioStreamWAV.LOOP_FORWARD and heart.loop_end>40000,"Herzschlag schleift ueber volle Laenge")
	bank.set_loop("spieler_warnung",true)
	check(bank.loop_players["spieler_warnung"].playing,"Herzschlag startet")
	bank.set_loop("spieler_warnung",true)
	check(bank.loop_players["spieler_warnung"].playing,"Herzschlag laeuft weiter")
	bank.set_loop("spieler_warnung",false)
	check(not bank.loop_players["spieler_warnung"].playing,"Herzschlag stoppt")
	bank.set_loop("spieler_warnung",true,0.0)
	check(not bank.loop_players["spieler_warnung"].playing,"stumm bei Lautstaerke 0")
	check(bank.play("spieler_tod"),"Spielertod spielt")
	check(bank.duck_timer>0.0,"Ducking bei Spielertod")
	for player in bank.loop_players.values():
		player.stop()
		player.stream=null
		player.free()
	bank.loop_players.clear()
	for player in bank.players:
		player.stop()
		player.stream=null
		player.free()
	bank.players.clear()
	bank.streams.clear()

func check_mob_voices()->void:
	var bank=Bank.new()
	var listener:=Vector2(100,100)
	var wolf:={"uid":7,"type":3,"pos":Vector2(150,100),"hp":10.0,"max_hp":72.0,"attack_state":{"id":1,"fired":false,"ability":{"id":"sprungbiss","shape":"leap"}}}
	var names:=func(list:Array)->Array:
		var out:Array=[]
		for entry in list:out.append(entry[0])
		return out
	check(names.call(bank.observe_mobs([wolf],listener))==["wolf_knurren"],"Wolf knurrt beim Ausholen")
	check(bank.observe_mobs([wolf],listener).is_empty(),"kein doppeltes Knurren")
	wolf["attack_state"]["fired"]=true
	check(names.call(bank.observe_mobs([wolf],listener))==["wolf_sprung"],"Wolf springt")
	wolf["attack_state"]["landed"]=true
	check(names.call(bank.observe_mobs([wolf],listener))==["wolf_landung"],"Wolf landet")
	check(names.call(bank.observe_mobs([],listener,true))==["wolf_tod"],"Koop: verschwundener Wolf jault")
	var beetle:={"uid":8,"type":1,"pos":Vector2(9000,0),"hp":30.0,"max_hp":32.0,"attack_state":{"id":1,"fired":false,"ability":{"id":"druesensekret","shape":"projectile"}}}
	check(bank.observe_mobs([beetle],listener).is_empty(),"zu weit weg: still")
	var mushroom:={"uid":9,"type":2,"pos":listener,"hp":60.0,"max_hp":65.0,"attack_state":{"id":4,"fired":false,"ability":{"id":"giftstaub","shape":"cloud"}}}
	check(names.call(bank.observe_mobs([mushroom],listener))==["pilz_ankuendigung"],"Pilz kuendigt an")
	check(bank.observe_mobs([],listener,true).is_empty(),"gesunder Gegner verschwindet ohne Todeslaut")
