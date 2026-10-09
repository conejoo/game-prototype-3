# G009 local Windows delivery

Run from repository root. G009 is the final checklist task; these helpers create
no follow-up task, installation, publication or commit.

`build_packages.py` uses installed Godot 4.7.2 and existing standard templates.
It archives exact previous canonical release/validation folders before replacement,
exports into unique G009 staging, runs external packed resource audits and isolated
outside-checkout startups, then promotes only after six passing cases. Production
bytes are checked around each case. Release override bytes remain unchanged.

Both G009 packages use the Windows Desktop resource filter: validation is its
debug-template export, release its release-template export. Both exclude tests and
bridges. The historical Windows Validation preset remains unchanged for review use.
Neither exported package depends on external audit scripts or reference snapshots.

`launch_native.ps1 -Session <fresh-name> -Phase writer` creates an exact release
copy in a direct TEMP child named ReturningFair-G009-<session>, outside checkout.
Writer/reader share isolated APPDATA/LOCALAPPDATA; neutral uses a separate fresh
group. Existing override identity is preserved. Launch JSON records exact executable,
PCK/override hashes, cwd, PID, args and save path; normal F10 exit records its code.
Do not overwrite an existing session. Reader requires the writer's GUI save.

Use existing `tools/npc_migration/invoke_native.ps1` for bounded requests and
`tools/foraging_items/walk_native.ps1` for physical movement with
`-StandaloneDirectory`. These are input delivery/navigation helpers, not evidence
of completed gameplay. The shared helper validates matching G009 task/path,
canonical hashes, reparse points, owned executable/PID/window, unlocked Default
desktop, foreground focus, client bounds and key/button cleanup. Existing N018
ownership remains supported. `native_guard_checks.ps1` tests new standalone guards
with synthetic package bytes, never OS input; existing native dispatcher checks
cover malformed commands, focus failures and cleanup.

Inspect each actual final pause/modal capture before next batch. Edric's ordinary
positive introduction plus two distinct gathered flowers reaches3/Acquaintance;
fresh neutral plus two flowers reaches2. Only three flowers exist, so one other
recipient can receive the last. No inventory/fact/quest/time setup or teleport.
Complete existing Maris recovery, GUI Save, normal quit, separate-process GUI Load,
paused re-save and physical revisit. Detached packed save/forecast comparison uses
`tools/foraging_items/save_oracle.gd`; it reads copied GUI-save bytes only.

Native availability failures leave G009 incomplete. Fresh exports, fixtures and
historical N018/G008 evidence cannot satisfy that gate. See workflow
[G009 acceptance](../../docs/gifts-friendship-people-journal/G009_ACCEPTANCE.md)
for the completed native/restart/neutral proof,204 inspected images, exact save/
package hashes and cleanup. G001-G009 Done; every item complete, no successor.
