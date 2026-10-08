#!/usr/bin/env python3
"""Validate pause/live-state provenance and create uniquely named contact sheets."""
import argparse
import hashlib
import json
import math
import sys
import textwrap
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4
from PIL import Image, ImageDraw, ImageFont

PROJECT = Path(__file__).resolve().parent.parent


def validate_state(view, path):
    mode = view.get("mode", "pause")  # Existing paused manifests remain valid.
    if mode == "pause":
        if view.get("paused") is not True or view.get("pause_overlay_verified") is not True:
            raise ValueError(f"Unverified pause: {path}")
        return mode
    if mode not in {"hold", "hold-released", "backpack", "drag", "dialogue", "journal"}:
        raise ValueError(f"Unknown capture mode: {path}")
    if (view.get("paused") is not False or view.get("pause_overlay_verified") is not False
            or view.get("state_verified") is not True or view.get("window_focused") is not True
            or type(view.get("settled_frames")) is not int or view["settled_frames"] != 4
            or view.get("frame_post_draw_verified") is not True):
        raise ValueError(f"Unverified live state/settling: {path}")
    start, end = view.get("started_ticks_msec"), view.get("ticks_msec")
    if type(start) is not int or type(end) is not int or start < 0 or end < start:
        raise ValueError(f"Invalid capture timing: {path}")
    if view.get("kind") not in {"synthetic", "debug-input"}:
        raise ValueError(f"Live viewport helper cannot claim native input: {path}")
    if view.get("overlay") is not (mode in {"backpack", "dialogue", "journal"}):
        raise ValueError(f"Incorrect live overlay mode: {path}")
    if view.get("controls_enabled") is not (mode in {"hold", "hold-released"}):
        raise ValueError(f"Incorrect live controls: {path}")
    if mode == "dialogue":
        conversation, display = view.get("conversation"), view.get("display")
        if (view.get("dialogue_modal_verified") is not True or view.get("panel_fits") is not True
                or not isinstance(view.get("focus"), str) or not view["focus"]
                or not isinstance(conversation, dict) or not isinstance(display, dict)
                or not isinstance(conversation.get("token"), str) or not conversation["token"]
                or conversation["token"] != display.get("token")):
            raise ValueError(f"Unverified dialogue modal/focus/cursor: {path}")
    elif mode == "journal":
        if (view.get("journal_modal_verified") is not True or view.get("panel_fits") is not True
                or not isinstance(view.get("focus"), str) or not view["focus"]
                or view.get("tab") not in {"quests", "people"}
                or not isinstance(view.get("selected_id"), str)):
            raise ValueError(f"Unverified journal modal/focus: {path}")
    elif mode == "backpack":
        if (view.get("backpack_modal_verified") is not True or view.get("panel_fits") is not True
                or not isinstance(view.get("focus"), str) or not view["focus"]):
            raise ValueError(f"Unverified backpack modal/focus: {path}")
    else:
        if view.get("focus") != "":
            raise ValueError(f"World capture retains UI focus: {path}")
        if mode == "drag":
            if (view.get("drag_verified") is not True or view.get("preview_visible") is not True
                    or not isinstance(view.get("instance_id"), str) or not view["instance_id"]
                    or not isinstance(view.get("preview_errors"), list)
                    or any(not isinstance(error, str) for error in view["preview_errors"])):
                raise ValueError(f"Unverified drag preview: {path}")
            foot = view.get("preview_foot")
            if "preview_foot" not in view or (foot is not None and (not isinstance(foot, list) or len(foot) != 3
                    or any(type(value) not in (int, float) or not math.isfinite(value) for value in foot))):
                raise ValueError(f"Invalid drag foot: {path}")
        else:
            active = mode == "hold"
            progress = view.get("hold_progress")
            if (view.get("hold_verified") is not True or view.get("hold_active") is not active
                    or view.get("e_down") is not active or view.get("progress_visible") is not active
                    or type(progress) not in (int, float) or not math.isfinite(progress)
                    or not 0 <= progress < 1 or (not active and progress != 0)
                    or (active and (not isinstance(view.get("instance_id"), str) or not view["instance_id"]))):
                raise ValueError(f"Unverified hold/progress/release: {path}")
    return mode


