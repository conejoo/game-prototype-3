# Weather and interactive lighting migration checklist

This checklist brings the existing weather, day clock and interactive exterior lights into the Returning Fair Godot prototype. It is the task authority for this workflow. Each fresh agent completes or resumes exactly one task, then writes a handoff for the next session.

Prepared 2026-10-04, America/Vancouver. W001-W010 verified Done; no next item. Production clock/forecast, environment saves, moving outdoor lighting, exterior consumers, persistent E switching, clouds/rain/lightning, lifecycle/HUD, isolated review controls, visual regressions, measured performance and fresh packaged/native acceptance are verified. P001-P014 and map M001-M019 completion/evidence remain preserved as historical baselines.

Read [the contract](CONTRACT.md), [current state](CURRENT_STATE.md) and [agent prompt](AGENT_PROMPT.md). The target is `D:/development/game-dev-blender/returning-fair-prototype`; the Godot project is its `game/` directory. The source `D:/development/game-prototype-2` is read-only.

## Task selection and completion

1. Read all four workflow documents and applicable workspace instructions before selecting work.
2. Resume the single In progress task. A Blocked task is retried first when its recorded blocker can be resolved; if it cannot, report the exact blocker and stop. Do not mark it complete or skip dependent work.
3. Otherwise select the lowest-numbered Pending task whose dependencies are verified Done. Dependencies require current artifacts and evidence, not a checkbox alone.
4. Mark the selected task In progress in this checklist and CURRENT_STATE before editing implementation files. State the ID, scope and acceptance in the chat.
5. Complete only that task, including necessary integration, regression repairs and checks. Do not begin its successor even if time remains.
6. Mark Done only when every acceptance criterion has evidence. Retain In progress for incomplete work, or Blocked with the exact missing prerequisite/tool/decision. Record failed and unrun checks honestly.
7. Update CURRENT_STATE before ending an incomplete session as well as a completed one. Append a completion record below only for a Done task.
8. If statuses conflict, inspect artifacts and records to resolve stale documentation. If the selected task cannot be determined safely, record the conflict and stop instead of guessing.
9. Once all ten are Done, report completion and stop. Do not invent an eleventh task.

Statuses: Pending, In progress, Blocked, Done. `[ ]` means not complete; `[x]` means verified Done.

## Ordered tasks

| ID | Status | Dependencies | Outcome |
| --- | --- | --- | --- |
| W001 | Done | Existing M019 baseline | Source inventory and verified feature contract |
| W002 | Done | W001 | Pure clock and deterministic forecast |
| W003 | Done | W002 | Versioned environment save compatibility |
| W004 | Done | W003 | Moving sun and location lighting profiles |
| W005 | Done | W004 | Exterior light assets and source bindings |
| W006 | Done | W005 | Persistent E key light switching |
| W007 | Done | W006 | Clouds, world anchored rain and lightning |
| W008 | Done | W007 | Lifecycle integration, HUD and isolated review controls |
| W009 | Done | W008 | Visual matrix, regressions and measured performance |
| W010 | Done | W009 | Packaged Windows and native acceptance |

Dependencies are deliberately sequential. The first playable lighting checkpoint is W006; the full feature requires W010.

## W001 Source inventory and verified contract

- [x] Done. Status: Done. Depends: verified M019 baseline. Evidence: [retained baseline](reference/README.md), [inventory](reference/light-inventory.json), [reproducible audit](reference/audit.py).
- Inspect actual Godot project, applicable instructions, parent architecture/state, M019 release handoff, pinned map/catalog/layout and current Git changes. Preserve all prior work.
- Hash and record the read-only behavior sources listed in CONTRACT. Retain a target-local, scoped reference copy or equivalent fixed test vectors for forecast/day/light rules; never refresh the old map snapshot automatically.
- Complete an inventory of every in-scope exterior light: location, prop ID, source ID, default enabled state, switchability, 3D wrapper/anchor, emitter kind and required visual asset. Include six dock lamps, authored building window sources and the two exterior waylights where present in the pinned data.
- Record adaptations of 2D sprite origins, ground-light radius and shadow styling into physical 3D anchors. Identify every asset gap and assign it to W005.
- Confirm room profiles, clock gates, source transition probabilities, save shape, renderer strategy and performance method. Update CONTRACT with verified decisions and reference hashes.
- Acceptance: M019 capability is intact; all selected IDs/defaults have evidence; no runtime dependency on the source checkout is proposed; the new workflow has a reproducible source baseline and no unresolved design prerequisite for W002.
- Validation: document/source/link/hash audit and a bounded startup/baseline check if needed. Do not rerun the whole historical acceptance suite for documentation alone.

