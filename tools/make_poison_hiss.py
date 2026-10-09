"""Pure poison air hiss: noise only, no speech source or pitched components."""
from pathlib import Path
import sys,json
import numpy as np
root=Path(__file__).resolve().parent.parent
sys.path.insert(0,str(root/'.cache/audio-python'))
import soundfile as sf
rate=48000;duration=1.2;count=round(rate*duration)
rng=np.random.default_rng(219)
frequency=np.fft.rfftfreq(count,1/rate)
# Smooth broad air bands, with no voiced harmonics or transient clicks.
air=np.clip((frequency-700)/900,0,1)*np.exp(-(frequency/7800)**2)
breath=np.exp(-((frequency-950)/850)**2)*np.clip(frequency/300,0,1)
noise=rng.normal(size=count)
spectrum=np.fft.rfft(noise)
signal=np.fft.irfft(spectrum*(air+.18*breath),n=count)
t=np.arange(count)/rate
envelope=(1-np.exp(-t/.045))*np.exp(-t/ .4)
envelope[:int(.045*rate)]*=np.sin(np.linspace(0,np.pi/2,int(.045*rate)))**2
envelope[-int(.22*rate):]*=np.cos(np.linspace(0,np.pi/2,int(.22*rate)))**2
signal*=envelope
signal-=signal.mean();signal[0]=0;signal[-1]=0
signal*=.4/np.max(np.abs(signal))
for path in [root/'docs/design/sound-references/mushroom_poison_hiss_v5.wav',root/'docs/design/sound-references/mushroom_spores_clean.wav',root/'audio/sfx/mushroom_spores_clean.wav']:
 path.parent.mkdir(parents=True,exist_ok=True);sf.write(path,signal,rate,subtype='PCM_16')
checked,_=sf.read(root/'audio/sfx/mushroom_spores_clean.wav')
assert checked[0]==0 and checked[-1]==0 and np.max(np.abs(checked))<.401
print('POISON_HISS_OK 1.2 seconds / noise only / no speech source / smooth attack and tail / zero endpoints')
