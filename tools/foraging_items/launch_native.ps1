#Requires -Version 7.0
param([Parameter(Mandatory)][string]$Session, [Parameter(Mandatory)][ValidateSet('writer','reader')][string]$Phase)
$ErrorActionPreference = 'Stop'
$weatherRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if ($Session -notmatch '^[A-Za-z0-9_-]{1,64}$') { throw 'Invalid session name' }
$weatherEvidence = Join-Path $weatherRoot "docs/evidence/F010/native-$Session/$Phase"
$weatherStaging = Join-Path $weatherRoot "builds/foraging-items-backpack/F010/native-$Session"
New-Item -ItemType Directory -Path $weatherEvidence -ErrorAction Stop | Out-Null
$env:APPDATA = Join-Path $weatherStaging 'appdata'
$env:LOCALAPPDATA = Join-Path $weatherStaging 'localappdata'
New-Item -ItemType Directory -Path $env:APPDATA,$env:LOCALAPPDATA -Force | Out-Null
$weatherExe = Join-Path $weatherRoot 'builds/windows/ReturningFair.exe'
$weatherOverride = Join-Path (Split-Path $weatherExe -Parent) 'override.cfg'
if ((Get-Content $weatherOverride -Raw) -notmatch 'custom_user_dir_name="ReturningFair-P014-ReleaseValidation"') { throw 'Unverified release save isolation' }
$weatherSave = Join-Path $env:APPDATA 'ReturningFair-P014-ReleaseValidation/saves/returning-fair.json'
if ($Phase -eq 'writer' -and (Test-Path $weatherSave)) { throw 'Fresh native writer requires absent save' }
if ($Phase -eq 'reader' -and -not (Test-Path $weatherSave)) { throw 'Native reader requires writer save' }
$weatherArgs = @('--resolution','960x640','--position','40,40','--verbose','--log-file',(Join-Path $weatherEvidence 'runtime.log'),'--','--p003-evidence')
$nativeWorkingDirectory = [IO.Path]::GetTempPath()
if ([IO.Path]::GetFullPath($nativeWorkingDirectory).StartsWith([IO.Path]::GetFullPath($weatherRoot), [StringComparison]::OrdinalIgnoreCase)) { throw 'Native working directory must be outside checkout' }
$weatherProcess = Start-Process -FilePath $weatherExe -WorkingDirectory $nativeWorkingDirectory -ArgumentList $weatherArgs -WindowStyle Hidden -RedirectStandardOutput (Join-Path $weatherEvidence 'stdout.log') -RedirectStandardError (Join-Path $weatherEvidence 'stderr.log') -PassThru
@{pid=$weatherProcess.Id;exe=$weatherExe;arguments=$weatherArgs;cwd=$nativeWorkingDirectory;APPDATA=$env:APPDATA;LOCALAPPDATA=$env:LOCALAPPDATA;save_path=$weatherSave;override_sha256=(Get-FileHash $weatherOverride).Hash;release_sha256=(Get-FileHash $weatherExe).Hash;pack_sha256=(Get-FileHash ([IO.Path]::ChangeExtension($weatherExe,'.pck'))).Hash;provenance='Ordinary native input; read-only movement trace; no fixtures/bridge/review/time skips'} | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $weatherEvidence 'launch.json')
Write-Output "F010_NATIVE=$weatherEvidence PID=$($weatherProcess.Id)"
$weatherProcess.WaitForExit()
@{pid=$weatherProcess.Id;exit_code=$weatherProcess.ExitCode;finished_utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content (Join-Path $weatherEvidence 'exit.json')
Write-Output "F010_NATIVE_EXIT=$($weatherProcess.ExitCode)"
