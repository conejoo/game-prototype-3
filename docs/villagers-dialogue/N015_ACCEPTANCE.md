# N015 - Della public Lantern Rest entry acceptance

N015 completes Della Pike/npc-14 with an ordinary public conversation, six exact
source portraits, distinct editable 3D art and independently remembered public
facts. N008/N006/N007 actual packages, placement/presenter/rig contracts and
N014 integration evidence were inspected before selection. Target began clean
at `c18ef206c999fa632e29540a56e6cc60988f42ef`; source remains clean/pinned at
`60c20eb2816e7271fb84afaba286af006ebe3ccf`. No unrelated changes existed.

## Implementation and placement

Source `lantern-rest:della-inn-host-01`, anchor `inn-host-01`, indoor foot
`(256,288)` source units, maps by an explicit public exterior adaptation to
target `(-9,0,3.5)`, approach `(-9,0,4.5)`, stable instance
`alderwake-npc-14-contact`. Interior coordinates are never transformed into town
coordinates. The future inn portal remains inert at `Rect2(-8,3.5,2,1.5)`.
Della's full capsule rectangle `Rect2(-9.4,3.1,.8,.8)` does not intersect it.
Nine supported full player footprints across the pad, navigation samples every
0.25m and an ordinary round trip to `(-7,0,4.25)` prove clearance.

NpcRegistry now activates exactly the requested eight. NpcWorldAdapter adds
Della's source prompt. ConversationView adds a fixed Della-only notice:
`Public entrance adaptation. Inn interior, rooms and sleep unavailable.`
Bundled graph/portraits retain exact pinned bytes, including N001's audited
public entrance welcome. No other villager, source catalog, geographic asset,
portal, save format, recovery service, ship stage or game authority changed.
Manual schema7/content1 and existing companion role remain intact.

[Della package](../../art/exports/NPC_14_PACKAGE.md) records actual interfaces,
source mapping, custom authoring/normalization/audit scripts and exposure policy.

## Every selected criterion

| Criterion | Verified evidence |
| --- | --- |
| Fresh ordinary contact, introduction, follow-up, exit/reopen | Writer starts at real root arrival and uses shared TestRunJourney WASD, E and actual pointer/wheel input to reach Della, select introduction and four return branches, exit/reopen and traverse the inn lane. No teleport or branch seeding. |
| Exclusive remembered introductions and no replay | Fresh writer careful+1 versus separate neutral passing+0; one receipt each, stale opposite command rejected without mutation. Shared rules pass977 assertions over58 enabled nodes/38 choices, including all8 enabled Della nodes/6 choices. Public branches remain available at level0. |
| Permitted public facts and portrait identity | Innkeeper, quiet-company and quilting disclosed only by authored node entry; visible ordinary fact scrolling and remembered reader revisit. Six source portraits retain exact pixels; shared UI suite passes384 assertions/48 portraits/eight people. No records, private history or family disclosure added. |
| Room/gift boundaries and placement labeling | Source welcome and fixed notice explicitly describe exterior adaptation. Disabled room choice displays interior-unavailable reason; ordinary pointer click is inert. Synthetic room/gift commands also reject before mutation. No room directions, entitlement, sleep, home ownership or mandatory morning event. |
| Safe source/target mapping, door/portal and town route | Owning placement report records both source indoor coordinates and adapted target feet separately. All eight full actor/player support/navigation/LOS checks pass. Capsule excludes exact future pad; nine pad samples and sampled lane pass. Writer physically walks across pad and returns. Geography/portal bytes remain unchanged. |
| Distinct editable/source-informed art | Age58, full mature face, silver swept waves/bun/wisps, plum gathered gown/sleeves, cream apron/ties, olive fringed shawl/brass brooch and brown boots. Custom mesh geometry, not a recolored calibration. Source/mainfile and raw GLB audits pass; actual front/back/profile/face and source portrait/sheet inspected. Hidden depth/anatomy are stylized adaptations. |
| Scale, feet, idle/walk/facing, transitions and weather | Skin sampled at120Hz with481 idle/98 walk poses,196 stance and120 blend samples. Soles0/seams0, stance drift2.384185791015625e-7m at0.8m/s; blend max vertex step0.019758066162467003m. Continuous gown/apron repair removes first waist/center gaps. Godot day/night loops/blends and production default-distance/day/night/real-rain captures inspected. Idle/facing runtime; walk review-only. |
| One noncombatant and lifecycle | One wrapper/presenter for each of eight after travel/return/retry; removed presenter weak reference expires. Actual pause/focus/dialogue freeze/resume and player-facing checks pass. Party/session actors stay two. Existing rollback, interaction/quest/foraging/light/travel/map checks pass. |
| No ordinary reward/service or cross-person effect | Before/after ordinary dialogue compares complete inventory, resources, placements, quests/effects, relationship/trust, progression, actors, party and light overrides. Other seven memories remain empty. Room/gift rejection changes no memory. No inn service, item, quest/trust reward or restored recovery capability. |
| Manual exact persistence and separate-process restart | WriterPID26040 GUI Save; readerPID11492 GUI Load in a fresh process, strict typed disk validation and TestRunSnapshot exact whole durable-state/full-precision forecast oracle. Reader physically returns and browses all three facts once. NeutralPID56120 uses separate fresh memory. Synthetic process pair is distinct from this ordinary proof. |

