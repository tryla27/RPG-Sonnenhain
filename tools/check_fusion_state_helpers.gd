extends SceneTree

const FusionState=preload("res://components/fusion_state.gd")

func _initialize()->void:
	var fusions:Array=[
		{"id":4,"a":0,"b":1,"gold":100,"max_rank":4},
		{"id":5,"a":1,"b":2,"gold":200,"max_rank":4}
	]
	var abilities:Array=[
		{"req":3},{"req":8},{"req":12},{},{"req":8},{"req":12}
	]
	var learned:Array=[true,true,false,false,false,false]
	var levels:Array=[1,1,0,0,0,0]
	var offers:=FusionState.available_fusions(fusions,learned,levels)
	assert(offers.size()==1 and int(offers[0]["id"])==4)
	assert(FusionState.can_fuse(fusions[0],learned,levels,abilities,8,100))
	assert(not FusionState.can_fuse(fusions[0],learned,levels,abilities,7,100))
	assert(not FusionState.can_fuse(fusions[0],learned,levels,abilities,8,99))
	assert(FusionState.target_slot([2,0,1],0,1,4)==1)
	assert(FusionState.target_slot([2,-1,3],0,1,4)==1)
	assert(FusionState.target_slot([2,3,5],0,1,4)==0)
	print("FUSION_STATE_HELPERS_OK offers, requirements and slot selection")
	quit()
