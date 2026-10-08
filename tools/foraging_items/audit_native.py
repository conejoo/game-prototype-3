"""Read-only F010 native records/save oracle; creates a fresh derived review."""
import argparse
import hashlib
import json
import re
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument("run", type=Path)
    parser.add_argument("--output-directory", type=Path, required=True)
    args = parser.parse_args()
    run = args.run.resolve()
    destination = args.output_directory.resolve()
    destination.mkdir(parents=True, exist_ok=False)
    report = {"phases": {}, "failures": [], "captures": [], "contact_sheets": []}
    correction = read(run / "launch-correction.json") if (run / "launch-correction.json").exists() else None
    report["launch_correction"] = correction

    def check(ok, label):
        if not ok:
            report["failures"].append(label)

    for phase in ("writer", "reader"):
        directory = run / phase
        launch, exit_record = read(directory / "launch.json"), read(directory / "exit.json")
        native = [read(path) for path in directory.glob("*.json") if "target_pid" in read(path)]
        log = "\n".join((directory / name).read_text(encoding="utf-8-sig") for name in ("stdout.log", "stderr.log", "runtime.log"))
        errors = re.findall(r"(?m)^\s*(?:SCRIPT ERROR:|ERROR:|WARNING:).*", log)
        # A sandbox-only preflight could not see the desktop and sent no input.
        refusals = [r for r in native if r["target_pid"] == launch["pid"] and not r["ok"] and not r["steps"] and
                    "Expected exactly one release game window; found 0" in (r["error"] or "") and
                    not r["cleanup_errors"] and not r["unreleased_keys"] and not r["mouse_unreleased"]]
        # Retain the observed pause-toggle focus stop separately. Its ESC press
        # reached the game, cleanup released it, and a fresh inspected checkpoint
        # precedes retry. It is not a successful gameplay or arrival request.
        focus_stops = [r for r in native if r["target_pid"] == launch["pid"] and not r["ok"] and r.get("failed_step") == 0 and
                       "Release lost foreground focus; stopped." in (r["error"] or "") and
                       len(r["steps"]) == 1 and not r["steps"][0]["ok"] and
                       r["steps"][0]["step"] == {"op": "hold", "keys": ["ESC"], "duration_ms": 60} and
                       not r["cleanup_errors"] and not r["unreleased_keys"] and not r["mouse_unreleased"]]
        executed = [r for r in native if r not in refusals and r not in focus_stops]
        check(exit_record["pid"] == launch["pid"] and exit_record["exit_code"] == 0 and not errors, phase + " clean owned runtime/exit")
        check("P001: Quit requested while paused." in log, phase + " normal paused F10 quit")
        check(all(r["ok"] and r["target_pid"] == launch["pid"] and not r["cleanup_errors"] and
                  not r["unreleased_keys"] and not r["mouse_unreleased"] for r in executed), phase + " guarded input/cleanup")
        check(all(Path(r["executable"]) == Path(launch["exe"]) for r in native), phase + " guarded executable identity")
        actual_cwd = correction["actual_cwd"] if correction else launch["cwd"]
        check(not Path(actual_cwd).is_relative_to(Path(__file__).resolve().parents[2]), phase + " outside-checkout cwd")
        check(not any("--path" in a or "playtest-dir" in a or "review=" in a or "fixture" in a for a in launch["arguments"]), phase + " ordinary release arguments")
        report["phases"][phase] = {"launch": launch, "exit": exit_record, "requests": len(executed),
                                     "retained_no_input_refusals": refusals, "retained_focus_guard_stops": focus_stops,
                                     "runtime_diagnostics": errors}
        captures = [(step, r["id"]) for r in executed for step in r["steps"] if step["step"]["op"] == "capture"]
        for step, request_id in sorted(captures, key=lambda pair: pair[0]["completed_utc"]):
            label = step["step"]["label"]
            path = directory / (label + ".png")
            with Image.open(path) as picture:
                size = list(picture.size)
                picture.verify()
            check(size == [960, 640], phase + "/" + label + " client size")
            timing = "pause checkpoint (visually reviewed)" if "paused" in label else "active or modal; inspect image"
            if label == "17b-focus-refusal-observed-paused":
                timing = "active world; retained incorrect filename after focus stop"
            if label == "38-tollworks-paused":
                timing = "paused during pending travel; does not establish arrival"
            report["captures"].append({"path": str(path), "label": phase + "/" + label,
                "kind": "native-client", "completed_utc": step["completed_utc"], "request_id": request_id,
                "engine_pid": launch["pid"], "viewport_size": size, "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                "timing": timing})
    before_path, after_path = run / "writer/40-final-save.json", run / "reader/03-restored-save.json"
    before, restored, revisited = read(before_path), read(after_path), read(run / "reader/20-revisited-save.json")
    report["restart_exact_bytes"] = before_path.read_bytes() == after_path.read_bytes()
    report["restart_sha256"] = hashlib.sha256(before_path.read_bytes()).hexdigest()
    report["separate_processes"] = report["phases"]["writer"]["launch"]["pid"] != report["phases"]["reader"]["launch"]["pid"]
    writer_launch, reader_launch = (report["phases"][phase]["launch"] for phase in ("writer", "reader"))
    check(all(writer_launch[key] == reader_launch[key] for key in
              ("release_sha256", "pack_sha256", "override_sha256", "APPDATA", "LOCALAPPDATA", "save_path")),
          "same native package/isolated pair identity")
    for field in ("restart_exact_bytes", "separate_processes"):
        check(report[field], field)
    report["packed_typed_oracle"] = read(run / "save-oracle.json")
    check(not report["packed_typed_oracle"]["failures"] and report["packed_typed_oracle"]["typed_snapshot_exact"] and
          report["packed_typed_oracle"]["forecast_exact"], "packed production typed save/forecast replay")
    check(before["schema_version"] == 6 and before["content_version"] == 1, "schema6/content1")
    check(before["inventory"] == {"active_item_id": "item-moonflower", "item_counts": {"item-moonflower": 3}}, "saved active flower/count3")
    origins = ["fishing-rod-dock-01", "moonflower-01", "moonflower-02", "moonflower-03"]
    check(before["collected_resource_ids"] == origins, "all four collected origins")
    placements = before["world_item_placements"]
    check(len(placements) == 1 and placements[0]["instance_id"] == "dropped-fishing_rod" and
          placements[0]["item_id"] == "item-fishing-rod" and placements[0]["provenance"] == "generated_drop", "one saved world rod")
    check(before["quests"]["prototype-maris-recovery"] == ["maris-lead", "maris-expedition", "maris-guardian"], "native quest/travel/combat facts")
    check(any(row["prop_id"] == "dock-lamp-02" and row["enabled"] for row in before["light_source_overrides"]), "native lamp override")
    check(revisited["inventory"] == {"active_item_id": "item-fishing-rod", "item_counts": {"item-fishing-rod": 1, "item-moonflower": 3}}, "restored rod recollected/active count1")
    check(not revisited["world_item_placements"] and revisited["collected_resource_ids"] == origins, "revisit preserves absent origins/unique rod")
    prior_fields = set(before) - {"inventory", "world_item_placements", "elapsed_play_seconds", "environment"}
    check(all(before[key] == revisited[key] for key in prior_fields), "prior durable facts preserved during revisit")
    check(before["environment"]["weather_seed"] == revisited["environment"]["weather_seed"], "forecast seed preserved")
    check(before["elapsed_play_seconds"] < revisited["elapsed_play_seconds"], "ordinary revisit advances time")
    dropped = read(run / "writer/10-dropped-save.json")["world_item_placements"]
    dragged_path = run / "writer/12b-dragged-save.json"
    if not dragged_path.exists():
        dragged_path = run / "writer/12-dragged-save.json"
    dragged = read(dragged_path)["world_item_placements"]
    invalid = read(run / "writer/14-invalid-save.json")["world_item_placements"]
    check(dropped != dragged and dragged == invalid, "native valid drag commits/invalid-water rollback exact")
    report["saved_facts"], report["revisited_facts"] = before, revisited
    font = ImageFont.load_default(size=16)
    for offset in range(0, len(report["captures"]), 12):
        sheet = Image.new("RGB", (1440, 1496), "#101820")
        draw = ImageDraw.Draw(sheet)
        draw.text((10, 8), "F010 ordinary native client input; timing reviewed separately", font=font, fill="white")
        for index, capture in enumerate(report["captures"][offset:offset+12]):
            x, y = (index % 3) * 480, 36 + (index // 3) * 365
            with Image.open(capture["path"]) as picture:
                picture.thumbnail((474, 316))
                sheet.paste(picture, (x+3, y))
            draw.text((x+4, y+321), capture["label"], font=font, fill="white")
            draw.text((x+4, y+344), capture["timing"], font=font, fill="#c0ccd8")
        path = destination / f"native-contact-{offset//12+1:02d}.png"
        sheet.save(path)
        report["contact_sheets"].append(str(path))
    report["status"] = "passed" if not report["failures"] else "failed"
    output = destination / "native-audit.json"
    output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"report": str(output), "status": report["status"], "captures": len(report["captures"]),
                      "sheets": report["contact_sheets"], "failures": report["failures"]}))
    if report["failures"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
