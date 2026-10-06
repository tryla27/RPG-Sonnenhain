extends SceneTree

class TestGame extends "res://main.gd":
	func _ready()->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	root.add_child(g)
	g.bosses_defeated=[true,true,true]
	for gate in g.VILLAGE_GATES:g.opened_village_gates[gate]=true

	var checked:=0
	for trail in g.TRAILS:
		for i in range(trail.size()-1):
			var a:Vector2=trail[i]
			var b:Vector2=trail[i+1]
			var dir:Vector2=(b-a).normalized()
			var side:=dir.rotated(PI*.5)
			var count:=maxi(1,ceili(a.distance_to(b)/48.0))
			for n in range(count+1):
				var p:=a.lerp(b,float(n)/float(count))
				if g.region_at(p)==0:continue
				for offset in [0.0,-22.0,22.0]:
					var sample:Vector2=p+side*float(offset)
					assert(not g.terrain_blocked(sample,16.0),"Main trail blocked at %s" % sample)
				checked+=1

	var bush:={"zone":8,"radius":70.0}
	assert(is_zero_approx(g.obstacle_collision_radius(bush)),"Bush obstacles must be walk-through")
	assert(g.obstacle_collision_radius({"zone":1,"radius":70.0})<=18.0)
	assert(g.obstacle_collision_radius({"zone":3,"radius":70.0})<=30.0)
	assert(g.obstacle_collision_radius({"zone":11,"radius":70.0})<=26.0)

	for zone in range(1,13):
		var found_tree:=false
		var bounds:Rect2=g.region_rect(zone).intersection(Rect2(Vector2.ZERO,g.WORLD))
		var min_tx:=floori(bounds.position.x/64.0)
		var max_tx:=ceili(bounds.end.x/64.0)
		var min_ty:=floori(bounds.position.y/64.0)
		var max_ty:=ceili(bounds.end.y/64.0)
		for tx in range(min_tx,max_tx):
			for ty in range(min_ty,max_ty):
				var tree:=g.decorative_tree_in_cell(tx,ty)
				if tree.is_empty():continue
				assert(float(tree["radius"])<=14.0,"Tree trunk collision too large in region %d" % zone)
				found_tree=true
				break
			if found_tree:break

	print("WORLD_TRAVERSAL_CLEARANCE_OK samples=",checked," bushes=walkthrough tree_trunks<=14")
	g.queue_free()
	quit()
