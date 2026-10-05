"""Audit W010 native input/exit/save records and index actual capture timing."""
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
    parser.add_argument("--output-directory", type=Path, help="Fresh caption/audit revision directory; original evidence stays intact")
    args = parser.parse_args()
    run = args.run.resolve()
    destination = args.output_directory.resolve() if args.output_directory else run
    if args.output_directory:
        destination.mkdir(parents=True, exist_ok=False)
    report = {"phases":{}, "failures":[], "captures":[], "contact_sheets":[]}
    output = destination / "native-audit.json"
    if output.exists():
        raise ValueError("Native audit output exists; preserve it")
    for phase in ("writer", "reader"):
        directory = run / phase
        launch = read(directory / "launch.json")
        exit_record = read(directory / "exit.json")
        records = [read(path) for path in directory.glob("*.json")]
        native = [record for record in records if "target_pid" in record]
        log = "\n".join((directory / name).read_text(encoding="utf-8-sig") for name in ("stdout.log", "stderr.log", "runtime.log"))
        errors = re.findall(r"(?m)^\s*(?:SCRIPT ERROR:|ERROR:|WARNING:).*", log)
        report["phases"][phase] = {"launch":launch,"exit":exit_record,"requests":len(native),"input_failures":[r for r in native if not r["ok"]],"runtime_errors":errors}
        if exit_record["exit_code"] != 0 or errors or any(not r["ok"] or r["target_pid"] != launch["pid"] for r in native):
            report["failures"].append(phase + " native runtime/input/exit failed")
        capture_steps = [(step, record["id"]) for record in native for step in record["steps"] if step["step"]["op"] == "capture"]
        for step, request_id in sorted(capture_steps, key=lambda pair:pair[0]["completed_utc"]):
            label = step["step"]["label"]
            path = directory / (label + ".png")
            with Image.open(path) as image:
                size = list(image.size)
                image.verify()
            if size != [960,640]: report["failures"].append("Native viewport differs: " + label)
            timing = "pause overlay" if "paused" in label or label in {"04-maris-approach","08-dock-row-off","10-tollworks-arrival","01-reader-fresh","02-native-load","03-exact-restored-save","04-reader-revisit","05-reader-outdoor","06-reader-final-save","09-independent-lamps-save","18-completed-save","11-native-combat","12-guardian-clear","14-return-path","15-native-return"} else "active or dialogue modal"
            report["captures"].append({"path":str(path),"label":phase+"/"+label,"kind":"native-input","capture_timing":timing,"timestamp":step["completed_utc"],"request_id":request_id,"engine_pid":launch["pid"],"viewport_size":size,"sha256":hashlib.sha256(path.read_bytes()).hexdigest()})
    writer = run / "writer/18-completed-save.json"
    restored = run / "reader/03-exact-restored-save.json"
    initial = read(run / "writer/09-progress-save.json")
    before, after = read(writer), read(run / "reader/06-revisited-save.json")
    report["restart_exact_bytes"] = writer.read_bytes() == restored.read_bytes()
    report["restart_sha256"] = hashlib.sha256(writer.read_bytes()).hexdigest()
    report["separate_process"] = report["phases"]["writer"]["launch"]["pid"] != report["phases"]["reader"]["launch"]["pid"]
    report["seed_retained"] = initial["environment"]["weather_seed"] == before["environment"]["weather_seed"] == after["environment"]["weather_seed"]
    report["clock_progression"] = [initial["environment"], before["environment"], after["environment"]]
    report["elapsed_progression"] = [initial["elapsed_play_seconds"], before["elapsed_play_seconds"], after["elapsed_play_seconds"]]
    def minutes(save):
        return 1440 * (save["environment"]["day_index"] + save["environment"]["day_cycle_progress"])
    report["natural_clock_monotonic"] = minutes(initial) < minutes(before) < minutes(after)
    report["saved_facts"] = before.copy()
    for save in (before, after):
        save.pop("environment")
        save.pop("elapsed_play_seconds")
    report["revisit_other_facts_exact"] = before == after
    for gate in ("restart_exact_bytes","separate_process","seed_retained","natural_clock_monotonic","revisit_other_facts_exact"):
        if not report[gate]: report["failures"].append(gate)
    font = ImageFont.load_default(size=17)
    for offset in range(0,len(report["captures"]),12):
        captures = report["captures"][offset:offset+12]
        sheet = Image.new("RGB",(1440,4*365+36),"#101820")
        draw = ImageDraw.Draw(sheet)
        draw.text((10,8),"W010 ordinary native input; active captures followed by inspected pauses",font=font,fill="white")
        for index, capture in enumerate(captures):
            x,y=(index%3)*480,36+(index//3)*365
            with Image.open(capture["path"]) as image:
                image.thumbnail((474,316))
                sheet.paste(image,(x+3,y))
            draw.text((x+4,y+321),capture["label"],font=font,fill="white")
            draw.text((x+4,y+344),capture["capture_timing"],font=font,fill="#c0ccd8")
        path = destination / f"native-contact-{offset//12+1:02d}.png"
        if path.exists(): raise ValueError("Contact sheet exists; preserve it")
        sheet.save(path)
        report["contact_sheets"].append(str(path))
    report["status"] = "passed" if not report["failures"] else "failed"
    output.write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({"report":str(output),"status":report["status"],"captures":len(report["captures"]),"sheets":report["contact_sheets"],"failures":report["failures"]}))
    if report["failures"]: raise SystemExit(1)


if __name__ == "__main__":
    main()
