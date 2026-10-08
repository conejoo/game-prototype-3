# Ivo Oran (`npc-07`) dry booking-shore contact package

N013 adds one public noncombatant at approved target foot `(36,0,20)`, approach
`(34.5,0,20)`, instance `alderwake-npc-07-contact`, prompt `Talk to Ivo Oran`.
Source `alderwake:ivo-passenger-dock-01` / `passenger-booking-ivo-01`, foot
`(1856,1216)`, maps through `X=(sx-704)/32`, `Z=(sy-576)/32`. Physical current
terrain determines Y. This newer actor uses the existing pinned dry booking
anchor; no geographic refresh, quay/ship alteration or service is added.

## Art and ownership

Editable `art/source/npc-07.blend` opens on `RF-Npc07-Ivo`. Reusable builder
`build_npc_07.py` loads only the calibration rig/clips, discards its calibration
skin in the new owned scene, and authors Ivo's own mesh. Original artist scene
and prior character files remain preserved. `normalize_npc_07.py` normalizes
the owned snapshot into an ordinary editable mainfile and exports portable GLB.
`check_npc_07_source.py` audits source transforms/rig/packed texture and absence
of drivers/constraints; `audit_npc_07.py` checks actual raw exported bytes.

Public portrait/four-facing idle sheet and town age39 canon guide lean
clean-shaven warm face, strong nose, swept dark curls beneath ribbed navy beanie,
tailored navy waistcoat/split lapels/rear adjuster, teal knotted scarf, rolled
ochre shirt, brown trousers/boots. Unseen depth and anatomy are stylized
adaptations. No beard, satchel or invented profession prop.

GLB `game/assets/models/npcs/npc-07.glb` contains 8,135 triangles, 4,280 authored
vertices, 16 bones, one material/packed32x32 palette. Exported `idle` lasts4s;
`walk` lasts0.8s at0.8m/s. Both import as linear loops. Fixed contact uses idle
and actual speaking facing; walk remains review-only. No profession action,
routine, booking, salvage or gameplay is attached to exported art.

Existing wrapper owns capsule, navigation reservation and stable identity
outside replaceable `VisualRoot/Presenter`. Root owns independent pause,
dialogue, focus, travel, modal and death holds. No Party actor, pose/save field
or schema change; manual schema7/content1 saves remain authoritative.

## Dialogue and validation

Exact pinned graph/six portraits remain unchanged. Careful+1/passing0
introductions are exclusive, one receipt each; public supplies/work/busy/hobby
branches work at level0 and disclose only public-role/local-seamanship/knotwork.
Gifts remain honestly unavailable. Fixed modal notice says `Conversation only.
Booking, salvage jobs and departures unavailable.` Source words stay exact.
No second-city passage, hull repair, departure, customer sequence, payout,
quest/companion trust or supply grant. Existing shortened recovery helper stays
unnamed and explicitly temporary; Ivo does not replace it.

`npc_07_checks.gd` verifies actual imported skin at120Hz, stance/loop/blend,
root lifecycle, exactly one wrapper after travel/retry, full-footprint dry
support/LOS/navigation, public quay return path and water negatives. These are
synthetic physical fixtures. `npc_07_render.gd` uses shared bounded ordinary
WASD/E/pointer/GUI journeys for both introductions/every public branch/facts,
gift rejection/quay return and exact separate-process manual GUI Save/Load.
Studio/seeded production day/night/rain reviews are explicitly synthetic.

Task acceptance/commands/hashes, inspected captures and retained attempts:
[N013 acceptance](../../docs/villagers-dialogue/N013_ACCEPTANCE.md).
