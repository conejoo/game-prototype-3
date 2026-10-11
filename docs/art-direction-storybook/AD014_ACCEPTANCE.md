# AD014 acceptance — painted Mayor Vale home

Completed 2026-10-11 UTC. **Done: every AD014 criterion verified.** Existing four-room cutaway now has warm oak/timber, cream plaster/linen, quiet teal/indigo textiles, muted books and stone hearth. Existing town atlas reused; no new room, texture asset, geometry, emitter, durable field or routine. All access, identity, collider, station, party arrival and reciprocal travel owners remain intact. No staging, commit or push; user requested a separate post-review commit instruction.

## Scope and source authority

Starting HEAD `03a6e9894e36c59647bb4301450a4378e4f53fdf` is context only. Read workspace AGENTS, this workflow/prompt/contract/checklist/brief/baseline, AD008 pilot acceptance, R007 room acceptance, current architecture/static pipeline, interiors ownership handoff and versioned PLAYTEST/gameplay-testing skill/reference. No applicable repository `.agents` directory/skills or additional AGENTS existed. Interiors workflow remains planning only; historical R016 remains Blocked/incomplete. No external source checkout, other agent conversation, Blender scene or native input used.

Exactly **13 task paths** in [scope](../evidence/AD014/authoring-20261011/task-scope.json):

- `game/world/mayor_vale_home.gd`: one material-override line in the existing `_box`; every original line remains exact after removing it. Original StandardMaterial3D, BoxMesh, transforms and construction order remain recoverable.
- `game/world/storybook_home_material.gd/.uid`, `storybook_home.gdshader/.uid`: 21 cached immutable finishes across 15 semantic families; all 165 existing boxes receive intentional six-face room/world-metre triplanar sampling. No extra mesh surface or node.
- `game/tests/storybook_home_checks.gd`, `art_direction_home_render.gd`: meaningful resource/cache/coverage and labeled actual engine review fixtures.
- `game/tests/routine_home_checks.gd`, `routine_home_render.gd`: narrow legacy-fixture adaptations below; no original assertion or physical pin removed.
- `art/source/storybook/home-painted-recipe.json`: editable recipe, exact owner/atlas/palette/coverage/coincident-face policy.
- This acceptance, CHECKLIST and CURRENT_STATE.

Original JSON/scene/collision/navigation/station/light/profile/portal/routine/actor/import/Blender/GLB/atlas bytes are protected. Existing 32 colliders, two historical source furniture repairs, nine anchor feet/facings, 26 floor seams, two floor rectangles, four unshadowed warm lamps, original torus/labels and full-party arrival pocket retained. Schema8/content1 unchanged. All art editing belongs to the procedural Godot source; no Blender export is needed for this room.

Shared 1024 RGB town albedo keeps existing imports/mips; shader explicitly samples linear mipmaps with clamped atlas access. Timber/plaster safe patches span480px and stone/linen224px, inside16px gutters. Each projection plane uses64texels/m independently of box dimensions; continuous mirrored folds and shared world phase prevent floor seams or density jumps. Patch/reference normalization avoids doubled palette multiplication; matte roughness0.92, restrained stroke strength0.70 (tiny parts0.30), no fixed directional shadow or emission.

Original sofa/island/rug faces coincide with the middle partition at z=-5.5. Pixel review exposed their inherited material speckles with the lighter plaster. Final shader assigns identical plaster palette/patch/strength to those coincident vertical fragments below0.65m. Every vertex, depth, transform, surface and collider remains untouched; visible upholstery/rug/timber elsewhere keeps its finish. Final engine pixels confirm clean partitions.

## Acceptance evidence

