# R006 acceptance: safe exterior stations and entrances

Completed 2026-10-09 UTC. Exactly R006 completed; R007-R016 remain Pending.
Baseline target HEAD `3dfdea9b04b140f48e11a02499d0fd071a3d4161`, source
`60c20eb2816e7271fb84afaba286af006ebe3ccf`, both clean. No baseline user changes.
R002/R005 artifacts and accepted baseline fingerprint were verified, with the
R001 live-source gate passing before implementation. Workspace instructions,
source AGENTS/test-gameplay, current installed/versioned gameplay-testing skill,
architecture and shared runner/isolation/journey/interaction/native guidance read.
No target nested AGENTS or .agents. Both supplied engines exist. The source
Flutter/Linux harness does not apply to this typed GDScript target.

## Delivered scope and criterion mapping

`RoutineExteriorRegistry` returns fresh detached records qualified by
`prototype-alderwake`; wrong maps/unknown anchors/entrances return empty. It owns
exact eleven station IDs, source facing, measured physical Y, dialogue approaches,
two inactive entrance sites and exterior return party feet. No scene construction,
travel dispatch, actor movement, routine activation or durable state is added.

| Acceptance | Actual evidence |
| --- | --- |
| All eleven qualified targets, elevations and source facing | R002 catalog initializes; exact declaration set, R001 source X/Z/facing and measured terrain Y compared in `routine_anchor_checks`. Every source station foot remains exact. |
| Dry support and current capsule clearance | Nine-point flat endpoint support and 0.4m-radius/1.6m-height shape probes for stations, dialogue approaches, entrance/player/ally approaches and returns. Five-point support along every route follows actual pinned elevation. |
| Reachable paths | Production nav queries reach unsnapped approaches; 22 forward/reverse station routes include a continuously collision-swept final approach-to-station leg. Ten additional entrance/party paths give 32 paths and 7,491 physical displacement samples, maximum 0.08m spacing. |
| Required dialogue and door LOS/reach | Every dialogue approach has a clear 0.8m-height ray and distance <=1.7m; approach clearance includes the existing owning actor. Both entrance approach rays are clear. |
| No resource, lamp, other actor, ally station or arrival overlap | Station/approach/door endpoints are compared to live interaction feet, temporary-companion station, both existing arrival party feet and all planned stations. Both return parties use the actual 1m east offset with >=0.8m separation. Conservative 0.4m probes also cover the smaller current 0.35m party capsules. |
| Exceptions measured and bounded | Three explicit adaptations below. Exact source stations, building shells, water, terrain, crossings, lamp/resource identities, fixed contact feet and nav outlines remain unchanged. |
| Negative water/physical failures | Water/building/rail-edge/wrong-elevation/nonfinite probes reject; real bench rejects despite excluding Maris's actor body; occupied original home return rejects and adapted return clears; thin wall stops a terminal capsule sweep. |
| Preservation and inactivity | Entire typed SaveCodec snapshot, player/ally feet and camera remain exact; eight contacts/two party members/one nav region remain. Neither absent room destination is in the live catalog; both metadata entrances stay disabled. |

The checks use a labeled synthetic CharacterBody3D probe on real production
geometry. Fixture starting placement does not certify a route: every subsequent
displacement uses `move_and_collide`, with actual endpoint, collision and footprint
assertions. The prospective moving actor excludes only its own parked static body,
not other NPCs or furniture. Party RIDs are excluded along geometry routes because
R009 owns dynamic occupancy. Endpoint overlap checks remain independent.
Static actor bake holes are retained; nav reaches dialogue approaches and a
physically proved terminal segment reaches its own station. This does not claim
dynamic NPC routing, ordinary input, moving performance or room delivery.

## Exact station mapping

Exterior origin is source (704,576), 32 units/metre. All runtime feet have Y=0,
confirmed against the pinned terrain and physical floor. Approach values are X/Z
metres, also Y=0. Source coordinates and runtime feet are recorded separately.

