"""ComfyUI-Entwürfe als gerahmte, geschichtete Krita-Quellen vorbereiten."""
import argparse
import importlib.util
from pathlib import Path
from PIL import Image

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location("vectors",HERE/"build_vector_assets.py")
vectors=importlib.util.module_from_spec(spec);spec.loader.exec_module(vectors)
ROOT=HERE.parents[1]
def main():
    p=argparse.ArgumentParser();p.add_argument("--inkscape",required=True);a=p.parse_args()
    frame='<rect x="3" y="3" width="186" height="186" rx="8" fill="none" stroke="#213840" stroke-width="6"/><rect x="6" y="6" width="180" height="180" rx="6" fill="none" stroke="#cfaf6e" stroke-width="2"/>'
    frame_path=vectors.UI/"portrait_frame.png"
    vectors.export(a.inkscape,"portrait_frame",vectors.svg(192,192,frame),frame_path)
    for name in ["mira","fenna","borin"]:
        image=Image.open(ROOT/f"art/concepts/quality_v1/{name}_portrait.png").convert("RGBA").resize((192,192),Image.Resampling.LANCZOS)
        vectors.ora("portrait_"+name,[("Rahmen",Image.open(frame_path).convert("RGBA")),("Porträtentwurf · ComfyUI",image)])
        print("PORTRAIT_SOURCE_OK",name)
if __name__=="__main__":main()
