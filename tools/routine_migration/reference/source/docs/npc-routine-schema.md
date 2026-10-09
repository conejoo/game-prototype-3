# NPC routine JSON schema version 1

Routine data is pure authored content. It contains stable IDs and no world
coordinates, Flame types, UI state, paths, or transient execution state. The
strict parser rejects missing and unknown keys at every level.

The desktop editor's project-level Stories mode provides the structured routine
timeline, step controls, map-qualified anchor selection, reference inspection,
runtime resolver preview, and cross-content validation described in
[NPC story workspace](story-editor.md).

Executable examples live in
`test/fixtures/routines/`; its README identifies valid and intentionally invalid
records. These fixtures are the key-spelling contract for schema version 1.

## Catalog index

`assets/data/routines/catalog.json` uses this exact shape for production
routines:

```json
{
  "schemaVersion": 1,
  "routines": [
    {
      "schemaVersion": 1,
      "id": "stable-routine-id",
      "asset": "assets/data/routines/stable-routine-id.json"
    }
  ]
}
```

Index IDs and asset paths must be non-blank and unique. Each indexed routine
file must declare the same `id`. Catalog output is ordered by routine ID.

## Routine record

Every routine has exactly these keys:

- `schemaVersion`: integer `1`.
- `id`: non-blank stable routine ID.
- `priority`: non-negative integer. Resolver order is descending priority, then
  ascending routine ID.
- `timeWindow`: exact keys `start` and `end`, each strict `HH:mm` from `00:00`
  through `23:59`. Equal values are invalid. `start > end` is overnight.
- `participants`: non-empty unique stable NPC ID list. More than one participant
  makes the routine atomic; no extra JSON flag exists.
- `conditions`: tagged condition list. Every entry must match, so composition is
  logical AND. Empty means unconditional.
- `interactionPolicy`: bounded dialogue entry and outcome behavior.
- `participantSteps`: exactly one non-empty step plan for every declared
  participant; no undeclared participant is allowed.

## Condition variants

Each object has exact keys shown:

| `kind` | Other exact keys |
| --- | --- |
| `worldEventActive` | `eventId` |
| `worldEventInactive` | `eventId` |
| `learnedFact` | `npcId`, `factId` |
| `relationshipFlagSet` | `npcId`, `flagId` |
| `relationshipFlagUnset` | `npcId`, `flagId` |
| `playerEvent` | `eventKind`, `subjectId`, `targetId`, `minimumCount`, `maximumCount`, `occurredWithinActiveSeconds` |

`playerEvent.eventKind` is one of `areaEntered`, `resourceGathered`,
`itemGifted`, or `dialogueChoiceSelected`. Nullable fields must still be
present. Counts require `minimumCount >= 0` and either null `maximumCount` or
`maximumCount >= minimumCount`. Recency is null or finite non-negative active
play seconds. These values map directly to the bounded `PlayerEventJournal`
query vocabulary.

## Step variants

`participantSteps` entries have exact keys `participantId` and `steps`. Step IDs
must be non-blank and unique within that participant plan.

| `kind` | Other exact keys | Rules |
| --- | --- | --- |
| `move` | `id`, `target` | `target` has exact `mapId` and `anchorId`; no coordinates |
| `wait` | `id`, `durationSeconds` | finite and greater than zero |
| `action` | `id`, `actionId`, `durationSeconds` | non-blank action ID; positive finite duration |
| `speech` | `id`, `text`, `durationSeconds` | non-blank text; positive finite expiry duration |

Action art remains optional by product contract: runtime action lookup may fall
back to idle in NR08. Schema stores only stable `actionId`.

NPC visual `world` manifests have exact keys `worldCellWidth`,
`worldCellHeight`, `rowOrder`, `idle`, `walk`, and `actions`. World cells must
remain `48 x 48`. `actions` is an object keyed by a declared semantic action
ID. Every idle, walk, and action value has exact keys `asset`,
`textureCellWidth`, `textureCellHeight`, `framesPerFacing`, and `stepSeconds`.
Texture cells use the one supported `192 x 192` clean-HD size. Sheet texture width is
`textureCellWidth * framesPerFacing`; sheet texture height is
`textureCellHeight * rowOrder.length`. Displayed sheet-grid dimensions use the
corresponding world-cell values instead. Old `cellWidth`/`cellHeight` fields
are invalid. Every named sheet uses the same south/north/west/east facing rows
as idle and walk. A declared semantic action may be absent from `actions`;
runtime lookup then returns idle animation for requested facing.

