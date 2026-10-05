# Weather and interactive lighting migration contract

This is the verified design for the W001-W010 workflow. W001 completed source inventory and behavior pinning on 2026-10-04. Proposed runtime filenames are suggestions until implemented; runtime weather and lifecycle/HUD through W008 are implemented and verified in their acceptance records.

Prepared 2026-10-04, America/Vancouver. Scope is the existing Godot Alderwake exterior, stable Tollworks interior lighting, saved environment time/forecast and authored exterior light behavior.

## Project and source authority

- Workspace: `D:/development/game-dev-blender`.
- Target repository: `D:/development/game-dev-blender/returning-fair-prototype`.
- Godot project: target `game/`; renderer is GL Compatibility; language is typed GDScript.
- Read-only source: `D:/development/game-prototype-2`.
- Existing map reference: target `tools/map_migration/reference/`, snapshot `alderwake-f4630f9-m002`, source commit `f4630f9966d6637ef6579cd87623ea354758191c`.
- Pinned map SHA256: `af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f`.
- Pinned catalog SHA256: `59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2`.
- Runtime layout: target `game/content/maps/alderwake_layout.json`.
- Existing coordinates/ownership: [map contract](../map-migration/CONTRACT.md). Do not refresh its snapshot or rerun source generators for this milestone.

P001-P014 and M001-M019 are recorded complete by [parent state](../CURRENT_STATE.md) and [map state](../map-migration/CURRENT_STATE.md). M019 is the larger-map release baseline, not acceptance of future weather. Preserve unrelated local changes and optional historical artifacts.

## Behavior references for W001

Read and record hashes for these source files:

- `docs/weather.md` and time/light sections of `docs/game-mvp.md`.
- `lib/game/weather/weather_schedule.dart` and `weather_components.dart`.
- `lib/game/day_night/day_night_clock.dart`, `day_night_cycle.dart`, `night_light_component.dart`, `night_light_ground_pool.dart`, `light_switch_component.dart`.
- Clock/light commands and condition derivation in `lib/game/state/runtime_game_controller.dart`.
- `test/game/weather/weather_schedule_test.dart` and relevant source day/light/persistence tests found during inventory.

Use pinned map/catalog data for light identities, defaults and geographic placement. Current source code supplies behavior reference only after its hash is recorded. If current source differs from pinned geography, record the discrepancy and use the pinned target geography. Retain necessary source rules/vectors locally so future execution does not rely on an evolving checkout.

## Clock and weather rules

One full authored day takes 600 active seconds. Initial displayed time is 10 AM with day index 0 and progress 0. The source progress cycle wraps at its 10 AM origin; midnight in the display is not that cycle boundary.

Advance environment time through the existing GameSession update gate. Pause, save/load restore and travel locks freeze it. Dialogue and journal follow the existing advancing session timer. Indoor active play advances the global clock/forecast. Window focus loss follows existing session-time behavior while clearing input; this feature does not invent a second focus policy. No wall-clock or offline catch-up.

| Current condition | Next condition |
| --- | --- |
| sunny | cloudy |
| cloudy | sunny 55 percent, rainy 45 percent |
| rainy | cloudy 65 percent, thunderstorm 35 percent |
| thunderstorm | rainy 75 percent, cloudy 25 percent |

Periods last 240-480 authored minutes inclusive, equivalent to 100-200 active real seconds. The previous/current presentation blends over the first 15 authored minutes, equivalent to 6.25 active real seconds. Fresh runs start sunny.

Forecast sampling uses the source seed/hash algorithm, with deliberate unsigned 32-bit masking despite GDScript's signed 64-bit integers. Equal seed and time yield equal period, condition and blend after restart. Transient caches are implementation details, never competing save truth.

Only thunderstorm yields the derived `heavy-rain` condition. Ordinary rain does not. Provide a typed read-only query for later NPC routines; schedules, authored event storage and scene/story effects are outside this feature.

## Persistent state and ownership

Verified W001 design for v5 plain-data additions (implemented and verified W003):

- `environment`: `day_index`, `day_cycle_progress`, `weather_seed`.
- `light_source_overrides`: validated records keyed by location ID, source prop instance ID and source ID, with an enabled boolean.

The exact shape, duplicate policy and time bound below are fixed by W001; W003 verifies codec implementation and additive content compatibility. Do not serialize Nodes, Resources, emitter caches, particle state or transient review overrides. The weather period/transition reconstructs from seed and clock.

