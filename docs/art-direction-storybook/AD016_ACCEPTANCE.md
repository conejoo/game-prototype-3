# AD016 Tollworks acceptance

Done 2026-10-11 UTC. Every AD016 criterion verified; blockers and required unrun checks: **none**. Exactly one task completed. AD017-AD020 remain Pending; every checklist item through AD020 complete: **no**. Implementation turn stopped before staging/commit/push. User now authorized successful-task commit including acceptance evidence; follow-up recorded below.

## Appearance and preservation

Current compact Tollworks uses cool worn slate `#4d5d63` for its combat floor and softer grey stone `#858b85` for its four walls. Broad brush treatment reuses accepted town atlas and inn triplanar shader:64texels/metre,existing stone patch origin(528,528)/span(224,224),16px gutters,mirrored folds,linear mipmapped/clamped sampling,0.70 stroke strength,roughness0.92. All six faces intentionally covered;two immutable cached materials shared across five meshes/reloads. No new texture/import,geometry,surface,node,emitter or durable field.

Existing AD011 vessel/plinth and AD013 guardian/party remain byte-identical. Bronze/timber warmth and teal role accents provide restrained contrast against cool stone. Existing room has no additional timber structures;none invented. Editable [recipe](../../art/source/storybook/tollworks-painted-recipe.json) records boundary. [Adapter](../../game/world/storybook_tollworks_material.gd) sets appearance only;[scene](../../game/world/tollworks.tscn) gains one resource declaration plus five visual script attachments. Remove overrides to recover original flat BoxMesh materials.

[Audit](../evidence/AD016/authoring-20261011/acceptance-audit.json) strips exactly those six attachment lines and verifies every other scene byte against starting HEAD `42ce563d43cbff3f400515b4a56c26b56b64c51a`. Original floor/wall/plinth dimensions,transforms,six room/plinth colliders,vessel collider,guardian capsule,arrival/recovery/combat/exit anchors,IDs/navigation/torus/labels/developer fixtures unchanged. Gameplay,quest,input,weather/light owners and schema8/content1 preserved. Shared inn shader reused without editing it or inn/home sources.

Eight task paths:recipe,room scene,adapter,two reusable fixtures,this acceptance,CHECKLIST,CURRENT_STATE. Preservation:**3,262 starting /3,259 protected files**,zero unexpected changes,including unrelated direction/interiors/user instructions and earlier accepted art. No external source checkout or other conversation used. No applicable additional repository AGENTS or `.agents/skills` found. Workspace instructions,active workflow/look/baseline/architecture,static asset contract,AD008/AD011/AD013/AD015 acceptance/evidence and versioned testing/art guidance read.

Read-only [source inspection](../evidence/AD016/authoring-20261011/blend-sources.json) opens guardian,recovery_vessel,tollworks_plinth in separate background Blender5.2.2 LTS without saving;all three source hashes unchanged. Chosen concept,existing atlas and current material owners inspected. Live Blender/editor untouched;no export/live connection needed for native box-material adapters.

## Final gates

Cwd `D:/development/game-dev-blender/returning-fair-prototype`;PowerShell7,supplied Godot4.7.2 Mono console,GL Compatibility960x640. Runner isolates APPDATA/LOCALAPPDATA/save groups under `builds/testing/AD016`;ordinary user saves untouched.

~~~powershell
./tools/run_checks.ps1 -Task AD016 -Names application_smoke,storybook_tollworks_checks,asset_pipeline_checks,combat_checks,recovery_presentation_checks,location_travel_checks,environment_lighting_checks,environment_lifecycle_checks -RenderScript art_direction_tollworks_render -RenderPhases paint,input-ortho,input-perspective -TimeoutSeconds 180
~~~

[Final report](../evidence/AD016/20261011-112536683-8b797983/results.json):**13/13 passed,exit0**,empty diagnostics. Engine/recursive parse gates,application smoke,58 new material/cache/physical-pin assertions,original static import/wrapper/collision/navigation/selector/quest/save checks,combat windows/damage/LOS/dodge/retry,existing recovery presentation,ten travel round trips/rollback,30,053 lighting and157 environment lifecycle assertions pass. All original assertions/source pins retained;no existing suite edited.

Source.changed=false,error=null;stable **1,404-file SHA256 `222c5a20f51fabf25c1bdbc96bfeb2e3a7f9ed61a67d634b460f0b0a9375b502`**. All current game/tools bytes reverified after visual/source inspection;no production/check edits after validated run.

[Capture report](../evidence/AD016/20261011-112536683-8b797983/render/derived/20261011-112746-6017070d/capture-report.json):**46 actual Godot images/four provenance sheets**,all inspected plus full-size perspective combat floor,orthographic guardian windup and actual recovered-vessel GUI.22 synthetic paint views cover entry/combat/vessel,both projections,0.8/1.15 combat zooms,eight exact before/after pairs,clear day/storm night,four whole-room surface angles. Original controls remove five room overrides only;camera/party/guardian feet,feedback,sun/environment match exactly. Audit verifies32,670 all-face sampling probes inside safe stone patch and **zero changed world pixels** in fixed ROI(0,170)-(960,510) between clear day/storm night. STABLE_INDOOR stays dry with no WorldRain/new indoor emitter.

