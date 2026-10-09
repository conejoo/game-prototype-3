# FS007 acceptance - Integrated fishing and exact restart

Execution date: 2026-10-09 UTC. Entry HEAD
`2fc801f49e069e4bfb0e4b27c510e31b6d8fe588`; entry Git clean.
Selected task only: FS007. FS008 remains Pending; no export, commit or push.
Status: **Done**. Every FS007 criterion passes; no remaining blocker.

## Acceptance evidence

| Criterion | Verified evidence |
| --- | --- |
| Fresh ordinary rod pickup, B selection, dry approaches, F/click and visible reeling | [Ordinary renderer](../../game/tests/fishing_integrated_render.gd) starts with the production fresh session and empty bag, verifies camera-relative movement, walks to the existing rod, holds E, opens B and selects the owned rod with a real pointer click. It uses only TestRunJourney for routes. No position, inventory, RNG, clock or quest setup. F and world click cast; pointer press/release on the visible Reel button hooks and controls the automatically advancing fight. |
| Three authored areas and overlaps without teleport | Ordinary WASD visits all four FS001 sites: dock, channel, west dock/reeds overlap, east channel/reeds overlap. Actual post-click target-cell distribution is asserted against the expected exact area IDs. All nine writer journeys and three reader journeys succeed, including cross-map gate routes. Real waiting/bobber screenshots show each site. Sunken Reeds remains an overlap, never an invented reeds-only area. |
| Three species deterministic integration | [Integration checks](../../game/tests/fishing_integration_checks.gd) use explicitly synthetic legal rod/rich-state setup, seeded species encounters and legal feedback trajectories. Bluegill, river trout and golden carp each land +1; exact whole typed snapshots prove no other inventory, rod, social, quest, party, environment, lamp or time fact changes. These are separate from ordinary catch proof. |
| At least one ordinary unforced catch | Accepted ordinary writer's first dock attempt lands one bluegill. Production RNG is randomized normally and never seeded, replaced or tuned by the renderer. Real root/challenge/world time remains automatic. Actual waiting, BITE and fight captures, +1 inventory assertion, selected Bluegill 1/99 bag and independent loaded bag inspected. Only one ordinary landed fish is claimed. |
| Invalid, early/missed hook, cancel, safe recast, rod drop/retrieve | Ordinary dry-ground click stays targeting with visible rejection. Real early pointer reel produces early_reel. Fresh ordinary missed-hook attempt chooses bluegill and expires without reward. After two ordinary misses, an unforced golden-carp bite is hooked through Reel and canceled through the visible Cancel button. Immediate F/click recast succeeds, F cancels safely, then ordinary B/Drop/E retrieves the unique rod. All failed/canceled attempts retain counts. Deterministic failure/capacity coverage comes from the focused regression fixtures below. |
| Actual GUI Save, normal quit, independent GUI Load, exact counts/selection/all facts | Ordinary writer PID44024 and reader PID10696 use one isolated render slot. TestRunGui observes actual Save/Load success; typed disk snapshot and full-precision TestRunSnapshot oracle are exact before resuming. Reader starts empty with no auto-load. Bluegill1, rod1 and selected bluegill restore; forecast and every durable field match, restart_errors=[]. Both logs record production F10 `Quit requested while paused.` and exit0. |
| No attempt resumes; travel/revisit cannot duplicate fish | Reader has idle fishing, no effects/hold/drag after Load. Both ordinary processes walk to the existing Tollworks gate, use E, return through its normal gate and walk back to the dock. Counts remain exactly equal to the pre-travel inventory. Monotonic elapsed time is asserted separately from the stable restart oracle. Eight villagers and two party wrappers remain present after revisit. |
| Failed save preserves previous slot without another reward | Rich integration and independent rich reader obstruct only their isolated `.tmp` path with an owned directory. Actual root Save reports IO failure, leaves primary/backup bytes and every live fact unchanged; previous slot still validates. Removing only that owned obstruction and retrying Save changes no fish/facts. Three canceled phases save/load exactly without transient resurrection. |
| Rich old facts survive independent processes | [Process checks](../../game/tests/fishing_process_checks.gd) separately share one isolated write/read slot. Synthetic complete social/gift/quest/party/flower/lamp/weather baseline plus all three landed species is saved with golden carp selected. PIDs44848/54904 differ; exact typed complete snapshot/forecast matches before any resumed assertion. Every species count1 and selection restore, paused re-save is inert, failed-save/retry preserves facts. This synthetic pair does not replace the ordinary GUI pair. |
| Existing-game regression | Final27 focused suites all pass: fishing session/reward/lifecycle/UI; inventory/foraging transactions/save/physical interactions/bag/placement; social transactions/save/gift UI/all-eight integration/People/NPC integration; shortened recovery/combat/ally; travel/movement/camera/water/crossings; lamps/environment/startup. Fresh synthetic renderer225 assertions and57 inspected frames show all species in bag, pre-cast/landing capacity and all failure results, live phases across lighting/projections/sizes and teardown. No production runtime/content/geography change was needed. |

## Scope and preservation

New reusable files: the three linked GDScript fixtures and their generated UIDs.
Documentation: this acceptance, [CHECKLIST](CHECKLIST.md), [CURRENT_STATE](CURRENT_STATE.md).
No existing game/tool/source/asset/schema/native/package/instruction file edited.
Inherited scenario adapters reuse existing normal pickup/drop/gate, GUI, journey,
snapshot and capture owners; no copied navigation or timing loops.

The rich fixture normalizes synthetic starting hero health before recording its
oracle because the inherited legal cast fixture starts healthy. This is declared
fixture setup; ordinary gameplay receives no healing or other state setup.
Schema7/content1, catalog ownership, atomic existing inventory rewards, rod1
conservation, manual saves and transient attempts remain unchanged.

