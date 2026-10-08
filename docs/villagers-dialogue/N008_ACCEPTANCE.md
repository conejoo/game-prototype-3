# N008 acceptance - Edric first complete vertical slice

Completed 2026-10-08 UTC. Exactly N008; no N009 implementation, commit or push.

## Result and prerequisites

Mayor Edric Vale (`npc-01`) is reachable through ordinary fresh town play at the
pinned civic foot `(-0.5,0,-1.5)` / approach `(-0.5,0,-0.5)`, stable instance
`alderwake-npc-01-contact`. E opens the actual source graph with source portraits,
exclusive introductions, remembered woods lines and the Moonflower disclosure.
One custom editable/animated 3D asset mounts under the existing noncombatant
wrapper. Physics/navigation/Party ownership stays outside art.

N006/N007 actual code, placement/pipeline evidence and N001/N002 pins inspected.
Target began clean at `6c8c15031a5b37a32b5fb6cbf9a0f70fd9b40d85`; source remains
clean at `60c20eb2816e7271fb84afaba286af006ebe3ccf`. Read-only converter checks
all132 authority hashes/67 outputs. Catalog remains
`9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.
Schema7/content1, six byte-exact Edric portraits, other people/graphs, pinned
geometry, current recovery/companion/weather/foraging features and saves retained.

## Files and actual interfaces

- `art/source/npc-01.blend`, `build_npc_01.py`, `normalize_npc_01.py`,
  `audit_npc_01.py`, `check_npc_01_source.py`; `art/exports/npc-01.json` and
  [working package template](../../art/exports/NPC_01_PACKAGE.md).
- `game/assets/models/npcs/npc-01.glb`, retained import UID/linear idle/walk loops,
  extracted embedded palette PNG/import record.
- NpcRegistry enables exactly npc-01 and maps `VISUAL_ASSETS` to its real GLB.
  NpcWorldAdapter owns a `presenters` map and mounts under VisualRoot/Presenter.
  `sync_visuals(holds,speaker,player_foot)` forwards independent holds and facing;
  root calls it on control changes and process ticks. Fixed contacts stay idle.
- `npc_01_checks.gd`/UID and `npc_01_render.gd`/UID. Narrow updates to historical
  world/calibration activation assertions and location_travel_checks: fresh civic
  E may correctly open Edric, so its travel oracle closes via real Esc first.
- Checklist, contract, current state, README/architecture discovery and this report.

The mesh is custom shaped geometry, not a recolored calibration. Only rig/loops
are reused. Public reference silhouette/face, swept brown/grey hair, blue eyes,
beard, blue/gold civic coat, cream collar, chain/leaf medallion, green trousers and
brown boots inform a low-poly 3D adaptation. It is not a photoreal reconstruction.
Private profile text is not copied into runtime/public facts.

## Acceptance matrix

| Required criterion | Evidence and result |
| --- | --- |
| Complete named package/identity/portraits/public graph | Real npc-01 .blend/GLB, source catalog and six original PNGs; source/raw/editable audits PASS. Npc_content_checks423 assertions/75 malformed candidates, exact eight graphs/assets and detached publication PASS. |
| Ordinary physical contact/introduction/follow-up/exit/reopen | Final writer physically walks to approved civic approach, E opens real intro, pointer accepts helpful branch, Esc exits, E reopens follow-up. Contact phase separately captures body at unchanged normal camera after actual walk. No teleport/forced flags in these journeys. |
| Alternative introduction/exclusivity/one-time effects | Separate fresh isolated neutral run uses second GUI response, affinity0/one receipt; helpful writer affinity1/one receipt. Stale alternate rejection changes no facts. Both reopen follow-up, never both introductions. |
| Real woods first/repeat and exactly-once fact | Writer makes seven ordinary WASD journeys: civic, first woods/return, repeat woods/return, Moonflower/return. First woods edge selects woods-first once; repeated crossing selects woods-repeat. Actual held E commits one moonflower-01 gather, maps to resourceGathered/moonflower/null, then selects Moonflower hint. Reopen shows one learned preference without redisclosure. |
| All enabled/deferred graph paths and public disclosure | All seven enabled Edric nodes/two enabled introduction choices covered by ordinary writer plus neutral. Shared rules977 assertions cover all58 enabled roster nodes/38 choices and135 rejection commands. Deferred gift-response/milestone remain excluded; both gift choices unavailable honestly. Disabled pointer gift consumes/rewards nothing. Level remains0; role/fishing facts stay unknown; no artificial unlock. |
| Cross-person/quest/inventory/companion boundaries | Writer asserts other seven memories remain empty and no quest effects/trust changes. Inventory changes only from actual gathered flower. Disabled gift cannot consume it. Existing interaction/quest/foraging/light regressions PASS. |
| Imported rig/clips/portable art/budgets | Raw GLB7,614 triangles,16 bones,one material/one packed32x32 RGBA texture,313,756 bytes. Exactly idle4s/walk0.8s,48 baked channels each,zero raw endpoint error/external URIs. Normalized mainfile opens active RF-Npc01-Edric with exactly root/rig/mesh, packed image, no drivers/constraints. |
| Feet/envelope/facing/transitions | Named skin722 assertions including evidence write;120Hz481 idle/98 walk samples,196 planted stance samples and120 blend samples. Soles min0; idle bounds size(.706964,1.596946,.336598)m; walk(.706964,1.596661,.600000)m. Loop seams0; stance max drift2.3841858e-7m at.8m/s; blend max vertex step.0127691m, no sunk soles. Actual speaking facing changes visuals only. |
| Viewed day/night/rain/default camera and expressions | Compatibility NVIDIA RTX4070 Laptop/OpenGL3.3 renders; full front/profile/back/face, sixteen day/night loop samples/five real blend captures and actual exterior day/night/rain plus size18 default-camera surveys inspected. Portrait/body/fact/gift text readable in real960x640 UI. Final rain really renders rain; earlier mislabeled/obscured survey retained as superseded. |
| Actual root lifecycle/one wrapper after travel/retry | Root pause and focus freeze/resume named pose; actual dialogue holds/release tested. Travel disposes original presenter; return/retry reconstruct exactly one wrapper/presenter. Npc_world_checks all-eight fixtures10,253 assertions/10,131 route samples PASS; revised travel suite10 round trips, rejected IDs/unsafe rollback/pause/focus/input/ownership PASS. |
| Exact save/reload of this person and every prior field | Actual GUI Save writer enginePID8056, quit0, new readerPID8560 GUI Load and exact TestRunSnapshot typed whole-state/forecast comparison PASS before resuming. Reader physically revisits Edric and sees one remembered preference. Separate synthetic NPC-process pair also retains populated prior/current fields. Only fresh isolated data/slots used. |
| Repeatable package and honest exposure | NPC_01_PACKAGE.md documents actual authoring/mapping/registry/mount/lifecycle/test pattern. Idle ordinary; walk review-only; fishing stays N016. No gift/routine/fishing reward or native package claim. |

## Commands, runs and isolation

All commands from repository root, PowerShell7. Installed console:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
Python: `C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe`.
Authoring uses existing skill MCP client/live Blender5.2.2 at127.0.0.1:9876; original
RF-RecoveryVessel scene/file is preserved, owned Edric scene remains available.

```powershell
& $python tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
& $python art/source/audit_npc_01.py --output docs/evidence/N008/authoring/raw-glb-audit.json
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background 'D:/development/game-dev-blender/returning-fair-prototype/art/source/npc-01.blend' --python 'D:/development/game-dev-blender/returning-fair-prototype/art/source/check_npc_01_source.py'
./tools/run_checks.ps1 -Task N008 -Names npc_01_checks,npc_content_checks,npc_dialogue_rule_checks,npc_save_checks,npc_world_checks,npc_asset_pipeline_checks,interaction_dialogue_checks,quest_checks,foraging_interaction_checks,light_interaction_checks,location_travel_checks,application_smoke -ProcessScripts npc_process_checks -RenderScript npc_01_render -RenderPhases write,read,review -TimeoutSeconds 240
./tools/run_checks.ps1 -Task N008 -Names location_travel_checks,npc_01_checks,npc_dialogue_rule_checks,npc_save_checks,application_smoke -ProcessScripts npc_process_checks -RenderScript npc_01_render -RenderPhases write,read,review -TimeoutSeconds 240
./tools/run_checks.ps1 -Task N008 -RenderOnly -RenderScript npc_01_render -RenderPhases neutral -TimeoutSeconds 120
./tools/run_checks.ps1 -Task N008 -RenderOnly -RenderScript npc_01_render -RenderPhases contact,review -TimeoutSeconds 120
```

Every shared run uses `docs/evidence/N008/<run>/` and matching fresh
`builds/testing/N008/<run>/{appdata,localappdata}` containers with per-check named
slots. Only writer/reader explicitly share their group's slot. Neutral has its own
new runner group. Reports record exact arguments/cwd/PIDs/exits/app-data/slots;
normal user saves untouched. Evidence writer/diagnostic/source guards unchanged.

| Run | Exact outcome |
| --- | --- |
| 20261008-111157041-06433481 | Expanded12 named checks:11 PASS, travel FAIL; application smoke still PASS. Overall failed; process/render phases not run. All required content/world/pipeline/interaction/quest/foraging/light suites passed. Only later change outside renderer was travel fixture correction, no production change. |
| 20261008-111537969-95b2a472 | Final focused12 cases all PASS/exit0: version/parse, five named checks, synthetic process pair, ordinary writer/reader and art review.721 named JSON assertions/722 including write. Writer52/read15 assertions,10+3 captures. Zero forbidden diagnostics/timeouts/source changes. |
| 20261008-111802387-2f19dc1a | Separate isolated neutral: all3 cases PASS/exit0,18 assertions/four captures; source bytes identical to focused run. |
| 20261008-111859620-b2544153 | Review-camera refinement: all3 cases PASS; no production change. Superseded by final survey below. |
| 20261008-112104670-8bbb2263 | Final contact/default-distance/full-body-weather survey: all4 cases PASS/exit0,20 contact/38 review assertions,5+31 captures. Only additional renderer review/contact paths since prior gameplay run; writer/read/neutral actions unchanged.803 game/tools files stable at275581a3b069fa3af4260db7f2066b39fae811564b24d5111f092c835a2fa734. |

Final acceptance selects53 captures: writer10,reader3,neutral4,contact5,review31.
All inspected through sheets plus full-size source/portrait/fact/neutral/identity,
ordinary camera and final exterior day/night/rain/default-scale images. Studio,
seeded weather/camera/visibility fixtures and ordinary journeys are labeled separately.
Survey hides party visuals/Label3D annotations only in review; production untouched.
Pause overlay is confirmed around ordinary analysis boundaries; live dialogue capture
uses the shared modal/token/provenance guard. Raw evidence remains ignored.

GLB SHA256 `4aeb9d211342f15bef34b3466035a90172a4146d94a82e12f550ce7b1c5bb41a`.
Editable .blend SHA256 `8175368c4291b449b3fec38f7f2c152a09fbd5b4da55370d2c18cd31a952d647`.

Final audits retained under `20261008-112104670-8bbb2263`: `final-audit.json`
checks all803 current source bytes, unchanged target HEAD, clean source pins,
asset hashes, all18 task rows/dependencies, local documentation links and exact
accepted/failed report statuses. `visual-review.json` hashes and verifies dimensions
of all53 selected PNGs. `process-audit.json` checks all95 recorded engine/launcher
IDs across N008 runs: none remains running; no termination performed.

## Failed/superseded attempts and retained limits

- 110303948-6505fae1: sandbox owned-process observation denied at import;
  auto-review allowed isolated runner execution. No current permission blocker.
- 110347577-8df120c0 and110709209-32311f08: strict source-change failures from
  generated import/texture/UID metadata. Retained metadata and reran; no guard bypass.
- 110735365-17daa768: initial five-case skin/review run PASS, but survey camera
  obstructed body and clock labels swapped. Retained as initial evidence only.
- 110912123-0844c666: ordinary writer/read/neutral PASS; purported rain remained
  clear on first-day forecast. Later review explicitly checks real rain at day1.
- Expanded travel assertion failed because new correct civic interaction suspends
  controls. Fixture closes it via Esc before unchanged rejected-command oracle;
  final10 round trips and unsafe rollback gates PASS. No production workaround.
- Studio walk is review-only. N016 owns actual fishing art. Gifts, milestone,
  routines, private/interior/story expansion and N018 native release remain deferred.

No remaining N008 criterion/blocker. All owned engine/helper/background processes
exited; existing Blender remains open on its original scene with owned Edric scene
available. No user-editor cleanup, normal saves, agents/chats/schedules, installation,
external message/publication, commit or push. Next eligible N009; N010-N015 also
independent after N008. Remaining N009-N018; all through N018 are not complete.

## Authorized commit follow-up

After acceptance, the user authorized committing N008 under the successful-task
commit policy. The implementation/art, reusable validation fixtures, this evidence
summary, package documentation and durable workflow/discovery updates are included.
Raw ignored runs/captures/appdata stay local under the existing evidence policy.
Pre-commit scope and unchanged accepted runtime/art bytes, then commit identity,
tree and working-tree status are audited in the latest local N008 evidence folder.
The resulting commit identity is available in Git history and the follow-up report.
No unrelated change, push or N009 implementation is included.
