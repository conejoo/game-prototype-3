# Foraging, items and backpack migration contract

Prepared 2026-10-04; F001 reference audit completed2026-10-05, America/Vancouver.
F002 content/inventory rules completed2026-10-07; world/UI activation remains F005+.
Current saves remain schema5/content1; F004 owns schema6.
[CHECKLIST.md](CHECKLIST.md) owns task status. [CURRENT_STATE.md](CURRENT_STATE.md)
owns continuation. Target repository: `D:/development/game-dev-blender/returning-fair-prototype`.
Application: target `game/`, Godot4.7.2 typed GDScript/Compatibility renderer.
Read-only source inspiration: `D:/development/game-prototype-2`, Flutter/Flame.

## Scope and authority

Requested: hold-to-gather moonflowers; persistent collected nodes; 20-slot backpack,
stack limits, active items/tools; rod pickup/drop/reposition; peaceful gameplay foundation.
The supplied statement that Godot resource records remain inert describes baseline.
Migration activates selected records through runtime wrappers, without rewriting
pinned geographic snapshot. Authored Godot Resource definitions remain immutable data.

Target architecture wins for ownership, 3D physics, controls and save policy.
Source wins for named items, stack meaning, durations and atomic outcomes. Fishing
inspires staged interaction, held input, readable progress, explicit cancellation
and reward-after-success transaction. Full fishing excluded: no cast, fish tables,
bite/hook/tension phases, fish rewards or water-target minigame. Also exclude gifting,
shops, crafting, respawn economy, new quests/NPC schedules/campaign, combat redesign.
Rod is selectable active tool and movable pickup. Do not advertise working Fish/Cast;
if direct use exposed, give honest unavailable feedback. Preserve Space dodge/mouse
attack; source Space interaction/F casting must not overwrite current bindings.

P001-P014/M001-M019/W001-W010 completion stays historical. Their checklists do not
select work here. New feature needs fresh evidence. Earlier inert-resource statements
remain accurate for historical baseline; update production descriptions on activation.

## Verified baseline and source identity

Target inspected HEAD `8274a251cfa27d4ac66cf1fea99e06c9630aaf8d`; source inspected HEAD
`60c20eb2816e7271fb84afaba286af006ebe3ccf`. Both status commands returned clean before
planning. Recheck current artifacts and hashes in F001; HEAD alone does not pin bytes.

Geography authority: target [layout](../../game/content/maps/alderwake_layout.json),
snapshot `alderwake-f4630f9-m002`, [map contract](../map-migration/CONTRACT.md),
[manifest](../../tools/map_migration/reference/manifest.json). Live source map drifted;
never auto-refresh map/colliders/portals/navigation.
Four resourceNode records currently runtime_enabled=false/runtime_mapping=null:

| Instance ID | Resource/item ID | Godot foot (x,y,z metres) |
| --- | --- | --- |
| fishing-rod-dock-01 | fishing_rod | (-8,0,15.75) |
| moonflower-01 | moonflower | (26,0.25,-2) |
| moonflower-02 | moonflower | (34,0.25,7) |
| moonflower-03 | moonflower | (30,0.5,-9) |

Source alderwake maps explicitly to prototype-alderwake. Definition and instance IDs
are distinct. One Godot metre per32 source units, existing point transform. Never
convert saved Godot feet again. Use current terrain-height contract; measure support
and reachable approach. Keep authored X/Z/identity fixed; record discrepancies.

Source files read; SHA-256 relative to source root:

