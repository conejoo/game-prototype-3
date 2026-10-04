# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M017 verified complete.

## Selection and next action

- Active item: none. M017 save/load/retry/scene compatibility complete.
- Next eligible: M018 measured map performance only. Record actual machine,
  renderer/settings and measure town/dense-forest/crossing frame/draw budgets,
  memory after repeated swaps and navigation/load targets from CONTRACT.md.
  Optimize measured rendering/navigation issues only; do not start M019.
- Evidence: [M017 validation](../evidence/M017/VALIDATION.md),
  [transaction/lifecycle report](../evidence/M017/checks-report.json),
  [preservation/GUI audit](../evidence/M017/audit.json),
  [final exits](../evidence/M017/final-results.json).
- Normal larger `prototype-alderwake` retained. Parent P001–P014 compact native
  completion remains historical; M019 owns larger-map packaged/native acceptance.

## Preparation and source identity

Full migration prompt, applicable AGENTS (workspace only), parent architecture/state,
migration investigation/checklist/state/contract, retained layout/provenance, M016
evidence and actual artifacts/Git inspected. Initial HEAD a4faeff, Git clean.
M017 marked in progress before work; exactly one item. Caveman/gameplay-testing
skills applied. No source write/generator/refresh, Blender, dependency installation,
subagent, commit, push, publication or next-item work.

Snapshot alderwake-f4630f9-m002/source commit
f4630f9966d6637ef6579cd87623ea354758191c unchanged. MapSHA256
 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
layoutSHA2567477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be.
Five pinned inputs/extractor remain unchanged, hashes audited. Prior M015 source
NPC drift (537 objects versus534 pinned) remains recorded there, no source refresh
or live-source revalidation in M017. Schema4/content1 and all production IDs fixed.

## Implementation and changed files

- `game/features/actors/actor_placeholder.gd`: initialize refreshes collision and
  feedback immediately when ready; ready handles actors initialized before tree.
  Fixes stale downed-ally/corpse collision and presentation during paused restore,
  and refreshes living state immediately after retry.
- `game/app/game_root.gd`: guardian state receives durable defeat health before
  initialize; paused restored guardian is immediately nonblocking/flattened.
  No session/save/quest/party authority or persistent field changes.
- `game/tests/map_save_checks.gd` + UID: historical-save matrix, separate-process
  writer/reader, owner bindings, safe party arrivals, load locking/rollback,
  backup/future refusal,24 scene swaps, once-only replays and five retry cases.
- `game/tests/fixtures/map_saves/`: four byte-exact P013/P014 pre-map gameplay saves,
  one labeled synthetic Tollworks-start/downed-ally variant; PROVENANCE.json hashes.
  `map_save_ally_blocked.tscn` and `map_save_retry_failure.tscn`: isolated fixtures.
- `game/tests/companion_checks.gd`: original P009 obstacle coordinates now use
  detached compact Alderwake definition. Assertions and original room retained;
  M010/M017 cover new-map navigation/restore.
- `docs/evidence/M017/`: exact logs/results/reports, launch/bridge/audit scripts,
  three process launches/exits,14 request/response pairs and14 rendered PNGs,
  two actual GUI saved envelopes and acceptance mapping. Migration CHECKLIST/state.

Parent scope/ownership and CONTRACT require no change. Source data, art, terrain,
physics footprints, nav policy, stable IDs, normal save and previous evidence fixed.

## Verification

Exact argv and environment in M017 VALIDATION.md/final-results/process-results/
launch JSONs. Supplied Godot console4.7.2.stable.mono.official.ed1daf0bf. Python
C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe -B.

- Final import0; known missing .NET SDK10.0.9 editor diagnostic remains, no new
  script/asset error. Pinned extractor --check0 and preservation/GUI audit0.
- `map_save_checks.gd -- --phase=write/read/checks`: final PASS0 each, distinct PIDs.
  Five fixtures: fresh town/lead town/completed return/Tollworks vessel plus
  synthetic Tollworks-start with hero37/ally0. Full envelope equality; schema4
  needs no migration, Load leaves disk unchanged. Party at anchor/+1mX; safe floor/
  capsule, owner binding, paused actor/corpse presentation/collision verified.
- Four failed loads restore original session/room/positions/region, preserve
  progress/health, release locks and remain paused. Companion-only obstruction
  explicitly rejected. Concurrent Save/Load/Resume blocked during restore.
- Two warm-ups plus ten round trips:24 swaps, old scene weakrefs null and regions
  absent; one world/region and same two wrappers. All completed quest/reaction/
  upgrade replays leave facts unchanged; no guardian respawn or duplicate reward.
- Four successful synthetic death retries cover all production anchors, both100HP;
  failed navigation retry retains hero0/ally13/original room and positions, no heal.
  One expected rejection ERROR line is labeled in validation; checks PASS0.
- Final save_checks/combat_checks/companion_checks/recovery_presentation_checks/
  application_smoke PASS0. Existing malformed/newer-save, backup, IO/size, legacy
  party migration, unsafe restore and actor/service regressions retained.
- Three rendered current-code GUI processes, all normal F10 exits0 and zero
  ERROR/SCRIPT ERROR runtime lines. Historical GUI Load -> ordinary WASD/E into
  Tollworks -> GUI Save/quit -> new-process GUI Load -> ordinary return -> GUI
  Save/quit -> new-process town GUI Load/resumed hero+ally. No bridge mutations.
  All saved health/progress/trust/upgrades/time restored exactly,75/75HP, strike40,
  trust1, six effects once, specialist restored.14 actual960x640 captures, core
  startup/restore/gameplay/pause views inspected. Actual Compatibility/OpenGL3.3,
  RTX4070 Laptop/NVIDIA581.29. No performance or native-release claim.
- GUI APPDATA/LOCALAPPDATA redirected to builds/m017-windowed-data/local-data,
  slot m017-gui. Headless checks use m017-check/regression directories and isolated
  m017/PID-scoped slot names. Normal user save never opened.
- Final Git review and git diff --check0; prior files/evidence unchanged.

## Retained failures and limits

Initial test property typo caused stalled script/interruption; numeric JSON type
comparison/output-path errors and actual stale paused collision then failed1.
Partial CRLF edit failed writer1 before final fix. Old compact companion positions
failed1 before detached fixture repair; final0. Launcher encoding refused once
before any game launch, then UTF-8 runs0. Failed logs/reports retained and separated
from accepted evidence; no checks silently reclassified. Git ownership restriction
handled with command-scoped safe.directory only when necessary.

Historical save seeding and direct headless placements/death/action retries are
explicit synthetic setup. GUI evidence proves restoration and ordinary continuation,
not a fresh quest journey or hardware/native release. M018 frame/memory/loading
benchmarks and M019 packaged/native larger-map gate remain open. Parent P014 compact
completion preserved. No unresolved M017 criterion; no next item started.