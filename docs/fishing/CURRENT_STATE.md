# Fishing migration current state

Updated: 2026-10-09 UTC (FS005 execution complete; prior history retained below).
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns stable
behavior/mappings; [AGENT_PROMPT](AGENT_PROMPT.md) supplies invocation.

## Selection and next safe action

Active fishing task: none. **FS001-FS005 Done**, FS006-FS008 Pending.
Next eligible: **FS006 - Public HUD, visual feedback and testing access**.
Final task: **FS008**. Remaining IDs: FS006, FS007, FS008.
Whole fishing checklist: incomplete. FS005 blockers: none.
Exact next safe action: await the next authorized invocation, recheck Git/current
interfaces and FS005 acceptance, then mark FS006 In progress. Build the public
snapshot-only fishing HUD, pointer Reel/Cancel, source-derived fish icons and
anchored effects; replace obsolete unavailable/gift help. Extend only guarded
read-only observations/captures and native F/FS008 evidence routing as FS006 owns.
Reuse root's FishingSessionService and set_fishing_reel input aggregation, private
verified token commit and current lifecycle gates. Do not create another inventory,
save, catalog or root mode owner. Existing native delivery remains unchanged.
FS005 finished at HEAD `199dd77a977b2a56fa156294f1644104ca80b438`, without commit.
Only FS005 ran in this invocation; no successor started.

Production now supports F targeting/world-click cast, E hook/hold/release, all
phase/lifecycle cancellation and exactly-once inventory fish rewards. Provisional
root phase/outcome feedback is functional; finished public HUD/help/icons/effects
remain FS006. Ordinary unforced catch/restart remains FS007; native release FS008.
Earlier planning/execution paragraphs below retain their historical boundaries.

## Planning baseline and independent work (historical)

Repository: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot application: `game/`. Workspace: `D:/development/game-dev-blender`.
Read-only source: `D:/development/game-prototype-2`.
Planning HEAD: `5046448521994f7441c63a37b89af35c2f801f3f`.
Source HEAD: `60c20eb2816e7271fb84afaba286af006ebe3ccf`, source status clean.
Detailed source hashes, tool paths and target layout identity live in CONTRACT.

Observed implemented foundations: current schema7/content1; existing selected/
movable rod and twenty-slot bag; finite flowers; weather/lighting; all eight villagers
and G001-G008 social features. Rod and backpack still say fishing unavailable.
Three catch areas and profiles retained as inert layout data. No fishing feature
owner/tests or matching workflow found. Existing runtime fish icons are NPC art,
not a playable fishing system. These are source-inspection findings, not new playtest proof.

[Foraging handoff](../foraging-items-backpack/CURRENT_STATE.md) records F001-F010 Done;
[weather handoff](../weather-lighting/CURRENT_STATE.md) W001-W010 Done;
[villager handoff](../villagers-dialogue/CURRENT_STATE.md) N001-N018 Done.
[Social handoff](../gifts-friendship-people-journal/CURRENT_STATE.md) records G001-G008
Done, G009 In progress. Re-read these later; another active session can change them.

Unrelated dirty/untracked paths observed before planning, preserved:
- docs/gifts-friendship-people-journal/CHECKLIST.md and CURRENT_STATE.md.
- tools/native_input.ps1, tools/testing_paths.ps1, tools/tests/native_input_checks.ps1.
- tools/social_migration/DELIVERY.md, build_packages.py, launch_native.ps1,
  native_guard_checks.ps1 and package_audit.gd.

No independent task selected/status edited. FS001 can proceed using read-only
capability/reference inspection. Later production edits must reconcile current
changes; FS008 requires completed/stable independent delivery before shared package
promotion. Native helper lacks F and FS evidence routing at this snapshot;
FS006 owns narrow tested extension. Do not reuse another task's evidence ID.

## Planning decisions and verification

Deliverables created only under `docs/fishing/`: CHECKLIST.md, CONTRACT.md,
AGENT_PROMPT.md and this file. Eight outcome-based tasks; FS003 and FS004 independent
after content, then root/UI/integration/local release. FS001 is first eligible.

