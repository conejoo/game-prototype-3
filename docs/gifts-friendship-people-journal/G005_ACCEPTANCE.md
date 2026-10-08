# G005 ordinary gift UI acceptance

Completed 2026-10-08 UTC. Exactly G005; [checklist](CHECKLIST.md),
[contract](CONTRACT.md), [continuation](CURRENT_STATE.md).
Entry HEAD `673accf2889e1ff357f63b648beb1d7a4a68d689`, clean worktree,
no nested instructions or unrelated changes. Read-only source stays clean at
`60c20eb2816e7271fb84afaba286af006ebe3ccf`.

## Delivered behavior

Ordinary source conversations show authored gift choices and the current item,
preference or shared-cap reason. Their detached social snapshot includes affinity,
authored threshold/label, derived level and actual backpack Moonflower count.
ConversationView displays progress toward Acquaintance, or Reached at level1,
with no invented level2. It only displays snapshots and submits stable commands.

NpcDialogueService retains accepted recipient/item/friendship feedback through
the response or milestone node, including a later rejected stale command. This
feedback is transient and clears with the cursor. The root refreshes backpack/HUD
after the whole service publication; the view never consumes items. Keyboard
echoes cannot activate the newly focused response-node control. Existing stable
tokens continue to reject double-click notifications and stale commands.

Moonflower description, backpack detail and selected-item HUD explain gifting
through conversations after learning a preference; selecting the flower is optional.
Rod remains non-giftable with its existing tool/help behavior. Schema7/content1,
catalog activation, portraits, actors, source text, contacts, geography, three finite
flowers, quest/companion authorities and manual save boundaries are unchanged.

## Criteria and evidence

| Required criterion | Evidence |
| --- | --- |
| Source preference unlocks correct gift; visible bag decrement; recipient-only progress | Ordinary fresh production WASD/E journey introduces helpful Edric, physically gathers flower01 and flower02, enters the authored hint, gives through mouse then Tab/Enter after reopening, and reaches one milestone. Bag/HUD immediately shows 0, last selection clears, affinity becomes2 then3, and all seven other people remain unmet/affinity0. All-eight synthetic UI checks independently cover each authored preference/gift/progress path. |
| Honest missing-item/cap reasons; feedback survives node change | All-eight UI fixtures test preference gates, missing inventory, two accepted gifts and cap2 with one remaining owned flower. Actual wheel input reveals disabled gift rows in longer return menus. Captures show the full reasons, recipient/count/delta feedback and reached threshold; stale rejection is displayed without erasing accepted gift feedback. Helena's already-entered gather hint correctly counts as learned disclosure. |
| Mouse, Tab, Enter, long choices and Continue/Close at small/larger viewports | Ordinary mouse first gift, contained Tab/Enter second gift, mouse Continue, B/Enter bag inspection and Esc work. Synthetic button notifications test double-click command reuse; real Enter accepts the second intentional gift. Long finite display fixture scrolls and keeps exits inside the viewport. Requested root1440x900 renders an actually measured1350x900 viewport; small captures are960x640. All57 final acceptance images and six sheets were inspected, plus full-size details. |
| Stale/double-click/input repeat cannot double-consume; intentional second gifts work | UI355 assertions plus transaction238 and milestone657 test stable IDs/tokens, duplicate old-button notifications, rejected old commands, Enter echoes at the response node, selected remaining units, detached snapshots and reopening for a second deliberate gift. Ordinary route consumes exactly two genuinely gathered units, preserves flower03, cannot replay the milestone, and displays no-item after reopening. |
| Dialogue blocks movement/attack/dodge/hold/drag/aim/zoom/save/load; focus/unload release controls | Existing npc_dialogue_ui_checks384 assertions test blocked world keys/pointer/camera, actor controls/AI, hold/drag/other modals, forced-pause Save/Load rejection, focus containment, focus loss/gain, unload and inactive restored cursor. New UI fixture repeats focus cancellation and echo safety. foraging_interaction_checks130 preserves mode/hold/drag arbitration; backpack_ui_checks passes after help changes. |
| Maris recovery/specialist, companion choices and bag remain usable | npc_03_checks729 verifies one live Maris counter/chat/recovery owner and routing/lifecycle boundaries; quest_checks preserves legal recovery commands and rejects forged sources. Ordinary post-gift walk/E/mouse activates the existing noncanonical companion station's positive reaction, changes trust0 to1 through its own owner and leaves all NPC gifts/memory and inventory exact. consequence_checks passes once-only alternatives/trust, upgrades and strict current-schema data. Bag selection/clear/rod/drop/modal checks pass. |
| Only authorized social/UI changes; source and pins intact | Read-only social reference/converter audits exit0 with empty stderr; production catalog hash remains `efb76e8a42796a92fab80fa5815885adc7abdfd565ee7cfe036a7d165409e1d3`. Read-only source, other workflow checklists, art, contacts, resource supply, save format and local packages remain unchanged. Intended diff, local links and final source manifests are reviewed in final-review. |

