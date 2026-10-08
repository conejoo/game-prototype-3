# N003 acceptance â€” per-person memory and deterministic dialogue rules

Completed 2026-10-08, America/Vancouver. Exactly N003 implemented this invocation.
[Checklist](CHECKLIST.md) owns status; [contract](CONTRACT.md) owns stable rules.

## Acceptance evidence

| Criterion | Verified result |
| --- | --- |
| Source introductions/revisits, facts and events | Owning [rule suite](../../game/tests/npc_dialogue_rule_checks.gd) exercises all 58 enabled nodes and all 38 enabled choices in the real eight graphs. Both introduction alternatives use independent fresh sessions. Explicit source entry/return IDs, signed affinity, authored targets, branch disclosure and no replay are asserted. Edric woods-first, seen suppression, second woods crossing, higher-priority Moonflower hint and Helena hint/fact suppression pass. |
| Priorities, ties and defaults | Real Edric 180/140/130/100 priorities pass. Validated fixtures reverse entry ordering and assert priority-descending/node-ID-ascending selection, absent priority 0 and default official-neutral expression. Preferred routine injection is absent; Helena routine fallback and Edric level-one milestone remain deferred even when their numeric gates match. |
| Node entry has only authored disclosure/seen effects | Entry records only that node and revealed_fact_ids; no role/art/private inference, affinity or choice event. All eight introductions and follow-up disclosure branches are covered. Close/cancel retains previously disclosed facts but applies no unselected flags, receipts, events or rewards. Edric public-role/river-fishing and Helena archive-practice remain unknown. |
| Atomic accepted responses and bounded affinity | Memory, added/reward flags, once-only receipts, target disclosure and exact choice event aggregate publish in one session.conversations replacement. Signal observer sees the complete state and new cursor once. Signed -1/0/+1, lower/upper clamp 0..2147483647, relationship threshold 3, receipt/reward-flag suppression and exhausted-event-budget rejection pass. Repeatable zero-effect responses do not become once-only receipts. |
| Opposite introductions and person/session isolation | Stale original commands, alternative introduction on revisit and consumed current-node fixture response reject without mutation. Independent fresh positive/neutral sessions pass for all eight people. Two people and two sessions remain independent; same-session second-owner publication invalidates the first cursor, preventing opposite reward. Memory, events and UI snapshots detach nested collections. |
| Hidden/stale/unknown/wrong-speaker/deferred rejection | 135 labeled rejected choice commands assert exact state/cursor equality and zero notification. Wrong speaker, instance, node, unknown ID, old token, repeated response, foreign state publication, unsupported gift/interior actions and dynamically changed event condition pass. Unbound owners, invalid catalog/session, blank identity, unrequested person and unavailable sole entry also reject. External adapters cannot fabricate choice/gift events. |
| Valid exit and finite continuation | Every real terminal exits; Edric/Helena optional-only choices have Continue-to-close and Close. No choice is auto-selected. Validated Continue and explicit endsConversation fixtures exercise finite authored transitions, entry disclosure and absence of extra choice events on Continue. Hidden choices are omitted; deferred rows explain missing capability. Owner cancel clears stale/lifecycle cursors without effects. |
| Session ownership and existing gameplay | Actual GameRoot initializes its separate NPC service, and manual schema6 Save/Load rebinds the restored session with fresh independent NPC memory, not inferred history. Legacy DialogueService, quest/trust/reward owners and schema6 codec remain unchanged. Required consequence_checks/quest_checks, affected interaction_dialogue_checks and application_smoke pass. No NPC route/UI/world adapter is activated. |
| Bounded event semantics | Exact kind/subject/target keys, including null, match pinned source. Allowlist has exactly 40 keys: woods entry, Moonflower gather, 38 enabled choices. Latest-event inclusive time window, minimum/maximum counts, first/last aggregate and detached query snapshots pass. No eviction or silent count saturation; invalid/nonfinite/regressive time and exhausted sequence reject before publication. |

## Actual interfaces and boundaries

- [ConversationMemory](../../game/features/npcs/conversation_memory.gd): per-person detached value with affinity, flags, learned_fact_ids, seen_node_ids and applied_choice_ids. level(threshold), entered(node), responded(choice), consumed(choice), detached_copy() and snapshot(threshold). Stable sets are sorted/unique; receipts follow source has_one_time_effect semantics. responded is pure and suppresses the complete effect when either receipt or authored reward flag exists.
- [NpcEventMemory](../../game/features/npcs/npc_event_memory.gd): initialize(catalog), record(kind, subject, target, seconds), count(), matches(), detached_copy(), snapshot(), supported_key_count(). record returns a new value or null, never mutates its input. Dictionary-key encoding is the JSON array of the exact three components, avoiding delimiter/null collisions.
- [NpcConversationState](../../game/features/npcs/npc_conversation_state.gd): GameSession.conversations owns eight memories and event aggregates. initialize(catalog), memory(id), events(), detached_copy(), with_person(memory, events=null), with_events(events), snapshot(). All public query values detach; the publishing owner stages candidate memory/events before one state assignment. Low-level with_* methods are owner operations, not an untrusted command or save decoder; N004 must validate all restored input before using them.
- [NpcDialogueRules](../../game/features/npcs/npc_dialogue_rules.gd): pure matches(), resolve(), choice_reason(). Ordinary entries use conditions and coverage; targets reached through accepted choices/Continue use authored links, as source _targetNode does. No gift/routine/milestone consumer is fabricated. Consumed once-only responses reject rather than record a reward-free replay event.
- [NpcDialogueService](../../game/features/npcs/npc_dialogue_service.gd): initialize(catalog, session), active(), begin(npc_id, instance_id), snapshot(), choose(npc_id, instance_id, node_id, token, choice_id), advance(npc_id, instance_id, node_id, token), close(same envelope), cancel(), record_event(kind, subject, target). Result has ok/message. changed emits after complete state/cursor publication, never for rejection. Tokens include service instance plus monotonically advancing cursor generation; accepted state identity protects against another owner's publication. cancel/reinitialize are owner lifecycle operations; stale UI envelopes never clear a current cursor.

