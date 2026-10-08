#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Z][A-Z0-9_-]{0,31}$')][string]$Task,
    [string[]]$Names = @('application_smoke'),
    [switch]$Import,
    [string[]]$ProcessScripts = @(),
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
. (Join-Path $PSScriptRoot 'testing_runner_observation.ps1')
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
$report = [ordered]@{schema_version=2; task=$Task; run_id=$runId; cwd=$projectRoot; engine_path=$EnginePath; engine_version=$null; appdata=$appData; localappdata=$localData; save_groups=@(); source=[ordered]@{before=$null; after=$null; git=$null; changed=$false; changes=@(); error=$null}; started_utc=[DateTime]::UtcNow.ToString('o'); finished_utc=$null; status='running'; error=$null; cases=@()}
$sourceBaseline = $null
function Write-RunReport {
    $temporary = $reportPath + '.tmp'
    [IO.File]::WriteAllText($temporary, ($report | ConvertTo-Json -Depth 30), [Text.UTF8Encoding]::new($false))
    # Windows readers may briefly hold the destination without delete sharing.
    # Keep publication atomic; retry the same staged bytes for at most one second.
    $publishWait = [Diagnostics.Stopwatch]::StartNew()
    while ($true) {
        try { [IO.File]::Move($temporary, $reportPath, $true); break }
        catch [IO.IOException] {
            if ($publishWait.Elapsed.TotalSeconds -ge 1) { throw }
            Start-Sleep -Milliseconds 25
        } catch [UnauthorizedAccessException] {
            if ($publishWait.Elapsed.TotalSeconds -ge 1) { throw }
            Start-Sleep -Milliseconds 25
        }
    }
}
function Record-SourceChanges($Changes, [string]$Checkpoint) {
    if ($Changes.Count -eq 0) { return }
    $report.source.changed = $true
    foreach ($change in $Changes) {
        $report.source.changes += [ordered]@{checkpoint=$Checkpoint; path=$change.path; change=$change.change; before_sha256=$change.before_sha256; after_sha256=$change.after_sha256}
        [Console]::WriteLine("SOURCE_CHANGED checkpoint=$Checkpoint change=$($change.change) path=$($change.path)")
    }
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
function New-SaveGroup([string]$Kind, [string]$Script) {
    $id = $Kind + '-' + $report.save_groups.Count.ToString('D3')
    $group = [ordered]@{id=$id; kind=$Kind; script=$Script; save_slot=('check-' + $runId + '-' + $report.save_groups.Count.ToString('D3')); appdata=(Join-Path $appData $id); localappdata=(Join-Path $localData $id)}
    New-Item -ItemType Directory -Path $group.appdata,$group.localappdata | Out-Null
    $report.save_groups += $group
    return $group
}
function Invoke-OwnedGodot([string]$Label, [string[]]$EngineArguments, [bool]$IsImport = $false, [string]$EvidenceDirectory = '', $SaveGroup = $null) {
    $safeLabel = $report.cases.Count.ToString('D2') + '-' + $Label.Replace('/','-')
    $caseAppData = if ($SaveGroup) { $SaveGroup.appdata } else { $appData }
    $caseLocalData = if ($SaveGroup) { $SaveGroup.localappdata } else { $localData }
    $row = [ordered]@{label=$Label; arguments=$EngineArguments; save_group=$(if ($SaveGroup) {$SaveGroup.id} else {$null}); save_slot=$(if ($SaveGroup) {$SaveGroup.save_slot} else {$null}); appdata=$caseAppData; localappdata=$caseLocalData; launcher_pid=$null; engine_pids=@(); exit_code=$null; timed_out=$false; stopped_on_diagnostic=$false; evidence_directory=$EvidenceDirectory; mode=$(if ($EngineArguments -contains '--headless') {'headless'} else {'rendered-debug'}); status='running'; stdout=(Join-Path $runDirectory "$safeLabel.stdout.log"); stderr=(Join-Path $runDirectory "$safeLabel.stderr.log"); diagnostics=@(); allowed_diagnostics=@(); source_before=$null; source_after=$null; source_changes=@(); failure_summary=$null; error=$null; started_utc=[DateTime]::UtcNow.ToString('o'); finished_utc=$null}
    $report.cases += $row
    Write-RunReport
    [Console]::WriteLine("CASE_START index=$($report.cases.Count) label=$Label timeout=${TimeoutSeconds}s stdout=$($row.stdout) stderr=$($row.stderr)")
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
            else {
                if ($row.diagnostics.Count -eq 0) { [Console]::WriteLine("CASE_DIAGNOSTIC label=$Label message=$line") }
                $row.diagnostics += $line
            }
        }
    }
    try {
        try {
            $before = Get-RunnerSourceSnapshot $projectRoot
            $row.source_before = Save-RunnerSourceSnapshot $before (Join-Path $runDirectory "$safeLabel.source-before.json")
        } catch { $report.source.error = $_.Exception.Message; throw }
        $row.source_changes = @(Compare-RunnerSourceSnapshots $sourceBaseline $before)
        Record-SourceChanges $row.source_changes "$Label-before"
        if ($row.source_changes.Count -gt 0) { throw 'Source changed before launch; rerun against stable source.' }
        $info = [Diagnostics.ProcessStartInfo]::new()
        $info.FileName = $EnginePath
        $info.WorkingDirectory = $projectRoot
        $info.UseShellExecute = $false
        $info.CreateNoWindow = $true
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        foreach ($argument in $EngineArguments) { $info.ArgumentList.Add($argument) }
        $info.Environment['APPDATA'] = $caseAppData
        $info.Environment['LOCALAPPDATA'] = $caseLocalData
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
        $nextProgress = 5.0
        if ([IO.Path]::GetFileName($EnginePath) -notlike '*_console.exe') { $row.engine_pids = @($process.Id) }
        while (-not $process.WaitForExit(250)) {
            Read-Diagnostics
            if ($lifetime.Elapsed.TotalSeconds -ge $nextProgress) {
                [Console]::WriteLine("CASE_RUNNING label=$Label elapsed=$([Math]::Round($lifetime.Elapsed.TotalSeconds,1))s timeout=${TimeoutSeconds}s")
                $nextProgress = $lifetime.Elapsed.TotalSeconds + 5.0
            }
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
        try {
            $after = Get-RunnerSourceSnapshot $projectRoot
            $row.source_after = Save-RunnerSourceSnapshot $after (Join-Path $runDirectory "$safeLabel.source-after.json")
            $changes = @(Compare-RunnerSourceSnapshots $sourceBaseline $after)
            $row.source_changes += $changes
            Record-SourceChanges $changes "$Label-after"
            if ($row.source_changes.Count -gt 0) { $row.status = 'failed'; $row.error = 'Source changed during run; evidence is not valid for stable source. Rerun after edits stop.' }
        } catch {
            $report.source.error = $_.Exception.Message
            $row.error = "Source verification failed: $($_.Exception.Message)"
            $row.status = 'failed'
        }
        $row.finished_utc = [DateTime]::UtcNow.ToString('o')
        Write-RunnerCaseResult $row $TimeoutSeconds
        Write-RunReport
    }
    if ($report.source.changed -or $report.source.error) { throw $row.error }
    return $row.status -eq 'passed'
}
Write-RunReport
Write-Output ("RUN_REPORT=" + $reportPath)
try {
    if (-not (Test-Path -LiteralPath $EnginePath -PathType Leaf)) { throw "Godot executable absent: $EnginePath" }
    if ($RenderOnly -and -not $RenderScript) { throw 'RenderOnly requires RenderScript.' }
    if ($RenderOnly -and $ProcessScripts.Count -gt 0) { throw 'RenderOnly cannot be combined with ProcessScripts.' }
    if ($RenderOnly -and $PSBoundParameters.ContainsKey('Names')) { throw 'RenderOnly cannot be combined with Names.' }
    # pwsh -File can bind comma names as one string: normalize before launching.
    $expanded = @()
    if (-not $RenderOnly) { $expanded = @($Names | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
    if ($expanded.Count -eq 0 -and $ProcessScripts.Count -eq 0 -and -not $RenderScript -and -not $Import) { throw 'No checks requested.' }
    if (@($expanded | Select-Object -Unique).Count -ne $expanded.Count) { throw 'Duplicate check names.' }
    $scripts = @($expanded | ForEach-Object { Resolve-CheckScript $_ })
    if (@($scripts | Select-Object -Unique).Count -ne $scripts.Count) { throw 'Duplicate resolved check scripts.' }
    $processScriptsResolved = @($ProcessScripts | ForEach-Object { $_ -split ',' } | ForEach-Object { Resolve-CheckScript $_ })
    if (@($processScriptsResolved | Select-Object -Unique).Count -ne $processScriptsResolved.Count) { throw 'Duplicate process scripts.' }
    if (@($processScriptsResolved | Where-Object { $_ -in $scripts }).Count -gt 0) { throw 'Process scripts must not also run as single-phase checks.' }
    $render = if ($RenderScript) { Resolve-CheckScript $RenderScript } else { $null }
    try {
        $sourceBaseline = Get-RunnerSourceSnapshot $projectRoot
        $report.source.before = Save-RunnerSourceSnapshot $sourceBaseline (Join-Path $runDirectory 'source-before.json')
    }
    catch { $report.source.error = $_.Exception.Message; throw }
    $report.source.git = Get-RunnerGitContext $projectRoot
    [Console]::WriteLine("SOURCE_BASELINE sha256=$($sourceBaseline.sha256) files=$($sourceBaseline.file_count) manifest=$($report.source.before.manifest)")
    Write-RunReport
    $parse = @(Get-ParseClosure (@($scripts) + @($processScriptsResolved) + @($render | Where-Object { $_ }) + @($ParseScripts | ForEach-Object { $_ -split ',' } | ForEach-Object { Resolve-ParseScript $_ })))
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
        $group = New-SaveGroup 'check' $script
        $checkLabel = $script.Substring(12).Replace('.gd','')
        $destination = "res://../docs/evidence/$Task/$runId/checks/$checkLabel"
        $null = Invoke-OwnedGodot $checkLabel @('--headless','--path',(Join-Path $projectRoot 'game'),'--script',$script,'--',('--save-slot=' + $group.save_slot),("--report-dir=$destination")) $false (Join-Path $projectRoot "docs/evidence/$Task/$runId/checks/$checkLabel") $group
    }
    foreach ($processScript in $processScriptsResolved) {
        if (@($report.cases | Where-Object status -ne 'passed').Count -gt 0) { break }
        $group = New-SaveGroup 'process' $processScript
        $processLabel = $processScript.Substring(12).Replace('.gd','')
        foreach ($phase in @('write','read')) {
            $destination = "res://../docs/evidence/$Task/$runId/process/$processLabel"
            $processArguments = @('--headless','--path',(Join-Path $projectRoot 'game'),'--script',$processScript,'--',('--save-slot=' + $group.save_slot),('--phase=' + $phase),("--report-dir=$destination"))
            if (-not (Invoke-OwnedGodot ("$processLabel-$phase") $processArguments $false (Join-Path $projectRoot "docs/evidence/$Task/$runId/process/$processLabel") $group)) { break }
        }
    }
    if ($render -and @($report.cases | Where-Object status -ne 'passed').Count -eq 0) {
        $group = New-SaveGroup 'render' $render
        foreach ($phase in $phases) {
            $renderArguments = @('--path',(Join-Path $projectRoot 'game'),'--script',$render,'--',('--save-slot=' + $group.save_slot),('--phase=' + $phase),("--report-dir=res://../docs/evidence/$Task/$runId/render"))
            if (-not (Invoke-OwnedGodot ("render-$phase") $renderArguments $false (Join-Path $runDirectory 'render') $group)) { break } # dependent phases never follow a failed writer
        }
    }
    $report.status = if (@($report.cases | Where-Object status -ne 'passed').Count -eq 0) {'passed'} else {'failed'}
} catch {
    $report.error = $_.Exception.Message
    $report.status = 'failed'
} finally {
    if ($null -ne $sourceBaseline) {
        try {
            $finalSource = Get-RunnerSourceSnapshot $projectRoot
            $report.source.after = Save-RunnerSourceSnapshot $finalSource (Join-Path $runDirectory 'source-after.json')
            Record-SourceChanges @(Compare-RunnerSourceSnapshots $sourceBaseline $finalSource) 'run-final'
        } catch { $report.source.error = $_.Exception.Message }
        if ($report.source.changed -or $report.source.error) {
            $report.status = 'failed'
            if (-not $report.error) { $report.error = if ($report.source.error) {"Source verification failed: $($report.source.error)"} else {'Source changed during run; rerun against stable source.'} }
        }
    }
    $report.finished_utc = [DateTime]::UtcNow.ToString('o')
    Write-RunReport
    if ($report.error) { [Console]::WriteLine("RUN_FAILURE=$($report.error)") }
    Write-Output ("REPORT=" + $reportPath)
    Write-Output ("RESULT=" + $report.status)
}
if ($report.status -ne 'passed') { exit 1 }