CONTRACT selects existing semantic cell0.5m/range12m, retained area probabilities,
source challenge tiers, F targeting, E/pointer reeling, current combat bindings,
manual save and transient attempt state. No fish gift-preference expansion or autosave.
Schema7/content1 retained by default because fish expand recognized inventory IDs only.

Read actual source catalog, fishing challenge/resolver/targeting/HUD/input/tests,
target item/save/root/camera/backpack/test-runner/native guards and current handoffs.
Read plan-agent-tasks templates and gameplay-testing workflow.
Verified supplied Godot console path exists. Source live area profiles currently
match retained Godot area transforms; live map hash differs from pinned source map.
Historical geometry stays authoritative. Code presence is not ordinary catch evidence.

Documentation verification PASS: exact read-back of all four files; 34 existing local
links; eight unique Pending IDs and matching task sections; acyclic dependencies;
FS001 first ready; correct absolute bootstrap; both supplied Godot paths exist;
new-document whitespace clean; git diff --check exit0 (existing LF/CRLF warnings only).
No engine, source Flutter suite, renderer, native input or package rebuild run for planning.
Concurrent social work also added tools/social_migration/audit_native.py during planning;
that independent change was not edited or used as fishing acceptance.

## Planning continuation limits (historical)

At planning, all FS acceptance remained unrun; FS001 artifacts were proposed only.
The executed FS001 record below supersedes that historical pending state.
Before implementation recheck concurrent changes and any native/package ownership.
No owned gameplay process/editor started, no cleanup owed.
Raw historical reports are optional archives; durable acceptance/current capability
must be reviewed rather than blocked solely by absent screenshots.

## FS001 executed handoff (2026-10-09 UTC)

