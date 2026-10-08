extends RefCounted
## Dry wooden-door foley, cached once and shared by all enterable village houses.
const OPEN_PATH:="res://audio/door_open_v2.wav"
const CLOSE_PATH:="res://audio/door_close_v2.wav"
static var streams:Dictionary={}
static func make(opening:bool)->AudioStreamWAV:
	var path:=OPEN_PATH if opening else CLOSE_PATH
	if not streams.has(path):streams[path]=load(path)
	return streams[path]
