# AD019 full painted-build performance acceptance

Done, 2026-10-11 UTC. Exactly AD019 completed. AD001-AD019 Done; AD020 remains Pending and is the next eligible task. Every checklist item through AD020 complete: **no**. The user supplied the separate post-review successful-task commit instruction, explicitly including acceptance evidence. This follow-up records and commits reviewed AD019 scope only; no push or AD020 work.

## Outcome and scope

The accepted painted build meets every fixed art performance target at town, dense forest, bridge and ford, under clear day and storm/night. No demonstrated over-budget art/material/batching defect required a production repair. The current painted textures, lighting, HUD, default routines, actors, rain, shadows, physics, navigation, feet, identities and schema8/content1 remain unchanged.

Starting HEAD `c6325cb76c30ed7ca3ddda1b7058b4f32b5b63a6` is context only. AD018 prerequisite acceptance/raw evidence, current sources, workspace instructions, active prompt/checklist/handoff/contract/look/baseline, architecture, weather/map/routine profiling methods, PLAYTEST and versioned gameplay-testing skill were inspected. No additional applicable AGENTS or `.agents/skills` exists. The selected concept and fresh engine pixels were opened. No other conversation, external source checkout, live editor/Blender state or ordinary user save directory was used.

Six task paths: `tools/art_direction/profile_storybook.py`, `game/tests/art_direction_performance_profile.gd`, its generated `.uid`, this acceptance, `CHECKLIST.md` and `CURRENT_STATE.md`. The Python adapter reuses the M018 Win32 process-memory counters, creates unique AD019 evidence/app-data paths, retains logs/commands/hardware/PIDs, fingerprints game/tools and bounds/cleans its owned process tree. It never routes acceptance into W009/R016. The GDScript fixture reuses the original M018 cadence/query/travel method and W009 real-weather presets, explicitly rebinds the detached review session to the current default routine owner and refreshes frozen HUD presentation before capture. The legacy helpers and original assertions/pins remain unchanged.

The only inventory adaptation is task-local: M018's whole-location physics count includes scheduled CharacterBody3D contacts. A legitimate departure changes total824/823 with6/5 live bodies. The new fixture records both quantities and compares invariant static physics818 while retaining every inherited tree/cliff/geometry/navigation assertion. It does not disable routines or replace the live roster with a fixed fixture. Both full profiles pass this invariant and all original lifecycle safety checks.

## Full method and hardware

Two fresh, sequential full runs, painted first and prepaint second, avoid competing benchmark GPU load. Each uses GL Compatibility (`gl_compatibility`), Godot4.7.2 stable Mono (`ed1daf0bf`), 960x640, orthographic zoom1, VSync0/max_fps0. Hardware: Windows11 Home10.0.26200, Intel Core Ultra9 185H, 33,736,015,872 RAM bytes, NVIDIA GeForce RTX4070 Laptop GPU/OpenGL3.3.0 NVIDIA581.29; CIM driver32.0.15.8129. The Intel Arc adapter/driver32.0.101.8132 is also declared by CIM; actual engine renderer uses NVIDIA. Both hardware JSON files and all benchmark settings match.

Each of eight view/condition pairs has10s warmup followed by **three full60s windows**, nearest-rank whole-process-frame intervals and draw-call samples. Captures are verified paused, synthetic clock/seed/party feet setups; normal full production processing resumes for every measured window. Clock/weather advance naturally within each window, and the real forecast stays fully clear or storm, with night factor1 and storm rain1. Six named storm lamps are explicitly enabled within the existing eight-emitter pool. Default routine owner, loaded villagers, party AI, UI, physics and shadows remain active. The review banner and disabled review save repository are present in both builds. No ordinary-play, natural-day or native-input claim is made.

Process working set is sampled every nominal0.25s using the **actual engine PID**, not the console launcher or Godot texture/static estimates. Twelve town/Tollworks round trips retain original request/arrival, old scene/region disposal, one region/world, two party wrappers and safe spawn assertions. Checkpoint1 follows two warmup round trips and10s idle; checkpoint11 follows ten further round trips and10s idle. Each checkpoint includes four process-memory samples. Nodes/objects/resources/effects are compared in the same storm/arrival phase.

The prepaint baseline is an isolated exact Git archive of `8bbf35d8edbc327b1df5aa15a9a2a780af1360c3`, prepared under `builds/art-direction/AD019/prepaint-8bbf35d`; it is never a checkout/reset target. Only the identical AD019 fixture/UID is added. Its100 imported metadata files differ solely by CRLF/LF normalization after local import; all original production/source/export bytes and import parameters match the archive. Archive SHA256 `53497abf2bccfb54f5fb3a35ea87079938a313e0e3ee26a4d6d11ae7db88e132`. [Preparation](../evidence/AD019/authoring-20261011/baseline-preparation.json) and [raw audit](../evidence/AD019/authoring-20261011/profile-data-audit.json) retain the proof.

## Results

