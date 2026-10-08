extends SceneTree
const Props=preload("res://components/village_forecourts.gd")
const SOURCE:="res://art/village/forecourts/source-v2/"
func _initialize()->void:
	DirAccess.make_dir_recursive_absolute(Props.ART_PATH)
	for kind:String in Props.SPECS:
		var image:=Image.load_from_file(SOURCE+kind+".png")
		assert(not image.is_empty(),"Missing ImageGen source: "+kind)
		image.convert(Image.FORMAT_RGBA8)
		var data:=image.get_data()
		# Suppress translucent fringes before nearest-neighbor import; retain drawn detail.
		for pixel in range(3,data.size(),4):data[pixel]=255 if data[pixel]>=230 else 0
		image=Image.create_from_data(image.get_width(),image.get_height(),false,Image.FORMAT_RGBA8,data)
		image=image.get_region(image.get_used_rect())
		var limit:Vector2i=Props.SPECS[kind]["size"]
		var factor:=minf(float(limit.x)/image.get_width(),float(limit.y)/image.get_height())
		image.resize(maxi(1,roundi(image.get_width()*factor)),maxi(1,roundi(image.get_height()*factor)),Image.INTERPOLATE_NEAREST)
		assert(image.save_png(Props.ART_PATH+kind+".png")==OK)
		print("FORECOURT_SPRITE_OK ",kind," ",image.get_size())
	quit()
