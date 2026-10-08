# G006 detached People projection acceptance

Status: Done, 2026-10-08 UTC. Every G006 criterion passes. Exactly G006 completed;
no G007 implementation, commit or push.

## Authority and outputs

Entry HEAD `8384b52661c0bd7995f032a35d339d3a720bba01`, clean worktree. Applicable
workspace AGENTS.md read; no nested instructions or unrelated user edits.
G001 immutable People vectors/source snapshot and G005 actual content/service
artifacts inspected. Source read-only clean at
`60c20eb2816e7271fb84afaba286af006ebe3ccf`. No conversation-history dependency.

New [PeopleSnapshot](../../game/features/npcs/people_snapshot.gd) and
[projection suite](../../game/tests/people_snapshot_checks.gd), with generated
script UIDs. [CONTRACT](CONTRACT.md) records exact plain-data APIs/fields, met/fact
guards, portrait fallback and bounded progress. No UI/root integration, social
mutation, new store, source activation, imported data/art or save/version change.
Schema7/content1 and the production catalog remain current.

## Acceptance mapping

| Criterion | Evidence |
| --- | --- |
| Initially empty; only entered people | Fresh production catalog/session is empty despite all eight contacts, public names and gift rules. Actual service Begin makes exactly its person met before any introduction choice. Unknown/unrequested IDs and null/uninitialized owners return empty values. Synthetic flags/affinity/facts without entered nodes do not create met people; foreign/unknown/deferred-only seen IDs are excluded. |
| Authored sorting/identity/portrait/progress | All eight production rows match public names/pronouns/threshold/official-neutral resources. Name order matches G001's exact eight-ID vector. Actual positive/neutral introduction and two accepted gifts per recipient derive affinity1/2/3 and level0/1 with null/Acquaintance label. Synthetic affinity0/1/2/3/4/MAX boundaries prove capped progress/no invented level2. Detached portrait variants prove missing/deferred primary, first valid fallback and empty fallback; strict production content remains untouched. |
| Only learned public facts; no side effects | All-eight actual node/choice/preference paths compare exact persisted learned IDs and authored category/label/description. Partial snapshots remain unchanged after disclosure. Validated category/label fixture proves category priority and label sorting within a category. Foreign/unknown facts and Edric's two undisclosed facts/Helena archive-practice stay absent even in invalid-state fixtures. Repeated queries and edits preserve exact whole SaveCodec state, event memory, milestone receipts, item/quest/trust/progression/environment fields and catalog bytes. |
| Independence/detachment/freshness/load | Each recipient's positive/neutral choice/gift history preserves the seven unmet memories. Mixed all-eight met projection changes only Maris after one synthetic owned-item gift. Nested fact edits, row fields, list ordering/clearing cannot affect source owners. Current strict decode yields equal projection; restoring an earlier intro snapshot yields earlier facts/affinity rather than cached later values; querying a fresh owner is empty. Restored conversation reopening is inert. |

All supplied items, gather events, invalid memory, full-roster and altered label/
portrait boundaries are labeled synthetic. Node entry, choice/gift effects and
save derivation use existing production services and strict catalogs. This is
headless query/rule proof; no ordinary input, UI rendering, native play or package
acceptance is claimed. G007 owns People UI; G008/G009 retain integrated/native gates.

## Commands, isolation and retained attempts

Repository cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot console path checked before use:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
Version `4.7.2.stable.mono.official.ed1daf0bf`. No C# build/install needed.
Bundled runner host:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe`.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File tools/run_checks.ps1 -Task G006 -Names people_snapshot_checks,npc_content_checks,social_save_checks -ProcessScripts social_process_checks -TimeoutSeconds 150
```

Final run: [results](../evidence/G006/20261008-232638827-ccda0a36/results.json).
All seven cases pass: engine/parse gates, projection960, content432 assertions/
78 malformed candidates, social-save844 assertions/560 malformed histories and
separate-process social writer3/reader29 assertions. The existing process pair
proves actual isolated disk/root restoration, exact paused re-save, inert reopens,
failed-write/corrupt/backup handling and load rollback; setup is explicitly synthetic.
Zero diagnostics (including allowed), timeouts, source changes or runtime errors.
Runner owns per-case/group isolated APPDATA/LOCALAPPDATA and unique
slots under `builds/testing/G006/20261008-232638827-ccda0a36/`. Normal saves untouched.
Stable game/tools digest `132877a23459a4423ab352f38baec687f7efb22ae9091c532827a5e246011143`
covers 938 files. Engine exit0 alone is never accepted.

Read-only reference/current converter audits under
`docs/evidence/G006/20261008-232202-reference/`: both exit0, empty stderr.
Bundled Python:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.

```text
tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2
tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
```

No historical G001 owner-byte comparison was imposed on later authorized features.
Immutable reference hashes/source revision remain checked; pins never rewritten.
[Preservation audit](../evidence/G006/final-review/preservation.json) checks all 934
pre-existing game/tools files against actual initial working bytes: no changes.
Catalog SHA256 `efb76e8a42796a92fab80fa5815885adc7abdfd565ee7cfe036a7d165409e1d3`.
New projection SHA256 `9db292460fc1d971aa63e22cbcde2f2772f2857ae9a2e4b87dc01aa4bdf73321`;
suite SHA256 `dce8567ea0d6c4503166b4a913f85118fad278bdee3bf148b2c7e946d252540a`.

Retained failures under G006:232133 sandbox engine Access denied, then same
authorized runner approved with escalation;232151 import generated two UIDs,
source guard correctly rejected unstable bytes (existing import-only missing
.NET SDK diagnostic allowance, no installation);232214 test preload alias
`Projection` collided with a Godot builtin, renamed `PeopleQuery`;232241 sorting
fixture guessed wrong Maris node ID, replaced with actual service entry;232450
sorting fixture duplicated already-learned public-role, repaired to merge unique
IDs. No failed attempt relabeled as accepted. Runtime projection had no semantic
repair after resource-aware portrait lookup; later changes were fixture-only.

No captures needed or inspected for this pure projection task. Final diff/link/
dependency/status review passes under `docs/evidence/G006/final-review/`.
Only newly appended architecture lines required mixed-ending whitespace repair;
old spans preserved. All owned runner/engine processes exited, no held controls
or cleanup owed. No commit/push, export/publication, external message, successor
implementation or normal-save access. No required criterion failed or unrun.

Next eligible G007: integrate this projection with existing J journal/HUD and
root modal lifecycle. Remaining G007,G008,G009. Every item through G009: incomplete.
No blockers. Stop after exactly G006.
