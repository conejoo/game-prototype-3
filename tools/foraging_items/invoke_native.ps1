#Requires -Version 7.0
param([Parameter(Mandatory)][int]$GameProcessId,[Parameter(Mandatory)][string]$EvidenceDirectory,[Parameter(Mandatory)][string]$StepsJson)
$ErrorActionPreference='Stop'
$foragingRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. (Join-Path $foragingRoot 'tools/testing_paths.ps1')
$foragingEvidence=Resolve-NativeEvidenceDirectory $foragingRoot $EvidenceDirectory
$foragingRequest=Join-Path $foragingEvidence ('request-'+[Guid]::NewGuid().ToString('N')+'.json')
$foragingSteps=ConvertFrom-Json $StepsJson
@{steps=@($foragingSteps)} | ConvertTo-Json -Depth 9 | Set-Content -LiteralPath $foragingRequest -Encoding utf8NoBOM
$foragingResult=& (Join-Path $foragingRoot 'tools/native_input.ps1') -TargetProcessId $GameProcessId -CommandFile $foragingRequest -OutputDirectory $foragingEvidence | Out-String | ConvertFrom-Json
$foragingResult | Select-Object id,ok,error,target_pid,elapsed_ms,requested_duration_ms,cleanup_errors,unreleased_keys,mouse_unreleased | ConvertTo-Json -Depth 5
if (-not $foragingResult.ok) { throw $foragingResult.error }