24 input views use separate orthographic/perspective processes. Only quest lead/direct room transition synthetic. Subsequent real viewport A movement travels0.73333m with released keys;pointer/click/SPACE exercises windup/active/recovery,dodge,natural guardian0.75s windup. Additional bounded clicks plus autonomous companion clear guardian in1.998/2.049s resumed loop,hero75/50HP and ally50HP;no damage/health/AI mutation. Actual guardian-clear fact recorded. Successful TestRunJourney WASD routes reach vessel through unchanged navigation/collision. Actual E opens dialogue;Tab/Enter chooses recovery path;rendered response and `maris-return-path-open` fact verified. Esc closes dialogue;final pause overlay verified,no held movement keys. Combined combat proves integration;focused combat suite owns isolated damage rules.

Guardian/vessel/exit visually distinct;cyan/purple party,gold/red/cyan combat cues readable against quiet floor in both projections. No visible atlas bleed,missing texture/surface,seam or clash with accepted bronze/teal props. Existing labels/HUD overlap remain AD017 scope. No ordinary exterior-route,native hardware input,GUI Save/Load,new-process restart,package or full performance acceptance claimed;AD018-AD020 own later integration/profile/delivery.

Capture validation and pixel/coverage/preservation audit used installed Blender Python3.13 with existing cached Pillow12.3.0,no installation. Exact commands retained below;all exit0. Python wrapper emits harmless real-location message;Pillow emits getdata deprecation during successful audit. Initial probes without cached Pillow failed import;no source/dependency changed.

~~~powershell
& 'C:/Program Files/Blender Foundation/Blender 5.2/5.2/python/bin/python.exe' -c 'import sys,runpy; sys.path.insert(0,"C:/Users/aldoc/AppData/Local/uv/cache/archive-v0/20FP8sDPf87Nj1oA"); sys.argv=["tools/capture_evidence.py","docs/evidence/AD016/20261011-112536683-8b797983/render/tollworks-paint-index.json","docs/evidence/AD016/20261011-112536683-8b797983/render/tollworks-input-ortho-index.json","docs/evidence/AD016/20261011-112536683-8b797983/render/tollworks-input-perspective-index.json"]; runpy.run_path(sys.argv[0],run_name="__main__")'
& 'C:/Program Files/Blender Foundation/Blender 5.2/5.2/python/bin/python.exe' -c 'import sys,runpy; sys.path.insert(0,"C:/Users/aldoc/AppData/Local/uv/cache/archive-v0/20FP8sDPf87Nj1oA"); runpy.run_path("docs/evidence/AD016/authoring-20261011/audit.py",run_name="__main__")'
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background --python 'docs/evidence/AD016/authoring-20261011/inspect_sources.py'
~~~

## Retained failure and cleanup

[Initial sandbox report](../evidence/AD016/20261011-112512333-7a6089b6/results.json) retains read-only owned-child CIM access failure at parse gate. Scoped elevation approved;no auto-review rejection. Same command then passes all final gates. No material/fixture repair needed after validation. Documentation write initially rejected a duplicate-path patch;corrected without partial source mutation.

[Cleanup](../evidence/AD016/authoring-20261011/cleanup-pids.json):all **28 recorded Godot launcher/engine/subprocess PIDs exited**;background Blender exits0. No held input,live owned Godot/editor/Blender mutation or cleanup owed. Whitespace,scope,source,paired-frame,coverage,weather,preservation audits pass. Historical R016 remains Blocked/incomplete;older route/draw observations remain in their own evidence.

Next eligible **AD017 only**,fresh invocation. Stop before HUD work. User now supplied separate reviewed commit instruction;no push.

## Authorized commit follow-up - 2026-10-11 UTC

User authorized successful AD016 commit after review,including acceptance evidence. Reverified all eight task hashes,1,404 validated source files,13/13 main cases,46 capture hashes and3,259 protected inputs before documentation-only follow-up edits. Runtime/check sources and original run reports unchanged;all prior failures/limits remain above.

Commit scope:eight AD016 task paths plus selected reports/logs/source manifests,46 final engine frames/four sheets,retained sandbox-failure report,source/preservation/pixel/process/pre-commit audits. Build/save archives,temporary scripts and unrelated direction/interiors/user prompt/contract stay excluded. [Commit review](../evidence/AD016/commit-review.json) records exact scope/hashes;local `docs/evidence/AD016/authorized-commit-20261011/commit-audit.json` records verified commit/tree/path/blob identity and final status after commit,outside commit to avoid self-reference. AD001-AD016 remain Done;AD017-AD020 Pending. No push or AD017 work.
