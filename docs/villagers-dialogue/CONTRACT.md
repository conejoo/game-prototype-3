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

## N003 implemented rule/session boundary (2026-10-08)

[N003 acceptance](N003_ACCEPTANCE.md) records actual interfaces and source semantics.
GameSession.conversations owns NpcConversationState, eight detached ConversationMemory
values and bounded NpcEventMemory. GameRoot.npc_dialogue owns NpcDialogueService;
NpcDialogueRules is pure. Existing legacy dialogue remains the ordinary gameplay
owner until N005 converts all callers. N006 owns actual woods/gather event adapters.

Ordinary entries rank priority descending, stable node ID ascending; enabled coverage
and authored conditions both apply. Entry records only seen node/authored fact IDs.
Accepted response stages flags/once-only receipts, signed bounded affinity, exact
choice event and linked target disclosure, then swaps the entire state before changed.
Close/owner cancel applies no unselected effects. Commands include NPC/instance/node
and service-generation token; stale/foreign publication and unavailable/hidden/consumed
responses reject with no changes. Linked target conditions retain source entry-gate
meaning. No routine preference, milestone injection, gifts or quest/trust authority.

Event allowlist has 40 keys: (areaEntered,woods,null),
(resourceGathered,moonflower,null), and dialogueChoiceSelected for 38 enabled exact
NPC/choice pairs. Null stays exact. Count/global/first/last sequence cap2147483647;
finite active timestamps0..2190600 seconds, globally nondecreasing. Exhaustion rejects
whole transaction with no eviction/saturation. Latest-event window boundary inclusive.
Source-like once-only receipts apply only to has_one_time_effect choices; repeatable
responses can record repeated events without gaining an invented one-time receipt.

N004 must strictly validate restored IDs, complete structure, bounds and derived
relations, reconstruct allowlist/latest timestamp and detach candidates before swap.
At the historical N003 boundary, schema6 intentionally serialized no conversation/event
state. N004 replaces it with schema7/content1 below. Cursor/token/scene/animation
state stays transient.

## N004 implemented strict persistence boundary (2026-10-08)

Current runtime supports only schema7/content1. No schema6 or other old/new format,
migration, ID remapping, inferred inventory history or missing-field default is
accepted. Historical deliveries and packages retain their own documented versions.
See [N004 acceptance](N004_ACCEPTANCE.md) for interfaces, bounds and evidence.

SaveCodec requires conversations with exactly eight people and bounded events.
GameSession.initialize accepts optional validated npc_content after restored_environment;
fresh sessions initialize all eight memories, while validated restored candidates
publish NpcSaveData.Result.state only after every existing/new fact passes validation.
Root rebinds the durable state to a fresh inactive cursor after physical acceptance.
Root Save/Load rejects either active dialogue service until closed.

Each person stores npc_id, affinity, derived level, flags, learned_fact_ids,
seen_node_ids and applied_choice_ids. Seen nodes must be enabled and person-owned;
facts equal their authored disclosures. Choice events, once-only receipts, added
flags/reward flags, affinity and level must agree; introduction alternatives remain
exclusive. Current enabled pin has nonnegative reward deltas and one one-time
introduction per person. Future negative deltas require ordered persistence and
reject here rather than inventing chronology; general source rule clamping remains.
Detached candidates canonicalize sets without mutating inputs. Duplicate/foreign/
deferred IDs, unknown fields and shared/cyclic mutable containers reject.

Event envelope stores last_sequence and <=40 exact allowlisted facts with kind,
subject_id, target_id, count, first_sequence, last_sequence, first_active_seconds,
last_active_seconds. Existing 2147483647 count/sequence and 2190600-second time caps
remain. Totals, unique endpoints, count/span feasibility, global time order and
timestamps <=saved elapsed active time must agree. Restore rebuilds the allowlist
and latest time from the validated catalog/latest sequence. Null is exact. Integer
lexemes cannot hide rounded fractions; every timestamp round-trips binary64 exactly.
No cursor/token/NodePath/imported visual/animation/placement cache is serialized.

