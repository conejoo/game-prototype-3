# Returning Fair prototype architecture

Current save policy (2026-10-08): accept only schema7/content1. The project has no
released data or customers requiring backward compatibility. No old-schema
migrations, ID remapping or missing-field defaults. Future schema changes replace
the supported format and update fixtures; reject other versions before live swap.
Historical delivery sections below describe past implementations and do not
reinstate compatibility requirements. Backup/recovery, validation and atomic
restore remain required.

Status: implementation contract; runnable Godot prototype through P014, M019 map,
W010 weather and F010 foraging/native delivery, current schema7/content1 with N004 persistence, N005 portrait conversation integration, N015 ordinary contacts/art for all eight requested villagers and N016 separate review-only semantic action variants, N017 integrated all-eight/recovery/restart acceptance and N018 fresh Windows/native delivery.
Current development source also includes G001-G008 social rules/save/activation,
friendship/bag feedback, ordinary viewport gifting and met-only People journal.
Integrated ordinary social recovery/restart is verified; fresh native delivery remains G009. Historical N018 packages retain
their pre-social boundary.
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

Use one continuous source-derived Alderwake exterior and the compact Tollworks,
one companion, one recoverable NPC, one
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
      environment/          # Clock/weather rules, light registry, state and lighting presenter
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
| Save repository | Validated current-schema snapshots and checked backup recovery | Live scene-tree serialization |

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
Support only the current schema/content versions. Change the schema deliberately
when required, update complete test fixtures, and reject other formats. Do not add
migrations or silently default missing saved fields.

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
upgrade points. Scene/service presentation of reconnection is delivered in P011 below.

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
At P007 delivery, normal play stopped at the unimplemented guardian objective. Only debug builds
launched with `--quest-test-fixtures` add the labeled TEST ONLY Tollworks prop;
choosing its dialogue requests simulated clearance through normal quest rules.
It never changed facts automatically or supplied combat evidence. P008 replaces
its event source with actual guardian defeat, preserving saved step/effect
IDs deliberately. Live bridge adds read-only quest/journal observations and J input;
it still has no objective/state mutation command.

### Delivered combat and durable guardian boundary (P008)

ActorPlaceholder supplies movement, facing, attack, dodge and damage APIs to both
hero input and an injected GuardianController. CombatState owns transient action
timers, locked swing direction and contacted target IDs; it has no UI/model/tree
dependency. Actor wrappers resolve range/cone and world-obstruction queries, then
apply damage through the target API. A target consumes one contact per swing,
including a dodged contact; active frames cannot repeatedly damage that target.
Combat feedback belongs to wrapper markers/VisualRoot and HUD, not damage rules.

One guardian instance `tollworks-guardian-01` appears after expedition eligibility.
Its actual death callback requests quest clearance using that source ID. P007's
simulation prop/dialogue is removed. Quest/step/action/effect IDs remain unchanged;
schema2/content1 stays compatible, including previously saved P007 clearance.
The existing `tollworks-guardian-cleared` effect is the authoritative durable
instance fact; no redundant guardian boolean or save migration is needed. On load
or revisit, presentation creates a defeated, nonblocking wrapper from that fact.

Unfinished guardian health/actions are transient and reset on room reload/retry;
hero health stays session-owned. Death disables actions; R performs validated
arrival-anchor placement, then restores hero health while retaining quest/effects.
Failed travel preserves old guardian/state/targets and resumes input. Save/load
requires a living hero with no attack/dodge and no living guardian within 5m or
engaged; pause freezes combat and permits Resume, while save/load stays disabled.
Interactions/journal reject this unstable combat boundary. No mid-fight snapshot,
healing economy, companion behavior or general AI framework is introduced.

### Delivered active companion and save migration boundary (P009)

Session owns ordered `party-player` / `party-companion` ActorStates; definitions
remain immutable. Root creates one persistent companion wrapper using existing
ActorPlaceholder movement/damage/swing APIs, injects hero/enemy into its transient
CompanionController, and rebinds both states after validated restore. Location
dialogue stand-ins remain labeled stationary fixtures, not extra party members.
Hero/ally do not block each other; attacks still reject friendly targets.

Each tiny graybox owns a NavigationRegion3D baked from layer-1 static gameplay
collision before placement/server synchronization. Replaced art contributes no
navigation. Radius 0.4m, height 1.6m and climb 0.1m keep routes off low plinths.
The companion requests server paths every 0.4s, follows within 1.6m, assists nearby
guardian combat, and returns when beyond its 6m combat leash. Guardian can choose
either living party member; all damage and death callbacks use shared actor APIs.

Stalled movement for 2.5s or separation over 8m permits catch-up only outside enemy
threat. Candidate positions near hero require navigation, level floor, full capsule
clearance including actors, and world LOS to hero. Unsafe candidates never place or
heal. Health zero incapacitates; recovery to full health requires 3s outside threat,
living hero and safe placement. R restores both members only after safe arrival.
Travel/modal/focus changes suspend AI; travel resets route/action/source references,
including failed-placement rollback. No navigation/action/recovery timers persist.

Schema3/content1 contains the same plain fields as v2, now requiring exactly the
two ordered stable party IDs and matching actor records with validated health.
Exact v1/v2 content1 saves validate their original single-hero contract first;
migration deliberately adds the labeled fixture companion at full health. V1 adds
empty quest/effect state as before; v2 preserves it. Candidate creation does not
mutate caller or disk. Explicit Save writes v3; incompatible versions still cannot
fall back or overwrite good data. Downed companion health also round-trips.
Save/load/modal entry additionally rejects ally action windows and enemy threat.

Runtime baking is intentionally limited to these small rooms; richer levels may
pre-bake regions. No recruitment, companion commands, permanent identity, trust,
romance, upgrade, general AI framework or new persistent quest effects introduced.

M009 adds an isolated source-derived exterior candidate with explicit dry physical
surfaces, radius 0.4m, height 1.6m and climb 0.1m. A measured single-region bake
plus exact cliff/gate/perimeter centre clipping meets its loading budget; normal
production selection stays compact until M015. WorldHost now waits for a nonzero
navigation iteration and the candidate region to own the arrival-anchor query
before party placement/commit. Failed bake/placement restores and synchronizes
the previous region before resuming party control. Definitions, session, party,
save ownership and production route IDs remain unchanged. See the migration
contract and M009 evidence for geometry and timing details.

M010 strengthens the shared companion safety rule: follow stops only at similar
height with clear world sight; catch-up/recovery requires synchronized navigation,
complete endpoints, a capsule-checked physical path and clear direct relocation
corridor. Disconnected islands, stale physical blockers and water/cliff shortcuts
are rejected even when the landing near the hero is clear. Recovery keeps the
existing stall/separation/delay/threat gates and authoritative ActorState. Normal
compact rooms retain their navigation height offset; no map activation, new save
field, service or persistent recovery authority is introduced.

### Delivered relationship and progression boundary (P010)

