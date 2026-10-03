# Alderwake map migration contract

M001/M002 verified 2026-10-03 (America/Vancouver). This contract fixes conversion
and acceptance targets; it does not certify an implemented exterior. M002 pinned
inputs; M003–M014 build an isolated candidate, M015 activates it, and M019 verifies
the resulting Windows build against the native release gate. Parent P014 completed
for the compact prototype after M001; that evidence does not certify a future map build.

## Authority and ownership

Shipping source: `D:/development/game-prototype-2/assets/maps/mvp_world.json`,
map `alderwake`, source HEAD `f4630f9966d6637ef6579cd87623ea354758191c`.
Map SHA-256 `af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f`.
Object catalog: `assets/data/world_objects/catalog.json`, SHA-256
`59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2`.
M002 compared these hashes before pinning byte-exact inputs under
`tools/map_migration/reference/`. Snapshot `alderwake-f4630f9-m002` and its manifest
also pin terrain/raw-tile/art registries needed for exterior record resolution.
Normalized layout is `game/content/maps/alderwake_layout.json`; its provenance and
the extraction report carry input/manifest/extractor hashes. The target snapshot
wins; source drift requires deliberate reconciliation, never automatic refresh.
Older forest-document hashes and generators cannot replace shipping geography.
See [extractor schema and commands](../../tools/map_migration/README.md) and
[M002 acceptance](../evidence/M002/VALIDATION.md).

Godot 4.7.2 typed GDScript remains the runtime. GameRoot composes existing
GameSession/services, WorldHost, persistent Party, CameraRig and UI. Location
wrappers own collision, navigation and presentation; session/services own health,
quest/effect, relationship and upgrade facts. Terrain, imported art, collision,
navigation, interactions and durable IDs are separate. Visual replacement must
not change blockers or IDs. No Dart runtime, source navigation caches or new
global authority. Source is read-only; no source generators are run.

Normal Alderwake remains the compact room until M015. Candidate harness uses a
detached catalog and explicit test-save slot. Candidate-only location IDs cannot
enter the normal catalog or normal save. Tool output must be deterministic,
target-local and independent of the source checkout at runtime/export; extraction
must never overwrite authored scenes or Blender sources.

## Coordinates, grids and transforms

Use one Godot metre per 32 source units. Source spawn `(704,576)` is the exterior
origin. For a logical source point `(sx,sy)` and physical surface height `h`:

```text
Godot (X,Y,Z) = ((sx - 704)/32, h, (sy - 576)/32)
source (sx,sy) = (32*X + 704, 32*Z + 576)
east = +X; south = +Z; north = -Z; up = +Y
```

Bounds are `X [-22,125)`, `Z [-18,62)`: 147 × 80m. Moonwood's source rectangle
`(1504,0,3200,2560)` maps to `X [25,125)`, `Z [-18,62)`. Footprint/boundaries use
logical coordinates, never source elevation-projected screen coordinates.

| Coordinate type | Conversion / rule |
| --- | --- |
| Point/foot/portal destination | Floating source units; preserve fractional values, convert once |
| Explicit rectangle | Convert left/top as point; width/height divide by 32; no recentering before flattening |
| Gameplay/elevation cell `(cx,cy)` | 32 units; top-left `(cx-22, cy-18)` in X/Z, center adds 0.5 |
| Ground/terrain/shoreline tile cell | Layer `cellSize=16`; 0.5m, 294 × 160 cells over full extent |
| Decorations/art cell | 32 units; 1m; image pixel dimensions do not determine geometry |
| Group pivot | Gameplay grid point, `pivotX*32,pivotY*32`; not a 16-unit terrain cell |
| Catalog footprint | Foot-relative units; transform corners/vertices then divide by 32 |

Preserve layer order/visibility, default paints and explicit empty overrides.
Ground has zero explicit cells but default center-material grass. Absent paint
uses layer default; explicit null clears that layer only. No default grass holes
or silent paint-kind substitutions; unsupported data fails or is explicitly
reported with record identity and reason. M002 retains semantic paint/material
and art references without importing source renderer behavior.

