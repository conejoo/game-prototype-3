# F010 local Windows acceptance tools

These tools select no checklist item and publish nothing. Follow the active task,
[playtest instructions](../PLAYTEST.md) and [native helper contract](../skills/returning-fair-gameplay-testing/references/native-commands.md).

- `build_packages.py` exports both existing presets with installed standard templates,
  archives previous packages, audits packed schema6/items/art/exclusions and checks
  standalone startup from the system temporary directory with isolated app-data.
  Fresh audited output is copied into the existing local Windows build directories;
  the adjacent release override is preserved. Evidence/staging use fresh F010 IDs.
- `package_audit.gd` reads exported resources through the installed Godot console.
  Its `debug_build` describes that audit host, not the separately exported executable.
- `launch_native.ps1 -Session <fresh-name> -Phase writer|reader` launches the release
  outside checkout, verifies override/save isolation, retains the original process
  object and records normal exit. Writer requires no prior save; reader requires it.
- `invoke_native.ps1 -GameProcessId <pid> -EvidenceDirectory <run-child> -StepsJson
  '<JSON array>'` writes a fresh request and delegates only to `native_input.ps1`.
  It checks the result and fails on input/cleanup refusal. Inspect client captures
  before issuing actions; no fixture, observation bridge or live mutation is added.
- `walk_native.ps1` reads existing ordinary movement logs and synthetic path guidance,
  delegates bounded holds to the same native helper and finishes with capture/pause.
  Short look-ahead limits eight-direction drift on long paths. It remains physical
  input, can stall against blockers and does not prove pause without image review.
  Use explicit bridge centre approaches before crossings; never remove rail/water
  collision or widen success tolerances to accept a stalled route. Direction mapping
  assumes the verified default camera. Source geometry guidance is not gameplay proof.
- `save_oracle.gd` uses packed production SaveCodec and WeatherSchedule to compare
  the two archived native GUI saves as detached candidates. It does not observe or
  change the native process; the ordinary GUI Load/Save and exact file comparison
  establish the live restart boundary.
- `audit_native.py <run> --output-directory <fresh-derived-directory>` validates
  requests/cleanup, package launch provenance, logs/exits, exact whole-save restart,
  item/old facts and drag rollback. It creates capture hashes/contact sheets for
  visual review. A known no-input sandbox desktop refusal is retained separately;
  successful gameplay requests must pass. The exact observed ESC-only foreground
  stop is retained separately with clean release, fresh observation/pause and retry;
  it is not successful gameplay proof. A launch-correction record overrides false
  cwd metadata and makes that older pair fail. Caption timing requires image inspection.

Use bundled Python/Pillow already installed on this host. No downloads or dependency
installation are needed. Raw evidence remains ignored; durable F010 acceptance owns
the actual run IDs, commands, package hashes, inspected images and limits.
