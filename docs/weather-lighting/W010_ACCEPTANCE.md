# W010 packaged Windows and native acceptance

Completed 2026-10-04 (America/Vancouver). Exactly W010 selected from an initially
clean tree after verifying W001-W009 artifacts and acceptance. All W010 criteria
pass; W001-W010 are Done with no next item. No production behavior, save contract,
renderer, pinned geography or source checkout changed.

## Criteria and evidence

| Criterion | Verified result |
| --- | --- |
| Rebuild both existing Windows presets; preserve old packages | Windows Validation/debug and Windows Desktop/release exported with retained official standard 4.7.2 templates. Original packages and override archived before promotion; new hashes below. |
| Package assets/scripts and independent startup | Both packs contain valid catalog, pinned layout, schema5, 23-source registry and all four imported environment kits. Release excludes tests; no Blender authoring/Flutter files. Both executables start normally with cwd outside checkout, no editor/project path, exit0 and clean runtime scans. |
| Fresh native recovery and lamp switching | Actual release writer, ordinary WASD/E/mouse/journal/dialogue controls: trust choice, Maris lead, Strike upgrade, independent lamps, Moonwell ramp, sand ford and bridge, Tollworks guardian defeat/vessel/return, fitting and specialist service preview. No injected quest/combat facts or placement. |
| GUI Save, quit, separate-process GUI Load and revisit | Native writer24704 and reader27408, both normal exit0. Reader starts fresh, explicitly loads through GUI, then saves while still paused. Entire save file is byte-identical; typed release-pack decode independently confirms exact snapshot and reconstructed forecast. Native Tollworks revisit retains cleared guardian; town revisit retains service, party facts and opposite lamp choices. |
| Genuine clock/weather progression | Seed627001559 retained; native Clear → Cloudy → Rain → Cloudy, daylight → dusk/night → after midnight. Ordinary play clock advances through both rooms, without F6/debug review or forced time/weather. |
| Inspected captures and clean logs | 80 actual960x640 native images inspected via seven sheets and important originals. Actors, lamps, E prompts, terrain, forest canopy, bridge/ford, rainy night and indoor combat remain readable. All352 guarded native requests successful; writer/reader stdout/stderr/runtime scans clean and exits0. |
| Imports and focused regressions | Import/parse and listed runtime suites pass after focused settings child evidence-path repair. Known editor-only missing .NET SDK10.0.9 diagnostic retained; standard GDScript packages need no .NET runtime. |
| Durable workflow/release handoff | Checklist, weather state/contract and parent README/architecture/state reconciled. Historical P/M acceptance and ignored raw evidence preserved. Link/status/source/diff review completed. |

Headless checks certify rules and package contents. Native screenshots certify
appearance and ordinary controls. W009's synthetic visual matrix and measured
performance remain their own accepted evidence, not native journey substitutes.
W010 did not repeat rare thunderstorms or the inactive closed exit; those existing
matrix/map checks remain historical. No required W010 criterion is failed/unrun.

## Commands and retained raw runs

Working directory for source tools:
`D:/development/game-dev-blender/returning-fair-prototype`.
Godot console:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
Python:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Runner records actual argv, isolated environment, process IDs, exits and scans.

```powershell
./tools/run_checks.ps1 -Task W010 -Import -Names application_smoke,environment_lifecycle_checks,environment_save_checks,light_interaction_checks,playable_slice_checks,recovery_presentation_checks,combat_checks,extension_checks,settings_debug_checks -TimeoutSeconds 180
./tools/run_checks.ps1 -Task W010 -Names settings_debug_checks,save_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task W010 -Names map_activation_checks,map_camera_checks,location_travel_checks -TimeoutSeconds 150
```

Raw roots under `docs/evidence/W010/`, respectively:
`20261005-042909294-c1ba9525`, `20261005-043216461-87baf7d7`,
`20261005-043426322-729a039e`. Initial import and eight runtime checks passed;
settings flag child failed because it omitted required `--report-dir`. Repaired
only child evidence routing and distinct child index filename; settings/save
rerun passes. Remaining map/camera/ten-round-trip checks pass. All final runtime
exits0 and scans clean; import retains only the known .NET diagnostic.

