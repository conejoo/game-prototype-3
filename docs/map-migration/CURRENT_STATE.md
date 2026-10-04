# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M009 verified complete.

## Selection and next action

- Active item:none. M009 navigation for complete exterior completed.
- Next eligible:M010 companion river/ramp recovery only. Require traversable
  connectivity from ally to catch-up point;local floor/LOS alone insufficient.
- Candidate remains isolated/test-only;normal compact Alderwake until M015.
  Parent P001–P014 compact build complete;M019 must revalidate map release.
- Acceptance:[M009 validation](../evidence/M009/VALIDATION.md). No M009 blocker.

## Preparation and authority

Read workspace AGENTS(no nested),full map prompt,parent architecture/state,
migration investigation/checklist/state/contract,pinned inputs/layout/provenance,
M008 evidence and actual candidate/actor/party/WorldHost/camera/input bridge.
Marked M009 in progress before edits;exactly one item.Caveman and Returning Fair
gameplay-testing skills used. No subagents,source writes/generators/refresh,
installation,Blender,commit,push,publication or export by this agent.
Initial HEAD00c9110a27a434c49c2be89c00a1e1272d49d067 with existing M008 changes;
HEAD advanced externally to59bdc6c(M008 commit)during work.Prior changes/evidence
including P014 preserved.Some initial M009 cliff-carve/report-path edits were
included in that external commit;remaining diff is relative to59bdc6c.

Snapshot alderwake-f4630f9-m002;source commit
f4630f9966d6637ef6579cd87623ea354758191c.Five inputs unchanged;runtime uses
target-local normalized layout only. [Hashes](../evidence/M009/snapshot-hashes.json).
Map SHA256 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
catalog59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2;
layout7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be;
report66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.

## Implementation and changed files

- elevation_surfaces.gd:post-erosion cliff centre carve resolves Moonwell turn;
  physical472 height cells/16 ramps/238 cliffs unchanged.
- terrain_preview.gd:explicit dry physical surfaces,radius0.4m,height1.6m,
  climb0.1m,cell0.2m/height0.05m,contour error0.1,slope20degrees;existing0.2m
  prop/water/rail margin.After bake,clip against physical cliff boxes/gate
  grown0.44m and bounds inset0.44m.Square corners preserve capsule radius.
  Weld0.01m vertices+0.0001m raster bias at height+0.05m;omit collinear/
  duplicate-index triangles;unexpected holes fail.Isolated world merge cells
  0.01m;project defaults unchanged.Measured synchronous region needs no cache/
  background task.Adds construction/source/bake/clip/polygon report.
- world_host.gd:party stays suspended until nonzero navigation iteration and
  exact region owns anchor query;same barrier on rollback.Original placement,
  session/party/save ownership unchanged;normal rooms pass.
- map_navigation_checks.gd/UID plus fixtures/map_navigation_failure.gd/UID/tscn:
  whole-mesh/routes/negatives/topology/load/query budgets,immediate commit
  readiness,three rejections,four round trips and region release.Detached only.
  Forest test writes M009 report;M008 evidence preserved.Candidate labels M009.
- CONTRACT/CHECKLIST/this state,CANDIDATE,parent ARCHITECTURE and M009 evidence.
  Parent architecture documents readiness and accurate compact P014 completion;
  production geography/quest/scope/IDs remain unchanged.

## Final commands, results and measurements

Exact commands/logs in VALIDATION.md,all from target root.Both supplied engine
paths exist;4.7.2.stable.mono.official.ed1daf0bf.Process-local APPDATA/LOCALAPPDATA:
builds/m009-user-data and builds/m009-local-data.Normal user save untouched.

- Pinned extractor --check and report_m009.py:PASS/exit0.
- Godot --headless --editor --path game --import --quit:exit0,known missing
  SDK10.0.9/certificate diagnostics retained;no clean-import claim.
- map_navigation_checks:final PASS0;336373 actual0.4m capsule samples<=0.1m
  apart across6336 polygons/6151 vertices and required bidirectional routes.
  No non-manifold edges;18 town/landmark routes+4 direct crossing routes.
  Tollworks113.53m<=180m;other required max130.15m<=200m.Eight water/gate
  negatives>=0.4m from usable nav.Three failed-floor/blocker/bake rollbacks
  restore queryable exterior;four full candidate/Tollworks round trips leave
  one region/location and two original party wrappers.Ready at commit.
- Fresh-process generation/bake797.363ms(construction434.236,source73.661,
  bake123.453,clip165.884);cold arrival1026.184ms.Warm request->commit max
  exterior1315.746ms,Tollworks121.424ms.Thirty path queries:p95718microseconds.
  Meets5s/2s/5ms targets;single synchronous strategy,no OS cache-flush claim.
- Final forest/town/water/candidate/application_smoke/location_travel/companion
  checks PASS0.Forest16 physical routes/18369 samples/64178 polygon probes;
  town74 routes/18325 samples/37325 probes.Normal ten travel round trips and
  compact companion behavior correct;M010 exterior recovery not certified.
- Final runtime logs:no SCRIPT ERROR,query-before-first-iteration error or
  edge merge warning;known certificate-store diagnostic only.
- git diff --check:exit0,intended files reviewed.Parent P014 evidence preserved.

## Rendered evidence and repairs

Final m009-nav-b,fresh candidate start,Compatibility/OpenGL960x640,
RTX4070 Laptop/NVIDIA581.29,Windows11 build26200,Core Ultra9 185H(registry/runtime;
WMI denied).Ordinary viewport WASD through existing opt-in bridge;no teleport,
actor/quest/save mutation.Short batches begin/end confirmed paused;wall timing
is not fixed physics.[Index](../evidence/M009/rendered-index.json) retains18 PNGs,
raw command/responses/driver logs and inspected moving views/contact sheet.
Forward through entry/corner/Moonwell ramps reaches(31.3263874,0.5,5.2677431),
paused9.79268485s;reverse->town(-0.17688414,0,0.05088943),paused19.47498252s.
Hero/ally/ramps readable;pause/focus verified.Normal F10 exit0;named
playtest-m009-nav-b.json absent.No game/helper remains.Earlier m009-nav-a also
quits0,but diagnostic startup query-before-sync error repaired in final run.

Earlier coarse whole-mesh audit failed8328 samples;0.05m full bake failed warm/
query budgets/merging;rounded exact clip failed1066 samples;millimetre welding
left4 aliases.Exact square clipping+centimetre raster welding passes without
physics/source change.Commit-readiness test exposed async race;WorldHost now
waits.Startup exposed zero-iteration query;explicit guard fixes it.All earlier
failed/preliminary logs retained/labeled;only plain final check names and
windowed-final accepted.M008 historical failures remain preserved.

## Remaining scope

M010 must prove connected catch-up/incapacitation recovery across river/cliffs,
normal follow/repath on ramps/crossings,and modal/travel suspension.Do not infer
that from M009 connectivity or compact companion checks.M011–M014 art,M015
activation/quest route,M016 aim/canopies,M017 saves,M018 frame/memory,M019 native
map release remain pending.Schema4/content1,468 props/455 catalog footprints/
102 authored colliders,physical geometry,docks and snapshot unchanged.
Next session selects M010 only.
