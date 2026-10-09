#Requires -Version 7.0
## Synthetic bitmap classifier tests. No game process or OS input.
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'hud_pixels.ps1')
Add-Type -AssemblyName System.Drawing
$template=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'bite_pixels.json') -Raw | ConvertFrom-Json
$assertions=0
function Check([bool]$Ok,[string]$Label) {$script:assertions++;if (-not $Ok) {throw $Label}}
$bitmap=[Drawing.Bitmap]::new(960,640)
$graphics=[Drawing.Graphics]::FromImage($bitmap)
try {
    $graphics.Clear([Drawing.Color]::Black)
    $blank=Get-FishingHudPixels $bitmap $template
    Check (-not $blank.bite -and -not $blank.fight) 'Blank screen triggers input'
    for ($row=0;$row -lt 23;$row++) {for ($column=0;$column -lt 200;$column++) {
        if ($template.rows[$row][$column] -eq '1') {$bitmap.SetPixel(550+$column,480+$row,[Drawing.Color]::White)}
    }}
    $bite=Get-FishingHudPixels $bitmap $template
    Check ($bite.bite -and -not $bite.fight) 'Exact BITE glyph mask refused'
    $graphics.Clear([Drawing.Color]::Black)
    for ($x=550;$x -lt 922;$x++) {$bitmap.SetPixel($x,452,[Drawing.Color]::FromArgb(57,134,108))}
    $noMarker=Get-FishingHudPixels $bitmap $template
    Check (-not $noMarker.fight) 'Meter without marker triggers E'
    foreach ($tension in @(.1,.3,.5,.7,.9)) {
        for ($x=550;$x -lt 922;$x++) {$bitmap.SetPixel($x,452,[Drawing.Color]::FromArgb(57,134,108))}
        $center=550+[int](372*$tension)
        for ($x=$center-2;$x -lt $center+2;$x++) {$bitmap.SetPixel($x,452,[Drawing.Color]::White)}
        $fight=Get-FishingHudPixels $bitmap $template
        Check ($fight.fight -and -not $fight.bite -and [math]::Abs($fight.tension-$tension) -lt .004) 'Rendered tension estimate differs'
    }
    $wrongSize=[Drawing.Bitmap]::new(1350,900)
    try {$refused=$false;try {Get-FishingHudPixels $wrongSize $template | Out-Null}catch{$refused=$true};Check $refused 'Resized client accepted'}finally{$wrongSize.Dispose()}
    $bad=($template | ConvertTo-Json -Depth 5 | ConvertFrom-Json);$bad.rows=@('bad')
    $refused=$false;try{Get-FishingHudPixels $bitmap $bad | Out-Null}catch{$refused=$true};Check $refused 'Malformed template accepted'
} finally {$graphics.Dispose();$bitmap.Dispose()}
$projectRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$evidence=Join-Path $projectRoot ('docs/evidence/FS008/pixel-checks-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $evidence | Out-Null
@{task='FS008';status='passed';assertions=$assertions;proof='Synthetic bitmap classification; no native gameplay'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $evidence 'results.json')
Write-Output "FS008 pixel checks PASS assertions=$assertions REPORT=$evidence/results.json"
