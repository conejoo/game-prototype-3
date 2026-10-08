# Gifts, friendship and People journal current state

Updated: 2026-10-08 UTC.
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns stable rules;
[AGENT_PROMPT](AGENT_PROMPT.md) supplies the reusable invocation.

## Current selection and exact continuation

G001-G005 Done. Active task: none. G006-G009 Pending. Whole checklist incomplete;
final task G009. Exactly G005 completed the implementation invocation. No blocker.
G005 successful-task commit authorized in the separate follow-up; this state is
included with that commit. Raw ignored evidence stays local. No push or G006 work.
Next eligible G006. Exact next action: read [G005 acceptance](G005_ACCEPTANCE.md),
source People snapshots and current catalog/ConversationMemory/fact ownership;
mark G006 In progress, implement a detached met-only projection and its suite.
Keep UI integration for G007; do not add a met/fact/affinity store or disclose
private/deferred facts. No G006 implementation occurred here.

## G005 outcome, interfaces and verification

Entry HEAD673accf2889e1ff357f63b648beb1d7a4a68d689, clean worktree. No nested
AGENTS.md or unrelated user changes. Source read-only clean at60c20eb2; current
catalog SHA256efb76e8a42796a92fab80fa5815885adc7abdfd565ee7cfe036a7d165409e1d3.
Schema7/content1, NPC source text/art/contact/resource supply and historical pins
unchanged. Only authorized UI/service feedback/help, fixtures and these docs changed.

NpcDialogueService.snapshot adds detached social {affinity,threshold,level,
level_label,moonflowers} and transient gift_feedback. Existing gift command
composes authored recipient/count/delta feedback before changed notification;
the cursor retains it through response/milestone and rejected stale input, and
clears it on close/cancel. No persisted field or new relationship authority.
ConversationView renders threshold/Reached and bag count above the scrollable
body/choices/facts; status retains gift feedback with any current error/service
notice. Prototype recovery/companion graphs keep their prior presentation.
GameRoot _present_dialogue refreshes bag/HUD after service publication, and its
dialogue input gate consumes keyboard echoes before GUI focus can activate a new
node. Stable service IDs/tokens/revision/owner guards remain unchanged.
Moonflower description/backpack/HUD explain authored gifts after preference
disclosure and optional selection; non-giftable/rod help fallbacks preserved.

New tests social_gift_ui_checks(.gd/.uid) and social_gift_ui_render(.gd/.uid).
All-eight checks label supplied items/events/contact bindings and long display
fixtures synthetic; actual wheel/Tab/Enter exercise root GUI. Ordinary renderer
reuses TestRunJourney/GUI/capture helpers and physical production WASD/E/mouse/
Tab/Enter only: two distinct flowers, helpful Edric/two gifts/one milestone,
last-item clear, missing-item reopen, independent recipients and uncollected
flower03. A normal source woods-priority detour is entered/closed before the
second gift; no entry is forced. Existing noncanonical companion station is
physically reached and its ordinary positive choice changes only companion trust.
Existing backpack_ui_checks updates its formerly obsolete no-use expectation.

Accepted runs under docs/evidence/G005/:
- 20261008-230634406-ca06e70a/results.json: all11 cases pass. UI355 headless,
  rendered397/42 captures, transaction238, milestone657, modal384, foraging130,
  backpack148, Maris729 and quest suite. Stable934-file digestd7535c689ae421fa320fc6a6cd6cb34788afefb13f1076fbd1dd14f95074a367.
- 20261008-230853742-eed20e8f/results.json: all4 cases pass. Consequence suite
  plus ordinary78 assertions/15 captures. Only ordinary test fixture changed
  since bulk; digest ed714ac07c4cf9f620961e3ade512a0a19d02d442cd0c9bbdda66dd62307ebf9.
