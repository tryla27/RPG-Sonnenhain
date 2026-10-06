extends SceneTree

const Rules=preload("res://components/quest_progress_rules.gd")

func _initialize()->void:
	var previous:={
		"quests":[{"state":3,"progress":8},{"state":2,"progress":5}],
		"borin_quests":[{"state":3,"progress":6}],
		"event_states":[3,2],
		"event_progress":[3,4],
		"bosses_defeated":[true,false,true],
		"rescue_state":3,
		"rescue_kills":20,
		"final_completed":true
	}
	var stale:={
		"quests":[{"state":0,"progress":0},{"state":1,"progress":1}],
		"borin_quests":[{"state":0,"progress":0}],
		"event_states":[0,1],
		"event_progress":[0,1],
		"bosses_defeated":[false,false,false],
		"rescue_state":0,
		"rescue_kills":0,
		"final_completed":false
	}
	var merged:=Rules.merge_save_progress(previous,stale)
	assert(int(merged["quests"][0]["state"])==3)
	assert(int(merged["quests"][0]["progress"])==8)
	assert(int(merged["quests"][1]["state"])==2)
	assert(int(merged["quests"][1]["progress"])==5)
	assert(int(merged["borin_quests"][0]["state"])==3)
	assert(int(merged["event_states"][0])==3 and int(merged["event_states"][1])==2)
	assert(int(merged["event_progress"][0])==3 and int(merged["event_progress"][1])==4)
	assert(merged["bosses_defeated"]==[true,false,true])
	assert(int(merged["rescue_state"])==3 and int(merged["rescue_kills"])==20)
	assert(bool(merged["final_completed"]))
	var forward:=Rules.merge_save_progress(stale,{
		"quests":[{"state":1,"progress":4}],
		"borin_quests":[{"state":1,"progress":2}],
		"event_states":[1],
		"event_progress":[2],
		"bosses_defeated":[true,false,false],
		"rescue_state":1,
		"rescue_kills":2,
		"final_completed":false
	})
	assert(int(forward["quests"][0]["state"])==1 and int(forward["quests"][0]["progress"])==4)
	assert(int(forward["borin_quests"][0]["state"])==1)
	assert(int(forward["event_states"][0])==1 and int(forward["event_progress"][0])==2)
	assert(bool(forward["bosses_defeated"][0]))
	print("QUEST_PROGRESS_ONCE_OK completed quests/events/bosses never roll back")
	quit()
