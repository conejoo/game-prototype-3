"""P012 visible revision. Run in live Blender with RF-RecoveryVessel loaded.

Adds bronze diamond emblems using existing export-compatible material. Does not
edit any Godot wrapper, ID, collision, script or quest data. Repeat is safe.
"""
import bpy
import json
import math
import contextlib
from pathlib import Path
from mathutils import Matrix

ROOT = Path(__file__).resolve().parents[2]
path = ROOT / 'art/source/build_assets.py'
helpers = {'__name__': 'author_helpers', '__file__': str(path)}
exec(compile(path.read_text(), str(path), 'exec'), helpers)
scene = bpy.data.scenes['RF-RecoveryVessel']
asset_root = scene.objects['RF_RecoveryVessel']
trim = scene.objects['GEO-vessel-rib-0'].data.materials[0]
for name, y in [('vessel-return-mark', 0.275), ('vessel-return-mark-back', -0.275)]:
    existing = scene.objects.get('GEO-' + name)
    if existing is None:
        existing = helpers['box'](scene, name, (0, y, 0.56),
            (0.16, 0.035, 0.16), trim, asset_root, 0.012,
            Matrix.Rotation(math.pi/4, 3, 'Y'))
    existing.data.materials[0] = trim
with (ROOT / 'docs/evidence/P012/blender-reexport-v2.log').open('w') as log, contextlib.redirect_stdout(log):
    report = helpers['save_export'](scene, asset_root, 'recovery_vessel')
(ROOT / 'docs/evidence/P012/asset-manifest-v2.json').write_text(json.dumps(report, indent=2))
print(json.dumps(report))