Schema v1-v4 migration preserves all existing facts, uses day 0/progress 0/fixed source default seed `0x6c8e9cf5` and no light overrides, and does not reset `elapsed_play_seconds`. Loading never rewrites old files; explicit Save writes v5. New runs choose a seed once. Content version remains 1 only if W003 confirms additive catalog compatibility.

Manual pause-menu Save/Load, stable save boundaries, arrival-anchor restore, detached validation, backups and rollback stay in force. No autosave or new-game/reset UI is part of this milestone.

GameSession owns durable state. Node-independent rules sample time/forecast and resolve enabled sources. GameRoot composes a single environment presenter. LocationDefinition declares outdoor/indoor profile. Location wrappers own source anchors and E targets. UI displays values and submits commands; it cannot own persistence. Failed travel/load does not publish a candidate environment.

## Exterior lights

Initial pinned lamp inventory:

| Prop ID | Source ID | Default enabled | Switchable |
| --- | --- | --- | --- |
| dock-lamp-01 | lantern | false | true |
| dock-lamp-02 | lantern | false | true |
| dock-lamp-03 | lantern | false | true |
| dock-lamp-04 | lantern | false | true |
| dock-lamp-05 | lantern | false | true |
| dock-row-lamp-01 | lantern | true | true |

Map source defaults override definition defaults. Saved validated overrides take precedence over both. The production saved location ID is `prototype-alderwake`; source `alderwake` needs an explicit registry mapping.

All 23 pinned exterior sources are in [retained W001 reference](reference/README.md) and its exact [JSON registry design](reference/light-inventory.json): six lamps, fourteen window sources, two waylights and one luminous net. Windows remain non-switchable; four window defaults are false. Both waylights and `dock-luminous-nets-01/woven-lights` are enabled and non-switchable. Buildings without declared sources stay dark.

Enabled exterior source brightness follows the day/dusk/night/dawn factor. A daytime on command records readiness for dusk; off remains dark. Clock brightness and rendering distance do not change the persistent enabled value. Existing Tollworks vessel/quest glow keeps its current ownership rather than inheriting automatic exterior fading.

The source's raster origins are 2D sprite positions, not physical heights. W001/W005 author light anchors against the actual 3D assets and map axes. Ground-light radius is intended floor coverage; choose 3D range/cone using source height as well. Preserve fractional instance feet, source IDs, wrappers, collision, navigation and aim metadata.

Add one reusable lamp visual and dedicated window emission surfaces. Keep material/state independence wherever sources can differ. Turning one lamp off must not mutate a shared imported material and extinguish other lamps.

## Presentation and renderer

Keep GL Compatibility. Use the current sun for smooth physical shadows and adjust direct light, ambient light, colors and shadow contrast across the day and cloud conditions. Translate source appearance into 3D readability; a literal 58 percent full-screen night tint is not the requirement.

Building windows primarily use emission. Local illumination uses a measured, bounded selection of nearby OmniLight3D/SpotLight3D nodes with controlled ranges and fades. Avoid unnecessary local shadow passes. The renderer's per-mesh light limits must be checked on actual geometry and installed engine, especially batched terrain/trees.

Rain uses a bounded number of world-space instanced batches with stable coordinates and session-driven phase. Clip/exclude terrain and covered areas; do not create a scene node per drop. New weather shader uniforms follow session time, not built-in shader TIME, to freeze on pause.

Thunderstorm flashes are deterministic, brief, restrained and subordinate to actor/UI/telegraph readability. No damage, thunder audio, wind mechanics, volumetric fog, new global event bus or renderer migration is required.

Tollworks uses an explicit stable indoor profile and shows no outdoor rain/sky flashes. The global forecast continues while indoors and resumes correctly outside. Any ordinary fog is optional and must pass Compatibility visual/performance checks.

Implementation references: [Godot renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html) and [lights and shadows](https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html). Verify capabilities against installed 4.7.2 rather than assuming rolling documentation describes that exact executable.

## Validation and delivery

Inspect all four day phases and four weather conditions, both projections and zoom limits. Check town, dense forest, bridge, ford, roofs, elevation, river and indoor boundaries. View saved captures; headless tests cannot prove the appearance.

Use the retained M018 method at the end of this contract and `tools/map_migration/profile_map.py` as the measurement reference. Initial targets are frame p95 <=16.67 ms, p99 <=25 ms and draw p95 <=500 on the same declared machine/settings. These are percentile targets, not maximum-frame promises. Measure at least clear day and storm/night at all four views with three runs each, warm-up and raw samples. Track engine PID memory and scene/effect/resource counts through repeated travel.

