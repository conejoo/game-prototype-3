# R013 acceptance: complete catalog activation

R013 Done 2026-10-09 UTC. Exactly one task completed. R014-R016 remain Pending;
every checklist item through R016 complete: no. No commit/push; user reviews this
result before separately instructing the already authorized successful-task commit.

Commit authorization follow-up: user reviewed the successful result and requested
the R013 commit. Only the30 intended task paths are staged; generated raw evidence
remains local under the established repository ignore policy. Accepted runtime/test
bytes and exact adaptations are rechecked before/after staging. Git and local
`docs/evidence/R013/commit-audit.json` identify the resulting commit; no push/R014.

## Scope and preserved baseline

Baseline target HEAD `5cbb4ab960dd4bf4f41bc792cee58c7841f1311c`; empty index and
clean working tree before selection. Read-only source HEAD
`60c20eb2816e7271fb84afaba286af006ebe3ccf` remains clean. Baseline records 1505
tracked hashes in [baseline](../evidence/R013/baseline.json), captured after the
single checklist status changed to In progress. No user work was displaced.
Workspace instructions, workflow contract/prompt, all content/art/maps, schema8/
content1, public/private activation gates and original source/derived pins retain
baseline bytes. Existing identities, quests, gift/item atomicity, recovery, party,
clock/weather/save owners remain. New test UID files are retained deliberately.

Production GameRoot now owns the existing execution director by default and binds
one instance to world/dialogue. Actual-map scheduled contacts replace old static
count assumptions. Routine entries expose guarded ordinary Chat, retaining the
same identity/token/group lease; existing authored ordinary introductions/gifts
remain accessible during archive work. Counter quest routing remains intact.

The recorded R012 full market-to-river failure is resolved. Edric physically walks
past solid stationary Tess to the unchanged `(15,0,1.5)` river endpoint, speaks,
then uses the existing fishing action. Rendered route uses one repath. Each retry
tries at most two deterministic sides/five navigation sublegs; real collision,
dry support and occupancy remain authoritative. Speed2m/s, wait0.5s, two-repath/
1.5s continuous-block limits remain. Party blockers, opposing movers and occupied
stations retain bounded refusal. No anchor, geometry, NPC relocation or reward.

## Every criterion

| Criterion | Accepted evidence |
| --- | --- |
| Exact eight villagers/25 routines, one production owner and actual map contacts | Default-root matrix, required NPC integration, fresh renderer; no duplicate party or combatant townsfolk |
| Every ID: selector, conditions, every authored participant step, location/anchor, dialogue policy and portable art/fallback | [Exact 25-ID coverage](R013_COVERAGE.json), 18 pinned selector vectors and all bound move targets |
| Baseline/fact/gather/flag/thunderstorm precedence | Default-owner matrix; current-schema restores, deterministic seeded weather and explicitly unsaved fact/flag inputs; ordinary rain stays distinct |
| Ivo circuits; Vale breakfast/work/briefing/evening/rest/departure/returns | Eight full selected physical plans in coverage; real collision, continuous <=0.2001m per0.1s loaded step, player/camera/party unchanged; cross-map3495 assertions |
| Full retained Tess obstruction | Full physical matrix/presentation checks and three inspected rendered river frames, no one-metre precursor |
| Ordinary talk/gift and met-only People at actual contacts | Fresh WASD/E/GUI journey: Edric/Ivo introductions, actual finite moonflower gather, Helena ordinary Chat/introduction/gift, authored ledger flag, indoor Della introduction, both rooms/returns; only four actually met People |
| Existing quest/social/fishing/recovery/party behavior and closed gates | All five required regressions plus affected dialogue/UI/gift/directive/executor/movement/occupancy/cross-map cases pass; original content/gates/geometry bytes preserved |
| Hash/source preservation and cleanup | Live reference1626 assertions,88 pins,81 exact adaptations,ten negative refusals; final audit; all owned Godot exited, no held input/editor/cleanup owed; Blender2664 preserved |

Edric's `npc-01-river-fishing` fact is still deferred: no enabled public source node
discloses it. Its pinned fact branch is an UNSAVED synthetic memory probe, not an
earned fact or forged save. Forged saves remained rejected. Fresh renderer earns
only existing public role/preference facts, gather/gift history and Helena flag.
Matrix seek/placement/seeded weather/short wait-action-speech timers never count as
ordinary input or natural weather. Eight route records distinguish initial
zero-duration reconstruction from later physical movement. No source Dart test,
full natural day, native package or R014 stress/performance completion claim.

