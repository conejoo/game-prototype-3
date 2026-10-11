"""AD006 reproducible shared RGB albedo; no geometry or directional lighting."""
from pathlib import Path
import json
import random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
REGIONS = {'dock': ((0,0,512,512),'#62442E'),
           'plaza': ((512,0,1024,512),'#777C73'),
           'wall': ((0,512,1024,1024),'#74796F')}

def main():
    rng = random.Random(6006)
    atlas = Image.new('RGB',(1024,1024))
    records = {}
    for family,(rect,swatch) in REGIONS.items():
        x0,y0,x1,y1=rect; w,h=x1-x0,y1-y0
        rgb=tuple(bytes.fromhex(swatch[1:])); tile=Image.new('RGB',(w,h),rgb)
        draw=ImageDraw.Draw(tile)
        for _ in range(360 if family!='wall' else 650):
            x,y=rng.randrange(w),rng.randrange(h)
            dx,dy=(rng.randint(25,65),rng.randint(4,10)) if family=='dock' else (rng.randint(12,30),rng.randint(7,20))
            shift=rng.choice([-8,-5,-3,3,5,8])
            draw.polygon([(x,y),(x+dx,y+1),(x+dx-2,y+dy),(x+2,y+dy-1)],fill=tuple(max(0,min(255,c+shift)) for c in rgb))
        if family!='dock':
            # Quiet symmetric mortar/contact accents, not cast sun shadows.
            row_h=32 if family=='plaza' else 24
            for y in range(16,h,row_h):
                draw.line((0,y,w,y),fill=tuple(c-10 for c in rgb),width=2)
                x=(24 if (y//row_h)%2 else 0)
                while x<w:
                    step=rng.choice([40,48,56])
                    draw.line((x,y,x,y+row_h),fill=tuple(c-10 for c in rgb),width=2)
                    x+=step
        tile=tile.filter(ImageFilter.GaussianBlur(1.1))
        interior=np.asarray(tile.crop((16,16,w-16,h-16)))
        atlas.paste(Image.fromarray(np.pad(interior,((16,16),(16,16),(0,0)),mode='edge')),(x0,y0))
        records[family]={'rect_pixels':rect,'safe_pixels':[x0+16,y0+16,x1-16,y1-16],'srgb':swatch}
    for folder in ['art/source/storybook','game/assets/environment/storybook']:
        atlas.save(ROOT/folder/'dock-painted-albedo.png')
    recipe={'task':'AD006','seed':6006,'size':[1024,1024],'gutter':16,'density_texels_per_m':64,'regions':records,
            'coverage':'Original module planar face UVs; shared world-metre stone projection for exact low-wall prisms and semantic cobblestone.',
            'joints_m':{'plaza_row':0.5,'wall_row':0.375,'stone_width':[0.625,0.75,0.875]},
            'import':'RGB sRGB, lossless, mipmaps, linear mip filter, clamp; no alpha/normal/displacement/directional shadow'}
    (ROOT/'art/source/storybook/dock-painted-recipe.json').write_text(json.dumps(recipe,indent=2)+'\n')
    print('AD006 shared1024 RGB atlas,64 texels/m,16px gutters')

if __name__=='__main__': main()