Normalize group quarter turns `q=((q%4)+4)%4`. Points rotate clockwise in the
source X/Y plane before pivot translation: q0 `(x,y)`, q1 `(-y,x)`, q2 `(-x,-y)`,
q3 `(y,-x)`. Godot yaw for the same local X/Z rotation is `-q*90 degrees`.
Cell **top-lefts** instead transform to q0 `(px+x,py+y)`, q1 `(px-y-1,py+x)`,
q2 `(px-x-1,py-y-1)`, q3 `(px+y,py-x-1)`. Rotate all rectangle corners; preserve
polygon vertices. Carry the group's rotation into catalog collision, not just
the prop's transformed foot. Destination coordinates belong to the destination
map and must not receive the exterior group/origin transform. All current 31
groups are q0; M002 still needs a rotated fixture to certify the other cases.

Respect `collisionEnabled` (default true), collision kind none/box/polygon and
source default rules. Moonwell has an eight-vertex polygon, not its 96-unit sprite
square. Reed Chandlery at group foot `(480,896)` has local box
`(-90,-72,169,68)`: world source `(390,824,169,68)` and Godot X/Z rectangle
`(-9.8125,7.75,5.28125,2.125)`. Its sprite is 192 × 160 units; that larger square
must not block Maris's reserved pad. Future gate art explicitly disables catalog
collision; the separately authored `future-exit-gate` rectangle is authoritative.

## Physical heights and clearance

Flat height `h=0.25*level` metres; absent elevation cell is level 0. There are
472 overrides, maximum level 7 (1.75m), and 16 directional one-cell slopes.
A slope's low neighbor is opposite ascent and high neighbor is along ascent;
high level must equal low+1. Interpolate across its 1m cell from low height to
low+0.25m. North progress `1-localY`, east `localX`, south `localY`, west
`1-localX`. This gives rise/run 0.25 and slope approximately 14.04 degrees.
Adjacent slopes with matching ascent may form a wider ramp. Other differing-level
edges and ramp sides are cliffs, including diagonal shortcuts. No automatic
steps across cliffs. Source 8-unit visual lift is not a physical height rule.

M003–M007 may explicitly preview flat heights; M008 must implement these heights,
grounding and cliffs, then validate all anchors/crossings again. M009 navigation
must use real walkable surfaces and exclude water/blocker tops/art. Retain 0.4m
nav radius and 1.6m height initially; the tiny-room 0.1m max climb cannot replace
ramps. Do not raise climb to cross 0.25m cliff edges. Aim-on-height and canopy
visibility remain M016 gates. Any necessary height/clearance adaptation requires
named records, measured reason and contract/evidence update, not global rescaling.

Both party wrappers have capsule radius 0.35m, height 1.6m, foot-relative center
Y=0.8m. Hero speed stays 4m/s (dodge 2.5×), physics movement remains authoritative.
Measured bridge blocker gap is source Y `[512,608)` (3m); ford gap `[928,1024)`
(3m). Hero diameter 0.7m leaves nominal 2.3m center corridor; nav diameter 0.8m
leaves 2.2m before voxel erosion/other props. Even source test radius 18/32=0.5625m
and nav radius+clearance 23/32=0.71875m fit these nominal openings. This confirms
scale for candidate work; it is not physical route acceptance.

Bridge art occupies source X `[3744,3936)`, Y `[512,608)` (6 × 3m); the middle
deck art row alone is only 1m wide. Full-row solid rails would contradict the
larger source movement footprint. M005 must place rails at corridor edges and
keep at least 1.6m clear usable width, enough for existing nav and capsule plus
margin; M014 records any visual rail/deck adaptation. Ford cells x89–95,y29–31
span Godot X `[67,74)`, Z `[11,14)`. Water remains blocked on both adjacent sides;
no third crossing, swimming or ferry.

