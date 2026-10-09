# Fishing migration contract

Prepared 2026-10-08, America/Vancouver. This is an execution plan, not implemented
fishing or gameplay acceptance. [CHECKLIST](CHECKLIST.md) owns task status;
[CURRENT_STATE](CURRENT_STATE.md) records continuation.

## Goal, authority and boundaries

Target repository: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot application: `game/`, Godot4.7.2 typed GDScript, Compatibility renderer.
Read-only source: `D:/development/game-prototype-2`, Flutter/Flame.
Installed console: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`;
editor: same directory, `Godot_v4.7.2-stable_mono_win64.exe`.
Check those paths before searching/installing; installation directory is not the project.

Requested scope: existing rod selection, ranged water casting, authored catch
areas, waiting/bite/hook, hold/release tension, three fish species and backpack rewards.
Include ordinary usability, cancellation, persistence, integrated play and current
local Windows delivery. Source gameplay rules guide behavior; current target
[architecture](../ARCHITECTURE.md) owns session/physics/UI/save boundaries.

Preserve current rod pickup/drop/reposition, finite moonflowers, twenty-slot bag,
eight named villagers/social facts/gifts/People, companion trust/upgrades, shortened
Maris recovery, guardian/ally, time/weather/lights and geography. Do not implement
new shops, fish selling, gift preferences, quests, skills/XP, bait/durability,
crafting, resource respawn, NPC schedules, full campaign, farming or mobile/web.
Do not add autosave or import Flutter saves. Existing manual Save/Load remains.
Fish catalog giftability does not create an NPC preference or affinity award.

Planning observed F001-F010, W001-W010 and N001-N018 Done; G001-G008 Done,
G009 In progress. Their checklists are reference/coordination, never fishing task
selectors. Re-read current capabilities and user changes; historical status is not
acceptance of new fishing. Final delivery coordinates G009 per FS008.

## Source identity and inputs

Planning target HEAD: `5046448521994f7441c63a37b89af35c2f801f3f`.
Source HEAD: `60c20eb2816e7271fb84afaba286af006ebe3ccf`; source status clean.
Target contains concurrent social-delivery edits recorded in CURRENT_STATE.
FS001 rechecks and pins minimal references/vectors. HEAD alone does not pin working bytes.

SHA-256 observed relative to source root:

| Input | SHA-256 |
| --- | --- |
| assets/data/gameplay/catalog.json | c3677ed12a62a51e49e67479b383d6acf6a2b8aa9e468027a2ad9b83e64fbc2a |
| lib/game/fishing/fishing_challenge.dart | 738d365f3609ae311580bc9ff884cf81ba16adb70e83a2f69d0339f9a40112ce |
| lib/game/activities/activity_outcome_resolver.dart | 335e7f3bf42ca68a3c4032a4aa3816e16a029adbadc988b0759154fe0a533874 |
| lib/game/items/item_targeting.dart | dfe02f79fbe199343c8e8a4b3c1c61f451dc5a70a9bdf85bb6948286a43684fc |
| assets/maps/mvp_world.json | 777b99288fb18852d51c96ea1705cd264eba3a9703e6b043757c408cc8c637da |

Also inspect source `lib/game/items/item_definition.dart`,
`lib/game/cozy_adventure_game.dart` (cast/attempt/reward/cancel paths),
`lib/ui/fishing_hud_overlay.dart`, `lib/game/input/desktop_input_adapter.dart`,
`lib/world_map/world_map.dart` activity shapes, and
`assets/images/items/{bluegill,river_trout,golden_carp}.png`.
Source behavioral tests: `test/game/fishing/fishing_challenge_test.dart`,
`test/game/activities/activity_outcome_resolver_test.dart`,
`test/game/items/item_targeting_test.dart`, `test/ui/fishing_hud_overlay_test.dart`.
Source files/tests were read during planning; source tests were not run.

Geography authority is current target
[layout](../../game/content/maps/alderwake_layout.json) and
[map contract](../map-migration/CONTRACT.md), snapshot `alderwake-f4630f9-m002`.
Layout hash: `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.
Its original source map hash is af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
live source map differs. The three live fishing area profiles/shapes currently match
the retained target transforms, but this is no authorization to refresh geography.
Consume retained records through a separate runtime adapter. Keep pinned layout bytes,
colliders/ramps/water/decks/portals and map extractor unchanged.
No Flutter/Dart checkout, source PNG path or reference auditor is a runtime dependency.

