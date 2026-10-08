# Della Pike (`npc-14`) public Lantern Rest entry package

N015 implements one fixed public innkeeper contact at target foot `(-9,0,3.5)`,
approach `(-9,0,4.5)`, instance `alderwake-npc-14-contact`, prompt
`Talk to Della Pike`. Source provenance is `lantern-rest:della-inn-host-01`,
anchor `inn-host-01`, indoor foot `(256,288)` source units. This exterior foot
is an explicit prototype adaptation; the town transform is never applied to
indoor coordinates. Pinned future inn portal pad is `Rect2(-8,3.5,2,1.5)`.
Actor capsule stays outside it; owning checks sample the full player footprint
and ordinary lane round trip across it. Geography and portal behavior stay exact.

## Editable art and ownership

`art/source/npc-14.blend` opens on `RF-Npc14-Della`. `build_npc_14.py` loads
only delivered calibration rig/clips into a new owned scene and authors Della's
mesh; original artist scene/file and other character assets are preserved.
`normalize_npc_14.py` normalizes only the owned library snapshot into an ordinary
editable mainfile and portable GLB. `check_npc_14_source.py` audits editable
transforms, packed texture, baked clips and absence of constraints/drivers;
`audit_npc_14.py` audits actual GLB bytes and embedded image/animation channels.

Official portrait/four-facing idle sheet and town canon age58 guide full mature
cheeks/chin, silver swept waves/high bun/wisps, plum gathered gown/sleeves,
cream bib/apron/back ties, olive fringed shoulder shawl/brass brooch and brown
boots. Unseen depth/anatomy are stylized adaptations. Continuous weighted gown
and apron close waist/center seams through the exported walk. No gameplay prop.

GLB `game/assets/models/npcs/npc-14.glb` contains8720 triangles/4599 authored
vertices/16 bones/one material and packed32x32 palette. `idle` lasts4s;
`walk` lasts0.8s at0.8m/s. Both import as linear loops. Fixed contact uses idle
and actual speaking facing; walk remains review-only. Shared presenter is under
replaceable VisualRoot; wrapper retains capsule, reservation and stable identity.
Root owns pause/dialogue/focus/travel/modal/death holds; no saved pose or Party actor.

## Public dialogue boundary

Exact pinned graph/six source portraits retained, including N001 audited public
entrance welcome. Careful+1/passing0 introductions remain exclusive. Hosting,
quiet-company, busy and quilting branches work at level0 and disclose only
public-role/quiet-company/quilting. Room directions and gifts remain disabled.
Fixed modal notice supplements source words on every branch:
`Public entrance adaptation. Inn interior, rooms and sleep unavailable.`
No guest-room/sleep entitlement, private records/history, home ownership,
mandatory morning event, item/quest/trust or inn service is introduced.

`npc_14_checks.gd` owns imported skin/stance/loop/blend, lifecycle/facing,
eight-contact full support/navigation/LOS, future portal pad and rejected room/gift
commands. Synthetic fixtures are explicitly labeled. `npc_14_render.gd` uses
shared bounded ordinary WASD/E/pointer/wheel and GUI Save/Load in fresh independent
writer/reader/neutral processes; studio and seeded weather reviews are separate.

Task criteria/commands/hashes/inspection and retained attempts:
[N015 acceptance](../../docs/villagers-dialogue/N015_ACCEPTANCE.md).
