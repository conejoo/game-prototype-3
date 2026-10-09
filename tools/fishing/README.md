# Fishing reference tools (FS001)

These are development-only references and checks, not production fishing owners.
The runtime and exports must not depend on this directory or the source checkout.

`reference/manifest.json` pins 18 source files (working bytes, not only Git HEAD),
six unchanged geography owners and three local reference artifacts. Source tests
and four icons are hashed without copying them into runtime. `source_excerpts.json`
retains bounded challenge, resolver, targeting, shape and orchestration excerpts.
`rules.json` retains four exact item records, three source and Godot area records,
timing/tier constants, RNG and cancellation policy. `behavior_vectors.json` supplies
26 closed-shape cases, five distributions, 38 interval/no-area cases, three wait
rolls, four cast sites and five negative points.

From repository root, use the installed bundled Python (outside PATH here):

```powershell
$pythonExe = 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $pythonExe tools/fishing/reference_audit.py
& $pythonExe tools/fishing/reference_audit.py --source-root D:/development/game-prototype-2
./tools/run_checks.ps1 -Task FS001 -Names fishing_reference_checks,inventory_checks,reference_mapping_checks,map_water_checks,map_crossing_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task FS001 -RenderOnly -RenderScript fishing_reference_render -RenderPhases sites -TimeoutSeconds 150
```

The offline auditor uses local pins/vectors only. Live audit also rejects changed
source hashes and checks each excerpt against its exact source line range. It never
repins. `freeze_reference.py` was the reviewed FS001 bootstrap: it refuses an existing
reference directory. Do not remove pins or invoke it to hide future drift.

The source map differs from the historical map used to build Godot geography.
All three live fishing shapes/profiles still transform exactly to retained records;
no map regeneration, bank/collider/deck/navigation or source edit was made.

Area boundaries are closed, including rectangle right/bottom edges. Polygon
membership uses the source-unit cross-product/segment epsilon 1e-6. Map bounds and
water/deck half-metre occupancy remain half-open. Snap relative to (-22,-18), then
query cell center; distance is horizontal from current hero feet, inclusive 12m.
Sorted source item IDs accumulate weighted probabilities; reward mass is never
normalized. A profile lacking an item contributes zero. No-area consumes no RNG
and starts no attempt; miss consumes an encounter roll, then independent wait roll.
Production rolls must be finite [0,1); wait is 1.5+1.5*roll. Reject invalid inputs
instead of preserving the source helper's out-of-domain clamp.

Actual water mesh is undisplaced Y=.015m. Safety bodies extend to Y=3m and exclude
walking; they are not water surfaces or solid cast occluders. Only these named water
bodies may be excluded from fishing rays. Keep the gate, terrain, cliffs and other
structures. Dry semantic dock/bridge occupancy wins before underlying water/base
floor. Dock physical tops Y=0 and separate art Y=.022 stay unchanged. FS004 still
owns pointer projection, camera occlusion, zoom and preview implementation.

Sunken Reeds lies within the union of Dock Shallows and Lake Channel. It has no
independent-only interior. Audit both overlaps: golden-carp probability is 2/15 in
the dock/reeds overlap and 43/300 in channel/reeds; channel-only remains .03.
No probability, cast range or geography was changed to manufacture a site.

Synthetic geometry/nav/capsule/line checks are distinct from the fresh rendered
WASD journeys. The render check walks from real startup without pose, progress,
clock, item or RNG setup, uses TestRunJourney/Gui/Capture and records all failures.
Screenshots show dry approaches and verified pause; they do not show a working cast,
bite or landed catch. Runtime fishing activation belongs to later tasks.

See [FS001 acceptance](../../docs/fishing/FS001_ACCEPTANCE.md) and
[contract](../../docs/fishing/CONTRACT.md) for measured sites and deliberate 3D,
phase-time carry and manual-save adaptations. Existing source autosave and its
frame-boundary overshoot discard are not target behavior. No production edits,
new save fields, inventory awards, native release or source Flutter suite here.
