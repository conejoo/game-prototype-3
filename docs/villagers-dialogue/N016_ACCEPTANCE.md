# N016 acceptance — source-mapped semantic action art

Completed 2026-10-08 UTC. Exactly N016; N017/N018 remain Pending. No commit/push.
Target started clean at `dae77459e99e90e149689e24a1452e7cfe42cd8e`; read-only source
started and remains clean at `60c20eb2816e7271fb84afaba286af006ebe3ccf`.
N007/N008/N009 prerequisite packages, editable sources, actual presenter/owner APIs
and accepted ordinary assets were inspected. No other agent conversation was used.

[NPC_ACTIONS](../../art/exports/NPC_ACTIONS.md) records delivered files, repeatable
authoring/export workflow, actual APIs, material/rig budgets and exposure policy.

## Every selected acceptance criterion

| N016 requirement | Implementation and evidence | Result |
| --- | --- | --- |
| Actual Edric river-fishing and Helena archive-work references | Both pinned public action sheets viewed at full resolution. Source fishing is a two-hand rod lift/lower; archive work is handheld open-book checking/page stroke. Reference hashes below; no invented desk/minigame/director. | Pass |
| Exported real named 3D action clips/accessories | Two separate portable variants and normal editable action mainfiles. Each has original named body, 16-bone rig, matching supporting-hand skinned accessory, embedded palette, idle/walk and one four-second source-mapped loop. Raw and Blender source audits pass. | Pass |
| Identity preserved through idle/walk/action/interrupt | Original body position/normal/UV/joint/weight/index values match original GLB exactly. Editable geometry/UV/weights and original idle/walk F-curves match original .blend exactly. Viewed front/profile/back, all phases and entry/exit show retained faces/costumes and coherent accessory grips. All eight ordinary original assets remain unchanged. | Pass |
| Feet/accessory alignment and safe transitions | 481 deformed action samples/person, zero ground penetration, zero planted-foot drift, zero endpoint seam. Every accessory influence is exactly its supporting hand. Actual .12s entry/walk/action/exit mixer samples pass ground/continuity bounds. First failing rod grip was repaired and previous art retained. | Pass |
| Dialogue/pause/focus/travel safely freeze/cancel and resume | Real automatic frame processing freezes exact pose/time with overlapping pause/focus holds. Pending real blend also freezes without snapping and resumes without restarting. Dialogue/travel/modal/death cancel action and hide prop, then resume idle. Actual GameRoot pause/focus/dialogue hooks exercised by explicitly synthetic variant mounting; actual travel frees presenters/accessories and return reconstructs ordinary original assets once. Wrapper identity/transform and eight contacts/two-member party retained. | Pass |
| Review scene displays both real assets; honest exposure | `res://tests/review/npc_action_review.tscn`, visible Idle/Walk/Action/Pause/Resume controls and explicit review label. Original registry mapping/feet unchanged. Neither action is ambient: civic contact is not a river, no approved archive-work/routine consumer exists, and measured action props exceed .4m contact reservation. Ordinary idle, review-only walk/actions documented separately. | Pass |
| No leaked Blender drivers/gameplay attached to art | Source objects have zero drivers/constraints. Raw GLB contains only 48 transform channels per clip, no root motion/external URI/extensions/camera/light. Presenter rejects non-transform semantic tracks/missing or unrecognized action accessories. No catalog, fact, outcome, item, routine, reward, memory/save/schema or geographic file changed; pure art/holds leave exact conversation snapshot unchanged. Deferred source consumers remain deferred. | Pass |
| Required action/pipeline/dialogue checks, actual Godot day/night transitions, source-independent runtime names/materials | Final 20-case shared-runner pass; owning 1,814 assertions including evidence write, all eight named asset/lifecycle checks and dialogue UI/rules/save/world regressions. 45 current Compatibility framebuffer captures viewed in five sheets plus full-size selected frames. Raw audit and retained import records prove named clips/PBR/palette available entirely from bundled game assets. | Pass |

## Commands, versions and isolation

All commands ran from `D:/development/game-dev-blender/returning-fair-prototype`,
PowerShell7. Executables verified before use: installed Godot console
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
Blender `C:/Program Files/Blender Foundation/Blender 5.2/blender.exe` (5.2.2 LTS),
analysis Python `C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe`.
Existing Blender MCP helper at
`C:/Users/aldoc/.codex/skills/text-to-blender/scripts/mcp_client.py` inspected live
scene, then invoked owned build/refinement entries; no install/config replacement.
Live original scene was `RF-RecoveryVessel`, 21 objects, empty mainfile path;
authoring restored that scene after each operation. Original named sources retained.

Final command:

