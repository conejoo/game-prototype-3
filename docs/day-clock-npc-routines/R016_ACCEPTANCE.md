# R016 fresh Windows packages and native acceptance

## Final user-requested stop and as-is commit (2026-10-10 UTC)

User instruction: "it is enough checking, could you tell your Ai agent to finish
an commit as it is". This supersedes the earlier implementation-turn stop before
commit. Testing and implementation stopped immediately; only owned cleanup,
truthful acceptance/handoff documentation, scoped Git byte/scope checks and the
authorized local commit follow. No push, successor or resumed native interaction.

R001-R015 remain Done. R016 remains **Blocked / incomplete** because its full
native acceptance was not verified before the user requested stopping. It is the
only unfinished ID; every checklist item through R016 complete: **no**. Committing
the existing work does not accept the remaining criteria or create a Done record.

| R016 criterion | Actual outcome at stop |
| --- | --- |
| Fresh Desktop/Validation, exact package inventory/exclusions, startup outside checkout | PASS: eight package cases, exact 25 routines/two rooms/rig actions/social/schema8/content1, preserved prior archives/override. |
| Focused engine/parse/smoke/content, synthetic native guards, immutable reference checks | PASS: focused 4/4 (848 assertions/228 rejection fixtures), guards7, dispatcher745, reference1626. These do not prove native gameplay. |
| Native ordinary town/home/inn paths and physical returns | PASS in retained partial sessions; latest D completed both home and inn returns with party2. |
| Natural solo/group transition and authored routine behavior | PASS partial observations: B Helena archive action/readable speech/shelf walk and solo boundary; C natural evening solo-to-family-group transition. No new full-day/branch-matrix claim. |
| Native talk/gather/gift | PASS: earned Moonflower; Helena ordinary choices/facts/preference, flower1->0 and affinity2; Della helpful intro/remembered conversation. |
| Native Maris recovery | PARTIAL: D earned Maris lead and one Journal preparation upgrade (Deliberate Strike25->40). Bridge crossings, Tollworks combat/vessel/fitting/reconnection/specialist recovery UNRUN. |
| Actual native GUI Save | PASS three D intermediate checkpoints (flower, gift, lead); final recovered Save UNRUN. |
| Native writer normal quit | PASS latest D stdout "P001: Quit requested while paused." at456.99s, writer42568 exit0 at2026-10-10T04:04:10.9699106Z. Earlier A forced exit and B/C unobserved terminations remain separate failures/limitations. |
| New-PID GUI Load, exact typed whole durable/primary+backup/forecast oracle, physical remembered restart revisit | UNRUN. save_oracle.gd syntax-only check passed earlier; no executed restart oracle. |
| Native input/capture provenance and visual review | PARTIAL: critical D checkpoints inspected. Retained B focus/input failure and obscured pixels, C lost writer, D transient Attach refusal and final walk absent PID remain failures; no final all-capture provenance/review acceptance. |
| Owned process/input/TEMP cleanup | COMPLETE at stop: writer42568/controller60084 absent; previous failed requests released input. Last walk could not attach absent PID and sent no input. Exact B/C/D TEMP copies removed only after containment/reparse/live-process checks; A already removed. Evidence/isolated saves and unrelated work retained. |

Latest session: r016-20261010-d, writer42568/controller60084. The detached option
starts the same guarded launcher using a hidden WMI process; it supplies no
gameplay/state/save setup and preserves all input guards. Startup worked, but no
controlled executor-teardown survival test was performed. The paused writer
quit normally before the second east-bridge batch; no bridge/recovery acceptance
comes from that failed absent-PID request or its nonexistent capture filename.

Actual GUI save SHA256s, copied from the isolated native session:
flower fd64ac83bbec9aefa6c840d8e0644534993bdb8033aa84129548732f55f224b2;
gift 799c2767fb5b100b5402adaaa99d5d0fb81a81c8d8df2ba71a49241aa379ac7d;
lead 46608fb2d5aaeaa4bce1f084f055ef22e8c5bc6c0b5b6863e133cba832e6d047.
These establish intermediate Save evidence, not exact restart/backup acceptance.

Evidence: ../evidence/R016/native-r016-20261010-{b,c,d}/writer/ (requests,
actual captures/logs/checkpoints); D writer/exit.json; as-is-stop-cleanup.json;
resumed-final-audit.json and earlier package/focused/reference reports. Final
local commit hash/tree/status and exact-byte scope are recorded separately in
../evidence/R016/as-is-commit-audit.json after commit. Raw evidence/builds remain
under their existing ignore policy. README/architecture remain unchanged because
native delivery is incomplete. Unrelated docs/interiors-map-migration/ is excluded.

