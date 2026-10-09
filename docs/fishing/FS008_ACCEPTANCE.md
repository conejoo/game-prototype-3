# FS008 acceptance - fresh Windows delivery and native fishing

Status: **Done**, 2026-10-09 UTC. Exactly FS008 executed. Execution entry/final HEAD:
`0907b2a69e5fdca6bbe3da48a1da6d107148c71d`; entry Git clean. No commit or push
during acceptance. The separately authorized local commit follow-up is recorded in
CURRENT_STATE; no push or successor.
G009 Done, its current guarded native capability and canonical package ownership,
FS007 acceptance/current capability, installed console and 4.7.2 export templates
were verified before selection. No remaining fishing IDs or successor.

## Delivered scope

Fresh locally promoted [Windows Desktop](../../builds/windows/ReturningFair.exe)
and [Windows Validation](../../builds/windows-validation/ReturningFairValidation.exe),
with exact prior packages/override archived under
`builds/fishing/FS008/20261009-054725-1f89786c/previous-packages/`.
Both actual export presets now exclude all `tests/*`; Validation previously shipped
other test scripts through its partial exclusions. No runtime test/audit dependency.

Fourteen files: this acceptance, CHECKLIST/CURRENT_STATE, `game/export_presets.cfg`,
and ten `tools/fishing/` files: DELIVERY.md, build_packages.py, package_audit.gd,
launch_native.ps1, reel_native.ps1, hud_pixels.ps1, hud_pixel_checks.ps1,
bite_pixels.json, audit_native.py, native_guard_checks.ps1. The existing guard retains
its default FS006 route and adds explicit FS008 evidence routing. Existing native,
navigation, GUI save and typed-oracle helpers are reused without edits.

Gameplay, challenge luck/time/rules, fish rewards, schema7/content1, pinned layout,
source game, instructions, social workflow and normal saves remain unchanged.
Only export exclusions change under `game/`. Local artifacts/evidence remain ignored
under established testing policy; no package publication or deployment.

## Every acceptance criterion

| Criterion | Accepted evidence |
| --- | --- |
| Final-source Desktop and Validation rebuild | Actual `--export-release "Windows Desktop"` and `--export-debug "Windows Validation"`; accepted eight-case package run below. Production bytes unchanged through export and final review. |
| Packed fish definitions, icons, areas, live item/save state and exclusions | External packed fishing audit: 500 assertions each preset; exact three fish metadata/caps/icons, rod capability, three adapted area profiles, pinned layout/runtime modules, fresh empty bag/idle real root, schema7/content1 and transient-save exclusion. Detached fish99/selection/restore checks are synthetic. Inherited current social audit also passes each preset. All tests/tools/docs/reference-manifest/Flutter/blend exclusions checked. |
| Outside-checkout exe+pck | Both standalone startup cases use TEMP cwd. Actual native release is an exact-hash direct TEMP copy, without `--path`, source checkout, bridge or setup flags. |
| Fresh rod/select/cast/reel and unforced catch in real bag | Native writer PID50204: physical WASD/E rod pickup, B/pointer selection, physical dock arrival, F/world click and rendered-HUD-reactive E. Tenth bounded cast lands one ordinary Bluegill; real bag shows Bluegill1/99 and rod1/1. |
| Cancel/recast | Actual waiting HUD, F cancellation, immediate new waiting cast, F cancellation and unchanged real bag captured after landing. |
| GUI Save/quit/new process GUI Load/revisit | Actual paused GUI Save, normal F10 exit0, independent fresh reader PID27060, paused GUI Load/Save, exact typed whole-snapshot/forecast oracle before resuming, physical rod/dock revisit and GUI Save. Selected Bluegill1 persists; no resumed attempt or duplicate catch. |
| Distinct PIDs, package identity, logs and normal exits | Both native launch/exit records, all guarded input identities and cleanup, canonical/archive hashes and clean native runtime logs verified by 375-assertion audit. Both exit0; TEMP copy removed after exact identity and process checks. |
| Bounded rendered timing and inspected pauses | Classifier reads actual native PNG BITE glyph/meter only; driver <=40 wall seconds/100 iterations, guarded holds/waits release every request. Final landing trace takes 8.1978105s. Each terminal/paused checkpoint inspected before another batch; all120 captures/20 contact sheets reviewed. |
| All-three-species correctness with honest native scope | Current challenge8,786/integration59 assertions and prerequisite FS007 prove all species. Only Bluegill landed natively; no native trout/carp claim. |