Party arrival retains hero at anchor and ally at `anchor + (1,0,0)`. Require
0.4m horizontal clearance around both feet, 1.6m headroom plus 0.02m collision
query margin, level floor with normal Y>=0.9, and floor within existing ±0.2m
ray range. Both feet must share a reachable safe surface; anchors on ramps,
water, props or across cliffs are invalid. Reserve a minimum 2 × 2m flat arrival
pad centered on the midpoint of the two feet. Final safety uses actual capsule
queries/navigation, not this nominal reservation. Keep suspension, synchronization,
validated placement and rollback; M010 additionally requires catch-up connectivity.

## Converted landmark and route probes

Values below are Godot **(X,Y,Z)** in metres after final physical heights.
Data-only values are reproduced in [M001 measurements](../evidence/M001/source-measurements.json).
They are test targets, not assertions of current scene contents. Moonwell's prop
foot is a placement target; route to a clear nearby approach rather than through
its blocking polygon.

| Probe | Source logical point | Godot point |
| --- | --- | --- |
| `alderwake-start` | (704,576) | (0,0,0) |
| Maris / fitting foot | (464,928) | (-7.5,0,11) |
| Fitting player | (512,944) | (-6,0,11.5) |
| Customer | (560,944) | (-4.5,0,11.5) |
| Entry ramp west / east | (1488,592) / (1552,592) | (24.5,0,0.5) / (26.5,0.25,0.5) |
| Footbridge west / east | (3680,560) / (4000,560) | (93,0,-0.5) / (103,0,-0.5) |
| Ford west / east | (2816,976) / (3104,976) | (66,0,12.5) / (75,0,12.5) |
| Moonwell exact foot | (1712.421630859375,723.8731079101562) | (31.51317596435547,0.5,4.621034622192383) |
| Tollworks entrance center | (4136,536) | (107.25,0,-1.25) |
| Proposed `alderwake-from-tollworks` pad | (4136,616) | (107.25,0,1.25) |
| Closed-exit approach | (4592,352) | (121.5,0,-7) |
| Beyond explicit gate | (4680,352) | (124.25,0,-7) |
| Water: bridge north cell (120,15) | (3856,496) | (98.5,0,-2.5) |
| Water: bridge south cell (120,19) | (3856,624) | (98.5,0,1.5) |
| Water: ford north cell (92,28) | (2960,912) | (70.5,0,10.5) |
| Water: ford south cell (92,32) | (2960,1040) | (70.5,0,14.5) |

Tollworks source trigger `(4104,512,64,48)` maps to X/Z rectangle
`(106.25,-2,2,1.5)`. Explicit east gate `(4640,224,64,256)` maps to
`(123,-11,2,8)`. Beyond-gate probe remains inside map bounds: the gate, not the
perimeter, must block it in both directions. Proposed return pad is 2.5m south
of gate center, outside current 1.6m travel reach, and has no ungrouped prop foot
within the inspected 100-source-unit neighborhood. It remains **unverified**
until full geometry/party-placement tests in M003/M007/M008/M017; if adjustment
is needed preserve ID, document offset and recheck travel reach/clearance.

## Stable IDs, portals and save compatibility

| Source / existing fact | Runtime mapping |
| --- | --- |
| `alderwake` | `prototype-alderwake`, activated at M015 |
| `buried-tollworks` | Existing `prototype-tollworks`; keep compact interior |
| Source player spawn | `alderwake-start` at converted source spawn |
| Exterior return | `alderwake-from-tollworks` at validated forest entrance pad |
| Source Tollworks destination (128,480) | **Do not convert using exterior origin**; adapt to existing `tollworks-from-alderwake` at (0,0,-2.5) |
| Existing `tollworks-start` | Retain unchanged at (0,0,0), including catalog/save validity |
| `maris-chandlery-01` / `npc-03` | Source provenance / canonical identity; one existing `npc-03-counter` gameplay wrapper, not a second NPC |
| `tollworks-entrance-01` | Source provenance; existing `alderwake-travel-gate` gameplay interaction at mapped entrance |
| Existing Tollworks return gate | `tollworks-travel-gate` -> `prototype-alderwake/alderwake-from-tollworks` |