All48 full windows pass. Painted242,139 frame samples; prepaint261,709; combined503,848. Each CSV sample count/focus count, duration and p95/p99/draw quantile was independently recalculated from raw rows. Every window ran at least60s, with no unfocused sample. These are full profiles, not extrapolated smoke observations.

| View / condition | Painted p95 / p99 ms (worst of3) | Prepaint p95 / p99 ms (worst of3) | Painted / prepaint draw p95 |
| --- | --- | --- | --- |
| Town clear day | 8.188 / 10.629 | 8.052 / 10.237 | 264 / 282 |
| Forest clear day | 7.943 / 10.436 | 7.759 / 9.924 | 149 / 151 |
| Bridge clear day | 8.327 / 10.687 | 7.679 / 9.762 | 130 / 136 |
| Ford clear day | 7.955 / 10.767 | 7.407 / 9.449 | 127 / 129 |
| Town storm/night | 8.852 / 11.407 | 8.352 / 10.555 | 288 / 306 |
| Forest storm/night | 7.929 / 10.280 | 7.674 / 9.858 | 155 / 157 |
| Bridge storm/night | 7.913 / 10.410 | 8.000 / 10.140 | 139 / 145 |
| Ford storm/night | 7.585 / 9.700 | 7.556 / 9.668 | 126 / 128 |

| Fixed gate | Painted | Prepaint | Outcome |
| --- | --- | --- | --- |
| Whole-frame p95<=16.67ms | max8.852ms | max8.352ms | Pass |
| Whole-frame p99<=25ms | max11.407ms | max10.555ms | Pass |
| Draw p95<=500 | max288 | max306 | Pass |
| Process peak<=2GiB | 570,249,216 bytes (543.83MiB) | 543,637,504 bytes (518.45MiB) | Pass |
| Travel growth<=64MiB | 1,335,296 bytes (1.273MiB) | 860,160 bytes (0.820MiB) | Pass |
| Stable lifecycle counts | 4066nodes / 8420objects / 519resources | 4064nodes / 8330objects / 414resources | Exact within each build |
| Stable effects/ownership | one rain owner /12batches /23consumers /8emitters /one presenter | same | Exact within each build |

Both retain zero orphan nodes, one navigation region, one world child and two party members. Current painted peak adds26,611,712 bytes (25.38MiB) over the fresh prepaint run; final checkpoint working set adds34,131,968 bytes (32.55MiB). Resource count rises105 and node count2 across builds, consistent with the accepted expanded presentation/resources; neither grows across the ten measured travel trips. Draw p95 is lower in every corresponding view. Largest positive paired p95 difference is0.648ms at bridge/day; bridge/storm is0.087ms lower. These sequential measurements include ordinary run variability and all accepted presentation changes; they do not isolate a material's causal cost. Both meet the strict art targets without using the historical routine paired-baseline allowance.

No fresh full-profile target failed in either build. Historical R014's original2ms scheduler estimate/revised4ms budget and historical AD018 synthetic navigation/save-fixture failures remain separately recorded; this task does not repair or certify those older suites. The AD001 paused120-frame samples remain observations, not the paired full baseline used here. Individual frame maxima remain in raw CSV/reports; the declared gates are p95/p99, not a maximum-frame bound.

## Commands and evidence

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7, unless explicitly stated. Installed console path was verified. All engine processes use unique APPDATA/LOCALAPPDATA under `builds/art-direction/AD019` or the bounded runner's `builds/testing/AD019`, with named debug slots. Review Save/Load is disabled; no ordinary save is read or written.

```powershell
./tools/run_checks.ps1 -Task AD019 -Import -Names application_smoke -ParseScripts tests/art_direction_performance_profile,tests/environment_review -TimeoutSeconds 180
./tools/run_checks.ps1 -Task AD019 -Names application_smoke -ParseScripts tests/art_direction_performance_profile,tests/environment_review -TimeoutSeconds 180
& 'C:/Program Files/Blender Foundation/Blender 5.2/5.2/python/bin/python.exe' tools/art_direction/profile_storybook.py --smoke
& 'C:/Program Files/Blender Foundation/Blender 5.2/5.2/python/bin/python.exe' tools/art_direction/profile_storybook.py --smoke --label prepaint --project-root builds/art-direction/AD019/prepaint-8bbf35d
& 'C:/Program Files/Blender Foundation/Blender 5.2/5.2/python/bin/python.exe' tools/art_direction/profile_storybook.py
& 'C:/Program Files/Blender Foundation/Blender 5.2/5.2/python/bin/python.exe' tools/art_direction/profile_storybook.py --label prepaint --project-root builds/art-direction/AD019/prepaint-8bbf35d
```

The same runner import/parse/application command was run from the isolated prepaint project's cwd. Fresh staging import normalization is retained as a failed changed-source attempt; the stable rerun passes3/3 at its `docs/evidence/AD019/20261011-125319617-61e7c3fb/results.json`. Current final parse/application [gate](../evidence/AD019/20261011-125416781-c6bc5c25/results.json) passes3/3, source.changed=false/error=null.

