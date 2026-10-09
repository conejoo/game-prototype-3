#Requires -Version 7.0
# Execute the documented launch recipe with a fake process; no engine or OS input.
$ErrorActionPreference='Stop'
$recipeProject=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$recipeText=Get-Content -LiteralPath (Join-Path $recipeProject 'tools/skills/returning-fair-gameplay-testing/references/native-commands.md') -Raw
$recipeBlocks=[regex]::Matches($recipeText,'(?s)```powershell\r?\n(.*?)```')
$recipeBlock=@($recipeBlocks | Where-Object {$_.Groups[1].Value.Contains('$nativeData =')})
if ($recipeBlock.Count -ne 1) {throw 'Unique isolated launch recipe required'}
$recipeRun=Join-Path $recipeProject ('docs/evidence/testing-tools/native-recipe-'+[guid]::NewGuid().ToString('N'))
$recipeFixture=Join-Path $recipeRun 'fixture'
New-Item -ItemType Directory -Path (Join-Path $recipeFixture 'tools'),(Join-Path $recipeFixture 'builds/windows') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $recipeProject 'tools/testing_paths.ps1') -Destination (Join-Path $recipeFixture 'tools/testing_paths.ps1')
foreach ($recipeLeaf in @('ReturningFair.exe','ReturningFair.pck','override.cfg')) {
    Set-Content -LiteralPath (Join-Path $recipeFixture ('builds/windows/'+$recipeLeaf)) -Value ('synthetic '+$recipeLeaf)
}
$recipeCode=$recipeBlock[0].Groups[1].Value.Replace("D:/development/game-dev-blender/returning-fair-prototype",$recipeFixture.Replace('\','/'))
$recipeScript=[ScriptBlock]::Create($recipeCode)
$recipeOriginalAppData=$env:APPDATA; $recipeOriginalLocalData=$env:LOCALAPPDATA
$script:recipeAssertions=0
$script:recipeThrow=$false
$script:recipeLaunches=0
function Check-Recipe([bool]$Value,[string]$Message) {
    $script:recipeAssertions++
    if (-not $Value) {throw $Message}
}
function Start-Process {
    param($FilePath,$WorkingDirectory,$ArgumentList,$WindowStyle,[switch]$PassThru)
    $script:recipeLaunches++
    Check-Recipe ($env:APPDATA -ne $recipeOriginalAppData -and (Test-Path -LiteralPath $env:APPDATA)) 'Fresh APPDATA missing at launch'
    Check-Recipe ($env:LOCALAPPDATA -ne $recipeOriginalLocalData -and (Test-Path -LiteralPath $env:LOCALAPPDATA)) 'Fresh LOCALAPPDATA missing at launch'
    Check-Recipe ($env:APPDATA.StartsWith($recipeFixture) -and $env:LOCALAPPDATA.StartsWith($recipeFixture)) 'Fixture isolation escaped'
    Check-Recipe ($WindowStyle -eq 'Hidden' -and $PassThru) 'Hidden owned process handle missing'
    Check-Recipe (([IO.Path]::GetFullPath($FilePath)) -eq ([IO.Path]::GetFullPath((Join-Path $recipeFixture 'builds/windows/ReturningFair.exe')))) 'Unexpected executable'
    Check-Recipe (-not ([IO.Path]::GetFullPath($WorkingDirectory)).StartsWith($recipeFixture)) 'Outside-checkout cwd missing'
    if ($script:recipeThrow) {throw 'Injected launch failure'}
    $recipeFake=[pscustomobject]@{Id=12345;ExitCode=0}
    Add-Member -InputObject $recipeFake -MemberType ScriptMethod -Name WaitForExit -Value {} # retain ordinary-exit contract
    return $recipeFake
}
$nativeTask='G009' # Synthetic fixture path only; does not reopen/select G009.
. $recipeScript
Check-Recipe ($env:APPDATA -eq $recipeOriginalAppData -and $env:LOCALAPPDATA -eq $recipeOriginalLocalData) 'Caller environment changed'
$recipeLaunch=Get-Content -LiteralPath (Join-Path $runEvidence 'launch.json') -Raw | ConvertFrom-Json
Check-Recipe ($recipeLaunch.pid -eq 12345 -and $recipeLaunch.APPDATA -ne $recipeOriginalAppData) 'Launch provenance missing'
Check-Recipe ((Test-Path -LiteralPath (Join-Path $runEvidence 'exit.txt')) -and $recipeLaunch.release_sha256) 'Normal exit or package hash missing'
$script:recipeThrow=$true
$recipeFailed=$false
try {. $recipeScript} catch {
    if ($_.Exception.Message -ne 'Injected launch failure') {throw}
    $recipeFailed=$true
}
Check-Recipe $recipeFailed 'Injected failure was ignored'
Check-Recipe ($env:APPDATA -eq $recipeOriginalAppData -and $env:LOCALAPPDATA -eq $recipeOriginalLocalData) 'Failure leaked caller environment'
Check-Recipe ($script:recipeLaunches -eq 2) 'Unexpected launch count'
# A missing PCK must fail before any process starts or caller environment changes.
Remove-Item -LiteralPath (Join-Path $recipeFixture 'builds/windows/ReturningFair.pck')
$recipeMissing=$false
try {. $recipeScript} catch {$recipeMissing=$true}
Check-Recipe ($recipeMissing -and $script:recipeLaunches -eq 2) 'Missing package launched a process'
Check-Recipe ($env:APPDATA -eq $recipeOriginalAppData -and $env:LOCALAPPDATA -eq $recipeOriginalLocalData) 'Preflight failure changed environment'
@{status='passed';assertions=$recipeAssertions;proof='Documented recipe executed with mock process only; environment restored on success/failure';fixture=$recipeFixture} | ConvertTo-Json | Set-Content (Join-Path $recipeRun 'results.json')
Write-Output "Native launch recipe: PASS assertions=$recipeAssertions REPORT=$recipeRun/results.json (mock process; no OS input)"
