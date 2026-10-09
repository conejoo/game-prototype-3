# Fishing migration execution checklist

Goal: select the existing rod, cast into eligible water, play a bite/tension challenge,
and land bluegill, river trout or golden carp into the existing persistent backpack.
Target repository: `D:/development/game-dev-blender/returning-fair-prototype`.
Application: `game/`. Read-only source: `D:/development/game-prototype-2`.
This file owns task status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation;
[CONTRACT](CONTRACT.md) owns behavior and source mappings;
[AGENT_PROMPT](AGENT_PROMPT.md) selects this workflow.

Planning complete on 2026-10-08, America/Vancouver. FS001 Done on 2026-10-09 UTC;
FS002-FS008 Pending. Next eligible FS002. Final task FS008; checklist incomplete.

## Selection and evidence

- Resume the single In progress task first. Reassess a Blocked task if its recorded
  blocker changed. Otherwise choose the lowest-numbered Pending task with verified
  Done prerequisites. An unresolved blocker excludes its dependents, not independent branches.
- Verify prerequisite capability and durable acceptance, not checkboxes alone.
  Missing historical raw captures are not automatically blockers; use current artifacts
  and proportionate fresh verification. Record conflicts instead of inventing completion.
- Complete exactly one task per invocation; mark In progress before implementation.
  Update CURRENT_STATE after incomplete sessions too. Done requires every criterion.
  No automatic agents, schedules, implementation of successors, commits or publication.
- FS003 and FS004 are independent after FS002. Default order still selects FS003
  first; if its blocker is unresolved, FS004 can proceed. This is a dependency graph,
  not authorization to launch parallel agents or race shared files.
- Preserve current user work and independent workflows, especially G009 delivery.
  Final package promotion has an explicit external coordination gate in FS008.
- Existing test scripts listed below were found during planning. Every new
  `fishing_*.gd`, fishing tool or reference artifact below is a proposed deliverable,
  not an available command until its owning task creates it.

## Task status

| ID | Status | Dependencies | Observable outcome |
| --- | --- | --- | --- |
| FS001 | Done | Current F010 item capability and pinned map available | Frozen source rules, area mappings and usable cast-site audit |
| FS002 | Pending | FS001 | Three fish definitions, strict activity resolver and inventory/save support |
| FS003 | Pending | FS002 | Deterministic bite, hook and tension challenge |
| FS004 | Pending | FS002 | Correct 3D water targeting and cast preview |
| FS005 | Pending | FS003, FS004 | Root-owned fishing lifecycle with exactly-once rewards |
| FS006 | Pending | FS005 | Readable public controls, HUD, fish icons and cast/bite feedback |
| FS007 | Pending | FS006 | Integrated ordinary play, cancellation and independent-process persistence |
| FS008 | Pending | FS007; completed/stable independent native-delivery baseline | Fresh Windows packages and ordinary native fishing/restart proof |

## FS001 — Freeze references and map-safe casting requirements

- **Inputs/prerequisites:** CONTRACT source inventory and hashes; actual rod,
  backpack, schema and root APIs; F010 acceptance; current layout and map contract.
  Recheck current Git changes and social delivery state before selecting files.
- **Outputs/allowed scope:** proposed `tools/fishing/reference/` manifest, minimal
  target-local source excerpts, executable behavior vectors, reference auditor;
  proposed `game/tests/fishing_reference_checks.gd`; FS001 acceptance summary.
  Measure current water/deck geometry through isolated checks. No production activation.
- **Acceptance:** pin current source bytes and exact fish/area/timing rules; distinguish
  live source drift from pinned Godot geography. Verify all three area shapes,
  weights, profiles and source-to-Godot transforms. Audit ordinary dry approaches and
  in-range open-water targets for each area, including an overlap and golden-carp
  coverage; classify bridge/deck, shoreline, cliff, out-of-map and no-area negatives.
  Specify boundary and occlusion rules, water height, RNG input semantics and cancel rules.
  Preserve layout hash and existing blockers. Record a genuine unreachable-site
  conflict as Blocked; do not move banks, enlarge range or remove collision to hide it.
- **Verification:** read/hash/source audit and reference vectors; isolated proposed
  fishing_reference_checks plus existing reference_mapping_checks, map_water_checks
  and map_crossing_checks as relevant. Synthetic geometry probes are not ordinary
  walking proof. No Flutter suites, minigame, reward or save-schema change.