## Existing target integration owners

- [ItemDefinition](../../game/features/items/item_definition.gd) currently permits
  forage/tool; [rod definition](../../game/content/items/fishing_rod.tres) has
  stable ID item-fishing-rod, source ID fishing_rod, cap1, movable pickup,
  non-giftable, and unavailable-fishing description.
- [InventoryState](../../game/features/items/inventory_state.gd) owns twenty distinct
  IDs, one stack/type, nullable owned selection and active_tool capability.
  Commands/revisions/snapshots are pure session facts. Do not store counts in Resources.
- [ForagingState](../../game/features/items/foraging_state.gd) and
  [ForagingSaveData](../../game/features/items/foraging_save_data.gd) preserve collected
  origins/placements and exactly one rod across bag/world. Fish are inventory rewards,
  not gathered origin IDs or extra movable world items.
- [GameRoot](../../game/app/game_root.gd) arbitrates input, modes, session/travel,
  retry, save/load, UI and party. Add focused fishing owners instead of expanding an
  untyped global facade/autoload/event bus. Inspect current signatures before editing.
- [CameraRig](../../game/app/camera_rig.gd) ground_point intentionally finds walkable
  floors and skips water blockers. It is not itself a fishable-water query.
  A dedicated target resolver must avoid weakening combat/drag/terrain aiming.
- [BackpackView](../../game/ui/backpack_view.gd),
  [PrototypeUI](../../game/ui/prototype_ui.gd) and
  [ForagingItemVisual](../../game/world/foraging_item_visual.gd) own current presentation.
  Reuse item icons/snapshot/selection routes; fishing view submits commands only.
- [SaveCodec](../../game/core/save_codec.gd): schema7/content1, strict current-only
  format, backup/recovery and detached restore. The architecture's current policy
  overrides older migration clauses in historical foraging/weather documents.

Proposed additions are `game/features/fishing/`, `game/content/fishing/`,
three item Resources under `game/content/items/`, fishing view/assets and
`tools/fishing/` references/delivery helpers. FS001/FS002 resolve exact names;
avoid catalog stable-ID collisions and duplicate state ownership.

## Item and species mappings

Keep source IDs separate from global Godot content IDs. Proposed new IDs below are
reserved by this workflow unless FS001 finds a real collision and records its resolution.

| Source item | Godot item ID | Category/cap | Difficulty | Hook seconds | Fight min/max seconds |
| --- | --- | --- | --- | --- | --- |
| fishing_rod | item-fishing-rod (existing) | tool / 1 | none | none | none |
| bluegill | item-bluegill | fish / 99 | easy | 1.2 | 2 / 5 |
| river_trout | item-river-trout | fish / 99 | medium | 0.9 | 6 / 12 |
| golden_carp | item-golden-carp | fish / 99 | hard | 0.7 | 15 / 30 |

Fresh bags remain empty. Pick up rod using existing world interaction; it does not
auto-select. Fish definitions are giftable metadata as in source, non-tool,
non-movable, no direct-use action. Current NPC accepted preferences stay unchanged.

## Targeting and catch-area truth

Source cell16 units -> Godot cell0.5m; source range384 units ->12m.
Convert source X/Z once: X=(sourceX-704)/32, Z=(sourceY-576)/32.
Use the target map origin (-22,-18) when snapping cells; range uses cell center and
horizontal hero-foot distance, inclusive12m. No source projected-screen lift becomes
Godot world position. Water height and dry-surface/occlusion handling must be measured
and recorded by FS001/FS004; never guess from the hero's hill height.

