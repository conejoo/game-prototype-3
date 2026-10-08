# N011 — Harlan public dock contact acceptance

Task scope: one named dockmaster, source ordinary public dialogue and source-informed
editable 3D presentation. No ship stage, sluice control or travel service. N008
and delivered N006/N007 contact/asset owners were inspected before selection.
Target started clean at `8f93a77369b8633acc7964d901cd3946df7764b6`; source clean
at pinned `60c20eb2816e7271fb84afaba286af006ebe3ccf`. No unrelated changes.

## Implementation and authority

Source `assets/data/npcs/npc-04/{runtime,dialogue,visuals}.json`, public official
portrait and idle sheet were read/viewed, with town canon (Harlan age48/dockmaster).
Converter read-only audit verifies132 authority input hashes and67 runtime
outputs exactly; selected roster remains eight, runtime graph/six portrait bytes
unchanged. Source worktree stays read-only. Private history never becomes content.

New custom source/build/normalize/raw/source-audit files and GLB/palette/import
records use actual `npc-04`. Registration adds only Harlan; current enabled set
is npc-01/npc-02/npc-03/npc-04. Narrow adapter prompt addition uses source
`Talk to Harlan Reed`. Existing wrapper/presenter, physics, navigation, root holds,
manual schema7/content1 saves and Party ownership are unchanged.

Public foot `(41,0,17)`, approach `(42.5,0,17)`, instance
`alderwake-npc-04-contact` retain N001 measured contract. No geographic refresh,
building/quay/water edits or guessed interior transform. Source town coordinate
transform remains `X=(sx-704)/32`, `Z=(sy-576)/32`, Y from physical support.
Pinned source `alderwake:harlan-dockmaster-01` / `harlan-sluice-practice-01`,
foot `(2016,1120)` in `assets/maps/mvp_world.json` maps exactly to `(41,0,17)`.
Anchor naming is provenance, not an implemented sluice action.

[Harlan package](../../art/exports/NPC_04_PACKAGE.md) records actual interfaces.
Custom square mature face, close brown/gray beard, short tousled gray-templed hair,
teal working vest/brass buttons, rust scarf/brass slide, rolled cream sleeves,
brown trousers/boots derive from viewed source. Hidden surfaces are stylistic
adaptations. Reused calibration rig/clips have custom newly authored skin, not
a recolored generic actor. No invented semantic action/routine. Idle/facing
ordinary; walk review-only.

## Criteria and evidence

| Criterion | Evidence and precise claim |
| --- | --- |
| Fresh ordinary physical contact/introduction/follow-up/public fact/revisit | Owning renderer `write`: shared bounded `TestRunJourney.walk`, actual viewport E/pointer/Esc and source portrait UI. No teleport/flags/branch seeding. Work/weather/hobby select exact authored nodes; three facts learned once and visible on repeated return. |
| Alternative introduction and exclusive receipt | Fresh isolated `neutral` takes passing (+0) versus writer's careful (+1); both traverse all public branches at level zero. Stale alternate command rejects without memory change; rule suite exercises both source alternatives/replay rejection. |
| Full enabled/deferred graph coverage | `npc_dialogue_rule_checks` visits all58 enabled nodes/38 choices across eight graphs, including Harlan's seven nodes/five choices. Source gift target/choice deferred; disabled gift pointer command inert with honest UI reason and valid Close/Esc. |
| Public disclosure only/no service or campaign reward | Exactly source public-role/shared-checks/shore-birds. Writer/neutral assert no quest effects, companion trust or item reward and no other person's memory. Content/source audits forbid drift; source graph contains no accident/private testimony, campaign command or control/travel transaction. |
| Dry feet/full approach/water-negative clearance | Owning738-assertion skin/world fixture invokes production nine-point full-capsule/approach/navigation/LOS gates. Three rejected feet `(35,0,25)`, `(41,0,24)`, `(38,0,25)`. Shared world checks sample all-eight physical route support on current geometry. Ordinary dry lane round-trip visits approved quay approach `(34.5,0,20)` and returns to Harlan. |
| Lamp/rod arbitration | Owning synthetic actual four-person world checks require dry reachable selector approaches for dock-lamp-01..05, dock-row-lamp-01 and fishing-rod-dock-01. All seven selected deterministically; affected light/foraging checks exercise production input/commands. |
| Source identity/feet/scale/portable 3D art | Raw/source audits; actual imported skin sampled120Hz at481 idle/98 walk poses; both loop seams zero, soles ground-zero;196 stance/120 blend samples. Viewed front/profile/back/face, day/night loops/transitions and actual production day/night/rain/default-distance survey. |
| Lifecycle/one noncombatant after travel/retry | Owning actual root fixture checks dialogue/pause/focus holds, freeze/resume, disposal on travel, one replacement on return/retry, unchanged two Party/session actors. Other named skin suites pass with current registry. |
| Exact manual save/separate-process restart/prior state | Writer invokes actual GUI Save at verified pause; new `read` startup has no implicit memory/autoload, invokes GUI Load and `TestRunSnapshot.compare_restored` against exact whole-state/forecast oracle and typed disk, then physically walks/reopens all three facts. Independent synthetic save-process pair and strict save suite supplement ordinary proof. |

