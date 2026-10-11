#Requires -Version 7.0
$ErrorActionPreference='Stop'
$root=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. (Join-Path $root 'tools/testing_paths.ps1')
$count=0
function Check([bool]$Pass,[string]$Message) { $script:count++; if (-not $Pass) {throw $Message} }
function Refuse([scriptblock]$Action,[string]$Message) {
    $rejected=$false; try {& $Action | Out-Null} catch {$rejected=$true}; Check $rejected $Message
}
$run=Join-Path $root ('docs/evidence/AD020/guards-'+[guid]::NewGuid().ToString('N'))
$fixture=Join-Path $run 'fixture'
$canonical=Join-Path $fixture 'builds/windows'
$copy=Join-Path ([IO.Path]::GetTempPath()) ('ReturningFair-AD020-guards-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $canonical,$copy | Out-Null
foreach ($name in @('ReturningFair.exe','ReturningFair.pck','override.cfg')) {
    Set-Content -LiteralPath (Join-Path $canonical $name) -Value ('synthetic guard bytes '+$name)
    Copy-Item -LiteralPath (Join-Path $canonical $name) -Destination (Join-Path $copy $name)
}
$evidence=Join-Path $fixture 'docs/evidence/AD020/test-run'
Check ((Resolve-NativeStandaloneDirectory $fixture $copy $evidence) -eq $copy) 'Exact AD020 package refused'
Refuse {Resolve-NativeStandaloneDirectory $fixture $copy (Join-Path $fixture 'docs/evidence/N018/test-run')} 'Cross-task evidence admitted'
Refuse {Resolve-NativeStandaloneDirectory $fixture ($copy+'-child/nested') $evidence} 'Nested TEMP copy admitted'
foreach ($name in @('ReturningFair.exe','ReturningFair.pck','override.cfg')) {
    Add-Content -LiteralPath (Join-Path $copy $name) -Value 'tampered'
    Refuse {Resolve-NativeStandaloneDirectory $fixture $copy $evidence} ('Tampered '+$name+' admitted')
    Copy-Item -LiteralPath (Join-Path $canonical $name) -Destination (Join-Path $copy $name) -Force
}
$linked=Join-Path ([IO.Path]::GetTempPath()) ('ReturningFair-AD020-link-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Junction -Path $linked -Value $copy | Out-Null
Refuse {Resolve-NativeStandaloneDirectory $fixture $linked $evidence} 'Junction copy admitted'
# Remove only our verified direct TEMP children and link; retain raw fixture evidence.
$tempRoot=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([char[]]'\/')
foreach ($owned in @($linked,$copy)) {
    if ((Split-Path ([IO.Path]::GetFullPath($owned)) -Parent) -ne $tempRoot -or (Split-Path $owned -Leaf) -notmatch '^ReturningFair-AD020-(link|guards)-[0-9a-f]{32}$') {throw 'Unsafe cleanup'}
}
Remove-Item -LiteralPath $linked
Remove-Item -LiteralPath $copy -Recurse
@{task='AD020';status='passed';assertions=$count;proof='Synthetic exact-hash/path/reparse guards; no OS input'} | ConvertTo-Json | Set-Content (Join-Path $run 'results.json')
Write-Output "AD020 native guards: PASS assertions=$count REPORT=$run/results.json"