| Anchor | Source foot units | Runtime foot X/Z m | Player approach X/Z m | Facing |
| --- | --- | --- | --- | --- |
| celia-basic-repairs-01 | 592,960 | -3.5,12 | -3.5,13 | west |
| edric-market-rounds | 640,640 | -2,2 | -2,3.1 | south |
| edric-rain-shelter | 832,400 | 4,-5.5 | 4,-4.4 | south |
| edric-river-bank | 1184,624 | 15,1.5 | 16.1,1.5 | east |
| edric-town-square | 688,528 | -0.5,-1.5 | -0.5,-0.6 | south |
| harlan-sluice-practice-01 | 2016,1120 | 41,17 | 42.5,17 | south |
| helena-town-square | 752,528 | 1.5,-1.5 | 2.5,-1.5 | west |
| maris-fitting-01 | 464,928 | -7.5,11 | -6,11 | east |
| passenger-booking-ivo-01 | 1856,1216 | 36,20 | 34.5,20 | west |
| passenger-salvage-handoff-01 | 1696,1216 | 31,20 | 32.1,20 | east |
| store-service-tess-01 | 944,736 | 7.5,5 | 9,5 | east |

Celia/Ivo newer-source actor adaptations reuse their already delivered unique
contacts; no source actor import or geography refresh. The current Edric fixed
foot equals the source station; older R001 prose suggesting a different foot does
not override current code or the exact source coordinates.

## Measured adaptations and entrance handoff

1. Civic dialogue approach changes from existing contact metadata (-0.5,-0.5)
   to routine metadata (-0.5,-0.6), 0.1m north. Original approach was 0.707107m
   from town-start, below the conservative 0.4+0.35m combined radius. New distance
   is 0.781025m, with 0.031025m clearance; it remains 0.9m from Edric. Actor station,
   historical NpcRegistry and arrival feet remain exact. R006 owns this adaptation.
2. Home source return (4,-5.5) exactly equals rain-shelter station. New hero return
   (4,-4.6) moves 0.9m south: conservative NPC/probe radius 0.4+0.4 plus 0.1m gap.
   Actual 0.35m hero has 0.15m gap to an occupied 0.4m shelter. Ally (5,-4.6)
   preserves existing 1m east arrival. Synthetic occupied-shelter regression proves
   original refusal and new clearance. R006 owns metadata; R007 binds real spawn.
3. Maris's existing actor capsule and real bench were shapes in one StaticBody3D.
   Move only BenchCollision to a sibling BenchBody, preserving exact shape,
   global transform, layer/mask, visuals, identity and navigation outline. The bench
   remains 2.2x0.85x0.7m at local (0,0.425,0.8); self-exclusion cannot hide it.
   Original bench remains 0.05m beyond the 0.4m station capsule. R006 owns the split;
   R009 owns later actor-only static-obstacle replacement.

| Site | Exact source door X/Z | Player / ally approach X/Z | Hero / ally exterior return X/Z |
| --- | --- | --- | --- |
| mayor-vale-home-entrance | 5,-6.25 | 5,-5.15 / 5,-3.95 | 4,-4.6 / 5,-4.6 |
| lantern-rest-entrance-01 | -7,4.25 | -7,5.35 / -7,6.55 | -11.5,4.5 / -10.5,4.5 |

All values have Y=0. Door source/return portal IDs, destinations and arrival IDs
retain exact R001/R002 pins. Inn hero return remains source-exact. Future home/inn
rooms, wall openings, indoor party feet/cameras and ordinary door travel remain
R007/R008 work; no absent destination was enabled by this task.

## Commands, isolation and inspected evidence

Repository cwd `D:/development/game-dev-blender/returning-fair-prototype`,
PowerShell7, explicit console4.7.2. All accepted cases have exit0, empty diagnostics,
`source.changed=false`, `source.error=null`, independent task save groups and
APPDATA/LOCALAPPDATA. Any primary/backup saves from recovery regressions stay within
those groups. New anchor checks only query snapshots; no save is written.

- Initial stable `-Task R006 -Import -Names routine_anchor_checks -ParseScripts
  features/routines/routine_exterior_registry -TimeoutSeconds150`: PASS4 cases,
  [103820 results](../evidence/R006/20261009-103820300-e042b68b/results.json).
  Later coverage expanded and measurements superseded; import remains valid.
- Required/affected `-Task R006 -Names routine_anchor_checks,map_navigation_checks,
  map_crossing_checks,npc_world_checks,world_item_placement_checks,npc_03_checks,
  recovery_presentation_checks -ParseScripts features/routines/routine_exterior_registry
  -TimeoutSeconds150`: accepted crossing/NPC-world/item/Maris/recovery cases in
  [104142 results](../evidence/R006/20261009-104142325-ad0f4b6c/results.json).
  Whole run FAILED for the subsequently repaired navigation fixture timeout;
  it is not relabeled. Crossing4032 support probes/94 bidirectional walk-dodge runs;
  NPC-world10254 assertions/10131 path samples; item128 and Maris729 assertions;
  recovery variants/input/once-only effects/travel/manual save restore pass.
