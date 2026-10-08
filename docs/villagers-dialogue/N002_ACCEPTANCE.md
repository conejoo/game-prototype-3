# N002 acceptance — typed selected NPC content and strict publication

Completed 2026-10-07, America/Vancouver. Exactly N002 implemented this invocation.
[Checklist](CHECKLIST.md) owns status; [contract](CONTRACT.md) owns stable rules.
N001 pin integrity and measured contact evidence were verified before selection.

## Acceptance evidence

| Criterion | Verified result |
| --- | --- |
| Eight graphs and every declared reference convert deterministically | [Converter](../../tools/npc_migration/convert_content.py) consumes only N001 target-local public snapshots. Byte audit of all 67 outputs and two independent in-memory conversions passes. Exactly npc-01/02/03/04/06/07/08/14; 70 nodes, 54 choices, 24 facts, 48 portraits, 18 sheets and eight gift rules. Reload three times retains eight definitions. No seven unrequested packages. |
| Preserve source IDs, text, entry ordering and expressions | Converted [catalog](../../game/content/npcs/catalog.json) preserves complete runtime/dialogue documents, node/choice arrays, conditions, formatted text, priorities and expression IDs. Only N001's audited npc-14-introduction text differs. Visual paths map to owned res:// files; all 66 original PNGs retain exact source bytes. Converter --check verifies every output against hashed inputs, coverage and adaptation. |
| Typed definitions and identity/fact/portrait/action indexes | NpcDefinition supplies typed facts, gifts, relationship/milestone metadata, source dimensions/agent profile, flag/action IDs, portraits and sheets. NpcDialogueGraph supplies typed nodes, choices, conditions and exact-null event keys. Reference validation resolves entries, transitions, flags, facts, portraits, gifts, milestones and declared action sheets within the same person. |
| Preserve deferred gifts/routines and report reasons | All 12 deferred nodes, 16 deferred choices, three undisclosed facts and eight deferred gift rules retain N001 classification/reasons. NpcContentAvailability has ENABLED/DEFERRED enum. Gifts, Helena archive entries/outcomes, Edric milestone and Della room branch cannot be marked enabled. No transactions, routine injection or fabricated disclosures. |
| Atomic publication and independent data | Complete candidate validation precedes publication. 75 malformed candidates tested against both an empty catalog and an already valid catalog; rejected initial candidates publish zero definitions and rejected replacements preserve the complete prior snapshot. Caller dictionaries, exported snapshots, nested typed views and subsequent lookups do not share authoritative mutable collections. |
| Malformed keys/types and duplicate IDs rejected visibly | Explicit key schemas at every object boundary; exact array/string/bool/integral finite-number checks. Tests cover unknown/missing keys, null/wrong types, booleans as numbers, NaN/infinity/fractional values, duplicate NPC/node/choice/fact/flag/entry IDs and duplicate choices across nodes. Root reports loader errors through existing application initialization failure boundary. |
| Dangling/cross-person references, missing assets/facts and illegal transitions rejected | Tests exercise foreign actor aliases and person IDs, missing/foreign node/flag/fact/gift/milestone references, missing or foreign portraits, missing actions, invalid texture dimensions/facing order, unsupported conditions/events, contradictory/inverted bounds, target/end conflicts, choices-plus-Continue, cycles and enabled transitions into deferred content. Valid finite Continue and optional source condition/event fields also pass and decode into typed values. |
| Target-local runtime, Maris reuse and existing gameplay preserved | GameRoot validates its separate npc_catalog before session startup. Core ContentManifest remains exactly 21 definitions; existing npc-03 ActorDefinition is reused by identity, without another actor definition or wrapper. Existing legacy dialogue remains unchanged. Both export presets explicitly include content/npcs/*.json. Runtime loaders use only res:// JSON/textures; no absolute source dependency. SaveCodec remains schema6/content1. |
| Required checks and durable handoff | Stable-source run passes import, parse preflight, npc_content_checks, content_catalog_checks and application_smoke. Full result/log/evidence review and final source/output/baseline/document/diff audits pass. Checklist records N002 Done; next eligible task is N003. |

## Actual interfaces and ownership

- [NpcContentCatalog](../../game/features/npcs/npc_content_catalog.gd): initialize_path(actors, path=PATH) and initialize_document(value, actors) return PackedStringArray errors. A validated ContentCatalog containing the existing npc-03 is required. npc_ids(), definition_count(), get_npc(id) and document_snapshot() expose accepted content. Unknown IDs return null. No discovery outside the fixed selected roster.
- [NpcDefinition](../../game/features/npcs/npc_definition.gd): detached RefCounted typed view, with nested Fact/GiftRule/Sheet. actor_id always equals source id; seven new live actor bindings remain future world/character tasks. The Maris alias points to the existing identity, not a duplicate definition.
- [NpcDialogueGraph](../../game/features/npcs/npc_dialogue_graph.gd): detached graph with NodeDefinition/Choice/Conditions/EventCondition and node/choice indexes. Ordered entry_node_ids and choice arrays retain source ordering. No selection, memory, reward, UI or event adapter exists yet.
- [NpcContentAvailability](../../game/features/npcs/npc_content_availability.gd): typed status/reason. Sheet availability describes an art reference, not a claim that its 3D clip or routine exists.

Canonical publication is a private deep-copied plain-data document. Every typed lookup
and exported snapshot is detached. Treat definitions as authored data; callers may
edit their own views without mutating any catalog or other lookup. This strict loader
is the selected equivalent to immutable authored Resources. JSON keys must be Strings;
programmatic fixtures use bracket insertion because Godot dot insertion creates
StringName keys. Integral JSON floats decode to typed integers; booleans are rejected.
Optional absent numeric bounds use -1 sentinels only in typed views, never in JSON.
Null subject/target event components remain exact nulls. Source sprite dimensions
remain source metadata, never inferred 3D actor dimensions.

The catalog embeds enabled/deferred coverage with reasons for each node, choice,
fact, gift, portrait and sheet. Original N001 snapshots remain immutable, including
Della's original welcome. No geography refresh, save bump, quest/trust change, NPC
activation or art production. The copied world sheets are labeled reference assets;
they do not satisfy N007 or named-character ART acceptance.

## Commands, isolation and outcomes

All commands ran from D:/development/game-dev-blender/returning-fair-prototype.
Python: C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe.
Godot: installed console 4.7.2.stable.mono.official.ed1daf0bf, Compatibility renderer.

```powershell
& $python tools/npc_migration/npc_reference_checks.py --source D:/development/game-prototype-2 --geometry docs/evidence/N001/20261007-reference/placement-attempt-4.json
& $python tools/npc_migration/convert_content.py --source D:/development/game-prototype-2
& $python tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
./tools/run_checks.ps1 -Task N002 -Import -Names npc_content_checks,content_catalog_checks,application_smoke -TimeoutSeconds 150
git -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --check
```

N001 checker passed before any runtime edit: 132 authority inputs, 90 copied files,
70 nodes/54 choices/24 facts/48 portraits/18 sheets, all 462 production files unchanged
at that checkpoint. After N002 changes, that historical unchanged-production check
is intentionally no longer applicable; convert_content --check independently protects
all N001 input/generated hashes and can verify all original source hashes with --source.

Final successful runner evidence:
`docs/evidence/N002/20261008-063748469-bd2b5f8b/results.json`.
All six cases passed with exit 0, no timeout and no runtime/parse diagnostic. The existing
runner explicitly permits the import-only missing .NET SDK 10.0.9 message; this GDScript
project needs no SDK installation. Source fingerprint remained
`460a0cfc07088315cd2e921d0992c25306000cbe78034da8e78ad0a7dab4d3b1`
across all cases (750 game/tools files). Reports, source manifests, stdout/stderr and
`checks/npc_content_checks/npc-content.json` were inspected. The suite logs 423 assertions,
including evidence-write success; JSON contains the preceding 422 assertions and 75
rejection records, zero failures. Counts and full rejected-candidate errors inspected.
Baseline content check passes21 definitions. Smoke proves root NPC validation, existing
party 2, composition, pause/resume and independent session state.

Isolation: `builds/testing/N002/20261008-063748469-bd2b5f8b/{appdata,localappdata}`,
with separate named check slots/subdirectories supplied by the shared runner.
No save read/write commands in the new suite; no normal user appdata access.
All owned Godot processes exited; no editor, live-input ownership or cleanup owed.

Retained failed attempts, never counted as acceptance:

1. `docs/evidence/N002/20261008-063420225-db3dc25a/`: initial import created 66 PNG import records and five script UIDs. Runner correctly rejected the changed source baseline and stopped before tests. Generated metadata retained; no guard weakened.
2. `docs/evidence/N002/20261008-063540688-5cf0b0a5/`: stable import/parse/core catalog/smoke passed, but new suite failed seven fixture assertions. Newly inserted dot keys were StringName and correctly failed the strict String-key schema before transition checks. Fixture inserts were changed to bracket String keys; the full suite then passed, including Continue/cycle checks. No production validation was weakened.

## Preservation, hashes and final review

Target baseline HEAD: `71b087ab6aa098b2e5afc7c8e8e4227bfe592b11`, clean before N002.
Source HEAD: `60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean before/after.
Source hashes match all 132 pinned authority paths. Command-local safe.directory was
used where the sandbox Git identity differs; no global settings changed.

Runtime catalog SHA256:
`9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.
All 48 portrait and 18 reference-sheet hashes match N001 exactly. Catalog has LF-specific
.gitattributes so its deterministic byte hash survives Git checkout. Existing modified
scripts retain their original CRLF; diff check uses cr-at-eol accordingly.

Production audit: 459 of 462 prior game/art files remain exact. Only game_root.gd,
export_presets.cfg and application_smoke.gd changed. All 144 added production files are
within game/assets/npcs, game/content/npcs, game/features/npcs or the new owning content
suite/UID; no prior file removed. Geometry, old actor/dialogue content, save/session,
combat, quest, relationship, environment, items and art sources remain byte-exact.
P/M/W/F workflow documents and N001 pin files remain unchanged. No user edits existed
at selection; no agents/chats/schedules/commits/push/publication launched.

Supplemental final-audit.json independently verifies complete source/runtime/visual
document parity, all passing game byte hashes, 82 local Markdown links and N003/N007
eligibility. Initial supplemental audit reached Git diff and returned 129 in elevated
execution; final-audit-attempt-1.json retains the failure. Repeating with explicit -C
checkout and command-local safe.directory passed; no source or Git settings changed.

Final intended diff, local links, bootstrap/status/dependency consistency and immutable
pin audit were reviewed. No ordinary eight-person route, portrait UI, rig/export or
native package claim; these gates belong to their owning later tasks. N003 is next;
N007 becomes an independently ready ART branch but is not started. Stop after N002.
