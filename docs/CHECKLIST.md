# Sequential prototype development checklist

Read ARCHITECTURE.md and CURRENT_STATE.md before selecting work. Use
AGENT_PROMPT.md to start each implementation session. Work on one eligible item
per session. A task may span sessions; keep it in progress until its acceptance
criteria actually pass. Do not begin the next task merely because time ran out.

Status legend: `[ ]` pending, `[-]` in progress, `[x]` verified complete.
Every task depends on the preceding task. Fix a prerequisite regression before
continuing. Each completion updates CURRENT_STATE.md with concrete evidence,
changed files, known limitations, and the next eligible task.

P001–P011 verified complete; P012 next eligible. Subsequent tasks remain pending.

## [x] P001 — Runnable project and application root

- Create `../game/project.godot` using installed Godot 4.7.2 and typed GDScript.
- Create persistent GameRoot with WorldHost, Party, CameraRig, and UI entry
  points; add only the session scaffolding needed to launch.
- Configure input actions, pause/quit, a simple test scene, and README commands.
- Inspect Git context; use a dedicated repository here if no suitable repository
  already owns it. Add appropriate ignores. No remote push is needed.
- Acceptance: headless editor import succeeds; interactive game opens, pauses,
  resumes, and quits without script errors. Record actual engine version.

## [x] P002 — Definition catalog and runtime-state ownership

- Add stable-ID definitions for locations, actors, and the minimal prototype
  content. Keep authored Resources separate from mutable actor/session state.
- Implement explicit service initialization and content validation.
- Reuse Maris's `npc-03` identity. Label temporary companion and dialogue as
  prototype fixtures. Read relevant source canon before importing named facts.
- Acceptance: duplicate IDs, absent references, and malformed definitions fail
  with useful errors; two instances do not share mutable health/progress.

## [x] P003 — Hero movement and overhead camera

- Implement CharacterBody3D movement, facing, collision, InputMap controls,
  camera-relative movement, and independent visual root.
- Compare orthographic and mild perspective using the same primitive room.
- Support modest zoom and prevent movement input leaking through pause/UI.
- Acceptance: wall/corner collisions work; camera and aiming agree; chosen
  projection and provisional controls are recorded with playable evidence.

## [x] P004 — Connected locations and party lifecycle

- Add compact Alderwake and Tollworks grayboxes with stable spawn anchors.
- WorldHost transitions locations while keeping session/party ownership clear.
- Explicitly suspend actors/input during unload/load, reset navigation, then
  place the party safely. Add guards against repeated transition requests.
- Acceptance: repeated round trips work without duplicate actors, lost session
  state, invalid spawns, stale references, or input during transitions.

## [x] P005 — Versioned save/load foundation

- Implement plain-data snapshot, validation, checked temporary-file write,
  backup recovery, and `user://` storage. Define stable save boundaries.
- Initially persist player/location/party state; extend schema deliberately as
  later systems arrive. Record content/save version compatibility rules.
- Acceptance: close/reopen returns to the right location; malformed and newer
  saves do not overwrite the live session or a good save; recovery is tested.

## [x] P006 — Reusable interaction and dialogue

- Add interaction selection, prompt, input arbitration, and reusable NPC/prop
  interactions. Author dialogue independently from physical actor scenes.
- Implement dialogue choices and explicit action results. Text/UI never owns
  persistent quest or reward state.
- Acceptance: talk to NPC and inspect prop in either room; dialogue blocks
  attacks/movement as intended; cancellation restores control; no stuck UI.

## [x] P007 — Quest progression, journal, and durable effects

- Implement one shortened recovery quest definition and quest service with
  prerequisites, legal transitions, stable action/effect IDs, and journal.
- Validate a recovery sequence: lead, expedition objective, vessel recovery,
  return and reconnection. Reserve combat objective for P008.
- Extend save schema for quest progress/completed effects with compatibility
  handling. Use explicit test setup for any temporarily simulated objective.
- Acceptance: illegal/out-of-order actions fail; repeated completion grants
  effects once; quest progress survives room travel and process restart.

## [x] P008 — Hero action combat and guardian

- Implement attack, dodge, health, damage/attack windows, one guardian behavior,
  defeat/retry flow, and clear hit/death feedback.