## W002 Pure clock and deterministic forecast

- [x] Done. Status: Done. Depends: W001. Evidence: [W002 acceptance](W002_ACCEPTANCE.md), typed rules/session checks and exact retained fixture.
- Add typed environment runtime state and node-independent clock/forecast rules, suggested under `game/features/environment/`. Wire clock advancement through the existing session update; do not create a competing timer authority.
- Preserve the source 600-second day, 10 AM initial display, day-index/progress convention, four weather values, seeded period duration and transition graph. Generate a new-run seed once.
- Implement source-compatible unsigned 32-bit mixing in GDScript and a typed sample containing previous/current condition, period bounds and blend progress. Expose derived `heavy-rain` only for thunderstorms.
- Cache forecast sampling between boundaries; avoid replaying all periods every render frame. Establish bounded reconstruction or a justified validated time limit for long saved runs.
- Acceptance: fixed source vectors match; midnight/display time and source cycle boundary are not conflated; large delta advances do not lose days; equal seed/time produces equal forecast; invalid inputs fail; pause/travel gates behave as contracted.
- Validation: meaningful rule checks for seeds, exact boundaries, 4-8 hour durations, transition probabilities, blend edges, day wrapping, long-time sampling and derived conditions; affected application/session checks.
- Production rendering and environment serialization remain owned by later tasks.

## W003 Versioned environment save compatibility

- [x] Done. Status: Done. Depends: W002. Evidence: [W003 acceptance](W003_ACCEPTANCE.md), environment codec/legacy/backup/physical rollback and separate-process checks.
- Extend SaveCodec to schema v5 with validated environment clock, weather seed and a map-qualified light-override container. Keep content version 1 only after confirming additive compatibility.
- Support exact v1-v4 envelopes through documented migrations. Retain all prior party, health, quests, once-only effects, companion trust/reactions, progression and elapsed-play fields.
- Legacy environment defaults are day index 0, progress 0, a fixed migration seed and no overrides. Preserve old elapsed time separately. New v5 runs choose their seed once. Do not re-roll seeds on load.
- Validate supported time bounds, integer seed range, known light keys, boolean values, duplicates and unknown fields. Register light identities from W001 without requiring visual scene nodes.
- Update affected tests and any UI text assuming Save writes v4. Retain validated backups, detached candidate restore and travel rollback.
- Acceptance: round trips preserve exact clock/seed/overrides; v1-v4 migration is deterministic; malformed/newer saves remain rejected; failed physical restore leaves the previous run and environment intact; decoding never rewrites files.
- Validation: environment codec checks, existing save/legacy/backup tests, and a separate-process write/read using isolated slots. Every v5 test fixture is valid against the actual light registry.
- Manual Save/Load and arrival-anchor restoration remain the product behavior.

## W004 Moving sun and location lighting profiles

- [x] Done. Status: Done. Depends: W003. Evidence: [W004 acceptance](W004_ACCEPTANCE.md), sampling/profile/ownership checks and 37 inspected synthetic rendered captures.
- Compose one environment presenter in GameRoot. Drive existing DirectionalLight3D and WorldEnvironment from sampled clock values; keep simulation facts in session/services.
- Add authored outdoor/indoor lighting profiles to LocationDefinition and set production Alderwake/Tollworks explicitly. Give existing fixtures intentional defaults.
- Implement smooth daylight, evening, navy night and dawn; move the sun using the map axes; vary direct/ambient light and shadow strength. Adapt source colors to 3D lighting rather than applying its 2D tint opacity literally.
- Preserve the current stable Tollworks appearance during indoor visits. Its environment clock continues advancing under the existing session gates.
- Acceptance: the 600-second cycle and sun direction are coherent; actors, interaction labels, ground aiming, canopy treatment and guardian telegraphs remain readable; outdoor/indoor changes have no flash or abandoned environment owner.
- Validation: profile and sampling integration checks; inspect actual day/dusk/night/dawn captures in both camera projections, plus Tollworks and pause/resume.
- Additional scene-local light behavior is deferred to W005/W006.

