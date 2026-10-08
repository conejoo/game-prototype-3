# Edric and Helena semantic action packages (N016)

These are explicit art-review variants of the accepted named characters. Ordinary
`NpcRegistry.VISUAL_ASSETS` still mounts the original idle/walk packages at the
pinned civic feet. No routine consumer, fishing system, archive director, reward,
dialogue disclosure, saved pose or geographic change is introduced.

| Person | Source sheet/action | Portable variant | Exported action | Exposure |
| --- | --- | --- | --- | --- |
| Mayor Edric Vale / npc-01 | `npc_01_river_fishing_sheet.png` / `river-fishing` | `game/assets/models/npcs/npc-01-actions.glb` | `action_river_fishing` | Review only: two-handed rod lift/lower, no catch/line/reel transaction. |
| Helena Vale / npc-02 | `npc_02_archive_work_sheet.png` / `archive-work` | `game/assets/models/npcs/npc-02-actions.glb` | `action_archive_work` | Review only: supporting an open book, page checking/stroke and downward glance. |

Source sheets are the pinned public snapshots under
`tools/npc_migration/reference/assets/images/actors/npcs/`. They were actually
viewed. Each four-second action is sampled at 30fps with authored matching end
poses, immutable root/torso/feet and no drivers/constraints. The original named
body geometry, UVs, skin weights and idle/walk action keys are exact copies, as
verified by both editable-source and raw GLB audits. The existing stylized named
faces/costumes remain authoritative; this does not claim exact raster likeness.

## Editable and portable files

`art/source/npc-01-actions.blend` and `npc-02-actions.blend` are normal editable
mainfiles with active `RF-N016-01-Actions` / `RF-N016-02-Actions`. Each has a root,
16-bone armature, original body mesh and one source accessory mesh. The rod follows
`hand.R`; the two open page blocks, cover/spine and ruled marks follow `hand.L`.
Accessory vertices are inverse-bound from their authored action pose, rather than
parented with a corrective runtime offset. Both use the original packed 32x32
palette/PBR material. No texture or mesh comes from another person's identity.

Edric costs 7,686 triangles; Helena 8,497. Each has two material surfaces using
one material, 16 bones and one embedded RGBA PNG (4KiB before mips), below shared
12,000-triangle/32-bone/three-surface limits. GLBs include idle4s, walk0.8s and their
own action4s; import records retain all three linear-loop settings and asset UIDs.
No external URI, camera, light, collision, gameplay script or method track exists.
All required runtime bytes and palette extractions are in `game/`.

`build_npc_actions.py` loads owned original source copies and refuses an existing
N016 scene; it never regenerates original named geometry. `run_npc_actions.py`
is the MCP entry point. `normalize_npc_actions.py` operates only on owned action
mainfiles in background Blender, canonicalizes four object names, exports and
saves. For later artist edits, open the delivered action mainfile and edit there;
do not rerun generation over edits. Solo the desired NLA track for preview;
all three are available to the NLA exporter. The original live recovery-vessel
scene/file and all ordinary character mainfiles are retained.

Read-only validation:

```powershell
& $python art/source/audit_npc_actions.py --output <fresh-N016-run>/raw-actions.json
& $blender --background art/source/npc-01-actions.blend --python art/source/check_npc_actions_source.py -- <fresh-N016-run>/npc-01-source.json
& $blender --background art/source/npc-02-actions.blend --python art/source/check_npc_actions_source.py -- <fresh-N016-run>/npc-02-source.json
```

Use the absolute installed runtimes from the text-to-blender runtime instructions.
Actual command paths and inspected evidence are in
[N016 acceptance](../../docs/villagers-dialogue/N016_ACCEPTANCE.md).

## Presenter and exposure boundary

`NpcVisualPresenter.set_action(clip)` accepts only the two source-mapped names
and only a mounted asset containing that clip and its matching `PROP-<clip>` mesh.
It rejects wrong-person/unknown actions, any outstanding hold and achieved motion.
`active_action()` reports transient presentation; `cancel_action()` hides props
and returns to latest idle/walk. Zero achieved speed preserves an active action;
walking cancels it. Existing 0.12s mixer blends apply to entry/exit.

Props start hidden and remain hidden in idle/walk and after cancellation. Pause
and focus use independent holds and `AnimationPlayer.pause()` to preserve the
displayed pose and pending blend. Clearing only one hold cannot resume animation.
The last release resumes the same action without restarting it. Dialogue, travel,
modal and death cancel the action; after their last hold clears, locomotion resumes.
Facing rotates visuals only. Travel frees the whole scene-owned presenter and
accessory; reconstruction mounts the original ordinary asset. No presentation
state enters schema7/content1. Direct manual calls to the underlying player's
`advance()` bypass suspension; normal owners never use that path while held.

The reviewed action envelopes extend beyond the unchanged 0.4m ordinary contact
reservation: Edric's rod reaches about1.085m forward; Helena's book reaches0.454m.
The civic contact is not a river site, and no approved archive-work placement or
routine consumer exists. Consequently neither action is ambient gameplay. Idle
remains ordinary; walk and actions remain review-only. Their presence teaches no
river-fishing/archive-practice fact and enables no deferred routine outcome.

`res://tests/review/npc_action_review.tscn` displays both real variants with visible
Idle/Walk/Action/Pause/Resume buttons and explicit review labeling. It owns no
GameRoot or persistent state. `npc_action_render.gd` captures day/night phases,
real mixer entry/interrupt, suspended pose, profile/back and actual default camera
scale. `npc_action_checks.gd` measures imported skins and exercises production
owner hooks by explicitly labeled synthetic replacement, separately from ordinary
access. There is no new ordinary route, standalone release or native input claim.
