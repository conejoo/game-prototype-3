# R015 ordinary full-day and recovery acceptance

Status: Done (2026-10-10 UTC). Exactly R015 completed; R016 remains Pending.
No successful-task commit or push this turn; user will separately request the commit
after review. All R015 criteria pass under the approved correction. Historical
unfinished/failure records below retain their original meaning; final evidence is authoritative.

## Approved validation correction

The original requirement for Ivo routine actions/speech conflicted with immutable
source content. Both Ivo routines contain three move and three wait steps, no
action or speech. Source/target hashes and the original blocker remain in
CURRENT_STATE. The user approved the proposed correction with "yes, validate that":
validate Ivo movement, waits and conversation, and observe authored routine
actions/speech on Edric and Helena. No authored routine content is changed.

Every other R015 criterion remains required: at least600 active seconds with no
acceleration, night/rest/morning and solo/group transitions; actual town/home/inn
walking/returns and Della/Vale contacts; earned facts/gather/gift and Helena choices;
Maris lead/preparation/Tollworks combat/vessel/fitting with ally and both crossings;
inspected rendering, GUI Save/new-process GUI Load/physical revisits and cleanup.
Deterministic matrices complement the natural day and cover every routine/directive
and rain/thunderstorm. Random thunderstorm is not a completion gate.

## Scope and preservation

Baseline target HEADf2c601ed1f0a20570995c29174aa2cf5c7ca8354. The only pre-existing
changes were the two R015 blocker documentation edits; those records are retained.
Read-only source HEAD60c20eb2816e7271fb84afaba286af006ebe3ccf is clean.
Intended allowlist expanded to ten paths for a real ordinary Save failure:
this document, CHECKLIST.md, CURRENT_STATE.md, game/tests/routine_full_day_render.gd
and its UID, game/features/npcs/npc_save_data.gd, game/tests/npc_save_checks.gd,
game/tests/routine_directive_checks.gd, tools/routine_migration/adaptations.json
and reference_checks.py. New driver reuses current public input/GUI/capture/oracle
helpers and actual scheduled contacts. Runtime repair is restricted to counting
pinned introduction reward flags separately from independent oneTime receipts.
All receipt/event/flag/affinity, gift chronology and schema8/content1 rules remain.
Regression uses real social and bound routine transactions with explicitly
synthetic placement/items; fully derived opposite introductions still reject.
The historical standalone manual-save modal fixture temporarily detaches/restores
its routine owner instead of inventing a world contact. Offline ownership gate
now permits R015 and exact ledger entries preserve original before-hashes/reasons.
No authored content/geography/assets, scheduler, item/quest/party owners or source
pins changed. Manual-save API and historical evidence/packages remain preserved.
R014 user-approved4ms scheduler ceiling, original2ms failures and combined-slice/
synthetic measurement limits remain; threading investigations stay deferred.
Unrelated unsaved BlenderPID2664 is preserved.

## Method and isolation

Repository cwd:D:/development/game-dev-blender/returning-fair-prototype.
PowerShell7 tools/run_checks.ps1, explicit installed Godot4.7.2 Mono console,
Compatibility960x640. Named save slots, primary/backup and APPDATA/LOCALAPPDATA
remain isolated under builds/testing/R015/<run>; normal profile saves are excluded.
The rendered driver uses public viewport WASD/E/Esc/P/mouse/Tab/Enter/F10 and actual
GUI Save/Load. Navigation supplies guidance only. No position, state, clock,
weather, health or affinity setup is used in its ordinary writer. Observation
records natural clock seconds, wall milliseconds, actual-map identities/step
transitions and loaded Ivo body movement separately from paused screenshots.
Read phase uses a distinct process and exact complete typed durable/forecast
oracle at the stable GUI Load checkpoint, followed by actual physical revisits.
Synthetic reused branch/restart checks retain their explicit provenance.

Commands:

```powershell
./tools/run_checks.ps1 -Task R015 -Import -RenderOnly -RenderScript routine_full_day_render -RenderPhases write,read -TimeoutSeconds 900
./tools/run_checks.ps1 -Task R015 -RenderOnly -RenderScript routine_full_day_render -RenderPhases write,read -TimeoutSeconds 900
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/routine_migration/reference_checks.py --source D:/development/game-prototype-2 --self-test --report docs/evidence/R015/reference-preflight.json
./tools/run_checks.ps1 -Task R015 -Names routine_activation_checks,routine_directive_checks -ProcessScripts routine_integration_process_checks -TimeoutSeconds 180
```

Reference audit passed1626 assertions,25 routines,21 anchors,88 source pins,
82 prior exact adaptations and ten negative drift refusals. This is static source
preservation evidence, not ordinary gameplay or source Dart test execution.

