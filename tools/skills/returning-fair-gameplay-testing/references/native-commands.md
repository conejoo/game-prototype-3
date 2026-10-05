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
stops waits. Key/mouse releases run in finally on normal errors; forced process
termination can bypass cleanup. Do not mix human input with a timed batch.

Current output guard accepts only run subdirectories of `docs/evidence/P014` or
`docs/evidence/W001` through `W010`. Task roots, sibling prefixes, path traversal
outside those roots and existing junction/symlink ancestors are rejected. Use a
fresh task/run directory; do not overwrite historical captures. Pure guard tests
live in `tools/tests/testing_tools_checks.ps1`. Executable/PID/window/desktop/focus
and finally input-release checks remain mandatory.
Do not remove target/focus/path checks or silently substitute an old release for
current project source. Verify or rebuild the intended executable before testing it.

Request JSON has `steps`: 1-32 operations, summed requested holds/waits <=30000ms.
Individual durations are16-5000ms; captures/startup/input overhead add real time.

| Operation | Fields |
| --- | --- |
| hold | keys array, duration_ms; keys W/A/S/D/E/J/SPACE/ESC/R/F10/TAB/ENTER, up to4 |
| wait | duration_ms; native foreground guard remains active |
| pointer | x, y in actual client pixels |
| click | x, y; normal left-button press/release |
| capture | label using1-64 letters/digits/underscore/hyphen; saves PNG |
| quit | final operation only; normal F10 |

Capture labels must be unique within a request and cannot overwrite an existing PNG.
Exclusive file creation also prevents overwrites during execution.

Every request creates GUID.json with success/error, exact steps, completed UTC
timestamps and actual elapsed milliseconds. Inspect emitted PNG files with
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
