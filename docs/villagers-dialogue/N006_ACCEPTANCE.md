# N006 scene-owned contacts and actual event acceptance

Completed 2026-10-08 UTC. Exactly N006 completed; N007-N018 remain Pending.
No commit or push. [CHECKLIST](CHECKLIST.md) owns status; [CURRENT_STATE](CURRENT_STATE.md)
owns continuation. No ordinary villagers, character art, routines or new package are
claimed by this infrastructure task.

## Baseline and implementation

Target began clean at `8b9da9cdcbbbf3a00f88934a042139409a9ffbc4` (accepted N005).
Source remains clean at `60c20eb2816e7271fb84afaba286af006ebe3ccf`. N001 measured
placements, N002 content and N005 current modal/service evidence were inspected.
Installed console/editor paths exist; execution uses Godot
`4.7.2.stable.mono.official.ed1daf0bf`, Compatibility. Schema7/content1 is unchanged.

`NpcRegistry.entries/find` supply detached copies of all eight N001 fixed contact
feet, player approaches, stable wrapper IDs and 1.7m reach. `NpcRegistry.ENABLED`
is empty. Character tasks N008-N015 own activation and replaceable VisualRoot art.
`PrototypeWorldHost.enabled_npcs` copies this gate, prepares contacts before scene
validation/navigation, and validates staged placement before publishing arrival.
Foreign-room item placement probes also include enabled NPC collision/reservations.

`PrototypeLocation.npc_contacts` owns `NpcWorldAdapter`: seven possible stationary
noncombatant wrappers with radius0.4m/height1.6m capsules, empty replaceable
VisualRoots and conservative navigation reservations. Maris reuses the existing
`npc-03-counter`, body and bench. No ActorDefinition, party member or combat owner
is added. Unknown/duplicate activation rejects before construction; invalid scene
identity or physical placement rejects before replacing the current location.
`PrototypeInteractable.npc_id` validates against the exact registry wrapper identity;
root rechecks the live selected target before routing to the existing single
`NpcDialogueService.begin`. Maris's production recovery route is unchanged while
activation remains empty; N010 must compose ordinary and recovery access.

`PrototypeLocation.npc_events` owns `NpcWorldEvents`, a weak-session membership
sampler. Successful arrival/load/retry and failed-transition reattachment seed the
actual current foot without recording an entry. Root observes physical player feet
only in its active, focused, living, stable world update. Woods membership uses the
union of pinned layout zones whose role is exactly `woods`; overlapping/nested zones
never create extra crossings. Detachment clears the weak owner.

`ForagingState._collect` stages `(resourceGathered,moonflower,null)` only after the
authored flower command, revision, operation, origin and capacity checks pass.
Inventory, origin suppression and event memory publish together before `committed`.
Event-cap failure rejects before any item mutation. Canceled/rejected actions,
rod pickup/placement, reconstruction and restore generate no gather history.
Accepted dialogue choices retain the existing atomic
`(dialogueChoiceSelected,npcId,choiceId)` publication; no second event listener or
general event bus is introduced. All timestamps use session active seconds.

Location exit disconnects its previous foraging listener. Successful arrival binds
one new listener; rollback explicitly rebinds the retained scene. NPC wrappers and
membership are transient and never enter saves. Contacts are fixed; no local walk
or schedule is advertised.

## Every acceptance criterion

| Criterion | Evidence |
| --- | --- |
| Actor/player support, navigation and LOS | Synthetic activation of all eight in the real root; exact parity with N001 registry. Nine-point flat dry support and full capsules validated for every fixed foot/approach; safe LOS and exact source/instance root dialogue binding. All eight approaches reachable with the whole crowd present. |
| Deterministic nearest interaction | Correct target at each person approach; equal-distance civic targets resolve by stable ID. Ten existing light/resource/pickup targets retain physically safe selectable approaches with all eight contacts enabled. Existing lamp/foraging/Maris interaction regressions pass. |
| Critical routes and obstruction rejection | 10,131 samples across all contact paths and eight existing bridge/ford/Moonwell/Tollworks/blocked-exit/Maris routes. Full radius0.4m capsules and dry terrain support, using actual local ramp height for walking routes. Water/quay/building negatives reject; stationary feet retain the stricter flat-foot gate. |
| Once per physical woods crossing | Real capsule motion across the production zone boundary records once; 20 stationary samples, inside rebind and overlapping woods membership add nothing. Exit/reentry adds exactly one more. Arrival into woods, manual load and retry preserve exact aggregates. These are bounded synthetic placement/movement fixtures, not an ordinary town walkthrough. |
| Only committed gathering | New observer assertion sees the event with inventory/origin commit. Actual viewport E holds record exactly three flower events; partial/released holds, twelve modal/input cancellations, seven target losses, full stack/bag, stale/repeated commands, lamp and rod interactions create no flower events. Event exhaustion rejects atomically. |
| Dialogue-choice subject mapping | All eight real root source-graph introductions select an enabled response, publish exactly one matching person/choice event, and reject stale replay without changing memory. Source graph rules and isolation suite passes. |
| Travel/retry/load/disposal/rollback | One wrapper per identity, existing Maris reused, two party members. Old scene freed; foreign location has no villagers; return/retry reconstruct eight once. One foraging listener remains after every lifecycle change. Injected staged NPC water placement rejects, retaining current scene, session and events and reconnecting one listener. Manual isolated Save/Load preserves aggregates exactly; separate-process NPC restart passes. |
| Preserve baseline and deferred scope | Required navigation/activation/travel/companion/foraging/light suites and affected dialogue/save/transaction/startup checks pass. Read-only converter verifies all132 source authority hashes and67 runtime outputs. Source/catalog/portraits/pinned geometry/save schema remain unchanged; production activation remains empty. |

