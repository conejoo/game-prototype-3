"""AD002 editable deterministic brush recipe; generates shared sRGB albedo only."""
from pathlib import Path
import json
import random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
REGIONS = {
    'plaster': ((0, 0, 512, 512), '#E7C98F'),
    'slate': ((512, 0, 1024, 512), '#344664'),
    'timber': ((0, 512, 512, 1024), '#735033'),
    'stone': ((512, 512, 768, 768), '#8B8C7B'),
    'amber': ((768, 512, 1024, 768), '#D8A45E'),
    'sage': ((512, 768, 768, 1024), '#71844E'),
    'linen': ((768, 768, 1024, 1024), '#E3CF9F'),
}


def main():
    rng = random.Random(2002)
    atlas = Image.new('RGB', (1024, 1024))
    recipe = {}
    for family, (rect, color) in REGIONS.items():
        x0, y0, x1, y1 = rect
        w, h = x1-x0, y1-y0
        rgb = tuple(bytes.fromhex(color[1:]))
        tile = Image.new('RGB', (w, h), rgb)
        paint = ImageDraw.Draw(tile, 'RGB')
        # Broad, broken brush dabs; no baked directional light or fine speckle.
        for _ in range(420 if w == 512 else 90):
            x, y = rng.randrange(w), rng.randrange(h)
            bw, bh = rng.randint(12, 36), rng.randint(7, 22)
            delta = rng.choice([-10, -7, -4, 4, 7, 10])
            if family == 'timber': bw, bh = rng.randint(38, 95), rng.randint(3, 9)
            tint = tuple(max(0, min(255, c+delta)) for c in rgb)
            paint.polygon([(x,y), (x+bw,y+2), (x+bw-3,y+bh), (x+2,y+bh-1)], fill=tint)
        tile = tile.filter(ImageFilter.GaussianBlur(1.3))
        # Dilate interior edge into 16px gutter. UVs never reach region boundary.
        interior = tile.crop((16,16,w-16,h-16))
        arr = np.pad(np.asarray(interior), ((16,16),(16,16),(0,0)), mode='edge')
        atlas.paste(Image.fromarray(arr), (x0,y0))
        recipe[family] = {'rect_pixels':rect, 'safe_pixels':[x0+16,y0+16,x1-16,y1-16], 'srgb':color}
    source = ROOT/'art/source/storybook'
    runtime = ROOT/'game/assets/environment/storybook'
    source.mkdir(parents=True,exist_ok=True)
    runtime.mkdir(parents=True,exist_ok=True)
    for folder in [source, runtime]: atlas.save(folder/'town-painted-albedo.png')
    (source/'town-painted-recipe.json').write_text(json.dumps({'task':'AD002','seed':2002,'size':[1024,1024], 'gutter':16,'density_texels_per_m':64,'regions':recipe},indent=2)+'\n')
    print('AD002 shared atlas: 1024 RGB sRGB, 7 regions, 16px dilated gutters')


if __name__ == '__main__': main()
