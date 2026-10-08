#Requires -Version 7.0
param([Parameter(Mandatory)][int]$GameProcessId,[Parameter(Mandatory)][string]$EvidenceDirectory,[Parameter(Mandatory)][string]$StandaloneDirectory,[Parameter(Mandatory)][ValidateSet('npc-01','npc-02','npc-03','npc-04','npc-06','npc-07','npc-08','npc-14')][string]$NpcId,[Parameter(Mandatory)][string]$Prefix,[switch]$Neutral,[switch]$RevisitOnly)
$ErrorActionPreference='Stop'
$npcRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$npcLog=Join-Path $EvidenceDirectory 'stdout.log'
$npcModes=[regex]::Matches((Get-Content $npcLog -Raw),'P001: (Paused|Resumed) at play time')
if ($npcModes.Count -eq 0 -or $npcModes[-1].Groups[1].Value -ne 'Paused') { throw 'Person route requires an inspected pause checkpoint' }
$npcCatalog=Get-Content (Join-Path $npcRoot 'game/content/npcs/catalog.json') -Raw | ConvertFrom-Json
$npcPackage=@($npcCatalog.packages | Where-Object id -eq $NpcId)[0]
function Key([string]$Name) { return @{op='hold';keys=@($Name);duration_ms=70} }
function Capture([string]$Name) { return @{op='capture';label=($Prefix+'-'+$Name)} }
function Open-Person {
    $open=@((Key 'E'),@{op='wait';duration_ms=150})
    # E intentionally opens Maris's prototype counter. This observed public
    # footer routes to the same person's source graph without applying effects.
    if ($NpcId -eq 'npc-03') { $open+=@(@{op='click';x=267;y=536},@{op='wait';duration_ms=150}) }
    return $open
}
function Invoke-Person([array]$Steps) {
    & (Join-Path $PSScriptRoot 'invoke_native.ps1') -GameProcessId $GameProcessId -EvidenceDirectory $EvidenceDirectory -StandaloneDirectory $StandaloneDirectory -StepsJson (ConvertTo-Json -InputObject $Steps -Depth 9 -Compress)
}
$npcSteps=@((Key 'ESC')) + @(Open-Person) + @((Capture 'open'))
if (-not $RevisitOnly) {
    if ($Neutral) { $npcSteps+=,(Key 'TAB') }
    $npcSteps+=@((Key 'ENTER'),@{op='wait';duration_ms=150},(Capture 'response'),(Key 'ESC')) + @(Open-Person) + @((Capture 'return'))
}
Invoke-Person $npcSteps
if (-not $RevisitOnly -and $NpcId -notin @('npc-01','npc-02')) {
    $npcReturn=@($npcPackage.dialogue.nodes | Where-Object id -eq ($NpcId+'-return'))[0]
    $npcAvailable=@($npcReturn.choices | Where-Object { $npcPackage.coverage.choice.($_.id).status -eq 'enabled' })
    for ($npcIndex=0;$npcIndex -lt $npcAvailable.Count;$npcIndex++) {
        $npcSteps=@()
        for ($npcTab=0;$npcTab -lt $npcIndex;$npcTab++) { $npcSteps+=,(Key 'TAB') }
        $npcSteps+=@((Key 'ENTER'),@{op='wait';duration_ms=150},(Capture $npcAvailable[$npcIndex].id),(Key 'ESC')) + @(Open-Person) + @((Capture ('return-'+$npcIndex)))
        Invoke-Person $npcSteps
    }
}
# Dialogue exits with Esc; a distinct second Esc opens pause. No Continue/end guess.
Invoke-Person @((Key 'ESC'),(Key 'ESC'),@{op='wait';duration_ms=150},(Capture 'paused'))
$npcModes=[regex]::Matches((Get-Content $npcLog -Raw),'P001: (Paused|Resumed) at play time')
if ($npcModes[-1].Groups[1].Value -ne 'Paused') { throw 'Expected pause absent; inspect captured mode before further input' }
Write-Output "N018_PERSON_INPUT=$NpcId (native delivery only; inspect captures and saved-state oracle for acceptance)"
