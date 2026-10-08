#Requires -Version 7.0
param([Parameter(Mandatory)][int]$GameProcessId,[Parameter(Mandatory)][string]$EvidenceDirectory,[Parameter(Mandatory)][string]$StandaloneDirectory,[Parameter(Mandatory)][string]$Label,[switch]$LoadFirst)
$ErrorActionPreference='Stop'
$npcLog=Join-Path $EvidenceDirectory 'stdout.log'
$npcLaunch=Get-Content (Join-Path $EvidenceDirectory 'launch.json') -Raw | ConvertFrom-Json
if ($npcLaunch.pid -ne $GameProcessId) {throw 'Owned launch PID differs'}
$npcText=Get-Content $npcLog -Raw
$npcModes=[regex]::Matches($npcText,'P001: (Paused|Resumed) at play time')
if ($npcModes.Count -eq 0 -or $npcModes[-1].Groups[1].Value -ne 'Paused') {throw 'GUI save/load requires inspected pause'}
$npcBefore=[regex]::Matches($npcText,'P005 save: OK').Count
$npcSteps=@()
if ($LoadFirst) {
    $npcSteps+=@(@{op='click';x=480;y=402},@{op='wait';duration_ms=2000},@{op='capture';label=($Label+'-loaded-paused')})
}
$npcSteps+=@(@{op='click';x=480;y=338},@{op='wait';duration_ms=1500},@{op='capture';label=($Label+'-saved-paused')})
& (Join-Path $PSScriptRoot 'invoke_native.ps1') -GameProcessId $GameProcessId -EvidenceDirectory $EvidenceDirectory -StandaloneDirectory $StandaloneDirectory -StepsJson (ConvertTo-Json -InputObject $npcSteps -Depth 9 -Compress)
$npcTimer=[Diagnostics.Stopwatch]::StartNew()
while ([regex]::Matches((Get-Content $npcLog -Raw),'P005 save: OK').Count -le $npcBefore -and $npcTimer.Elapsed.TotalSeconds -lt 10) {Start-Sleep -Milliseconds 100}
if ([regex]::Matches((Get-Content $npcLog -Raw),'P005 save: OK').Count -ne $npcBefore+1) {throw 'GUI Save has no new successful outcome'}
if ($LoadFirst -and (Get-Content $npcLog -Raw) -notmatch 'P005 load: Loaded') {throw 'GUI Load has no successful outcome'}
$npcDestination=Join-Path $EvidenceDirectory ($Label+'-save.json')
if (Test-Path -LiteralPath $npcDestination) {throw 'Save snapshot would overwrite evidence'}
Copy-Item -LiteralPath $npcLaunch.save_path -Destination $npcDestination
Write-Output "N018_GUI_SAVE=$npcDestination SHA256=$((Get-FileHash $npcDestination).Hash)"
