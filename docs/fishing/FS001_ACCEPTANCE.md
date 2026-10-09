# FS001 reference and cast-site acceptance

Status: Done, 2026-10-09 UTC. Exactly FS001 executed; FS002 not started.
Target entry/final HEAD `210c2b7a38600a1c9c144e4b773c89a5c1be8ad8`.
Entry Git status contained only untracked user-authored `docs/fishing/`.
Existing AGENT_PROMPT instructions and planning history were preserved; no tracked
production, other migration, package, source-game or normal-save file was changed.
No commit/push, source regeneration, installation or automatic successor.

## References and prerequisite capability

Source HEAD `60c20eb2816e7271fb84afaba286af006ebe3ccf`, working tree clean.
[Manifest](../../tools/fishing/reference/manifest.json) pins 18 working source
files, six existing geography owners and three bounded local reference artifacts.
All five planning source hashes still match. Live map SHA256 `777b99288fb18852d51c96ea1705cd264eba3a9703e6b043757c408cc8c637da`
differs from historical source map `af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f`.
All three live fishing shapes/profiles/weights transform exactly to target;
pinned Godot layout stays `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.
No geography reconciliation beyond documenting this bounded difference.

[Rules](../../tools/fishing/reference/rules.json) retains exact source rod/fish
records, source and target areas, tier constants/curves, hook/fight/wait data,
input RNG and cancellation policy. [Excerpts](../../tools/fishing/reference/source_excerpts.json)
retain challenge/resolver/targeting/shape/orchestration source with exact line ranges.
Source challenge tests (wait, early/no bite, missed hook, easy land, slack grace/reset,
hard exhaustion), resolver overlap/miss/no-roll/no-area/edge tests, inclusive-range/
elevation targeting tests and labeled HUD/early pointer reel tests were reviewed.
Source Flutter suites were not run or used as Godot acceptance.

Current actual ItemDefinition, rod Resource, ContentCatalog, InventoryState,
ForagingRegistry/SaveData, GameRoot, SaveCodec and map owners were inspected.
Current catalog has 21 definitions, existing cap1 selectable/movable rod, 20 item
types, strict schema7/content1 and one-rod conservation. Fish IDs are unused.
F010 durable acceptance plus current inventory/reference-mapping checks verify
prerequisite capability; historical schema6 wording does not override architecture.
Social G001-G009 now Done; its docs/native tools/packages were untouched.

## Criteria and measured results

| FS001 criterion | Evidence/result |
| --- | --- |
| Exact source bytes and species/timing rules pinned | Live reference audit 143 assertions; offline audit 120. Four exact source item records: existing rod cap1 and bluegill/easy/1.2/2-5, river trout/medium/.9/6-12, golden carp/hard/.7/15-30, all fish cap99. Source difficulty curves and .5/.65/.55/.75/.25 constants retained. |
| Three shapes, weights, profiles and source transforms | All source-to-Godot rectangle/vertex conversions and profile equality checked; blend weights1/1/2 unchanged, three runtime_enabled=false records remain inert. |
| Closed area boundaries, weighted intervals and RNG | 26 membership cases, five exact distributions, 38 interval/no-area cases and three wait vectors. Closed rectangles/polygon edges, sorted IDs, missing-item zero, preserved miss mass, invalid RNG rejection, independent half-open wait input documented. |
| Dry ordinary approaches, open-water/range, overlap and golden coverage | Four fresh WASD journeys reach supported dry feet within shared helper .16m goal tolerance; actual ranges and unobstructed rod lines checked at arrival. Synthetic physics proves cell-centered water, capsule clearance, full nav approaches and golden-carp coverage at three sites. Table in CONTRACT records exact sites/distances. |
| Bridge/deck, shoreline, cliff, out-of-map and no-area negatives | Dry deck(-7,18), bridge(98,-.5), shoreline(10,13), cliff-6-0-east real solid ray, half-open map edge(125,62), water-with-no-area(-12.75,20.25) checked. |
| Water height/occlusion, no collision shortcuts | Actual water vertices all Y=.015; shader has no displacement. Safety volume top Y3 differs from water. Local exclusion list excludes only identified water bodies and both party actor RIDs; gate/terrain/cliff/structural bodies remain. Dry deck/bridge semantics win over underlying water. Underwater base floor is measured below water and is not fishability. |
| Source/target differences and cancellation specified | Source wait clamp, discarded phase overshoot and catch autosave explicitly adapted to strict roll inputs, elapsed carry and existing manual Save. CONTRACT/rules name all fresh-input, explicit Esc/F/right-click and lifecycle cancel boundaries; transient attempt/token never saved. |
| Layout/blockers and unrelated state preserved | Six geography hashes match; 90 water records, 8,766 authored/8,598 effective cells, retained dock cutouts/bridge/ford/cliffs/nav. Current map/reference/inventory suites pass; tracked Git diff empty. No production fishing, item/schema or geography activation. |

Sunken Reeds is wholly contained in dock/channel union, so no reeds-only site is
invented. Dock/reeds golden probability2/15, miss8/15; channel/reeds golden43/300,
miss31/60; channel-only golden.03. No fish luck/range/bank tuning occurred.

## Commands, isolation and accepted evidence

All commands from `D:/development/game-dev-blender/returning-fair-prototype`,
PowerShell7. Both supplied Godot paths verified before launch. Installed engine
`4.7.2.stable.mono.official.ed1daf0bf`, Compatibility renderer.

```powershell
$pythonExe = 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $pythonExe tools/fishing/freeze_reference.py
& $pythonExe tools/fishing/reference_audit.py
& $pythonExe tools/fishing/reference_audit.py --source-root D:/development/game-prototype-2
./tools/run_checks.ps1 -Task FS001 -Import -Names fishing_reference_checks,inventory_checks,reference_mapping_checks,map_water_checks,map_crossing_checks -RenderScript fishing_reference_render -RenderPhases sites -TimeoutSeconds 150
& $pythonExe tools/capture_evidence.py docs/evidence/FS001/20261009-025540499-ca65b02a/render/sites-index.json
```

Freeze ran once against an absent reference directory, then bounded review expanded
only the challenge excerpt to include constants; original source hashes unchanged.
The tool now refuses overwrite/repin. Offline check needs no source checkout.

Final accepted runner `20261009-025540499-ca65b02a/results.json`: nine cases PASS,
exit0, no timeouts/forbidden diagnostics, source.changed=false/error=null.
969-file before/after game/tools SHA256
`3c0aa41ee226ab49eb7bcee105acd4b0fb634b8e5f3bdd65fb8affcefb61bb9d`.
Only existing import allowlist admits `.NET Sdk not found...10.0.9`; no .NET
installation required for GDScript. Parse and all runtime logs have empty diagnostics.
Reference geometry134 assertions; inventory199; reference mapping, complete water
and crossing checks PASS. Crossing4,032 clearance/floor probes,94 walk/dodge lanes,
four rail slides/27,780 motion samples. Render108 assertions, four ordinary journeys,
six960x640 captures. Literal script/scene dependencies discovered by runner;
no additional computed script dependency needed. New scripts' generated UIDs retained.

Unique report root `docs/evidence/FS001/20261009-025540499-ca65b02a/`.
Isolated APPDATA/LOCALAPPDATA under
`builds/testing/FS001/20261009-025540499-ca65b02a/`.
Five distinct check groups `check-000..004`, slots
`check-20261009-025540499-ca65b02a-000..004`; render has separate group/slot.
No persistence pair or Save/Load needed for this reference-only task.

Final `render/sites-index.json` records fresh ordinary input/provenance, actual feet,
camera and verified pauses. All six frames reviewed via contact sheet; full-size
dock and shoreline views inspected. Hero stays on dry deck/banks; open water remains
visible, final/fresh pause overlays present, HUD unchanged. Captures are ordinary
debug viewport proof; geometric targets are reference coordinates, not active
preview or fishing gameplay. Earlier `20261009-025127745-871b5c86` also passes focused
geometry/render and its six captures were inspected. Raw runs stay ignored/local.

## Retained failures, cleanup and continuation

- `20261009-024956877-32640ecb`: sandbox denied installed Godot process launch.
  Authorized escalation succeeded; no automatic approval rejection or remaining blocker.
- `20261009-025018698-ed5c709a`: reference fixture incorrectly mutated the physics
  query's copied exclude array. Four rod-line assertions failed; current production
  was intact. Fixed fixture to build/assign local RID list. Other four baseline
  suites passed. Overall failed run is retained and not claimed as acceptance.
- `20261009-025406077-edd91be9`: source guard caught README added during metadata
  preflight. Discarded run; no gameplay acceptance attributed to it.
- `20261009-025436460-b22fb6b9`: first import generated two new test UIDs, correctly
  invalidating source manifest. Both retained; stable final rerun passes import.

Runner-owned processes exited; final owned launcher PID lookup returns none live.
No game/editor/input left active and no cleanup owed. No unowned process stopped.
Normal saves, prior evidence and canonical packages preserved.

Final read-back/link/task/whitespace/Python syntax review PASS: 46 local links,
eight unique task rows, only FS001 Done, unchanged HEAD and empty tracked diff.
`final-review.json` retained under the accepted run; `git diff --check` passes.

FS001 blockers: none. No remaining FS001 criterion or failed required check.
Unrun later fishing challenge/target preview/reward/UI/integration/native acceptance
belongs to FS002-FS008. Next eligible FS002; exact safe action: recheck Git/current
capabilities, audit FS001 pins, then implement catalog fish/area resolver/current-save
compatibility per its checklist. Final task FS008. Remaining FS002, FS003, FS004,
FS005, FS006, FS007, FS008; whole fishing checklist incomplete. Stop before FS002.
