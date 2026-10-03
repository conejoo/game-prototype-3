# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P013.

## Current task

P013 complete — complete playable recovery slice. P014 next eligible, not started.
Fresh run: optional purple companion station choice; southwest Maris lead; J strike
upgrade; north Tollworks gate; guardian combat; southeast vessel; north return;
Maris's practical fitting; visible restored specialist service/preview.
WASD/mouse/Space, E interaction, J journal, Esc modal/pause, R death retry, F10 quit.
Explicit saves only: close modals and finish/retreat from combat, pause and Save.
Reopen -> pause -> Load -> Resume. Load uses last arrival anchor, not saved position.

## Implementation and changed files

Initial Git clean at P012 commit 5c1f139. Workspace instructions, architecture,
checklist, handoff, actual wrappers/rules/Git and read-only source MQ03 verified.
Root/art/recovery prerequisites pass. No unrelated changes found. Source game and
normal save preserved; no Blender work, subagents, installs, commits, push,
publication or Windows export. Existing .blend/GLB assets reused unchanged.

- game/app/game_root.gd: location-aware objective routing, optional reaction and
  earned-upgrade hints from existing services, room-specific E hints, explicit
  save guidance on pause, debug-gated developer fixture opt-in.
- game/app/world_host.gd: remove direct children grouped developer_fixture before
  scene validation/physics placement/navigation unless explicitly enabled.
- game/world/{alderwake,tollworks}.tscn: practice marker/test beacon assigned that
  group. Normal companion dialogue station, gates, Maris and vessel remain.
- game/ui/prototype_ui.gd/.tscn: recovery-slice label, correct selected/unspent
  upgrade text, clear save/load boundaries and no-autosave/restart instructions.
- game/content/dialogue/temporary_companion.tres, locations/{alderwake,tollworks}.tres,
  quests/maris_recovery.tres; features/interaction/npc_interaction.tscn: clearer
  labeled station/route/objectives, room names. No stable identity/stat changes.
- game/tests/playable_slice_checks.gd/.uid: normal defaults/no bridge/setup,
  early-travel routing, optional guidance, stable save hint and repeated normal/
  developer-mode room lifecycle/navigation/party checks. Rules are synthetic;
  full normal-input evidence is separate. interaction_dialogue_checks explicitly
  enables P006 practice fixtures; save_checks expects current location prompt.
- README canon deviations/run guidance, ARCHITECTURE narrow presentation/developer
  boundary, CHECKLIST completion, docs/evidence/P013 acceptance records.

## Checks and evidence

Exact commands, exits, acceptance map and limits: docs/evidence/P013/VALIDATION.md.
Godot 4.7.2.stable.mono.official.ed1daf0bf; supplied executable paths verified.

- Initial root PASS0. Restricted art/recovery checks exit1 lacked isolated user://
  file/certificate access; normal-access reruns PASS0. No prerequisite code defect.
- Initial/final editor imports exit0; existing editor-only missing C# SDK10.0.9
  message remains nonblocking for this GDScript game. New script UID registered.
- Thirteen focused scripts PASS0: application_smoke, content_catalog, playable_slice,
  interaction_dialogue, consequence, asset_pipeline, recovery_presentation, quest,
  save, companion, location_travel, live_playtest, combat. Initial save check failed
  only its old exact prompt assertion; corrected final save PASS0. Final affected
  root/slice/quest/save/dialogue reruns PASS0; final catalog after text edit PASS0.
- Window a: fresh normal inputs, trust+1, lead1, earned strike25->40, actual guardian
  death3, vessel4, return5, three-line fitting6, specialist preview/visible gear,
  GUI Save and F10 exit0. No inspector or objective/health/position setup.
- Windows b/c/d: independent fresh repeat with trust-1/upgrade. GUI save at lead1,
  quit/reopen GUI Load1 -> physical guardian fight -> vessel4 Save -> quit/reopen
  Load4. Cleared guardian and both-member health restored. Vessel replay stays4;
  return5, alternate reaction rejected/trust stays-1, fitting cancel stays5/basic
  specialist unavailable, final fitting6/restored shop, spent upgrade/GUI Save.
- Window e: new process GUI Load6, specialist preview, round trip, guardian0 and
  restored shop/effects6/trust-1/damage40 retained. All five windowed runs exit0.
- Actual no-flag run: native computer-use startup screenshot shows fresh state,
  no test marker/beacon, labeled ally/station, route. Native Esc pause, focused
  Enter Resume, F10 quit inspected/captured in chat and log; exit0. No save used.
- 298 exact input requests/responses retained in live-trace.json; selected rendered
  PNG/JSON and four isolated save snapshots retained. Compatibility renderer,
  RTX4070 Laptop,960x640. Accepted runtime error scan has zero matches; Git diff
  check exit0. Normal-input trace contains only bounded keys/mouse/waits/captures.

## Decisions, limits, blockers

No P013 blocker. Existing services remain authoritative; no completion/reward
counter or save field added. Schema4/content1 and quest/effect/actor/source IDs
unchanged. Imported visuals/collision/navigation ownership preserved. Normal
startup is fresh; load remains explicit. Developer props are opt-in in debug builds.

This is a shortened MQ03 recovery, skipping MQ00–MQ02/full fair opening and
Old Ford/Moonwood travel. Unnamed ally, trust/training, familiar customer/helper
are noncanonical prototype fixtures; helper replaces authored Helena for this
slice. Service preview has no inventory/purchase. Ivo salvage/hull-lift/ship repair,
fair restoration and onward Night Orchard are outside slice; no retired currency.
Art/combat remain provisional. No Windows build/export claim; P014 owns that gate.
Injected viewport and native SendInput evidence do not prove physical hardware.

Harness corrections: restricted save-copy access required normal-access evidence
copy; one guessed preview choice ID rejected by driver before sending input and
then corrected. No gameplay state was changed by these attempts. Source/normal
save untouched. All originating process handles retained exact quit exit codes.

## Next eligible task

P014 only — Extension check and Windows export. Demonstrate isolated test-only
content variant, verify compatible installed export templates, export and actually
play/reload standalone Windows executable. Not started; no template/build claim.