- 20261008-231032368-d8bac947/results.json: all4 cases pass, UI355/bag148,
  after preserving original non-giftable help fallbacks. Gift/rod rendered
  branches unchanged; digest33f56cbda36ec1aab50c545594e165e40fed6d8b31e56cfaa9253003a8d0c87d.

All accepted runs have zero diagnostics/timeouts/source changes/errors. Installed
Godot4.7.2 console verified first. Exact commands/cwd/executables in acceptance;
runner owns separate APPDATA/LOCALAPPDATA/slots under builds/testing/G005/<run>/.
Normal saves untouched. Reference/source/converter exit0/empty stderr under
reference-20261008-225708. Final diff/link/manifests/source review under final-review.

All57 final acceptance captures inspected through six contact sheets plus full-size
details: authored hint/response/milestone, missing/preference/cap reasons including
scrolling long menus, Della notice, long choices/exits, ordinary bag help/empty,
larger milestone and companion response. Actual images960x640 and1350x900; root
requested1440x900, project stretch yields1350x900. Provenance/dimensions/hashes
validated by shared capture_evidence.py. No G005 GUI restart/native/package claim.

Retained failed attempts:225602 engine Access denied then approved escalation;
225636 import generated two UIDs/source guard failed correctly with existing
editor-only SDK allowance;225700 wrong Continue fixture assumption on six return
menus;225906 overlooked Helena's actual entered gather disclosure;230103 wrong
authored hint-target/name assertions. Corrected fixtures; no failed run relabeled.
Initial passing230417/230447 renders retained before wheel/companion extensions.
New mixed-ending spans alone repaired during diff review; no unrelated normalization.

No required G005 criterion failed/unrun. All owned runners/engines exited; no held
input or cleanup owed. No source-checkout mutation, external message, export,
publication, commit/push or successor. Remaining G006-G009; stop here.

## G004 outcome, interfaces and verification

Entry HEAD84a4dfb7ca01b1d009099c98a27e95682ff6ed40, clean worktree;
no nested AGENTS.md or unrelated user changes. Read-only source remains clean
at60c20eb2816e7271fb84afaba286af006ebe3ccf. G003 acceptance/artifacts verified.
No actor/art/geography/resource/item metadata or historical reference bytes changed.

Changed runtime: production NPC catalog activates exactly27 approved availability
records; NpcContentCatalog requires approved gifts/responses/milestone enabled
and retains all room/routine/undisclosed-fact gates. NpcDialogueRules.transition
selects endsConversation, unseen crossing milestone, then authored target;
enter records the source milestone flag on actual node entry. NpcGiftRules stages
choice effects/gift delta before transition and uses enter. NpcDialogueService
ordinary choice/begin/Continue reuse those helpers; stable command/publication
API stays intact. Current67 nodes/48 choices/21 facts/58 event keys; schema7/content1.
No new affinity/cap authority, event bus, autoload, reward or generic gift action.

Tooling: converter expected_outputs(source=None,social=True)/default CLI now emits
approved social content; --social alias retained. --baseline requires --check and
cannot overwrite current production. Overlay checker supports G004 evidence,
checks current content while comparing exactly27 changes to immutable baseline,
and retains strict pin/hash protection. Tool README/contract/discovery updated.

Tests: new social_milestone_checks and generated UID; social_fixture uses validated
production content with optional explicit disabled-gate fixtures. SocialSaveFixture
removes injected milestone history and uses real service; original NpcSaveFixture
skips gift choices to retain its zero-gift scope. Existing content/rule/UI/save
assumptions updated deliberately. Both introduction paths/all8/10 choices/9 nodes,
observer atomics, cap/stale/cancel/entry/ends/ordinary crossing and load/reopen pass.
Supplied items/events and authoring boundaries remain synthetic rule evidence.

