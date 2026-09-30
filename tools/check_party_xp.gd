extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready() -> void: pass
	func _process(_delta: float) -> void: pass
	func _draw() -> void: pass
	func save_game() -> void: pass
	func ack_server_transaction(_tx: String) -> void: pass

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var g = TestGame.new()
	root.add_child(g)
	g.konflux_preview_mode = true
	g.remote_players = {2:{"level":7},3:{"level":40}}
	var low_xp: int = g.server_party_member_xp(1,0,2)
	assert(low_xp > 0)
	assert(g.server_party_member_xp(1,0,3) == 0) # Overleveled member alone loses XP.
	g.remote_players[3]["level"] = 100
	assert(g.server_party_member_xp(1,0,2) == low_xp)
	g.network_mode = "client"
	g.level = 7
	g.xp = 0
	g.rpc_server_party_progress({"tx":"partyxp:100:low","xp":low_xp})
	assert(g.xp == low_xp)
	g.rpc_server_party_progress({"tx":"partyxp:100:low","xp":low_xp})
	assert(g.xp == low_xp) # Repeated packets never give duplicate XP.
	g.rpc_server_combat_reward("reward:101:low",1,low_xp,3,[])
	assert(g.xp == low_xp*2) # Killing party member receives XP in its loot transaction.
	g.rpc_server_combat_reward("reward:101:low",1,low_xp,3,[])
	assert(g.xp == low_xp*2)
	print("PARTY_XP_OK level7 reward=",low_xp," alongside levels40/100, visible party reward, killer reward, duplicate protection")
	g.queue_free()
	await process_frame
	quit()
