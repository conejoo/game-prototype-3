# Current prototype state

Updated 2026-10-04. P001-P014 and map M001-M019 complete. Current feature workflow:
[weather-lighting](weather-lighting/CURRENT_STATE.md), W001-W005 Done, W006 next.
Typed clock/seed/cached forecast now advance through the existing session gate.
Schema5/content1 retains exact environment time/seed and six validated lantern
overrides; exact v1-v4 migrate without losing prior facts or rewriting files.
Save/backup/physical rollback and isolated separate-process checks pass.
One root-owned presenter drives the moving outdoor sun and smooth day/dusk/navy
night/dawn direct/ambient/background/shadow values. Tollworks keeps its original
lighting while global time advances. Profiles apply at committed arrival, including
paused travel/load; rollback retains the previous presentation. W004 sampling,
ownership/pause/rollback and eight affected regressions pass; 37 synthetic rendered
captures inspected in both projections. All23 exterior sources now have independent
visual consumers, imported lamp/waylight/net art and registered emissive window
panes. Eight unshadowed local emitters and source-opacity/spatial fading preserve
logical defaults/overrides and existing physics. W005 consumer13,289 assertions,
eight affected checks and65 inspected synthetic renders pass. E switching,
weather and native feature acceptance remain W006-W010; historical packages unchanged.

Playable baseline: larger Alderwake town/river/Moonwood, temporary ally/trust,
preparation-point Strike upgrade, guardian/vessel recovery, Maris return/fitting
and service preview, travel and manual saves. Schema5/content1; once-only effects
and stable actor/quest/location IDs. Six other portals stay inactive. Full campaign,
permanent companion decisions, NPC schedules, shops and inventory remain excluded.

M019 verified larger-map Windows exports/startup and genuine fresh native journey,
GUI Save, quit, independent GUI Load and replay. Durable quest/party/trust/upgrade
fields matched after restart. Focused application, combat, save, camera, navigation,
extension and lifecycle checks passed. No unresolved native release gate. P014's
compact release proof is historical; current packages are the larger map.

Useful context: [architecture](ARCHITECTURE.md), [map contract](map-migration/CONTRACT.md),
[map handoff](map-migration/CURRENT_STATE.md), applicable feature checklist/contract,
current source/tests and pinned references. Raw screenshots, logs, failed runs and
session drivers live under ignored docs/evidence; read only for a specific issue.
Missing local archives do not block development. Keep task acceptance criteria and
concise completion records; remove duplicate transcripts and oversized inventories.

Run/check commands and controls: README. Native/debug testing: tools/PLAYTEST.md
and tools/skills/returning-fair-gameplay-testing/SKILL.md. Native release requires
separate APPDATA plus verified override.cfg custom user directory; debug --save-slot
is ignored there. Pause must be observed before inspection between input batches.
Never overwrite normal saves. Keep installed/project testing skill copies aligned.

Local Windows packages live under builds/windows and builds/windows-validation;
rebuild before treating them as proof of later changes. Outputs remain ignored;
unsigned local builds only. Original compact packages/validation saves and raw
reports stay local. No publication or weather acceptance implied by these results.

Repository cleanup (2026-10-04): 8,505 generated evidence files untracked and
ignored; local archive and pre-cleanup document copies preserved. Compact weather
references, independent portal measurements and exact camera poses remain versioned.
Clean staged checkout passed weather audit, all 15 extractor tests, application
startup and ten affected map report checks; four render/profile scripts parse.
Tree audit used actual Compatibility renderer after expected headless rejection.
Import exit 0 retains known missing .NET SDK diagnostic. Saves/temp outputs isolated
under builds/repo-cleanup. No native quest/visual/performance acceptance rerun.