Release acceptance uses existing Windows Validation/Windows Desktop presets and ordinary native controls through the full recovery quest, E light actions, GUI Save, quit, separate process GUI Load and revisit. Forced developer states are labeled synthetic and remain isolated from normal saves/releases.

Do not add full NPC schedules, fair campaign, fishing, housing, shops or unrelated art work. Preserve current geometry, quest consequences, combat, companion behavior and prior P/M evidence. Changes to the contract require a recorded reason supported by source or observed implementation evidence; lack of time is not grounds to weaken acceptance.

## W001 verified decisions and handoff

Verified 2026-10-04. [Compact reference](reference/README.md),
[manifest](reference/source-manifest.json), [fixed vectors](reference/rule-vectors.json)
and [audit](reference/audit.py) retain the required baseline. Four exact rule
sources remain versioned; the manifest records all 23 inspected file hashes.
Other source/test copies and raw acceptance logs stay in the optional local archive.
This is a scoped behavioral snapshot, separate from the existing map snapshot.
Current source HEAD is `842704819cc681ccbabc629c6634c154a53b506b`;
source map now hashes `deda25dc53a7543c3c0705e8029f6c6ded6a63cf49107a7c7f019ce34ed30af5`,
which differs from the pinned map. Catalog still matches. No refresh is authorized.
Runtime/export code must depend only on target-authored rules/content; reference
Dart files are evidence outside `game/`, not imports or executable dependencies.
Python vectors are literal source transcription; no Flutter/Dart test run is claimed.

### Clock, forecast and bounded reconstruction

Source period membership uses `absolute_minutes >= period_end` to enter the next
period. Duration is `240 + mix(seed, index, 0x5f356495) % 241`. Transition roll is
`mix(seed, index, 0x9e3779b9) % 100`, with the table thresholds above. First period
has previous/current sunny and blend 1; subsequent blend is linear clamp of
`(absolute_minutes - period_start) / 15`. This is independent of display offset:
absolute forecast minutes are `1440 * (day_index + day_cycle_progress)`, while
clock display uses `(600 + 1440 * progress) % 1440`, floored for whole minutes.
Large delta advances add `floor(progress + delta / 600)` to day index.

Source mixing masks every stage to uint32: seed XOR `(index+1)*0x9e3779b9`
XOR salt; XOR right-shift 16; multiply `0x7feb352d`; XOR right-shift 15;
multiply `0x846ca68b`; XOR right-shift 16. Each shift operates on a nonnegative
masked value. GDScript's signed int64 can overflow the second product: compute
low32 products using 16-bit limbs, e.g.
`((a & 65535) * b + ((((a >> 16) * b) & 65535) << 16)) & 0xffffffff`.
Mask the period-index multiplier as well. The local vectors include all seed
edges, period/blend boundaries, source reload example and product cases.

Target supported environment range: integer `day_index` 0..3650 inclusive,
finite `day_cycle_progress` in [0,1), integer seed 0..4294967295. This deliberately
bounds source's unlimited replay: over ten authored years / up to 608.5 active
real hours, fewer than 21,906 transitions at minimum 240-minute periods. W002
must reconstruct once on load/seek and increment a transient cached cursor at
boundaries, never replay history every frame; measure the upper-bound case in
Godot. Invalid or out-of-range clock advances fail without partial mutation;
do not wrap day index or silently clamp/truncate elapsed time. Raising this
bound later requires measured reconstruction and a documented compatibility decision.

GameRoot `_process` currently advances session only while unpaused and not
WorldHost transitioning. Load requires pause; focus loss clears controls but
does not pause elapsed time. Dialogue/journal also advance elapsed time. Preserve
these gates; outdoor and indoor use the same clock. Source weather docs advance
during fades; target deliberately freezes during travel to preserve its existing
transaction boundary. No second timer, wall clock or offline catch-up.

### Save shape and registry policy

W003 adds exactly these two envelope fields to the existing v4 facts:

```json
{
  "environment": {"day_index": 0, "day_cycle_progress": 0.0, "weather_seed": 1821285621},
  "light_source_overrides": [
    {"location_id": "prototype-alderwake", "prop_id": "dock-lamp-01", "source_id": "lantern", "enabled": true}
  ]
}
```

