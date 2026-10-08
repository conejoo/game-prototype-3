# F009 — Integrated gameplay and restart acceptance

Completed 2026-10-07, America/Vancouver. Exactly F009 completed; F010 Pending.
Initial HEAD `f352d7b70d5ddba53e60ef9df7f8f1b272b2bb8c`; worktree clean.
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns behavior.

## Delivered result

Added [foraging_integrated_render.gd](../../game/tests/foraging_integrated_render.gd)
and its Godot UID. It reuses TestRunJourney, GUI, exact snapshot and pause/live
capture support through the existing backpack/placement renderer helpers.
One fresh ordinary journey walks from spawn to rod and all three flowers,
cancels an actual hold with B, requires fresh E, selects flower/rod through the
backpack, drops/drags/recollects the rod, rejects a water release, switches camera
with P, switches a lamp with immediate E, travels to Tollworks and back, then
uses GUI Save and production F10 quit. A different process uses GUI Load, compares
every durable fact and forecast exactly, walks to each absent flower and physically
recollects the saved world rod. Both processes quit through F10 while paused.

No pose, reward, selection, environment, travel or save mutation shortcut supplies
the ordinary journey. Reads of current wrappers/session facts establish outcomes;
navigation guides bounded camera-relative viewport WASD through actual collision.
Writer engine PID16572 and reader PID20052 differ. Normal arrival-anchor restore
is retained; arbitrary player position is not persisted.

Repaired two inherited test fixtures: companion/quest v1/v2 envelopes now omit
the three schema6 fields before legacy validation. They additionally assert empty
inventory/null selection/one authored rod after migration. Quest's isolated raw
legacy file now creates and checks its parent directory before writing. Strict
production schema validation remains unchanged. Updated README controls and
architecture discovery. No production game/content/physics/save/input code changed.

## Every acceptance criterion

| Criterion | Fresh evidence and result |
| --- | --- |
| All CONTRACT behavior observed | Six feature suites verify20 types/21st rejection, caps99/1, full existing-stack growth, invalid IDs/quantities/selection, atomic world/bag commits, stale/wrong-room/duplicate rejection, placement rollback, legacy/hostile saves and lifecycle ownership. Integrated ordinary route adds all-four physical gathering, honest flower/tool selection, fresh input after modal cancellation, drop/drag/recollect, both projections, immediate lamp and gate input. PASS. |
| Modes, focus, combat and retry | foraging_interaction_checks103, backpack_ui_checks148 and world_item_placement_checks128 assertions exercise release/LOS/range/target loss, every modal/focus/travel/load/retry gate, attack/dodge conflicts, fresh input and unchanged facts on cancellation. These forced mode/pose/boundary cases are synthetic. Ordinary B cancellation/selection/close is separately rendered in the integrated route. Combat/companion/recovery regressions verify shared actor damage, assist, safe recovery and retry with existing progress retained. PASS. |
| Exact paused restart snapshot | GUI Save matches independently decoded typed disk snapshot. Separate-process GUI Load uses TestRunSnapshot.compare_restored with its different-PID requirement: exact entire schema6 snapshot and forecast match both writer oracle and typed disk. No timer tolerances, omitted prior fields or JSON-number dictionary comparison. read-index restart_errors/failures empty. PASS. |
| Origins absent, rod unique, no stale input | All four collected IDs remain absent after gate round-trip and Load. Reader physically revisits every flower, then picks up the restored generated rod; rod_count remains1, placement disappears and origin stays suppressed. Hold/drag/preview/backpack start inactive after Load; fresh ordinary movement/E/B/Enter work. PASS. |
| Existing recovery, companion, lamps and environment work | Final17 regression suites all PASS, including playable slice/reconnection presentation, combat/companion, dialogue/quest/consequence, lamps, environment lifecycle/lighting/weather, map activation/travel, settings and movement/camera. Ordinary E lamp override participates in the integrated exact restart snapshot. PASS. |
| New suites and affected regressions, no runtime errors/warnings | Final feature run, repaired quest/prior-save process run, full regression run and art run all exit0 with no timeout, forbidden diagnostics or observed source changes. Direct dependency parse gates PASS. Import was verified earlier with only the existing editor-only missing .NET SDK10.0.9 allowance. PASS. |
| Fresh visuals inspected; fixtures labeled |22 integrated captures and96 matrix captures pass structural/state/provenance validation. Reviewed both integrated contact sheets, all eight matrix sheets and full-size ordinary hold/restored bag/GUI Load, night hold, rain invalid preview and night flower images. Items/counts/prompts/progress/invalid feedback remain readable; no item UI clipping or new overlap observed. Matrix72 pose/clock views and24 actual live inputs after forced setup explicitly say synthetic. Capacity and invalid-save/placement checks are labeled synthetic, never ordinary-route proof. PASS. |
| Frame cost if unresolved concern | No unresolved frame-cost concern emerged. F009 adds test/documentation work only, with identical production runtime/assets to accepted F008. Historical M018/W009 measurements retain their limits; no new FPS benchmark or performance comparison claimed. Conditional measurement not required. |

