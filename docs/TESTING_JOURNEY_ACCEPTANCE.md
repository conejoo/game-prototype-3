# Shared journey helper

Tooling follow-up requested2026-10-07 (America/Vancouver), after F007 commit
`eff156a`. This does not select F008 or change gameplay/save/navigation ownership.
Status: Complete. F001-F007 remain Done; F008 remains the next eligible feature task.

## Implementation

`game/tests/support/test_run_journey.gd` exposes `TestRunJourney.walk(game, goal,
label, overrides={})` and `wait_navigation(location, point, max_frames=120,
max_ms=3000)`. F005's `_walk` is now a thin result/trace adapter; F006 and F007
inherit that adapter and use the shared helper. Both new scripts include UIDs.
F007's three workaround midpoint routes were removed.

- Movement uses viewport WASD and the current camera's movement axes each frame.
  There is no actor placement, goal snapping, focus clearing or gameplay grant.
- Readiness requires an active map, the expected enabled region owning the start
  query, and usable local path queries across a stable server iteration. Queued
  changes are synchronized and polled with bounded frame/wall limits.
- Path start and endpoint are checked before input. Arrival requires horizontal
  and vertical tolerances; an already reached goal succeeds without movement.
- Route length/current actor speed set the physics budget with steering overhead;
  explicit frame/wall hard caps remain. The watchdog measures route progress,
  rather than accepting arbitrary movement or waiting for the full route timeout.
- Failures return a reason/error and available path, position, waypoint, timing,
  input, focus, camera and collision diagnostics. Scenario traces keep failures.
- Mode/location/region changes cancel. Viewport key-up always runs after input;
  if a paused actor cannot receive it, cleanup erases only this journey's accepted
  transient movement actions. Preexisting caller-held input is rejected and retained.

The maintained recipe lives in the gameplay skill's shared testing-tools reference.
Repository and installed copies are synchronized; both pass quick_validate using
the existing cached PyYAML dependency. No installation or global configuration change.

## Acceptance

- [x] Standalone reusable helper replaces the embedded movement algorithm.
- [x] Readiness accepts delayed exact-region registration and rejects wrong maps,
  invalid limits and disabled regions; disconnected endpoints fail before input.
- [x] F007's unreachable `(107.25,0,-2)` goal fails immediately and identifies the
  actual endpoint `(107.25,0.05,-1.3999)`, approximately0.600m away.
- [x] Current and rotated camera axes drive actual viewport movement; arrival,
  explicit frame/wall limits, stalls and mode/navigation changes release owned keys.
- [x] Focus/pause/region cancellation and a subsequent valid journey are checked;
  foreign held keys survive a pre-input rejection.
- [x] Final F007 long ordinary travel/restart and F005 flower-route regressions.
- [x] Discoverable recipe and synchronized, validated installed skill copy.

## Verification

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7,
Godot console `4.7.2.stable.mono.official.ed1daf0bf`, Compatibility renderer.
Runner creates unique TESTING evidence/app-data/save-slot directories; normal saves
and read-only source are untouched. Runtime diagnostics fail, including exit-zero
errors. Initial import passes with only the preexisting allowed editor SDK diagnostic.

- `./tools/run_checks.ps1 -Task TESTING -Import -Names testing_journey_checks -TimeoutSeconds 90`:
  initial helper34 assertions
  passed in `20261008-002158507-37854133` before additional cancellation cases.
- Final focused check `20261008-003413329-c8e6a30f`:35 assertions pass after the
  additional readiness, pause cleanup and isolated-fixture repairs.
- Final combined run `20261008-003454550-821aafba`:
  journey35, shared support64 and movement_camera_checks pass. F007 writer passes;
  outbound128.281m route uses2044 frames, return129.684m uses2039 frames, both beyond
  the old1800-frame ceiling. The post-travel dock/rod PNG was inspected at960x640.
  Independent reader passes exact whole-save GUI Load,2039-frame ordinary revisit
  and physical recollection. Both post-travel and restored-recollection PNGs were
  inspected at960x640; the rod remains after travel and is absent after recollection.
- `./tools/run_checks.ps1 -Task TESTING -Names testing_journey_checks,testing_support_checks,movement_camera_checks -RenderScript world_item_placement_render -RenderPhases write,read -TimeoutSeconds 240`
  is the exact final combined command above. Parse and runtime scans pass with
  no diagnostics; both owned renderer processes exit normally.
- `./tools/run_checks.ps1 -Task TESTING -RenderOnly -RenderScript foraging_interaction_render -RenderPhases write,read -TimeoutSeconds 150`:
  `20261008-003812551-28bb5991` passes ordinary dock and all three flower routes,
  hold/cancel/completion, GUI Save, independent exact GUI Load and normal revisit.
  Moonflower03 arrives at approximately `(30.76245,0.5,-8.85182)` on its elevated
  plot. Ten writer captures/two live frames and three reader captures are retained.
  The gathered flower03 PNG was inspected at960x640. No runtime diagnostics.

All owned check/renderer processes exited. Raw evidence remains ignored. No native
release/export was regenerated, and no source geography, normal save or feature
checklist status changed. The next feature task is still F008.

## Failure lessons retained

Intermediate failed runs remain under ignored `docs/evidence/TESTING/`. They exposed
ownership becoming queryable before path publication, zero-length self-paths being
an unsuitable readiness probe, paused actors missing viewport release, and synthetic
fixtures interrupting preflight rather than accepted movement. Fixtures now wait
for actual accepted input before injecting cancellation.

Synthetic navigation uses an explicitly owned World3D and synchronized map activation;
it does not add/remove probe regions in the production map. Disabling/re-enabling
the full exterior region is not the production restoration lifecycle: an owner query
can succeed while path queries remain unavailable. That destructive cancellation
fixture runs last and is disposed; actual travel/restart validates WorldHost's
authoritative arrival lifecycle. No sleep count substitutes for a readiness result.

Native/export checks and broader unrelated gameplay were not selected. F006's
standalone scenario is compiled through inheritance and its modal helpers run in
F007; its complete separate scenario is not repeated for this movement-only change.