R014 user-approved4ms ceiling, original2ms misses, combined-slice/synthetic
measurement limitations and deferred threading remain intact. R015 still proves
Ivo movement/waits/conversation and Edric/Helena authored actions/speech under the
approved correction. No source/content/geometry/runtime changes were made here.

Commit portability: exact staged-byte review found normalization of six new
files. Narrow root/nearer attribute exceptions and immutable adaptation history
preserve reviewed bytes. Final authorized scope is19 paths (17 task files plus
two attribute files); unrelated interior documentation remains excluded.

Workflow stops after this authorized as-is commit. No further task or testing is
authorized by this handoff. Earlier continuation/no-commit statements below are
historical snapshots superseded by this final user instruction.

## Historical unlocked retry B: partial native, visibility blocker

## Scope and preserved baseline

Baseline HEAD `4a2afda40c68f1bfc37ac3af06ebcad38ad313ae`, clean worktree/empty
index; read-only source `60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean.
Workspace AGENTS, workflow prompt/checklist/contract, current architecture,
installed and versioned gameplay testing guidance, save/journey/interaction/native
acceptance and current native guard/build patterns were inspected. No nested
AGENTS or workspace `.agents` existed. Both supplied Godot paths exist.

Intended paths: this document, CHECKLIST.md, CURRENT_STATE.md,
game/export_presets.cfg, tools/testing_paths.ps1,
tools/tests/native_input_checks.ps1, tools/routine_migration/adaptations.json,
tools/routine_migration/reference_checks.py, and new routine_migration
build_packages.py/package_audit.gd/launch_native.ps1/native_guard_checks.ps1/
DELIVERY.md, plus the repository testing skill's references/native-commands.md.
README and architecture are unchanged because native delivery is unfinished.

Both existing presets now include `content/routines/*.json` in addition to NPC
JSON. Runtime, authored content, geography, rigs, source pins, schema8/content1,
normal saves and all existing owners are unchanged. Exact native evidence/TEMP
path support adds R016 only; PID, hashes, reparse, desktop, foreground, client and
input cleanup guards remain intact. Original adaptation before-hashes/reasons
remain; four new baseline adaptations document the existing-file changes.
R014's user-approved 4 ms ceiling, original 2 ms misses, combined-slice/synthetic
measurement limits and deferred threading are preserved. R015's approved Ivo
movement/waits/conversation and Edric/Helena action/speech correction is unchanged.

## Accepted package and focused evidence

Repository cwd, bundled Python3.12.14, PowerShell7, explicit installed
Godot4.7.2 Mono console. Commands:

```powershell
./tools/routine_migration/native_guard_checks.ps1
./tools/tests/native_input_checks.ps1 -EvidenceTask R016
python tools/routine_migration/build_packages.py --promote
./tools/run_checks.ps1 -Task R016 -Names application_smoke,routine_content_checks -TimeoutSeconds 150
python tools/routine_migration/reference_checks.py --source D:/development/game-prototype-2 --self-test --report docs/evidence/R016/reference-preflight.json
```

`packages-20261010-012353-bfa9a577/results.json`: PASS, eight cases, all exits0,
no forbidden diagnostics, stable production bytes. Windows Validation and Desktop
each exported, passed the external routine and fishing audits, then started from
TEMP cwd without checkout arguments. Separate app-data groups are recorded per
case. Only the existing exact editor-import .NET SDK diagnostic is allowed during
exports; no runtime diagnostics are exempted and no SDK was installed.

Both packs contain all 25 immutable routines, both room definitions/scenes,
eight rigs and 48 portraits, production Edric/Helena actions, current public
social69/53/22/eight gift rules, schema8/content1 and the single live root director.
External audits reject bundled tests/bridge/private/Flutter/editable art/source
dependencies. Inventory and exact packaged routine-byte checks are recorded in
the final audit. No ordinary route or rendering proof follows from these checks.

Prior release and validation folders are copied/hash-verified under
`builds/day-clock-npc-routines/R016/20261010-012353-bfa9a577/previous-packages/`.
Promotion occurred only after all eight cases passed. Original release override
hash `8f5fc180acedec304e626cb811982472a2e867a28ee3f50920ccb45b38a74654`
is unchanged; validation has no override. Fresh release:
`builds/windows/ReturningFair.exe`; validation:
`builds/windows-validation/ReturningFairValidation.exe`.

| Artifact | SHA256 |
| --- | --- |
| Release EXE | d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562 |
| Validation EXE | 51498b72b3a237f882ebd7d1787f06a4bc1eaf0572daab93837adcfd3cfdc107 |
| Both PCKs | c9944be0d3c9b3b17702ce2977e3bfb632c03373d8a945b4c39c0c1eb4b930c9 |

Standalone synthetic guards PASS7; dispatcher PASS745 including R016 path
acceptance/refusal and exact production interop compilation without OS input.
Focused runner `20261010-012551316-109bdf2b/results.json` PASS4/4: engine, parse,
application smoke and routine content848 assertions/228 rejection fixtures.
All exits0, zero diagnostics and unchanged1309-file game/tools fingerprint
`8b4d3b67e521016a137f2a8d7e8c3a3a3670c6418e6b169a05fab5015fdf16fd`.
Named slots/primary-backup/app-data groups are isolated beneath R016 builds/testing.
Reference preflight PASS1626/88 pins/85 exact adaptations/ten drift refusals;
final reference PASS1626/88 pins/86 adaptations/ten refusals after the maintained
R016 native guidance was appended.

## Native blocker and retained failures

`launch_native.ps1 -Session r016-20261010-a -Phase writer` launched PID25216
from an exact TEMP release copy with isolated restart APPDATA/LOCALAPPDATA and
the unchanged validation override. Actual release startup reached Alderwake with
two party members, without a bridge or setup command.

The first guarded capture/pause request failed before every step:

> Desktop locked or not Default; no input sent.

Report `native-r016-20261010-a/writer/2e89691ddee3495f86de09f59a4bef9a.json`
records `ok=false`, zero executed steps, no cleanup errors, no unreleased keys
and `mouse_unreleased=false`. No PNG exists; no visual inspection is claimed.
This is a desktop availability failure, not an automatic approval rejection.
All later native inputs were stopped; no bypass or synthetic replacement used.

Owned PID25216 was identity-checked and forcibly cleaned up because normal F10
input was unavailable. `forced-cleanup.json` retains this reason; `exit.json`
records exit-1, which is **not** accepted as a normal native exit. The exact TEMP
copy is removed only after process exit and path verification. No held input,
owned game window, editor change or cleanup is owed; unrelated processes remain.

The first dispatcher run retained a failure at `entrypoint accepted foreign
standalone directory`: the actual refusal was correct, but the test expected the
old N018/G009/FS008 message. The expected message and R016 positive/negative path
cases were updated; the fresh rerun passes745. Original failed evidence directory
`native-guards-137c27255ecf46d3a71ea1f0cf921e28` remains and its diagnostic is retained.

Final scope audit initially stripped leading Git porcelain status whitespace,
misparsing the first filename. Exact Git output shows all14 intended paths only;
`final-audit-scope-parser-failure.json` retains the bookkeeping failure, and the
corrected final audit verifies the exact scope without changing implementation.

## Unfinished acceptance and exact continuation

Unverified: native ordinary town/home/inn routes and returns; natural solo/group
transition; talk/gift; Maris recovery; actual GUI Save/normal quit/new-PID GUI Load;
exact whole typed durable/forecast oracle, primary/backup evidence, physical
remembered revisits, inspected native captures and normal process exits.
R015's accepted full-day/deterministic tests retain their original meaning and
do not satisfy these native criteria.

Unlock the Windows Default desktop, then resume exactly R016. Reverify current
source and package hashes and use a fresh writer session such as
`launch_native.ps1 -Session <new-name> -Phase writer`; do not reuse the failed
writer or assume a save exists. Complete native criteria using existing guarded
public input and inspected pause checkpoints, followed by its reader and exact
packed oracle. Retain every failure. Only then mark Done, update delivered
README/architecture if needed, and append a completion record. No successor exists.

Final review restored the original mixed line endings on unchanged historical
lines, removing incidental whole-file churn from Windows text writes. Only
intended semantic changes remain. Exact adaptation hashes were refreshed and
the static preservation gate rerun; runtime/game package bytes stayed identical.

Final source/package/status/link/scope/cleanup evidence:
`docs/evidence/R016/final-audit.json`. Default sandbox shell failed during setup;
scoped automatically reviewed commands succeeded, with no approval rejection.
