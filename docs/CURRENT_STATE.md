# Current prototype state

Updated: 2026-10-03 (America/Vancouver). P001–P013 verified complete.

## Current task

P014 in progress — extension check and Windows export. Resume P014 only.
Extension and exported debug gameplay pass. Full native release journey remains
unverified; no P014 completion record. No next checklist item defined.

Fresh route: optional purple companion station; southwest Maris lead; J upgrade;
north Tollworks gate; guardian; southeast vessel; north return; practical fitting;
restored specialist preview. WASD/mouse/Space, E, J, Esc, R retry, F10 quit.
Close modals/finish or retreat from combat -> pause Save. Reopen -> pause Load ->
Resume. Explicit saves only; placement uses last arrival anchor.

## Implementation and files

Initial Git clean at 86d5756. Applicable rules, architecture/checklist/handoff,
actual services/wrappers/imports/Git verified. P013 slice prerequisite PASS0.
No unrelated changes. Source game and normal save untouched. No Blender edits,
subagents, engine/SDK installs, commit, push or publication.

- game/features/quests/{quest_definition,quest_service}.gd and content/quests/maris_recovery.tres:
  authored journal_note/completion_text replaces hardcoded Maris presentation.
  First quest wording, transition rules and session ownership unchanged.
- game/tests/extension_checks.gd/.uid; fixtures/extension_{guardian,quest,location}.tres,
  extension_room.tscn: detached manifest adds second quest, 60-health guardian,
  inherited room. Once-only effects, first-progress isolation, shared actor wrapper/
  collision after visual swap, plain save round trip and room travel tested.
  Fixture saves deliberately fail normal exact-quest-set validation.
- game/export_presets.cfg: project-local standard templates; release excludes tests;
  separate debug validation retains opt-in bridge, excludes other test content.
- game/project.godot: disable text-to-binary export conversion after standalone
  lost PackedStringArray spawn/dialogue values. Rebuilt runtime validates 17 defs.
- game/tests/live_playtest_bridge.gd: exported guard derives builds/playtest from
  executable directory. Editor contract retained; no state/objective command.
- README, ARCHITECTURE narrow metadata/export boundary, CHECKLIST progress,
  docs/evidence/P014 commands/logs/hashes/input traces/inspected captures.

## Checks and builds

Full exact commands/results: [P014 validation](evidence/P014/VALIDATION.md).
Supplied executables exist. Editor4.7.2.stable.mono.official.ed1daf0bf; templates
4.7.2.stable; exported runtime same ed1daf0bf. Official standard package downloaded/
extracted under ignored builds/p014; no global install. Restricted download exit7,
normal-access retry exit0. Existing editor-only missing .NET SDK10.0.9 message.

Console from project root, all use --headless --path game:

- --editor --import --quit: initial/final exits0.
- --script res://tests/{extension,content_catalog,quest,save,playable_slice,
  live_playtest,asset_pipeline,recovery_presentation}_checks.gd: all PASS0.
  Final extension/live_playtest/quest/save reruns PASS0 after repairs.
- --export-release 'Windows Desktop' ../builds/windows/ReturningFair.exe: exit0.
- --export-debug 'Windows Validation' ../builds/windows-validation/ReturningFairValidation.exe:
  exit0; repaired final pack tested. --export-pack 'Windows Desktop'
  ../builds/p014/release-audit.zip: exit0, inventory has zero test/extension entries.
- git diff --check: exit0. Accepted debug/native release logs have no runtime errors.

Window b: exported debug fresh run; ordinary inputs trust+1/lead1/upgrade25->40/
gate2/companion combat/guardian death3/vessel4/return5/fitting6/restored preview.
Idle hero death required normal R before fight; no setup/mutation. GUI Save/F10 exit0.
Window c new executable GUI Load6, trust replay unchanged, spent upgrade, guardian0,
round trip and restored preview pass; F10 exit0. Window d from executable directory
(no editor/project path) Load6/revisit6 pass, F10 exit0.

Native release: app access authorized after initial approval timeout. Startup,
canvas attack, Esc, GUI Save, F10 exit0; new process from build directory GUI Load
restores elapsed135.476898/health100/party2/neutral quest, Resume/F10 exit0.
These prove startup/empty-run persistence, not full release quest. Invalid initial
foreground capture discarded and recaptured. Failed/forced-stop attempts retained
separately, never accepted as passes.

## Decisions, limits and remaining gate

Schema4/content1 and production IDs unchanged; no permanent narrative decisions.
Existing .blend/GLB/collision/navigation retained. Binary-resource export failure
repaired using text resources; first debug guard failure repaired using executable
directory. Release contains no test scripts/fixtures. Local unsigned exe+pck only.

Windows11 Home10.0.26200 x64, Core Ultra9 185H, ~32GiB, RTX4070 Laptop,
NVIDIA581.29/OpenGL3.3 Compatibility. Debug viewport960x640; independent load/revisit
--print-fps samples228–240FPS (4.16–4.38mspf), not broad benchmark. Native capture
643x458 including chrome/scaled client. No minimum hardware or physical-keyboard claim.

Blocker: computer-use API exposes press_key taps, no held-key action. Observed
WASD taps did not move actor even after canvas focus; native GUI/attack input works.
Safe next action: human plays builds/windows/ReturningFair.exe from fresh start,
full quest -> GUI Save -> F10 -> reopen -> GUI Load -> verify specialist/guardian/
trust/upgrade and room revisit; or supported held-input API. Record release
captures/save/logs and exact quits, then mark P014 complete only after this gate.
Current local override.cfg isolates release user:// at
%APPDATA%/ReturningFair-P014-ReleaseValidation; normal slot stays untouched.
Debug slot: playtest-p014-standalone.json. No next item started.
