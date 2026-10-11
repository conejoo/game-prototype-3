# AD015 Lantern Rest acceptance

Done 2026-10-11 UTC. Every AD015 criterion verified; blockers and required unrun checks: **none**. Exactly one task completed. AD016-AD020 remain Pending; every checklist item through AD020 complete: **no**. The implementation turn stopped before staging/commit/push. The user has now supplied the separate successful-task commit instruction, including acceptance evidence; the authorized follow-up is recorded below.

## Delivered appearance and preservation

Existing Lantern Rest now shares warm painted oak/timber, cream plaster/linen, sage seating, restrained indigo breakfast/terracotta lounge rugs, quiet ceramics and blue-grey bedding/windows. All **118 existing boxes / 11 material families / 14 shared cached materials** receive intentional six-face coverage. Original StandardMaterial3D stays on each BoxMesh; removing the override reproduces previous inn colors. Families/counts: oak-floor2, plank-seam46, plaster7, timber33, upholstery6, rug4, linen6, worktop6, bed-cloth1, glass3, ceramic4.

Existing local 1024 town atlas/unchanged import settings supply64texels/m,16px gutters,linear mipmapped/clamped sampling and metre-aligned triplanar brush. Mirrored folds stay within each safe patch; patch/reference normalization occurs once. Roughness0.92, no shader emission, new texture/mesh/surface/node/emitter/durable field. [Editable recipe](../../art/source/storybook/inn-painted-recipe.json), [factory](../../game/world/storybook_inn_material.gd) and [shader](../../game/world/storybook_inn.gdshader) are task-owned sources. No Blender export or live editor connection needed for these procedural assets.

One appearance override line added to [original builder](../../game/world/lantern_rest.gd). Normalized comparison against starting HEAD `0e2e170e38222b022dc8b871b7c3bbad676b295b` proves every other statement identical. Both floors,46 seams,19 exact colliders,furniture/window/bed/rug shapes/transforms,host station/facing,party arrival,exit torus/portal,labels/navigation and four original unshadowed lamps remain. Lamps retain color(1,.75,.40),energy.65,range10. Layout/scene/portal/routine/gameplay/save bytes unchanged; schema8/content1 retained. Accepted home brush method reused in inn-owned shader, deliberately omitting home's geometry-specific partition correction; no home source changed.

## Commands and final gates

Cwd `D:/development/game-dev-blender/returning-fair-prototype`; PowerShell7; supplied Godot4.7.2 Mono console/GL Compatibility960x640. Runner isolates APPDATA/LOCALAPPDATA/save groups under `builds/testing/AD015`; evidence under `docs/evidence/AD015`. Ordinary user saves untouched.

~~~powershell
./tools/run_checks.ps1 -Task AD015 -Names application_smoke,storybook_inn_checks,routine_inn_checks,location_travel_checks,environment_lighting_checks,environment_lifecycle_checks,routine_portal_checks -RenderScript art_direction_inn_render -RenderPhases paint -TimeoutSeconds 180
./tools/run_checks.ps1 -Task AD015 -RenderOnly -RenderScript art_direction_inn_journey_render -RenderPhases journey -TimeoutSeconds 180
~~~

[Main report](../evidence/AD015/20261011-105844807-2a81f230/results.json): **10/10 passed, exit0**. Engine/parse gates;720 material/cache/atlas assertions;**1,997 original inn assertions /950 continuous capsule sweeps**;original host support/reach/LOS/public-room routes;ten travel round trips/identity/rollback;30,053 lighting,157 environment lifecycle,363 portal assertions;61 synthetic rendered views. No original assertion/source pin changed.

[Ordinary journey](../evidence/AD015/20261011-110024466-6860500b/results.json): **3/3 passed, exit0**,129 assertions including report publication (index snapshots128 before that final assertion),**29 images /seven guarded successful walking routes**. Fresh ordinary WASD/E/Esc/P/+/- enters at affinity0,reaches/selects actual Della through normal range/LOS,opens/closes dialogue,walks host/lounge/breakfast/guest-desk areas,both projections/zoom0.8/1/1.15,returns through reciprocal door and walks to town start. Full party grounded;post-dialogue memories/actual return spawn retained. Runtime navigation supplies explicit guidance; no placement/fact/time/weather/affinity setup or native hardware-input claim.

Both final reports:source.changed=false,error=null,empty diagnostics,matching stable **1,401-file SHA256 `90781252604f174bc20aa9a1cb426a181be2e75837b06f4bb89f2236c82016c7`**. No final production/check source edits afterward.

## Visual acceptance and supporting audits