The illustrated seed is fixed migration seed `0x6c8e9cf5`, not a fresh-run seed.
New v5 runs generate once; v1-v4 migrations use that seed, empty overrides and
zero environment clock while retaining the existing elapsed timer separately.
All envelope/environment/record fields are exact. Override array entries sort
lexically by the three-field tuple; duplicate tuples fail, even when booleans
agree. IDs must be exact known registry strings; boolean values must be actual
booleans. Persisted overrides are allowed only for the six switchable lantern
keys. Automatic windows/net/waylights always resolve their pinned instance
(default before definition) and cannot acquire overrides from disk or commands.
This makes switchability enforceable across the save boundary. The registry
includes all 23 identities without requiring live visual nodes. No Nodes,
Resources, cache cursor, weather sample or forced review state enters a save.
Existing exact legacy validation, backups, candidate restore and manual saves
remain required. W003 confirms content version 1 compatibility below.

### Physical light adaptation and W005 asset gaps

Exact feet/yaw/source pointers/defaults and planned anchor recipes are in the
inventory JSON. The runtime owners already exist: `TownFootprints/<prop_id>`
and `ForestPopulation/<prop_id>` under Alderwake, each with `VisualRoot`.
Engine probe verified all 23 wrappers/feet. W005 adds anchors/visual consumers
without changing those wrappers, collision, navigation or aim metadata.

- Six dock lamps currently have collider grayboxes. Author one reusable pole/
  lantern visual aligned with the existing local footprint centre
  (-0.1875,-0.265625) in X/Z. Initial lantern anchor is local
  (-0.1875,1.55,-0.265625)m, full-circle floor coverage radius 1m;
  initial unshadowed Omni range 1.8946m includes physical height and 0.05m margin.
  Catalog origin (16,64) is at the sprite foot, so literal Y conversion would
  put the emitter on the ground. It is reference registration only.
- Two waylights currently have grayboxes. Add small waylight shell/core visuals;
  local initial emitter (0,0.65,-0.125)m and radius 0.625m give range 0.9517m.
  Preserve both authored `answer-light` IDs/defaults. These are automatic lights.
- Fourteen building sources already have imported vertex-colored window art,
  sharing one material with walls/roof. Add independent emissive panes driven
  by each source; never enable emission on the imported shared building material.
  Reuse mapped local polygon edges, t=0.23/0.77, civic levels 0.75/1.55m for
  Lantern Rest/Mayor and 0.77m for others, height [level-0.22,level+0.24],
  half-span min(0.075,0.28/edge_length). Place at outward offset 0.0095m
  between existing glass (0.009m) and wooden crossbars (0.010m), dividing around
  crossbars. W005 checks depth stability and may document a measured offset repair.
  This follows actual compressed 3D art; source origin is not a window height.
- `dock-luminous-nets-01/woven-lights` has only a nonblocking foot marker.
  W005 adds a modest nonblocking woven-net display with emissive knots,
  initial local glow centre (0,1,-0.45)m. Emission only; no ground pool is
  declared by source. This discovered source is included because W001 inventories
  every existing exterior source, not only the initial lamps/windows/waylights.

These are W005 physical designs, not a claim of authored assets or rendered
alignment. Lamp/window/net state and material instances must remain independent.
Absent definitions festival-beacon, house-of-echoes, miniature-woven-light,
preservation-heart and refuge-memory-vessel have no pinned exterior instances;
do not invent consumers. The existing Tollworks quest vessel is unrelated and
retains its current always-owned quest presentation.

### Room, renderer and performance decisions

W004 explicitly assigns Alderwake outdoor-cycle and Tollworks stable-indoor;
fixtures receive intentional stable defaults. Tollworks keeps current root Sun
rotation (-55,-25,0), energy 1.1, color (1,0.89,0.73), shadows enabled, ambient
color (0.65,0.76,0.86), energy 0.65 and background (0.055,0.075,0.095). Indoor
visits suppress exterior fading/rain/lightning but advance durable global time.
Physical sun adapts the source moving-shadow sense: morning/east casts toward
west, evening/west casts toward east, daylight casts south; source raster shadow
vectors/tint opacity are reference styling, not another shadow renderer.

Installed 4.7.2 ed1daf0bf headless probe reads Compatibility settings:
`max_lights_per_object=8`, `max_renderable_lights=32`,
`max_renderable_elements=65536`. These are actual engine settings, not a rendered
stress test. Official [lighting docs](https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html)
and [renderer docs](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html)
were checked. Keep a conservative pool of at most eight total unshadowed local
emitters, including fading entries, with stable IDs and smooth selection fades.
Emission remains visible for all logically enabled sources even outside the pool.
Windows primarily emit; selected nearby window pools may use the same budget.
No renderer/settings change, GI, volumetric fog or assumed screen glow support.
W005/W009 must verify actual per-mesh overlap on batched terrain/trees and measure
readability/performance; headless settings do not certify those future criteria.

