# G007 People journal acceptance

Status: Done, 2026-10-08 UTC. Every G007 criterion passes. Exactly G007 completed;
G008/G009 remain Pending. No commit or push.

## Authority and delivered interfaces

Entry HEAD `62dd03bf6be043939fbb35cd7d0bed22c83b314f`, clean worktree. Workspace
AGENTS.md, workflow prompt/checklist/contract/current state, architecture, G006
acceptance/API and project gameplay-testing skill/recipes read. No nested
AGENTS.md or unrelated user changes. Source clean at
`60c20eb2816e7271fb84afaba286af006ebe3ccf`, checked with command-local
safe.directory. Public pins, content, art, actor placements, finite supply and
schema7/content1 remain unchanged. Source reference/current converter audits pass.

New [PeopleJournalView](../../game/ui/people_journal_view.gd) renders detached
G006 PeopleSnapshot rows. PrototypeUI adds Quest & companion / People tabs inside
the existing journal and a HUD People button. GameRoot queries its current
conversation owner on opening/refresh, opens J on the quest tab, and opens the
HUD entry directly on People. Selection resets on closing/reopening. No session,
save, relationship command, met/fact store or event authority enters this view.

Root opening gates cover focus, combat/death, retry/load/travel, pause, dialogue
and backpack. Opening cancels holds/drag, clears actor/aim input and locks manual
Save/Load. J/Esc/Close exit; focus loss, death/retry and unload close the modal.
Elapsed/environment simulation continues under the existing unpaused policy.
Canceled drag retains the existing trailing mouse-release suppression until the
release arrives; this preserves the old pointer safety contract.

New [UI checks](../../game/tests/people_journal_checks.gd) and
[render wrapper](../../game/tests/people_journal_render.gd), each with generated
UID. Shared TestRunInteractionCapture adds `journal(game,label,directory,kind,note)`:
four settled frames/post-draw, visible root-owned journal, contained visible focus,
blocked actors, no overlapping input mode and viewport fit. Evidence records
tab/selection and live simulation rather than falsely claiming pause. Python
capture validation adds strict journal provenance and malformed-record tests;
all existing modes retain their guards. No native or ordinary-route claim.

## Acceptance mapping

| Criterion | Evidence |
| --- | --- |
| Met-only list, empty/partial states, identity/portrait/facts/progress | Fresh empty hint; actual production Begin then cancel yields exactly one Edric row with zero affinity/no learned facts. Synthetic service introductions/preferences for all eight produce exact authored sorted names, pronouns, primary portraits, learned category/label/description details. Fractional progress remains exact rather than Range rounding. Two synthetic gifts yield Edric 3/3, Acquaintance/Reached; no invented level2. G006 projection suite also passes all960 independence/disclosure/detachment/restore assertions. |
| Scroll/focus/exits at required sizes | Actual viewport mouse opens HUD/People and selects all eight rows; focus scrolling reaches Tess. Tab/Enter selects Della, Tab/Shift-Tab cycles tabs/list/detail/Close, arrows/wheel scroll long detached facts, and J/Esc/Enter on Close exit. Panel and fixed exit fit actual960x640 and1350x900 captures (requested root1440x900 uses project stretch). Fourteen final captures include all eight portraits, empty/no-facts, long details at both sizes, quest upgrade and synthetic night/rain readability. |
| Opening/selection/reopening has no social effects | Exact whole SaveCodec snapshot comparisons preserve facts, affinity, gifts, event/milestone receipts, inventory and old state through opening, person selection, repeated requests, reopening and detached long-text edits. Initial blocked input does not introduce any person. Selection is presentation only. |
| Root modal/input/simulation/lifecycle | Held W clears on opening. Movement/attack/dodge/E/hold/drag/aim/zoom/P/B/debug input stay blocked; save/load boundary rejects and pause cannot overlap. Existing unpaused elapsed/environment advance is explicitly asserted. Dialogue/backpack/pause/travel/load/retry/focus/death reject opening; focus loss/regain, defeat and actual WorldHost unload/arrival close safely. Synthetic hold/drag attempts cancel without item mutation; trailing pointer release is consumed. Existing actual placement regression passes128 assertions, including journal/focus/pause and other cancellation modes. |
| Existing quest, upgrade and companion content | J defaults to exact existing quest/trust journal; preparation command remains visible and actual mouse activation buys Deliberate Strike/damage40. Existing quest, NPC dialogue384, backpack148, foraging130 and movement/camera regression suites pass. No companion-trust, quest, geography, art, resource or save-rule changes. |

