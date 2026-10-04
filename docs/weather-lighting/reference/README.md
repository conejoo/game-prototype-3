# Retained weather references

Use CONTRACT.md for implementation. These small inputs preserve decisions that
would otherwise depend on an evolving external checkout. Raw W001 reports,
captures, full source/test copies and preservation inventories stay in the ignored
local archive; agents do not need them to resume.

- Four exact Dart files: deterministic forecast, clock, daylight and rain/lightning
  presentation rules. Reference only; not imports or build dependencies.
- source-manifest.json: source commit and inspected-file hashes. Only entries with
  retained_path have a versioned copy. Source HEAD was
  842704819cc681ccbabc629c6634c154a53b506b on 2026-10-04.
- rule-vectors.json: 49 forecast cases plus clock, advance and uint32 products.
  Python transcription of pinned rules; no claim that Flutter/Dart tests ran.
- light-inventory.json: all 23 exact source identities/defaults, existing wrappers
  and physical anchor/window recipes for W005. Target map snapshot remains
  alderwake-f4630f9-m002. Current source map drift does not authorize refreshing it.

From repository root run `python docs/weather-lighting/reference/audit.py`.
This checks retained hashes, pinned map inputs, identities/defaults and all vectors;
it neither requires nor writes docs/evidence or packaged builds.

W001 original acceptance passed: source/inventory audit, actual headless production
root (all 23 wrappers/feet, safe party arrival, pause clock and renderer settings),
standalone Windows startup, document/link/diff review; all final exits 0 and no
runtime errors. This proves the pre-weather baseline only. New visuals, performance,
save schema v5 and native weather acceptance remain W002-W010 work.
