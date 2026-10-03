extends SceneTree
## M002 data-consumption acceptance; no scene, movement or visual claim.

var failures: Array[String] = []


func _initialize() -> void:
	var text: String = FileAccess.get_file_as_string("res://content/maps/alderwake_layout.json")
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		push_error("M002 runtime layout JSON failed to load")
		quit(1)
		return
	var layout: Dictionary = parser.data
	_check(layout.schema_version == 1 and layout.candidate_only, "Candidate data schema")
	_check(layout.props.size() == 468 and layout.colliders.size() == 102, "Footprint inventory")
	_check(layout.portals.size() == 7 and layout.groups.size() == 31, "Portal/group inventory")
	_check(layout.tile_layers[0].cells.is_empty(), "Empty ground overrides")
	_check(layout.tile_layers[0].default_paint.material == "grass", "Default grass retained")
	_check(layout.tile_layers[0].cell_size_m == 0.5 and layout.tile_layers[3].cell_size_m == 1.0, "Mixed grid scale")
	_check(layout.elevation.cells.size() == 472 and layout.elevation.slopes.size() == 16, "Height metadata")
	var active_routes: int = 0
	for value: Variant in layout.portals:
		var portal: Dictionary = value
		_check(not portal.runtime_enabled, "M002 must not activate routes")
		if portal.phase_role == "activate-at-M015":
			active_routes += 1
			_check(portal.id == "tollworks-entrance-01", "Only Tollworks retained for activation")
	_check(active_routes == 1, "Single future active route")
	var moonwell_found: bool = false
	for value: Variant in layout.props:
		var prop: Dictionary = value
		if prop.id == "moonwell-prop":
			moonwell_found = true
			_check(is_equal_approx(float(prop.foot_xyz_m[0]), 31.51317596435547), "Fractional Moonwell X")
			_check(is_equal_approx(float(prop.foot_xyz_m[2]), 4.621034622192383), "Fractional Moonwell Z")
			_check(prop.collision.vertices_xz_m.size() == 8, "Moonwell polygon")
	_check(moonwell_found, "Moonwell record present")
	_check(not text.contains("D:/development/game-prototype-2") and not text.contains("D:\\development\\game-prototype-2"), "Target-local runtime data")
	if failures.is_empty():
		print("M002 map_layout_checks PASS: target-local JSON, inventories, defaults, mixed grids, heights, inert portals and fractional polygon")
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