## Commands, isolation and retained failures

All runner commands use PowerShell7 from
`D:/development/game-dev-blender/returning-fair-prototype`, installed console
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
Godot4.7.2 Mono Compatibility. Each case has fresh isolated
`builds/testing/N011/<run>/appdata` and `localappdata` children/named slots;
render phases share only their explicit render group, synthetic process pair
its own group. No normal user save access. Full args/PIDs/exits/diagnostics/source
manifests/isolation are in schema2 `results.json`, not inferred from exit code.

First passing iteration:

```powershell
./tools/run_checks.ps1 -Task N011 -Names npc_04_checks,application_smoke -RenderScript npc_04_render -RenderPhases review,write,read,neutral -TimeoutSeconds 180
```

`docs/evidence/N011/20261008-125854163-a3a37977/`: all8 cases passed before visual
hair/jaw/shoulder refinement.738 owning assertions; ordinary write52/read14/
neutral42 assertions. Prior .blend/GLB retained under `art-before-refine/`.
Visual inspection, not numeric success alone, prompted scoped repair.

Final expanded command:

```powershell
./tools/run_checks.ps1 -Task N011 -Import -Names npc_04_checks,npc_01_checks,npc_02_checks,npc_03_checks,npc_content_checks,npc_dialogue_rule_checks,npc_save_checks,npc_world_checks,npc_asset_pipeline_checks,interaction_dialogue_checks,quest_checks,foraging_interaction_checks,light_interaction_checks,location_travel_checks,map_activation_checks,map_navigation_checks,application_smoke -ProcessScripts npc_process_checks -RenderScript npc_04_render -RenderPhases review,write,read,neutral -TimeoutSeconds 180
```

`docs/evidence/N011/20261008-130353486-aecdfeb8/`: all26 cases PASS/exit0,
zero forbidden diagnostics/timeouts/source changes,827 stable game/tools files,
SHA256 `eb618cbe4f64d297abbc510c08cd32dc9034a2e61ae3c95834b6cf31cf2c8729`.
All required/affected suites and synthetic process pair pass. Existing editor
import has only the exact allowed missing.NET SDK10.0.9 diagnostic; no C#
compilation claim. GDScript parse/runtime clean. No check guard or allowance changed.

Final visual review added owning test-only actual wheel input to reveal the third
public fact and full unavailable-gift reason, including after new-process restore.
Production/art are unchanged; manifest comparison finds only
`game/tests/npc_04_render.gd` differs from the26-case passing run. Focused command:

```powershell
./tools/run_checks.ps1 -Task N011 -Names npc_04_checks,npc_dialogue_ui_checks,application_smoke -RenderScript npc_04_render -RenderPhases review,write,read,neutral -TimeoutSeconds 180
```

