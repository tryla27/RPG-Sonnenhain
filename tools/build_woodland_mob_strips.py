"""Pack authored 4x2 directions into the game's S,SW,W,NW,N,NE,E,SE strip.

Only crops, uniform nearest-neighbour scaling and transparent padding are used.
No painted asset pixels are created here.
"""
from pathlib import Path
import sys
from collections import deque
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "art/sprites/mobs/woodland_v2"

def build(name: str, source: str):
    image = Image.open(source).convert("RGBA")
    assert image.getchannel("A").getextrema()[0] == 0, "Source needs transparency"
    width, height = image.size
    cells = []
    if name == "moss_wolf":
        # The long side views cross nominal grid lines. Locate intact connected
        # silhouettes instead of cutting a paw or tail at a cell boundary.
        mask = bytearray(image.getchannel("A").point(lambda a: 1 if a >= 96 else 0).tobytes())
        boxes = []
        for start in range(len(mask)):
            if not mask[start]:
                continue
            mask[start] = 0
            queue = deque([start])
            left = right = start % width
            top = bottom = start // width
            count = 0
            while queue:
                at = queue.popleft()
                x, y = at % width, at // width
                left, right, top, bottom = min(left,x), max(right,x), min(top,y), max(bottom,y)
                count += 1
                for nxt in (at-width, at+width, at-1 if x else -1, at+1 if x+1<width else -1):
                    if 0 <= nxt < len(mask) and mask[nxt]:
                        mask[nxt] = 0
                        queue.append(nxt)
            if count > 2000:
                boxes.append((left,top,right+1,bottom+1))
        assert len(boxes)==8, f"Expected eight intact wolves, found {len(boxes)}"
        boxes.sort(key=lambda b: (int((b[1]+b[3])/2 >= height/2), b[0]))
        cells = [image.crop(b) for b in boxes]
    for direction in range(0 if cells else 8):
        x, y = direction % 4, direction // 4
        cell = image.crop((x*width//4, y*height//2, (x+1)*width//4, (y+1)*height//2))
        # Bound by visible artwork; low-alpha antialiasing remains in the crop.
        bounds = cell.getchannel("A").point(lambda a: 255 if a >= 96 else 0).getbbox()
        assert bounds, f"Missing direction {direction}"
        cells.append(cell.crop(bounds))
    ratio = min(76 / max(c.width for c in cells), 72 / max(c.height for c in cells))
    output = Image.new("RGBA", (96*8, 96))
    for index, cell in enumerate(cells):
        size = (max(1,round(cell.width*ratio)), max(1,round(cell.height*ratio)))
        cell = cell.resize(size, Image.Resampling.NEAREST)
        output.alpha_composite(cell, (index*96+(96-size[0])//2, 80-size[1]))
    ART.mkdir(parents=True, exist_ok=True)
    image.save(ART / "source" / f"{name}.png")
    output.save(ART / f"{name}_8dir.png")
    print(f"WOODLAND_STRIP_OK {name} 8 directions, uniform scale, transparent margins")

if __name__ == "__main__":
    build(sys.argv[1], sys.argv[2])