Selected/status: FS001 Done; [acceptance](FS001_ACCEPTANCE.md) verifies every criterion.
Entry/final HEAD `210c2b7a38600a1c9c144e4b773c89a5c1be8ad8`; entry Git status only
`?? docs/fishing/`. No other active workflow conflict. Social G001-G009 is now Done;
its current docs/tool/package state was read, not changed. FS008 must reverify later.
Source HEAD remains `60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean working tree.
Five planning hashes unchanged; all18 source working-byte identities recorded in
[manifest](../../tools/fishing/reference/manifest.json). Git used command-local
safe.directory for read-only source status, with no global configuration change.

Bounded actual files touched:

- docs/fishing/CHECKLIST.md, CURRENT_STATE.md, CONTRACT.md, new FS001_ACCEPTANCE.md.
  Existing user AGENT_PROMPT.md unchanged; planning provenance retained.
- tools/fishing/README.md, freeze_reference.py, reference_audit.py.
- tools/fishing/reference/manifest.json, rules.json, source_excerpts.json,
  behavior_vectors.json.
- game/tests/fishing_reference_checks.gd, fishing_reference_render.gd and both UIDs.
No existing tracked game/tool/art/schema/native/package file edited. Allowlist stays
reference/docs/test only; no ContentCatalog, inventory, root or save owner replaced.

Decisions: target layout remains SHA256
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.
Live map hash differs from its historical source but all three source area transforms/
weights/profiles match retained data. No geography refresh. Area bounds closed;
map/water/deck occupancy half-open. Measured mesh waterY=.015, dry deckY=0/art.022,
safety volumes topY3. Exclude only named water safety bodies from future cast ray;
retain gate/terrain/cliff/structural occlusion. Underwater floor is not fishability.
Sunken Reeds always overlaps dock/channel; both overlaps and golden probabilities
are audited. Rod/input/schema7/content1/manual-save/current social facts unchanged.
Source autosave and frame-boundary time loss are explicit target adaptations.

Four cast sites and negatives are listed in CONTRACT. Synthetic physics validates
actual support, radius.4/height1.6 clearance, navigation, open water cells, range,
rod lines and bridge/deck/shore/cliff/map/no-area exclusions. Independent ordinary
fresh WASD route uses shared TestRunJourney/Gui/Capture without teleport/setup;
actual arrived feet within.16m and all actual ranges/rod lines pass. No active cast,
preview/bite/fight/catch or native release claim. Those remain later tasks.

Commands/cwd: prototype root, PowerShell7; bundled Python path and exact commands in
acceptance/README. Offline reference120 and live source143 assertions PASS. Final:

```powershell
./tools/run_checks.ps1 -Task FS001 -Import -Names fishing_reference_checks,inventory_checks,reference_mapping_checks,map_water_checks,map_crossing_checks -RenderScript fishing_reference_render -RenderPhases sites -TimeoutSeconds 150
```

Accepted run `docs/evidence/FS001/20261009-025540499-ca65b02a/results.json`, nine cases
PASS/exit0. Isolated staging/app-data in matching `builds/testing/FS001/` run child;
five check groups/distinct slots and separate render group. No normal slot accessed.
Source before/after969-file digest
`3c0aa41ee226ab49eb7bcee105acd4b0fb634b8e5f3bdd65fb8affcefb61bb9d`;
source.changed=false/error=null, no timeout/runtime/parse diagnostics. Import's
existing narrow missing SDK10.0.9 advisory remains allowed; no install needed.
Reference134/inventory199/render108 assertions; map/mapping/crossing baselines PASS.
Six final PNGs/contact sheet inspected, plus full-size dock/shoreline views.
Fresh/final pause overlays confirmed; hero dry, open water visible, existing HUD intact.

Retained failed/unaccepted runs: sandbox process-launch denial
`20261009-024956877-32640ecb` resolved by authorized escalation; no auto-review rejection.
`20261009-025018698-ed5c709a` copied physics exclude-array fixture bug fixed; production
untouched. `20261009-025406077-edd91be9` README addition during preflight invalidated
that run. `20261009-025436460-b22fb6b9` first import generated two UIDs; final stable
rerun accepts them. Earlier focused geometry/render `20261009-025127745-871b5c86`
passed and its six frames were inspected too. Evidence preserved; failed overall
runs are not acceptance. Source Flutter suites not run; later task checks unrun.

Final launcher PID lookup: none alive; runner-owned processes exited, no active
editor/game/input or cleanup owed. Never stopped an unowned process. Normal saves,
historical evidence and canonical packages preserved. No commit/push or publication.
Remaining FS001 criteria/blockers: none. FS002 next; stop here.
Final docs read-back/46 local links/eight status rows/Python syntax/whitespace and
intended scope review PASS; accepted run retains final-review.json. HEAD unchanged.

## FS002 executed handoff (2026-10-09 UTC)

Selected/status: FS002 Done; [acceptance](FS002_ACCEPTANCE.md) maps every criterion.
Entry/final HEAD `24b5a01c21c8fe5edfb6f31dbcfe310eaf8dd3aa`; clean entry Git status.
Root AGENTS, current architecture, fishing prompt/contract/reference acceptance,
project-owned gameplay-testing skill, testing-tools recipe and PLAYTEST read. No
repository/nested AGENTS or workspace/repository `.agents` directory found. No
subagents/new threads or another agent conversation used. Social G001-G009 remains
Done; independent native tools/packages/instructions untouched. Read-only source HEAD
`60c20eb2816e7271fb84afaba286af006ebe3ccf`, status clean. Live reference audit before/
after143 assertions PASS: all18 source pins and layout SHA256
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be` exact.

Bounded actual files touched:

- docs/fishing/CHECKLIST.md, CURRENT_STATE.md, new FS002_ACCEPTANCE.md.
- game/core/content_catalog.gd, content_manifest.gd;
  game/features/items/item_definition.gd; game/content/prototype_catalog.tres,
  game/content/items/fishing_rod.tres and new bluegill/river_trout/golden_carp.tres.
- New game/features/fishing/fishing_challenge_definition.gd,
  rod_activation_definition.gd, fishing_area_definition.gd, fishing_area_adapter.gd,
  fishing_activity_resolver.gd and their five UIDs.
- New game/tests/fishing_content_checks.gd, fishing_activity_checks.gd and two UIDs.
  Existing inventory_checks.gd, content_catalog_checks.gd, application_smoke.gd,
  npc_content_checks.gd receive catalog-count/manifest-fixture updates only.

Ownership/decisions:24 authored catalog entries plus three adapted retained areas
publish atomically as27 definitions. Manifest explicitly references target layout;
adapter validates inert records without altering runtime_enabled=false/map bytes.
Area/source IDs, shapes, weights/probabilities and fish references validate before
existing catalog publication. Weighted/closed-edge/sorted/no-area/miss rules exact;
query accepts supplied finite [0,1) roll and owns no RNG generator/inventory command.
Species metadata retains difficulty/hook/fight times; rod capability uses metres.
No challenge controller, root input, reward, UI/icon/help, schema or content version
change. Existing inventory, ForagingState, SaveCodec, social/environment/quest/party
owners remain. Fish giftable metadata adds no authored NPC preference/action.