`docs/evidence/N011/20261008-131017190-309a93bd/`: all9 cases PASS/exit0,
827 stable files, SHA256
`bc46e28e85e43e0e4557930ec00f0f36a3c14ce54f738e261755432cd2b85423`.
738 skin/world/lifecycle assertions,384 affected UI assertions/48 portraits/eight
people,161 rendered assertions including evidence writes. Final ordinary writer
PID25168/read PID66276 exact typed whole-state/forecast GUI comparison; neutral
PID31540 traverses all public branches at zero affinity. Studio/survey PID10116
is explicitly synthetic. Every owned case exits0; no forbidden diagnostics,
timeout, source change/error, normal-save access or residual failed criterion.

Actual idle maximum height1.580397m; minimum soleY0; both imported seams0.
196 stance samples maximum slide1.9073486e-6m at.8m/s,120 blend samples maximum
vertex step.012204223m without ground penetration. Current all-eight physical
fixture checks10,254 assertions including full-route samples and all existing
contacts. Source132-hash/67-output read-only conversion and source Git cleanliness
rechecked after validation; all other art/content/geometry bytes preserved.

All64 final PNGs decoded960x640, hashed and viewed in six
`render/all-captures-01..06.png` sheets. Full-size source portrait/idle sheet,
front/face/profile/walk, introduction/hobby, scrolled public-fact/disabled-gift
UI and night/rain/default-distance views inspected.39 pause/dialogue records
pass unmodified `tools/capture_evidence.py` in
`render/derived/20261008-131238-e1e0e682/capture-report.json`.
The25 studio frames retain separate labeled clip/PID/sample provenance.
Initial helper manifest key error (`captures` instead of supported `views`)
was corrected in task-owned evidence only; no validator change or guard bypass.

Final intended diff/link/status/hash/process audit is retained in latest run.
Owned runner/engine/helper processes exited. Original live Blender scene/file
preserved; owned Harlan scene available. No editor cleanup, blocker or unrun N011
criterion. Exactly N011 complete. Remaining N012,N013,N014,N015,N016,N017,N018;
next eligible N012. All through N018 are not complete. Stop; no commit/push.

Retained failures: sandbox runner observation Access denied in
`20261008-125706859-c7717a28` resolved by approved isolated elevated execution;
`20261008-125732955-7a9d0ffb` correctly invalidated first import's generated
UIDs/palette/import settings; `20261008-125807672-ef6b886d` correctly invalidated
loop-settings normalization. Stabilized before acceptance. Preflight
`20261008-130310367-9fc9445c` rejected nonexistent `map_runtime_checks`; used
actual map_activation_checks/map_navigation_checks afterward. No guard relaxed.

First MCP invocation defined module but did not execute main guard; explicit
owning `build()` followed. No absent asset claimed as built. Live MCP preserved
RF-RecoveryVessel original scene/file and other character assets. Task-only
refinement retained previous assets before replacing the unedited owned scene.
Background normalize/read-only source audit use explicit owned .blend path;
Python raw/source conversion reports and logs remain under `preflight/`.

Final raw GLB audit: 304,660 bytes,7,387 triangles,16 bones,one material/32x32
packed PNG,no external URI/camera/driver/gameplay. Idle4s/walk.8s raw endpoints
exact zero, no root motion. GLB SHA256
`7ea634f11a34a5962a67fac2cba77fec27399627d8112b7e9804c154976d5c2b`;
editable .blend SHA256
`dd1721d4233efd556597778d539646fd47a573e2420860de57f5c0be214ac479`.

Walk remains review-only; synthetic art/weather/physical fixtures are distinct
from ordinary viewport routes. Native new-package/all-eight integration acceptance
belongs to N017/N018. No successor implementation, commit/push, installation,
agent/chat/schedule, publication or external message.

## Authorized N011 commit follow-up — 2026-10-08 UTC

User authorized committing successful N011 implementation/art, reusable checks,
acceptance report and checklist/durable-state/discovery documents. Preflight
verified exactly23 task paths, all827 accepted runtime/tool files and final
GLB/.blend hashes; no unrelated or staged work. Runtime/art bytes and task
statuses remain unchanged. Raw evidence stays ignored under existing policy.
Fresh commit scope/tree/identity/status audits are retained in the final local
N011 run. Commit identity is available in Git history and follow-up report.
No push or N012 implementation.