Retain M018 method: Windows11/Core Ultra9 185H/33,736,015,872 bytes RAM/RTX4070
Laptop driver32.0.15.8129, GL Compatibility, 960x640, orthographic zoom1, VSync0,
max_fps0; 10s warm-up then three 60s runs at town/dense-forest/bridge/ford for
clear day and worst storm/night. Monotonic process-frame cadence, nearest-rank
p95<=16.67ms/p99<=25ms, draw-call p95<=500 includes shadows/UI. Memory<=2GiB;
after two warm-up round trips plus ten further round trips and 10s idle,
growth<=64MiB with stable node/object/resource/effect counts. Record actual
engine PID, raw samples/settings and hardware anew; do not overwrite M018.

## W002 implementation decisions

W002 implements typed EnvironmentState, EnvironmentClock and WeatherSchedule under
`game/features/environment/`. GameSession generates a fresh uint32 seed once only
after successful initialization and advances both timers atomically through the
existing GameRoot gate. Rules return explicit errors (or null for an invalid
forecast); no invalid input changes clock/elapsed state or forecast cursor.
Forecast queries return detached typed samples; the cursor reconstructs for a new
seed/backward seek and computes subsequent periods only at crossed boundaries.
Diagnostics count reconstructions/computed periods; they are never save facts.

The 49 W001 vectors use authored absolute minutes before normalizing progress.
Observed IEEE double round trip `369 / 1440 * 1440` gives
`368.99999999999994` in both Python and installed Godot, so strict comparison
alone misses the vector's intended exact boundary for seed 123456. W002
canonicalizes forecast minutes to the nearest integer only when the absolute
error is <=1e-9 authored minutes (less than 0.42 nanoseconds active time; roughly
one ULP at the supported upper bound). There is no relative tolerance, clock
rounding or widened visible transition. Times 0.0001 minute before each tested
boundary remain in the previous period. Hashes, seeds, duration/transition
arithmetic and retained source/vector bytes are unchanged. Display flooring still
uses the source clock formula without this forecast-only normalization.

At W002, schema4 saves could not retain environment clock/seed. W003 adds the
persistence below; W002's rendering/acceptance scope remains unchanged.

## W003 implementation decisions

Schema5/content1 adds only the two contracted envelope fields. Existing catalog,
location/spawn, actor, quest/effect, trust/reaction and progression IDs remain
unchanged. All five retained historical v4 fixtures migrate with prior facts
preserved, while their checked-in bytes/provenance remain unchanged. Content1
therefore remains compatible; schema version distinguishes the additive fields.

LightSourceRegistry is node-independent runtime content under features/environment.
Its 23 effective defaults/switchability match the retained W001 inventory, with
a compact independent test fixture. EnvironmentState stores overrides and resolves
validated values before defaults. Commands reject automatic/unknown sources;
SaveCodec rejects duplicate tuples even with identical booleans, extra/missing
fields, invalid types and unsupported values. Override snapshots deep-copy/sort.
V1-v4 use EnvironmentState's fixed defaults; v4 keeps consequences. Only successful
fresh initialization generates a seed; candidate initialization accepts already
validated environment facts. Save/recovery and physical rejection keep existing
transaction/publication boundaries, with no competing presenter or timer.

