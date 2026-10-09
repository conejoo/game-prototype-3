# R005 acceptance: qualified directed portals

Completed 2026-10-09 UTC. R005 alone is Done; R006-R016 remain Pending.
Baseline target HEAD `cb3244275db2a91286d4b8c9f92ab6a61657fbf9`, source
`60c20eb2816e7271fb84afaba286af006ebe3ccf`; both initially clean. No user changes
were present. Workspace instructions, current architecture, workflow contract,
R001 pins, installed/versioned testing skill and current shared runner/save/input
guidance were read. The source test-gameplay skill is for Linux Flutter and does
not apply to this Godot target. Both supplied engine paths exist. No source writes,
normal saves, editor changes, agents, messages, commits, pushes or publication.

## Delivered behavior and scope

PortalBinding carries source-qualified portal ID, destination and arrival.
LocationDefinition declares each exit; ContentCatalog validates all directed
references atomically. PortalRoutes snapshots authored metadata and returns
detached deterministic shortest directed chains. Visited locations bound searches;
no reverse exit is inferred. Same-map queries return no legs. Invalid reloads keep
the previous graph/catalog. Current-only locations are eligible; planned rooms
cannot be reached until their owning tasks provide valid definitions and scenes.

PrototypeLocation matches declared edges to exactly one physical interaction.
PrototypeInteractable validates explicit travel bindings and rejects mixed actions.
GameRoot reselects the live target and submits its WeakRef to WorldHost, which
rejects freed, foreign, wrong-source and altered bindings before invoking the
existing placement transaction. WeakRef avoids Godot rejecting a freed typed node
before the stale guard can execute. NPC route queries have no scene/player travel
authority. Legacy single-gate destination fields are diagnostic mirrors, never
dispatch inputs; the two-exit fixture deliberately gives them an unrelated value.

Only the existing Alderwake/Tollworks pair is enabled. Existing gate instance IDs,
feet, source Tollworks entrance ID and both arrival IDs remain unchanged. The
existing return gate now has the explicit target-local portal ID
`tollworks-exit-to-alderwake`. The four R001 home/inn portal pins and their qualified
arrival IDs remain unchanged and inactive; R006-R008 own physical delivery.
No new room, door, anchor, schedule, actor movement or save field is activated.

Changes are limited to the two new world scripts/UIDs, two portal resources,
location definitions, catalog, interactable, current location/gate wrappers,
WorldHost and narrow root dispatch; R005 checks/UID and three synthetic scenes;
affected compact/unsafe fixtures and bounded travel-test error reporting; exact
adaptation ledger/gate, narrow appended byte-preservation attributes, current
architecture, checklist, handoff and this acceptance. Historical source/reference
pins, geometry/content/art and schema8/content1 remain intact.

## Criterion evidence

| Criterion | Verified result |
| --- | --- |
| Two synthetic exits reach distinct destinations | Actual root selector and WorldHost transactions reach `r005-west` and `r005-east` from one hub, with correct `start` arrivals and reciprocal returns. Synthetic direct actor placement is explicitly labeled; this is not an ordinary walk or delivered production interior. |
| Stale/wrong source/arrival rejects | Freed/null/foreign WeakRefs, wrong active source, absent or different valid arrival, altered destination/portal ID are inert. Detached graph/catalog reloads reject wrong source, missing arrival/destination, empty/padded IDs, null/duplicate edges and self-links. Physical scene checks reject wrong source/arrival, duplicate/missing and unbound exits. |
| NPC queries preserve player location/camera/party | 100 repetitions query current routes, a two-hop chain and absent planned rooms. Exact complete SaveCodec snapshot, scene/count, party identities/feet and camera transform remain unchanged, with no transition. Detached returned edges cannot mutate later queries. |
| Existing arrivals/Tollworks round trips/rollback | Production selector dispatch reaches exact existing Tollworks and Alderwake arrival IDs. `location_travel_checks` passes ten full round trips, original actor/state/health/time ownership, synchronous input locks and pause/focus behavior. Real floor/obstruction probes reject both unsafe spawns and restore the exact prior scene/session/grounded feet/party. |
| No duplicate navigation region | Multi-exit fixture replacements have exactly one host child and one server navigation region. Existing map activation/travel checks verify unloaded scenes disappear and production routes retain physical capsule support. |
| Existing saves and integrations preserved | `save_checks`, `routine_save_checks`, `companion_checks`, `content_catalog_checks` and `interaction_dialogue_checks` pass; current primary/backup/restore behavior is retained, including 213 routine-save assertions and 44 malformed-save cases. |

