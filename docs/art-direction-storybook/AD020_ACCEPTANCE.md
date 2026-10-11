# AD020 local Windows painted-art delivery

2026-10-11 UTC. **Done.** AD001-AD020 are all Done; unfinished IDs: none;
next eligible task: none. Blockers and required unrun criteria: none. This is
unsigned local art delivery and bounded native smoke, not full R016 routine,
recovery, replay or natural-day release acceptance. R016 remains incomplete.
User requested review before the separate authorized commit instruction; no
commit, push, publication, installer or other migration was performed.

## Delivery and acceptance

Fresh current **Windows Desktop/release** and **Windows Validation/debug** presets
were exported, audited, started outside checkout and promoted only after all ten
package cases passed, exit0 with no diagnostics. Canonical deliverables are
`builds/windows/ReturningFair.exe` + `ReturningFair.pck` + unchanged `override.cfg`,
and `builds/windows-validation/ReturningFairValidation.exe` + `.pck` + console
wrapper. Previous packages remain exact, hash-verified copies in
`builds/art-direction/AD020/20261011-142239-03737612/previous-packages/`.

| Deliverable | Bytes | SHA256 |
| --- | ---: | --- |
| Desktop EXE | 109268480 | `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562` |
| Validation EXE | 103176704 | `51498b72b3a237f882ebd7d1787f06a4bc1eaf0572daab93837adcfd3cfdc107` |
| Both fresh PCKs | 19046812 each | `08ffdba571ee35bc24ee15ab9a92b2e7cd215deb06cd227ff55be6c98ab4f370` |
| Preserved Desktop override | 113 | `8f5fc180acedec304e626cb811982472a2e867a28ee3f50920ccb45b38a74654` |

Both actual rendered native startups report NVIDIA RTX4070 Laptop,
OpenGL3.3/NVIDIA581.29, **GL Compatibility**, at960x640. Validation used an exact
fresh TEMP copy, isolated data and bounded `--quit-after 240`, exit0; this proves
rendered startup, not a Validation GUI journey. Desktop used exact guarded TEMP
copies and ordinary native controls, with no bridge, teleport, developer fixture,
clock/weather preset, progress grant or supplied save. Native logs contain no
missing-resource, texture, script or warning diagnostic.

The first Desktop journey physically walked town/home/inn/forest/Tollworks,
entered all three existing interiors with E and returned from home and inn.
Town/forest brushwork, facades/roofs, trees, river/bridge, indoor timber/rugs/stone,
plinth/vessel, capsule party and HUD remained readable. Clear daylight naturally
advanced to cloudy17:36; this was not a natural full day or combat/recovery test.
Both party health values remained100. Current Tollworks content was inspected
without earning Maris's lead or manufacturing recovery/guardian progress.

Primary restart acceptance used a separate fresh isolated writer. Ordinary WASD/E
entered Mayor Vale home; observed Tab focus and Enter activated GUI Save. Settled
native pixels show **"Saved. Load returns to last arrival anchor."** and logs
show `P005 save: OK`. Writer **PID71804** quit through public F10, exact exit0.
Independent reader **PID26528** visibly started fresh town, then actual GUI Load
restored home with **"Loaded saved run at arrival anchor."** and matching log.
While still paused, a separately observed actual GUI re-save completed. Packed
production SaveCodec replay verifies **whole typed snapshot exact** and
**forecast exact**, schema8/content1, failures empty. Saved location is
`prototype-mayor-vale-home`, elapsed play25.457731121212376 seconds, day0,
progress0.042429551868686154 and seed2433035180; health100/100 and all durable
quest/social/item/routine/environment fields match. A subsequent short ordinary
resume captured the same painted home/party/HUD in the reader, then observed pause
and normal F10 quit, exact exit0. The exact oracle uses the earlier paused saves,
not the subsequently advancing art frame.

## Necessary packaging adaptation and preservation

Presets formerly bundled NPC authoring sprite sheets and test calibration assets.
They now exclude `assets/npcs/reference/*` and
`assets/models/npcs/npc_calibration*` alongside tests. All gameplay portraits,
rigs/actions, current rooms,25 routines, eight identities and JSON catalog bytes
remain unchanged. Both read-only pack audits resolve six painted GLBs and six
1024px atlases, presentation shaders/HUD and existing gameplay/content owners.
Private source/reference rasters, tests/bridge and evidence are absent, including
their imported runtime payloads.

The strict NPC loader previously loaded authoring sheet pixels at runtime merely
to validate retained source references. Exported `project.binary` packs now use
a compact runtime metadata manifest for those18 sheet dimensions. The manifest
retains original paths, source revision and source PNG SHA256 values, with exact
manifest pin `51d32379c24db0fbac0c91e1ff70af2d3cf424ac8946f4bca2a8a010ef0e13fa`.
Source runs still require actual source images and original dimension checks;
portraits and semantic/person/path ownership checks remain strict everywhere.
Exported probes reject changed dimensions, unknown sheets and cross-person paths
in both packs. No asset/material/UV, geometry, collider, station/door/actor ID,
gameplay service, save field or schema change was made.

