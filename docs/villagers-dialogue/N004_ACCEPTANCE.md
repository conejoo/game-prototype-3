# N004 — Strict current-schema NPC and event persistence

Task scope: one additive save change, schema7/content1. N005 UI/ordinary contacts,
N006 real woods/gather adapters and N007 art remain separate tasks.

## Baseline and implemented boundary

Target began clean at e6e907922e46cf63c4adb2902afb7bc3a0da2030. Source began clean
at 60c20eb2816e7271fb84afaba286af006ebe3ccf. Both installed Godot paths exist;
console reports 4.7.2.stable.mono.official.ed1daf0bf. Compatibility renderer retained.
Read-only convert_content.py --check --source verifies all 132 authority hashes and
67 runtime outputs, including catalog SHA256
9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9.

SaveCodec now requires conversations alongside every prior durable field.
Only schema7/content1 is supported: schema6, all other old/new versions and content
versions reject before fallback/defaults/migration. SaveRepository's existing
staging, incompatible-file preservation and visible read-only backup recovery remain.

GameSession.initialize accepts optional validated npc_content after restored_environment;
otherwise it validates the bundled catalog for a fresh session. It initializes eight
independent memories before publishing readiness. Root injects its already validated
catalog. Decoding validates NPC state before constructing its detached GameSession;
successful physical restore rebinds NpcDialogueService to the restored state and a
fresh inactive cursor. Failed candidates or placement preserve live owners/facts.

NpcSaveData.restore(data, catalog, elapsed_seconds) returns Result.state/errors.
The complete conversations envelope has exactly people and events. people has exactly
the pinned eight IDs. Each person has exactly npc_id, affinity, level, flags,
learned_fact_ids, seen_node_ids and applied_choice_ids. All collections detach;
unknown fields, foreign/deferred IDs, duplicate strings and shared/cyclic mutable
containers reject. Memory sets canonicalize only in the detached candidate.

Learned facts equal authored disclosures from enabled seen nodes. Accepted choice
events require the authored owner/target nodes, exact once-only receipts, flags and
clamped affinity derivation. Opposite introduction receipts reject. Derived level
must match the source threshold. Current pinned enabled choices have nonnegative
affinity deltas and one mutually exclusive one-time introduction per person;
unsupported future negative deltas require a deliberate ordered-history policy and
are rejected instead of reconstructed from lossy aggregates. General rule-service
signed clamping remains intact; no gift/routine/milestone rewards are fabricated.

events has exactly last_sequence and facts; <=40 exact allowlisted records.
Each record has kind, subject_id, target_id, count, first_sequence, last_sequence,
first_active_seconds and last_active_seconds. Null target is exact, never wildcard.
Counts/sequences are whole numbers within 1..2147483647; empty global sequence is 0.
Totals, unique endpoint sequences, first/latest boundaries, count/span feasibility
and globally nondecreasing endpoint times validate. Interval allocation is bounded
by records, not the potentially huge sequence count. Finite timestamps are within
0..2190600 and <=saved elapsed active time. Allowlist/latest active time reconstruct
from the validated catalog/latest sequence; no past event is inferred from inventory.

SaveJsonFields also rejects fractional NPC integer lexemes even when Godot's JSON
parser rounds them to whole values. SaveNumber restores every event timestamp from
its decimal lexeme for exact binary64 round trips, including the double below 1.
Dialogue cursor, generation tokens, scenes, NodePaths and animation/placement caches
are absent. Root Save/Load rejects either active dialogue owner until closed and
retains manual pause/arrival boundaries. Normal user save slots were never accessed.

## Acceptance evidence

New npc_save_checks exercises all eight real-service introduction/revisit memories
layered over the complete prior quest/party/trust/upgrade/environment/light/item/rod
fixture. Inner malformed assertions call the production NpcSaveData boundary with
prevalidated immutable content; outer codec, lexemes, disk, root, physical rollback
and independent processes have separate assertions.

| Criterion | Evidence |
| --- | --- |
| Exact current-format round trip | Full SaveCodec.snapshot equality for old/new state, binary64 timestamp edge, independent per-person branches and detached source/candidate/query collections. |
| Exact separate-process restart | npc_process_checks writer/reader use real root manual Save/Load; full durable oracle equality, party/wrapper bindings, arrival anchor, inactive fresh cursor, reconstructed allowlist/latest time and old-session detachment. |
| Reject other formats | Explicit schema1..6/8/99/max-version tests; inherited save_checks covers primary/backup preservation and no fallback for incompatible formats. |
| Strict IDs/structure/numeric/derivation | Missing/extra/foreign/deferred IDs/fields; duplicate sets/JSON fields, escaped duplicates, fractional lexemes, malformed types, bounds, counts/spans/order, disclosure/reward/level mismatches and shared containers. |
| Backup/staging/failure/placement | Nonempty NPC root fixture fails staging without file loss; malformed state cannot swap owners; both unsafe spawn variants retain every live fact/foot; corrupt primary restores exact validated NPC backup visibly without rewriting files. Required baseline suites retain other failure paths. |
| No inferred history/cursor save | Fresh schema7 fixtures explicitly have empty conversation/event state regardless of item/quest history; process reader starts empty without autoload. Active NPC dialogue blocks manual Save/Load; exact envelope has no cursor fields. |

