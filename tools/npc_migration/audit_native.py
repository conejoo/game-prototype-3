"""N018 read-only native provenance/save audit and labeled contact sheets.

Run after all three owned native processes quit normally. Every assertion reads
captured outputs; this script never seeds or mutates a game or save.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
IDS = {"npc-01", "npc-02", "npc-03", "npc-04", "npc-06", "npc-07", "npc-08", "npc-14"}


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("evidence", type=Path)
    args = parser.parse_args()
    evidence = args.evidence.resolve()
    if not evidence.is_relative_to(ROOT / "docs/evidence/N018"):
        raise ValueError("N018 evidence child required")
    output = evidence / "native-audit.json"
    if output.exists():
        raise ValueError("Fresh audit evidence required; retain prior output")
    failures = []
    assertions = 0

    def check(condition, label):
        nonlocal assertions
        assertions += 1
        if not condition:
            failures.append(label)

    result = {"task": "N018", "proof": "Read-only audit of native public input, GUI saves and actual capture provenance", "phases": {}, "captures": [], "sheets": [], "retained_input_failures": []}
    launches = {}
    for phase in ("writer", "reader", "neutral"):
        folder = evidence / phase
        launch = read(folder / "launch.json")
        launches[phase] = launch
        exit_record = read(folder / "exit.json")
        check(exit_record["pid"] == launch["pid"] and exit_record["exit_code"] == 0, phase + " normal exit")
        exe = Path(launch["exe"])
        check(not exe.resolve().is_relative_to(ROOT), phase + " standalone executable")
        check(Path(launch["cwd"]).resolve() == exe.parent.resolve(), phase + " standalone cwd")
        for key, path in (("release_sha256", exe), ("pack_sha256", exe.with_suffix(".pck")), ("override_sha256", exe.parent / "override.cfg")):
            check(sha(path) == launch[key].lower(), phase + " exact " + key)
        check(launch["arguments"][-2:] == ["--", "--p003-evidence"], phase + " read-only trace argument")
        check(not any(x in launch["arguments"] for x in ("--path", "--input-bridge", "--review", "--fixture")), phase + " no setup/bridge")
        check(Path(launch["APPDATA"]).resolve().is_relative_to(ROOT / "builds/villagers-dialogue/N018"), phase + " isolated appdata")
        text = "\n".join((folder / leaf).read_text(encoding="utf-8-sig", errors="replace") for leaf in ("stdout.log", "stderr.log", "runtime.log"))
        check(not re.search(r"(?m)^(?:ERROR:|WARNING:|SCRIPT ERROR:|FATAL|.*Parse Error:)", text), phase + " clean runtime logs")
        check("P005 save: OK" in text, phase + " GUI save")
        stdout = (folder / "stdout.log").read_text(encoding="utf-8-sig")
        modes = list(re.finditer(r"P001: (Paused|Resumed) at play time ([0-9.]+)s", stdout))
        freeze_pairs = [(before, after) for before, after in zip(modes, modes[1:]) if before[1] == "Paused" and after[1] == "Resumed" and "P005 load: Loaded" not in stdout[before.end():after.start()]]
        check(bool(freeze_pairs) and all(before[2] == after[2] for before, after in freeze_pairs), phase + " logged pause/resume freeze checkpoints (explicit GUI restoration excluded)")
        if phase == "reader":
            check("P005 load: Loaded" in text, "reader actual GUI load")
        requests = []
        captures = {}
        normal_quit = False
        for path in sorted(folder.glob("*.json")):
            if not re.fullmatch(r"[a-f0-9]{32}", path.stem):
                continue
            report = read(path)
            requests.append(report)
            check(not report["cleanup_errors"] and not report["unreleased_keys"] and not report["mouse_unreleased"], phase + " released input " + report["id"])
            if not report["ok"]:
                result["retained_input_failures"].append({"report": str(path.relative_to(evidence)), "error": report["error"], "accepted_as_route_proof": False})
                check("foreground focus" in report["error"], phase + " disclosed recoverable foreground refusal " + report["id"])
            check(report["target_pid"] == launch["pid"] and Path(report["executable"]).resolve() == exe.resolve(), phase + " input owner " + report["id"])
            for row in report["steps"]:
                step = row["step"]
                normal_quit |= step.get("op") == "hold" and "F10" in step.get("keys", [])
                if step.get("op") == "capture":
                    captures[step["label"] + ".png"] = {"report": str(path.relative_to(evidence)), "completed_utc": row["completed_utc"]}
        check(bool(requests) and normal_quit, phase + " public F10 normal quit")
        pngs = sorted(folder.glob("*.png"))
        for path in pngs:
            check(path.name in captures, phase + " capture request " + path.name)
            result["captures"].append({"path": str(path.relative_to(evidence)), "sha256": sha(path), **captures.get(path.name, {})})
        result["phases"][phase] = {"pid": launch["pid"], "requests": len(requests), "captures": len(pngs), "exit_code": exit_record["exit_code"]}
    check(len({x["pid"] for x in launches.values()}) == 3, "three distinct native processes")
    check(launches["writer"]["save_path"] == launches["reader"]["save_path"], "restart shares isolated writer slot")
    check(launches["neutral"]["save_path"] != launches["writer"]["save_path"], "neutral fresh separate slot")
    writer_path = evidence / "writer/40-recovered-save.json"
    reader_path = evidence / "reader/02-restored-save.json"
    writer, reader = read(writer_path), read(reader_path)
    revisit = read(evidence / "reader/20-revisited-save.json")
    neutral = read(evidence / "neutral/20-neutral-save.json")
    civic_baseline = read(evidence / "writer/04-edric-save.json")
    for key in civic_baseline:
        if key not in {"conversations", "elapsed_play_seconds", "environment"}:
            check(neutral[key] == civic_baseline[key], "neutral public chats preserve fresh civic " + key)
    check(writer_path.read_bytes() == reader_path.read_bytes(), "whole GUI restart save bytes exact")
    check(writer == reader, "whole GUI restart state exact")
    oracle = read(evidence / "packed-save-oracle.json")
    check(oracle["typed_snapshot_exact"] and oracle["forecast_exact"] and not oracle["failures"], "packed typed state and forecast exact")
    catalog = read(ROOT / "game/content/npcs/catalog.json")
    expected_facts = set()
    expected_choices = set()
    for package in catalog["packages"]:
        expected_facts.update(k for k, v in package["coverage"]["fact"].items() if v["status"] == "enabled")
        expected_choices.update(k for k, v in package["coverage"]["choice"].items() if v["status"] == "enabled")
    actual_facts, actual_choices = set(), set()
    actual_nodes = set()
    for label, save, affinity in (("writer", writer, 1), ("neutral", neutral, 0)):
        people = save["conversations"]["people"]
        check(set(people) == IDS, label + " exactly eight NPC memories")
        for npc_id, person in people.items():
            check(person["affinity"] == affinity and person["level"] == 0, label + " affinity " + npc_id)
            # Both one-time introductions record one receipt, including zero affinity.
            check(len(person["applied_choice_ids"]) == 1, label + " exclusive reward receipts " + npc_id)
            actual_facts.update(person["learned_fact_ids"])
            actual_nodes.update(person["seen_node_ids"])
        for event in save["conversations"]["events"]["facts"]:
            if event["kind"] == "dialogueChoiceSelected":
                actual_choices.add(event["target_id"])
        check(save["schema_version"] == 7 and save["content_version"] == 1, label + " strict current schema")
    check(actual_facts == expected_facts and len(actual_facts) == 21, "all21 enabled public facts, no deferred fact")
    check(actual_choices == expected_choices and len(actual_choices) == 38, "all38 enabled public choices across native runs")
    for person in revisit["conversations"]["people"].values():
        actual_nodes.update(person["seen_node_ids"])
    expected_nodes = {k for p in catalog["packages"] for k, v in p["coverage"]["node"].items() if v["status"] == "enabled"}
    check(not (actual_nodes - expected_nodes), "native runs entered no deferred node")
    check(actual_nodes == expected_nodes and len(actual_nodes) == 58, "all58 enabled public nodes across native runs")
    result["native_nodes"] = sorted(actual_nodes)
    result["native_nodes_not_visited"] = sorted(expected_nodes - actual_nodes)
    check(len(writer["completed_effect_ids"]) == 6, "six real recovery effects")
    check(writer["actors"][0]["health"] > 0, "native recovered hero alive")
    check(set(revisit["conversations"]["people"]) == IDS, "all-eight revisit memory owners")
    result["revisit_new_seen_nodes"] = {}
    for npc_id, before in writer["conversations"]["people"].items():
        after = revisit["conversations"]["people"][npc_id]
        for key in before:
            if key != "seen_node_ids":
                check(before[key] == after[key], "revisit exact " + npc_id + "/" + key)
        check(set(before["seen_node_ids"]) <= set(after["seen_node_ids"]) <= expected_nodes, "revisit preserves prior seen public nodes " + npc_id)
        result["revisit_new_seen_nodes"][npc_id] = sorted(set(after["seen_node_ids"]) - set(before["seen_node_ids"]))
    for key in ("completed_effect_ids", "quests", "inventory", "collected_resource_ids", "world_item_placements", "light_source_overrides", "progression", "relationship", "actors", "party_member_ids", "location_id", "spawn_id"):
        check(writer[key] == revisit[key], "revisits preserve " + key)
    check(revisit["elapsed_play_seconds"] >= writer["elapsed_play_seconds"], "revisit actual clock monotonic")
    result["save_hashes"] = {str(p.relative_to(evidence)): sha(p) for p in (writer_path, reader_path)}
    result["public_facts"] = sorted(actual_facts)
    result["public_choices"] = sorted(actual_choices)
    result["recovery_effects"] = writer["completed_effect_ids"]
    from PIL import Image, ImageDraw
    sheet_folder = evidence / "sheets"
    sheet_folder.mkdir(exist_ok=False)
    for phase in ("writer", "reader", "neutral"):
        paths = sorted((evidence / phase).glob("*.png"))
        for offset in range(0, len(paths), 12):
            sheet = Image.new("RGB", (1440, 1408), "#192024")
            draw = ImageDraw.Draw(sheet)
            for i, path in enumerate(paths[offset:offset + 12]):
                with Image.open(path) as frame:
                    check(frame.size == (960, 640), "actual client capture size " + path.name)
                    thumbnail = frame.convert("RGB").resize((480, 320))
                x, y = (i % 3) * 480, (i // 3) * 352
                draw.text((x + 4, y + 4), phase + "/" + path.stem, fill="white")
                sheet.paste(thumbnail, (x, y + 28))
            path = sheet_folder / f"{phase}-{offset // 12 + 1:02d}.jpg"
            sheet.save(path, quality=92)
            result["sheets"].append(str(path.relative_to(evidence)))
    result.update(assertions=assertions, failures=failures, status="passed" if not failures else "failed")
    output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": result["status"], "assertions": assertions, "captures": len(result["captures"]), "sheets": len(result["sheets"]), "failures": failures}, indent=2))
    return bool(failures)


if __name__ == "__main__":
    raise SystemExit(main())
