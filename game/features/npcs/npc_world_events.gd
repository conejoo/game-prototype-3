class_name NpcWorldEvents
extends RefCounted
## Transient scene membership; restoration/rebinding seeds, never invents entry.
var _owner: WeakRef
var _inside: bool = false

func bind(run: GameSession, location: PrototypeLocation, foot: Vector3) -> void:
	_owner = weakref(run)
	_inside = contains_woods(location, foot)

func clear() -> void:
	_owner = null

func observe(run: GameSession, location: PrototypeLocation, foot: Vector3, service: NpcDialogueService) -> void:
	if _owner == null or _owner.get_ref() != run or not location.is_inside_tree(): return
	var inside: bool = contains_woods(location, foot)
	if inside and not _inside: service.record_event(NpcEventMemory.AREA, "woods", null)
	_inside = inside

static func contains_woods(location: PrototypeLocation, foot: Vector3) -> bool:
	if not location is AlderwakeExterior or not foot.is_finite(): return false
	for zone: Dictionary in (location as AlderwakeExterior).layout.zones:
		if zone.role != "woods": continue
		var rect: Array = zone.rect_xz_m
		if Rect2(rect[0],rect[1],rect[2],rect[3]).has_point(Vector2(foot.x,foot.z)): return true
	return false
