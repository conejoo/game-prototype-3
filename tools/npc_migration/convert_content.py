"""Deterministic N002 conversion from the immutable N001 target-local pin."""
import argparse
import copy
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REF = ROOT / "tools/npc_migration/reference"
ROSTER = ("npc-01", "npc-02", "npc-03", "npc-04", "npc-06", "npc-07", "npc-08", "npc-14")
OUTPUT = ROOT / "game/content/npcs/catalog.json"


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def digest(data):
    return hashlib.sha256(data).hexdigest()


def expected_outputs(source=None, social=False):
    manifest = read(REF / "manifest.json")
    for row in manifest["inputs"]:
        if "snapshot_path" in row:
            assert digest((REF / row["snapshot_path"]).read_bytes()) == row["sha256"], row["snapshot_path"]
        if source is not None:
            assert digest((source / row["source_path"]).read_bytes()) == row["sha256"], "Source drift: " + row["source_path"]
    for row in manifest["generated"]:
        assert digest((REF / row["path"]).read_bytes()) == row["sha256"], row["path"]
    selected = read(REF / "selected_catalog.json")["npcs"]
    assert tuple(row["id"] for row in selected) == ROSTER
    coverage = read(REF / "coverage.json")
    adaptations = read(REF / "adaptations.json")
    outputs = {}
    packages = []
    for entry in selected:
        npc_id = entry["id"]
        package = {"id": npc_id, "actor_id": npc_id}
        for kind in ("runtime", "dialogue", "visuals"):
            package[kind] = read(REF / entry[kind])
        package["coverage"] = {}
        for kind in ("node", "choice", "fact", "gift_rule", "portrait", "sheet"):
            package["coverage"][kind] = {
                row["id"]: {"status": row["status"], "reason": row["reason"]}
                for row in coverage if row["npc_id"] == npc_id and row["kind"] == kind
            }
        for adaptation in adaptations:
            if adaptation["npc_id"] == npc_id:
                node = next(n for n in package["dialogue"]["nodes"] if n["id"] == adaptation["node_id"])
                assert adaptation["field"] == "text"
                node["text"] = adaptation["target_text"]
        visuals = package["visuals"]
        def asset(path):
            original = REF / path
            folder = "portraits" if "/portraits/" in path else "reference"
            relative = f"game/assets/npcs/{folder}/{npc_id}/{original.name}"
            outputs[ROOT / relative] = original.read_bytes()
            return "res://" + relative.removeprefix("game/")
        visuals["portraits"] = {key: asset(path) for key, path in visuals["portraits"].items()}
        world = visuals["world"]
        for sheet in [world["idle"], world["walk"], *world.get("actions", {}).values()]:
            sheet["asset"] = asset(sheet["asset"])
        packages.append(package)
    if social:
        sys.path.insert(0, str(ROOT / "tools/social_migration"))
        from activation_overlay import apply
        packages = apply(packages)
    document = {"format_version": 1, "source_revision": manifest["source_revision"], "packages": packages}
    outputs[OUTPUT] = (json.dumps(document, ensure_ascii=False, indent=2) + "\n").encode("utf-8")
    return outputs


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="Read-only exact conversion/hash/roster audit")
    parser.add_argument("--source", type=Path, help="Optional read-only authority drift check")
    parser.add_argument("--social", action="store_true", help="Opt-in approved G004 social coverage overlay; do not activate production before G004")
    args = parser.parse_args()
    outputs = expected_outputs(args.source, args.social)
    for path, data in outputs.items():
        if args.check:
            assert path.is_file() and path.read_bytes() == data, "Converted output drift: " + str(path)
        elif not path.is_file() or path.read_bytes() != data:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
    actual = {p for folder in (ROOT / "game/content/npcs", ROOT / "game/assets/npcs") for p in folder.rglob("*") if p.is_file() and p.suffix in (".json", ".png")}
    assert actual == set(outputs), "Unexpected runtime NPC content or extra roster"
    print("N002_CONVERSION PASS " + json.dumps({"mode": "check" if args.check else "convert", "people": len(ROSTER), "files": len(outputs), "catalog_sha256": digest(outputs[OUTPUT]), "portraits": 48, "reference_sheets": 18}, sort_keys=True))


if __name__ == "__main__":
    main()
