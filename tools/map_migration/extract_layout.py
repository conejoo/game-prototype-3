"""Deterministic, offline M002 extraction. Never reads or refreshes the source checkout."""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
from pathlib import Path
import re
import sys
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
REFERENCE = Path(__file__).parent / "reference"
OUTPUT = ROOT / "game/content/maps/alderwake_layout.json"
REPORT = Path(__file__).parent / "extraction_report.json"
SCALE = 32
ORIGIN = (704, 576)
DIRECTIONS = {"north": (0, -1), "east": (1, 0), "south": (0, 1), "west": (-1, 0)}


class LayoutError(ValueError):
    pass


def require(condition: bool, path: str, message: str) -> None:
    if not condition:
        raise LayoutError(f"{path}: {message}")


def keys(value: Any, path: str, required: str, optional: str = "") -> dict:
    require(isinstance(value, dict), path, "expected object")
    expected, extra = set(required.split()), set(optional.split())
    require(expected <= value.keys(), path, f"missing fields {sorted(expected - value.keys())}")
    require(value.keys() <= expected | extra, path, f"unknown fields {sorted(value.keys() - expected - extra)}")
    return value


def number(value: Any, path: str, integer: bool = False, positive: bool = False) -> float:
    require(type(value) in (int, float) and math.isfinite(value), path, "expected finite number")
    require(not integer or type(value) is int, path, "expected integer")
    require(not positive or value > 0, path, "expected positive number")
    return value


def string(value: Any, path: str) -> str:
    require(isinstance(value, str) and bool(value.strip()), path, "expected nonempty string")
    return value


def boolean(value: Any, path: str) -> bool:
    require(type(value) is bool, path, "expected boolean")
    return value


def records(value: Any, path: str) -> list:
    require(isinstance(value, list), path, "expected array")
    return value


def point(value: Any, path: str) -> tuple:
    keys(value, path, "x y")
    return number(value["x"], path + ".x"), number(value["y"], path + ".y")


def rotate(x: float, y: float, q: int) -> tuple:
    return ((x, y), (-y, x), (-x, -y), (y, -x))[q % 4]


def transform_point(x: float, y: float, group: dict | None) -> tuple:
    if group is None:
        return x, y
    x, y = rotate(x, y, group["quarterTurns"])
    return x + group["pivotX"] * SCALE, y + group["pivotY"] * SCALE


def transform_cell(x: int, y: int, group: dict | None) -> tuple:
    if group is None:
        return x, y
    q = group["quarterTurns"] % 4
    x, y = ((x, y), (-y - 1, x), (-x - 1, -y - 1), (y, -x - 1))[q]
    return x + group["pivotX"], y + group["pivotY"]


def xz(x: float, y: float) -> list:
    return [(x - ORIGIN[0]) / SCALE, (y - ORIGIN[1]) / SCALE]


def rect(value: dict, path: str, group: dict | None = None) -> list:
    left, top = number(value["left"], path + ".left"), number(value["top"], path + ".top")
    width = number(value["width"], path + ".width", positive=True)
    height = number(value["height"], path + ".height", positive=True)
    corners = [transform_point(x, y, group) for x, y in
               [(left, top), (left + width, top), (left + width, top + height), (left, top + height)]]
    xs, ys = zip(*corners)
    return [*xz(min(xs), min(ys)), (max(xs) - min(xs)) / SCALE, (max(ys) - min(ys)) / SCALE]


def polygon(value: Any, path: str) -> list:
    values = records(value, path)
    require(len(values) >= 3, path, "polygon needs at least three vertices")
    points = [point(p, f"{path}[{i}]") for i, p in enumerate(values)]
    area = sum(a[0] * b[1] - b[0] * a[1] for a, b in zip(points, points[1:] + points[:1]))
    require(abs(area) > 1e-10, path, "degenerate polygon")
    return points