## FS002 — Fish content, catch areas and atomic backpack compatibility

- **Inputs:** FS001 frozen references and vectors; current ContentCatalog,
  ItemDefinition, InventoryState, ForagingSaveData, SaveCodec and source activity resolver.
- **Outputs/allowed scope:** extend item category validation for fish; register three
  immutable fish item definitions and typed challenge/rod-activation metadata;
  target-local fishing area adapter and pure weighted resolver. Proposed
  `fishing_content_checks.gd` and `fishing_activity_checks.gd`. New filenames and
  class ownership must follow actual current architecture, not a parallel catalog.
- **Acceptance:** exact IDs/caps and difficulty data from CONTRACT; fish can be
  inspected/selected but are not active tools or movable rod pickups. Validate shapes,
  IDs, finite probabilities, weights and duplicate/unknown definitions before catalog
  publication. Blend overlapping profiles, sort outcome IDs and preserve miss probability;
  no-area is distinct from miss. No reward is granted by the resolver.
  Existing inventory adds/consumes and strict save decode accept legitimate fish
  counts/selection, reject malformed or excessive counts, and preserve rod conservation
  and every social/environment/quest fact. Same schema7/content1 is the default
  because only recognized inventory IDs expand; if actual shape changes are necessary,
  document and test a replacement current format with no legacy migration.
- **Verification:** proposed content/activity suites with exact interval/boundary and
  overlap vectors; existing inventory_checks, content_catalog_checks,
  foraging_save_checks and social_save_checks. Include detached snapshot/failed
  operation and full-bag/existing-stack-at-cap cases. No world fishing input yet.

## FS003 — Deterministic fishing challenge rules

- **Inputs:** FS002 fish metadata and FS001 source challenge/vectors.
- **Outputs/allowed scope:** pure transient challenge state/controller and structured
  snapshots/results under proposed `game/features/fishing/`;
  proposed `fishing_challenge_checks.gd`. No scene, save or inventory authority.
- **Acceptance:** waiting -> bite -> fighting -> terminal result/cancel; 1.5-3s wait,
  species hook windows/fight limits, hold/release tension and source difficulty curves.
  Fresh reel press required to hook; early reel, missed hook, slack, snap and timeout
  have distinct outcomes. Danger timer resets when tension returns to safety.
  A resolved/canceled attempt cannot resolve again. Reject invalid inputs.
  Use bounded deterministic simulation increments with elapsed-time carry across phase
  boundaries; test differing frame partitions/hitches against stated tolerances and
  single reward eligibility. Do not copy source frame-boundary time loss blindly.
- **Verification:** proposed challenge suite proves all three species can land,
  every failure, exact boundaries and cancellation/restart; no actual-player claim.
  Existing inventory/content tests only if touched. Root integration remains FS005.

## FS004 — 3D water target resolution and preview

- **Inputs:** FS002 rod/area data, FS001 geometry evidence, current camera ray APIs,
  pinned terrain/water/deck data and UI pointer ownership.
- **Outputs/allowed scope:** proposed water-target resolver plus transient preview
  presenter; `fishing_targeting_checks.gd` and `fishing_targeting_render.gd`.
  Any camera helper change must preserve existing ground aiming. No active rewards.
- **Acceptance:** map-anchored 0.5m cells, cell-center XZ range <=12m; open-water
  selection under orthographic/perspective and supported zoom. Elevation and water
  surface resolve correctly without using shader color or treating underlying base
  floor as fishable terrain. Reject dry decks/bridges, solid occlusion, dry land,
  invalid rays, out-of-bounds/range, indoor maps and UI-covered pointers. Water safety
  blockers do not themselves make every cast impossible. Preview reports eligibility
  and no-area feedback distinctly, follows current player position and revalidates
  on cast. Never bake navigation or alter movement collision for targeting.
- **Verification:** proposed rules/render suites inspect actual preview captures across
  camera modes, dry structures, banks and area overlap. Existing map_camera_checks,
  movement_camera_checks and map_water_checks if affected. Synthetic pointer/pose
  setups remain labeled; input activation is owned by FS005.

## FS005 — Fishing orchestration, input ownership and reward commit

- **Inputs:** FS003 and FS004 accepted outputs; current root input/lifecycle,
  inventory revision/commands, party/combat, world replacement and manual save boundaries.