Root owns npc_dialogue separately from existing dialogue until N005 converts content,
callers and UI. GameSession stores conversations without scene/cursor ownership.
No normal input currently calls the new service; N006 owns actual world adapters.
record_event accepts only supported woods/gather keys and reads session active time;
these tests explicitly use synthetic events, not physical crossings/gathering.

Event numeric contract for N004: count and global/first/last sequence are integers
1..2147483647 for recorded facts; empty journal global sequence is 0. Maximum 40
keys, exact allowlist, no gifts/deferred choices. Active timestamps are finite
0..2190600 seconds, grounded in the existing 3651-day/600-second-day bound; records
must not regress globally. Counts cannot exceed last sequence; first/last sequence
and timestamps preserve source order. Snapshot includes first/last sequence/time
and count per key plus global last_sequence. N004 must rebuild the allowlist from
content and derive global latest time from the last-sequence aggregate, validate
all numeric/derived relations and publish detached candidates. This task creates
no codec, migration or persistent dialogue cursor. Only schema6/content1 remains
supported; its restored NPC memory is deliberately fresh until N004 changes schema.

## Commands and inspected evidence

Cwd: D:/development/game-dev-blender/returning-fair-prototype.
Python: C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe.
Installed console/editor paths exist; console version 4.7.2.stable.mono.official.ed1daf0bf.
Compatibility renderer unchanged.

```powershell
& $python tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
./tools/run_checks.ps1 -Task N003 -Import -Names npc_dialogue_rule_checks,consequence_checks,quest_checks,interaction_dialogue_checks,application_smoke -TimeoutSeconds 150
git -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --check
```

Final run: docs/evidence/N003/20261008-074106073-ccf87fae/results.json.
All eight cases PASS/exit0: engine version, import, parse preflight and five checks.
977 owning-suite assertions including evidence write (JSON records preceding 976),
58 enabled nodes/38 choices/135 labeled rejected commands, zero failures.
Reports, every stdout/stderr, rule JSON and before/after source manifests inspected.
No timeout, runtime/parse diagnostic or source change. Import-only SDK 10.0.9 message
is the existing explicitly allowed runner diagnostic; no installation performed.
Source fingerprint f73dd08ac081b40b1ffbfcbe897260e78fe2e162a4d9f89a734d0e8d17346e51
matches before/after all 762 runner-scoped files.

Fresh isolated builds/testing/N003/20261008-074106073-ccf87fae/{appdata,localappdata}
and separate per-check named slots. New root-binding check uses only its runner slot.
Normal user saves never accessed. All owned headless processes exited; no editor,
live input, captures or cleanup owed. No UI/ordinary-play/3D/native-package claim.

Retained nonacceptance attempts: 20261008-073435360-7dc01d0e import generated five
script UIDs; 20261008-073829848-ef67672b generated test UID. Runner correctly stopped
both for source changes; metadata retained, guard unchanged. Earlier stable run
20261008-073848939-5b9d1a87 passed 959 assertions before adding actual root load/rebind,
unavailable-entry and deferred-level/routine assertions. Final run above supersedes
that smaller scope; no failed rule assertions or repaired production logic hidden.
Initial supplemental raw HEAD-byte audit rejected four preexisting clean CRLF checkout
files whose Git blobs are LF. git ls-files --eol confirmed the difference. Retained
final-audit-attempt-1.json records it; final audit verifies exact passing-run bytes
and only normalizes these four newline-only baseline comparisons. No files were
rewritten and no gameplay verification guard changed.

## Preservation and handoff

Initial clean target HEAD 0f590e79d51ff5f042c998c9b696a743902332ef includes user's
strict current-schema policy. Read-only source remains clean at
60c20eb2816e7271fb84afaba286af006ebe3ccf. All 132 authority hashes and 67 generated
outputs match N002 pin; catalog SHA256
9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9.
Only existing GameRoot/GameSession production files change, plus six new scripts/
UIDs. Source data, pinned geometry, portraits, assets, legacy dialogue/save/quest/
trust/combat/environment/foraging owners and previous P/M/W/F histories unchanged.

Checklist/current state/contract and parent discovery document actual service names,
interfaces, numeric bounds and N004 continuation. Final byte/link/status/dependency/
diff/source review is recorded in final-audit.json beside final results. No agents,
chats, schedules, commits, messages, publication or successor implementation.
Next eligible N004; independent N007 remains ready but unstarted. Stop after N003.

Supplemental audit retry 2 completed production byte/source/link checks, then hit
Windows cp1252 default decoding the UTF-8 checklist. final-audit-attempt-2.json
retains the tooling failure. Final retry uses explicit UTF-8; no production change.