| Criterion | Verified result |
| --- | --- |
| Coherent warm treatment, readable rooms/stations | All15 semantic families/165 boxes painted; all four existing rooms inspected at both projections and0.8/1/1.15 zoom. [Final painted archive](../evidence/AD014/20261011-103551439-374cfd54/render/archive-ortho-115-painted.png), [clean parlor](../evidence/AD014/20261011-103551439-374cfd54/render/parlor-perspective-80-painted.png). Final50 synthetic images cover entry/four rooms/extreme zooms,20 registered original/painted pairs,three reverse/side cutaway diagnostics,day/storm control and stationary/three moving/shelf-arrival contact frames. All inspected through five provenance sheets and critical full-size frames. No hidden-contact or new texture seam observed. |
| Texture scale and all-face coverage | Four existing safe atlas regions,64texels/m for every plane,16px gutters,clamped mipmaps; resource/cache assertions and bounded plane-coordinate audit pass. Original BoxMesh/UV/source geometry retained. Three cutaway angles expose reverse/top/side surfaces with consistent finish. Books and cloth stay quieter than actors. |
| Party/NPC feet and narrow routes clear | Original home check passes5368 assertions,2586 continuous0.4m capsule sweeps,25 routes; source collider/station/provenance pins and paired Vale/party clearances preserved. Final1002 new material/cache assertions pass; reconstruction reuses21 resources. Original default activation gate passes2610 assertions/all25 routines, including actual physical Vale home plans. |
| Stable indoor profile under exterior weather | Final home checks exercise three seeded exterior storms while sun/profile remain fixed.157 environment lifecycle assertions pass. Actual clear-day/storm-night captures share exact sun/camera/party/contact registration and **zero changed world pixels** in960x350 ROI y160–510. HUD correctly changes forecast; no indoor rain node. Existing four room lights untouched. |
| Existing public entry/return and contact motion | Final ordinary renderer passes125 assertions/28 captures/seven guarded WASD routes, fresh E entry, all four rooms, P/+/- zoom bounds, E return and town revisit. No feet/facts/time/weather/affinity injection; active default routine owner remains. Safe archive approach uses existing Edric station(2,0,0), avoiding Helena's occupied desk(4,0,0). Separate explicitly synthetic manual contact-goal review uses actual Helena wrapper/mover/navigation/physics/animator: three2m/s walk frames with distinct exported cursors, endpoint(6,0,-1.5) within1e-5m, then idle. |

[Pixel audit](../evidence/AD014/authoring-20261011/pixel-audit.json) verifies20 exact original/painted camera/feet/environment/sun/contact pairs,visible world changes,weather invariance,motion clips/cursors and endpoint. [Acceptance audit](../evidence/AD014/authoring-20261011/acceptance-audit.json) verifies current source hashes, original builder equivalence, physical/material/route counts, all-plane gutters/sampling and scope. [Preservation](../evidence/AD014/authoring-20261011/preservation.json) protects2689 of2694 starting files; zero unexpected changes or additions outside13 task paths. Starting snapshot follows only the initial task-status edits, whose two paths are explicitly excluded/protected by scope; all other starting inputs were captured before implementation.

## Commands and accepted runs

Repository cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7. Explicit installed Godot4.7.2 stable Mono/GL Compatibility,960x640. Runner gives each check independent named save group/APPDATA/LOCALAPPDATA and render-specific isolated group; ordinary user saves untouched.

```powershell
./tools/run_checks.ps1 -Task AD014 -Names application_smoke,storybook_home_checks,routine_home_checks,location_travel_checks,environment_lifecycle_checks,routine_portal_checks,routine_activation_checks -RenderScript routine_home_render -RenderPhases check -TimeoutSeconds 180
./tools/run_checks.ps1 -Task AD014 -Names application_smoke,storybook_home_checks,routine_home_checks,environment_lifecycle_checks -RenderScript art_direction_home_render -RenderPhases pilot -TimeoutSeconds 180
./tools/run_checks.ps1 -Task AD014 -RenderOnly -RenderScript routine_home_render -RenderPhases check -TimeoutSeconds 180
```

[Main](../evidence/AD014/20261011-102730681-121d9195/results.json): **10/10 passed,exit0**. Covers original10 round trips/rollback/identity guarantees,364 portal assertions,157 environment assertions,full25-routine/default-owner coverage and ordinary home journey. Digest `7f6eb2d382544448319176e412d1048ccb6c2aafc2c6c5bc766b5cd3045f5622`,1396 files.

[Final paint/room/weather run](../evidence/AD014/20261011-103551439-374cfd54/results.json): **7/7 passed,exit0**. [Final ordinary journey](../evidence/AD014/20261011-103717462-962e22fa/results.json): **3/3 passed,exit0**. Both final digest `99f3698b1456cec3a33ee2e9dc8884ee8211d7845486f615dd7d5bc182375de8`,1396 files. Every accepted run has source.changed=false/error=null, zero runtime diagnostics/timeouts. Only home material factory/shader and render fixture differ from main: final coincident-face finish and paused assigned-animation/cursor diagnostics. All gameplay, geometry, physical/routine checks and ordinary renderer bytes match main. Final room/weather/material and ordinary engine captures were rerun after that appearance repair.

