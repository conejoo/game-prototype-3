# Runner observations only: no gameplay changes or Git configuration writes.
function Get-RunnerSourceSnapshot([string]$ProjectRoot) {
    $files = [Collections.Generic.SortedDictionary[string,string]]::new([StringComparer]::Ordinal)
    $pending = [Collections.Generic.Stack[string]]::new()
    foreach ($scope in @('game','tools')) { $pending.Push((Join-Path $ProjectRoot $scope)) }
    while ($pending.Count -gt 0) {
        $directory = Get-Item -LiteralPath $pending.Pop() -Force
        if ($directory.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked source directory cannot be fingerprinted: $($directory.FullName)" }
        foreach ($item in Get-ChildItem -LiteralPath $directory.FullName -Force) {
            if ($item.PSIsContainer -and $item.Name -in @('.godot','__pycache__','.git')) { continue }
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked source cannot be fingerprinted: $($item.FullName)" }
            if ($item.PSIsContainer) { $pending.Push($item.FullName); continue }
            if ($item.Extension -in @('.pyc','.pyo')) { continue }
            $relative = [IO.Path]::GetRelativePath($ProjectRoot, $item.FullName).Replace('\','/')
            $files.Add($relative, (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant())
        }
    }
    $entries = @($files.GetEnumerator() | ForEach-Object { [ordered]@{path=$_.Key; sha256=$_.Value} })
    # Stable content identity: ordinal paths and byte hashes, never timestamps or Git state.
    $canonical = ($entries | ForEach-Object { $_.path + "`t" + $_.sha256 + "`n" }) -join ''
    $digest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($canonical))).ToLowerInvariant()
    return [ordered]@{algorithm='SHA256'; sha256=$digest; captured_utc=[DateTime]::UtcNow.ToString('o'); scopes=@('game','tools'); excludes=@('directory:.godot','directory:__pycache__','directory:.git','extension:.pyc','extension:.pyo'); file_count=$entries.Count; files=$entries}
}

function Save-RunnerSourceSnapshot($Snapshot, [string]$Path) {
    [IO.File]::WriteAllText($Path, ($Snapshot | ConvertTo-Json -Depth 8), [Text.UTF8Encoding]::new($false))
    return [ordered]@{sha256=$Snapshot.sha256; captured_utc=$Snapshot.captured_utc; file_count=$Snapshot.file_count; manifest=$Path}
}

function Compare-RunnerSourceSnapshots($Before, $After) {
    $old = [Collections.Generic.Dictionary[string,string]]::new([StringComparer]::Ordinal)
    $new = [Collections.Generic.Dictionary[string,string]]::new([StringComparer]::Ordinal)
    foreach ($entry in $Before.files) { $old[$entry.path] = $entry.sha256 }
    foreach ($entry in $After.files) { $new[$entry.path] = $entry.sha256 }
    $paths = [Collections.Generic.SortedSet[string]]::new([StringComparer]::Ordinal)
    foreach ($path in @($old.Keys) + @($new.Keys)) { $null = $paths.Add($path) }
    foreach ($path in $paths) {
        if (-not $old.ContainsKey($path)) { [ordered]@{path=$path; change='added'; before_sha256=$null; after_sha256=$new[$path]} }
        elseif (-not $new.ContainsKey($path)) { [ordered]@{path=$path; change='removed'; before_sha256=$old[$path]; after_sha256=$null} }
        elseif ($old[$path] -ne $new[$path]) { [ordered]@{path=$path; change='modified'; before_sha256=$old[$path]; after_sha256=$new[$path]} }
    }
}

function Get-RunnerGitContext([string]$ProjectRoot) {
    try {
        $head = @(& git -c "safe.directory=$ProjectRoot" -C $ProjectRoot rev-parse HEAD 2>$null)
        if ($LASTEXITCODE -ne 0) { throw 'Git HEAD unavailable.' }
        $status = @(& git -c "safe.directory=$ProjectRoot" -C $ProjectRoot status --porcelain 2>$null)
        if ($LASTEXITCODE -ne 0) { throw 'Git status unavailable.' }
        return [ordered]@{head=($head -join '').Trim(); working_tree_dirty=($status.Count -gt 0); status=$status; error=$null}
    } catch { return [ordered]@{head=$null; working_tree_dirty=$null; status=@(); error=$_.Exception.Message} }
}

function Get-RunnerFailureSummary($Case, [int]$TimeoutSeconds) {
    $context = @(); $stack = @(); $tail = @(); $assertion = $null
    foreach ($stream in @('stdout','stderr')) {
        $path = $Case[$stream]
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
        $lines = @(Get-Content -LiteralPath $path)
        $first = -1
        for ($index = 0; $index -lt $lines.Count; $index++) {
            $line = $lines[$index]
            if ($first -lt 0 -and ($Case.diagnostics -contains $line -or $line -match '(?i)assertion failed|^\s*(?:FAIL|FAILED):')) { $first = $index }
            if ($null -eq $assertion -and $line -match '(?i)assertion failed') { $assertion = $line.Trim() }
            $entry = [ordered]@{stream=$stream; line_number=($index + 1); text=$line}
            if ($index -ge [Math]::Max(0, $lines.Count - 8)) { $tail += $entry }
            if ($first -ge 0 -and $index -lt $first + 24) {
                $context += $entry
                if ($line -match '^\s*(?:at:|at |\[\d+\]|(?:GDScript |C# )?(?:backtrace|stack trace))') { $stack += $entry }
            }
        }
    }
    $reason = if ($Case.source_changes.Count -gt 0) {'source_changed'} elseif ($Case.timed_out) {'timeout'} elseif ($Case.error) {'runner_error'} elseif ($Case.diagnostics.Count -gt 0) {'diagnostic'} else {'exit_code'}
    $message = if ($Case.error) {$Case.error} elseif ($Case.diagnostics.Count -gt 0) {$Case.diagnostics[0]} elseif ($assertion) {$assertion} elseif ($Case.timed_out) {"Exceeded ${TimeoutSeconds}s timeout."} else {"Engine exited with code $($Case.exit_code)."}
    return [ordered]@{reason=$reason; message=$message; failed_assertion=$assertion; diagnostic_context=$context; stack=$stack; log_tail=$tail; stdout=$Case.stdout; stderr=$Case.stderr}
}

function Write-RunnerCaseResult($Case, [int]$TimeoutSeconds) {
    $seconds = ([DateTime]$Case.finished_utc - [DateTime]$Case.started_utc).TotalSeconds
    [Console]::WriteLine("CASE_END label=$($Case.label) status=$($Case.status) elapsed=$([Math]::Round($seconds,2))s exit=$($Case.exit_code)")
    if ($Case.status -eq 'passed') { return }
    $Case.failure_summary = Get-RunnerFailureSummary $Case $TimeoutSeconds
    [Console]::WriteLine("CASE_FAILURE label=$($Case.label) reason=$($Case.failure_summary.reason) message=$($Case.failure_summary.message)")
    if ($Case.failure_summary.failed_assertion) { [Console]::WriteLine("ASSERTION=$($Case.failure_summary.failed_assertion)") }
    foreach ($entry in $Case.failure_summary.stack) { [Console]::WriteLine("STACK $($entry.stream):$($entry.line_number) $($entry.text)") }
    if ($Case.failure_summary.stack.Count -eq 0) {
        foreach ($entry in $Case.failure_summary.log_tail) { [Console]::WriteLine("LOG_TAIL $($entry.stream):$($entry.line_number) $($entry.text)") }
    }
    [Console]::WriteLine("FAILURE_LOGS stdout=$($Case.stdout) stderr=$($Case.stderr)")
}
