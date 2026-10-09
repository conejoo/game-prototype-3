# Day clock and NPC routines current state

Updated 2026-10-09 UTC / America/Vancouver. R001-R003 complete.
Routine content and pure selection delivered; production activation not started.
Read [CHECKLIST](CHECKLIST.md), [CONTRACT](CONTRACT.md), [AGENT_PROMPT](AGENT_PROMPT.md).

## Current selection

Active task: none. R003 Done; R004-R016 Pending. Exactly R003 completed this invocation.
Baseline HEAD 2f0d60f39ae87731309d8f3bbd1c356a1913a8c5, clean before work; source
clean at60c20eb2. No nested AGENTS.md or workspace/target .agents found. Source
test-gameplay skill read; its Flutter/Linux tools do not apply to Godot target.
Current versioned/installed gameplay-testing skill, runner and shared save/journey/
interaction/native guidance read. Supplied engine exists; no SDK install required.

R003 allowlist/actual changes: four new context/plan/resolver/director scripts and
their UIDs under game/features/routines/, two new routine_* checks and their UIDs,
CHECKLIST.md/CURRENT_STATE.md/R003_ACCEPTANCE.md and ignored R003 evidence/staging.
All pre-existing game/tools/content bytes preserved, including R001/R002 pins,
schema7/content1 and geography. AGENT_PROMPT/user instructions/source unchanged.
No baseline user changes existed. Unrelated Blender PID2664 preserved.
No root activation, movement, save field, geometry, dialogue/art or extra task.
Implementation ended without commit/push. Separate R003-only successful-task commit
is now authorized; follow-up details below. No push or R004 work authorized here.

## R003 result and verification

RoutineResolutionContext detaches environment clock, weather-derived/authored event
union and actual conversation/event-memory snapshots. Reuses NpcEventMemory.matches
for exact keys/inclusive count and recency. Invalid samples fail before director
publication. Caller supplies authoritative suppression day; old-day IDs are ignored
only at day-index rollover, with no mutation or durable suppression owner here.
R004 must implement actual commands/persistence/expiry; R003 fixtures are not saved
delivery. Narrow existing WeatherSchedule epsilon normalizes float boundary round
trips; no second clock/time seek/offline advancement.

RoutineResolver applies suppression/window/AND-conditions/conflict precedence,
priority descending/ID ascending and whole-group acceptance. Immutable transient
plans expose detached stable assignments/ID-enum rejection diagnostics and current
elapsed window seconds. RoutineAssignmentDirector compares actual decision truth
and day, reevaluating when window/condition/suppression/recency changes; unchanged
updates refresh elapsed without resolution/revision/restart. Caller must sample on
updates even without player input. Changed participants include both group members;
same-routine new day is a new assignment generation. No actor/executor/effects.

R001 preflight: bundled Python3.12.14 tools/routine_migration/reference_checks.py
--source D:/development/game-prototype-2 --report
docs/evidence/R003/reference-preflight/results.json PASS1624, source hashes unchanged.
Repository cwd for all commands. Final affected checks:
./tools/run_checks.ps1 -Task R003 -Names routine_resolver_checks,routine_clock_checks
-ParseScripts features/routines/routine_resolution_context,features/routines/routine_assignment_plan,features/routines/routine_resolver,features/routines/routine_assignment_director
-TimeoutSeconds150
PASS4 cases at docs/evidence/R003/20261009-091213986-0fcf01c2/results.json.
13310 resolver /301 clock assertions, zero failures; all exits0/diagnostics empty.
source.changed=false/source.error=null; fingerprint
60653ad0b08587974c6c55069251d2e1762c4c72d927244d8a5d62519074b323 (1194 files).
Two independent check-000/001 save groups with distinct named slots and task-local
APPDATA/LOCALAPPDATA under builds/testing/R003/<run>/; checks never access primary
or backup saves. No ordinary save/profile access.