- **Outputs/allowed scope:** focused transient fishing service owned by GameRoot,
  F targeting/cancel action, E reel routing, cast dispatch and inventory reward path;
  honest provisional phase/outcome feedback. Proposed `fishing_session_checks.gd`,
  `fishing_reward_checks.gd` and `fishing_lifecycle_checks.gd`.
- **Acceptance:** owned selected rod required; one active attempt; validate target,
  area roll and selected species capacity before starting. No-area returns immediately;
  miss has the normal wait. Casting consumes no rod/item.
  During attempts clear/block hero movement, attack/dodge and world interactions,
  item drag/backpack/travel/load; preserve active world clock/weather. Cancel safely
  on focus loss, pause/modal transition, room/session replacement, retry/death,
  combat engagement, rod/capability invalidation or explicit cancellation.
  Fresh inputs required after exit. CONTRACT defines Esc/F/right-click behavior.
  Only one verified landed token can add +1 fish to the bound current session;
  revalidate rod, map, capacity and token immediately before commit. Replay, stale
  callback/reentrant command, capacity loss and malformed result change no facts.
  Publish success only after commit; no fishing-only autosave or durable attempt timer.
- **Verification:** proposed session/reward/lifecycle suites through actual root plus
  isolated negative fixtures; existing inventory, foraging_transaction, backpack_ui,
  combat, companion, interaction_dialogue, location_travel, social_transaction and
  environment_lifecycle checks where affected. Test cancel in every phase, failed
  transition rollback, save while canceled and load without resurrected attempts.
  This task owns correctness; FS007 is integration proof, not deferred basic testing.

## FS006 — Public HUD, visual feedback and testing access

- **Inputs:** FS005 working lifecycle and snapshots; source HUD/icon assets;
  current PrototypeUI/BackpackView/ForagingItemVisual and guarded test helpers.
- **Outputs/allowed scope:** focused fishing view with labeled phase, bite prompt,
  tension safe/warning/danger zones, landing progress, E and pointer reel controls,
  Cancel and clear failure/capacity feedback; source-derived fish icons and small
  nonblocking line/bobber/cast/bite effects. Proposed `fishing_ui_checks.gd` and
  `fishing_ui_render.gd`; update rod/backpack help only after functionality exists.
- **Acceptance:** readable at960x640 and one larger viewport, daylight/night/rain,
  both camera projections; information is conveyed by text as well as color.
  Pointer/keyboard reel sources cannot leave held state stuck, trigger world attack
  or hook automatically across phases. Capture waiting/bite/fight and every result
  with genuine state provenance. Fish icons/names/counts/selection work in existing
  bag, no false tool/drop/gift promise. Effects remain anchored at water, no physics
  or navigation changes. Hide/cancel all effects on teardown.
  Read-only fishing observations may extend existing bridge/capture helpers; no
  production force-catch/RNG/time/reward command or debug acceptance shortcut.
  Add guarded native F support and FS008 evidence routing with negative tests,
  preserving concurrent G009 paths, bounds, foreground/ownership and release cleanup.
- **Verification:** proposed UI/render suites with inspected PNGs; existing
  backpack_ui_checks, testing_support_checks, testing_capture_render and native input
  guard checks if changed. Deterministic species/phase setup is labeled synthetic.
  No new character rig/animation production, mobile flow or art editor needed.

## FS007 — Integrated fishing, persistence and existing-game regression

- **Inputs:** FS006 complete controls; current testing journey/gui/capture/snapshot
  owners; FS001 site audit; current social/NPC/weather/quest acceptance.
- **Outputs/allowed scope:** proposed `fishing_integration_checks.gd`,
  `fishing_integrated_render.gd`, `fishing_process_checks.gd`;
  durable FS007 acceptance; necessary bounded fixes only.
- **Acceptance:** fresh ordinary movement picks up rod, opens B, selects rod, walks
  to audited dry cast sites, uses F/world click and visible reel controls to land fish.
  Observe all three catch areas and their overlap without teleporting.
  Prove all three species through deterministic integration cases labeled as such;
  additionally demonstrate at least one normal unforced-RNG catch through ordinary
  gameplay. Bounded unsuccessful runs retain evidence and task stays incomplete.
  Show invalid casts, early/missed hook, canceled fight, safe immediate recast,
  capacity failure and rod drop/retrieve after cancel; negatives may use labeled fixtures.
  Actual GUI Save, normal quit, independent-process startup/GUI Load restore exact
  typed fish counts/selection and all unchanged durable facts; no attempt resumes.
  Travel/revisit preserves catch and does not duplicate it. Failed save keeps the
  previous slot valid and never issues another reward.
  Recheck affected shortened recovery/combat/ally, eight villagers/gifts/People,
  flowers, lamps/weather, terrain/crossings and modal focus.
