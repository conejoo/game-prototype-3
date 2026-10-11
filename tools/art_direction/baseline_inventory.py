"""AD001 read-only asset/source inventory. Never save or export Blender files."""
from pathlib import Path
import argparse
import hashlib
import json
import struct
import sys

ROOT = Path(__file__).resolve().parents[2]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--blend-source-audit", action="store_true")
    options = parser.parse_args(args)
    output = options.output.resolve()
    evidence = (ROOT / "docs/evidence/AD001").resolve()
    if not output.is_relative_to(evidence) or len(output.relative_to(evidence).parts) < 2:
        raise ValueError("Output must be in an AD001 evidence run child")
    if output.exists():
        raise FileExistsError(output)
    rows = []
    if options.blend_source_audit:
        import bpy
        for path in sorted((ROOT / "art/source").glob("*.blend")):
            bpy.ops.wm.open_mainfile(filepath=str(path), load_ui=False)
            meshes = [obj for obj in bpy.data.objects if obj.type == "MESH"]
            rows.append({"path":path.relative_to(ROOT).as_posix(), "sha256":digest(path),
                         "scenes":[scene.name for scene in bpy.data.scenes],
                         "meshes":len(meshes), "meshes_with_uv":sum(bool(obj.data.uv_layers) for obj in meshes),
                         "materials":[mat.name for mat in bpy.data.materials],
                         "image_nodes":[{"material":mat.name, "image":node.image.name if node.image else None}
                                        for mat in bpy.data.materials if mat.use_nodes
                                        for node in mat.node_tree.nodes if node.type == "TEX_IMAGE"],
                         "armatures":sum(obj.type == "ARMATURE" for obj in bpy.data.objects)})
        result = {"task":"AD001", "kind":"read-only background Blender source audit; no live scene modified or file saved",
                  "blender_version":bpy.app.version_string, "sources":rows}
    else:
        for path in sorted((ROOT / "game/assets").rglob("*.glb")):
            data = path.read_bytes()
            magic, version, length = struct.unpack_from("<III", data)
            if magic != 0x46546C67 or version != 2 or length != len(data):
                raise ValueError(f"Invalid GLB: {path}")
            size, kind = struct.unpack_from("<II", data, 12)
            if kind != 0x4E4F534A:
                raise ValueError(f"Missing GLB JSON: {path}")
            gltf = json.loads(data[20:20 + size])
            primitives = [p for m in gltf.get("meshes", []) for p in m["primitives"]]
            rows.append({"path":path.relative_to(ROOT).as_posix(), "sha256":digest(path), "bytes":len(data),
                         "meshes":len(gltf.get("meshes", [])), "primitives":len(primitives),
                         "uv_primitives":sum("TEXCOORD_0" in p["attributes"] for p in primitives),
                         "color_primitives":sum("COLOR_0" in p["attributes"] for p in primitives),
                         "materials":gltf.get("materials", []), "images":gltf.get("images", []),
                         "animations":[a.get("name") for a in gltf.get("animations", [])]})
        pin_paths = list((ROOT / "art/source").glob("*.blend"))
        pin_paths += list((ROOT / "game/assets/environment").glob("*mapping.json"))
        pin_paths += list((ROOT / "game/content/maps").glob("*.json"))
        pin_paths += [ROOT / "game/tests/fixtures/map_camera_poses.json", ROOT / "game/world/maris_counter.tscn",
                      ROOT / "game/world/tollworks.tscn", ROOT / "game/world/portal_routes.gd",
                      ROOT / "game/features/npcs/npc_registry.gd", ROOT / "game/core/save_codec.gd"]
        result = {"task":"AD001", "kind":"read-only GLB JSON and immutable source/preservation pins",
                  "models":rows, "pins":[{"path":p.relative_to(ROOT).as_posix(), "sha256":digest(p)} for p in sorted(pin_paths)]}
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"AD001 inventory rows={len(rows)} output={output}")


if __name__ == "__main__":
    main()
