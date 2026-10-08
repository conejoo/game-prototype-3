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
    live = {**view, "paused": False, "pause_overlay_verified": False, "state_verified": True,
            "window_focused": True, "settled_frames": 4, "frame_post_draw_verified": True,
            "started_ticks_msec": 10, "ticks_msec": 20, "focus": ""}
    modes = {
        "hold": {"controls_enabled": True, "hold_verified": True, "hold_active": True,
                 "hold_progress": .25, "progress_visible": True, "e_down": True, "instance_id": "rod"},
        "hold-released": {"controls_enabled": True, "hold_verified": True, "hold_active": False,
                          "hold_progress": 0, "progress_visible": False, "e_down": False, "instance_id": ""},
        "backpack": {"controls_enabled": False, "backpack_modal_verified": True, "panel_fits": True,
                     "focus": "/root/game/ui/backpack/Slot01", "overlay": True},
        "dialogue": {"controls_enabled": False, "dialogue_modal_verified": True, "panel_fits": True,
                     "focus": "/root/game/ui/dialogue/Close", "overlay": True,
                     "conversation": {"token": "fixture:1"}, "display": {"token": "fixture:1"}},
        "drag": {"controls_enabled": False, "drag_verified": True, "preview_visible": True,
                 "instance_id": "rod", "preview_errors": [], "preview_foot": [1, 0, 2]},
    }
    def reject(value):
        write(value)
        try:
            module.collect([manifest], root)
        except (ValueError, TypeError):
            return
        raise AssertionError(f"invalid live capture accepted: {value}")
    fixtures = {}
    for mode, fields in modes.items():
        live_image = root / f"{mode}.png"
        Image.new("RGB", (16, 12), "blue").save(live_image)
        fixture = {**live, **fields, "mode": mode, "label": mode, "path": str(live_image)}
        fixtures[mode] = fixture
        write(fixture)
        _, accepted = module.build([manifest], root)
        assert accepted["views"][0]["mode"] == mode and accepted["schema_version"] == 2
        for field, bad in [("paused", True), ("pause_overlay_verified", True), ("state_verified", False),
                           ("window_focused", False), ("settled_frames", 0), ("settled_frames", True),
                           ("frame_post_draw_verified", False), ("ticks_msec", 9), ("ticks_msec", True),
                           ("started_ticks_msec", -1), ("note", " "), ("kind", "native-input"),
                           ("controls_enabled", not fields["controls_enabled"]),
                           ("overlay", not fixture["overlay"]), ("mode", "unknown")]:
            reject({**fixture, field: bad})
        if mode in ("hold", "hold-released"):
            for field, bad in [("hold_verified", False), ("hold_active", not fields["hold_active"]),
                               ("progress_visible", not fields["progress_visible"]), ("e_down", not fields["e_down"]),
                               ("hold_progress", float("nan")), ("hold_progress", True),
                               ("hold_progress", 1), ("focus", "foreign-focus")]:
                reject({**fixture, field: bad})
        elif mode == "backpack":
            for field, bad in [("backpack_modal_verified", False), ("panel_fits", False), ("focus", "")]:
                reject({**fixture, field: bad})
        elif mode == "dialogue":
            for field, bad in [("dialogue_modal_verified", False), ("panel_fits", False), ("focus", ""),
                               ("conversation", {}), ("display", {"token": "stale"})]:
                reject({**fixture, field: bad})
        else:
            for field, bad in [("drag_verified", False), ("preview_visible", False), ("instance_id", ""),
                               ("preview_errors", "error"), ("preview_errors", [True]),
                               ("preview_foot", [1, 2]), ("preview_foot", [True, 0, 2]),
                               ("preview_foot", [float("inf"), 0, 2]), ("focus", "foreign-focus")]:
                reject({**fixture, field: bad})
            write({**fixture, "preview_errors": ["no dry ground"], "preview_foot": None})
            assert module.collect([manifest], root)[0][0]["mode"] == "drag"
    # Both unified views and existing named live arrays are fully validated/included.
    mixed = {"views": [view, fixtures["dialogue"]], "live_frames": [fixtures["hold"], fixtures["hold-released"]],
             "modal_views": [fixtures["backpack"]], "drag_views": [fixtures["drag"]], "failures": []}
    manifest.write_text(json.dumps(mixed))
    _, accepted = module.build([manifest], root)
    assert accepted["count"] == 6 and {v["mode"] for v in accepted["views"]} == {"pause", *modes}
    manifest.write_text(json.dumps({"views": [], "drag_views": [fixtures["drag"], fixtures["drag"]]}))
    try:
        module.collect([manifest], root)
    except ValueError:
        pass
    else:
        raise AssertionError("duplicate across arrays accepted")
    for invalid in [{"views": [], "live_frames": [view]}, {"views": [], "modal_views": [fixtures["drag"]]},
                    {"views": [], "drag_views": "invalid"}, {"views": [False]}]:
        manifest.write_text(json.dumps(invalid))
        try:
            module.collect([manifest], root)
        except ValueError:
            pass
        else:
            raise AssertionError("malformed/untagged live array silently accepted")
    write(view, ["intentional failed source"])
    _, failed = module.build([manifest], root)
    assert failed["status"] == "failed" and failed["source_failures"]
    assert image.exists() and manifest.exists()  # sources preserved
print("Capture evidence: PASS (pause/live guards, mixed contact sheets, timing, provenance, integrity, failed sources)")
