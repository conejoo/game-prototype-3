# Weather and interactive lighting migration checklist

This checklist brings the existing weather, day clock and interactive exterior lights into the Returning Fair Godot prototype. It is the task authority for this workflow. Each fresh agent completes or resumes exactly one task, then writes a handoff for the next session.

Prepared 2026-10-04, America/Vancouver. W001 source inventory verified Done; W002-W010 remain Pending. No production weather implementation has started. P001-P014 and map M001-M019 are recorded complete in their own handoffs; that historical release does not certify this future feature.

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
| W002 | Pending | W001 | Pure clock and deterministic forecast |
| W003 | Pending | W002 | Versioned environment save compatibility |
| W004 | Pending | W003 | Moving sun and location lighting profiles |
| W005 | Pending | W004 | Exterior light assets and source bindings |
| W006 | Pending | W005 | Persistent E key light switching |
| W007 | Pending | W006 | Clouds, world anchored rain and lightning |
| W008 | Pending | W007 | Lifecycle integration, HUD and isolated review controls |
| W009 | Pending | W008 | Visual matrix, regressions and measured performance |
| W010 | Pending | W009 | Packaged Windows and native acceptance |

Dependencies are deliberately sequential. The first playable lighting checkpoint is W006; the full feature requires W010.

## W001 Source inventory and verified contract

- [x] Done. Status: Done. Depends: verified M019 baseline. Evidence: [W001 validation](../evidence/W001/VALIDATION.md), [inventory](../evidence/W001/LIGHT_INVENTORY.md), [hash audit](../evidence/W001/audit-results.json).
- Inspect actual Godot project, applicable instructions, parent architecture/state, M019 release handoff, pinned map/catalog/layout and current Git changes. Preserve all prior work.
- Hash and record the read-only behavior sources listed in CONTRACT. Retain a target-local, scoped reference copy or equivalent fixed test vectors for forecast/day/light rules; never refresh the old map snapshot automatically.
- Complete an inventory of every in-scope exterior light: location, prop ID, source ID, default enabled state, switchability, 3D wrapper/anchor, emitter kind and required visual asset. Include six dock lamps, authored building window sources and the two exterior waylights where present in the pinned data.
- Record adaptations of 2D sprite origins, ground-light radius and shadow styling into physical 3D anchors. Identify every asset gap and assign it to W005.
- Confirm room profiles, clock gates, source transition probabilities, save shape, renderer strategy and performance method. Update CONTRACT with verified decisions and reference hashes.
- Acceptance: M019 capability is intact; all selected IDs/defaults have evidence; no runtime dependency on the source checkout is proposed; the new workflow has a reproducible source baseline and no unresolved design prerequisite for W002.
- Validation: document/source/link/hash audit and a bounded startup/baseline check if needed. Do not rerun the whole historical acceptance suite for documentation alone.

## W002 Pure clock and deterministic forecast

- [ ] Done. Status: Pending. Depends: W001.
- Add typed environment runtime state and node-independent clock/forecast rules, suggested under `game/features/environment/`. Wire clock advancement through the existing session update; do not create a competing timer authority.
- Preserve the source 600-second day, 10 AM initial display, day-index/progress convention, four weather values, seeded period duration and transition graph. Generate a new-run seed once.
- Implement source-compatible unsigned 32-bit mixing in GDScript and a typed sample containing previous/current condition, period bounds and blend progress. Expose derived `heavy-rain` only for thunderstorms.
- Cache forecast sampling between boundaries; avoid replaying all periods every render frame. Establish bounded reconstruction or a justified validated time limit for long saved runs.
- Acceptance: fixed source vectors match; midnight/display time and source cycle boundary are not conflated; large delta advances do not lose days; equal seed/time produces equal forecast; invalid inputs fail; pause/travel gates behave as contracted.
- Validation: meaningful rule checks for seeds, exact boundaries, 4-8 hour durations, transition probabilities, blend edges, day wrapping, long-time sampling and derived conditions; affected application/session checks.
- Production rendering and environment serialization remain owned by later tasks.

