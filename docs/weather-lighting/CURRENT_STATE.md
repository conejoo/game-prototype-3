# Current weather and lighting state

Updated 2026-10-04. W001-W003 Done; W004-W010 Pending. No active/blocked W task.
Completed: W003 versioned environment save compatibility. Next eligible: W004.
Read CHECKLIST, CONTRACT, AGENT_PROMPT and [W003 acceptance](W003_ACCEPTANCE.md).

Production schema5/content1 retains exact day/progress/uint32 seed and validated
map-qualified light overrides. Node-independent LightSourceRegistry owns all23
pinned identities/effective defaults; only six switchable lanterns accept boolean
overrides. Automatic windows/net/waylights remain defaults. Duplicate/unknown/
non-switchable tuples, invalid fields/types/ranges and newer envelopes fail.

V1-v4 exact migration preserves all prior facts and elapsed time separately,
adds day0/progress0/fixed seed1821285621/no overrides. V1-v3 receive neutral
consequences; v4 keeps trust/reactions/upgrades. Only fresh initialization chooses
seed; load supplies validated environment before candidate publication. Read and
backup recovery never rewrite files. Physical restore rejection keeps previous
environment/session/world/party/nav/input state. Manual Save/arrival-anchor Load
remain product behavior; no new presenter, timer, automatic save or E action.

SaveRepository uses full-precision primary/backup JSON. Actual installed reader
rounded the double below1 to1; SaveNumber repairs only timer numeric lexemes with
bounded decimal-to-binary64 ties-even conversion. CONTRACT documents token1100/
exponent-spelling5 limits, version-protection ordering, independent vectors and
observed failures. Supported save shape/day bounds unchanged; cursors unsaved.

W003 changed files:

- game/core/save_codec.gd, save_repository.gd, save_number.gd/.gd.uid
- game/app/game_session.gd, game_root.gd
- game/features/environment/environment_state.gd, light_source_registry.gd/.gd.uid
- game/tests/environment_save_checks.gd/.gd.uid
- game/tests/save_checks.gd, save_process_checks.gd, map_save_checks.gd
- game/tests/companion_checks.gd, consequence_checks.gd, quest_checks.gd
- game/tests/fixtures/environment_light_registry.json, environment_save_v5.json,
  environment_save_numbers.json
- docs/weather-lighting/CHECKLIST.md, CURRENT_STATE.md, CONTRACT.md, W003_ACCEPTANCE.md
- docs/ARCHITECTURE.md, docs/CURRENT_STATE.md, README.md

W002 edits/untracked artifacts were already present at selection, including rules,
rule/session tests/vector fixture and W002_ACCEPTANCE. Preserved; no commits/reset/
source generators/subagents/installation or next task. Existing historical fixture
bytes/provenance and pinned map remain unchanged.

Verification: retained reference/hash audit, Godot import, environment codec517
assertions (305 independent bit vectors), environment rules12,792 assertions,
session gates, application/save/quest/consequence/companion regressions, separate
writer PID28244/reader PID18380, map fixtures5/replacements24/rejections5/retries5.
All final checks exit0; runtime scans clean except exactly one expected map retry
diagnostic (`M009 expected navigation bake rejection`). Import retains only known
missing .NET SDK10.0.9 diagnostic. Final codec PID38484. No new render/frame benchmark.
Links/statuses/registry/fixtures/diff check pass. Commands and criteria in acceptance.

Save isolation: process-local APPDATA=`builds/weather-lighting/W003/appdata` and
LOCALAPPDATA=`builds/weather-lighting/W003/localappdata` beneath repository root.
Confirmed Godot/app_userdata/Returning Fair — Prototype beneath APPDATA. Explicit
w003 debug slots; code-created p005/m017/w003 test slots all stay there. Process
test uses saves/playtest-w003-process.json. Normal saves untouched. Raw logs and
map report stay ignored at docs/evidence/W003/run-20261004-01; initial precision,
signed-zero/type comparisons and sandbox diagnostics retained. All test processes
exited; no held input, GUI/editor change or live game remains from W003.

Remaining: no unresolved W003 criterion. Sun/WorldEnvironment remain fixed.
Rendering/light consumers/E key/rain/HUD/performance/native exports belong to
W004-W010. Current schema4 Windows packages remain historical; rebuild later.
Next safe action: select W004, inspect lighting composition/location definitions,
verify W003 prerequisites and add moving sun/explicit outdoor-indoor profiles.
Keep GL Compatibility, source snapshot alderwake-f4630f9-m002, authored geography,
W001 registry/defaults, eight pooled unshadowed emitters as future W005 scope.
Historical P001-P014/M001-M019 baselines and local archives preserved.