def read_json(path: Path) -> Any:
    def unique_pairs(pairs: list) -> dict:
        result = {}
        for key, value in pairs:
            require(key not in result, str(path), f"duplicate JSON key {key}")
            result[key] = value
        return result
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_pairs)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def pinned_inputs(reference: Path) -> tuple:
    manifest = read_json(reference / "manifest.json")
    keys(manifest, "manifest", "snapshot_id source_commit inputs")
    entries = records(manifest["inputs"], "manifest.inputs")
    expected = {"mvp_world.json", "catalog.json", "terrain_materials.json", "tile_manifest.csv", "art_tile_catalog.dart"}
    require({e["file"] for e in entries} == expected and len(entries) == len(expected), "manifest", "unexpected input set")
    for entry in entries:
        keys(entry, "manifest.input", "file source_path sha256")
        data = (reference / entry["file"]).read_bytes()
        require(digest(data) == entry["sha256"], entry["file"], "pinned input hash mismatch; reconcile deliberately, never auto-refresh")
    return manifest, {name: read_json(reference / name) for name in expected if name.endswith(".json")}


def art_registry(reference: Path) -> dict:
    # The pinned registry is reference text, never executed or imported as Dart.
    text = (reference / "art_tile_catalog.dart").read_text(encoding="utf-8")
    result = {}
    for factory, directory, prefix in [("bridge", "moonwood_footbridge", "moonwood-footbridge"),
                                      ("fairBridge", "fair_bridge", "fair-bridge")]:
        require(f"{prefix}-r$row-c$column.png'" in text, "art registry", "unrecognized factory template")
        for row, col, depth in re.findall(rf"ArtTileCatalogEntry\.{factory}\((\d+), (\d+), ArtTileDepthIntent\.(\w+)\)", text):
            result[f"tiles/world/{directory}/{prefix}-r{row}-c{col}.png"] = {"depth_intent": depth, "cell_size_m": 1}
    for factory, directory in [("quay", "passenger_quay"), ("tollworks", "tollworks")]:
        require(f"'tiles/world/{directory}/$piece.png'" in text, "art registry", "unrecognized factory template")
        for piece, option in re.findall(rf"ArtTileCatalogEntry\.{factory}\('([^']+)'([^)]*)\)", text):
            depth = "inFrontOfActor" if "retainingFace: true" in option else (
                "walkableSurface" if factory == "quay" or "floor: true" in option else "standard")
            result[f"tiles/world/{directory}/{piece}.png"] = {"depth_intent": depth, "cell_size_m": 1}
    return result