```powershell
& $weatherPython tools/weather_lighting/build_packages.py
& $weatherPython docs/weather-lighting/reference/audit.py
./tools/weather_lighting/launch_native.ps1 -Session 20261004-journey -Phase writer
./tools/weather_lighting/launch_native.ps1 -Session 20261004-journey -Phase reader
& $weatherPython tools/weather_lighting/audit_native.py docs/evidence/W010/native-20261004-journey
& $weatherPython tools/weather_lighting/audit_native.py docs/evidence/W010/native-20261004-journey --output-directory docs/evidence/W010/native-20261004-journey/caption-revision
```

`$weatherPython` is the Python executable above. Package raw root:
`packages-20261005-043344-61e32d70`; disposable staging:
`builds/weather-lighting/W010/20261005-043344-61e32d70`. Package results retain
exact export/audit/startup argv and launcher IDs (not falsely called engine IDs).
Both exports, external pack audits and standalone startups exit0. Original builder
startup cwd was staged package; stronger separate tests below run outside checkout.
Reusable builder now uses external TEMP for future standalone startups.

Outside startup raw root `outside-58057331`: each installed executable directly
with `--headless --quit-after 180 --verbose`, cwd
`C:/Users/aldoc/AppData/Local/Temp`; validation58212/release30508 exit0 with
normal Alderwake party2 arrival and clean scans. APPDATA/LOCALAPPDATA are separate
`builds/weather-lighting/W010/outside-appdata` and `outside-localappdata`.
Neither source `--path game` nor Flutter checkout is part of startup.

Read-only typed save reconstruction, engine10468, exit0/clean scan:

```powershell
& $weatherGodotExe --headless --path builds/windows --main-pack "$weatherRoot/builds/windows/ReturningFair.pck" --script "$weatherRoot/tools/weather_lighting/save_audit.gd" -- --before="$weatherRoot/docs/evidence/W010/native-20261004-journey/writer/18-completed-save.json" --after="$weatherRoot/docs/evidence/W010/native-20261004-journey/reader/03-exact-restored-save.json" --audit-output="$weatherRoot/docs/evidence/W010/outside-58057331/native-save-audit.json"
```

`$weatherRoot` is the absolute target root and `$weatherGodotExe` the console
above. The saved report is immutable; replay requires a fresh output path.
Reference audit passes four exact source hashes, 23 lights, 49 forecast vectors,
clock advances and uint32 arithmetic; no source refresh/generator invocation.

## Package identity and preservation

| Installed file | Bytes | SHA256 |
| --- | ---: | --- |
| builds/windows/ReturningFair.exe | 109268480 | d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562 |
| builds/windows/ReturningFair.pck | 5035280 | e8c5287f996e488afb8d994541761274ab5fa8b9ef7acfcec2f2046a48f0ac0c |
| builds/windows-validation/ReturningFairValidation.exe | 103176704 | 51498b72b3a237f882ebd7d1787f06a4bc1eaf0572daab93837adcfd3cfdc107 |
| builds/windows-validation/ReturningFairValidation.pck | 5140788 | ad625bf40799195cf42c4b95bf5d78dba7d03c42bd6323b0e314671c59175588 |
| builds/windows-validation/ReturningFairValidation.console.exe | 188928 | 5514c7645ee897a01f540d3cf22ede5badf92394521a08bfab66a54d7369e6e6 |

Old files are retained under staging `previous-packages/windows` and
`previous-packages/windows-validation`. Old release pack SHA256
`28868aaf1dfa7a9dfd4cdc14e8a1746de885df5be5974e6f45cb7820783d12b8`;
old validation pack `09d91cf1c9e0a0131d815f28743adf2c99e4fd81265a689aee89f4f26f8c654c`.
Preserved release override SHA256
`8f5fc180acedec304e626cb811982472a2e867a28ee3f50920ccb45b38a74654`.
Pinned layout remains
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.
Outputs remain unsigned/local/ignored; no commit, publication or installation.

## Native provenance and exact persistence

