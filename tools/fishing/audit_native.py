"""Read-only FS008 native identity, cleanup, save/revisit and packed-oracle audit.

Rendered gameplay/phase/pause recognition still requires separate pixel review.
Failed native requests remain explicit excluded evidence, never successful journeys.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[2]


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run", type=Path, required=True)
    parser.add_argument("--exclude-focus-request", action="append", default=[])
    args = parser.parse_args()
    run = args.run.resolve()
    if not run.is_relative_to(ROOT / "docs/evidence/FS008") or run == ROOT / "docs/evidence/FS008":
        raise ValueError("FS008 run-child evidence required")
    failures, retained, requests = [], [], []
    assertions = 0

    def check(ok, label):
        nonlocal assertions
        assertions += 1
        if not ok: failures.append(label)

    launches = {phase: read(run / phase / "launch.json") for phase in ("writer", "reader")}
    check(launches["writer"]["pid"] != launches["reader"]["pid"], "distinct writer/reader PIDs")
    check(launches["writer"]["APPDATA"] == launches["reader"]["APPDATA"], "isolated restart group shared")
    check(Path(launches["writer"]["APPDATA"]).resolve().is_relative_to(ROOT / "builds/fishing/FS008"), "no normal saves")
    for phase, launch in launches.items():
        check(launch["task"] == "FS008" and launch["phase"] == phase, "FS008 launch identity " + phase)
        check(not Path(launch["cwd"]).resolve().is_relative_to(ROOT), "outside checkout " + phase)
        check(not any("playtest" in arg or arg == "--path" for arg in launch["arguments"]), "no debug bridge " + phase)
        for key, leaf in (("release_sha256", "ReturningFair.exe"), ("pack_sha256", "ReturningFair.pck"), ("override_sha256", "override.cfg")):
            check(launch[key].lower() == digest(ROOT / "builds/windows" / leaf), "current exact native package " + phase + "/" + leaf)
        exit_record = read(run / phase / "exit.json")
        check(exit_record["pid"] == launch["pid"] and exit_record["exit_code"] == 0, "normal owned exit " + phase)
        for name in ("stdout.log", "stderr.log", "runtime.log"):
            text = (run / phase / name).read_text(encoding="utf-8-sig")
            check(not re.search(r"^\s*(?:SCRIPT ERROR:|ERROR:|WARNING:)", text, re.M), "clean runtime " + phase + "/" + name)
        for path in sorted((run / phase).glob("*.json")):
            report = read(path)
            if not isinstance(report, dict) or report.get("schema_version") != 2: continue
            check(report["target_pid"] == launch["pid"] and report["executable"] == launch["exe"], "request ownership " + path.name)
            check(not report["cleanup_errors"] and not report["unreleased_keys"] and not report["mouse_unreleased"], "released native controls " + path.name)
            if not report["ok"]:
                check(report["id"] in args.exclude_focus_request and "foreground" in report["error"], "unexpected failed native request " + path.name)
                retained.append({"id": report["id"], "error": report["error"], "path": str(path), "accepted": False})
            requests.append({"id": report["id"], "ok": report["ok"], "phase": phase})
    check(set(args.exclude_focus_request) == {row["id"] for row in retained}, "exact disclosed focus failure exclusions")
    writer_path = run / "writer/writer-bluegill-save.json"
    reader_path = run / "reader/reader-restored-save.json"
    revisit_path = run / "reader/reader-revisited-save.json"
    writer, reader, revisit = map(read, (writer_path, reader_path, revisit_path))
    check(writer_path.read_bytes() == reader_path.read_bytes() and writer == reader, "exact whole native paused Save/Load/re-Save bytes")
    check(writer["inventory"] == {"active_item_id": "item-bluegill", "item_counts": {"item-bluegill": 1, "item-fishing-rod": 1}}, "ordinary landed fish count/selection/rod")
    check(writer["schema_version"] == 7 and writer["content_version"] == 1, "current save format")
    check(writer["collected_resource_ids"] == ["fishing-rod-dock-01"] and writer["world_item_placements"] == [], "rod origin conserved")
    check(revisit["inventory"] == writer["inventory"], "revisit preserves fish/selection without duplicate catch")
    check(revisit["elapsed_play_seconds"] > writer["elapsed_play_seconds"], "actual resumed monotonic time")
    stable = lambda value: {k: v for k, v in value.items() if k not in ("elapsed_play_seconds", "environment")}
    check(stable(revisit) == stable(writer), "every baseline durable field preserved on revisit")
    oracle = read(run / "packed-save-oracle.json")
    check(not oracle["failures"] and oracle["typed_snapshot_exact"] and oracle["forecast_exact"], "packed production exact typed snapshot/full-precision forecast")
    result = {"task": "FS008", "status": "passed" if not failures else "failed", "assertions": assertions,
              "failures": failures, "retained_excluded_requests": retained, "requests": requests,
              "pids": {k: v["pid"] for k, v in launches.items()},
              "writer_sha256": digest(writer_path), "reader_sha256": digest(reader_path),
              "revisit_sha256": digest(revisit_path), "inventory": writer["inventory"],
              "elapsed": [writer["elapsed_play_seconds"], revisit["elapsed_play_seconds"]],
              "limits": "Requires separate inspected PNG/provenance report for native landing, cancel/recast, bag, pause and live phases."}
    output = run / ("native-audit-" + uuid4().hex + ".json")
    output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": result["status"], "assertions": assertions, "failures": failures, "report": str(output)}))
    if failures: raise SystemExit(1)


if __name__ == "__main__": main()