def extract(reference: Path = REFERENCE) -> tuple[dict, dict]:
    manifest, inputs = pinned_inputs(reference)
    world, catalog = inputs["mvp_world.json"], inputs["catalog.json"]
    keys(world, "$", "mapId columns rows tileSize tileLayers artLayers elevation playerSpawn zones activityAreas objects colliders portals groups", "artDirection lighting")
    require(world["mapId"] == "alderwake", "mapId", "only Alderwake exterior supported")
    require(world["tileSize"] == SCALE, "tileSize", "contract requires 32 units")
    columns = number(world["columns"], "columns", integer=True, positive=True)
    rows = number(world["rows"], "rows", integer=True, positive=True)
    require((columns, rows) == (147, 80), "dimensions", "contract requires 147 by 80 cells")
    require(point(world["playerSpawn"], "playerSpawn") == ORIGIN, "playerSpawn", "contract origin differs")
    report = {"snapshot_id": manifest["snapshot_id"], "excluded_or_inert": [], "warnings": []}
    seen: set[tuple[str, str]] = set()

    def identity(value: dict, path: str, namespace: str = "objects") -> str:
        stable_id = string(value["id"], path + ".id")
        key = (namespace, stable_id)
        require(key not in seen, path, f"duplicate {namespace} identity {stable_id}")
        seen.add(key)
        return stable_id

    def inert(path: str, stable_id: str, reason: str) -> None:
        report["excluded_or_inert"].append({"path": path, "id": stable_id, "reason": reason})

    def grid_cell(value: dict, path: str, size: int = SCALE, bounded: bool = True) -> tuple:
        x, y = number(value["x"], path + ".x", integer=True), number(value["y"], path + ".y", integer=True)
        require(not bounded or (0 <= x < columns * SCALE / size and 0 <= y < rows * SCALE / size), path, "cell outside map")
        return x, y

    keys(world["elevation"], "elevation", "cells slopes")
    levels = {}
    elevation = []
    for i, cell in enumerate(records(world["elevation"]["cells"], "elevation.cells")):
        path = f"elevation.cells[{i}]"
        keys(cell, path, "x y level")
        xy = grid_cell(cell, path)
        require(xy not in levels, path, "duplicate elevation cell")
        level = number(cell["level"], path + ".level", integer=True)
        require(1 <= level <= 8, path, "elevation override must be level 1 through 8")
        levels[xy] = level
        elevation.append({"cell": list(xy), "level": level, "height_m": level * 0.25})
    slopes, slope_by_cell = [], {}
    for i, slope in enumerate(records(world["elevation"]["slopes"], "elevation.slopes")):
        path = f"elevation.slopes[{i}]"
        keys(slope, path, "id x y ascendsToward")
        stable_id, xy = identity(slope, path, "slopes"), grid_cell(slope, path)
        direction = slope["ascendsToward"]
        require(direction in DIRECTIONS, path, "unknown ascent direction")
        require(xy not in slope_by_cell, path, "duplicate slope cell")
        require(xy not in levels, path, "slope overlaps flat elevation override")
        dx, dy = DIRECTIONS[direction]
        require(all(0 <= x < columns and 0 <= y < rows for x, y in
                    [(xy[0] - dx, xy[1] - dy), (xy[0] + dx, xy[1] + dy)]), path, "slope endpoints outside map")
        low, high = levels.get((xy[0] - dx, xy[1] - dy), 0), levels.get((xy[0] + dx, xy[1] + dy), 0)
        require(high == low + 1, path, "slope endpoints must differ by one level")
        result = {"id": stable_id, "cell": list(xy), "ascends_toward": direction,
                  "low_height_m": low * 0.25, "high_height_m": high * 0.25}
        slopes.append(result)
        slope_by_cell[xy] = result
    for slope in slopes:
        dx, dy = DIRECTIONS[slope["ascends_toward"]]
        x, y = slope["cell"]
        require((x - dx, y - dy) not in slope_by_cell and (x + dx, y + dy) not in slope_by_cell,
                slope["id"], "slope endpoints must be flat")

    def xyz(x: float, y: float) -> list:
        cx, cy = math.floor(x / SCALE), math.floor(y / SCALE)
        slope = slope_by_cell.get((cx, cy))
        height = levels.get((cx, cy), 0) * 0.25
        if slope:
            lx, ly = x / SCALE - cx, y / SCALE - cy
            progress = {"north": 1 - ly, "east": lx, "south": ly, "west": 1 - lx}[slope["ascends_toward"]]
            height = slope["low_height_m"] + 0.25 * progress
        px, pz = xz(x, y)
        return [px, height, pz]

    keys(catalog, "catalog", "schemaVersion objects")
    require(catalog["schemaVersion"] == 8, "catalog", "only pinned schema 8 supported; no legacy defaults invented")
    definitions = {}
    for definition in records(catalog["objects"], "catalog.objects"):
        keys(definition, "catalog.definition", "id label kind category sprite hitbox collision", "shadow lightSources")
        stable_id = string(definition["id"], "catalog.id")
        require(stable_id not in definitions, "catalog", f"duplicate definition {stable_id}")
        string(definition["label"], stable_id + ".label")
        require(definition["kind"] in ("prop", "structure"), stable_id, "unknown catalog kind")
        require(definition["category"] in ("boulders", "trees", "furniture", "outdoorProps", "structures"), stable_id, "unknown catalog category")
        sprite = keys(definition["sprite"], stable_id + ".sprite", "asset textureWidth textureHeight worldWidth worldHeight")
        string(sprite["asset"], stable_id + ".sprite.asset")
        for field in ["textureWidth", "textureHeight", "worldWidth", "worldHeight"]:
            number(sprite[field], stable_id + ".sprite." + field, integer=True, positive=True)
        hitbox = keys(definition["hitbox"], stable_id + ".hitbox", "width height")
        for field in ["width", "height"]:
            number(hitbox[field], stable_id + ".hitbox." + field, positive=True)
        collision = definition["collision"]
        kind = collision.get("kind")
        require(kind in ("none", "box", "polygon"), stable_id, "unknown collision kind")
        if kind == "box":
            keys(collision, stable_id, "kind left top width height")
            rect(collision, stable_id)
        elif kind == "polygon":
            keys(collision, stable_id, "kind points")
            polygon(collision["points"], stable_id)
        else:
            keys(collision, stable_id, "kind")
        definitions[stable_id] = definition

    terrain = inputs["terrain_materials.json"]
    require(terrain["schemaVersion"] == 2 and terrain["tileSize"] == 16, "terrain catalog", "unsupported schema/grid")
    materials = {m["id"]: m for m in terrain["materials"]}
    with (reference / "tile_manifest.csv").open(encoding="utf-8", newline="") as stream:
        raw_tiles = {row["path"].removeprefix("assets/"): row for row in csv.DictReader(stream)}
    art_tiles = art_registry(reference)
    used_materials, used_raw, used_art, used_defs = set(), set(), set(), set()

    def paint(value: Any, path: str) -> Any:
        if value is None:
            return None  # explicit clear; absence is resolved separately by the layer default
        keys(value, path, "kind", "tileId material")
        if value["kind"] == "raw":
            keys(value, path, "kind tileId")
            require(value["tileId"] in raw_tiles, path, "unknown raw tile")
            used_raw.add(value["tileId"])
        else:
            require(value["kind"] in ("centerMaterial", "connectedMaterial"), path, "unknown paint kind")
            keys(value, path, "kind material")
            require(value["material"] in materials, path, "unknown material")
            used_materials.add(value["material"])
        return value

    tile_layers = []
    for i, layer in enumerate(records(world["tileLayers"], "tileLayers")):
        path = f"tileLayers[{i}]"
        keys(layer, path, "id name visible cellSize cells", "defaultPaint")
        stable_id = identity(layer, path, "tile_layers")
        size = number(layer["cellSize"], path, integer=True, positive=True)
        require(size in (16, 32), path, "unsupported layer grid")
        require("defaultPaint" not in layer or layer["defaultPaint"] is not None, path, "defaultPaint cannot be null; omit for no default")
        default = paint(layer.get("defaultPaint"), path + ".defaultPaint")
        cells, occupied = [], set()
        for j, cell in enumerate(records(layer["cells"], path)):
            cell_path = f"{path}.cells[{j}]"
            keys(cell, cell_path, "x y paint")
            xy = grid_cell(cell, cell_path, size)
            require(xy not in occupied, cell_path, "duplicate paint cell")
            occupied.add(xy)
            cells.append({"cell": list(xy), "paint": paint(cell["paint"], cell_path)})
        tile_layers.append({"id": stable_id, "name": string(layer["name"], path), "visible": boolean(layer["visible"], path),
                            "cell_size_m": size / SCALE, "grid_size": [columns * SCALE // size, rows * SCALE // size],
                            "origin_xz_m": xz(0, 0), "default_paint": default,
                            "cells": sorted(cells, key=lambda c: (c["cell"][1], c["cell"][0]))})

    props, colliders, portals, art_layers, inert_objects, groups = [], [], [], [], [], []

    def provenance(path: str, group: dict | None) -> dict:
        return {"path": path, "group_id": group["id"] if group else None}

    def art_layer(layer: dict, path: str, group: dict | None) -> None:
        keys(layer, path, "id name visible cells", "defaultTileId")
        stable_id = f"{group['id']}--{layer['id']}" if group else layer["id"]
        identity({"id": stable_id}, path, "art_layers")
        default = layer.get("defaultTileId")
        require(default is None or default in art_tiles, path, "unknown default art tile")
        if default:
            used_art.add(default)
        cells, occupied = [], set()
        for j, cell in enumerate(records(layer["cells"], path)):
            cp = f"{path}.cells[{j}]"
            keys(cell, cp, "x y tileId")
            xy = grid_cell(cell, cp, bounded=group is None)
            xy = transform_cell(*xy, group)
            require(0 <= xy[0] < columns and 0 <= xy[1] < rows, cp, "transformed art outside map")
            require(xy not in occupied, cp, "duplicate art cell")
            occupied.add(xy)
            require(cell["tileId"] is None or cell["tileId"] in art_tiles, cp, "unknown art tile")
            if cell["tileId"]:
                used_art.add(cell["tileId"])
            cells.append({"cell": list(xy), "tile_id": cell["tileId"]})
        art_layers.append({"id": stable_id, "name": string(layer["name"], path), "visible": boolean(layer["visible"], path),
                           "cell_size_m": 1, "default_tile_id": default,
                           "default_grid_transform": {"pivot_cell": [group["pivotX"], group["pivotY"]], "quarter_turns": group["quarterTurns"] % 4} if group else None,
                           "cells": sorted(cells, key=lambda c: (c["cell"][1], c["cell"][0])), "source": provenance(path, group)})

    def prop(value: dict, path: str, group: dict | None) -> None:
        keys(value, path, "type id definitionId x y", "collisionEnabled lightSourceStates renderDepthOffsetY")
        require(value["type"] == "prop", path, "group entry must be prop")
        stable_id = identity(value, path)
        definition_id = value["definitionId"]
        require(definition_id in definitions, path, f"unknown prop definition {definition_id}")
        definition = definitions[definition_id]
        used_defs.add(definition_id)
        foot = transform_point(number(value["x"], path), number(value["y"], path), group)
        q = group["quarterTurns"] % 4 if group else 0
        enabled = boolean(value.get("collisionEnabled", True), path + ".collisionEnabled")
        geometry = None
        collision = definition["collision"]
        if enabled and collision["kind"] != "none":
            if collision["kind"] == "box":
                l, t, w, h = (collision[k] for k in ["left", "top", "width", "height"])
                local_points = [(l, t), (l + w, t), (l + w, t + h), (l, t + h)]
            else:
                local_points = polygon(collision["points"], path + ".collision")
            points = [xz(foot[0] + rotate(*p, q)[0], foot[1] + rotate(*p, q)[1]) for p in local_points]
            geometry = {"id": f"prop:{stable_id}", "kind": collision["kind"], "vertices_xz_m": points}
            if collision["kind"] == "box":
                xs, zs = zip(*points)
                geometry["rect_xz_m"] = [min(xs), min(zs), max(xs) - min(xs), max(zs) - min(zs)]
        states = value.get("lightSourceStates", {})
        require(isinstance(states, dict), path, "invalid light source states")
        for key, state in states.items():
            string(key, path)
            boolean(state, path + ".lightSourceStates")
        offset = number(value.get("renderDepthOffsetY", 0), path + ".renderDepthOffsetY")
        if states or offset:
            inert(path, stable_id, "source light/depth metadata retained; no 2D renderer or night-light behavior imported")
        tree = None
        if definition["category"] == "trees":
            parts = definition_id.split("-tree")
            tree = {"species": parts[0], "size": parts[1].removeprefix("-") or "standard"}
        props.append({"id": stable_id, "definition_id": definition_id, "foot_xyz_m": xyz(*foot), "source_foot_units": list(foot),
                      "quarter_turns": q, "yaw_degrees": -q * 90, "collision_enabled": enabled, "collision": geometry,
                      "tree": tree, "light_source_states": states, "render_depth_offset_units": offset, "source": provenance(path, group)})

    def collider(value: dict, path: str, group: dict | None) -> None:
        keys(value, path, "id left top width height")
        colliders.append({"id": identity(value, path, "colliders"), "rect_xz_m": rect(value, path, group), "source": provenance(path, group)})

    def portal(value: dict, path: str, group: dict | None) -> None:
        keys(value, path, "id label prompt left top width height destinationMapId destinationX destinationY")
        stable_id = identity(value, path, "portals")
        active = stable_id == "tollworks-entrance-01"
        portals.append({"id": stable_id, "label": string(value["label"], path), "source_prompt": string(value["prompt"], path),
                        "rect_xz_m": rect(value, path, group), "destination_map_id": string(value["destinationMapId"], path),
                        "destination_source_units": [number(value["destinationX"], path), number(value["destinationY"], path)],
                        "runtime_enabled": False, "phase_role": "activate-at-M015" if active else "inert",
                        "runtime_mapping": {"interaction_id": "alderwake-travel-gate", "location_id": "prototype-tollworks", "spawn_id": "tollworks-from-alderwake", "arrival_xyz_m": [0, 0, -2.5]} if active else None,
                        "source": provenance(path, group)})
        inert(path, stable_id, "route deferred until M015" if active else "destination outside this migration phase; no interactable")

    for i, value in enumerate(records(world["objects"], "objects")):
        path = f"objects[{i}]"
        require(isinstance(value, dict), path, "expected object")
        kind = value.get("type")
        if kind == "prop":
            prop(value, path, None)
            continue
        schemas = {"npc": ("definitionId", ""), "resourceNode": ("definitionId", ""),
                   "marker": ("markerKind label", ""), "routineAnchor": ("", "facing tags")}
        require(kind in schemas, path, f"unknown object type {kind}")
        required, optional = schemas[kind]
        keys(value, path, "type id x y " + required, optional)
        stable_id = identity(value, path)
        for field in required.split():
            string(value[field], path + "." + field)
        if "facing" in value:
            require(value["facing"] in DIRECTIONS, path, "unknown facing")
        if "tags" in value:
            for tag in records(value["tags"], path + ".tags"):
                string(tag, path + ".tags")
        mapping = "npc-03-counter" if stable_id == "maris-chandlery-01" else None
        inert_objects.append({"id": stable_id, "kind": kind, "foot_xyz_m": xyz(number(value["x"], path), number(value["y"], path)),
                              "metadata": {k: v for k, v in value.items() if k not in {"x", "y", "id", "type"}},
                              "runtime_mapping": mapping, "runtime_enabled": False, "source": provenance(path, None)})
        inert(path, stable_id, "map to existing Maris wrapper at M015; no duplicate NPC" if mapping else "inert provenance; no AI, interaction, economy or extra collision")
    for field, handler in [("artLayers", art_layer), ("colliders", collider), ("portals", portal)]:
        for i, value in enumerate(records(world[field], field)):
            handler(value, f"{field}[{i}]", None)
    for i, group in enumerate(records(world["groups"], "groups")):
        path = f"groups[{i}]"
        keys(group, path, "id pivotX pivotY quarterTurns artLayers props colliders portals")
        stable_id = identity(group, path, "groups")
        for field in ["pivotX", "pivotY", "quarterTurns"]:
            number(group[field], path + "." + field, integer=True)
        groups.append({"id": stable_id, "pivot_source_cells": [group["pivotX"], group["pivotY"]],
                       "quarter_turns": group["quarterTurns"] % 4, "source_path": path})
        for field, handler in [("artLayers", art_layer), ("props", prop), ("colliders", collider), ("portals", portal)]:
            for j, value in enumerate(records(group[field], path + "." + field)):
                handler(value, f"{path}.{field}[{j}]", group)
    zones, activities = [], []
    for i, zone in enumerate(records(world["zones"], "zones")):
        path = f"zones[{i}]"
        keys(zone, path, "id role label left top width height")
        stable_id = identity(zone, path, "zones")
        zones.append({"id": stable_id, "role": string(zone["role"], path), "label": string(zone["label"], path), "rect_xz_m": rect(zone, path)})
        inert(path, stable_id, "zone metadata only; no source eligibility/schedules")
    for i, area in enumerate(records(world["activityAreas"], "activityAreas")):
        path = f"activityAreas[{i}]"
        keys(area, path, "id label shape activities")
        stable_id = identity(area, path, "activity_areas")
        shape = area["shape"]
        require(isinstance(shape, dict), path, "expected shape object")
        if shape.get("kind") == "rectangle":
            keys(shape, path, "kind left top width height")
            geometry = {"kind": "rectangle", "rect_xz_m": rect(shape, path)}
        else:
            require(shape.get("kind") == "polygon", path, "unknown activity shape")
            keys(shape, path, "kind points")
            geometry = {"kind": "polygon", "vertices_xz_m": [xz(*p) for p in polygon(shape["points"], path)]}
        for profile in records(area["activities"], path):
            keys(profile, path, "activityId blendWeight outcomes")
            string(profile["activityId"], path)
            number(profile["blendWeight"], path, positive=True)
            for outcome in records(profile["outcomes"], path):
                keys(outcome, path, "itemId probability")
                string(outcome["itemId"], path)
                require(0 <= number(outcome["probability"], path) <= 1, path, "invalid probability")
        activities.append({"id": stable_id, "label": string(area["label"], path), "shape": geometry, "source_profiles": area["activities"], "runtime_enabled": False})
        inert(path, stable_id, "activity geometry retained; fishing/resource economy excluded")
    for field in ["artDirection", "lighting"]:
        if field in world:
            inert(field, field, "source appearance metadata retained; renderer/cycle excluded")
    for stable_id in sorted(used_defs):
        inert("catalog." + stable_id, stable_id, "sprite/shadow/light metadata is appearance reference only; images and renderer not imported")
    layout = {
        "schema_version": 1, "map_id": "alderwake", "runtime_location_id": "prototype-alderwake", "candidate_only": True,
        "provenance": {**manifest, "manifest_sha256": digest((reference / "manifest.json").read_bytes()),
                       "extractor_sha256": digest(Path(__file__).read_bytes())},
        "coordinates": {"source_units_per_metre": SCALE, "source_origin_units": list(ORIGIN), "height_per_level_m": 0.25,
                        "source_y_axis": "godot-positive-z", "bounds_xz_m": [-22, -18, columns, rows]},
        "spawn_xyz_m": xyz(*ORIGIN), "tile_layers": tile_layers, "art_layers": art_layers, "props": props,
        "colliders": colliders, "portals": portals, "inert_objects": inert_objects, "groups": groups,
        "elevation": {"cell_size_m": 1, "default_level": 0, "cells": sorted(elevation, key=lambda c: (c["cell"][1], c["cell"][0])), "slopes": slopes},
        "zones": zones, "activity_areas": activities,
        "appearance_reference": {field: world.get(field) for field in ["artDirection", "lighting"]},
        "catalog_reference": [definitions[key] for key in sorted(used_defs)],
        "material_reference": [materials[key] for key in sorted(used_materials)],
        "raw_tile_reference": [raw_tiles[key] for key in sorted(used_raw)],
        "art_tile_reference": {key: art_tiles[key] for key in sorted(used_art)},
    }
    report["counts"] = {key: len(layout[key]) for key in ["props", "colliders", "portals", "inert_objects", "groups", "zones", "activity_areas", "art_layers"]}
    report["counts"].update(elevation_cells=len(elevation), slopes=len(slopes), enabled_catalog_collisions=sum(p["collision"] is not None for p in props))
    report["unused_registry_entries"] = {
        "prop_definitions": sorted(definitions.keys() - used_defs),
        "materials": sorted(materials.keys() - used_materials),
        "raw_tiles": sorted(raw_tiles.keys() - used_raw),
        "art_tiles": sorted(art_tiles.keys() - used_art),
        "reason": "catalog registry entries not referenced by this exterior; not emitted into runtime layout",
    }
    report["provenance"] = layout["provenance"]
    return layout, report


def encoded(value: dict) -> bytes:
    return (json.dumps(value, indent=2, ensure_ascii=False, allow_nan=False) + "\n").encode("utf-8")


def run(reference: Path, output: Path, report_path: Path, check: bool) -> None:
    layout, report = extract(reference)
    # Validate/encode both documents before touching either output.
    outputs = [(output, encoded(layout)), (report_path, encoded(report))]
    for path, data in outputs:
        if check:
            require(path.is_file() and path.read_bytes() == data, str(path), "stale or missing output; regenerate from pinned inputs")
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
    print(f"M002 {'check' if check else 'extract'} PASS: {json.dumps(report['counts'], sort_keys=True)}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="read-only byte and pinned-hash check; fails on drift")
    parser.add_argument("--reference", type=Path, default=REFERENCE, help="target-local snapshot or test fixture")
    parser.add_argument("--output", type=Path, default=OUTPUT)
    parser.add_argument("--report", type=Path, default=REPORT)
    args = parser.parse_args()
    try:
        run(args.reference, args.output, args.report, args.check)
    except (LayoutError, OSError, ValueError, KeyError, TypeError) as error:
        print(f"M002 FAIL: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
