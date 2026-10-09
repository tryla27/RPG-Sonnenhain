"""Pack isolated pose silhouettes using the tested wolf extraction pipeline."""
from pathlib import Path
import sys
import build_wolf_animation as pack

ROOT=Path(__file__).resolve().parents[1]

def build(mob,direction,source):
    assert mob in ("forest_slime","flower_beetle","mushroom")
    pack.ART=ROOT / "art/sprites/mobs/woodland_v3" / mob
    pack.build(direction,source)
    print(f"WOODLAND_ANIMATION_ASSET_OK {mob} {direction}")

if __name__=="__main__":build(*sys.argv[1:])
