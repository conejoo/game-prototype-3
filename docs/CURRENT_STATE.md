# Current prototype state

Save compatibility cleanup (2026-10-08): user explicitly requires no backward
compatibility for this new project. Runtime accepts only schema6/content1; old
schema branches, migration flags and load notices removed. Reusable map/environment
fixtures now author full schema6 data. Future N004 plan uses only its resulting
current format; historical migration acceptance below is not a current requirement.
Validation, exact timers, checked IO, backup recovery and live restore remain intact.
Existing Windows packages predate this cleanup and require rebuilding to include it.
Verification: nine focused headless checks and five independent writer/reader
pairs pass; dependency parsing passes, source fingerprints remain unchanged and
`git diff --check` is clean. Isolated reports:
`docs/evidence/SAVE_CLEANUP/20261008-070519091-3f120853/results.json` and
`docs/evidence/SAVE_RESTART/20261008-070622124-698f250f/results.json`.
No native/export acceptance rerun; normal save files remain untouched.

Updated 2026-10-07, America/Vancouver. P001-P014, map M001-M019, weather W001-W010
and [foraging F001-F010](foraging-items-backpack/CURRENT_STATE.md) Done; no next item.
[F010 acceptance](foraging-items-backpack/F010_ACCEPTANCE.md) verifies fresh current
schema6/content1 Windows release/validation packages, actual outside-checkout native
all-four gathering/backpack/rod/lamp/quest/party/travel and exact GUI Save/new-process
Load, physical origin revisits and saved rod recollection. Both native quits exit0;
all criteria verified, no owned process/editor/cleanup owed. Runtime unchanged by F010.
Historical [weather-lighting](weather-lighting/CURRENT_STATE.md) baseline follows.
User-requested [testing tools follow-up](TESTING_TOOLS_IMPROVEMENTS.md) adds guarded
evidence, live diagnostics, dependency parsing, verified GUI outcomes and RenderOnly;
regressions pass and project/installed skill guidance is synchronized.
Typed clock/seed/cached forecast now advance through the existing session gate.
Weather's historical schema5/content1 retained exact environment time/seed and six validated lantern
overrides; exact v1-v4 migrate without losing prior facts or rewriting files.
Save/backup/physical rollback and isolated separate-process checks pass.
One root-owned presenter drives the moving outdoor sun and smooth day/dusk/navy
night/dawn direct/ambient/background/shadow values. Tollworks keeps its original
lighting while global time advances. Profiles apply at committed arrival, including
paused travel/load; rollback retains the previous presentation. W004 sampling,
ownership/pause/rollback and eight affected regressions pass; 37 synthetic rendered
captures inspected in both projections. All23 exterior sources now have independent
visual consumers, imported lamp/waylight/net art and registered emissive window
panes. Eight unshadowed local emitters and source-opacity/spatial fading preserve
logical defaults/overrides and existing physics. W005 consumer13,289 assertions,
eight affected checks and65 inspected synthetic renders pass. Six lamp switches now use typed identities, existing E/range/LOS and modal/combat locks, with independent saved choices. W006151 checks, seven focused regressions and17 inspected renders prove GUI Save/new-process Load and town/Tollworks persistence.
Forecast-driven overcast, world-anchored terrain/roof-excluded rain and bounded
lightning now pass W007193,417 checks and66 inspected rendered captures. Pause
rain pixels freeze; actual GUI Save/new-process Load restores exact storm phase/
flash. Tollworks retains stable appearance and excludes weather; rain owner frees
on travel. W008 lifecycle/HUD/review isolation, W009 visual/performance gates and
W010 fresh package/native feature acceptance are verified. Current Windows builds
include weather; historical packages preserved. See [W010 acceptance](weather-lighting/W010_ACCEPTANCE.md)
for commands/hashes, isolated appdata, exact native restart and retained failures.

User-requested settings/debug addition (2026-10-04): Esc → Settings exposes
independent Show FPS and Enable debug shortcuts switches, both run-local and off
by default. `--debug-shortcuts` initializes the same mode; Settings can disable
it. F6 skips exactly one environment hour, refreshes weather/lighting, preserves
play/actor/quest timers and respects pause/modal/travel/load/death/retry/focus
gates. Esc from Settings returns to the paused menu before resuming.
Focused settings_debug_checks, actual flag subprocess and rendered GUI/key
review pass; four 960x640 screenshots inspected. Startup, environment session,
movement/camera, environment saves and existing playtest bridge regressions pass.
Final isolated evidence: docs/evidence/SETTINGS/20261005-013452115-2f9402fc;
regressions: 20261005-013304874-856232de (initial settings fixture failures
retained and corrected). Runtime diagnostics clean. Existing Windows packages
were not rebuilt at that settings follow-up; W010 later rebuilt/accepted them.