## Retained failures (historical verification states)

- 20261010-000306062-07e9bbb5: first import generated the owned UID; source-change
  guard correctly failed the run. Existing allowed import-only .NET SDK diagnostic
  remains recorded; no SDK installation or runtime diagnostic exemption added.
- 20261010-000336262-0619da60: observer read a detached Ivo wrapper during room
  replacement. Added current-room/transition/tree-membership observation guards;
  no production owner changed. The runner retained diagnostics and stopped.
- 20261010-000450928-ee07e562: ordinary social/room route completed; requested river
  viewing point(13,0,-1) was outside navigation by0.20m. Driver now uses previously
  verified reachable(12,0,-1); journey endpoint tolerance is unchanged. Failed
  whole report stays failed. Inspected actual earned-ledger home screenshot.
- 20261010-000716386-ae2a81d3: manually stopped only recorded owned engine tree
  PID22248 at320.72 wall seconds, after natural Edric speech/fishing and22:00 Ivo
  wait. Code inspection identified a redundant later archive-speech wait that
  crossed authoritative10AM assignment-day rollover. Actual Helena breakfast
  speech already meets the approved gate; removed that optional later requirement
  and retained runtime rollover semantics. Run remains failed/unfinished, not
  full-day proof. Inspected full natural Edric speech/fishing and Della frames.

Full-day, recovery, distinct-process restart, final capture inspection and cleanup
remain unfinished until the final passing reports below are recorded.

## Passing deterministic complement

[Report](../evidence/R015/20261010-001358528-58105cd8/results.json): PASS 6/6,
all exit codes 0, diagnostics empty, source.changed=false and source.error=null.
All 1,305 observed game/tools files have fingerprint
`7d98dcfb201238078f2a8d4d418bd1f163c6d0ba0a6cb0553046b713fa4b1e6d`.
The headless checks ran alongside the unchanged waiting natural renderer, with
independent runner directories and save groups; no performance benchmark claimed.

| Check | Actual result | Provenance |
| --- | --- | --- |
| routine_activation_checks | 2,610 assertions, exact 25 routines, zero failures | Existing R013 default-root matrix reused under R015 evidence; synthetic times/conditions/weather/shortened timers, actual physical paths and presentation declarations |
| routine_directive_checks | 128 assertions, zero failures | All five authored Helena choices, atomic failures/events/stale guards; explicitly synthetic setup |
| routine_integration_process_checks write/read | 83 / 99 assertions, zero failures; engine PIDs 37100 / 49816 | Existing R014 complete synthetic durable state, distinct-process primary/backup/forecast/owner oracle; no ordinary-play claim |

The two independent checks use `check-000` and `check-001`; only the restart
writer/reader share `process-002`. Every slot/app-data path is recorded in the
runner report under builds/testing/R015/20261010-001358528-58105cd8.
These passing cases do not replace the unfinished ordinary rendered criteria.

- 20261010-001332676-a80275d9: 561.49 natural active / 564.24 wall seconds,
  26 captures, loaded Ivo circuit 9.99985m, actual Edric speech/fishing and both
  night-rest bodies; breakfast failed. Exact retained trace at 505.99s identifies
  Helena blocker `party-1`, movement failure 3, two repaths/three requests; Edric
  safely canceled with the group. Ally following viewing hero at (2,-8.5)
  occupied the kitchen entry. Driver now walks both party bodies to verified
  kitchen viewpoint (6,0,-4.5) before breakfast. This corrects ordinary route
  guidance, not runtime collision/anchors/retry policy. Run remains failed,
  reader unrun. Full night-rest screenshot inspected; no false breakfast claim.

## Ordinary Save failure and bounded repair

- 20261010-002429235-221e7e03: 681.716441 natural active / 689.415 observed wall
  seconds, actual loaded Ivo distance14.999771m, full night/rest/breakfast/morning,
  Edric and Helena speech/actions, complete six-effect recovery with ally/guardian,
  bridge outward and ford return. Actual GUI Save rejected valid earned Helena
  introduction plus ledger receipts as "opposite introduction receipts". Writer
  failed; reader unrun. Full-day success alone did not mark R015 Done.
- Inspection confirmed every pinned ordinary introduction has a reward flag;
  independent npc-02-review-archive-ledger-choice is oneTime with no reward flag.
  NpcSaveData now applies introduction exclusivity only to the former, preserving
  strict one-time counts/receipt derivation and chronology for all choices.
- 20261010-004028834-106349ad: failed affected checks retained. Historical
  npc_save_checks synthetic fixture contact correctly could not acquire a loaded
  routine lease; the narrow modal-only fixture now explicitly detaches/restores
  its owner. New regression initially lacked its declared synthetic gift item;
  added exactly one owned fixture item, no production inventory change.
