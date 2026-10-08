# Gifts, friendship and People journal current state

Updated: 2026-10-08 UTC.
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns stable rules;
[AGENT_PROMPT](AGENT_PROMPT.md) supplies the reusable invocation.

## Current selection and exact continuation

G001 Done. Active task: none. G002-G009 Pending. Whole checklist incomplete.
Final G task: G009. No known blocker. Exactly G001 completed, then stopped.
Successful-task commit authorized in the separate user follow-up; this state is
included with the G001 commit. No push or successor work.

Next eligible task: G002. G006 is also dependency-ready, but G002 has lower ID.
Exact next action: read the G001 activation policy/vectors/acceptance and current
InventoryState/ItemDefinition/NpcDialogueRules/ConversationMemory/event owners;
mark G002 In progress, build pure gift eligibility and detached atomic candidates,
add explicit item giftability and deterministic overlay support, verify G002
criteria/affected suites, update this workflow and stop. Ordinary production gift
activation remains G004; do not start G003/G006 in the same invocation.

## G001 outcome and interfaces

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

## Baseline, user changes and prerequisites

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

## Commands, isolation and results

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

## Retained attempts, limits and cleanup

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
