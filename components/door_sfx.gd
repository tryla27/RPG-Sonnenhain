extends RefCounted
## Small procedural wooden-door sounds so every enterable house has feedback
## without adding more binary audio assets.
static func make(opening: bool) -> AudioStreamWAV:
	var rate := 22050
	var duration := 0.42 if opening else 0.28
	var frames := int(rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	var phase := 0.0
	for i in frames:
		var t := float(i) / float(rate)
		var env := pow(maxf(0.0, 1.0 - t / duration), 1.7)
		var freq := (115.0 + 42.0 * sin(t * 17.0)) if opening else (92.0 + 25.0 * sin(t * 23.0))
		phase += TAU * freq / float(rate)
		var creak := sin(phase) * 0.52 + sin(phase * 0.47) * 0.22
		var knock := 0.0
		if not opening and t < 0.055:
			knock = sin(TAU * 68.0 * t) * (1.0 - t / 0.055) * 0.85
		var sample := clampf((creak * env + knock) * 0.48, -1.0, 1.0)
		var value := int(sample * 32767.0)
		bytes[i * 2] = value & 0xff
		bytes[i * 2 + 1] = (value >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.stereo = false
	stream.data = bytes
	return stream