- Drive combat through shared actor APIs. Keep damage rules independent of UI
  and model names. Persist guardian instance facts where required by the quest.
- Replace simulated quest combat objective with actual guardian defeat.
- Acceptance: defeat guardian in normal play; one swing does not hit the same
  target repeatedly by accident; death/retry cannot duplicate quest rewards.

## [x] P009 — One active companion

- Add follow, fight, return, navigation recovery, and safe catch-up behavior.
- Companion uses the existing actor movement/combat components. Spawn and
  transition lifecycle integrates with WorldHost and Party.
- Establish incapacitation/recovery rule suitable for prototype; persist only
  required durable companion state.
- Acceptance: companion follows through both rooms and around obstacles,
  assists combat, recovers from a stuck route, and survives save/load/transition.

## [x] P010 — Relationship consequence and character upgrade

- Add one authored dialogue choice with recorded companion reaction and trust
  change. Keep reactions separate from romance and avoid canon invention.
- Add one earned, selectable upgrade whose effect is observable in combat.
- Extend persistence/validation for trust, reaction IDs, and progression.
- Acceptance: choice and upgrade matter in play and persist; replay/reload
  cannot repeat trust changes or spend the same upgrade point twice.

## [x] P011 — Recovery and persistent world presentation

- Implement Maris's return/reconnection scene and practical restored-service
  presentation. Derive variants from authoritative quest/world facts.
- Add camera occluder handling where prototype layout actually needs it.
- Acceptance: recovery changes the correct shop state after reconnection;
  leaving/reloading preserves the result; unrecovered saves show original state.

## [ ] P012 — Reusable Blender asset pipeline

- Read applicable Blender skills; inspect live connection/scene and preserve
  unrelated work. Create isolated prototype source files/collection.
- Export recovery vessel, guardian, and one modular Tollworks prop as GLB.
- Record scale/origin/forward/material/export contracts. Replace visuals inside
  existing gameplay wrappers; keep collision/navigation in Godot.
- Acceptance: inspect assets in Godot; re-export one asset and prove scripts,
  IDs, interactions, collision, and quest progress remain correct. Save .blend
  sources and record import/render evidence. Missing live connection leaves
  this item incomplete, with exact blocker and runnable placeholders retained.

## [ ] P013 — Complete playable recovery slice

- Connect normal start, lead, companion, expedition, guardian, recovery,
  reconnection, trust reaction, upgrade, and visible town result.
- Remove temporary setup paths from normal play; retain labeled developer tools.
- Provide understandable prompts/objectives and a deliberate save/load flow.
- Acceptance: complete full slice without inspector/debug setup; repeat after
  save/restart at supported boundaries. Record remaining deviations from canon.

## [ ] P014 — Extension check and Windows export

- Add a small test-only second quest/actor-definition variant to demonstrate
  content extension without changing first quest/session rules.
- Run targeted headless checks and manual walkthrough; resolve material errors.
- Export Windows build with compatible Godot templates. Use installed paths
  before searching for tools; document any missing external prerequisite.
- Acceptance: exported executable completes slice and reloads progress outside
  editor. Record build path, tested machine/context, performance observations,
  and limitations. No completion claim based only on editor/headless execution.

## Completion record template

For each completed item, append a brief entry below:

```text
Pxxx — completed YYYY-MM-DD
Changed:
Checks and evidence:
Known limitations:
Architecture/content decisions:
Next eligible task:
```

### P001 — completed 2026-10-01

- Changed: local Git repository/ignores, README commands, typed GDScript root/
  session, WorldHost/Party entry points, supplied camera target, test room,
  input actions, HUD/pause/resume/quit, focused smoke; scene/script UIDs kept.
- Checks/evidence: engine `4.7.2.stable.mono.official.ed1daf0bf`; headless editor
  import exit 0; smoke PASS exit 0; actual Windows game opens, pauses/freezes,
  resumes, F10 quits while paused, exit 0, no runtime script errors. Buttons
  inspected too. Commands/logs/screenshots: `evidence/P001/VALIDATION.md`.
- Limits: Mono editor reports missing C# SDK 10.0.9; GDScript import completes
  and runtime/smoke clean. Hero stationary; room/camera/visuals provisional.
  No Blender work or Windows export.
