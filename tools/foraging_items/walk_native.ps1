#Requires -Version 7.0
param([Parameter(Mandatory)][int]$GameProcessId,[Parameter(Mandatory)][string]$EvidenceDirectory,[Parameter(Mandatory)][string]$RouteFile,[Parameter(Mandatory)][string]$Goal,[ValidateRange(1,25)][int]$Seconds=20)
$ErrorActionPreference='Stop'
$weatherRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$weatherLog=Join-Path $EvidenceDirectory 'stdout.log'
$weatherId=[Guid]::NewGuid().ToString('N').Substring(0,8)
$weatherStatePath=Join-Path $EvidenceDirectory ('walk-'+$Goal+'-progress.json')
$weatherRoute=@(Get-Content $RouteFile -Raw | ConvertFrom-Json | Where-Object goal -eq $Goal)
if ($weatherRoute.Count -ne 1) { throw 'Expected exactly one native guidance route' }
$weatherPoints=@($weatherRoute[0].path)
$weatherIndex=0
if (Test-Path $weatherStatePath) { $weatherIndex=(Get-Content $weatherStatePath -Raw | ConvertFrom-Json).index }
$weatherModes=[regex]::Matches((Get-Content $weatherLog -Raw),'P001: (Paused|Resumed) at play time')
if ($weatherModes.Count -eq 0 -or $weatherModes[-1].Groups[1].Value -ne 'Paused') {throw 'Start requires inspected pause checkpoint'}
function Invoke-WeatherInput($Steps) {
    $weatherRequest=Join-Path $EvidenceDirectory ('walk-request-'+[Guid]::NewGuid().ToString('N')+'.json')
    @{steps=@($Steps)} | ConvertTo-Json -Depth 7 | Set-Content $weatherRequest -Encoding utf8NoBOM
    $weatherResponse=& (Join-Path $weatherRoot 'tools/native_input.ps1') -TargetProcessId $GameProcessId -CommandFile $weatherRequest -OutputDirectory $EvidenceDirectory | Out-String | ConvertFrom-Json
    if (-not $weatherResponse.ok) {throw $weatherResponse.error}
}
function Get-WeatherPosition {
    $weatherText=Get-Content $weatherLog -Raw
    $weatherMatches=[regex]::Matches($weatherText,'P003 input release [^:]+: position=\(([-0-9.]+), ([-0-9.]+), ([-0-9.]+)\)')
    $weatherArrival=[regex]::Matches($weatherText,'P004: arrived ([^/]+)/([^;]+);')
    if ($weatherArrival.Count -gt 0 -and ($weatherMatches.Count -eq 0 -or $weatherArrival[-1].Index -gt $weatherMatches[-1].Index)) {
        switch ($weatherArrival[-1].Groups[2].Value) {
            'alderwake-start' {return ,@(0.0,0.0,0.0)}
            'alderwake-from-tollworks' {return ,@(107.25,0.0,1.25)}
            default {throw 'Unsupported native arrival for exterior route'}
        }
    }
    if ($weatherMatches.Count -eq 0) {throw 'Native position trace absent'}
    return ,@([double]$weatherMatches[-1].Groups[1].Value,[double]$weatherMatches[-1].Groups[2].Value,[double]$weatherMatches[-1].Groups[3].Value)
}
$weatherDirections=@()
foreach ($weatherSpec in @(@(1,0,'D'),@(-1,0,'A'),@(0,1,'S'),@(0,-1,'W'),@(1,1,'D','S'),@(1,-1,'D','W'),@(-1,1,'A','S'),@(-1,-1,'A','W'))) {
    $weatherX=($weatherSpec[0]*16+$weatherSpec[1]*10)/[math]::Sqrt(356)
    $weatherZ=(-$weatherSpec[0]*10+$weatherSpec[1]*16)/[math]::Sqrt(356)
    $weatherLength=[math]::Sqrt($weatherX*$weatherX+$weatherZ*$weatherZ)
    $weatherDirections+=@{x=$weatherX/$weatherLength;z=$weatherZ/$weatherLength;keys=@($weatherSpec[2..($weatherSpec.Count-1)])}
}
$weatherTimer=[Diagnostics.Stopwatch]::StartNew()
$weatherResumed=$false
$weatherError=$null
try {
    Invoke-WeatherInput @(@{op='hold';keys=@('ESC');duration_ms=60})
    $weatherResumed=$true
    $weatherStalls=0
    while ($weatherIndex -lt $weatherPoints.Count -and $weatherTimer.Elapsed.TotalSeconds -lt $Seconds) {
        $weatherPosition=Get-WeatherPosition
        $weatherPoint=$weatherPoints[$weatherIndex]
        $weatherDx=$weatherPoint[0]-$weatherPosition[0];$weatherDz=$weatherPoint[2]-$weatherPosition[2]
        $weatherDistance=[math]::Sqrt($weatherDx*$weatherDx+$weatherDz*$weatherDz)
        if ($weatherDistance -lt 0.12) {$weatherIndex++;continue}
        # Native input has eight directions. Steer along a short look-ahead on
        # long segments so quantization cannot drift into a river beside them.
        if ($weatherIndex -gt 0 -and $weatherDistance -gt 1.3) {
            $foragingPrevious=$weatherPoints[$weatherIndex-1]
            $foragingSegmentX=$weatherPoint[0]-$foragingPrevious[0]
            $foragingSegmentZ=$weatherPoint[2]-$foragingPrevious[2]
            $foragingLength=[math]::Sqrt($foragingSegmentX*$foragingSegmentX+$foragingSegmentZ*$foragingSegmentZ)
            if ($foragingLength -gt 1.3) {
                $foragingProjection=(($weatherPosition[0]-$foragingPrevious[0])*$foragingSegmentX+($weatherPosition[2]-$foragingPrevious[2])*$foragingSegmentZ)/($foragingLength*$foragingLength)
                $foragingAlong=[math]::Clamp($foragingProjection+1.0/$foragingLength,0.0,1.0)
                $weatherDx=$foragingPrevious[0]+$foragingAlong*$foragingSegmentX-$weatherPosition[0]
                $weatherDz=$foragingPrevious[2]+$foragingAlong*$foragingSegmentZ-$weatherPosition[2]
                $weatherDistance=[math]::Sqrt($weatherDx*$weatherDx+$weatherDz*$weatherDz)
            }
        }
        $weatherDirection=$weatherDirections | Sort-Object @{Expression={$_.x*$weatherDx+$_.z*$weatherDz};Descending=$true} | Select-Object -First 1
        $weatherMs=[math]::Max(32,[math]::Min(500,[int]($weatherDistance/4*1000*0.75)))
        Invoke-WeatherInput @(@{op='hold';keys=$weatherDirection.keys;duration_ms=$weatherMs})
        $weatherAfter=Get-WeatherPosition
        $weatherMoved=[math]::Sqrt([math]::Pow($weatherAfter[0]-$weatherPosition[0],2)+[math]::Pow($weatherAfter[2]-$weatherPosition[2],2))
        if ($weatherMoved -lt 0.015) {$weatherStalls++} else {$weatherStalls=0}
        if ($weatherStalls -ge 4) {throw "Physical native stall at $weatherAfter toward $weatherPoint"}
    }
} catch { $weatherError=$_.Exception.Message }
finally {
    if ($weatherResumed) {Invoke-WeatherInput @(@{op='capture';label=('walk-'+$Goal+'-'+$weatherId+'-world')},@{op='hold';keys=@('ESC');duration_ms=60},@{op='wait';duration_ms=150},@{op='capture';label=('walk-'+$Goal+'-'+$weatherId+'-paused')})}
    $weatherState=@{goal=$Goal;index=$weatherIndex;points=$weatherPoints.Count;complete=($weatherIndex -ge $weatherPoints.Count);position=(Get-WeatherPosition);seconds=$weatherTimer.Elapsed.TotalSeconds;error=$weatherError;capture=('walk-'+$Goal+'-'+$weatherId+'-paused.png')}
    $weatherState | ConvertTo-Json -Depth 4 | Set-Content $weatherStatePath
    $weatherState | ConvertTo-Json -Depth 4
}
if ($weatherError) {throw $weatherError}