## W005 Exterior light assets and source bindings

- [x] Done. Status: Done. Depends: W004. Evidence: [W005 acceptance](W005_ACCEPTANCE.md), all23 consumers,13,289 checks and65 inspected rendered captures.
- Build a small reusable dock-lamp visual with explicit 3D light anchor. Add dedicated emissive window surfaces to source-defined buildings, appropriate visuals/anchors for both waylights and the pinned nonblocking luminous net. All 23 W001 registry entries require visual consumers.
- Use applicable Blender skills if modeling/export is needed. Inspect the live scene first; save sources under `art/source/` and exports under `game/assets/`.
- Bind each visual/emitter to the W001 registry and the pinned instance default. Five dock lamps start disabled; Dock Row lamp starts enabled. Building windows are automatic and non-switchable.
- Use emissive windows and a bounded set of local illumination nodes. Derive ground illumination from physical lamp height and intended pool size, not a literal conversion of sprite origin to Y height.
- Keep independent instance state/materials where switching requires it. Preserve existing wrapper IDs, collision, aim-ground metadata and navigation geometry.
- Acceptance: every registry entry has its intended visual consumer; lights align with existing art; on/off and dawn/dusk intensity are visible; no entire building wall glows; local-light selection does not change logical enabled state.
- Validation: asset/import/registry checks and viewed day/dusk/night town/waylight captures. Record Blender/GLB outputs and light ranges/material decisions.
- Switching commands are W006; no full character or town art redesign.

## W006 Persistent light switch interactions

- [x] Done. Status: Done. Depends: W005. Evidence: [W006 acceptance](W006_ACCEPTANCE.md),151 command/input assertions and17 inspected rendered E/GUI/restart captures.
- Extend PrototypeInteractable and validation with a typed light action instead of inventing a dialogue for switches. Reuse InteractionSelector and GameRoot's existing range, visibility, input and combat boundaries.
- Submit a command using location/prop/source identity; revalidate the selected target before mutation. Scene nodes read the resulting session override.
- Show Turn on/Turn off prompts and clear feedback. A daytime on choice is armed for dusk; manually disabled lamps remain dark.
- Acceptance: only marked switchable sources can toggle; one command produces one change; stale/unloaded targets fail; toggling one lamp does not affect another; pause/dialogue/journal/focus/travel locks remain correct.
- Acceptance also requires explicit Save -> process restart -> Load and town/Tollworks round trips to preserve independent lamp choices and clock/weather.
- Validation: command/input/registry tests, save process checks, actual E/GUI interactions and dusk/night captures. Preserve current quest/interaction checks.
- W006 is the first complete playable lighting checkpoint, not full weather completion.

## W007 Clouds rain and lightning

- [x] Done. Status: Done. Depends: W006. Evidence: [W007 acceptance](W007_ACCEPTANCE.md),193,417 assertions and66 inspected Compatibility captures with exact GUI restart reconstruction.
- Add smooth overcast ambience, reduced direct illumination/shadow contrast, rain and deterministic bounded lightning driven by the forecast.
- Use a bounded number of world-space instanced rain batches near the visible region. Stable world coordinates/session time prevent rain following camera movement; roof/terrain exclusion keeps it outside sheltered areas.
- Use session-driven animation uniforms rather than shader TIME for new weather effects so pause actually freezes them. Account for river, elevation, both projections and zoom.
- Keep effect resources count bounded and dispose them with their owning location/presenter. Lightning is a restrained atmospheric flash, not damage or a new gameplay event.
- Acceptance: four conditions are visibly distinct, transition smoothly, and reconstruct after save/load; rain has no camera dragging, obvious batch seams, below-ground streaks or indoor leakage; pause freezes weather motion.
- Validation: weather renderer/rule checks and inspected sunny/cloudy/rain/storm captures including camera movement, hills, covered town areas and Tollworks. No performance claim until W009.
- Audio, wind gameplay, wetness mechanics and NPC schedules are outside this milestone.

