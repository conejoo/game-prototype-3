#Requires -Version 7.0
param(
    [Parameter(Mandatory)][int]$GameProcessId,
    [Parameter(Mandatory)][string]$EvidenceDirectory,
    [Parameter(Mandatory)][string]$StandaloneDirectory,
    [Parameter(Mandatory)][ValidateRange(0,959)][int]$CastX,
    [Parameter(Mandatory)][ValidateRange(0,639)][int]$CastY,
    [ValidateRange(1,40)][int]$WallSeconds=38
)
$ErrorActionPreference='Stop'
$fishingRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. (Join-Path $fishingRoot 'tools/testing_paths.ps1')
. (Join-Path $PSScriptRoot 'hud_pixels.ps1')
Add-Type -AssemblyName System.Drawing
$fishingEvidence=Resolve-NativeEvidenceDirectory $fishingRoot $EvidenceDirectory
$null=Resolve-NativeStandaloneDirectory $fishingRoot $StandaloneDirectory $fishingEvidence
$fishingTemplate=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'bite_pixels.json') -Raw | ConvertFrom-Json
$fishingId=[guid]::NewGuid().ToString('N')
$fishingTrace=@(); $fishingIndex=0; $fishingError=$null; $fishingHooked=$false
function Invoke-FishingInput($Steps) {
    $request=Join-Path $fishingEvidence ('reel-request-'+[guid]::NewGuid().ToString('N')+'.json')
    @{steps=@($Steps)} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $request -Encoding utf8NoBOM
    $response=& (Join-Path $fishingRoot 'tools/native_input.ps1') -TargetProcessId $GameProcessId -CommandFile $request -OutputDirectory $fishingEvidence -StandaloneDirectory $StandaloneDirectory | Out-String | ConvertFrom-Json
    if (-not $response.ok -or $response.cleanup_errors.Count -or $response.unreleased_keys.Count -or $response.mouse_unreleased) {throw ('Native fishing input/cleanup failed: '+$response.error)}
    return $response
}
$fishingTimer=[Diagnostics.Stopwatch]::StartNew()
try {
    # Caller must inspect a real site pause and current client cast coordinates.
    $label='reel-'+$fishingId+'-000'
    $null=Invoke-FishingInput @(@{op='hold';keys=@('ESC');duration_ms=60},@{op='hold';keys=@('F');duration_ms=60},@{op='click';x=$CastX;y=$CastY},@{op='wait';duration_ms=50},@{op='capture';label=$label})
    while ($fishingTimer.Elapsed.TotalSeconds -lt $WallSeconds -and $fishingIndex -lt 100) {
        $bitmap=[Drawing.Bitmap]::new((Join-Path $fishingEvidence ($label+'.png')))
        try {$pixels=Get-FishingHudPixels $bitmap $fishingTemplate} finally {$bitmap.Dispose()}
        $fishingTrace+=@{index=$fishingIndex;seconds=$fishingTimer.Elapsed.TotalSeconds;capture=$label+'.png';pixels=$pixels;hooked=$fishingHooked}
        $fishingIndex++
        $label='reel-'+$fishingId+'-'+$fishingIndex.ToString('000')
        $steps=@()
        if ($pixels.bite -and -not $fishingHooked) {
            $steps+=@{op='hold';keys=@('E');duration_ms=120}; $fishingHooked=$true
        } elseif ($pixels.fight) {
            # Exact package hashing/foreground attachment releases E between requests.
            # Compensate the observed ~0.6s release gap, aiming at rendered ~58%.
            # This changes ordinary input duration only, never game rules or RNG.
            if ($pixels.tension -lt .85) {
                $holdMs=[int][math]::Clamp([math]::Round((.58-$pixels.tension+.32)/.65*1000),16,900)
                $steps+=@{op='hold';keys=@('E');duration_ms=$holdMs}
            } else {$steps+=@{op='wait';duration_ms=32}}
        } elseif ($fishingHooked -or $fishingTimer.Elapsed.TotalSeconds -gt 5) {break}
        else {$steps+=@{op='wait';duration_ms=32}}
        $steps+=@{op='capture';label=$label}
        $null=Invoke-FishingInput $steps
    }
} catch {$fishingError=$_.Exception.Message}
finally {
    # Pause cancels any unfinished attempt. This is not evidence of a live bite/fight.
    try {$null=Invoke-FishingInput @(@{op='capture';label=('reel-'+$fishingId+'-terminal')},@{op='hold';keys=@('ESC');duration_ms=60},@{op='wait';duration_ms=150},@{op='capture';label=('reel-'+$fishingId+'-paused')})} catch {$fishingError=($_.Exception.Message+'; '+$fishingError)}
    $record=@{task='FS008';id=$fishingId;pid=$GameProcessId;provenance='Rendered HUD pixels -> bounded ordinary native E holds; unforced RNG; no bridge/state/memory';seconds=$fishingTimer.Elapsed.TotalSeconds;hooked=$fishingHooked;error=$fishingError;trace=$fishingTrace;terminal_capture=('reel-'+$fishingId+'-terminal.png');pause_capture=('reel-'+$fishingId+'-paused.png');acceptance='Caller must inspect actual terminal/bag/paused screenshots; input success alone never completes catch'}
    $record | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $fishingEvidence ('reel-'+$fishingId+'.json')) -Encoding utf8NoBOM
    $record | Select-Object id,seconds,hooked,error,terminal_capture,pause_capture | ConvertTo-Json
}
if ($fishingError) {throw $fishingError}