Only open visible water in committed prototype-alderwake is castable; solid dry deck,
bridge surface, terrain or structural occlusion wins over underlying water.
Source allows water-painted cells; dry deck rejection and structure occlusion are
deliberate physical-3D adaptations. Use semantic occupancy and actual top surfaces,
not shader pixels or hidden floor under water. Water boundary safety bodies must
not accidentally reject every shore-to-water ray. Target must lie in map, within
range and outside UI ownership; cast rechecks current rod/session/position/ray.
River water outside authored areas can be targeted but returns immediate no-area
feedback without starting a fight. Interiors/Tollworks have no fishing area here.

Retained target areas (`activity_areas`) already contain Godot shapes/profile data
with runtime_enabled=false. This workflow activates an adapter, not a geography rewrite.

| Area ID | Shape in Godot XZ metres | Blend weight | Outcome probabilities |
| --- | --- | --- | --- |
| fishing-dock-shallows | Rectangle(-11,16,16,18) | 1 | bluegill .30; river_trout .10 |
| fishing-lake-channel | Polygon(5,16),(23.5,16),(23.5,34),(17,36.5),(5,34) | 1 | river_trout .30; bluegill .12; golden_carp .03 |
| fishing-sunken-reeds | Polygon(2,21),(8.5,19.5),(12,26),(7.5,31),(1.5,28) | 2 | river_trout .22; bluegill .08; golden_carp .20 |

Query the targeted water cell center, not player/bobber screen position.
Collect all containing fishing profiles; each item probability is
sum(profile weight * item probability) / total matching weight.
Sort source item IDs lexically, choose at most one interval using an injected uniform
roll in [0,1), and leave remaining mass as miss. Never normalize reward mass to100%.
Source missing item probabilities contribute zero. No matching profile is no-area,
not a random miss. Define/test rectangle and polygon-edge membership in FS001.
Weather/day do not change probabilities; no depleted catch pools or offline progress.
Inject RNG for labeled tests; production uses ordinary RNG, with no player force-catch UI.

## Challenge and timing

Source baseline: tension .5, held rise .65/sec, release fall .55/sec,
warning progress multiplier .25, dangerous progress0, optimal progress1.
Landing progress grows dt * multiplier / species minimum duration.
Tension clamps0..1. Continuous dangerous slack/tight time >=.75s loses fish;
returning to safety resets that danger timer. At source resolution priority:
danger loss, then landing>=1, then maximum-duration exhaustion.

| Tier | Optimal tension | Danger outside/inclusive bounds | Source struggle curve at fight time t |
| --- | --- | --- | --- |
| easy | [.30,.70] | <=.10 or >=.90 | .12*sin(pi*t) |
| medium | [.35,.65] | <=.15 or >=.85 | .22*sin(2*pi*t/1.35) |
| hard | [.40,.60] | <=.20 or >=.80 | .22*sin(2*pi*t/1.9)+.10*sin(2*pi*t/.8) |

Cast rolls encounter and independent bite wait1.5..3s. Capacity rejection for selected
species happens before waiting, with revalidation at landing. Miss waits normally then
resolves no bite. New reel press while waiting scares encounter away. New held press
during the hook window starts fighting; a press already held at cast/phase boundary
cannot hook automatically. Distinct terminals: no bite, early reel, missed hook,
line slack, line snapped, exhausted, landed, explicit/lifecycle cancel.

Implement in a pure transient controller with bounded deterministic substeps and
phase-time carry; document tolerance in FS003 and test frame partitions/hitches.
Preserve source feel/constants; do not port Flutter ValueNotifier or source's discarded
phase-boundary overshoot. One attempt token/terminal event, no repeated success.

## Controls, modes and lifecycle

Default PC controls selected for migration:
- B selects existing rod through backpack; close modal before casting.
- F enters/exits rod targeting. In targeting, world left-click confirms valid cast;
  UI clicks never cast/attack. Movement remains normal while targeting, preview
  revalidates current position; no automatic cast on key repeat.
- E fresh press hooks; hold/release E controls fighting tension. A pointer Reel
  button offers the same semantic action. Combine keyboard/pointer held sources
  safely; releasing one must not strand another or generate double hook.
- F, right-click or Cancel cancels current targeting/attempt. Esc cancels fishing
  mode and opens the existing pause menu in that action; verify actual overlay.
  F10 retains quit behavior. Source Space interaction is not ported: Space keeps dodge
  in normal play, world left-click keeps attack outside fishing modes.