## Commands, isolation and accepted case sets

Cwd for every command: `D:/development/game-dev-blender/returning-fair-prototype`.
Explicit PowerShell7/bundled Python3.12 and installed Godot4.7.2 stable .NET console,
GL Compatibility960x640/RTX4070 Laptop. Repository maintained testing skill and
current save/journey/interaction/native guidance were read. Runner uses distinct
R013 build/save groups, primary/backup paths and isolated APPDATA/LOCALAPPDATA;
normal saves and historical package evidence were untouched. Synthetic flags/fact
vectors are never saved. No private source or external app writes.

```powershell
./tools/run_checks.ps1 -Task R013 -Names routine_activation_checks,routine_dialogue_checks -RenderScript routine_activation_render -RenderPhases river,ordinary -TimeoutSeconds 360
./tools/run_checks.ps1 -Task R013 -Names routine_dialogue_checks -RenderScript routine_activation_render -RenderPhases river,ordinary -TimeoutSeconds 360
./tools/run_checks.ps1 -Task R013 -Names npc_integration_checks,social_integration_checks,fishing_integration_checks,playable_slice_checks,recovery_presentation_checks,routine_movement_checks,routine_occupancy_checks,routine_presentation_checks,routine_directive_checks,npc_dialogue_ui_checks,npc_dialogue_rule_checks,social_gift_ui_checks,routine_executor_checks,routine_cross_map_checks -RenderScript routine_activation_render -RenderPhases ordinary -TimeoutSeconds 360
./tools/run_checks.ps1 -Task R013 -Names npc_dialogue_ui_checks,npc_dialogue_rule_checks,social_gift_ui_checks -RenderScript routine_activation_render -RenderPhases ordinary -TimeoutSeconds 360
./tools/run_checks.ps1 -Task R013 -RenderOnly -RenderScript routine_activation_render -RenderPhases ordinary -TimeoutSeconds 360
python -B tools/routine_migration/reference_checks.py --source D:/development/game-prototype-2 --self-test --report docs/evidence/R013/reference-final.json
```

- [matrix: 20261009-212942257-e752ba6c](../evidence/R013/20261009-212942257-e752ba6c/results.json): accepted cases engine-version, parse-preflight, routine_activation_checks. Whole report **failed**.
- [dialogue_river: 20261009-213350648-ca3fa9d6](../evidence/R013/20261009-213350648-ca3fa9d6/results.json): accepted cases engine-version, parse-preflight, routine_dialogue_checks, render-river. Whole report **failed**.
- [regressions: 20261009-213530625-32583188](../evidence/R013/20261009-213530625-32583188/results.json): accepted cases engine-version, parse-preflight, npc_integration_checks, social_integration_checks, fishing_integration_checks, playable_slice_checks, recovery_presentation_checks, routine_movement_checks, routine_occupancy_checks, routine_presentation_checks, routine_directive_checks, routine_executor_checks, routine_cross_map_checks. Whole report **failed**.
- [ui_rules: 20261009-213933178-54fd82e9](../evidence/R013/20261009-213933178-54fd82e9/results.json): accepted cases engine-version, parse-preflight, npc_dialogue_ui_checks, npc_dialogue_rule_checks, social_gift_ui_checks. Whole report **failed**.
- [ordinary: 20261009-214625899-d00cc8e7](../evidence/R013/20261009-214625899-d00cc8e7/results.json): accepted cases engine-version, parse-preflight, render-ordinary. Whole report **passed**.

The matrix case reports2610 console assertions/25 routines/zero failures; serialized
report records2609 before its successful evidence-write assertion. Dialogue82,
river16/3 captures, final ordinary101/16 captures/94.54 active seconds. Required
NPC108/social403/fishing59 recorded assertions; movement1363/occupancy311,
executor71/cross-map3495/directives128 console assertions. UI383/rules928/gift355
recorded assertions pass. Every accepted case exits0 with zero forbidden diagnostics,
source.changed=false/source.error=null. No failed whole report was relabeled.
NPC integration preserves established5ms path p95: all12 crowd queries pass,
measured261-1510 microseconds. Full integrated R014 budgets remain its own task.

