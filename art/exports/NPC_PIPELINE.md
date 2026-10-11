# Animated NPC asset and presenter contract

N007 extends the historical [static pipeline](PIPELINE.md). Its calibration is an
articulated checker mannequin, not a villager, likeness, completed character or
ordinary contact. Source identity, portraits and named costumes remain N008-N015.
N001/N002 pins still own reference content. No source checkout is needed at runtime.

## Authoring and export

- Blender 5.2.2 LTS, existing MCP at 127.0.0.1:9876; Godot 4.7.2 Mono Compatibility.
  The text-to-blender skill's `scripts/mcp_client.py` can use the existing connection
  when native tools are absent. Do not install a second server or change preferences.
- One unit is one meter. Blender Z up, +Y front; glTF converts to Godot Y up, -Z
  front. Ground-center model root, armature and mesh object transforms are identity.
  Mesh vertices/rest bones contain authored placement. No wrapper axis/scale repair.
- Editable source lives under `art/source/`, GLB under `game/assets/models/npcs/`.
  Calibration: `npc_calibration.blend` / `npc_calibration.glb`. Named character paths
  should include actual source ID (`npc-01`, etc.). Imported art stays inside the
  wrapper's VisualRoot; physics, NPC/instance IDs and navigation stay outside it.
- Calibration has 16 deform bones: root, hips, spine, head, and thigh/shin/foot/
  upper_arm/forearm/hand with `.L`/`.R`. All non-root joints parent to root; baked
  absolute segment poses form an intentionally simple rigid diagnostic rig. This
  demonstrates skinning and is not a mandatory anatomical hierarchy. Named assets
  may use a proper connected deformation rig with at most 32 exported bones.
- Export a single asset root, mesh and deform rig from the active asset scene.
  GLB, Y-up, skins, named skins, selected objects, baked sampling at 30 fps,
  `export_animation_mode='NLA_TRACKS'`, `export_force_sampling=True`, frame step 1,
  **`export_anim_slide_to_zero=True`**. Blender frame 1 must export at t=0, or stance
  synchronization and durations fail. Export no cameras, lights, collisions,
  gameplay scripts, drivers, constraints or external URIs. Authoring constraints
  must be baked to joint transforms. No root motion: wrapper owns achieved motion.
- Required baseline exported clips are `idle` and `walk`, with matching endpoint
  transforms. Extra authored actions must use an explicit source mapping. Reserve
  `action_river_fishing` for npc-01's source `river-fishing`, `action_archive_work`
  for npc-02's source `archive-work`; N016 owns their export/exposure. Calibration
  has no semantic action, gift, profession reward, routine or story attachment.
  N016 supplies separate [action variants](NPC_ACTIONS.md), with explicit
  supporting-hand accessories and review-only exposure. Ordinary named assets
  retain their original two clips and fixed civic placement.
- Idle/walk import as `Animation.LOOP_LINEAR`. Retain `.glb.import` UID and these
  subresource settings: `animations/idle/settings/loop_mode=1` and equivalent walk
  entry (nested animations dictionary). Do not mutate shared Animation resources
  at runtime to hide a missing export/import contract. Immutable glTF channels
  may use STEP; moving keys must use LINEAR or an explicitly validated interpolator.
- Opaque Principled PBR with base color, roughness, metallic and optional baked
  UV textures. Calibration includes one packed 32x32 checker and two color-only
  materials. GLB embeds PNG bytes. Godot also extracts a local PNG/import record;
  retain it with the asset. No Blender procedural shader or external file is needed.
  No transmission/alpha dependence in Compatibility. Named portraits stay separate.

`build_npc_calibration.py` creates a new owned RF-NpcCalibration scene and restores
the user's prior scene. It refuses an existing calibration scene. It writes a scoped
library snapshot; `normalize_npc_calibration.py` opens only that owned file in a
background Blender process and saves it as an ordinary editable mainfile. Default
live vessel scene/file remains authoritative and unchanged. Do not rerun generation
over an artist's edited source. Open the delivered .blend for further edits; select
its root/rig/mesh and re-export using the animated settings above. Solo the desired
NLA track while previewing; both tracks remain available for export.