## Commands, isolation and evidence

All commands ran from `D:/development/game-dev-blender/returning-fair-prototype`
under PowerShell7. The shared runner creates fresh task/run-specific APPDATA,
LOCALAPPDATA and named save groups under `builds/testing/N006/<run>/`; no normal
user save was read or written. Evidence paths below are local ignored raw runs.

```powershell
./tools/run_checks.ps1 -Task N006 -Import -Names npc_world_checks,map_navigation_checks,map_activation_checks,location_travel_checks,companion_checks,foraging_interaction_checks,light_interaction_checks,npc_dialogue_rule_checks,npc_save_checks,foraging_transaction_checks,foraging_save_checks,interaction_dialogue_checks,application_smoke -ProcessScripts npc_process_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task N006 -Names npc_world_checks,foraging_interaction_checks -TimeoutSeconds 150
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
```

Expanded run `docs/evidence/N006/20261008-100827014-f14056aa/`: all18 cases PASS,
exit0, zero forbidden diagnostics/timeouts/source changes. Import's existing allowed
missing .NET SDK10.0.9 diagnostic is unchanged; no installation was needed. Snapshot
780 game/tools files: `3697f69612c157dcb95ad24aaab46f27a1614024f0601b0af54e76cd7b7679a3`.
NPC separate-process writer PID29796 and reader PID53696 verify complete durable
old/new state and restored event allowlist/time behavior.

Final test-only extension run `docs/evidence/N006/20261008-101212326-dd2a2f3c/`:
all4 cases PASS/exit0, no forbidden diagnostics/timeouts/source changes. Production
bytes match the expanded run; only world/foraging acceptance assertions were added.
World10,253 assertions/10,131 route samples, foraging130 assertions. Snapshot780 files:
`b212ef8d97d2d0078bff35723489a0654154d7aaa06b5e79d82b9e1f98a52676`.
Inspected both results.json, source-before/after manifests, numbered stdout/stderr
logs, `checks/npc_world_checks/npc-world.json`, foraging-interaction-report.json and
the NPC process writer/reader JSON. No render/capture or native package gate belongs
to N006; no visual acceptance is claimed. Final audit is in the latter run.

Converter PASS: eight people,48 portraits,18 reference sheets,67 exact outputs;
catalog SHA256 `9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.

## Retained failed attempts and handoff

Raw failed runs remain retained:

- `20261008-100343264-ade13139`: sandbox denied process observation during engine
  preflight. Auto-review approved subsequent isolated execution; no approval blocker.
- `20261008-100410605-430770d2`: first import generated four expected tracked UIDs;
  strict source-change guard rejected the run. Later runs use stable UIDs.
- `20261008-100437598-e5c103e6`: test passed a freed scene as a typed argument after
  successful manual load. Fixed the fixture to keep a WeakRef.
- `20261008-100519820-38c5ac92`: route fixture incorrectly applied stationary flat
  foot support to existing ramps. Walking audit now uses authored per-offset terrain
  heights and full capsule clearance; production contact gate was not relaxed.
- `20261008-100706948-c33385f3`: flower-cap fixture filled20 rather than authored99.
  Corrected setup to use the actual ItemDefinition.stack_limit.

Owned checks exited; no editor, process, cleanup, outstanding N006 criterion or
blocker remains. Changed runtime files are the three NPC infrastructure scripts,
PrototypeLocation, WorldHost, GameRoot, PrototypeInteractable and ForagingState;
new npc_world_checks and narrow foraging_interaction_checks assertions plus UIDs.
Workflow/README/architecture document the actual delivered interfaces.

Next eligible task is N007 (reusable exported rig/animation/presenter pipeline).
N008 still requires N007. Exactly one task completed; stop here. Remaining IDs:
N007,N008,N009,N010,N011,N012,N013,N014,N015,N016,N017,N018. All through N018 are
not complete. Character visuals, ordinary villager routes, semantic action art and
fresh native delivery retain their later-task acceptance gates.
