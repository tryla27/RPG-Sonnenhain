"""Crop and pack authored poses without painting or deforming their anatomy."""
from pathlib import Path
import sys
from collections import deque
from PIL import Image,ImageChops,ImageFilter

ROOT=Path(__file__).resolve().parents[1]
ART=ROOT / "art/sprites/mobs/wolf_v3"

def sprite_boxes(cell):
    """Extract intact animals even when a tail crosses a nominal grid line."""
    width,height=cell.size
    mask=bytearray(cell.getchannel("A").point(lambda a:1 if a>=96 else 0).tobytes())
    results=[]
    for start in range(len(mask)):
        if not mask[start]:continue
        mask[start]=0
        queue=deque([start])
        left=right=start%width
        top=bottom=start//width
        count=0
        pixels=[]
        while queue:
            at=queue.popleft()
            pixels.append(at)
            x,y=at%width,at//width
            left,right,top,bottom=min(left,x),max(right,x),min(top,y),max(bottom,y)
            count+=1
            for dy in (-1,0,1):
                for dx in (-1,0,1):
                    nx,ny=x+dx,y+dy
                    if (dx or dy) and 0<=nx<width and 0<=ny<height:
                        nxt=ny*width+nx
                        if mask[nxt]:mask[nxt]=0;queue.append(nxt)
        if count>1000:results.append(((left,top,right+1,bottom+1),pixels))
    return results

def build(direction, source):
    image=Image.open(source).convert("RGBA")
    assert image.getchannel("A").getextrema()[0]==0, "Need a transparent source"
    width,height=image.size
    boxes=sprite_boxes(image)
    assert len(boxes)==24,f"Expected 24 intact wolves, found {len(boxes)}"
    ordered={}
    for bounds,pixels in boxes:
        x=int((bounds[0]+bounds[2])*.5/(width/4))
        y=int((bounds[1]+bounds[3])*.5/(height/6))
        frame=y*4+x
        assert frame not in ordered,f"Two poses share slot {frame}"
        cell=image.crop(bounds)
        # Adjacent poses sometimes overlap bounding rectangles. A silhouette
        # mask extracts this animal only; one pixel retains its alpha fringe.
        mask=bytearray(cell.width*cell.height)
        for at in pixels:
            px,py=at%width-bounds[0],at//width-bounds[1]
            mask[py*cell.width+px]=255
        silhouette=Image.frombytes("L",cell.size,bytes(mask)).filter(ImageFilter.MaxFilter(3))
        cell.putalpha(ImageChops.multiply(cell.getchannel("A"),silhouette))
        ordered[frame]=cell
    assert set(ordered)==set(range(24)),"Every animation slot must have a whole animal"
    cells=[ordered[frame] for frame in range(24)]
    # Scale once from the idle body and preserve that size in every action.
    ratio=min(76/max(c.width for c in cells[:4]),72/max(c.height for c in cells[:4]))
    output=Image.new("RGBA",(128*24,128))
    for frame,cell in enumerate(cells):
        size=(max(1,round(cell.width*ratio)),max(1,round(cell.height*ratio)))
        assert size[0]<=116 and size[1]<=100, f"Pose {frame} needs larger margins: {size}"
        cell=cell.resize(size,Image.Resampling.NEAREST)
        output.alpha_composite(cell,(frame*128+(128-size[0])//2,104-size[1]))
    (ART / "source").mkdir(parents=True,exist_ok=True)
    (ART / "source/.gdignore").write_text("")
    image.save(ART / "source" / f"{direction}.png")
    output.save(ART / f"{direction}.png")
    print(f"WOLF_ANIMATION_ASSET_OK {direction}: 4 idle, 8 gait, 4 bite, 4 pounce, 2 hurt, 2 death")

if __name__=="__main__":build(sys.argv[1],sys.argv[2])
