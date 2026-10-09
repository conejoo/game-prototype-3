#Requires -Version 7.0
param([ValidateSet('FS006','FS008')][string]$EvidenceTask='FS006')
## Synthetic guard checks only; never native fishing acceptance.
$ErrorActionPreference='Stop'
$projectRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. (Join-Path $projectRoot 'tools/testing_paths.ps1')
$count=0
function Check([bool]$Pass,[string]$Message) { $script:count++; if (-not $Pass) {throw $Message} }
function Refuse([scriptblock]$Action,[string]$Message) {
    $rejected=$false; try {& $Action | Out-Null} catch {$rejected=$true}; Check $rejected $Message
}
$run=Join-Path $projectRoot ('docs/evidence/'+$EvidenceTask+'/native-guards-'+[guid]::NewGuid().ToString('N'))
$fixture=Join-Path $run 'fixture'
$canonical=Join-Path $fixture 'builds/windows'
$copy=Join-Path ([IO.Path]::GetTempPath()) ('ReturningFair-FS008-guards-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $canonical,$copy | Out-Null
foreach ($name in @('ReturningFair.exe','ReturningFair.pck','override.cfg')) {
    Set-Content -LiteralPath (Join-Path $canonical $name) -Value ('synthetic guard bytes '+$name)
    Copy-Item -LiteralPath (Join-Path $canonical $name) -Destination (Join-Path $copy $name)
}
$evidence=Join-Path $fixture 'docs/evidence/FS008/test-run'
Check ((Resolve-NativeStandaloneDirectory $fixture $copy $evidence) -eq $copy) 'Exact FS008 copy refused'
foreach ($task in @('N018','G009')) {Refuse {Resolve-NativeStandaloneDirectory $fixture $copy (Join-Path $fixture "docs/evidence/$task/test-run")} 'Cross-task copy admitted'}
Refuse {Resolve-NativeStandaloneDirectory $fixture ($copy+'/nested') $evidence} 'Nested TEMP copy admitted'
foreach ($path in @('FS008','FS007/run','FS009/run','FS008-sibling/run','FS008/../../outside/run')) {
    Refuse {Resolve-NativeEvidenceDirectory $fixture (Join-Path $fixture "docs/evidence/$path")} ('Unsafe route '+$path)
}
foreach ($name in @('ReturningFair.exe','ReturningFair.pck','override.cfg')) {
    Add-Content -LiteralPath (Join-Path $copy $name) -Value 'tampered'
    Refuse {Resolve-NativeStandaloneDirectory $fixture $copy $evidence} ('Tampered '+$name+' admitted')
    Copy-Item -LiteralPath (Join-Path $canonical $name) -Destination (Join-Path $copy $name) -Force
}
$linked=Join-Path ([IO.Path]::GetTempPath()) ('ReturningFair-FS008-link-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Junction -Path $linked -Value $copy | Out-Null
Refuse {Resolve-NativeStandaloneDirectory $fixture $linked $evidence} 'Junction copy admitted'
# Verify exact resolved direct TEMP children before deleting only our fixtures.
$tempRoot=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([char[]]'\/')
foreach ($owned in @($linked,$copy)) {
    if ((Split-Path ([IO.Path]::GetFullPath($owned)) -Parent) -ne $tempRoot -or (Split-Path $owned -Leaf) -notmatch '^ReturningFair-FS008-(link|guards)-[0-9a-f]{32}$') {throw 'Unsafe cleanup'}
}
Remove-Item -LiteralPath $linked
Remove-Item -LiteralPath $copy -Recurse
@{task=$EvidenceTask;status='passed';assertions=$count;proof='Synthetic exact-hash/path/reparse guards for FS008; no OS input or package modification'} | ConvertTo-Json | Set-Content (Join-Path $run 'results.json')
Write-Output "$EvidenceTask native guards: PASS assertions=$count REPORT=$run/results.json"
