"""M002 acceptance tests. Fixture edits affect temporary target-local copies only."""
from __future__ import annotations

from contextlib import redirect_stdout
import copy
import io
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

import extract_layout as extractor


class ExtractionChecks(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.layout, cls.report = extractor.extract()

    def fixture(self, mutate, name="mvp_world.json") -> Path:
        directory = tempfile.TemporaryDirectory(prefix="m002-")
        self.addCleanup(directory.cleanup)
        reference = Path(directory.name) / "reference"
        shutil.copytree(extractor.REFERENCE, reference)
        document = extractor.read_json(reference / name)
        mutate(document)
        # Deliberately permit non-finite tokens in negative fixtures; production output forbids them.
        (reference / name).write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
        manifest = extractor.read_json(reference / "manifest.json")
        next(x for x in manifest["inputs"] if x["file"] == name)["sha256"] = extractor.digest((reference / name).read_bytes())
        (reference / "manifest.json").write_bytes(extractor.encoded(manifest))
        return reference

    def reject(self, mutate, message, name="mvp_world.json") -> None:
        with self.assertRaisesRegex(extractor.LayoutError, message):
            extractor.extract(self.fixture(mutate, name))

    def test_inventory_and_record_disposition(self):
        self.assertEqual(self.report["counts"], dict(activity_areas=3, art_layers=8, colliders=102,
            elevation_cells=472, enabled_catalog_collisions=455, groups=31, inert_objects=91,
            portals=7, props=468, slopes=16, zones=25))
        self.assertEqual(len(self.layout["tile_layers"]), 4)
        disposition = {r["id"] for r in self.report["excluded_or_inert"]}
        for r in self.layout["inert_objects"] + self.layout["portals"] + self.layout["zones"] + self.layout["activity_areas"]:
            self.assertIn(r["id"], disposition)
        self.assertTrue(all(not r["runtime_enabled"] for r in self.layout["inert_objects"] + self.layout["portals"]))
        # Source IDs are namespaced. Both authored collision and prop must survive.
        self.assertIn("passenger-broken-piling-01", {r["id"] for r in self.layout["props"]})
        self.assertIn("passenger-broken-piling-01", {r["id"] for r in self.layout["colliders"]})

    def test_mixed_grids_and_empty_default(self):
        ground, terrain, shore, decor = self.layout["tile_layers"]
        self.assertEqual(ground["cells"], [])
        self.assertEqual(ground["default_paint"], {"kind": "centerMaterial", "material": "grass"})
        self.assertEqual([l["cell_size_m"] for l in [ground, terrain, shore, decor]], [.5, .5, .5, 1])
        self.assertEqual([len(l["cells"]) for l in [ground, terrain, shore, decor]], [0, 13478, 156, 183])
        self.assertEqual(ground["grid_size"], [294, 160])
        self.assertEqual(decor["grid_size"], [147, 80])
        self.assertEqual(ground["origin_xz_m"], [-22, -18])
        def edit(m):
            m["tileLayers"][0]["cells"] = [{"x": 0, "y": 0, "paint": None}]
        layout, _ = extractor.extract(self.fixture(edit))
        self.assertIsNone(layout["tile_layers"][0]["cells"][0]["paint"])
        self.assertEqual(layout["tile_layers"][0]["default_paint"]["material"], "grass")

    def test_fractional_moonwell_polygon_chandlery_and_gate(self):
        props = {p["id"]: p for p in self.layout["props"]}
        moonwell = props["moonwell-prop"]
        self.assertEqual(moonwell["source_foot_units"], [1712.421630859375, 723.8731079101562])
        self.assertEqual(moonwell["foot_xyz_m"], [31.51317596435547, .5, 4.621034622192383])
        self.assertEqual(moonwell["collision"]["kind"], "polygon")
        self.assertEqual(len(moonwell["collision"]["vertices_xz_m"]), 8)
        self.assertEqual(moonwell["collision"]["vertices_xz_m"][0], [30.66942596435547, 2.089784622192383])
        chandlery = next(p for p in props.values() if p["definition_id"] == "reed-chandlery")
        self.assertEqual(chandlery["collision"]["rect_xz_m"], [-9.8125, 7.75, 5.28125, 2.125])
        gate = next(p for p in props.values() if p["definition_id"] == "blocked-gate")
        self.assertFalse(gate["collision_enabled"])
        self.assertIsNone(gate["collision"])
        self.assertEqual(next(c for c in self.layout["colliders"] if c["id"] == "future-exit-gate")["rect_xz_m"], [123, -11, 2, 8])

    def test_all_portals_against_independent_m001_measurements(self):
        measured = extractor.read_json(extractor.ROOT / "docs/evidence/M001/source-measurements.json")
        portals = {p["id"]: p for p in self.layout["portals"]}
        self.assertEqual(set(portals), {p["id"] for p in measured["portals"]})
        for p in measured["portals"]:
            actual = portals[p["id"]]
            l, t, w, h = p["source_rect"]
            self.assertEqual(actual["rect_xz_m"], [(l - 704) / 32, (t - 576) / 32, w / 32, h / 32])
            self.assertEqual(actual["destination_map_id"], p["destination"])
            self.assertEqual(actual["destination_source_units"], p["destination_source"])
        self.assertEqual(portals["tollworks-entrance-01"]["destination_source_units"], [128, 480])
        self.assertEqual(portals["tollworks-entrance-01"]["runtime_mapping"]["arrival_xyz_m"], [0, 0, -2.5])
        self.assertEqual(sum(p["phase_role"] == "activate-at-M015" for p in portals.values()), 1)

    def test_tree_inventory_and_metadata(self):
        source = extractor.read_json(extractor.REFERENCE / "mvp_world.json")
        catalog = extractor.read_json(extractor.REFERENCE / "catalog.json")
        tree_defs = {d["id"] for d in catalog["objects"] if d["category"] == "trees"}
        source_trees = [p for p in source["objects"] if p.get("definitionId") in tree_defs]
        source_trees += [p for g in source["groups"] for p in g["props"] if p["definitionId"] in tree_defs]
        actual = [p for p in self.layout["props"] if p["tree"]]
        self.assertEqual({p["id"] for p in actual}, {p["id"] for p in source_trees})
        self.assertTrue(all(p["tree"]["size"] in ("standard", "small", "large") for p in actual))
        self.assertTrue(all(p["collision"]["kind"] == "box" for p in actual if p["collision"]))

    def test_all_quarter_turns_in_integrated_group_fixture(self):
        # Independent hand-calculated world feet/cells for pivot (30,30), local foot (16,8), cell (2,3).
        feet = [(976, 968), (952, 976), (944, 952), (968, 944)]
        cells = [(32, 33), (26, 32), (27, 26), (33, 27)]
        for q in [0, 1, 2, 3, -1, 5]:
            with self.subTest(quarter_turns=q):
                def edit(m):
                    m["groups"] = [{"id": "rotation-fixture", "pivotX": 30, "pivotY": 30, "quarterTurns": q,
                        "props": [{"type": "prop", "id": "rotated-box", "definitionId": "reed-chandlery", "x": 16, "y": 8},
                                  {"type": "prop", "id": "rotated-polygon", "definitionId": "moonwell", "x": 16, "y": 8}],
                        "artLayers": [{"id": "art", "name": "Fixture", "visible": True, "cells": [{"x": 2, "y": 3, "tileId": "tiles/world/moonwood_footbridge/moonwood-footbridge-r1-c0.png"}]}],
                        "colliders": [{"id": "rotated-rect", "left": 0, "top": 0, "width": 64, "height": 32}],
                        "portals": [{"id": "rotated-portal", "label": "Fixture", "prompt": "Inert", "left": 0, "top": 0, "width": 64, "height": 32,
                            "destinationMapId": "other", "destinationX": 123.5, "destinationY": 456.25}]}]
                layout, _ = extractor.extract(self.fixture(edit))
                box, poly = layout["props"][-2:]
                fx, fy = feet[q % 4]
                self.assertEqual(box["source_foot_units"], [fx, fy])
                self.assertEqual(box["yaw_degrees"], -(q % 4) * 90)
                self.assertEqual(layout["art_layers"][-1]["cells"][0]["cell"], list(cells[q % 4]))
                expected_first_offsets = [(-27, -81), (81, -27), (27, 81), (-81, 27)]
                px, py = expected_first_offsets[q % 4]
                self.assertEqual(poly["collision"]["vertices_xz_m"][0], [(fx + px - 704)/32, (fy + py - 576)/32])
                # Four independently calculated rotated rectangle extents (before metre/origin conversion).
                expected_rects = [(960,960,64,32),(928,960,32,64),(896,928,64,32),(960,896,32,64)]
                l,t,w,h = expected_rects[q % 4]
                expected = [(l-704)/32,(t-576)/32,w/32,h/32]
                self.assertEqual(layout["colliders"][-1]["rect_xz_m"], expected)
                self.assertEqual(layout["portals"][-1]["rect_xz_m"], expected)
                self.assertEqual(layout["portals"][-1]["destination_source_units"], [123.5,456.25])
                # Rotated Chandlery box must carry rotation about the foot, not sprite extent.
                offsets = [(-90,-72,169,68),(4,-90,68,169),(-79,4,169,68),(-72,-79,68,169)]
                l,t,w,h = offsets[q % 4]
                self.assertEqual(box["collision"]["rect_xz_m"], [(fx+l-704)/32,(fy+t-576)/32,w/32,h/32])

    def test_elevation_and_directional_slopes(self):
        slopes = self.layout["elevation"]["slopes"]
        self.assertEqual(len(slopes), 16)
        self.assertEqual(max(c["height_m"] for c in self.layout["elevation"]["cells"]), 1.75)
        for s in slopes:
            self.assertEqual(s["high_height_m"] - s["low_height_m"], .25)
        def edit(m):
            m["elevation"] = {"cells": [{"x": 29, "y": 30, "level": 1}, {"x": 31, "y": 30, "level": 2}],
                              "slopes": [{"id": "fixture-slope", "x": 30, "y": 30, "ascendsToward": "east"}]}
            m["objects"] = [{"type": "marker", "id": "fixture-probe", "markerKind": "fixture", "label": "fixture", "x": 968, "y": 976}]
        layout, _ = extractor.extract(self.fixture(edit))
        self.assertEqual(layout["inert_objects"][0]["foot_xyz_m"], [8.25,.3125,12.5])

    def test_all_cardinal_slope_height_formulas(self):
        # At local (.25,.5), N/E/S/W progress is .5/.25/.5/.75 respectively.
        for direction, high_cell, height in [("north", (30,29), .125), ("east", (31,30), .0625),
                                              ("south", (30,31), .125), ("west", (29,30), .1875)]:
            with self.subTest(direction=direction):
                def edit(m):
                    m["elevation"] = {"cells": [{"x": high_cell[0], "y": high_cell[1], "level": 1}],
                        "slopes": [{"id": "fixture-slope", "x": 30, "y": 30, "ascendsToward": direction}]}
                    m["objects"] = [{"type": "marker", "id": "fixture-probe", "markerKind": "fixture", "label": "fixture", "x": 968, "y": 976}]
                layout, _ = extractor.extract(self.fixture(edit))
                self.assertEqual(layout["inert_objects"][0]["foot_xyz_m"], [8.25,height,12.5])

    def test_repeat_generation_and_check_mode(self):
        self.assertEqual(extractor.encoded(self.layout), extractor.encoded(extractor.extract()[0]))
        directory = tempfile.TemporaryDirectory(prefix="m002-output-")
        self.addCleanup(directory.cleanup)
        output, report = Path(directory.name)/"layout.json", Path(directory.name)/"report.json"
        with redirect_stdout(io.StringIO()):
            extractor.run(extractor.REFERENCE, output, report, False)
            first = output.read_bytes()
            extractor.run(extractor.REFERENCE, output, report, False)
            self.assertEqual(first, output.read_bytes())
            extractor.run(extractor.REFERENCE, output, report, True)
        output.write_bytes(first + b" ")
        with self.assertRaisesRegex(extractor.LayoutError, "stale"):
            extractor.run(extractor.REFERENCE, output, report, True)

    def test_cli_stale_input_and_output_exit_one(self):
        ref = self.fixture(lambda m: None)
        output, report = ref.parent/"layout.json", ref.parent/"report.json"
        command = [sys.executable, str(Path(extractor.__file__)), "--reference", str(ref), "--output", str(output), "--report", str(report)]
        self.assertEqual(subprocess.run(command, capture_output=True).returncode, 0)
        self.assertEqual(subprocess.run(command + ["--check"], capture_output=True).returncode, 0)
        report.write_bytes(b"stale")
        stale = subprocess.run(command + ["--check"], capture_output=True, text=True)
        self.assertEqual(stale.returncode, 1)
        self.assertIn("stale", stale.stderr)
        (ref/"mvp_world.json").write_bytes((ref/"mvp_world.json").read_bytes() + b" ")
        stale = subprocess.run(command + ["--check"], capture_output=True, text=True)
        self.assertEqual(stale.returncode, 1)
        self.assertIn("pinned input hash mismatch", stale.stderr)
        self.assertEqual(report.read_bytes(), b"stale")  # check never repairs or refreshes

    def test_unknown_record_and_fields_rejected(self):
        self.reject(lambda m: m["objects"][0].update(type="unknown"), "unknown object type")
        self.reject(lambda m: m.update(unrecognized=[]), "unknown fields")
        self.reject(lambda m: m["groups"][0].update(unrecognized=[]), "unknown fields")
        self.reject(lambda m: m["objects"][0].update(definitionId="missing"), "unknown prop definition")

    def test_unknown_paint_material_and_art_rejected(self):
        self.reject(lambda m: m["tileLayers"][1]["cells"][0]["paint"].update(kind="unknown"), "unknown paint kind")
        self.reject(lambda m: m["tileLayers"][1]["cells"][0]["paint"].update(material="unknown"), "unknown material")
        self.reject(lambda m: m["tileLayers"][3]["cells"][0]["paint"].update(tileId="missing.png"), "unknown raw tile")
        def edit(m):
            next(g for g in m["groups"] if g["artLayers"])["artLayers"][0]["cells"][0]["tileId"] = "missing.png"
        self.reject(edit, "unknown art tile")

    def test_malformed_data_and_duplicates_rejected(self):
        self.reject(lambda m: m["objects"][0].update(x=float("inf")), "finite number")
        self.reject(lambda m: m["objects"][0].update(collisionEnabled="false"), "boolean")
        self.reject(lambda m: m["colliders"][0].update(width=0), "positive number")
        self.reject(lambda m: m["groups"][0].update(quarterTurns=.5), "integer")
        self.reject(lambda m: m["objects"].append(copy.deepcopy(m["objects"][0])), "duplicate objects")
        self.reject(lambda m: m["tileLayers"][1]["cells"].append(copy.deepcopy(m["tileLayers"][1]["cells"][0])), "duplicate paint cell")
        self.reject(lambda m: m["elevation"]["slopes"][0].update(ascendsToward="diagonal"), "unknown ascent")
        self.reject(lambda m: m["objects"][0].update(x=True), "finite number")
        self.reject(lambda m: m["tileLayers"][0].update(defaultPaint=None), "defaultPaint cannot be null")
        self.reject(lambda m: m["elevation"]["cells"][0].update(level=9), "level 1 through 8")
        def overlap(m):
            s = m["elevation"]["slopes"][0]
            m["elevation"]["cells"].append({"x": s["x"], "y": s["y"], "level": 1})
        self.reject(overlap, "slope overlaps")

    def test_catalog_collision_failures_rejected(self):
        self.reject(lambda c: c["objects"][0]["collision"].update(kind="circle"), "unknown collision kind", "catalog.json")
        self.reject(lambda c: c["objects"][0]["collision"].update(points=[{"x":0,"y":0}]), "three vertices", "catalog.json")
        self.reject(lambda c: c["objects"][0]["collision"].update(points=[{"x":0,"y":0},{"x":1,"y":1},{"x":2,"y":2}]), "degenerate", "catalog.json")

    def test_runtime_has_no_source_checkout_dependency(self):
        data = extractor.encoded(self.layout).decode("utf-8")
        self.assertNotIn("D:/development/game-prototype-2", data)
        self.assertNotIn("D:\\development\\game-prototype-2", data)
        self.assertNotIn(".dart", json.dumps({k:v for k,v in self.layout.items() if k != "provenance"}))


if __name__ == "__main__":
    unittest.main(verbosity=2)
