# Pure request validation and bounded dispatch, shared by the native entrypoint
# and deterministic fault-injection tests. This file performs no OS input itself.
function Get-NativeInputKeys {
    return @{ W=0x57; A=0x41; S=0x53; D=0x44; E=0x45; J=0x4A; B=0x42; F=0x46; SPACE=0x20; ESC=0x1B; R=0x52; F10=0x79; TAB=0x09; ENTER=0x0D }
}
function Assert-NativeInteger($Value, [int]$Minimum, [int]$Maximum, [string]$Name) {
    if (($Value -isnot [int] -and $Value -isnot [long]) -or $Value -lt $Minimum -or $Value -gt $Maximum) {
        throw "$Name must be an integer in $Minimum..$Maximum."
    }
}
function Get-NativeFields($Object) {
    if ($Object -is [Collections.IDictionary]) { return @($Object.psbase.Keys) }
    if ($Object -is [pscustomobject]) { return @($Object.PSObject.Properties.Name) }
    throw 'Expected a JSON object.'
}
function Assert-NativeInputRequest($Request) {
    $fields = @(Get-NativeFields $Request)
    if ($fields.Count -ne 1 -or $fields[0] -cne 'steps') { throw 'Request requires only steps.' }
    if ($Request.steps -isnot [array] -or $Request.steps.Count -lt 1 -or $Request.steps.Count -gt 32) { throw 'Expected 1-32 steps.' }
    $keys = Get-NativeInputKeys
    $totalMs = 0
    for ($index = 0; $index -lt $Request.steps.Count; $index++) {
        $step = $Request.steps[$index]
        $fields = @(Get-NativeFields $step)
        if ('op' -cnotin $fields) { throw 'Step requires op.' }
        $required = @(switch -CaseSensitive ($step.op) {
            'hold' { @('op','keys','duration_ms') }
            'wait' { @('op','duration_ms') }
            'pointer' { @('op','x','y') }
            'click' { @('op','x','y') }
            'drag' { @('op','from_x','from_y','to_x','to_y','duration_ms') }
            'capture' { @('op','label') }
            'quit' { @('op') }
            default { throw "Unknown operation: $($step.op)" }
        })
        if ($fields.Count -ne $required.Count -or @($required | Where-Object { $_ -cnotin $fields }).Count -gt 0) {
            throw "Invalid fields for $($step.op): expected $($required -join ', ')."
        }
        if ($step.op -in @('hold','wait','drag')) {
            Assert-NativeInteger $step.duration_ms 16 5000 'duration_ms'
            $totalMs += $step.duration_ms
        }
        if ($step.op -in @('click','quit')) { $totalMs += 50 }
        if ($step.op -eq 'hold') {
            if ($step.keys -isnot [array] -or $step.keys.Count -lt 1 -or $step.keys.Count -gt 4) { throw 'Hold requires 1-4 keys.' }
            foreach ($key in $step.keys) {
                if ($key -isnot [string] -or -not $keys.ContainsKey($key)) { throw "Key not allowed: $key" }
            }
            if (@($step.keys | ForEach-Object { $_.ToUpperInvariant() } | Select-Object -Unique).Count -ne $step.keys.Count) { throw 'Duplicate key.' }
        }
        foreach ($coordinate in @('x','y','from_x','from_y','to_x','to_y') | Where-Object { $_ -cin $fields }) {
            Assert-NativeInteger $step.$coordinate 0 32767 $coordinate
        }
        if ($step.op -eq 'capture' -and ($step.label -isnot [string] -or $step.label -cnotmatch '^[A-Za-z0-9_-]{1,64}$')) { throw 'Invalid capture label.' }
        if ($step.op -eq 'quit' -and $index -ne $Request.steps.Count - 1) { throw 'Quit must be final step.' }
    }
    if ($totalMs -gt 30000) { throw 'Request exceeds 30 seconds including click/quit waits.' }
    $labels = @($Request.steps | Where-Object op -eq 'capture' | ForEach-Object label)
    if (@($labels | ForEach-Object { $_.ToUpperInvariant() } | Select-Object -Unique).Count -ne $labels.Count) { throw 'Duplicate capture labels.' }
    return $totalMs
}
function Release-NativeOwnedInputs($Owned, [scriptblock]$Dispatch, $Errors) {
    # Releases intentionally bypass the foreground guard after focus loss. Release
    # only inputs this request acquired; attempt all even if one SendInput fails.
    foreach ($vk in @($Owned.keys.ToArray())) {
        try { $null = & $Dispatch 'Key' @($vk, $true); $null = $Owned.keys.Remove($vk) }
        catch { $Errors.Add("Key release ${vk}: $($_.Exception.Message)") }
    }
    if ($Owned.mouse) {
        try { $null = & $Dispatch 'Mouse' @($true); $Owned.mouse = $false }
        catch { $Errors.Add("Mouse release: $($_.Exception.Message)") }
    }
}
function Invoke-NativeInputSteps([array]$Steps, [scriptblock]$Dispatch) {
    $trace = [Collections.Generic.List[object]]::new()
    $cleanupErrors = [Collections.Generic.List[string]]::new()
    $owned = @{ keys=[Collections.Generic.List[int]]::new(); mouse=$false }
    $keys = Get-NativeInputKeys
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $failure = $null
    $failedStep = $null
    $budget = $null
    try {
        $budget = Assert-NativeInputRequest @{steps=$Steps}
        # Validate every client coordinate before acquiring any key/button.
        $null = & $Dispatch 'Guard' @()
        foreach ($step in $Steps) {
            if ($step.op -in @('pointer','click')) { $null = & $Dispatch 'ValidatePoint' @($step.x, $step.y) }
            if ($step.op -eq 'drag') {
                $null = & $Dispatch 'ValidatePoint' @($step.from_x, $step.from_y)
                $null = & $Dispatch 'ValidatePoint' @($step.to_x, $step.to_y)
            }
        }
        for ($index = 0; $index -lt $Steps.Count; $index++) {
            $step = $Steps[$index]
            $started = $timer.Elapsed.TotalMilliseconds
            $stepError = $null
            try {
                $null = & $Dispatch 'Guard' @()
                switch ($step.op) {
                    'hold' {
                        foreach ($key in $step.keys) {
                            $vk = $keys[$key]; $null = & $Dispatch 'Key' @($vk, $false); $owned.keys.Add($vk)
                        }
                        $null = & $Dispatch 'Wait' @($step.duration_ms)
                    }
                    'wait' { $null = & $Dispatch 'Wait' @($step.duration_ms) }
                    'pointer' { $null = & $Dispatch 'Pointer' @($step.x, $step.y) }
                    'click' {
                        $null = & $Dispatch 'Pointer' @($step.x, $step.y)
                        $null = & $Dispatch 'Mouse' @($false); $owned.mouse = $true
                        $null = & $Dispatch 'Wait' @(50)
                    }
                    'drag' {
                        $null = & $Dispatch 'Pointer' @($step.from_x, $step.from_y)
                        $null = & $Dispatch 'Mouse' @($false); $owned.mouse = $true
                        # Straight client-space path. Settle both press and final
                        # preview while down; integer waits sum to duration_ms.
                        $samples = [Math]::Max(2, [int][Math]::Ceiling($step.duration_ms / 16.0))
                        for ($sample = 0; $sample -lt $samples; $sample++) {
                            $fraction = $sample / ($samples - 1.0)
                            $x = [int][Math]::Round($step.from_x + ($step.to_x - $step.from_x) * $fraction)
                            $y = [int][Math]::Round($step.from_y + ($step.to_y - $step.from_y) * $fraction)
                            $null = & $Dispatch 'Pointer' @($x, $y)
                            $wait = [int][Math]::Floor(($sample + 1) * $step.duration_ms / [double]$samples) - [int][Math]::Floor($sample * $step.duration_ms / [double]$samples)
                            $null = & $Dispatch 'Wait' @($wait)
                        }
                    }
                    'capture' { $null = & $Dispatch 'Capture' @($step.label) }
                    'quit' {
                        $null = & $Dispatch 'Key' @(0x79, $false); $owned.keys.Add(0x79)
                        $null = & $Dispatch 'WaitForQuit' @(50)
                    }
                }
            } catch { $stepError = $_.Exception.Message; throw }
            finally {
                Release-NativeOwnedInputs $owned $Dispatch $cleanupErrors
                if ($cleanupErrors.Count -gt 0 -and $null -eq $stepError) { $stepError = $cleanupErrors[-1] }
                $trace.Add(@{ index=$index; step=$step; ok=($null -eq $stepError); error=$stepError; elapsed_ms=$timer.Elapsed.TotalMilliseconds-$started; completed_utc=[DateTime]::UtcNow.ToString('o') })
                if ($null -ne $stepError) { $failedStep = $index }
            }
            if ($cleanupErrors.Count -gt 0) { throw $cleanupErrors[-1] }
        }
    } catch { $failure = $_.Exception.Message }
    finally { Release-NativeOwnedInputs $owned $Dispatch $cleanupErrors }
    return @{ ok=($null -eq $failure -and $cleanupErrors.Count -eq 0); error=$failure; failed_step=$failedStep;
        cleanup_errors=@($cleanupErrors.ToArray()); unreleased_keys=@($owned.keys.ToArray()); mouse_unreleased=$owned.mouse;
        requested_duration_ms=$budget; steps=@($trace.ToArray()); elapsed_ms=$timer.Elapsed.TotalMilliseconds }
}
