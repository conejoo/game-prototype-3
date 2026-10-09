# R002 - immutable routine content

Done 2026-10-09 UTC / America/Vancouver. Exactly R002 completed this invocation.
Next eligible R003; R005 independently ready. Final ID R016; whole checklist incomplete.

Baseline target fc049516ae90deffac78bd2f7bb6ded804fbe28c was clean.
Read-only source60c20eb2816e7271fb84afaba286af006ebe3ccf remains clean.
R001 live-source reference audit passes1624 assertions, with88 source authority pins.
Workspace/user AGENT_PROMPT instructions and all pre-existing game/tool tracked bytes
preserved. No runtime graph/social pin, save7/content1, geography, rig or activation edit.

## Acceptance

| Criterion | Delivered evidence |
| --- | --- |
| All25 valid definitions load immutably | [Catalog](../../game/content/routines/catalog.json), [loader](../../game/features/routines/routine_content_catalog.gd), [typed definitions](../../game/features/routines/routine_definition.gd). Exact25 IDs/eight people/104 steps/21 qualified anchors. Deep read-only canonical data and typed copies; mutable snapshots/arrays never change accepted definitions. Caller document edits after publication remain detached. |
| Malformed/unknown/duplicate keys and IDs reject | [Strict JSON](../../game/features/routines/routine_json.gd) rejects duplicate keys, including escaped equivalent names/nested step keys, malformed grammar/trailing commas/content and excessive nesting before semantic validation. Tests remove every key/add unknown key across actual archive object levels, reject wrong types/non-string keys/schema/IDs/index paths, duplicate participants/plans/steps/entry pairs/tags/catalog assets and excluded/unindexed files. |
| Finite durations and nonempty/distinct windows | Strict HH:mm range, start!=end, typed overnight window; waits/actions/speech require finite positive duration. Zero/negative/NAN/INF/boolean/string duration fixtures reject with file/routine/actual step context. Raw huge exponent refuses before engine conversion diagnostics. |
| Participants/flags/events/actions resolve | Exactly one nonempty plan per known participant; current NpcContentCatalog declarations validate actions/facts/flags. Unknown and cross-person references reject. Player event kinds/subjects/targets/count bounds/recency validate; nullable synthetic vocabulary and all four kinds tested. Current memory allowlist is reused as reference context, with no invented gameplay event. |
| Dialogue/outcomes/entries/jumps resolve | Default entry exists for every participant; step entry resolves its participant/step/node; outcome tag exists in participant graphs; jump target exists in named plan. Disabled dialogue forbids entries/bindings. Real Helena resume/jump/end are typed; valid/invalid event directives are explicitly synthetic fixtures, with no new production choice. Deferred routine nodes stay deferred. |
| Qualified maps/anchors/portals declared | [References](../../game/content/routines/references.json) pins three map aliases/21 anchors/four directed source-destination-arrival contracts. Every move target resolves; wrong-map/unsupported anchors/maps reject. All nine map-pair declaration chains pass; severed synthetic graph fails. Runtime validates pinned declaration bytes. Room physics/path/support/LOS remain R006-R008/R009 gates. |
| Complete atomic publication | Every228 negative fixture checks both empty initial catalog and unchanged previously accepted25-item catalog after failed reload. Missing/unindexed/last invalid routine cannot partially publish. No root/schedule wiring. |
| Existing content remains valid | Final required runner passes npc_content_checks, content_catalog_checks and application_smoke; validated NPC snapshot unchanged before/after new catalog operations. |

## Conversion and isolation

[Converter](../../tools/routine_migration/convert_content.py) invokes fail-closed
R001 offline audit before writing. All25 source values remain exact except move
mapId mapping to prototype- prefixed target identities. Catalog assets are target-local
res:// paths; [conversion provenance](../../game/content/routines/conversion.json)
records each source SHA256 and adaptation. --check byte-compares all28 expected
documents and rejects additional JSON. .gitattributes keeps JSON bytes stable.
Runtime needs only target content and current NPC catalog, with no source path,
Flutter, private profile, extra person, save cursor or production activation.

JSON bounds:2MiB/document, nesting64,100000 values,512 characters/number;
explicit exponent magnitude<=308 and finite double result. Authored selected
values are within these defensive limits; no durations/windows changed.
Counts/priorities use existing signed32-bit bound; bool never means integer.
Optional action art is separate from semantic declaration, remaining R012 work.

Commands used repository cwd and bundled Python3.12.14:

- reference_checks.py --source D:/development/game-prototype-2 --report docs/evidence/R002/preflight-reference.json: PASS1624.
- convert_content.py, then convert_content.py --check: PASS28 documents; offline reference audit PASS1535.
- run_checks.ps1 -Task R002 -Import -Names routine_content_checks,npc_content_checks,content_catalog_checks,application_smoke -TimeoutSeconds150: stable import/parse and existing regressions passed in retained084429 run; routine failure repaired below.
- Final run_checks.ps1 -Task R002 -Names routine_content_checks,npc_content_checks,content_catalog_checks,application_smoke -ParseScripts features/routines/routine_content_catalog,features/routines/routine_definition,features/routines/routine_json -TimeoutSeconds150: PASS6 cases/all exits0/no diagnostics.

Final raw report:
[results](../evidence/R002/20261009-085202820-ad2f415e/results.json) and
[content report](../evidence/R002/20261009-085202820-ad2f415e/checks/routine_content_checks/routine-content.json).
Routine stdout:848 assertions,228 rejection fixtures,zero failures (JSON records847
before final evidence-write assertion). Source before/after digest
6501daece5c783a731b969dbeaf320e715358740a6f1c09db3a5edd941349a87;
source.changed=false/source.error=null. Actual console4.7.2.stable.mono.official.ed1daf0bf.
Four independent runner save groups check-000..003, named check-<run>-<index> slots,
isolated builds/testing/R002/<run>/appdata and localappdata per group.
Data-only checks do not read/write either primary or backup slots; no normal save access.

## Retained failures and limits

084401 import generated new UIDs and source guard rejected unstable run.
084429 negative fixture found int/bool allowDialogue comparison; type gates repaired.
084631 huge exponent triggered Godot strtod warning; pre-conversion bounds repaired.
084748 repair had incorrect regex capture and test int/string path comparison; corrected.
084839 fixture wrongly treated valid same-home Edric rest anchor as missing; actual
wrong-map fixture substituted. Two ordered-context patch failures were atomic.
085016 focused run passed after all repairs;085202 final run supplies explicit new-script
parse coverage and coherent required regressions on same final source digest.
All failed raw logs/reports retained, no diagnostic allowances weakened.

Reviewed converted content, structured rejection contexts, stdout/stderr and source/
save-group manifests. No rendered/native capture, ordinary scheduling, physical
navigation, source Dart test, save behavior or room delivery claimed. These are
later task gates, with none waived. No blockers or unfinished R002 criteria.
Owned engines exited, no held input/editor/game process or cleanup owed. Unrelated
Blender2664 preserved. Evidence/staging retained under ignored R002 directories.
No agents/chats/messages/schedules/exports/source writes/commit/push.
