extends SceneTree
const Pose=preload("res://components/woodland_pose_animation.gd")
var failures:=0
func check(value:bool,label:String)->void:
	if not value:
		failures+=1
		print("FAIL ",label)
func _initialize()->void:
	for type in 3:
		for direction in 8:
			var texture:Texture2D=Pose.Sprites.texture(Pose.path(type,direction))
			check(texture!=null,"asset %d/%d"%[type,direction])
			if texture==null:continue
			check(texture.get_size()==Vector2(3072,128),"24 whole poses")
			var image:=texture.get_image()
			for frame in 24:
				var cell:=image.get_region(Rect2i(frame*128,0,128,128))
				check(not cell.is_invisible(),"nonempty pose")
				for corner in [Vector2i.ZERO,Vector2i(127,0),Vector2i(0,127),Vector2i(127,127)]:check(cell.get_pixelv(corner).a<.01,"transparent margin")
			var gait:Dictionary={}
			for frame in range(4,12):gait[hash(image.get_region(Rect2i(frame*128,0,128,128)).get_data())]=true
			check(gait.size()>=6,"real drawn movement phases")
		check(is_equal_approx(Pose.advance_gait(type,.3,0),.3),"no movement means no stepping")
		check(is_equal_approx(Pose.advance_gait(type,.3,Pose.STRIDES[type]),.3),"one stride completes one cycle")
		var half:=Pose.advance_gait(type,.3,Pose.STRIDES[type]*.5)
		check(is_equal_approx(Pose.advance_gait(type,half,Pose.STRIDES[type]*.5),.3),"gait independent of frame rate")
	var walking:Dictionary={}
	for step in 8:walking[Pose.frame(step*TAU/8.0+.001,-1,{"walking":true})]=true
	check(walking.size()==8,"all gait poses played")
	check(Pose.frame(0,.39,{})==15 and Pose.frame(0,.4,{})==16,"release occurs at actual attack boundary")
	check(Pose.frame(0,.6,{})==18 and Pose.frame(0,.8,{})==19,"two follow-through poses")
	check(Pose.frame(0,-1,{"hurt":.18})==20 and Pose.frame(0,-1,{"hurt":.04})==21,"flinch and recovery")
	check(Pose.frame(0,-1,{"death":.1})==22 and Pose.frame(0,-1,{"death":.4})==23,"collapse and fallen")
	check(Pose.lift(0,PI,-1,{"walking":true})>5.8,"slime leaves ground mid-hop")
	check(absf(Pose.lift(0,0,-1,{"walking":true}))<.01 and Pose.lift(1,PI,-1,{"walking":true})==0,"grounded contact and beetle feet")
	if failures==0:print("WOODLAND_POSE_ANIMATION_OK 576 authored poses / 8 directions / complete movement and attack cycles / hurt and death / distance-driven gait")
	quit(1 if failures else 0)
