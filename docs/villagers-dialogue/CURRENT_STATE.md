# Villagers and dialogue current state

Updated: 2026-10-08, America/Vancouver.
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns stable rules;
[AGENT_PROMPT](AGENT_PROMPT.md) supplies the reusable invocation.

## Selection and exact continuation

N001/N002/N003 Done; N004-N018 Pending. Active task: none. Exactly N003 completed
this invocation. Next eligible N004 â€” strict current-schema NPC/event persistence.
N007 remains independently ready; lowest eligible is N004. Neither started.

Exact action: recheck current Git/source pins and schema6 policy; read N003_ACCEPTANCE
and implemented memory/service interfaces. Mark N004 In progress, implement only its
strict additive current-format codec/restart checks. Provisionally schema7/content1;
reject schema6 and every other noncurrent format, no migrations/defaults. Remove N003's
transitional root schema6-fresh-memory comment when durable restore replaces it.
Keep manual saves and reject active conversation; preserve full existing durable oracle.
Rebuild supported event keys from catalog, derive latest time from last-sequence
aggregate, validate all IDs/bounds/relationships before live swap. Stop after N004.

## N003 result and durable evidence

Target began clean at 0f590e79d51ff5f042c998c9b696a743902332ef, including user's strict
current-schema policy. Source clean at 60c20eb2816e7271fb84afaba286af006ebe3ccf;
all 132 authority hashes/67 runtime outputs match. No user changes at selection.
Schema6/content1, Compatibility, geometry and previous P/M/W/F history retained.

Implemented five typed services/value modules plus npc_dialogue_rule_checks under
game/features/npcs and game/tests; UIDs tracked. GameSession.conversations owns eight
memories/events. Root npc_dialogue initializes/binds new session and successful manual
restores; existing dialogue/quest/trust remain untouched. State swaps accepted flags,
receipts, affinity, target disclosure and choice event before one notification.
Snapshot queries detach; source entry priorities/ties/defaults and condition gates
match pin. Forty supported exact event keys, counts/sequences cap2147483647,
affinity0..2147483647/level threshold3, finite timestamps0..2190600 documented in
[N003 acceptance](N003_ACCEPTANCE.md). No gifts/routine/milestone/quest reward injection.

Final command from repository root:
./tools/run_checks.ps1 -Task N003 -Import -Names npc_dialogue_rule_checks,consequence_checks,quest_checks,interaction_dialogue_checks,application_smoke -TimeoutSeconds 150.
All eight cases PASS/exit0, 977 rule assertions including evidence write (976 in JSON),
58 enabled nodes/38 choices/135 rejected commands, zero failure/timeouts/runtime/parse
diagnostics/source changes. Actual root schema6 Save/Load rebind passes; NPC history
is currently unsaved/fresh on load, explicitly owned by N004. Existing allowed import
SDK diagnostic retained; no installation. No ordinary route/UI/art/package claim.

Evidence docs/evidence/N003/20261008-074106073-ccf87fae/{results.json,source-before.json,
source-after.json,checks/npc_dialogue_rule_checks/npc-dialogue-rules.json,logs} inspected.
Source fingerprint f73dd08ac081b40b1ffbfcbe897260e78fe2e162a4d9f89a734d0e8d17346e51,
762 runner-scoped files stable. Matching fresh builds/testing/N003 run appdata/
localappdata, separate named slots; normal saves untouched. Retained failed imports
073435360-7dc01d0e and073829848-ef67672b generated UIDs; guard stayed strict. Smaller
073848939-5b9d1a87 passed before final root/deferred/unavailable-entry scope expansion.

Changed existing production files only game/app/game_root.gd and game_session.gd;
12 added script/UID files, plus workflow acceptance/checklist/contract/current state
and parent README/architecture discovery. Source/catalog/assets and save/legacy/
quest/trust/foraging/environment implementations unchanged. Final diff/link/status/
dependency/byte audit and source pin check recorded in final-audit.json. Initial
supplemental audit's four preexisting Git-blob LF/checkout CRLF differences retained
in final-audit-attempt-1.json; final comparison verifies exact passing bytes and
normalizes only those baseline newline differences. No production repair needed.
All owned
headless processes exited; no live process/editor/cleanup owed. No agents/chats/
schedules/commits/external messages/publication. No remaining N003 criterion or blocker.

## N002 result and durable evidence

