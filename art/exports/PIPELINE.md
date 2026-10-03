# P012 asset contract

Original, provisional Returning Fair prototype art; no external models, paid
generators, permanent story additions or reference-project edits. Blender 5.2.2
LTS, Godot 4.7.2 Compatibility renderer. Hero/companion remain capsules.

| Source in `art/source` | Export in `game/assets/models` | Measured Godot size (m) | Triangles |
| --- | --- | --- | --- |
| `recovery_vessel.blend` | `recovery_vessel.glb` | 0.60 × 1.16 × 0.60 | 1,744 |
| `guardian.blend` | `guardian.glb` | 0.74 × 1.58 × 0.4275 | 2,052 |
| `tollworks_plinth.blend` | `tollworks_plinth.glb` | 2.00 × 0.60 × 2.00 | 756 |

Sizes above are X/Y/Z in Godot. One Blender unit = one meter, Z up, +Y forward.
glTF exporter converts to Godot Y up / -Z actor forward; no corrective axis
rotation or scale on gameplay wrappers. Ground-center root origin, identity root
and object transforms; mesh vertices carry part placement. Guardian visor/chest
face +Y in Blender; imported visor center is at negative Godot Z.

Bevel modifiers are evaluated for export. Faceted forms intentionally remain
low-poly. Materials use Principled BSDF flat base colors, metallic 0 or 1,
roughness and teal emission only. No procedural texture, transparency, rig,
animation, external texture, light or camera is required in GLB. Godot owns
lighting; its Compatibility result differs from Blender studio reflections.
Studio lights/cameras remain only in editable sources. Texture/animation naming
contracts are deferred until those features exist.

Export settings: GLB, selected asset root + its mesh children, **active scene
only**, apply modifiers, Y up, animations/cameras/lights disabled; no compression.
Each source is an isolated RF-* scene with an RF_* root. Default live Scene/Cube/
Light/Camera remains untouched; current file is not overwritten. Source files
are ordinary editable mainfiles; initial library snapshots are normalized in a
separate background process before delivery.

## Re-export an edited asset

Open its source .blend in Blender, edit mesh/materials, select only RF_* root and
mesh children, then export to the same GLB path with settings above. Keep root
origin/units/forward stable. Leave studio nodes unselected. Do not add collision
name suffixes or gameplay scripts to imported art. Godot automatically reimports;
retain `.glb.import` UID/settings and wrapper scene UIDs in Git.

Wrappers: `features/combat/guardian.tscn` retains actor script/capsule/combat marker;
`features/interaction/recovery_vessel.tscn` owns stable interaction ID/dialogue,
fixed box collision/sign; `world/tollworks.tscn` keeps fixed Plinth box collider
and instances art under `Plinth/VisualRoot` (offset -0.3m compensates existing
collider center). No imported child names are used by gameplay. Navigation bakes
layer-1 static Godot collision, never mesh art. Guardian visuals extend 0.02m
beyond capsule on each side; physics capsule remains intentionally unchanged.

`build_assets.py` creates v1 in new isolated live scenes and refuses duplicate
scene names. `reexport_vessel.py` adds front/back bronze diamond emblems (repeat
safe); it can run after loading the vessel source into live Blender. Both write
scoped library snapshots. Run `prepare_sources.py` in **background Blender**
after either script to turn task-owned snapshots into ordinary .blend mainfiles.
`render_assets.py` reopens those saved files and renders evidence without saving.
Do not run these helpers against unrelated files. No installation is needed.

After any asset edit:

```powershell
$engine = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
& $engine --headless --path game --editor --quit
& $engine --headless --path game --script res://tests/asset_pipeline_checks.gd
& $engine --path game --resolution 960x640 --script res://tests/asset_gallery.gd
```

Also play affected normal interaction/combat/collision paths. P012's actual
re-export preserved wrapper/script/quest hashes, collision and quest effects;
normal GUI save before export loaded in a fresh process after export. See
`docs/evidence/P012/VALIDATION.md`. Gallery is visual inspection only; synthetic
pipeline fixtures are not normal quest-completion evidence.
