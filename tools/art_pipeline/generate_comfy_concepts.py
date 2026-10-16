"""Reproduzierbare Konzeptserie über die lokale ComfyUI-API (keine Cloud)."""
import argparse
import json
import shutil
import time
import urllib.request
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/"art/source/comfyui"
OUT=ROOT/"art/concepts/quality_v1"
MODEL="v1-5-pruned-emaonly-fp16.safetensors"
MODEL_HASH="e9476a13728cd75d8279f6ec8bad753a66a1957ca375a1464dc63b37db6e3916"
STYLE="close up portrait painting of one person, head and shoulders only, one face centered in frame, detailed eyes, warm golden light, plain dark teal background, beautiful painterly fantasy illustration, single subject"
NEGATIVE="text, lettering, watermark, logo, extra limbs, extra fingers, blurry, disfigured, duplicate face, two people, multiple people, full body, collage, grid, contact sheet, character sheet, lineup, turban, hat, line art, sketch, anime, modern clothes, plastic, 3d render"
PROMPTS={
 "mira_portrait":STYLE+", one wise elderly woman, silver hair in a bun, purple shawl, gentle warm smile, kindly grandmother, modest clothing",
 "fenna_portrait":STYLE+", one woman with chestnut brown bob haircut, teal blouse, leather apron, friendly confident smile",
 "borin_portrait":STYLE+", one wise elderly man with short grey hair and grey beard, blue cloak, amber brooch, gentle smile",
 "moss_architecture":"stylized hand painted fantasy game environment concept, modular ancient mossy stone wall and small stone arch, orthographic three quarter view, chunky irregular pale limestone blocks, teal shadows, moss green accents, warm soft light, isolated on plain dark teal background, readable shapes, restrained detail, no people, no text"
}
def request(base,path,data=None):
    req=urllib.request.Request(base+path,data=json.dumps(data).encode() if data is not None else None,headers={"Content-Type":"application/json"})
    with urllib.request.urlopen(req,timeout=30) as response:return json.load(response)
def workflow(text,seed,name):
    return {
      "1":{"class_type":"CheckpointLoaderSimple","inputs":{"ckpt_name":MODEL}},
      "2":{"class_type":"CLIPTextEncode","inputs":{"text":text,"clip":["1",1]}},
      "3":{"class_type":"CLIPTextEncode","inputs":{"text":NEGATIVE,"clip":["1",1]}},
      "4":{"class_type":"EmptyLatentImage","inputs":{"width":512,"height":512,"batch_size":1}},
      "5":{"class_type":"KSampler","inputs":{"seed":seed,"steps":24,"cfg":7.0,"sampler_name":"dpmpp_2m","scheduler":"karras","denoise":1.0,"model":["1",0],"positive":["2",0],"negative":["3",0],"latent_image":["4",0]}},
      "6":{"class_type":"VAEDecode","inputs":{"samples":["5",0],"vae":["1",2]}},
      "7":{"class_type":"SaveImage","inputs":{"filename_prefix":"quality_v1/"+name,"images":["6",0]}}
    }
def main():
    p=argparse.ArgumentParser();p.add_argument("--base",default="http://127.0.0.1:8188");p.add_argument("--server-output",type=Path,required=True);a=p.parse_args()
    SOURCE.mkdir(parents=True,exist_ok=True);OUT.mkdir(parents=True,exist_ok=True)
    stats=request(a.base,"/system_stats")
    metadata={"model":MODEL,"sha256":MODEL_HASH,"model_source":"https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive","license":"CreativeML OpenRAIL-M; Quelle/Lizenz vor Weitergabe prüfen","system":stats,"assets":[]}
    for index,(name,prompt) in enumerate(PROMPTS.items()):
        seed=2026101621+index;graph=workflow(prompt,seed,name)
        (SOURCE/(name+".api.json")).write_text(json.dumps(graph,ensure_ascii=False,indent=2),encoding="utf-8")
        submitted=request(a.base,"/prompt",{"prompt":graph,"client_id":"sonnenhain-quality-local"})
        prompt_id=submitted["prompt_id"];deadline=time.monotonic()+900
        while time.monotonic()<deadline:
            history=request(a.base,"/history/"+prompt_id)
            if prompt_id in history:
                record=history[prompt_id]
                if record.get("status",{}).get("status_str")=="error":raise RuntimeError(record["status"])
                images=record.get("outputs",{}).get("7",{}).get("images",[])
                if images:
                    im=images[0];source=a.server_output/im.get("subfolder","")/im["filename"]
                    target=OUT/(name+".png");shutil.copy2(source,target)
                    metadata["assets"].append({"name":name,"seed":seed,"prompt":prompt,"negative":NEGATIVE,"path":str(target.relative_to(ROOT)),"status":"Entwurf, visuell prüfen"})
                    print("COMFY_CONCEPT_OK",name,flush=True);break
            time.sleep(2)
        else:raise TimeoutError(name)
    (SOURCE/"generation.json").write_text(json.dumps(metadata,ensure_ascii=False,indent=2),encoding="utf-8")
if __name__=="__main__":main()
