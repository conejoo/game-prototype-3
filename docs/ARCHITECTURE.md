# Returning Fair prototype architecture

Status: implementation contract; runnable Godot prototype through P007.
Prepared: 2026-10-01. These decisions reflect the current conversation and can
be revised deliberately when playable evidence supports a change.

## Product target

- Single-player PC adventure/action RPG with a main story and companions.
- Mature fantasy: believable motives, relationships, and consequences, with
  room for beauty, humor, and hope.
- Full 3D world with an angled overhead camera and stylized Blender assets.
- Godot 4.7.2, typed GDScript. The installed .NET editor can run GDScript.
- One active companion initially; companionship is independent of romance.
- Initial control proposal: WASD movement, mouse aiming, attack, dodge, E to
  interact. Bind actions through InputMap. Final bindings follow playtesting.

## Playable scope

Build a shortened, explicitly labeled adaptation of the Returning Fair recovery
loop: accept a lead in Alderwake, travel with a companion into the Tollworks,
defeat a protective construct, recover Maris's missing experience, return for
reconnection, and see her specialist service recover. Include one optional
dialogue choice with a companion reaction and one character upgrade.

This is a systems prototype, not a claim that MQ00–MQ03 or the full fair opening
have shipped. Do not silently change the existing campaign's canonical order.
The source story puts a return scene and practical work after recovery; touching
a vessel should not instantly restore the whole town or repair the ship.

Use two compact connected locations, one companion, one recoverable NPC, one
guardian type, one quest, one ability upgrade, a journal, and durable saves.
Start with primitive geometry. Introduce one small Blender asset set after
gameplay works. The full opening, farming, housing, romance, full NPC schedules,
second city, and a large party are later work. Multiplayer is outside scope.

## Source material and canon

Read-only source project: `D:/development/game-prototype-2`.

- `README.md`: engine and installed-versus-planned content context.
- `game-story.txt`: selected story, The Returning Fair.
- `game-direction.txt`: original life-adventure design; some priorities differ
  from the new journey/companion focus.
- `docs/market-of-borrowed-days.md`: current Returning Fair quest design despite
  the historical filename.
- `docs/towns/alderwake.md`: town canon; consult before adapting named residents.
- `docs/returning-fair-campaign-schema.md` and campaign models: useful examples
  of quest steps, checkpoints, and presentation states, not a direct runtime port.

Preserve known IDs such as `npc-03` for Maris. Use arbitrary string IDs for new
content; do not restrict all future quests to an enum of prototype quest IDs.
Keep any temporary test companion explicitly noncanonical. Its identity and
story role remain open; do not assign romance, secrets, or new household facts
to existing residents without authored design. Label prototype dialogue as an
adaptation. Retired borrowed-days/memory-currency concepts stay retired.

## Repository layout

```text
returning-fair-prototype/
  docs/                  # Architecture, checklist, handoff, agent prompt
  game/
    project.godot
    app/                 # Entry point and session/scene composition
    core/                # Shared IDs, content catalog, save codec
    features/
      actors/
      combat/
      interaction/
      dialogue/
      quests/
      relationships/
      progression/
    content/             # Authored .tres definitions, organized by feature
    world/               # Locations, spawn anchors, persistent props
    ui/
    assets/              # Exported GLB, textures, audio
    tests/               # Headless tests and fixtures
  art/source/            # .blend sources, outside Godot import tree
  art/exports/           # Export notes and validation evidence
  builds/                # Ignored local export output
```

Co-locate scripts and scenes for a feature. Add folders and abstractions when
needed, not empty classes for every planned feature. Preserve scene/script UIDs
in version control; exclude Godot's generated `.godot/` directory and private
export credentials. Track useful authoring files and reusable export settings.

## Ownership and dependency direction

```text
GameRoot
  GameSession             persistent progress and gameplay services
  WorldHost               current location, loading, applying persisted facts
  Party                   player and active companion
  CameraRig               follows a supplied target
  UI                      HUD, dialogue, journal, menus
```

Keep GameRoot alive during location changes. WorldHost replaces its location
child. Party transitions with explicit lifecycle hooks and spawn anchors; avoid
letting actors simulate against a half-unloaded world. The root wires services,
actors, camera, and UI. Dependencies are provided explicitly. Add a global
autoload only for a demonstrated application-wide need.

| Owner | Responsibility | Must not own |
| --- | --- | --- |
| Content catalog | Stable IDs and authored immutable definitions | Current health or quest progress |
| Session | Current run, party membership, progression, persistent world facts | Rendering or imported model nodes |
| Quest service | Legal objective transitions and once-only effects | Direct HUD/model manipulation |
| Relationship service | Companion trust and recorded reactions | Main-story eligibility through arbitrary affinity gates |
| Actor components | Movement, health, attacks, interaction, animation hooks | Town-wide quest state |
| World presenter | Maps persistent facts to scene variants | Independent copies of campaign progress |
| UI | Displays state and submits commands | Reward rules or save authority |
| Save repository | Validated snapshots and version migration | Live scene-tree serialization |

