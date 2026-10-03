# Local live playtest tools

The debug game can accept bounded input commands from a local directory. This
lets an agent hold W for 100 ms, combine keys, click UI, observe state and capture
the rendered viewport. Normal gameplay services and input gates remain active.

## Start and send

PowerShell 7 from the prototype root:

```powershell
$godotExe = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
$gamePath = 'D:/development/game-dev-blender/returning-fair-prototype/game'
$sessionDir = 'D:/development/game-dev-blender/returning-fair-prototype/builds/playtest/manual'
& $godotExe --path $gamePath -- --playtest-dir=$sessionDir
# In a separate shell/tool call while the game runs:
./tools/send_playtest.ps1 -SessionDir $sessionDir -CommandFile ./docs/evidence/P003/live-camera-command.json
```

Write a command JSON file and supply its path. Example:

```json
{"steps":[
  {"op":"hold","keys":["W","D"],"duration_ms":100},
  {"op":"pointer","x":650,"y":340},
  {"op":"capture"},
  {"op":"observe"}
]}
```

The client reads ready.json, adds a fresh request/boot ID, atomically publishes
request.json and waits for an atomic response. It prints a compact summary and
response path; use -FullResponse for all observations. Captures and responses
remain in the ignored session directory. Use a fresh directory for each run.

## Commands

| Operation | Fields | Behavior |
| --- | --- | --- |
| hold | keys, duration_ms | Press chord, keep held for requested time, release |
| key_down / key_up | keys | Sequence a hold across steps within one request |
| wait | duration_ms | Let normal gameplay/rendering advance, including pause UI |
| pointer | x, y | Send viewport mouse motion |
| click | x, y | Left mouse down/up through normal GUI/game input |
| mouse_down / mouse_up | x, y | Sequence a mouse press across steps |
| observe | none | Record player/camera/aim/pause/UI state |
| capture | none | Save actual viewport PNG; requires windowed renderer |
| quit | none | Last step only; publish response, then normal F10 quit |

Keys: W, A, S, D, E, J, P, SPACE, R, ESC, TAB, ENTER, +, -. Coordinates use viewport pixels
(current prototype captures are 960x640), not desktop coordinates. Holds/waits
are 16–5000 ms, up to 32 steps/30 seconds per request. Monotonic deadlines never
release early; scheduling and physics quantization can extend observed duration.
Responses report elapsed time, positions, contacts, headings, UI focus and PNGs.
P004 observations also report location/spawn IDs, transition count/lock, actor
object identity, health, room/party counts and party suspension. E uses the
normal nearby travel-gate action; no direct transition command exists.
P005 adds read-only save status/path, loading lock and ordered party observations.
Save/Load uses ordinary pause-menu click or Tab/Enter input. Debug-only
`--save-slot=p005-validation` selects `user://saves/playtest-p005-validation.json`
so validation cannot overwrite the normal slot. Names accept 1–48 ASCII letters,
digits, underscore or hyphen; release builds ignore this option. No direct
save/load or session-mutation bridge command is added.

P006 adds read-only selected interaction ID/prompt and dialogue definition,
source-instance ID, text, selected choice and explicit result/action ID. E reaches
NPC/prop/gate through normal range/line-of-sight selection. Choose with mouse or
Tab/Enter; Esc cancels dialogue before pause. The bridge adds no dialogue command
or persistent-state mutation. P008 replaces configured attack input with real
combat; modal checks now verify blocking and fresh attacks after cancellation.

P007 adds read-only quest completion/effect IDs, journal visibility/text and HUD
objective. J operates the normal journal modal. No quest command exists in the
bridge. P008 removes the previous P007 `--quest-test-fixtures` simulated interaction.
Use an isolated `--save-slot` for validation.

P008 adds read-only attack timer, dodge timer, guardian health/position/screen
coordinates/action/hit IDs and player screen coordinates. Click attacks; SPACE
dodges; R retries only after death. The same normal input gates apply. No damage,
health, defeat, retry-service or quest mutation command exists in the bridge.

All held keys/buttons release at request end. key_down does not persist between
requests. Movement may be ignored while paused, UI-focused or after application
focus loss; inspect controls_enabled and ui_focus instead of forcing game state.
Do not send concurrent requests or mix human input during a timed sequence.

P009 adds read-only companion health/position/screen, mode, swing contacts,
path/repath/catch-up/recovery counters, wrapper identity and enabled state, plus
actual window focus/retry lock. Companion acts autonomously through normal AI.
There is still no teleport, AI control, health or quest mutation command. Inspect
`window_focused` when injected input is ignored; restore actual desktop focus
instead of bypassing the game's focus gate.

The bridge is created only by an explicit --playtest-dir flag in debug builds,
under this project's builds/playtest. It has no network listener or arbitrary
code/path execution. Invalid/stale commands cannot execute input; duplicate
request IDs do not replay. Normal runs have no bridge. No teleport, objective,
reward, relationship or save commands exist.

Injected viewport input proves gameplay/GUI integration and rendered behavior;
it does not verify OS/hardware keyboard or window focus. Test those separately.
A rendered capture is not a Windows export test or a quest completion shortcut.

P010 adds read-only relationship/progression snapshots, derived hero damage,
unspent preparation points and upgrade-button screen coordinates. Select with
normal J journal/GUI input; reactions use ordinary NPC dialogue choices. No
relationship, point, upgrade or objective mutation command exists.

P011 adds read-only counter presentation/sign/gear visibility, dialogue line index,
Continue and choice-button screen coordinates. Return/fitting/service commands
still use ordinary E/GUI input; no quest or shop mutation path was added.

P013 normal rooms hide practice markers/test beacons. Explicit debug-only
`--developer-fixtures` retains those reusable test props; it grants no progress.
The purple station remains labeled prototype dialogue for the active ally.
Full slice evidence uses only `--playtest-dir` and isolated `--save-slot`, without
developer fixtures or any state setup. Normal no-flag startup has no bridge.
