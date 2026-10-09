# FS002 content, catch-area and inventory/save acceptance

Status: Done, 2026-10-09 UTC. Exactly FS002 executed; FS003 not started.
Entry/final HEAD `24b5a01c21c8fe5edfb6f31dbcfe310eaf8dd3aa`; entry Git status clean.
Execution finished before commit. Subsequent user instruction authorizes the local
FS002 commit; no push. [CHECKLIST](CHECKLIST.md) owns status; [CURRENT_STATE](CURRENT_STATE.md)
records exact touched files, isolation, failed attempts and next safe action.

## Criteria and evidence

| FS002 criterion | Implemented behavior and verification |
| --- | --- |
| Exact IDs/caps/difficulty data | Existing ItemDefinition permits fish and typed FishingChallengeDefinition/RodActivationDefinition. Registered item-bluegill/easy/1.2/2-5, item-river-trout/medium/.9/6-12, item-golden-carp/hard/.7/15-30, cap99. Source IDs separate from global IDs. Existing rod cap1/movable/nongiftable has .5m cell/12m water/castFishingLine metadata. Tests compare every authored value with frozen FS001 rules. |
| Fish inspect/select without tool/pickup capability | Existing inventory returns detached metadata, permits owned fish selection, derives no active_tool, clears selection on last consume, and rejects unowned selection. Fish have no rod activation, movable pickup or foraging origin. WorldItemPlacement rejects fish pretending to be rod. Fresh bag empty; no automatic grant or fishing input. |
| Strict validation before catalog publication | Existing ContentCatalog validates24 authored definitions plus three adapted areas before publishing27 indexes. Manifest binds target-local retained layout; adapter validates exact record/shape/profile/outcome structure and finite numbers without changing map. Area definitions reject invalid/degenerate/self-intersecting shapes, duplicate/blank IDs, invalid weights/probabilities and mass>1. Catalog rejects duplicate/global/source IDs, unknown/nonfish outcomes, unknown locations and aggregate weight overflow. Failed initial/replacement catalogs publish no partial content; timing/capability errors likewise rejected. |
| Overlap, order, miss and no-area | Pure resolver queries supplied cell-position XZ independently of water targeting. All26 frozen closed-membership cases, five distributions and38 exact interval/no-area cases pass. Missing profile item contributes zero; weights1/1/2 unchanged. Sorted source IDs select at most one outcome with supplied finite [0,1) roll; residual mass remains miss. Matching zero-mass profile is miss, unmatched point is no_area. Three-way boundary blend/shuffled authoring, indoor/invalid queries and invalid rolls pass. |
| Resolver grants no reward | Query has no inventory/session/reward reference, RNG generator or scene mutation. Tests compare full session snapshot/inventory revision before/after fish/miss rolls. Returned probabilities/area IDs detach from subsequent queries. |
| Inventory and capacity | Existing InventoryState adds/consumes/selects fish without production edits. Failed quantities/capacity operations preserve counts/selection/revision. Synthetic20-type bag rejects new fish, grows existing98->99 fish stack, rejects fish100/rod2/huge quantities, reuses consumed slot. Snapshot, detached copy and nested definition edits cannot mutate live facts/authored metadata. |
| Strict save counts/selection and old facts | Existing SaveCodec/ForagingSaveData accept99 of each fish and every fish/null selection, no save code edits. Full20-type fish99 save accepts, known21st type rejects. Zero/negative/fractional/excessive/boolean/string/null/nonfinite/huge counts, unknown source IDs, unowned selection, duplicate JSON fish keys, double/missing rod, fish origin/placement and extra attempt field reject. Exact typed whole snapshot/forecast roundtrip preserves social gifts/memories/effects, quests, party/health, companion/progression, environment/lamps, collected origins/placements and rod conservation. Detached decode cannot mutate source. |
| Current format/ownership | Schema7/content1/manual Save/Load and existing inventory authority unchanged. No durable field, migration, parallel catalog/inventory, reward, mode, source edit, geography regeneration, icon/HUD/help activation or native package change. Fish giftable metadata creates no NPC preference. |

New suites are synthetic rule/content/save fixtures. FS003-FS008 own challenge,
targeting, orchestration, presentation, ordinary integrated catch/restart and native
delivery. No rendered/ordinary catch claim. Existing backpack suite verifies unchanged
snapshot/select/modal machinery; new fish inspection uses existing inventory metadata.

## Commands and accepted run

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7.
Supplied Godot paths checked; installed console4.7.2 used, no installation.
Live reference audit before/after143 assertions PASS: source HEAD
`60c20eb2816e7271fb84afaba286af006ebe3ccf`, all18 frozen hashes exact, source status
clean. Target layout remains
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/fishing/reference_audit.py --source-root D:/development/game-prototype-2
./tools/run_checks.ps1 -Task FS002 -Import -Names fishing_content_checks,fishing_activity_checks,inventory_checks,content_catalog_checks,foraging_save_checks,social_save_checks,application_smoke,npc_content_checks,backpack_ui_checks -ParseScripts core/content_catalog,core/content_manifest,features/items/item_definition,features/fishing/fishing_challenge_definition,features/fishing/rod_activation_definition,features/fishing/fishing_area_definition,features/fishing/fishing_area_adapter,features/fishing/fishing_activity_resolver -TimeoutSeconds 150
git -c core.whitespace=cr-at-eol diff --check
```

Accepted local report:
`docs/evidence/FS002/20261009-031709346-24ed574e/results.json`.
All12 cases PASS/exit0: engine version, import, explicit dependency parse, both new
suites, inventory, catalog, foraging save, social save, startup, NPC content, backpack UI.
Assertions: content255, activity208, inventory199, foraging-save111, social-save844
(560 rejection cases), NPC432, backpack148; catalog/startup PASS.
Nine distinct slots and APPDATA/LOCALAPPDATA groups under matching
`builds/testing/FS002/20261009-031709346-24ed574e/`; normal saves untouched.
All case reports/logs reviewed: no timeout/runtime/parse diagnostic, source.changed
false/error null. Known import-only missing SDK10.0.9 advisory recorded separately;
this is GDScript acceptance. Stable986-file game/tools before/after digest:
`c1854214fc96f2d08c74986d05b9ff51a9d04da3fa95593005ff7a3e3eb6c42a`.
Recorded launcher PIDs exited; no cleanup owed.

Failed launch/first UID import/typed hostile dictionary/nonfinite serialization runs
retained and excluded; exact IDs/repairs in CURRENT_STATE. No approval rejection
outstanding. Existing CRLF-indexed files checked with command-local cr-at-eol;
no Git configuration or authoring instruction changed.

Remaining FS002 criteria/blockers: none. Next eligible FS003 (FS004 also ready).
Remaining IDs FS003, FS004, FS005, FS006, FS007, FS008. Every item through FS008 is
not complete. No successor started; no push/package publication.
