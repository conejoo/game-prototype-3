# Villagers and dialogue migration contract

Prepared: 2026-10-07, America/Vancouver. Stable migration authority. N001 reference audit completed; runtime migration remains N002 onward.
[CHECKLIST](CHECKLIST.md) owns task status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation.
Target repository: D:/development/game-dev-blender/returning-fair-prototype.
Godot application: target game/, res://app/game_root.tscn.
Read-only reference: D:/development/game-prototype-2.

## Outcome and scope

Deliver eight identifiable villagers in the existing 3D prototype, ordinary public conversations with authored branches and portraits, persistent choices/flags/learned facts, and source-informed character animation. The player must encounter these people through normal town play and see different return dialogue when actual authored conditions change.

The requested roster is exactly:

| Source definition ID | Person | Placement policy for this workflow |
| --- | --- | --- |
| npc-01 | Mayor Edric Vale | Public civic contact in Alderwake; retain source role and source ordinary dialogue. |
| npc-02 | Helena Vale | Public civic/archive contact in Alderwake; no new Hall or private-home access. |
| npc-03 | Maris Reed | Existing Reed Chandlery counter; reuse the real npc-03 definition and existing quest interaction identities. |
| npc-04 | Harlan Reed | Public dock/control-hut neighborhood, clear of quay and travel lanes. |
| npc-06 | Tess Reed | Existing source store neighborhood in town; ordinary conversation, no shop transactions. |
| npc-07 | Ivo Oran | Passenger-booking/dry-shore neighborhood; no actual booking, salvage payout or departure. |
| npc-08 | Celia Oran | Source public repair-work neighborhood; no purchased repair or demo ride. |
| npc-14 | Della Pike | Public Lantern Rest entry contact, explicitly adapted from source lantern-rest:inn-host-01. No new interior, sleep or room entitlement. |

These are bounded public contact placements, not a port of the daily schedule system. N001 must record the exact source placement/anchor, target foot and player approach for each. Retain an already safe pinned town placement when available. For absent/newer source placements, use an additive target-local registry after checking current terrain, full actor/player footprints, navigation and nearby interaction occupancy. The source coordinate transform is X=(sx-704)/32, Z=(sy-576)/32; Y comes from current Godot physical terrain. Interior coordinates cannot be transformed into town coordinates. Della's exterior foot is a deliberate adaptation, never described as the original indoor placement. Do not regenerate the pinned world to import newer contacts.

The live source catalog now contains 15 packages. The seven additional packages are outside this request. Do not increase this roster through automatic catalog import.

## Boundaries between migrations

Included: finite dialogue graphs, source node/choice IDs and priorities, authored public fact disclosure, seen nodes, mutually exclusive introduction flags, once-only choice effects, small per-person affinity needed by source choice/condition rules, portrait expression selection, a compact known-facts view inside conversation, 3D actor identity and animation assets.

Deferred: gift transactions and gift-driven milestones, the full People journal and relationship progression UI, daily/group/cross-map routines, full campaign/cutscene director, new interiors/fair maps, shops/economy, fishing gameplay, romance/household changes, new companions, player-model replacement, mobile/web release, bespoke authoring editors and autosave/startup-resume changes.

Import gift and routine bindings as typed deferred capabilities. Gift choices must remain unavailable with an honest reason and must never consume inventory or grant affinity. Routine-only entries cannot become ordinary entries simply because their consumer is absent. Preserve valid unreachable nodes and source milestone declarations; do not fake the conditions to make them visible. N001 must give every selected source node/choice an enabled/deferred classification and reason. Retain source text unless a specific location-dependent adaptation is recorded. Distinguish lack of the relevant capability from lack of an owned item. This boundary does not authorize shipping a broken conversation: Close/Continue must always permit a valid exit when all optional choices are unavailable.

Per-person conversation affinity is independent of existing companion trust. Keep source signed choice deltas/clamping and level derivation; no new arbitrary affinity gate for the Maris quest or ordinary services. Full friendship/gifting remains a later workflow.

