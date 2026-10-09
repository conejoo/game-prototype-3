# R003 pure clock/condition selection acceptance

Done2026-10-09 UTC / America/Vancouver. Exactly R003; implementation ended before
successor/commit/push. Separate successful-task commit follow-up authorized after
acceptance; no push. Clean baseline target2f0d60f39ae87731309d8f3bbd1c356a1913a8c5;
read-only source60c20eb2816e7271fb84afaba286af006ebe3ccf remained clean.

## Delivered boundary

Four new typed components under game/features/routines/: detached immutable
RoutineResolutionContext, RoutineAssignmentPlan, pure RoutineResolver and transient
RoutineAssignmentDirector. Six new scripts (including two checks) have generated
UIDs for version control. Existing root/game/tool/content/save bytes are unchanged.
Only CHECKLIST/CURRENT_STATE and this acceptance document change existing workflow.
No production schedule, actor, movement, new clock, saved cursor or durable owner.

Context captures EnvironmentState/EnvironmentClock and WeatherConditionService,
actual NpcConversationState/ConversationMemory and detached NpcEventMemory.
Authored events union derived thunderstorm heavy-rain; ordinary rain derives none.
Event queries reuse the existing exact-key inclusive matcher. Snapshot incoherence
(event time after sampled active time), invalid clock/time/owner and unknown event/
suppression IDs fail closed. Old-day suppression is ignored when authoritative
day index changes; caller arrays/state stay intact. R004 owns durable expiration.

Resolver retains source ordering and rejection precedence. Director compares
day plus per-definition window/suppression/condition truth each caller update;
unchanged truth skips resolution and returns fresh elapsed values without changing
assignment revision. Window and recency expiry reevaluate without player input.
Changed participant IDs permit downstream atomic group reconciliation. A day change
marks same-routine assignments as a new generation; midnight alone does not.
Root/executor wiring remains R010/R013.

Source-semantic adaptation: canonicalize clock minute only within existing
WeatherSchedule.BOUNDARY_EPSILON_MINUTES (1e-9) of integer, preventing normalized
progress round trips from missing an inclusive authored boundary. No authored
window/clock/duration changes. Count/recency matching and weather remain unchanged.

## Acceptance matrix

| Criterion | Actual evidence |
| --- | --- |
| All25 routines selected | routine_resolver_checks consumes all18 R001 selection vectors and asserts exact25-ID coverage, eight roster/service assignments and memory immutability. |
| Inclusive/exclusive/overnight boundaries | Six probes per definition plus all1440 clock minutes; whole group and exactly eight assignments each minute. Empty/invalid windows refuse. |
| Midnight versus10AM wrap | R001 clock vectors, real EnvironmentState.advance at10AM, retained midnight suppression and expired old-day suppression; current-day suppression honored. Pure fixture only. |
| Priority/ties/groups/rejection precedence | Explicit opposing solo/group fixtures, reversed input order, priority then ID, complete conflict rejection and exact sorted conflicting IDs. Suppression/window/condition/conflict enum probes. |
| Facts/flags/event counts/recency | Actual detached conversation/event owners; fact, flag-set/unset precedence, all-AND fixture, inclusive min/max/recency, missing aggregate, exact-null subject/target and person-specific lookup. Inventory never sampled. |
| Rain versus thunderstorm/authored union | Real seeded WeatherSchedule/WeatherConditionService samples; storm survives authored heavy-rain removal, ordinary rain selects fishing, authored fixture selects shelter. Forecast seed unchanged. |
| Stable plans / expiry without actions |120 actual clock updates preserve one resolution/revision while elapsed advances. Window expiry changes both Vale members, fact/flag changes one member; validated finite-recency catalog expires past inclusive endpoint without a new event and reselects on fresh event/count limit. |
| Elapsed plans / detached atomic state | R001 elapsed vectors22:00/00:00/06:00/09:45, max-clock/huge-delta refusal, copied inputs/read-only nested plans and invalid director update preserving accepted plan/count. |
| Prerequisites / clock preservation | Live-source pin audit1624; current routine content848 assertions/228 malformed fixtures; environment rules12792 and session active/pause/modal/focus/travel/shared-clock checks pass. |

