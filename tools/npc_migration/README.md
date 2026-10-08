# NPC migration reference tooling

N001 pins exactly eight selected public source packages and art references.
Nothing in this folder activates NPCs or changes save/content versions.

- [Manifest](reference/manifest.json): immutable source revision/path/hash inventory.
- [Coverage](reference/COVERAGE.md): enabled/deferred nodes, choices, facts, portraits,
  sheets, gift bindings and outcome fields; complete fields in coverage.json.
- [Contacts](reference/contact_registry.json): measured public contact specification.
- [Acceptance](../../docs/villagers-dialogue/N001_ACCEPTANCE.md): semantics,
  selection decisions, commands, evidence and future gates.

Use installed bundled Python (see acceptance) to run:

```powershell
& $python tools/npc_migration/npc_reference_checks.py
& $python tools/npc_migration/npc_reference_checks.py --source D:/development/game-prototype-2 --geometry docs/evidence/N001/20261007-reference/placement-attempt-4.json
```

Checker reads only. Optional --source verifies authority drift; omission proves
local snapshot integrity without source checkout. It also protects all462 baseline
game/art files for this N001-only audit; after authorized later implementation,
that production-identity assertion intentionally stops passing. Do not loosen it
and claim N001 identity for changed runtime. N002 creates its own conversion checks.

pin_reference.py is explicit one-time extraction and refuses an existing manifest.
Never refresh pin silently. A future authorized repin must explain/reconcile drift
and establish a new snapshot rather than replacing this one. Source catalog/maps/
Dart/canon/routines are hashed, not bundled; selected catalog, placement and routine
context are selective adapters with source indexes/paths. Private profiles excluded.

measure_contacts.gd runs outside game import tree against existing production root,
with fresh isolated appdata and explicit report output. It changes only task-owned
in-memory navigation reservations, using existing synchronization barrier. It does
not activate villagers. Capture paths/logs go to fresh docs/evidence/N001 runs;
never use ordinary user appdata. It proves physical policy, not ordinary UI/play.

N002 copies/converts only approved local public inputs into game-owned content;
target release must not contain authoring tools, source snapshots, Flutter files,
private profiles or test bridges. Retain schema6/content1 until owning save task.

Local .gitattributes disables text conversion for reference/** so Git preserves
manifest-covered source and fixture hashes across staging and checkout.
