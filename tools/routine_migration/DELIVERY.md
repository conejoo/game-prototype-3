# R016 Windows delivery

Run from the repository root with the installed Godot 4.7.2 console, bundled
Python and PowerShell 7. These tools do not commit, push, install or publish.

`build_packages.py [--promote]` archives and hashes both previous canonical
packages before exporting Windows Validation/debug and Windows Desktop/release
into a unique `builds/day-clock-npc-routines/R016/<run>` directory. Every export,
routine audit, fishing audit and outside-checkout startup has separate isolated
APPDATA/LOCALAPPDATA. Production game bytes must stay stable around each case.
Promotion requires all eight passing cases and retains the original override.
Both presets exclude tests and include the exact NPC and routine JSON files.

`package_audit.gd` is an external read-only packed-resource audit. It initializes
the strict 25-routine catalog, checks both rooms, eight rig mappings/portraits,
production action clips, schema8/content1 inventory, pinned geography and
test/private/source/authoring exclusions. It starts a packed production root and
checks its single shared director and eight assignments. Audit execution and
headless startup do not establish native gameplay acceptance.

`launch_native.ps1 -Session <fresh-name> -Phase writer` creates an exact hashed
release/pack/override copy in `TEMP/ReturningFair-R016-<session>`, outside checkout.
Writer and reader share a fresh isolated restart app-data group. Reader requires
the writer's actual GUI save; it never supplies state or opens Load automatically.
The helper records launch identity, package hashes, save path and exact exit code.
Use a new session after an incomplete writer. Preserve failed evidence.

Use `tools/npc_migration/invoke_native.ps1` for bounded requests and
`tools/native_evidence.py` for read-only provenance review. Native path guards
require R016 run-child evidence, a direct TEMP copy, canonical hashes and no
reparse points. Existing executable/PID/window/unlocked Default desktop/foreground/
client bounds and acquired-input cleanup checks remain mandatory.
`native_guard_checks.ps1` and `tools/tests/native_input_checks.ps1 -EvidenceTask
R016` are synthetic guard/dispatcher checks; they do not send OS input.

Inspect actual pause/modal captures before subsequent input. Public walking must
visit town, Mayor Vale home and Lantern Rest, observe a natural solo/group
transition, talk/gift and complete Maris recovery. GUI Save, normal quit, new-PID
GUI Load, exact typed durable/forecast comparison and physical revisits remain
required. R015's full day and deterministic branch evidence complement these
checks; neither a debug bridge nor package startup can substitute for native input.

Native helpers: walk_native.ps1 steers bounded public WASD from inspected pause
using read-only release position/arrival logs; room-aware native_route.gd generates
synthetic navigation guidance in a detached isolated process. Guidance never
places the live player or supplies progress. save_oracle.gd replays copied actual
GUI writer/reader saves through packed production SaveCodec and WeatherSchedule;
syntax check alone cannot establish the restart oracle.

Current disposition: user requested stopping checks and committing R016 as-is.
Package/focused/reference checks passed. Native town/home/inn returns, natural
solo/group observations, talk/gift, earned Maris lead/preparation and three GUI
Save checkpoints are recorded. Latest writer logged normal paused quit/exit0.
Full Maris recovery, final recovered Save, new-PID GUI Load, exact whole typed
primary/backup/forecast oracle and physical remembered restart revisit remain
unrun. Retained failed focus/provenance attempts are not accepted. R016 stays
Blocked/incomplete; R001-R015 Done; all throughR016 complete:no.
Owned native/controller processes are gone; exact owned TEMP copies removed,
inputs released, isolated evidence/saves and unrelated files preserved. No push
or successor. No further testing follows this user-approved as-is commit.
Consult [R016 acceptance](../../docs/day-clock-npc-routines/R016_ACCEPTANCE.md)
and [current handoff](../../docs/day-clock-npc-routines/CURRENT_STATE.md).
