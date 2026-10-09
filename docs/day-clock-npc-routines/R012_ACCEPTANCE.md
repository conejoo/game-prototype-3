# R012 acceptance: actions and timed public speech

Done 2026-10-09 UTC. Exactly R012 implemented; R013-R016 remain Pending.
Implementation validation stopped without commit/push. Separate reviewed user
follow-up now authorizes the successful R012-only commit, including these18 paths;
Git and ignored commit audit record its hash. No push or R013 work.

## Scope and criterion evidence

- Explicit production NpcRegistry mapping mounts the existing reviewed npc-01-actions.glb / npc-02-actions.glb once per actual wrapper. `river-fishing` selects `action_river_fishing` for Edric; `archive-work` selects `action_archive_work` for Helena. Achieved movement continues to own walk; motion rejects actions, stationary phases use qualified authored facing. No rig replacement per frame or new art/sheets.
- Scene-owned RoutinePresentation uses a public authored-current-step billboard Label3D, 32px source glyphs / .016m pixel size, outline and wrapping above actual feet. No Control, input, collider, local timer, durable text or private diagnostic text. Existing executor owns bounded active wait/action/speech durations and expiry. Cancel/reassignment/completion/failure/unload/disposal clear stale text/props.
- Pause retains exact pose/text. Focus hides text and retains exact action pose; dialogue/modal/travel/death hide text and cancel unsafe accessories. Held executor timers stay exact; release reads the same live step and resumes its presentation. Existing dialogue leases integrate with root holds; clock semantics remain unchanged.
- Required `npc_action_checks` PASS1814 validates actual imported 4s action loops, rigid source support-hand accessory weights, seams, 481 samples per action, planted feet, no penetration/spikes, blend continuity, nested holds and actual root pause/focus/dialogue/travel. `npc_asset_pipeline_checks` PASS839 preserves exported identity/16-bone rigs, portable materials/UVs, .8m/s stance and real wrapper ownership. `map_camera_checks` passes330 terrain/camera samples. Actual action stations are flat dry Y=0; slope navigation remains the unchanged terrain owner, verified by real `routine_movement_checks` PASS1363 / 412 samples / 18 legs / eight bodies. No presenter terrain tilt or offset is invented.
- New focused checks PASS94 cover exact authored speech/expiry, six hold reasons, no rewards or durable mutation, unchanged rig after100 updates, moving-action refusal, facing, fallback, cancellation, active speech unload, active accessory disposal and bounded failed movement with inert output. Other six villagers retain their exported idle on an optional unmapped action; foreign/unavailable clips explicitly fall back to idle and show no prop. Selected production actions are both mapped; no missing action sheet is fabricated.
- Rendered sequence PASS60 / 13 captures: physical one-metre river approach, walk -> speech -> fishing, subsequent actual action pose; Helena archive action -> public speech -> physical shelf walk -> archive action. Both projections, actual public zoom bounds0.8/1.15, verified pause captures and public journal timer hold. All13 images inspected on both contact sheets, plus full far speech, fishing pose and archive speech frames. Speech readable, soles planted, source fishing/archive props correctly attached, no stale labels/accessories or blocked input. Public projection/zoom/journal/Esc controls remain operational.
- Presentation grants no fish, facts, items, income or quests; exact SaveCodec snapshots remain unchanged in deterministic cases. No source/geometry/anchor/step/portrait/identity/save8/content1 changes. Root retains existing player/party/social/recovery/item/weather/save owners. Default routines remain disabled until R013.

## Baseline, commands and isolation

Repository cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7, explicit installed Godot console4.7.2.stable.mono.official.ed1daf0bf, GL Compatibility960x640, bundled Python3.12.14. Baseline clean HEAD28d6f9e0e6fcaa0ac02cd2a071d5d54d134676c5, empty index/no user changes; source60c20eb2 clean/read-only. Workspace caveman/Godot instructions and applicable current testing/save/journey/capture/native guidance read; no nested target AGENTS/.agents skills. Blender2664 preserved. Sandbox shell setup fails before execution; scoped reviewed shell succeeds, with no automatic review rejection.

Completed runner commands:

```powershell
./tools/run_checks.ps1 -Task R012 -Names routine_presentation_checks,npc_action_checks,npc_asset_pipeline_checks,map_camera_checks,routine_movement_checks,routine_executor_checks,routine_dialogue_checks -RenderScript routine_presentation_render -RenderPhases capture -TimeoutSeconds 150
./tools/run_checks.ps1 -Task R012 -Names routine_presentation_checks -TimeoutSeconds 150
```