- Decisions: root/UI process during pause; world/party/camera stop; session
  owns time, UI submits commands. Logical Esc/F10 repaired after real input
  check; physical WASD reserved for movement. No architecture/canon changes.
- Next eligible task: P002 — Definition catalog and runtime-state ownership.

### P002 — completed 2026-10-01

- Changed: typed actor/location/dialogue definitions and five authored fixtures,
  explicit manifest/catalog validation, separate per-instance ActorState/session
  progress, root initialization and wrapper injection, focused checks and README.
- Checks/evidence: Godot `4.7.2.stable.mono.official.ed1daf0bf`; import exit 0,
  catalog rejection/isolation checks PASS exit 0; root composition/input/pause
  smoke PASS exit 0; malformed-catalog application abort expected exit 1 with
  useful errors; real Windows main-scene startup exit 0; `git diff --check` exit 0.
  Exact commands/logs and acceptance mapping: `evidence/P002/VALIDATION.md`.
- Limits: source reference checkout empty (only .git, no commits); no additional
  canon facts imported. Maris uses user-supplied `npc-03` identity; health remains
  fixture data. Companion/dialogue catalog-only and explicitly noncanonical.
  Spawn IDs are metadata until P004. No new visual/gameplay/export claim.
  Existing missing C# SDK warning does not block GDScript checks.
- Decisions/repair: authored resources immutable by contract; mutable health/
  progress never stored in definitions. Negative fixtures explicitly copy each
  external definition after manifest-only deep copy proved insufficient.
  No architecture change; existing P001 commit and source preserved.
- Next eligible task: P003 — Hero movement and overhead camera.

### P003 — completed 2026-10-02

- Changed: physical hero/independent VisualRoot, collidable walls/plinth,
  camera-relative WASD/mouse facing, overhead follow, projection comparison/zoom,
  pause/UI/focus input clearing; focused checks and opt-in local live playtest tools.
- Checks/evidence: import exit 0 (no GDScript errors); P001 smoke, P002 catalog,
  P003 movement/camera and bridge checks PASS/exit 0. Actual Windows renderer
  inspected via viewport captures; timed normal input reached all walls, both
  corners, escaped and contacted plinth. Pause/held-key/UI focus/zoom checks pass;
  normal quit exit 0. User also confirmed normal keyboard walking/collision.
  Exact commands, JSON responses and screenshots: `evidence/P003/VALIDATION.md`.
- Decisions/repairs: provisional orthographic chosen from same-room comparison;
  logical WASD, mouse facing, P and wheel/+/- comparison controls. Minimum wall
  slide angle zero fixes shallow-angle sticking; monotonic harness timing avoids
  short holds after capture stalls. Definitions/session ownership unchanged.
- Limits: test input is injected into normal Godot viewport paths, not OS hardware.
  Initial desktop lock/automation key-tap limits resolved for acceptance using
  user manual evidence plus explicitly authorized rendered playtest harness.
  Existing missing C# SDK warning remains; no Blender assets or Windows export.
- Next eligible task: P004 — Connected locations and party lifecycle. Not started.

### P004 — completed 2026-10-02

- Changed: compact Alderwake/Tollworks grayboxes, stable spawn anchors, nearby E
  travel, persistent Party wrappers, WorldHost validate/suspend/load/place/resume
  with physics/navigation synchronization, request lock and unsafe-spawn rollback.
  Prior test room retained; earlier tests now await loader and select their fixture.
- Checks/evidence: editor import exit0; P001/P002/P003 regressions, live bridge and
  P004 lifecycle checks PASS/exit0. Ten headless round trips preserve actor/state,
  health/time, valid arrivals and camera; invalid IDs/anchors/gates/floor/obstruction
  reject safely; pause/focus/reentry input locked. Actual Windows normal viewport
  WASD/E travel: four round trips plus final one after sign repair; captures
  inspected, held keys clear, paused E blocked, normal F10 quit exit0 twice.
  Exact commands/logs/JSON/screenshots: `evidence/P004/VALIDATION.md`.
- Decisions/repair: candidate scene logic suspended while collision remains active
  for spawn queries (disabling whole scene removed its physics bodies). Party stays
  persistent; session location/spawn commit after placement only. Navigation map
  refreshed; no agents/path cache exists until P009. Existing architecture retained.
