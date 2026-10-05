#!/usr/bin/env python3
"""Validate pause/provenance manifests and create uniquely named contact sheets."""
import argparse
import hashlib
import json
import sys
import textwrap
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4
from PIL import Image, ImageDraw, ImageFont

PROJECT = Path(__file__).resolve().parent.parent


def collect(manifests, evidence_root):
    evidence_root = evidence_root.resolve()
    views, failures, seen = [], [], set()
    for manifest in manifests:
        manifest = manifest.resolve()
        if not manifest.is_relative_to(evidence_root):
            raise ValueError(f"Manifest outside evidence root: {manifest}")
        data = json.loads(manifest.read_text(encoding="utf-8-sig"))
        if not isinstance(data.get("views"), list):
            raise ValueError(f"Missing views: {manifest}")
        failures.extend({"manifest": str(manifest), "error": error} for error in data.get("failures", []))
        for view in data["views"]:
            path = Path(view["path"]).resolve()
            if not path.is_relative_to(manifest.parent) or path.suffix.lower() != ".png":
                raise ValueError(f"PNG outside manifest run: {path}")
            if path in seen:
                raise ValueError(f"Duplicate PNG: {path}")
            if view.get("kind") not in {"synthetic", "debug-input", "native-input"} or not view.get("note"):
                raise ValueError(f"Missing provenance: {path}")
            if view.get("paused") is not True or view.get("pause_overlay_verified") is not True:
                raise ValueError(f"Unverified pause: {path}")
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
            views.append({**view, "path": str(path), "manifest": str(manifest),
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
        draw.text((8, 6), "SOURCE FAILURES RETAINED" if failures else "Pause/provenance verified; visual review still required", font=font, fill="#ffcd78")
        for index, view in enumerate(page):
            x, y = (index % columns) * cell_width, 30 + (index // columns) * cell_height
            with Image.open(view["path"]) as image:
                thumb = image.convert("RGB")
                thumb.thumbnail((352, 235))
                sheet.paste(thumb, (x + 4, y + 4))
            caption = f"{view['label']} | {view['kind']} | pause=yes overlay={view['overlay']} proj={view['camera']['projection']}"
            draw.multiline_text((x + 5, y + 244), "\n".join(textwrap.wrap(caption, 43)), font=font, fill="white", spacing=3)
        path = output / f"contact-{offset // 12 + 1:02d}.png"
        sheet.save(path)
        sheets.append(str(path))
    report = {"schema_version": 1, "status": "failed" if failures else "ready-for-visual-review",
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
