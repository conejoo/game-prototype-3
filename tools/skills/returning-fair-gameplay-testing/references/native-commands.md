# Native release commands

Project root: `D:/development/game-dev-blender/returning-fair-prototype`.
Inspect `tools/native_input.ps1` before relying on its current guards/schema.
It is the reusable implementation; do not duplicate its Windows interop or rewrite
input helpers each session. The P014 driver is historical, with fixed paths and
coordinates: never reuse its old PID or overwrite its captures.

## Current helper contract

```powershell
./tools/native_input.ps1 -TargetProcessId $gameProcessId `
  -CommandFile $requestPath -OutputDirectory $runEvidence
```

Only `<project>/builds/windows/ReturningFair.exe` is currently allowed. It must
match the PID's actual executable, and exactly one release-owned game window must
exist. Unlock/Default desktop and foreground checks precede input; loss of focus
stops waits and drag motion. Only successfully acquired keys/buttons are released
in finally, even after focus loss. Cleanup attempts every owned input and retries
failed releases once at the request boundary. Failed releases fail the request and
remain visible in its report; OS rejection or forced termination can prevent release.
Already-held keys/left button are refused without releasing human-owned input.
Do not mix human input with a timed batch.

Current output guard accepts only run subdirectories of `docs/evidence/P014` or
`docs/evidence/W001` through `W010`, or `F001` through `F010`. Task roots, sibling prefixes, path traversal
outside those roots and existing junction/symlink ancestors are rejected. Use a
fresh task/run directory; do not overwrite historical captures. Pure guard tests
live in `tools/tests/testing_tools_checks.ps1` and `tools/tests/native_input_checks.ps1`.
The latter also checks bounded dispatch and injected cleanup failures without OS input.
Executable/PID/window/desktop/focus
and finally input-release checks remain mandatory.
Do not remove target/focus/path checks or silently substitute an old release for
current project source. Verify or rebuild the intended executable before testing it.

Request JSON has only `steps`: an array of 1-32 operations. Summed requested
hold/wait/drag durations plus fixed50ms click/quit waits must be <=30000ms.
Individual hold/wait/drag durations are integer16-5000ms; captures/startup/input
overhead add real time. Reject unknown/missing fields, numeric strings, fractional
numbers, booleans, duplicate keys/labels and out-of-range coordinates before input.
All request coordinates are checked against the actual client before acquiring any
input, then checked again during motion. Coordinates are integer0-32767 and must
lie within the current client; they are not desktop coordinates.

| Operation | Fields |
| --- | --- |
| hold | keys array, duration_ms; keys W/A/S/D/E/J/B/SPACE/ESC/R/F10/TAB/ENTER, up to4 |
| wait | duration_ms; native foreground guard remains active |
| pointer | x, y in actual client pixels |
| click | x, y; normal left-button press/release |
| drag | from_x, from_y, to_x, to_y, duration_ms; atomic left press, straight interpolated client motion, release |
| capture | label using1-64 letters/digits/underscore/hyphen; saves PNG |
| quit | final operation only; normal F10 |

Capture labels must be unique within a request and cannot overwrite an existing PNG.
Exclusive file creation also prevents overwrites during execution.

Drag settles the initial press and final preview while holding the button. Integer
motion waits sum exactly to duration_ms; actual wall time can be longer. There is
no mouse_down/mouse_up command or held state between requests. A drag releases
before the next step, including a capture. To inspect an in-progress preview use
the rendered interaction helper; a native post-drag capture proves only the observed
post-release state. Input delivery does not prove a valid placement transaction.

Every launched request creates exclusive GUID.json (schema2) with success/error,
exact steps including the failed step, zero-based failed_step, completed UTC
timestamps, requested_duration_ms and actual elapsed milliseconds. cleanup_errors,
unreleased_keys and mouse_unreleased report cleanup failures explicitly. A preflight
failure before launch throws without sending input; a client-bound failure after
Attach produces a report with no executed steps. Inspect emitted PNG files with
view_image. Output success means input/capture execution, not gameplay acceptance.

## Start isolated release and keep exit evidence

Check exe+pck and adjacent override.cfg before launch. Current override sets
custom user directory `ReturningFair-P014-ReleaseValidation`; do not replace an
existing override or save silently. Use a fresh run ID below. Example launch uses
known960x640 client, but action coordinates still require fresh inspection.

```powershell
$projectRoot = 'D:/development/game-dev-blender/returning-fair-prototype'
$runId = [Guid]::NewGuid().ToString('N')
$runEvidence = Join-Path $projectRoot ('docs/evidence/P014/gameplay-' + $runId)
New-Item -ItemType Directory -Path $runEvidence | Out-Null
$releasePath = Join-Path $projectRoot 'builds/windows/ReturningFair.exe'
$gameProcess = Start-Process -FilePath $releasePath `
  -WorkingDirectory (Split-Path $releasePath -Parent) `
  -ArgumentList @('--resolution','960x640','--position','40,40',
                  '--log-file',(Join-Path $runEvidence 'release.log')) `
  -WindowStyle Hidden -PassThru
$gameProcess.Id | Set-Content (Join-Path $runEvidence 'pid.txt')
# Preserve this original process object in a running shell session. The helper
# restores its game window before capture. Other calls send the bounded inputs.
$gameProcess.WaitForExit()
"release exit=$($gameProcess.ExitCode)" | Set-Content (Join-Path $runEvidence 'exit.txt')
```

