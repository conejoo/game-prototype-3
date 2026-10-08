# Live interaction capture helpers

Tooling follow-up requested2026-10-07 (America/Vancouver). This does not select
F008, change feature checklist status, or modify production input/save behavior.
Existing shared journey work was present at the start and preserved.
Status: Complete. All requested capture/contact-sheet criteria verified; owned
test engines exited. Feature checklist and next eligible F008 remain unchanged.

## Implementation

`game/tests/support/test_run_interaction_capture.gd` exposes three async methods:
`TestRunInteractionCapture.hold(game,label,directory,kind,note,active=true)`,
`backpack(game,label,directory,kind,note)`, and
`drag(game,label,directory,kind,note)`. Each returns a consumed `ok/error` or a
PNG observation dictionary. `hold(...,false)` verifies an actual released checkpoint.

- Real renderer and explicit synthetic/debug-input provenance are required.
  Evidence labels, runner-owned directory, links and overwrite protection use the
  existing TestRunEvidence guard, revalidated after rendering awaits.
- Every live capture requires a resumed/focused game with no pause overlay,
  travel/load/retry/dialogue/journal/settings, and the current session/world owner.
- Entry, four process frames and post-draw checks require the same location,
  session, item facts and target identity. Active hold additionally requires E,
  current range/LOS/revision and visible progress. Released hold requires no
  E/hold/progress. Backpack requires contained focus, disabled world controls and
  a panel fitting the settled viewport. Drag requires pointer ownership, current
  target/revision, disabled world controls and the visible ghost mesh.
- Live and pause captures share an overlap lock. Capture never sends input,
  freezes time, pauses, changes focus/modal, commits placement or grants items.
  Completion/cancellation/disposal while settling fails without producing a PNG.
- Results retain mode, engine identity, actual PNG size, camera, location/position,
  session snapshot/environment, start/end monotonic ticks, settled-frame/post-draw
  verification, controls/focus and mode-specific observations. Red invalid drag
  previews retain errors and nullable foot rather than being rejected as subjects.
- F005/F006/F007 render scenarios now use shared helpers instead of hand-written
  capture blocks. Ordinary input, synthetic capacity setup and exact paused
  restart oracles retain their prior roles.
- `tools/capture_evidence.py` validates all `views`, `live_frames`, `modal_views`
  and `drag_views` arrays and includes their PNGs in unique contact sheets. Captions
  state actual mode/pause/provenance; source failures and duplicate/path/hash guards
  remain. Derived report schema is2. Existing paused views without mode remain
  compatible. Historical unverified live manifests must be regenerated.
- Maintained recipes live in the testing skill's shared tools reference. Repository
  and installed skill copies match and pass skill-creator quick_validate using
  the existing cached PyYAML dependency; no package installation.

## Verification

- [x] Dedicated actual-renderer contract fixtures pass57 assertions/seven images,
  including active/released holds, both backpack window sizes, drag and original
  paused capture: `20261008-004738262-6b1410df`.
- [x] Guards reject wrong state, missing provenance, native claims, unsafe paths,
  overwrite, concurrent pause/live capture, stale revision, lost focus, missing
  progress/preview mesh, enabled modal/drag controls and absent modal focus.
- [x] Cancellation, hold completion that frees its target, modal closure and game
  disposal during settling produce no PNG, release the lock and allow later capture.
- [x] Original pause capture/GUI regression passes:
  `20261008-004748400-e1d1c47c`. `test_run_capture.gd` is unchanged.
- [x] F005 ordinary walking/E hold/release/Save and independent GUI Load pass:
  `20261008-004811473-eb466506` (two live frames plus13 paused views).
- [x] F006 ordinary backpack/input/Save/new-process GUI Load and labeled synthetic
  twenty-slot display pass: `20261008-004953323-80bb9767` (eight modal plus two
  pause captures; both960x640 and800x600 panel fits).
- [x] Python integrity tests pass legacy pause checks, valid/invalid live states,
  timing/settling/provenance, malformed named arrays, duplicate images, mixed-mode
  inclusion, unique output and retained source failures.
- [x] First combined contact sheets validate25 captures across contract fixtures,
  pause regression and F005; F006 sheets validate ten. Inspected sheets and full
  ordinary hold image show actual progress, visible backpack focus and accurate
  pause/mode captions. All five derived sheets (46 total source images) inspected.
- [x] F007 ordinary red/green drag/drop/travel and independent GUI restart pass:
  `20261008-005245498-26f751c6` (four drag, two backpack and five pause captures).
  The writer completes the actual Tollworks round trip; the reader verifies the
  exact restart oracle and physically recollects the restored rod.
- [x] Final red/green images and11-image contact sheet inspected. Valid ghost is
  green; invalid ghost is red with the actual Cannot place prompt and retained
  errors. Ghost remains small against the dock; F008 visual polish stays separate.
- [x] Git whitespace check passes with the repository's existing CRLF handling.
  All five successful runner reports contain only passing cases; owned engine
  PIDs are absent. No source-game, production, renderer or native-helper changes.

Raw ignored runs live under `docs/evidence/TESTING/`; UTC Oct8 IDs correspond to
local Oct7. No native input/export proof is claimed by these viewport helpers.

## Retained failures

Initial contract run `20261008-004607618-1914d417` caught a freed-target type error
when hold completion removed its node during settling. Identity tracking now uses
instance IDs across awaits, and disposed-game/target fixtures verify clean refusal.

First full F007 run `20261008-005047242-16ca11db` produced four verified drag
images, then lost window focus during its long route. Shared movement correctly
stopped and retained the failed evidence. No focus/input guard was weakened.
