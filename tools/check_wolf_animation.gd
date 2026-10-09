extends SceneTree
const Wolf=preload("res://components/wolf_animation.gd")
var failures:=0
func check(value:bool,label:String)->void:
	if not value:
		failures+=1
		print("FAIL ",label)
func _initialize()->void:
	for direction in 8:
		var texture:Texture2D=Wolf.Sprites.texture(Wolf.path(direction))
		check(texture!=null,"direction "+str(direction))
		if texture==null:continue
		check(texture.get_size()==Vector2(3072,128),"24 complete pose frames")
		var image:=texture.get_image()
		for frame in 24:
			var cell:=image.get_region(Rect2i(frame*128,0,128,128))
			check(not cell.is_invisible(),"nonempty pose")
			for corner in [Vector2i.ZERO,Vector2i(127,0),Vector2i(0,127),Vector2i(127,127)]:check(cell.get_pixelv(corner).a<.01,"transparent margins")
		var hashes:Dictionary={}
		for gait in range(4,12):hashes[hash(image.get_region(Rect2i(gait*128,0,128,128)).get_data())]=true
		check(hashes.size()>=6,"articulated gait has distinct drawn poses")
	var poses:Dictionary={}
	for gait in 8:poses[Wolf.frame(gait*TAU/8.0+.001,-1,"",{"walking":true})]=true
	check(poses.size()==8,"all eight walking frames used")
	check(Wolf.frame(0,-1,"",{"walking":false,"clock":.4}) in range(0,4),"animated rest")
	check(Wolf.frame(0,.1,"sprungbiss",{})==12 and Wolf.frame(0,.3,"sprungbiss",{})==16,"two crouch poses")
	check(Wolf.frame(0,.47,"sprungbiss",{})==18 and Wolf.frame(0,.56,"sprungbiss",{})==19,"flight becomes compressed landing")
	check(Wolf.frame(0,.8,"sprungbiss",{})==15,"landing rises during recovery")
	check(Wolf.frame(0,.35,"biss",{})==13 and Wolf.frame(0,.4,"biss",{})==14,"jaws open before the real bite frame")
	check(Wolf.frame(0,-1,"",{"hurt":.18})==20 and Wolf.frame(0,-1,"",{"hurt":.05})==21,"hurt and recovery poses")
	check(Wolf.frame(0,-1,"",{"death":.1})==22 and Wolf.frame(0,-1,"",{"death":.4})==23,"collapse and fallen poses")
	var phase:=Wolf.advance_gait(.3,0)
	check(is_equal_approx(phase,.3),"no sliding paws when stationary")
	var whole:=Wolf.advance_gait(.3,42)
	var split:=Wolf.advance_gait(Wolf.advance_gait(.3,21),21)
	check(is_equal_approx(whole,split),"gait independent of frame rate")
	check(is_equal_approx(Wolf.advance_gait(.3,84),.3),"stride length wraps one full gait")
	if failures==0:print("WOLF_ANIMATION_OK 192 authored poses / transparent margins / distance-driven gait / synchronized attack poses / hurt and death")
	quit(1 if failures else 0)
