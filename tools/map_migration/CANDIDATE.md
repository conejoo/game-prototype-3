# M003 isolated terrain candidate

From the target repository root:

```powershell
$godotExe = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
& $godotExe --path game res://tests/map_candidate.tscn
# Optional alternate safe arrival, not a travel interaction:
& $godotExe --path game res://tests/map_candidate.tscn -- --candidate-return
& $godotExe --headless --path game --script res://tests/map_candidate_checks.gd
```

Normal main scene and catalog remain unchanged. The alternate root extends the
existing root and appends one location to a detached manifest. Session/services,
WorldHost safe placement, party wrappers, controls and camera are reused. Candidate
defaults to `user://saves/playtest-map-candidate.json`; optional debug `--save-slot`
still selects a named `playtest-*.json` slot. Normal catalog rejects candidate saves.
There is no automatic load or normal save write. Candidate ID is `candidate-alderwake`;
start/return spawn IDs are retained within that detached definition. Production
activation and quest interactions remain M015. The journal is hidden in this harness.

Only normalized `res://content/maps/alderwake_layout.json` is read at runtime.
Snapshot `alderwake-f4630f9-m002` stays authoritative. Run extractor `--check`
before further migration work; do not refresh pinned source inputs automatically.

Preview resolves each visible tile layer separately, preserving layer order, defaults,
explicit null clears, layer origins and 0.5m/1m grids. Center/connected paints use
their named solid material color; masks, variants and animation are deferred to M011.
Adjacent same-material cells merge into row rectangles and seven render batches:
grass, four terrain materials, shoreline, and raw decoration markers. All 183 raw
records keep a 0.12m dot at the center of their source 1m cell; these are explicitly
diagnostic markers, not source artwork. Individual tile IDs and paint kinds remain
in the unchanged layout and preview report. Unsupported material/kind fails scene
validation; pinned extractor validates raw references. Hidden layers emit no visuals.

One separate flat floor covers X[-22,125), Z[-18,62), with four 3m outside perimeter
walls; their visible graybox rims are 0.6m tall to keep party readable. There is
no jump mechanic; taller separate colliders guard the full capsule/dodge. Visual
offsets of 0.003m per layer prevent overlapping planes without changing
physical Y=0. Start (0,0,0) and return (107.25,0,1.25) have the existing +1m X ally
offset and no local blockers. Return is safe in this flat stage only; revalidate
after water/props/heights. Torus/labels identify pads and add no collision.

Water is a neutral blue-gray **walkable preview** until M004. Physical elevations
and ramps are flat until M008. A single perimeter-inset flat navigation polygon
allows existing party lifecycle/follow to operate in this empty stage; M009 must
replace it using complete physical surfaces. This does not certify river routes or
companion recovery. No authored water/prop/catalog blockers, bridge/deck, trees,
landmarks, buildings, art layers, portals, NPCs, routine/resources, zones or activities
are instantiated in M003. Their IDs/provenance remain in pinned data. Future-exit
blocking belongs to M007; only map perimeter is implemented here.

For rendered evidence, use the existing opt-in bridge and `send_playtest.ps1` from
[PLAYTEST.md](../PLAYTEST.md), with a fresh `builds/playtest/m003-*` directory and
named test slot. Its commands inject ordinary viewport input, with no teleport
or session mutation. Use short resume/actions/pause batches and confirm pause.
Headless checks label their synthetic actor placements/physics stepping explicitly.