Earlier stable run20261009-091034886-f9e57a6c passed engine/import/parse and actual
routine_content_checks848/228 rejections, environment_rule_checks12792 and
environment_session_checks (active/pause/resume/modal/focus/travel/shared clock).
Its two new checks failed because initial clear day0 cannot produce desired rain/
storm at18:00, and some times cannot be sunny. Fixture now selects real seeded
later-day rain/storm and any nonstorm baseline. All affected checks rerun above;
unaffected prerequisite scripts/bytes unchanged. First091011 import run correctly
failed source guard because six owned UID files were generated. All failures and
logs retained; no failed overall report relabeled as passing.

Viewed structured results/source manifests/logs and detailed two rule reports:
18 pinned selection vectors select all25 IDs;1440-minute full roster/group sweep;
all start/end/overnight boundaries; priority/ties/rejection order; facts/flags/AND/
count/recency/exact-null keys; max clock/elapsed vectors; window/recency reevaluation;
120 unchanged updates; midnight versus10AM suppression; actual seeded rain/storm
and authored union. Synthetic branches clearly labeled, no ordinary gameplay,
saved-state, rendered, movement, reconstruction or native claims. Full criterion
mapping in [R003 acceptance](R003_ACCEPTANCE.md).

No current blocker. Default exec helper setup fails; reviewed execution works.
Final readback/diff audit passed16 statuses/64 relative links/dependencies and15
allowlisted changed files; R004/R005 ready, ordered next R004. Source remains clean.
One unmatched final documentation patch refused atomically; corrected, no partial
write or runtime-source change.
No automatic approval rejection. Per-command Git safe.directory only; no global
configuration changes. All owned Godot checks exited; no editor/game/input/held
controls or cleanup owed. Ignored task evidence/staging retained; Blender untouched.

Remaining unfinished IDs: R004,R005,R006,R007,R008,R009,R010,R011,R012,R013,R014,R015,R016.
Every item through R016 complete: no. Next eligible R004 (R005 independently ready;
ordered selection chooses R004). Exact next action: recheck current architecture/
SaveCodec/fixtures; implement only minimal session-owned authored active events/
current-day suppression, strict current-format commands/persistence/detached restore,
then required isolated save/restart/rollback checks. Stop before R004 here.

## R003 authorized successful-task commit follow-up

After successful acceptance, user authorized committing exactly delivered R003
components/checks/UIDs, durable acceptance, checklist and handoff. Baseline index
empty; all15 changed paths belong to R003, no unrelated changes. Raw evidence/logs
and staging stay ignored under existing policy. Current game/tools fingerprint
matches accepted60653ad0b08587974c6c55069251d2e1762c4c72d927244d8a5d62519074b323;
no runtime source changed after acceptance. Stage explicit allowlist, verify staged
tree/whitespace and unchanged accepted fingerprint, commit, then verify committed
paths and clean working tree. R004 remains Pending; no push or successor work.

## Historical R002 selection (superseded, evidence preserved)

