#Requires -Version 7.0
param([Parameter(Mandatory)][string]$Session,[Parameter(Mandatory)][ValidateSet('writer','reader','neutral')][string]$Phase)
$ErrorActionPreference='Stop'
$npcRoot=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
. (Join-Path $npcRoot 'tools/testing_paths.ps1')
if ($Session -notmatch '^[A-Za-z0-9_-]{1,64}$') { throw 'Invalid session name' }
$npcEvidence=Join-Path $npcRoot "docs/evidence/G009/native-$Session/$Phase"
$npcStaging=Join-Path $npcRoot "builds/gifts-friendship-people-journal/G009/native-$Session"
$null=Resolve-NativeEvidenceDirectory $npcRoot $npcEvidence
New-Item -ItemType Directory -Path $npcEvidence -ErrorAction Stop | Out-Null
$npcStaging=Resolve-ProjectChildPath $npcRoot $npcStaging 'builds/gifts-friendship-people-journal/G009'
$npcGroup=if ($Phase -eq 'neutral') {'neutral'} else {'restart'}
$env:APPDATA=Resolve-ProjectChildPath $npcRoot (Join-Path $npcStaging "$npcGroup/appdata") 'builds/gifts-friendship-people-journal/G009'
$env:LOCALAPPDATA=Resolve-ProjectChildPath $npcRoot (Join-Path $npcStaging "$npcGroup/localappdata") 'builds/gifts-friendship-people-journal/G009'
New-Item -ItemType Directory -Path $env:APPDATA,$env:LOCALAPPDATA -Force | Out-Null
$npcStandalone=Join-Path ([IO.Path]::GetTempPath()) ('ReturningFair-G009-'+$Session)
if ($Phase -eq 'writer') {
    New-Item -ItemType Directory -Path $npcStandalone -ErrorAction Stop | Out-Null
    foreach ($leaf in @('ReturningFair.exe','ReturningFair.pck','override.cfg')) {
        Copy-Item -LiteralPath (Join-Path $npcRoot ('builds/windows/'+$leaf)) -Destination (Join-Path $npcStandalone $leaf)
    }
}
foreach ($leaf in @('ReturningFair.exe','ReturningFair.pck','override.cfg')) {
    if ((Get-FileHash -LiteralPath (Join-Path $npcStandalone $leaf)).Hash -ne (Get-FileHash -LiteralPath (Join-Path $npcRoot ('builds/windows/'+$leaf))).Hash) { throw 'Standalone package hash mismatch' }
}
$null=Resolve-NativeStandaloneDirectory $npcRoot $npcStandalone $npcEvidence
$npcExe=Join-Path $npcStandalone 'ReturningFair.exe'
$npcOverride=Join-Path $npcStandalone 'override.cfg'
if ((Get-Content $npcOverride -Raw) -notmatch 'custom_user_dir_name="ReturningFair-P014-ReleaseValidation"') { throw 'Unverified release isolation' }
$npcSave=Join-Path $env:APPDATA 'ReturningFair-P014-ReleaseValidation/saves/returning-fair.json'
if ($Phase -ne 'reader' -and (Test-Path $npcSave)) { throw 'Fresh native session requires absent save' }
if ($Phase -eq 'reader' -and -not (Test-Path $npcSave)) { throw 'Native reader requires writer save' }
$npcArgs=@('--resolution','960x640','--position','40,40','--verbose','--log-file',(Join-Path $npcEvidence 'runtime.log'),'--','--p003-evidence')
$npcCwd=$npcStandalone
if ([IO.Path]::GetFullPath($npcCwd).StartsWith([IO.Path]::GetFullPath($npcRoot),[StringComparison]::OrdinalIgnoreCase)) { throw 'Standalone cwd must be outside checkout' }
$npcProcess=Start-Process -FilePath $npcExe -WorkingDirectory $npcCwd -ArgumentList $npcArgs -WindowStyle Hidden -RedirectStandardOutput (Join-Path $npcEvidence 'stdout.log') -RedirectStandardError (Join-Path $npcEvidence 'stderr.log') -PassThru
@{task='G009';phase=$Phase;pid=$npcProcess.Id;exe=$npcExe;arguments=$npcArgs;cwd=$npcCwd;APPDATA=$env:APPDATA;LOCALAPPDATA=$env:LOCALAPPDATA;save_path=$npcSave;override_sha256=(Get-FileHash $npcOverride).Hash;release_sha256=(Get-FileHash $npcExe).Hash;pack_sha256=(Get-FileHash ([IO.Path]::ChangeExtension($npcExe,'.pck'))).Hash;provenance='Native public controls only; read-only movement log; no bridge/fixture/position/fact setup'} | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $npcEvidence 'launch.json')
Write-Output "G009_NATIVE=$npcEvidence PID=$($npcProcess.Id)"
$npcProcess.WaitForExit()
@{pid=$npcProcess.Id;exit_code=$npcProcess.ExitCode;finished_utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content (Join-Path $npcEvidence 'exit.json')
Write-Output "G009_NATIVE_EXIT=$($npcProcess.ExitCode)"
