from pathlib import Path
import json
import wave
import numpy as np

folder=Path(__file__).parent
source=folder/'approved_first24.wav'
with wave.open(str(source),'rb') as w:
    sr=w.getframerate()
    channels=w.getnchannels()
    assert w.getsampwidth()==2
    raw=w.readframes(24*sr)
clip=np.frombuffer(raw,dtype='<i2').reshape(-1,channels).copy()
# A 3ms boundary repair keeps the rhythm and length intact while avoiding
# a waveform discontinuity between the two different instrumentation levels.
repair=round(.003*sr)
target=(clip[-1].astype(float)+clip[0].astype(float))/2
ramp=np.linspace(1,0,repair)[:,None]
start_delta=target-clip[0].astype(float)
end_delta=target-clip[-1].astype(float)
clip[:repair]=np.rint(clip[:repair].astype(float)+ramp*start_delta).astype('<i2')
clip[-repair:]=np.rint(clip[-repair:].astype(float)+ramp[::-1]*end_delta).astype('<i2')
loop=np.tile(clip,(5,1))
out=folder.parents[1]/'boss_golem.wav'
with wave.open(str(out),'wb') as w:
    w.setnchannels(channels);w.setsampwidth(2);w.setframerate(sr)
    w.writeframes(loop.astype('<i2').tobytes())
with wave.open(str(out),'rb') as w:
    assert w.getnframes()==120*sr
assert all(np.array_equal(loop[i*24*sr:(i+1)*24*sr],clip) for i in range(5))
report={'seconds':120,'source_seconds':[0,24],'repetitions':5,
        'boundary_repair_ms':3,'boundary_step_pcm':int(np.max(np.abs(clip[0].astype(int)-clip[-1].astype(int)))),
        'peak':float(np.max(np.abs(loop.astype(float)))/32768),
        'equal_repetitions':True,'listening_review':False}
out.with_suffix('.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print(json.dumps(report));print(out.resolve())
