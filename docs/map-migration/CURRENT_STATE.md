# Current map migration state

Updated2026-10-03,America/Vancouver. M001–M010 verified complete.

## Selection and next action

- Active item:none. M010 companion river/ramp recovery complete.
- Next eligible:M011 landscape appearance only. Replace diagnostic terrain/water
  with coherent grass,paths,sand,banks and restrained river motion;retain source
  registration,default grass and all gameplay geometry/ownership.
- Acceptance:[M010 validation](../evidence/M010/VALIDATION.md). No M010 blocker.
- Candidate remains isolated/test-only;normal compact Alderwake until M015.
  Parent P001–P014 compact build complete;M019 must verify native map build.
  No M011 implementation,export/native map release claim.

## Preparation and authority

Read workspace AGENTS(no nested),full migration prompt,parent architecture/state,
migration investigation/checklist/state/contract,pinned inputs/layout/provenance,
M009 evidence and actual controller/actor/root/party/WorldHost/camera/bridge/tests.
Clean Git at38adac28774c2d936dcaf88e2dc19a99fdac2a58;HEAD unchanged. M010 marked
in progress before edits;exactly one item. Caveman and Returning Fair gameplay-
testing skills used. No subagents,source writes/generators/refresh,installation,
Blender,commit,push,publication or export. P014 and historical M evidence preserved.

Snapshot alderwake-f4630f9-m002/source commit
f4630f9966d6637ef6579cd87623ea354758191c. Five pinned inputs unchanged;runtime
uses target-local normalized layout. [Hashes](../evidence/M010/snapshot-hashes.json).
Map SHA256 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
catalog59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2;
layout7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be;
report66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.
Schema4/content1,production location/spawn/actor/quest/effect IDs unchanged.

## Implementation and changed files

- companion_controller.gd:existing1.6m follow stop now needs height difference
  <0.1m and low world LOS;nearby hero across cliff no longer stops ramp repathing.
  Safe placement enforces enabled/living hero/no threat/nonzero nav iteration,
  complete nav endpoints,actual capsule/floor corridors along path and directly
  from actor to landing. Floor rays/samples<=0.1m plus sweeps reject stale/low/thin
  blockers. Direct corridor checked before long path query;distant legal bridge
  does not authorize teleport through river/cliff/trunk. Placement clears old
  input/velocity. Normal speeds,repath/stall/separation/heal timers preserved.
- map_companion_checks.gd/UID:14 physically stepped AI journeys,19,808 hero/ally
  samples,true low-curb stall/no unsafe jump then safe catch-up after removal,
  shared-API damage/3s recovery,five rejections,modal/focus/travel suspension,
  same state/two wrappers. Synthetic setup/leader2.8m/s labeled;rendered separate.
- companion_checks.gd:full-barrier fixture now rejects unsafe teleport;positive
  separated catch-up uses clear northern room lane. Existing recovery/combat/
  defeat/save/migrations/retry/identity assertions retained and pass.
- map_candidate_root.gd:M010 labels only. CONTRACT/CHECKLIST/this state,CANDIDATE
  and parent ARCHITECTURE document stricter shared safety;no authority/schema/
  geography/production selection change.
- docs/evidence/M010/:VALIDATION,accepted/failed logs,exact exits,companion report,
  hash/audit script,rendered index/four contact sheets,windowed driver/commands/
  raw responses/runtime and64 copied PNGs.

## Exact checks and results

Commands in VALIDATION.md from target root. Both supplied engine paths exist;
4.7.2.stable.mono.official.ed1daf0bf. Process-local APPDATA/LOCALAPPDATA isolate
builds/m010-user-data,m010-local-data and compact counterparts. Normal save
untouched;fresh named playtest-m010-follow-a.json absent.

- Pinned extractor --check:PASS/exit0;all inputs/layout/report unchanged.
- Final import:exit0,new tracked test UID;known missing.NET SDK10.0.9/certificate
  diagnostics retained. No clean-import claim.
