# R001 — source, mappings and acceptance pins

Done 2026-10-09 UTC / America/Vancouver. Exactly R001 completed.
Final workflow ID is R016; R002-R016 remain Pending. Next eligible: R002.

## Delivered reference evidence

Target baseline `e10d13edd6035aeb3bac4cbaded6f82b756f8e39`; read-only source
`60c20eb2816e7271fb84afaba286af006ebe3ccf`. Source was and remains clean. Target
began with only the four user-authored untracked workflow documents. No nested
target AGENTS.md or target/workspace `.agents` exists. Workspace instructions,
installed/versioned returning-fair-gameplay-testing skill, source `.agents` testing
guidance, current runner and save-isolation/observation docs, architecture, N/G/F/FS/W/M
handoffs and source/target code were inspected. Old handoff schema numbers remain
historical: actual codec is schema7/content1.

| Criterion | Evidence and result |
| --- | --- |
| Exact scope and exclusions | [Manifest](../../tools/routine_migration/reference/manifest.json), [selected catalog](../../tools/routine_migration/reference/selected_catalog.json), [exclusions](../../tools/routine_migration/reference/exclusions.json): 39 source routines, exactly 25 selected/eight people; 14 routines/seven other people excluded. Selected public packages/routines only; full public maps are reference geometry, never automatic cast import. |
| Hashed inputs and drift refusal | 88 source authority inputs; 85 byte-exact snapshots plus three authority-only hashes/selected extracts. Every relative source path/revision/hash recorded. Closed snapshot inventory, target baseline and derived hashes checked. Source tests pinned/read, not run. [Preservation](../../tools/routine_migration/reference/preservation_baseline.json) verifies all 1,238 pre-existing tracked files unchanged. |
| Full mappings and owners | [Coverage](../../tools/routine_migration/reference/coverage.json) maps every routine/participant/step, condition, qualified anchor, public node/choice/flag/fact, entry/outcome/event and action. Exact five real Helena tags/jumps checked against source choices/participant plans. Current routine entries correctly remain deferred; social/gift activation must compose rather than be overwritten in R011. |
| Qualified anchors and portals | [Mappings](../../tools/routine_migration/reference/mappings.json): 21 targets (11 exterior, nine home, one inn); four directed reciprocal doors and nine ordered map-pair chains. Flattened group rectangles match pinned exterior; quarter-turn fixtures cover all four rotations. Existing Tollworks interaction/arrival IDs retained; other gates excluded. All source/target feet, facings, deltas and owners recorded. No anchor shifted. |
| Rooms, obstacles and actual envelopes | [Geometry audit](../../tools/routine_migration/reference/geometry_audit.json): home 16x14m, inn 28x24m; explicit local origins, floor/door limitations, nearest geometry at every required anchor/door; 21 consecutive move legs, including straight-line collision diagnostics and required cross-map chains. NPC 0.4m/1.6m, hero/ally 0.35m/1.6m, Maris current 0.35m; source town-adult radius only 0.3125m. Seven bounded repair records own real risks. No untested route described as safe. |
| Source motion/selection/reconstruction | [Semantics](../../tools/routine_migration/reference/source_semantics.json), [vectors](../../tools/routine_migration/reference/vectors.json), [INT-064](../../tools/routine_migration/reference/INT-064.md): speed64 units/s=2m/s; blocked wait0.5s, two repaths. Inclusive/exclusive/overnight, priority/ID, atomic groups, flags/facts/count/recency/weather and elapsed-window vectors pass. Actual source world caller pins origin precedence, release/restore/start and elapsed replay; ordinary reassignments differ from reconstruction. Pending source failure enum remains unknown; R010 owns diagnosis/repair. |
| Numeric budgets/readiness | [Budgets](../../tools/routine_migration/reference/budgets.json): scheduler+eight NPC p95<=2ms; established path p95<=5ms; unchanged leg no per-frame path requests; max reconstruction50ms/64 transitions per actor/512 total; wait/repath limits; one room/region/wrapper; ten-cycle zero owned-object growth and <=64MiB working-set growth. Historical accepted N017 idle/query baseline and current machine/settings documented, no moving-runtime measurements invented. |
| Art readiness and declared activation gates | [Action metadata](../../tools/routine_migration/reference/action_assets.json): existing Edric `action_river_fishing` and Helena `action_archive_work` GLB clips/hash/mesh inventory inspected. Separate review variants, not promoted/rendered; R012 owns production fitting/actions. No further durable fact needed beyond R004 authored events/day suppression. All later physical/rendered/native gates remain explicit. |

## Measured conflicts and bounded decisions

- Seven routine destinations overlap retired fixed NPC bake bodies/outlines. R009
  replaces actor-only obstacles with occupancy; retains Maris 2.2x0.7m bench,
  authored worktop and TemporaryCompanion station/party identity.
- Home hall inner faces232..280 source units give 1.5m width, versus1.7m for two
  0.4m-radius NPCs with0.1m gap. R007/R009 first prove single-file reservations/yield
  at room pockets; a needed target-local wall repair must have bounded measured
  before/after, without source writes.
- Both home rest feet have only0.450694m center clearance to bed corner:
  0.050694m beyond target capsule. R007 must validate actual nav/capsule access;
  conservative obstruction margins may require measured furniture clearance
  repair. No closer rest anchor, teleport or claim of safety was introduced.
