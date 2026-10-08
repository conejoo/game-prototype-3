# Celia Oran (`npc-08`) public repair contact package

N014 adds one fixed public noncombatant at approved target foot `(-3.5,0,12)`,
player approach `(-3.5,0,13)`, instance `alderwake-npc-08-contact`, and source
prompt `Talk to Celia Oran`. Source `celia-basic-repairs-actor-01` /
`celia-basic-repairs-01`, foot `(592,960)`, maps through
`X=(sx-704)/32`, `Z=(sy-576)/32`. The current pinned repair anchor supplies
dry ground; no geographic refresh, interior, dock or ship alteration is added.

## Art and ownership

Editable `art/source/npc-08.blend` opens on `RF-Npc08-Celia`. The reusable
`build_npc_08.py` loads only the delivered calibration rig/clips into a new
owned scene and authors Celia's own mesh. Original artist scene/file and prior
characters remain preserved. `normalize_npc_08.py` converts the library snapshot
into an ordinary editable mainfile and exports portable GLB.
`check_npc_08_source.py` audits identity transforms, rig, packed texture and
absence of drivers/constraints; `audit_npc_08.py` validates actual exported bytes.

The source official portrait/four-facing idle sheet and town canon age37 guide
an angular warm face, strong brows, swept dark hair/back braid, rust collared
rolled-sleeve shirt, ochre fitted apron/front pocket/tool loops/back ties, sage
knotted scarf and brown trousers/boots. Unseen depth/anatomy are stylized
adaptations. Costume tools are inert mesh details; no action or reward is added.

GLB `game/assets/models/npcs/npc-08.glb` contains 10,014 triangles, 5,240 authored
vertices, 16 bones and one material/packed32x32 palette. Exported `idle` lasts4s;
`walk` lasts0.8s at0.8m/s. Both import as linear loops. Fixed contact uses idle
and actual speaking facing; walk remains review-only. No service, boat ride,
memory recovery, morning scene or profession gameplay is attached to art.

Existing wrapper owns capsule, navigation reservation and stable identity
outside replaceable `VisualRoot/Presenter`. Root owns independent pause,
dialogue, focus, travel, modal and death holds. No Party actor, saved pose or
schema change; strict manual schema7/content1 saves remain authoritative.

## Dialogue and verification

Exact pinned graph/six portraits are unchanged. Careful+1/passing0 introductions
are exclusive, with one receipt each. Supplies/demo/busy/hobby branches work at
level0 and disclose only public-role/basic-repairs/woodcarving. Gifts remain
honestly deferred. Fixed modal notice supplements unchanged source words:
`Conversation only. Repair services and fair boat rides unavailable.`
No boat ride, service transaction, hull repair, stage change, quest/trust/item
grant, recovery or cutscene is enabled by ordinary conversation.

`npc_08_checks.gd` validates actual imported skin at120Hz, stance/loop/blend,
root lifecycle, one wrapper after travel/retry, full dry support/LOS/navigation
and neighboring repair/dock lane. These are synthetic physical fixtures.
`npc_08_render.gd` uses shared bounded ordinary WASD/E/pointer/GUI journeys
for both introductions, every public branch/fact, gift rejection, lane return
and exact separate-process manual GUI Save/Load. Studio/seeded production
day/night/rain reviews are explicitly synthetic.

Task acceptance, commands/hashes, inspected captures and retained attempts:
[N014 acceptance](../../docs/villagers-dialogue/N014_ACCEPTANCE.md).
