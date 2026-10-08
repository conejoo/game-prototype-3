"""Read-only G002 deterministic overlay proof; never writes runtime outputs."""
import argparse
import copy
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/npc_migration"))
from convert_content import OUTPUT, expected_outputs
import activation_overlay


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path)
    parser.add_argument("--evidence", type=Path, required=True)
    args = parser.parse_args()
    destination = args.evidence.resolve()
    assert destination.is_relative_to((ROOT / "docs/evidence/G002").resolve())
    destination.mkdir(parents=True, exist_ok=True)
    baseline = expected_outputs(args.source)
    overlay = expected_outputs(args.source, social=True)
    assert overlay == expected_outputs(args.source, social=True), "Nondeterministic conversion"
    assert all(path.read_bytes() == data for path, data in baseline.items()), "Production drift"
    assert all(data == overlay[path] for path, data in baseline.items() if path != OUTPUT), "Art changed"
    base_doc = json.loads(baseline[OUTPUT])
    active_doc = json.loads(overlay[OUTPUT])
    policy = activation_overlay.expected_policy()
    changes = []
    totals = {kind: 0 for kind in policy["expected_enabled_totals"]}
    for base, active in zip(base_doc["packages"], active_doc["packages"]):
        expected = copy.deepcopy(base)
        expected["coverage"] = active["coverage"]
        assert expected == active, "Source fields/adaptation changed"
        for kind, coverage in base["coverage"].items():
            for identifier, value in coverage.items():
                new = active["coverage"][kind][identifier]
                if value != new:
                    changes.append((base["id"], kind, identifier))
                if kind in totals and new["status"] == "enabled":
                    totals[kind] += 1
    allowed = [(row["npc_id"], kind, row["id"]) for kind, rows in policy["enable"].items() for row in rows]
    assert sorted(changes) == sorted(allowed) and len(changes) == 27
    assert totals == policy["expected_enabled_totals"]
    # Mutated policy files fail independently of immutable original references.
    rejected = []
    original = activation_overlay.POLICY_PATH
    for label in ["extra-person", "deferred-fact", "wrong-item", "wrong-activation-task"]:
        bad = copy.deepcopy(policy)
        if label == "extra-person": bad["selected_ids"].append("npc-05")
        elif label == "deferred-fact": bad["enable"]["fact"] = [{"npc_id":"npc-01", "id":"npc-01-public-role"}]
        elif label == "wrong-item": bad["source_item_mapping"]["moonflower"] = "item-fishing-rod"
        else: bad["activation_task"] = "G002"
        path = destination / (label + ".json")
        path.write_text(json.dumps(bad, indent=2) + "\n", encoding="utf-8")
        activation_overlay.POLICY_PATH = path
        try:
            activation_overlay.apply(base_doc["packages"])
        except AssertionError:
            rejected.append(label)
        else:
            raise AssertionError("Malformed policy accepted: " + label)
        finally:
            activation_overlay.POLICY_PATH = original
    (destination / "social-catalog-preview.json").write_bytes(overlay[OUTPUT])
    report = {"status":"passed", "proof":"target-local read-only overlay preview, not runtime activation",
              "production_sha256":hashlib.sha256(baseline[OUTPUT]).hexdigest(),
              "preview_sha256":hashlib.sha256(overlay[OUTPUT]).hexdigest(),
              "changed_availability":changes, "enabled_totals":totals,
              "assets_unchanged":len(overlay) - 1, "rejected_policies":rejected}
    (destination / "overlay-report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("G002_OVERLAY PASS " + json.dumps(report, sort_keys=True))


if __name__ == "__main__":
    main()