All new evidence is synthetic pure-rule/service fixture evidence. Later-day seeded
weather is deliberate because source forecast starts clear and cannot produce
day-zero18:00 storm. No natural-weather, saved-state suppression, public input,
physical route, actor, source Dart test, rendered or native proof claimed.

## Commands and retained results

Repository cwd D:/development/game-dev-blender/returning-fair-prototype; PowerShell7,
installed explicit Godot console4.7.2.stable.mono.official.ed1daf0bf. Default sandbox
exec helper fails setup; reviewed commands work, with no approval rejection. No
global Git config, source write, installation or normal save access.

- Bundled Python3.12.14 reference_checks.py --source D:/development/game-prototype-2
  --report docs/evidence/R003/reference-preflight/results.json: PASS1624 assertions,
  88 live-source pins/25 routines/21 targets. No source drift or refreshed pins.
- run_checks.ps1 -Task R003 -Import -Names routine_resolver_checks,routine_clock_checks,routine_content_checks,environment_rule_checks,environment_session_checks
  -ParseScripts the four new components -TimeoutSeconds150: retained initial
  [091011 report](../evidence/R003/20261009-091011722-7c6b4720/results.json)
  failed after import generated six owned UIDs, invalidating stable-source gate.
  No gameplay checks credited from that run.
- Same command after UIDs settled: [091034 report](../evidence/R003/20261009-091034886-f9e57a6c/results.json).
  Stable source; engine/import/parse/content/environment rules/environment session
  cases pass. Overall run failed because two new weather fixtures assumed impossible
  day-zero forecasts. Retained27 resolver/6 clock failures; fixture repaired.
- Affected rerun: ./tools/run_checks.ps1 -Task R003 -Names routine_resolver_checks,routine_clock_checks
  -ParseScripts features/routines/routine_resolution_context,features/routines/routine_assignment_plan,features/routines/routine_resolver,features/routines/routine_assignment_director
  -TimeoutSeconds150. [Final report](../evidence/R003/20261009-091213986-0fcf01c2/results.json)
  PASS4 cases; all exits0/diagnostics empty, source.changed=false/source.error=null.
  Resolver13310 /clock301 assertions; zero failures. Detailed reports record one
  fewer assertion because evidence-write assertion happens after serialization.

Final observed game/tools fingerprint60653ad0b08587974c6c55069251d2e1762c4c72d927244d8a5d62519074b323,
1194 files. Earlier prerequisite-only bytes unchanged by fixture repair; passing
cases remain credited individually, never the failed overall run. Separate task
check groups/slots and APPDATA/LOCALAPPDATA under builds/testing/R003/<run>; both
primary/backup saves remain untouched by these data checks. Environment session
runner retains its own independent isolated group. Viewed structured reports,
source manifests, rule detail and stdout/stderr; no captures needed for pure task.

## Handoff

All acceptance criteria pass; blockers none. Owned checks exited, no held input,
live owned editor/game or cleanup owed; Blender2664 untouched. Raw failed/passing
evidence and task staging retained ignored. Pre-existing game/tool/pin/geometry/
save/source/AGENT_PROMPT/user instruction bytes preserved; no baseline user changes.

Remaining R004-R016. Every item through R016 complete: no. Next eligible R004;
recheck actual save schema and implement minimal durable events/day suppression
and isolated command/save/restart/rollback acceptance. R005 independently ready.
No successor started; no commit/push.

Final documentation/diff audit passes:16 exact statuses (R001-R003 Done,
R004-R016 Pending),64 resolving relative links, valid dependencies/ready IDs
R004/R005 and exactly15 changed files in the declared allowlist. Git diff --check
passes; source worktree remains clean. One final documentation patch attempt had
an unmatched context and made no changes; corrected patch applied atomically.
