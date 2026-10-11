extends RefCounted
# Anonyme Lastmessung: CPU je Serverbild, Weltpaket-Bytes und Warteschlangen.
var elapsed := 0.0
var frames := 0
var cpu_us := 0
var peak_us := 0
var snapshot_count := 0
var snapshot_bytes := 0
var snapshot_encode_us := 0
var skipped := 0

func record_snapshot(bytes: int, encode_us: int) -> void:
	snapshot_count += 1
	snapshot_bytes += bytes
	snapshot_encode_us += encode_us

func frame_done(us: int, delta: float) -> void:
	elapsed += delta
	frames += 1
	cpu_us += us
	peak_us = maxi(peak_us,us)
	if elapsed < 60.0: return
	printerr("SERVER_PERF cpu_avg=%.3fms cpu_max=%.3fms world_kib_s=%.2f packets=%d encode_avg=%.3fms deferred=%d" % [float(cpu_us)/maxi(1,frames)/1000.0,float(peak_us)/1000.0,float(snapshot_bytes)/maxf(1.0,elapsed)/1024.0,snapshot_count,float(snapshot_encode_us)/maxi(1,snapshot_count)/1000.0,skipped])
	elapsed=0.0;frames=0;cpu_us=0;peak_us=0
	snapshot_count=0;snapshot_bytes=0;snapshot_encode_us=0;skipped=0
