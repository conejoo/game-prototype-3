# N007 acceptance — reusable rig and Godot animation pipeline

Completed 2026-10-08 UTC. Exactly N007; N008 has not started. No commit or push.

## Result and authority

Delivered an editable generic articulated calibration .blend, actual skinned GLB,
baked idle/walk loops, a transactional VisualRoot presenter, an eight-rig review
scene, raw/source audits and Godot checks/captures. This is diagnostic pipeline art,
not Edric or another completed villager. Production NpcRegistry.ENABLED stays empty.

Target began clean at `737c0cb45ff5abda47f9d0b6b0dd8f61950a6e33` (N006 committed).
Source stayed clean at `60c20eb2816e7271fb84afaba286af006ebe3ccf`. N001/N002 actual
local source content, geometry/placement contract and N006 wrapper were inspected;
read-only conversion verified all132 authority hashes/67 outputs. Required source
action names are `river-fishing` / `archive-work`; their real art remains N016.
Source files, prior runtime, schema7/content1 and pinned map were not changed.

## Files and interfaces

- `art/source/npc_calibration.blend`, builder/normalizer and read-only source/raw
  audit scripts; `art/exports/npc_calibration.json` / `NPC_PIPELINE.md` and a narrow
  extension of historical PIPELINE.md.
- `game/assets/models/npcs/npc_calibration.glb`, retained import UID/settings and
  Godot-extracted checker PNG/import metadata. Source/GLB hashes below.
- `NpcVisualPresenter` and UID: `mount(PackedScene, walk_speed)` returns errors;
  rejects without replacing an accepted model. `set_locomotion(achieved_speed)`
  selects/rates actual exported loops; `face_direction` rotates only visuals.
  Independent `suspend(reason)` / `resume(reason)` holds freeze real pose.
- `NpcAssetProbe`, pipeline checks/render script with UIDs and labeled
  `res://tests/review/npc_asset_review.tscn` / script. Review is outside GameRoot.
- Checklist, contract, current state and this tracked acceptance summary.

No existing game/tools implementation was edited. Physics, IDs, party, content,
source portraits, map, manual saves, player/ally assets and previous art stay intact.

## Acceptance evidence

Final shared run: `docs/evidence/N007/20261008-103647902-04ca9996/`.
All six cases PASS/exit0, no forbidden diagnostics, timeouts or source changes.
Version + parse + npc_asset_pipeline_checks + asset_pipeline_checks +
application_smoke + render-review. 832 pipeline assertions including evidence write
(831 in JSON); 25 actual 960x640 Compatibility captures. Source manifests contain
795 game/tools files, stable digest
`b757aae1e0c578535697173b82f4719dad25b6f7c5ca5d36630d3a52a03a3f21`.

| Selected criterion | Verified result / evidence |
| --- | --- |
| Measured rig/unit/axis/foot/material/clip contract and reusable workflow | NPC_PIPELINE.md extends static rules; normalized source opens active RF-NpcCalibration with3 objects/16 bones/two NLA clips, identity transforms, packed image, no constraints/drivers. `editable-source-audit.log` PASS. |
| Real exported skeleton and clips, not Blender-only drivers | Raw GLB contains16 joints/48 baked transform channels per clip, zero external URIs, no camera/light extension. Imported player has23 retained transform tracks per loop; source/raw/Godot audits agree. |
| Correct meter scale and ground origin | Root/presenter identity; idle max height1.560481m, width0.68m; soles min0. Godot samples and viewed close/profile show full body and -Z front markers. |
| Idle/walk names, loops and portable material/texture | Idle4s, walk0.800000012s; linear imported loops. Raw first/last values match exactly; imported endpoints independently checked. Opaque three StandardMaterial3D surfaces, one decoded32x32 checker with UVs; embedded PNG bytes verified. |
| Measured animation envelope and planted feet | 120Hz CPU-deformed skin: idle bounds `(-.34,0,-.189467)` size `(.68,1.560481,.309467)`; walk `(-.340523,0,-.34)` size `(.681046,1.560196,.6)`. No ground penetration/head spikes. 196 actual exported stance samples over two cycles, both feet and .8m/s wrapper motion: max drift1.1920929e-7m, sole-height error1.7881393e-9m. |
| Stable transitions/lifecycle | Four real idle/walk blends: max120Hz vertex step0.012539962m, no sunk soles; nested dialogue/pause/focus/travel holds keep exact frozen pose until last resume. Invalid speeds/facing/replacements preserve accepted state; actual wrapper travel disposes presenter. |
| Wrapper owns collision and IDs | Synthetic production contact mounting keeps `alderwake-npc-01-contact` / npc-01 and unchanged body transform, radius.4m/height1.6m capsule. Default production has no contacts; calibration stays review-only. |
| Current renderer and actual viewed Godot clips/transitions | NVIDIA RTX4070 Laptop / driver581.29 / OpenGL3.3 Compatibility; day/night eight-rig loop phases, close/profile, default overhead scale, blends and paused pose captured and inspected. Corrected earlier profile cropping. No flicker, disappearance, stretch spike, detached foot or texture failure observed. |
| Exact budgets grounded in eight-actor estimate | Calibration204 triangles/16 bones/3 surfaces each => eight1,632 triangles/128 bones/24 main surface draws. Shared production caps12,000 triangles/32 bones/3 surfaces =>96,000/256/24 for eight; one1024² RGBA atlas per person estimates32MiB before mips/42.7MiB with mips. Shadow-pass cost explicitly counted in pipeline. Review120 frames median4.157ms/p954.338ms; this includes scheduling and is not a full-map performance guarantee. |
| Production tools confirmed, historical pipeline preserved | Existing Blender MCP5.2.2 live connection, installed Godot4.7.2 paths/version and historical static asset regression all verified. No dependency installation. Existing live RF-RecoveryVessel scene restored; source file never overwritten. |