Target began clean at 71b087ab6aa098b2e5afc7c8e8e4227bfe592b11. Source remains clean
at60c20eb2816e7271fb84afaba286af006ebe3ccf; all 132 pinned source hashes match. No user
edits existed at selection. N001 pin/coverage/contact audit passed before runtime edits.
Historical N001 unchanged-production assertion is now intentionally superseded;
convert_content --check independently protects all pin/generated/runtime bytes.

Implemented typed strict loader and deterministic local conversion: eight people,
70 nodes/54 choices/24 facts/48 portraits/18 reference sheets/eight gift rules.
Deferred 12 nodes/16 choices/three facts remain classified with reasons. Complete
source runtime/dialogue fields preserved except audited Della welcome. PNGs byte-exact.
NpcContentCatalog stores a detached canonical document and returns fresh typed views;
input/snapshot/nested view mutation cannot alter publication. Entire invalid candidates
reject without a partial initial catalog or loss of prior definitions.

Actual modules: game/features/npcs/npc_content_catalog.gd, npc_definition.gd,
npc_dialogue_graph.gd, npc_content_availability.gd; typed nested node/choice/condition/
event/fact/gift/sheet types. Runtime game/content/npcs/catalog.json, owned portraits
and reference sheets under game/assets/npcs/. Tool convert_content.py consumes only
N001 target-local public inputs; optional --source is read-only drift verification.
GameRoot validates separate npc_catalog before session initialization. Core catalog
stays 21 definitions and existing npc-03; seven new IDs are future wrapper identities,
not live actors or duplicate ActorDefinitions. Export presets explicitly include JSON.

Checks from target root: ./tools/run_checks.ps1 -Task N002 -Import -Names
npc_content_checks,content_catalog_checks,application_smoke -TimeoutSeconds 150.
All six cases PASS/exit 0, no timeout/runtime/parse diagnostic/source change. 423 assertions
(including evidence write), 75 malformed candidates. Import-only missing .NET SDK 10.0.9
message remains the existing allowed runner diagnostic. No install needed.
Commands, criteria, source/output hashes and complete interfaces in N002_ACCEPTANCE.

Successful run: docs/evidence/N002/20261008-063748469-bd2b5f8b/, inspected results/logs
and checks/npc_content_checks/npc-content.json. Matching fresh isolated
builds/testing/N002/20261008-063748469-bd2b5f8b/{appdata,localappdata}, separate named
check slots. Normal saves never accessed. No ordinary input or N002 capture required.
Failed runs retained:063420225-db3dc25a generated 66 import files/five UIDs and triggered
source guard;063540688-5cf0b0a5 caught seven fixture assertions because new dot keys were
StringName. Bracket String inserts corrected fixtures; no validation weakened.

Final conversion --check --source PASS; two predicted conversions identical/67 exact
outputs. Catalog SHA256 9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9.
All 66 PNGs match pin. 459 of 462 prior production files exact; only root/export/smoke
changed, 144 owned game additions, none removed. Geometry, legacy definitions/save/
quest/trust/combat/environment/items/art sources and P/M/W/F docs unchanged. Original
modified script CRLF retained; diff check recognizes cr-at-eol. Schema6/content1 and
Compatibility retained. Final diff/links/status/dependency/source audit PASS.
Supplemental final-audit.json verifies independent full document parity, exact passing
game bytes and 82 local links. Retained final-audit-attempt-1.json records initial
elevated Git diff exit 129; explicit -C/command-local safe.directory rerun passed.

Changed files: N002 acceptance, checklist/current state/contract, discovery README/
architecture, npc_migration tool/README/.gitattributes, four new typed scripts/UIDs, owning test/UID,
67 generated public inputs plus 66 import records/catalog .gitattributes, narrow
GameRoot/export/smoke edits. No agents/chats/schedules/commits/publication. All owned
headless processes exited; no editor or cleanup owed. No remaining N002 criterion,
failed acceptance or blocker; no UI/ordinary NPC access/3D/native claim.

## N001 result and evidence (historical)

