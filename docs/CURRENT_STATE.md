# Current prototype state

Updated: 2026-10-03 (America/Vancouver). P001–P014 verified complete.

## Current task and next action

P014 complete — extension check and Windows export. No next item exists in this
prototype checklist; no migration task started in this session. Separate map migration has reached M015 production exterior activation; follow
[its handoff](map-migration/CURRENT_STATE.md) when requested. P014 certifies the
compact build only; M019 must verify the resulting larger-map native release.

Final evidence: [native release validation](evidence/P014/native-holds/VALIDATION.md).
Earlier extension/export/debug evidence: evidence/P014/VALIDATION.md; focused
resume checks: evidence/P014/resume-2026-10-03-b/VALIDATION.md.

## Implementation and changed files

Baseline 073c924. Actual fixtures/services/root guards/export presets/templates,
Git and build hashes inspected. Extension/save/slice checks PASS0 before native
work; no gameplay regression or additional production abstraction required.

Earlier P014 implementation: QuestDefinition/QuestService authored journal_note
and completion_text; isolated second quest, 60-health guardian/shared wrapper and
inherited test room; Windows release/debug presets; text-resource conversion
workaround and executable-relative debug bridge path. Schema4/content1 and all
production IDs/once-only rules remain unchanged.

This continuation adds tools/native_input.ps1: target-restricted Windows SendInput
scan-code holds/clicks, unlocked desktop/foreground guards, finally key release,
client capture and timing traces. tools/PLAYTEST.md and local native-holds/driver.ps1
record short resume/actions/Esc-pause/capture batches. No game bridge/debug flag,
position/health/quest mutation or release rebuild. Game/art files unchanged.

Updated README P014 status only (existing migration links retained), CHECKLIST
completion, CURRENT_STATE and P014 evidence index/new native-holds evidence.
Architecture contracts unchanged; its original P014 open-gate wording predates
final release evidence. Preserve docs/map-migration/, docs/evidence/M001/ and
both earlier P014 resume directories. Source game and normal save untouched.
No Blender work, installation, subagents, commit, push or publication.

## Exact accepted checks

From project root, console executable is
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe.
Both supplied engine paths exist. Editor4.7.2.stable.mono.official.ed1daf0bf;
release4.7.2.stable.official.ed1daf0bf.

- --headless --path game --script res://tests/{extension,save,playable_slice}_checks.gd:
  PASS/exit0 with normal local app access. Initial restricted runs emitted log/
  certificate diagnostics, retained separately. Release headless startup exit0.
- --headless --path game --script res://tests/combat_checks.gd: final PASS/exit0;
  isolated swing/range/LOS/dodge/pause/death/retry/once-only/save rules.
- Original imports/exports/focused checks: PASS0; release audit112 entries, zero
  tests/extension entries. Final release exe+pck SHA256 equal original evidence.
- Native release a: fresh trust+1, lead, strike25->40, gate, actual combined-party
  guardian defeat100->10->0, vessel, return, three-line fitting, specialist preview,
  GUI Save, normal F10 exit0. Idle inspection delay caused death; normal R retry
  restored party before fight. No exact hero-only damage inferred from combined HP.
- Native release b: independent executable-directory start, fresh0, observed
  Tab/Enter GUI Load6, hero75/ally75/trust1/strike40/specialist restored. Initial
  mouse Load missed; fresh captures rejected as evidence, save6 stayed intact.
  Trust replay unchanged; upgrade disabled/selected; guardian0 revisit, town round
  trip, GUI Save/F10 exit0. All durable saved fields equal before/after, elapsed
  708.729573002131 -> 751.670010002675 only. Runtime ERROR/SCRIPT ERROR scan0.
- git diff --check exit0. Native helper parsed and executed; commands and exact
  per-step durations/UTC completions retained in native-holds/*.json.
  Final deadline sleep clamp checked in native smoke c: W500ms/Esc, paused timer
  stays28s over600ms wait, normal F10 exit0; no save writes.

## Playtesting timing contract

Game continues between tool calls and during helper startup; requested hold
milliseconds do not bound that interval. Inspect a confirmed pause first, run
one short resume/actions/pause/capture batch, verify overlay, then analyze while
paused. Native b remains at708s across a measured32-second inspection gap.
Dialogue/journal suspend actor controls but session time still advances. Esc may
close a modal or be ignored during travel; never assume it paused without evidence.
Wall timing is not deterministic physics stepping. Companion/enemy actions run
within resumed batches; exact isolated damage belongs in focused rules checks.

## Build, context and limits

Release: D:/development/game-dev-blender/returning-fair-prototype/builds/windows/ReturningFair.exe
beside ReturningFair.pck. Local override.cfg isolates user:// at
%APPDATA%/ReturningFair-P014-ReleaseValidation/saves. Keep for isolated playtests;
normal application slot remains separate. Debug slot: playtest-p014-standalone.json.

Windows11 Home10.0.26200 x64/Core Ultra9 185H/~32GiB/RTX4070 Laptop plus Intel Arc;
NVIDIA driver32.0.15.8129. Native client960x640. Release-b286 print-fps samples
227–242FPS/4.13–4.40mspf include pause/UI/revisit, not a combat/minimum-PC benchmark.
Unsigned local exe+pck; no distribution/signing claim. Static prototype art,
temporary ally/dialogue/customer/helper, shortened MQ03, service preview only;
ship/fair/salvage and permanent companion decisions remain outside scope.

## Reusable gameplay-testing skill

User requested/installed `returning-fair-gameplay-testing` after P014 completion.
Versioned source: tools/skills/returning-fair-gameplay-testing/SKILL.md; personal
copy: C:/Users/aldoc/.codex/skills/returning-fair-gameplay-testing/SKILL.md.
Scoped to this project; default automatic selection retained. Covers native/debug
input choice, uncontrolled tool-call gaps, verified pause batches, isolated damage
claims, fresh-process GUI save/load/replay and exact evidence/exit records.
Supporting native-commands reference documents current executable/P014 output
guards and fresh PID/run directory usage. Both copies pass quick_validate.py
using bundled Python/cached PyYAML; three PowerShell examples parse; copies match
SHA256. Skill creation ran no new gameplay and changed no production game/art.
Keep both copies in sync on updates. No next checklist item started.