- Limits: prototype rooms/gates shorten geography; no new permanent story facts,
  companions, saves, Blender assets or Windows export. Rendered input is injected
  into normal gameplay paths, not hardware. Existing unused C# SDK warning remains.
  P003 local commit `77aed4b` preserved; no source edits/push/publication.
- Next eligible task: P005 — Versioned save/load foundation. Not started.

### P005 — completed 2026-10-02

- Changed: schema/content-v1 plain-data codec, isolated candidate validation,
  checked user:// temporary writes/backup publication/recovery, explicit ordered
  hero party IDs, pause-menu Save/Load, safe root restore after physical placement,
  focused filesystem/lifecycle checks and two-process fixture. Script UIDs kept.
- Checks/evidence: editor import exit0 (existing unused Mono SDK warning only);
  all six focused checks PASS/exit0, separate writer/reader PASS/exit0. Invalid
  versions/IDs/types/health/size and corrupt files reject; failed staging preserves
  files; backup recovery and unsafe-spawn rollback pass. Actual Windows normal
  WASD/E travel, GUI Save, F10 close, new process mouse/keyboard Load restore exact
  time/location/health/party/anchor; Resume movement/focus passes, three exits0.
  Commands, logs, raw responses and inspected PNGs: `evidence/P005/VALIDATION.md`.
- Repairs/decisions: Resume releases any pause-menu focus; completed paused load
  refreshes travel prompt. Saves resume last arrival anchor, no autosave. Strict
  v1 compatibility documented; P007 must migrate before extending schema. Backup
  read does not rewrite primary; newer versions never silently downgrade.
- Limits: one hero, no arbitrary-position/mid-action saves, active companion,
  combat/dialogue state, Blender work or Windows export. Disk-failure checks use
  staging obstructions, not physical power loss. User's normal save slot untouched;
  playtest slots isolated. Source/Git baseline preserved; no push/publication.
- Next eligible task: P006 — Reusable interaction and dialogue. Not started.

### P006 — completed 2026-10-02

- Changed: reusable NPC/prop/gate selection with range/LOS and stable instance
  IDs; authored dialogue choices, separate transient service and explicit action
  results; root modal input/save arbitration; GUI choice/Finish/Close/Esc, held-key
  clearing/focus release and unload cleanup. Both rooms contain labeled fixtures.
- Checks/evidence: import exit0 (existing unused Mono SDK warning); seven focused
  checks and separate save writer/reader PASS/exit0. Affected smoke/save/dialogue/
  bridge checks repeated after repairs PASS/exit0. Actual Windows renderer:
  normal WASD/E reaches NPC/prop in both rooms, four choices, blocked input,
  held-key cancellation/fresh movement, three close paths, travel and GUI save/
  load/replay pass. Five windowed runs quit0, including F10 during dialogue.
  Commands/logs/raw responses/inspected PNGs: evidence/P006/VALIDATION.md.
- Repairs/decisions: hide world prompt during modals, remove redundant clipping
  room labels, enlarge fixture signs. Playtest client publishes with native file
  rename; bridge checks open/read before consuming after one empty-read rejection.
  Dialogue actions only show prototype responses; no durable effects. Save schema/
  content remain v1. No general dialogue graph or new permanent narrative decision.
- Limits: attack/dodge still unimplemented; blocking verifies attack input, not
  damage. Temporary stand-ins have no companion AI. Source canon read-only and
  now populated; no Blender work/export/push/publication. Viewport input is injected,
  not hardware/OS-focus proof. Existing Mono SDK warning remains nonblocking.
- Next eligible task: P007 — Quest progression, journal, and durable effects.
  Not started; deliberately bump/migrate schema v1 before quest data.

### P007 — completed 2026-10-02

- Changed: ordered authored recovery steps, independent quest state/service,
  prerequisite/location/source validation, atomic once-only effects and journal;
  Maris/vessel dialogue commands and normal travel arrivals; schema2/content1 with
  exact v1 migration; root restore rebinding and modal input/focus/save boundaries.
- Checks/evidence: normal editor import exit0 (existing unused Mono SDK warning);
  eight focused scripts and both separate-process writer/reader pairs PASS/exit0.
  Affected checks repeated after repairs PASS/exit0. Actual Windows WASD/E/GUI lead,
  expedition, explicit TEST ONLY guardian setup, vessel/return/reconnection; journal
  locks/Tab focus, retries, GUI save/restart at vessel and completed state pass.
  Four windowed runs quit0; no-flag Tollworks has no test prop. Exact commands,
  logs, JSON and inspected PNGs: evidence/P007/VALIDATION.md. git diff --check exit0.