- 20261010-004142046-e8e8348e: PASS5/5 (engine/parse/NPC save/routine save/directive
  checks), zero diagnostics and stable source. New actual authored introduction,
  preference/gift and bound ledger transaction restored exactly; modified receipt,
  flag/affinity and fully derived opposite introductions rejected. This focused
  report predates the final explicit fixture-owner restoration/readability capture.
- 20261010-004259267-6dcd2dc6: source-change guard failed after final fixture-owner
  restoration and its exact ledger hash were corrected during routine_save_checks.
  Exit0 assertions alone are not accepted stable-source evidence. Remaining matrix,
  restart and render phases were suppressed; final stable rerun is required.

Simultaneous breakfast world billboards overlap in some camera projections.
The final driver additionally inspects Helena's natural staggered solo speech tail,
without changing placement/clock/dialogue/renderer. Prior overlapping frames remain
in evidence; no claim of simultaneous line separation is made.

Final stable command:

```powershell
./tools/run_checks.ps1 -Task R015 -Names npc_save_checks,routine_save_checks,routine_directive_checks,routine_activation_checks -ProcessScripts routine_integration_process_checks -RenderScript routine_full_day_render -RenderPhases write,read -TimeoutSeconds 900
```
- 20261010-004341624-42409a31: stable final runtime passed engine/parse, NPC save568
  (510 malformed refusals), routine save213, directive139, matrix2610/25 and
  synthetic integration write82/read98. Ordinary writer again reached681.775147
  active/687.829 observed wall seconds,45 images and complete recovery. Actual GUI
  Save now succeeded, exposing a new driver error: current SaveRepository creates
  its first valid backup atomically with primary, so the assumed absent backup and
  redundant second GUI Save predicate were wrong. Whole report remains failed,
  reader unrun. Removed only those two incorrect driver checks; final writer now
  decodes and exactly compares both files produced by the one actual GUI Save.
  Runtime/save API/earlier passing check bytes remain unchanged. Repeat rendered
  writer/reader is required; no passing whole-report or unrun-reader claim.

Verified readable final-runtime frames from that retained run: met-only four-row
People journal, Edric fishing rig, Ivo22:00 rain/wait, both home rest bodies,
Helena natural solo breakfast line and morning archive action. Remaining final
rerun images will be validated and inspected after writer/read completion.
## Final accepted evidence and criterion coverage

[Final rendered report](../evidence/R015/20261010-005834284-09fd668e/results.json):
PASS4/4, every exit0, no diagnostics, source.changed=false/error=null.
Exact 1,305-file game/tools fingerprint:
`fb77b28b62ffba6b388e5defaecd3819893353dfd991e91469ce159311f22ee3`.
WriterPID17464:236 assertions,46 captures, zero failures; readerPID12208:
28 assertions,four captures, zero failures. Writer observed681.722768900904 natural
active seconds /687.976 wall seconds (inspection pauses excluded from clock);
runner process elapsed693.23s. Reader process50.75s. Both normal F10 quits exit0.

```powershell
./tools/run_checks.ps1 -Task R015 -RenderOnly -RenderScript routine_full_day_render -RenderPhases write,read -TimeoutSeconds 900
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/R015/20261010-005834284-09fd668e/render/full-day-write-index.json docs/evidence/R015/20261010-005834284-09fd668e/render/full-day-read-index.json
```

| Criterion | Verified result |
| --- | --- |
| Natural day/solo/group | >=600 active seconds, Engine.time_scale1; actual night rest, both family breakfast bodies/speech, Edric morning town departure and Helena home archive action;22 naturally selected routine IDs recorded |
| Ivo correction | Ordinary conversation and both day/evening assignments; actual late shore/booking circuit14.999771m, MOVING/WAITING states and decreasing real wait timer |
| Edric/Helena art/speech | Actual Edric river line/fishing clip and Helena archive clip; both breakfast lines, plus readable naturally staggered Helena tail; both projections inspected |
| Rooms/social | Actual town/home/inn walking and reciprocal returns; Vale/Della contacts, four met-only People rows; actual moonflower gather/gift consumed once, Helena public-role/preference facts and ledger flag/receipt earned |
| Recovery/ally/crossings | Lead/preparation, main bridge outward, actual two-swing guardian/ally combat (guardian100->50->0, hero100->75), vessel, ford return, fitting; exactly six owned effects, two party members and specialist presentation |
| Save/restart/revisit | Actual GUI Save; complete typed primary and first backup equal writer; F10 quit and separatePID GUI Load exact whole durable/forecast oracle; Maris specialist and indoor Della remembered through physical revisits, no repeated effect/gift |
| Branches/directives | All25/default activation matrix2610; five authored Helena directives plus earned-save regression139; NPC save568/510 malformed refusals; routine save213; separate-PID synthetic integrated primary/backup/restart82/98 |
| Source/preservation | Final live read-only reference audit1626/25 routines/21 anchors/88 pins/82 exact adaptations/ten drift refusals; original baseline before-hashes/prior reasons preserved |