## Source authority and initial facts

Planning inspection found clean worktrees:
- Target HEAD d95f548eff72dbd72664656f39cc82f8918ee3a6.
- Source HEAD 60c20eb2816e7271fb84afaba286af006ebe3ccf.

The eight selected source packages contain 70 dialogue nodes, 24 public facts and 48 portrait references. Edric declares river-fishing action art; Helena declares archive-work; the other six declare no world action sheets beyond idle/walk. These counts are inspection facts, not runtime acceptance or an instruction to invent extra actions. N001 rechecks actual bytes, asset dimensions and hashes.

Authority order:
1. User scope, applicable AGENTS instructions and current target architecture.
2. Selected source public runtime/dialogue/visual packages and resolver behavior for identity and conversation semantics.
3. Source town canon for age, household relationships and public/private disclosure boundaries.
4. Current target pinned geometry, physical navigation, combat, environment and save contracts for engine integration.

Read the relevant files from the read-only source root:
- assets/data/npcs/catalog.json and assets/data/npcs/<selected-ID>/{runtime,dialogue,visuals}.json.
- Every image actually referenced by those eight visuals documents; do not assume filenames, count or dimensions.
- lib/game/dialogue/dialogue_model.dart, dialogue_document_codec.dart and dialogue_choice_eligibility.dart.
- lib/game/state/runtime_game_state.dart, runtime_game_controller.dart and player_event_journal.dart.
- lib/game/npc/npc_content_validator.dart and npc_runtime_document_codec.dart.
- assets/maps/project.json, mvp_world.json, lantern_rest.json and selected NPC routines for placement/action context only.
- docs/towns/alderwake.md, returning-fair-cast-integration.md, returning-fair-integration-checklist.md and visual-assets.md.
Private docs/npcs profiles may inform identity where required but must not be bundled or copied into public facts. Future/unfinished source chapter tasks are not installed gameplay.

N001 created a target-local, hashed reference set and an extraction/coverage inventory under proposed tools/npc_migration/reference/. Only selected public data/assets and necessary placement/action references are copied. Every input has its source path, hash and source revision; selective adapters have a readable report. No runtime/export dependency on the source checkout, Flutter, historical candidate maps or private profiles. After pinning, refuse unexplained source drift; do not silently refresh.

## Existing target to preserve

See [architecture](../ARCHITECTURE.md), [map contract](../map-migration/CONTRACT.md),
[weather handoff](../weather-lighting/CURRENT_STATE.md) and
[foraging handoff](../foraging-items-backpack/CURRENT_STATE.md).
P001-P014, M001-M019, W001-W010 and F001-F010 are delivered history; their task selectors do not govern this workflow.

Planning baseline: schema6/content1, 21 manifest definitions, manual pause Save/Load, arrival-anchor restoration, two persistent party wrappers, companion trust/strike training, shortened Maris recovery and specialist presentation, physical larger Alderwake/Tollworks travel, clock/weather/lights, four gatherable/pickup records, 20-slot backpack and rod placement.
Recheck current artifacts and user changes before implementation; historical handoffs sometimes contain older boundaries.

Preserve all existing IDs, quest effect ordering, health/combat/retry, one ally, modal/focus input clearing, camera/canopy/ground aiming, gates/crossings, source geometry provenance, weather/light state and item conservation. Preserve the labeled temporary companion: it is not one of these villagers. Do not assign a named resident to its story/party role.

Maris ordinary graph and existing recovery dialogue share one real person. Use a root-owned dialogue router or equivalent explicit composition: ordinary conversation can lead to the existing quest/service flow without replacing its legal commands, progress, counter identity or specialist gating. No second npc-03 actor/counter or automatic recovery. Prototype customer/helper labels remain honest unless a separately verified integration uses the existing real person without duplicating them.

## Ownership and dialogue semantics

