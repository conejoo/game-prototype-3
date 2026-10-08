#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. (Join-Path $projectRoot 'tools/testing_runner_observation.ps1')
. (Join-Path $projectRoot 'tools/testing_paths.ps1')
$assertions = 0
function Check([bool]$Condition, [string]$Message) {
    $script:assertions++
    if (-not $Condition) { throw $Message }
}
$id = [Guid]::NewGuid().ToString('N')
$scratch = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot "builds/testing/observation-$id") 'builds/testing'
New-Item -ItemType Directory -Path "$scratch/game/.godot","$scratch/tools/__pycache__" | Out-Null
[IO.File]::WriteAllText("$scratch/game/a.gd", 'before')
[IO.File]::WriteAllText("$scratch/tools/tool.ps1", 'tool')
$before = Get-RunnerSourceSnapshot $scratch
[IO.File]::WriteAllText("$scratch/game/.godot/cache", 'generated')
[IO.File]::WriteAllText("$scratch/tools/__pycache__/cache.pyc", 'generated')
[IO.File]::SetLastWriteTimeUtc("$scratch/game/a.gd", [DateTime]::UtcNow.AddDays(-1))
$unchanged = Get-RunnerSourceSnapshot $scratch
Check ($before.sha256 -eq $unchanged.sha256 -and $before.file_count -eq 2) 'hash depends on cache/timestamps'
Check (@(Compare-RunnerSourceSnapshots $before $unchanged).Count -eq 0) 'stable snapshot has changes'
[IO.File]::WriteAllText("$scratch/game/a.gd", 'after')
[IO.File]::Delete("$scratch/tools/tool.ps1")
[IO.File]::WriteAllText("$scratch/game/new.tres", 'added')
$after = Get-RunnerSourceSnapshot $scratch
$changes = @(Compare-RunnerSourceSnapshots $before $after)
Check ($before.sha256 -ne $after.sha256 -and $changes.Count -eq 3) 'content/add/remove not detected'
Check ($changes[0].path -eq 'game/a.gd' -and $changes[0].change -eq 'modified' -and $changes[0].before_sha256 -ne $changes[0].after_sha256) 'modified hashes missing'
Check ($changes[1].change -eq 'added' -and $null -eq $changes[1].before_sha256) 'added path incorrect'
Check ($changes[2].change -eq 'removed' -and $null -eq $changes[2].after_sha256) 'removed path incorrect'
Check ($after.files[0].sha256 -eq (Get-FileHash -LiteralPath "$scratch/game/a.gd" -Algorithm SHA256).Hash.ToLowerInvariant()) 'fingerprint not file byte hash'
$renamed = @{files=@(@{path='game/A.gd'; sha256=$before.files[0].sha256}, $before.files[1])}
$caseChanges = @(Compare-RunnerSourceSnapshots $before $renamed)
Check ($caseChanges.Count -eq 2 -and $caseChanges[0].path -ceq 'game/A.gd' -and $caseChanges[0].change -eq 'added' -and $caseChanges[1].change -eq 'removed') 'case-only rename not detected'
[IO.File]::WriteAllText("$scratch/out.log", "ASSERTION FAILED: expected durable rod`n    at: _check (res://tests/rod.gd:42)`n")
[IO.File]::WriteAllText("$scratch/err.log", '')
$row = @{stdout="$scratch/out.log"; stderr="$scratch/err.log"; diagnostics=@(); source_changes=@(); timed_out=$false; error=$null; exit_code=1}
$failure = Get-RunnerFailureSummary $row 5
Check ($failure.failed_assertion -eq 'ASSERTION FAILED: expected durable rod') 'assertion not extracted'
Check ($failure.stack.Count -eq 1 -and $failure.stack[0].line_number -eq 2 -and $failure.stack[0].stream -eq 'stdout') 'stack location incorrect'
Check ($failure.log_tail.Count -eq 2 -and $failure.stdout -eq $row.stdout) 'tail/log paths absent'
[IO.File]::WriteAllText("$scratch/out.log", "FAILED: generic process failure`n")
$failure = Get-RunnerFailureSummary $row 5
Check ($null -eq $failure.failed_assertion -and $failure.diagnostic_context.Count -eq 1) 'generic failure invented an assertion'
# A linked source cannot be verified safely; fail before any engine starts.
$linkedSource = Join-Path $projectRoot "game/tests/fixtures/testing_tools/observation-$id-linked"
try {
    New-Item -ItemType Junction -Path $linkedSource -Value "$scratch/game" | Out-Null
    $linkLines = @(& (Join-Path $PSHOME 'pwsh.exe') -NoProfile -File (Join-Path $projectRoot 'tools/run_checks.ps1') -Task TESTING -Names fixtures/testing_tools/pass)
    $linkExit = $LASTEXITCODE
    $linkReportPath = @($linkLines | Where-Object { $_ -like 'REPORT=*' })[-1].Substring(7)
    $linkReport = Get-Content -LiteralPath $linkReportPath -Raw | ConvertFrom-Json
    Check ($linkExit -eq 1 -and $linkReport.cases.Count -eq 0 -and $linkReport.source.error -like '*Linked source*') 'unverifiable source did not fail closed'
} finally { if (Test-Path -LiteralPath $linkedSource) { Remove-Item -LiteralPath $linkedSource } }
# Real Godot assertion proves its stderr format, not only fabricated log parsing.
$runLines = @(& (Join-Path $PSHOME 'pwsh.exe') -NoProfile -File (Join-Path $projectRoot 'tools/run_checks.ps1') -Task TESTING -Names fixtures/testing_tools/assertion_error)
$assertExit = $LASTEXITCODE
$assertReportPath = @($runLines | Where-Object { $_ -like 'REPORT=*' })[-1].Substring(7)
$assertReport = Get-Content -LiteralPath $assertReportPath -Raw | ConvertFrom-Json
$assertCase = $assertReport.cases[-1]
Check ($assertExit -eq 1 -and $assertCase.failure_summary.failed_assertion -like '*expected durable rod*') 'real assertion absent from summary'
Check (@($runLines | Where-Object { $_ -like 'ASSERTION=*expected durable rod*' }).Count -eq 1) 'real assertion absent from console'
Check ($assertCase.failure_summary.stack.Count -gt 0) 'real assertion stack absent'
# Mutate only our unique sentinel files while a real owned engine is running.
$fixtureDirectory = Join-Path $projectRoot 'game/tests/fixtures/testing_tools'
$modifiedPath = Join-Path $fixtureDirectory "observation-$id-modified.txt"
$removedPath = Join-Path $fixtureDirectory "observation-$id-removed.txt"
$addedPath = Join-Path $fixtureDirectory "observation-$id-added.txt"
$process = [Diagnostics.Process]::new()
$started = $false
try {
    [IO.File]::WriteAllText($modifiedPath, 'before')
    [IO.File]::WriteAllText($removedPath, 'remove me')
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = Join-Path $PSHOME 'pwsh.exe'
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    foreach ($argument in @('-NoProfile','-File',(Join-Path $projectRoot 'tools/run_checks.ps1'),'-Task','TESTING',
        '-Names','fixtures/testing_tools/stream,fixtures/testing_tools/pass','-ProcessScripts','fixtures/testing_tools/save_restart_other',
        '-RenderScript','fixtures/testing_tools/pass','-TimeoutSeconds','20')) { $info.ArgumentList.Add($argument) }
    $process.StartInfo = $info
    $started = $process.Start()
    $reportRead = $process.StandardOutput.ReadLineAsync()
    Check ($reportRead.Wait(10000) -and $reportRead.Result.StartsWith('RUN_REPORT=')) 'live report path missing'
    $livePath = $reportRead.Result.Substring(11)
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $ready = $false
    $deadline = [Diagnostics.Stopwatch]::StartNew()
    while (-not $process.HasExited -and $deadline.Elapsed.TotalSeconds -lt 20) {
        $live = Get-Content -LiteralPath $livePath -Raw | ConvertFrom-Json
        $members = @($live.cases | Where-Object label -eq 'fixtures/testing_tools/stream')
        if ($members.Count -gt 0 -and (Test-Path -LiteralPath $members[0].stdout)) {
            if ((Get-Content -LiteralPath $members[0].stdout -Raw) -like '*LIVE_LOG_READY*') { $ready = $true; break }
        }
        Start-Sleep -Milliseconds 100
    }
    if (-not $ready) {
        $early = Get-Content -LiteralPath $livePath -Raw | ConvertFrom-Json
        throw "Mutation fixture never became ready: $($early.error). Report: $livePath"
    }
    [IO.File]::WriteAllText($modifiedPath, 'after')
    [IO.File]::Delete($removedPath)
    [IO.File]::WriteAllText($addedPath, 'added')
    Check ($process.WaitForExit(20000) -and $process.ExitCode -eq 1) 'changed-source run accepted or hung'
    $output = $stdout.GetAwaiter().GetResult()
    $errorOutput = $stderr.GetAwaiter().GetResult()
    Check ([string]::IsNullOrWhiteSpace($errorOutput)) "runner threw outside retained report: $errorOutput"
    $done = Get-Content -LiteralPath $livePath -Raw | ConvertFrom-Json
    $case = $done.cases[-1]
    Check ($done.status -eq 'failed' -and $done.source.changed -and $null -eq $done.source.error) 'changed run not invalidated'
    Check ($case.label -eq 'fixtures/testing_tools/stream' -and $case.exit_code -eq 0 -and $case.status -eq 'failed') 'changed-source case result incorrect'
    Check ($case.failure_summary.reason -eq 'source_changed' -and $case.source_changes.Count -eq 3) 'changed paths absent from case'
    Check ($done.cases.Count -eq 3 -and $done.save_groups.Count -eq 1) 'later check/process/render ran after source changed'
    Check ($case.source_before.sha256 -eq $done.source.before.sha256 -and $case.source_after.sha256 -eq $done.source.after.sha256 -and $case.source_before.sha256 -ne $case.source_after.sha256) 'source fingerprints not linked to case'
    foreach ($change in $case.source_changes) {
        Check ($output.Contains("change=$($change.change) path=$($change.path)")) 'changed path absent from console'
    }
    Check ($output.Contains('CASE_FAILURE label=fixtures/testing_tools/stream reason=source_changed')) 'source failure absent from console'
    Check ($null -eq (Get-Process -Id $case.launcher_pid -ErrorAction SilentlyContinue)) 'changed-source launcher survived'
    foreach ($engineId in $case.engine_pids) { Check ($null -eq (Get-Process -Id $engineId -ErrorAction SilentlyContinue)) 'changed-source engine survived' }
} finally {
    if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
    $process.Dispose()
    foreach ($path in @($modifiedPath,$removedPath,$addedPath)) { if ([IO.File]::Exists($path)) { [IO.File]::Delete($path) } }
}
Write-Output "Runner observations: PASS assertions=$assertions"
Write-Output "Assertion evidence: $assertReportPath"
Write-Output "Changed-source evidence: $livePath"
