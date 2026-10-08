# N001 acceptance — pinned public references and measured contacts

Completed 2026-10-07, America/Vancouver. N001 only. No NPC activation, new save field,
3D asset or new release. [Checklist](CHECKLIST.md) owns status; [contract](CONTRACT.md)
owns future implementation rules.

## Criterion evidence

| N001 criterion | Verified result |
| --- | --- |
| Fixed eight IDs and exact source identity | Source HEAD `60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean before/after. Selected catalog preserves exactly npc-01/02/03/04/06/07/08/14 from 15 records. No source drift. |
| Public inputs pinned locally | [Manifest](../../tools/npc_migration/reference/manifest.json): 132 source inputs with path/revision/SHA256; 90 exact copies: 24 JSON, 48 portraits, 18 sheets. Other authority files are hashed, not copied. No private profiles or Flutter files copied. |
| All nodes, choices, facts, conditions, outcomes and art classified | [Coverage table](../../tools/npc_migration/reference/COVERAGE.md), [full fields](../../tools/npc_migration/reference/coverage.json): 70 nodes, 54 choices, 24 facts, 30 condition fields, 8 gift rules, 48 portraits, 18 sheets. 58 nodes/38 choices/21 facts enabled; 12 nodes/16 choices/3 facts deferred. Five outcome tags remain inside deferred Helena choices; all authored fields/text retained. |
| Source rules traceable | Resolver/condition/receipt/affinity/entry/event semantics below, tied to source file hashes in manifest. No source runtime execution claim. |
| Eight source/target contact policies measured | [Contact registry](../../tools/npc_migration/reference/contact_registry.json) and selected [source context](../../tools/npc_migration/reference/placement_context.json). Actor and approach full support, conservative capsules, paths with all future reservations, LOS/range/occupancy pass. Della interior foot never transformed. |
| Tooling/baseline/version dependencies confirmed | Godot console/editor paths exist; console reports `4.7.2.stable.mono.official.ed1daf0bf`; target Compatibility/schema6/content1/21 definitions. Current F010 artifacts inspected. Blender read-only connection succeeds; animation rig/export still N007 acceptance. |
| Prior work/source/geometry preserved | [Production baseline](../../tools/npc_migration/reference/target_baseline.json): all 462 game/art files remain exact, no additions/removals; P/M/W/F files unchanged. Initial target changes were README.md and untracked workflow docs; retained. Source clean; normal saves untouched. |
| Handoff/checklist/links coherent | N001 Done only, N002 next eligible; N003-N018 remain Pending. Final bootstrap/link/status/diff audit recorded in task evidence. |

## Pinned semantics and deliberate target boundaries

Source references below are source-root paths. Their exact byte hashes and revision
are in manifest; no future runtime consumer needs that checkout.

- `lib/game/dialogue/dialogue_repository.dart:7-40`: ordinary resolver filters graph
  entry IDs and same NPC, tests conjunctive conditions, sorts priority descending
  then node ID ascending. Entry list order is preserved as data but does not resolve
  an ordinary equal-priority tie. `runtime_game_controller.dart:286-317` instead
  tries distinct preferred routine entry IDs in supplied order before fallback.
  This preferred entry facility remains deferred, especially both Helena archive nodes.
- `dialogue_model.dart:32-53`: all flag/fact/seen/affinity/level/event tests combine
  with AND. Required sets must all be present; any excluded/unknown/unseen member
  present rejects. Affinity minima/maxima are inclusive. Defaults are empty sets,
  level0 and no affinity bounds. Event default minimum is1; optional maximum is inclusive.
- `dialogue_model.dart:143-180`: one-time means `oneTime` OR nonempty reward flag.
  Applied choice ID OR existing reward flag suppresses the entire repeated effect,
  including added flags. Accepted new effect adds authored flags/reward receipt and
  the stable choice ID. Non-once questions can repeat without an affinity reward.
  Each introduction offers one +1 and one0 response; both add the same completed
  introduction flag. Reopening then selects return, so alternatives cannot both
  award. Contract additionally rejects stale/wrong-speaker/deferred commands; the
  source helper itself accepts a supplied node and is not a sufficient command guard.
- `runtime_game_state.dart:314-351`: level is0 below authored threshold3 and1 at/above3;
  signed deltas clamp affinity to `[0,2147483647]`. Only Edric declares a level-one
  milestone. `runtime_game_controller.dart:567-627,963-1025`: node entry unions seen
  node and authored revealed facts; milestone entry sets its seen flag. A level
  increase can replace the authored choice target with milestone, unless the choice
  ends conversation. Explicit target/Continue lookup stays within the speaker graph.
- `dialogue_choice_eligibility.dart:43-91`: source gifts check conditions, rule,
  giftable item, quantity, required fact, then itemGifted count for item/NPC against
  acceptanceCap. All eight pinned rules have Moonflower/+1/cap2 and an authored
  preference/hobby fact gate. Target gifts remain unavailable regardless of ownership;
  no item consumption, affinity or gifted event. Introduction alone never reaches
  Edric threshold3. Keep milestone intact/deferred; do not lower threshold or seed gifts.
- `player_event_journal.dart:63-177`: aggregate exact `(kind,subjectId,targetId)`
  keys; null subject/target is an exact key component, not a wildcard. Record increments
  count/global sequence and preserves first occurrence, replacing last occurrence.
  Event count defaults to0. Time window checks latest timestamp with inclusive
  `now-last<=window`; missing timestamp fails a window. No selected graph authors a
  time window. Source journal itself has no explicit maximum unique-key/count/sequence
  cap despite its size-bounded comment. Target key domain must be bounded to selected
  supported events; N003/N004 must document strict numeric persistence bounds rather
  than pretending source provides them. Historical null timestamps must never be invented.
- `runtime_game_controller.dart:370-408,770-803,824,925,952,1146-1153`: successful
  collection records source resource definition subject; failed/full/already-collected
  commands do not. Entering union of woods-role zones is one outside-to-inside edge,
  with inclusive rectangles, no per-frame repetition. Movement/load rebinding updates
  transient woods membership without a fabricated event. For target pinned map,
  woods union is Moonwood `[25,-18,100,80]`; nested danger pocket adds no second entry.
- Choice selection events use `(dialogueChoiceSelected,npcId,choiceId)` at session
  active time. Enabled committed collection maps target `resource-moonflower` /
  `item-moonflower` and moonflower-01/02/03 to source subject `moonflower`, null target.
  Woods events use `(areaEntered,woods,null)`. Source fishing_rod pickup events have no
  selected graph consumer and need no persisted target aggregate. Gift events deferred.
  Loading a schema6 bag/collected list does not prove any past event or sequence.

Selected finite graphs have no cycles and no authored Continue edges. Terminal
nodes close; any node with all optional choices deferred needs an always-valid Close
(or appropriate Continue-to-close) without applying an unselected effect. Classification
means future capability eligibility, not already installed conversations.

Declared facts `npc-01-public-role` and `npc-01-river-fishing` have no authored
revealing node. Preserve definitions but do not auto-disclose them from labels, art
or conversation entry. `npc-02-archive-practice` is revealed only by deferred
`npc-02-routine-archive-default`. N009 must assert it stays unknown in ordinary
public contact; the source provides no enabled ordinary disclosure. Its "only through
source-sanctioned enabled disclosure" criterion does not authorize inventing one.

Della keeps source `lantern-rest:della-inn-host-01` / `inn-host-01` `(256,288)` and
player `inn-meal-player-01` `(192,288)` as indoor provenance. Target contact is a
public exterior adaptation beside current entry. [Adaptations](../../tools/npc_migration/reference/adaptations.json)
specifies exactly one replacement welcome text; original bytes remain pinned.
`npc-14-ask-room`/`npc-14-room` stay deferred because indoor left/right directions
are not valid at exterior contact. Explain unavailable interior; no room/sleep grant.
Other selected public supply/repair/fair-boat lines describe source roles, with no
purchases, service entitlement, delivery work, boat ride or chapter effects.

## Contact measurements

All target feet/approaches below use current Godot physical Y=0, location
`prototype-alderwake`. Probe capsule radius0.4m/height1.6m conservatively exceeds
current hero radius0.35m. Each foot has nine dry level support rays; every route is
sampled at <=0.1m. Seven new0.8m-square reservations plus existing Maris body/bench
are included in a task-only navigation rebake. No production scene was edited.
N006 must supply equivalent scene-owned reservations and revalidate; named-character
art or changed footprints must be checked again by owning tasks.

| NPC | Canonical source actor/anchor feet | Target NPC foot (X,Y,Z)m | Player approach (X,Y,Z)m | Route length / samples |
| --- | --- | --- | --- | --- |
| Edric | placement npc-01 `(704,528)`; public routine edric-town-square `(688,528)` | `(-0.5,0,-1.5)` | `(-0.5,0,-0.5)` | 0.707m /10 |
| Helena | helena-town-square `(752,528)`; no direct npc-02 outdoor object | `(1.5,0,-1.5)` | `(2.5,0,-1.5)` | 3.270m /43 |
| Maris | maris-chandlery-01 / maris-fitting-01 `(464,928)` | `(-7.5,0,11)` | `(-6,0,11)` | 13.319m /175 |
| Harlan | harlan-dockmaster-01 / harlan-sluice-practice-01 `(2016,1120)` | `(41,0,17)` | `(42.5,0,17)` | 56.909m /710 |
| Tess | tess-store-01 / store-service-tess-01 `(944,736)` | `(7.5,0,5)` | `(9,0,5)` | 12.479m /158 |
| Ivo | ivo-passenger-dock-01 / passenger-booking-ivo-01 `(1856,1216)` | `(36,0,20)` | `(34.5,0,20)` | 46.769m /587 |
| Celia | celia-basic-repairs-actor-01 / celia-basic-repairs-01 `(592,960)` | `(-3.5,0,12)` | `(-3.5,0,13)` | 14.799m /197 |
| Della | indoor della-inn-host-01 / inn-host-01 `(256,288)` | `(-9,0,3.5)` public adaptation | `(-9,0,4.5)` | 10.375m /128 |

Each exact approach snaps only0.05m vertically to navigation and has clear LOS and
range1.0-1.5m. Edric's nearest existing competitor is temporary companion1.581m
versus Edric1m; Maris selects existing npc-03-counter at1.5m. No competing lamp,
resource, portal or another NPC wins at the measured feet. Maris retains existing
body/bench/interaction identity; it needs no duplicate wrapper.

Tess/Ivo/Celia newer source actor placements are absent from pinned geographic
snapshot, while their anchors already exist. New local wrappers may reuse these
anchors without refreshing map bytes. Harlan/civic contact feet already pinned.
Della footprint lies west of inn portal rectangle `[-8,3.5,2,1.5]`, with0.6m between
its envelope edge and portal's west edge. Her approach/route leaves door/portal
clear. In-memory reserved navigation keeps normal spawn usable and all contacts
reachable. Water negatives `(35,0,25)` and `(41,0,24)` and inn wall `(-7,0,2)` reject.

## Visual inventory and tooling limits

All48 approved PNGs decode, retain source alpha/pixels/hashes and measure512x512.
All18 motion references decode with192x192 cells; idle/action768x768, walk576x768,
south/north/west/east rows. Viewed
`docs/evidence/N001/20261007-reference/portrait-inventory.png` at full inventory scale:
eight distinct people, six expressions/role portraits each; no missing or mixed row.
Edric blue civic coat/chain versus fishing outfit; Helena green vest/cream blouse;
Maris ochre work apron; Harlan teal vest/red scarf; Tess green/terracotta apron;
Ivo yellow shirt/navy vest; Celia red shirt/ochre work apron/braid; Della grey curls,
plum dress/olive shawl/quilt. Canon ages52/50/46/48/41/39/37/58 remain public design
context; no household relationships/private histories added as learned facts.

Only Edric river-fishing and Helena archive-work have authored action sheets.
Ropework/birdwatching/flower-pressing/knotwork/woodcarving/quilting portraits do not
create world action clips. N016's archive action can remain review-only because
ordinary public civic site supplies no archive workstation/routine consumer.

Read-only Blender MCP `get_scene_info(user_prompt=...)` succeeds: existing
RF-RecoveryVessel,21 objects/14 materials, unchanged. First call omitted required
user_prompt and failed tool schema validation; corrected call passes. Existing Blender
executable/analysis runtime paths exist. Static P012 pipeline explicitly disables
rig/animation export, so connection success does not certify N007's new pipeline.
No missing connection blocker; rig/action/export/import proofs remain future gates.

## Commands, isolation and failures

Cwd for target commands: `D:/development/game-dev-blender/returning-fair-prototype`.
Python: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Godot console path as in contract. Source commands use `D:/development/game-prototype-2`.

```powershell
& $python tools/npc_migration/pin_reference.py --source D:/development/game-prototype-2
& $godot --headless --path game --log-file "$run/placement-attempt-4.log" --script "$root/tools/npc_migration/measure_contacts.gd" -- "$run/placement-attempt-4.json"
& $python tools/npc_migration/npc_reference_checks.py --source D:/development/game-prototype-2 --geometry docs/evidence/N001/20261007-reference/placement-attempt-4.json
git diff --check
```

`$root` is target root, `$run` is its `docs/evidence/N001/20261007-reference`.
APPDATA/LOCALAPPDATA exclusively use `builds/testing/N001/20261007-reference/{appdata,localappdata}`.
No Save/Load or input was sent. Final geometry exit0,8 contacts/2,008 path samples,
three negatives,21 current definitions; all assertions pass and log has no runtime,
parse, script or resource diagnostics. Probe processes exited; no editor launched.
`--source` checker verifies132 current source hashes against immutable manifest;
without it, target-local checks need no source checkout. Final checker exit0.

Retained unsuccessful attempts1-3 in same evidence directory. Attempt1 paused a
newly rebuilt region before binding/synchronization; attempt2 changed timing only;
attempt3 bound region but did not wait its asynchronous iteration. Attempt4 uses
existing WorldHost synchronization barrier and passes. Attempt1 also found conservative
Maris approach `(-6,0,11.5)` touching bench; corrected northward to `(-6,0,11)`.
No normal route defect inferred from the failed synchronization fixtures.
Initial Python-on-PATH probe failed; bundled runtime used. Initial pin stopped at
Git target ownership protection; command-local exact safe.directory override repaired
it without global config change. Failed partial pin had no manifest and was completed
before sealing; pin now refuses replacement.

Historical F010 `20261008-033128476-26d025f5/results.json` inspected: all9 cases passed,
exit0; source drift false. F009/F010 acceptance/current state and map/architecture
artifacts supply prior delivered P/M/W/F capability evidence. Current production
baseline checker proves all462 game/art files unchanged. No unrelated suites rerun,
no ordinary eight-contact gameplay, no new art/import/native package acceptance claimed.

Next eligible: **N002 — typed NPC/graph definitions and strict conversion**. Use pinned
source packages, explicit deferred rows/adaptation and existing npc-03 actor. N001
reference files under tools are not runtime content yet. Stop here.

## Commit preparation

README discovery status synchronized to N001 Done/N002 next. Scoped
`tools/npc_migration/.gitattributes` preserves reference/** exact bytes, including
original CRLF, and treats those carriage returns as valid line endings for whitespace
checks. One generated COVERAGE.md extra EOF blank removed and its manifest hash
updated; no source snapshot bytes changed. Reference/source/geometry checker passes
again. All99 manifest-covered staged blobs match their SHA256 values exactly;
111 staged paths are limited to README, workflow docs and npc_migration tooling/
references. Staged diff whitespace check passes. Ignored raw evidence/builds excluded.