Verification/cwd: prototype root, PowerShell7, installed console4.7.2. Exact final
command and explicit runtime parse dependencies in acceptance. Accepted report
`docs/evidence/FS002/20261009-031709346-24ed574e/results.json`:12 cases PASS/exit0;
nine distinct check groups under matching `builds/testing/FS002/` appdata/localappdata,
slots `check-20261009-031709346-24ed574e-000` through `-008`.
Stable986-file game/tools digest
`c1854214fc96f2d08c74986d05b9ff51a9d04da3fa95593005ff7a3e3eb6c42a`,
source.changed=false/error=null. No runtime/parse diagnostics or timeouts; exact known
import-only SDK10.0.9 advisory allowed, no installation. Content255/activity208/
inventory199/foraging-save111/social-save844/NPC432/backpack148 assertions; catalog/
startup PASS. Exact complete typed fish/selection save and forecast roundtrip preserves
old facts. Full-bag/new-fish rejection, existing fish stack growth/cap99,20-type save,
malformed counts/selection, rod conservation, detached snapshots/metadata and atomic
failed operations proven. Synthetic fixtures, no ordinary catch/render/native claim.

Retained failed/unaccepted runs:
- `20261009-031344435-ec3da8f2`: sandbox engine-launch access denial; authorized scoped
  escalation resolved it. No automatic approval rejection or user gate outstanding.
- `20261009-031408508-e65d7a8a`: first import generated seven UIDs; changed-source run
  rejected. UIDs reviewed/retained before stable reruns.
- `20261009-031441393-590071d9`: hostile count fixture used typed dictionary, coercing
  malformed values; replaced with untyped plain data. Activity suite passed.
- `20261009-031522659-18665db7`: serializing NaN/Infinity emitted warnings; nonfinite
  fixtures now test plain-data validator, JSON-safe hostile values test actual decode.
  Required regressions passed, overall run excluded.

Final all-case launcher PID lookup: none alive. No owned editor/game or cleanup owed;
no unowned process stopped. Normal saves, prior evidence, source, geography/collision/
navigation/portals, original AGENT_PROMPT and native packages preserved. No commit/
push/deployment/publication. FS002 criteria/blockers remaining: none. FS003 next;
remaining FS003-FS008, whole checklist incomplete. Stop before successor.

Final docs read-back,48 local links,eight status rows/dependencies, bounded29-file
allowlist,986-file byte rehash and command-local CRLF-aware whitespace review PASS.
Accepted run retains final-review.json. HEAD unchanged; no process or cleanup owed.

### FS002 commit follow-up

Subsequent user instruction authorizes the successful FS002 local commit only.
The execution records above describe the pre-commit acceptance boundary. Rechecked
all12 passed cases and every986 tested game/tool file hash before staging the reviewed
29-file task allowlist. Durable acceptance, checklist, handoff and reusable source/
tests are versioned; ignored raw runner reports/logs remain local as project policy
requires. No unrelated changes staged, no push, no FS003 work. Verified commit hash
is reported to the user after commit; it is not embedded in its own content.

## FS003 executed handoff (2026-10-09 UTC)

Selected/status: FS003 Done; [acceptance](FS003_ACCEPTANCE.md) maps every criterion.
Entry/final HEAD `044a0fe9c99eb7b876ebd509644d6dcf258e9ab8`; entry Git clean.
Read root AGENTS, fishing prompt/checklist/current state/contract, architecture,
FS002 acceptance/current catalog/species/resolver, frozen source challenge and
project-owned gameplay-testing skill/shared testing-tools/PLAYTEST. No nested AGENTS
or workspace/repository .agents directory; no agents/new chats/conversations used.
No current coordination conflict. Immutable source pins and pinned layout exact;
live audit 143 assertions PASS before/after. Source is read-only and unchanged.

