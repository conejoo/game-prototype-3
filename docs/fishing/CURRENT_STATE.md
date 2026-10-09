# Fishing migration current state

Updated: 2026-10-09 UTC (FS001 execution; planning history retained below).
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns stable
behavior/mappings; [AGENT_PROMPT](AGENT_PROMPT.md) supplies invocation.

## Selection and next safe action

Active fishing task: none. **FS001 Done**, FS002-FS008 Pending.
Next eligible: **FS002 - Fish content, catch areas and atomic backpack compatibility**.
Final task: **FS008**. Remaining IDs: FS002, FS003, FS004, FS005, FS006, FS007, FS008.
Whole fishing checklist: incomplete. Current blockers: none.
Exact next safe action: recheck Git/current interfaces and audit FS001 reference
pins; verify its accepted sites/rules, then mark FS002 In progress and implement
fish catalog/area resolver/current-format inventory compatibility within its scope.
No successor was started in the FS001 invocation.

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