NPC runtime `dimensions` has exact keys `hitWidth`, `hitHeight`, and
`interactionRadius`. Visual world size comes only from visual manifest;
retired runtime `displayWidth`/`displayHeight` fields are invalid. Collision,
navigation footprint, interaction origin/range, routine IDs, and saves remain
independent from texture resolution.

The top-level NPC visual manifest has exact keys `npcId`, `portraits`, and
`world`. Old `usesPlaceholderArt` is invalid. Every NPC package declares its
own real sheet paths; missing art fails load/validation instead of resolving a
fallback raster.

## Interaction and dialogue outcomes

`interactionPolicy` has exact keys:

- `allowDialogue`: boolean.
- `defaultDialogueEntryNodeId`: stable node ID or null.
- `stepDialogueEntries`: objects with exact `participantId`, `stepId`, and
  `dialogueEntryNodeId` keys. Participant/step pairs must be unique and resolve
  inside this routine.
- `outcomeDirectives`: objects with exact `outcomeTag` and `directive` keys.
  Tags must be unique.

When `allowDialogue` is false, all entry IDs and outcome lists must be empty or
null. Directive variants are:

At runtime, an interacting participant tries its current step-specific entry
first, then the routine default entry, then the NPC graph's ordinary entry
resolution. A preferred entry whose authored conditions do not match is
skipped. `allowDialogue: false` prevents dialogue while that participant is
executing the routine. Opening routine dialogue pauses every loaded participant
in the atomic group before the overlay opens. Closing, canceling, switching to
another modal, or otherwise ending dialogue without an outcome uses `resume` as
the explicit default. Tagged outcomes apply their bound directive while the
group remains paused; the group resumes or receives one deterministic replan
when the dialogue closes.

| `directive.kind` | Other exact directive keys |
| --- | --- |
| `resume` | none |
| `jumpToStep` | `participantId`, `stepId` |
| `endRoutineForDay` | none |
| `activateWorldEvent` | `eventId` |
| `deactivateWorldEvent` | `eventId` |

Jump targets are validated within the routine. NPC, dialogue, action, fact,
flag, event, map, anchor, and portal existence is deliberately deferred to the
cross-content validator in NR06.

## Cross-content declarations and validation

Each NPC runtime manifest owns a required `routine` object with exact keys
`agentProfile`, `actionIds`, and `relationshipFlagIds`. `agentProfile` has exact
keys `id`, `footprintRadius`, and `clearance` and maps to the actor-neutral
`NavigationAgentProfile`. Action IDs are semantic declarations independent of
optional animation art; a declared action may render idle until NR08 supplies
art. Relationship flags used by dialogue and routines must be declared here.

Dialogue choices may expose optional `outcomeTag`. Tags are unique within one
NPC graph. Routine outcome bindings must match a tag exposed by at least one
participant. A default routine dialogue entry must exist for every participant;
step-specific entries resolve in their named participant graph.

`RoutineContentValidator` reports the routine file, routine ID, JSON field,
optional step ID, and cause. It validates world events, NPCs, facts, flags,
PlayerEventJournal subjects/targets, dialogue nodes/outcomes, actions, maps,
anchors, and consecutive move routes. Same-map and portal-leg reachability use
the generic `WorldNavigationService` with each NPC's declared profile and no
dynamic blockers. Cross-map moves require a directed authored portal chain;
every visible source leg, portal arrival leg, and final anchor leg must be
statically reachable.

Run all bundled content or one catalog ID with stable exit codes (`0` success,
`1` content/load failure, `64` usage or unknown focused ID):

```sh
dart run tool/validate_routine_content.dart --all
dart run tool/validate_routine_content.dart --id <routine-id>
```
