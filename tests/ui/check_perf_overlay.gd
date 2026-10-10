extends SceneTree
# F3-Leistungsanzeige: Taste, Mittelwerte über eine Sekunde, aus = keine Arbeit.

const PerfOverlay=preload("res://components/perf_overlay.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("PERF_OVERLAY_FAIL "+label)

func _initialize()->void:
	var key:=InputEventKey.new();key.keycode=KEY_F3;key.pressed=true
	check(PerfOverlay.is_toggle_key(key),"F3 schaltet um")
	var other:=InputEventKey.new();other.keycode=KEY_F2;other.pressed=true
	check(not PerfOverlay.is_toggle_key(other),"andere Taste nicht")
	var o:=PerfOverlay.new()
	for i in 60:o.tick(1.0/60.0)
	check(o.fps==0.0,"aus: zählt nicht")
	o.visible=true
	for i in 59:o.tick(1.0/60.0)
	o.tick(0.1)
	check(o.fps>50.0 and o.fps<60.0 and o.worst_ms>99.0,"FPS und längstes Bild (%s, %s)" % [o.fps,o.worst_ms])
	check(o.text(12).contains("Gegner 12"),"Text")
	if failures>0:
		push_error("PERF_OVERLAY_FAILED %d" % failures);quit(1);return
	print("PERF_OVERLAY_OK")
	quit()
