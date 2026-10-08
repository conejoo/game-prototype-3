# F010 fresh Windows/native acceptance

Status: Done, 2026-10-07, America/Vancouver. Selected exactly F010 from clean HEAD
`f643057f1f905e75fe947c4346fb54894ae5bfe0`. F009 prerequisite accepted; production
runtime/content/art/save/input/geography unchanged. Corrected outside-checkout
native pair, final audit and every acceptance criterion pass.

## Packages and prerequisites

Godot `4.7.2.stable.mono.official.ed1daf0bf`, installed console executable:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
Existing official standard x86_64 templates under ignored `builds/p014/templates`;
Compatibility renderer, schema6/content1, existing export presets unchanged. No
install, publication, commit, source refresh or new gameplay authority.

Repository-root bundled Python command: `tools/foraging_items/build_packages.py`.
Accepted raw run `docs/evidence/F010/packages-20261008-032953-90f9b5ad/results.json`.
Both export/audit/startup triplets PASS, exit0. Export-only missing .NET SDK10.0.9
diagnostic narrowly allowed; packed audit and runtime logs have no diagnostics.
Startup runs from `C:/Users/aldoc/AppData/Local/Temp`, with isolated APPDATA/
LOCALAPPDATA under fresh staging, no source `--path game`, actual arrival and
bounded `--quit-after 180`. Release ignores environment review flag as expected.

Packed audits load catalog, both item definitions/icons/mesh kits, four registry
records, fresh schema6 snapshot with empty bag/collected/placements, all four
environment GLB kits and pinned layout SHA256
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.
Release contains no tests; validation excludes checks/fixture directory/gallery,
retains intended review/input/render support. Neither pack contains authoring/source
assets. Audit `debug_build` describes the installed console host, not release exe.

| Local file | Bytes | SHA256 |
| --- | ---: | --- |
| builds/windows/ReturningFair.exe | 109268480 | d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562 |
| builds/windows/ReturningFair.pck | 5109864 | 6158e8df60c6e9d401325aa65e921b793a268bb3a537eecd6d63a5ca14c8cf8a |
| builds/windows-validation/ReturningFairValidation.exe | 103176704 | 51498b72b3a237f882ebd7d1787f06a4bc1eaf0572daab93837adcfd3cfdc107 |
| builds/windows-validation/ReturningFairValidation.pck | 5286736 | 276ae60015f3d0b986458b7693e648aca89e82a0c59b5a578badf7314e3aeb5c |
| builds/windows-validation/ReturningFairValidation.console.exe | 188928 | 5514c7645ee897a01f540d3cf22ede5badf92394521a08bfab66a54d7369e6e6 |

Previous directories, including release override, archived reversibly under
`builds/foraging-items-backpack/F010/20261008-032953-90f9b5ad/previous-packages`;
old hashes recorded in package results. Historical P014/M019/W010 records retained.
Promoted files match audited staging. Adjacent113-byte override unchanged, SHA256
`8f5fc180acedec304e626cb811982472a2e867a28ee3f50920ccb45b38a74654`.
Both exported exe hashes exactly match their installed standard release/debug
templates (`template-identity.json`); executable build kind is verified separately
from the debug audit host.

Fresh repository-root PowerShell command:

```powershell
./tools/run_checks.ps1 -Task F010 -Names inventory_checks,foraging_transaction_checks,foraging_save_checks,foraging_interaction_checks,backpack_ui_checks,world_item_placement_checks,application_smoke -TimeoutSeconds 150
./tools/tests/native_input_checks.ps1
```

Feature runner `20261008-033128476-26d025f5`: engine/parse + all seven suites PASS;
199/587/112/103/148/128 feature assertions and application smoke. Exit0, empty
runtime diagnostics, no timeout/source drift. Before/after496-file game/tools
digest `47b9da8d400cbdc1b94532adbb128dccf6c58fbd0ca277456c3863c1cf832b13`.
F010 tools refined afterward; production/feature/helper bytes unchanged. F009's
final affected regression/art/process evidence remains applicable; no game edits.
Native helper715 assertions and Win32 interop compilation PASS; guard evidence
`native-guards-04073ba63b4140cfa9c3366be468ad7b`. PowerShell tool syntax PASS.
Read-only source/reference audit PASS20 source/three reference/three geography
hashes/six negative controls; source tests not run. Normal saves/source untouched.
`source-reference-audit.json`, `f009-production-identity.json` and
`production-identity.json` retain current provenance: all448 game files match F009's
accepted final regression run, F010 checks and current tree. Tool Python syntax PASS.