| File | SHA-256 |
| --- | --- |
| assets/data/gameplay/catalog.json | c3677ed12a62a51e49e67479b383d6acf6a2b8aa9e468027a2ad9b83e64fbc2a |
| lib/game/fishing/fishing_challenge.dart | 738d365f3609ae311580bc9ff884cf81ba16adb70e83a2f69d0339f9a40112ce |
| lib/game/state/runtime_game_state.dart | 5b965d130ef38a6ee2c8e6769eb51744fc01c17458deaf58d4a076e4c9db2cae |
| lib/game/state/runtime_game_controller.dart | 29bef8302107fb116b9814840ae24386163f1442e50a9eb06c7803e0bd8c8c26 |
| lib/game/interaction/interaction_hold_system.dart | 0924bff59797984df54354e1a12229629ea5df742240400ed43472b4c98ce0bf |
| lib/game/items/world_item_placement_validator.dart | 6884a8b5452d478e22f579ef849be594b767a980727e0c5d5b1ace7ecd40a486 |
| lib/game/cozy_adventure_game.dart | acf5043f59b58bd7439efb9683863844338ef6b0c97966b95f743aae7534c295 |
| lib/ui/inventory_panel_overlay.dart | d297b915a7a4ea0b8647d715b0c6355ba522a512d6066314ba1ec853d5f4b4be |

Other source inputs: resources/resource_definition.dart and resource_node_component.dart,
state/inventory_snapshot.dart, ui inventory/fishing HUD overlays, input/desktop_input_adapter.dart,
persistence/save_game.dart. Source regression specifications: test/game/state/
runtime_game_state_test.dart and runtime_game_controller_test.dart; test/game/items/
item_definition_test.dart and world_item_placement_validator_test.dart;
test/game/fishing/fishing_challenge_test.dart; test/ui/inventory_overlays_test.dart.
Tests read, not run. F001 pins minimal target-local references/vectors/manifest.
Runtime/export cannot depend on source checkout or Flutter.

## Behavior

- Maximum20 distinct item IDs, one stack per ID. No overflow into second stack.
  Existing stack can grow when slots full until own cap. Reject unknown IDs,
  nonpositive/fractional quantities, overflow and missing active IDs atomically.
- moonflower: forage, cap99, no direct use/world drop in slice. fishing_rod: tool,
  cap1, movable pickup, not giftable. Fresh bag empty; collect rod in world.
- One nullable owned active item ID. Selection may inspect any item; active-tool
  capability derives from definition. Final-unit consume/drop clears active;
  failure preserves it. No silent auto-equip on pickup.
- Hold E0.6s for flower/E0.5s for rod. One fresh press starts one attempt. Release,
  selected-target change, range/LOS loss/removal, modal, pause, focus loss,
  travel/load/retry cancel progress. Fresh press required after cancel/complete;
  holding E cannot sweep nodes or trigger adjacent lamp/dialogue/gate afterward.
- At completion revalidate location/instance/definition/eligibility/capacity.
  Commit +1 and authored collected ID together, then publish success. Full bag/
  stack leaves node, counts and placements unchanged; no completion event.
- Collected origins stay absent across travel/retry and explicit Save/quit/new-process
  Load. No day/weather respawn. Timer/selection/drag preview/feedback transient.
- Source fishing waits for success before addActivityReward and gives clear failures.
  Reuse transaction/cancel discipline, not minigame or requestSave autosave. Godot
  keeps explicit stable pause-menu Save/Load and player last-arrival restore.

## Ownership, identity and placement

Immutable authored definitions in ContentCatalog; mutable inventory, collected IDs
and placements in GameSession/typed services. Catalog currently uses single stable-ID
index: item/resource namespaces must differ (e.g. item-moonflower/resource-moonflower)
with source-ID mapping. The resolved F001 table below is authoritative; never duplicate catalog stable ID.
Pure rules have no scene ownership. GameRoot owns modes/lifecycle. Extend existing
typed interaction selection/actions, no parallel event bus/autoload. Wrappers own
instance/bounds/visual children. UI renders snapshots/submits commands. Lamps stay
immediate E actions.

Reconstruction: instantiate committed location, bind correct session, apply collected
facts/placement overrides, connect observers, enable input. Failed travel/load restores
old session/wrappers/placements. No stale references, duplicate subscriptions/rewards.

Authored rod origin stays suppressed after collection. Drop has separate persistent
identity (source dropped-fishing_rod), item/location/finite Godot feet. Uncollected
origin can move under original ID with placement override. Override replaces original,
never adds second rod. Pickup removes placement and adds inventory atomically;
collected origin never reenabled. Explicit provenance separates authored override
from generated drop. Single authored rod/cap1 allows deterministic drop identity;
no general multi-instance equipment system required.

