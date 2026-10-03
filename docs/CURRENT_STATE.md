# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P012.

## Current task

P012 complete — reusable Blender asset pipeline. P013 next eligible, not started.
Normal gameplay remains: accept southwest Maris lead; optionally select Deliberate
Strike in J; travel north with temporary ally; defeat guardian; inspect southeast
vessel; return; complete Maris's labeled practical fitting; preview restored service.
WASD/mouse/Space combat, E interaction, J journal/upgrade, Esc modal/pause,
R retry and F10 quit. Saves remain explicit at stable boundaries/arrival anchors.

## Implementation and changed files

Git initially clean. Workspace AGENTS/caveman, architecture/checklist/handoff and
actual wrappers/rules inspected. P011 recovery and root smoke prerequisites PASS0.
Initial Blender connection absent; user started Blender/MCP and live retry succeeded:
5.2.2 LTS, addon1.7/protocol11 current, telemetry off. Original unsaved Scene with
Cube/Light/Camera preserved; authoring uses three isolated RF-* scenes. Source
game and normal save untouched. P012 committed locally at user request; no push,
publication, subagents, installations or Windows export. Architecture rules and
schema4/content1 unchanged.

- art/source/{guardian,recovery_vessel,tollworks_plinth}.blend: ordinary editable
  source mainfiles, each with scoped art root and excluded studio camera/lights.
  Original faceted stone/clay/bronze forms with teal emission. Ground origins,
  meter scale; Blender +Y maps to Godot -Z forward. Budgets1744/2052/756 triangles
  (vessel/guardian/plinth). Sizes and exact workflow: art/exports/PIPELINE.md.
- art/source/build_assets.py, reexport_vessel.py, prepare_sources.py,
  render_assets.py: scoped authoring/export, repeat-safe visible vessel revision,
  background conversion from library snapshots to mainfiles, saved-source renders.
- game/assets/models/*.glb and .import: mesh-only static exports with retained
  import UIDs. Active-scene-only selected export prevents cross-scene selection
  leakage. Applied bevels, PBR colors/metal/roughness/emission; no texture dependency.
- game/features/combat/guardian.tscn: imported GuardianModel under VisualRoot;
  existing actor script, capsule, combat marker and scene UID preserved.
- game/features/interaction/recovery_vessel.tscn: dedicated gameplay wrapper owns
  maris-recovery-vessel ID, existing dialogue/interaction script, box collision,
  sign and imported VesselModel. Generic practice markers remain unchanged.
- game/world/tollworks.tscn: vessel wrapper instance and Plinth/VisualRoot/
  PlinthModel. Existing collider center compensated by -0.3m visual offset.
  Collision, navigation, stable IDs and authored quest definition unchanged.
- game/tests/asset_pipeline_checks.gd/.uid: meaningful import/scale/ground/forward/
  material checks plus wrapper ownership, physical collision/nav, selector,
  prerequisite rejection, once-only quest effects and save restore. Direct
  positions/death are labeled synthetic fixtures.
- game/tests/asset_gallery.gd/.uid: rendered import inspection only, no session or
  quest fixture. README, CHECKLIST, CURRENT_STATE and docs/evidence/P012 updated.
  ARCHITECTURE unchanged: this implements its existing imported-art boundary.

## Checks and evidence

Exact commands, acceptance map and caveats: docs/evidence/P012/VALIDATION.md.
Godot4.7.2.stable.mono.official.ed1daf0bf; both supplied engine paths verified.

- P011 recovery_presentation and application_smoke prerequisites PASS/exit0.
  Initial restricted recovery run exit1 could not access isolated user:// saves
  and Windows certificate store; normal-access repeat passes.
- v1/v2/final/UID editor imports exit0; existing editor-only missing C# SDK10.0.9
  message remains. Six focused checks at v1 and v2 PASS0: asset_pipeline, combat,
  companion, interaction_dialogue, recovery_presentation, application_smoke.
  After final back emblem, asset_pipeline and companion reruns PASS0.
- Three .blend mainfiles prepared/reopened/rendered exit0; all source PNGs
  inspected. Background preference-read/temporary-cleanup warnings nonblocking.
  Native live scene/object/viewport inspections plus blender-preservation.json
  verify new art and preserved original scene/file.
- Godot gallery Compatibility render exit0, inspected godot-asset-gallery.png:
  all three assets, materials, ground placement and recognizable silhouettes.
  Normal room screenshots inspect actual gameplay wrappers too.
- Window a normal viewport lead/J upgrade, guardian fight and vessel recovery
  reaches4 effects. GUI Save before re-export preserves hero75/ally75/Tollworks.
  Window b fresh process GUI Load after revised GLB restores4/guardian0;
  E/vessel replay grants nothing. Normal return/revisit retains5 and cleared
  guardian; normal D+S hits Plinth and stops hero x1.649 at collider edge2.
  Window b F10 exit0; runtime scan clean.
- Before/after hashes prove only vessel GLB changed during re-export; guardian/
  plinth GLBs, wrapper scenes, scripts and quest definition identical. Visible
  bronze diamond emblems: vessel14->16 meshes,1528->1744 triangles, bounds unchanged.
  Live trace retains140 exact input requests/responses; PNG/JSON evidence retained.
- Final default-workspace git diff --check exit0. Earlier escalated Git call
  could not see repository (129); normal check resolved it.

## Decisions, limits, blockers

No P012 blocker. P012 adds art only; definitions/mutable state, once-only effects,
save schema/IDs and root ownership unchanged. Godot keeps collision/navigation/
lighting; imported child names have no gameplay authority. No generalized art
manager or animation abstraction. Companion/dialogue remain noncanonical fixtures;
no new permanent narrative facts, retired currency ideas or source-game edits.

Art is provisional low-poly static PBR, no rig/animation/textures/full art-direction
claim. Godot Compatibility metal reflections differ from Blender studio; inspected
results are readable. Hero/ally capsules, rotating test beacon and P011/graybox
stage label remain. Guardian visuals extend0.02m beyond unchanged capsule each side.
No Windows build claim. Injected viewport input proves gameplay integration, not
new hardware bindings or OS-focus evidence.

Initial exporter selected other scenes; corrected active-scene export and inspected
final imports. Harness startup preceded ready.json once; retried. First revisit
attempt used E outside gate reach; corrected walk/E passes. Collision assertion
initially read wrong field; actual contacts_during_step confirms Plinth. Window a
normal quit/process termination observed, but exit handle acquired too late:
exact exit code unavailable. Window b and gallery exit0 captured properly.

## Next eligible task

P013 only — Complete playable recovery slice. Validate normal start-to-restored
service, companion reaction/upgrade and restart boundaries without debug setup;
review prompts/save flow and remaining canon deviations. Do not start P014
extension/export work in same session. P012 requires no follow-up before P013.