SaveRepository backup, failed staging, incompatible-file preservation and read-only
visible recovery remain unchanged. Physical placement rejection keeps every prior
and new live fact/owner. Tests use fresh isolated slots; source, user saves, geometry,
content/portraits, companion/quest/trust authority and manual boundaries are retained.

## N005 delivered conversation composition (2026-10-08)

This replaces the historical two-service root composition above. GameRoot.dialogue
is the single NpcDialogueService owner. begin(npc_id, instance_id) and
begin_graph(ConversationDefinition, instance_id) select source and current prototype
graphs through the same NpcDialogueGraph/cursor/snapshot/UI/lifecycle. Stable commands
carry person, instance, node and generation token; prototype commands remain in
authored Choice.command and dispatch only to root-owned legal quest/reaction hooks.
Callback reentry rejects; callback cancellation cannot resurrect a cursor. No
DialogueDefinition/DialogueChoice/DialogueService or parallel legacy cursor remains.

Six existing prototype resources retain all original stable IDs, speakers, words,
response order and15 legal commands across24 finite nodes. Presentation indexes are
read-only fixture observation metadata, never a second line-navigation API. Prototype
graphs apply no source NPC facts/affinity; Maris recovery reads the same person's
already learned facts. The temporary companion retains its original role/labels.

Snapshot supplies graph_id/npc_id/instance_id/node_id/token, speaker/text/portrait,
available choices with honest reasons, can_continue/can_close, learned fact records
and current-node revealed IDs. ConversationView formats paired source bold markers,
preserves literal brackets, highlights current disclosures and renders only learned
facts. Body/choices/facts scroll; exits stay visible and keyboard focus contained.
Open/node change/close clear held input; modal blocks world/combat/gather/drag/camera/
save commands. Focus loss/unload cancel without unselected effects; focus gain needs
fresh controls. Save restoration always binds an inactive cursor. Schema7/content1
and manual save boundaries retained.

[N005 acceptance](N005_ACCEPTANCE.md) records exact conversion, all criteria,48
source expressions/eight people, actual960x640/1350x900 captures, unavailable-gift
mouse/keyboard exits and required/affected regressions. UI bindings/expression and
length fixtures are synthetic. Ordinary eight-person routes/3D art/native packages
remain N006-N018 work; existing source portraits are reused byte-exactly. Pinned
geography, source hashes, deferred capabilities and normal user saves unchanged.

## N006 delivered contact and event boundary (2026-10-08)

NpcRegistry.entries/find supplies the eight N001 measured fixed public contact feet,
approaches, wrapper identities and reach. ENABLED remains empty; N008-N015 must
activate only their completed characters. WorldHost.enabled_npcs prepares each
scene's NpcWorldAdapter before validation/navigation and checks complete actor/player
support, capsule clearance, reachable approach and LOS before publishing arrival.
Foreign-room item placement probes include enabled NPC collisions/reservations.

Seven possible wrappers have radius0.4m/height1.6m collision outside an empty
replaceable VisualRoot, plus conservative navigation reservations. Maris reuses the
existing npc-03-counter/body/bench. No new ActorDefinition, party member or combat
owner is created. PrototypeInteractable.npc_id must match its exact registry instance;
root revalidates the selected live wrapper and uses the existing single dialogue
owner. Production Maris recovery is unchanged while activation is empty; N010 owns
ordinary/recovery route composition. Fixed contacts imply no walking schedule.

PrototypeLocation.npc_events owns weak-session NpcWorldEvents membership. The union
of pinned woods-role zones determines physical outside-to-inside edges. Root samples
actual feet during stable focused living world updates. Arrival/load/retry/rollback
seed membership without recording; exit clears the weak owner. Overlapping zones,
stationary frames, placement reconstruction and load do not invent entry history.

