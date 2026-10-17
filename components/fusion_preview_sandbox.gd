extends "res://main.gd"
## Abgeschlossene Übungswelt für die Fusionsvorschau: eigene Spielinstanz auf
## dem Arenaboden mit Held und Übungspuppe. Gewirkt wird über denselben Weg wie
## im Spiel (`use_ability` → `execute_ability_effects` → `cast_fusion_at_impact`).
## Diese Instanz speichert nie, lädt keinen Spielstand, verbindet sich nicht,
## liest keine Eingaben und spielt keine Klänge. Sie verändert nichts am
## eigentlichen Spiel (Gold, Zutaten, Lernstand, Gegner, Spielstand).

const DUMMY_HP:=1000000.0
const HERO_OFFSET:=Vector2(-150,0)
## Abstand Held–Puppe ohne bekannte Trägerreichweite (Geschosse).
const DEFAULT_DISTANCE:=300.0

var dummy_pos:=Vector2.ZERO
## Puppenabstand: drei Viertel der Trägerreichweite, damit Nahkampfträger treffen.
var dummy_distance:=DEFAULT_DISTANCE
var carrier_id:=-1
## Gemessen seit dem letzten Wirken.
var hits:=0
var total_damage:=0.0
var cooldown_seconds:=0.0
var cast_id:=-1

# --- Alles abschalten, was nach außen wirkt -------------------------------
func load_game()->void:pass
func save_game()->void:pass
func ensure_player_uuid()->void:pass
func setup_multiplayer_signals()->void:pass
func refresh_save_slot_labels()->void:pass
func ensure_live_multiplayer()->void:pass
func join_live_multiplayer()->void:pass
func announce_multiplayer_context()->void:pass
func play_sound(_name:String)->void:pass
func play_world_sound(_name:String,_pos:Vector2)->void:pass
func message(_value:String)->void:pass
func message_error(_value:String)->void:pass
func _input(_event:InputEvent)->void:pass
func _unhandled_input(_event:InputEvent)->void:pass
# Nur die Welt zeigen, keine Oberfläche des Übungshelden.
func draw_hud()->void:pass
func draw_chat_overlay()->void:pass
func draw_online_list()->void:pass
func draw_party_widget()->void:pass
func draw_multiplayer_debug_overlay()->void:pass
func app_draw_keyboard_bar()->void:pass

## Übungswelt aufbauen. `source` ist das echte Spiel: übernommen werden nur
## Werte, die die Stärke bestimmen (Klasse, Stufe, Ausrüstung, Essenz).
func setup(source,fusion_id:int,rank:int)->void:
	panel="";character_created=true;creative_mode=false;network_mode="offline"
	arena_mode="preview";dungeon_id=-1;interior_id=-1
	class_id=int(source.class_id);level=int(source.level);hero_race=int(source.hero_race);hero_gender=int(source.hero_gender)
	inventory=source.inventory.duplicate(true)
	equipped_uid=int(source.equipped_uid);equipped_armor_uid=int(source.equipped_armor_uid)
	equipped_ring_uid=int(source.equipped_ring_uid);equipped_ring2_uid=int(source.equipped_ring2_uid)
	equipped_head_uid=int(source.equipped_head_uid);equipped_necklace_uid=-1
	essence.restore(source.essence.snapshot())
	ensure_skill_state_size()
	for i in learned.size():learned[i]=false
	learned[fusion_id]=true
	skill_levels[fusion_id]=clampi(rank,1,4)
	for i in slots.size():slots[i]=-1
	slots[0]=fusion_id
	cast_id=fusion_id
	var fusion:=fusion_definition_by_id(fusion_id)
	var fusion_plan:Dictionary=FusionCast.plan(int(fusion.get("a",-1)),int(fusion.get("b",-1))) if not fusion.is_empty() else {}
	carrier_id=int(fusion_plan.get("carrier",-1))
	dummy_distance=clampf(float(FusionCast.FALLBACK_REACH.get(carrier_id,DEFAULT_DISTANCE/.75))*.75,70.0,DEFAULT_DISTANCE)
	reset()