Playable baseline: larger Alderwake town/river/Moonwood, temporary ally/trust,
preparation-point Strike upgrade, guardian/vessel recovery, Maris return/fitting
and service preview, travel and manual saves. Current schema6/content1; once-only effects
and stable actor/quest/location IDs. Six other portals stay inactive. Full campaign,
permanent companion decisions, NPC schedules and shops remain excluded. Current
foraging adds peaceful flowers,20-slot backpack and movable selectable rod; full
fishing minigame remains excluded.

M019 verified larger-map Windows exports/startup and genuine fresh native journey,
GUI Save, quit, independent GUI Load and replay. Durable quest/party/trust/upgrade
fields matched after restart. Focused application, combat, save, camera, navigation,
extension and lifecycle checks passed. No unresolved native release gate. P014's
compact release proof is historical; current packages are the larger map.

Useful context: [architecture](ARCHITECTURE.md), [map contract](map-migration/CONTRACT.md),
[map handoff](map-migration/CURRENT_STATE.md), applicable feature checklist/contract,
current source/tests and pinned references. Raw screenshots, logs, failed runs and
session drivers live under ignored docs/evidence; read only for a specific issue.
Missing local archives do not block development. Keep task acceptance criteria and
concise completion records; remove duplicate transcripts and oversized inventories.

Run/check commands and controls: README. Native/debug testing: tools/PLAYTEST.md
and tools/skills/returning-fair-gameplay-testing/SKILL.md. Native release requires
separate APPDATA plus verified override.cfg custom user directory; debug --save-slot
is ignored there. Pause must be observed before inspection between input batches.
Never overwrite normal saves. Keep installed/project testing skill copies aligned.

Local Windows packages live under builds/windows and builds/windows-validation;
F010 accepts their current schema6 foraging build; W010 remains historical weather
schema5 evidence. Rebuild before accepting later changes. Outputs remain ignored;
unsigned local builds only. Original compact packages/validation saves and raw
reports stay local. No publication; current package/native acceptance belongs to F010.

Repository cleanup (2026-10-04): 8,505 generated evidence files untracked and
ignored; local archive and pre-cleanup document copies preserved. Compact weather
references, independent portal measurements and exact camera poses remain versioned.
Clean staged checkout passed weather audit, all 15 extractor tests, application
startup and ten affected map report checks; four render/profile scripts parse.
Tree audit used actual Compatibility renderer after expected headless rejection.
Import exit 0 retains known missing .NET SDK diagnostic. Saves/temp outputs isolated
under builds/repo-cleanup. No native quest/visual/performance acceptance rerun.

Testing follow-up (2026-10-04): shared bounded runner, exact typed restart/capture
helpers, read-only environment/camera bridge observations, narrow W-task native
path/no-overwrite guards and synced project/installed skill are complete.
Runner/guard32 and support64 assertions, capture integrity/refusal tests, existing
bridge/W006151/codec517 checks and17 new real restart renders pass. Native helper
interop/focus guards remain unchanged; no new native package claim. See
[tooling acceptance](TESTING_TOOLS_ACCEPTANCE.md) and tools/PLAYTEST.md. W007 remained next at that tooling follow-up.

Weather W007 follow-up (2026-10-04): final rule/renderer checks and eight affected
regressions pass; initial W006/testing dirty work preserved. Checklists/contract/
handoff reconciled. All owned game processes exited, normal saves/user Blender
untouched. Next eligible W008 only; no next task started.

Weather W008 completed (2026-10-04): committed time/weather HUD, read-only condition
service and isolated debug review controls. Lifecycle157 and actual CLI checks,
affected save/map/input/travel regressions and exact GUI process restart pass.
Fourteen accepted rendered views inspected; review saves refuse at root/repository.
Legacy map report-path/interaction fixtures repaired; historical report recovery
recorded in W008 acceptance. No W009 benchmark or W010 package started.
Next eligible W009 only; normal saves untouched and owned processes exited.

Weather W009-W010 complete (2026-10-04): W009 full visual matrix and24 focused
three-run benchmark windows pass unchanged gates (worst6.805ms p95/9.188ms p99/
280 draw p95), with stable repeated-travel resources. W010 rebuilt/audited both
Windows presets and outside-checkout startups, then genuine native recovery,
independent lamps, natural weather/time, exact GUI process restart and service/
cleared-room revisit.80 native images inspected; all final runtime scans clean.
Historical packages archived, normal saves/user Blender untouched; owned processes
exited. [W010 acceptance](weather-lighting/W010_ACCEPTANCE.md) holds commands/hashes/
failures/isolation. All W001-W010 Done. No next item.