Initial focused passing run:
docs/evidence/N004/20261008-083240856-c30233e7/ — all five cases PASS/exit0,
560 assertions before final lexeme/interval expansion, writer PID72508 and reader
PID12528 distinct. Full acceptance command/results and final audit follow below.

## Commands and isolation

Cwd: D:/development/game-dev-blender/returning-fair-prototype, PowerShell7.
Python: C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe.

```powershell
& $python tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
./tools/run_checks.ps1 -Task N004 -Import -Names npc_save_checks,save_checks,foraging_save_checks,environment_save_checks,map_save_checks,consequence_checks,npc_dialogue_rule_checks,application_smoke,inventory_checks,foraging_transaction_checks,reference_mapping_checks,testing_support_checks -ProcessScripts npc_process_checks,save_process_checks -TimeoutSeconds 150
```

Runner creates fresh docs/evidence/N004/<run>/, matching builds/testing/N004/<run>/
appdata/localappdata and separate named check groups; only each process suite shares
its own writer/reader group. This is synthetic rule/root/process evidence, not
ordinary input, portrait/route/art or standalone native package acceptance.

## Retained failed attempts

- 082324156-5b942717: sandbox engine preflight access denied. Automatic review
  approved running the existing isolated headless runner outside the sandbox;
  no security setting changed, no approval question or bypass.
- 082353439-dd9c66cd and 082646350-9caad49f: first imports generated the four
  owned script UIDs; strict source guard retained these as failed evidence.
- 082451515-c71915f6: adding a fixture while the runner was starting invalidated
  source stability; no acceptance attributed to that run.
- 082711322-e82d734d: runtime rejected an incorrect packed-to-typed Array
  constructor. Corrected to typed assign; no validation weakened.
- 082813102-fe921d48: malformed boolean NPC identity exposed an unsafe comparison.
  Added explicit String guard; inherited save_checks independently passed here.
- 082915081-f4c9eed0: 150s timeout from repeated catalog/image validation for every
  inner malformed fixture. Pure boundary checks now reuse validated content;
  full codec/root/disk/restart checks remain separate and pass.

One-time fixture preparation initially stopped on a non-envelope JSON list; resumed
only unfinished edits, then removed the helper. A shell quoting attempt failed before
any work. A supplemental byte-preservation script initially could not resolve Git
in the elevated environment; no bytes changed on that attempt. These are preparation
failures, not passing runtime evidence.

## Final result

Final run docs/evidence/N004/20261008-083758961-2874c9d4/results.json: all19 cases
PASS/exit0, no timeout, forbidden runtime/parse diagnostic or source change.
567 NPC-save assertions including evidence write (566 in JSON), 509 malformed inputs;
N003 rule regression retains 977 assertions, 58 enabled nodes/38 choices. Required
save_checks, save_process_checks, foraging_save_checks, environment_save_checks,
map_save_checks, consequence_checks plus affected startup/inventory/transaction/
reference/testing-support checks all pass. Existing import-only missing .NET SDK
10.0.9 diagnostic remains allowed by the unchanged runner; no installation needed.

Fingerprint 2a200140321af5a13056d70f92956a01c4bdd0f68bbc9fe792061c3ca64c2404,
770 game/tools files stable. Final exact-byte/fixture-prior-fact/local-link/Git diff/
dependency/status audit is final-audit.json in that run. Independent phase captures
are process/npc_process_checks/npc-process-write.json and npc-process-read.json;
logs are the run's numbered stdout/stderr files. Commands/appdata/slots/PIDs/exits
are in results.json. All owned processes exited; no editor or cleanup owed.

Prior full run 083413707-67472aad also passed all19 cases. Final rerun certifies
the reduced diff after preserving original unchanged GDScript line endings and
fixture formatting; all six prior fixture facts remain exact. Supplemental formatting
preparation caught a CRLF injection omission before execution; it was repaired and
the final authored fixtures were independently parsed/compared. Supplemental handoff/
audit scripts required Python -X utf8 on Windows; default cp1252 stopped before
writing, then explicit UTF-8 passed. No production validation was relaxed.

Final audit verifies all770 tested game/tools files byte-exact; 102 local links,
18 checklist rows and eligible IDs N005/N007. Baseline game/art comparison has595
byte-exact files, four preexisting Git-blob/checkout LF/CRLF-only differences and19
owned changed records (including the renamed fixture). No unrelated logical change.
Source remains clean and all pinned source/runtime hashes match. This implementation
audit ran before the user-authorized commit follow-up.

N004 Done; every selected acceptance criterion has evidence. Remaining N005-N018;
N005 next eligible, N007 independently eligible. All through N018 not complete.
No successor, agent, schedule, external message, commit or publication started.

## Commit follow-up

User authorized committing the successfully verified N004 work. Commit scope is the
five changed production scripts, the NPC persistence module/checks/fixtures and UIDs,
affected schema/path regression assertions, acceptance/checklist/contract/handoff and
README/architecture discovery. Generated docs/evidence and builds remain local under
repository policy; this acceptance summary is the committed evidence. No push or
successor task is authorized by this follow-up. Runtime bytes remain those verified
by the final 19-case run; no extra runtime change or test run is needed.