[N001 acceptance](N001_ACCEPTANCE.md) owns complete criterion evidence, semantics,
source IDs/adapters, measurements, tooling and commands. Target HEAD remains
`d95f548eff72dbd72664656f39cc82f8918ee3a6`; source HEAD remains
`60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean before/after. Initial user changes:
README.md discovery edit and this untracked planning folder. Preserved.

New tools/npc_migration/reference pins24 exact public JSON files,48 original portrait
PNGs and18 idle/walk/action sheets;132 source paths/hashes/revisions including
hash-only semantic/canon/map/routine authority. Selected catalog has eight of15 people.
Coverage70 nodes/54 choices/24 facts/30 condition fields/8 gift rules/48 portraits/
18 sheets;58 nodes/38 choices/21 facts enabled for future migration, others explicitly
deferred. Portrait PNGs512x512 and sheets192px cells decode; inventory sheet viewed.
No private profile or Flutter file copied. No source writes.

Exact feet/approaches and source actor/anchor IDs in contact_registry.json. Synthetic
production root measurements include all seven new actor reservations plus current
Maris body/bench. Eight dry actor/player capsules, support, LOS, interaction priority,
reserved-navigation paths and three water/wall negatives pass. Maris approach changed
only in specification from source fitting player(-6,0,11.5) to(-6,0,11), clearing
conservative0.4m capsule against bench. No runtime placement or geometry edited.
Della source indoor(256,288) remains provenance only; exterior(-9,0,3.5)/player(-9,0,4.5)
is explicit adaptation with one welcome-text replacement and deferred room directions.
Tess/Ivo/Celia new source actors will use existing pinned anchors/additive wrappers.

CONTRACT now pins source priority-descending/node-ID-ascending ties, exact once-only
receipt and fact-entry semantics, affinity clamp/threshold, giftcap2, event keys and
real woods/gather/choice mappings. Archive-practice plus Edric role/fishing facts
have no enabled ordinary disclosure. Gifts, routines/outcomes, milestone and indoor
room branch remain deferred. No fabricated affinity/events/quest/service rewards.
Runtime still schema6/content1/21 catalog definitions/Compatibility. All462 game/art
files in target_baseline match exactly; no production additions/removals. Historical
P/M/W/F statuses/bytes and normal saves untouched.

Godot console/editor paths exist; console4.7.2.stable.mono.official.ed1daf0bf.
Bundled Python used because python is absent from PATH. Blender read-only scene query
works (RF-RecoveryVessel21 objects/14 materials); no scene/settings/file edits. Initial
missing-user_prompt schema call failed, corrected call passed. Static P012 pipeline
still has animations disabled; N007 must prove its rig/export/import extension.
No future ART capability falsely certified and no current N001 blocker.

Changed files: N001_ACCEPTANCE.md, CHECKLIST.md, CONTRACT.md, CURRENT_STATE.md;
new tools/npc_migration scripts/README/reference. Existing README.md/AGENT_PROMPT.md
preserved. No agents/chats/schedules/commits/publication or other task implementation.

Commands/cwd/isolation/results: see acceptance. pin_reference.py completed with a
command-local exact target Git safe.directory exception after ownership mismatch;
no global settings. npc_reference_checks.py --source D:/development/game-prototype-2
--geometry docs/evidence/N001/20261007-reference/placement-attempt-4.json PASS.
Godot external measure_contacts.gd final attempt4 PASS8 contacts/2,008 path samples/
three negatives, exit0/clean log. Attempts1-3 retained failed: rebaked navigation was
queried before asynchronous synchronization; corrected via existing WorldHost barrier.
First attempt also caught Maris old conservative approach; northward approach passes.
No unrun ordinary eight-contact gameplay, art/import or native package claim.
Historical F010 all9 passed cases inspected; unaffected runtime suites not rerun.
Final source/production/hash/PNG/link/bootstrap/checklist/dependency/diff audits pass.

Raw evidence: docs/evidence/N001/20261007-reference/, including placement-attempt-1..4
JSON/logs, image-decode.json, viewed portrait-inventory.png, audit outputs. Geometry
uses isolated builds/testing/N001/20261007-reference/{appdata,localappdata}; no save
operations/input. All owned headless processes exited, no editor or cleanup owed.

## Commit preparation follow-up

User requested commit of this work. README discovery now matches N001 Done/N002 next.
Added scoped npc_migration/.gitattributes to preserve original reference bytes across
Git newline conversion. Removed generated coverage EOF blank and updated its manifest
hash; pinned source bytes unchanged. Staged99 manifest-covered blobs verified exact,
reference/source/geometry audit and staged whitespace check pass. Commit scope111
files: README, villagers-dialogue docs and npc_migration tooling/references. Ignored
raw runs/builds excluded. This follow-up implements no successor task.

## Retained planning history (before N001; superseded selection/status)

The following records preserve initial planning provenance. Their all-Pending and
not-yet-run wording describes planning only; N001 acceptance/current continuation
above supersedes it. N002 onwards remain unimplemented.

## Inspected baseline

Workspace: D:/development/game-dev-blender.
Target repository: D:/development/game-dev-blender/returning-fair-prototype.
Application: game/, res://app/game_root.tscn.
Read-only reference: D:/development/game-prototype-2.
Both target/source Git status commands were clean before these planning files.

Target HEAD: d95f548eff72dbd72664656f39cc82f8918ee3a6.
Source HEAD: 60c20eb2816e7271fb84afaba286af006ebe3ccf.
The new files are planning-only user-authorized changes; future execution must preserve/reinspect them.

Current architecture/save/manifest/root/UI artifacts were read. Planning baseline schema6/content1 and 21 catalog definitions; current foraging workflow F001-F010 delivered, weather W001-W010 delivered, prior P/M map history retained. Existing DialogueService provides line/terminal-choice quest/reaction routing; it does not yet implement source finite graph memory/portraits. Maris actor retains npc-03. Relevant stable behavior and source authority live only in CONTRACT.

Source catalog now has 15 people, but selected roster stays the eight quoted by the user. The selected public files contain 70 nodes, 24 facts and 48 portrait references; source Edric/Helena have special world action sheets, six others idle/walk only. These are read-only inspection counts, not checked runtime parity. N001 pins hashes, examines source disclosure/gift/routine/event dependencies and measures placements.

Both Godot executable paths in CONTRACT/AGENT_PROMPT exist. Existing tools/run_checks.ps1, tools/PLAYTEST.md, project-local gameplay/testing recipes, current tests and static Blender export pipeline were inspected for plan feasibility. Current Windows template directory builds/p014/templates exists; future export must reverify actual presets/template versions. No compiler/import/build/gameplay command was run.

## Decisions and boundaries

CONTRACT is the authority; do not duplicate/reinterpret it here. Key scope reminder: named actors + ordinary graph/portrait/fact memory; source-driven 3D adaptation and copied approved portraits. Full gifts/People journal, schedules, interiors/campaign/commerce and player-model redesign are deferred.
Della's public inn-entry placement is an explicit bounded adaptation of an unmigrated indoor contact; N001 must record exact safe feet and text adaptations. All other contacts use verified pinned/source public neighborhoods with no automatic geographic refresh.
N007 is an independent shared ART branch after N001/N002; per-character tasks become independent after Edric N008; selection still one task per invocation.

## Planning artifacts and verification

Created this folder's CHECKLIST.md, AGENT_PROMPT.md, CURRENT_STATE.md and CONTRACT.md; added a discovery link in parent README.md.
Documentation verification: readback, local target links/source references and executable paths, 18 unique tasks/statuses, acyclic dependency graph and first-ready N001, prompt selecting this workflow, proposed-versus-existing checks and no drafting placeholders.
Final planning verification: inline Python audit from the target repository read back all four files; all relative links resolve, 18 unique task rows/headings are Pending, dependency graph is acyclic and N001 is the only initially ready task. Nineteen referenced existing check scripts and bootstrap/tool files resolve. Selected source counts match 70 nodes/24 facts/48 portraits; all 48 portrait PNG signatures/dimensions were checked at 512x512. The 15-person source catalog does not expand the eight-person scope. No source image was edited.
Final non-escalated git diff --check returned exit0; status contains only README.md and this new documentation folder. The initial audit incorrectly treated the PowerShell run_checks tool as a .gd test; exclusion was corrected, then the audit passed. Initial README prefix guard stopped before editing because of mixed newlines; only the new discovery block was then normalized to LF to pass whitespace checks. A git check in the escalated write environment could not resolve the repository; the normal project check above supplied verification.
These are documentation/reference checks only. No N task completed or completion record appended; no runtime acceptance claimed.

No game process/editor was launched or owned by planning; no cleanup owed. Source project unchanged. Normal user saves untouched. No agents, chats, schedules, commits, push or publication.

## Remaining work and retry

Every N acceptance criterion remains unimplemented. No current planning blocker.
Future N001 must recheck source drift and target schema/active workflows before choosing mappings. Future ART tasks must verify Blender/rig/export capability; native final gate must verify actual focus/input support. Do not classify unavailable future tooling as already verified.
If interrupted during an implementation invocation, update CHECKLIST/CURRENT_STATE with selected task, preserved changes, failed/unrun checks, evidence and exact next action; resume that task before its successor.

Supplemental audit retry 2 completed production byte/source/link checks, then hit
Windows cp1252 default decoding the UTF-8 checklist. final-audit-attempt-2.json
retains the tooling failure. Final retry uses explicit UTF-8; no production change.