Baseline target HEAD fc049516ae90deffac78bd2f7bb6ded804fbe28c, worktree clean;
source clean and R001 live-source audit passes 1624 assertions. No nested target
AGENTS.md or target/workspace .agents found. Source .agents/skills/test-gameplay
read: Flutter/Linux workflow does not apply to target Godot checks. Current versioned
and installed target testing skill/runner/save isolation guidance read.
Unrelated Blender PID2664 preserved; owned Godot checks exited.
Bounded allowlist: game/features/routines/**, game/content/routines/**,
game/tests/routine_content_checks.gd*, tools/routine_migration/convert_content.py,
this folder's CHECKLIST.md/CURRENT_STATE.md/R002_ACCEPTANCE.md and ignored R002 evidence.
Delivered detached typed content/reference validation and invalid fixtures; no root
wiring, save/graph/rig/geometry change. Required checks all pass; full details in
[R002 acceptance](R002_ACCEPTANCE.md). Default exec helper fails setup; reviewed
commands work. No automatic approval rejection. No commit/push performed.

## R002 completion and next action

25 definitions/eight people/104 steps load through RoutineContentCatalog without
production activation. RoutineDefinition typed window/step/condition/directive views
own recursively read-only copies; public snapshots detach. Strict bounded JSON
rejects duplicate raw keys before Godot can collapse them. Complete catalog candidate
must pass exact schema/IDs/paths and current NPC fact/flag/action/node/outcome references
before publication; failed initial loads publish nothing and failed reloads retain
previous accepted catalog. Target-only references pin three maps/21 anchors/four
directed portals and declared arrivals; planned rooms remain declarations.

Converter verified R001 pins before writing, preserving source speech, IDs, windows,
conditions, policy and durations. Only move mapId gains prototype- prefix. Catalog
assets become res://content/routines paths. Existing NPC/social catalogs unchanged.
JSON -text attributes preserve byte pin across Windows checkout.
Save schema7/content1 unchanged. No new art, physics, room, clock/history/save owner.

Final runner from repository cwd:
./tools/run_checks.ps1 -Task R002 -Names routine_content_checks,npc_content_checks,content_catalog_checks,application_smoke
-ParseScripts features/routines/routine_content_catalog,features/routines/routine_definition,features/routines/routine_json
-TimeoutSeconds150
PASS6 cases in docs/evidence/R002/20261009-085202820-ad2f415e/results.json;
source.changed=false/source.error=null, all exits0/diagnostics empty.
Routine-content stdout reports848 assertions/228 rejection fixtures/zero failures
(structured report records847 before final evidence-write assertion).
Source digest6501daece5c783a731b969dbeaf320e715358740a6f1c09db3a5edd941349a87.
Separate check-000..003 groups use builds/testing/R002/<run>/{appdata,localappdata};
no normal save/primary/backup access. Stable import passed in084429 run, including
known runner-allowed optional Mono SDK editor message; no SDK installation needed.
Bundled Python3.12.14 converter --check passes28 documents and offline1535 R001
assertions. Live-source preflight passes1624; source remains clean at60c20eb2.

Retained failures: first import generated four owned UID files, so source guard
rightly invalidated run. Negative allowDialogue fixture revealed unsafe int/bool
comparison; repaired type gates. Huge raw exponent revealed Godot conversion warning;
bounded preflight now refuses before conversion. A repair used wrong regex capture
and test path int/string comparison; fixed. Final wrong-map fixture originally used
valid same-home Edric rest anchor; corrected to actual wrong-map anchor. Two patch
attempts rejected out-of-order contexts atomically; corrected ordered patch succeeded.
Failed reports/logs remain under R002, and affected checks rerun successfully.
Final coherent required-suite repeat adds explicit new-script parse coverage.

Inspected JSON/source/logs/manifests; no rendered captures requested/claimed for data
task. Future physical routes, actual dialogue directives/actions, selector, durable
facts and native delivery remain owning tasks. No held input/editor/game/owned process
or cleanup owed; isolated ignored evidence/staging retained. Blender2664 untouched.
No source writes, exports, agents/chats/messages/schedules/commit/push.

Remaining unfinished IDs: R003,R004,R005,R006,R007,R008,R009,R010,R011,R012,R013,R014,R015,R016.
Every item through R016 complete: no. Blockers: none. Next eligible R003 (R005
independently ready; ordered selection selects R003). Exact next action: read immutable
catalog/R001 vectors and current clock/weather/conversation/event snapshot APIs,
implement pure selector/transient assignment plan and routine_resolver_checks.gd/
routine_clock_checks.gd; no movement or new durable owner. This invocation stops here.

## R002 authorized successful-task commit follow-up

R002 successful-task commit follow-up authorized after the acceptance above.
Commit only delivered R002 code/content/fixtures/converter, durable acceptance,
checklist and this handoff. Raw logs/staging remain ignored under existing policy.
Baseline index empty; all current changes belong to R002. Verify staged reference
bytes and unchanged accepted game/tool fingerprint before commit, then committed
tree and clean working tree afterwards. R003 remains Pending; no push.

## Historical R001 handoff (superseded selection, preserved evidence)

Prior R001 continuation (historical): Final task ID: R016. Exactly R001
completed; stop before successor. Next eligible: R002 (R005 independently ready;
ordered selection chooses R002). Exact next action: read local manifest/coverage,
implement strict detached immutable routine content and routine_content_checks.gd,
then use current tools/run_checks.ps1 with its required tests and isolated groups.
No R001 blocker; whole checklist incomplete. [R001 acceptance](R001_ACCEPTANCE.md)
supplies criterion evidence.

Completed scope/allowlist: tools/routine_migration/**; this workflow's CHECKLIST.md,
CURRENT_STATE.md, CONTRACT.md and R001_ACCEPTANCE.md; ignored docs/evidence/R001/**.
No runtime activation/gameplay execution. AGENT_PROMPT.md/user workspace instructions
preserved. Implementation ended without commit/push. Separate successful-task follow-up
now authorizes an R001-only commit; no push or successor work.

Verified baseline: target e10d13edd6035aeb3bac4cbaded6f82b756f8e39, source 60c20eb2816e7271fb84afaba286af006ebe3ccf. Source clean; target only pre-existing untracked docs/day-clock-npc-routines/ (all four user-authored planning files preserved). No nested AGENTS.md found; workspace .agents absent. Versioned and installed gameplay-testing skill/current runner/save isolation/observation guidance read. Both installed Godot executables exist. Existing Blender process is unrelated and untouched. No owned editor/game/input process started.

Default sandbox process helper failed before execution twice; read-only commands work with reviewed require_escalated execution. Git reads use per-command safe.directory for both repositories, with no global configuration changes. Python alias is unavailable; verified bundled Python 3.12.14 at C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe. rg unavailable; bounded Python/PowerShell reads used. No automatic approval rejection.

CHECKLIST owns status; CONTRACT owns stable rules and identities. Older completed N/G/F/FS/W/M/P selectors do not select this workflow's work.

## Inspected baseline

Repository D:/development/game-dev-blender/returning-fair-prototype; application game/.
Read-only source D:/development/game-prototype-2.
Target HEAD e10d13edd6035aeb3bac4cbaded6f82b756f8e39; source HEAD 60c20eb2816e7271fb84afaba286af006ebe3ccf. Both worktrees clean before plan creation. No nested target AGENTS.md found; workspace instructions supply caveman mode and Godot paths. These revisions are observations, not reset targets.

Clock gap in the earlier investigation is stale: current target delivers ten-minute day/night, saved forecast/lights and heavy-rain service. Eight real NPCs/dialogue/portraits/rigs, foraging/backpack, gifts/friendship/People journal and fishing handoffs report delivery. Actual save codec is schema7/content1; architecture rejects other versions without migration/defaulting. Some handoffs retain older historical boundaries. This audit inspected current implementation/status references, not fresh gameplay/regression acceptance.

Missing routine integration: NpcRegistry fixed exterior feet; NpcWorldAdapter static contact bodies/service_outlines baked into navigation and zero locomotion; single-destination PrototypeLocation travel; absent routine director/executor and Mayor-home/inn rooms. Existing GameRoot clock advances through dialogue/journal/backpack/focus loss and freezes for pause/travel/load/retry. Motion holds are separate and must preserve this policy.

## Decisions and risks

- Requested 25 routines exactly match existing eight villagers. Current source 39 includes 14 routines/seven people outside scope. CONTRACT enumerates selected IDs and 21 qualified move targets.
- Add only required Mayor Vale home/Lantern Rest interiors and reciprocal doors, with real party/NPC clearance and visual review. No full-map/campaign/sleep/housing expansion.
- Reuse existing clock/weather/social event truth. R004 chooses the next current schema after rechecking then-current bytes; no invented legacy history or cursor serialization.
- Fixed NPC blockers must become dynamic without losing true counter/furniture collision. Loaded actors walk physically; no companion catch-up/teleport behavior.
- Source INT-064 remains Pending: Edric can fail offscreen overnight arrival under reconstruction. R010 owns diagnosis/regression and ordinary versus seek/load proof.
- Edric/Helena action GLBs are review variants. R012 explicitly validates/promotes production mappings.
- Portal/room branch is independent of selector/save branch. Exactly one task per invocation; no agents launched by planning.

## Planning files and investigation (historical)

Only new docs/day-clock-npc-routines/{CHECKLIST,CONTRACT,AGENT_PROMPT,CURRENT_STATE}.md. No runtime, source, art, saves, exports or older workflow files changed.

Read-only inspection used git status/rev-parse in both repositories; source JSON filtering; target clock/NPC/conversation/save/travel implementations; source resolver/director/executor, schema/tests and INT-064 status; relevant current handoffs. Verified installed Godot console/editor paths. Inventory returned 39 total/25 selected/21 unique qualified targets; target catalog/registry confirms eight people and codec confirms schema7. No runtime/test suite/build ran.

One oversized combined documentation write failed before process creation with Windows command-length error; no files were written by that attempt. Split bounded writes created the four requested documents. This was a tooling failure, not an approval rejection or implementation blocker.

## Remaining work and cleanup

R002-R016 criteria remain. No current task blocker: required source/target/tool access
exists. R001 supplies hashes/vectors and static anchor/portal/capsule audit; physical
path/support/LOS/room checks remain their owning tasks. Reconcile later source/schema/
world drift explicitly; never silently refresh pins or imply safe routes from static data.

No owned editor/game/input process started; no held input, test save, package promotion or cleanup owed. Future tests must isolate task saves/primary/backup/APPDATA/LOCALAPPDATA and confirm pause checkpoints. Old packages do not certify future routines.

## Planning verification - passed

Python documentation audit read all four files and passed: 23 relative links resolve; R001-R016 each have a matching task section; all 16 statuses Pending; dependency references valid/acyclic; only R001 initially ready; copyable invocation selects this workflow. All 40 referenced existing check stems and required runner/native/support/action-asset paths resolve. Proposed routine checks remain clearly future deliverables. Source JSON independently reconfirmed 39 total routines, 25 selected, 21 qualified move targets, with every selected ID in CONTRACT. Both installed Godot executable paths exist.

Readback of checklist/prompt/state and git diff --check passed. Git status shows only the four-file untracked docs/day-clock-npc-routines/ folder; source remains clean at the recorded revision. A sandbox read of source Git status initially rejected ownership; one-command safe.directory configuration repeated the read successfully, without changing global Git configuration or source files. No gameplay tests/builds ran. Planning checks verify workflow consistency, not migration acceptance.

## R001 completion and exact continuation

New [tools](../../tools/routine_migration/README.md) and
[manifest](../../tools/routine_migration/reference/manifest.json) pin88 source authority
inputs/85 selected public snapshots, exact25 IDs/eight people,14 routines/seven people
excluded,21 anchors(11/9/1),four doors/nine directed map-pair chains. Coverage maps
every routine/step/dialogue/outcome/condition/action/public dependency to its owner.
No private profiles or additional runtime cast imported. All1238 pre-existing tracked
files remain exact; source clean at60c20eb2, target HEAD e10d13ed unchanged.

Interior origins: home(256,384),inn(448,672),32 units/metre. All source-anchor deltas
zero. Proposed indoor arrivals remain unaccepted. Static audit measured seven fixed
contact destinations, home1.5m hall versus1.7m opposing-NPC width, rest bed-corner
center clearance0.450694m. Seven bounded repair records own R005/R007/R008/R009/R010
work, retaining geography/counter furniture.21 consecutive move legs identify
straight-line detours/qualified chains without certifying routes. Source INT-064
Pending/enum unknown; actual world caller origin/release/start/elapsed pinned,
not reproduced. Source tests read are not tests run.

Targets declared before implementation: eight-NPC scheduler p95<=2ms,path p95<=5ms,
no per-frame requests for unchanged legs,0.5s wait/two repaths; reconstruction50ms,
64 transitions/actor512 total; one room/region/wrapper; ten-cycle owned-object/
reservation/listener growth0 and working-set<=64MiB. Current machine/settings and
historical N017 fixed-actor ABBA/query baseline recorded; moving budgets unmeasured.
Existing GLBs expose action_river_fishing/action_archive_work; R012 owns promotion.
Save7/content1 unchanged; only authored events/day suppression identified for R004.

Commands used repository cwd and verified bundled Python3.12.14:
pin_reference.py --source D:/development/game-prototype-2; audit_geometry.py;
reference_checks.py --source D:/development/game-prototype-2 --self-test --report
docs/evidence/R001/20261009-reference-final/results.json; audit_geometry.py --check.
Final reference PASS1624 assertions/six drift refusals; geometry PASS2 rooms/4 doors/
21 legs/7 repairs. JSON/text/GLB metadata inspected; no PNG claimed. Actual console
--version confirms4.7.2.stable.mono.official.ed1daf0bf.

Failure history retained: sandbox helper setup before execution, Python Store alias,
collision.kind=none KeyError before writes, first check Windows charmap/cwd. Explicit
none/UTF-8/correct cwd repaired them. Failed report and stable1613-assertion pass
retained; final repeat justified by actual source world reconstruction caller/closed
snapshot additions. Initial coverage corrected to actual coverage.status/singular
outcomeTag before acceptance; source pins never refreshed. One final multi-file doc
patch rejected unmatched CONTRACT context atomically; readback confirmed no partial
status changes, then corrected patch succeeded.

Default helper unavailable; bounded reviewed elevated commands succeeded. No
auto-review rejection/extra user permission request. Per-command Git safe.directory
only. TEMP negative copies cleaned; no APPDATA/save/test-slot use. No owned editor/
game/native input/process or cleanup owed; unrelated Blender untouched. No source
edits/packages/export/agents/chats/commit/push.

All R001 criteria pass. Unrun gameplay/source Dart/room rendering/physical routes/
moving performance/INT-064 reproduction is downstream work, not waived. Remaining
unfinished IDs: R002,R003,R004,R005,R006,R007,R008,R009,R010,R011,R012,R013,R014,R015,R016.

Final readback: all16 task statuses/sections/dependencies and50 relative links pass;
nextR002/finalR016 correct. Git diff --check passes; new files only this workflow
and tools/routine_migration. Offline reference check without live --source passes.
No Godot process remains; unrelated Blender PID2664 untouched, no cleanup owed.

## Authorized successful-task commit follow-up

R001-only commit authorized after acceptance. Preflight found no unrelated staged,
tracked or untracked changes; all new paths belong to this workflow/reference tools.
Include unchanged pre-existing AGENT_PROMPT.md as required workflow dependency,
preserving its authored instructions. Add tools/routine_migration/.gitattributes:
core.autocrlf=true otherwise converts LF pins to CRLF on a fresh Windows checkout,
invalidating exact hashes. Scoped -text reference rule preserves original and derived
bytes; tools use LF. No root attributes, runtime, source pins or task statuses changed.
Durable acceptance/audits are versioned; raw docs/evidence logs remain ignored per
existing policy. Verify staged blobs against pin SHA256 before commit and commit
tree afterwards. R002 remains Pending; no push or successor.
Staged whitespace check found one generated INT-064 excerpt blank line at EOF.
Trimmed that derived excerpt and updated only its derived hash/capture-history hash;
all85 byte-exact source snapshots stayed unchanged. Rechecked reference acceptance
and staged whitespace/blob hashes before committing.