## Presenter interface and lifecycle

`NpcVisualPresenter` is a script on a Godot Node3D child under VisualRoot, never
on the imported model or wrapper body. `mount(PackedScene, authored_walk_speed)`
returns errors and publishes one accepted model only after validation. Missing rig,
clips, nonlooping clips, gameplay/studio nodes, wrong root transform or excessive
geometry reject while preserving any previously accepted model.

`set_locomotion(achieved_speed_mps)` selects idle below 0.001 m/s, otherwise walk
at achieved speed / authored speed, with a 0.12 s blend. Pass actual displacement
speed after collision; desired velocity can cause sliding against walls. The
presenter does not move its wrapper or infer a route. `face_direction(Vector3)`
rotates only visuals, using Godot -Z forward; zero/nonfinite input rejects.

`suspend(reason)` / `resume(reason)` maintain independent holds. Dialogue, pause,
focus loss and travel owners must use separate reason strings; clearing one cannot
clear another. Holds freeze exported pose/speed; latest achieved speed resumes only
after the last hold clears. A scene-owner removal frees the presenter/model. No
memory, cursor, clip, bone, transform or hold state goes into schema7 saves.
N016 extends this API with explicit `set_action`, `cancel_action` and
`active_action`; its allowlisted variants/prop and freeze/cancel policy are in
[NPC_ACTIONS](NPC_ACTIONS.md). Pause/focus now call `AnimationPlayer.pause()`
as well as zero speed, preserving pending mixer state until the last hold clears.
Engine process inheritance also respects ordinary tree pause. N007 verifies these
interfaces as fixtures; N008-N015 must connect their actual root/modal/lifecycle
owners and prove ordinary behavior. Production NpcRegistry.ENABLED remains empty.
Fixed contacts stay idle; walking is review-only unless a later approved clear lane
and actual movement owner are implemented. Generic calibration never fills a
named character's art requirement.

## Measured calibration and eight-actor budget

The steady exported walk is 0.8 s at 0.8 m/s, two alternating 0.4 s stance phases;
each planted ankle moves backward at exactly wrapper speed while the swing foot
lifts 7.5 cm. Idle is 4 s with 6 mm body breathing and fixed soles. Validation samples
the actual Godot skin at 120 Hz, not only static mesh AABBs. Steady world-space
stance is tested over two cycles for both feet; blends are checked for continuity
and ground penetration separately.

| Cost | One calibration | Eight calibration | Per-person production limit | Eight-person estimate at limit |
| --- | ---: | ---: | ---: | ---: |
| Exported triangles | 204 | 1,632 | 12,000 | 96,000 |
| Skeleton bones | 16 | 128 | 32 | 256 |
| Mesh/material surfaces | 3 | 24 | 3 | 24 |
| Base-color texture bytes before mips | 4 KiB | 32 KiB | 4 MiB (one RGBA 1024² atlas) | 32 MiB |

At the limit, one shadow pass can add up to 24 surface draws and 96,000 triangles;
one RGBA atlas per person with a full mip chain estimates 42.7 MiB for eight unique
atlases. Extra normal/roughness textures must be counted separately and justified.
These are explicit town-crowd planning caps, not a measured guarantee for a fully
populated map. The eight-rig review records frame wall timing, GPU/renderer and
actual cost; N017 owns full-map performance regression with the final characters.
Runtime mount enforces geometry/bone/surface limits. Asset review must separately
enforce texture and clip bounds against each person's placement/capsule.