ForagingState stages only a successful authored flower gather's exact
(resourceGathered,moonflower,null) before mutation, then publishes inventory/origin/
memory together before committed observers. Unsupported/capped event state rejects
before any item mutation. Rod operations, partial/canceled/full/replayed commands
and restoration record no gather. Existing dialogue-choice publication retains exact
(dialogueChoiceSelected,npcId,choiceId). No scene listener fabricates these events,
general bus, routine simulator, save field or format change is introduced.

Location exit disconnects old foraging ownership; successful arrival and failed-scene
rollback reconnect exactly one listener. All wrappers/membership stay transient.
[N006 acceptance](N006_ACCEPTANCE.md) records all18 expanded and4 final passing cases,
all-eight physical synthetic activation, 10,131 route samples, source choices, actual
viewport gather assertions and exact lifecycle/restart proof. Ordinary character art/
routes and native packaging retain later gates. N007 is next eligible.

## N007 delivered animated visual boundary (2026-10-08)

[NPC_PIPELINE](../../art/exports/NPC_PIPELINE.md) extends historical static exports;
[N007 acceptance](N007_ACCEPTANCE.md) owns complete measurements/commands/evidence.
Generic16-bone checker calibration has an editable .blend, embedded-texture GLB,
baked idle/walk clips, identity meter/ground transforms and inspected Compatibility
captures. It is not a completed named character. NpcRegistry.ENABLED stays empty.

NpcVisualPresenter.mount validates before replacing an accepted model. Actual
achieved speed selects/rates exported loops; facing rotates only visuals. Separate
reason holds suspend/resume animation without moving wrappers or serializing pose.
Wrapper owns stable IDs/collision/navigation and scene disposal. Named tasks must
connect actual lifecycle owners, enforce person-specific clip/texture bounds and
prove ordinary access. Calibration walk stays review-only. No semantic action,
routine, gift, reward or current-save-format change is introduced.

Shared caps: <=12,000 exported triangles,32 bones,3 material surfaces per person;
eight-person estimate96,000 triangles/256 bones/24 main surface draws. One1024²
RGBA atlas/person estimates32MiB before mips; count extra maps/shadow passes as
documented. N007 measures an actual eight-calibration scene, not maximum-cost map
performance. N017 owns integrated final crowd regression. N016 owns source-mapped
action_river_fishing/action_archive_work; neither clip exists in calibration.

## N008 delivered named-character boundary (2026-10-08)

This supersedes the historical empty-activation state above. NpcRegistry.ENABLED
contains only npc-01; VISUAL_ASSETS maps its custom named GLB. NpcWorldAdapter
mounts an accepted NpcVisualPresenter under VisualRoot/Presenter and rejects the
candidate location on asset failure. Other definitions do not become live actors.
The original civic foot/approach/instance, capsule/navigation and source graph/
six portraits remain unchanged. No new Party/ActorDefinition or saved pose.

GameRoot forwards independent dialogue/pause/focus/travel/modal/death holds on
control changes and process ticks; speaking faces actual player feet by rotating
visuals only. Fixed contacts report zero achieved motion. WorldHost owns disposal,
rollback and one-per-person reconstruction. Idle ordinary; walk review-only.
River-fishing stays N016; no invented routine/fishing/gift outcome or disclosure.

[N008 acceptance](N008_ACCEPTANCE.md) records ordinary helpful/neutral branches,
real first/repeat woods edges and committed Moonflower gathering/once-only preference,
disabled gifts, exact independent GUI restart, physical/lifecycle regressions and
viewed named-art/day/night/rain/default-camera evidence. The actual package and
reusable interfaces are in [NPC_01_PACKAGE](../../art/exports/NPC_01_PACKAGE.md).
Only the source-authored preference becomes known; public-role/river-fishing facts
remain undisclosed. Schema7/content1 and all prior manual-save/geometry boundaries
are retained. N009-N018 remain unfinished; N009 is next eligible.


## N009 delivered Helena boundary (2026-10-08 UTC)

Current NpcRegistry.ENABLED is exactly npc-01/npc-02, superseding historical
single-person activation above. Helena's named GLB mounts under the same
transactional VisualRoot presenter at public civic foot(1.5,0,-1.5), approach
(2.5,0,-1.5), exact source prompt Talk to Archivist Vale. Her source graph and
six portraits stay unchanged; independent noncombatant physics/navigation/lifecycle
stay outside visuals. No new party/actor state or save field.

