extends SceneTree
const Door=preload("res://components/door_sfx.gd")
func _initialize()->void:
	var opening:=Door.make(true)
	var closing:=Door.make(false)
	assert(opening!=null and closing!=null and opening!=closing)
	assert(opening==Door.make(true) and closing==Door.make(false),"Door streams should be cached")
	for stream in [opening,closing]:
		assert(stream.get_length()>0.25 and stream.get_length()<1.5)
		assert(stream.mix_rate==44100 and stream.format==AudioStreamWAV.FORMAT_16_BITS)
		assert(not stream.stereo and stream.loop_mode==AudioStreamWAV.LOOP_DISABLED)
	var game:=FileAccess.get_file_as_string("res://main.gd")
	assert(game.contains('sound_streams["door_open"] = DoorSfx.make(true)'))
	assert(game.contains('sound_streams["door_close"] = DoorSfx.make(false)'))
	assert(game.contains('play_sound("door_open")') and game.contains('play_sound("door_close")'))
	print("DOOR_SFX_OK distinct cached PCM foley, short mono non-looping clips, entrance/exit triggers unchanged")
	quit()