- Active attempt clears/blocks movement, attack/dodge, resource/dialogue/lamp/gate
  interactions, item drag/backpack/journal and save/load/travel until cancel/terminal.
  Pause remains available. Avoid a parallel UI focus path.
- Clock/weather continue during active fishing. Do not pause the whole world to ease
  timing. Ally ownership survives; combat engagement/damage/death cancels fishing
  before the normal combat/retry path. Modal/focus/room/load/session replacement and
  invalid rod/capability cancel without reward; failed transition rollback does not
  resurrect a partial cast. Every exit clears held controls; fresh press required.
- Camera projection/zoom retain existing UI pointer gates. Bobber/preview use committed
  world coordinates; no cast state may leak across camera or location changes.

## Rewards and persistence

Fishing coordinator captures bound session/location/rod capability and a unique
transient attempt token. On landed result, validate token still unresolved, current
session/room, owned selected rod and inventory capacity. Consume the completion token
and add exactly one known fish atomically through existing inventory command authority,
then publish coherent count/snapshot/success. Reject stale/reentrant/replayed results.
No miss/failure/cancel/invalid cast alters inventory, rod ownership, collected nodes,
placements, relationships, quest rewards or durable RNG facts. Failed add is terminal
with honest capacity feedback, never a deferred reward retried by opening bag/loading.

Successful fish counts and optional fish selection live in current inventory facts;
attempt phases/tokens/RNG choice/tension/timers/targets/effects are transient and
absent from saves. Preserve schema7/content1 if payload shape is unchanged. If new
durable fields are truly needed, replace supported schema and fixtures explicitly,
reject other schemas and invent no migration/default chain. No need to persist attempts.
Manual Save after a safe terminal/cancel, then GUI Load restores inventory at existing
arrival anchor. A failed save preserves earlier valid files and current-session catch;
retrying Save serializes facts without rerunning reward. Keep backup/recovery,
131072-byte bound, strict numeric/ID/cap validation and atomic restore.

## Verification, isolation and delivery

Use existing [runner](../../tools/run_checks.ps1) from repository root, PowerShell7.
It accepts FS task names, owns unique evidence/app-data/save groups and rejects
diagnostics/source changes. Example existing baseline command, to run only when
the selected task needs those checks:

```powershell
./tools/run_checks.ps1 -Task FS001 -Names inventory_checks,reference_mapping_checks,map_water_checks -TimeoutSeconds 150
```

After FS003 creates its proposed script:

```powershell
./tools/run_checks.ps1 -Task FS003 -Names fishing_challenge_checks -TimeoutSeconds 150
```

Dynamic dependencies belong in -ParseScripts. Reuse TestRunJourney, TestRunGui,
TestRunSnapshot and capture/evidence owners under `game/tests/support/`;
inspect current contracts in [PLAYTEST](../../tools/PLAYTEST.md). Never copy ad hoc
movement loops or modify normal user slots. For active fishing captures, verify live
phase and record frame/time drift; pausing cancels attempts and cannot prove an
active bite/fight picture. Inspect PNGs, not merely widget presence.

Relevant existing regressions: inventory_checks, foraging_transaction_checks,
foraging_save_checks, foraging_interaction_checks, backpack_ui_checks,
world_item_placement_checks, social_transaction_checks, social_save_checks,
social_gift_ui_checks, people_journal_checks, npc_integration_checks,
combat_checks, companion_checks, location_travel_checks, movement_camera_checks,
map_camera_checks, map_water_checks, environment_lifecycle_checks and application_smoke.
Select affected checks per task; broaden only for failures/new concerns. No unrelated
whole-source Flutter suites or repeated full campaigns for documentation.