- Della's current exterior(-9,0,3.5) maps to single indoor host(-6,0,-12) in the
  new local frame. R008/R013 retire exterior contact; room access enables no sleep/booking.
- PrototypeLocation still has one destination per room. R005 binds individual
  qualified doors; NPC queries cannot move player/party/camera. Proposed room
  arrivals(0,0,0)/(0,0,-1.2) remain unaccepted until physical room tests.
- Source reconstructs from first sorted authored placement or first move anchor,
  then advances elapsed time. Edric's source town origin(704,528) differs from
  target civic foot(688,528). Source executor goal snapping and cancellation/release
  ownership must be deliberately adapted by R009/R010; unknown INT-064 cause is not inferred.

Exterior geography remains `alderwake-f4630f9-m002` byte-exact. Exterior origin
(704,576), home(256,384), inn(448,672), scale32 units/metre finalized. Indoor Y=0 is
new-room floor proposal; exterior Y is audited from actual pinned elevation code,
then must be verified through physical support. All21 anchor deltas are zero
under their own map frame; Della's map move remains an explicit change of ownership.

## Verification, failures and limits

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`. Verified bundled
Python3.12.14 at `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Both supplied Godot executables exist; console `--version` returns
`4.7.2.stable.mono.official.ed1daf0bf`. Current machine Core Ultra9 185H,
RTX4070 Laptop/Intel Arc, 33,736,015,872 bytes RAM. Historical N017960x640 Compatibility
ABBA baseline: crowd p95 civic7.539/dock11.590/bridge11.170ms; query max p951.190ms.
Those are prior fixed-contact measurements read from its acceptance, not fresh routine proof.

```powershell
$routinePython = 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $routinePython -B tools/routine_migration/pin_reference.py --source D:/development/game-prototype-2
& $routinePython -B tools/routine_migration/audit_geometry.py
& $routinePython -B tools/routine_migration/reference_checks.py --source D:/development/game-prototype-2 --self-test --report docs/evidence/R001/20261009-reference-final/results.json
& $routinePython -B tools/routine_migration/audit_geometry.py --check
```

Final [structured result](../evidence/R001/20261009-reference-final/results.json):
PASS1,624 assertions, all25 selections/21 anchors/88 authority inputs; six negative
fixtures correctly refused (byte drift, allowlist, excluded cast despite forged hash,
unsafe path, qualified anchor despite forged hash, source hash). 3.433s offline
reference audit includes preserved-file hashing; not gameplay latency. Geometry
check PASS two rooms/four doors/21 legs/seven repair records. An earlier stable
1,613-assertion pass was repeated only after adding the actual source world
reconstruction caller and closed snapshot verification, a new substantive concern.

[Capture history](../../tools/routine_migration/reference/capture_history.json)
retains failures: sandbox helper setup twice (before execution), unavailable Python
Store alias, initial `collision.kind=none` capture KeyError before writes, and first
check's Windows charmap/incorrect finalization cwd. Failed
[report](../evidence/R001/20261009-reference-first/results.json) retained. Explicit
UTF-8/correct cwd/none handling repaired them. Initial derived coverage was corrected
against actual `coverage.status` and singular `outcomeTag` before acceptance.
World-caller dependency and action metadata were deliberately added with hashes;
no existing source pins refreshed. No automatic approval rejection occurred.

Default sandbox shell setup remained unusable; reviewed elevated commands performed
bounded authorized reads/reference writes. Git used per-command safe.directory,
no global config. `rg` unavailable; bounded Python/PowerShell used. No engine game,
Godot editor, Blender operation, native input, ordinary save, test save, source
write, package/export, agent/chat, commit or push occurred. TEMP negative copies
automatically cleaned. Existing unrelated Blender process untouched; no owned
process/input/editor state or cleanup owed. No capture inspection was needed:
this task's evidence is JSON/text/GLB metadata; visuals/routes remain later gates.

All R001 criteria passed. No R001 blocker. Gameplay suites/source Dart suites,
physical routes/rooms, moving-runtime budgets and INT-064 reproduction are unrun
explicit downstream work, not waived. R002's exact next action: consume local pins,
implement strict detached immutable catalog and `routine_content_checks.gd`, then
run its required checks through current runner with task-owned isolated save groups.
Stop before R002. Whole checklist is not complete.

Final documentation readback passed: all16 statuses/sections/dependencies valid,
exactly R001 Done, next R002 (R005 independently ready), final R016 and50 relative
links resolved. Git diff --check passed; intended untracked diff confined to this
workflow and tools/routine_migration, preserving pre-existing AGENT_PROMPT. No Godot
process remains; unrelated Blender PID2664 untouched. Offline check without --source
also passes, proving local reference operation needs no live source checkout.

Successful-task commit follow-up separately authorized. Git core.autocrlf=true;
scoped tools/routine_migration/.gitattributes now preserves exact reference bytes
and LF tools on checkout. Original pins unchanged. Staged blob SHA256 is checked
against every snapshot/derived pin before commit. Unchanged AGENT_PROMPT is included
as required workflow dependency. Raw ignored logs remain local; durable acceptance,
manifest/vectors/geometry/coverage/budgets are committed. No push or R002 work.
Commit preflight repaired one generated excerpt blank line at EOF, explicitly updating
derived INT-064/capture-history hashes; all byte-exact source snapshots unchanged.
