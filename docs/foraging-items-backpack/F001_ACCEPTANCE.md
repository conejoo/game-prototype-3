# F001 acceptance — pinned behavior and runtime mapping

Completed2026-10-05, America/Vancouver. F001 only. Production gameplay remains unchanged.
Target HEAD8274a251cfa27d4ac66cf1fea99e06c9630aaf8d; read-only source HEAD
60c20eb2816e7271fb84afaba286af006ebe3ccf. Both match planning. Initial target changes:
README.md plus untracked workflow folder; preserved. Source Git status empty, queried
with per-command safe.directory override; no global Git configuration or source writes.

## Acceptance evidence

| Criterion | Result and evidence |
| --- | --- |
| Reproducible audit detects drift | PASS: target-only and optional live-source audits; 20 source hashes, three target geography hashes, three local reference hashes; changed-byte, missing-node, changed-foot and namespace collision negative controls |
| Four exact IDs/feet mapped | PASS: vectors reproduce pinned source XY -> Godot X/Z with32 units/m, origin(704,576); production check confirms four inert records, floor heights, dry capsule approaches and LOS results |
| Durations/limits/slots/fishing inspiration reproducible | PASS: source catalog and12 line-ranged excerpts; 20 slots, caps99/1,600/500ms; declarative inventory/hold/transaction/UI vectors; landed-only award boundary |
| No runtime source dependency | PASS: production .gd/.tscn/.tres/project scan finds no source checkout access/import; only existing layout test mentions source paths as rejection strings; source excerpts/auditor outside game; both presets exclude new *_checks script |
| No unresolved F002 design prerequisite | PASS: distinct four definition stable IDs, explicit resource->item mappings, immutable catalog/session ownership, count/selection/ordering rules resolved; schema6/provenance plan recorded |
| Geometry discrepancy/repair boundary recorded | PASS: underlying Y matches; rod water anchor and flower01 cliff anchor blocked; exact blockers/dry approaches pinned; F005 must repair or block before its acceptance, with map/LOS authority retained |
| Fresh P/M/W baseline checks | PASS: application_smoke, content_catalog_checks, map_activation_checks, environment_save_checks; current production entry separately checked by mapping suite |

The two blocked authored anchors are actual future activation constraints. F001's check
passes because it detects and pins them, not because it declares them safe. Neither
F005's reachable four-node interaction criterion nor any ordinary input criterion is met.
F002 content rules do not depend on those physical anchors.

## Commands and isolation

All commands ran from D:/development/game-dev-blender/returning-fair-prototype,
using PowerShell7 and checked installed Godot console path. Engine version:
4.7.2.stable.mono.official.ed1daf0bf. Baseline:

```powershell
./tools/run_checks.ps1 -Task F001 -Import -Names application_smoke,content_catalog_checks,map_activation_checks,environment_save_checks -TimeoutSeconds 150
```

PASS report: ../evidence/F001/20261005-072246477-fde37221/results.json.
All seven cases passed; inspected results and stdout/stderr diagnostics, not exit alone.
application_smoke proves composition/pause/detached state in its fixture room;
map_activation and F001 mapping prove current production exterior. Catalog validates17
definitions; environment suite validates schema5 and retained legacy facts.

Final geometry run:

```powershell
./tools/run_checks.ps1 -Task F001 -Import -Names reference_mapping_checks -TimeoutSeconds 150
```

PASS report: ../evidence/F001/20261005-073211388-5575def8/results.json.
Production root instantiated, schema5/content1 asserted, resources remain inert;
all four expected geometries verified;1,648 capsule route samples.
Raw per-node/path measurements:
../evidence/F001/20261005-073211388-5575def8/checks/reference_mapping_checks/resource-mapping-report.json.
Reusable compact measurements: [geometry baseline](reference/geometry_baseline.json).

Each engine run uses separate builds/testing/F001/<run-id>/appdata and localappdata,
save slot check-<run-id>, and fresh docs/evidence/F001/<run-id>. Normal user save untouched.
No timeout/runtime error/warning in accepted runs. Import-only allowed diagnostic:
"ERROR: .NET Sdk not found. The required version is '10.0.9'." No SDK installed.

```powershell
$pythonExe = 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $pythonExe docs/foraging-items-backpack/reference/audit.py --self-test
& $pythonExe docs/foraging-items-backpack/reference/audit.py --source-root D:/development/game-prototype-2 --self-test
```

Both PASS, exit0/errors empty. Five offline negative controls; six source controls.
Raw output/commands: ../evidence/F001/audit-20261005-073430-9fcda68c/results.json.
Auditor is read-only and uses no save/engine paths. Source tests were read, not run;
no Dart/Flutter dependency or installation added.

## Retained failures and limits

- 20261005-072900870-3e922a72: geometry probe failed because initial ray correctly
  hit water/cliffs before underlying floor, rather than an unobstructed support surface.
- 20261005-073026478-4a95c991: underlying support measured, but the naive assumption
  that every exact origin has clear LOS failed for rod/flower01.
- Final check explicitly asserts those deficiencies and nearby dry routes.
  Earlier reports retained; no map or gameplay fix concealed.

No live editor, rendered game, native input or ordinary walking launched. Rays/nav/
capsule probes are synthetic, not usable enabled-resource proof. No engine process
remains owned. F002+ runtime/save/UI/placement behavior and source tests unrun.

## Changed artifacts and next task

Created reference README/audit/manifest/excerpts/vectors/geometry, F001 acceptance,
game/tests/reference_mapping_checks.gd and generated UID. Updated CONTRACT,
CHECKLIST, CURRENT_STATE, README discovery and architecture discovery. No production
script/content/layout/art/save/export change. Review checked links, task/status
consistency, hashes and whitespace.

Next eligible: F002 — immutable item/resource definitions and20-slot inventory rules.
F001 evidence/mappings available locally. Stop before F002.
