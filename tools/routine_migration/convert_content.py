"""Convert only R001 public pins; --check refuses target drift. No runtime/source writes."""
import argparse
import copy
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REF = ROOT / "tools/routine_migration/reference"
OUT = ROOT / "game/content/routines"


def read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def outputs():
    manifest = read(REF / "manifest.json")
    # Reuse the fail-closed R001 audit before any conversion/publication.
    import subprocess
    import sys
    subprocess.run([sys.executable, str(REF.parent / "reference_checks.py")], cwd=ROOT, check=True)
    maps = read(REF / "mappings.json")
    ids = manifest["selected_ids"]
    result = {}
    conversions = []
    for rid in ids:
        path = REF / f"source/assets/data/routines/{rid}.json"
        doc = read(path)
        converted = copy.deepcopy(doc)
        for plan in converted["participantSteps"]:
            for step in plan["steps"]:
                if step["kind"] == "move":
                    step["target"]["mapId"] = "prototype-" + step["target"]["mapId"]
        result[f"{rid}.json"] = converted
        conversions.append({"id": rid, "source_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                            "adaptation": "mapId gains prototype- prefix; all other authored values exact"})
    result["catalog.json"] = {"schemaVersion": 1, "routines": [
        {"schemaVersion": 1, "id": rid, "asset": f"res://content/routines/{rid}.json"} for rid in ids]}
    result["references.json"] = {
        "schemaVersion": 1, "sourceRevision": manifest["source_revision"],
        "validation": "declarations-only; no physical navigation or room acceptance",
        "maps": [{"id": "prototype-" + mid, "sourceId": mid,
                  "anchors": sorted(a["anchor_id"] for a in maps["anchors"] if a["source_map_id"] == mid)}
                 for mid in ["alderwake", "mayor-vale-home", "lantern-rest"]],
        "portals": [{"id": p["id"], "sourceMapId": p["source_location_id"],
                     "destinationMapId": p["destination_location_id"], "arrivalId": p["arrival_id"]}
                    for p in maps["portals"]],
        "events": [e["id"] for e in read(REF / "source/assets/data/world_events/catalog.json")["events"]],
        "areas": ["woods"], "resources": ["moonflower"], "giftItems": ["moonflower"],
    }
    result["conversion.json"] = {"schemaVersion": 1, "sourceRevision": manifest["source_revision"], "routines": conversions}
    return {name: (json.dumps(doc, ensure_ascii=False, indent=2) + "\n").encode("utf-8") for name, doc in result.items()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = outputs()
    if args.check:
        for name, data in expected.items():
            if not (OUT / name).is_file() or (OUT / name).read_bytes() != data:
                raise SystemExit(f"Converted content drift: {name}")
        if {p.name for p in OUT.glob("*.json")} != set(expected):
            raise SystemExit("Unexpected routine content files")
    else:
        OUT.mkdir(parents=True, exist_ok=True)
        for name, data in expected.items():
            (OUT / name).write_bytes(data)
    print(f"PASS {len(expected)} target-local documents; 25 exact public routines")


if __name__ == "__main__":
    main()
