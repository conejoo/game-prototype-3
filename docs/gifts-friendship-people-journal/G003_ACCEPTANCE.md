# G003 strict social persistence acceptance

Completed 2026-10-08 UTC. Exactly G003; [checklist](CHECKLIST.md),
[contract](CONTRACT.md), [continuation](CURRENT_STATE.md).
Entry HEAD `ce5af94a9716bb774f9e02e2ffd2cbafb8678bbc`, clean worktree and no
nested instructions or unrelated user changes. Source remains read-only, clean
at `60c20eb2816e7271fb84afaba286af006ebe3ccf`.

## Delivered boundary

Schema7/content1 and the plain-data envelope are unchanged. NpcSaveData now
cross-checks itemGifted totals with recipient-qualified authored gift choices,
shared rule caps, paired consecutive event sequences/identical times, item
mapping/giftability and derived affinity, level, flags, disclosures and receipts.
Bounded social history checks prove prerequisites and legal node/milestone entry;
an injected milestone may replace a response without requiring that skipped node.
No new counter/store, autosave, migration or transient cursor field.

SaveCodec.decode/validate optionally reuse an initialized NPC catalog. The existing
SaveRepository can bind it via `(path,social_catalog=null)` and uses the same
authority for candidate, staged, primary and backup validation. Defaults still load
strict bundled production content. Item metadata is passed to NpcSaveData.restore.
Existing zero-gift saves, precision/numeric/container/size/version gates, backup
protection and root rollback remain intact.

Production catalog, content gates, actor/geography assets, finite resources,
converter default and immutable pins remain unchanged. G004 still owns production
activation and service milestone routing. Tests clearly label injected social
availability, inventory and source milestone transitions synthetic. No ordinary
gift, UI, People, rendered or native/package acceptance is claimed.

## Criterion evidence

| Required criterion | Passing evidence |
| --- | --- |
| Gift counts equal authored choices for same item/person; shared caps | social_save_checks covers all eight positive/neutral paths after each of two gifts. Edric/Helena use hint then follow-up; other six deliberately repeat the same choice. Mismatched totals and coherent matching third gifts reject. |
| Affinity/level/flags/facts/receipts derive from legal effects/entry | Exact whole-session round trips at each gift; helpful+2 reaches3/level1, neutral+2 reaches2/level0. Edric milestone node/flag derive on entry; other seven get no invented flags. 560 malformed cases cover forged rewards, foreign/deferred keys, missing evidence, item data, sequence/time and gift-before-intro chronology. Existing NPC suite preserves mutually exclusive/once-only introductions. |
| Legal milestone replacement and repeatability | Distinct unvisited enabled response target is deliberately substituted in a synthetic authoring variant, then legally skipped by the crossing milestone. Restore accepts it. Synthetic endsConversation crossing saves level1 without prematurely granting the milestone flag; later authored milestone entry also restores. Gift receipts remain absent; original introduction receipt remains exactly one. |
| Strict current versions/precision/container bounds | Final social tests preserve binary64 event time immediately below1 and maximum active elapsed, reject fractional numeric lexemes and uninitialized catalog/non-giftable metadata. Negative gift-delta variant refuses aggregate-only inference. Existing npc_save567, foraging_save111 and general save checks retain their precision, 128KiB, container/integer, unsupported schema/content and maximum aggregate cases. |
| Real disk round trip and separate processes | Actual SaveRepository writes/reopens persisted primary and backup bytes. social_process_checks writer/reader have distinct PIDs, fresh reader startup and exact whole supported durable oracle. Paused re-save is byte-identical. NPC and general save restart pairs also pass. |
| Corrupt/incompatible/failed-write preserve state/files | New repository fixtures test temporary-path obstruction, malformed social primary/backup and unsupported schema8 without fallback/overwrite. Actual root fixtures prove corrupt social load does not swap owners/state, backup restore is exact/read-only, failed write preserves both files, and unsafe no-floor/blocked travel staging rolls back social/inventory/all prior state and physical bindings. |
| Reopen and old-system preservation | Process reader reopens Edric/Maris, cancels and compares exact complete durable state: no repeated gifts/rewards/milestone/facts. Party/actor bindings, arrival anchor, quest/trust/upgrades, timers/environment, collected origins/rod placement are preserved. G002 gift/publication suites also pass. |

## Commands, isolation and exact source

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Bundled shell: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe`.
Installed console checked first: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
version `4.7.2.stable.mono.official.ed1daf0bf`. Bundled Python:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.

```powershell
./tools/run_checks.ps1 -Task G003 -Names social_save_checks,social_gift_checks,social_transaction_checks,npc_save_checks,foraging_save_checks,save_checks -ProcessScripts social_process_checks,npc_process_checks,save_process_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task G003 -Names social_save_checks -ProcessScripts social_process_checks -TimeoutSeconds 150
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
git diff --check
```

Full passing run: `docs/evidence/G003/20261008-222737370-3b4c2f29/results.json`.
All14 cases (engine/parse, six suites, three independent-process pairs) pass.
G002 suites335/238 assertions; NPC567; foraging111. Only two test files then
changed to add endsConversation/later-entry cases and correct synthetic routing
for that case; no runtime/tool bytes changed. Final focused run:
`docs/evidence/G003/20261008-223022667-288e284a/results.json`, all5 cases pass,
social842 assertions/560 malformed cases, write2/read28 assertions.

Both runners report exit0 for every case, no diagnostic, timeout, source change
or source error. Full stable game/tools digest:
`65a87ca72e7e716ce97cc78ab7316bb368abbe8c827cfed273947475a43715a2`.
Final928-file digest:
`6ef45a8e01edf5e8b0bbb4b9849b91815bcafb958a3165873aef87f22b89839e`.
Shared runner records actual commands, source manifests, owned process IDs,
per-check fresh APPDATA/LOCALAPPDATA and per-pair shared isolated slots under
`builds/testing/G003/<run>/`. Normal saves were never accessed.

Read-only reference/converter logs: `docs/evidence/G003/20261008-222418-reference/`.
Both exit0, empty stderr; source HEAD/status/hash/excerpts, all existing NPC/social
pin hashes and exact67 baseline outputs/48 portraits/18 sheets pass. Production
NPC catalog SHA256 remains
`9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.
Final audit under `docs/evidence/G003/final-review/` checks links, status/dependency
consistency, source manifests, intended files and whitespace. Unchanged portions
of mixed-line-ending SaveCodec retain their original Git bytes; no broad rewrite.

## Retained attempts and cleanup

Initial222153 engine launch hit sandbox Access denied; the same isolated runner
was approved and retried.222211 import generated three script UIDs, correctly
failing source guard; retained and rerun. Existing editor-only missing .NET SDK
warning used the runner's established import allowance; no C# build/install.
222245 fixture opened a priority woods terminal before gift selection; corrected
to follow ordinary entry resolution.222341 social save/process pass retained.
222508 stronger skipped-target fixture used one choice for both commands, so
changing its target also changed the first command; corrected to retain actual
hint cursor then use follow-up. The full/final runs above pass after those repairs.
No required G003 criterion remains failed or unrun; no captures needed/claimed.

All owned runners/engine processes exited. No held input or cleanup owed. No
commit/push, source-checkout mutation, external message, export or successor.
G003 Done. Next eligible G004 (G006 independently ready). Remaining
G004,G005,G006,G007,G008,G009; every item through G009 is not complete.
