# Maris (`npc-03`) character and counter package

N010 reuses the existing `npc-03-counter` at foot `(-7.5,0,11)`, approach
`(-6,0,11)`. No second actor, body, bench or counter is created. Original bench,
collision, service boards and stage props remain. The former capsule mesh is
hidden only after the named asset successfully mounts under `VisualRoot/Presenter`.

## Character pipeline

`art/source/npc-03.blend` is an editable active mainfile with root, 16-bone
armature and custom skin. `build_npc_03.py` uses the N007 calibration rig/baked
loops and new shaped character geometry: mature full face, broad nose, brown
side-parted hair/low braid with gray streak, blue vest, cream rolled sleeves,
ochre work apron, pocket/rope loop, brown trousers and boots. Official portrait
and front/back/profile idle sheet supply public appearance. Unseen geometry is
a stylized adaptation, not an exact portrait reconstruction.

`normalize_npc_03.py` sets the owned mainfile's active scene;
`check_npc_03_source.py` audits editable transforms, rig and packed texture;
`audit_npc_03.py` audits the actual raw GLB, portable embedded PNG, budget and
baked endpoints. No source checkout is required at runtime. Import loops are
explicitly linear. Idle is ordinary runtime; walk is review-only. No work action,
commerce, inventory transaction, daily routine or gift capability is introduced.

Runtime asset: `game/assets/models/npcs/npc-03.glb`, one packed 32x32 palette,
7,907 triangles, 16 bones and one material. `NpcWorldAdapter` mounts the existing
transactional presenter and forwards independent root dialogue/pause/focus/travel/
modal/death holds. Physics/navigation and stable IDs remain outside the art.

## Ordinary versus recovery routes

E opens the existing stage-derived prototype recovery graph. The same portrait
modal has a fixed keyboard-focusable `Chat with Maris` button. It opens the
unchanged source graph. Its `Recovery / counter` button returns to the graph
currently selected by authoritative quest effects. Switching resets the transient
cursor only. `GameRoot._switch_maris_route(command)` verifies the full current
snapshot, mode, scene-owned counter and actual selected visible contact before
cancel/begin; stale, distant, wrong-person and unloaded routes reject.

No source node, choice, receipt, text, fact or portrait changes. Ordinary public
role/supplier practice/decorative-knots disclosure stays in Maris's separate
conversation memory. Chat never restores specialist service. Recovery remains
accept lead -> actual guardian clearance -> vessel return path -> returned-town
fitting -> practical reconnection -> specialist preview. Leaving, canceling or
switching routes cannot complete the fitting. Existing unnamed customer/helper
and the shortened prototype labels remain honest. Manual schema7/content1
Save/Load persists conversation memory and quest effects independently.

`npc_03_checks.gd` measures actual imported skin/feet/loops/blends and live
wrapper/holds/travel/retry. `npc_03_render.gd` uses shared bounded ordinary input,
GUI Save/new-process Load and separate synthetic art/weather/fitting-prefix
review. Exact commands, inspections, failed attempts and final evidence belong
to [N010 acceptance](../../docs/villagers-dialogue/N010_ACCEPTANCE.md).
