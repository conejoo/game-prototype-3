# R004 durable routine facts acceptance

Done 2026-10-09 UTC / America/Vancouver. Exactly R004 delivered; stop before R005.
Baseline target HEAD `6c8b09d585b83a5cb90cd82bd9c9680a8475205b`, source
`60c20eb2816e7271fb84afaba286af006ebe3ccf`; both clean before work. No baseline
user changes, nested target instructions or workspace/target .agents. Workspace
AGENTS, current testing skill/runner/isolation guidance and source test-gameplay
skill read; the source Flutter/Linux runtime does not apply here. Supplied console
engine exists and reports4.7.2.stable.mono.official.ed1daf0bf.

## Delivered ownership and format

`RoutineFacts` owns detached authored active-event IDs (harbor-festival/heavy-rain)
and the exact25 allowed suppressed routine IDs. Sorted plain sets are the only new
`routine_facts` fields. The existing saved environment day supplies their lifetime:
suppression survives midnight and expires only when GameSession.advance commits
a new day index at10AM. No extra day/clock/history, positions, paths, step/timers,
leases, speech, animation, saved revision or cursor. Large deltas expire once;
failed clock advancement changes no facts. Commands/advancement never autosave.

`RoutineFactCommand` captures weak live-session identity, authoritative day,
transient revision and expected prior fact. Typed event/suppression commands reject
null/uninitialized/foreign/unknown/stale/replayed/unchanged requests. GameSession
validates current and detached candidate facts before one publication/revision;
observers see complete state and nested commands/advance reject. Authored event
removal changes no forecast and cannot remove concurrent weather-derived heavy-rain.
`RoutineResolutionContext.from_session` validates and samples these actual owners.
R011 must separately authorize the dialogue speaker/instance/routine/step before
constructing a command; no UI/debug exposure or schedule execution added here.

SaveCodec now supports only schema8/content1. Missing/extra/foreign/duplicate/malformed
routine facts reject before detached candidate adoption. All prior facts retain
their existing strict validation. Old/newer versions reject without migration,
defaults or backup fallback, preserving disk/live state. Existing root adoption
rebinds session, WorldHost, dialogue, party and weather through unchanged owners.

Six complete current save fixtures replace schema7, with explicit empty routine
sets; every other parsed value equals its HEAD fixture. The weather fixture becomes
environment_save_v8.json; its three path consumers update. Five map fixture hashes
and provenance retain original source/previous recorded hashes. Explicit current
version assertions and package/native audit constants update together; historical
reference/evidence bytes and packages stay unchanged. README/current architecture
state the new supported policy; historical delivery paragraphs remain historical.

## Acceptance mapping

| Criterion | Actual evidence |
| --- | --- |
| Writer/reader retains new and all prior facts | Complete social/foraging/quest/party/environment fixture, manual production root Load/Save, independent processes, exact TestRunSnapshot full typed snapshot/forecast; primary and backup both exact after reader re-save |
| Suppression expires only at day rollover | Real sole-clock advances across midnight,10AM,multiple days,failed max-clock deltas; restored reader retains same-day facts then expires at next actual day index |
| Wrong/stale commands and bad saves inert | Session/day/revision/expected-value, foreign/replay/unknown/duplicate/reentry probes;213 routine-save assertions,44 bad-save cases; strict all6 current fixtures |
| Old/newer/malformed envelopes reject before live swap | Versions1..7,9,99; malformed/missing/extra/unknown/shared/cyclic sets and duplicate raw keys; repository incompatible-primary/backup refusal and complete live-owner checks |
| Authored removal cannot clear derived storm or forecast | Explicit seeded thunderstorm/rainy fixtures; add/remove authored heavy-rain, effective union and exact forecast unchanged |
| Failed save/restore cannot half-publish | Real .tmp/.bak.tmp IO obstruction, exact primary/backup bytes, corrupt backup recovery/read-only reads; actual no-floor/blocked-spawn root rejection preserves full session/room/dialogue/party/feet |

No R004 criterion unrun or waived. All weather/state/speaker fixtures are synthetic;
the production Save/Load APIs, filesystem, detached rebinding and physical arrival
rejection are exercised headlessly. No ordinary input, GUI capture, room/routine
movement, rendered action, natural storm or native package claim.

## Commands and inspected evidence

All commands use repository cwd, PowerShell7 and supplied explicit console engine.
Run reports are schema2; every independent check uses a distinct R004 named save
slot and APPDATA/LOCALAPPDATA under builds/testing/R004. Each process pair shares
only its own group; routine and existing save restart groups are separate. Both
primary/backup fixture slots are isolated. Normal saves are never read or written.

1. Initial import generated four owned UIDs. `093127675-5ace207c` correctly FAILED
   source guard; subsequent stable import passed in `093227973-0795cb89`.
2. `./tools/run_checks.ps1 -Task R004 -Names routine_save_checks,routine_content_checks,routine_clock_checks,save_checks,environment_save_checks,npc_save_checks,social_save_checks,foraging_save_checks -ProcessScripts routine_process_checks -ParseScripts features/routines/routine_facts,features/routines/routine_fact_command,features/routines/routine_resolution_context -TimeoutSeconds 150`
   Stable `20261009-093524352-fcec8465` has passing routine save201/content848/clock301,
   save transactions, environment441, NPC569/510 refusals, foraging111. Its social
   case FAILED because hardcoded future8 became current. Source unchanged; the
   whole report remains failed. That exact case was repaired and rerun below.
