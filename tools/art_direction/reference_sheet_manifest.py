"""AD020 pin authoring-sheet dimensions/hashes without shipping source rasters."""
import hashlib
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
catalog = json.loads((ROOT / "game/content/npcs/catalog.json").read_text())
entries = {}
for package in catalog["packages"]:
    world = package["visuals"]["world"]
    for sheet in [world["idle"], world["walk"], *world["actions"].values()]:
        path = sheet["asset"]
        data = (ROOT / "game" / path.removeprefix("res://")).read_bytes()
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            raise ValueError("Invalid PNG: " + path)
        size = list(struct.unpack(">II", data[16:24]))
        if size != [sheet["textureCellWidth"] * sheet["framesPerFacing"], sheet["textureCellHeight"] * 4]:
            raise ValueError("Source dimensions disagree: " + path)
        entries[path] = {"size": size, "sha256": hashlib.sha256(data).hexdigest()}
output = ROOT / "game/content/npcs/reference_sheet_manifest.json"
payload = (json.dumps({"source_revision": catalog["source_revision"], "sheets": entries}, indent=2, sort_keys=True) + "\n").encode()
if output.exists() and output.read_bytes() != payload:
    raise RuntimeError("Pinned sheet manifest differs; explicit source review required")
if not output.exists():
    output.write_bytes(payload)
print(json.dumps({"sheets": len(entries), "sha256": hashlib.sha256(payload).hexdigest(), "source_revision": catalog["source_revision"]}))