Bounded actual files touched:
- New game/features/fishing/fishing_challenge_controller.gd and generated UID.
- New game/tests/fishing_challenge_checks.gd and generated UID.
- docs/fishing/CHECKLIST.md, CURRENT_STATE.md and new FS003_ACCEPTANCE.md.
Original AGENT_PROMPT/CONTRACT/other user instructions remain exact. No existing
production/content/root/UI/inventory/save/tool/native/package/map file changed.

Ownership/decisions: one pure RefCounted controller owns transient attempt only,
local increasing token, detached Resource/snapshot/result. Paired no-fish metadata
models normal waiting miss. Fresh generations plus observed release forbid automatic
hooking from held input. Commands sample inputs at interval start. Source curves,
constants and danger/landed/exhausted priority preserved. Exact waiting/bite phase
carry; fixed 240Hz end-sample Euler fight steps with remainder/final partial timeout
step. Accepted dt finite [0,60], max 14,401 bounded steps/call; giant delta rejected.
Timing precision 4.167ms, same-timestamp partitions numeric tolerance 1e-9, boundary
roundoff 1e-10. No claim of source's frame-dependent numerical equivalence.
Root FS005 still must bind current session/location/rod and consume verified token
before any existing inventory command; controller emits eligibility only. No reward,
save field/schema/content change, input activation, targeting, HUD or durable count.

Verification/cwd: prototype root, PowerShell7, supplied console 4.7.2. Exact command
in acceptance. Accepted `docs/evidence/FS003/20261009-033554872-0f0043b7/results.json`,
six cases PASS/exit0. Three independent check groups/slots under matching
builds/testing/FS003 run, suffixes -000/-001/-002; app-data/localappdata isolated.
Challenge 8,786/content 255/activity 208 assertions, twelve retained legal synthetic
species land/slack/snap/timeout traces. Exact species hooks/waits/zones/grace/reset,
priority boundary fixtures, phase carry/hitches/partition equality, invalid inputs,
stale tokens, terminal replay, detached values and every-phase seven-reason cancel/
restart pass. Isolated priority/zone states seeded directly in tests only; no
production force command. Synthetic rules, no actual-player/render/save/native claim.
Inventory/content owners untouched; no unrelated gameplay regression rerun required.
All 990 game/tools files stable, digest
`a8fb54f8e337f45adc618143ecf01e19b5203ea4e56fdcd8ec3d8df2d8b078e0`;
source.changed=false/error=null. Logs/reports/traces reviewed, no runtime/parse
diagnostic/timeout. Import-only known SDK 10.0.9 advisory retained; no installation.

Retained attempts:
- 20261009-033347206-b3b5813e: sandbox engine-launch Access denied; scoped runner
  escalation allowed and resolved it. No automatic approval rejection/user gate.
- 20261009-033410139-23b3fab9: first import generated two reviewed UIDs; changed-
  source run correctly failed, excluded from acceptance.
- 20261009-033430121-259a9c46: stable initial six-case run PASS, challenge 8,675;
  final additional hook/replay/detachment checks motivated the accepted rerun above.
All evidence preserved, none relabeled. Final runner-owned PID lookup: none alive.
No editor/game/held-input process or cleanup owed; no unowned process stopped.
Normal saves, old evidence, source game, geography/navigation/portals and independent
social/native delivery preserved. No commit/push/publication or successor work.
FS003 remaining criteria/blockers: none. FS004 next; remaining FS004-FS008, whole
checklist incomplete. Exact next action above. Final read-back/local-links/eight
status rows/dependencies/allowlist/990-file rehash/whitespace PASS recorded in
accepted run final-review.json. HEAD unchanged. Stop; commit awaits user instruction.

### FS003 commit follow-up

Subsequent user instruction authorizes the successful FS003 local commit only.
The execution records above describe the pre-commit acceptance boundary. Rechecked
all six passed cases and every 990 tested game/tool file hash before staging the
reviewed seven-file task allowlist. Durable acceptance, checklist, handoff and
reusable controller/tests are versioned; ignored raw runner reports/logs remain
local as project policy requires. No unrelated changes staged, no push, no FS004
work. Verified commit hash is reported after commit; it is not embedded in its
own content.

## FS004 executed handoff (2026-10-09 UTC)