All social items/events, full-roster/lifecycle setup, long descriptions and
night/rain preset are explicitly synthetic. Production GUI input/root/service
execution and actual rendered pixels are UI proof. Ordinary gathered-item/social
restart integration remains G008; standalone native delivery remains G009.

## Commands, isolation, results and images

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Installed console checked first:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
version `4.7.2.stable.mono.official.ed1daf0bf`. Bundled host:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe`.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File tools/run_checks.ps1 -Task G007 -Names people_snapshot_checks,people_journal_checks,movement_camera_checks,npc_dialogue_ui_checks,backpack_ui_checks,quest_checks,foraging_interaction_checks -RenderScript people_journal_render -RenderPhases check -TimeoutSeconds 150
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File tools/run_checks.ps1 -Task G007 -Names people_journal_checks,world_item_placement_checks -RenderScript people_journal_render -RenderPhases check -TimeoutSeconds 150
```

[Bulk results](../evidence/G007/20261008-234112883-18de76ca/results.json): all10
cases pass, seven suites plus engine/parse/render. Projection960, UI130,
NPC-dialogue384, bag148, foraging130; movement/quest checks pass. Render143/13
captures. Digest `ea6d16c1b6581b0f496c24cabf3edba1e3a29f7c5ac9c7cab4e8f3a3d33eb3af`.

[Final results](../evidence/G007/20261008-234357228-2e720fcd/results.json): all5
cases pass, UI134, placement128, render148/14 captures plus engine/parse. Only
changes since bulk: undo the unnecessary `_dispose_item_drag` ownership edit,
and extend UI fixture with entered/no-facts, Tab/Enter and trailing release.
Final944-file game/tools digest
`4efa2a264ad4d6f19879bbaab837e2f81bcdd8fde114289a0b12df3e355b1881`.
Both accepted runs have zero diagnostics (including allowed), timeouts, source
changes or runtime errors. Each suite/render owns isolated APPDATA/LOCALAPPDATA
and slots under `builds/testing/G007/<run>/`; normal saves remain untouched.
Owned engine/runner processes exited; no held controls or cleanup owed.

[Final image provenance/hash/dimension report](../evidence/G007/20261008-234357228-2e720fcd/render/derived/20261008-234432-c329f952/capture-report.json)
validates all14 PNGs. Both final contact sheets/all14 images inspected, with
full-size met-no-facts and larger scrolling detail; earlier passing sheets plus
full-size Edric threshold, Tess list end, larger detail and night/rain inspected.
Text, portraits and fixed exits are readable; clipping inside scrolled content
is intentional and scrollable. Source capture pixels are960x640/1350x900.

Bundled Python read-only audits/checks (exit0/empty stderr) under
`docs/evidence/G007/reference-20261008-2342/`:

```text
tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2
tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
tools/tests/capture_evidence_checks.py
tools/capture_evidence.py docs/evidence/G007/20261008-234357228-2e720fcd/render/people-journal.json
```

Python executable:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Current catalog SHA256 remains
`efb76e8a42796a92fab80fa5815885adc7abdfd565ee7cfe036a7d165409e1d3`.

Retained failed attempts under G007:233746 sandbox launch Access denied, then
approved escalation;233811 preflight invalidated by a fixture edit during launch;
233830 import generated three UIDs and correctly failed source guard (existing
editor-only missing .NET SDK allowance; no install);233850 guessed short names,
fractional progress rounding, unscrolled last row and detail arrow focus;
233938 detail focus plus overly strong cleared-drag-flag assertion;234257 the
unnecessary drag ownership change broke old trailing-release safety and was
reverted. Final134/148 UI and placement128 prove repairs. Earlier focused234037
passed before final fixture additions. One contact-sheet command used a wrong
render subdirectory and failed without writes; corrected to actual `render/`.
No failed evidence is relabeled. Newly inserted CRLF spans alone repaired; old
line endings preserved. Final diff/local-link/status/dependency review retained
under `docs/evidence/G007/final-review/`.

No required G007 criterion failed/unrun. No blocker. No install, export,
publication, external message, commit/push or successor implementation.
Next eligible G008; remaining G008,G009. Every item through G009: incomplete.
