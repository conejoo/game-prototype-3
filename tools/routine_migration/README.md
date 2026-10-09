# R001 routine references

These tools and public snapshots are engineering evidence outside `game/`.
Nothing is activated or exported. Read the workflow's
[contract](../../docs/day-clock-npc-routines/CONTRACT.md) and
[R001 acceptance](../../docs/day-clock-npc-routines/R001_ACCEPTANCE.md).

The selected catalog has exactly 25 routines/eight people. `reference/manifest.json`
pins 88 source inputs at `60c20eb2816e7271fb84afaba286af006ebe3ccf`, target baseline
`e10d13edd6035aeb3bac4cbaded6f82b756f8e39`, byte-exact public inputs, derived audits,
and preserved target files. Only selected routine/package documents are copied.
Full public map JSON is geometry/portal authority: its excluded cast, maps and
campaign records do not authorize runtime import. Private profiles/images/Flutter
SDKs/source navigation caches are not copied. Existing NPC art/reference pins stay
owned by `tools/npc_migration`.

From repository root, using verified bundled Python 3.12.14:

```powershell
$routinePython = 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $routinePython -B tools/routine_migration/reference_checks.py --self-test
& $routinePython -B tools/routine_migration/reference_checks.py --source D:/development/game-prototype-2 --self-test --report docs/evidence/R001/<unique-run>/results.json
& $routinePython -B tools/routine_migration/audit_geometry.py --check
```

The first command works with local snapshots and target files alone. The optional
live-source check reads each original input and revision; it never refreshes them.
The negative cases use isolated automatically removed TEMP copies, no saves.
Any bad hash, excluded cast, extra snapshot, unsafe path, mapping/coverage mismatch
or unexplained baseline drift fails. Review intentional target changes in the
owning task, recording path/before/after hash/reason; source pins must not be silently
refreshed. A later runtime task changes target baseline expectations only with its
documented adaptation; this is not a new permission gate.

R004 records schema8/current-fixture adaptations in `adaptations.json` without
editing historical reference bytes. The gate checks each original pin and exact
current after-hash, unique known paths, owner/reason and the one explicit v7-to-v8
fixture relocation. Any unrecorded change still fails. Later tasks must extend
this narrowly reviewed owner policy when recording their own changes.

`pin_reference.py --source <read-only-root>` is a one-shot initial capture, refusing
an existing reference directory. `audit_geometry.py` likewise refuses overwrite.
They are not update commands. Initial capture corrections/dependency additions are
recorded in `capture_history.json` and R001 acceptance. Vectors/budgets are authored
acceptance decisions, not regenerated source semantics.

`coverage.json` maps every step, qualified anchor, routine dialogue entry/outcome,
public flag/fact/choice and action to its downstream owner. `mappings.json` retains
source feet separately from target feet, group transforms and directed portal chains.
`geometry_audit.json` measures both room bounds, doors, capsules and straight-leg
conflicts. Those samples diagnose detours; they do not prove navmesh routes,
collision-free movement, physical support, dialogue LOS or ordinary travel.
`source_semantics.json` pins actual startup/load/ordinary reconstruction differences;
INT-064 remains unresolved. `budgets.json` declares runtime limits before implementation.
Source Dart tests were read/pinned, never executed here.

R002 consumes immutable content and implements its actual Godot checks through
`tools/run_checks.ps1`. Later tasks own all physical/rendered/native acceptance.