The following ownership describes the intended integration. N002 definition/catalog interfaces are implemented below; remaining NPC services and wrappers are proposed:
- game/features/npcs/: immutable NpcDefinition, graph/node/condition definitions, per-NPC ConversationMemory, pure eligibility/choice services, scene-owned wrapper/registry and replaceable actor presenter.
- game/content/npcs/: converted Resources or validated target-local public catalog/graphs.
- game/assets/npcs/: portraits and 3D GLBs. Editable Blender files stay under art/source/npcs/.
- GameSession owns persistent per-person memory and the bounded player-event memory queried by selected graphs.
- GameRoot injects services and arbitrates all input/modal/lifecycle commands.
- UI displays a conversation snapshot and submits stable node/choice commands; it does not decide rewards.
- During N005, convert existing Maris/companion/vessel/practice dialogue content and quest/reaction commands into the current conversation flow. Preserve authored outcomes and identities, then remove superseded dialogue formats/services after their callers are converted. Do not keep a parallel legacy engine or old API for compatibility, and do not introduce a general string event bus.

Validate the whole candidate before publishing catalogs. Fail unsupported keys/IDs/duplicate definitions, missing portraits, dangling graph/fact/flag/choice references and illegal source-to-target identity mapping. Mirror selected source rules: deterministic priority/tie resolution, authored entry order where significant, finite next/continue/end transitions, condition reevaluation at command time, source once-only flags/choice IDs, node-entry facts/seen state, milestones and affinity derivation. N001 identifies exact tie, cap and event-window behavior before fixtures encode it.

Persist only real event aggregates needed by selected graph conditions. Connect actual woods entry/exit, committed foraging and selected dialogue commands to stable source event subjects. Standing in woods for multiple frames is one entry, not unlimited events. Loading, placement reconstruction, failed pickup or replayed reward is not a new action. Use session active time consistently. Do not invent past event ordering/timestamps from a legacy inventory or collected-node list.

A rejected/stale choice, wrong speaker/instance, hidden condition, missing graph or unavailable deferred action changes no memory, inventory or quest state. Publishing an accepted choice must update its facts/flags/affinity/receipts together before observers see the result. Cancel/Close must never apply unselected choice effects. On-node-entry disclosure follows source behavior and is recorded separately from accepting a response.

## Current-schema persistence

N004 owns one deliberate schema change, provisionally schema7/content1 if schema6 is still current. Reconcile actual current format and document the next version before editing. Only the resulting current format is supported; this new project has no backward compatibility requirement.

Add strict plain-data per-NPC memories and bounded event aggregates. Validate all IDs against pinned converted content, numeric limits, independent sets and complete envelope structure. Do not migrate older formats or infer conversation/event history from them. After the schema change, reject schema6 and all other noncurrent formats. Current-schema round trips must preserve health, quest, trust, upgrade, environment, light, inventory, collected IDs, rod placements and new memories exactly.

Do not serialize dialogue cursor, NodePaths, imported visuals, paths, NPC animation time or placement caches. Keep manual Save/Load and current stable-boundary exclusion during dialogue. Closing dialogue retains accepted facts in session; saving later makes them durable. Loading reconstructs actor bindings from stable identity. Failed validation/placement rolls back without replacing current session; corrupt/newer files retain existing reject/backup/preservation rules. Tests use isolated APPDATA/LOCALAPPDATA and named slots; normal user saves are never opened.

## Visual and actor delivery

Reuse the 48 approved portrait PNGs with source expression IDs and preserve their pixels/alpha; do not regenerate faces when copying is enough. Validate dimensions/hashes and actual UI readability without stretching or clipping.

World actors are stylized 3D Blender adaptations of the same people. Use source portraits/sheets and canon as references for face, age, skin/hair, clothing, accessories and silhouette. A generic shared body may support a reusable rig, but recolored copies/capsules are not completed named-character art. Keep actor scale consistent with hero and current town clearance; do not infer mesh height from 2D sprite rectangle height. Collision, identity and interactions live outside replaceable VisualRoot.