The final accepted1297-file game/tools manifest SHA256 is
`9a7713f4438a930fa77e0f166efcbf439876504a9ec1fc8caea34bdd61fa371e`.
Only offline adaptation ledger/reference owner gate changed afterward; final
runtime and accepted driver hashes remain exact. Original before-hashes/reasons
were retained; no pin refresh. [Final reference audit](../evidence/R013/reference-final.json).

## Retained failures and inspected evidence

All R013 attempt directories remain. Repairs cover generated UID/preflight errors,
legacy fake instance/static-count assumptions, strict-save rejection of deferred
fact/flag fixtures, dynamic Tess blockage, opposing-mover refusal, a noisy p95
attempt, dialogue gift-policy fixture contamination, and test-room fake GUI
bindings. One early report was invalidated by a mid-run edit and stays failed.
Fresh walking failures retain shop-corner/nav endpoint and party-held home arrival
lane diagnostics. Public waypoints clear both lanes; the home wait now requires
Helena ACTING at her real archive. Wrong invented gift-hint ID corrected to the
existing `npc-02-moonflower-hint`; the actual gift had already succeeded.
The first ledger script encountered an existing renamed schema fixture and did
not write the ledger; [failed audit](../evidence/R013/reference-final-failed-ledger.json)
is preserved, then the original after-path mapping was respected and audit passed.
No approval rejection occurred; ordinary launcher setup failed before execution,
so scoped reviewed shell calls were used without broader permissions or source writes.

All19 accepted PNGs visually inspected: the three river speech/fishing frames in
both projections, and every final16 ordinary frame through the two contact sheets.
Full Helena introduction/gift frames were also inspected from the preceding failed
attempt; final sheets confirm their fresh accepted counterparts. Portraits/text,
visible Chat, single gift feedback, archive/inn bodies and room returns are readable.
Capture helpers verify real pause checkpoints; live dialogue captures retain the
interaction state. Navigation guidance uses public viewport input and guaranteed
release. No direct ordinary state/time/weather/body placement.

- [Final ordinary sheet1](../evidence/R013/20261009-214625899-d00cc8e7/ordinary-contact-sheet-1.jpg)
- [Final ordinary sheet2](../evidence/R013/20261009-214625899-d00cc8e7/ordinary-contact-sheet-2.jpg)
- [River orthographic](../evidence/R013/20261009-213350648-ca3fa9d6/render/river-full-river-route-speech-ortho.png)
- [River perspective](../evidence/R013/20261009-213350648-ca3fa9d6/render/river-full-river-route-speech-perspective.png)
- [River fishing](../evidence/R013/20261009-213350648-ca3fa9d6/render/river-full-river-route-fishing.png)

## Exact intended file allowlist

- `.gitattributes`
- `docs/ARCHITECTURE.md`
- `docs/day-clock-npc-routines/CHECKLIST.md`
- `docs/day-clock-npc-routines/CURRENT_STATE.md`
- `docs/day-clock-npc-routines/R013_ACCEPTANCE.md`
- `docs/day-clock-npc-routines/R013_COVERAGE.json`
- `game/app/game_root.gd`
- `game/features/npcs/npc_dialogue_service.gd`
- `game/features/routines/routine_execution_director.gd`
- `game/features/routines/routine_movement.gd`
- `game/features/routines/routine_occupancy.gd`
- `game/tests/fishing_integration_checks.gd`
- `game/tests/npc_dialogue_rule_checks.gd`
- `game/tests/npc_dialogue_ui_checks.gd`
- `game/tests/npc_integration_checks.gd`
- `game/tests/routine_activation_checks.gd`
- `game/tests/routine_activation_checks.gd.uid`
- `game/tests/routine_activation_render.gd`
- `game/tests/routine_activation_render.gd.uid`
- `game/tests/routine_dialogue_checks.gd`
- `game/tests/routine_movement_checks.gd`
- `game/tests/routine_presentation_checks.gd`
- `game/tests/social_gift_ui_checks.gd`
- `game/tests/social_integration_checks.gd`
- `game/tests/support/routine_execution_fixture.gd`
- `game/tests/support/test_run_routines.gd`
- `game/tests/support/test_run_routines.gd.uid`
- `game/ui/conversation_view.gd`
- `tools/routine_migration/adaptations.json`
- `tools/routine_migration/reference_checks.py`

Final hash/diff/link/status/dependency/process readback recorded in
[final audit](../evidence/R013/final-audit.json). Blockers/unrun R013 criteria:none.
Next eligible R014: integrated restart/rollback/retry and measured runtime bounds.
Stop before R014. No commit/push this turn.
