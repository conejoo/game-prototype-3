"""Read-only G009 native provenance, GUI save and contact-sheet audit.

Does not drive input, change live state or replace evidence. Packed production
codec/forecast comparison and human image review remain separate required gates.
"""
import hashlib
import json
import re
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]


def main():
    base = Path(sys.argv[1]).resolve()
    allowed = ROOT / "docs/evidence/G009"
    if not base.is_relative_to(allowed) or base == allowed:
        raise ValueError("G009 run-child required")
    if (base / "native-audit.json").exists() or (base / "sheets").exists():
        raise ValueError("Refusing evidence overwrite")
    failures, captures, launches = [], [], {}
    assertions = 0

    def check(value, message):
        nonlocal assertions
        assertions += 1
        if not value:
            failures.append(message)

    def read(path):
        return json.loads(path.read_text(encoding="utf-8-sig"))

    for phase in ("writer", "reader", "neutral"):
        folder = base / phase
        launch = read(folder / "launch.json")
        launches[phase] = launch
        check(launch["task"] == "G009" and launch["phase"] == phase, phase + " launch identity")
        check(not Path(launch["cwd"]).is_relative_to(ROOT), phase + " outside checkout")
        check("--path" not in launch["arguments"] and "--playtest-dir" not in str(launch), phase + " no bridge")
        for field, name in (("release_sha256", "ReturningFair.exe"), ("pack_sha256", "ReturningFair.pck"), ("override_sha256", "override.cfg")):
            expected = hashlib.sha256((ROOT / "builds/windows" / name).read_bytes()).hexdigest()
            check(launch[field].lower() == expected, phase + " package " + field)
        exit_info = read(folder / "exit.json")
        check(exit_info["pid"] == launch["pid"] and exit_info["exit_code"] == 0, phase + " normal exit")
        for log in ("stdout.log", "stderr.log", "runtime.log"):
            text = (folder / log).read_text(encoding="utf-8-sig", errors="replace")
            check(not re.search(r"(?m)^\s*(SCRIPT ERROR:|ERROR:|WARNING:)", text), phase + " clean " + log)
        images = set()
        for path in sorted(folder.glob("*.json")):
            row = read(path)
            if row.get("schema_version") != 2 or "target_pid" not in row:
                continue
            check(row["target_pid"] == launch["pid"] and row["executable"] == launch["exe"], path.name + " owned PID")
            check(not row["cleanup_errors"] and not row["unreleased_keys"] and not row["mouse_unreleased"], path.name + " released input")
            # Guard refusals stay failed, but cannot prove gameplay. No failed input
            # step is silently upgraded by this audit.
            if not row["ok"]:
                check(not row["steps"], path.name + " failed request sent partial input; review required")
                continue
            for step in row["steps"]:
                check(step["ok"], path.name + " successful step")
                command = step.get("step", step.get("command", step))
                if command.get("op") == "capture":
                    images.add(command["label"] + ".png")
        # Every image must be tied to an actual successful native capture request.
        for path in sorted(folder.glob("*.png")):
            check(path.name in images, phase + " orphan capture " + path.name)
            with Image.open(path) as image:
                check(image.size == (960, 640), phase + " client size " + path.name)
            captures.append({"phase": phase, "path": str(path), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
    check(launches["writer"]["pid"] != launches["reader"]["pid"], "separate writer/reader processes")
    check(launches["writer"]["APPDATA"] == launches["reader"]["APPDATA"], "explicit shared restart group")
    check(launches["neutral"]["APPDATA"] != launches["writer"]["APPDATA"], "independent neutral group")
    saves = {key: read(base / phase / name) for key, phase, name in (
        ("writer", "writer", "writer-recovered-save.json"),
        ("reader", "reader", "reader-restored-save.json"),
        ("revisit", "reader", "reader-revisited-save.json"),
        ("neutral", "neutral", "neutral-social-save.json"))}
    check(saves["writer"] == saves["reader"], "whole paused save equality")
    pre_recovery = read(base / "writer/social-before-recovery-save.json")
    for field in ("inventory", "collected_resource_ids", "world_item_placements"):
        check(pre_recovery[field] == saves["writer"][field], "recovery conserves " + field)
    check(pre_recovery["conversations"]["people"] == saves["writer"]["conversations"]["people"], "recovery conserves people")
    check([row for row in pre_recovery["conversations"]["events"]["facts"] if row["kind"] == "itemGifted"] ==
          [row for row in saves["writer"]["conversations"]["events"]["facts"] if row["kind"] == "itemGifted"], "recovery conserves exact gift endpoints")
    check((base / "writer/writer-recovered-save.json").read_bytes() == (base / "reader/reader-restored-save.json").read_bytes(), "paused exact bytes")
    oracle = read(base / "packed-save-oracle.json")
    check(oracle.get("typed_snapshot_exact") and oracle.get("forecast_exact") and not oracle["failures"], "packed typed/forecast oracle")
    for key, save in saves.items():
        check(save["schema_version"] == 8 and save["content_version"] == 1, key + " supported format")
        people = save["conversations"]["people"]
        edric = people["npc-01"]
        neutral = key == "neutral"
        check(edric["affinity"] == (2 if neutral else 3) and edric["level"] == (0 if neutral else 1), key + " Edric affinity/level")
        check(edric["applied_choice_ids"] == (["npc-01-neutral-response"] if neutral else ["npc-01-helpful-response"]), key + " actual positive/neutral introduction")
        check(edric["learned_fact_ids"] == ["npc-01-moonflower-preference"], key + " learned preference")
        check(edric["seen_node_ids"].count("npc-01-level-1-milestone") == (0 if neutral else 1), key + " one milestone")
        check(("relationshipLevel1Seen" in edric["flags"]) == (not neutral), key + " milestone flag")
        events = save["conversations"]["events"]["facts"]
        gifts = {event["target_id"]: event["count"] for event in events if event["kind"] == "itemGifted"}
        check(gifts == ({"npc-01": 2} if neutral else {"npc-01": 2, "npc-03": 1}), key + " gift counts")
        check(save["inventory"]["item_counts"].get("item-moonflower", 0) == 0, key + " consumed inventory")
        check(sorted(save["collected_resource_ids"]) == (["moonflower-01", "moonflower-02"] if neutral else ["moonflower-01", "moonflower-02", "moonflower-03"]), key + " finite collected supply")
        if not neutral:
            check(people["npc-03"]["affinity"] == 2, key + " independent Maris")
            check(len(save["completed_effect_ids"]) == 6 and save["progression"]["upgrade_ids"] == ["prototype-deliberate-strike"], key + " full recovery/upgrade")
            check(save["relationship"]["trust"] == 0 and len(save["party_member_ids"]) == 2, key + " separate trust/party")
        else:
            check(not save["completed_effect_ids"] and not save["progression"]["upgrade_ids"], "neutral fresh quest/progression")
            check(all(not person["seen_node_ids"] for npc, person in people.items() if npc != "npc-01"), "neutral met-only Edric")
    for field in saves["writer"]:
        if field not in ("elapsed_play_seconds", "environment", "conversations"):
            check(saves["writer"][field] == saves["revisit"][field], "revisit old field " + field)
    check(saves["writer"]["conversations"]["people"] == saves["revisit"]["conversations"]["people"], "revisit people exact")
    check(saves["revisit"]["elapsed_play_seconds"] >= saves["writer"]["elapsed_play_seconds"], "legitimate walking time")
    writer_events = saves["writer"]["conversations"]["events"]
    revisit_events = saves["revisit"]["conversations"]["events"]
    check([e for e in writer_events["facts"] if e["kind"] != "areaEntered"] ==
          [e for e in revisit_events["facts"] if e["kind"] != "areaEntered"], "revisit gift/choice/gather endpoints exact")
    walking_changes = {"elapsed_before": saves["writer"]["elapsed_play_seconds"],
                       "elapsed_after": saves["revisit"]["elapsed_play_seconds"],
                       "area_before": [e for e in writer_events["facts"] if e["kind"] == "areaEntered"],
                       "area_after": [e for e in revisit_events["facts"] if e["kind"] == "areaEntered"],
                       "environment_before": saves["writer"]["environment"],
                       "environment_after": saves["revisit"]["environment"]}
    sheets = base / "sheets"
    sheets.mkdir()
    sheet_paths = []
    for offset in range(0, len(captures), 12):
        subset = captures[offset:offset + 12]
        sheet = Image.new("RGB", (1280, 3 * 244), "#152022")
        draw = ImageDraw.Draw(sheet)
        for index, row in enumerate(subset):
            x, y = (index % 4) * 320, (index // 4) * 244
            with Image.open(row["path"]) as image:
                image.thumbnail((320, 213)); sheet.paste(image, (x, y))
            draw.text((x + 3, y + 214), row["phase"] + ": " + Path(row["path"]).stem[:44], fill="white")
        path = sheets / ("sheet-%02d.png" % (offset // 12 + 1))
        sheet.save(path); sheet_paths.append(str(path))
    result = {"task": "G009", "status": "failed" if failures else "passed", "assertions": assertions,
              "failures": failures, "captures": captures, "sheets": sheet_paths, "walking_changes": walking_changes,
              "visual_review": "Required separately; data audit never establishes image inspection"}
    (base / "native-audit.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": result["status"], "assertions": assertions, "captures": len(captures), "failures": failures}))
    return bool(failures)


if __name__ == "__main__":
    sys.exit(main())
