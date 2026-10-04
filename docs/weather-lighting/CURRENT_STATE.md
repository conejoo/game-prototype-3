# Current weather and lighting state

Updated 2026-10-04. W001 Done; W002-W010 Pending. No active/blocked W task.
Next: W002 pure clock/deterministic forecast. Cleanup starts no new W task.

Read CHECKLIST, CONTRACT and AGENT_PROMPT. W001 inputs now live in
[reference/](reference/README.md): four exact Dart rules, inspected-source hashes,
49 forecasts plus uint32/clock/advance vectors, and all 23 light identities/anchors.
Run `python docs/weather-lighting/reference/audit.py` from repository root.
No local evidence, external source checkout or existing build is needed for audit.

W001 original acceptance passed: immutable rules/IDs/defaults/feet, actual
headless production arrival with two actors/all 23 wrappers/pause timer/renderer
settings, standalone release startup, final link/diff review. All final exits 0;
no runtime errors. Dart tests were inspected, not executed. No new visual or
performance claim. Raw W001 logs and full reference copies remain ignored locally.

Production still uses elapsed timer, fixed Sun/WorldEnvironment and manual
schema4/content1 saves. W003 owns v5 environment and light overrides. Six lamps
are switchable; fourteen windows, two waylights and luminous net automatic.
W005 owns missing visual consumers; buildings without sources remain dark.

Contract fixes 600 active seconds/day, 10 AM origin, deterministic uint32 mixing,
240-480 minute weather periods, 15 minute blend, thunderstorm-only heavy-rain,
day0..3650 and pause/travel/load freeze. W002 must bound reconstruction and cache
between period boundaries. Pinned map geography wins over source drift.

Keep Compatibility and at most eight pooled unshadowed local emitters including
fades. M018 method/thresholds retained in CONTRACT; verify overlap/rendered output
and actual performance in their future tasks. Headless checks cannot prove visuals.

P001-P014 and M001-M019 complete; compact parent/map handoffs describe baseline.
Save writes must remain isolated (release ignores debug --save-slot); tools/PLAYTEST
and project testing skill document input/pause rules. Cleanup verification ran only
isolated test processes, now exited; no user scene touched. No unresolved W001 criterion.

Cleanup validation: retained reference audit and all 15 extractor tests pass from
staged checkout without evidence. Application + ten affected map checks pass;
render/profile/capture scripts parse. Raw results and initial headless tree rejection
remain local under builds/repo-cleanup/verification. W002 still Pending.
