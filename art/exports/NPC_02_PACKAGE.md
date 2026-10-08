# Helena (`npc-02`) character package

N009 adds Helena beside the delivered Edric contact. The pinned source graph,
six portraits, authored fact IDs and schema7/content1 stay unchanged. The
[animated pipeline](NPC_PIPELINE.md) supplies shared rig/export/presenter rules.

## Identity and physical contract

Source npc-02 / Helena Vale / Town Archivist maps to
`alderwake-npc-02-contact`, public civic foot `(1.5,0,-1.5)`, approach
`(2.5,0,-1.5)`, prompt `Talk to Archivist Vale`. This is the N001 approved public
adaptation, not a new archive interior or daily schedule. The noncombatant remains
outside the two-person Party, with independent radius0.4m/height1.6m collision and
navigation reservation. Facing rotates visuals toward the player, never the body.

The source official-neutral portrait and idle/walk sheets inform a mature angular
face, narrow jaw/nose, auburn swept hair in a pinned low bun, fitted moss-green
vest and long skirt, cream blouse/puff sleeves, ink-dark stitched sleeve guards,
narrow brass key pendant, belt and brown boots. Source canon specifies age50.
These are custom shaped mesh surfaces, not a recolored calibration or Edric mesh.
The back follows the public idle sheet; the long skirt uses two overlapping
tailored panels following the thighs for the exported walk adaptation. The small
face and mature creases are stylized, not an exact photoreal likeness claim.
No private profile text, household facts or story disclosures enter runtime data.

## Actual files and editing

- `art/source/npc-02.blend`: editable ordinary active mainfile, three objects
  (root, armature, skin), packed32x32 palette, identity meter/ground transforms.
- `build_npc_02.py`: custom geometry authoring; only N007 rig and baked loops
  reused. It loads an owned calibration copy into a new RF-Npc02-Helena scene,
  refuses an existing owned scene and restores the prior live scene afterward.
- `normalize_npc_02.py`, `check_npc_02_source.py`, `audit_npc_02.py`: owned-mainfile
  normalization, read-only Blender audit and raw GLB portability/endpoint audit.
- `game/assets/models/npcs/npc-02.glb`, retained import UID/linear idle/walk loop
  settings, extracted embedded palette PNG/import. No external texture dependency.
- `npc_02_checks.gd` and `npc_02_render.gd`: imported skin/lifecycle/deferred
  archive assertions and separate ordinary/review routes using the shared runner.

Measured cost:8317 exported triangles,4366 authored vertices,16 bones,one material
surface,one32x32 RGBA palette. Idle4s and walk0.8s have baked matching endpoints.
Idle is ordinary runtime; walk is review-only. Archive-work belongs to N016 and
is absent here. There is no desk, fake work action, routine consumer or reward.

For further editing open the owned mainfile rather than regenerating over artist
edits. Select its root/rig/mesh, export NLA clips with slide-to-zero, then audit
raw GLB, retained imports and actual Godot skin before accepting changes. To run
the authoring entry through MCP use an explicit `__name__='__main__'` namespace
with `exec(compile(path.read_text(), str(path), 'exec'), namespace)`; the MCP
execute-code namespace does not itself invoke Python's normal main guard.

## Public disclosure and persistence

Initial ordinary conversation teaches only `npc-02-public-role`. Careful research
response grants one affinity; neighborly response grants zero. Both are one-time,
mutually exclusive and have source-authored portrait/text endings. Reopening
selects the authored follow-up. Actual committed Moonflower gathering enables
the once-only hint and `npc-02-moonflower-pressing`, even though gifts remain
unavailable. Disabled gifts consume no inventory and grant no affinity.

`npc-02-archive-practice` remains unknown: its sole disclosure node and both
archive preferred entries/outcome tags are deferred without a source-sanctioned
routine consumer. Ordinary civic dialogue cannot jump to a ledger, suppress a
daily action, unlock a private home or disclose household history. The visual
key/costume/title does not teach additional facts.

Manual Save/Load persists source flags/receipts/seen nodes/learned facts and
independent affinity with all prior durable state exactly. No cursor, pose or
presenter gets saved. Ordinary routes, synthetic art/weather/lifecycle fixtures
and later native package acceptance are distinct evidence scopes.