Actual installed Godot 4.7.2 exposed two precision issues. Default JSON.stringify
rounds clock values; using [full_precision](https://docs.godotengine.org/en/stable/classes/class_json.html#class-json-method-stringify)
preserves written digits. Its JSON/String.to_float reader nevertheless converts
`0.9999999999999999` to1, including GDScript decimal literals. Tests construct the
preceding double as `1.0 - pow(2.0,-53.0)` and compare actual double bits.
SaveNumber reads only elapsed_play_seconds/day_cycle_progress numeric lexemes
after JSON structural parsing, supports escaped keys, and converts decimal by
long division to significand bits followed by one ties-even rounding (including
subnormals). It neither clamps clocks nor changes field types/save shape.
All other schema/field/type/ID checks remain strict. Numeric timer tokens are
bounded at1100 characters and exponent spellings at5 characters (including sign)
to bound work; unsupported spellings reject without changing files. Supported
full-precision engine output and all retained legacy saves fit these limits.
Newer schema/content protection runs first, including duplicate timer lexemes,
so numeric errors cannot permit older-backup fallback for future envelopes.
305 independent Python repr/struct/Decimal vectors and the final supported
clock double prove precise decoding/filesystem reload; cursor/cache is transient.

Acceptance: [W003 record](W003_ACCEPTANCE.md). No rendered weather/light/E-key or
packaged/native claim; those remain later tasks. Existing schema4 builds stay
historical; rebuild and perform W010 before accepting future feature releases.

## W004 implementation decisions

LocationDefinition uses a validated LightingProfile enum: STABLE_INDOOR=0,
OUTDOOR_CYCLE=1. Production Alderwake authors1; Tollworks and the existing test
room author0; dynamically authored fixtures default0 deliberately. Profiles are
immutable content choices, never saved run facts. Schema5/content1 is unchanged.

One GameRoot-owned EnvironmentPresenter receives the existing DirectionalLight3D
and WorldEnvironment and duplicates the Environment per root. It has no process
timer, session copy, scene listener or weather authority. Root presents after its
existing gated advance and synchronously after committed arrival/restore rebinding.
During travel it retains the previous lighting; rollback reapplies that same
committed profile/time. Paused arrivals still hydrate correctly before drawing.

EnvironmentLighting keeps the source knots0/.25/.30/.375/.50/.75/.80/.875/.96/1
and cubic smoothstep, with equal endpoint values/zero endpoint slopes. Direct
energy runs1.1 in daylight to0.18 at night; ambient energy0.65 to0.48 with a navy
palette. Night shadow opacity0 removes a false daytime cast while ambient/direct
fill keeps actors/floor readable; dawn/evening regain physical shadows gradually.
The source shadow X/Z displacement becomes incoming direction
normalize(2*dx,-1,2*dy), with east+X/south+Z. Evening casts east, morning west,
daylight south. Minimum downward component keeps light above the horizon and
avoids grazing, excessive long shadows on the dense map. This is a deliberate
source-inspired stylized physical adaptation, not astronomical positioning or
another 2D shadow/tint renderer. Tollworks restores exactly its prior rotation,
colors/energies/background and shadow opacity1 throughout global clock changes.

[W004 acceptance](W004_ACCEPTANCE.md) records30,053 sampling/integration assertions,
eight affected regressions and37 inspected synthetic rendered captures at960x640
in Compatibility. No exterior light assets/consumers, E actions, weather effects,
new HUD/review controls, frame-budget claim or native feature gate belongs to W004.

## W005 implementation decisions

Production Alderwake explicitly composes ExteriorLights after its imported art.
Each existing source wrapper owns an ExteriorLightConsumer under
VisualRoot/ExteriorLightAnchors/<source_id>, with an explicit EmitterAnchor.
GameRoot passes committed EnvironmentState and hero position through its existing
presentation gate; consumers own no persistent state or independent timer.
The runtime mapping contains only target-local W001 physical recipes, with the
pinned snapshot unchanged. The23 registry defaults remain authoritative.

The reusable Blender kit exports six static meshes,2,344 triangles,186,252 bytes.
Lamp/waylight frames use rough vertex palettes; their opaque dormant core materials
receive per-consumer overrides. Woven display ropes/wood and16 luminous knots
are nonblocking art. Editable source and reproducible script are in art/source;
runtime exports are in game/assets/environment. Live authoring uses a separate
scene and restores the user's active scene; export is explicitly active-scene-only.

Four separate panes surround each existing wooden crossbar, with0.05m gaps;
32 panes per ordinary building source/64 for two-level civic sources. Pane vertices
retain W001 edges/fractions/heights/0.0095m offset. Rendered registration at both
projections/zoom endpoints requires no offset change. Every source owns its
glow material; original building walls/roof/wood never gain emission. Windows
use warm color(1,.65,.24)/peak emission1.4; lamp cores use that color/peak2.2.
Waylights use(.48,.95,.78), net knots(.72,.91,.47), peak2.2. These are stylized
Compatibility emission values, not physical lumen/GI claims.

Local emitter selection simplifies to eight fixed identities because exactly
six lanterns/two waylights require floor coverage; automatic windows and net
remain emission-only. This meets the existing total-eight budget, including
disabled/fading nodes, without pool reassignment or additional window-light nodes.
Lamp local anchor(-.1875,1.55,-.265625), range1.8946m, peak energy7; waylight
(0,.65,-.125), range.9517m, peak2.6. Both use attenuation.55/specular.2/no shadows.
Positive physical range is required; the net's retained zero-range recipe never
allocates an emitter. Source collision_enabled metadata remains unchanged even
where the pinned definition has no collision shape.

Source light-opacity knots0/0/0/.42/1/1/1/.62/0/0 follow the same cubic smoothstep
and phase knots as W004. Enabled daylight sources remain armed with zero emission/
illumination. Horizontal hero-distance smoothstep fades local illumination from
12m to18m; all enabled mesh emission remains visible beyond that selection.
Neither phase nor distance mutates overrides or defaults. Exactly eight global
local nodes bound overlap on every batched terrain/tree mesh to the installed
Compatibility limit8, independently of the directional sun. Official
[light limits](https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html)
and [Omni range](https://docs.godotengine.org/en/stable/classes/class_omnilight3d.html)
were rechecked; the real renderer/captures verified visible pools and all-source
emission. The observed single-frame draws are not W009 performance acceptance.

[W005 acceptance](W005_ACCEPTANCE.md):13,289 consumer assertions, eight focused
headless checks and65 inspected actual Compatibility source/phase/override images.
No E action, weather effect, normal-input/native/restart claim, benchmark or package
export belongs to W005. W006 remains the next task and first switching checkpoint.

## W006 implementation decisions

LightSwitchAction is a typed immutable identity Resource, not dialogue content.
Six LightSwitch nodes belong directly to their existing source wrappers, outside
replaceable VisualRoot. Instance ID equals pinned prop ID; action carries the
location/prop/source tuple. Position uses the existing lantern's X/Z anchor at
wrapper ground height; reach1.7m retains normal range/LOS and authored blockers.
The selector recognizes the target wrapper's own sibling collision only; other
props still obstruct. No additional collider/navigation/source identity is added.

GameRoot submits a transient WeakRef plus expected enabled value, reselects under
existing modal/focus/travel/combat gates and rejects stale/unloaded/queued targets.
WeakRef is necessary because installed Godot rejects previously freed typed Node
arguments before function guards can run. GameSession then validates committed
location, registry/switchability and expected current value before toggling
EnvironmentState once. The expected-value check rejects an immediate repeated
command rather than toggling twice. New genuine E presses obtain current state;
echo key events remain ignored by the existing input boundary.

Prompts derive Turn on/off from saved-enabled state, independent of brightness.
Feedback explains daylight readiness, lasts2.5 active seconds, is scoped to that
selected lamp and clears on travel/load. Root immediately presents committed
facts; consumers never own toggles. Existing schema5/content1 codec and all
clock/forecast/automatic-source/default/material/light-budget rules remain intact.

[W006 acceptance](W006_ACCEPTANCE.md) verifies151 focused assertions, affected
consumer/save/application/dialogue/quest/travel regressions and17 inspected renders.
Actual normal startup movement/E and GUI Save -> separate-process GUI Load preserve
clock/seed/exact forecast and independent lamp choices. Forced phase/remote gate
reviews remain synthetic; weather/performance/packaged/native gates belong to
W007-W010. W006 is the first playable light-switch checkpoint.

## W007 implementation decisions

WeatherVisuals is a node-independent render sampler, separate from forecast truth.
It smoothsteps the existing linear15-authored-minute blend for overcast0/.55/.8/1,
rain0/0/.48/1 and storm0/0/0/1. Clear retains W004 sampling; full overcast scales
direct energy to.32 and shadow opacity to.16, shifts colors toward blue-gray,
and retains ambient energy>=.44 before bounded flash. Clouds are overcast ambience,
without a volumetric cloud/sky renderer or new source behavior. Save schema5/
content1, period/seed arithmetic, clock gates and light defaults are unchanged.

Alderwake explicitly composes one WorldRain after imported structures. Its16m
world lattice has24x24 independently jittered cells per tile, at most576 columns.
Camera frustum projects atY0/Y8.6 plus2m margin, clips to map bounds and selects
fixed tiles without moving their origins. Hard maximum64 active/retained batches;
retire-before-add prevents a transient excess. Dry conditions hide the bounded
set instead of allocating invisible tiles. Current rendered matrix peaks36.
One shared QuadMesh/ShaderMaterial per owner; no per-drop Nodes/physics/shadows,
extra light or GPU particle subsystem. Native Godot MultiMesh custom data and
explicit displacement AABB are verified on installed Compatibility renderer.
Official [MultiMesh guidance](https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html)
informs this design; actual installed-engine checks/captures establish support.

Rain columns sample actual elevation and begin0.05m above floor. Vertical streaks
are0.44m long/0.045m wide and remain above that floor throughout the fall. The21
imported building AABBs, transformed into room coordinates and grown0.12m,
conservatively exclude complete columns, including roof overhang and sheltered
space. This avoids sampling source collision boxes as roof geometry. Rain over
water uses the existing physical surface reference; bridges/ford and raised hills
are covered in real captures. Decorative trees do not create indoor profiles.

Animation uses authoritative (day_index+progress)*600 active seconds, modulo64
for rain, exactly forty1.6-second/6.4m fall cycles. Shader never uses TIME; world
X/Z stays fixed, camera right only orients the narrow vertical quads. Per-column
phase/density hashes and smooth opacity thresholds avoid a visible tile/transition
seam. Particle state is not saved: fixed coordinates plus reconstructed phase are
sufficient. Shared pure batch data supports headless checks because the installed
dummy renderer returns zero MultiMesh transforms; real GPU checks independently
compare every uploaded transform with generated columns.

Lightning admits a seeded1-in-3 pulse per8-second window, delay1..4.999 seconds,
duration0.32s, sin-squared profile and peak ambient increment0.18. Storm blend
attenuates it at weather boundaries. It writes existing ambient/background only;
no directional/local extra light, damage, signal, audio or new event authority.
Tollworks ignores weather rendering and retains its exact W004 indoor values.
Global forecast still advances there under existing session gates.

GameRoot positions its camera at committed arrival before sampling rain's view.
Location disposal releases rain meshes/material/batches; no independent processing
or listener remains. W007 checks this basic owner boundary and exact GUI restart;
W008 retains the full lifecycle/rollback/HUD/review-control matrix. Existing river
TIME styling was unchanged and excluded only from the weather-only pause pixel
comparison; new weather motion is genuinely session-driven and frozen.

[W007 acceptance](W007_ACCEPTANCE.md) records193,417 rule/world/lifecycle assertions,
eight focused regressions and66 inspected real images in both projections. Exact
Save/new-process GUI Load restores forecast and all weather render values. These
synthetic review facts/poses do not claim normal/native quest, full W009 visual
matrix/frame budgets or W010 packages. Next task is W008, not started.

## W008 implementation decisions

GameSession owns WeatherConditionService bound to its EnvironmentState; UI and
future routine consumers can query detached samples/condition IDs/heavy-rain
without owning facts, timers, scene nodes or events. Each validated restored
session initializes its own binding. Heavy-rain remains thunderstorm-only.

GameRoot hydrates the existing presenter, compact time/weather HUD and exterior
consumers only when WorldHost session/location match the committed run. Load/retry
gaps explicitly gate advancement; existing focus/modal/indoor behavior is retained.
Transition start clears light feedback identity along with transient targets.
Header replaces elapsed seconds with source-format time and readable condition;
elapsed play remains a tooltip. Indoor HUD describes global weather, not indoor rain.

Explicit debug --environment-review=<1..48 ASCII letters/digits/underscore/hyphen>
loads tests/environment_review.gd, outside release exports. Before root binding,
the controller validates a detached snapshot clone, marks transient review_only,
uses user://environment-review/<namespace>/disabled.json and starts paused. Root
Save/Load and SaveRepository.write reject review provenance; it is never serialized.
Save/Load buttons disable while Resume stays available. Restart without the flag
returns to ordinary fresh play; no review-to-normal save conversion exists.

Paused, focused F7/F8 cycle Day/Dusk/Night/Dawn at progress .05/.375/.625/.875
and the four conditions. Presets use day2 and the first seed below10000 whose real
forecast is fully blended at that phase; no alternate forced forecast enters
production sampling. Resumed/modal/travel/load/retry review requests reject.
The synthetic marker sits above the footer, beneath modal menus. These controls
prepare W009 reviews but do not themselves certify its full matrix/performance.

Map regression checks accept fresh --report-dir paths; runner now supplies a
per-check W evidence directory. Fixed historical report writes were removed and
the stale map interaction expectation now verifies exactly the three existing
wrappers plus six W006 lamps. Historical reports/recovery are recorded in
[W008 acceptance](W008_ACCEPTANCE.md). Schema5/content1, source hashes, renderer,
map geometry/IDs, save shape and prior P/M gates stay unchanged. Next: W009.
