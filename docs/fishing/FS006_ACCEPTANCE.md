# FS006 acceptance - Public fishing HUD, visuals and testing access

Completed 2026-10-09 UTC. Exactly FS006 executed; FS007/FS008 remain Pending.
Entry/final HEAD `93aea06a59552ce152473f95582ddc3333749a84`; entry Git clean.
Every FS006 criterion below passes. No commit, push, export or successor work.

## Criteria and evidence

| Criterion | Implementation and verified evidence |
| --- | --- |
| Readable public phases, controls and text/color zones | Snapshot-only [FishingView](../../game/ui/fishing_view.gd), opaque panel, 22px title/16px instruction, labeled safe/warning/danger tension bands and landing percentage. Public E/Reel, Cancel/F/right-click and Esc help. Final actual rendered matrix: 960x640 and 1350x900, orthographic/perspective, daylight/night/rain, waiting/bite/fighting (36 frames). All panels fit; PNGs inspected. Separate actual WARNING76% and DANGER100% captures verified. |
| Pointer/keyboard input cannot strand held state, attack beneath UI or auto-hook | Actual viewport Reel press, release outside button, mixed E/pointer ownership in both release orders, repeated press, waiting early-reel, fresh recast, focus loss and F cancellation. Actual pointer Cancel in waiting/bite/fighting and automatic phase transitions in the rendered matrix. Buttons have no keyboard focus; panel owns pointer. UI75, session57 and lifecycle344 assertions pass. |
| Capture phases and every result with genuine provenance | Shared read-only capture observes real root mode/phase/token/outcome before and after four settling frames/post-draw. Root processing and automatic challenge/world time continue during captures; paused, frozen, modal, stale owner, wrong phase or expired bite are refused. Ten terminal frames: canceled, no_bite, early_reel, missed_hook, line_slack, line_snapped, exhausted, landed, capacity, stale_reward. Additional actual pre-cast capacity, dry-deck, audited no-area, rod-required and indoor-map rejection frames. No manufactured presentation snapshots. |
| Existing bag fish icons/names/counts/selection; honest help | Exact source bluegill/river_trout/golden_carp PNG copies and existing ForagingItemVisual lookup. Three actual B backpack frames show legal deterministic landed fish, selected names/icons/counts1/99. UI checks also inspect count2/99 and selection. Fish are not active tools; no drop/current gift-recipient promise. Rod description/footer/bag teach implemented F/click/E/Reel behavior. Inventory199/backpack148/People134 regressions pass. |
| Small anchored effects without physics/navigation; teardown | [FishingEffects](../../game/world/fishing_effects.gd) draws line, bobber and ripple at committed water point; BITE uses gold and restrained pulse. Unshaded cues remain visible at night/rain. UI checks verify waterY anchor and zero CollisionObject3D/NavigationRegion3D descendants. Root cancellation/teardown clears mesh and hides effects; focus, F, pointer Cancel, phase terminal and final actual Esc pause inspected. Existing lifecycle344 checks remain passing. |
| Observations/testing extend existing owners; no forcing commands | TestRunObservation returns detached fishing data; opt-in bridge adds bounded F and that read-only observation. No force-catch/RNG/time/reward command is accepted. Shared TestRunInteractionCapture and capture_evidence.py validate live fishing separately from paused evidence. Python positive/negative integrity/timing/provenance tests, testing_support64 and live_playtest checks pass. Existing testing_capture_render passes three actual pause/settings captures and actual GUI Save/Resume plus refusal cases. |
| Guarded native F and future FS008 paths preserve existing guards | F VK0x46 uses existing bounded dispatch/release path. Only FS008 run children and exact owned direct TEMP FS008 copies added; task match, canonical hashes, traversal/link restrictions retained. Native739 assertions (fault injection, release cleanup, ownership, bounds, Win32 compile, no OS input); FS00813 path/hash/junction guards; existing G0097 guards all pass. Native interop/foreground/PID ownership implementation and packages unchanged. |

## Scope and ownership

Root owns input/modes/service and passes detached snapshots to the view/effects.
Service only adds read-only zone thresholds and remembers actual idle entry-rejection
outcomes for correct result titles. No challenge rules, luck, target geometry,
reward authority, inventory/save shape, schema7/content1 or social/quest/party facts
changed. Footer/obsolete provisional fishing notice hide during active fishing;
existing world interaction help returns afterwards. Explicit instruction line wrapping
avoids a container zero-width/autowrap height cycle during live phase changes.
Pointer gui_input plus global release avoids BaseButton release loss during layout.

New production files: fishing view/effects and their UIDs; three copied icons and
Godot import settings. New verification: fishing_ui_checks/render and UIDs,
tools/fishing/native_guard_checks.ps1. Existing root/UI/icon/help, service snapshot,
shared fixture/observation/capture/bridge, inventory help assertion, guarded native
paths/commands/tests and testing guidance changed only for FS006. Full actual file
list is in [CURRENT_STATE](CURRENT_STATE.md). User prompt/contract, pinned maps,
collision/navigation, independent delivery scripts/packages and normal saves preserved.

Source PNG identities (also verified against frozen source manifest):

| Source / copied filename | SHA256 |
| --- | --- |
| bluegill.png | cff56f8d6edb842828750593309b80b5e908d4fa192f111dc887e572af89a45d |
| river_trout.png | 2ef86aa5f619faf7b1f7756eb4f3565639d62ff465e8c48d754442dc3a414216 |
| golden_carp.png | 1fa3a6f3af7f4e564652be721a0fdbfd550688966186a902aaf67d5d1363cf65 |

