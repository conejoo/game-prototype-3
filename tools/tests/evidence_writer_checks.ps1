#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$writers = [ordered]@{
    map_elevation_checks = @('M008/elevation-report.json')
    map_navigation_checks = @('M009/navigation-report.json')
    map_forest_checks = @('M009/forest-report.json')
    map_companion_checks = @('M010/companion-report.json')
    map_landscape_checks = @('M011/landscape-report.json')
    map_tree_art_checks = @('M012/tree-report.json')
    map_town_art_checks = @('M013/town-art-report.json','M013/tour-guide.json')
    map_landmark_art_checks = @('M014/landmark-art-report.json','M014/tour-guide.json')
    map_activation_checks = @('M015/activation-report.json','M015/tour-guide.json')
    map_camera_checks = @('M016/camera-report.json','M016/camera-tour-guide.json')
    map_save_checks = @('M017/checks-report.json','M017/write-report.json','M017/read-report.json')
}
# Old archives are optional. Protect their bytes when present and their absence
# when missing; acceptance never depends on having retained a historical run.
$before = @{}
foreach ($relative in @($writers.Values | ForEach-Object { $_ })) {
    $path = Join-Path $projectRoot ('docs/evidence/' + $relative)
    $before[$path] = if (Test-Path -LiteralPath $path -PathType Leaf) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash } else { $null }
}
try {
    $headless = @($writers.Keys | Where-Object { $_ -notin @('map_tree_art_checks','map_save_checks') })
    # MultiMesh transforms require Compatibility. Save write/read omit the old
    # checks phase's deliberately logged retry failure; diagnostics still fail.
    $invocations = @(@('-Names',($headless -join ',')),
        @('-RenderOnly','-RenderScript','map_tree_art_checks','-RenderPhases','check'),
        @('-RenderOnly','-RenderScript','map_save_checks','-RenderPhases','write,read'))
    foreach ($arguments in $invocations) {
        $lines = @(& (Join-Path $PSHOME 'pwsh.exe') -NoProfile -File (Join-Path $projectRoot 'tools/run_checks.ps1') -Task TESTING @arguments -TimeoutSeconds 120)
        $exitCode = $LASTEXITCODE
        $reportPath = @($lines | Where-Object { $_ -like 'REPORT=*' })[-1].Substring(7)
        $report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
        Write-Output ("REPORT=" + $reportPath)
        if ($exitCode -ne 0) { throw 'Migrated writer regression failed; inspect retained case logs.' }
        foreach ($case in @($report.cases | Where-Object { $_.label -in $headless -or $_.label -like 'render-*' })) {
            $outputs = @(Get-ChildItem -LiteralPath $case.evidence_directory -Filter '*.json' -File)
            if ($case.status -ne 'passed' -or $outputs.Count -eq 0) { throw "No fresh report from $($case.label)" }
            foreach ($file in $outputs) { $null = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json }
        }
    }
} finally {
    foreach ($path in $before.Keys) {
        $after = if (Test-Path -LiteralPath $path -PathType Leaf) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash } else { $null }
        if ($after -ne $before[$path]) { throw "Historical evidence changed: $path" }
    }
}
Write-Output "Evidence writers: PASS writers=$($writers.Count) historical_paths=$($before.Count)"