Raw runs use fresh `docs/evidence/FSxxx/<run-id>/`; staging/app-data under
`builds/testing/FSxxx/<run-id>/`, or FS008's own `builds/fishing/` staging.
Version reusable fixtures, references, acceptance summaries and decisions; raw
captures/logs remain local ignored archives. Preserve historical evidence.
Native helper currently lacks F and limits evidence routing to older task IDs;
FS006 explicitly owns tested extension for FS008 without weakening guards.
Use actual release exe+pck, guarded native input, fresh client captures and confirmed
pause checkpoints; no debug bridge/state/RNG commands in release acceptance.
Narrowly scoped timing-driver work may read rendered HUD pixels and dispatch bounded
ordinary inputs; it must not read game memory or set fish/counters/time.
If bite/tension timing cannot be driven through supported input, retain a precise
human-play gate; do not claim package acceptance from debug/synthetic proof.
Stage and audit both presets with current templates; final local package promotion
waits for FS008's independent-delivery gate. No installation, external messages,
commit/push/publication or automated successor authorized by this plan.

## FS001 measured reference decisions (2026-10-09 UTC)

FS001 pins [reference manifest](../../tools/fishing/reference/manifest.json),
[rules](../../tools/fishing/reference/rules.json),
[vectors](../../tools/fishing/reference/behavior_vectors.json) and bounded source
excerpts. Target entry HEAD is `210c2b7a38600a1c9c144e4b773c89a5c1be8ad8`;
source HEAD and the five planning source hashes are unchanged. All 18 source file
hashes are recorded. Live source map differs from the historical map identity,
but all three shapes, weights and profiles transform exactly to pinned target data.
Do not regenerate geography. Current independent social G001-G009 is Done;
later FS008 must still verify its then-current delivery capability and ownership.

Area rectangles include left/top/right/bottom; polygon edges count as inside.
Preserve the source polygon predicate in source units (cross-product and endpoint
epsilon `0.000001`), or its explicitly equivalent scaled predicate. This differs
from half-open map/water/deck occupancy. Quantize relative to (-22,-18) and query
cell center. Bounds X[-22,125), Z[-18,62); horizontal range <=12m.

Actual undisplaced water mesh is Y=.015m (float storage .0149999996647). Dry dock
floor is Y=0, visual top .022. Water walking safety bodies extend Y[-.2,3]; they
are not the water plane. A normal physics ray otherwise hits their top Y=3.
The future target resolver may exclude only identified water safety bodies;
gate, structural/terrain/cliff solids remain occluders. Underwater base floor
must not establish fishability. Reject semantic dry dock/bridge cells first.
No collision/navigation change is necessary for the measured rod-to-water lines.

| Site | Dry foot XYZ metres | Open-water cell center XYZ metres | Horizontal distance | Profiles |
| --- | --- | --- | ---: | --- |
| Dock Shallows | (-7,0,18) | (-4.75,.015,20.25) | 3.182m | dock |
| Lake Channel | (10,0,13) | (10.25,.015,17.25) | 4.257m | channel |
| Sunken Reeds west overlap | (3,0,13) | (3.25,.015,22.25) | 9.253m | dock + reeds |
| Sunken Reeds east overlap | (6,0,13) | (6.25,.015,22.25) | 9.253m | channel + reeds |

Sunken Reeds is contained in dock/channel union; no reeds-only ordinary site is
invented. Weighted golden carp remains .03 in channel, 2/15 in dock/reeds and
43/300 in channel/reeds. The western overlap miss is 8/15; eastern miss is 31/60.
All four dry approaches have real support/capsule clearance/navigation and fresh
ordinary WASD proof. See [FS001 acceptance](FS001_ACCEPTANCE.md) for actual foot
tolerances, inspected renders and separate synthetic geometry evidence.

Negatives: dry east deck(-7,18), bridge(98,-.5), dry shoreline(10,13), retained
cliff-6-0-east solid, excluded map edge(125,62), open no-area water(-12.75,20.25).
These classify current geometry, not a shipped pointer resolver. FS004 still
owns camera modes/zoom/structural pointer occlusion and actual target preview.

Encounter and wait rolls are independent finite [0,1). No-area consumes neither;
miss waits normally. Wait=1.5+1.5*roll. Source wait helper clamps finite values,
including1, but the production RNG domain remains half-open and target rejects
invalid supplied rolls. Source discards phase-boundary overshoot and autosaves
on catch; deliberately retain target elapsed carry and existing manual Save.
Fresh hook press, danger-reset/priority/constants and lifecycle cancellation
remain as specified above; no attempt state survives load.