```powershell
./tools/run_checks.ps1 -Task N016 -Import -Names npc_action_checks,npc_asset_pipeline_checks,npc_01_checks,npc_02_checks,npc_03_checks,npc_04_checks,npc_06_checks,npc_07_checks,npc_08_checks,npc_14_checks,npc_dialogue_ui_checks,npc_dialogue_rule_checks,npc_save_checks,npc_world_checks,interaction_dialogue_checks,application_smoke -RenderScript npc_action_render -RenderPhases review -TimeoutSeconds 150
```

Final [results](../evidence/N016/20261008-160510124-2f0aad9c/results.json):
20/20 cases Pass, `4.7.2.stable.mono.official.ed1daf0bf`, no timeout/forbidden
diagnostic/source change/error. Stable game/tool manifest has 874 files,
SHA256 `cf2300d9d660a52830bb1a92246e18011fa663b1d9ab20e8ad4d587e57db3e01`.
Pre-existing import-only `.NET Sdk not found ... 10.0.9` diagnostic remains in
the runner's explicit allowed list; runtime uses typed GDScript/Compatibility.
Shared runner's child-process observation required authorized sandbox escalation;
its guards were retained. Each headless case has a fresh APPDATA/LOCALAPPDATA/
named save slot under `builds/testing/N016/20261008-160510124-2f0aad9c/`; rendered
review has its own group. Per-case arguments, launcher/engine PIDs, logs, isolation
and source manifests are in results. No normal user save was accessed.

Editable/raw validation commands:

```powershell
$analysisPython = 'C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe'
$blenderExe = 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe'
& $blenderExe --background 'D:/development/game-dev-blender/returning-fair-prototype/art/source/npc-01-actions.blend' --python 'D:/development/game-dev-blender/returning-fair-prototype/art/source/check_npc_actions_source.py' -- 'D:/development/game-dev-blender/returning-fair-prototype/docs/evidence/N016/20261008-155940832-d2add5eb/npc-01-source.json'
& $blenderExe --background 'D:/development/game-dev-blender/returning-fair-prototype/art/source/npc-02-actions.blend' --python 'D:/development/game-dev-blender/returning-fair-prototype/art/source/check_npc_actions_source.py' -- 'D:/development/game-dev-blender/returning-fair-prototype/docs/evidence/N016/20261008-155940832-d2add5eb/npc-02-source.json'
& $analysisPython art/source/audit_npc_actions.py --output docs/evidence/N016/20261008-155940832-d2add5eb/raw-actions.json
& $analysisPython tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
& $analysisPython art/source/npc_action_contact_sheets.py docs/evidence/N016/20261008-160510124-2f0aad9c
```