Final runner docs/evidence/G004/20261008-224309617-f3c86bbd/results.json:
all16 cases pass: engine/parse, ten suites and social/NPC write/read pairs.
Milestone657, gifts335, transaction238, social-save844/560 malformed,
content432/78 malformed, original NPC rules929 with58 nodes38 choices,
NPC-save568/510 malformed, modal384 and Maris729 assertions; quest checks pass.
Social process writer3/reader29 and NPC writer2/reader9 prove actual isolated
disk/root restoration, exact whole durable oracle/paused re-save, rollback,
failed-write/corrupt/incompatible/backup handling and inert restored reopens.
Zero diagnostics (including allowed), timeouts, source changes or source/run errors.
Stable930-file digestbc39309a5f9a1dd3020f9b56219e997e5c81dc3612812c4befa6c371114bbb4b.

Command from repository root through bundled pwsh:
tools/run_checks.ps1 -Task G004 -Names social_milestone_checks,social_gift_checks,social_transaction_checks,social_save_checks,npc_content_checks,npc_dialogue_rule_checks,npc_save_checks,quest_checks,npc_dialogue_ui_checks,npc_03_checks
-ProcessScripts social_process_checks,npc_process_checks -TimeoutSeconds150.
Installed Godot4.7.2 console checked first. Per-case/group APPDATA/LOCALAPPDATA
and user:// slots isolated under builds/testing/G004/<run>/; normal saves untouched.

Final source/reference/converter/overlay audit:
docs/evidence/G004/20261008-224415-reference-final/; three exit0 and expected
baseline-write exit1 refusal before mutation. Current catalog SHA256
efb76e8a42796a92fab80fa5815885adc7abdfd565ee7cfe036a7d165409e1d3;
all66 asset/source text/adaptation bytes unchanged; four bad policies reject.
Earlier audit under224050 retained. Final diff/link/UTF-8/status/dependency/source
review recorded under docs/evidence/G004/final-review/.

Retained attempts:223850 engine Access denied then approved escalation;223902
import created script UID and source guard failed correctly. Editor-only missing
.NET SDK warning used existing import allowance; no install.223930 run exposed
four old fixture assumptions (authored gift-end suffix, original coverage,
zero-gift save scope and missing-item UI notice); repaired before final runner.
Final diff audit found CRLF whitespace on inserted README/architecture spans;
corrected only those new spans, preserving original mixed-ending bytes.
Retained diagnostic: docs/evidence/G004/final-review/whitespace-before.log.
No required G004 criterion failed/unrun. Headless modal checks report captures0,
renderedfalse; no images inspected or ordinary/UI visual/native claim.
All owned runners/engine processes exited; no held controls or cleanup owed.
No read-only source-checkout mutation, export/publication, external message,
commit/push or successor. Remaining G005,G006,G007,G008,G009; stop here.

## G003 outcome, interfaces and verification

Entry HEAD ce5af94a9716bb774f9e02e2ffd2cbafb8678bbc (G002 committed), clean
worktree; no unrelated user changes or nested instructions. Source read-only clean
at60c20eb2816e7271fb84afaba286af006ebe3ccf. Immutable pins, production catalog,
actors/geography/assets, finite resources and converter default remain unchanged.

Changed runtime: NpcSaveData cross-checks gift/authored-choice totals/shared caps,
paired consecutive endpoints/identical binary64 times, validated mapped giftable
item metadata, affinity/level/effects/once-only receipts, reachable disclosure,
source transition/milestone entry flags and legal skipped response targets.
Schema7/content1/envelope unchanged. No counters/migration/autosave/transient data.
SaveCodec.decode/validate optional initialized NPC catalog; SaveRepository(path,
social_catalog=null) uses one catalog for candidate/stage/primary/backup. Default
still strict bundled content. NpcSaveData.restore(data,catalog,seconds,items=null)
requires item metadata for gift histories; SaveCodec supplies core catalog.

New files: tests/social_save_checks.gd, tests/social_process_checks.gd and
support/social_save_fixture.gd plus three generated UIDs. Synthetic approved
availability and source milestone routing are test-only; no production activation,
ordinary/UI/People/native/save-import acceptance claimed. Existing fixtures did
not need changed assumptions; all original acceptance assertions retained.

