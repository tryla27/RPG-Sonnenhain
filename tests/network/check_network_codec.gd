extends SceneTree
# Verhaltenstest für components/network_codec.gd und die Weiterleitungen in main.gd.

const Codec=preload("res://components/network_codec.gd")
const Content=preload("res://components/game_content.gd")

func _initialize()->void:
	# Base36 hin und zurück, inklusive Grenzwerten.
	for value in [0,1,35,36,65535,2130706433,4294967295]:
		assert(Codec.from_base36(Codec.to_base36(value))==value)
	assert(Codec.to_base36(-7)=="0")
	assert(Codec.from_base36("zz")==Codec.from_base36("ZZ"))
	assert(Codec.from_base36("A-B")==-1)

	# IPv4 hin und zurück; ungültige Adressen werden abgelehnt.
	for address in ["127.0.0.1","192.168.1.20","0.0.0.0","255.255.255.255"]:
		assert(Codec.int_to_ipv4(Codec.ipv4_to_int(address))==address)
	for bad in ["1.2.3","1.2.3.4.5","256.0.0.1","-1.0.0.1",""]:
		assert(Codec.ipv4_to_int(bad)==-1)

	# Einladungscode: Rundreise, Kleinschreibung, Leerzeichen und Fehlerfälle.
	var code:=Codec.make_invite_code("192.168.1.20",8910)
	assert(code.begins_with("SH-"))
	assert(Codec.decode_invite_code(code)=={"address":"192.168.1.20","port":8910})
	assert(Codec.decode_invite_code("  "+code.to_lower()+" ")=={"address":"192.168.1.20","port":8910})
	assert(Codec.make_invite_code("kein.host",8910)=="")
	for bad_code in ["","XX-1-1","SH-1","SH-1-0","SH-!-1","SH-1-1EKG"]:
		assert(Codec.decode_invite_code(bad_code).is_empty())

	# Fremde Quest-/Ereigniszeilen: ungültige IDs, Duplikate und Überläufe fallen weg.
	var first_count:=int(Content.QUESTS[0]["count"])
	var rows:=Codec.sanitize_active_quest_rows([[0,999],[0,1],[-1,2],[Content.QUESTS.size(),1],[3],"x",[2,-5]])
	assert(rows==[[0,first_count],[2,0]])
	assert(Codec.sanitize_active_quest_rows(null)==[])
	assert(Codec.sanitize_active_borin_quest_rows([[0,999],[Content.BORIN_QUESTS.size(),1]])==[[0,int(Content.BORIN_QUESTS[0]["count"])]])
	assert(Codec.sanitize_active_event_rows([[1,999],[1,0]])==[[1,int(Content.WORLD_EVENTS[1]["goal"])]])

	# Belohnungs-Payload entfernt Inventaridentität und verändert das Original nicht.
	var item:={"uid":7,"stack_value":3,"name":"Waldklinge","extra":{"a":[1]}}
	var payload:=Codec.network_reward_payload(item)
	assert(not payload.has("uid") and not payload.has("stack_value"))
	assert(payload["name"]=="Waldklinge" and item.has("uid"))
	payload["extra"]["a"].append(2)
	assert(item["extra"]["a"]==[1])

	# main.gd leitet weiterhin unter den alten Namen weiter.
	var game=load("res://main.gd").new()
	assert(game.decode_invite_code(code)==Codec.decode_invite_code(code))
	assert(game.sanitize_active_event_rows([[0,99]])==Codec.sanitize_active_event_rows([[0,99]]))
	game.free()
	print("NETWORK_CODEC_OK invite codes, row sanitizing and reward payloads")
	quit()