## W003 Versioned environment save compatibility

- [ ] Done. Status: Pending. Depends: W002.
- Extend SaveCodec to schema v5 with validated environment clock, weather seed and a map-qualified light-override container. Keep content version 1 only after confirming additive compatibility.
- Support exact v1-v4 envelopes through documented migrations. Retain all prior party, health, quests, once-only effects, companion trust/reactions, progression and elapsed-play fields.
- Legacy environment defaults are day index 0, progress 0, a fixed migration seed and no overrides. Preserve old elapsed time separately. New v5 runs choose their seed once. Do not re-roll seeds on load.
- Validate supported time bounds, integer seed range, known light keys, boolean values, duplicates and unknown fields. Register light identities from W001 without requiring visual scene nodes.
- Update affected tests and any UI text assuming Save writes v4. Retain validated backups, detached candidate restore and travel rollback.
- Acceptance: round trips preserve exact clock/seed/overrides; v1-v4 migration is deterministic; malformed/newer saves remain rejected; failed physical restore leaves the previous run and environment intact; decoding never rewrites files.
- Validation: environment codec checks, existing save/legacy/backup tests, and a separate-process write/read using isolated slots. Every v5 test fixture is valid against the actual light registry.
- Manual Save/Load and arrival-anchor restoration remain the product behavior.

## W004 Moving sun and location lighting profiles

- [ ] Done. Status: Pending. Depends: W003.
- Compose one environment presenter in GameRoot. Drive existing DirectionalLight3D and WorldEnvironment from sampled clock values; keep simulation facts in session/services.
- Add authored outdoor/indoor lighting profiles to LocationDefinition and set production Alderwake/Tollworks explicitly. Give existing fixtures intentional defaults.
- Implement smooth daylight, evening, navy night and dawn; move the sun using the map axes; vary direct/ambient light and shadow strength. Adapt source colors to 3D lighting rather than applying its 2D tint opacity literally.
- Preserve the current stable Tollworks appearance during indoor visits. Its environment clock continues advancing under the existing session gates.
- Acceptance: the 600-second cycle and sun direction are coherent; actors, interaction labels, ground aiming, canopy treatment and guardian telegraphs remain readable; outdoor/indoor changes have no flash or abandoned environment owner.
- Validation: profile and sampling integration checks; inspect actual day/dusk/night/dawn captures in both camera projections, plus Tollworks and pause/resume.
- Additional scene-local light behavior is deferred to W005/W006.

## W005 Exterior light assets and source bindings

- [ ] Done. Status: Pending. Depends: W004.
- Build a small reusable dock-lamp visual with explicit 3D light anchor. Add dedicated emissive window surfaces to source-defined buildings, appropriate visuals/anchors for both waylights and the pinned nonblocking luminous net. All 23 W001 registry entries require visual consumers.
- Use applicable Blender skills if modeling/export is needed. Inspect the live scene first; save sources under `art/source/` and exports under `game/assets/`.
- Bind each visual/emitter to the W001 registry and the pinned instance default. Five dock lamps start disabled; Dock Row lamp starts enabled. Building windows are automatic and non-switchable.
- Use emissive windows and a bounded set of local illumination nodes. Derive ground illumination from physical lamp height and intended pool size, not a literal conversion of sprite origin to Y height.
- Keep independent instance state/materials where switching requires it. Preserve existing wrapper IDs, collision, aim-ground metadata and navigation geometry.
- Acceptance: every registry entry has its intended visual consumer; lights align with existing art; on/off and dawn/dusk intensity are visible; no entire building wall glows; local-light selection does not change logical enabled state.
- Validation: asset/import/registry checks and viewed day/dusk/night town/waylight captures. Record Blender/GLB outputs and light ranges/material decisions.
- Switching commands are W006; no full character or town art redesign.

## W006 Persistent light switch interactions