Full passing runner docs/evidence/G003/20261008-222737370-3b4c2f29/results.json:
six suites plus social/NPC/general restart pairs, engine/parse (14 cases). G002
335/238 assertions, NPC567, foraging111, general save pass. Two test files then
added endsConversation/later-entry cases; runtime/tools stayed identical. Final
focused docs/evidence/G003/20261008-223022667-288e284a/results.json: all5 cases
pass; social842 assertions/560 malformed cases; separate writer2/reader28. Exact
whole durable oracle/paused re-save, corrupt/incompatible/failed-write files/live
state, unsafe load/travel rollback and inert social reopens verified.

Commands from repository root through bundled pwsh:
tools/run_checks.ps1 -Task G003 -Names social_save_checks,social_gift_checks,social_transaction_checks,npc_save_checks,foraging_save_checks,save_checks
-ProcessScripts social_process_checks,npc_process_checks,save_process_checks -TimeoutSeconds150;
final focused -Names social_save_checks -ProcessScripts social_process_checks.
Installed Godot4.7.2 console path checked; each case/group isolated APPDATA,
LOCALAPPDATA and user:// slot under builds/testing/G003/<run>/. Normal saves untouched.
Both accepted runs have zero diagnostics/timeouts/source changes/errors. Final928-file
game/tools digest6ef45a8e01edf5e8b0bbb4b9849b91815bcafb958a3165873aef87f22b89839e.

Bundled Python source/reference and baseline converter audits exit0/empty stderr
under docs/evidence/G003/20261008-222418-reference/; final pin/link/diff/status/source
review under docs/evidence/G003/final-review/. SaveCodec unchanged mixed-line-ending
portions preserved as original Git bytes. See acceptance for exact paths/hashes.

Retained attempts: sandbox engine Access denied then approved same runner; import
created UIDs/source guard correctly failed; priority woods terminal fixture repaired;
skipped-target variant repaired to preserve hint then follow-up cursor. Existing
editor-only missing .NET SDK warning was allowed only during import; no install.
No required G003 criterion failed/unrun. No images/captures needed or inspected.
All owned processes exited; no held input, cleanup, source mutations, export,
external messages, commit/push or successor. Remaining G004-G009; stop here.

## G002 outcome, interfaces and validation

Entry HEAD a167eda47162aa3358f654a55e29095ed97e8a56, clean worktree; no unrelated
user changes or nested instructions. Source clean at60c20eb2816e7271fb84afaba286af006ebe3ccf.
N018/F010/W010 acceptance and current G001 pins/owners checked. Immutable NPC and
social reference files, production NPC catalog, actors/art/placements unchanged.

Changed runtime: ItemDefinition.giftable (Moonflower true, rod false),
InventoryState.detached_copy()/item_definition() (detached metadata query),
NpcGiftRules.eligibility()/stage() and detached Candidate, conditional
NpcEventMemory.GIFT allowlist, existing NpcDialogueRules/Service gift staging and
atomic publication. Service commands retain their five-argument API; transient
token now includes inventory revision. Same-revision bag replacement and changed
conversation ownership reject; notification guard covers choose/begin/rebind/events.
Foraging's weak session owner follows swapped inventory and revision directly.

Candidate validates availability, conditions, rule/item mapping and giftability,
quantity, learned fact, shared item/NPC cap, target/prospective milestone and both
event slots before returning any publishable data. Choice effects then signed
gift delta; gift event then choice event at identical time. Milestone target is
preflighted on crossing, but G004 must still select/enter it and add its flag.
Schema7/content1 remains; G002 does not claim accepted gift save/load support.

Tooling: converter expected_outputs(source=None, social=False), --social opt-in;
activation_overlay.apply() validates complete immutable social audit and exact
policy, deep-copies only approved availability; overlay_checks.py writes read-only
preview/reports under fresh G002 evidence. Default converter still checks baseline.
Strict production NPC loader still requires all gift/milestone content deferred.
Synthetic social_fixture validates baseline then deliberately bypasses only
coverage gate for G002 rule tests; it is not ordinary play or production loading.