Godot recovered16 missing UID sidecars from its existing cache during the first
escalated export. They are retained under their original script/shader paths to
make subsequent exports clean and stable; original script/shader bytes remain
unchanged. New reusable AD020 files are `tools/art_direction/{build_packages.py,
package_audit.gd,launch_native.ps1,native_guard_checks.ps1,save_oracle.gd,
reference_sheet_manifest.py,DELIVERY.md}` and
`game/content/npcs/reference_sheet_manifest.json`. Existing modifications are
export presets, NPC catalog loader, shared native path guards and their tests,
this workflow checklist/handoff. No original routine/fishing helper or other
workflow status was modified. Shared native routing adds only AD020 evidence
children and matching exact TEMP copies; every existing path/hash/PID/window/
unlocked-desktop/foreground/client/request-limit/input-release guard is retained.

Starting HEAD `c7667c6edc9f47bcf93d771a06feef26dd3d34ba` and empty index remain.
[Final audit](../evidence/AD020/preflight/final-audit.json) verifies4170 protected
files out of4176 starting files, zero unexpected changes, all1435 current
game/tools files matching validated SHA256
`8e9874d015fbba02be8d8a9f272cc90520d5f22e1af0397b70049b241ac5fc50`, all package/
archive/capture hashes and exact oracle. Unrelated direction/interiors and
user-authored AGENT_PROMPT/CONTRACT are byte-preserved.

## Verification and evidence

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7.
Installed Godot4.7.2 console and both actual preset template paths were verified.
Every runner/package/guidance/oracle process used AD020-local isolated APPDATA/
LOCALAPPDATA. Native writer/reader used fresh per-session AD020 restart data plus
the unchanged adjacent custom-user-directory override; ordinary user saves were
neither read nor written. Detached nav guidance is explicitly synthetic and never
places or mutates the native player. Reused historical audit modules are read-only
dependency methods in AD020 evidence, not completion claims for their workflows.

```powershell
./tools/art_direction/native_guard_checks.ps1
./tools/tests/native_input_checks.ps1 -EvidenceTask AD020
& 'C:/Program Files/Blender Foundation/Blender 5.2/5.2/python/bin/python.exe' tools/art_direction/reference_sheet_manifest.py
./tools/run_checks.ps1 -Task AD020 -Names application_smoke,npc_content_checks -TimeoutSeconds 180
& 'C:/Program Files/Blender Foundation/Blender 5.2/5.2/python/bin/python.exe' tools/art_direction/build_packages.py --promote
./tools/art_direction/launch_native.ps1 -Session ad020-20261011-1424 -Phase writer -Detached
./tools/art_direction/launch_native.ps1 -Session ad020-20261011-restart -Phase writer -Detached
./tools/art_direction/launch_native.ps1 -Session ad020-20261011-restart -Phase reader -Detached
```

The detached packed oracle used absolute script/input/output paths from the same
repository cwd, with APPDATA=`builds/art-direction/AD020/oracle/appdata` and
LOCALAPPDATA=`builds/art-direction/AD020/oracle/localappdata` resolved absolutely.
The following explicit argument vector reproduces that verification:

```text
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe
--headless
--main-pack D:/development/game-dev-blender/returning-fair-prototype/builds/windows/ReturningFair.pck
--script D:/development/game-dev-blender/returning-fair-prototype/tools/art_direction/save_oracle.gd
--
--oracle-writer=D:/development/game-dev-blender/returning-fair-prototype/docs/evidence/AD020/native-ad020-20261011-restart/writer/gui-save.json
--oracle-reader=D:/development/game-dev-blender/returning-fair-prototype/docs/evidence/AD020/native-ad020-20261011-restart/reader/gui-save-verified.json
--oracle-output=D:/development/game-dev-blender/returning-fair-prototype/docs/evidence/AD020/native-ad020-20261011-restart/save-oracle.json
```