Drop validates nearby clear place before consume. No place means unchanged bag.
Reposition: pointer drag from nearby reachable rod, ground-ray preview, commit once
on release. Invalid release returns original; preview changes no durable facts.
Block attack/aim/zoom conflicts and gather while dragging; Esc cancels/F10 quits.
Cancel preview on modal/focus/travel/load/retry; fresh input afterward.

Placement validates finite position, committed location, bounds, footprint versus
blockers/water/portal/spawn reservations, supported dry terrain and retrievable hero
capsule approach. Reject gaps/cliffs/unsupported height/cross-bank shortcuts and
slopes/steps incompatible with footprint. Godot geometry/navigation authoritative,
not projected sprite bounds. Items nonblocking; no geography rebake to permit unsafe
placement. F007 records measured tolerances/search/preview behavior.

## UI and save proposal

Backpack InputMap B plus HUD entry. Twenty slots (5x4 at960x640), counts/caps, active
highlight/details, Close and rod-only Drop; mouse/Tab/Enter. B/Esc/Close restores
control. Modal clears held controls, blocks world input and contains focus. Drop
closes only after successful command or reports failure in place. Gather progress,
success/full/invalid placement readable day/night/rain. No developer IDs in UI.

SaveCodec currently schema5/content1. Proposed schema6/content1 adds inventory,
collected IDs and placements; F004 records final field names here. Preserve exact
v1-v5 validation/default chains, environment numbers/lights/party/health/quest/
trust/upgrades. Legacy new fields empty. No Flutter save import. Validate exact
fields, ID ownership, quantities/caps, duplicates, provenance/location/geometry
before session swap. Reject contradictory rod ownership (bag plus placement or
unsuppressed collected origin), duplicate placement aliases and collected IDs from
wrong resource/location. Preserve newer-version rejection, primary/backup protection
and128KiB bound. Save plain facts, no Resources/NodePaths/arbitrary actor position.
Cancel hold/drag before stable pause save boundary; no continuation on load.

## Verification and delivery

Each task owns correctness checks. Label synthetic full-capacity/placement fixtures;
they cannot prove ordinary routes. Extend bridge only with read-only item/node/
placement/hold/modal observations and B support; no mutation/reward/teleport/save
command. Existing exact snapshot/GUI/capture support applies. Raw evidence ignored
under docs/evidence/Fxxx; durable summaries/fixtures tracked.
F009 walks all four nodes normally, proves whole loop and GUI separate-process
persistence. F010 fresh local Windows packages/native controls; historical release
evidence insufficient. Local prototype delivery only; no deployment/publication/
commit/push authorization. No unrelated installs.
## F001 resolved definitions, provenance and schema plan

F001 reference audit completed2026-10-05. See [reference](reference/README.md),
[manifest](reference/manifest.json), [vectors](reference/behavior_vectors.json) and
[acceptance](F001_ACCEPTANCE.md). Source/target HEADs and eight planning hashes match;
source worktree remains clean. Twenty source-file hashes now pinned. Runtime remains
schema5/content1 with17 catalog definitions and inert resources. No F002+ implementation.

| Source item/resource ID | Target item stable ID | Target resource stable ID | Target behavior |
| --- | --- | --- | --- |
| moonflower | item-moonflower | resource-moonflower | forage cap99; gather600ms; inspect only |
| fishing_rod | item-fishing-rod | resource-fishing-rod | tool cap1; pickup500ms; movable; fishing unavailable |

Resource definition references its item stable ID explicitly; instance registry references
resource stable ID, owning prototype-alderwake and original authored foot. Keep source IDs
as provenance, never as duplicate catalog keys. Registry order is stable instance-ID order;
inventory snapshot/serialization order is stable item-ID order. A fresh inventory is empty,
active_item_id is null; pickup never silently selects. Select any owned item for details;
derive active-tool capability from definition, never presence alone.