Selected/status: FS004 Done; [acceptance](FS004_ACCEPTANCE.md) maps every criterion.
Entry/final HEAD `cd07b4d4a27c0d6e11df4c0b69c56bdbfa667b2f`, entry Git clean.
Read root AGENTS, fishing prompt/checklist/handoff/contract, current architecture,
FS001/FS002 acceptance and actual water/terrain/crossings/camera/UI/rod/catalog
interfaces. Project-owned gameplay-testing skill, shared testing-tools and PLAYTEST
used. No nested AGENTS or workspace/repository .agents directory found. No agents,
new chats, another conversation or schedules used. Independent G009 still Done;
its native/package files untouched. No coordination conflict or approval rejection.

Bounded actual files touched (11):

- New game/features/fishing/fishing_water_target_resolver.gd and generated UID.
- New game/features/fishing/fishing_target_preview.gd and generated UID.
- New game/tests/fishing_targeting_checks.gd, fishing_targeting_render.gd and UIDs.
- docs/fishing/CHECKLIST.md, CURRENT_STATE.md and new FS004_ACCEPTANCE.md.

Original AGENT_PROMPT/CONTRACT/AGENTS/user instructions unchanged. Existing root,
camera/UI, scene/map/physics/navigation/geography, inventory/content/save/schema,
social/environment/quest/party and native/package owners unchanged.

Decisions: dedicated read-only resolver consumes committed Alderwake semantic
water cells, map origin/grid and actual undisplaced water mesh elevationY.015.
Half-open occupancy and floor-snapped .5m centers; inclusive12m horizontal range.
Layer1 camera/raw/cell and rod/cell segments exclude only identified water safety
bodies owned by water_blockers, preserving actual future gate/terrain/cliff/props.
Dry dock/bridge semantics win; underwater support never supplies fishability.
Result/status/no-area and preview snapshots detached. Snapshot-only unshaded ring/
billboard words at target; current-context refresh and full revalidate, no stored
cast authorization or input activation. Clear hides/removes transient presentation.
Schema7/content1/manual persistence/rod conservation unchanged; no inventory/RNG/
reward/challenge authority added. FS005 remains root input/lifecycle/reward owner.

Source HEAD `60c20eb2816e7271fb84afaba286af006ebe3ccf`, working tree clean. Live
reference audit143 assertions PASS before/after, all18 source pins exact. Pinned
layout SHA256 `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`;
no geography refresh. Frozen reference/casting sites/area weights unchanged.

Commands/cwd: prototype root, PowerShell7, installed supplied console4.7.2.
Exact final command/dependencies/contact-sheet recipe in acceptance. Accepted
`docs/evidence/FS004/20261009-035302983-41ba302d/results.json`: all10 version/import/
parse/targeting/content/activity/camera/movement/water/render cases PASS/exit0.
Targeting135/content255/activity208/render72 assertions;24 all-site/projection/zoom
target samples,330 existing ground-camera samples. Six independent check groups
and one renderer group under matching builds/testing/FS004 run, slots suffix000-006;
APPDATA/LOCALAPPDATA isolated, no normal slot access. All998 game/tool files stable:
digest `611484d8fdcbe4817d125bc955ee2d4ba4548f8cf35806549c312a1e52582421`;
source.changed=false/error=null, no runtime/parse diagnostic/timeouts. Existing exact
import-only SDK10.0.9 advisory retained; no C# or installation claim.

18 fresh real960x640 frames via shared pause-gated TestRunCapture; capture_evidence
validated all PNG provenance/dimensions and created two derived sheets under
render/derived/20261009-035418-d8584553. Both sheets and full-size dock-ortho-1_0,
west-overlap-perspective and no-area reviewed. All camera/zoom/site, dry deck/bridge/
bank, no-area and solid-blocked samples show correctly anchored preview and distinct
words/color. Captions now readable; fixture camera HUD reflects actual projection/
zoom. Final actual pause overlay visible and preview cleared. Samples are explicitly
paused synthetic poses/rays/presenter, not ordinary movement/casting, active
waiting/bite/fight or native evidence. Production pause/UI rejection verified in
target suite; no capture is mislabeled as an active attempt.

Retained runs and repairs:

- 20261009-034933090-a166700a: sandbox installed-engine Access denied; scoped runner
  escalation approved/resolved. No automatic approval rejection/user gate.
