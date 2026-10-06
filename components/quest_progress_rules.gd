extends RefCounted

# Monotone Fortschrittsregeln fuer einmalige Quests/Events.
# Ein hoeherer Zustand oder Fortschritt darf nie durch einen aelteren Save zurueckgesetzt werden.

static func merge_rows(previous:Variant,incoming:Variant)->Array:
	var prev:Array=previous if previous is Array else []
	var next:Array=incoming if incoming is Array else []
	var size:=maxi(prev.size(),next.size())
	var out:Array=[]
	for i in size:
		var a:Dictionary=prev[i] if i<prev.size() and prev[i] is Dictionary else {"state":0,"progress":0}
		var b:Dictionary=next[i] if i<next.size() and next[i] is Dictionary else {"state":0,"progress":0}
		out.append({
			"state":maxi(clampi(int(a.get("state",0)),0,3),clampi(int(b.get("state",0)),0,3)),
			"progress":maxi(maxi(0,int(a.get("progress",0))),maxi(0,int(b.get("progress",0))))
		})
	return out

static func merge_event_states(previous:Variant,incoming:Variant)->Array:
	var prev:Array=previous if previous is Array else []
	var next:Array=incoming if incoming is Array else []
	var size:=maxi(prev.size(),next.size())
	var out:Array=[]
	for i in size:
		var a:=clampi(int(prev[i]),0,3) if i<prev.size() else 0
		var b:=clampi(int(next[i]),0,3) if i<next.size() else 0
		out.append(maxi(a,b))
	return out

static func merge_numbers(previous:Variant,incoming:Variant)->Array:
	var prev:Array=previous if previous is Array else []
	var next:Array=incoming if incoming is Array else []
	var size:=maxi(prev.size(),next.size())
	var out:Array=[]
	for i in size:
		var a:=maxi(0,int(prev[i])) if i<prev.size() else 0
		var b:=maxi(0,int(next[i])) if i<next.size() else 0
		out.append(maxi(a,b))
	return out

static func merge_bools(previous:Variant,incoming:Variant)->Array:
	var prev:Array=previous if previous is Array else []
	var next:Array=incoming if incoming is Array else []
	var size:=maxi(prev.size(),next.size())
	var out:Array=[]
	for i in size:
		out.append((bool(prev[i]) if i<prev.size() else false) or (bool(next[i]) if i<next.size() else false))
	return out

static func merge_save_progress(previous:Dictionary,incoming:Dictionary)->Dictionary:
	var out:=incoming.duplicate(true)
	out["quests"]=merge_rows(previous.get("quests",[]),incoming.get("quests",[]))
	out["borin_quests"]=merge_rows(previous.get("borin_quests",[]),incoming.get("borin_quests",[]))
	out["event_states"]=merge_event_states(previous.get("event_states",[]),incoming.get("event_states",[]))
	out["event_progress"]=merge_numbers(previous.get("event_progress",[]),incoming.get("event_progress",[]))
	out["bosses_defeated"]=merge_bools(previous.get("bosses_defeated",[]),incoming.get("bosses_defeated",[]))
	out["rescue_state"]=maxi(clampi(int(previous.get("rescue_state",0)),0,3),clampi(int(incoming.get("rescue_state",0)),0,3))
	out["rescue_kills"]=maxi(maxi(0,int(previous.get("rescue_kills",0))),maxi(0,int(incoming.get("rescue_kills",0))))
	out["final_completed"]=bool(previous.get("final_completed",false)) or bool(incoming.get("final_completed",false))
	return out
