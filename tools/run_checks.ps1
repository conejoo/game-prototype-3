#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Z][A-Z0-9_-]{0,31}$')][string]$Task,
    [string[]]$Names = @('application_smoke'),
    [switch]$Import,
    [string]$RenderScript,
    [string[]]$RenderPhases = @('write','read'),
    [ValidateRange(1,900)][int]$TimeoutSeconds = 120,
    [string]$EnginePath = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'testing_paths.ps1')
$projectRoot = Split-Path $PSScriptRoot -Parent
$runId = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssfff') + '-' + [Guid]::NewGuid().ToString('N').Substring(0,8)
$runDirectory = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot "docs/evidence/$Task/$runId") 'docs/evidence'
$staging = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot "builds/testing/$Task/$runId") 'builds/testing'
New-Item -ItemType Directory -Path $runDirectory,$staging | Out-Null
$appData = Join-Path $staging 'appdata'
$localData = Join-Path $staging 'localappdata'
New-Item -ItemType Directory -Path $appData,$localData | Out-Null
$reportPath = Join-Path $runDirectory 'results.json'
$report = [ordered]@{schema_version=1; task=$Task; run_id=$runId; cwd=$projectRoot; engine_path=$EnginePath; engine_version=$null; appdata=$appData; localappdata=$localData; save_slot=('check-' + $runId); started_utc=[DateTime]::UtcNow.ToString('o'); finished_utc=$null; status='running'; error=$null; cases=@()}
function Write-RunReport { $report | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $reportPath -Encoding utf8 }
function Resolve-CheckScript([string]$Name) {
    $clean = $Name.Trim() -replace '\.gd$',''
    if ($clean -notmatch '^[A-Za-z0-9_-]+(?:/[A-Za-z0-9_-]+)*$') { throw "Invalid check name: $Name" }
    $scriptPath = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot "game/tests/$clean.gd") 'game/tests'
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) { throw "Check script absent: $clean" }
    return "res://tests/$clean.gd"
}
function Invoke-OwnedGodot([string]$Label, [string[]]$EngineArguments, [bool]$IsImport = $false) {
    $safeLabel = $report.cases.Count.ToString('D2') + '-' + $Label.Replace('/','-')
    $row = [ordered]@{label=$Label; arguments=$EngineArguments; launcher_pid=$null; engine_pids=@(); exit_code=$null; timed_out=$false; mode=$(if ($EngineArguments -contains '--headless') {'headless'} else {'rendered-debug'}); status='running'; stdout=(Join-Path $runDirectory "$safeLabel.stdout.log"); stderr=(Join-Path $runDirectory "$safeLabel.stderr.log"); diagnostics=@(); allowed_diagnostics=@(); error=$null; started_utc=[DateTime]::UtcNow.ToString('o'); finished_utc=$null}
    $report.cases += $row
    Write-RunReport
    $process = [Diagnostics.Process]::new()
    $started = $false
    $stdoutTask = $null
    $stderrTask = $null
    try {
        $info = [Diagnostics.ProcessStartInfo]::new()
        $info.FileName = $EnginePath
        $info.WorkingDirectory = $projectRoot
        $info.UseShellExecute = $false
        $info.CreateNoWindow = $true
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        foreach ($argument in $EngineArguments) { $info.ArgumentList.Add($argument) }
        $info.Environment['APPDATA'] = $appData
        $info.Environment['LOCALAPPDATA'] = $localData
        $process.StartInfo = $info
        $started = $process.Start()
        if (-not $started) { throw 'Godot process did not start.' }
        $row.launcher_pid = $process.Id
        Write-RunReport
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        # Record only descendants of the exact process we just created.
        $lifetime = [Diagnostics.Stopwatch]::StartNew()
        if ([IO.Path]::GetFileName($EnginePath) -notlike '*_console.exe') { $row.engine_pids = @($process.Id) }
        while (-not $process.WaitForExit(250)) {
            if ($row.engine_pids.Count -eq 0) {
                $row.engine_pids = @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$($process.Id)" | Where-Object { $_.Name -eq ([IO.Path]::GetFileName($EnginePath).Replace("_console.exe", ".exe")) } | Select-Object -ExpandProperty ProcessId)
            }
            if ($lifetime.Elapsed.TotalSeconds -ge $TimeoutSeconds) { $row.timed_out = $true; $process.Kill($true); $process.WaitForExit(); break }
        }
        $row.exit_code = $process.ExitCode
        $stdout = $stdoutTask.GetAwaiter().GetResult()
        $stderr = $stderrTask.GetAwaiter().GetResult()
        Set-Content -LiteralPath $row.stdout -Value $stdout -Encoding utf8
        Set-Content -LiteralPath $row.stderr -Value $stderr -Encoding utf8
        $lines = @((($stdout + "`n" + $stderr) -split '\r?\n') | Where-Object { $_ -match 'SCRIPT ERROR|ERROR:|WARNING:' })
        foreach ($line in $lines) {
            if ($IsImport -and $line.Trim() -eq "ERROR: .NET Sdk not found. The required version is '10.0.9'.") { $row.allowed_diagnostics += $line }
            else { $row.diagnostics += $line }
        }
        if ($Label -eq 'engine-version') { $report.engine_version = $stdout.Trim() }
        $row.status = if ($row.timed_out) {'timeout'} elseif ($row.exit_code -ne 0 -or $row.diagnostics.Count -gt 0) {'failed'} else {'passed'}
    } catch {
        $row.error = $_.Exception.Message
        $row.status = 'failed'
    } finally {
        if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        # Retain output even when an unexpected failure interrupts a case.
        if ($stdoutTask -and -not (Test-Path -LiteralPath $row.stdout)) { Set-Content -LiteralPath $row.stdout -Value $stdoutTask.GetAwaiter().GetResult() -Encoding utf8 }
        if ($stderrTask -and -not (Test-Path -LiteralPath $row.stderr)) { Set-Content -LiteralPath $row.stderr -Value $stderrTask.GetAwaiter().GetResult() -Encoding utf8 }
        $process.Dispose()
        $row.finished_utc = [DateTime]::UtcNow.ToString('o')
        Write-RunReport
    }
    return $row.status -eq 'passed'
}
Write-RunReport
try {
    if (-not (Test-Path -LiteralPath $EnginePath -PathType Leaf)) { throw "Godot executable absent: $EnginePath" }
    # pwsh -File can bind comma names as one string: normalize before launching.
    $expanded = @($Names | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() })
    if ($expanded.Count -eq 0 -and -not $RenderScript -and -not $Import) { throw 'No checks requested.' }
    if (@($expanded | Select-Object -Unique).Count -ne $expanded.Count) { throw 'Duplicate check names.' }
    $scripts = @($expanded | ForEach-Object { Resolve-CheckScript $_ })
    if (@($scripts | Select-Object -Unique).Count -ne $scripts.Count) { throw 'Duplicate resolved check scripts.' }
    $render = if ($RenderScript) { Resolve-CheckScript $RenderScript } else { $null }
    $phases = @($RenderPhases | ForEach-Object { $_ -split ',' })
    if ($render -and ($phases.Count -eq 0 -or @($phases | Where-Object { $_ -notmatch '^[a-z][a-z0-9_-]{0,31}$' }).Count -gt 0 -or @($phases | Select-Object -Unique).Count -ne $phases.Count)) { throw 'Invalid or duplicate render phases.' }
    if (-not (Invoke-OwnedGodot 'engine-version' @('--headless','--version'))) { throw 'Engine preflight failed.' }
    if ($Import -and -not (Invoke-OwnedGodot 'import' @('--headless','--editor','--path',(Join-Path $projectRoot 'game'),'--import','--quit') $true)) { throw 'Import failed.' }
    foreach ($script in $scripts) {
        $null = Invoke-OwnedGodot ($script.Substring(12).Replace('.gd','')) @('--headless','--path',(Join-Path $projectRoot 'game'),'--script',$script,'--',('--save-slot=' + $report.save_slot))
    }
    if ($render) {
        foreach ($phase in $phases) {
            $renderArguments = @('--path',(Join-Path $projectRoot 'game'),'--script',$render,'--',('--save-slot=' + $report.save_slot),('--phase=' + $phase),("--report-dir=res://../docs/evidence/$Task/$runId/render"))
            if (-not (Invoke-OwnedGodot ("render-$phase") $renderArguments)) { break } # dependent phases never follow a failed writer
        }
    }
    $report.status = if (@($report.cases | Where-Object status -ne 'passed').Count -eq 0) {'passed'} else {'failed'}
} catch {
    $report.error = $_.Exception.Message
    $report.status = 'failed'
} finally {
    $report.finished_utc = [DateTime]::UtcNow.ToString('o')
    Write-RunReport
    Write-Output ("REPORT=" + $reportPath)
    Write-Output ("RESULT=" + $report.status)
}
if ($report.status -ne 'passed') { exit 1 }