N007 extends the existing static [asset pipeline](../../art/exports/PIPELINE.md) with a measured rig/animation contract: identity transforms, ground-foot pivot, Blender/Godot axes, units, named idle/walk/action clips, loop policy, materials/textures and glTF compatibility. Verify an exported rig in Godot before eight character productions. No runtime scripts/cameras/lights in GLBs, external dependencies or automatic collision import.

Each villager task supplies edited source .blend, exported GLB, source/reference mapping and viewed Godot renders. Check face/silhouette/feet and clip transitions at actual camera distance in day/night/rain, approach facing and canopy conditions. Idle/walk clips must exist and work; stationary contact actors need not wander just to advertise animation. Any short local walk remains within an approved clear contact lane and suspends for dialogue/pause/focus/travel. It is not a daily schedule.

N016 ports only the two actually authored semantic actions: Edric river-fishing and Helena archive-work. Inspect these clips in a labeled review scene and, where an approved ordinary contact site supports them, ambient runtime presentation. They grant no fish, items, work rewards or routine outcomes. Report which clips are ordinary-play versus review-only. Do not invent six additional profession animations or mount unsafe desks/props merely to show a clip.

## Evidence and delivery

Use current shared testing tools and project gameplay skill, not historical hard-coded PIDs or stale evidence paths. Existing headless/viewport checks, a fresh rendered route and a fresh packaged native release each prove different things. Proposed checks must be created by their owning task before commands reference them.

Focused task tests cover observable successful and rejected commands, cross-person isolation, rejection of unsupported save versions, lifecycle, real graph use and physical access. Rendered/live acceptance uses ordinary movement and actual UI; synthetic state seeding is labeled rule/fixture evidence. Capture full-size portraits/facts/branches and inspect images.

Final integrated route reaches all eight people, exercises alternative/repeat conversations, saves via pause UI, exits, loads in a separate process and verifies all prior and new durable facts exactly. Alternative mutually exclusive introduction branches need separate isolated fresh sessions. Complete the existing guardian/vessel/Maris fitting flow as a regression. Final Windows packages must work outside the checkout with no source reference dependency, test bridge or private content in release. Record native focus/pause/input/capture provenance, pack audit and actual exit/log results. No publishing is requested.

## N001 pinned decisions (2026-10-07)

Source revision remains60c20eb2816e7271fb84afaba286af006ebe3ccf; selected source
bytes match planning counts70 nodes/24 facts/48 portraits. The completed
[N001 audit](N001_ACCEPTANCE.md), [manifest](../../tools/npc_migration/reference/manifest.json),
[coverage](../../tools/npc_migration/reference/COVERAGE.md),
[adaptation](../../tools/npc_migration/reference/adaptations.json) and
[contact registry](../../tools/npc_migration/reference/contact_registry.json)
are the pinned extraction/placement authority. They contain54 choices,30 condition
fields,8 deferred gift rules and18 world sheets. Only eight selected packages and
66 images are copied; hashed authority/canon/routines/Flutter sources are not copied.
No runtime consumer exists yet. Source geometry stays pinned at its existing
f4630f9 snapshot; newer source actor placements never trigger map regeneration.

Ordinary resolver sorts priority descending then stable node ID ascending; entry
ordering is retained but is not ordinary tie precedence. Routine preferred entries
use supplied order in source and remain deferred. All58 enabled nodes/38 enabled
choices retain authored conditions, portraits and text, except exactly the audited
Della welcome. Twelve nodes/sixteen choices remain deferred (gifts, archive routines,
Edric milestone, Della indoor directions);21 facts can be disclosed ordinarily.
Edric public-role/river-fishing facts have no authored disclosure; Helena archive-practice
has only deferred routine disclosure. Do not auto-learn these three from roles or art.
N009 must assert archive-practice stays unknown at ordinary civic contact until an
actual source-sanctioned consumer exists. No new archive entry or private home.

Source affinity deltas clamp0..2147483647, level threshold3 for each person; only
Edric declares milestone. Source gift acceptance cap is2 per item/NPC; target gifts
stay disabled even with owned Moonflowers. Journal keys match kind/subject/target
exactly, including null; latest-event time-window boundary is inclusive. No selected
graph uses a time window. Source journal supplies no numeric/key count cap itself;
N003/N004 must bound supported target keys and document strict persistence ranges.
Do not infer recorded history from schema6 possessions/collected origins.

