"""Focused evidence integrity checks, with disposable generated images."""
import importlib.util
import json
import tempfile
from pathlib import Path
from PIL import Image

spec = importlib.util.spec_from_file_location("capture_evidence", Path(__file__).resolve().parents[1] / "capture_evidence.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

with tempfile.TemporaryDirectory(prefix="returning-fair-capture-") as folder:
    root = Path(folder)
    image = root / "view.png"
    Image.new("RGB", (16, 12), "green").save(image)
    view = {"path": str(image), "label": "fixture", "kind": "synthetic", "note": "generated fixture",
            "paused": True, "pause_overlay_verified": True, "overlay": False, "camera": {"projection": 1},
            "engine_pid": 1, "engine": "fixture", "viewport_size": [16, 12]}
    manifest = root / "index.json"
    def write(value, failures=None):
        manifest.write_text(json.dumps({"views": [value], "failures": failures or []}))
    write(view)
    first, report = module.build([manifest], root)
    second, _ = module.build([manifest], root)
    assert first != second and first.exists() and second.exists()
    assert report["count"] == 1 and len(report["views"][0]["sha256"]) == 64
    for field, value in [("paused", False), ("pause_overlay_verified", False), ("kind", "unspecified"),
                         ("viewport_size", [1, 1]), ("path", str(root.parent / "outside.png")),
                         ("camera", {}), ("camera", {"projection": True}), ("engine_pid", 0), ("engine_pid", True)]:
        write({**view, field: value})
        try:
            module.collect([manifest], root)
        except ValueError:
            pass
        else:
            raise AssertionError(f"invalid {field} accepted")
    write(view, ["intentional failed source"])
    _, failed = module.build([manifest], root)
    assert failed["status"] == "failed" and failed["source_failures"]
    assert image.exists() and manifest.exists()  # sources preserved
print("Capture evidence: PASS (unique output, integrity, provenance, pause, failed sources)")
