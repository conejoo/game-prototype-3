# FS004 water targeting and preview acceptance

Status: Done, 2026-10-09 UTC. Exactly FS004 executed; FS005 not started.
Entry/final HEAD `cd07b4d4a27c0d6e11df4c0b69c56bdbfa667b2f`; entry Git clean.
[CHECKLIST](CHECKLIST.md) owns status; [CURRENT_STATE](CURRENT_STATE.md) records
continuation, isolation, actual file scope and retained failed runs. No commit/push.
The execution record above describes the pre-commit acceptance boundary. Subsequent
user instruction authorizes the successful FS004 local commit only; no push.

## Criteria and evidence

| FS004 criterion | Implemented behavior and verification |
| --- | --- |
| Map-anchored half-metre cells, inclusive 12m XZ range | FishingWaterTargetResolver floors relative to current pinned bounds origin (-22,-18), returns the cell center and uses current player-foot XZ distance. Interior jitter, exact cell edges, immediately preceding cells, exact12m and just-over12m pass. Half-open map upper edges reject; lower edge remains included. Invalid rod metadata cannot enlarge range. |
| Orthographic/perspective and supported zoom | 24 physical camera samples: four audited sites in both projections at .8/1/1.15. Every sample resolves the exact measured water cell/height and expected area IDs. Rendered dock samples cover all six projection/zoom combinations; channel and both overlaps render in both projections. |
| Water/elevation truth | Read water Y from undisplaced authored WaterVisuals/AuthoredWaterPreview mesh in world space (measured .015m). Never use hero height, shader color, safety-top height or base-floor aim. Elevated hero, dry elevated terrain, actual cliff, safety topY3 and underlying floor negatives pass. |
| Dry structures, banks and solids rejected | Semantic dock and bridge occupancy wins over underlying water. Dry shoreline/terrain rejects. Camera-to-pointer, camera-to-snapped-center and rod-to-center layer1 ray segments retain terrain/cliffs/structures/gate/other solids, with hit_from_inside enabled. Camera-side/rod-side synthetic solids and actual gate/cliff blockers reject. Only direct water-owner bodies identified by existing authored water collider IDs are excluded. No generic floor/prop exclusion. |
| Invalid rays, range, bounds, interiors and UI pointers | Nonfinite origin/direction/player/length, zero/upward/horizontal/backward/too-short rays, invalid pointers/camera/catalog/capability reject. Outside viewport/map, test-room/interior and uncommitted candidate map reject. Explicit pointer permission comes from existing root/UI ownership, plus viewport bounds. Actual header/footer and pause ownership reject and hide preview. |
| Safety blockers do not prohibit normal cast sites | Actual raw vertical physics hits safety topY3; dedicated query resolves open waterY.015. All four audited dry-foot rod lines remain eligible without removing or modifying any blocker. FS001 already supplies ordinary approach evidence; FS004 poses/rays remain explicitly synthetic. |
| Eligibility and no-area are distinct | Detached typed result exposes status/reason, has_point, surface_valid, cell/point/range and matching area IDs. Eligible green “Cast here”, open-water no_area amber “No fishing area”, and red invalid reasons are separate. No-area never rolls an encounter or grants a reward. |
| Current player and cast revalidation | Preview.refresh takes current context/player/pointer each call; revalidate reruns the entire query and updates display instead of trusting stored eligibility. Moved player, changed ray/UI gate and a newly introduced solid invalidate a previously valid preview. Returned results and nested view snapshots are detached. clear hides all effects and removes snapshot/text. |
| Ground aiming, movement, geography and ownership preserved | Existing camera/root/UI/map/collision/navigation/save/inventory/source/native files unchanged. Full durable snapshot, navigation RID, room child count and semantic water/blocker/cliff counts remain exact across queries/presentation. Pinned layout hash unchanged. Existing map_camera, movement_camera and map_water regressions pass. No navigation bake, collision shortcut, input activation, active challenge, cast/reward or new state authority. |

The focused owner files are
[resolver](../../game/features/fishing/fishing_water_target_resolver.gd) and
[preview](../../game/features/fishing/fishing_target_preview.gd); verification lives in
[rules](../../game/tests/fishing_targeting_checks.gd) and
[renderer](../../game/tests/fishing_targeting_render.gd), with their four generated UIDs.
FS002 existing rod/catalog/area capability and durable acceptance were reviewed and
fresh content/activity suites pass. Source HEAD
`60c20eb2816e7271fb84afaba286af006ebe3ccf` remains clean; live reference audit before/
after143 assertions PASS. All18 source pins and pinned layout SHA256
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be` unchanged.

## Verification and inspected evidence

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7.
Installed console4.7.2 checked at supplied path. No installation.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/fishing/reference_audit.py --source-root D:/development/game-prototype-2
./tools/run_checks.ps1 -Task FS004 -Import -Names fishing_targeting_checks,fishing_content_checks,fishing_activity_checks,map_camera_checks,movement_camera_checks,map_water_checks -RenderScript fishing_targeting_render -RenderPhases preview -ParseScripts features/fishing/fishing_water_target_resolver,features/fishing/fishing_target_preview -TimeoutSeconds 150
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/FS004/20261009-035302983-41ba302d/render/preview-index.json
git -c core.whitespace=cr-at-eol diff --check
```

Accepted report: `docs/evidence/FS004/20261009-035302983-41ba302d/results.json`.
All10 cases PASS/exit0: version/import/parse, targeting135 assertions, content255,
activity208, map camera330 physical samples, movement camera, water and render72
assertions. No timeout/runtime/parse diagnostics; source.changed=false/error=null.
Known import-only missing SDK10.0.9 advisory remains the runner's narrow allowance;
no C# compilation claim. Stable998-file game/tools digest before/after:
`611484d8fdcbe4817d125bc955ee2d4ba4548f8cf35806549c312a1e52582421`.

Six distinct check slots/groups and one renderer group under matching
`builds/testing/FS004/20261009-035302983-41ba302d/`, suffixes000-006; APPDATA/
LOCALAPPDATA isolated per group. Normal saves and prior evidence preserved.
All case logs/results, diagnostics/source manifests and launcher PID exits reviewed.
No owned process/editor or cleanup owed; no unowned process stopped.

18 actual960x640 PNGs: twelve eligible dock/channel/overlap views, no-area, dry deck,
bank, bridge, synthetic solid-occlusion negative and final visible pause overlay.
Capture provenance verified with shared TestRunCapture/capture_evidence; both final
contact sheets and full-size dock, perspective west-overlap and no-area PNGs inspected.
Final labels readable, ring anchored at cell center/water, existing HUD intact;
camera HUD matches actual projection/zoom. Green/amber/red feedback also uses words.
All preview frames are paused synthetic player/camera/pointer/presenter fixtures with
explicit geometric pointer permission. Production pause rejection is tested separately.
No live waiting/bite/fight, ordinary input casting/catch, or native-release claim.

Initial sandbox launch denial, first-import UID source-change rejection and one
misplaced oblique-ray fixture are retained/excluded; exact run IDs in CURRENT_STATE.
First all-pass run preceded visual inspection; its tiny caption was enlarged and
camera HUD refreshed before final stable rerun. No approval rejection outstanding.

## Continuation boundary

Every FS004 criterion verified; blockers none. FS005 next, FS005-FS008 unfinished;
every item through FS008 is not complete. Root FS005 must call refresh during
targeting and revalidate with current UI/mode/session/rod/position/ray immediately
before starting any attempt. This view owns no input or durable/session facts.
FS005 supplies input/cancellation/rewards; FS006 public fishing HUD follows it.
No successor started, commit, push, package promotion, publication or schedule.