Use typed Resources for authored definitions. Treat them as immutable; runtime
state belongs in separate typed objects. Implement story, relationship, reward,
and save rules without dependencies on live world nodes where practical.
Physics, navigation, and animation remain normal Godot nodes.

Commands request actions; signals report completed changes. Use direct typed
service calls for commands, with explicit results. Avoid a string-based global
event bus as the only dependency mechanism. A single operation validates and
updates its related facts before observers see the result. Quest rewards and
scene checkpoint effects have durable completion IDs so retry/load cannot
grant them twice.

Player input and companion AI use the same actor movement/combat API. Prefer
small composed components and focused behavior states over a deep inheritance
tree. Start companion AI with follow, fight, return, and safe catch-up; make
room for commands later without building a general behavior editor now.

## Content and persistence contracts

Definitions identify actors, quests, dialogue nodes, abilities, locations,
spawn anchors, and persistent world objects by stable IDs. Physical instances
need their own IDs: two guardians of the same definition are distinct.
NodePaths and display names are not durable identity.

First save envelope includes `schema_version`, a content compatibility version,
current location/spawn information, player state, party membership, quest
progress, completed effects, relationship state, upgrades, and relevant world
facts as those features arrive. Represent vectors/enums explicitly as plain
data. Do not persist node references or executable Resources.

Validate a candidate save before replacing the current session. Write via a
temporary sibling file, retain a known-good backup, and check every file
operation. Use Godot's `user://` path for saves. Handle missing/corrupt files,
unknown newer versions, renamed IDs, and invalid spawn positions deliberately.
Introduce migrations when a previously shipped save schema changes. Default
new optional fields only when the compatibility rule is documented.

At first, save at stable boundaries outside an active attack/dialogue/cutscene.
Document that limit in UI and tests. Support arbitrary mid-scene saving only
when resumable scene checkpoints are implemented. Quest/trust/progression and
world changes must survive both location unloading and process restart.

Load order: validate definitions and snapshot, initialize session, load location,
apply persistent facts, place actors at valid anchors, connect UI, enable input.
World presentation reads authoritative facts whenever a location loads.

### Delivered save boundary and compatibility (P005)

Normal pause UI explicitly saves/loads `user://saves/returning-fair.json`; no
autosave or implicit startup load. Restore uses the saved location's last arrival
anchor, never an arbitrary position/heading/velocity. Save/load rejects unfinished
travel; loading stays paused and locks repeated requests until safe placement
and root-owned session/actor rebinding complete. Future combat/dialogue owners
must extend this boundary before those features can save.

At P005 delivery, schema/content versions were both 1. Strict plain JSON contains location/spawn IDs,
player instance ID, ordered party member IDs, actor instance/definition/health,
and elapsed seconds. P005 supports only `party-player` / `prototype-hero`; maximum
health is derived from content, never trusted from disk. Unknown/missing fields,
IDs, versions and invalid numeric data fail before live-session replacement.
This was the first save schema. P007's delivered v2 migration is specified below.
Additive compatible content
may retain content version 1; incompatible ID/stat changes require a documented
version/migration decision, never silent remapping/defaulting.

Repository is a single-writer local slot: validate/flush/reopen sibling `.tmp`,
stage and publish a validated `.bak`, then publish primary with checked same-folder
rename. First save also creates a recovery copy. Missing/malformed primary can
load validated backup without rewriting files; incompatible versions or IO
failures block fallback. Save refuses incompatible primary/backup and corrupt
primary without valid backup. After recovery, explicit Save may replace corrupt
primary while retaining good backup. Uncommitted temporary files are ignored.

### Delivered interaction/dialogue boundary (P006)

Location-owned interaction wrappers carry stable instance IDs, kind, prompt,
reach and dialogue-definition ID. Replaceable visuals live under VisualRoot;
collision stays on the wrapper. Nearest in-range, unobstructed target wins,
with instance-ID ordering for ties; commands reselect rather than trust a stale
prompt. Travel uses the same selector and existing WorldHost transaction.

GameRoot composes a transient, node-independent DialogueService. Immutable
DialogueDefinition/DialogueChoice Resources contain introduction lines and
terminal choice responses. Runtime cursor/source/selection/result stay in the
service, never in authored Resources or UI. P006 needs no general graph engine:
at P006, explicit prototype-observe/prototype-leave actions only present responses;
unknown actions fail. Quest/reward/trust commands must be routed to their owning
services when those features arrive, with durable once-only IDs there.

Dialogue is an exclusive input mode: clear held movement, disable actor controls,
block world key/mouse actions, allow GUI choice/Finish/Close, and use Esc to cancel
before pause. Pause UI cannot stack over dialogue. Closing releases GUI focus;
fresh movement presses are required. Location unload cancels dialogue/source
references. Save/load rejects active dialogue, even if externally forced paused;
dialogue has no resumable checkpoint. Existing schema/content v1 remain compatible:
only additive presentation fixtures were added, no durable data fields changed.

### Delivered quest, journal and migration boundary (P007)