[Combined report](../evidence/R012/20261009-210402630-320414f0/results.json) PASS10 cases: engine/parse, presentation87 before cleanup strengthening, required actions1814/asset839/camera330, movement1363, executor71, dialogue69, renderer60/13captures.
[Final strengthened report](../evidence/R012/20261009-210904390-6255195b/results.json) PASS3 / presentation94. Accepted exits0, forbidden diagnostics empty, source.changed=false/error=null. Each independent check owns separate APPDATA/LOCALAPPDATA/save_group/named primary/backup slots; render its own group under builds/testing/R012. No normal save use. Save/restart is not a new R012 criterion; no restart or native claim.

[Inspected capture report](../evidence/R012/20261009-210402630-320414f0/render/derived/20261009-210609-b2cf66aa/capture-report.json) owns13 images/two contact sheets. Initial clocks/party/art setup are synthetic. River fixture starts one metre before unchanged authored anchor, then actual physical movement; no claim that this setup proves the complete ordinary town-to-river routine. All subsequent steps use unaccelerated live root execution. Archive phase waits its complete remaining authored duration, never seeks during play. Public input and verified pauses guard captures.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/routine_migration/reference_checks.py --source D:/development/game-prototype-2 --self-test --report docs/evidence/R012/reference-final.json
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/R012/20261009-210402630-320414f0/render/presentation-render-index.json
```

[Live reference](../evidence/R012/reference-final.json) PASS1626 / 88 source pins / 80 exact target adaptations / ten correctly refused fixtures. Original before-hashes/source pins/prior reasons preserved. New R012 owner recognition is narrow; immutable historical coverage remains intact. Final1291-file manifest sha8b7a473dd9a4b0b4556ad116b2e32948515ad718e92bed5da61a9cc1ef90a9a2. Compared with successful inspected combined manifest: only subsequent game change is focused-test cleanup/refusal strengthening; only tool change is exact ledger update. Runtime, render fixture, action assets and reused tests match accepted bytes exactly.

## Retained failures, limits and continuation

-205445/205705 imports generate new UIDs; changing-source reports remain failed. Imported SDK diagnostic is the existing allowed editor-only one; no C# installation required.
-205742 presentation expiry test incorrectly expected ACTING on the READY boundary; one subsequent active tick fixes the assertion. Asset/camera cases already passed there. UTF-8/default-encoding/mixed-ending repair attempts retained; reapplying narrow changes from original Git UTF-8 bytes preserves all existing text and endings.
-205853 full river fixture stops before speech/action. Later deterministic diagnosis identifies actual stationary Tess `npc-06`, at Edric foot(6.6001,0,4.6001), movement BLOCKED, two repaths / three path requests, typed safe refusal. Original speculation about party position is disproved. New negative case preserves this failure and verifies no false action/speech. R013 ordinary-route integration must review this contact/path obstruction; R012's bounded art setup does not certify or conceal that route.
-210052 archive render's40s observation cap expires while49s remained; increase to80s bounded observation and retain failure. Its tiny speech and camera-input scope were repaired after visual review; final far text and true zoom bounds inspected.
-210245/210315 parse failures retain malformed inline camera loop; exact multiline repair passes.210802 strengthened diagnostic assumed party rather than measured Tess blocker; corrected to observed npc-06, final94 pass. No failed whole run relabeled or erased.

R012 blockers/unrun criteria:none. Future R013 route concern above is explicit; no R013 work performed. No natural full-day/native/package/default-activation claim. All owned Godot engines exited, no held input/editor or cleanup owed; Blender2664 unchanged. Next eligible R013: activate complete catalog using delivered dialogue/presentation, integrate real scheduled access and resolve/verify observed Tess river-leg obstruction. Remaining unfinished IDs:R013,R014,R015,R016. Every item through R016 complete:no. Stop here; await separate reviewed commit instruction, no push.

## Exact intended paths

- `.gitattributes`
- `docs/ARCHITECTURE.md`
- `docs/day-clock-npc-routines/CHECKLIST.md`
- `docs/day-clock-npc-routines/CURRENT_STATE.md`
- `docs/day-clock-npc-routines/R012_ACCEPTANCE.md`
- `game/app/game_root.gd`
- `game/features/npcs/npc_registry.gd`
- `game/features/npcs/npc_world_adapter.gd`
- `game/features/routines/routine_execution_director.gd`
- `game/features/routines/routine_presentation.gd`
- `game/features/routines/routine_presentation.gd.uid`
- `game/tests/npc_action_checks.gd`
- `game/tests/routine_presentation_checks.gd`
- `game/tests/routine_presentation_checks.gd.uid`
- `game/tests/routine_presentation_render.gd`
- `game/tests/routine_presentation_render.gd.uid`
- `tools/routine_migration/adaptations.json`
- `tools/routine_migration/reference_checks.py`
