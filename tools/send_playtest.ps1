param(
    [Parameter(Mandatory = $true)][string]$SessionDir,
    [Parameter(Mandatory = $true)][string]$CommandFile,
    [int]$TimeoutSeconds = 40,
    [switch]$FullResponse
)
$ErrorActionPreference = 'Stop'
$taskSessionPath = [IO.Path]::GetFullPath($SessionDir)
$allowedRoot = [IO.Path]::GetFullPath((Join-Path (Split-Path $PSScriptRoot -Parent) 'builds/playtest')) + [IO.Path]::DirectorySeparatorChar
if (-not $taskSessionPath.StartsWith($allowedRoot, [StringComparison]::OrdinalIgnoreCase)) { throw 'SessionDir must be a child of this project builds/playtest.' }
$readyPath = Join-Path $taskSessionPath 'ready.json'
if (-not (Test-Path -LiteralPath $readyPath)) { throw 'No live bridge ready.json. Launch opt-in game first.' }
$ready = Get-Content -LiteralPath $readyPath -Raw | ConvertFrom-Json
$command = Get-Content -LiteralPath $CommandFile -Raw | ConvertFrom-Json
$requestId = 'cmd-' + [Guid]::NewGuid().ToString('N')
$request = @{ id = $requestId; boot_id = $ready.boot_id; steps = $command.steps }
$requestPath = Join-Path $taskSessionPath 'request.json'
if (Test-Path -LiteralPath $requestPath) { throw 'An unconsumed request exists; do not overwrite.' }
$temporaryPath = Join-Path $taskSessionPath ($requestId + '.tmp')
$request | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $temporaryPath -Encoding utf8NoBOM
[IO.File]::Move($temporaryPath, $requestPath)
$responsePath = Join-Path $taskSessionPath ($requestId + '.json')
$deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
while (-not (Test-Path -LiteralPath $responsePath)) {
    if ([DateTime]::UtcNow -ge $deadline) { throw "Timed out; request id $requestId. Check game/bridge before retrying." }
    Start-Sleep -Milliseconds 100
}
$response = Get-Content -LiteralPath $responsePath -Raw | ConvertFrom-Json
if ($FullResponse) {
    $response | ConvertTo-Json -Depth 20
} else {
    @{ response_file = $responsePath; ok = $response.ok; error = $response.error;
       position = $response.after.position; paused = $response.after.paused;
       camera = $response.after.camera; ui_focus = $response.after.ui_focus;
       contacts = @($response.steps.contacts_during_step | Select-Object -Unique);
       images = @($response.steps.image_path | Where-Object { $_ });
       step_elapsed_ms = @($response.steps.elapsed_ms)
    } | ConvertTo-Json -Depth 10
}
if (-not $response.ok) { exit 1 }
