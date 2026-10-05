# Foraging, items and backpack current state

Updated2026-10-05, America/Vancouver. Read [CHECKLIST.md](CHECKLIST.md),
[AGENT_PROMPT.md](AGENT_PROMPT.md), [CONTRACT.md](CONTRACT.md).

## Selection

F001 Done; F002-F010 Pending. Active task: none.
Next eligible: F002 — content and20-slot inventory rules.
Next action: inspect current user changes, read F001 reference/vectors/acceptance,
verify audit plus prerequisite artifacts, mark F002 In progress before edits.
This session completed exactly F001 and stops before successor.

## Baseline and preserved work

Target HEAD8274a251cfa27d4ac66cf1fea99e06c9630aaf8d; read-only source HEAD
60c20eb2816e7271fb84afaba286af006ebe3ccf. Both planning HEADs and eight hashes match.
Initial target Git status: README.md modified; docs/foraging-items-backpack/ untracked.
Those planning changes preserved. Source worktree clean before/after audit; Git
used -c safe.directory only for that read-only checkout, no global config changes.

Historical P/M/W completion retained. Current production uses game/app/game_root.tscn,
pinned Alderwake exterior, schema5/content1,17 immutable catalog definitions. Session
has environment/quest/party/progression but no inventory/foraging state. Resources
stay inert data; interaction kinds talk/inspect/travel/light remain immediate.
F001 changed no production scripts, content, art, layout, geography, saves or exports.

## F001 delivered artifacts and decisions

[Acceptance](F001_ACCEPTANCE.md), [reference guide](reference/README.md),
[manifest](reference/manifest.json), [vectors](reference/behavior_vectors.json),
[excerpts](reference/source_excerpts.json), [geometry](reference/geometry_baseline.json),
[auditor](reference/audit.py), and
[production geometry check](../../game/tests/reference_mapping_checks.gd) plus UID.
Updated this state/checklist/CONTRACT and parent README/architecture discovery.
Manifest pins20 source files, three geography files, three reusable reference files,
and historical target script observations. Runtime has no source/Flutter dependency.

Resolved item-moonflower/resource-moonflower and item-fishing-rod/resource-fishing-rod,
source alderwake -> prototype-alderwake, original four instance IDs and exact feet.
Pinned caps99/1,20 types/one stack each,600/500ms holds, owned nullable selection,
source atomic reward/placement outcomes, UI/fishing inspiration and excluded features.
CONTRACT records schema6 proposed fields, explicit authored_override/generated_drop
provenance, deterministic dropped-fishing_rod identity and exactly-one durable rod.

## Verification, commands and isolation

Repository-root PowerShell7:
- ./tools/run_checks.ps1 -Task F001 -Import -Names application_smoke,content_catalog_checks,map_activation_checks,environment_save_checks -TimeoutSeconds 150
  PASS; docs/evidence/F001/20261005-072246477-fde37221/results.json.
- ./tools/run_checks.ps1 -Task F001 -Import -Names reference_mapping_checks -TimeoutSeconds 150
  PASS; docs/evidence/F001/20261005-073211388-5575def8/results.json; four nodes and1,648 capsule samples.
- Bundled Python reference/audit.py --self-test, then --source-root D:/development/game-prototype-2 --self-test
  both PASS; docs/evidence/F001/audit-20261005-073430-9fcda68c/results.json.
  Offline works without source; negative controls detect hashes/node/foot/namespace drift.

Runner checked Godot console/editor paths, engine4.7.2.stable.mono.official.ed1daf0bf;
isolated APPDATA/LOCALAPPDATA under builds/testing/F001/<run-id>, check-<run-id> save slot.
Inspected results and diagnostic logs. Accepted runs: no runtime error/warning/timeout;
only documented editor import missing .NET SDK10.0.9 diagnostic allowed. No SDK install.
Normal user save untouched. Source tests read, not executed. No native/rendered input.
Documentation links/status/hash consistency and git diff --check verified.

Retained failed geometry evidence:
20261005-072900870-3e922a72 initial rays hit obstructors;
20261005-073026478-4a95c991 exact-origin LOS assumptions failed.
Final check pins actual discrepancies rather than claiming interactions work.

## Known activation constraints and remaining work

All four underlying heights match authored feet. Synthetic dry capsule routes exist:
rod(-7,0,15.75), flower01(26.75,0.25,-2), flower02(34.75,0.25,7),
flower03(30.75,0.5,-9). Flower02/03 clear LOS. Rod authored foot(-8,0,15.75)
inside south-water-06; flower01(26,0.25,-2) overlaps cliff-47-15-east/cliff-47-16-east.
Nearby dry route does not make either exact anchor usable. F005 must resolve safe
adapter/visual/LOS placement under unchanged authored XZ/map authority; if impossible,
record exact design conflict and Block F005. No LOS bypass, collider removal, map
refresh or geography rebake authorized. This does not block F002-F004/F006.

F002-F010 acceptance unverified. No gameplay feature activated in F001.
No source save import, fishing, tutorial side effects, autosave, economy/gifting,
new NPC/campaign, combat redesign or unrelated work in scope.
Runner processes exited; no editor/live game launched or cleanup owed.
Raw ignored evidence preserved; durable references sufficient for continuation.
