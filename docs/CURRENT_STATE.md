# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified implementation state.

## Current task

- P002 complete; P001 prerequisite rechecked. P003 next eligible; P003–P014 pending.
- Runnable stationary graybox with pause/resume/quit, validated content catalog,
  explicit session initialization, separate mutable actor health and run progress.
- No movement, quest runner, combat, companion AI, saves, Blender assets, or export.

## Implementation and changed files

Root: `D:/development/game-dev-blender/returning-fair-prototype`; Godot project:
root plus `/game`. Architecture contract unchanged; source reference untouched.

- `game/core/content_definition.gd`, `content_manifest.gd`, `content_catalog.gd`:
  typed authored data, global stable-ID uniqueness, field/reference validation,
  typed lookups. Candidate errors return descriptive strings without publishing
  partial indexes or replacing a good catalog.
- `game/features/actors/actor_definition.gd`, `actor_state.gd`,
  `actor_placeholder.gd`: authored max health, per-instance scalar copies, wrapper
  receiving authoritative session state; visual remains under `VisualRoot`.
- `game/world/location_definition.gd`,
  `game/features/dialogue/dialogue_definition.gd`: scene/spawn/actor references,
  speaker/line metadata. No room travel or dialogue runtime added.
- `game/content/prototype_catalog.tres`, `actors/{hero,maris,temporary_companion}.tres`,
  `locations/test_room.tres`, `dialogue/temporary_companion.tres`: five definitions.
- `game/app/game_session.gd`: validated one-time initialization, actor dictionary,
  current location/spawn IDs and time. Rejected initialization preserves progress.
- `game/app/game_root.gd`, `.tscn`: catalog -> session -> actor wrapper initialization;
  invalid content aborts startup with exit 1. Existing camera/UI composition kept.
- `game/tests/content_catalog_checks.gd`, `application_smoke.gd`: focused negative,
  ownership and integration checks. New generated script `.uid` files retained;
  original scene/script UIDs preserved.
- `README.md`, `docs/CHECKLIST.md`, this file, `docs/evidence/P002/`: commands,
  completion, evidence and handoff. No P003 implementation started.

## Checks and evidence

Engine: `4.7.2.stable.mono.official.ed1daf0bf` (`--version`, exit 0).
Executable: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
All commands below use `--path D:/development/game-dev-blender/returning-fair-prototype/game`.
Exact complete commands, logs and acceptance mapping: `evidence/P002/VALIDATION.md`.

- `--headless --editor --import --log-file <P002>/editor-first.log`: exit 0,
  imports/classes registered, no GDScript parse errors. Existing missing Mono
  SDK `10.0.9` diagnostic remains; GDScript does not require C# tooling.
- `--headless --script res://tests/content_catalog_checks.gd --log-file <P002>/catalog-final.log`:
  exit 0/PASS. Duplicate IDs (including cross-kind), missing/wrong-kind references,
  invalid fields, scenes/spawns/dialogue, missing/null/unsupported definitions,
  atomic rejection, independent actor health/session time/location progress.
- `--headless --script res://tests/application_smoke.gd --log-file <P002>/smoke-first.log`:
  exit 0/PASS. Actual root initializes services/wrapper; P001 composition/input/
  synthetic pause/resume regression passes without runtime errors.
- `--headless --script res://tests/content_catalog_checks.gd --log-file <P002>/invalid-startup.log -- --invalid-startup`:
  expected exit 1. Actual root reports empty hero ID and missing actor reference;
  no partial usable session. These logged errors are deliberate negative evidence.
- `--quit-after 30 --log-file <P002>/windowed-startup.log`: exit 0, real Windows
  Compatibility renderer starts main scene cleanly (RTX 4070 Laptop, driver
  581.29). Bounded startup only, no new interactive/gameplay quality claim.
- `git diff --check`: exit 0. P001 baseline commit `237fdf9`; clean Git snapshot
  immediately before P002 edits. Old handoff's no-commit claim was stale.
  P002 implementation/docs/evidence recorded together in local Git at user's
  request on 2026-10-02. No push or publication.

P001's actual interactive evidence remains in `evidence/P001/VALIDATION.md`.
P002 changes data/ownership only; no new visual or playable feature claimed.

## Decisions, repairs and limitations

- Definitions treated as immutable by contract. Session/ActorState retain IDs
  and scalar values; UI/models do not own campaign state. No autoload, speculative
  quest/combat/reward/save service or architecture change.
- IDs: `prototype-hero`, `npc-03`, `prototype-companion`, `prototype-test-room`,
  `prototype-companion-greeting`; player instance `party-player`; spawn metadata
  `prototype-start`. Spawn placement/anchors remain P004 work.
- Maris ID/name supplied by user; all health defaults are prototype content.
  Source checkout has only `.git`, no HEAD commits, no requested story/canon files;
  confirmed both sandbox and normal-access read. No extra named facts imported.
  Restore or supply relevant source canon before later narrative adaptation;
  no restoration/modification attempted here. This does not block P003 movement.
- Companion and greeting explicitly labeled temporary/noncanonical; neither
  spawned/run yet. No permanent companion, romance, household or hero motive
  decision made. Retired currency concepts not introduced.
- First catalog test failed because manifest `duplicate(true)` retained external
  `.tres` references. Fixed by duplicating each definition explicitly; final
  checks also prove cached authored resources stay unchanged. Disk content never
  changed by tests. Initial failed log retained as `catalog-first.log`.
- Initial sandbox prerequisite smoke passed with cache/certificate diagnostics;
  final engine checks used normal application access and explicit evidence logs.
- P002 acceptance has no remaining blocker. SDK warning affects unused C# tooling.
  Blender connection/export templates remain unverified, outside current task.

## Next session

P003 only: hero CharacterBody3D movement/facing/collision, camera-relative controls
and aiming, pause/UI input isolation, modest zoom; compare orthographic and mild
perspective in same room with actual interactive evidence. Recheck prerequisites,
preserve P002 implementation, read instructions/docs first. No canon source
needed for temporary movement fixture. Stop before P004 unless explicitly authorized.
