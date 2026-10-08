# Tess Reed (`npc-06`) store contact package

N012 adds one public noncombatant at pinned target foot `(7.5,0,5)`,
approach `(9,0,5)`, instance `alderwake-npc-06-contact`, source prompt
`Talk to Tess Reed`. Source `alderwake:tess-store-01`, anchor
`store-service-tess-01`, foot `(944,736)` maps through
`X=(sx-704)/32`, `Z=(sy-576)/32`; physical target support determines Y.
This newer source actor uses the existing pinned store anchor. No snapshot
refresh, neighboring building, door, lane, shop interior or service is added.

## Character asset

Editable `art/source/npc-06.blend` opens on `RF-Npc06-Tess`, with identity
root, 16-bone rig and custom skin. `build_npc_06.py` reuses only calibration
rig/topology helpers and planted clips, then authors Tess's mature oval face,
chestnut wavy bob, green waistcoat/open cream collar, puff sleeves, rust apron
with pocket/pencils/back ties, brown trousers and boots. Official source portrait
and idle front/back/profile sheet are appearance authority; unseen forms are
stylized adaptations. Tess does not reuse another person's skin.

`normalize_npc_06.py` normalizes only the owned snapshot, re-exports and saves
an ordinary editable mainfile. `check_npc_06_source.py` audits scene/transforms,
packed image, rig and absent drivers/constraints. `audit_npc_06.py` reads actual
GLB bytes for embedded PNG, no external URIs, budget and baked clip endpoints.

Final GLB `game/assets/models/npcs/npc-06.glb`: 8,496 triangles, 4,429 authored
vertices, 16 bones, one material, packed 32x32 palette. Exported `idle` lasts
4 seconds; `walk` lasts 0.8 seconds at 0.8m/s. Both import as linear loops.
Idle/facing runs at fixed contact; walk remains review-only. No routine,
profession action, delivery reward or gameplay lives in exported art.

Existing scene-owned wrapper keeps capsule/navigation/identity outside
`VisualRoot/Presenter`; transactional presenter and root pause/dialogue/focus/
travel/modal/death holds remain authoritative. No Party member, saved pose or
save field. Travel/retry reconstruct exactly one wrapper per enabled person.

## Public conversation boundary

Exact pinned graph and six portraits stay unchanged. Careful (+1) and passing
(+0) introduction receipts remain mutually exclusive. Supplies, practical-help
boundaries, busy-day and hobby branches work at zero affinity, revealing only
source general-goods/everyday-supplies/pressed-flowers facts. Revisit retains
memory. Gifts stay disabled with honest reason and valid exits.

Source role text is preserved. Fixed modal status explicitly says
`Conversation only. Purchases and delivery jobs unavailable.` No commerce UI,
wallet, delivery contract, item grant, quest effect or companion trust is added.

`npc_06_checks.gd` samples actual imported skin at120Hz, loop seams/stance/blends,
actual root holds/disposal/reconstruction, all enabled contact support/navigation/
LOS and full-footprint neighboring store-lane destination. These are synthetic
physical/rule fixtures. `npc_06_render.gd` uses shared bounded ordinary WASD/E/
pointer/GUI journeys, both introductions, every public branch, fact/gift scrolling,
lane return and exact separate-process GUI Save/Load. Studio and seeded actual
world day/night/rain surveys are explicitly synthetic.

Acceptance, exact commands/hashes/inspection and retained failures:
[N012 acceptance](../../docs/villagers-dialogue/N012_ACCEPTANCE.md).