- **Verification:** proposed suites, process writer/reader and inspected rendered
  journeys using existing helpers; selected existing regressions from CONTRACT.
  Record exact stable restart oracle before resumed monotonic-time assertions.
  Source/tool changes during a runner case invalidate that run. No native-release
  claim or publication; final executable evidence belongs to FS008.

## FS008 — Fresh Windows release and native acceptance

- **Inputs/prerequisites:** FS007 evidence; actual export presets/templates and
  current source fingerprint. G009 must be Done with verified current capability,
  or a separately authorized stable delivery baseline must resolve its overlap.
  No fishing code dependency on G009; this gate prevents racing shared native tools
  and replacing independent in-progress package outputs.
- **Outputs/allowed scope:** proposed `tools/fishing/` package audit/build/native
  drivers using existing guarded helpers, fresh isolated staging under
  `builds/fishing/FS008/<run-id>/`, acceptance and readiness updates.
  Preserve current packages/override before safe local promotion; never delete archives.
- **Acceptance:** rebuild Windows Desktop and Windows Validation from final source;
  audit packed fish definitions/icons/area data and live item/save state; correct
  export exclusions and no Flutter/source-checkout/reference-audit dependency.
  Start exe+pck outside checkout. Actual native fresh rod/select/cast/reel lands
  >=1 unforced fish, visibly appears in bag; cancel/recast, then GUI Save/quit and
  independent native process GUI Load/revisit preserve exact fish and baseline facts.
  Distinct PIDs, package hashes, clean runtime diagnostics and normal exits recorded.
  All-three-species correctness comes from earlier deterministic rule/integration
  proof; do not claim three native catches unless observed. Native automation must
  react to rendered HUD within bite/tension timing, preserve bounded input/release,
  and verify pause before reasoning. If supported timing/input tooling cannot
  complete this, record exact human/native gate and leave task incomplete.
  Debug bridge, forced RNG, fixed poses and package startup cannot substitute.
- **Verification:** exports/audit, focused final regressions and ordinary native
  traces/captures plus exact separate-process save oracle. No installation, push,
  publication or historical checklist reclassification. Stop; workflow has no successor.

## Completion records

Append only for verified Done work:

```text
Task/date/status:
Starting source/repository identity and preserved user changes:
Outcome, changed files and compatibility decisions:
Commands/cwd/isolation and actual results:
Durable acceptance and inspected evidence:
Remaining limits and next eligible task:
```

### FS001 / 2026-10-09 UTC / Done

Entry/final HEAD `210c2b7a38600a1c9c144e4b773c89a5c1be8ad8`; only existing
user-authored `docs/fishing/` untracked at entry. Original agent instructions,
production, source checkout, other workflows/packages and normal saves preserved.
Frozen18 source hashes/three transformed area profiles/exact species/timing rules,
executable weighted/boundary vectors and four physically supported casting sites.
Source-map drift documented without geography refresh. Water Y=.015, safety bodies
Y[-.2,3], closed area versus half-open map/deck semantics and safe occlusion policy
recorded. Sunken Reeds necessarily overlaps dock/channel; golden coverage verified.

[FS001 acceptance](FS001_ACCEPTANCE.md) maps every criterion, files, commands and
limits. Offline/live audits120/143 assertions PASS. Final isolated runner
`20261009-025540499-ca65b02a`: all nine import/parse/reference/inventory/mapping/water/
crossing/render cases PASS; reference134/render108 assertions, four fresh ordinary
WASD journeys and six inspected captures. Source unchanged across969 files, no
runtime diagnostics/timeouts; known import-only SDK advisory retained. Failed
fixture/preflight/first-UID-import runs retained and excluded from acceptance.
No active process or cleanup owed; no commit/push. FS001 blockers none.
Next FS002; remaining FS002-FS008, whole checklist incomplete. Stop before successor.
