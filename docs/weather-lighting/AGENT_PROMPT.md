# Weather and interactive lighting fresh agent prompt

Use the same short prompt for every fresh chat. Repository documents supply all memory. The agent selects and completes exactly one eligible W task, then updates the handoff.

## Prompt to paste

```text
Follow D:/development/game-dev-blender/returning-fair-prototype/docs/weather-lighting/AGENT_PROMPT.md.
Read and follow its full preparation, selection, implementation and handoff rules.
Resume unfinished weather-lighting work first; otherwise implement the lowest-numbered
Pending W task whose dependencies are verified Done. Work on exactly one task.
Verify every acceptance criterion and update CHECKLIST.md and CURRENT_STATE.md before
finishing. Do not stop at a plan, do not start the next task, and preserve existing work.
```

## Full instructions for the executing agent

You are implementing the approved weather and interactive lighting feature in the existing Returning Fair Godot 3D project. You start with no chat memory. Treat the files below as your context; inspect actual source and current state before changing anything. The user's reuse of this prompt authorizes the selected task's implementation and necessary verification within its scope.

### Preparation

1. Read `D:/development/game-dev-blender/AGENTS.md` and any applicable nested AGENTS for files you will edit. Follow the caveman response preference unless the user changes it.
2. Work from `D:/development/game-dev-blender/returning-fair-prototype`, the actual Git repository. Godot `--path` is its `game/` directory; the parent workspace and engine installation are not Godot projects.
3. Read `docs/weather-lighting/CHECKLIST.md`, `CURRENT_STATE.md`, and `CONTRACT.md` completely. This prompt is the fourth workflow document.
4. Read `docs/ARCHITECTURE.md`, `docs/CURRENT_STATE.md`, `docs/map-migration/CURRENT_STATE.md` and relevant map CONTRACT/reference manifest. P/M workflows are historical baselines; never invoke their prompts to select work instead of W tasks.
5. Inspect Git status, relevant current code/assets, applicable tool docs and any editor/Blender state needed for the task. Preserve existing modifications, saves and live user work. An initially dirty tree is not permission to reset or include unrelated files.
6. Use current evidence to verify prerequisites. The initial baseline records P001-P014 and M001-M019 complete, but that does not certify weather. Source is read-only at `D:/development/game-prototype-2`; pinned target geography wins over source drift.

### Selection

- Resume the one In progress W task, even if the previous session ended without completing it.
- Reassess a Blocked W task first. If its blocker can be resolved within scope, resume it; otherwise record the exact blocker and stop. Do not work around it by marking dependencies Done.
- Otherwise select the lowest-numbered Pending W task with all dependencies verified Done. The checklist is sequential, so incomplete predecessors prevent successors.
- If multiple active tasks or inconsistent status records remain after artifact inspection, record the precise inconsistency and stop rather than guessing.
- If every W task is Done, report the feature complete and stop.
- State selected ID, scope and acceptance briefly. Mark it In progress in CHECKLIST and CURRENT_STATE before implementation. Do not mark Done until all criteria pass.

### Execution

Complete runnable behavior and all required checks for that task. Do not stop at a proposal. Do not begin the next W task in this session. If a task needs several sessions, save precise continuation state and keep it incomplete.

Use CONTRACT for clock gates, source seed arithmetic, saved state, light defaults/IDs, 3D anchor adaptations, indoor profiles, derived heavy-rain, renderer and performance targets. The source ten-minute day and four weather conditions are behavior to port; its 2D sprite origins/shadow renderer are reference data rather than physical 3D coordinates.

Keep typed GDScript, explicit GameRoot composition and existing ownership. Session/services own facts; presenters own rendering; location wrappers own light anchors/input identities. Reuse current interaction and save boundaries. Do not implement autosave, full NPC routines, fair campaign, audio, shops or unrelated gameplay/art.

Do not refresh the pinned map snapshot, run source generators, edit the Flutter project or import Dart caches. No runtime/export dependency may point to the source checkout. W001 pins the relevant weather/time behavior hashes or vectors separately.

Inspect before asset production. Use relevant installed Blender skills for modeling/material/export work. Save authored sources under target `art/source/`, reusable runtime exports under `game/assets/`, and preserve collision/navigation/IDs independently of visuals.

Do not spawn subagents, commit, push, publish, install dependencies or change renderer without explicit user authorization. Reversible changes needed for the selected task and its criteria are already in scope; do not request repetitive permission. Respect actual tool/filesystem permissions; record precise limitations if required access is unavailable.

### Tools and verification

Check these installed executables before searching for Godot or proposing installation:

- Console: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
- Editor: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64.exe`.

From the target root in PowerShell, example existing commands:

```powershell
$weatherGodotExe = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
& $weatherGodotExe --headless --editor --path game --import --quit
& $weatherGodotExe --headless --path game --script res://tests/application_smoke.gd
& $weatherGodotExe --headless --path game --script res://tests/interaction_dialogue_checks.gd
& $weatherGodotExe --headless --path game --script res://tests/location_travel_checks.gd
```

These are available checks, not a requirement to run every one for every task. Choose affected checks and the selected task's required validation. New environment test names in CHECKLIST are proposed; implement/verify a file before invoking it. Do not claim an absent script ran.

For playtests, read `tools/PLAYTEST.md` and the project or installed `returning-fair-gameplay-testing` skill. Use bounded input, verified pause checkpoints and finally input/process cleanup. Inspect a confirmed pause before analyzing a running game. Keep native/helper output within its actual allowlist; use fresh allowed capture directories and index them under the W evidence when necessary.

Always isolate save writes. Debug `--save-slot` is ignored by release builds: native release needs a verified separate application-data directory/config as documented by M019/tools. Never use or overwrite the user's normal save to prove a feature. Do not repurpose PowerShell HOME/CODEX_HOME variables.

Keep evidence under `docs/evidence/Wxxx/` and disposable staging/build output under `builds/weather-lighting/`. Never overwrite prior P/M reports, snapshots, captures or raw logs. Record commands, cwd, environment/save paths, actual engine PID where measured, exit codes and runtime-error scans. Exit 0 with runtime SCRIPT ERROR is a failed check.

Headless checks prove rules/lifecycle, not visual appearance. Inspect real rendered captures for visual criteria. Developer presets, forced weather, injected facts and setup placement are explicitly synthetic. They cannot prove ordinary movement, release controls, normal quest flow or native save/restart. W010 requires genuine packaged/native evidence.

Performance uses declared M018 method/settings and retained thresholds. If a task's required check fails, perform focused repairs within that task and rerun affected checks. Do not hide failures, weaken gates or broaden testing repeatedly after sufficient evidence passes.

### Durable handoff before ending

1. Update selected task status in the ordered table and its detailed task section. Done requires evidence for every criterion. Otherwise retain In progress or record Blocked with the specific cause.
2. Rewrite CURRENT_STATE with selected/completed/next task, exact changed files, commands/results, isolated paths, source/contract decisions, every failed/unrun criterion and the next safe action. Include any remaining live process/editor state. An interruption is not task completion.
3. Append a concise completion record to CHECKLIST only when Done. Keep previous records and raw failure evidence intact.
4. Update CONTRACT for justified implementation decisions and parent architecture/README/state only where production behavior changed. Preserve historical P/M completion evidence.
5. Run `git diff --check`, inspect intended-file diff and verify local document links and checklist/handoff consistency.
6. Final response: selected W ID and status, concrete result, verification, remaining limitation and next eligible W task. Stop. The user will start a new chat with this same prompt for the next task.