Raw root `docs/evidence/W010/native-20261004-journey/`, writer/reader subdirectories
contain launch/exit records, captured helper request IDs/input traces and logs.
Launcher uses installed release cwd `builds/windows`, resolution960x640,
position40,40, verbose/runtime log and only read-only `--p003-evidence` tracing.
No bridge, developer fixtures, teleport, direct state mutation or time skipping.
Separate external `native_route.gd` computes synthetic navigation guidance from
the packaged navigation mesh. `walk_native.ps1` converts that guidance to actual
camera-relative WASD pulses bounded25s, ends paused, and fails physical stalls.
Guidance is not gameplay evidence; native captures/movement/quest logs are.
Every batch uses guarded `tools/native_input.ps1`; observed pause checkpoints
precede inspection. Input released by helper finally paths; no owned game remains.

Native APPDATA/LOCALAPPDATA:
`builds/weather-lighting/W010/native-20261004-journey/appdata` and `localappdata`.
Verified adjacent override selects `ReturningFair-P014-ReleaseValidation`.
Actual save: `appdata/ReturningFair-P014-ReleaseValidation/saves/returning-fair.json`.
Fresh writer requires absent save; reader reuses only that isolated writer slot.
Release ignores debug `--save-slot`; normal user saves were never used.

Writer progress/completed and reader replay snapshots retain seed627001559 with
day0 progress `0.23311473834987154`, `0.5699809053838213`, `0.669324332925979`;
elapsed seconds `139.8688430099335`, `341.98854323005884`, `401.59459975523475`.
Completed writer and immediately re-saved still-paused GUI reader are byte-identical:
SHA256 `5652df3785fea5bd25816d7bc935a849429c3636659d5cce1ad2f28c42663c00`.
Typed decode confirms entire snapshot and forecast: Rain/previousCloudy, period2,
start587/end898 minutes, blend1, heavy-rain false, display11:40PM.

Independent saved choices: `prototype-alderwake/dock-lamp-04/lantern=true` and
`prototype-alderwake/dock-row-lamp-01/lantern=false`. Native revisit shows lamp04
lit with Turn off prompt and Dock Row dark with Turn on prompt. Saved ordered
party hero75/ally25, trust1/shared-plan, Deliberate Strike, six once-only effects
and six recovery steps restore exactly. Arrival remains `alderwake-from-tollworks`,
not the physical town save position. Revisit re-save matches every other durable
fact; only naturally advanced environment time/elapsed are excluded from that
replay comparison. Restart comparison excludes nothing.

All80 image pixels and seven original sheets inspected. Caption revision corrects
three actual paused frames formerly labeled conservatively as active/modal;
revised sheets01/03 inspected, originals/raw inputs preserved. Native auditor
checks PNG dimensions/hashes/timestamps/PIDs, 260 writer +92 reader requests,
both exits/scans, exact restart and durable replay facts. Active screenshots were
taken just before pause; dialogue/journal screenshots are modal, not clock-frozen.

## Repairs, files and final handoff

Retained failures: settings child missing report-dir; first external route planner
used relative pack/script paths and failed startup. Corrected absolute paths
produce pass0 guides. First physical Maris approach hit a building and was corrected
through ordinary movement; first combat aim batch required further ordinary attacks.
No runtime/quest repair, test weakening or fabricated completion. Initial audit
caption correction is retained alongside its fresh revision.

Reusable new tools: [builder](../../tools/weather_lighting/build_packages.py),
[pack audit](../../tools/weather_lighting/package_audit.gd),
[native launcher](../../tools/weather_lighting/launch_native.ps1),
[guidance](../../tools/weather_lighting/native_route.gd),
[bounded walker](../../tools/weather_lighting/walk_native.ps1),
[save audit](../../tools/weather_lighting/save_audit.gd),
[native auditor](../../tools/weather_lighting/audit_native.py).
Narrow regression fix: `game/tests/settings_debug_checks.gd`.
Updated weather CHECKLIST/CURRENT_STATE/CONTRACT and parent README/ARCHITECTURE/
CURRENT_STATE. Script parsing, document links, all10 Done statuses, package hashes
and intended-file diff reviewed. `git diff --check` run; CRLF-aware check used for
the repository's retained CRLF documents. Plain check flags retained CRLF endings
as trailing whitespace; `git -c core.whitespace=cr-at-eol diff --check` exits0.
Known missing editor .NET SDK diagnostic
is the only remaining environment limitation. All owned Godot/native processes
exited normally; user Blender work untouched. Next eligible task: none.
