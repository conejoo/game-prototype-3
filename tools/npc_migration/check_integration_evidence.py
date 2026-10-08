"""Audit N017 runner/ordinary coverage and derive strict capture contact sheets.

Run after acceptance processes exit. This validates recorded evidence; visual
acceptance still requires opening the resulting sheets and full-size frames.
"""
import argparse
import json
import sys
from pathlib import Path
from uuid import uuid4

PROJECT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT / "tools"))
import capture_evidence


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def accepted_run(path):
    path = path.resolve()
    if not path.is_relative_to(PROJECT / "docs/evidence/N017"):
        raise ValueError("Run must be an N017 evidence child")
    report = read(path / "results.json")
    if (report["status"] != "passed" or report["source"]["changed"]
            or report["source"]["error"] or any(c["status"] != "passed" for c in report["cases"])):
        raise ValueError(f"Runner not accepted: {path}")
    before = report["source"]["before"]["sha256"]
    if before != report["source"]["after"]["sha256"]:
        raise ValueError("Source manifests disagree")
    return report, before


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run", type=Path)
    parser.add_argument("--regressions", type=Path)
    parser.add_argument("--ui", type=Path)
    parser.add_argument("--profile", type=Path, help="Separate idle profile run after regressions exit")
    args = parser.parse_args()
    report, digest = accepted_run(args.run)
    for extra in (args.regressions, args.ui, args.profile):
        if extra and accepted_run(extra)[1] != digest:
            raise ValueError("Accepted runs must observe identical source bytes")
    run = args.run.resolve()
    phases = {}
    views = []
    capture_groups = {}
    for phase in ("write", "read", "neutral", "survey", "profile"):
        phase_run = args.profile.resolve() if phase == "profile" and args.profile else run
        data = read(phase_run / "render" / f"{phase}-integration.json")
        if data["failures"] or any(not t["ok"] for t in data["traces"]):
            raise ValueError(f"Failed phase/journey: {phase}")
        phases[phase] = data
        views.extend(data["captures"])
        capture_groups.setdefault(phase_run, []).extend(data["captures"])
    if phases["write"]["pid"] == phases["read"]["pid"]:
        raise ValueError("Restart reused writer process")
    catalog = read(PROJECT / "game/content/npcs/catalog.json")
    expected_nodes, expected_choices = set(), set()
    for package in catalog["packages"]:
        expected_nodes.update(k for k, v in package["coverage"]["node"].items() if v["status"] == "enabled")
        expected_choices.update(k for k, v in package["coverage"]["choice"].items() if v["status"] == "enabled")
    actual_nodes = set(phases["write"]["nodes"] + phases["neutral"]["nodes"])
    actual_choices = set(phases["write"]["choices"] + phases["neutral"]["choices"])
    missing_nodes = sorted(expected_nodes - actual_nodes)
    missing_choices = sorted(expected_choices - actual_choices)
    if missing_nodes or missing_choices:
        raise ValueError(f"Ordinary coverage missing nodes={missing_nodes}, choices={missing_choices}")
    if (len(expected_nodes), len(expected_choices)) != (58, 38):
        raise ValueError("Enabled coverage changed from pinned contract")
    deferred_nodes = {node["id"] for p in catalog["packages"] for node in p["dialogue"]["nodes"]} - expected_nodes
    if deferred_nodes & actual_nodes:
        raise ValueError("Ordinary journey entered deferred source node")
    manifests = []
    for capture_run, group in capture_groups.items():
        # Strict capture validation pins each PNG to its own manifest run.
        manifest = capture_run / f"integration-views-{uuid4().hex[:8]}.json"
        manifest.write_text(json.dumps({"views": group, "failures": []}, indent=2), encoding="utf-8")
        manifests.append(manifest)
    capture_path, capture_report = capture_evidence.build(manifests, PROJECT / "docs/evidence")
    result = {
        "task": "N017", "status": "ready-for-visual-review", "source_sha256": digest,
        "cases": len(report["cases"]), "nodes": sorted(expected_nodes), "choices": sorted(expected_choices),
        "ordinary_coverage": [58, 38], "writer_pid": phases["write"]["pid"], "reader_pid": phases["read"]["pid"],
        "neutral_pid": phases["neutral"]["pid"], "captures": len(views),
        "assertions": {phase: data["assertions"] for phase, data in phases.items()},
        "capture_report": str(capture_path), "sheets": capture_report["contact_sheets"],
        "note": "Viewport ordinary input/restart plus labeled synthetic surveys. No native release claim.",
    }
    output = capture_path.parent / "integration-coverage.json"
    output.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps({"report": str(output), **result}))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, OSError, AssertionError) as error:
        print(f"N017 evidence rejected: {error}", file=sys.stderr)
        raise SystemExit(1)
