# AD020 local Windows art delivery

Run from repository root with installed Godot 4.7.2, Python and PowerShell 7.
These tools never commit, push or publish. AD020 is a bounded art/package smoke,
not the incomplete R016 routine/recovery acceptance campaign.

`build_packages.py --promote` archives and hashes existing canonical packages,
exports the actual Windows Validation/debug and Windows Desktop/release presets
into fresh `builds/art-direction/AD020/<run>` directories, and runs ten isolated
cases: two exports, six read-only packed audits, two outside-checkout startups.
Routine and fishing audits retain existing identity/content/geometry assertions;
the new storybook audit resolves six painted GLBs and six 1024px atlases, verifies
painted presentation owners, Compatibility and schema8/content1, and rejects
tests, source, reference and evidence resources. Presets exclude NPC reference
sheets and the test calibration asset; gameplay portraits remain included.
Production hashes must stay unchanged around every case. Promotion requires all
cases to pass and retains the canonical release override byte-for-byte.

`launch_native.ps1 -Session <fresh-name> -Phase writer` copies exact canonical
EXE/PCK/override bytes to direct `TEMP/ReturningFair-AD020-<session>` and launches
outside checkout. Writer/reader share fresh AD020 APPDATA/LOCALAPPDATA. Reader
requires the actual writer GUI save. Each phase records PID, executable, hashes,
arguments, data paths and exact normal exit using the original process handle.
`-Detached` creates an owned waiting launch controller, never an input driver.

Shared `tools/native_input.ps1` accepts only AD020 run-child evidence and matching
exact TEMP copies through its existing guards. PID/executable, unlocked Default
desktop, unique window, foreground, client bounds, request limits and acquired
input cleanup are unchanged. `native_guard_checks.ps1` and shared
`tools/tests/native_input_checks.ps1 -EvidenceTask AD020` test synthetic guards and
fault-injected dispatch; they cannot establish native gameplay acceptance.

Use shared `tools/npc_migration/invoke_native.ps1` for bounded requests. Reused
`tools/routine_migration/native_route.gd` creates explicitly synthetic detached
navigation guidance only; `walk_native.ps1` steers ordinary WASD using read-only
release position logs. Inspect current native pause frames before every batch.
No bridge, teleport, state grant, fixture save or clock/weather preset is allowed
for the native acceptance journey. `save_oracle.gd` compares copied actual GUI
Save/Load/Save bytes through packed production SaveCodec and forecast replay;
it never mutates the live process. Read-only `tools/native_evidence.py` audits
launch/request/capture/cleanup provenance; inspect actual image pixels too.