Source `D:/development/game-prototype-2` is read-only, HEAD
`60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean. Live reference audit143 assertions
passes before/after; all18 pins unchanged. Pinned target layout SHA256
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be` unchanged.
Runtime assets are target-local; no Flutter/source-checkout dependency introduced.

## Commands, reports and isolation

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7.
Supplied console/editor paths verified; installed engine
`4.7.2.stable.mono.official.ed1daf0bf`. Applicable workspace AGENTS, fishing
prompt/checklist/handoff/contract, architecture, FS005 acceptance, current root/UI/
native APIs, caveman skill and project-owned gameplay-testing skill/references/
PLAYTEST read. No nested AGENTS or .agents directory found; no other conversation,
agent, chat or schedule used.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/fishing/reference_audit.py --source-root D:/development/game-prototype-2
./tools/run_checks.ps1 -Task FS006 -Names fishing_ui_checks,fishing_session_checks,fishing_reward_checks,fishing_lifecycle_checks,backpack_ui_checks,testing_support_checks,live_playtest_checks,inventory_checks,people_journal_checks,environment_lifecycle_checks,application_smoke -RenderScript fishing_ui_render -RenderPhases check -ParseScripts tests/environment_review,tests/live_playtest_bridge -TimeoutSeconds 180
./tools/run_checks.ps1 -Task FS006 -RenderOnly -RenderScript testing_capture_render -RenderPhases check -ParseScripts tests/environment_review,tests/live_playtest_bridge -TimeoutSeconds 120
./tools/run_checks.ps1 -Task FS006 -Names fishing_ui_checks -RenderScript fishing_ui_render -RenderPhases check -ParseScripts tests/environment_review,tests/live_playtest_bridge -TimeoutSeconds 120
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/tests/capture_evidence_checks.py
./tools/tests/native_input_checks.ps1 -EvidenceTask FS006
./tools/fishing/native_guard_checks.ps1
./tools/social_migration/native_guard_checks.ps1
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/FS006/20261009-050532433-270cde49/render/fishing-ui-render-index.json
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/FS006/20261009-050439596-ea61d5d0/render/check-index.json
git -c core.whitespace=cr-at-eol diff --check
```

Accepted reports under ignored local `docs/evidence/`:

- Broad regressions `FS006/20261009-050233710-b5e072de/results.json`: all14 cases
  PASS/exit0; UI75/session57/reward72/lifecycle344/bag148/support64/inventory199/
  People134/environment157, bridge/startup and renderer pass. Stable1025-file
  digest `3a3f2a1951bcd325b0bcd85a6a05b0d9f80b340e58f648ddbffea49b307c6992`.
  Eleven independent check save groups plus one render group.
- Shared capture regression `FS006/20261009-050439596-ea61d5d0/results.json`:
  all3 cases PASS, same source digest; one rendered save group; three inspected PNGs.
- Final UI/render `FS006/20261009-050532433-270cde49/results.json`: all4 cases
  PASS, UI75/render225; two isolated groups. Only intervening source change from
  broad/shared runs is the render fixture's warning-duration correction and two
  explicit zone assertions. Final1025-file digest
  `4682338c71cd307fc52812f4414b34e83652e0101a6bc544c6bf45b9d55c19d0`.
- Final capture review `FS006/20261009-050532433-270cde49/render/derived/20261009-050629-57e86118/capture-report.json`:
  all57 provenance/integrity checks pass, five contact sheets inspected; selected
  full-size night BITE, rain fight, warning, rod-required and golden-carp bag inspected.
  Shared regression review: `FS006/20261009-050439596-ea61d5d0/render/derived/20261009-050534-951e88be/capture-report.json`.
- Native input739: `FS006/native-guards-107c03f1e523456aa18c670b418173dd` refusal
  traces; FS00813: `FS006/native-guards-7bf5f6e8dd8243a7a8bb9428cc795773/results.json`;
  preserved G0097: `G009/guards-15d30ebe19af464e98e5f079d40c77be/results.json`.

All accepted runners have source.changed=false/error=null, no runtime/parse
diagnostics/timeouts, owned processes exited. First import retained its known
SDK10.0.9 advisory; no installation needed. Sandbox engine launch needed scoped
escalation, approved without rejection. Early import/fixture failures remain local
and excluded; corrections documented in handoff. No editing game/tools during
accepted cases. Named slots/app-data live beneath matching builds/testing/FS006
run IDs; normal saves preserved. Native fake copies were verified direct TEMP
children and removed with native PowerShell; no OS input or release package modified.

## Limits and continuation

Synthetic legal rod pickup/pose/RNG/weather/capacity/trajectory fixtures establish
UI and rule integration. Actual automatic waiting->bite and pointer hook/Cancel,
backpack input and GUI Resume run through production paths. Active captures never
freeze time; the late1.19s bite refusal proves settling cannot relabel expiration.
This is not ordinary unforced catch, independent fishing restart or native delivery
proof; those remain FS007/FS008 as assigned. No FS006 criterion remains unrun or
blocked. Next eligible FS007; unfinished FS007, FS008; not every item through FS008
is complete. No process/editor/input or cleanup owed. Stop; commit requires the
user's separate instruction.