All **90 actual Godot images /nine provenance sheets** and critical full-size host-perspective,guest-bed-orthographic and actual host-dialogue frames visually inspected. [Synthetic index](../evidence/AD015/20261011-105844807-2a81f230/render/inn-painted-index.json) covers entrance,host/meals,lounge,breakfast,guest desk,kitchen,guest bed,both projections/extreme zooms,28 original/painted pairs,clear-day/storm-night and three whole-cutaway angles. Direct room/party/camera/time/weather setup explicitly synthetic;default scheduled Della remains present. [Paint](../evidence/AD015/20261011-105844807-2a81f230/render/derived/20261011-110027-bfe1d987/capture-report.json) and [ordinary](../evidence/AD015/20261011-110024466-6860500b/render/derived/20261011-110206-0b3b898c/capture-report.json) reports validate source hashes/pause/dialogue-modal/focus/settling provenance.

Brush scale consistent across all existing surfaces,without seams/atlas bleed;floor/cream trim/quiet cloth belong to accepted town/home palette. Della and cyan/purple party remain readable. Entrance,common lanes and current authored areas/cutaway visible in both projections;real input journey and original capsule sweeps verify physical use. [Audit](../evidence/AD015/authoring-20261011/acceptance-audit.json):**28 paired camera/party feet/sun/contact records exactly equal;zero clear/storm changed world pixels** in ROI(0,120)-(960,500);**90,624 safe all-face sampling checks**. Forecast/HUD changes while room remains dry/stably lit. Four-lamp budget unchanged.

Frozen120-warmup+120-frame sample:p95/p99 **2.440/2.803ms**,drawp95 **266**,nodes393/resources505,texture32,528,618 bytes. Observations only;full active/process-memory/travel-growth profile remains AD019. Inherited baseline sampler's `hud` string mentions a review banner;this fixture creates no review node/banner. Actual ordinary HUD visible,pause overlay hidden for these pixels;all captures retain explicit synthetic provenance. This metadata wording is recorded rather than treated as an actual second HUD.

[Preservation](../evidence/AD015/authoring-20261011/preservation.json):**3,032 starting/3,029 protected files**,zero unexpected changes,exact one-line builder adaptation and ten task paths/hashes. Unrelated direction/interiors/user prompt/contract,original sources/earlier accepted art and historical R016 Blocked/incomplete retained. No external source refresh,editor/Blender,atlas/import,shared UI or other workflow changed.

## Retained attempts and cleanup

[Initial sandbox run](../evidence/AD015/20261011-105638459-29b4efac/results.json) failed because owned-child CIM query unavailable. Scoped isolated-run elevation approved;no auto-review rejection. [Next diagnostic run](../evidence/AD015/20261011-105708747-4417cdfd/results.json) retained copied new-fixture wrong path `res://world/mayor_vale_inn.tscn`;original physics/travel/environment/portal cases passed,but whole run failed and supplies no visual acceptance. New fixture corrected to actual `lantern_rest.tscn`;complete final gates above passed. Constructor explicitly identifies root-owned seams/rugs as LanternRest,matching accepted home pattern before scene root name assignment. No production gameplay repair or original guard weakening.

[Cleanup](../evidence/AD015/authoring-20261011/cleanup-pids.json):all **45 recorded owned launcher/engine/subprocess PIDs exited**. Synchronous keys/journey finally guards released input;final ordinary capture verified pause before disposal. No live Godot,held input,editor/Blender mutation or cleanup owed. Source/pixel/coverage/capture/preservation/whitespace/scope checks pass. No native,GUI Save/Load,new-process restart,package or full-profile acceptance claimed.

Next eligible implementation **AD016 only**,in a fresh invocation after this authorized local commit. No successor work or push occurred.


## Authorized commit follow-up - 2026-10-11 UTC

The user authorized the successful AD015 commit after review, explicitly including acceptance evidence. Reverified all ten reviewed task hashes,1,401 stable validated source files,10/10 main and3/3 ordinary cases,90 capture hashes and3,029 protected starting inputs before documentation-only follow-up edits. Production/check sources and original run reports remain unchanged. Existing failures, metadata caveat and later profiling/native limitations remain recorded above.

Commit scope is ten AD015 task paths plus selected reports/logs/source manifests,90 final engine frames/nine provenance sheets,retained failed-attempt records and acceptance/preservation/cleanup/final/pre-commit audits. Temporary authoring scripts,build/testing/save archives and unrelated direction/interiors/user prompt/contract remain excluded. [Commit review](../evidence/AD015/commit-review.json) records exact selected scope/hashes. Local `docs/evidence/AD015/authorized-commit-20261011/commit-audit.json` records verified commit/tree/path/blob identity and final working-tree status after commit; it is kept outside the commit to avoid self-referential commit hashes. AD001-AD015 remain Done;AD016-AD020 Pending. No AD016 implementation,push or new gameplay checks.
