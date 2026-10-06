extends SceneTree

class TestGame extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	root.add_child(g)
	g.remote_players={
		1:{"context":"world","instance_id":"world","pos":[100.0,100.0]},
		2:{"context":"world","instance_id":"world","pos":[180.0,100.0]},
		3:{"context":"world","instance_id":"world","pos":[2200.0,100.0]},
		4:{"context":"dungeon","instance_id":"dungeon:1","pos":[160.0,100.0]}
	}
	var normal:={"type":0,"pos":Vector2(100,100),"damage_by_peer":{},"damage_at_by_peer":{}}
	assert(g.server_party_quest_eligible(1,1,normal),"Killer keeps own quest progress")
	assert(g.server_party_quest_eligible(2,1,normal),"Nearby party member shares normal quest progress")
	assert(not g.server_party_quest_eligible(3,1,normal),"Far party member gets no normal quest progress")
	assert(not g.server_party_quest_eligible(4,1,normal),"Different context gets no quest progress")

	var now:=Time.get_ticks_msec()
	var boss:={"type":12,"pos":Vector2(100,100),"damage_by_peer":{2:50},"damage_at_by_peer":{2:now}}
	assert(g.server_party_quest_eligible(1,1,boss),"Boss killer keeps own boss progress")
	assert(g.server_party_quest_eligible(2,1,boss),"Nearby recent contributor shares boss progress")
	boss["damage_by_peer"]={}
	assert(not g.server_party_quest_eligible(2,1,boss),"Non-contributor gets no boss progress")
	boss["damage_by_peer"]={2:50}
	boss["damage_at_by_peer"]={2:now-g.PARTY_BOSS_ACTIVITY_MS-1}
	assert(not g.server_party_quest_eligible(2,1,boss),"Stale contributor gets no boss progress")
	boss["damage_at_by_peer"]={3:now}
	boss["damage_by_peer"]={3:50}
	assert(not g.server_party_quest_eligible(3,1,boss),"Far contributor gets no boss progress")
	print("PARTY_QUEST_ELIGIBILITY_OK range context and boss contribution enforced")
	g.queue_free()
	quit()