Yield the waiting shell as a tool session; do not block user-facing communication
for the whole game run. Recover PID/run paths from the new files, not this example.
After normal F10, collect the launch session's final exit. No --path/editor/debug
bridge arguments are used. Capture fresh world and establish/verify pause before
hostile play. On first focus/window failure, inspect error and current process
state; do not send inputs to another window or force repeated unknown actions.

## Bounded gameplay block from an observed pause

Only use the example below if the current screenshot confirms paused mode and
Resume has keyboard focus. Otherwise first establish that observed focus. The
actual gameplay actions depend on the current test; this is a movement example,
not a combat assertion or a fixed route.

```powershell
$steps = @(
  @{op='hold';keys=@('ENTER');duration_ms=70}, # observed Resume
  @{op='hold';keys=@('W');duration_ms=250},
  @{op='hold';keys=@('ESC');duration_ms=70},
  @{op='wait';duration_ms=150},
  @{op='capture';label='movement-paused'}
)
$requestPath = Join-Path $runEvidence 'request.json'
@{steps=$steps} | ConvertTo-Json -Depth 8 |
  Set-Content -LiteralPath $requestPath -Encoding utf8NoBOM
& "$projectRoot/tools/native_input.ps1" -TargetProcessId $gameProcessId `
  -CommandFile $requestPath -OutputDirectory $runEvidence
```

Inspect the resulting pause overlay. If absent, the test is not safely frozen.
Settle150ms worked previously but is not a guarantee of frame readiness or travel
completion. To prove freezing, compare timer/state in two paused captures with a
measured interval; never infer it from the requested key duration. To view world
without an overlay, capture just before pausing in the same short batch and label
its timing; companion/enemy actions can still occur before pause takes effect.

## N018 standalone package guard

N018 may pass `-StandaloneDirectory` to the shared native helper and foraging
walk helper. Only a direct temporary-directory child named
`ReturningFair-N018-<bounded session name>` is accepted, with N018 run-child
evidence, no directory/file reparse points, and exact EXE/PCK/override SHA256
matches to the current canonical `builds/windows` release. The owned PID must
execute that exact copy. Arbitrary copies and other task evidence are rejected;
default canonical-path guarding remains unchanged.

Use the N018 helpers described in `tools/npc_migration/DELIVERY.md` for fresh
isolated launch, observed source-chat selection, GUI Save/Load and normal exit.
Detached navigation and save decoding are guidance/oracle evidence only. Never
count them as live movement or dialogue. Inspect actual captured pause after
each bounded batch, including a foreground refusal and cleanup, before retrying.

## Backpack and rod drag recipe

Use a fresh `docs/evidence/F010/<run-id>` child for F010. Verify the intended fresh
release first: older P014/W builds do not establish current backpack/rod behavior.
From inspected resumed gameplay, send B, settle, capture; inspect the actual modal
before selecting inventory/Drop with observed coordinates or Tab/Enter. Close it
with B/Esc and inspect resumed gameplay before dragging. Do not reuse viewport or
historical coordinates. The rod must be visible, nearby and reachable.

Once `$rodClientX/$rodClientY` and `$groundClientX/$groundClientY` come from a fresh
native client capture, a bounded reposition request is:

```powershell
$steps = @(
  @{op='drag';from_x=$rodClientX;from_y=$rodClientY;
    to_x=$groundClientX;to_y=$groundClientY;duration_ms=500},
  @{op='wait';duration_ms=150},
  @{op='capture';label='rod-after-release'},
  @{op='hold';keys=@('ESC');duration_ms=70},
  @{op='wait';duration_ms=150},
  @{op='capture';label='rod-paused'}
)
# Serialize/invoke using the same command above, with a new request/capture name.
```

Inspect rod-after-release for actual placement, then verify rod-paused shows the
pause overlay. Invalid ground should leave the original rod intact. Esc may cancel
another mode instead of pausing; a successful request is not a pause assertion.
This recipe and dispatcher checks prepare F010; only a fresh exported release
journey can complete its native gameplay acceptance.