3. `./tools/run_checks.ps1 -Task R004 -Names routine_save_checks,social_save_checks,fishing_content_checks,fishing_reference_checks,foraging_transaction_checks,inventory_checks,npc_dialogue_rule_checks,reference_mapping_checks,testing_support_checks -ProcessScripts routine_process_checks,save_process_checks -ParseScripts features/routines/routine_facts,features/routines/routine_fact_command,features/routines/routine_resolution_context -TimeoutSeconds 150`
   Stable `20261009-093842444-84a9b488` passes routine save213/44 refusals (structured
   report212 before its final write assertion), social844/560 refusals, fishing
   content255, foraging transactions587, inventory199, NPC dialogue929, reference
   mapping1657 route samples, testing support64. The old FS001 fish-absence assertion
   FAILED; all3 species are already shipped and valid. No production fish changed.
   The whole report remains failed; repaired affected case repeated below.
4. `./tools/run_checks.ps1 -Task R004 -Names fishing_reference_checks -ProcessScripts routine_process_checks,save_process_checks -ParseScripts features/routines/routine_facts,features/routines/routine_fact_command,features/routines/routine_resolution_context -TimeoutSeconds 150`
   Final `20261009-094110226-c4b0055b/results.json` PASS7 cases, every exit0,
   diagnostics empty, source.changed=false/error=null. Fishing reference134 now
   verifies actual species ID/cap/category/challenge/nonpickup, preserving geometry
   assertions. Routine writer12/reader18 (reports11/17 before evidence-write assert).
   Writer PID69272, reader25584; exact oracle comparison before subsequent reader
   rollover. Writer day146/progress0.6180339887498948/seed4294967295 and three
   suppressions; reader rolls to147/0 and clears only suppression, then accepts
   vale-breakfast on its fresh binding. Existing save restart write/read also pass.

Final game/tools fingerprint:
`637278940925301b2936119dbf634b7d02e6b30ca9282f172ce63531107bdebb` (1203 files).
Earlier passing save/content/clock cases are individually accepted at their stable
hashes; subsequent edits only affect their documented test consumers/adaptation
ledger or add validated session sampling. Failed cases are not counted as passes.

`python tools/routine_migration/reference_checks.py --source D:/development/game-prototype-2 --self-test --report docs/evidence/R004/reference-final/results.json`
PASS1624 assertions/ten negative refusals.30 exact target changes recorded in
tools/routine_migration/adaptations.json; original source/derived/preservation pins
are unchanged. Gate validates each original before-hash/current after-hash,
known unique path, R004 owner/reason and the one explicit fixture relocation;
unexplained drift still refuses. Source revision and all88 live inputs exact.
All4 changed Python consumers parse. Independent6-fixture comparison confirms
all pre-existing JSON values unchanged after removing version/new facts.

Inspected structured results, all listed stdout/stderr/reports, source manifests,
routine oracle/save bytes, both restart groups, reference refusals and intended
diff. No PNG generated or claimed. Final whitespace audit uses existing CRLF
tolerance; current source/process/preservation audit recorded in CURRENT_STATE.

## Retained failures, boundaries and cleanup

Default sandbox exec helper failed before launch; explicit reviewed execution works.
No approval rejection or extra permission question. Git uses command-local
safe.directory only; no global config change. Initial fixture script encountered
non-save PROVENANCE list; next script's optional missing text assertion interrupted
consumer edits. Both repaired before testing; six fixture values independently
verified. One output-inspection Python command hit Windows cp1252; rerun with
explicit UTF-8 stdout, no game/evidence mutation.

`093227973-0795cb89` had one new backup-loop setup failure. The loop now resets its
own known-good backup each version case. Its unsafe fixture ID also corrected to
match the actual fixture scene, so final proof reaches floor/body rejection.
A source edit began before that runner's later save case ended; source guard
correctly invalidated/stopped the run. Those cases were rerun at stable bytes.
All failed reports/logs remain; no overwritten passing evidence. Initial reference
gate refused intentional SaveCodec drift before the exact adaptation ledger existed;
final strict audit above passes without refreshing pins.

Only schema8/content1 accepted; previous native packages remain schema7 historical
delivery. R005 owns routing; R010 owns reconstruction; R011 dialogue authority;
R013 production schedules; R016 fresh native packages. No cast/scene/clock/history,
geography/art/content/social supply/quest behavior changed. AGENT_PROMPT and user
workspace instructions preserved. All owned Godot processes exited; no editor,
held input or cleanup owed. Unrelated Blender PID2664 preserved. Task evidence/
isolated staging retained and ignored. No commit, push, source writes or messages.

Remaining R005-R016; every item through R016 complete: no. Blockers: none.
Next eligible R005: inspect actual portal/travel/arrival contracts and implement
only directed qualified routing with multi-exit, NPC-isolation and current travel
rollback checks. This invocation stops here.

## Authorized successful-task commit portability follow-up

User subsequently authorized R004-only local commit. Exact preflight found all
46 accepted changes and empty index, no unrelated work. Git newline filters would
alter21 adapted files; narrow root -text rules and one nested social audit override
preserve exact committed/fresh-checkout pin bytes and all prior attribute rules.
Those two bounded attribute changes are recorded alongside existing adaptations,
now32 records. No runtime/test/fixture byte changed; historical source pins remain
exact. Only tools' ledger/nested attributes differ from the accepted source manifest;
current game/tool digest is d08a05d6d48949be89b1464a826dc9778d20d7fd8d3eaa01c6db4f24d47bfcaf.
Commit verification checks staged/committed exact blobs and ledger hashes; raw
evidence/staging remain ignored. No push or R005 execution authorized.
