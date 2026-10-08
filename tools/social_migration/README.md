# Social migration reference tooling

G001 records reviewed public source semantics, an exact future activation overlay,
reference expectations and a bounded historical target baseline. It does not
activate gifts, milestones or People, and it never reads normal saves.

From repository root, use the installed bundled Python:

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2
```

Without `--source`, all reference checks remain target-local. With it, the checker
also verifies live source HEAD, clean status, full input hashes and excerpt parity.
Differences fail; there is no refresh/repin mode. Neither mode invokes Godot.

`--check-g001-baseline` additionally checks the 18 current owner/content hashes
recorded during G001. Use it only while verifying G001. Later authorized runtime
changes belong to later acceptance tasks; the default audit does not freeze game
files or assert production social behavior.

The existing NPC converter `tools/npc_migration/convert_content.py --check --source
D:/development/game-prototype-2` now proves current G004 production activation.
Historical G001/G002 acceptance records retain their pre-activation scope.

- [Manifest](reference/manifest.json): source revision/full hashes, bounded excerpt
  hashes, existing NPC reference hashes and artifact hashes. No duplicated public
  packages or portraits, no private profiles or additional NPCs.
- [Activation](reference/social_activation.json): policy `social-60c20eb2-g001`,
  schema1. `enable` contains recipient-qualified node/choice/gift-rule IDs;
  `recipients` traces rules, introductions, preference disclosure and every incoming
  and outgoing activated-node transition. `preserve_deferred` preserves full N001
  reasons/fields for the three remaining nodes, six choices and three facts.
- [Behavior vectors](reference/behavior_vectors.json): 16 positive/neutral recipient
  sequences, shared caps, eligibility/event/transition order, selection, signed and
  milestone boundaries, People sorting/disclosure and finite ordinary supply.
  These are reference expectations for downstream runtime fixtures, not executed
  Dart/Godot assertions. `target_strengthening_not_source_proof` separates command,
  atomicity and strict-save requirements from observed source behavior.
- [Target baseline](reference/target_baseline.json): historical schema7/content1,
  availability, two item types, 20 slots, three flowers, 40 event keys and selected
  owner excerpts. Full game-byte preservation evidence remains under ignored G001
  evidence, not an enduring production constraint in this reference checker.
- [G001 acceptance](../../docs/gifts-friendship-people-journal/G001_ACCEPTANCE.md)
  records inspected source tests, verification commands, boundaries and results.

Source excerpts use inclusive original line numbers and normalized LF UTF-8 text.
Their manifest also records full original-file byte lengths and SHA256 hashes.
Additional bounded `npc_content.dart` and `dialogue_repository.dart` excerpts pin
authored threshold/label/milestone parsing and priority/tie resolution. The
historical NPC pin stays unchanged.

G002 adds [activation_overlay.py](activation_overlay.py), consumed by the existing
converter's originally opt-in social output. G004 changes the current interface to
`expected_outputs(source=None, social=True)` / default CLI (explicit `--social` alias).
It runs the immutable hash/semantic audit, matches the exact approved policy and
copies only its27 availability records. Current production loader requires these
approved records enabled and retains every room/routine/disclosure gate.
`--baseline` requires `--check`; it cannot overwrite active production.

[overlay_checks.py](overlay_checks.py) proves a deterministic preview, approved
27 changes, unchanged66 assets/text/adaptations, preserved deferred records and
rejected malformed policies. From repository root:

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/social_migration/overlay_checks.py --source D:/development/game-prototype-2 --evidence docs/evidence/G004/<fresh-run>
```

Preview/report/negative fixtures remain ignored evidence; game catalog is never
written by this check. A G004 destination checks production against approved
overlay; historical G002 destinations check the inactive baseline.
[G002 acceptance](../../docs/gifts-friendship-people-journal/G002_ACCEPTANCE.md)
records original candidate/publication boundaries.

Nothing under this folder is a runtime/export dependency. G004 is the activation
task; G006 may build the independent read-only People projection after G001.
