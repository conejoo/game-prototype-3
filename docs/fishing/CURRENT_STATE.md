# Fishing migration current state

Updated: 2026-10-09 UTC (FS002 execution; planning/FS001 history retained below).
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns stable
behavior/mappings; [AGENT_PROMPT](AGENT_PROMPT.md) supplies invocation.

## Selection and next safe action

Active fishing task: none. **FS001-FS002 Done**, FS003-FS008 Pending.
Next eligible: **FS003 - Deterministic fishing challenge rules**.
FS004 is also dependency-ready; default numeric selection chooses FS003.
Final task: **FS008**. Remaining IDs: FS003, FS004, FS005, FS006, FS007, FS008.
Whole fishing checklist: incomplete. Current blockers: none.
Exact next safe action: await the next authorized invocation, recheck Git/current
interfaces and FS002 acceptance, then mark FS003 In progress and implement its pure
transient challenge using published species metadata and frozen challenge rules.
Do not activate world fishing input, rewards or HUD ahead of their owning tasks.
FS002 completed at HEAD `24b5a01c21c8fe5edfb6f31dbcfe310eaf8dd3aa`, without commit.
Only FS002 ran in this invocation; no successor started.

The planning invocation created instructions only. FS001 now adds development-only
reference tools/tests and casting-site proof; production fishing remains inactive.

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