## Native procedure and proof

Fresh corrected pair: `docs/evidence/F010/native-20261008-verified-cwd`.
Writer PID14748, original launcher session14807, normal paused F10 exit0.
Reader PID59448, original launcher session78411, normal paused F10 exit0.
`launch_native.ps1 -Session 20261008-verified-cwd -Phase writer|reader` uses one
verified temp cwd for both Start-Process and launch record. Separate APPDATA/
LOCALAPPDATA in `builds/foraging-items-backpack/F010/native-20261008-verified-cwd`;
adjacent override selects `ReturningFair-P014-ReleaseValidation/saves/returning-fair.json`.
Writer requires absent save, reader requires writer's ordinary GUI save. Launch
flags: resolution960x640, position40,40, verbose/log-file and read-only P003
movement trace. No bridge, fixture, grants, teleports, review flags or time skips.

Native requests delegate to existing guarded `tools/native_input.ps1`; PID/exe/
window/foreground/desktop/coordinates/time limits and cleanup guards unchanged.
Bounded25s walking batches use actual key-release traces, synthetic navigation
guidance and <=500ms physical holds. Guidance is not gameplay proof. Each next
batch starts from inspected pause; actual client captures establish world/modal/
pause timing. Default camera verified. Source/layout untouched.

Ordinary controls: WASD movement; E0.5s rod/E0.6s moonflower (release cancels,
fresh press retries); B or HUD Bag; mouse/Tab/Enter item selection; rod-only Drop;
nearby rod pointer drag with valid commit/invalid rollback; B/Esc/Close exits bag.
Rod HUD honestly says fishing unavailable; selected moonflower says no direct use.
J journal, mouse attack, Space dodge, E lamp/Maris/gate remain inherited controls.
Close modal then Esc → Save; new process Esc → Load; F10 quits while paused.

Writer40-final-save and new reader03-restored-save match exact whole-file SHA256
`f23b621e976c21b4c30648d0d9e77eff44b53ad7d121b6c877dc71b24a8c9464`.
GUI Load success followed by GUI Save establishes restored live facts, rather than
comparing unchanged disk. Exact schema6 snapshot retains flowers3/active flower,
all four collected origins and one generated world rod at
`[-5.553992748260498, 3.725290298461914e-09, 14.925992012023926]`, location/provenance/
origin identity, all actor/party/quest/effect/progression/relationship/location/
arrival/time/environment/light facts. Hero100/companion50, three Maris quest steps,
lamp dock-lamp-02 true. Transient input/hold/drag/modal state is not serialized.

Read-only external `save_oracle.gd` with installed console and exported pack,
cwd TEMP and separate oracle appdata: PASS, engine PID56124, exact typed whole-save
and reconstructed forecast (sunny, previous cloudy, period2, start655/end1089,
blend1, heavy-rain false). Raw `save-oracle.json`/log. This detached candidate replay
supplements native GUI restart proof; it never observes or mutates the native game.
Reader physically revisits all three collected flower approaches and tries fresh E;
no flower reappears or extra award occurs. It walks to the exact restored world rod,
holds E to recollect, opens B and selects the rod. Reader20-revisited-save has rod1,
flowers3, active rod, all four collected origins and no world placements. All prior
actor/party/quest/effect/progression/relationship/light/location/arrival facts remain
exact; weather seed unchanged, ordinary play advances elapsed time332.66365072707487
to461.07831463605 with corresponding day progress.

Final `audit_native.py docs/evidence/F010/native-20261008-verified-cwd --output-directory
docs/evidence/F010/native-20261008-verified-cwd/derived-final` PASS, exit0. Raw
`derived-final/native-audit.json` records105 native960x640 captures with SHA256,
request/PID/UTC provenance,530 successful writer requests and322 reader requests.
All nine contact sheets and key full-size feature/pause captures inspected; timing
labels distinguish world/modal/pause and explicitly correct17b. One retained ESC
focus guard stop is classified separately below. All executed requests release
owned keys/mouse with no cleanup errors. Both accepted runtime logs have empty
diagnostics; both retained original process handles record exit0 after paused F10.
`owned-process-check.json` confirms no owned native process remains, no cleanup owed.