- [ ] Done. Status: Pending. Depends: W005.
- Extend PrototypeInteractable and validation with a typed light action instead of inventing a dialogue for switches. Reuse InteractionSelector and GameRoot's existing range, visibility, input and combat boundaries.
- Submit a command using location/prop/source identity; revalidate the selected target before mutation. Scene nodes read the resulting session override.
- Show Turn on/Turn off prompts and clear feedback. A daytime on choice is armed for dusk; manually disabled lamps remain dark.
- Acceptance: only marked switchable sources can toggle; one command produces one change; stale/unloaded targets fail; toggling one lamp does not affect another; pause/dialogue/journal/focus/travel locks remain correct.
- Acceptance also requires explicit Save -> process restart -> Load and town/Tollworks round trips to preserve independent lamp choices and clock/weather.
- Validation: command/input/registry tests, save process checks, actual E/GUI interactions and dusk/night captures. Preserve current quest/interaction checks.
- W006 is the first complete playable lighting checkpoint, not full weather completion.

## W007 Clouds rain and lightning

- [ ] Done. Status: Pending. Depends: W006.
- Add smooth overcast ambience, reduced direct illumination/shadow contrast, rain and deterministic bounded lightning driven by the forecast.
- Use a bounded number of world-space instanced rain batches near the visible region. Stable world coordinates/session time prevent rain following camera movement; roof/terrain exclusion keeps it outside sheltered areas.
- Use session-driven animation uniforms rather than shader TIME for new weather effects so pause actually freezes them. Account for river, elevation, both projections and zoom.
- Keep effect resources count bounded and dispose them with their owning location/presenter. Lightning is a restrained atmospheric flash, not damage or a new gameplay event.
- Acceptance: four conditions are visibly distinct, transition smoothly, and reconstruct after save/load; rain has no camera dragging, obvious batch seams, below-ground streaks or indoor leakage; pause freezes weather motion.
- Validation: weather renderer/rule checks and inspected sunny/cloudy/rain/storm captures including camera movement, hills, covered town areas and Tollworks. No performance claim until W009.
- Audio, wind gameplay, wetness mechanics and NPC schedules are outside this milestone.

## W008 Lifecycle HUD and isolated review controls

- [ ] Done. Status: Pending. Depends: W007.
- Finish hydration, save restore, safe travel commit/rollback, retry, repeated room replacement and teardown integration for clock/lights/weather.
- Bind the presented environment only to a committed session/location. Retire stale listeners, resources and interaction targets.
- Add compact time/condition HUD and light-action feedback. Avoid turning production UI into an implementation dashboard.
- Add explicitly developer-only state/environment review controls for the W009 matrix. Use detached sessions and isolated save namespaces; forced conditions/presets cannot enter a normal save or release path.
- Expose a read-only weather condition service for future routine integration. Derive `heavy-rain`; do not persist it as an authored event or implement schedules here.
- Acceptance: startup/load has no incorrect first-frame presentation; failed travel/load retains previous state; retries keep durable environment facts; repeated replacements create no duplicate owners; review controls stay isolated.
- Validation: lifecycle/rollback/focus checks, affected save/map/travel checks and actual HUD/travel/load captures.

## W009 Visual regressions and measured performance

- [ ] Done. Status: Pending. Depends: W008.
- Inspect a labeled 4 day-phase x 4 weather matrix at representative town, dense-forest, bridge and ford views. Exercise both projections and supported zoom endpoints; verify indoor exclusion separately.
- Include all six lamp defaults, independent toggles, window/waylight alignment, night combat/aim readability, canopy visibility, pause, travel, failure rollback and new-process persistence.
- Run focused environment/save/interaction checks and affected existing combat, companion, quest, camera, map and playable-slice regressions.
- Adapt/reuse the M018 measurement method with outputs under W009 rather than overwriting old evidence. Record machine, settings, engine PID, warm-up, capture windows, raw samples and repeated-travel resource counts.
- Acceptance: on the same declared development baseline, each profiled run meets frame p95 <=16.67 ms, frame p99 <=25 ms and draw-call p95 <=500 including shadows/UI. At least clear day and worst storm/night lighting are measured at all four benchmark views. Repeat travel has no accumulating scene/effect/light resources.
- Match M018's three runs per profiled view/condition when claiming equivalent evidence; retain raw failed runs. If comparison hardware/settings differ, label the difference and still test the targets.
- Performance failures remain open and receive a focused repair/retest; do not silently switch renderer, remove required lights/effects, weaken thresholds or label setup placements as normal walkthroughs.
- Validation: raw measurement audit, inspected capture index, exact regression commands/exits and a concise criterion-to-evidence report.