QuestDefinition contains ordered QuestStep Resources with arbitrary stable quest,
step, action, effect, location and source IDs. The previous step is the prerequisite;
no general graph/event bus is needed. Session owns separate QuestState completion
prefixes and completed effect IDs. QuestService validates action/order/location/source,
commits both facts before its changed signal, and acknowledges retries without
granting or notifying again. Effects are durable recovery facts, not currency or
upgrade points. Scene/service presentation of reconnection remains P011 work.

DialogueChoice can reference a catalog-validated quest/action. DialogueService
delegates to an injected root command; root checks live source and input mode,
QuestService owns rules. Rejection preserves choices and displays a useful error.
Successful physical travel records an eligible arrival only after placement;
restoring a save rebinds QuestService and never replays arrival effects. Journal
reads service state; J/Esc/Close exits its exclusive input mode. Journal/dialogue
focus cycles stay inside their modal; save/load requires closing both first.

Schema v2/content v1 adds `quests` (quest ID -> ordered completed step IDs) and
`completed_effect_ids` (unique strings). Decode requires exactly the compatible
quest set, legal prefixes and the corresponding complete effect set. Unknown,
duplicate, skipped, missing or inconsistent IDs fail before replacing a session.
Exact schema-v1/content-v1 envelopes migrate to empty quest/effect state while
preserving all existing validated actor/location/time facts. Migration copies data;
Read leaves disk unchanged and announces migration. Explicit Save publishes v2
using the existing checked repository. Newer schemas/content remain incompatible;
there is no fallback to older saves for an incompatible primary.

One labeled shortened Maris (`npc-03`) adaptation covers lead, expedition,
guardian clearance, vessel return path, return and reconnection checkpoint.
Normal play stops at the unimplemented guardian objective. Only debug builds
launched with `--quest-test-fixtures` add the labeled TEST ONLY Tollworks prop;
choosing its dialogue requests simulated clearance through normal quest rules.
It never changes facts automatically or supplies combat evidence. P008 must
replace its event source with actual guardian defeat, preserving saved step/effect
IDs deliberately. Live bridge adds read-only quest/journal observations and J input;
it still has no objective/state mutation command.

## Blender/Godot asset boundary

Godot owns gameplay scenes, collision, navigation, lighting, and interaction.
Blender owns meshes, UVs, textures/material preparation, rigs, and source
animation. A Godot gameplay wrapper instances the exported visual scene under
VisualRoot. Scripts and persistent IDs are attached to wrapper nodes, not
generated imported children. An asset re-export must preserve gameplay setup.

Use GLB as the initial exchange format. Establish a meter-based scale, Godot
Y-up convention, agreed actor forward direction, ground origin, applied
transforms, animation names, and export settings through one measured test.
Let the exporter handle coordinate conversion; avoid ad hoc axis rotations.
Use simple export-compatible materials and verify their actual Godot result.
Do not assume Blender procedural shaders or modifiers transfer directly.

One initial set: recovery vessel, guardian, modular Tollworks prop. Hero and
companion may remain capsules until movement/combat are stable. Keep the live
Blender user's unrelated scene safe; inspect the connection and scene first,
then work in an isolated prototype collection/file using applicable skills.

## Validation and architectural completion

Use targeted headless tests for meaningful rules: content references, illegal
quest transitions, once-only rewards, save round trips, corrupt/newer saves,
and progress surviving reload. Verify camera, collision, combat feel, companion
navigation, and art import in the actual game. A passing headless check alone
does not prove visual quality or playable completion.

Architecture succeeds when a second quest, guardian variant, location, and
replacement visual can be added without rewriting the session or first quest.
Demonstrate extension with a small isolated content fixture, not by doubling
the production scope. A runnable Windows export is the final prototype gate.

### Local live playtest tooling (P003)

An explicitly enabled debug-only bridge under `game/tests/` accepts bounded
JSON commands from a local `builds/playtest/<session>` directory. GameRoot
composes it only with `--playtest-dir=...`; normal runs and release builds do
not start it. No listener, network endpoint, executable command or autoload.

The bridge injects viewport key/mouse events through normal InputMap/GUI paths,
schedules holds using monotonic time, and observes/captures the actual rendered
application. It does not teleport actors, change session/quest/reward/save facts,
or bypass gameplay input gates. Commands carry boot/request IDs, validate before
input, avoid duplicate execution and release held input afterward. Outputs remain
ignored local artifacts unless deliberately copied to validation evidence.

This tool supports repeatable windowed playtests without OS key-hold automation.
Injected input does not prove physical keyboard mappings or OS focus handling;
those require separate real desktop/manual evidence. A synthetic objective still
cannot establish normal quest gameplay. Harness observations never own game state.

## Decisions still open

- P003 chooses orthographic provisionally after same-room playable comparison;
  revisit camera projection/feel with richer locations and combat.
- First canonical companion and hero's reason for onward travel.
- Combat timing, difficulty, aiming details, art palette, and minimum PC target.

These do not block primitive movement and system work. Use labeled temporary
content and record provisional decisions rather than inventing permanent canon.