## W008 Lifecycle HUD and isolated review controls

- [x] Done. Status: Done. Depends: W007. Evidence: [W008 acceptance](W008_ACCEPTANCE.md), 157 lifecycle assertions, affected regressions, exact GUI restart and 14 accepted rendered views.
- Finish hydration, save restore, safe travel commit/rollback, retry, repeated room replacement and teardown integration for clock/lights/weather.
- Bind the presented environment only to a committed session/location. Retire stale listeners, resources and interaction targets.
- Add compact time/condition HUD and light-action feedback. Avoid turning production UI into an implementation dashboard.
- Add explicitly developer-only state/environment review controls for the W009 matrix. Use detached sessions and isolated save namespaces; forced conditions/presets cannot enter a normal save or release path.
- Expose a read-only weather condition service for future routine integration. Derive `heavy-rain`; do not persist it as an authored event or implement schedules here.
- Acceptance: startup/load has no incorrect first-frame presentation; failed travel/load retains previous state; retries keep durable environment facts; repeated replacements create no duplicate owners; review controls stay isolated.
- Validation: lifecycle/rollback/focus checks, affected save/map/travel checks and actual HUD/travel/load captures.

## W009 Visual regressions and measured performance

- [x] Done. Status: Done. Depends: W008. Evidence: [W009 acceptance](W009_ACCEPTANCE.md), inspected matrix/GUI/benchmark pixels and independently audited full-duration focused windows.
- Inspect a labeled 4 day-phase x 4 weather matrix at representative town, dense-forest, bridge and ford views. Exercise both projections and supported zoom endpoints; verify indoor exclusion separately.
- Include all six lamp defaults, independent toggles, window/waylight alignment, night combat/aim readability, canopy visibility, pause, travel, failure rollback and new-process persistence.
- Run focused environment/save/interaction checks and affected existing combat, companion, quest, camera, map and playable-slice regressions.
- Adapt/reuse the M018 measurement method with outputs under W009 rather than overwriting old evidence. Record machine, settings, engine PID, warm-up, capture windows, raw samples and repeated-travel resource counts.
- Acceptance: on the same declared development baseline, each profiled run meets frame p95 <=16.67 ms, frame p99 <=25 ms and draw-call p95 <=500 including shadows/UI. At least clear day and worst storm/night lighting are measured at all four benchmark views. Repeat travel has no accumulating scene/effect/light resources.
- Match M018's three runs per profiled view/condition when claiming equivalent evidence; retain raw failed runs. If comparison hardware/settings differ, label the difference and still test the targets.
- Performance failures remain open and receive a focused repair/retest; do not silently switch renderer, remove required lights/effects, weaken thresholds or label setup placements as normal walkthroughs.
- Validation: raw measurement audit, inspected capture index, exact regression commands/exits and a concise criterion-to-evidence report.

## W010 Packaged Windows and native acceptance

- [x] Done. Status: Done. Depends: W009. Evidence: [W010 acceptance](W010_ACCEPTANCE.md), fresh exports/pack audits/outside startup and ordinary native recovery with exact GUI process restart.
- Rebuild Windows Validation and Windows Desktop using existing presets/templates. Preserve historical M019 packages/evidence needed for comparison; identify the new package hashes.
- Audit packaged assets/scripts and startup from outside the source checkout. Runtime must not depend on the read-only Flutter folder or local authoring files.
- Use ordinary native input for a fresh recovery journey, lamp switching, GUI Save, quit, separate process GUI Load and revisit. Demonstrate restored clock, seed/forecast, independent lamp choices and existing quest/party facts.
- Include genuine clock/weather progression; labeled deterministic development fixtures can prove rare-condition matrices, but cannot substitute for release controls, save/restart or a normal quest route.
- Acceptance: resulting native release passes the full existing recovery loop and feature persistence with inspected captures and clean runtime logs. Debug bridge evidence alone cannot complete this task.
- Update parent architecture/README/current state where the resulting feature or release description changed; retain historical P/M evidence. Finish this workflow state with all tasks Done and no next item.
- Validation: imports, exports, pack audit, focused release regressions and native walkthrough. Record any required human gate if native input tooling is unavailable; leave W010 incomplete.