def collect(manifests, evidence_root):
    evidence_root = evidence_root.resolve()
    views, failures, seen = [], [], set()
    for manifest in manifests:
        manifest = manifest.resolve()
        if not manifest.is_relative_to(evidence_root):
            raise ValueError(f"Manifest outside evidence root: {manifest}")
        data = json.loads(manifest.read_text(encoding="utf-8-sig"))
        groups = {"views": None, "live_frames": {"hold", "hold-released"},
                  "modal_views": {"backpack"}, "drag_views": {"drag"}}
        if not any(key in data for key in groups):
            raise ValueError(f"Missing capture arrays: {manifest}")
        captures = []
        for key, modes in groups.items():
            if key not in data:
                continue
            if not isinstance(data[key], list):
                raise ValueError(f"Invalid capture array {key}: {manifest}")
            for view in data[key]:
                if not isinstance(view, dict):
                    raise ValueError(f"Invalid capture entry: {manifest}")
                if modes is not None and view.get("mode") not in modes:
                    raise ValueError(f"Missing/wrong live mode in {key}: {manifest}")
                captures.append(view)
        failures.extend({"manifest": str(manifest), "error": error} for error in data.get("failures", []))
        for view in captures:
            path = Path(view["path"]).resolve()
            if not path.is_relative_to(manifest.parent) or path.suffix.lower() != ".png":
                raise ValueError(f"PNG outside manifest run: {path}")
            if path in seen:
                raise ValueError(f"Duplicate PNG: {path}")
            if (view.get("kind") not in {"synthetic", "debug-input", "native-input"}
                    or not isinstance(view.get("note"), str) or not view["note"].strip()):
                raise ValueError(f"Missing provenance: {path}")
            mode = validate_state(view, path)
            if type(view.get("camera", {}).get("projection")) is not int or view["camera"]["projection"] not in (0, 1, 2):
                raise ValueError(f"Missing camera projection: {path}")
            if type(view.get("engine_pid")) is not int or view["engine_pid"] <= 0 or not view.get("engine"):
                raise ValueError(f"Missing engine identity: {path}")
            if not isinstance(view.get("overlay"), bool) or not view.get("label"):
                raise ValueError(f"Missing capture label/overlay: {path}")
            with Image.open(path) as image:
                size = list(image.size)
                image.verify()
            if size != view.get("viewport_size"):
                raise ValueError(f"Viewport/PNG mismatch: {path}")
            seen.add(path)
            views.append({**view, "mode": mode, "path": str(path), "manifest": str(manifest),
                          "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
    if not views:
        raise ValueError("No captures to inspect")
    return views, failures


def build(manifests, evidence_root):
    views, failures = collect(manifests, evidence_root)
    # Create only after the entire source manifest passes structural validation.
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S") + "-" + uuid4().hex[:8]
    output = manifests[0].resolve().parent / "derived" / stamp
    output.mkdir(parents=True, exist_ok=False)
    font = ImageFont.load_default(size=15)
    sheets = []
    for offset in range(0, len(views), 12):
        page = views[offset:offset + 12]
        columns = min(3, len(page))
        cell_width, cell_height = 360, 318
        rows = (len(page) + columns - 1) // columns
        sheet = Image.new("RGB", (columns * cell_width, rows * cell_height + 30), "#171c24")
        draw = ImageDraw.Draw(sheet)
        draw.text((8, 6), "SOURCE FAILURES RETAINED" if failures else "Capture state/provenance verified; visual review required", font=font, fill="#ffcd78")
        for index, view in enumerate(page):
            x, y = (index % columns) * cell_width, 30 + (index // columns) * cell_height
            with Image.open(view["path"]) as image:
                thumb = image.convert("RGB")
                thumb.thumbnail((352, 235))
                sheet.paste(thumb, (x + 4, y + 4))
            caption = f"{view['label']} | {view['kind']} | mode={view['mode']} pause={view['paused']} overlay={view['overlay']} proj={view['camera']['projection']}"
            draw.multiline_text((x + 5, y + 244), "\n".join(textwrap.wrap(caption, 43)), font=font, fill="white", spacing=3)
        path = output / f"contact-{offset // 12 + 1:02d}.png"
        sheet.save(path)
        sheets.append(str(path))
    report = {"schema_version": 2, "status": "failed" if failures else "ready-for-visual-review",
              "source_failures": failures, "count": len(views), "views": views, "contact_sheets": sheets}
    result = output / "capture-report.json"
    result.write_text(json.dumps(report, indent=2), encoding="utf-8")
    return result, report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifests", nargs="+", type=Path)
    args = parser.parse_args()
    try:
        path, report = build(args.manifests, PROJECT / "docs/evidence")
    except (ValueError, KeyError, TypeError, OSError, json.JSONDecodeError) as error:
        print(f"Evidence validation failed: {error}", file=sys.stderr)
        return 1
    print(json.dumps({"report": str(path), "status": report["status"], "count": report["count"], "sheets": report["contact_sheets"]}))
    return 1 if report["source_failures"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
