#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. (Join-Path $projectRoot 'tools/testing_paths.ps1')
$assertions = 0
function Check([bool]$Condition, [string]$Message) {
    $script:assertions++
    if (-not $Condition) { throw $Message }
}
foreach ($task in @('P014','W001','W006','W010')) {
    $path = Join-Path $projectRoot "docs/evidence/$task/native-future"
    Check ((Resolve-NativeEvidenceDirectory $projectRoot $path) -eq [IO.Path]::GetFullPath($path)) "accepted native $task"
}
foreach ($relative in @('W000/run','W011/run','W006','W006-sibling/run','P014-sibling/run','W006/../../outside/run','../../outside/run')) {
    $rejected = $false
    try { $null = Resolve-NativeEvidenceDirectory $projectRoot (Join-Path $projectRoot "docs/evidence/$relative") } catch { $rejected = $true }
    Check $rejected "unsafe native path accepted: $relative"
}
$guardRun = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot ('docs/evidence/W006/native-guard-' + [Guid]::NewGuid().ToString('N'))) 'docs/evidence'
$junctionTarget = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot ('builds/testing/junction-target-' + [Guid]::NewGuid().ToString('N'))) 'builds/testing'
New-Item -ItemType Directory -Path $guardRun,$junctionTarget | Out-Null
$junction = Join-Path $guardRun 'linked'
New-Item -ItemType Junction -Path $junction -Value $junctionTarget | Out-Null
$rejected = $false
try { $null = Resolve-NativeEvidenceDirectory $projectRoot (Join-Path $junction 'run') } catch { $rejected = $true }
Check $rejected 'junction output accepted'
Set-Content -LiteralPath (Join-Path $guardRun 'existing.png') -Value 'preserved fixture'
foreach ($labels in @(@('existing'), @('repeat','repeat'), @('../outside'))) {
    $rejected = $false
    try { Assert-NewEvidenceCaptures $guardRun $labels } catch { $rejected = $true }
    Check $rejected 'unsafe/duplicate/existing capture accepted'
}
Assert-NewEvidenceCaptures $guardRun @()
Assert-NewEvidenceCaptures $guardRun @('new-capture')
Check ((Get-Content -LiteralPath (Join-Path $guardRun 'existing.png') -Raw).Trim() -eq 'preserved fixture') 'guard changed existing evidence'
$initialAppData = $env:APPDATA
$initialLocalData = $env:LOCALAPPDATA
function Run-Fixture([string[]]$Arguments) {
    $lines = @(& (Join-Path $PSHOME 'pwsh.exe') -NoProfile -File (Join-Path $projectRoot 'tools/run_checks.ps1') -Task TESTING @Arguments)
    $exitCode = $LASTEXITCODE
    $reportLine = @($lines | Where-Object { $_ -like 'REPORT=*' })[-1]
    $report = Get-Content -LiteralPath $reportLine.Substring(7) -Raw | ConvertFrom-Json
    return @{report=$report; exit=$exitCode; path=$reportLine.Substring(7)}
}
$absent = Run-Fixture @('-Names','fixtures/testing_tools/pass,absent_check')
Check ($absent.exit -eq 1 -and $absent.report.cases.Count -eq 0 -and $absent.report.error -like '*absent*') 'all names must preflight before any launch'
$unsafe = Run-Fixture @('-Names','../app/game_root')
Check ($unsafe.exit -eq 1 -and $unsafe.report.cases.Count -eq 0) 'traversal name accepted'
$duplicate = Run-Fixture @('-Names','fixtures/testing_tools/pass,fixtures/testing_tools/pass.gd')
Check ($duplicate.exit -eq 1 -and $duplicate.report.cases.Count -eq 0) 'duplicate resolved scripts accepted'
$badPhase = Run-Fixture @('-Names','fixtures/testing_tools/pass','-RenderScript','fixtures/testing_tools/pass','-RenderPhases','write,../read')
Check ($badPhase.exit -eq 1 -and $badPhase.report.cases.Count -eq 0) 'unsafe phase not preflighted'
$missingEngine = Run-Fixture @('-Names','fixtures/testing_tools/pass','-EnginePath',(Join-Path $projectRoot 'builds/testing/absent.exe'))
Check ($missingEngine.exit -eq 1 -and $missingEngine.report.cases.Count -eq 0) 'missing engine not preflighted'
$errorRun = Run-Fixture @('-Names','fixtures/testing_tools/pass,fixtures/testing_tools/runtime_error')
Check ($errorRun.exit -eq 1 -and $errorRun.report.cases.Count -eq 4) 'comma arguments not expanded'
$passedCase = @($errorRun.report.cases | Where-Object label -eq 'fixtures/testing_tools/pass')[0]
$errorCase = @($errorRun.report.cases | Where-Object label -eq 'fixtures/testing_tools/runtime_error')[0]
Check ($passedCase.status -eq 'passed') 'pass fixture failed'
Check ($errorCase.exit_code -eq 0 -and $errorCase.status -eq 'failed' -and $errorCase.diagnostics.Count -gt 0) 'exit-zero runtime error escaped scan'
$fixtureLine = (Get-Content -LiteralPath $passedCase.stdout | Where-Object { $_ -like 'TESTING_FIXTURE=*' })
$fixture = $fixtureLine.Substring(16) | ConvertFrom-Json
Check ([IO.Path]::GetFullPath($fixture.user_data).StartsWith($errorRun.report.appdata + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) 'save isolation failed'
Check ($env:APPDATA -eq $initialAppData -and $env:LOCALAPPDATA -eq $initialLocalData) 'caller environment changed'
$hang = Run-Fixture @('-Names','fixtures/testing_tools/hang','-TimeoutSeconds','2')
$case = @($hang.report.cases | Where-Object label -eq 'fixtures/testing_tools/hang')[0]
Check ($hang.exit -eq 1 -and $case.timed_out -and $case.status -eq 'timeout') 'timeout not recorded'
Check ($null -eq (Get-Process -Id $case.launcher_pid -ErrorAction SilentlyContinue)) 'owned launcher still alive'
foreach ($engineId in $case.engine_pids) { Check ($null -eq (Get-Process -Id $engineId -ErrorAction SilentlyContinue)) 'owned engine still alive' }
Check ((Test-Path -LiteralPath $case.stdout) -and (Test-Path -LiteralPath $case.stderr)) 'timeout logs missing'
Check ($hang.report.appdata -ne $errorRun.report.appdata -and $hang.path -ne $errorRun.path) 'run folders reused'
$failedWriter = Run-Fixture @('-Names','fixtures/testing_tools/pass','-RenderScript','fixtures/testing_tools/runtime_error','-RenderPhases','write,read')
Check ($failedWriter.exit -eq 1 -and $failedWriter.report.cases.Count -eq 4 -and $failedWriter.report.cases[-1].label -eq 'render-write') 'dependent reader ran after failed writer'
$renderOnly = Run-Fixture @('-RenderOnly','-RenderScript','fixtures/testing_tools/pass','-RenderPhases','check')
Check ($renderOnly.exit -eq 0 -and $renderOnly.report.cases[-1].label -eq 'render-check' -and @($renderOnly.report.cases | Where-Object label -eq 'application_smoke').Count -eq 0) 'render-only ran default smoke'
foreach ($arguments in @(@('-RenderOnly'), @('-RenderOnly','-Names','fixtures/testing_tools/pass','-RenderScript','fixtures/testing_tools/pass'))) {
    $invalid = Run-Fixture $arguments
    Check ($invalid.exit -eq 1 -and $invalid.report.cases.Count -eq 0) 'invalid render-only combination launched engine'
}
$legacy = Run-Fixture @('-Names','fixtures/testing_tools/legacy_output')
Check ($legacy.exit -eq 1 -and $legacy.report.cases.Count -eq 0 -and $legacy.report.error -like '*historical*') 'legacy evidence route not rejected before launch'
$originalJunction = $env:RETURNING_FAIR_TEST_JUNCTION
try {
    $env:RETURNING_FAIR_TEST_JUNCTION = $junction
    $evidence = Run-Fixture @('-Import','-Names','testing_evidence_checks')
    Check ($evidence.exit -eq 0 -and -not (Test-Path -LiteralPath (Join-Path $junctionTarget 'denied.json'))) 'Godot evidence junction guard failed'
} finally { $env:RETURNING_FAIR_TEST_JUNCTION = $originalJunction }
foreach ($arguments in @(@('-Names','fixtures/testing_tools/pass,fixtures/testing_tools/parse_error'),
    @('-Names','fixtures/testing_tools/dynamic_parse'),
    @('-Names','fixtures/testing_tools/pass','-ParseScripts','tests/fixtures/testing_tools/parse_error'))) {
    $badParse = Run-Fixture $arguments
    Check ($badParse.exit -eq 1 -and $badParse.report.cases[-1].label -eq 'parse-preflight' -and $badParse.report.cases[-1].diagnostics.Count -gt 0) 'parser failure escaped execution gate'
    Check (@($badParse.report.cases | Where-Object label -eq 'fixtures/testing_tools/pass').Count -eq 0) 'check executed before full parse gate'
}
$fatal = Run-Fixture @('-Names','fixtures/testing_tools/error_hang','-TimeoutSeconds','20')
$fatalCase = @($fatal.report.cases | Where-Object label -eq 'fixtures/testing_tools/error_hang')[0]
Check ($fatal.exit -eq 1 -and $fatalCase.stopped_on_diagnostic -and -not $fatalCase.timed_out) 'diagnostic did not stop hanging engine early'
Check (([DateTime]$fatalCase.finished_utc - [DateTime]$fatalCase.started_utc).TotalSeconds -lt 10) 'diagnostic waited for full timeout'
Check ($null -eq (Get-Process -Id $fatalCase.launcher_pid -ErrorAction SilentlyContinue)) 'fatal engine launcher survived cleanup'
# Observe a real flushed log while its owning check is still running.
$info = [Diagnostics.ProcessStartInfo]::new()
$info.FileName = Join-Path $PSHOME 'pwsh.exe'
$info.UseShellExecute = $false
$info.CreateNoWindow = $true
$info.RedirectStandardOutput = $true
foreach ($argument in @('-NoProfile','-File',(Join-Path $projectRoot 'tools/run_checks.ps1'),'-Task','TESTING','-Names','fixtures/testing_tools/stream','-TimeoutSeconds','15')) { $info.ArgumentList.Add($argument) }
$streamProcess = [Diagnostics.Process]::new()
$streamProcess.StartInfo = $info
try {
    $null = $streamProcess.Start()
    $reportRead = $streamProcess.StandardOutput.ReadLineAsync()
    Check ($reportRead.Wait(10000)) 'runner did not expose live report path'
    $livePath = $reportRead.Result.Substring(11)
    $rest = $streamProcess.StandardOutput.ReadToEndAsync()
    $observed = $false
    $deadline = [Diagnostics.Stopwatch]::StartNew()
    while (-not $streamProcess.HasExited -and $deadline.Elapsed.TotalSeconds -lt 20) {
        $live = Get-Content -LiteralPath $livePath -Raw | ConvertFrom-Json
        $streamCase = @($live.cases | Where-Object label -eq 'fixtures/testing_tools/stream')
        if ($streamCase.Count -gt 0 -and (Test-Path -LiteralPath $streamCase[0].stdout)) {
            $log = Get-Content -LiteralPath $streamCase[0].stdout -Raw
            if ($log -like '*LIVE_LOG_READY*' -and $streamCase[0].status -eq 'running') { $observed = $true; break }
        }
        Start-Sleep -Milliseconds 100
    }
    Check $observed 'stdout unavailable until exit'
    Check ($streamProcess.WaitForExit(20000) -and $streamProcess.ExitCode -eq 0) 'stream fixture failed'
    $null = $rest.GetAwaiter().GetResult()
    $done = Get-Content -LiteralPath $livePath -Raw | ConvertFrom-Json
    Check ((Get-Content -LiteralPath $done.cases[-1].stdout -Raw) -like '*LIVE_LOG_FINISHED*') 'final streamed output lost'
} finally {
    if (-not $streamProcess.HasExited) { $streamProcess.Kill($true); $streamProcess.WaitForExit() }
    $streamProcess.Dispose()
}
Write-Output "Testing tools: PASS assertions=$assertions"
Write-Output "Failure evidence: $($errorRun.path); $($hang.path)"
