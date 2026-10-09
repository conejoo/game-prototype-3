# FS008 local Windows delivery

Run from repository root in PowerShell 7 with the installed Godot 4.7.2 console
and bundled Python. No installation, commit, publication or successor.

`build_packages.py --promote` exports the actual Windows Validation and Windows
Desktop presets to fresh `builds/fishing/FS008/<run>/` staging. Both exclude all
tests. Eight cases require clean exports, inherited current social packed audits,
fishing packed audits and outside-checkout startup. Exact prior canonical packages
are copied/hash-verified before replacement; existing override identity is preserved.
Without `--promote`, packages remain staged. Failed runs never promote.

`package_audit.gd` is an external read-only packed audit. It verifies fish rules,
icons, rod capability, three adapted profiles/pinned layout, runtime modules,
strict schema7/content1 and actual fresh root/bag/idle fishing. Detached fish99
selection/restore cases are explicitly synthetic. No audit dependency is exported.

`launch_native.ps1 -Session <fresh-name> -Phase writer|reader` uses an exact direct
TEMP release copy with matching FS008 evidence, isolated restart APPDATA and unchanged
override. Writer requires no slot, reader requires writer's actual GUI save. The
retained process handle records normal exit; no bridge or setup flags exist.
Reuse `tools/npc_migration/invoke_native.ps1`, `save_native.ps1`, and the shared
foraging physical walk helper. Inspect actual captures and command cleanup.

`reel_native.ps1` requires an inspected 960x640 site pause and current cast client
coordinates. It resumes/F/clicks, then recognizes rendered BITE glyphs and the
rendered meter through `hud_pixels.ps1`. It sends only guarded short E holds/waits
through the existing native dispatcher, releasing every request. Bound: <=40 wall
seconds/100 iterations. It records every decision, actual native capture and timing,
then captures terminal and pauses. No memory, phase log, RNG, reward, position or
clock mutation. `bite_pixels.json` is a bounded synthetic UI glyph template, not a
force-catch input or a native success oracle. The caller must inspect final pause,
terminal and real bag/save before accepting a catch. Missing or mistimed HUD evidence
leaves native/human acceptance open; never substitute package startup or debug proof.

Pure guard checks: `native_guard_checks.ps1 -EvidenceTask FS008`; inherited dispatcher
suite uses its existing `-EvidenceTask FS006` route (synthetic only). Classifier tests:
`hud_pixel_checks.ps1`. Read-only `tools/native_evidence.py` reviews request/capture
provenance; existing `tools/foraging_items/save_oracle.gd` compares typed packed
production snapshots/full-precision weather from copied actual GUI saves.

CHECKLIST/CURRENT_STATE own acceptance status. Package delivery alone is insufficient;
ordinary unforced native landing, bag, cancel/recast, GUI Save/normal quit/new PID
GUI Load/exact stable oracle and physical revisit remain required.
