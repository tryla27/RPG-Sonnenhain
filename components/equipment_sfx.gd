extends RefCounted
## Procedural equipment rustle/clink so equip and unequip feedback does not depend on binary audio assets.
static func make(equipping: bool) -> AudioStreamWAV:
	var rate:=22050
	var duration:=0.24 if equipping else 0.20
	var frames:=int(rate*duration)
	var bytes:=PackedByteArray()
	bytes.resize(frames*2)
	var phase:=0.0
	for i in frames:
		var t:=float(i)/float(rate)
		var env:=pow(maxf(0.0,1.0-t/duration),1.55)
		var base_freq:=150.0 if equipping else 118.0
		phase+=TAU*(base_freq+28.0*sin(t*36.0))/float(rate)
		var cloth:=sin(phase)*0.32+sin(phase*1.73)*0.16
		var clink:=0.0
		var hit_t:=0.035 if equipping else 0.022
		if t<hit_t:
			clink=sin(TAU*(720.0 if equipping else 520.0)*t)*(1.0-t/hit_t)*0.72
		var tail:=sin(TAU*245.0*t)*0.16*env
		var sample:=clampf((cloth*env+clink+tail)*0.58,-1.0,1.0)
		var value:=int(sample*32767.0)
		bytes[i*2]=value&0xff
		bytes[i*2+1]=(value>>8)&0xff
	var stream:=AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=rate
	stream.stereo=false
	stream.data=bytes
	return stream