## Ausgangslage herstellen (auch für „Nochmal“).
func reset()->void:
	enemies.clear();projectiles.clear();enemy_projectiles.clear();battle_zones.clear()
	effects.clear();spell_visuals.clear();lightning_lines.clear();poison_clouds.clear()
	drops.clear()
	player_pos=ARENA_CENTER+HERO_OFFSET;facing=Vector2.RIGHT
	dummy_pos=player_pos+Vector2(dummy_distance,0)
	frame_camera()
	var dummy:=make_enemy(4,dummy_pos)
	dummy["hp"]=DUMMY_HP;dummy["max_hp"]=DUMMY_HP;dummy["uid"]=1;dummy["facing"]=Vector2.LEFT
	enemies.append(dummy)
	hp=max_hp();energy=max_energy()
	for i in cooldowns.size():cooldowns[i]=0.0
	hits=0;total_damage=0.0;cooldown_seconds=0.0

## Bildausschnitt: Die Vorschau zeigt nur PREVIEW_SIZE (halbe Spielfläche) in
## voller Größe, mittig zwischen Held und Puppe.
const PREVIEW_SIZE:=Vector2(576,324)
func frame_camera()->void:
	camera_pos=(player_pos+dummy_pos)*.5-PREVIEW_SIZE*.5+Vector2(0,-30)
	camera_smooth=camera_pos

## Einmal wirken; gibt die Abklingzeit zurück.
func cast()->float:
	reset()
	use_ability(0)
	cooldown_seconds=float(cooldowns[cast_id]) if cast_id>=0 and cast_id<cooldowns.size() else 0.0
	return cooldown_seconds

func damage_enemy(index:int,amount:int,push:Vector2,stun:bool=false,element:String="",source_peer:int=0,apply_runes:bool=true,direct_hit:bool=true)->void:
	if index<0 or index>=enemies.size():return
	var before:=float(enemies[index]["hp"])
	super(index,amount,push,stun,element,source_peer,apply_runes,direct_hit)
	if index<enemies.size():
		var dealt:=before-float(enemies[index]["hp"])
		if dealt>0.0:hits+=1;total_damage+=dealt
		# Die Puppe bleibt stehen und wird nie besiegt.
		enemies[index]["pos"]=dummy_pos
		enemies[index]["hp"]=maxf(float(enemies[index]["hp"]),DUMMY_HP*.5)

## Nur die Wirkabläufe weiterrechnen, keine Gegner-KI, kein Spawnen, keine Eingabe.
func _process(delta:float)->void:
	world_time+=delta
	for i in cooldowns.size():cooldowns[i]=maxf(0.0,float(cooldowns[i])-delta)
	shield_timer=maxf(0.0,shield_timer-delta);rage_timer=maxf(0.0,rage_timer-delta)
	drain_timer=maxf(0.0,drain_timer-delta);invulnerable=maxf(0.0,invulnerable-delta)
	attack_anim=maxf(0.0,attack_anim-delta);warrior_jump_timer=maxf(0.0,warrior_jump_timer-delta)
	update_battle_zones(delta)
	update_impact_zones(delta)
	update_poison_clouds(delta)
	update_projectiles(delta)
	for enemy in enemies:
		enemy["flash"]=maxf(0.0,float(enemy.get("flash",0.0))-delta)
		enemy["pos"]=dummy_pos
	for list in [effects,spell_visuals,lightning_lines]:
		for i in range(list.size()-1,-1,-1):
			list[i]["life"]=float(list[i]["life"])-delta
			if float(list[i]["life"])<=0.0:list.remove_at(i)
	combat_feedback.step(delta)
	# Sprünge und Stöße dürfen den Helden nicht aus dem Bild tragen.
	player_pos=player_pos.clamp(ARENA_CENTER-Vector2(420,200),ARENA_CENTER+Vector2(420,200))
	frame_camera()
	queue_redraw()