Immutable ReactionDefinition Resources identify temporary companion, decision
and trust delta. DialogueChoice references a catalog-validated reaction; root
validates active source/action/input mode and injects RelationshipService command.
Session owns separate RelationshipState trust/reaction IDs. One prototype decision
has +1/-1 alternatives: same outcome retry succeeds unchanged; alternate fails.
Trust and reaction commit before notification. No romance or story eligibility gate.
Stationary dialogue fixtures explicitly speak for the noncanonical active ally.

One UpgradeDefinition identifies Deliberate Strike, +15 damage and earning effect
`maris-lead-accepted`. Accepting lead earns one prototype preparation point, available
before guardian combat. ProgressionService derives unspent point from authoritative
quest effect minus selected upgrade IDs; no duplicate reward counter/effect exists.
Session owns ProgressionState selected IDs. Selection requires earned point and
stable journal mode; repeat selection acknowledges without spending/notifying again.
Root applies derived hero strike damage 25→40 through existing combat wrapper.
Journal scroll/upgrade button and HUD display state; UI owns no reward rules.

Schema4/content1 adds exactly `relationship` (companion definition ID, integer trust,
reaction ID array) and `progression` (upgrade ID array). Validate unknown/duplicate/
conflicting reactions, trust disagreement, extra/missing fields and unearned/duplicate
upgrades before candidate replacement. Exact schema1–3 envelopes validate original
party/quest contract first, preserving old facts; v3 retains both actor health values.
Legacy trust/reactions/upgrades start neutral/empty. Accepted lead in old saves makes
one point available; no auto-selection. Read never rewrites disk. Explicit Save
published v4 at P010 (current W003 saves publish v5); existing incompatible-version/backup policy remains. Restore rebinds
both services and recomputes damage, avoiding cumulative bonuses on load/travel.

### Delivered recovery presentation boundary (P011)

The location-owned MarisCounter interaction wrapper retains `npc-03-counter`.
Root supplies authoritative completed effects on quest change and after successful
travel/restore, after candidate session rebinding. The wrapper maps these facts to
basic supplies, returned-experience fitting, or restored specialist variants. It
owns only transient presentation; no shop flag, inventory or second quest authority.
Definitions and collision stay separate from replaceable VisualRoot children.

`maris-returned-to-town` exposes a labeled three-line return/comparison/practical
fitting scene using temporary unnamed customer/helper fixtures. Its final choice
requests existing `maris-reconnect` through QuestService. Cancellation or pausing
the fitting grants nothing; only `maris-reconnected` reveals specialist gear and
service preview. Active dialogue retains its immutable definition through the
variant update. Basic supplies remain available; ship/fair facts do not change.

Schema4/content1 and all durable IDs remain compatible; older completed saves
present restored service immediately from their validated effects. This small
wrapper is sufficient; no general shop economy or world-variant framework added.
Low perimeter walls/counter keep actors readable in this layout; camera fading is
unnecessary. Billboard service text disables depth testing to avoid bench clipping.

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

The pause menu also exposes Settings with independent, run-local FPS and debug
shortcut toggles. `--debug-shortcuts` initializes the same root-owned mode in
editor or release runs; Settings can disable it. UI samples FPS while paused.
F6 advances only EnvironmentState by one authored game hour (25 clock seconds
at the 600-second cycle), immediately re-presents outdoor sun/weather/lights,
and keeps elapsed play time and actor/quest timers intact. Existing environment
validation handles cycle rollover and rejects the supported day cap atomically.
Key repeats and pause/modal/travel/load/retry/death/focus gates block the shortcut.
Esc inside Settings returns to the paused menu; the next Esc resumes. These
controls are independent of the opt-in automation bridge described below.

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

### Delivered normal slice presentation (P013)

Normal startup remains a fresh run; explicit pause-menu Load resumes an existing
save. The root derives optional reaction/upgrade reminders and wrong-room routing
from the existing services/quest definitions. UI displays those hints and the
stable save boundary; it owns no new completion or reward state. Schema4/content1,
quest/effect/actor IDs and imported-art wrappers are unchanged.