## W010 Packaged Windows and native acceptance

- [ ] Done. Status: Pending. Depends: W009.
- Rebuild Windows Validation and Windows Desktop using existing presets/templates. Preserve historical M019 packages/evidence needed for comparison; identify the new package hashes.
- Audit packaged assets/scripts and startup from outside the source checkout. Runtime must not depend on the read-only Flutter folder or local authoring files.
- Use ordinary native input for a fresh recovery journey, lamp switching, GUI Save, quit, separate process GUI Load and revisit. Demonstrate restored clock, seed/forecast, independent lamp choices and existing quest/party facts.
- Include genuine clock/weather progression; labeled deterministic development fixtures can prove rare-condition matrices, but cannot substitute for release controls, save/restart or a normal quest route.
- Acceptance: resulting native release passes the full existing recovery loop and feature persistence with inspected captures and clean runtime logs. Debug bridge evidence alone cannot complete this task.
- Update parent architecture/README/current state where the resulting feature or release description changed; retain historical P/M evidence. Finish this workflow state with all tasks Done and no next item.
- Validation: imports, exports, pack audit, focused release regressions and native walkthrough. Record any required human gate if native input tooling is unavailable; leave W010 incomplete.

## Validation and evidence rules

Use current [architecture](../ARCHITECTURE.md), [playtest tools](../../tools/PLAYTEST.md) and project gameplay skill when playing. Evidence belongs under `docs/evidence/W001/` through `W010/`; disposable staging/build outputs use `builds/weather-lighting/`. Do not alter prior P/M evidence.

Record actual command, working directory, environment/save isolation, exit code, runtime-error scan and artifact path. Exit 0 with SCRIPT ERROR is not a pass. Rendered evidence requires inspecting pixels. Setup placements, forced times/weather and injected facts are explicitly synthetic; they prove only their stated checks. Normal saves are never test fixtures.

Suggested future test filenames are proposals, not existing commands: `environment_rule_checks.gd`, `environment_save_checks.gd`, `environment_lighting_checks.gd`, `light_interaction_checks.gd`, `weather_presentation_checks.gd`, `environment_lifecycle_checks.gd`. Verify existence before invoking them.

Before each final response, run `git diff --check`, review intended changes, reconcile checklist/state and report task/status, result, exact verification, remaining limits and next eligible task.

## Completion records

W001 - completed 2026-10-04 (America/Vancouver)

Result: 23 exterior sources/defaults/wrapper anchors inventoried; 23 exact behavior references pinned; clock/forecast/save/room/renderer/performance decisions verified.
Files: weather CHECKLIST, CURRENT_STATE, CONTRACT; docs/evidence/W001/ audit/reference/inventory/vector/baseline/report artifacts. AGENT_PROMPT and production game/art unchanged.
Commands and exact results: audit.py --capture-source PASS0; run_baseline.py PASS0 (engine probe0, standalone release startup0, no runtime errors); final audit/diff/link results in W001/final-review.json.
Evidence and viewed captures: W001/VALIDATION.md, source-manifest.json, light-inventory.json, rule-vectors.json, baseline-results.json, engine-baseline.json. No new visual captures required or claimed for W001.
Decisions and retained limits: pinned target geography wins over current source drift; four automatic window defaults false; luminous net included; conservative eight-emitter pool; schema4/content1 unchanged until W003. Headless baseline does not prove future weather visuals/performance.
Next eligible task: W002 only; not started.