## Validation and evidence rules

Use current [architecture](../ARCHITECTURE.md), [playtest tools](../../tools/PLAYTEST.md) and project gameplay skill when playing. Raw evidence belongs under ignored `docs/evidence/W001/` through `W010/`; disposable staging/build outputs use `builds/weather-lighting/`. Preserve local prior reports. Track only concise acceptance results, durable decisions and reusable fixtures outside the archive.

Record actual command, working directory, environment/save isolation, exit code, runtime-error scan and artifact path. Exit 0 with SCRIPT ERROR is not a pass. Rendered evidence requires inspecting pixels. Setup placements, forced times/weather and injected facts are explicitly synthetic; they prove only their stated checks. Normal saves are never test fixtures.

Suggested future test filenames are proposals, not existing commands: `environment_rule_checks.gd`, `environment_save_checks.gd`, `environment_lighting_checks.gd`, `light_interaction_checks.gd`, `weather_presentation_checks.gd`, `environment_lifecycle_checks.gd`. Verify existence before invoking them.

Before each final response, run `git diff --check`, review intended changes, reconcile checklist/state and report task/status, result, exact verification, remaining limits and next eligible task.

## Completion records

W001 - completed 2026-10-04 (America/Vancouver)

Result: all 23 exterior sources/defaults/wrapper anchors inventoried; clock,
forecast, save, room, renderer and performance decisions fixed in CONTRACT.
W001 original source audit, headless root and standalone startup passed (exit 0,
no runtime errors). Documentation/link/diff review passed. No visual/performance
claim or production weather implementation.
Retained inputs: [reference README](reference/README.md), four exact rule sources,
inspection hashes, fixed vectors and light inventory. Raw logs and broad snapshots
are optional local archives; missing archives do not block W002.
Limits: pinned geography wins over source drift; four automatic windows disabled;
luminous net included; eight-emitter pool; schema4/content1 until W003.
Next eligible task: W002 only; not started.

Repository cleanup - 2026-10-04 (user request, no additional W task)

Raw evidence untracked/ignored; all local files preserved. Retained four exact rule
sources, inspection hashes, vectors, compact light registry and independent map
fixtures. Clean-checkout reference audit/extractor tests, affected map checks and
script parsing pass. Current states shortened; task criteria/statuses unchanged.

W002 - completed 2026-10-04 (America/Vancouver)

Result: typed environment state, 600-second/10 AM clock, once-per-run uint32 seed,
source-compatible forecast and cached detached samples. Atomic session advancement
uses existing root gates; day 0..3650 cap rejects without partial mutation.
All 49 fixed forecasts, uint32 products, display/day wraps, large deltas, all 100
transition rolls, duration/blend edges, invalid inputs and thunderstorm-only
heavy-rain pass; 12,792 rule assertions. Upper-bound reconstruction <=55.897ms
in final run; 1,000 same-period queries computed no further periods.
Root/session gates and affected application/dialogue/ten-round-trip checks pass,
all exit 0 with clean runtime scans. Reference/fixture/hash/link/diff audits pass.
[Acceptance/commands](W002_ACCEPTANCE.md). Initial boundary failure retained locally;
forecast-only 1e-9-minute normalization documented in CONTRACT.
Limits: fixed lighting, schema4/content1, no environment persistence/render/native
claim. Import retains known missing .NET SDK 10.0.9 diagnostic. Next: W003 only.

W003 - completed 2026-10-04 (America/Vancouver)

