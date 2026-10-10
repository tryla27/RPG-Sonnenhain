"""Editable 80-bar boss loop: 8 bars = 12 seconds at 160 BPM."""
from pathlib import Path
import json
import wave
import numpy as np

SR, BPM, SECONDS = 44100, 160, 120
BEAT = 60 / BPM
N = SR * SECONDS
music = np.zeros((N, 2))
low = np.zeros(N)

def add(bus, signal, onset, gain=1, pan=0):
    pos = round(onset*SR)
    signal = signal*gain
    if bus.ndim == 2:
        signal = signal[:,None]*np.array([np.sqrt((1-pan)/2),np.sqrt((1+pan)/2)])
    # Circular placement retains note tails across the loop boundary.
    for offset in range(0,len(signal),N):
        chunk = signal[offset:offset+N]
        start = (pos+offset)%N
        count = min(len(chunk),N-start)
        bus[start:start+count] += chunk[:count]
        if count<len(chunk): bus[:len(chunk)-count] += chunk[count:]

def tvec(length): return np.arange(round(length*SR))/SR
def hz(note): return 440*2**((note-69)/12)
def envelope(t,length,attack=.025,release=.07):
    return (1-np.exp(-t/attack))*np.clip((length-t)/release,0,1)

def horn(note,length,velocity=1):
    t=tvec(length)
    phase=2*np.pi*hz(note)*t+.018*np.sin(2*np.pi*4.7*t)
    s=sum(np.sin(k*phase+.12*k)/k**1.7 for k in range(1,7))
    return np.tanh(s*.85)*envelope(t,length,.022)*.24*velocity

def bass(note,length):
    t=tvec(length); p=2*np.pi*hz(note)*t
    return (.29*np.sin(p)+.105*np.sin(2*p)+.035*np.sin(3*p))*envelope(t,length,.032,.10)

def tekk(note,length):
    t=tvec(length); p=2*np.pi*np.cumsum(hz(note)*(1+.10*np.exp(-t*35)))/SR
    body=np.tanh(2.5*(np.sin(p)+.3*np.sin(2*p)))
    return body*envelope(t,length,.009,.035)*.15

def kick():
    t=tvec(.33)
    f=49+145*np.exp(-t*45)+650*np.exp(-t*230)
    p=2*np.pi*np.cumsum(f)/SR
    return np.tanh(2.2*np.sin(p))*(1-np.exp(-t*1800))*np.exp(-t*10)*.48

def bell(note,length):
    t=tvec(length); p=2*np.pi*hz(note)*t
    return (np.sin(p)+.22*np.sin(2*p))*envelope(t,length,.012)*np.exp(-t*1.7)*.10

def snare():
    t=tvec(.16)
    rng=np.random.default_rng(73)
    noise=rng.normal(0,1,len(t))
    # Short, softened snare rather than abrasive, continuous noise.
    noise=np.convolve(noise,np.ones(5)/5,mode='same')
    body=np.sin(2*np.pi*185*t)*np.exp(-t*28)
    return (.15*body+.24*noise*np.exp(-t*32))*(1-np.exp(-t*1500))

def added_layer_gain(onset):
    # Retire the added layers gradually in the final four bars for the loop.
    return 1 if onset<114 else max(0,(120-onset)/6)

thirds={62:65,64:67,65:69,67:70,69:72,70:74,72:76}

roots=[38,34,41,36]
chords=[[50,57,65],[50,58,65],[53,60,69],[52,55,60]]
theme=[[62,65,69,67,65],[62,65,70,69,65],
       [65,69,72,69,67],[64,67,72,67,64]]
hook=[[69,69,65,62],[70,70,65,62],[72,72,69,65],[72,67,64,62]]
# Ten 8-bar blocks. Theme is identical in blocks 0 and 1; the bass joins at 12s.
sections=["Theme","Theme + Hardtekk bass","Hook","Theme variation",
          "Attack + hook","Contrast","Theme return","Hook return",
          "Full theme","Loop transition"]
