# G002 pure gift rules and atomic candidates acceptance

Status: Done, 2026-10-08 UTC. Exactly G002 implemented and verified. No successor,
commit or push. All selected acceptance criteria pass; no blocker remains.

## Scope and authority

Entry target HEAD `a167eda47162aa3358f654a55e29095ed97e8a56`, clean; no user
changes or nested AGENTS. Source read-only/clean at
`60c20eb2816e7271fb84afaba286af006ebe3ccf`. G001 reference/vectors/policy,
N018/F010/W010 acceptance and actual session/item/dialogue/event/foraging owners
inspected. Eight public source people, finite three flowers and companion trust
remain independent. Immutable reference hashes, art/text/placements and runtime
NPC catalog unchanged. No repin, new items, resources, actors or event bus.

Runtime outputs: explicit ItemDefinition.giftable plus both item resources;
InventoryState.detached_copy/item_definition; new NpcGiftRules Candidate,
eligibility and stage; conditional gift event allowlist; existing dialogue
rules/service token guards and sole atomic publication. New social_fixture,
social_gift_checks and social_transaction_checks plus four Godot UIDs. Tooling
adds activation_overlay/overlay_checks and opt-in converter --social.

The production strict content validator and generated coverage still defer all
gifts/milestones. Synthetic fixture first validates current strict baseline,
then deliberately bypasses its coverage capability gate to exercise G002.
It also seeds item/person memory; these are pure/service rule assertions, not
ordinary acquisition/play, save/load, UI, milestone-entry or native proof.
G003 owns durable validation; G004 owns content activation and milestone routing.
G002 validates prospective milestone target without selecting/entering it.

## Acceptance mapping

| Required behavior | Verified evidence |
| --- | --- |
| Fact/item/cap/condition gates | Pure suite rejects missing quantity/fact/rule, unknown source mapping, non-giftable metadata, unavailable rule/choice, failed conditions, foreign node/choice/person and invalid time. Source moonflower maps only to item-moonflower; rod metadata false. |
| Accepted command consumes one, selection and effects | All eight recipients tested twice. Exact count/revision, gift delta and entered authored response checked. Last unit clears selected flower; remaining units and selected rod survive. Synthetic signed/clamped choice/gift deltas, choice flag/receipt and consumed gate checked separately. |
| Shared caps and repeatability | Edric/Helena alternate hint/follow-up choices across two gifts and reject third against one item/person aggregate. Other six repeat same choice intentionally. Gift choices create no once-only receipt. Reopen creates fresh accepted second command; stale/double-click tokens reject. |
| Event staging/order/exhaustion | itemGifted(moonflower,NPC) then dialogueChoiceSelected(NPC,choice), consecutive sequences and identical full-precision active time. Exhaustion at MAX and MAX-1, unsupported first/second key and backward time reject with no candidate publication. Baseline40/future58 allowed keys remain bounded. |
| Foreign/changed/invalid/reentrant command atomicity | Service rejects foreign NPC/node/instance/token, unknown choice, bag revision change, same-revision owner replacement, foreign conversation publication, unavailable target, missing item/fact and both event-budget boundaries. Exact before/after whole durable/cursor/foraging snapshots, object identities and zero notifications checked. Pure stage also rejects missing/deferred/foreign prospective milestone. |
| All affected values before observers | One changed callback sees decremented bag, correct person, both event counts and new cursor together; foraging snapshot/revision follows current bag. Fresh/stale choose, external event, begin and owner initialize during callback reject. One notification only. |
| Independent people/sessions/trust and detached callers | All other seven memories compared on every candidate/publication; separate sessions unchanged. Entire old durable snapshot (trust, quests, party, environment, health, progression, collection/placements) compared after excluding only selected inventory/conversation changes. Caller candidate edits and item metadata edits cannot alter original memory/bag/catalog query. |
| Deterministic activation overlay, production unavailable | Read-only preview exactly changes8 gift rules/10 choices/9 nodes, totals67/48/21/8. Same source fields, Della adaptation and66 assets. Four mutated policies (extra person, fact, mapping, activation task) reject. Production catalog bytes/hash and strict deferred content tests pass; all immutable source/reference hashes remain protected. |

## Actual verification and isolation

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Installed console checked present and reports
`4.7.2.stable.mono.official.ed1daf0bf`:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
Bundled shell:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe`.
Bundled Python:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.

```powershell
./tools/run_checks.ps1 -Task G002 -Names social_gift_checks,social_transaction_checks,inventory_checks,npc_dialogue_rule_checks,consequence_checks,npc_content_checks,foraging_transaction_checks -TimeoutSeconds 150
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/social_migration/overlay_checks.py --source D:/development/game-prototype-2 --evidence docs/evidence/G002/<fresh-run>
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
git diff --check
```

Final runner `docs/evidence/G002/20261008-220842855-d4b8a199/results.json`:
engine/parse plus all7 selected suites passed, exit0, no diagnostic/timeouts,
source.changed=false/source.error=null. Before/after922-file game/tools source
SHA256 `944407d8b520c3bc9619d6a6ff12cccbf870dbd021d1cbbf0590539e7a891a0b`.
335 pure assertions,238 transaction,199 inventory,977 NPC rules (58 nodes/38
choices),423 NPC content (75 malformed candidates),587 foraging and consequence
checks passed. Actual root load rebinding and old strict persistence checks in
existing suites remain baseline regression evidence, not accepted gift durability.

Runner uses fresh per-case APPDATA/LOCALAPPDATA and named slots under
`builds/testing/G002/20261008-220842855-d4b8a199/`; exact paths/PIDs/logs/source
manifests captured in results.json. Normal saves untouched. Overlay/reference
audit initially passed under isolated `docs/evidence/G002/20261008-220646-overlay/`.
Final raw source/converter/overlay/link/code-preservation audit lives under
`docs/evidence/G002/final-audit/`, with isolated child appdata and retained logs.
Only documentation/README changes followed the final engine checks; final audit
compares every accepted game/script/code byte against runner's source manifest.

Production NPC catalog SHA256 remains
`9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.
Deterministic future preview SHA256:
`efb76e8a42796a92fab80fa5815885adc7abdfd565ee7cfe036a7d165409e1d3`.

## Retained attempts and handoff

Initial `20261008-220554379-393cce67` failed engine launch Access denied;
approved isolated runner retry permitted installed Godot execution.
`20261008-220645739-68876351` import generated four expected script UIDs;
source-change guard invalidated that run. Existing editor-only .NET SDK10.0.9
warning allowance remained unchanged; this typed GDScript feature needs no C#
build. `20261008-220709438-999c31e9` then passed five selected suites on stable
files. Review added prospective-milestone rejection checks; final seven-suite
run above passed. Source Git ownership rejection resolved using per-command
safe.directory, never global config. rg absent; used native PowerShell reads.

No G002 criterion failed or unrun. No images/captures or ordinary input/native
package claim. All owned processes exited; no held keys or cleanup owed.
CHECKLIST/CONTRACT/CURRENT_STATE updated. Next eligible G003; G006 also ready
but higher ID. Remaining G003-G009; every item through G009 is not complete.
Stop after exactly G002. Commit/push remain unperformed.

G002 successful-task commit authorized in the separate 2026-10-08 UTC follow-up.
The commit includes this acceptance, task code/fixtures/tooling and durable
state; ignored raw evidence remains local. No push or G003 work authorized.
