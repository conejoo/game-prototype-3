# Gifts, friendship and People journal current state

Updated: 2026-10-08 UTC.
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns stable rules;
[AGENT_PROMPT](AGENT_PROMPT.md) supplies the reusable invocation.

## Current selection and exact continuation

G001-G003 Done. Active task: none. G004-G009 Pending. Whole checklist incomplete.
Final G task: G009. No blocker. Exactly G003 completed this invocation.
G003 successful-task commit authorized in the separate follow-up; this state is
included with that commit. No push or G004 work.

Next eligible G004; G006 independently ready but higher ID. Exact next action:
read [G003 acceptance](G003_ACCEPTANCE.md) and strict NpcSaveData history rules,
then mark G004 In progress; integrate approved converter activation/production
catalog gates and source milestone routing/entry flag in the single service.
Keep every other deferred node/choice/fact, source pin and existing owner intact.
G003 social_save_fixture injects milestone routing synthetically; replace that
injection with real G004 service behavior when testing activation.

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