Result: strict schema5/content1 environment clock/seed and map-qualified light
overrides, node-independent 23-source registry/six switchable lanterns. Exact
v1-v4 migrations preserve prior facts; v4 keeps trust/reactions/upgrades. Manual
Save writes v5; read/recovery never rewrites files or rerolls environment seed.
Primary/backup full-precision output and bounded exact timer decoder repair
observed installed-engine rounding without changing field shape or clock bounds.
517 codec assertions include 305 independent binary64 vectors, last-clock-double
filesystem reload, strict malformed/newer rejection and deterministic migrations.
Rule/session/save/quest/consequence/companion/application regressions pass;
independent writer/reader restore clock/seed/six overrides/forecast/party/arrival.
Historical map fixtures5/replacements24/rejections5/retries5 pass; only expected
synthetic retry diagnostic. Reference/link/status/runtime/diff audits pass.
[Commands/evidence/repairs](W003_ACCEPTANCE.md). W002 uncommitted baseline preserved.
Limits: rendering fixed, E switching and packaged/native weather unrun as later
scope; known missing .NET SDK import diagnostic. Next eligible: W004 only.

W004 - completed 2026-10-04 (America/Vancouver)

Result: one root-owned environment presenter, authored outdoor/stable indoor
profiles, smooth source-knot day/dusk/navy night/dawn and physical moving sun.
Tollworks retains original appearance while global clock advances. Root applies
committed profile/time synchronously; pause freezes, failed placement retains old
presentation and repeated room replacement retains one owner/independent resource.
30,053 lighting assertions, retained reference audit and eight affected regressions
pass (rules12,792; codec517; ten-round-trip, camera/combat/save/gate checks).
37 actual960x640 Compatibility captures inspected: four phases/both projections
at town, forest, Moonwell and Tollworks plus pause/travel/resume. Actors/labels,
floor aim/canopy and gold windup remain readable. Final exits0/runtime scans clean;
import retains known missing .NET SDK10.0.9. Failed fixture-ID/float32/aim-probe
runs retained, repaired in tests. Links/statuses/UID/diff audit pass.
[Commands/evidence/decisions/limits](W004_ACCEPTANCE.md). No normal/native journey,
new performance benchmark or weather/local-light claim; historical baselines and
normal saves preserved. Next eligible: W005 only; not started.

W005 - completed 2026-10-04 (America/Vancouver)

Result: all23 pinned exterior sources have independent visual consumers, six
reusable dock lamps, fourteen dedicated window surfaces, two waylights and one
nonblocking woven net. Editable Blender source/six-mesh GLB (2,344 triangles),
physical anchors and eight fixed unshadowed local emitters; windows/net emit only.
Source light-opacity knots drive dusk/night/dawn, spatial fading preserves enabled
facts. Wrappers/IDs/feet/collision/navigation and W004 baseline remain intact.
13,289 consumer assertions, W004 lighting30,053/codec517 and five affected
application/interaction/travel/town-art/forest regressions pass. All65 final
960x640 Compatibility source/phase/override captures inspected; on/off and floor
illumination visible, panes aligned, wall materials non-emissive. Reference/asset,
metadata/link/UID/status/runtime/diff audits pass; final runtime exits0/scans clean.
[Commands/repairs/decisions/limits](W005_ACCEPTANCE.md). Initial multi-scene export,
zero-range net allocation and metadata-only collider test repaired; failures kept.
Known missing .NET SDK10.0.9 import diagnostic remains. No normal saves/native
route/performance/package claim. Next eligible: W006 only; not started.

W006 - completed 2026-10-04 (America/Vancouver)