tekk_levels=[0,1,.9,.8,1,.28,.85,1,.8,0]
kick_levels=[1,1,1,.95,1,.60,1,1,1,1]
for block in range(10):
    base=block*12
    for b in range(32):
        chord_index=b//8
        onset=base+b*BEAT
        add(music,kick(),onset,kick_levels[block]*(1 if b%4==0 else .9))
        if block>=1 and b%4 in [1,3]:
            add(music,snare(),onset,.92*added_layer_gain(onset),.03)
        if block>=2 and b%4 in [0,2]:
            # Complement the existing backbeat with snares on beats 1 and 3.
            add(music,snare(),onset,.70*added_layer_gain(onset),.03)
        if block==1 and b==0:
            # First snare marks the requested 12-second entrance exactly.
            add(music,snare(),onset,.72,.03)
        if b%4==0:
            add(low,bass(roots[chord_index],3.96*BEAT),onset)
        if tekk_levels[block]:
            # One measured offbeat pulse per beat, no rattling subdivisions.
            add(low,tekk(roots[chord_index]-12,.43*BEAT),onset+.5*BEAT,tekk_levels[block])
    for phrase in range(4):
        onset=base+phrase*8*BEAT
        t=tvec(8*BEAT+.12)
        pad=sum(np.sin(2*np.pi*hz(n)*t)+.15*np.sin(4*np.pi*hz(n)*t) for n in chords[phrase])
        add(music,pad*envelope(t,8*BEAT+.12,.20,.25),onset,.038,-.25)
        lead_gain=.70 if block==5 else 1.15
        for j,(offset,length) in enumerate([(0,1.8),(2,.85),(3,.85),(4,1.8),(6,1.8)]):
            note=theme[phrase][j]
            # Articulation varies while the recognisable tune remains intact.
            velocity=(.95 if j==0 else .85)*(1+.035*np.sin(phrase+j))
            add(music,horn(note,length*BEAT,velocity),onset+offset*BEAT,lead_gain,-.08)
            add(music,horn(note-12,length*BEAT,.30),onset+offset*BEAT+.009,lead_gain,.16)
        if block in [2,4,7]:
            for j,note in enumerate(hook[phrase]):
                add(music,bell(note,.85*BEAT),onset+(j*2+.5)*BEAT,.95,.22)
        elif block in [3,6,8]:
            for j,note in enumerate(hook[phrase][2:]):
                add(music,bell(note,.7*BEAT),onset+(5+j)*BEAT,.42,.20)

# Circular temple reflections; bass remains centered and dry.
dry=music.copy()
for delay,gain in [(.043,.10),(.079,.07),(.127,.05)]:
    music+=np.roll(dry[:,::-1],round(delay*SR),axis=0)*gain
phase=(np.arange(N)/SR)%BEAT
low*=.68+.32*(1-np.exp(-phase/.04))
music+=low[:,None]*np.sqrt(.5)
music=np.tanh(music*1.05)
music*=.89/np.max(np.abs(music))
# No intro/outro fades. Last block returns to the opening instrumentation.
pcm=(music*32767).astype('<i2')
out=Path(__file__).parent/'Golem_Hardtekk_2min_Loop_v8_Onbeat_Snare.wav'
with wave.open(str(out),'wb') as w:
    w.setnchannels(2);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())
with wave.open(str(out),'rb') as w:
    assert w.getnframes()==N and w.getnchannels()==2 and w.getframerate()==SR
seam=float(np.max(np.abs(music[0]-music[-1])))
near=np.concatenate([music[-SR//2:],music[:SR//2]])
report={"duration_seconds":SECONDS,"bpm":BPM,"bars":80,
        "melody_repeat_seconds":12,"snare_entry_seconds":12,
        "harmonized_melody":False,"additional_onbeat_snare_entry_seconds":24,
        "peak":float(np.max(np.abs(music))),
        "finite":bool(np.isfinite(music).all()),"clipped_samples":int(np.sum(np.abs(pcm)>=32767)),
        "boundary_step":seam,"boundary_neighbour_max_step":float(np.max(np.abs(np.diff(near,axis=0)))),
        "sections":[{"start_seconds":i*12,"name":name} for i,name in enumerate(sections)],
        "listening_review":"Not performed; circular rendering and file checks performed."}
assert report['finite'] and report['clipped_samples']==0 and seam<.01
out.with_suffix('.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
# Two complete joins for convenient auditioning of the actual boundary.
preview=np.concatenate([pcm[-3*SR:],pcm[:3*SR],pcm[-3*SR:],pcm[:3*SR]])
with wave.open(str(out.with_name('Golem_Loop_Uebergang_v8_Pruefung.wav')),'wb') as w:
    w.setnchannels(2);w.setsampwidth(2);w.setframerate(SR);w.writeframes(preview.tobytes())
print(json.dumps(report,indent=2))
print(out.resolve())