Read-only source HEAD `60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean.
Live reference audit143 passes before/after; all18 pins and target layout SHA256
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be` match.
Independent G001-G009 remains Done; native baseline/packages preserved.
The future FS008 invocation must still reverify its current delivery gate.

## Commands and isolated results

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7.
Supplied Godot console/editor paths exist; engine
`4.7.2.stable.mono.official.ed1daf0bf`, Compatibility renderer.
Root AGENTS, fishing prompt/checklist/handoff/contract, current architecture,
FS006 acceptance and project-owned gameplay-testing skill/references/PLAYTEST read.
No nested AGENTS or workspace/repository `.agents` directory found.
No agents, other conversations, chats or schedules used.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/fishing/reference_audit.py --source-root D:/development/game-prototype-2
./tools/run_checks.ps1 -Task FS007 -Names fishing_integration_checks -ProcessScripts fishing_process_checks -RenderScript fishing_integrated_render -RenderPhases write,read -ParseScripts tests/environment_review,tests/live_playtest_bridge -TimeoutSeconds 600
./tools/run_checks.ps1 -Task FS007 -Names fishing_session_checks,fishing_reward_checks,fishing_lifecycle_checks,fishing_ui_checks,inventory_checks,foraging_transaction_checks,foraging_save_checks,foraging_interaction_checks,backpack_ui_checks,world_item_placement_checks,social_transaction_checks,social_save_checks,social_gift_ui_checks,social_integration_checks,people_journal_checks,npc_integration_checks,recovery_presentation_checks,combat_checks,companion_checks,location_travel_checks,movement_camera_checks,map_camera_checks,map_water_checks,map_crossing_checks,light_interaction_checks,environment_lifecycle_checks,application_smoke -RenderScript fishing_ui_render -RenderPhases check -ParseScripts tests/environment_review,tests/live_playtest_bridge -TimeoutSeconds 180
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/FS007/20261009-052244450-562877fb/render/write-index.json
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/FS007/20261009-052244450-562877fb/render/read-index.json
```

Accepted integration/ordinary run:
`docs/evidence/FS007/20261009-052244450-562877fb/results.json`.
All7 cases PASS/exit0; integration59, synthetic process writer23/reader22 assertions.
One check group, one rich writer/reader group and one ordinary rendered writer/reader
group are isolated under matching `builds/testing/FS007/<run>/` APPDATA/LOCALAPPDATA.
Normal saves and historical evidence untouched.
All1031 game/tools files stable, digest
`46304c72ab1af127ca9cee167f34a1ae9a33e77f9a8986e30a12a9b061070d78`;
source.changed=false/error=null, no runtime/parse diagnostics or timeouts.

Ordinary visual manifests: write23/read5 PNGs, all provenance/integrity checks pass.
All28 frames inspected on three sheets and selected full-size fight/restored bag.
Writer review `render/derived/20261009-052537-24ad9788/capture-report.json`;
reader review `render/derived/20261009-052647-1e084715/capture-report.json`.
Readable actual BITE/Reel/tension, anchored water cues, rejected dry target,
unforced fish icon/count/selection, Save/Load statuses and final pause confirmed.
Paused terminal/site frames establish safe checkpoints, never active-phase proof.
Live captures retain actual phase/token and automatic-time settling provenance.

Retained excluded runs:
- `20261009-052133285-b0417121`: sandbox engine launch access denied; scoped runner
  escalation approved subsequently, no automatic approval rejection.
- `20261009-052149981-3ee3796e`: first import generated three UIDs, correctly
  invalidating source stability. UIDs reviewed and retained. Known import-only
  SDK10.0.9 advisory remains; no installation needed.
- `20261009-052209471-a6d1466f`: rich fixture started injured while inherited
  synthetic cast heals; exact +1-only oracle correctly failed for first bluegill.
  Synthetic starting health was normalized before its baseline; accepted stable
  run proves exact equality. Production and ordinary health behavior unchanged.

Final affected regression run:
`docs/evidence/FS007/20261009-052616250-f33827b1/results.json`.
All30 cases PASS/exit0: version, parse,27 selected suites, existing fishing_ui_render.
Twenty-seven independent check groups plus one rendered group; normal saves remain
untouched. Same1031-file digest as the accepted integration/ordinary run, with
source.changed=false/error=null and no runtime/parse diagnostics or timeouts.
Session57/reward72/lifecycle344/UI75/inventory199/transaction587/foraging-save111/
physical-interaction130/bag148/placement128/social-transaction238/social-save844/
gift-UI355/social-integration402/People134/NPC97/lamp151/environment157 assertions.
Recovery/combat/ally/travel/movement/camera/water/crossing/startup pass too.

Current synthetic visual review:
`render/derived/20261009-053137-9ba4c0f4/capture-report.json` under that run.
All57 PNG integrity/provenance checks pass; all five contact sheets and full-size
pre-cast capacity frame inspected. Real capacity text, missed hook/other outcomes,
three species icons/counts/selection, live warning/danger and day/night/rain across
both projections/sizes remain readable. These57 synthetic frames do not add an
ordinary or native catch claim. Combined inspected evidence85 PNGs/eight sheets.

Final owned launcher/observed-engine PID lookup: none alive. Every accepted process
exited normally; ordinary writer/reader have explicit production quit logs. No
owned editor/game/input, obstruction or cleanup remains; no unowned process stopped.
Final source pin/hash, intended nine-file scope, docs/link/status/whitespace read-back
and source-manifest recheck pass. HEAD unchanged, no commit/push/publication.
FS007 Done; blockers none. Remaining/next ID FS008; not every item through FS008 is
complete. Windows export/native timing/restart remains FS008, whose independent
G009 delivery gate must be checked at its own invocation. Stop before successor.
