$ErrorActionPreference = 'Stop'
$taskEvidence = Join-Path (Get-Location) 'docs/evidence/AD012/authoring-20261011'
$scope = @('art/exports/NPC_PIPELINE.md','art/source/storybook/npc-painted-recipe.json','docs/art-direction-storybook/AD012_ACCEPTANCE.md','docs/art-direction-storybook/CHECKLIST.md','docs/art-direction-storybook/CURRENT_STATE.md','game/features/npcs/npc_visual_presenter.gd','game/features/npcs/storybook_npc_material.gd','game/features/npcs/storybook_npc_material.gd.uid','game/features/npcs/storybook_npc.gdshader','game/features/npcs/storybook_npc.gdshader.uid','game/tests/storybook_npc_checks.gd','game/tests/storybook_npc_checks.gd.uid','game/tests/art_direction_npc_render.gd','game/tests/art_direction_npc_render.gd.uid','game/tests/npc_asset_pipeline_checks.gd','game/tests/npc_action_checks.gd')
foreach($id in '01','02','03','04','06','07','08','14'){ $scope += ('game/tests/npc_'+$id+'_checks.gd') }
if($scope.Count -ne 24){throw 'Scope count mismatch'}
$records = @($scope | ForEach-Object { @{path=$_;sha256=(Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash} })
@{task='AD012';count=$records.Count;paths=$records} | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $taskEvidence 'task-scope.json')
$before = Get-Content (Join-Path $taskEvidence 'starting-manifest.json') -Raw | ConvertFrom-Json -AsHashtable
$protected = 0; $changed = @(); $unexpected = @()
foreach($p in $before.files.Keys){
    if($p -notin $scope){$protected++}
    if(-not (Test-Path -LiteralPath $p -PathType Leaf) -or (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash -ne $before.files[$p]){
        $changed += $p
        if($p -notin $scope){$unexpected += $p}
    }
}
$currentPaths = @(git -c safe.directory=D:/development/game-dev-blender/returning-fair-prototype ls-files --cached --others --exclude-standard)
$added = @($currentPaths | Where-Object {$_ -notin $before.files.Keys})
$unexpected += @($added | Where-Object {$_ -notin $scope})
@{starting_files=$before.files.Count;protected_files=$protected;allowed_existing_changes=$changed;allowed_added=$added;unexpected=$unexpected} | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $taskEvidence 'preservation-audit.json')
if($unexpected.Count){throw ('Unexpected files: '+($unexpected -join ','))}
$source = Get-Content docs/evidence/AD012/20261011-093006695-2beeef8b/source-after.json -Raw | ConvertFrom-Json
$sourceMismatch = @($source.files | Where-Object {(Get-FileHash -LiteralPath $_.path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $_.sha256.ToLowerInvariant()})
@{files=$source.file_count;sha256=$source.sha256;mismatches=$sourceMismatch;matches=($sourceMismatch.Count -eq 0)} | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $taskEvidence 'source-final-audit.json')
if($sourceMismatch.Count){throw 'Accepted source bytes changed'}
$reports = @(Get-ChildItem docs/evidence/AD012 -Directory | Where-Object Name -Match '^\d{8}-' | ForEach-Object { $p=Join-Path $_.FullName 'results.json'; if(Test-Path $p){Get-Content $p -Raw | ConvertFrom-Json} })
$reports += Get-Content builds/testing/AD012/prepaint-baseline/docs/evidence/AD012/20261011-091832187-285243d0/results.json -Raw | ConvertFrom-Json
$ids = @(@($reports.cases.launcher_pid)+@($reports.cases.engine_pids) | Where-Object {$_ -gt 0} | Sort-Object -Unique)
$alive = @($ids | ForEach-Object {Get-Process -Id $_ -ErrorAction SilentlyContinue} | Select-Object Id,ProcessName)
@{recorded_count=$ids.Count;recorded_pids=$ids;alive=$alive;all_recorded_exited=($alive.Count -eq 0);input='no native or held input; synthetic fixture only';editor='no live editor/Blender changes'} | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $taskEvidence 'cleanup-pids.json')
if($alive.Count){throw 'Owned PID still alive'}
$capture = Get-Content (Join-Path $taskEvidence 'accepted-capture-build.json') -Raw | ConvertFrom-Json
$review = @{task='AD012';capture_report=$capture.report;inspected_contact_sheets=$capture.sheets;inspected_capture_count=152;full_size=@('npc-03-painted-front','npc-02-forest-false-1_0','npc-14-inn-true-1_0','npc-03-storm-night-true');accepted=$true;findings='All eight recognizable. Original silhouette/control masks identical. Skin/cream groups read above dark clothes in real town/forest/inn/storm-night. Paint and source accessories stable through manually sampled phases and actual mixer advances. Maris single blue LSB recorded; no visible texture popping.'}
$review | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $taskEvidence 'pixel-review.json')
git -c safe.directory=D:/development/game-dev-blender/returning-fair-prototype -c core.whitespace=cr-at-eol diff --check
if($LASTEXITCODE -ne 0){throw 'Whitespace audit failed'}
$staged = @(git -c safe.directory=D:/development/game-dev-blender/returning-fair-prototype diff --cached --name-only)
if($staged.Count){throw 'Unexpected staged paths'}
Write-Output ('PASS: '+$scope.Count+' task paths; '+$before.files.Count+' starting/'+$protected+' protected files; '+$source.file_count+' accepted sources; '+$ids.Count+' owned PIDs exited; no staged changes')