Result: six wrapper-owned typed light actions; existing E selector/range/LOS and
input/combat boundaries; session-owned expected-state commands reject stale retries.
WeakRef safely rejects unloaded/freed targets. Dynamic Turn on/off prompts and
lamp-scoped feedback explain daylight readiness. Schema5/content1 and pinned
art/physics/navigation/IDs remain unchanged. All23 consumers still read defaults
and independent saved facts; seventeen automatic sources cannot toggle.
151 focused assertions, consumer13,289/codec517 and application/dialogue/quest/
ten-round-trip regressions pass. Writer/reader PIDs50060/33532 use actual GUI Save/
Load across separate processes; exact clock/seed/forecast and lamp02-on/Dock-Row-off
restore. E town/Tollworks round trip retains choices;17 actual960x640 images inspected
through three sheets plus originals. Final runtime exits0/scans clean; import
retains known missing .NET SDK10.0.9. Reference/link/status/UID/diff audits pass.
[Commands, criteria, repairs and limits](W006_ACCEPTANCE.md). Failed fixtures/runner/
movement/oracle runs retained locally. Forced phases/remote approaches are synthetic;
no weather/performance/packaged/native claim. Normal saves and prior P/M records
preserved. Owned game processes exited; user Blender untouched. Next: W007 only.

Testing infrastructure follow-up - completed 2026-10-04, explicitly requested after W006.
Shared bounded runner, API/camera preflight skill, exact restart helper, read-only
observations, pause/provenance capture tools and narrow native W evidence guards
verified. [Results and limits](../TESTING_TOOLS_ACCEPTANCE.md). W006 remains Done;
At that follow-up W007 remained Pending. W007 completion below occurred later; the tooling follow-up itself did not complete or start another W task.

W007 - completed 2026-10-04 (America/Vancouver)

Result: smooth forecast-driven cloud/direct/ambient/shadow composition, fixed-world
rain tiles with actual terrain/21-roof exclusion, and bounded seeded atmospheric
lightning. Rain shader/session phase and flash freeze on pause; no per-drop Nodes,
shader TIME, additional lights, gameplay damage/audio or persistent particle state.
One location-owned rain resource set, hard64-batch bound (captured max36), stable
camera coordinates and arrival-frustum hydration preserve existing ownership.
193,417 weather assertions, W00430,053/startup and eight affected environment/save/
switch/travel/camera/combat checks pass.66 actual960x640 Compatibility images,
six final sheets and important originals inspected: four conditions/five views/
both projections, storm night/zoom endpoints, hills/roofs/river, camera/input
motion, rain-to-storm transition, deterministic flash and stable indoor telegraph.
Paused rain-only images0.5s apart are byte-identical. Actual GUI Save -> writer
PID56332 exit -> reader1028 GUI Load exactly restores snapshot/forecast/render
phase/flash; indoor disposal and outdoor rehydration pass. Final runtime scans
clean; import retains known missing .NET SDK10.0.9. Reference/link/UID/status/diff
audits pass. [Commands, decisions, repairs and limits](W007_ACCEPTANCE.md).
Initial dirty W006/testing work and normal saves preserved; failures retained.
Synthetic review/viewport input does not prove native release or performance.
All owned Godot processes exited; Blender untouched. Next: W008 only; not started.

W008 - completed 2026-10-04 (America/Vancouver)

Result: committed clock/condition HUD, existing E light feedback, read-only
condition service and debug-only detached review sessions with isolated namespaces
and repository/root save refusal. Pause F7/F8 cycles real seeded phase/condition
presets; normal startup/release paths compose no review controller. Startup/load,
unsafe travel/load rollback, retry, focus, repeated room/resource cleanup and root
teardown pass 157 assertions plus actual CLI child. W007 193,417, lighting30,053,
codec517, switches151, save/dialogue/camera/map/startup and ten-travel regressions
pass; five historical v4 fixtures pass in separate writer/reader processes.
Actual GUI Tab/Enter Save -> new process Load restores exact snapshot/forecast;
E travel/return and 14 accepted960x640 images inspected. Runner32 checks and
reference/link/UID/status/diff audits pass; runtime exits0/scans clean. Import
retains known missing .NET SDK10.0.9. Stale map interaction assertion/report paths
repaired; historical report recovery and all failed runs documented in
[acceptance](W008_ACCEPTANCE.md). No benchmark/native/package claim or next task
started. Normal saves untouched; owned processes exited. Next: W009 only.

Testing follow-up - completed 2026-10-04 after W008 commit, at user request.

