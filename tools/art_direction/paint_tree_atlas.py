"""AD003 editable, deterministic broad foliage/bark brush recipe (sRGB)."""
from pathlib import Path
import json
import random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]


def main():
    rng = random.Random(3003)
    atlas = Image.new('RGB', (1024, 1024))
    regions = {}
    for name, x0, rgb in [('foliage', 0, (115, 140, 54)), ('bark', 512, (115, 80, 51))]:
        tile = Image.new('RGB', (512, 1024), rgb)
        paint = ImageDraw.Draw(tile)
        for _ in range(280):
            x, y = rng.randrange(512), rng.randrange(1024)
            w, h = (rng.randint(24, 68), rng.randint(18, 52)) if name == 'foliage' else (rng.randint(5, 15), rng.randint(35, 100))
            delta = rng.choice([-9, -6, -3, 3, 6, 9])
            color = tuple(max(0, min(255, c + delta)) for c in rgb)
            paint.polygon([(x, y), (x+w, y+3), (x+w-3, y+h), (x+2, y+h-2)], fill=color)
        tile = tile.filter(ImageFilter.GaussianBlur(2))
        tile = Image.fromarray(np.pad(np.asarray(tile.crop((16,16,496,1008))), ((16,16),(16,16),(0,0)), mode='edge'))
        atlas.paste(tile, (x0,0))
        regions[name] = {'safe_pixels':[x0+16,16,x0+496,1008], 'srgb':'#'+bytes(rgb).hex()}
    for folder in ['art/source/storybook', 'game/assets/environment/storybook']:
        atlas.save(ROOT/folder/'tree-painted-albedo.png')
    recipe = {'task':'AD003','seed':3003,'size':[1024,1024],'gutter':16,'density_texels_per_m':48,
              'regions':regions,'policy':'broad low-contrast dabs; vertical bark strokes; no directional light baked'}
    (ROOT/'art/source/storybook/tree-painted-recipe.json').write_text(json.dumps(recipe,indent=2)+'\n')
    print('AD003 shared tree atlas: 1024 RGB sRGB, foliage/bark, 16px dilated gutters')


if __name__ == '__main__': main()
