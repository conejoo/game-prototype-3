class_name FishingAreaDefinition
extends ContentDefinition
## Typed, immutable adapter output from the pinned map. One fishing profile per area.

@export var location_id: String = "prototype-alderwake"
@export_enum("rectangle", "polygon") var shape_kind: String = "rectangle"
@export var rectangle: Rect2 = Rect2()
@export var polygon: PackedVector2Array = []
@export var blend_weight: float = 1.0
@export var outcome_source_ids: PackedStringArray = []
@export var probabilities: PackedFloat64Array = []

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if location_id.is_empty() or location_id != location_id.strip_edges():
		errors.append("invalid fishing area location ID")
	if shape_kind == "rectangle":
		if not rectangle.position.is_finite() or not rectangle.size.is_finite() or rectangle.size.x <= 0.0 or rectangle.size.y <= 0.0 or not polygon.is_empty():
			errors.append("invalid fishing rectangle")
	elif shape_kind == "polygon":
		if polygon.size() < 3 or rectangle != Rect2():
			errors.append("invalid fishing polygon")
		var twice_area: float = 0.0
		for index: int in polygon.size():
			var a: Vector2 = polygon[index]
			var b: Vector2 = polygon[(index + 1) % polygon.size()]
			if not a.is_finite() or a == b:
				errors.append("invalid fishing polygon vertex")
			twice_area += a.cross(b)
			for other: int in range(index + 1, polygon.size()):
				var next: int = (other + 1) % polygon.size()
				if other == index + 1 or next == index: continue
				if Geometry2D.segment_intersects_segment(a, b, polygon[other], polygon[next]) != null:
					errors.append("self-intersecting fishing polygon")
		if not is_finite(twice_area) or absf(twice_area) <= 1e-12:
			errors.append("degenerate fishing polygon")
	else:
		errors.append("unknown fishing shape")
	if not is_finite(blend_weight) or blend_weight <= 0.0:
		errors.append("fishing blend weight must be finite and positive")
	if outcome_source_ids.is_empty() or outcome_source_ids.size() != probabilities.size():
		errors.append("invalid fishing outcomes")
	var seen: PackedStringArray = []
	var mass: float = 0.0
	for id: String in outcome_source_ids:
		if id.is_empty() or id != id.strip_edges() or id in seen:
			errors.append("invalid or duplicate fishing outcome ID")
		seen.append(id)
	for probability: float in probabilities:
		if not is_finite(probability) or probability < 0.0 or probability > 1.0:
			errors.append("fishing probability must be finite in [0,1]")
		mass += probability
	if not is_finite(mass) or mass > 1.0:
		errors.append("fishing probability mass exceeds one")
	return errors

func contains(point: Vector2) -> bool:
	if not point.is_finite(): return false
	if shape_kind == "rectangle":
		return point.x >= rectangle.position.x and point.y >= rectangle.position.y and point.x <= rectangle.end.x and point.y <= rectangle.end.y
	# Preserve the frozen source predicate's 1e-6 source-unit epsilon, including edges.
	var p: Vector2 = point * 32.0 + Vector2(704, 576)
	var inside: bool = false
	for index: int in polygon.size():
		var a: Vector2 = polygon[index] * 32.0 + Vector2(704, 576)
		var b: Vector2 = polygon[(index + 1) % polygon.size()] * 32.0 + Vector2(704, 576)
		var cross: float = (p.x-a.x)*(b.y-a.y)-(p.y-a.y)*(b.x-a.x)
		if absf(cross) <= 1e-6 and p.x >= minf(a.x,b.x)-1e-6 and p.x <= maxf(a.x,b.x)+1e-6 and p.y >= minf(a.y,b.y)-1e-6 and p.y <= maxf(a.y,b.y)+1e-6:
			return true
		if (b.y > p.y) != (a.y > p.y) and p.x < (a.x-b.x)*(p.y-b.y)/(a.y-b.y)+b.x:
			inside = not inside
	return inside