Runner now enforces fresh evidence routing, streams diagnostics, compiles runtime
script dependencies before execution and supports RenderOnly. Shared GUI helper
requires actual focus/outcomes; capture preserves settings/focus. Infrastructure50,
support64/evidence15, 11 migrated report writers/17 protected archive paths and
separate GUI Save/Load with nine inspected images pass. Project/installed skill
guidance updated. [Results and limits](../TESTING_TOOLS_IMPROVEMENTS.md).
W001-W008 remain Done; W009/W010 Pending. No next W task started.

W009 - completed 2026-10-04 (America/Vancouver)

Result: reusable detached visual matrix and M018 weather profiler/isolated launcher/
independent raw auditor.256 exterior combinations, eight night combat, eight
lamp/waylight defaults, four pause/rollback and four indoor telegraph captures;
all64 indoor presets assert exclusion.289 matrix/GUI images/25 sheets,24 accepted
benchmark images/two sheets and four repaired smoke images/one sheet inspected.
Lifecycle157/weather193,417 and nineteen focused regressions pass; GUI writer/
fresh reader exact environment/independent lamps/HUD and E travel/return pass.
24 full60s windows (three/view/condition,10s warm-up),341,144 focused frames;
worst p95=6.805ms,p99=9.188ms,draw p95=280, all16.67/25/500 gates pass.
Same M018 machine/settings; clear-day defaults/storm-night all six lamps enabled.
Final clean engine31936:12 round trips/24 commits, stable3836 nodes/7573 objects/
305 resources, zero orphans, one world/nav/presenter/rain owner,23 consumers/
eight emitters/12 rain batches; unchanged map inventory. Peak442.33MiB,
growth4.08MiB, within2GiB/64MiB. Independent raw hashes/coverage/settings/focus/
weather/memory/lifecycle audit passes. All contributing peaks<=444.44MiB.
Float32/caption/focus/audit-metadata/capture-index failures retained and repaired;
only valid focused windows accepted across preserved original/targeted retests.
No production/art/save/renderer/source changes or weakened gates. Reference/link/
UID/status/intended CRLF-aware diff audits pass; known missing .NET SDK10.0.9
import diagnostic remains. [Commands, selections, repairs and limits](W009_ACCEPTANCE.md).
Normal saves/P/M archives/Blender preserved; all owned Godot processes exited.
Native Windows/package acceptance remains unrun W010 scope. Next: W010 only;
not started.

W010 - completed 2026-10-04 (America/Vancouver)

Result: both existing Windows presets rebuilt with retained standard4.7.2 templates;
old packages/override archived, new hashes recorded. Catalog/pinned layout/23-source
registry/schema5/four imported kits/Compatibility audits pass; release tests absent.
Both standalone executables start outside checkout, exit0 and runtime scans clean.
Native release writer24704/reader27408 use only ordinary input/read-only trace:
fresh trust/lead/Strike, independent lamps, Moonwell/ford/bridge, guardian/vessel/
return/fitting/service, GUI Save/quit/separate GUI Load and native cleared revisit.
Exact whole-file and typed snapshot/forecast restart; seed627001559 retained,
Clear/Cloudy/Rain/Cloudy and daylight/night progression genuine. Lamp04-on/Row-off,
hero75/ally25, trust1/upgrade/all six effects/steps retained.352 guarded requests,
80 actual960x640 images/seven sheets inspected; both normal exits0/log scans clean.
Import and focused environment/save/switch/recovery/combat/extension/settings/map/
camera/travel checks pass after narrow settings child evidence-path repair.
Failed child/relative-planner attempts and original captions kept; fresh captions
correct three paused labels. Reference/script/link/status/package/intended CRLF-aware
diff audits pass. Known editor missing .NET SDK10.0.9 diagnostic remains; standard
GDScript packages run clean. [Commands, hashes, provenance and limits](W010_ACCEPTANCE.md).
Normal saves/P/M archives/user Blender preserved; all owned Godot processes exited.
No production/source/art/renderer change, commit, publication or installation.
W001-W010 Done. Next eligible task: none; workflow complete.