| F010 acceptance criterion | Verified evidence and result |
| --- | --- |
| Fresh release/validation packages, content/assets/schema/exclusions and hashes | Both export/audit/startup triplets PASS; packed schema6/content1, four registry records, both item/icon/mesh kits and four environment kits; template/override/layout identity verified; table above records actual promoted hashes. |
| Standalone feature, source checkout not required | Both package startups and corrected native writer/reader use actual TEMP cwd, exported exe/pck and isolated appdata, with no project path or source resource dependency. Packed audits exclude authoring assets and release tests. |
| Ordinary gather/backpack/Drop/drag/recollect | Native four pickups, early release cancellation/fresh retry, B keyboard/pointer selection and modal world block, Drop, valid11b/12b drag commit, invalid-water13/14 exact rollback and physical E recollection. No bridge/fixture/mutation substituted. |
| Existing lamp/quest/travel/party usable | Native lamp02 switch, Maris lead/journal, physical bridge/gate crossing, committed Tollworks arrival, guardian clear with party, return to Alderwake; saved prior facts preserved through items and restart. |
| Exact native restart facts and origin revisits | Writer40 GUI Save/F10, different reader PID GUI Load/Save exact whole bytes; exported typed whole-save/forecast oracle PASS; ordinary all-three flower revisits and saved rod recollection preserve uniqueness/counts/prior facts. |
| Both packages clean startup/quit | Isolated headless package startup/quit exit0 with no diagnostics; accepted native writer/reader paused F10 exit0, no held input or owned processes left. |
| Controls, checklist/state/discovery and local delivery | Controls and reusable tools documented here and tools README; workflow/parent records updated, historical failures/releases retained, local unsigned packages only, no publication. |

F001-F010 Done; no eligible successor or remaining criterion. Completed exactly
F010 this invocation, then stopped. Raw evidence/build outputs remain ignored/local.
Final intended diff/Markdown links/status/current package hashes/Python syntax review
PASS (`docs/evidence/F010/final-review.json`); all ten checklist rows Done, game diff
empty. `git -c core.whitespace=cr-at-eol diff --check` passes; existing Windows
newline-conversion notices are informational, with no whitespace errors.

## Retained failures and limits

- `packages-20261008-032924-d63c24b4`: audit used incomplete GameSession.initialize
  signature; fixed before accepted fresh export/audit run. Failed output not promoted.
- First native pair `native-20261008-0330`, PIDs11436/16364, completes all four
  pickups/rod/lamps/quest/travel/combat/exact GUI restart/revisits, both exit0. Its
  launcher falsely recorded TEMP while actually using builds/windows cwd.
  Original raw records retained with `launch-correction.json`; corrected derived
  audit fails exactly both outside-checkout cwd criteria. It cannot satisfy delivery.
  Nine contact sheets/key full-size images inspected; actual collected facts exact.
- That supplemental pair retains no-input sandbox refusal864c0538..., river/rail
  driver stalls325b4b88/92a65375 and bridge-centre physical recovery8865230f.
  No water/rail collision, tolerances or native guards weakened. User interruption
  left unpaused backpack open; inherited modal clock advanced. Save timers capture it.
  Initial travel screenshots37/38 are pending travel, not arrival;38b/38c establish
  actual Tollworks arrival. Screenshot31 name says lamp-off; actual GUI save proves on.
- Corrected writer retains pointer miss11/12 (no placement change), followed by
  successful drag11b/12b. Focus guard request35452ad5... stopped during initial ESC
  toggle, released all keys/mouse without cleanup errors. It is a guard stop, not
  successful gameplay. Observation17b filename incorrectly says paused; image is
  active world.17c reestablishes inspected pause before retry. All raw attempts retained.
- Initial synthetic route argument/path and unreachable guessed lamp failures retained;
  correct geometry guidance uses actual runtime lamp/Maris and bridge centre feet.
  One sandbox guidance engine reported root certificate store failure; its navigation
  output is guidance only, not an accepted runtime check or native game observation.

Tools: [local acceptance tools](../../tools/foraging_items/README.md). Raw evidence
and packages remain ignored/local. No successor, automatic agent, install or publication.
