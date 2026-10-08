#Requires -Version 7.0
param([Parameter(Mandatory)][int]$GameProcessId,[Parameter(Mandatory)][string]$EvidenceDirectory,[Parameter(Mandatory)][string]$StepsJson,[Parameter(Mandatory)][string]$StandaloneDirectory)
$ErrorActionPreference='Stop'
$npcRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. (Join-Path $npcRoot 'tools/testing_paths.ps1')
$npcEvidence=Resolve-NativeEvidenceDirectory $npcRoot $EvidenceDirectory
$npcRequest=Join-Path $npcEvidence ('request-'+[Guid]::NewGuid().ToString('N')+'.json')
$npcSteps=ConvertFrom-Json $StepsJson
@{steps=@($npcSteps)} | ConvertTo-Json -Depth 9 | Set-Content -LiteralPath $npcRequest -Encoding utf8NoBOM
$npcResult=& (Join-Path $npcRoot 'tools/native_input.ps1') -TargetProcessId $GameProcessId -CommandFile $npcRequest -OutputDirectory $npcEvidence -StandaloneDirectory $StandaloneDirectory | Out-String | ConvertFrom-Json
$npcResult | Select-Object id,ok,error,target_pid,elapsed_ms,requested_duration_ms,cleanup_errors,unreleased_keys,mouse_unreleased | ConvertTo-Json -Depth 5
if (-not $npcResult.ok) { throw $npcResult.error }