Practice markers and test beacons in the two gameplay rooms use the
`developer_fixture` group. WorldHost removes them before validation, collision
placement and navigation unless root enables explicit debug-only
`--developer-fixtures` (or a test sets the root's fixture property). The companion
dialogue station remains labeled normal prototype content for the active ally's
reaction. This narrowly isolates existing P006 props; no new setup/objective
mutation path or generalized developer framework is added. Test-room fixtures
and the separately opt-in playtest bridge retain their existing contracts.

### P014 extension and export evidence boundary

QuestDefinition owns journal_note and completion_text. QuestService presents those
authored strings; legal transitions, session ownership and save rules are unchanged.
Normal Maris wording stays identical. Tests append a separate quest, 60-health
guardian definition and inherited test room to a detached manifest. Existing
session/service/wrapper/WorldHost APIs handle them without changing normal content.
Exact quest-set validation deliberately rejects fixture saves in the normal catalog;
no production content-version change or save migration is implied.

Windows presets use project-local official 4.7.2 standard templates for pure
GDScript. Release excludes tests; separate debug validation retains only the
opt-in bridge. Exported bridge paths derive from the executable's adjacent
builds/playtest directory; editor paths retain their original rule. Release still
cannot start the bridge or use debug save-slot/developer flags.

Export text-resource binary conversion is disabled: the initial export lost packed
spawn/dialogue arrays and failed validation; text resources restore standalone
behavior. This observed workaround changes no authored IDs/values or schema4/content1.
Recheck conversion when changing engine/template versions. P014's native release
journey is complete for the compact prototype; M019 must revalidate the resulting
map build. Native and debug-export evidence remain recorded separately.

## Decisions still open

- P003 chooses orthographic provisionally after same-room playable comparison;
  revisit camera projection/feel with richer locations and combat.
- First canonical companion and hero's reason for onward travel.
- Combat timing, difficulty, aiming details, art palette, and minimum PC target.

These do not block primitive movement and system work. Use labeled temporary
content and record provisional decisions rather than inventing permanent canon.


### Delivered larger exterior activation (M015)

`prototype-alderwake` now selects the pinned 147 x 80m town/river/Moonwood
through `world/alderwake.tscn` and `alderwake_exterior.gd`. The existing terrain
builder supplies independent art, collision and explicit dry navigation. The
production subclass composes exactly the existing Maris counter at (-7.5,0,11),
one labeled temporary-companion dialogue station at (-2,0,0), and the existing
single travel interaction at the mapped forest Tollworks entrance (107.25,0,-1.25).
Six other source portals remain inert. Arrival IDs remain `alderwake-start` and
`alderwake-from-tollworks` (107.25,0,1.25); Tollworks and all quest/actor/effect,
trust and upgrade IDs remain unchanged, with schema4/content1.

Service bodies contribute conservative projected navigation obstructions;
render meshes never become navigable floors. Root configures the existing M008
nearby-floor grounding callback and 0.04m snap on each exterior arrival/rollback,
and restores ordinary 0.1m snap/no callback in compact rooms. Party/session and
service authority stay unchanged. The former compact Alderwake scene remains a
synthetic test fixture for unsafe-floor/navigation rejection checks.

M015 verifies the debug rendered recovery route and focused rules/lifecycle.
Camera/ground aim (M016), full save compatibility (M017), measured performance
(M018), and the resulting packaged/native Windows gate (M019) remain separate.
P014's completed compact release remains valid historical evidence.

### Delivered environment rules (W002)

GameSession owns typed EnvironmentState facts (day index, cycle progress and
once-per-fresh-run uint32 seed) and advances them atomically with elapsed time
through the existing GameRoot gate. EnvironmentClock and WeatherSchedule are
node-independent RefCounted rules: 600 active seconds per day, 10 AM display
origin, source uint32 forecast, four conditions and thunderstorm-only heavy-rain.
Forecast samples are detached; a transient cached cursor reconstructs on seek or
seed change, then computes only crossed periods. Supported day index 0..3650 and
finite progress [0,1) bound reconstruction; invalid advances return errors without
partial mutation. Pause/travel/load freeze and focus/modal/indoor policy stay as
specified in the weather contract. The measured normalized-minute boundary repair
is documented there. At W002 schema4/content1 retained only pre-W002 facts;
W003 adds environment persistence below. Rendering remains fixed until W004+.

### Delivered environment persistence (W003)

SaveCodec schema5/content1 adds exact environment day/progress/uint32 seed and
map-qualified light_source_overrides records. EnvironmentState owns those facts;
LightSourceRegistry owns all 23 pinned exterior identities/defaults, independently
of scene nodes. Only six switchable lantern tuples accept boolean overrides;
duplicates/unknown/automatic sources and extra fields fail. Snapshots deep-copy
and sort overrides by location/prop/source, never mutate the live run.

Exact v1-v4 migrations keep their existing party/health/quest/effect/time facts.
V1-v3 receive neutral consequences; v4 retains trust/reactions/upgrades. All four
receive day0/progress0/fixed seed1821285621/no overrides. Validated candidates
initialize with supplied environment, avoiding seed rerolls. Content version1
remains additive: actor/quest/effect/location/spawn/upgrade IDs are unchanged.
Manual Save writes v5; read/recovery never rewrites disk; failed physical restore
keeps the old environment, bindings and clock gates. Arrival anchors remain safe.

SaveRepository writes full-precision JSON for primary/backup. SaveNumber repairs
the installed JSON reader's timer rounding using bounded decimal long division
and one ties-even binary64 rounding, without changing the envelope fields.
Only elapsed/time-progress numeric lexemes receive this treatment; exact schema
and type validation still applies. The contract documents spelling bounds and
305 independent Python binary64 vectors, including subnormals/ties. Newer version
protection precedes numeric repair so malformed future data cannot trigger backup
fallback. Forecast cursors, samples, Nodes and review presets are never saved.
W003 acceptance covers rules/IO/physical transactions and independent processes;
rendered lighting, interactive E switching and native packages remain W004-W010.

### Delivered location lighting (W004)

LocationDefinition authors OUTDOOR_CYCLE for Alderwake and STABLE_INDOOR for
Tollworks/test rooms; new fixtures default intentionally to the stable profile.
GameRoot composes one EnvironmentPresenter and injects its existing Sun and
WorldEnvironment. The presenter duplicates the Environment resource per root,
owns no timer/session/listener and writes only rendering properties. Pure
EnvironmentLighting samples the retained source phase knots with smoothstep,
adapting palette, shadow sense and brightness to physical 3D readability.

Root presents after gated session advancement and synchronously after committed
travel/restore rebinding, before the new room draws. Failed travel/load keeps the
previous session/profile; pause freezes sampled sun movement. Indoor presentation
restores exact prior lighting while global time advances. W004 verifies rule and
lifecycle behavior plus synthetic phase/pose captures in both camera projections.
Exterior light consumers, E commands, clouds/rain/lightning, HUD, measured feature
performance and resulting native packages remain W005-W010.

### Delivered exterior light consumers (W005)

Production Alderwake explicitly builds ExteriorLights with23 consumers beneath
existing wrapper VisualRoots. GameRoot supplies committed environment facts and
hero position through its existing environment presentation gate. Registry/state
keep default/override authority; consumers own meshes/materials/anchors only.
Every lamp/window/waylight/net source owns its independent glow material.
Dedicated four-pane windows preserve imported wall/roof/crossbar materials.

A reusable authored Blender kit supplies lamp/waylight frames/cores and a
nonblocking woven net. Exactly eight fixed unshadowed Omni emitters cover six
lamps/two waylights; windows/net emit only. Source day-opacity knots and spatial
distance fading affect rendering without changing logical enabled state. Old
location disposal releases its consumers, and committed arrival hydrates new ones.
Physical wrappers/IDs/feet/collision/navigation remain unchanged. W005 verifies
consumer rules/imports/regressions and synthetic paused renderer captures. E
actions and normal switching/restart acceptance remain W006; weather/HUD/final
performance/native feature acceptance remain W007-W010.

### Delivered light switch interactions (W006)

Six location-wrapper LightSwitch nodes carry validated typed LightSwitchAction
location/prop/source identities. They stay outside replaceable visuals and share
existing range/LOS selection and input/combat gates. Root commands use WeakRef,
reselect before mutation and delegate expected-enabled validation to GameSession;
stale/queued/freed/foreign targets reject without changing facts. EnvironmentState
keeps independent overrides; automatic sources cannot toggle.

Prompts/feedback derive enabled state, explain daylight readiness and remain scoped
to the switched lamp. Root presents changed facts immediately and consumers hydrate
on committed travel/load. Schema5/content1 and timer/save ownership remain intact.
W006 verifies E/GUI switching and isolated Save/restart/Load, exact environment facts,
travel persistence and inspected synthetic phase renders. W007-W010 retain weather,
final lifecycle/HUD, performance and resulting native release acceptance.

### Delivered weather presentation (W007)

GameRoot samples committed EnvironmentState clock/forecast through WeatherVisuals
and extends its existing presenter with smooth overcast/direct/ambient/shadow
composition and bounded deterministic atmospheric flash. Session/save ownership
remains unchanged; no new clock, event, damage, local light or persisted particle
state. Camera arrival precedes weather-frustum hydration.

Alderwake owns one WorldRain using fixed world-space16m MultiMesh tiles, per-column
physical terrain heights and imported roof exclusion. Camera selection keeps
origins fixed; session shader phase freezes under pause. At most64 batches share
one mesh/material per location and are released with that location. Tollworks
retains stable lighting without outdoor rain/flash. W007 verifies current rules,
rendering, pause and exact GUI process-restart reconstruction. W008 lifecycle/HUD,
W009 measured feature performance and W010 native packages remain future work.

### Delivered environment lifecycle and HUD (W008)

GameRoot presents time/condition and lighting/weather only for matching committed
session/location ownership, including paused arrival/restore. Failed candidates
retain previous facts and presentation; load/retry gaps freeze the existing clock.
Repeated room replacement releases rain meshes/materials/targets and retains one
root presenter. GameSession exposes a read-only WeatherConditionService with
detached forecast queries and derived thunderstorm-only heavy-rain; no routine
or authored event is implemented. Header time/weather replaces elapsed seconds,
which remain a tooltip; existing E feedback remains the light command display.

Explicit debug --environment-review=<namespace> loads a test-only controller
before actor/service binding, validates a detached clone, starts paused and uses
an isolated namespace. Save/Load and repository writes reject transient review
provenance; release exports exclude the controller. Paused F7/F8 selects real
seeded phase/condition presets with a synthetic marker. Normal settings/F6/save
behavior remains separate. W008 verifies lifecycle and GPU/GUI integration;
W009 performance/full visual matrix and W010 native release are verified below.

### Delivered environment release acceptance (W009-W010)

W009 verifies the full phase/weather/projection/zoom matrix, pause/rollback and
indoor exclusion, plus M018-equivalent three-run measurements at four views in
clear day and worst storm/night. All frame/draw gates pass with stable resources
after repeated travel. [W009 acceptance](weather-lighting/W009_ACCEPTANCE.md)
records methods and limits; synthetic presets remain separate from native proof.

Both existing Windows presets now package schema5/environment/lights/weather/HUD
with target-local assets and Compatibility. Release excludes test controllers;
direct startup outside checkout passes. Ordinary native release recovery,
independent E lamps, natural clock/weather, GUI Save/quit/separate GUI Load and
actual room/service revisits pass with exact whole-save and typed forecast restore.
No runtime ownership or save contract changed for this acceptance task. Standard
GDScript templates need no .NET SDK; verified separate APPDATA/LOCALAPPDATA and
adjacent release override preserve normal saves. [W010 acceptance](weather-lighting/W010_ACCEPTANCE.md)
records new package identities, isolated evidence, clean runtime exits and retained
historical packages. W001-W010 complete; no next workflow item.

### Pinned foraging/item migration reference (F001)

[Foraging workflow](foraging-items-backpack/CHECKLIST.md) now pins source behavior,
separate item/resource stable-ID mappings and a proposed schema6 fact shape in
[CONTRACT](foraging-items-backpack/CONTRACT.md). At F001 runtime remained schema5/content1;
four source resource records stay inert. [F001 acceptance](foraging-items-backpack/F001_ACCEPTANCE.md)
records fresh P/M/W checks and synthetic floor/navigation measurements. Rod origin is
inside water collision and moonflower-01 overlaps cliff colliders; F005 must repair or
block before claiming four enabled interactions. No pinned map refresh or LOS bypass.
F002 content/inventory rules are delivered below; P/M/W release history remains unchanged.

### Delivered content and inventory rules (F002)

ContentCatalog validates21 immutable authored definitions, including typed ItemDefinition
and ForagingResourceDefinition. Distinct item/resource stable IDs and explicit references
retain source provenance. GameSession owns independent InventoryState; pure commands
validate20 distinct types, one stack/type, flower99/rod1, strict positive integer
quantities and nullable owned selection before mutation. Tool capability derives from
selected definition. Final-unit consumption removes stack and clears active selection.

Detached sorted InventorySnapshot observations cannot change session or Resources.
Catalog replacement publishes only after all item/resource references validate.
[Acceptance](foraging-items-backpack/F002_ACCEPTANCE.md) verifies rules and affected
root/map/save regressions. World records still inert, UI unchanged, schema5/content1
retained. F003 owns atomic collected/placement transactions; F004 owns persistence.
No gathering/backpack/drop activation or renewed P/M/W export claim implied.

### Delivered atomic item/resource commands (F003)

GameSession owns ForagingState with four pinned ForagingRegistry identities and
private collected-origin/typed-placement facts. gather/pickup/drop/move return typed
results, reject wrong identity/location/revision/capacity and conserve one rod across
origin/default-or-override, bag and generated placement. Inventory/world/capability
revisions form a transient opaque equality token. Collection/drop jointly commit bag,
active selection, origin suppression and placement before committed(revision) signal;
observers query detached snapshots and nested commands reject during publication.

Injected placement capability receives detached candidate/snapshot and returns strict
PackedStringArray validation. Missing/malformed/rejecting capability fails closed;
finite feet/provenance/location and post-callback room/revision checks precede consume.
Service owns no scene; GameRoot will revalidate physical target, F004 will validate
restored schema6 candidates, and F007 will supply measured geometry. [F003 acceptance](foraging-items-backpack/F003_ACCEPTANCE.md)
verifies synthetic transactions, observer timing/isolation, eight rod cycles and affected
inventory/session/save/map/environment/travel regressions. Physical records/UI remain
inert and schema5/content1 retained; no renewed native/export acceptance implied.

### Delivered item save compatibility and lifecycle (F004)

SaveCodec schema6/content1 preserves the exact v1-v5 chains and adds inventory with
nullable owned selection, collected authored origins and typed Godot-metre placements.
ForagingSaveData hydrates only fresh detached candidates, validates caps/IDs/provenance/
rod1 conservation and publishes no command signal. SaveJsonFields guards duplicate
JSON keys/escaped aliases and fractions rounded by the JSON parser. Existing precise
timer repair, newer-version/128KiB and primary/backup protection remain intact.

WorldHost receives restored facts separately from live ownership and proves every
saved placement against staged production floor/collision/navigation/reservations,
including hidden foreign-room probes. Only successful physical arrival swaps root
session/services/actors. PrototypeLocation binds one weak session/listener and exposes
detached location-filtered observations plus F005 application hook; scenes dispose
without old listeners. Retry retains collection/bag/selection; handled failed retry
uses UI feedback and ordinary logs while preserving prior state.

[Acceptance](foraging-items-backpack/F004_ACCEPTANCE.md) verifies exact all-field
independent-process binary oracles for bag/authored/generated/foreign-room states,
hostile saves/geometry, rollback/retry/travel and inherited P/M/W regressions. Current
runtime schema6/content1; world pickups/backpack/holds/drag remain F005+. Historical
P/M/W packages remain schema5 evidence; no renewed export/native claim implied.

### Delivered physical resources and held interaction (F005)

ForagingWorldAdapter derives nonblocking wrappers from actual inert resourceNode IDs,
approved registry feet and committed location-filtered facts. Saved authored/generated
placements override defaults, collected IDs suppress origins. PrototypeLocation's
existing single weak session/listener owns reconstruction. Wrapper identity/typed
ForagingAction and replaceable temporary visuals remain separate from durable state.

Root owns transient weak-session/target ForagingHoldController, copied command
identity/revision/target position and E press latch. Tick revalidates mode/target/LOS/
range/ownership before one atomic600ms flower/500ms rod commit. Release is observed
before GUI consumption; cancel/complete requires release/fresh E, preserving immediate
lamp/gate/dialogue/inspect dispatch. Root entry hooks synchronously cancel for travel/
load/retry. Noninteractive UI progress/feedback and hold/latch never enter saves.
Bridge exposes only read-only hold/inventory/foraging/world wrapper observations.

[F005 acceptance](foraging-items-backpack/F005_ACCEPTANCE.md) proves every cancellation/
capacity/lifecycle criterion, exact independent-process physical placement reconstruction
and ordinary rendered WASD all-four/hold/release/GUI Save/new-process Load/revisit.
Pinned geography/source unchanged; schema6/content1 retained. Later F006-F010
backpack/drop/drag/art/integrated/native gates are now Done; delivery evidence below.

### Delivered backpack modal and active HUD (F006)

B/HUD opens snapshot-only BackpackView with twenty slots, count/cap/details, distinct
active selection styling, Clear/Close and disabled rod-only Drop. Root owns modal state,
rejects stale/unowned/focus/lifecycle selection and delegates to existing InventoryState.
World controls/combat/AI/aim/projection/zoom and held gather input are cleared/blocked;
focus cycles inside modal. B/Esc/Close returns control requiring fresh world input.
Non-tools claim no direct use; active rod states fishing unavailable. Schema6/content1
and save ownership unchanged; explicit pause Save/Load after close persists selection.
Bridge supports B and read-only modal/slot/HUD observations. [F006 acceptance](foraging-items-backpack/F006_ACCEPTANCE.md)
verifies rules/modal conflicts, two window sizes, ordinary keyboard/pointer acquisition/
selection and exact whole-save independent-process GUI restart. Capacity presentation is
explicitly detached synthetic. Later F007-F010 placement/art/native gates are now Done.

### Delivered safe rod placement (F007)

GameRoot enables selected rod Drop using facing/alternative nearby search and binds
weak-session-qualified physical validation after each committed arrival/load. Shared
ForagingPlacementGeometry validates full rod support/clearance plus inherited restore
capsule/navigation/reservations; live commands require a dry local hero approach.
Existing ForagingState jointly consumes/places/moves before the same single location
listener applies wrappers. Invalid/no-space requests leave bag/active/world unchanged.

WorldItemDrag owns only transient copied identity/revision/foot and weak session/target.
Root consumes nearby projected rod press, disables controls/combat/AI, ground-rays a
green/red ghost and revalidates before one move on release. Original wrapper/facts
remain unchanged during preview. Esc/modal/focus/travel/load/retry/stale ownership
cancels; old pointer release is consumed before fresh world input. Save schema6 and
content1 unchanged; capability binding explains live token1 after candidate revision0.
[F007 acceptance](foraging-items-backpack/F007_ACCEPTANCE.md) verifies both projections/
zoom bounds, boundaries, indoor/foreign placement, ordinary loop/travel and exact GUI
independent-process restart/recollect. Later F008-F010 art/integrated/native gates
are now Done; historical release records remain preserved.

### Delivered local item art and feedback (F008)

ForagingItemVisual supplies editable local low-poly moonflower/rod meshes with mild
emission, plus matching SVG backpack icons. ForagingWorldAdapter replaces only
VisualRoot, preserving typed wrapper IDs/actions/feet, collision-free behavior,
session facts, the existing listener and successful-only reconstruction. Rod meshes
fit unchanged validated clearance; outlined labels draw above foliage without bypassing
actual interaction LOS. No new light, timer, animation framework or save field.

PrototypeUI stacks prompt/health/transient feedback below modal layers and styles the
existing gather progress track. Root reports received/full/cancel/invalid outcomes,
clears stale feedback on fresh E and hides it on modal entry. Existing durations,
commands, input latches and geometry remain authoritative. [F008 acceptance](foraging-items-backpack/F008_ACCEPTANCE.md)
verifies all four items across day/night/rain, both projections and zoom bounds,
ordinary gather/backpack/placement/travel and exact GUI independent restarts.
F009 integrated and F010 fresh native/export are now Done; historical releases retained.

### Delivered integrated foraging acceptance (F009)

The ordinary integrated renderer now walks the fresh all-four gather/backpack/rod
placement journey, switches a lamp, travels to Tollworks and returns, then performs
GUI Save and production F10 quit. A different process uses GUI Load and compares
all schema6 durable facts plus reconstructed forecast exactly before ordinary
all-origin revisits and physical saved-rod recollection. Shared journey/input/GUI/
capture helpers preserve normal physics, arrival anchors and ownership gates.

[Acceptance](foraging-items-backpack/F009_ACCEPTANCE.md) separates ordinary viewport
proof from synthetic capacity/geometry/focus/combat/retry/save fixtures and fresh
art/presentation samples. All affected regressions pass. Inherited companion/quest
legacy fixtures now omit schema6 fields; production validation remains strict.
Current runtime/assets/schema6/content1 are unchanged by this acceptance task.
Fresh standalone Windows/native package delivery is separately verified by F010
below; older package history and debug viewport results retain their own scope.

### Delivered fresh Windows/native foraging acceptance (F010)

External tools/foraging_items reuse installed standard templates and existing export
presets, audit packed schema6/items/icons/meshes/environment/layout/test exclusions,
and verify standalone startup/quit before promoting local packages. Production
runtime/content/save/input/geography bytes remain unchanged from accepted F009.
Historical P014/M019/W010 packages and records are preserved separately.

Corrected native writer/reader use the same verified TEMP cwd outside checkout and
fresh isolated appdata/override, exported release exe/pck and ordinary guarded Windows
input. All-four gather/backpack/rod Drop/drag/rollback/recollect, lamp/Maris/party/
guardian/travel, GUI Save/normal quit/new-PID GUI Load and physical origin revisits
pass. Whole durable save bytes and packed typed forecast match exactly. No native
fixture/bridge/mutation/time skip or new gameplay authority. Both original process
handles record exit0; final audit105 native captures and manual visual review pass.
[F010 acceptance](foraging-items-backpack/F010_ACCEPTANCE.md) owns hashes, controls,
criterion table and retained failed attempts, including the fully repeated native
loop after correcting actual cwd. F001-F010 complete; no successor or cleanup owed.

### Delivered selected NPC content boundary (N002)

GameRoot validates a separate NpcContentCatalog before session initialization. Its
strict bundled JSON input contains exactly eight selected public packages; the core
ContentManifest stays at 21 definitions and keeps the existing npc-03 identity.
No live NPC, memory, graph selection or save field is introduced at this boundary.

NpcDefinition and NpcDialogueGraph provide detached typed definitions, including
finite node/choice/condition/event data, facts, flags, expressions, gift bindings and
source visual/action references. Catalog publication deep-copies a completely
validated candidate. Lookups/snapshots detach nested collections, and invalid input
preserves the accepted catalog. Unknown keys/types, duplicate IDs, foreign/dangling
references, missing assets, unsupported conditions and cycles reject visibly.

The deterministic target-local converter preserves source fields/order/text except
N001's explicit Della welcome adaptation. All 48 portraits and 18 world sheets retain
source bytes; the sheets are reference art, not completed 3D actors or animations.
Coverage retains deferred gifts, archive routines, milestone and indoor directions
with reasons. Both export presets explicitly include content/npcs/*.json.
[N002 acceptance](villagers-dialogue/N002_ACCEPTANCE.md) verifies the eight graphs,
atomic/detached data, 75 malformed candidates and existing catalog/root regressions.
Schema6/content1 and manual saves remain unchanged. Selection/memory, UI, scene-owned
contacts, rig/export and character production belong to later N tasks.

### Delivered NPC memory and rule boundary (N003)

GameSession.conversations owns eight separate ConversationMemory values and bounded
NpcEventMemory through NpcConversationState. GameRoot.npc_dialogue composes the pure
NpcDialogueRules and transient NpcDialogueService; existing legacy dialogue remains
ordinary gameplay until N005 converts its callers. Entry disclosure, priority/ties,
condition reevaluation, atomic choice effects, cursor command tokens and detached
snapshots follow the pinned source and target capability policy.

One accepted response publishes per-person flags/receipts/affinity/target facts plus
its exact event aggregate before notifying observers. Unsupported, stale, foreign,
hidden, deferred and consumed commands change nothing. Forty fixed event keys and
numeric bounds prevent unbounded memory; gifts/routines/milestones remain deferred.
Close/cancel never applies unselected effects. Root startup and restored-session
rebinding are verified; schema6 still contains no NPC history, and N004 owns strict
current-format persistence. No scene-owned contact or ordinary NPC UI is activated.
[N003 acceptance](villagers-dialogue/N003_ACCEPTANCE.md) covers all 58 enabled nodes/
38 choices, 977 assertions, actual manual load rebinding and affected legacy checks.

### Delivered strict NPC persistence boundary (N004)

Current SaveCodec supports only schema7/content1 and adds conversations to every
prior durable field. NpcSaveData validates exactly eight per-person memories and
<=40 event aggregates before constructing a detached session. Person-owned enabled
disclosures, choices/receipts/flags/affinity, derived level and aggregate sequence/
time relations must agree. Duplicate/foreign/deferred IDs, unknown fields, numeric
fractions/bounds and shared containers reject. Exact decimal timestamp restoration
preserves binary64 values. No old-format migration or possession-derived history.

Fresh GameSession startup initializes independent memory through validated bundled
NPC content; root injects its catalog. Successful manual load rebinds restored
memory to a fresh inactive cursor after existing physical validation. Active legacy
or NPC dialogue blocks Save/Load until closed; pause/arrival/backup/rollback rules
remain intact. Current-schema fixtures explicitly carry empty NPC state when they
represent pre-conversation gameplay, preserving all authored prior facts.

[N004 acceptance](villagers-dialogue/N004_ACCEPTANCE.md) records strict malformed
rule checks, complete old/new-state round trips, root staging/placement/recovery
and separate-process restart with an exact whole-state oracle. Synthetic service/
root checks make no ordinary NPC route/UI/art or new native-package claim.

### Delivered portrait conversation composition (N005)

GameRoot.dialogue now owns one NpcDialogueService for source NPC graphs and converted
prototype ConversationDefinitions. Both use finite NpcDialogueGraph nodes, stable
identity/token commands, one snapshot/view/cancellation/save gate. Superseded
DialogueDefinition/DialogueChoice/DialogueService and the second root owner are
removed. Existing six conversations preserve exact IDs/words/quest/reaction commands
across24 nodes/15 choices; legal callbacks validate the actual live source and node.
Reentry rejects and callback cancellation cannot restore an old cursor.

ConversationView renders current speaker/expression/source portrait, authored bold
text/current disclosure highlights and only learned facts. Body, choices and facts
scroll independently; Continue/Close remain visible with contained focus. Deferred
gift/interior choices explain unavailability and retain valid exits. Existing Maris
recovery reads the same person's learned facts without new ordinary rewards.
Modal input clearing/world exclusion, focus loss/unload cleanup and closed-dialogue
manual exact save restore pass. Schema7/content1 and pinned geography remain intact.

[N005 acceptance](villagers-dialogue/N005_ACCEPTANCE.md) records all criteria, exact
conversion/removed-API audit, expanded26 plus focused8 plus final test-only4 passing
runner cases,48 expressions/68 captures and source/diagnostic/isolation guards.
Actual960x640/1350x900 modal renders inspected. Eight-person contact/expression/length
fixtures are explicitly synthetic; ordinary villager scene activation/routes, 3D
character assets and a new native release remain later N tasks. N006 next eligible.

### Delivered scene-owned NPC contact and event infrastructure (N006)

NpcRegistry pins all eight measured public contacts; its activation gate remains empty
until N008-N015 deliver their characters. WorldHost prepares scene-owned NpcWorldAdapter
wrappers/collision/navigation reservations before validation and proves physical actor/
player support, approach reachability and LOS before arrival publication. Maris reuses
her existing counter; villagers never join Party or combat. Gameplay identity lives
outside replaceable empty VisualRoots. PrototypeInteractable.npc_id validates the exact
wrapper instance, and root routes its live selected contact through the one dialogue
owner. Unsafe staged contact placement preserves the prior scene/session/facts.

Scene-owned weak-session NpcWorldEvents tracks the union of pinned woods-role zones.
Stable world updates sample actual player feet; arrival/load/retry/rollback seed
membership without recording. ForagingState stages only successful authored flower
gather events and atomically publishes memory with inventory/origin state before
observers. Choice events retain their existing atomic person/choice keys. Failed holds,
capacity failures, replay, rod operations and reconstruction create no gather history.
Exit disconnects old foraging ownership; rollback reconnects one listener. Contacts
stay fixed, with no routines or save fields added; schema7/content1 is unchanged.

[N006 acceptance](villagers-dialogue/N006_ACCEPTANCE.md) records all18 expanded and4
final passing cases, all-eight synthetic physical contacts/10,131 path samples,
existing lamp/resource arbitration, actual viewport gather event assertions, exact
manual restore and separate-process restart. Character activation/art/ordinary routes
and new native packaging retain their later gates. N007 is next eligible.


## N009 named Helena delivery (2026-10-08 UTC)

Current production activation is npc-01/npc-02. Helena's source graph/portraits and
approved public civic foot are bound to one scene-owned noncombatant wrapper,
custom editable3D skin and existing presenter/facing/hold owners. Introduction and
actual Moonflower gathering disclose only her two enabled public facts. Archive
preferred entries/outcomes and archive-practice disclosure remain deferred; no
routine controller, private home/interior or work action is simulated. Manual
schema7/content1 persistence preserves independent memory with existing durable
facts. [N009 acceptance](villagers-dialogue/N009_ACCEPTANCE.md) records ordinary
branches/gather/revisit/new-process GUI restart and physical/art/regression proof.


## N010 named Maris and counter routing (2026-10-08 UTC)

Production activates npc-01/npc-02/npc-03. Maris mounts custom editable3D art under
existing npc-03-counter VisualRoot/Presenter, hiding former capsule only. Original
body/bench/props/effect-derived variants/fixed foot/approach remain. E keeps current
recovery graph; ConversationView Chat/Recovery button routes through contained
focus and current snapshot/live-contact/mode gates to source graph or current
counter graph. One cursor/person, original IDs. Source portraits/content/schema7
remain exact; ordinary memory cannot change quests/trust/items/service. Practical
fitting order/cancellation and temporary helper labels remain honest.

[N010 acceptance](villagers-dialogue/N010_ACCEPTANCE.md) records ordinary public
branches/three facts/alternate keyboard route/exact GUI restart, real skin/feet/
holds/travel/retry and regressions. Returned-fitting segment uses explicit legal
prerequisite5; guardian/vessel integration is synthetic. Fresh full all-eight/
recovery/native acceptance stays N017/N018. Idle runtime; walk review-only;
gifts/commerce/routines unavailable.

## N012 named Tess public store contact (2026-10-08 UTC)

Production activates npc-01/npc-02/npc-03/npc-04/npc-06. Tess uses approved store
foot(7.5,0,5)/approach(9,0,5), distinct editable3D skin, current presenter/holds,
exact source graph/six portraits and ordinary independent public memory. Source
role lines stay exact; Tess-only fixed modal says purchases/delivery jobs unavailable.
No commerce/wallet/jobs/items/quest/trust effects, geographic refresh or save field.

[N012 acceptance](villagers-dialogue/N012_ACCEPTANCE.md) records zero-affinity
branches/three facts/revisit/store lane, exact manual new-process GUI restart,
physical/lifecycle regressions and inspected exported identity/loops/weather.
Runtime idle/facing; walk review-only. N013 next eligible, full integrated eight-
person and standalone native acceptance remain N017/N018.


## N013 Ivo public booking-shore contact (2026-10-08 UTC)

NpcRegistry now activates npc-01/npc-02/npc-03/npc-04/npc-06/npc-07. Ivo's
source identity uses approved dry foot(36,0,20)/approach(34.5,0,20), distinct
editable8135-triangle3D skin and existing transient presenter/lifecycle/facing.
Exact ordinary graph/six portraits and public-role/local-seamanship/knotwork
memory remain independently owned. Fixed modal notice makes booking/salvage/
departure unavailability explicit without changing source text. No hull repair,
passage, payout, ship/gate/geometry change, new party member or source migration.
Existing recovery helper stays explicitly temporary. Manual schema7/content1
unchanged; ordinary input/exact separate-process GUI restart and inspected
day/night/rain/exported clips in [N013 acceptance](villagers-dialogue/N013_ACCEPTANCE.md).
Idle/facing runtime; walk review-only. N014 next; all-eight/native gates N017/N018.

## N015 Della public Lantern Rest entry (2026-10-08 UTC)

All eight requested villagers now have fixed public contacts and distinct editable
3D skins. Della/npc-14 uses approved foot(-9,0,3.5)/approach(-9,0,4.5), preserving
indoor source identity lantern-rest:della-inn-host-01/inn-host-01(256,288) as
separate provenance. Exterior location is an explicit prototype adaptation;
future inn portal/door and pinned geometry remain exact and unobstructed.

Source public branches/six portraits/three facts and one introduction receipt
remain independently owned. Fixed notice and disabled room choice explain that
interior, rooms and sleep are unavailable; no records/history, entitlement,
morning event or service/reward is added. Existing presenter/lifecycle owners
retain collision and identity outside VisualRoot. Idle/facing runtime, walk
review-only; manual schema7/content1 unchanged. [N015 acceptance](villagers-dialogue/N015_ACCEPTANCE.md)
records ordinary town-to-inn input, exact separate-process GUI restart, physical
portal-pad checks and inspected day/night/rain/loop art. N016 next eligible;
semantic actions, integrated all-eight route and fresh native delivery remain
N016-N018. Prior release history remains intact.


## N017 integrated all-eight acceptance (2026-10-08 UTC)

Production contacts share the existing root/session/dialogue/save owners. Fresh
ordinary independent introduction branches exercise58 source nodes/38 choices,
21 public facts and remembered reopens; physical woods/gather/main bridge/ford,
Tollworks guardian/vessel and full Maris reconnect remain legal. GUI Save and a
new process GUI Load compare the exact complete typed durable snapshot and
forecast before actual revisits. Per-conversation event snapshots remain inert;
real walking can create new woods events. No duplicate wrapper/quest reward.

NpcWorldAdapter rejects enabled contact construction unless the claimed
Alderwake location has pinned AlderwakeExterior geometry, before mutation.
Compact negative navigation/companion fixtures explicitly opt out of production
contacts; process restore fixtures allow an inert current-room NPC selection at
arrival while retaining zero world input. Those are fixture policies, not new
runtime travel/save behavior. New integration checks/render and strict capture
coverage audit are reusable; selected old production assets/runner unchanged.

[N017 acceptance](villagers-dialogue/N017_ACCEPTANCE.md) records exact source
reuse, required NPC/existing regressions/process pairs,316 inspected captures,
disclosed ABBA idle crowd cost and navigation baseline comparisons. Deferred
capabilities/placement adaptations remain explicit; schema7/content1/manual
Save/Load, fixed geography and temporary companion unchanged. Idle/facing
ordinary; walk and semantic action variants review-only. N018 remains the fresh
Windows/native delivery gate; previous release history stays intact.


## N018 fresh Windows/native delivery (2026-10-08 UTC)

Fresh Windows validation/release export pairs resolve current public NPC graphs,
48 portraits,8 rigs/idle/walk and2 separate semantic review assets. External
pack audit rejects release tests/bridge/private profiles/Flutter/editable art;
strict schema7/content1, Compatibility and pinned geography remain unchanged.
Previous local packages are archived/hash-verified before reversible local
promotion; original release override is preserved, validation has none.

Native inputs run against an exact hashed release copy/cwd outside checkout,
owned PID/foreground/client and unique N018 evidence, with isolated restart and
alternative-introduction slots. Shared guard adds only N018 evidence and bounded
temporary-copy ownership; no runtime bridge/setup feature is introduced.
Ordinary physical controls reach all8, all58 public nodes/38 choices/21 facts and
full shortened Maris recovery. Actual GUI Save/normal quit/new-process Load
matches entire typed snapshot/forecast; all8 remembered revisits preserve old
and new durable fields. Three normal exits and clean runtime logs confirmed.
All720 production files remain identical to accepted pre-export bytes.

[N018 acceptance](villagers-dialogue/N018_ACCEPTANCE.md) records six package
cases, focused/guard tests,4228 native audit assertions,385 captures/34 inspected
sheets, exact hashes, retained failed attempts and cleanup.
[Delivery tooling](../tools/npc_migration/DELIVERY.md) documents reusable external
archive/audit/native/GUI Save/visual review helpers. Idle/facing remains runtime;
walk/fishing/archive-work review-only, gifts/routines/interiors/services/private
campaign deferred. All N001-N018 Done; no successor task.

## G004 authored gifts and once-only milestone (2026-10-08 UTC)

Current production catalog uses the approved social overlay: eight gift rules,
ten choices, eight response nodes and one Edric milestone enabled. Source IDs/text,
portraits/art/contact placements and historical pins stay exact. Three room/routine
nodes, six choices and three undisclosed facts remain deferred. Availability is
67 nodes/48 choices/21 facts; schema7/content1 stays current.

One NpcDialogueService stages accepted gifts through NpcGiftRules and publishes
detached inventory/person/events before observers. NpcDialogueRules.transition
shares endsConversation/milestone/authored-target ordering across gifts and
ordinary responses. Its enter helper records learned facts/seen node and the
Edric milestone flag on actual Begin/Continue/response entry. Helpful introduction
and two gifts reaches affinity3/Acquaintance once; neutral stays affinity2/level0.
Caps use existing itemGifted aggregates, with gift then choice at identical time.
Companion trust, quests, Maris routing and finite supplies keep their own owners.

[G004 acceptance](gifts-friendship-people-journal/G004_ACCEPTANCE.md) records all16
passing engine/parse/rule/modal/Maris/save/restart cases and exact approved
conversion/source protection. Supplied items/events/authoring fixtures remain
synthetic; G005 owns feedback/ordinary gifting UI, G006-G007 People and G008-G009
integrated/native social acceptance. No new package or ordinary-play claim here.

## G005 ordinary gifting and conversation feedback (2026-10-08 UTC)

NpcDialogueService snapshots expose detached authored friendship threshold/label,
derived level, affinity and actual Moonflower bag count. Accepted gift feedback is
transient cursor state, retained through response/milestone and stale rejection;
no new save field or relationship store. ConversationView displays progress or
Reached, bag count and retained feedback with fixed exits and scrolling choices.
GameRoot refreshes bag/HUD only after complete publication and blocks keyboard
echoes before new-node GUI activation. Item help describes authored conversation
gifts after preference disclosure; rod/non-giftable behavior remains intact.

[G005 acceptance](gifts-friendship-people-journal/G005_ACCEPTANCE.md) records
all-eight synthetic rule/UI/rejection/scroll fixtures, ordinary two-flower Edric
gifting/milestone and independent existing companion choice, inspected57 captures
at960x640/1350x900 and affected modal/foraging/bag/Maris/quest/consequence checks.
Source content/pins/geography/art/supply and schema7/content1 are unchanged.
People and fresh integrated social restart/native packages remain G006-G009.

## G006 detached People query (2026-10-08 UTC)

PeopleSnapshot projects the current session's ConversationMemory and validated
NPC catalog into detached public rows. Only persisted enabled node entry makes
a person met; only learned enabled authored fact IDs appear. Rows sort by display
name, facts by category/label, and retain authored pronouns/neutral portrait or
valid fallback, affinity, threshold and derived level-one progress/label.
Unknown/unmet queries fail empty. No cached relationship owner, met/fact store,
save field, entry effect or journal/root UI authority is introduced.

[G006 acceptance](gifts-friendship-people-journal/G006_ACCEPTANCE.md) maps query
independence, mutation isolation, source disclosure boundaries and current/earlier
restore freshness to headless production-service fixtures. Items/events and
boundary authoring remain explicitly synthetic. G007 owns J journal/HUD/modal
integration; G008/G009 retain ordinary integrated restart/native acceptance.

## G007 People journal and root modal (2026-10-08 UTC)

Existing J journal now has Quest & companion / People tabs; HUD People opens that
tab directly. GameRoot supplies fresh detached PeopleSnapshot data. The view owns
only transient selected person, portraits and learned text/progress, with contained
keyboard focus and scrolling list/details. No save field or social command.
Quest/trust/preparation content remains in its original tab.

Opening cancels holds/drag and clears actor/aim controls; root blocks gameplay and
manual Save/Load while unpaused elapsed/environment simulation continues. Modal
gates cover dialogue/backpack/pause/travel/load/retry/focus/death. J/Esc/Close exit;
focus loss/death/retry/unload close safely. Canceled drag's existing trailing-release
suppression remains intact. [G007 acceptance](gifts-friendship-people-journal/G007_ACCEPTANCE.md)
records actual viewport UI/captures960x640/1350x900, synthetic social/long-text/night
fixtures and affected projection/movement/dialogue/bag/foraging/quest/drag checks.
G008/G009 still own ordinary integrated restart and fresh native delivery.

## G008 integrated social and exact restart (2026-10-09 UTC)

[G008 acceptance](gifts-friendship-people-journal/G008_ACCEPTANCE.md) proves ordinary
helpful Edric/two existing flowers/one milestone, third-flower Maris, all-eight
met/public facts/People Tab/Enter, full recovery and independent neutral affinity2.
GUI Save/normal quit/new-process GUI Load and paused re-save match exact typed
durable state/forecast/bytes. Physical revisits preserve gifts/old fields; legitimate
elapsed/woods changes are separate. Synthetic all-eight gates/caps/levels and
gifted-roster focus/retry remain explicitly distinguished from ordinary input.
New fixtures reuse shared owners; only an old NPC test count changes, with no
runtime/content/supply/schema change. G009 alone owns fresh Windows/native proof;
historical packages remain unchanged.

## G009 current local Windows/native delivery (2026-10-09 UTC)

[G009 acceptance](gifts-friendship-people-journal/G009_ACCEPTANCE.md) completes
fresh native social delivery. Canonical release builds/windows and validation
builds/windows-validation replace exact archived prior packages only after six
passing export/pack-audit/outside-checkout-startup cases. Both use Desktop's
tests-excluding filter, with unchanged historical presets/overrides. External
audits check current social policy67/48/21/eight rules, rigs/portraits/actions,
People/save7/geography and source/private/bridge exclusions.

Shared native input admits only matching G009/N018 evidence and direct TEMP copies
with canonical executable/PCK/override hashes, rejecting reparse points; existing
owned PID/window/desktop/focus/client bounds/finally-cleanup controls remain.
Social delivery helpers record isolated launch/normal exits, audit copied GUI
saves/input/capture provenance and create review sheets; they add no game owner.

Ordinary guarded release controls prove helpful Edric/two distinct flowers/one
milestone/met-only People, third-flower Maris/full shortened recovery and exact
new-process GUI restart/re-save/revisit. Independent fresh neutral reaches2 with
no milestone. Read-only packed typed/forecast oracle and inspected204 frames/17
sheets support the data audit. All owned processes/controls/TEMP copy cleaned;
normal saves untouched. All754 accepted G008 game files remain exact bytes;
no runtime/content/save/geography/supply change. This supersedes historical
pre-social package/pending-native boundaries above. G001-G009 Done, no next task.