- map_companion_checks:PASS0;14 routes,19,808 samples,max grounding error
  0.00000025332m;gaps<1.9m,nonzero repaths,zero follow catch-ups. Four crossing
  routes,Moonwell round trip,western rise/upper Moonwood/western side rise round
  trips plus isolated northern terrace internal up/down. Curb blocks360 fixed
  ticks/stuck>=2.5s,no unsafe teleport;one catch-up after removal. Downed actor
  remains0 before3s then heals100 once on same state. River/cliff healthy/downed
  placement rejected;disconnected two-point partial nav path rejected;stale low
  barrier/combat rejected. Pause/dialogue/focus/journal freeze240 explicitly
  invoked AI ticks each;actual candidate/Tollworks round trip resets AI/identity.
- Final companion/application_smoke/movement-camera/location-travel/interaction-
  dialogue checks:PASS0. Compact real combat/post-defeat recovery/once-only
  effects/save/migrations/retry and normal controls/party ownership retained.
- report_m010.py:PASS0;audit eight import/extractor/Godot checks,hashes,recovery/
  gates,64 captures/31 moving,seven ordinary-input routes,normal quit0/no save.
- Final runtime/check logs:no SCRIPT ERROR,query-before-sync or nav mesh errors;
  known certificate-store diagnostic only. git diff --check/final review exit0.

## Rendered evidence

Fresh m010-follow-a paused town start,Compatibility/OpenGL3.3,960x640,RTX4070
Laptop/NVIDIA581.29,Windows11 build26200,Core Ultra9 185H(fresh registry/runtime).
Ordinary viewport WASD only,no teleport/health/quest/save mutation. Seven routes:
town->Moonwell->town,town->ford east,ford west,west-bank forest to bridge west,
bridge east then west. Every31 movement batch starts/ends confirmed paused and
focused. Before.play_seconds equals previous after.play_seconds across model/
helper gaps;wall timing is not fixed physics. All31 moving views inspected via
four contact sheets;full Moonwell/ford/bridge and initial/final pause views also
inspected. Both actors readable through ramps,crossings and trunk detours.

Final hero(92.9230728,0,-0.4866859),ally(94.4977341,0,-0.3891202),time
72.1158944545612s;HP100/100,132 repaths,zero catch-ups,empty quest/effects,two
stable wrappers. Normal F10 exit0;no live game/helper. [Rendered index](../evidence/M010/rendered-index.json)
retains hashes,observations,commands/responses and route endpoints. Synthetic
recovery separate;no native-release/M018 benchmark claim.

## Decisions, repairs and remaining limits

Connected nav alone insufficient:direct physical corridor also required. Ally
can remain stalled/down until safe connected landing exists;never bypass an
impassable obstacle to force recovery. Floor tolerance0.35m preserves compact
0.25m Recast/candidate0.05m offsets;physical geometry/heights/climb unchanged.
Northern1.5/1.75m terrace is authored isolated island;internal ramp synthetic,
no invented main-exterior link. No claim AI walked all16 distinct ramp lanes;
full networks/internal terrace meet M010,historical M008 hero geometry preserved.

Early failures retained/labeled in VALIDATION:read-only World3D map assignment,
empty asynchronous island query/-1 access,overlong short-plateau ramp fixtures,
wrong window focus signal,unsafe curb expectation,too-small compact nav-height
tolerance,and preliminary query-before-sync diagnostic despite exit0. Repaired
fixtures/lifetime/sync,full journeys/isolated terrace,APPLICATION focus signal,
blocked-then-cleared stall,physical-ground tolerance and zero-iteration guard.
Only final named checks/windowed evidence accepted;diagnostic flag/helper removed.

M011–M014 art,M015 activation/quest route,M016 aiming/canopies,M017 saves,M018
frame/memory,M019 native map release pending.468 props/455 footprints/102 authored
colliders,472 heights/16 slopes/238 cliffs,approved docks/source snapshot/save
and production IDs unchanged. Parent P014 compact completion preserved.
Next session selects M011 only.
