# Harlan Reed (`npc-04`) dock contact package

N011 activates the pinned public dock/control-hut foot `(41,0,17)`, approach
`(42.5,0,17)`, instance `alderwake-npc-04-contact`, source prompt
`Talk to Harlan Reed`. The source town transform remains
`X=(sx-704)/32`, `Z=(sy-576)/32`; target support determines Y. No town snapshot,
quay, building, water surface, ship stage, gate or service is changed.
Pinned source `alderwake:harlan-dockmaster-01`, anchor
`harlan-sluice-practice-01`, foot `(2016,1120)` in `assets/maps/mvp_world.json`
maps exactly to this target foot. Anchor provenance grants no sluice capability.

## Character asset

Editable `art/source/npc-04.blend` opens on `RF-Npc04-Harlan`, with root,
16-bone armature and custom skin. `build_npc_04.py` loads only the delivered
calibration rig/clips and authors Harlan's shaped square jaw, weathered face,
short tousled brown hair/gray temples, close beard, teal vest/brass buttons,
rust neckerchief/brass slide, rolled cream sleeves, brown trousers and boots.
Official portrait and idle front/back/profile sheet are public appearance
authority. Hidden geometry is a stylized adaptation, not an exact reconstruction.
No existing villager skin or recolored calibration mannequin substitutes for it.

`normalize_npc_04.py` normalizes only the owned snapshot's active scene and
dependency names, re-exports it and saves an ordinary editable mainfile.
`check_npc_04_source.py` audits identity transforms, rig, packed image and no
drivers/constraints. `audit_npc_04.py` audits actual GLB bytes, embedded PNG,
budget, clip durations/endpoints and absence of external URIs/root motion.

Runtime `game/assets/models/npcs/npc-04.glb`: 7,387 triangles, 3,860 authored
vertices, 16 bones, one material and packed 32x32 palette. Exported `idle` is
4 seconds, `walk` 0.8 seconds at 0.8 m/s; both import as linear loops.
Idle/facing runs at the fixed contact; walk is review-only. No work/fishing,
sluice operation, daily schedule or profession reward is attached to animation.

The existing scene-owned wrapper retains capsule/navigation/identity outside
`VisualRoot/Presenter`. Existing transactional presenter and root dialogue,
pause/focus/travel/modal/death holds are reused. No Party member, actor state,
save field or pose persistence is added. Travel/retry rebuild one Harlan wrapper.

## Public conversation boundary

The exact pinned graph/six portraits are unchanged. Fresh careful (+1) and
passing (+0) introductions remain exclusive with one source receipt. Returning
work/weather/hobby branches are available at level zero and disclose only
public-role, shared-checks and shore-birds. Reopening retains these facts once.
Gift transaction/target remain deferred with an honest reason; Close/Esc works.
No private testimony, accident history, household/story disclosure, later
campaign stage, ship/travel service, reward, quest effect or companion trust is
created. Source public text about working docks describes role, not a new service.

`npc_04_checks.gd` samples imported skin at120Hz, tests actual wrapper holds,
travel/retry, nine-point dry support, three water-negative footprints and all
six existing lamps plus rod contact arbitration. These are synthetic physical/rule
fixtures. `npc_04_render.gd` uses shared bounded ordinary WASD/E/pointer/GUI
journeys from fresh startup, alternative introduction and exact separate-process
manual Save/Load. Studio/seeded day/night/rain review is explicitly synthetic.

Commands, hashes, viewed captures, retained failed attempts and acceptance:
[N011 acceptance](../../docs/villagers-dialogue/N011_ACCEPTANCE.md).
