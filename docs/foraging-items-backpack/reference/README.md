# Pinned foraging/item reference (F001)

Prepared 2026-10-05, America/Vancouver. This is behavioral and geometry evidence,
not a gameplay activation. Follow [CONTRACT](../CONTRACT.md) for target authority.

- [manifest.json](manifest.json) pins 20 source files, three immutable target geography
  inputs, two minimal behavioral references and the geometry baseline. Historical
  target script hashes describe F001; later intentional feature edits need not match them.
- [source_excerpts.json](source_excerpts.json) retains the source gameplay catalog and
  12 line-ranged excerpts for inventory, holds, collection, move/drop, UI and fishing.
  Whole-file SHA-256 remains authoritative; excerpts normalize line endings to LF.
- [behavior_vectors.json](behavior_vectors.json) provides source/target definition
  mappings, four exact authored feet, expected operations and hold/UI/fishing boundaries.
  Vectors specify future target behavior; they do not claim F002+ implementation.
- [geometry_baseline.json](geometry_baseline.json) retains reusable measured support,
  nearby dry approaches, LOS blockers and the F005 repair boundary.
- [audit.py](audit.py) checks hashes, source tuning/excerpts, unique namespaces and
  pinned geography. It never writes, downloads, refreshes or executes Flutter.

Run from repository root with Python 3 (standard library only):

```powershell
$pythonExe = 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $pythonExe docs/foraging-items-backpack/reference/audit.py --self-test
& $pythonExe docs/foraging-items-backpack/reference/audit.py --source-root D:/development/game-prototype-2 --self-test
./tools/run_checks.ps1 -Task F001 -Names reference_mapping_checks -TimeoutSeconds 150
```

Omit --source-root to verify without the source checkout. The optional live-source
mode fails on any pinned file drift or missing source; never silently repin. Self-test
injects changed bytes, missing node, changed height and namespace collision into
in-memory inputs, checks they fail, and leaves every source/target file untouched.
Actual audit failures return exit 1 with exact errors. Review deliberate updates
against the contract before changing pins.

## Source behavior and target adaptations

Source items/resources share moonflower/fishing_rod strings in separate repositories.
Target ContentCatalog has one global stable-ID index, so use item-moonflower and
resource-moonflower; item-fishing-rod and resource-fishing-rod. Physical instance
IDs remain fishing-rod-dock-01 and moonflower-01/-02/-03. Source alderwake maps to
prototype-alderwake. The pinned map, not the current source map, owns geography.

Source inventory state lines63-188 documents capacity20, one stack/type, cap validation
before mutation, growth of an existing stack in a full bag, owned selection and
final-unit selection clearing. Source tests runtime_game_state_test.dart:272-333
specify detached consume/selection and 20/21 capacity behavior. Controller tests
runtime_game_controller_test.dart:156-231 specify once-only notification and distinct
resource/item resolution; :248-417 specifies authored move/drop/recollect and rejection.
These source tests were read, not executed. F002/F003 must create actual target checks.

Source hold code consumes a fresh interactionStartGeneration, cancels when held input
or selected target changes, handles pause requests, and clears progress after completion.
Catalog durations are600ms flower/500ms rod; source radius48 units becomes1.5m.
Target also requires explicit LOS/range/removal/lifecycle cancellation and fresh input
after completion/cancel. Immediate lamps/dialogue/travel retain their existing controls.

Source collection publishes inventory + collected origin + placement removal together.
Its permissive unknown-node fixtures and implicit placement identity are not sufficient
target validation: add authored location/definition/revision checks and explicit provenance.
Source autosave and tutorial/quest/gifting side effects are excluded.

Source backpack renders20 slots, five columns when its inner grid is at least420px,
four otherwise, active details and movable-only Drop. Target uses B/Esc/Close and
mouse/Tab/Enter, modal focus containment, and disabled Drop until F007.

Fishing source exposes inactive/waiting/bite/fighting and explicit failure outcomes.
Only landed calls addActivityReward before success feedback. Retain readable progress,
explicit cancellation and post-success atomic reward discipline. Fish/cast/targeting/
tension/rewards and source autosave are excluded.

## Geometry findings and honest proof limits

Synthetic production probes use installed Godot4.7.2, existing entry GameRoot,
the real pinned exterior, dry navigation from alderwake-start, radius0.4m/height1.6m
capsule clearance at0.1m route samples, floor rays and target LOS at foot+0.8m.

| Instance | Authored foot (m) | Nearby dry reachable foot (m) | Anchor result |
| --- | --- | --- | --- |
| fishing-rod-dock-01 | (-8,0,15.75) | (-7,0,15.75) | water blocker south-water-06 at origin/LOS |
| moonflower-01 | (26,0.25,-2) | (26.75,0.25,-2) | cliff-47-15-east / cliff-47-16-east at origin; LOS blocked |
| moonflower-02 | (34,0.25,7) | (34.75,0.25,7) | supported; clear LOS |
| moonflower-03 | (30,0.5,-9) | (30.75,0.5,-9) | supported; clear LOS |

Underlying floor heights agree with authored Y (rod ray numerical error4.47e-8m).
Rays explicitly exclude obstructing bodies only to measure the underlying support;
those exclusions do not prove usable dry placement. Approaches require unobstructed
floor and capsule routes. The first two target anchors remain unusable even though
nearby dry approaches are reachable. The check asserts those known discrepancies;
it does not bypass collision/LOS or accept F005's four-interaction criterion.

F005 must measure a safe adapter solution with canonical authored identity/XZ and
pinned map preserved. If exact-foot rendering/targeting cannot meet dry support/LOS,
record F005 Blocked with the conflict and proposed contract repair; do not erase water,
rebake geography or relax LOS to manufacture success. This is not a prerequisite
for F002 content rules, F003 transactions, F004 plain saves, or F006 UI.

[Tracked F001 acceptance](../F001_ACCEPTANCE.md) records commands, failures and limits.
No rendered input, native play, resource interaction or live walking was performed.
Runtime/export has no dependency on this folder, source checkout, Dart or Flutter.
Both Windows export presets exclude the new *_checks script.