- Repairs/decisions: separate new props from existing P006 fixture reach; update
  fixed prop-count test, fix HUD spacing and contain modal Tab focus. Strict ordered
  prefix/effect-set validation; legacy read migrates candidate only, explicit Save
  publishes v2. Effects are durable facts, no new currency/reward-point abstraction.
- Limits: guardian simulated explicitly, not combat evidence; reconnection is a
  labeled text checkpoint, full return/shop variant P011. Normal play stops at
  guardian pending P008. No active companion/trust/upgrades/Blender/export claim.
  Viewport input is injected, not hardware/OS-focus proof; normal save/source untouched.
  Initial sandbox save IO denial resolved by normal-access rerun. No push/publication.
- Next eligible task: P008 — Hero action combat and guardian. Not started.

### P008 — completed 2026-10-02

- Changed: shared actor attack/dodge/damage APIs and transient CombatState windows,
  one-contact swing rules, range/facing/LOS, guardian pursuit/telegraph/strike,
  health/hit/death feedback and R retry. Actual guardian defeat replaces simulated
  quest source; existing durable clearance effect drives defeated room presentation.
  Combat/save/modal gates, input bridge observations, focused checks and docs added.
- Checks/evidence: final import exit0; nine focused scripts PASS/exit0; separate
  save writer/reader and repaired quest writer/reader PASS/exit0. Normal Windows
  WASD/E/GUI lead/travel, guardian death/R retry, four clicks kill100->0 in25-point
  steps; effects2->3 once. Dodge consumes strike without damage. Combat pause freezes
  and locks Save/Load while Resume works. GUI save/new-process load, room revisit
  preserve clearance; normal vessel advances4 and restarts correctly. Five windowed
  runs quit0; final death/retry run clean. Exact commands/logs/JSON/inspected PNGs:
  evidence/P008/VALIDATION.md.
- Repairs/decisions: lower LOS ray blocks low plinth; P006 fixture waits real swing
  recovery; process writer uses labeled physical-defeat setup instead of quest-only
  mutation. HUD overlap/layering fixed from captures; rollback retains guardian
  references/state. Cached freed-collider tracing guarded after final log scan;
  normal death/retry/fight and affected checks rerun clean. Schema2/content1 unchanged;
  quest/step/action/effect IDs preserved,
  stable actual source tollworks-guardian-01. Prior P007 clearance remains compatible.
- Limits: unfinished guardian health/actions reset on room reload; hero health
  persists, death retry heals after validated anchor placement and keeps quest facts.
  Timing/difficulty provisional; direct pursuit can be blocked. Viewport input is
  injected, new hardware bindings/OS focus not separately tested. Existing unused
  Mono SDK warning only; no companion AI/trust/upgrades/Blender/export claim.
  Normal save/source untouched; committed locally at user request. No push/publication
  or permanent canon added.
- Next eligible task: P009 — One active companion. Not started.

### P009 — completed 2026-10-02

- Changed: one session-owned temporary ally, persistent gameplay wrapper/shared
  actor APIs, follow/fight/return controller, collision-derived room navigation,
  safe stuck/separated catch-up and incapacitation/recovery; root travel/restore/
  modal/focus gates, guardian party targeting, both-member safe R retry, ally HUD.
  Schema3/content1 with strict two-member records and exact v1/v2 migrations.
- Checks/evidence: import exit0; ten focused scripts PASS/exit0 across first/final
  runs; separate save and quest writer/readers PASS/exit0. Physical barrier/down/
  recovery windowed fixture PASS/exit0, inspected PNGs. Normal Windows WASD/E/GUI
  follow/obstacle routes in both rooms without catch-up; autonomous ally damages
  guardian100->40, downed ally then recovers after normal victory/effects2->3 once.
  GUI Save/new-process Load restores hero50/ally100/two members/clearance3; post-load
  round trip/follow passes; final windowed quit exit0. Runtime error scan and Git
  diff check clean. Commands/logs/input trace/PNGs: evidence/P009/VALIDATION.md.
