#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. (Join-Path $projectRoot 'tools/native_input_commands.ps1')
. (Join-Path $projectRoot 'tools/testing_paths.ps1')
$assertions = 0
function Check([bool]$Condition, [string]$Message) {
    $script:assertions++
    if (-not $Condition) { throw $Message }
}
function New-FakeDispatch($State) {
    return {
        param($operation, $arguments)
        $State.calls.Add(@{op=$operation; arguments=$arguments})
        if (-not $State.counts.ContainsKey($operation)) { $State.counts[$operation] = 0 }
        $State.counts[$operation]++
        if ($operation -eq $State.fail_op -and $State.counts[$operation] -eq $State.fail_at) { throw 'Injected focus/input failure.' }
        if ($operation -eq 'ValidatePoint' -and ($arguments[0] -ge 960 -or $arguments[1] -ge 640)) { throw 'Pointer outside client.' }
        if ($operation -eq 'Key') {
            $vk = $arguments[0]
            if ($arguments[1]) {
                if ($vk -eq $State.fail_release_key) { throw 'Injected key release failure.' }
                $null = $State.keys.Remove($vk)
            } else {
                if ($State.keys.Contains($vk)) { throw 'Requested key already held.' }
                $State.keys.Add($vk)
            }
        }
        if ($operation -eq 'Mouse') {
            if ($arguments[0]) {
                if ($State.release_mouse_failures -gt 0) { $State.release_mouse_failures--; throw 'Injected mouse release failure.' }
                $State.mouse = $false
            } else {
                if ($State.mouse) { throw 'Left mouse button already held.' }
                $State.mouse = $true
            }
        }
    }.GetNewClosure()
}
function New-State {
    return @{calls=[Collections.Generic.List[object]]::new(); counts=@{}; keys=[Collections.Generic.List[int]]::new(); mouse=$false;
        fail_op=''; fail_at=0; fail_release_key=-1; release_mouse_failures=0}
}
function Run-Steps([array]$Steps, $State) {
    return Invoke-NativeInputSteps $Steps (New-FakeDispatch $State)
}
$drag = @{op='drag'; from_x=40; from_y=50; to_x=220; to_y=110; duration_ms=101}
$valid = @{steps=@(@{op='hold'; keys=@('B'); duration_ms=70}, $drag, @{op='capture'; label='after-drag'})}
Check ((Assert-NativeInputRequest $valid) -eq 171) 'B/drag budget rejected'
# Exercise actual JSON types, rather than only PowerShell hashtables.
$json = $valid | ConvertTo-Json -Depth 8 | ConvertFrom-Json
Check ((Assert-NativeInputRequest $json) -eq 171) 'JSON request differs from hashtable contract'
$badRequests = @(
    @{steps=@()}, @{steps='wait'}, @{steps=@($drag); unexpected=$true},
    @{steps=@(@{op='drag'; from_x=1; from_y=2; to_x=3; duration_ms=50})},
    @{steps=@(@{op='drag'; from_x=1; from_y=2; to_x=3; to_y=4; duration_ms='50'})},
    @{steps=@(@{op='drag'; from_x=-1; from_y=2; to_x=3; to_y=4; duration_ms=50})},
    @{steps=@(@{op='pointer'; x=1.5; y=2})}, @{steps=@(@{op='pointer'; x=$true; y=2})},
    @{steps=@(@{op='pointer'; x=32768; y=2})}, @{steps=@(@{op='wait'; duration_ms=15})},
    @{steps=@(@{op='drag'; from_x=1; from_y=2; to_x=3; to_y=4; duration_ms=5001})},
    @{steps=@(@{op='wait'; duration_ms=16.0})}, @{steps=@(@{op='hold'; keys=@('B','B'); duration_ms=50})},
    @{steps=@(@{op='hold'; keys=@('X'); duration_ms=50})}, @{steps=@(@{op='hold'; keys='B'; duration_ms=50})},
    @{steps=@(@{op='hold'; keys=@('B','b'); duration_ms=50})},
    @{steps=@(@{op='mouse_down'})}, @{steps=@(@{op='quit'},@{op='wait'; duration_ms=20})},
    @{steps=@(@{op='capture'; label='../bad'})}, @{steps=@(@{op='capture'; label='same'},@{op='capture'; label='same'})},
    @{steps=@(@{op='capture'; label='Shot'},@{op='capture'; label='shot'})},
    @{steps=@(@{op='wait'; duration_ms=20; typo=3})}, @{steps=@(@{op='WAIT'; duration_ms=20})},
    @{steps=@(1..33 | ForEach-Object { @{op='wait'; duration_ms=16} })},
    @{steps=@(1..7 | ForEach-Object { @{op='drag'; from_x=1; from_y=2; to_x=3; to_y=4; duration_ms=5000} })},
    @{steps=@((1..6 | ForEach-Object { @{op='wait'; duration_ms=5000} }); @{op='click'; x=1; y=2})}
)
foreach ($request in $badRequests) {
    $rejected = $false
    try { $null = Assert-NativeInputRequest $request } catch { $rejected = $true }
    Check $rejected 'malformed/unbounded request accepted'
}
$state = New-State
$result = Run-Steps $valid.steps $state
Check ($result.ok -and $result.steps.Count -eq 3 -and $result.cleanup_errors.Count -eq 0) 'normal dispatch failed'
Check ($state.keys.Count -eq 0 -and -not $state.mouse -and -not $result.mouse_unreleased) 'normal dispatch leaked input'
Check (@($state.calls | Where-Object { $_.op -eq 'Key' -and $_.arguments[0] -eq 0x42 }).Count -eq 2) 'B did not send down/up'
$points = @($state.calls | Where-Object op -eq 'Pointer')
Check ($points[0].arguments[0] -eq 40 -and $points[-1].arguments[0] -eq 220 -and $points[-1].arguments[1] -eq 110) 'drag endpoints changed'
$waits = @($state.calls | Where-Object op -eq 'Wait')
Check ((($waits | ForEach-Object { $_.arguments[0] } | Measure-Object -Sum).Sum) -eq 171) 'drag requested duration not exact'
Check ($points.Count -gt 3 -and @($state.calls | Where-Object op -eq 'Mouse').Count -eq 2) 'drag lacks intermediate motion or atomic button lifecycle'
$down = @($state.calls | Where-Object { $_.op -eq 'Mouse' -and -not $_.arguments[0] })[0]
$up = @($state.calls | Where-Object { $_.op -eq 'Mouse' -and $_.arguments[0] })[0]
Check ($state.calls.IndexOf($down) -lt $state.calls.IndexOf($points[1]) -and $state.calls.IndexOf($up) -gt $state.calls.IndexOf($waits[-1])) 'drag does not settle while pressed'
foreach ($duration in @(16,17,4999,5000)) {
    $state = New-State
    $result = Run-Steps @(@{op='drag'; from_x=959; from_y=639; to_x=0; to_y=0; duration_ms=$duration}) $state
    Check ($result.ok -and $result.requested_duration_ms -eq $duration) 'boundary/reverse drag failed'
    $waits = @($state.calls | Where-Object op -eq 'Wait')
    Check (($waits | ForEach-Object { $_.arguments[0] } | Measure-Object -Sum).Sum -eq $duration) 'boundary drag budget drift'
    foreach ($point in @($state.calls | Where-Object op -eq 'Pointer')) {
        Check ($point.arguments[0] -ge 0 -and $point.arguments[0] -le 959 -and $point.arguments[1] -ge 0 -and $point.arguments[1] -le 639) 'interpolation left client'
    }
}
$state = New-State
$result = Run-Steps @(@{op='hold';keys=@('B');duration_ms=50}, @{op='click';x=960;y=10}) $state
Check (-not $result.ok -and $result.steps.Count -eq 0 -and $state.keys.Count -eq 0) 'late out-of-client point not preflighted'
Check (@($state.calls | Where-Object { $_.op -in @('Key','Mouse','Pointer') }).Count -eq 0) 'preflight emitted input'
$state = New-State
$result = Run-Steps @(@{op='hold';keys=@('B');duration_ms=50}, @{op='drag';from_x=1;from_y=2;to_x=3;to_y=4;duration_ms='50'}) $state
Check (-not $result.ok -and $state.calls.Count -eq 0) 'late malformed step emitted earlier input'
$state = New-State
$result = Run-Steps @(@{op='hold';keys=@('B');duration_ms=50}, @{op='capture';label='Shot'}, @{op='capture';label='shot'}) $state
Check (-not $result.ok -and $state.calls.Count -eq 0) 'case-only capture collision emitted earlier input'
$rejected = $false
try { Assert-NewEvidenceCaptures (Join-Path $projectRoot 'docs/evidence/F010/native-future') @('Shot','shot') } catch { $rejected=$true }
Check $rejected 'shared path guard accepted case-only capture collision'
foreach ($fault in @(@{op='Wait';at=2}, @{op='Pointer';at=3}, @{op='Guard';at=2})) {
    $state = New-State; $state.fail_op=$fault.op; $state.fail_at=$fault.at
    $result = Run-Steps @($drag, @{op='capture';label='must-not-run'}) $state
    Check (-not $result.ok -and $result.failed_step -eq 0 -and $result.steps.Count -eq 1 -and -not $result.steps[0].ok) 'failed drag trace missing'
    Check (-not $state.mouse -and @($state.calls | Where-Object op -eq 'Capture').Count -eq 0) 'failed drag leaked button or continued'
}
$state = New-State; $state.fail_op='Key'; $state.fail_at=2
$result = Run-Steps @(@{op='hold';keys=@('B','W');duration_ms=50}) $state
Check (-not $result.ok -and $state.keys.Count -eq 0 -and $result.unreleased_keys.Count -eq 0) 'partial key acquisition leaked B'
$state = New-State; $state.fail_op='Wait'; $state.fail_at=1
$result = Run-Steps @(@{op='hold';keys=@('B','W');duration_ms=50}) $state
Check (-not $result.ok -and $state.keys.Count -eq 0) 'focus loss during hold leaked keys'
$state = New-State; $state.keys.Add(0x42)
$result = Run-Steps @(@{op='hold';keys=@('B');duration_ms=50}) $state
Check (-not $result.ok -and $state.keys.Count -eq 1 -and @($state.calls | Where-Object { $_.op -eq 'Key' -and $_.arguments[1] }).Count -eq 0) 'released human-held B'
$state = New-State; $state.mouse=$true
$result = Run-Steps @($drag) $state
Check (-not $result.ok -and $state.mouse -and @($state.calls | Where-Object { $_.op -eq 'Mouse' -and $_.arguments[0] }).Count -eq 0) 'released human-held mouse'
$state = New-State; $state.release_mouse_failures=1
$result = Run-Steps @($drag, @{op='capture';label='must-not-run'}) $state
Check (-not $result.ok -and -not $state.mouse -and $result.cleanup_errors.Count -eq 1 -and -not $result.mouse_unreleased) 'mouse release retry/error not recorded'
Check ($result.failed_step -eq 0 -and @($state.calls | Where-Object op -eq 'Capture').Count -eq 0) 'release failure continued request'
$state = New-State; $state.fail_release_key=0x42
$result = Run-Steps @(@{op='hold';keys=@('B','W');duration_ms=50}) $state
Check (-not $result.ok -and $state.keys.Count -eq 1 -and $state.keys[0] -eq 0x42) 'release failure prevented release of other key'
Check ($result.cleanup_errors.Count -eq 2 -and $result.unreleased_keys.Count -eq 1) 'persistent release failure hidden'
foreach ($operation in @('click','quit')) {
    $step = if ($operation -eq 'click') { @{op='click';x=1;y=2} } else { @{op='quit'} }
    $state = New-State; $result = Run-Steps @($step) $state
    Check ($result.ok -and $result.requested_duration_ms -eq 50 -and -not $state.mouse -and $state.keys.Count -eq 0) "$operation lifecycle regression"
}
foreach ($task in @('F001','F007','F009','F010','P014','W010')) {
    $path = Join-Path $projectRoot "docs/evidence/$task/native-future"
    Check ((Resolve-NativeEvidenceDirectory $projectRoot $path) -eq [IO.Path]::GetFullPath($path)) "native route rejected $task"
}
foreach ($relative in @('F000/run','F011/run','F010','F010-sibling/run','F010/../../outside/run','../evidence-sibling/F010/run')) {
    $rejected = $false
    try { $null = Resolve-NativeEvidenceDirectory $projectRoot (Join-Path $projectRoot "docs/evidence/$relative") } catch { $rejected=$true }
    Check $rejected "unsafe F route accepted: $relative"
}
# Compile the exact production interop without touching the desktop or sending input.
$tokens = $null; $parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile((Join-Path $projectRoot 'tools/native_input.ps1'), [ref]$tokens, [ref]$parseErrors)
Check ($parseErrors.Count -eq 0) 'native entrypoint parse errors'
$addType = $ast.Find({param($node) $node -is [Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Add-Type' -and $node.Extent.Text -like '*-TypeDefinition*'}, $true)
Add-Type -TypeDefinition $addType.CommandElements[2].Value
Check ($null -ne ('ReturningFairNative' -as [type])) 'production interop did not compile'
# Entrypoint refusal tests run in a fresh shell. The target is this test's own
# PowerShell process, so the executable guard must stop before Attach/OS input.
$guardRun = Join-Path $projectRoot ('docs/evidence/F010/native-guards-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $guardRun | Out-Null
$requestFile = Join-Path $guardRun 'request.json'
$valid | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $requestFile -Encoding utf8NoBOM
$output = Join-Path $guardRun 'refused-output'
$lines = @(& (Join-Path $PSHOME 'pwsh.exe') -NoProfile -File (Join-Path $projectRoot 'tools/native_input.ps1') -TargetProcessId $PID -CommandFile $requestFile -OutputDirectory $output 2>&1)
Check ($LASTEXITCODE -ne 0 -and ($lines -join "`n") -like '*Target is not this project release executable*') 'entrypoint accepted non-release PID'
Check (-not (Test-Path -LiteralPath $output)) 'refused executable created output directory'
$lines = @(& (Join-Path $PSHOME 'pwsh.exe') -NoProfile -File (Join-Path $projectRoot 'tools/native_input.ps1') -TargetProcessId $PID -CommandFile $requestFile -OutputDirectory (Join-Path $projectRoot 'docs/evidence/F010') 2>&1)
Check ($LASTEXITCODE -ne 0 -and ($lines -join "`n") -like '*Native output must be a run subdirectory*') 'entrypoint accepted task-root output'
Write-Output "Native input: PASS assertions=$assertions (fault-injected dispatch; Win32 interop compiled, no OS input)"
Write-Output "Entrypoint refusal fixtures: $guardRun"
