#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Z][A-Z0-9_-]{0,31}$')][string]$Task,
    [string[]]$Names = @('application_smoke'),
    [switch]$Import,
    [switch]$RenderOnly,
    [string]$RenderScript,
    [string[]]$RenderPhases = @('write','read'),
    [string[]]$ParseScripts = @(),
    [ValidateRange(1,900)][int]$TimeoutSeconds = 120,
    [string]$EnginePath = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'testing_paths.ps1')
if (-not ('GodotLogPump' -as [type])) { Add-Type -Path (Join-Path $PSScriptRoot 'godot_log_pump.cs') }
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
function Write-RunReport {
    $temporary = $reportPath + '.tmp'
    [IO.File]::WriteAllText($temporary, ($report | ConvertTo-Json -Depth 30), [Text.UTF8Encoding]::new($false))
    [IO.File]::Move($temporary, $reportPath, $true)
}
function Resolve-CheckScript([string]$Name) {
    $clean = $Name.Trim() -replace '\.gd$',''
    if ($clean -notmatch '^[A-Za-z0-9_-]+(?:/[A-Za-z0-9_-]+)*$') { throw "Invalid check name: $Name" }
    $scriptPath = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot "game/tests/$clean.gd") 'game/tests'
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) { throw "Check script absent: $clean" }
    return "res://tests/$clean.gd"
}
function Resolve-ParseScript([string]$Name) {
    $clean = $Name.Trim() -replace '^res://','' -replace '\.gd$',''
    if ($clean -notmatch '^[A-Za-z0-9_-]+(?:/[A-Za-z0-9_-]+)*$') { throw "Invalid parse script: $Name" }
    $path = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot "game/$clean.gd") 'game'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Parse script absent: $clean" }
    return "res://$clean.gd"
}
function Assert-EvidenceRouting([string]$Script) {
    $source = Get-Content -LiteralPath (Join-Path $projectRoot ('game/' + $Script.Substring(6))) -Raw
    # Reject known legacy destinations before executing the check. This is a
    # source guard for project fixtures, not a sandbox for arbitrary scripts.
    if ($source -match 'res://\.\./docs/evidence/[PMW]\d{3}(?:/|["\x27])') {
        throw "Fixed historical evidence destination in $Script; use TestRunEvidence."
    }
}
function Get-ParseClosure([string[]]$Seeds) {
    $pending = [Collections.Generic.Queue[string]]::new()
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $found = [Collections.Generic.List[string]]::new()
    foreach ($seed in $Seeds) { $pending.Enqueue($seed) }
    while ($pending.Count -gt 0) {
        $resource = $pending.Dequeue()
        if (-not $seen.Add($resource)) { continue }
        $path = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot ('game/' + $resource.Substring(6))) 'game'
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Parse dependency absent: $resource" }
        if ($resource.EndsWith('.gd')) { $found.Add($resource); Assert-EvidenceRouting $resource }
        $source = Get-Content -LiteralPath $path -Raw
        # Follow literal script/scene references, including load() branches which
        # --check-only on the caller alone would never compile. Computed paths
        # must be supplied explicitly through ParseScripts.
        foreach ($match in [regex]::Matches($source, '["\x27](res://[A-Za-z0-9_/-]+\.(?:gd|tscn))["\x27]')) {
            $dependency = $match.Groups[1].Value
            $dependencyPath = Resolve-ProjectChildPath $projectRoot (Join-Path $projectRoot ('game/' + $dependency.Substring(6))) 'game'
            # Missing literals can be deliberate rejection fixtures. Explicit
            # selected/ParseScripts paths must exist; absent embedded paths do not.
            if (Test-Path -LiteralPath $dependencyPath -PathType Leaf) { $pending.Enqueue($dependency) }
        }
    }
    return $found.ToArray()
}
function Invoke-OwnedGodot([string]$Label, [string[]]$EngineArguments, [bool]$IsImport = $false, [string]$EvidenceDirectory = '') {
    $safeLabel = $report.cases.Count.ToString('D2') + '-' + $Label.Replace('/','-')
    $row = [ordered]@{label=$Label; arguments=$EngineArguments; launcher_pid=$null; engine_pids=@(); exit_code=$null; timed_out=$false; stopped_on_diagnostic=$false; evidence_directory=$EvidenceDirectory; mode=$(if ($EngineArguments -contains '--headless') {'headless'} else {'rendered-debug'}); status='running'; stdout=(Join-Path $runDirectory "$safeLabel.stdout.log"); stderr=(Join-Path $runDirectory "$safeLabel.stderr.log"); diagnostics=@(); allowed_diagnostics=@(); error=$null; started_utc=[DateTime]::UtcNow.ToString('o'); finished_utc=$null}
    $report.cases += $row
    Write-RunReport
    $process = [Diagnostics.Process]::new()
    $started = $false
    $stdoutTask = $null
    $stderrTask = $null
    $diagnostics = [Collections.Concurrent.ConcurrentQueue[string]]::new()
    $fatalAt = $null
    function Read-Diagnostics {
        $line = ''
        while ($diagnostics.TryDequeue([ref]$line)) {
            if ($IsImport -and $line.Trim() -eq "ERROR: .NET Sdk not found. The required version is '10.0.9'.") { $row.allowed_diagnostics += $line }
            else { $row.diagnostics += $line }
        }
    }
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
        $info.Environment['RETURNING_FAIR_EVIDENCE_DIR'] = $EvidenceDirectory
        $process.StartInfo = $info
        $started = $process.Start()
        if (-not $started) { throw 'Godot process did not start.' }
        $row.launcher_pid = $process.Id
        Write-RunReport
        $stdoutTask = [GodotLogPump]::CopyAsync($process.StandardOutput, $row.stdout, $diagnostics)
        $stderrTask = [GodotLogPump]::CopyAsync($process.StandardError, $row.stderr, $diagnostics)
        # Record only descendants of the exact process we just created.
        $lifetime = [Diagnostics.Stopwatch]::StartNew()
        if ([IO.Path]::GetFileName($EnginePath) -notlike '*_console.exe') { $row.engine_pids = @($process.Id) }
        while (-not $process.WaitForExit(250)) {
            Read-Diagnostics
            if ($row.diagnostics.Count -gt 0) {
                if ($null -eq $fatalAt) { $fatalAt = $lifetime.Elapsed.TotalSeconds; Write-RunReport }
                # Leave a short drain window for the diagnostic's stack trace.
                elseif ($lifetime.Elapsed.TotalSeconds - $fatalAt -ge 0.25) { $row.stopped_on_diagnostic = $true; $process.Kill($true); $process.WaitForExit(); break }
            }
            if ($row.engine_pids.Count -eq 0) {
                $row.engine_pids = @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$($process.Id)" | Where-Object { $_.Name -eq ([IO.Path]::GetFileName($EnginePath).Replace("_console.exe", ".exe")) } | Select-Object -ExpandProperty ProcessId)
            }
            if ($lifetime.Elapsed.TotalSeconds -ge $TimeoutSeconds) { $row.timed_out = $true; $process.Kill($true); $process.WaitForExit(); break }
        }
        $row.exit_code = $process.ExitCode
        $null = $stdoutTask.GetAwaiter().GetResult()
        $null = $stderrTask.GetAwaiter().GetResult()
        Read-Diagnostics
        if ($Label -eq 'engine-version') { $report.engine_version = (Get-Content -LiteralPath $row.stdout -Raw).Trim() }
        $row.status = if ($row.timed_out) {'timeout'} elseif ($row.exit_code -ne 0 -or $row.diagnostics.Count -gt 0) {'failed'} else {'passed'}
    } catch {
        $row.error = $_.Exception.Message
        $row.status = 'failed'
    } finally {
        if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        # Retain output even when an unexpected failure interrupts a case.
        if ($stdoutTask) { $null = $stdoutTask.GetAwaiter().GetResult() }
        if ($stderrTask) { $null = $stderrTask.GetAwaiter().GetResult() }
        Read-Diagnostics
        $process.Dispose()
        $row.finished_utc = [DateTime]::UtcNow.ToString('o')
        Write-RunReport
    }
    return $row.status -eq 'passed'
}
Write-RunReport
Write-Output ("RUN_REPORT=" + $reportPath)
try {
    if (-not (Test-Path -LiteralPath $EnginePath -PathType Leaf)) { throw "Godot executable absent: $EnginePath" }
    if ($RenderOnly -and -not $RenderScript) { throw 'RenderOnly requires RenderScript.' }
    if ($RenderOnly -and $PSBoundParameters.ContainsKey('Names')) { throw 'RenderOnly cannot be combined with Names.' }
    # pwsh -File can bind comma names as one string: normalize before launching.
    $expanded = @()
    if (-not $RenderOnly) { $expanded = @($Names | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
    if ($expanded.Count -eq 0 -and -not $RenderScript -and -not $Import) { throw 'No checks requested.' }
    if (@($expanded | Select-Object -Unique).Count -ne $expanded.Count) { throw 'Duplicate check names.' }
    $scripts = @($expanded | ForEach-Object { Resolve-CheckScript $_ })
    if (@($scripts | Select-Object -Unique).Count -ne $scripts.Count) { throw 'Duplicate resolved check scripts.' }
    $render = if ($RenderScript) { Resolve-CheckScript $RenderScript } else { $null }
    $parse = @(Get-ParseClosure (@($scripts) + @($render | Where-Object { $_ }) + @($ParseScripts | ForEach-Object { $_ -split ',' } | ForEach-Object { Resolve-ParseScript $_ })))
    $report['parse_scripts'] = $parse
    $harness = @('extends SceneTree')
    for ($index = 0; $index -lt $parse.Count; $index++) { $harness += ('const SCRIPT_{0} = preload("{1}")' -f $index,$parse[$index]) }
    $parsePath = Join-Path $staging 'parse_preflight.gd'
    $harness | Set-Content -LiteralPath $parsePath -Encoding utf8
    $phases = @($RenderPhases | ForEach-Object { $_ -split ',' })
    if ($render -and ($phases.Count -eq 0 -or @($phases | Where-Object { $_ -notmatch '^[a-z][a-z0-9_-]{0,31}$' }).Count -gt 0 -or @($phases | Select-Object -Unique).Count -ne $phases.Count)) { throw 'Invalid or duplicate render phases.' }
    if (-not (Invoke-OwnedGodot 'engine-version' @('--headless','--version'))) { throw 'Engine preflight failed.' }
    if ($Import -and -not (Invoke-OwnedGodot 'import' @('--headless','--editor','--path',(Join-Path $projectRoot 'game'),'--import','--quit') $true)) { throw 'Import failed.' }
    if ($parse.Count -gt 0 -and -not (Invoke-OwnedGodot 'parse-preflight' @('--headless','--path',(Join-Path $projectRoot 'game'),'--check-only','--script',("res://../builds/testing/$Task/$runId/parse_preflight.gd")))) { throw 'Parse preflight failed; see parse_scripts and diagnostic logs.' }
    foreach ($script in $scripts) {
        $checkLabel = $script.Substring(12).Replace('.gd','')
        $destination = "res://../docs/evidence/$Task/$runId/checks/$checkLabel"
        $null = Invoke-OwnedGodot $checkLabel @('--headless','--path',(Join-Path $projectRoot 'game'),'--script',$script,'--',('--save-slot=' + $report.save_slot),("--report-dir=$destination")) $false (Join-Path $projectRoot "docs/evidence/$Task/$runId/checks/$checkLabel")
    }
    if ($render -and @($report.cases | Where-Object status -ne 'passed').Count -eq 0) {
        foreach ($phase in $phases) {
            $renderArguments = @('--path',(Join-Path $projectRoot 'game'),'--script',$render,'--',('--save-slot=' + $report.save_slot),('--phase=' + $phase),("--report-dir=res://../docs/evidence/$Task/$runId/render"))
            if (-not (Invoke-OwnedGodot ("render-$phase") $renderArguments $false (Join-Path $runDirectory 'render'))) { break } # dependent phases never follow a failed writer
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
