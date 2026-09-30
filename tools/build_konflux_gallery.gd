extends SceneTree
func _initialize() -> void:
	var source: String=OS.get_environment("KONFLUX_BOARDS")
	var dest: String=OS.get_environment("KONFLUX_GALLERY")
	DirAccess.make_dir_recursive_absolute(dest)
	for file in DirAccess.get_files_at(source):
		if not file.ends_with(".png"): continue
		var img:=Image.load_from_file(source+"/"+file)
		img.convert(Image.FORMAT_RGB8)
		img.save_jpg(dest+"/"+file.get_basename()+".jpg",0.94)
	print("KONFLUX_GALLERY_OK")
	quit()