## Packages and final checks

Run from repository root in PowerShell7 using installed Godot4.7.2 console and bundled
Python `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Build command: `python tools/fishing/build_packages.py --promote` using that executable.
[Package results](../evidence/FS008/packages-20261009-054725-1f89786c/results.json):
all eight export/social-audit/fishing-audit/outside-startup cases PASS, promotion true.
The builder's `native_acceptance=false` field deliberately describes export-only
scope; actual native acceptance is the separate evidence below.

| Artifact | SHA256 |
| --- | --- |
| Desktop exe | `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562` |
| Validation exe | `51498b72b3a237f882ebd7d1787f06a4bc1eaf0572daab93837adcfd3cfdc107` |
| Both final PCKs | `895f4128910028f1f4dd2cdd6f1852b103e31e0ae2addadda33344a34a2cc1cd` |
| Preserved native release override | `8f5fc180acedec304e626cb811982472a2e867a28ee3f50920ccb45b38a74654` |

Final regression command:

```powershell
./tools/run_checks.ps1 -Task FS008 -Names fishing_content_checks,fishing_activity_checks,fishing_challenge_checks,fishing_integration_checks,fishing_ui_checks,foraging_save_checks,social_save_checks,backpack_ui_checks,application_smoke -ProcessScripts fishing_process_checks -ParseScripts tests/environment_review,tests/live_playtest_bridge -TimeoutSeconds 180
```

[Final runner](../evidence/FS008/20261009-060809861-e9b5865a/results.json): all13
engine/parse/nine check/process-writer/process-reader cases PASS. Content255,
activity208, challenge8,786, integration59, UI75, foraging-save111, social-save844,
bag148, process-writer23/reader22 assertions. No runtime/parse diagnostics/timeouts;
`source.changed=false`, `source.error=null`. All1040 game/tool files unchanged,
digest `870f66be32acd834ef8f7a377d69698bd39c01ee3a2ceea74e7d2322d3d02b89`.
Final current bytes match that manifest; game bytes match accepted export manifest.
Live reference audit before/after:143 assertions PASS; layout SHA256
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.

Pure checks: fishing native guards13 PASS in
`docs/evidence/FS008/native-guards-4ad3e62af1d24e34961f0a8f72e9fb9f/`;
existing dispatcher guards739 PASS using its existing FS006 route in
`docs/evidence/FS006/native-guards-cf7c20be10e44945affc7df2a5ccdc69/`;
final pixel classifier10 PASS in
`docs/evidence/FS008/pixel-checks-aa8201d03f2c44588e342642a95e7bfc/`.
These are synthetic guard/classifier proofs, not native gameplay. Python syntax and
all five fishing PowerShell parsers clean.

## Ordinary native journey and exact restart

Evidence root: `docs/evidence/FS008/native-fs008-20261009-0548/`.
Commands: `launch_native.ps1 -Session fs008-20261009-0548 -Phase writer|reader`,
existing physical `walk_native.ps1`/GUI `save_native.ps1`/guarded `invoke_native.ps1`,
and `reel_native.ps1` at inspected dock with current cast coordinate505,384.
Launch records contain full argument/env/path/hash identity. Pair save group:
`builds/fishing/FS008/native-fs008-20261009-0548/restart/{appdata,localappdata}`;
other package, runner and packed-oracle checks use separate groups.

The driver reads rendered automatic-time BITE/fight state, sends fresh guarded E
and compensates measured request latency with bounded holds. No memory/phase-log
control, fixed pose, forced RNG, reward injection, clock change or fishing tuning.
Ten cast outcomes: seven No Bite, one exhausted Bluegill fight, one missed hook,
then one landed Bluegill. Trace `hooked` means hook input requested, not accepted;
actual rendered fight/landing and real bag/save prove the successful catch.
Waiting/terminal/canceled pause frames are distinguished from live BITE/fight frames.

Useful captures: [live fight](../evidence/FS008/native-fs008-20261009-0548/writer/reel-65ad519dc2f44b06bd7cfba944cd0f8b-006.png),
[landed](../evidence/FS008/native-fs008-20261009-0548/writer/reel-65ad519dc2f44b06bd7cfba944cd0f8b-terminal.png),
[cancel/recast bag](../evidence/FS008/native-fs008-20261009-0548/writer/bluegill-bag-after-cancel-recast.png),
[reader revisit bag](../evidence/FS008/native-fs008-20261009-0548/reader/reader-revisited-bluegill-bag.png).

Writer GUI save and reader GUI Load/Save bytes identical, SHA256
`139a2f564f17a905cff504cbba7e88d4b74b5e9418aadd9060d6a05881d81685`.
Existing external packed `tools/foraging_items/save_oracle.gd`, PID17972,
reports typed_snapshot_exact/forecast_exact true, failures[] in
[packed oracle](../evidence/FS008/native-fs008-20261009-0548/packed-save-oracle.json).
Reader resumed elapsed time from201.157751545363 to228.59797187867173; every saved
field except intended elapsed/environment progression remains exact, including
inventory/selection/rod provenance, health/party/quest/social/placement facts.
Revisited save SHA256
`47f231d10a297f999bc5a199d2206ae85c102ae63c03021a5d8c2a315aa32ddb`.

`python tools/fishing/audit_native.py --run docs/evidence/FS008/native-fs008-20261009-0548 --exclude-focus-request 51e6d9fdaf334722a0fc89dfe0492f1b`:
[375 assertions PASS](../evidence/FS008/native-fs008-20261009-0548/native-audit-435acc98ace5492a932a5ce86ee1b154.json).
[Visual review](../evidence/FS008/native-fs008-20261009-0548/visual-review.json):
all120 actual native PNGs/20 individually inspected sheets, plus critical full-size
frames. [Generic provenance review](../evidence/testing-tools/native-review-20261009-060947-95f6961c/index.json)
retains status failed solely for the explicit foreground request described below;
all120 captures have valid request/capture/hash provenance, no orphan or cleanup error.

## Retained failures, preservation and stop

Initial sandbox engine launch denied; scoped escalation approved, no automatic
approval rejection. Package runs `054456-c0bd2ca6` (external GameRoot type) and
`054643-1fa8df79` (overbroad reference-art exclusion) retained, corrected before
accepted export; neither promoted. Shared guard command first rejected unsupported
FS008 label, then reran through supported FS006 label. First rod E hold too short;
actual bag correctly showed empty before successful ordinary pickup.

One native request `51e6d9fdaf334722a0fc89dfe0492f1b` refused foreground focus on
initial rod journey, with no executed steps/held input/cleanup error. Failure kept,
never accepted. Inspected pause then one successful physical retry. Generic reviewer
correctly retains its failure; explicit native audit excludes only that exact request.
Early No Bite/exhausted/missed-hook casts remain recorded rather than relabeled.
Known editor-only missing .NET SDK10.0.9 advisory retained; runtime logs clean.
Initial read-only external route command had relative-path failure before input;
absolute retry worked. A cleanup set-order check refused before deletion; corrected
exact three-file identity check removed only owned TEMP files and empty directory.

[Final review](../evidence/FS008/final-review.json) verifies accepted manifests,
archives/canonical packages/override and unchanged HEAD; [cleanup](../evidence/FS008/native-fs008-20261009-0548/cleanup.json)
records normal native exits0, exact temporary copy removal and no cleanup owed.
No unowned processes stopped. Native/fixture/runner processes exited; no editor or
held input left. Existing source/instructions/normal saves and unrelated work preserved.
Blockers: none. Remaining unfinished IDs: none. Every item FS001-FS008 complete: yes.
Stop; await separate explicit commit instruction.
