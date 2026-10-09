extends SceneTree
const Art=preload("res://components/woodland_mob_art.gd")
var failures:=0
func check(value:bool,label:String)->void:
	if not value:
		failures+=1
		print("FAIL ",label)
func _initialize()->void:
	check(Art.direction_index(Vector2.RIGHT)==6 and Art.direction_index(Vector2.LEFT)==2,"east/west face the actual target")
	check(Art.direction_index(Vector2.UP)==4 and Art.direction_index(Vector2.DOWN)==0,"north/south heading")
	for type in 4:
		var texture:Texture2D=Art.Sprites.texture(Art.PATHS[type])
		check(texture!=null,"asset "+str(type))
		if texture==null:continue
		check(texture.get_width()==int(Art.SIZES[type].x)*8,"eight complete directions")
		check(texture.get_height()==int(Art.SIZES[type].y),"frame height")
		var image:=texture.get_image()
		for direction in 8:
			var cell:=image.get_region(Rect2i(direction*int(Art.SIZES[type].x),0,int(Art.SIZES[type].x),int(Art.SIZES[type].y)))
			check(not cell.is_invisible(),"nonempty direction")
			for corner in [Vector2i.ZERO,Vector2i(cell.get_width()-1,0),Vector2i(0,cell.get_height()-1),Vector2i(cell.get_width()-1,cell.get_height()-1)]:
				check(cell.get_pixelv(corner).a<.01,"transparent sprite corner")
		for progress in [0.0,.4,.55,.86,1.0]:
			var pose:=Art.pose(type,0.0,progress)
			check(absf(float(pose["lunge"]))<=8.01,"bounded visual lunge")
			check(Vector2(pose["stretch"]).x>.7 and Vector2(pose["stretch"]).y>.7,"upright intact anatomy")
		var end:=Art.pose(type,0.0,1.0)
		check(Vector2(end["offset"]).is_zero_approx() and is_zero_approx(float(end["lunge"])),"attack returns to ground anchor")
	if failures==0:print("WOODLAND_MOBS_OK transparency, eight directions, grounded combat poses")
	quit(1 if failures else 0)