- Final anchor case in `-Task R006 -Names routine_anchor_checks,map_navigation_checks
  -ParseScripts features/routines/routine_exterior_registry -TimeoutSeconds150`:
  [104604 results](../evidence/R006/20261009-104604097-44977619/results.json),
  53,330 total assertions including evidence-write assertion, 7,491 physical samples,
  32 routes, no failure. JSON reports 53,329 before its final write assertion.
  Whole run FAILED for a mismatched repaired fixture portal ID, subsequently fixed.
- Final repaired `-Task R006 -Names map_navigation_checks -TimeoutSeconds150`:
  [104721 results](../evidence/R006/20261009-104721562-d6e285ec/results.json) PASS3
  cases. 336,373 full-mesh/route samples, all three original rollback probes,
  eight replacements,22 routes, query p95=856us. Exact intentional bake-error
  assertion and immediate rejected-request guard preserve original test coverage.
- Bundled Python `-B tools/routine_migration/reference_checks.py --source
  D:/development/game-prototype-2 --self-test --report
  docs/evidence/R006/reference-final/results.json`: PASS1624 assertions,88 source
  inputs,50 exact adaptations,ten negative drift refusals. Original source and
  derived reference pins unchanged; gate adds only R006 as a permitted owning task.

Final game/tools manifest is1218 files at
`cb1e4386fc8cc003cfd22a62735be635f56a9888c45526c039796a31f960e123`.
Final audits compare earlier accepted case manifests to final bytes: only explicitly
listed new registry/check and navigation-fixture/reference-tool changes differ;
production scene/old crossing/NPC/item/Maris/recovery bytes stay exact after their
passing cases. Structured reports, detailed routes/stations, physical failure
probes, logs, source manifests, isolation and intended diff were inspected.

## Failures retained, cleanup and stop

Initial103736 import generated the two owned UIDs; source guard correctly rejected
that run, stable import reran.104005 expanded overlap check found the civic approach
conflict; repaired0.1m without moving station/arrival.104142 old navigation check
awaited a signal after synchronous wrong-source inherited-gate refusal and timed
out150s. Fixture now explicitly binds its own source and the check never awaits
after refusal; all physical geometry and rollback probes retained.104604 first
repair used the wrong portal ID; exact diagnostic retained, corrected to the
actual `tollworks-entrance-01`, then104721 passes. Failed reports were not erased.

Allowed changes are the new registry/check/UIDs, narrow Maris collider split and
two assertion-path updates, required nav fixture/check repair, strict reference
owner gate/ledger, five narrow byte-preservation attributes, architecture and this
workflow's checklist/handoff/acceptance. No unrelated changes, source writes,
normal saves, packages, editor, native input, agents, extra chats, commits or pushes.
Default sandbox helper failed setup; bounded reviewed commands succeeded, with
no approval rejection. All owned Godot processes exited, no held input/editor or
cleanup owed; unrelated Blender2664 preserved. Raw R006 evidence/staging retained.

Blockers/unrun R006 criteria: none. Ordinary routines/rooms/render/native proof
are separately owned downstream criteria, not claimed here. Remaining unfinished:
R007,R008,R009,R010,R011,R012,R013,R014,R015,R016. Every checklist item through R016
complete: no. Next eligible R007; consume measured home entrance/return metadata,
build only the home and its nine stations, then verify its own criteria. Stop here;
await separate successful-task commit request.

Final documentation/source audit passes:16 intended paths,76 relative links,
all16 task states/dependencies and nextR007;1218 accepted files remain exact,
Maris geometry/visuals unchanged except collider ownership, source clean and
index/HEAD unchanged. Detailed audit: `docs/evidence/R006/final-audit.json`.
Initial audit helper trimmed Git porcelain leading whitespace; corrected helper
and reran, with no project-source change. No remaining blocker or cleanup.
The narrow -text rule exposes existing checkout CRLF in the npc_03 Git diff;
normalized HEAD/disk comparison proves only the one bench-path assertion changed.
The same exact comparison verifies recovery_presentation_checks. Historical
baseline hashes remain original; reviewed raw after-bytes are preserved on checkout.