- 20261009-034949860-e589a5ce: first import generated four UIDs; correctly rejected
  source change, UIDs reviewed/retained before stable rerun.
- 20261009-035008475-56986696: one changed-solid fixture stood above target rather
  than on oblique camera ray. Moved fixture onto actual ray and independently
  asserted fixture intersection. Production logic unchanged; failed run excluded.
- 20261009-035110873-88e286d1: all10 PASS, source stable; visual review found tiny
  caption and stale fixture camera HUD. Caption enlarged and fixture HUD refreshed;
  final all10 stable rerun above supplies acceptance. Earlier evidence preserved.

Final launcher PID lookup: none alive. Runner-owned engine processes exited;
no editor/game/held input or cleanup owed. Never stopped an unowned process.
Normal saves/old evidence/source/instructions/independent native packages preserved.
FS004 remaining criteria/blockers: none. FS005 next; FS005-FS008 unfinished and
whole checklist incomplete. No commit/push/publication/package promotion/successor.
Final docs read-back/local links/task statuses/dependencies/11-file allowlist/998-file
rehash and whitespace verification recorded in accepted run final-review.json.
Stop; commit awaits separate user instruction.

### FS004 commit follow-up

Subsequent user instruction authorizes the successful FS004 local commit only.
The execution records above describe the pre-commit acceptance boundary. Rechecked
all10 passed cases and every998 tested game/tool file hash before staging the
reviewed11-file task allowlist. Durable acceptance, checklist, handoff and reusable
resolver/preview/tests are versioned; ignored raw runner reports/logs/captures remain
local as project policy requires. No unrelated changes staged, no push or FS005 work.
Verified commit hash is reported after commit; it is not embedded in its own content.

## FS005 executed handoff (2026-10-09 UTC)

Selected/status: FS005 Done; [acceptance](FS005_ACCEPTANCE.md) maps every criterion.
Entry/final HEAD `199dd77a977b2a56fa156294f1644104ca80b438`; entry Git clean.
Root AGENTS and full fishing preparation/current architecture/prerequisite
acceptance/current code read, plus project-owned gameplay-testing skill, shared
testing-tools and PLAYTEST. No nested AGENTS or workspace/repository .agents found.
No agent/chat creation or another conversation used. No coordination conflict.
Independent social G001-G009 remains Done; native tools/packages unchanged.

Bounded actual files touched (17 including six generated UIDs):
- game/app/game_root.gd and game/project.godot.
- New game/features/fishing/fishing_session_service.gd and UID.
- New game/tests/fishing_session_checks.gd, fishing_reward_checks.gd,
  fishing_lifecycle_checks.gd, fishing_session_render.gd and four UIDs.
- New game/tests/support/fishing_root_fixture.gd and UID.
- docs/fishing/CHECKLIST.md, CURRENT_STATE.md and new FS005_ACCEPTANCE.md.
No existing catalog/content/inventory/save/actor/UI/map/tool/native/package/source
file edited. Original user AGENT_PROMPT/CONTRACT/workspace instructions preserved.

Decisions: one root-composed transient service owns targeting/attempt/reel binding.
Current weak session/map/inventory/catalog identities, rod capability signature,
starting hero health and private challenge result/token protect rewards. No callback
exists between validation/token consumption and synchronous InventoryState.add(+1).
Production uint32-scaled independent encounter/wait draws are strictly [0,1); no-area
consumes neither. Active attempt locks hero controls but keeps damage/combat/ally and
world clock/weather simulation available so engagement cancels before reward.
Targeting retains movement; current ray/player/UI is revalidated at cast. E release
is observed before GUI consumption; source aggregation and cancellation/release
gates prevent stale keyboard/pointer hooks. Esc cancels and opens actual pause.
Existing durable owners, schema7/content1, rod conservation and manual Save remain.

Current functional surface: F toggles targeting, world click casts, E fresh press
hooks and hold/release reels, F/right-click cancels, Esc cancels+pauses. Provisional
phase/outcome feedback uses existing root/UI snapshot routes. Public pointer Reel,
finished tension HUD, fish icons/effects, static rod's obsolete "Fishing unavailable"
help and generic fish gift wording are explicitly FS006 work, not silently completed.
No ordinary unforced-RNG catch, independent-process fishing restart or native release
claim. Synthetic fixtures disable actor physics and manually step challenge where
stated; live render captures reenable automatic root/world/challenge time and retain
before/after phase/token provenance. No production force/time/RNG/reward command.