## Commands, isolation and accepted runs

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Shell: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe`.
Installed console checked before launch:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
version `4.7.2.stable.mono.official.ed1daf0bf`.
Python: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.

```powershell
./tools/run_checks.ps1 -Task G005 -Names social_gift_ui_checks,social_transaction_checks,social_milestone_checks,npc_dialogue_ui_checks,foraging_interaction_checks,backpack_ui_checks,npc_03_checks,quest_checks -RenderScript social_gift_ui_checks -RenderPhases check -TimeoutSeconds 150
./tools/run_checks.ps1 -Task G005 -Names consequence_checks -RenderScript social_gift_ui_render -RenderPhases ordinary -TimeoutSeconds 220
./tools/run_checks.ps1 -Task G005 -Names social_gift_ui_checks,backpack_ui_checks -TimeoutSeconds 150
& '<bundled Python>' tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2
& '<bundled Python>' tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
& '<bundled Python>' tools/capture_evidence.py docs/evidence/G005/20261008-230634406-ca06e70a/render/social-gift-ui.json
& '<bundled Python>' tools/capture_evidence.py docs/evidence/G005/20261008-230853742-eed20e8f/render/social-gift-ui-ordinary.json
git diff --check
```

- `docs/evidence/G005/20261008-230634406-ca06e70a/results.json`: all11 cases pass,
  eight suites plus engine/parse and rendered UI397 assertions/42 captures.
  Headless UI355, transaction238, milestone657, modal384, foraging130, Maris729;
  backpack and quest suites pass. Stable934-file digest
  `d7535c689ae421fa320fc6a6cd6cb34788afefb13f1076fbd1dd14f95074a367`.
- `docs/evidence/G005/20261008-230853742-eed20e8f/results.json`: all4 cases pass,
  consequence suite and ordinary viewport78 assertions/15 captures, including the
  existing companion choice. Stable digest
  `ed714ac07c4cf9f620961e3ade512a0a19d02d442cd0c9bbdda66dd62307ebf9`.
  Only the ordinary test fixture changed after the preceding bulk run.
- `docs/evidence/G005/20261008-231032368-d8bac947/results.json`: all4 cases pass,
  final UI355/backpack checks after diff review preserved the original non-giftable
  item-help fallback. Actual Moonflower/rod branches and rendered behavior are
  unchanged. Final stable digest
  `33f56cbda36ec1aab50c545594e165e40fed6d8b31e56cfaa9253003a8d0c87d`.
  Only the two help fallback strings changed after the ordinary accepted run.
- `docs/evidence/G005/reference-20261008-225708/`: reference/source/converter exit0.

Every accepted runner has zero diagnostics/timeouts/source changes/run errors.
Each case/group uses runner-owned APPDATA/LOCALAPPDATA and named slots under
`builds/testing/G005/<run>/`; normal saves were untouched. No G005 restart/native
or fresh package claim: G008/G009 still own those integrated acceptance gates.

Final inspected synthetic sheets:
`20261008-230634406-ca06e70a/render/derived/20261008-230828-3ad0c6c0/contact-01.png`
through contact-04. Ordinary sheets:
`20261008-230853742-eed20e8f/render/derived/20261008-231033-3d3a8488/contact-01.png`
and contact-02. Reports in those same derived folders validate PNG hashes,
provenance, pause/live modal guards, focus/cursor and actual dimensions.
Full-size review includes cap/gift feedback, Della's extra unavailable-service
notice, long960/larger choices, ordinary bag help/empty bag, Edric response,
milestone/larger milestone, missing-item reopen and companion response.

## Retained attempts and cleanup

225602 engine launch Access denied required approved sandbox escalation for the
same isolated runner.225636 import created two UIDs and correctly invalidated the
source guard; the known editor-only missing .NET SDK diagnostic used the existing
import allowance. No dependency installation or C# build occurred.
225700 fixture incorrectly expected Continue on six return nodes with other
ordinary choices; corrected to visible Continue/Close.225906 fixture overlooked
Helena's legitimate disclosure from a prior global gather; corrected to actual
learned state.230103 ordinary fixture used a wrong hint-response ID and shortened
display name; corrected to authored target/name. These failed runs remain failed.
230417 and230447 initial passing renders remain retained; wheel-scroll proof and
ordinary companion acceptance subsequently extend their evidence. Mixed-ending
diff review corrected only newly inserted spans and preserved unrelated bytes.

No required G005 criterion remains failed or unrun. All owned runners/engines
exited; inputs released at bounded request ends, no helper/process cleanup owed.
No source-checkout mutation, external message, publication, export, commit/push or
successor implementation. G005 Done. Next eligible G006; remaining G006-G009.
Every item through G009 is not complete. Stop after exactly G005.
