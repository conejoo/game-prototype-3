# Current map migration state

Updated 2026-10-03, America/Vancouver. M001 verified complete.

## Selection and progress

- Active migration item: none.
- Completed migration items: M001, coordinate and compatibility contract.
- Next eligible item: M002, pinned source snapshot and layout extraction.
- M002–M019 remain pending; no extraction/candidate implementation started.
- Existing prototype P001–P013 complete. P014 native full release walkthrough
  remains in progress; candidate contract work does not resolve it.

## Workspace and source identity

Target: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot project: `game/`. Workspace parent is not the Git repository.
Target inspected HEAD: `073c924142cb0551a14510d6cd2e85c7f1b8678b`.
Initial unrelated changes preserved: tracked README migration links, untracked
`docs/evidence/P014/resume-2026-10-03/`, existing migration planning files.
No gameplay/source edits, dependency installs, Blender edits, subagents, commits,
pushes or publication. Parent ARCHITECTURE/CURRENT_STATE/P014 remain unchanged.

Source read-only: `D:/development/game-prototype-2`.
Observed HEAD: `f4630f9966d6637ef6579cd87623ea354758191c`.
Shipping exterior: `assets/maps/mvp_world.json`, `alderwake`, 147 × 80 cells,
4704 × 2560 units. Observed SHA-256:
`af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f`.
Object catalog `assets/data/world_objects/catalog.json` SHA-256:
`59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2`.
Both match M001 source measurements. These are observed identities; **no pinned
snapshot or normalized runtime layout exists yet**. M002 must compare before
pinning; after pinning do not auto-refresh from a drifting source checkout.

## M001 result and changed files

- Added [CONTRACT.md](CONTRACT.md): metres/origin/axes, grids/defaults/empty paints,
  group transforms and catalog footprints, physical height/ramps/cliffs, converted
  probes, IDs/portal/save mappings, retained/inert/excluded scope and measured gates.
- Updated CHECKLIST.md: M001 complete, completion record, M002 next.
- Rewrote this state with verified result and next-session memory.
- Added [M001 validation](../evidence/M001/VALIDATION.md), read-only measurement
  script/JSON, import and focused baseline logs, final document-check log.
- Runtime files and production ownership unchanged; no architecture update needed.

## Contract decisions

Confirmed 32 source units = 1m; source (704,576) -> Godot (0,0,0), source X/Y ->
Godot X/Z. Exterior bounds X[-22,125), Z[-18,62). Terrain layers 16 units=0.5m;
decorations/gameplay/art 32 units=1m. Group pivots use gameplay cells. Preserve
fractional feet and point-versus-cell rotation; current groups q0 only, so M002
needs explicit rotated fixtures. Ground's empty cell list still paints grass.

Height 0.25m/level, max 1.75m; one-cell directional ramps interpolate low->high,
other elevation edges block traversal. Moonwell foot maps to
(31.51317596435547,0.5,4.621034622192383). M003–M007 flat preview explicitly
provisional; M008 owns physical grounding, M009 correct walkable navigation.

Bridge/ford authored blocker gaps 3m; party diameter 0.7m, nav diameter 0.8m.
Scale fits nominal clearance. Bridge art's middle deck row is only 1m: do not
turn art rows into solid rails that shrink traversal; require >=1.6m clear width
and documented art adaptation. Static measurement does not certify routes.

Keep production IDs/schema4/content1. Only `tollworks-entrance-01` maps to active
`alderwake-travel-gate` -> existing Tollworks arrival at (0,0,-2.5). Six other
portals stay inert. Retain `tollworks-start` too. One existing `npc-03-counter`
maps source Maris; do not add duplicate NPC/quest effects. Proposed forest return
pad source (4136,616) -> (107.25,0,1.25), 2.5m south of gate, needs full geometry
and two-member physical/navigation safety checks before acceptance/activation.

Candidate first, normal compact room until M015. Preserve source props/trees,
record inert anchors/resource/NPC/portal metadata and exclusions; no full source
campaign, schedules, interiors, economy, romance or retired memory currency.
Contract declares landmark tolerances, route-length/time, visual readability and
frame/draw/memory/nav/load budgets; later stages must measure, not assume passes.

## Exact verification and evidence

Full commands, individual outcomes, failure labels and acceptance mapping:
[docs/evidence/M001/VALIDATION.md](../evidence/M001/VALIDATION.md).
Installed Godot console/editor paths verified; engine ed1daf0bf.
All Godot commands use target root and `--headless --path game`.

Final checks use process-local APPDATA=`<target>/builds/m001-user-data` and
LOCALAPPDATA=`<target>/builds/m001-local-data`. No normal save is accessed.

- `--editor --import --quit`: exit 0, initialization complete with known missing
  .NET SDK10.0.9/certificate-store errors; not claimed error-free.
- `--script res://tests/application_smoke.gd`: PASS, exit 0.
- `--script res://tests/location_travel_checks.gd`: PASS, exit 0, ten round trips,
  party/identity/health preserved, unsafe-placement rollback and room release.
- `--quit-after 1800 --script res://tests/save_checks.gd`: PASS before guard,
  exit 0; codec, isolated IO/backups, root restore and unsafe-arrival rollback.
- `--script res://tests/playable_slice_checks.gd`: PASS, exit 0; presentation/
  lifecycle/synthetic rules only, no full ordinary-input walkthrough claim.
- `& ./docs/evidence/M001/inspect_contract.ps1`: process exit 0, PASS; 19 converted
  probes, seven portals, mixed grids, fractional Moonwell/catalog/nominal clearance.
- Final document links/fences/required topics/inventory/status check: exit 0.
- `git diff --check` plus untracked-document whitespace/intended-file review: exit 0.

Initial default-AppData import/application/travel logs retain sandbox IO errors.
Initial save test dereferenced nil after inaccessible IO; no PASS, interrupted
launcher exit 1; isolated rerun fixed environment without runtime changes.
Measurement script's initial PowerShell array-parenthesis error repaired; final
run passes. Final runtime logs retain restricted certificate-store error but no
GDScript errors. No source tests, rendered gameplay or performance benchmark run.

## Unresolved issues and next-session handoff

No M001 blocker. Source snapshot/extractor/normalized layout/candidate scene are
absent by design. Safe forest return pad, actual crossings/rail clearance, ramps,
nav bake cost, cross-bank catch-up connectivity, slope aiming/canopy visibility,
large-map hints, runtime performance and pre-migration save placement remain
owned by their sequential checklist items. P014 native release gate still open;
M019 must reconcile resulting build and native ordinary-input evidence.

Select M002 only. Read applicable instructions/contract, inspect Git and actual
source identity; pin required supported inputs under tools/map_migration/reference,
write target-local extraction/check command and game/content/maps normalized
layout with provenance/exclusion reporting. Verify deterministic regeneration,
stale check, malformed/unknown data, rotation/cell transform fixture, polygon,
fractional Moonwell and all seven portals. Do not begin M003 this session.