Commands/cwd: prototype root, PowerShell7, supplied console4.7.2. Exact final command
in acceptance; explicit dynamic parse dependencies include root/service and existing
environment_review/live_playtest_bridge. Accepted final
`docs/evidence/FS005/20261009-041614814-97f748a6/results.json`: all22 cases PASS/exit0,
nineteen headless checks plus renderer/version/parse. Session57/reward72/lifecycle344/
render33 assertions; challenge8786/targeting135 and all selected root/save/item/social/
combat/ally/environment regressions PASS. All1010 game/tools files stable, digest
`17a92c7979b09433eba69725c43f889ac6f8adf7b25397d1ff120e099a21ec91`,
source.changed=false/error=null, no runtime/parse diagnostics/timeouts. Twenty groups
under matching builds/testing/FS005/run, nineteen check slots plus rendered slot,
isolated APPDATA/LOCALAPPDATA. No normal slot accessed or cleared.

Seven final960x640 frames and shared four-frame pause/bag/Save/Load contact sheet
inspected. Waiting/bite/fighting are genuinely live automatic phases under synthetic
pose/seed, with root time continuing during capture. Exact same-process actual GUI
Save/Load restores complete typed snapshot, bluegill1 and fish selection at arrival;
no canceled phase resumes. All-three-species and full/capacity-lost results are legal
synthetic trajectories, exact unchanged-fact/revision assertions and verified private
dispatch negatives. Forty-five all-phase/reason cancels plus actual failed physical
transition rollback/save/load/room replacement/root teardown pass. Fresh-input and
immediate-recast checks pass. FS007 alone owns ordinary unforced/restart proof.

Live source audit143 assertions PASS before/after; source HEAD
`60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean, all18 file pins exact.
Layout SHA256 `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`
unchanged. No geometry refresh/navigation bake/collision/portal/art alteration.

Retained failed/unaccepted and earlier runs:
- 20261009-040619261-bc8667fd: sandbox engine launch access denied. Scoped isolated
  runner escalation resolved it; no automatic approval rejection/user gate.
- 20261009-040632815-2d449590: first service import generated UID; changed-source
  rejection. Existing import-only missing SDK10.0.9 advisory remained allowed.
- 20261009-041026496-68b7832f: first fixtures import generated four UIDs; rejected.
- 20261009-041112085-d7ab30f2: session/reward passed; lifecycle fixture awaited a
  transition after its scene/catalog IDs differed. Verified recorded launcher39872
  and exact Godot child68592 command line before stopping only those owned PIDs.
  Fixed fixture IDs/spawn declarations and fail-fast request guard, not production.
- 20261009-041411924-7013c263: render fixture first import generated UID; rejected.
- 20261009-041516869-581b208f: all six focused cases PASS, seven frames inspected.
  Final broader stable run above accepts the same bytes and complete regressions.
All failures/raw evidence preserved; failed runs never serve as acceptance.

Final runner logs/results/source changes/diagnostics and owned PID exits reviewed.
No active owned gameplay/editor/held input or cleanup owed. No unowned process
stopped; normal saves, prior evidence, source, user instructions and independent
packages preserved. Final docs read-back/local links/eight task rows/dependencies/
17-file scope/1010-file rehash/whitespace verified in accepted final-review.json.
FS005 remaining criteria/blockers: none. Next eligible FS006, remaining FS006-FS008,
whole checklist incomplete. No commit/push/publication/package promotion/successor.
Stop here; commit awaits separate user instruction.

### FS005 commit follow-up

Subsequent user authorization requests the successful FS005 local commit only.
Execution records above describe the pre-commit acceptance boundary. Rechecked
all22 passing cases and all1010 tested game/tool file hashes before staging the
reviewed17-file task allowlist. Durable acceptance, checklist, handoff and reusable
service/tests are versioned; ignored raw runner reports/logs/captures remain local
as project policy requires. No unrelated files staged, no push or FS006 work.
Verified commit hash is reported after commit; it is not embedded in its own content.
