"""F001 reference audit. Standard library only; never writes or refreshes sources."""
import argparse
import copy
import hashlib
import json
from pathlib import Path

REFERENCE = Path(__file__).resolve().parent
REPOSITORY = REFERENCE.parents[2]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def mapping_errors(layout, vectors):
    errors = []
    records = [r for r in layout["inert_objects"] if r["kind"] == "resourceNode"]
    expected = vectors["nodes"]
    if len(records) != 4 or {r["id"] for r in records} != {r["instance_id"] for r in expected}:
        errors.append("four exact resource instance IDs changed")
    by_id = {r["id"]: r for r in records}
    for node in expected:
        record = by_id.get(node["instance_id"], {})
        if (record.get("foot_xyz_m") != node["authored_foot_xyz_m"]
                or record.get("metadata", {}).get("definitionId") != node["source_resource_id"]
                or record.get("runtime_enabled") is not False
                or record.get("runtime_mapping") is not None):
            errors.append("pinned record changed: " + node["instance_id"])
        x, y = node["pinned_source_foot_xy_units"]
        foot = node["authored_foot_xyz_m"]
        if [(x - 704) / 32, (y - 576) / 32] != [foot[0], foot[2]]:
            errors.append("coordinate contract changed: " + node["instance_id"])
    if layout["provenance"]["snapshot_id"] != vectors["snapshot_id"]:
        errors.append("snapshot identity changed")
    if layout["coordinates"]["source_units_per_metre"] != 32:
        errors.append("map scale changed")
    stable_ids = [v[k] for v in vectors["definitions"] for k in ["item_id", "resource_id"]]
    if len(set(stable_ids)) != 4:
        errors.append("item/resource namespaces collide")
    return errors


def pin_errors(rows, root, overrides=None):
    errors = []
    for row in rows:
        path = root / row["path"]
        try:
            raw = overrides[row["path"]] if overrides and row["path"] in overrides else path.read_bytes()
        except OSError as exc:
            errors.append(str(exc))
            continue
        if digest(raw) != row["sha256"]:
            errors.append("SHA-256 drift: " + row["path"])
    return errors


def audit(source_root=None, self_test=False):
    manifest = read_json(REFERENCE / "manifest.json")
    vectors = read_json(REFERENCE / "behavior_vectors.json")
    excerpts = read_json(REFERENCE / "source_excerpts.json")
    errors = pin_errors(manifest["local_references"], REFERENCE)
    errors += pin_errors(manifest["target_geography"], REPOSITORY)
    layout = read_json(REPOSITORY / "game/content/maps/alderwake_layout.json")
    errors += mapping_errors(layout, vectors)
    # Independently derive tuning from pinned source catalog, rather than trusting vectors.
    catalog = excerpts["catalog"]
    items = {i["id"]: i for i in catalog["items"]}
    resources = {r["id"]: r for r in catalog["resources"]}
    for vector in vectors["definitions"]:
        item = items[vector["source_item_id"]]
        resource = resources[vector["source_resource_id"]]
        for key in ["category", "stackLimit", "useBehavior", "worldBehavior"]:
            if item[key] != vector["source_item"][key]:
                errors.append("source item tuning changed: " + key)
        if resource["itemId"] != vector["source_item_id"] or resource["gatherMilliseconds"] != vector["hold_ms"]:
            errors.append("source resource award/duration changed")
    snippets = {s["name"]: s["text"] for s in excerpts["snippets"]}
    if vectors["slot_capacity"] != 20 or vectors["ui_inspiration"]["slots"] != 20 or "static const backpackSlotCapacity = 20;" not in snippets["inventory"]:
        errors.append("source slot capacity differs")
    for name, token in [
        ("hold", "input.interactionStartGeneration"),
        ("hold", "!identical(_targeting.selectedTarget, _activeTarget)"),
        ("hold", "target.onInteractionCancel()"),
        ("collect", "collectedResourceNodeIds: isDroppedItem && !isAuthoredNode"),
        ("collect", "worldItemPlacements: isDroppedItem"),
        ("drop", "instanceId: 'dropped-$itemId'"),
        ("backpack_grid", "? 5"),
        ("backpack_grid", "InventoryState.backpackSlotCapacity"),
        ("fishing_reward", "case FishingResolutionKind.landed:"),
        ("fishing_reward", "_runtimeController.addActivityReward(itemId)"),
    ]:
        if token not in snippets[name]:
            errors.append("behavior excerpt missing: " + name + " / " + token)
    if source_root:
        errors += pin_errors(manifest["source_inputs"], source_root)
        for snippet in excerpts["snippets"]:
            source = (source_root / snippet["path"]).read_text(encoding="utf-8-sig").splitlines()
            first, last = snippet["lines"]
            if "\n".join(source[first-1:last]) + "\n" != snippet["text"]:
                errors.append("source excerpt differs: " + snippet["name"])
        if read_json(source_root / "assets/data/gameplay/catalog.json") != catalog:
            errors.append("source catalog differs")
    negative_tests = []
    if self_test:
        for group, root in [
            ("local_references", REFERENCE), ("target_geography", REPOSITORY),
            *([("source_inputs", source_root)] if source_root else []),
        ]:
            row = manifest[group][0]
            mutated = (root / row["path"]).read_bytes() + b"\nDRIFT"
            caught = pin_errors([row], root, {row["path"]: mutated})
            if not caught:
                errors.append("negative hash control missed: " + group)
            negative_tests.append(group + ": modified bytes rejected")
        changed = copy.deepcopy(layout)
        changed["inert_objects"] = [r for r in changed["inert_objects"] if r["id"] != "moonflower-01"]
        if not mapping_errors(changed, vectors):
            errors.append("negative missing-node control missed")
        changed = copy.deepcopy(layout)
        next(r for r in changed["inert_objects"] if r["id"] == "moonflower-02")["foot_xyz_m"][1] += .25
        if not mapping_errors(changed, vectors):
            errors.append("negative foot control missed")
        changed_vectors = copy.deepcopy(vectors)
        changed_vectors["definitions"][0]["resource_id"] = changed_vectors["definitions"][0]["item_id"]
        if not mapping_errors(layout, changed_vectors):
            errors.append("negative namespace control missed")
        negative_tests += ["missing node rejected", "changed foot rejected", "namespace collision rejected"]
    return {
        "task": "F001", "status": "failed" if errors else "passed",
        "source_checked": str(source_root) if source_root else None,
        "source_inputs": len(manifest["source_inputs"]) if source_root else 0,
        "local_references": len(manifest["local_references"]),
        "target_geography": len(manifest["target_geography"]),
        "definitions": vectors["definitions"], "nodes": vectors["nodes"],
        "negative_tests": negative_tests, "errors": errors,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, help="Optional read-only source drift check")
    parser.add_argument("--self-test", action="store_true", help="In-memory negative drift controls; no file mutation")
    args = parser.parse_args()
    try:
        result = audit(args.source_root, args.self_test)
    except (OSError, KeyError, ValueError) as exc:
        result = {"task": "F001", "status": "failed", "errors": [str(exc)]}
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result["status"] == "passed" else 1)