New tests social_gift_checks/social_transaction_checks plus social_fixture and
four generated script UIDs. Final run docs/evidence/G002/20261008-220842855-d4b8a199/:
seven selected suites/engine/parse pass; new335/238 assertions, inventory199,
NPC rules977, content423/75 malformed, foraging587, consequences pass. No
diagnostics/timeouts/source changes; accepted game/tools source SHA256
944407d8b520c3bc9619d6a6ff12cccbf870dbd021d1cbbf0590539e7a891a0b.
Later tooling README edits only explain interfaces; final audit compares every
accepted game/code byte and records final documentation/pin/link checks.

Commands from repository root via bundled pwsh: tools/run_checks.ps1 -Task G002
-Names social_gift_checks,social_transaction_checks,inventory_checks,npc_dialogue_rule_checks,consequence_checks,npc_content_checks,foraging_transaction_checks
-TimeoutSeconds150. Runner isolates per-check APPDATA/LOCALAPPDATA and slots
under builds/testing/G002/<run>/, records exact installed Godot and cleanup.
Bundled Python overlay/reference/source/converter audits use isolated appdata
under docs/evidence/G002/20261008-220646-overlay/ and final-audit/. See acceptance
for exact executable paths, commands, reports and source hashes.

Retained attempts: initial sandbox engine launch Access denied, then approved
same runner; first import generated four UIDs and source guard failed correctly;
rerun five suites passed, final target guard repair caused final seven-suite rerun.
Known editor-only missing .NET SDK warning used existing import allowance; no
C# build/install. No required G002 criterion remains failed/unrun. No captures
or ordinary/UI/native/save acceptance claimed. All owned processes exited;
no held controls, user-save access, cleanup, commit/push or successor started.

## Historical G001 outcome and interfaces

[G001 acceptance](G001_ACCEPTANCE.md) maps every criterion to reviewed public
source and baseline evidence and passing read-only checks. New
[tooling README](../../tools/social_migration/README.md) documents interfaces.

- tools/social_migration/reference/manifest.json: schema 1 / social-60c20eb2-g001,
  17 public source/test full original hashes with bounded line-numbered excerpts,
  all 100 unchanged NPC reference hashes and social artifact hashes.
- social_activation.json: exact future G004 recipient-qualified enable lists for
  eight gift rules/ten choices/nine terminal gift/milestone nodes; complete source
  rule/intro/preference/incoming/outgoing traces. preserve_deferred retains three
  nodes/six choices/three undisclosed facts and their original fields/reasons.
- behavior_vectors.json: 16 positive/neutral recipient sequences, 8 explicit gift
  eligibility cases, shared caps, selection, ordered events/entry/publication,
  signed/milestone/People boundaries and finite ordinary supply. These are source
  expectations; target token/revision/atomicity/save requirements are labeled
  separately and need real downstream runtime assertions.
- target_baseline.json: historical schema 7/content 1, 58/38/21/0 availability,
  40 event keys, two item types/20-slot capacity/three flowers, 18 selected target
  owner/content hashes and bounded excerpts. It does not freeze later game code.
- social_reference_checks.py: read-only local reference/hash/coverage/vector/link
  audit. --source also checks live source HEAD/status/full hashes/excerpt parity.
  --check-g001-baseline compares recorded 18 owner/content hashes only for G001.
  Default remains usable after later authorized runtime changes. No refresh mode.

CONTRACT records clarified two-type/20-slot capacity, exact source order,
threshold/milestone/endsConversation rules, retained private/deferred disclosure,
excluded source tutorial/quest callbacks and existing journal simulation policy.
Source journal uses exact item/NPC keys; no separate gift counter is authorized.
Converter overlay consumption is still G002/G004 work. No runtime file changed.