Both [editable source reports](../evidence/N016/20261008-155940832-d2add5eb/npc-01-source.json)
and [Helena report](../evidence/N016/20261008-155940832-d2add5eb/npc-02-source.json)
pass; [raw report](../evidence/N016/20261008-155940832-d2add5eb/raw-actions.json) passes.
Those artifact bytes are unchanged in final validation, verified by final audit.
Source converter checks all 132 authority inputs and 67 bundled outputs, exact
eight-person roster/48 portraits/18 sheets; catalog SHA256
`9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.
Source Git used process-local `-c safe.directory=D:/development/game-prototype-2`
for read-only ownership checks; no global configuration or source write.

## Measurements, hashes and visual inspection

| Measure | Edric | Helena |
| --- | --- | --- |
| Triangles / bones / material surfaces | 7,686 / 16 / 2 | 8,497 / 16 / 2 |
| Action duration / raw endpoint seam | 4s / 0 | 4s / 0 |
| Imported action seam / planted-foot drift / real hold drift | 0 / 0 / 0m | 0 / 0 / 0m |
| Action max vertex movement at120Hz | .006241084m | .000657136m |
| Entry/walk/action/exit max vertex movement at120Hz | .135230139m | .057636339m |
| Deformed action bounds min (Godot XYZ) | (-.2999873,0,-1.0849985) | (-.3415961,0,-.454) |
| Deformed action bounds size | (.5995696,1.6105237,1.2359986) | (.7023140,1.5616773,.6019107) |
| Accessory support | hand.R | hand.L |
| Packed embedded palette | 32x32 RGBA | 32x32 RGBA |

The rod's large entry blend moves farther than the body; .20m/frame was the explicit
whole-accessory continuity cap, while action loops stay below .04m/frame. No wrapper
movement or ground penetration occurs. Ordinary contact physics stays unchanged.

| File | SHA256 |
| --- | --- |
| npc-01-actions.glb | eda2b6639a8229baf90d9220367156a63cc46ab00f9cae414bb76d125ef09544 |
| npc-02-actions.glb | 61d668f5976ea5f3d93b2e770bfd0357d4585daf0d3b87245b6f94787268a330 |
| npc-01-actions.blend | 73b97d3973ccc8f04e64d7736eca82170c936c9f5fbdc6609c8619f8f27bfc25 |
| npc-02-actions.blend | 342828b29a47c6ed4e553dcdd601082e8eb453d3e0259ef422cd2cdfb4023220 |
| pinned npc_01_river_fishing_sheet.png | 9744b485513ecbe5b00c176eb5229f7a42f308c4d48ce4400093f62da0368b74 |
| pinned npc_02_archive_work_sheet.png | a874907c43823f50bfd4d49a4c191bb97f6a5ee5790aa29d88bfab7900d2cae8 |

All 45 final960x640 images in
[capture index](../evidence/N016/20261008-160510124-2f0aad9c/render/npc-action-captures.json)
were viewed in five actual-render contact sheets. Full-size final inspections:
`day-enter-07`, `day-paused`, `day-interrupt-07`, `profile`, `back`,
`night-action-50`. Prior passing run's full-size day action0/50, profile and night
action50 also inspected. Frames show named faces/costumes, supporting-hand book,
two-hand rod, controlled entry/exit and day/night readable silhouettes/accessories.
Book/rod are hidden for idle/walk and after interrupt; held pose retains props.
Front projects much of the rod along viewing axis; profile/back disclose its real
length/angle. Default gameplay camera sample is explicitly art scale review.
No whole-scene flicker, new disconnected accessory, body identity substitution or
visible clipping was accepted. Existing named stylization is retained.

## Retained failed attempts and bounded repairs

- `155055164-a0fc1379`: sandbox child-process observation Access denied; no runtime
  acceptance. Authorized runner escalation used for subsequent attempts.
- `155344932-fc4235f9` and `155415943-ac662904`: new/generated import metadata
  correctly invalidated runs. Generated UIDs/palette imports/loop settings retained;
  later runs used stable bytes. No source guard disabled.
- `155530938-b1fa9e72`: rod inverse-bind grip pointed downward during idle/action
  blend; failed ground bounds. First .blend/GLBs retained in `first-art/`, original
  generated scenes retained with before-grip-refine names. Hands reoriented so rod
  remains above ground even in transitional poses; source/body identity retained.
- `155820047-1bf1e133`: retained Blender object suffixes caused strict missing/
  unrecognized accessory rejection. Owned normalizer canonicalizes four names;
  importer/presenter guards stayed strict.
- `155940832-d2add5eb` and `160052638-a0b3a5eb`: test forcibly advanced the underlying
  paused AnimationPlayer and re-evaluated mixer, producing failed freeze evidence.
  Freeze tests now use real automatic processing, not an evaluator bypass; presenter
  also uses `pause()` to retain pending blend. Official
  [AnimationPlayer pause semantics](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html#class-animationplayer-method-pause)
  support same-animation resumption. Mid-blend real focus check passes in final run.
- `160222035-eebb91e1`: first full focused pass, 7/7 cases and45 inspected captures.
  Final expanded run adds all-eight affected regressions and pending-blend proof;
  no accepted art bytes changed between these passing runs.

Initial helper raw audit had a Python path-concatenation error, repaired before its
first successful raw report; no asset was changed by that read-only failure.

## Handoff, limits and stop

Owned changes: action build/normalization/audit/contact-sheet helpers, two editable
variants/GLBs/imports/palettes, explicit presenter API/holds, owning checks/renderer/
interactive review scene and concise package/acceptance/workflow discovery docs.
No original named source/GLB, portrait/graph, NPC placement/registry, save format,
geography, recovery/companion/ship/gate or source-project file changed.

All acceptance criteria pass; no remaining N016 blocker or unrun criterion. Raw
evidence remains ignored under existing policy. All owned runner/Blender/helper
processes exited; original live Blender scene remains selected. Tests are synthetic
art/owner proof and affected regressions. Fresh integrated ordinary eight-person
route/persistence/recovery acceptance remains N017; new native packages remain N018.
Remaining N017,N018, next eligible N017. All items through N018 are not complete.
Stop after exactly N016; no successor implementation, agent/chat/schedule,
publication, installation, normal-save access, commit or push.

## Authorized commit follow-up

After this completed execution, the user authorized committing successful N016.
Preflight verifies exactly35 task paths, all874 accepted runtime/tool bytes and
four final GLB/.blend hashes, with no unrelated or pre-staged files. The commit
includes this concise acceptance report; generated raw runs/captures/appdata stay
ignored under existing repository policy. No implementation/art changes, push
or N017 work occur during commit follow-up. Verified identity and clean working
tree result are recorded in Git history, final local audit and follow-up report.