`checks/npc_asset_pipeline_checks/npc-asset-pipeline.json` contains measurements.
`render/npc-render-captures.json` records clip/time/light/view/PID/dimensions.
`render/eight-rig-timing.json` contains timing estimate. Raw/source audits are at
the run root; `results.json` and numbered logs remain authoritative.

GLB SHA256 `bf0cd0135c4f9401b62496699690377981cb82e5ab5f74ea2c0ba49249b89eee`
(84,476 bytes). Editable .blend SHA256
`b2d97e827bdd39ba676a9f332b7164aca6f3b69f63d4b3e941d5430843061d39`.
Catalog remains
`9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.

## Commands, isolation and visual inspection

All commands below use target repository root, PowerShell7, installed console path
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
Analysis Python is `C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe`.
MCP helper is `C:/Users/aldoc/.codex/skills/text-to-blender/scripts/mcp_client.py`.

```powershell
& $python tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
& $python art/source/audit_npc_calibration.py --output docs/evidence/N007/20261008-103647902-04ca9996/raw-glb-audit.json
./tools/run_checks.ps1 -Task N007 -Names npc_asset_pipeline_checks,asset_pipeline_checks,application_smoke -RenderScript npc_asset_pipeline_render -RenderPhases review -TimeoutSeconds 150
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background 'D:/development/game-dev-blender/returning-fair-prototype/art/source/npc_calibration.blend' --python 'D:/development/game-dev-blender/returning-fair-prototype/art/source/check_npc_source.py'
```

The source checker only reads and never saves; separate normalization was run
with the same background/source paths and `normalize_npc_calibration.py`.
The builder ran through existing MCP with a temporary invocation explicitly setting
`__name__='__main__'`; one scoped re-export corrected the zero-time option.

Fresh `builds/testing/N007/20261008-103647902-04ca9996/{appdata,localappdata}`
containers and per-case named slots isolate engine processes. Results record
actual child paths, launcher/observed engine PIDs and exits; no normal saves used.
Static asset regression performs its existing synthetic manual Save/Load in isolation.

Viewed all25 captures through day/night loop sheets, transition/paused sheet and
full-size close/profile/overhead/day-walk/night-idle/blend/paused frames. Sheet paths
are `render/{day-loops,night-loops,transitions,views}-sheet.jpg`; the first three
sheets plus individual views were directly inspected. Frames show intentional generic
checker geometry. Review roots stay stationary for in-place preview; planted-world
motion is separately proved by the CPU fixture, not attributed to ordinary input.
All captures are synthetic review/rule evidence. No UI/route/native-release claim.

Final supplemental audits: `final-audit.json` verifies all795 runtime/tool bytes,
42 local links, task/status consistency, asset hashes and clean source;
`visual-review.json` binds all25 inspected captures to SHA256/dimensions;
`process-audit.json` confirms zero live owned engine PIDs across retained attempts.

## Retained failed/superseded attempts

| Attempt | Failure / repair |
| --- | --- |
| `20261008-102743613-e050e457` | Sandbox owned-process observation denied at import; runner retained failure and cleaned its process. Auto-review approved isolated execution; no current permission blocker. |
| `20261008-102808183-82922198` | Import generated GLB/PNG/import/UID metadata; strict source-change guard stopped the run. Metadata retained; no guard weakened. |
| `20261008-103018064-9f410300` | Loop import settings normalized and two test UIDs generated; retained as source-change failure. |
| `20261008-103046706-d68072ce` | Export frame1 offset made clips4.0333/.8333s and stance drift.0333437m. Wrapper fixture also guessed a generated collision node name. Enabled export_anim_slide_to_zero and used the actual first CollisionShape3D child; wrong fixture assumption removed. |
| `20261008-103326557-2b49d808` | Two review script UIDs generated at import; source guard correctly failed before checks. |
| `20261008-103347090-89ae9ce8` | Earlier six-case pass/24 captures. Visual review found profile crowd cropping; isolated one full actor and added close front view. Raw/source audits and final stronger endpoint checks supersede this run. |

Supplemental prep: first MCP script returned without executing its guarded main;
explicit invocation corrected that before claiming an asset. Raw audit initially
rejected STEP export channels; inspection proved those channels immutable, and
the audit now requires equality of every STEP value. Moving channels remain LINEAR.
One documentation patch used a wrong context and one image read used a wrong
subdirectory; both failed without altering artifacts and were corrected.
Blender sandbox preference-read warning did not alter configuration or source;
existing addon reported current protocol11/addon1.7. Import-only missing SDK10.0.9
diagnostic remains the runner's unchanged historical allowance; no C# installation.

## Limits and continuation

No remaining N007 criterion, unrun required check or blocker. Runtime named assets,
actual modal/root hookups and ordinary contacts belong to N008-N015. Calibration
walk stays review-only; N016 owns semantic clips, N017 live integration/performance,
N018 native package acceptance. Night studio is not world weather proof. Budgets
are explicit estimates with actual eight-rig timing, not maximum-cost map certification.

Existing Blender was preexisting and remains open on RF-RecoveryVessel; the owned
RF-NpcCalibration scene remains available in memory for inspection. No owned game,
helper or background audit process remains. No editor closure/cleanup, source writes,
normal-save access, installation, agents/chats/schedules or external publication owed.
Raw evidence/builds are ignored under repository policy; this acceptance is tracked.

Next eligible N008 (Edric first vertical slice). Remaining N008-N018; all through
N018 are not complete. Stop after N007; commit only when separately requested.