F001 measured underlying floor at all four authored feet, two usable anchors and two
blocked anchors. [Geometry baseline](reference/geometry_baseline.json) pins nearby dry
capsule approaches: rod(-7,0,15.75), flower01(26.75,0.25,-2),
flower02(34.75,0.25,7), flower03(30.75,0.5,-9). These are synthetic observations, not
alternate persistent origins or permission to move authored X/Z. Rod origin lies in
south-water-06; flower01 overlaps cliff-47-15-east/cliff-47-16-east. No height repair needed.
F005 must resolve physical/visual/LOS adapter geometry before accepting these nodes;
if impossible under fixed origins, record exact conflict and block F005. Keep map
snapshot/colliders/nav unchanged; never bypass blocker LOS. F002 prerequisites resolved.

F003 commands receive owning location/instance/resource identity and expected state
revision; root revalidates physical target. Stale/unknown/mismatched requests reject.
Pure services use validated injected placement capability; no scene ownership. Observer
publication follows joint inventory/facts/placement commit. Revision is transient, reset
on new/restored sessions, never serialized.

Schema6/content1 plan (F004 implements and records actual final compatibility):
retain all exact schema5 fields, add exactly these three top-level fields:

```json
{
  "inventory": {"item_counts": {}, "active_item_id": null},
  "collected_resource_ids": [],
  "world_item_placements": []
}
```

item_counts maps target item stable IDs to positive integer quantities within cap.
No zero/unknown/duplicate item entries or more than20 types; active ID null or owned.
collected_resource_ids is sorted unique authored instance IDs from the four-node registry.
Generated drops never enter it; location ownership derives from registry, not current room.
Legacy v1-v5 validates its original shape then defaults these three fields empty; authored
rod remains at origin. Do not change existing environment/party/quest numeric repair rules.

Each placement has exactly instance_id, item_id, location_id, foot_xyz_m, provenance,
origin_instance_id. foot_xyz_m is three finite Godot metre numbers, never source coordinates.
For this slice item_id is item-fishing-rod and origin_instance_id is fishing-rod-dock-01.
provenance is one of:

- authored_override: instance_id fishing-rod-dock-01, location prototype-alderwake,
  origin not collected; replaces the original, never creates a second rod.
- generated_drop: instance_id dropped-fishing_rod, owning committed supported location
  prototype-alderwake or prototype-tollworks, origin already collected; replaces the
  one consumed bag rod. Deterministic source-inspired ID is preserved.

Snapshot sorting is by placement instance_id. Never accept aliases/duplicate placements,
bag rod plus world rod, authored override plus collected origin, generated drop before
origin suppression, wrong item/origin/location/provenance or unsafe geometry. Across
authored default/override, bag and generated placement, durable rod count is exactly1;
generic synthetic consume tests must not be confused with a valid production rod save.
Successful generated pickup removes placement while keeping original collected.
F004 uses strict candidate validation and geometry capability; F007 supplies fully
measured placement semantics without weakening the save boundary. No general multi-rod
equipment, fishing, tutorial journal, gifting, economy or autosave port.

## F002 implemented content/inventory boundary

Completed2026-10-07; [acceptance](F002_ACCEPTANCE.md). Catalog now21 definitions with
ItemDefinition and ForagingResourceDefinition under game/features/items. Four local
Resources implement the resolved F001 table and strict typed resource->item/source
references. Cached Resources follow existing immutable authored-data convention.

GameSession owns InventoryState. Positive integer Variant quantities required;
float1.0 is deliberately rejected alongside fractions/bools/nonfinite values, avoiding
GDScript int coercion. initialize/can_add/add/consume/select return PackedStringArray
errors; no scene/signal ownership. Snapshot detached and sorted by item stable ID;
active ID null or owned String. select(null) explicitly clears. active_tool derives
owned selection/category; neither pickup nor forage selection activates tool use.
Cap/quantity/ownership failure preserves counts and selection; final consume removes
stack and clears matching active ID. Generic consume fixtures do not establish a
valid production rod save; F003/F004 enforce cross-world conservation.

Schema5/content1 and four inert physical records retained. Inventory serialization,
collected/placement facts and publication are still F003/F004 work. JSON decoding in
F004 must first strictly validate whole numeric quantities then convert to int.
No source/geography refresh, world/UI/drop/fishing activation implied by F002.