Measured calibration idle bounds: X 0.68 m, Y 1.5605 m, Z 0.3095 m. Walk envelope:
X 0.6811 m, Y 1.5602 m, Z 0.6 m. Ground minimum 0 m. Full bounds are comfortably
within the 0.4 m horizontal contact reservation; physics capsule remains radius
0.4 m/height1.6 m. Named assets require their own deformed-envelope measurements.

## Verification and review

Run from the repository root after finishing all edits:

```powershell
& $python art/source/audit_npc_calibration.py
./tools/run_checks.ps1 -Task N007 -Import -Names npc_asset_pipeline_checks,asset_pipeline_checks,application_smoke -RenderScript npc_asset_pipeline_render -RenderPhases review -TimeoutSeconds 150
```

Use the installed analysis Python path from text-to-blender runtime instructions.
First import may generate UIDs/texture records; the shared runner correctly retains
that attempt as failed source-change evidence. Rerun against stable metadata, never
disable its guards. Raw GLB audit verifies embedded PNG/no external URI, skins,
authored raw endpoints/durations and root-motion exclusion before Godot import.

`res://tests/review/npc_asset_review.tscn` is a labeled review scene. The rendered
runner captures eight imported rigs in day/night studio light, loop phases, close
front/profile, actual default gameplay overhead scale (size18/offset10,14,16), real
idle-to-walk blends and a suspended pose. CPU skin probes measure bounds, foot
plant and seam independently. Viewed capture sheets and full-size frames are required;
engine exit alone is insufficient. Studio night is not live weather acceptance.

Tests mount calibration only in a synthetic scene-owned contact and verify stable
IDs/body transforms/capsule, invalid replacement rollback and travel disposal.
Existing static asset checks and startup remain required regressions. No ordinary
eight-person route, final named art, native package or semantic-action claim belongs
to this review. See [N007 acceptance](../../docs/villagers-dialogue/N007_ACCEPTANCE.md).


Current named deliveries: [Edric](NPC_01_PACKAGE.md) and [Helena](NPC_02_PACKAGE.md)
are enabled after N008/N009; historical empty-activation/calibration evidence above
retains its original N007 scope. Fixed runtime idle and review-only walk retain the
same export/presenter contract; semantic actions remain N016.

## AD012 painted surface adapter

The current named roster receives its storybook finish inside `NpcVisualPresenter.mount`
after the original portable asset passes the unchanged import audit. The explicit
`StorybookNpcMaterial.ASSETS` list includes all eight named ordinary packages and
the two existing action variants; calibration and unknown assets remain unchanged.
Surface overrides retain original mesh/UV/skin/animation resources, palette PNGs,
portraits, feet, bounds and accessory visibility. Do not bake this runtime finish
back over the recoverable original identity sources.

[Editable recipe](../source/storybook/npc-painted-recipe.json) and the native Godot
adapter/shader own the appearance. Original 32x32 RGBA identity palettes remain
nearest-sampled. The already-resident town atlas contributes only broad, bounded
brush value through local rest-space triplanar projection at 96 texels/m; mirrored
16px-safe plaster sampling covers front/back/sides without changing palette UVs.
Six-percent desaturation retains costume distinctions; .90-1.08 brush multiplier,
.94 roughness, .25 specular and zero metallic provide a quiet matte finish.
Double-sided rendering matches every original named body/accessory material.
There is no time/world-space input, alpha, emission, outline, new texture, material
surface or light. Materials cache by immutable imported source material and reuse
across mounts. Eight unique identity palettes still cost 32KiB before mips; the
shared brush atlas is existing world residency, not another per-person allocation.
Original per-person triangle/bone/surface and texture-memory caps remain intact.

Historical named/calibration checks explicitly disable the optional routine owner
in their fixed-contact fixtures. Edric/Helena body-envelope fixtures explicitly
mount their original ordinary packages; action variants retain separate checks.
All original physical, identity, clip and lifecycle assertions remain. Current
routine presentation/activation tests exercise the active production mappings
separately. This fixture adaptation makes no production routine or placement change.