- [Native guard result](../evidence/AD020/guards-c309627f4b5f447d94a48518773b58e7/results.json):7 synthetic exact-hash/task/reparse assertions pass. Shared dispatcher:751 assertions pass, fault-injected release/foreground/client/request refusals, no OS input in these tests; records in `../evidence/AD020/native-guards-315837a158fc44318498245fe1a931db/`.
- [Final source checks](../evidence/AD020/20261011-142323974-07c3e453/results.json):4/4 exit0, source.changed=false/error=null. NPC test432 assertions,78 malformed candidates; original source image/identity/publication guarantees retained. Earlier source run also4/4 pass.
- [Final packages](../evidence/AD020/packages-20261011-142239-03737612/results.json):10/10 exit0, unchanged production before/after. Two exports, current routine/fishing/storybook audit per pack, two outside-checkout headless startups. Separate actual rendered Validation [launch](../evidence/AD020/validation-rendered-startup/launch.json), [exit](../evidence/AD020/validation-rendered-startup/exit.json) PID33648/exit0, renderer/runtime logs in same directory.
- Native ordinary-input traces, owned launches/PIDs/windows/captures and exits: [art journey](../evidence/AD020/native-ad020-20261011-1424/writer/launch.json), [primary writer](../evidence/AD020/native-ad020-20261011-restart/writer/launch.json), [new reader](../evidence/AD020/native-ad020-20261011-restart/reader/launch.json). `tools/npc_migration/invoke_native.ps1` and `tools/routine_migration/walk_native.ps1` used these task paths through unchanged shared input interop. All request commands, timings and target identities are in their schema2 JSON records.
- [Packed exact oracle](../evidence/AD020/native-ad020-20261011-restart/save-oracle.json):exit0, typed_snapshot_exact=true, forecast_exact=true, failures empty. Actual copied writer `writer/gui-save.json` and verified reader `reader/gui-save-verified.json` are its inputs. The absolute argument vector and isolated data paths are recorded above; its PASS output remains in adjacent `save-oracle.log`.
- [Native provenance index](../evidence/testing-tools/native-review-20261011-144652-dd73d15d/index.json):271 successful bounded requests,49 actual native frames, zero failures/orphans/cleanup errors; all nine sheets inspected individually, critical full-size room/Save/Load/restored frames inspected. Review used bundled Python3.13 and cached Pillow12.3.0 via read-only PYTHONPATH/PYTHONDONTWRITEBYTECODE, no installation/network. Utility-only embedded-Python location message retained; review exit0 and all PNG hashes match.
- [Cleanup](../evidence/AD020/preflight/cleanup.json):all31 recorded owned engine/native/controller PIDs absent, three exact verified TEMP copies removed, no input held/live editor/Blender mutation/cleanup owed. Native PIDs53324/71804/26528 all normal F10 exit0. Packages, archives, isolated saves and evidence remain.

## Retained attempts and practical limits

The initial sandbox export timed out180s before import progress. Scoped escalation
resolved that restriction; initial guard junction Access denied was similarly
resolved. No automatic approval review rejected an action. UID-warning export,
initial packed missing-reference failure and JSON-float/typed-dimension comparison
failure are retained in earlier `packages-*` reports; failing owned audits were
stopped, corrected and clean exports rerun. An initial guidance command used a
relative external script path and failed; the corrected absolute-path guidance
passed for all four detached route specifications.

Two300ms post-Save capture/file checks were premature while validation/serialization
was active. The first writer eventually saved Tollworks and quit normally, but its
settled GUI success was not observed, so it is not the primary restart evidence.
Primary writer waited for actual visible Saved/file/log completion before quit.
Reader retained Load focus, so one Tab/Enter attempt opened Settings instead of
Save; it changed no setting and stayed paused. Back/Esc, observed contained Tab
focus and a newly completed actual re-save resolved it. Early filenames containing
"success" are preserved diagnostic labels, not accepted outcomes. The early
`reader/gui-save.json` is only a pre-resave copy and is not an oracle input.

Native screenshots prove the bounded ordinary journey on this machine, not full
routine/recovery/replay, night/rain Cartesian coverage, another hardware target,
installer signing or publication. AD018/AD019 retain integrated/performance evidence;
their statuses and historical limitations are unchanged. **All AD020 required
criteria have fresh evidence; no blocker or required unrun check remains.**

## Authorized commit follow-up

2026-10-11 UTC: user supplied the separate successful-task commit instruction
after review, including acceptance evidence. All31 reviewed task hashes,
1435 validated game/tools files,4170 protected original inputs, current packages,
previous package archives and49 capture hashes were reverified before the
documentation-only follow-up edits. Exact selected task/evidence paths, byte
hashes and expected Git blobs are in [commit review](../evidence/AD020/commit-review.json).
Post-commit identity/tree/path/blob verification and final working-tree status
are recorded locally in
`docs/evidence/AD020/authorized-commit-20261011/commit-audit.json`.

Scope includes31 task paths, final source/guard/package reports and retained
failed-run records, native launch/input/request/exit provenance,49 original
frames/nine sheets, the two actual primary GUI-save inputs and packed exact
oracle, preservation/cleanup evidence, checklist and handoff. Local executable/
PCK outputs, build/save archives, temporary scripts, synthetic guard binaries,
earlier duplicate passing runs, pre-resave reader copy and unrelated direction/
interiors/AGENT_PROMPT/CONTRACT remain excluded. All AD001-AD020 stay Done;
unfinished IDs:none; R016 remains user-stopped as-is. No push or new task.