- [Painted full process result](../evidence/AD019/painted-20261011-125512-9ac131ac/process-results.json), [full engine report](../evidence/AD019/painted-20261011-125512-9ac131ac/render/report.json): exit0,1565.280s, no runtime diagnostic/failure/source change.
- [Prepaint full process result](../evidence/AD019/prepaint-20261011-132146-b4aa67ad/process-results.json), [exact archived engine report](../evidence/AD019/prepaint-20261011-132146-b4aa67ad/archived-render/report.json): exit0,1566.157s, no runtime diagnostic/failure/source change. `launch.json` preserves the original engine evidence path under the isolated baseline project; archived reports/CSVs/PNGs are exact byte copies, not another launch.
- [Quantile/settings/source/archive audit](../evidence/AD019/authoring-20261011/profile-data-audit.json), [paired summary](../evidence/AD019/authoring-20261011/paired-summary.json), [preservation](../evidence/AD019/authoring-20261011/preservation-audit.json), [owned PID cleanup](../evidence/AD019/authoring-20261011/cleanup-pids.json).
- [Painted24 capture provenance](../evidence/AD019/painted-20261011-125512-9ac131ac/derived/20261011-132352-a4f19cfa/capture-report.json), [prepaint24 archive provenance](../evidence/AD019/prepaint-20261011-132146-b4aa67ad/derived/20261011-135012-818b6ffc/capture-report.json), [original/copy hash mapping](../evidence/AD019/prepaint-20261011-132146-b4aa67ad/archive-provenance.json).

Existing `tools/capture_evidence.py` ran with cached offline Pillow12.3.0 via installed `uv`, for both manifests. No network fetch occurred. Both helpers exit0 and validate24 paused960x640 PNGs/provenance each. All48 actual Godot frames/four sheets inspected, plus full-size painted town/day, forest/storm, bridge/storm, ford/storm and prepaint town/storm. Current painted recipe, party/crossing/HUD/rain/light readability remains intact; no missing texture/resource or broken physical footprint was observed. Captures are deliberately synthetic and paused; they are not native or ordinary-route acceptance.

## Retained attempts, preservation and completion

Initial sandbox CIM ownership query failed; scoped runner/profiler escalation was approved, with no automatic-review rejection. Current import generated17 UIDs and warned about previously absent caches; changed-source evidence failed as required. Sixteen older incidental UIDs were hash-verified/removed after import settled; only the new task UID remains. Stable current parse/application was rerun afterward. First short tooling smoke failed only the old dynamic-body inventory equality; all frame/draw/memory/lifecycle samples passed, but that attempt stays failed. Corrected painted/prepaint tooling smokes both pass and remain explicitly non-acceptance samples.

Python's sandbox launcher emitted a real-location warning; a first offline Pillow attempt against Python3.14 had no cached matching wheel. Python3.13 used cached Pillow successfully. The Blender Python utility's inherited `sitecustomize` printed a missing `blender.shared` message; capture helpers nevertheless exited0 with structurally verified hashes/PNGs. The final documentation audit first hit Windows default-encoding decoding of historical checklist punctuation; it was rerun with explicit UTF-8. These utility diagnostics are retained separately from clean Godot runtime logs and are not hidden as engine successes.

All1408 accepted AD018 game/tools input hashes match the full painted manifest. Final1411-file digest `06de66f011592e518852df960b30926363ddfef6198822d749d8e24301567f1e` matches current sources exactly; all code/asset/helper bytes remain unchanged after full measurement. Prepaint1314-file digest `e96cba7f456886dbe02e41306be1d18b4b8aa26e2a09c7f63c63af8699a8a6b0` is unchanged across its full run. Original pins, atlas/export/source artifacts, user-authored direction/prompt/contract/interiors documents and historical R016 status remain intact. Preservation and final scope audits record protected counts/exact task hashes. HEAD unchanged; index remains empty.

All38 recorded owned Godot launcher/engine PIDs have exited. No injected/held keyboard or mouse input, live test process, editor/Blender change or cleanup remains. Every AD019 criterion is verified; **blockers:none; required criteria remaining/unrun:none**. Historical R016 remains Blocked/incomplete. No package, native GUI Save/new-process Load, full routine release or general migration acceptance claim. AD020 is the only unfinished/next eligible AD task; stop here.


## Authorized commit follow-up - 2026-10-11 UTC

All six reviewed task hashes,1411 validated source files,48 full profile windows,48 capture hashes/four sheets and3890 protected inputs reverified before documentation-only follow-up edits/staging. Scope includes six task paths plus final engine frames/sheets,full CSV/process/hardware/source reports,stable current/baseline preflights,retained failed-run reports and acceptance/preservation/cleanup/pre-commit audits. Exact selected paths/hashes in [commit review](../evidence/AD019/commit-review.json). Builds/save archives/prepaint Git payload,temporary authoring scripts,duplicate tooling-smoke images and unrelated direction/interiors/AGENT_PROMPT/CONTRACT remain excluded. Local docs/evidence/AD019/authorized-commit-20261011/commit-audit.json records verified commit/tree/path/blob identity and final status after commit. AD001-AD019 remain Done;AD020 Pending. No push or AD020 implementation.