The unsafe fixture formerly inherited an unbound single-destination gate. Its
standalone replacement retains exact floor/blocker shapes, body transforms,
collision nodes and the two original spawn probes, with no outgoing travel action.
`docs/evidence/R005/fixture-geometry-audit.json` independently compares all 6
colliders to the original compact fixture. The compact fixture receives its real
explicit binding. Travel checks now report synchronous fixture rejection and exit
before awaiting a signal that cannot occur; no acceptance assertion was removed.

## Actual commands and results

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell 7,
Godot console `4.7.2.stable.mono.official.ed1daf0bf`. Runner isolation is exclusively
under `builds/testing/R005/<run>/{appdata,localappdata}` with a distinct named
primary/backup slot for every independent check. No ordinary save directory was read.

```powershell
./tools/run_checks.ps1 -Task R005 -Names location_travel_checks,map_activation_checks,save_checks,companion_checks,routine_save_checks,content_catalog_checks,interaction_dialogue_checks -ParseScripts world/portal_binding,world/portal_routes -TimeoutSeconds 150
./tools/run_checks.ps1 -Task R005 -Names routine_portal_checks -ParseScripts world/portal_binding,world/portal_routes -TimeoutSeconds 150
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/routine_migration/reference_checks.py --source D:/development/game-prototype-2 --self-test --report docs/evidence/R005/reference-final/results.json
```

- Required/affected regressions: `20261009-101306934-3d036361/results.json`, PASS
  nine cases (engine/parse plus seven checks), all exits0/diagnostics empty,
  source.changed=false/error=null. Seven distinct `check-000` through `check-006`
  save groups. Source fingerprint `0303c19b4623ba8caf3c7c2c735dccafbad3cf4788a7b2715cda475cd0845932`.
- Final focused portal/physical-refusal check: `20261009-101719323-6ff3196c/results.json`,
  PASS three cases, one independent slot, all exits0/diagnostics empty,
  source.changed=false/error=null. Detailed report records 363 assertions before
  its final evidence-write assertion; stdout records 364, zero failures.
  Final 1214-file game/tools fingerprint
  `c2d19d0d270bb1fb778dd01c391d623cff8e043568f12f7a5a074caa636b7e14`.
- Stable import/parse passed in `20261009-100545796-6a89c465`; its subsequent stale
  fixture failed and was repaired. Later parse/runtime gates pass at final bytes.
- R001 live-source reference audit: PASS1624 and ten correctly refused negative
  fixtures, 88 original source inputs, 45 exact target adaptations. All original
  source/derived/preservation pin files remain unchanged. Only R004/R005 owners
  are accepted; exact before/after hashes remain mandatory. Appended 13 explicit
  `-text` rules preserve accepted changed game/fixture bytes through checkout.

Structured reports, detailed portal evidence, physical failure/round-trip logs,
save logs, source manifests, isolation metadata, fixture geometry audit and intended
diff were inspected. No PNG/rendered/native claim is made by R005. Runtime game
bytes and all seven accepted regression scripts/fixtures did not change after the
regression pass; later source changes were only the focused portal coverage and
reference gate/ledger, verified separately. Final audit records that comparison.

## Retained failures and cleanup

`100517581-7ea7a450` import generated three owned UIDs and correctly invalidated its
source identity. `100545796-6a89c465` exposed a freed typed-argument diagnostic;
WeakRef repair passed later. `100639820-fe4f5fd3` exposed premature synthetic floor
observation; four actual settled physics frames repair it. Its travel fixture
stalled on synchronous validation; the run was interrupted before source edits.
`100958986-ffbffe3b` and `101156996-ef6a325c` also had interrupted fixture continuations;
their unfinished runner reports are retained as running, never relabeled as passing.
`101129248-8f9bcc5a` precisely reports the wrong-source inherited gate rejection.
An attempted inherited override did not resolve it; standalone geometry-preserving
fixture and all affected checks now pass. `101609142-c685a142` was already passing;
final physical-refusal additions are covered by the later final focused run.

Default sandbox shell startup failed before execution; reviewed bounded shell
commands succeeded. No automatic approval rejection or redundant user question.
Git safe.directory was command-local. All owned engines exited after checks and
interruptions; no editor, held input or cleanup is owed. Failed evidence and isolated
staging remain ignored. Source clean, index empty, HEAD unchanged. No commit/push.

Blockers/unrun R005 criteria: none. Every task through R016 complete: no.
Remaining IDs: R006,R007,R008,R009,R010,R011,R012,R013,R014,R015,R016.
Next eligible R006: inspect qualified exterior declarations/door approaches and
current capsules/navigation against pinned geography; implement only its measured
anchor/entrance registry and required physical checks. Stop before that work.