Home/routine/journey JSON records one fewer assertion than final stdout because each report-write assertion runs after serialization; the new material check reports its final1002 count directly.

Installed Python `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe` ran `tools/capture_evidence.py` on both final indexes, plus task-local `pixel_audit.py 20261011-103551439-374cfd54`, `acceptance_audit.py 20261011-103551439-374cfd54`, and `preservation.py verify`; all exit0. Final78 engine images/eight pause/provenance sheets and critical full-size frames inspected. Captures/metadata/raw reports remain local ignored evidence; reusable sources and durable acceptance are versionable.

Short frozen observation only: VSync0/max_fps0,120-frame warmup+120 samples, p95/p99 **2.795/3.042ms**,360 draws,472nodes/506resources,32,528,618 resident texture bytes. No paired prepaint memory/process-growth/full-active-performance claim. Inherited baseline sample helper's HUD string mentions a review banner; this fixture actually shows ordinary HUD only, with pause overlay hidden during sampling, as the inspected frames show. Atlas asset bytes remain unchanged; no new texture asset or emitter. Full profile remains AD019.

## Retained failures, cleanup and next action

Initial sandbox runner could not access CIM for owned-process tracking; scoped elevation approved, no automatic approval rejection. First import invalidated itself by generating two new home UIDs and four missing AD013 UIDs; only this run's four incidental AD013 sidecars were removed, originals untouched, then source stabilized. Exact editor-only missing.NET10.0.9 diagnostic remains allowed for GDScript import only; no C# build/install claim. New factory initially used root name before scene instantiation assigned it; explicit root owner fixed classification/cache. New fixture's exact float32 lamp-energy comparison changed to narrow approximate equality; authored lamp bytes remain exact.

Original home fixture expects an empty pre-R013 room. Stable isolated unchanged HEAD reproduces exactly the same23 failures/1683 sweeps/15 routes as initial painted run; [comparison](../evidence/AD014/authoring-20261011/legacy-fixture-comparison.json), [prepaint result](../evidence/AD014/prepaint-03a6e989/20261011-102523667-cb9bf2fd/results.json). Initial isolated import regenerations are retained and not promoted. Fixture now sets optional routine owner null before startup only for original empty-room sweeps, retaining every original assertion. Separate original activation checks and both final rendered fixtures keep production default routines active. Ordinary renderer approaches occupied archive desk from its existing safe Edric station; no contact/furniture/physics relocation or bypass. These are fixture/context repairs, not production gameplay changes.

[Cleanup](../evidence/AD014/authoring-20261011/cleanup-pids.json) records all78 owned launcher/observed-engine/subprocess PIDs exited, no live Godot process/held input/editor/Blender mutation or cleanup owed. CRLF-aware whitespace,source,scope,document/link/status audits pass. Unrelated direction/interiors/user-authored instructions, prior AD route/draw observations and historical R016 incomplete remain preserved.

**Blockers:none. Required AD014 criteria remaining/unrun:none.** No native package,GUI Save/Load,new-process restart,full ordinary routine-day or AD019 performance acceptance claimed. No staging/commit/push. Stop after this task; await separate authorized commit instruction.

Next eligible **AD015 only**: paint existing Lantern Rest within its current room/furniture/station/profile pins. Remaining **AD015,AD016,AD017,AD018,AD019,AD020**. Final checklist AD020; every checklist item complete: **no**.

## Authorized post-review commit

The user subsequently authorized the successful AD014 commit, explicitly including acceptance evidence, checklist and handoff. This follow-up commits exactly the13 reviewed task paths plus selected AD014 evidence: all task-run JSON/logs,final78 engine frames/eight provenance sheets,source/preservation/pixel/process/document audits and reproducible evidence scripts. Small prepaint reports/logs were copied byte-for-byte into the task evidence tree so the legacy-fixture reproduction remains accessible without committing its build snapshot. Earlier duplicate/rejected PNGs,build caches,unrelated direction/interiors and user-authored prompt/contract remain excluded. Original implementation reports/hashes stay historical; only acceptance/checklist/handoff prose changed after validation.

[Commit review](../evidence/AD014/commit-review.json) records exact selected paths/hashes and pre-stage preservation. Verified commit/tree/path/blob identity and final working-tree status are recorded after commit in local `docs/evidence/AD014/authorized-commit-20261011/commit-audit.json`. AD001-AD014 remain Done;AD015-AD020 Pending. Stop after this commit;no push or AD015 implementation.