Ordinary introduction discloses npc-02-public-role; actual committed Moonflower
gathering gates npc-02-moonflower-pressing once. Both introduction alternatives
retain their mutually exclusive source flags/receipts/affinity. Archive-practice
remains unknown; two routine preferred entries/all five routine outcomes remain
explicitly deferred. No archive-work, daily suppression, ledger jump, private
household disclosure or interior is invented. Idle ordinary, walk review-only;
source archive-work belongs to N016. Exact manual new-process GUI restart and
all common acceptance are in [N009 acceptance](N009_ACCEPTANCE.md) and
[NPC_02_PACKAGE](../../art/exports/NPC_02_PACKAGE.md). Schema7/content1, source
pins, portrait pixels, geography and prior features remain unchanged.


## N010 delivered Maris counter composition (2026-10-08 UTC)

Current activation is exactly npc-01/npc-02/npc-03. Existing npc-03-counter, foot
(-7.5,0,11), approach(-6,0,11), body/bench/service props remain authoritative.
Accepted art mounts under VisualRoot/Presenter and hides former capsule mesh only.
No duplicate person/counter/Party member or collision change.

E opens current effect-selected prototype recovery graph. Same ConversationView
has contained-focus Chat/Recovery button. GameRoot._switch_maris_route validates
current snapshot, mode and actual selected scene-owned counter before replacing
one transient cursor. Source graph/choices/portraits/facts remain unchanged.
Ordinary facts/affinity/receipts belong to Maris memory; Chat grants no quest/trust/
item/service effect. Recovery retains original source/location/order authority.
Switch/cancel/leave cannot complete practical fitting. Customer/helper remain
honest temporary fixtures. Schema7/content1/manual Save/Load remain unchanged.

[N010 acceptance](N010_ACCEPTANCE.md) and [Maris package](../../art/exports/NPC_03_PACKAGE.md)
record source-informed3D art/ordinary branches/exact new-process restart,
physical/lifecycle/regression proof and explicit returned-fitting prerequisite5
segment. Idle runtime, walk review-only; gifts/commerce/routines unavailable.
N011 next eligible; full fresh all-eight/recovery/native proof stays N017/N018.

## N011 delivered Harlan public dock boundary (2026-10-08 UTC)

Current activation is exactly npc-01/npc-02/npc-03/npc-04, superseding historical
three-person activation above. Source alderwake:harlan-dockmaster-01/anchor
harlan-sluice-practice-01 foot(2016,1120) maps to approved dry target(41,0,17),
approach(42.5,0,17), exact instance alderwake-npc-04-contact and source prompt
Talk to Harlan Reed. No geographic refresh, interior, quay/ship/stage change or
sluice/travel capability. Existing scene-owned wrapper retains capsule/navigation;
distinct7387-triangle/16-bone/packed-palette skin mounts under VisualRoot/Presenter.
No Party actor/save field/pose persistence. Idle/facing ordinary, walk review-only.

Exact source graph/six portraits and three public-role/shared-checks/shore-birds
facts retained. Careful+1/passing0 introductions exclusive with one receipt;
public work/weather/hobby available at zero level. Gift transaction/target remain
honestly deferred. No accident/private testimony/household or future campaign
disclosure, quest effect, companion trust or item/service grant. Manual schema7/
content1 and all prior state preserved. Ordinary input/GUI separate-process
restart, actual dry contact, lamp/rod arbitration and viewed art evidence are in
[N011 acceptance](N011_ACCEPTANCE.md) and
[Harlan package](../../art/exports/NPC_04_PACKAGE.md). N012 next eligible;
N017/N018 retain fresh integrated all-eight/native package acceptance.

## N012 delivered Tess public store boundary (2026-10-08 UTC)