Retain original source IDs in layout/provenance, including art layers as
`group-id--layer-id` where flattened. Explicit source-to-gameplay mapping avoids
confusing canonical NPC definition, authored placement and quest source IDs.
Do not derive durable IDs from node names, order, mesh resources or positions.

All seven source portals remain represented; only Tollworks becomes active:

| Portal ID | Flattened source rect (left,top,width,height) | Source destination | Phase |
| --- | --- | --- | --- |
| `fair-north-entrance-01` | (1408,368,64,48) | `old-bridge-fairground` | Inert |
| `fair-south-entrance-01` | (1248,680,64,48) | `old-bridge-fairground` | Inert |
| `starter-home-entrance-01` | (544,208,64,48) | `alderwake-starter-home` | Inert |
| `hall-entrance-01` | (704,528,64,48) | `alderwake-hall` | Inert |
| `lantern-rest-entrance-01` | (448,688,64,48) | `lantern-rest` | Inert |
| `mayor-vale-home-entrance` | (832,352,64,48) | `mayor-vale-home` | Inert |
| `tollworks-entrance-01` | (4104,512,64,48) | `buried-tollworks` | Active at M015 |

The four grouped rectangles include their 32-unit pivots. Keep original
destination coordinates as provenance; do not install the six unused routes or
advertise working interior prompts. Current single-destination location/root API
suffices for this phase. Inactive records must never enter interactable selection.

Save schema **4**, content version **1**, remain unchanged for geography alone.
Existing location/spawn/party IDs, `prototype-maris-recovery`, six ordered quest
steps/actions/effects, `npc-03-counter`, `location-arrival`,
`tollworks-guardian-01`, `maris-recovery-vessel`, companion reaction/upgrade IDs
and once-only semantics remain unchanged. Load uses validated arrival anchors,
not old physical positions. Preserve both actor health, ordered party, elapsed
time, quest/defeat, trust/reaction and upgrade data. Existing legacy migrations,
strict invalid/newer-save rejection and backup rules remain authoritative.
No geography flag, duplicate reward or schema migration is needed. M017 must
prove pre-migration schema-4 town/Tollworks saves in isolated slots and processes.

## Retained, inert and excluded content

- Retain exterior geography, all tile/elevation/group/collider data, source
  prop IDs/catalog footprints, tree species/size metadata, zones, landmark and
  portal records. Inventory baseline: 468 props (443 standalone +25 grouped),
  102 explicit colliders, 31 groups, 25 zones and 3 activity areas. These counts
  include data whose runtime role may be inert; M002/M007 report each disposition.
- Trees/structures/water/terrain become candidate presentation and relevant
  collision without reseeding. Bridge, ford, Moonwell, trail markers and closed
  exit retain authored positions. No source sprite rectangle becomes a blocker.
- Keep 78 routine anchors, 4 resource nodes, zones/activity metadata and other
  markers as inert provenance. Six inactive portals and source NPC placements
  `harlan-dockmaster-01`/`npc-04` and `npc-01` get no new AI, interaction or
  accidental collision. Source Maris is mapped to existing wrapper only.
- Keep current Maris fitting/service adaptation, temporary active companion and
  labeled dialogue station, guardian, vessel, trust choice and Deliberate Strike.
  M015 chooses a safe labeled companion station; it is not a new canonical NPC.
- Exclude full fair/campaign stages, inactive interiors, source NPC schedules,
  fishing/resources economy, housing, orchard/ship repair, romance and retired
  memory currency. Preserve unsupported records in an explicit exclusion report;
  no silent drop or invented canonical behavior. Source sprite/light/animation
  systems inform appearance only; Blender mappings may adapt species/structure
  visuals deliberately with provenance at M012–M014.

