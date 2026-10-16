"""SVG-Originale, Inkscape-Exporte und geschichtete Krita-Austauschquellen."""
import argparse
import io
import json
import math
import subprocess
import zipfile
from pathlib import Path
from xml.sax.saxutils import escape
import xml.etree.ElementTree as ET
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/"art/source/inkscape"
UI=ROOT/"art/ui/quality_v1"
TEXTURES=ROOT/"art/textures/quality_v1"
KRITA=ROOT/"art/source/krita"
for folder in [SOURCE,UI,TEXTURES,KRITA]:folder.mkdir(parents=True,exist_ok=True)

def svg(width,height,body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">{body}</svg>'

def export(inkscape,name,source,dest,size=None):
    path=SOURCE/(name+".svg");path.write_text(source,encoding="utf-8")
    args=[inkscape,str(path),"--export-type=png","--export-filename="+str(dest)]
    if size:args += ["--export-width="+str(size),"--export-height="+str(size)]
    subprocess.run(args,check=True,capture_output=True)
    return path

def ora(name, layers):
    width,height=layers[0][1].size
    root=ET.Element("image",w=str(width),h=str(height),name=name,version="0.0.3")
    stack=ET.SubElement(root,"stack")
    with zipfile.ZipFile(KRITA/(name+".ora"),"w") as archive:
        archive.writestr("mimetype","image/openraster",compress_type=zipfile.ZIP_STORED)
        for index,(label,im) in enumerate(layers):
            buffer=io.BytesIO();im.save(buffer,"PNG");source=f"data/layer{index}.png"
            archive.writestr(source,buffer.getvalue())
            ET.SubElement(stack,"layer",name=label,src=source,x="0",y="0",opacity="1.0",visibility="visible",**{"composite-op":"svg:src-over"})
        archive.writestr("stack.xml",ET.tostring(root,encoding="utf-8"))

def main():
    parser=argparse.ArgumentParser();parser.add_argument("--inkscape",required=True);a=parser.parse_args()
    symbols={
      "attack":'<path d="M18 46L43 12L50 9L49 17L25 51Z" fill="#b8cccd"/><path d="M15 36L30 49M19 45L11 55" stroke="#edc16c" stroke-width="6"/>',
      "skill":'<path d="M35 7L16 35H30L25 57L49 26H35Z" fill="#b7c9ef"/><path d="M13 14L17 18M46 47L51 51" stroke="#edc16c" stroke-width="3"/>',
      "quest":'<path d="M18 12H44V53L31 47L18 53Z" fill="#edc16c"/><path d="M31 21V33M31 39V42" stroke="#31444d" stroke-width="5"/>',
      "waystone":'<path d="M24 13L33 6L42 15L39 45H25Z" fill="#9daea7"/><path d="M33 17L28 26L36 31L30 39" fill="none" stroke="#f1d487" stroke-width="3"/><path d="M15 49H49L53 56H11Z" fill="#74897d"/>',
      "cooking":'<path d="M14 28H50L46 48Q32 56 18 48Z" fill="#b77d57"/><path d="M10 28H54M23 18Q18 13 24 7M34 19Q29 14 35 8M45 19Q40 14 46 8" fill="none" stroke="#edc16c" stroke-width="4"/>',
      "fusion":'<path d="M21 11L31 30L21 51L10 30Z" fill="#87cbb8"/><path d="M44 11L55 30L44 51L33 30Z" fill="#c6a0d4"/><path d="M27 30H38M33 24V36" stroke="#fff0b9" stroke-width="4"/>'}
    for name,shape in symbols.items():
        for size in [32,64]:export(a.inkscape,name,svg(64,64,shape),UI/f"{name}_{size}.png",size)
    # Ein skalierbarer Rahmen, ohne Text und ohne eingebrannte Gegenstände.
    frame='<rect x="2" y="2" width="60" height="60" rx="5" fill="#182c35" stroke="#b3945c" stroke-width="3"/><path d="M9 17V9H17M47 9H55V17M55 47V55H47M17 55H9V47" fill="none" stroke="#f0d490" stroke-width="2"/>'
    export(a.inkscape,"item_frame",svg(64,64,frame),UI/"item_frame.png")
    colors={"stone":("#899080","#606b62","#adb49c"),"wood":("#71533e","#493e33","#aa8155"),"moss":("#58784b","#3d593e","#89a35e")}
    for name,(base,dark,light) in colors.items():
        body=f'<rect width="64" height="64" fill="{base}"/>'
        for y in range(0,64,16):
            for x in range(-16,80,32):
                shift=16 if y%32 else 0
                if name=="stone":body+=f'<path d="M{x+shift} {y}H{x+shift+32}M{x+shift} {y}V{y+16}" stroke="{dark}" stroke-width="2"/><path d="M{x+shift+3} {y+3}H{x+shift+26}" stroke="{light}"/>'
                elif name=="wood":body+=f'<path d="M{x} {y+4}Q{x+20} {y-2} {x+32} {y+5}M{x} {y+10}H{x+32}" fill="none" stroke="{dark}"/>'
                else:body+=f'<path d="M{x+shift+3} {y+3}h5v4h-5zM{x+shift+18} {y+8}h6v5h-6z" fill="{light}"/>'
        export(a.inkscape,"material_"+name,svg(64,64,body),TEXTURES/(name+".png"))
        ora("material_"+name,[("Materialdetails",Image.open(TEXTURES/(name+".png")).convert("RGBA")),("Grundfläche",Image.new("RGBA",(64,64),base))])
    # Kurze VFX-Folgen mit transparentem Hintergrund, als bearbeitbare SVG-Quelle.
    for name,color in [("fire","#f6b65a"),("frost","#91d3e2"),("poison","#b0cc65"),("hit","#fff0bc")]:
        body=""
        for f in range(8):
            radius=5+f*2.5;opacity=1-f/9
            body+=f'<g transform="translate({f*64+32},32)" opacity="{opacity}"><circle r="{radius}" fill="none" stroke="{color}" stroke-width="3"/>'
            for k in range(6):
                angle=k*math.tau/6; x=math.cos(angle)*radius;y=math.sin(angle)*radius
                body+=f'<rect x="{x-2}" y="{y-2}" width="4" height="4" fill="{color}"/>'
            body+='</g>'
        export(a.inkscape,"vfx_"+name,svg(512,64,body),UI/("vfx_"+name+".png"))
    data=json.loads((SOURCE/"map_geometry.json").read_text())
    names=["Sonnenhain","Blütenwiesen","Pilzwald","Alte Ruinen","Kristallmoor","Ascheberge","Mondküste","Sternenbruch","Nebelheide","Bernsteinforst","Tiefenquell","Dämmergrat","Himmelsgarten"]
    body='<rect width="1000" height="650" fill="#142b32"/>'
    scale=.056
    for i,(x,y,w,h) in enumerate(data["regions"]):
        fill=["#506c4b","#728551","#45654d","#7d7b62","#4d7b77","#805d4c","#4d7782","#60516e"][i%8]
        sx=36+x*scale;sy=40+y*scale;sw=w*scale;sh=h*scale
        body+=f'<rect x="{sx}" y="{sy}" width="{sw}" height="{sh}" fill="{fill}" stroke="#233d40" stroke-width="2"/>'
        body+=f'<text x="{sx+sw/2}" y="{sy+sh/2}" text-anchor="middle" font-family="sans-serif" font-size="{9 if i==0 else 12}" fill="#fff0c7">{escape(names[i])}</text>'
    for trail in data["trails"]:
        points=" ".join(f"{36+x*scale},{40+y*scale}" for x,y in trail)
        body+=f'<polyline points="{points}" fill="none" stroke="#dbbf83" stroke-width="2" opacity=".7"/>'
    for x,y in data["waystones"]:body+=f'<circle cx="{36+x*scale}" cy="{40+y*scale}" r="3" fill="#fff0c7" stroke="#223d43"/>'
    body+='<text x="36" y="615" font-family="sans-serif" font-size="14" fill="#edcf8b">SONNENHAIN · Kartenentwurf aus tatsächlichen Gebiets-, Weg- und Wegsteindaten</text>'
    export(a.inkscape,"world_map",svg(1000,650,body),UI/"world_map.png")
    print("VECTOR_ASSETS_OK",len(list(UI.glob("*.png"))))
if __name__=="__main__":main()