## Commands, isolation and results

All commands use PowerShell7 from
`D:/development/game-dev-blender/returning-fair-prototype`. Installed console
Godot4.7.2 Mono/Compatibility was verified before execution. Shared runner uses
fresh per-case/group APPDATA/LOCALAPPDATA and named slots under
`builds/testing/N015/<run>/`; render writer/reader share only their explicit
group. Normal user saves were never accessed. Exact args/cwd/PIDs/exits,
isolation, diagnostics and source manifests remain in schema2 results.

Final expanded command:

```powershell
./tools/run_checks.ps1 -Task N015 -Import -Names npc_14_checks,npc_01_checks,npc_02_checks,npc_03_checks,npc_04_checks,npc_06_checks,npc_07_checks,npc_08_checks,npc_content_checks,npc_dialogue_rule_checks,npc_save_checks,npc_world_checks,npc_asset_pipeline_checks,npc_dialogue_ui_checks,interaction_dialogue_checks,quest_checks,foraging_interaction_checks,light_interaction_checks,location_travel_checks,map_activation_checks,map_navigation_checks,application_smoke -ProcessScripts npc_process_checks -RenderScript npc_14_render -RenderPhases review,write,read,neutral -TimeoutSeconds 180
```

Final `docs/evidence/N015/20261008-152625206-824099f7/`: all31 cases PASS,
exit0, zero forbidden runtime diagnostics/timeouts/source changes. Import retains
the runner's preexisting narrowly allowed `.NET Sdk not found...10.0.9`
diagnostic; no C# compilation claim. Runtime/tool source remains859 files,
SHA256 `d0e8792fefb07abb3d22007433637207de72bc1663c97f45d8aa9a59f062844c`.
Owning skin/world suite passes760 assertions; four rendered phases total212
assertions including evidence writes. Writer/read/neutral are ordinary input;
studio/seeded weather and independent service process pair are synthetic.

All75 final captures viewed in seven `render/inspected-sheets/sheet-01..07.png`
plus full-size source/face/profile/front/walk/rain/night/introduction/room/facts
views. All50 strict pause/dialogue provenance records validate via shared
`tools/capture_evidence.py` logic; report
`render/derived/20261008-153133-4b466196/capture-report.json`.
Portrait/body/choices/facts/notice/exits fit960x640; actual wheel input exposes
later branches and disabled room/gift choices. Captures and failed runs remain
ignored local evidence under existing policy.

Read-only source/conversion command passes all132 authority hashes/67 outputs:

```powershell
& 'C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe' tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
```

Existing text-to-blender fallback MCP client authored only owned Della scenes;
original RF-RecoveryVessel scene/file and other villagers were preserved. Scoped
background normalization precedes these successful audits:

```powershell
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background art/source/npc-14.blend --python-exit-code 1 --python art/source/check_npc_14_source.py
& 'C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe' art/source/audit_npc_14.py --output docs/evidence/N015/20261008-152625206-824099f7/raw-glb.json
```

Read-only editable audit passes three identity objects/16 bones/packed image/
baked idle+walk/zero drivers or constraints. Sandbox emits denied Blender
preference-read warning; no preference change or source save by audit. Raw GLB
has8720 triangles/4599 authored vertices,351080 bytes, one embedded32x32 palette,
48 channels per clip, endpoint errors0 and no external URI/camera/light.
GLB SHA256 `4e653fe86145af59c560435ca56b4d9e749f972308d3de674ec761eb2b6a8967`;
.blend SHA256 `990651b751310c35f25a697a108401e0fc5542b454dc8f8fd4b4b45695e55bec`.

## Retained attempts and final limits

- `152208287-8ecd0f61`: shared runner failed `Access denied` during read-only
  child-process inspection inside sandbox. Required authorized escalated runner
  execution; no guard or source change to bypass it.
- `152252760-0178af53`: import exited0 but runner correctly invalidated evidence
  when it generated Della palette/import metadata. Stable rerun required.
- `152329623-f711df3d`: skin/pipeline/startup/review passed; writer failed later
  choice clicks because buttons needed real scrolling. Owning fixture repaired.
  Visual inspection also found waist/center cloth gaps; first art retained in
  `art-before-refine/` and owned `RF-Npc14-Della-before-refine`. Builder copy
  retained under task preflight. Production graph/identity stayed exact.

Final diff/link/source/hash/process audit retained. All owned engine/helper
processes exited; original Blender scene/file remains active. No remaining
N015 criterion, blocker, cleanup, normal-save access, commit/push, successor
implementation, agent/chat/schedule or publication. Exactly N015 completed.
N016 next eligible; N016,N017,N018 remain unfinished. All through N018 incomplete.