- Repairs/decisions: radius rounding and untyped array error fixed; ally status
  moved into footer after capture overlap. Updated previous fixtures for two-member
  state/current schema; isolated hero swing tests disable ally AI. Health persists,
  timers/routes reset; old saves add labeled ally at full health. No permanent canon
  choice, new reward fact, general AI abstraction, subagents or Blender work.
- Limits: runtime baking for tiny static rooms, safe catch-up outside combat only,
  provisional combat/art. Windowed barrier is explicitly synthetic recovery setup,
  not normal quest evidence. Initial input attempts failed timing/focus; real focus
  restored and normal gameplay repeated. Existing unused Mono SDK warning only.
  Normal save/source untouched; external P008 commit preserved; no commit/push/export.
- Next eligible task: P010 — Relationship consequence and character upgrade.
  Not started.

### P010 — completed 2026-10-02

- Changed: authored noncanonical +1/-1 companion decision/reactions, separate
  relationship/progression definitions/state/services, lead-earned preparation
  point and selectable Deliberate Strike (+15 hero damage), journal scroll/UI/HUD,
  root source/modal validation and restore rebinding; schema4/content1 with strict
  consequence validation and exact v1–v3 migration; script UIDs, docs and checks.
- Checks/evidence: prerequisite companion PASS/exit0; import exit0 (existing unused
  Mono SDK warning only); eleven focused scripts PASS/exit0; six separate writer/
  reader processes PASS/exit0; final affected six PASS/exit0. Normal Windows WASD/E/
  GUI +1 choice/replay, fresh -1 choice, lead-earned point, journal select25→40,
  guardian40→0 hero strike after ally assist, GUI save/process restart, alternate
  rejection, disabled spent button and room round trip preserve consequences.
  Three windowed quits exit0; runtime scans clean. Commands, 128 input traces,
  logs and inspected PNG/JSON: evidence/P010/VALIDATION.md. Git diff check exit0.
- Repairs/decisions: journal overflow fixed with bounded scroll; UTF-8 helper
  encoding/partial wiring fixed before final checks. Point derives from existing
  lead effect minus selected IDs; no new currency/duplicate reward counter.
  Trust records companionship response only, no romance gate/canon invention.
- Limits: first idle fight failed; continuous-input retry proves actual strike.
  Input injected through normal rendered viewport, no new hardware/OS-focus claim.
  Timing/art/training reward provisional; P011 shop presentation still pending.
  Normal save/source untouched; no subagents, Blender, commit/push/export.
- Next eligible task: P011 — Recovery and persistent world presentation. Not started.

### P011 — completed 2026-10-02

- Changed: MarisCounter wrapper with fixed collision/replaceable visuals and basic,
  returned/fitting, restored specialist variants from existing quest effects;
  labeled return/comparison/practical fitting scene, final once-only command and
  specialist preview. Root refreshes after quest change and successful restore/travel;
  two authored definitions, focused lifecycle/process checks, read-only bridge views.
- Checks/evidence: P010 prerequisite PASS0; both imports exit0 (existing unused Mono
  SDK10.0.9 error only). Nine focused scripts, separate writer/reader, final four
  affected checks PASS0. Five Windows rendered runs quit0: normal guardian/vessel,
  fitting cancel5/final6, service preview, GUI save/restart/load6, round trip6; separate
  GUI unrecovered save/restart/load0 retains original shop. 213 exact input traces,
  logs and inspected PNG/JSON: evidence/P011/VALIDATION.md. git diff --check exit0.
- Repairs/decisions: service board shortened/raised and depth test disabled after
  rendered bench clipping; final views verified. Low walls/counter keep actors clear,
  so no camera fade added. Existing schema4/content1 and durable IDs unchanged;
  no separate shop flag/economy. Temporary unnamed customer/helper remain fixtures.
- Limits: short dialogue-led reconnection, service availability/preview only; no
  purchase/inventory/full MQ03/cinematic claim. Input injected into actual viewport,
  no new hardware evidence. Source/normal save preserved; no Blender/subagents/export,
  commit/push/publication. Failed first bridge launch corrected; successful runtime
  scans clean. Ship/fair recovery remain separate.
- Next eligible task: P012 — Reusable Blender asset pipeline. Not started.
