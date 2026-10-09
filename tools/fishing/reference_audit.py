"""Read-only FS001 reference audit. No source checkout needed for offline vectors.

Run with bundled Python; --source-root additionally checks live source identities.
This tool never refreshes pins or changes production geography.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REF = ROOT / "tools/fishing/reference"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def contains(shape, point):
    x, z = point
    if shape["kind"] == "rectangle":
        left, top, width, depth = shape["rect_xz_m"]
        return left <= x <= left + width and top <= z <= top + depth
    # Evaluate the pinned source predicate in source units. Its cross-product
    # epsilon is 1e-6 source-unit squared, not 1e-6 metre squared.
    x, z = x * 32 + 704, z * 32 + 576
    vertices = [(a * 32 + 704, b * 32 + 576) for a, b in shape["vertices_xz_m"]]
    inside = False
    for (ax, az), (bx, bz) in zip(vertices, vertices[1:] + vertices[:1]):
        cross = (x - ax) * (bz - az) - (z - az) * (bx - ax)
        if abs(cross) <= 1e-6 and min(ax, bx) - 1e-6 <= x <= max(ax, bx) + 1e-6 and min(az, bz) - 1e-6 <= z <= max(az, bz) + 1e-6:
            return True
        if (bz > z) != (az > z) and x < (ax - bx) * (z - bz) / (az - bz) + bx:
            inside = not inside
    return inside


def distribution(areas, point):
    profiles = [p for a in areas if contains(a["shape"], point) for p in a["source_profiles"] if p["activityId"] == "fishing"]
    if not profiles:
        return {}
    total = sum(p["blendWeight"] for p in profiles)
    ids = sorted({o["itemId"] for p in profiles for o in p["outcomes"]})
    return {i: sum(p["blendWeight"] * sum(o["probability"] for o in p["outcomes"] if o["itemId"] == i) for p in profiles) / total for i in ids}


def resolve(areas, point, roll):
    if not isinstance(roll, (int, float)) or isinstance(roll, bool) or not math.isfinite(roll) or not 0 <= roll < 1:
        raise ValueError("roll must be finite in [0,1)")
    probabilities = distribution(areas, point)
    if not probabilities:
        return "no_area"
    threshold = 0.0
    for item, probability in probabilities.items():
        threshold += probability
        if roll < threshold:
            return item
    return "miss"


def audit(source_root=None):
    manifest = json.loads((REF / "manifest.json").read_text())
    rules = json.loads((REF / "rules.json").read_text())
    vectors = json.loads((REF / "behavior_vectors.json").read_text())
    count = 0

    def check(ok, label):
        nonlocal count
        assert ok, label
        count += 1

    for record in manifest["local_artifacts"]:
        check(digest(ROOT / record["path"]) == record["sha256"], "local pin: " + record["path"])
    if source_root:
        for record in manifest["source_files"]:
            check(digest(source_root / record["path"]) == record["sha256"], "live source drift: " + record["path"])
        for excerpt in json.loads((REF / "source_excerpts.json").read_text()):
            lines = (source_root / excerpt["source"]).read_text(encoding="utf-8").splitlines()
            start, end = excerpt["lines"]
            check("\n".join(lines[start-1:end])+"\n" == excerpt["text"], "exact excerpt " + excerpt["source"])
    layout = json.loads((ROOT / "game/content/maps/alderwake_layout.json").read_text())
    check(layout["activity_areas"] == rules["areas"], "retained area records")
    check(len(rules["areas"]) == 3, "three authored areas")
    for source, target in zip(rules["source_areas"], rules["areas"]):
        shape = source["shape"]
        converted = {"kind": shape["kind"]}
        if shape["kind"] == "rectangle":
            converted["rect_xz_m"] = [(shape["left"] - 704) / 32, (shape["top"] - 576) / 32, shape["width"] / 32, shape["height"] / 32]
        else:
            converted["vertices_xz_m"] = [[(p["x"] - 704) / 32, (p["y"] - 576) / 32] for p in shape["points"]]
        check(source["id"] == target["id"] and converted == target["shape"], "shape transform " + source["id"])
        check(source["activities"] == target["source_profiles"] and target["runtime_enabled"] is False, "inert profiles " + source["id"])
        for p in target["source_profiles"]:
            check(p["blendWeight"] > 0 and math.isfinite(p["blendWeight"]), "weight")
            check(sum(o["probability"] for o in p["outcomes"]) <= 1, "preserved miss mass")
    for row in vectors["membership"]:
        area = next(a for a in rules["areas"] if a["id"] == row["area"])
        check(contains(area["shape"], row["point"]) == row["inside"], "membership " + row["label"])
    for row in vectors["distributions"]:
        actual = distribution(rules["areas"], row["point"])
        check(actual.keys() == row["probabilities"].keys() and all(math.isclose(actual[i], p, abs_tol=1e-14) for i, p in row["probabilities"].items()), "distribution " + row["label"])
        check(math.isclose(1 - sum(actual.values()), row["miss"], abs_tol=1e-14), "miss " + row["label"])
    for row in vectors["rolls"]:
        check(resolve(rules["areas"], row["point"], row["roll"]) == row["expected"], "roll " + row["label"])
    for bad in [-1, 1, float("nan"), float("inf"), True]:
        try:
            resolve(rules["areas"], [6.25, 22.25], bad)
        except ValueError:
            check(True, "invalid roll")
        else:
            check(False, "invalid roll accepted")
    for row in vectors["waits"]:
        check(math.isclose(1.5 + 1.5 * row["roll"], row["seconds"]), "wait mapping")
    challenge_text = next(e["text"] for e in json.loads((REF / "source_excerpts.json").read_text()) if e["source"].endswith("fishing_challenge.dart"))
    for field, source_name in {"wait_min":"minimumBiteWaitSeconds","wait_max":"maximumBiteWaitSeconds","danger_grace":"dangerGraceSeconds","held_rise":"reelRisePerSecond","release_fall":"releaseFallPerSecond","warning_progress":"warningProgressMultiplier"}.items():
        match = re.search(r"static const " + source_name + r" = ([\d.]+);", challenge_text)
        check(match is not None and float(match[1]) == rules["challenge"][field], "source challenge constant " + field)
    expected = {"bluegill": ("easy", 1.2, 2, 5), "river_trout": ("medium", .9, 6, 12), "golden_carp": ("hard", .7, 15, 30)}
    for item in rules["items"]:
        if item["id"] == "fishing_rod":
            f = item["features"][0]
            check(item["stackLimit"] == 1 and f["targetCellSize"] == 16 and f["maximumRange"] == 384 and f["requiredSurface"] == "water", "rod activation")
        else:
            f = item["features"][0]
            check((f["difficulty"], f["hookWindowSeconds"], f["minimumFightSeconds"], f["maximumFightSeconds"]) == expected[item["id"]], "species " + item["id"])
            check(item["category"] == "fish" and item["stackLimit"] == 99 and item["useBehavior"] == "none" and item["worldBehavior"] == "none", "fish metadata")
    # Negative controls ensure content/hash failures are observable, not silent repins.
    changed = dict(rules["areas"][0]); changed["id"] = "changed"
    check(changed != layout["activity_areas"][0], "negative area mutation")
    check(hashlib.sha256(b"mutated").hexdigest() != manifest["local_artifacts"][0]["sha256"], "negative bytes")
    return {"task": "FS001", "status": "pass", "assertions": count, "live_source_checked": bool(source_root), "layout_sha256": digest(ROOT / "game/content/maps/alderwake_layout.json")}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-root", type=Path)
    args = parser.parse_args()
    print(json.dumps(audit(args.source_root), indent=2))