## Historical G001 baseline, user changes and prerequisites

Target repository D:/development/game-dev-blender/returning-fair-prototype;
workspace parent is not itself a Git repository. Target HEAD remains
a0f5d7bba6be42885d7e528146d9742436ebf6c5. Entry changes were only four untracked
planning docs in this workflow; no tracked user changes or nested AGENTS.md.
Original AGENT_PROMPT preserved. No reset/stash/commit/source mutation occurred.

Read-only source D:/development/game-prototype-2 remains clean at
60c20eb2816e7271fb84afaba286af006ebe3ccf. Existing villagers-60c20eb2-n001 pin,
coverage, adaptations, contact registry, portraits and package bytes unchanged.
All 132 existing authority inputs match; no repin, roster/geography refresh or
private source profile read. Bounded additional resolver/relationship-metadata
excerpts explain stable public behavior.

N018/F010/W010 current handoffs/acceptance and actual target owners were inspected.
Their completed histories remain untouched. Native/package evidence is historical,
not a fresh social pass. Current game remains eight public contacts, schema 7/content 1,
per-person memory/events, finite foraging/rod, companion trust/Maris recovery,
manual saves and current journal. Gifts/milestones/People still unavailable.

All 720 working game files are byte-identical before/after G001 and tracked content
has no HEAD diff. Raw Git blob comparison found 17 pre-existing checkout CRLF/LF
changes, each proven line-ending-only; no file was normalized or rewritten.

## Historical G001 commands, isolation and results

All commands ran from repository root with installed bundled Python:
C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe.
Godot console/editor 4.7.2 explicit paths and Python checked present; no engine run.

Evidence: docs/evidence/G001/20261008-214756-0b0d757f/.
Checker subprocess APPDATA/LOCALAPPDATA isolated under that fresh evidence directory;
no save operation or normal-user slot accessed.

PASS exit0/empty stderr:
- tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2 --check-g001-baseline
- tools/social_migration/social_reference_checks.py
- tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2

Social audits verify 17 inputs, 8 rules, 10 choices, 9 nodes and 16 sequence vectors and
retained 3/6/3 boundaries. Four final isolated malformed-reference fixtures reject
extra person, unauthorized fact activation, bad affinity vector and corrupt excerpt.
Python syntax passes. Converter verifies 67 exact outputs, 48 portraits and 18 sheets;
current catalog SHA256 9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9.
Git diff,720-file preservation, source status,100 NPC reference hashes and final
link/status/dependency/UTF-8/whitespace review pass; exact records in acceptance
and raw checks/final-checks/preservation/handoff-review JSON/logs.

Final reference SHA256:
manifest: 82e90e070cc4b459e0325b364366090f02f1a68b8c7fb311abe14b1a033673e0;
activation: 05347622812a8795cd984e6594e2dc8ca425fa79622e5565b8a4679613e1276f;
vectors: d7c310f250a5428373b3a38a88a1630778ed9508be44eab8cb03c3b121a2f0b2;
baseline: dabe281c42823d63c5d4a1a38014ffa59ad1c2448ae70d2d0bd9776d2101cc23.

## Historical G001 retained attempts, limits and cleanup

Initial excerpt capture requested line 244 of a 241-line presentation snapshot test;
corrected to 241 and verified existing partial excerpts unchanged before finishing
manifest. Initial rg/path/cwd read misses used native PowerShell/repository cwd;
source resolver was located in dialogue_repository.dart. Overstrict raw HEAD byte
comparison exposed only existing line endings, proven above. Failed attempts and
successful reruns remain in ignored evidence. No required G001 criterion failed
or unrun; gameplay/render/native checks were intentionally outside G001 scope.
No images/captures inspected or claimed. No source tests executed.

No agent/chat/schedule/install/export/deployment/external message initiated.
All owned bounded Python/Git processes exited; no game/editor, held keys or cleanup
owed. Other user sessions were not altered. Stop before successor work.