The eight stable passing engine/parse/headless/restart cases in
[004341624 report](../evidence/R015/20261010-004341624-42409a31/results.json) remain
valid case evidence: exits0/no diagnostics/no source changes, writer38740/reader15192.
That whole report remains FAILED because its rendered driver was wrong about backup.
The final run repairs/reruns that failure. Comparing source manifests proves EXACTLY
ONE changed path since those passing cases: unused routine_full_day_render.gd.
All runtime and headless check bytes are identical; no unnecessary suite repeat.
These synthetic branch/restart cases do not substitute for the final ordinary run.

Final rendered save group `render-000`, slot
`check-20261010-005834284-09fd668e-000`; shared writer/reader APPDATA/LOCALAPPDATA
only under builds/testing/R015/20261010-005834284-09fd668e. Earlier independent
headless groupscheck-000..003 and restartprocess-004 remain isolated in their own
run directory. Normal user saves/profile/export presets/packages untouched.

### Visual review and practical limits

[Capture report](../evidence/R015/20261010-005834284-09fd668e/render/derived/20261010-011117-ae7ea5d8/capture-report.json)
verified all50 pause/live-state/settling/provenance records with zero source failures.
Viewed EVERY PNG through contact-01..05 in that derived directory. Also inspected
full-resolution final Helena solo-tail, GUI Saved and GUI Loaded images. Portraits,
choice/fact panels, met-only journal, actual room bodies, Ivo circuit, Edric action,
archive action, guardian/vessel/fitting and remembered return panels were visible.
Simultaneous breakfast billboards overlap in some projections; both individual lines
are readable in natural staggered captures. No claim of simultaneous separation.
Actual final morning HUD showed Thunderstorm (6:16/6:26/8:18AM); evening Edric
fishing was Cloudy and Ivo nighttime Rain. Natural evening thunderstorm shelter was
not observed; the deterministic matrix proves that condition separately.
No FPS/performance benchmark or native-package acceptance is claimed here. R014's
user-approved4ms scheduler p95 ceiling, original2ms misses and combined-slice/
synthetic measurement limitations remain unchanged; threading stays deferred.

[Final audit](../evidence/R015/final-audit.json) verifies intended ten paths, empty
index, unchanged accepted source bytes, historical adaptation reasons/before-hashes,
links and separate PIDs. Final process readback: no Godot engines/windows remain;
unrelated Blender2664/mcp-for-blender65880 untouched. Viewport inputs released,
no native held keys, editor changes or cleanup owed. Source HEAD60c20eb2 clean;
target HEADf2c601ed unchanged. No commit/push performed.

Blockers/unrun R015 criteria: NONE. Exactly R015 Done. Remaining unfinished:R016.
Every checklist item throughR016 complete:NO. Next eligible:R016 fresh Windows
packages and guarded native restart/travel acceptance, after this result's review
and separately instructed successful-task commit. Stop before R016.
R015 authorized successful-task commit follow-up (2026-10-10 UTC)
User reviewed the successful R015 result and explicitly instructed this commit.
Include only the ten reviewed task paths; verify accepted game/tools bytes and
staged blobs before committing. Retain ignored raw evidence locally. Git and
../evidence/R015/commit-audit.json record the verified commit/tree/index outcome.
No push or R016 work. R016 remains the only unfinished task; all throughR016
complete:no. R0144ms approval/original2ms misses/measurement limits and deferred
threading remain unchanged. Historical implementation-turn no-commit statements
above retain their original meaning.
Commit portability correction: initial ten-path staging normalized the validated
ordinary driver (work SHA256f910c600... vs stagedd27f2396...). Added exactly one
root .gitattributes driver/UID -text/-eol rule, making commit scope eleven paths.
Exact existing attribute adaptation retains original before-hash, previous accepted
7f9c203d... hash, all earlier rules/reasons and immutable pins. Only that offline
ledger changes inside accepted game/tools source; every tested game/other tool byte
remains exact. Restage verifies exact blobs. Static reference audit reruns; gameplay
checks are not repeated for Git attributes/offline ownership metadata.
First restage reused the cached normalized blob. Explicit path-scoped
git add --renormalize applies the new exact-byte attribute rule; all tested
game bytes stay unchanged. Commit verification refuses any remaining mismatch.