## Commands and evidence

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7,
installed Godot4.7.2.stable.mono.official.ed1daf0bf, Compatibility/NVIDIA renderer.
Arguments below follow `./tools/run_checks.ps1`:

| Run ID | Arguments | Actual result |
| --- | --- | --- |
|20261008-031053900-b9da6852| -Task F009 -Names inventory_checks,foraging_transaction_checks,foraging_save_checks,foraging_interaction_checks,backpack_ui_checks,world_item_placement_checks -ProcessScripts foraging_process_checks -RenderScript foraging_integrated_render -RenderPhases write,read -TimeoutSeconds 180 | PASS12 cases. Feature assertions199/587/112/103/148/128; independent item process phases76/79; ordinary integrated writer/reader and F10 exit,22 captures. |
|20261008-031422144-0870da15| -Task F009 -Names quest_checks -ProcessScripts save_process_checks -TimeoutSeconds 150 | PASS repaired quest fixture and independent prior-fact save write/read. |
|20261008-031504017-7fdd1f1c| -Task F009 -Names application_smoke,playable_slice_checks,recovery_presentation_checks,combat_checks,companion_checks,light_interaction_checks,environment_lifecycle_checks,map_activation_checks,location_travel_checks,settings_debug_checks,interaction_dialogue_checks,movement_camera_checks,quest_checks,consequence_checks,environment_lighting_checks,weather_presentation_checks,reference_mapping_checks -TimeoutSeconds 150 | PASS17 suites plus engine/parse preflight. Final runtime scans empty. |
|20261008-031503607-55eccf9a| -Task F009 -RenderOnly -RenderScript foraging_art_render -RenderPhases check -TimeoutSeconds 150 | PASS880 assertions/96 captures across all four items, day/night/rain, both projections and zoom1.0/1.15/0.8;24 live hold/release/preview captures. |

Each runner uses fresh `docs/evidence/F009/<run>` and
`builds/testing/F009/<run>` isolated APPDATA/LOCALAPPDATA. Independent checks have
distinct save groups/slots; each process or render write/read pair explicitly shares
its own group. Normal save slot and source checkout untouched. Reports retain command,
cwd, engine identity, exact owned PIDs, isolation paths and logs. All owned processes
exited; no live editor/process or cleanup owed.

Feature/ordinary run source SHA256:
`73d912a1ef80f2478ecaafe36ab92c7193e8e7afe6255a8cfa13f50ed2661797` (492 files).
Final quest/process/regression/art source SHA256:
`a250a48136bc8e1bc8b055cfde33d050f17fa5bff75ce17b2b46d2d533439706` (492 files).
Compared manifests: the only difference is quest_checks.gd's isolated-directory
preflight, added after the ordinary run exited. Every production file, feature check,
process fixture, integrated harness and helper byte remains identical. Every accepted
run has matching before/after digests, source.changed=false and source.error=null.

Bundled Python `tools/capture_evidence.py` validated integrated write/read-index.json
and art-index.json:22/96 PNG hashes, correct pause/live/modal/drag state, engine/camera
and setup provenance. Derived reviews are respectively
`render/derived/20261008-031433-aba0bcdf` and
`render/derived/20261008-031558-26d8bbda` under those accepted runs.

Bundled Python `docs/foraging-items-backpack/reference/audit.py --source-root
D:/development/game-prototype-2 --self-test` PASS20 source/three reference/three
geography hashes and six negative controls. Archived result:
`docs/evidence/F009/audit-20261008-0317/results.json`. Source status clean using
command-local safe.directory; no global Git configuration change.

Final review: intended diff and all new sources/UID reviewed; command-local
`git -c core.whitespace=cr-at-eol diff --check` PASS. Local Markdown links in
README, architecture, checklist, current state and this acceptance all resolve.
Checklist/status/next-task agree.

## Retained failures and limits

20261008-030629498-2b370094: sandbox denied installed engine launch; reran with
approved escalation.030647149-ddc2183f: import generated new UID, intentionally
invalidating source guard.030701801-76e35152: earlier full feature/integrated PASS
before adding production F10 quit.030731754-070d32e9: stale companion legacy fields
failed; other13 suites passed.031114570-f97cc13b: quest raw migration file's missing
isolated directory failed; other16 suites passed. All failures retained, repaired
and freshly rechecked; no failed/unrun F009 acceptance criterion remains.

Rendered evidence proves debug viewport gameplay/GUI integration. Focus notifications,
capacity, save corruption and geometry boundaries are explicitly synthetic fixtures;
they do not prove OS keyboard/mouse input or an exported package. F010 alone owns fresh
Windows/native delivery. No export, publication, commit, push, install, external
message, automatic agent/chat/schedule or source/geography refresh performed.

Next eligible F010: F009 prerequisites actually pass. Complete exactly F009; stop.