Current activation is exactly npc-01/npc-02/npc-03/npc-04/npc-06. Tess uses
source alderwake:tess-store-01/store-service-tess-01 foot(944,736), approved
target(7.5,0,5), approach(9,0,5), instance alderwake-npc-06-contact. Existing
pinned store anchor/geographic snapshot and neighboring lane remain unchanged.
Named8496-triangle/16-bone/packed-palette skin mounts under VisualRoot/Presenter;
one fixed noncombatant, no Party actor/save field. Idle/facing runtime; walk review-only.

Source graph/six portraits and three public facts remain exact. Careful+1/passing0
introductions exclusive, supplies/help/busy/hobby public branches at zero affinity.
Fixed modal commerce notice supplements source role text without changing it.
No functioning purchases, wallet, deliveries, supply grant, quest/trust effect,
gift transaction, schedule or interior. Strict manual schema7/content1 unchanged.
[N012 acceptance](N012_ACCEPTANCE.md) and [Tess package](../../art/exports/NPC_06_PACKAGE.md)
record all criteria, actual ordinary input/exact GUI restart, lane/support/lifecycle
and inspected art/weather evidence. N013 next eligible; N017/N018 keep final
integrated all-eight/native gates.


## N013 delivered Ivo dry booking-shore boundary (2026-10-08 UTC)

Current activation exactly npc-01/npc-02/npc-03/npc-04/npc-06/npc-07. Source
alderwake:ivo-passenger-dock-01/passenger-booking-ivo-01 foot(1856,1216) maps
to approved dry target(36,0,20), approach(34.5,0,20), stable instance
alderwake-npc-07-contact. No pinned map refresh, quay/ship change or service.
Distinct8135-triangle/16-bone/packed-palette3D skin mounts under existing
VisualRoot/Presenter. Fixed noncombatant idle/facing runtime, walk review-only;
no Party member, saved pose or profession action.

Exact source graph/six portraits and public-role/local-seamanship/knotwork
disclosures retained. Careful+1/passing0 exclusive receipts and public branches
work at level0; gifts remain deferred. Fixed modal explicitly says booking,
salvage jobs and departures unavailable. No second-city passage, hull repair,
payout/customer sequence, quest/trust change or private disclosure. Existing
shortened-recovery helper remains unnamed/temporary, separate from Ivo.
Strict manual schema7/content1 unchanged. [N013 acceptance](N013_ACCEPTANCE.md)
and [Ivo package](../../art/exports/NPC_07_PACKAGE.md) verify ordinary access,
exact independent GUI restart, dry-footprint/quay return/water negatives,
lifecycle/facing and inspected source-informed art/weather. N014 next eligible;
N016-N018 retain semantic actions/integrated all-eight/native acceptance.

## N014 delivered Celia public repair boundary (2026-10-08 UTC)

Current activation exactly npc-01/npc-02/npc-03/npc-04/npc-06/npc-07/npc-08.
Source celia-basic-repairs-actor-01/celia-basic-repairs-01 foot(592,960) maps
to approved dry target(-3.5,0,12), approach(-3.5,0,13), stable instance
alderwake-npc-08-contact. No map refresh, dock/ship alteration or service.
Distinct10,014-triangle/16-bone/packed-palette skin mounts under existing
VisualRoot/Presenter. Fixed noncombatant idle/facing runtime; walk review-only.
No Party member or saved pose.

Exact source graph/six portraits and public-role/basic-repairs/woodcarving
disclosures retained. Careful+1/passing0 exclusive receipts and four public
branches work at level0; gifts deferred. Fixed modal supplements source words:
repair services and fair boat rides unavailable. No boat ride/transaction,
memory recovery, morning scene, reward, stage/quest/trust or private disclosure.
Strict manual schema7/content1 unchanged. [N014 acceptance](N014_ACCEPTANCE.md)
and [Celia package](../../art/exports/NPC_08_PACKAGE.md) verify ordinary access,
exact independent GUI restart, repair-lane round trip/full footprint, lifecycle
and inspected source-informed art/weather. N015 next eligible; N016-N018 retain
semantic actions/integrated all-eight/native acceptance.
