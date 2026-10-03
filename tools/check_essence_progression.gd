extends SceneTree

const Essence=preload("res://components/essence_system.gd")
const Books=preload("res://components/book_system.gd")

func _initialize()->void:
	var e=Essence.new()
	assert(e.total_for_level(1)==1)
	assert(e.total_for_level(40)==40)
	assert(e.total_for_level(99)==40)
	assert(e.available(40)==40)
	assert(Essence.TREE_COUNT==5)
	assert(Essence.TALENTS_PER_TREE==5)
	assert(Essence.TREE_CAP==20)
	assert(Essence.TREE_COUNT*Essence.TREE_CAP==100)
	for tree in Essence.TREE_COUNT:
		for talent in Essence.TALENTS_PER_TREE:
			assert(e.rank(tree,talent)==0)

	# Four ranks per talent and specialization gates.
	assert(e.invest(40,2,0))
	assert(e.invest(40,2,0))
	assert(not e.invest(40,2,0)) # rank 3 needs 5 points in tree
	for talent in [1,2,3]:
		assert(e.invest(40,2,talent))
	assert(e.tree_spent(2)==5)
	assert(e.invest(40,2,0)) # now rank 3
	while e.tree_spent(2)<10:
		for talent in Essence.TALENTS_PER_TREE:
			if e.rank(2,talent)<2:
				assert(e.invest(40,2,talent))
				if e.tree_spent(2)>=10:break
	assert(e.invest(40,2,0))
	assert(e.rank(2,0)==4)
	assert(e.unstable_projectile_rank()>=1)
	assert(e.unstable_projectile_radius()>0.0)
	assert(e.unstable_projectile_damage_mult()>0.0)

	var snapshot:=e.snapshot()
	var restored=Essence.new()
	restored.restore(snapshot)
	assert(restored.ranks==e.ranks)

	var b=Books.new()
	assert(b.active_cap(1)==2)
	assert(b.active_cap(10)==3)
	assert(b.active_cap(20)==4)
	assert(b.active_cap(30)==5)
	assert(b.active_cap(40)==6)
	assert(b.learn("frostgriff")==1)
	assert(b.learn("frostgriff")==2)
	assert(b.learn("frostgriff")==3)
	assert(b.learn("frostgriff")==4)
	assert(b.learn("frostgriff")==4)
	assert(b.set_active(40,"frostgriff",true))

	var main:=FileAccess.get_file_as_string("res://main.gd")
	assert(main.find('panel="essence"')>=0)
	assert(main.find("func detonate_mage_autoattack()->bool:")>=0)
	assert(main.find("rpc_mage_auto_detonate")>=0)
	assert(main.find('"essence_state"')>=0)
	assert(main.find('"book_state"')>=0)
	print("ESSENCE_SYSTEM_OK level40=40 essence; 5x20 trees; 4 ranks; book cap; mage projectile detonation")
	quit()
