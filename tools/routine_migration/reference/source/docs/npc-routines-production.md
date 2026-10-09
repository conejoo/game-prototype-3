# Production NPC routines

Edric Vale (`npc-01`) and Helena Vale (`npc-02`) use schema-version-1
routines from `assets/data/routines/`. Authored times are inclusive at the
start and exclusive at the end. The selected baseline partitions every minute
of the day without assigning either NPC twice.

## Daily schedule

| Time | Edric | Helena | Selection notes |
| --- | --- | --- | --- |
| 22:00–06:00 | `vale-overnight-home` | `vale-overnight-home` | Atomic group rest in Mayor Vale home. |
| 06:00–08:00 | `vale-breakfast` | `vale-breakfast` | Atomic group morning moment. |
| 08:00–12:00 | `vale-morning-work` | `vale-morning-work` | Atomic group assignment with Edric in Alderwake and Helena doing archive work. |
| 12:00–13:00 | `vale-midday-briefing` | `vale-midday-briefing` | Atomic civic briefing in Alderwake. |
| 13:00–17:00 | `edric-afternoon-rounds` | `helena-afternoon-archive` | Solo default work. Conditioned replacements are listed below. |
| 17:00–20:00 | `edric-evening-fishing` | `helena-evening-archive` | Fishing requires `heavy-rain` to be inactive. Heavy rain selects Edric's indoor replacement. |
| 20:00–22:00 | `vale-evening-home` | `vale-evening-home` | Atomic return through the authored portals. |

## Conditioned replacements and fallback

- Learning `npc-01-river-fishing` selects higher-priority
  `edric-afternoon-river-notes`; without that People-journal fact, Edric keeps
  `edric-afternoon-rounds`. Suppressing the variant exposes the lower-priority
  default again.
- A recorded `resourceGathered` event for `moonflower` selects
  `helena-afternoon-moonflower-records` while
  `npc-02-archive-lead-shared` is unset. Without the event, Helena keeps
  `helena-afternoon-archive`.
- Setting `npc-02-archive-lead-shared` selects the priority-300
  `helena-afternoon-ledger-review` and makes the unset-flag alternatives
  ineligible.
- `heavy-rain` active selects `edric-evening-rain-shelter`; inactive selects
  `edric-evening-fishing`. The exterior weather schedule contributes this
  effective event only during thunderstorms; ordinary rain does not. These
  complementary conditions leave no weather-state gap.
- `endRoutineForDay` suppression is intentionally stronger than full-day
  baseline coverage. When no lower eligible replacement exists, the NPC stays
  at the last loaded position for the rest of that window and ordinary
  dialogue remains available. No raw position or path is persisted.

Every production condition kind is exercised by these records. Production
Helena archive links exercise `resume`, `jumpToStep`, and
`endRoutineForDay`. The clearly named schema fixture
`test/fixtures/routines/valid/fixture_group_overnight.json` retains coverage
for `activateWorldEvent` and `deactivateWorldEvent`; these directives have no
new production dialogue choice in this slice.

## Authored map contract

Routine JSON refers only to stable map-qualified anchor IDs. Five anchors live
in Alderwake and nine in Mayor Vale home. They were created and edited through
`EditorMapElementEditEngine`, then saved through the canonical `WorldMapCodec`;
they remain invisible and non-colliding at runtime.

The stable `mayor-vale-home-exit` portal keeps its destination and ID. Its
source rectangle is aligned with the visible interior door at
`left: 256, top: 384, width: 64, height: 32`, making its center statically
reachable for the shared generic route planner. No NPC-specific pathfinding or
raw-coordinate routine shortcut is used.

## Runtime, interaction, and persistence

The active-map actor walks visibly and remains interactable whenever its
routine policy permits dialogue. An actor on another loaded-map leg remains
mounted only as hidden, non-interactable transient execution. Visible portal
departure completes before that actor changes maps; offscreen legs may snap
only after generic route validation. Dynamic player/NPC footprints are
request-scoped blockers. A mover waits briefly, requests deterministic repath,
and enters a typed failure state rather than teleporting when no route remains.

Routine dialogue resolves current-step entry, routine default, then ordinary
NPC entry. Opening it pauses all loaded participants in the atomic routine;
closing without a tagged outcome resumes by default. Production Helena choices
cover resume, named-step jump, and current-day end. Version-1 fixtures cover
event activation/deactivation without adding unsupported production narrative.

Save data includes `dayCycleProgress`, monotonic `dayIndex`,
`activePlaySeconds`, active world-event IDs, current-day suppressed routine IDs,
relationships, and `PlayerEventJournal`. It deliberately excludes paths, NPC
positions, step indexes, action/speech timers, occupancy, and group/dialogue
pause state. Map load and save load reconstruct those transient values from
authored time, state, anchors, and portals. Reset returns all durable routine
state to current-format defaults.

## Developer acceptance and limits

Debug builds mount default-hidden, read-only routine diagnostics. F5 toggles
selected/rejected routine, participant, step, anchor, path/repath/no-path, and
occupancy IDs; F6 advances one authored hour and reconstructs loaded NPCs at
that clock position. It is ignored during an active routine dialogue.
`tool/gameplay state` reports current day, selected routines, active/suppressed
events, and bounded diagnostic text for real Linux smoke checks.

Validate production content with:

```sh
dart run tool/validate_npc_content.dart --all
dart run tool/validate_routine_content.dart --all
```

Actions are presentation-only. Unloaded maps are not continuously simulated;
validated offscreen legs resolve deterministically. No procedural dialogue,
runtime AI, raw-coordinate schedule destinations, crowd steering, enemy AI,
combat, pursuit, or NPC-specific pathfinding exists in this feature.

## Ivo's dock station windows

INT-019 registers `ivo-docks-day` (06:00–22:00) and
`ivo-docks-evening` (22:00–06:00), unconditional, priority 100 and always open
to dialogue. Ivo reaches `alderwake:passenger-booking-ivo-01`, waits 45 active
seconds, checks the ordinary dry shore at `passenger-salvage-handoff-01`, waits
20 seconds, returns to booking and remains available 400 seconds. Both use
the same approved dry-lane anchors and real `npc-07` actor. This brief station
walk represents routine line inspection, with no accident disclosure or
crew-work outcome. Scene leases pause and restore this executor; later tasks
own booking, customer-fitting and salvage events.
