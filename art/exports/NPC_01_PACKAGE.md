# Edric (`npc-01`) character package

N008 originally activated exactly one named villager. N009 adds Helena via
[NPC_02_PACKAGE](NPC_02_PACKAGE.md), preserving Edric's accepted asset and identity. The graph/portraits remain the byte-exact
N002 package; no new text, facts, event types, source roster entries or save fields.
The shared [animated pipeline](NPC_PIPELINE.md) remains authoritative.

## Identity and placement

Public reference files are `game/assets/npcs/portraits/npc-01/official-neutral.png`
and the six expression PNGs in that directory, plus `reference/npc-01/` idle/walk
sheets. Brown swept hair with grey temples, trimmed beard, blue civic coat with
gold edges, cream collar, chain/leaf medallion, green trousers and brown boots
inform the custom low-poly mesh. Head contour, nose, ears, eyes, brows, hair ridges,
beard, garments and chain are authored geometry. This is a stylized 3D adaptation,
not an exact photoreal portrait reconstruction or a recolored calibration mesh.
Only the N007 rig and baked loops are reused; hidden/back costume follows the
public idle sheet. Private development text is not copied to game assets/facts.

Stable mapping: source `npc-01` / Mayor Edric Vale / ordinary source graph to
`alderwake-npc-01-contact`, foot `(-0.5,0,-1.5)`, player approach `(-0.5,0,-0.5)`.
This is the pinned public civic contact, not a daily routine or river site.
Prompt is `Talk to Mayor Vale`; noncombatant remains outside the two-person Party.

## Actual package and repeatable pattern

- Editable `art/source/npc-01.blend`, authoring `build_npc_01.py`, owned-mainfile
  normalization and read-only source/raw audit scripts in the same directory.
- Runtime `game/assets/models/npcs/npc-01.glb`, retained import UID and explicit
  idle/walk linear-loop settings, extracted embedded palette PNG/import record.
- `NpcRegistry.ENABLED` originally enabled only npc-01; N009 also enables npc-02; `VISUAL_ASSETS` maps its named GLB.
  Existing approved `ROWS` retain placement and wrapper identity.
- `NpcWorldAdapter.build` mounts one transactional `NpcVisualPresenter` under
  `VisualRoot/Presenter`. Failure rejects the candidate location. It never mounts
  calibration for incomplete characters. Future tasks add only their completed
  named package and its registration, preserving this pattern and existing IDs.
- `GameRoot._sync_npc_visuals` forwards separate dialogue/pause/focus/travel/modal/
  death holds on controls changes and normal process ticks. Speaking turns only
  visuals toward actual player feet. Fixed contacts report zero achieved motion.
  WorldHost disposal/reconstruction owns presenter lifetime; no pose is saved.
- `npc_01_checks.gd` measures the imported skin/envelope/stance/blends and actual
  root lifecycle. `npc_01_render.gd` writes ordinary writer/reader/neutral routes
  and explicitly separate synthetic art/weather review. Use the shared runner.

Measured package: 7,614 triangles, 16 bones, one material surface, one embedded
32x32 RGBA palette (4 KiB before mips), identity meter/ground roots. Actual skin
samples and exported seam/stance measurements live in N008 acceptance evidence.
Physical capsule stays radius 0.4m/height 1.6m independently of art.

## Exposure and disclosure

Idle is ordinary runtime. Walk exists and is inspected in review, not a wandering
schedule. River-fishing belongs to N016 and is absent here. No gift transaction,
fish/item reward or routine consumer. Level-one milestone remains deferred;
introduction alone cannot reach its threshold. Only the authored Moonflower
preference fact is disclosed. Role/fishing art does not teach the other two facts.

Actual woods edges record `(areaEntered,woods,null)`; committed moonflower-01
gather records `(resourceGathered,moonflower,null)`. Source flags select first/repeat
woods lines and the exactly-once Moonflower hint. The enabled graph keeps exact
source node/choice IDs and source resolver priority. All existing durable fields
remain schema7/content1 and manual GUI Save/Load; no cursor/presenter data is saved.

For further editing open the owned mainfile rather than rerunning over artist edits.
Select its root/armature/mesh and use the shared NLA export options, including
`export_anim_slide_to_zero=True`; audit raw GLB, import loops and sample actual
Godot skin before acceptance. Existing live Blender scene/file remains untouched.