## Measurable gates for subsequent items

These are declared development-machine targets, **not M001 pass claims**.
Later items may revise them only with evidence and an explicit contract decision.

| Gate | Acceptance target / method | Owner |
| --- | --- | --- |
| Conversion | Exported logical feet/corners within 0.001m X/Z and heights within 0.005m; no integer snapping of Moonwell; exact record IDs/counts | M002/M006/M007/M008 |
| Geometry registration | Gameplay landmarks/banks/crossing endpoints within 0.05m of converted data; art base within 0.10m and no visible collision disagreement | M005–M014 |
| Routes | Bidirectional connected nav paths from town start to both crossing endpoints, clear Moonwell approach within 2m of its foot, Tollworks return pad and exit approach; start->Tollworks <=180m, each other required start->approach <=200m | M009 |
| Traversal | Real hero movement/dodge cannot enter four water probes, seams or closed gate; both crossings/ramp walked in both directions, grounded within 0.05m of floor; segment checks at <=0.1m intervals cannot skip blockers | M004/M005/M008 |
| Travel time | Fresh ordinary-input start->Tollworks approach <=90s movement time at existing speed; pauses/dialogue/combat excluded and actual route recorded | M015/M019 |
| Navigation safety | Paths sampled <=0.1m apart clear 0.4m agent footprint; negative water probes >=0.4m from usable nav; no phantom blocker-top/river/cliff paths, including diagonal cuts; catch-up connected to ally | M009/M010 |
| Visual readability | Actual 960×640 gameplay captures at town, each crossing, Moonwell, forest gate and dense forest; hero/ally/selected interaction readable in static and moving views, no cracks/water-on-deck; aim error <=0.15m on measured slopes | M011–M016 |
| Navigation/loading | Cold full-map generation/bake <=5s; warm location request->committed safe party arrival <=2s; p95 companion path query <=5ms, 30 requests across required routes | M009/M018 |
| Frame budget | After 10s warm-up, three 60s runs per town/dense-forest/crossing view: p95 frame time <=16.67ms, p99 <=25ms; report renderer, viewport, VSync/cap and sampling method; <=500 draw calls p95 | M018 |
| Memory/lifecycle | Process working set <=2GiB; after two warm-up round trips, ten further round trips then 10s idle: growth <=64MiB; zero stale exterior/nav regions and stable wrapper/party counts | M017/M018 |
| Release | Full fresh recovery route, both crossings/Moonwell/closed exit, Save->quit->new-process Load->revisit with ordinary native inputs and packaged assets; debug evidence cannot substitute | M019/P014 |

Performance reference is the machine recorded by P014: Windows 11 x64,
Core Ultra 9 185H, ~32GiB, RTX 4070 Laptop, Compatibility/OpenGL renderer.
M018 must record actual machine/driver/settings anew; no minimum-hardware claim.
Route limits are design budgets, not measured paths. A failing gate stays open
with measured repair scope rather than weakening a target silently.

## M001 verification and remaining limits

Read source shipping map/catalog, group transforms, catalog collision, elevation
and shipping probe tests; inspect actual target scene/actor/party/navigation/
WorldHost/quest/save ownership. Focused application, travel, save and playable
slice headless checks pass, with exact commands/results and initial sandbox
failures in [M001 validation](../evidence/M001/VALIDATION.md). Measurements verify
19 converted probes, seven portals and nominal crossing/actor clearance.

No candidate scene, runtime map port, native map journey, source tests or performance
benchmark is claimed. Parent P014 subsequently completed with
[native evidence](../evidence/P014/native-holds/VALIDATION.md); M019 must revalidate
the resulting map build. Import exit 0 still reports the pre-existing missing
.NET SDK 10.0.9 and restricted certificate-store access; typed GDScript checks pass.
M002 data extraction is now verified; M003 is next eligible.
