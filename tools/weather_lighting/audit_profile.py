"""Independently recompute W009 nearest-rank gates from retained raw CSV files."""
import argparse
import csv
import hashlib
import json
import math
from pathlib import Path


def percentile(values, fraction):
    return sorted(values)[math.ceil(len(values) * fraction) - 1]


def audit(directory, baseline=None, storm_baseline=None):
    report = json.loads((directory / "render/report.json").read_text(encoding="utf-8"))
    process = json.loads((directory / "process-results.json").read_text(encoding="utf-8"))
    settings = report["settings"]
    errors = []
    def require(ok, message):
        if not ok:
            errors.append(message)
    require(not process["smoke"] and report["acceptance_duration"], "smoke/short duration cannot certify performance")
    require(process["engine_exit"] == 0 and not process["runtime_errors"] and not process["failure"], "runtime failed")
    require(settings["pid"] == process["engine_pid"] > 0, "actual engine PID mismatch")
    require(settings["renderer"] == "gl_compatibility" and settings["viewport"] == [960, 640] and settings["vsync_mode"] == 0 and settings["max_fps"] == 0 and settings["projection"] == "orthographic" and settings["zoom"] == 1.0, "M018 settings mismatch")
    require(settings["warmup_seconds"] >= 10 and settings["run_seconds"] >= 60 and settings["runs_per_view_condition"] == 3, "measurement windows mismatch")
    require(not report["failures"], "engine acceptance failures")
    records = [(directory, row) for row in report["views"]]
    sources = [{"directory":str(directory), "engine_pid":process["engine_pid"], "selection":"all" if baseline is None else "storm-night"}]
    if baseline is not None:
        original = json.loads((baseline / "render/report.json").read_text(encoding="utf-8"))
        original_process = json.loads((baseline / "process-results.json").read_text(encoding="utf-8"))
        original_settings = original["settings"]
        fault_rows = [row for row in original["views"] if row["focused_samples"] != row["samples"]]
        focus_faults = [f"Focus lost during sample {row['view']}/{row['run']}" for row in fault_rows]
        require(bool(fault_rows) and all(row["view"].endswith("storm-night-all-lamps") for row in fault_rows), "baseline failures outside replaced storm windows")
        require(sorted(original["failures"]) == sorted(focus_faults) and sorted(original_process["runtime_errors"]) == sorted("ERROR: " + fault for fault in focus_faults), "baseline has non-focus diagnostic/failure")
        require(original_process["engine_exit"] == 1 and original_process["failure"] == "Runtime diagnostic; see retained log" and not original_process["smoke"] and original["acceptance_duration"] and original_process["memory_pass"], "baseline incomplete or failed for another cause")
        require(original_settings["pid"] == original_process["engine_pid"] > 0, "baseline PID mismatch")
        for field in ("renderer", "viewport", "vsync_mode", "max_fps", "projection", "zoom", "warmup_seconds", "run_seconds", "runs_per_view_condition", "adapter", "api"):
            require(original_settings[field] == settings[field], "baseline/retest settings differ: " + field)
        require(json.loads((baseline / "hardware.json").read_text()) == json.loads((directory / "hardware.json").read_text()), "baseline/retest hardware differs")
        if storm_baseline is None:
            require(report.get("conditions") == [3] and len(report["views"]) == 12 and all(row["view"].endswith("storm-night-all-lamps") for row in report["views"]), "retest must contain all twelve storm windows")
        else:
            require(report.get("conditions") == [3] and report.get("views_requested") == ["ford-west"] and len(report["views"]) == 3 and all(row["view"] == "ford-west-storm-night-all-lamps" for row in report["views"]), "final retest must contain all three ford windows")
            storm = json.loads((storm_baseline / "render/report.json").read_text(encoding="utf-8"))
            storm_process = json.loads((storm_baseline / "process-results.json").read_text(encoding="utf-8"))
            storm_fault_rows = [row for row in storm["views"] if row["focused_samples"] != row["samples"]]
            storm_faults = [f"Focus lost during sample {row['view']}/{row['run']}" for row in storm_fault_rows]
            require(bool(storm_fault_rows) and all(row["view"] == "ford-west-storm-night-all-lamps" for row in storm_fault_rows), "storm baseline failed outside replaced ford windows")
            require(sorted(storm["failures"]) == sorted(storm_faults) and sorted(storm_process["runtime_errors"]) == sorted("ERROR: " + fault for fault in storm_faults), "storm baseline has non-focus failures")
            require(storm_process["engine_exit"] == 1 and storm_process["failure"] == "Runtime diagnostic; see retained log" and not storm_process["smoke"], "storm baseline runtime mismatch")
            require(storm["settings"]["pid"] == storm_process["engine_pid"] > 0 and storm.get("conditions") == [3], "storm baseline PID/conditions mismatch")
            for field in ("renderer", "viewport", "vsync_mode", "max_fps", "projection", "zoom", "warmup_seconds", "run_seconds", "runs_per_view_condition", "adapter", "api"):
                require(storm["settings"][field] == settings[field], "storm baseline/retest settings differ: " + field)
            require(json.loads((storm_baseline / "hardware.json").read_text()) == json.loads((directory / "hardware.json").read_text()), "storm baseline/retest hardware differs")
            accepted_storm = [row for row in storm["views"] if row["view"] != "ford-west-storm-night-all-lamps"]
            require(len(accepted_storm) == 9, "storm baseline coverage incomplete")
            records = [(storm_baseline, row) for row in accepted_storm] + records
            sources.append({"directory":str(storm_baseline), "engine_pid":storm_process["engine_pid"], "selection":"nine focused town/forest/bridge storm windows only", "retained_failures":storm_faults})
        accepted_clear = [row for row in original["views"] if row["view"].endswith("clear-day")]
        require(len(original["views"]) == 24 and len(accepted_clear) == 12, "baseline clear-day coverage incomplete")
        records = [(baseline, row) for row in accepted_clear] + records
        sources.append({"directory":str(baseline), "engine_pid":original_process["engine_pid"], "selection":"twelve focused clear-day windows only", "retained_failures":focus_faults})
    expected = {(view + "-" + condition, run) for view in ("maris", "dense-forest", "bridge-west", "ford-west") for condition in ("clear-day", "storm-night-all-lamps") for run in range(3)}
    actual = {(row["view"], row["run"]) for source, row in records}
    require(actual == expected and len(records) == 24, "missing/duplicate measurement rows")
    rows = []
    for source, row in records:
        path = source / "render" / f"{row['view']}-{row['run']}.csv"
        with path.open(encoding="utf-8") as csv_source:
            samples = list(csv.DictReader(csv_source))
        frames = [float(x["interval_ms"]) for x in samples]
        draws = [int(x["total_draw_calls"]) for x in samples]
        measured = {"p95":percentile(frames, .95), "p99":percentile(frames, .99), "draw_p95":percentile(draws, .95)}
        require(len(samples) == row["samples"] == row["focused_samples"] and row["seconds"] >= 60, "sample/focus/duration mismatch " + path.name)
        require([int(x["frame"]) for x in samples] == list(range(len(samples))), "raw frame sequence mismatch " + path.name)
        require(all(x > 0 for x in frames) and math.isclose(sum(frames)/1000, row["seconds"], abs_tol=1e-5), "raw cadence duration mismatch " + path.name)
        for field, recorded in (("p95", "frame_p95_ms"), ("p99", "frame_p99_ms"), ("draw_p95", "draw_p95")):
            require(math.isclose(measured[field], row[recorded], abs_tol=1e-6), "percentile mismatch " + path.name + "/" + field)
        require(measured["p95"] <= 16.67 and measured["p99"] <= 25 and measured["draw_p95"] <= 500, "budget failed " + path.name)
        condition = 0 if row["view"].endswith("clear-day") else 3
        require(row["environment_start"] == row["environment_end"] and row["environment_start"]["condition"] == condition and row["environment_start"]["blend"] == 1, "weather drift " + path.name)
        require(row["local_emitters"] == 8 and row["rain_batches"] <= 64, "effect bound mismatch " + path.name)
        rows.append({"view":row["view"], "run":row["run"], **measured, "source":str(source), "sha256":hashlib.sha256(path.read_bytes()).hexdigest()})
    checkpoints = report["lifecycle"]
    require(len(checkpoints) == 2 and [x["trip"] for x in checkpoints] == [1, 11], "travel window mismatch")
    if len(checkpoints) == 2:
        for field in ("nodes", "objects", "resources", "orphan_nodes", "regions", "world_children", "party"):
            require(checkpoints[0][field] == checkpoints[1][field], "lifecycle count growth: " + field)
        require(checkpoints[1]["orphan_nodes"] == 0 and checkpoints[1]["regions"] == 1 and checkpoints[1]["world_children"] == 1 and checkpoints[1]["party"] == 2, "ownership invariant failed")
    require(len(report["loads"]) == 24 and len(report["effect_counts"]) == 2 and report["effect_counts"][0] == report["effect_counts"][1], "repeated travel/effect counts failed")
    require(report["initial_inventory"] == report["final_inventory"], "art/physics inventory changed")
    with (directory / "working-set.csv").open(encoding="utf-8") as source:
        memory = list(csv.DictReader(source))
    baseline = [int(x["working_set_bytes"]) for x in memory if x["stage"] == "checkpoint-baseline"]
    final = [int(x["working_set_bytes"]) for x in memory if x["stage"] == "checkpoint-final"]
    peak = max(int(x["peak_working_set_bytes"]) for x in memory)
    growth = max(final) - max(baseline) if baseline and final else None
    require(baseline == process["baseline_working_set_bytes"] and final == process["final_working_set_bytes"] and peak == process["peak_working_set_bytes"] and growth == process["growth_bytes"], "raw memory/report mismatch")
    require(peak <= 2*1024**3 and growth is not None and growth <= 64*1024**2 and process["memory_pass"], "memory budget failed")
    return {"status":"failed" if errors else "passed", "errors":errors, "rows":rows, "sources":sources, "peak_bytes":peak, "growth_bytes":growth, "engine_pid":process["engine_pid"]}


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("--baseline", type=Path, help="Retained full attempt: accept only its focused clear-day windows; replace all storm windows with a complete focused retest")
    parser.add_argument("--storm-baseline", type=Path, help="Retained storm attempt: accept only its nine focused town/forest/bridge windows; replace all ford windows with a complete focused retest")
    parser.add_argument("--name", default="raw-audit.json", help="Fresh output filename; existing audit files are never overwritten")
    args = parser.parse_args()
    if args.storm_baseline is not None and args.baseline is None:
        parser.error("--storm-baseline requires --baseline")
    if Path(args.name).name != args.name or not args.name.endswith(".json"):
        parser.error("--name must be a JSON filename within the evidence directory")
    result = audit(args.directory, args.baseline, args.storm_baseline)
    target = args.directory / args.name
    with target.open("x", encoding="utf-8") as output:
        json.dump(result, output, indent=2)
        output.write("\n")
    print(json.dumps({key:value for key,value in result.items() if key != "rows"}))
    return 0 if result["status"] == "passed" else 1


if __name__ == "__main__":
    raise SystemExit(main())