Target event subjects: actual outside-to-inside edge of pinned woods-role union
records(areaEntered,woods,null); committed gathering from moonflower-01/02/03 maps
resource-moonflower/item-moonflower to(resourceGathered,moonflower,null). Selected
accepted responses record(dialogueChoiceSelected,npcId,choiceId). Null fields are
not wildcards. No gifts/routines/quest rewards or inherited history are synthesized.
Loading initializes transient woods membership rather than recording an entry.

All eight contact policies in registry passed synthetic current-geometry support,
full conservative radius0.4m/height1.6m capsule, simultaneous reservation navigation,
LOS/range/competition and three water/wall negatives. N006 must implement/reverify
scene-owned reservations; measured specifications are not runtime actors. Maris
keeps existing npc-03-counter/body/bench at(-7.5,0,11), approach(-6,0,11). Edric uses
pinned civic routine foot(-0.5,0,-1.5); Helena(1.5,0,-1.5). Source newer Tess/Ivo/Celia
placements reuse pinned anchors via additive local wrappers. Della stays npc-14,
indoor provenance lantern-rest:della-inn-host-01/inn-host-01(256,288); exterior
adaptation(-9,0,3.5), approach(-9,0,4.5), leaves current inn portal/door clear. Never
apply town transform to her interior feet. Defer ask-room/room directions with an
honest unavailable-interior reason; original source graph bytes remain intact.

Godot4.7.2 Mono/Compatibility/schema6/content1/21 definitions verified. Blender
read-only MCP responds; N007 still must prove rig/animation/export/import extension
of historical static P012 pipeline. All462 current game/art files unchanged by
N001. Future task implementation invalidates N001's unchanged-production assertion;
use its pin integrity independently and create owning task acceptance checks.

## N002 implemented content boundary (2026-10-07)

GameRoot now owns a separate NpcContentCatalog validated before GameSession startup.
Its bundled input is res://content/npcs/catalog.json (format_version 1, the N001
source revision). Existing ContentManifest remains 21 definitions and npc-03 remains
its existing ActorDefinition; NpcDefinition.actor_id aliases the same stable source
identity. A definition/catalog does not activate a character or create an actor state.

Implemented files under game/features/npcs/: npc_content_catalog.gd,
npc_definition.gd, npc_dialogue_graph.gd and npc_content_availability.gd.
See [N002 acceptance](N002_ACCEPTANCE.md) for actual methods, nested typed classes,
complete acceptance and failed-attempt records. Canonical publication deep-copies
validated input; get_npc and document_snapshot return detached views. Caller changes
cannot alter an accepted catalog. Future rule/session owners consume typed data and
must not store current memory or reward state in it.

Deterministic convert_content.py reads only the N001 local pin, preserves full authored
runtime/dialogue fields and applies only its audited Della text adaptation. Portraits
and world-reference sheets are byte-exact local PNGs. Visual paths become owned res://
paths; no runtime dependency on source checkout or tools/reference. Both current
export presets explicitly include the JSON. Coverage reasons and typed ENABLED/
DEFERRED status accompany nodes, choices, facts, gifts, portraits and sheets. A sheet's
reference status never certifies a 3D clip or routine. Conditions remain on deferred
nodes as well as ordinary nodes. Source dimensions are metadata, not physical scale.

Strict loader rejects unknown/missing keys, malformed types/numeric ranges, duplicate
IDs, cross-person/dangling references, missing/wrong assets, unsupported conditions,
contradictory bounds and non-finite graph transitions before publishing any candidate.
All existing schema6/content1, geography, legacy dialogue, quest and companion-trust
contracts remain intact. N003 owns selection/memory rules; N004 owns persistence;
N005 owns actual portrait UI. N007 and character tasks own real exported 3D assets.
