# N018 Windows delivery helpers

Run from the repository root in PowerShell 7. The installed Godot console and
4.7.2 templates are explicit; no installation or source refresh is performed.

`build_packages.py` creates unique N018 staging/evidence, copies and hashes the
previous canonical validation/release folders, exports both presets, audits each
pack with external `package_audit.gd`, and starts each outside the checkout in
isolated appdata. Only six passing cases permit reversible local promotion of
the EXE/PCK pairs. Existing override bytes are preserved. Failed runs remain.

`launch_native.ps1 -Session <unique-name> -Phase writer` creates an exact temporary
release copy outside the checkout and a fresh isolated writer slot. `reader`
starts a distinct process against the same slot; `neutral` uses a different fresh
slot. Launch/normal-exit JSON records PID, arguments, cwd, paths and hashes.
Normal F10 quits the owned game. The launcher waits only on its owned handle.

`invoke_native.ps1` serializes bounded public input into unique requests and uses
the shared PID/executable/desktop/foreground/client-coordinate/release guards.
`person_native.ps1` opens the ordinary source conversation, exercises public
choices (or a remembered revisit), and ends at a pause checkpoint. Maris's
observed Chat footer selects source chat from her existing recovery counter.
`save_native.ps1` uses observed GUI Save/Load, waits for successful production
messages, and copies the resulting exact bytes to a unique evidence snapshot.
These helpers do not set position, health, time, facts, inventory or quest state.

The shared foraging walk helper supports this exact temporary copy through
`-StandaloneDirectory`. Detached packed navigation queries are guidance only;
live movement remains native WASD. Inspect every final pause capture before
further input or analysis. Dialogue and successful input do not prove pausing.

`audit_native.py` audits native provenance, saves and contact
sheets. The existing detached `tools/foraging_items/save_oracle.gd` compares full
typed production snapshots and reconstructed weather from copied GUI-save bytes;
it never changes the running game. Native routes, package proofs, and detached
codec checks are distinct evidence.

Run the final audit with the existing analysis Python (Pillow required):

```powershell
& 'C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe' tools/npc_migration/audit_native.py docs/evidence/N018/native-<session>
```

It refuses to replace an existing audit or sheets. Save snapshots use the
recorded route labels40-recovered,02-restored,20-revisited and20-neutral. A whole
typed/forecast oracle must already exist. Inspect every resulting sheet plus
full-size UI/combat/restart frames; a passing data audit is not a visual review.
