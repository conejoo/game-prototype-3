class_name ForagingState
extends RefCounted
## Session-owned atomic commands. Injected geometry is a capability, not scene ownership.
## Root must additionally reselect/revalidate physical targets before invoking commands.

signal committed(revision: int)

var initialized: bool = false
var _owner: WeakRef
var _catalog: ContentCatalog
var _collected: PackedStringArray = []
var _placements: Dictionary[String, WorldItemPlacement] = {}
var _world_revision: int = 0
var _command_active: bool = false
var _placement_validator: Callable
var _restored: bool = false


func initialize(catalog: ContentCatalog, session: GameSession) -> PackedStringArray:
	if initialized or catalog == null or not catalog.initialized or session == null or not session.inventory.initialized:
		return PackedStringArray(["foraging requires a fresh state, catalog and session inventory"])
	var errors: PackedStringArray = ForagingRegistry.validation_errors(catalog)
	if not errors.is_empty():
		return errors
	_catalog = catalog
	_owner = weakref(session)
	initialized = true
	return []


func restore_facts(inventory: Dictionary, collected: PackedStringArray, placements: Array) -> PackedStringArray:
	# Candidate-only hydration. Cannot replace a live, commanded or capability-bound state.
	var owner: GameSession = _session()
	if not initialized or owner == null or _command_active or _restored or revision() != 0:
		return PackedStringArray(["restore requires fresh foraging state"])
	if not _collected.is_empty() or not _placements.is_empty() or not owner.inventory.snapshot().item_counts.is_empty() or not get_signal_connection_list("committed").is_empty():
		return PackedStringArray(["restore requires fresh foraging state"])
	var errors: PackedStringArray = ForagingSaveData.validate(inventory, collected, placements, _catalog)
	if not errors.is_empty(): return errors
	var bag: InventoryState = InventoryState.new()
	bag.initialize(_catalog)
	for id: String in inventory.item_counts:
		bag.add(id, int(inventory.item_counts[id]))
	bag.select(inventory.active_item_id)
	# Hydration publishes no command/revision or signal.
	bag._revision = 0
	_restored = true
	owner.inventory = bag
	_collected = collected.duplicate()
	_collected.sort()
	for record: Dictionary in placements:
		var placed: WorldItemPlacement = ForagingSaveData.from_record(record)
		_placements[placed.instance_id] = placed
	return []


func bind_placement_validator(validator: Callable) -> PackedStringArray:
	if not initialized or _command_active:
		return PackedStringArray(["command_busy" if _command_active else "not_initialized"])
	# Empty capability deliberately disables placement; it never permits unchecked drops.
	_placement_validator = validator
	_world_revision += 1
	return []


func revision() -> int:
	var session: GameSession = _session()
	return _world_revision + (session.inventory.revision() if session != null else 0)


func snapshot() -> Dictionary:
	var placements: Array[Dictionary] = []
	var ids: Array[String] = _placements.keys()
	ids.sort()
	for id: String in ids:
		placements.append(_placements[id].to_dictionary())
	var session: GameSession = _session()
	return {"inventory": session.inventory.snapshot().to_dictionary() if session != null else {},
		"collected_resource_ids": _collected.duplicate(), "world_item_placements": placements, "revision": revision()}


func placement(instance_id: String) -> WorldItemPlacement:
	return _placements[instance_id].detached() if _placements.has(instance_id) else null


func is_collected(instance_id: String) -> bool:
	return instance_id in _collected


func rod_count() -> int:
	var session: GameSession = _session()
	var count: int = session.inventory.count(ForagingRegistry.ROD_ITEM) if session != null else 0
	if not is_collected(ForagingRegistry.ROD_ORIGIN):
		count += 1 # Default and authored override are the SAME origin.
	if _placements.has(ForagingRegistry.DROP_ID):
		count += 1
	return count


func gather(location_id: String, instance_id: String, resource_id: String, expected_revision: Variant) -> ForagingCommandResult:
	return _collect("gather", location_id, instance_id, resource_id, expected_revision)


func pickup(location_id: String, instance_id: String, resource_id: String, expected_revision: Variant) -> ForagingCommandResult:
	return _collect("pickup", location_id, instance_id, resource_id, expected_revision)


func _collect(kind: String, location_id: String, instance_id: String, resource_id: String, expected_revision: Variant) -> ForagingCommandResult:
	var errors: PackedStringArray = _guard(location_id, expected_revision)
	var entry: Dictionary = ForagingRegistry.find(instance_id)
	var placed: WorldItemPlacement = _placements.get(instance_id)
	var item_id: String = ""
	if errors.is_empty():
		if instance_id == ForagingRegistry.DROP_ID and placed != null:
			entry = {"location_id": placed.location_id, "resource_id": ForagingRegistry.ROD_RESOURCE, "item_id": placed.item_id}
		if entry.is_empty():
			errors.append("unknown_instance")
		elif entry.location_id != location_id:
			errors.append("wrong_location")
		elif entry.resource_id != resource_id:
			errors.append("resource_mismatch")
		else:
			item_id = entry.item_id
			var definition: ItemDefinition = _catalog.get_item(item_id)
			if (kind == "pickup") != definition.movable_pickup:
				errors.append("wrong_operation")
			elif is_collected(instance_id):
				errors.append("already_collected")
			else:
				errors.append_array(_session().inventory.can_add(item_id))
	if not errors.is_empty():
		return _result(kind, instance_id, item_id, errors)
	_command_active = true
	# No callbacks/signals between inventory mutation and world-fact commit.
	_session().inventory.add(item_id)
	if instance_id != ForagingRegistry.DROP_ID:
		_collected.append(instance_id)
		_collected.sort()
	_placements.erase(instance_id)
	return _publish(kind, instance_id, item_id)


func drop(location_id: String, item_id: String, foot: Vector3, expected_revision: Variant) -> ForagingCommandResult:
	var errors: PackedStringArray = _guard(location_id, expected_revision)
	if errors.is_empty():
		if item_id != ForagingRegistry.ROD_ITEM:
			errors.append("not_movable")
		elif not is_collected(ForagingRegistry.ROD_ORIGIN) or not _placements.is_empty() or _session().inventory.count(item_id) != 1:
			errors.append("missing_owned_item")
	if not errors.is_empty():
		return _result("drop", ForagingRegistry.DROP_ID, item_id, errors)
	var candidate: WorldItemPlacement = WorldItemPlacement.new(ForagingRegistry.DROP_ID, location_id, foot, WorldItemPlacement.GENERATED)
	return _place("drop", candidate, expected_revision)


func move(location_id: String, instance_id: String, item_id: String, foot: Vector3, expected_revision: Variant) -> ForagingCommandResult:
	var errors: PackedStringArray = _guard(location_id, expected_revision)
	var candidate: WorldItemPlacement = placement(instance_id)
	if errors.is_empty():
		if item_id != ForagingRegistry.ROD_ITEM:
			errors.append("not_movable")
		elif candidate == null and instance_id == ForagingRegistry.ROD_ORIGIN and not is_collected(instance_id) and location_id == ForagingRegistry.LOCATION:
			candidate = WorldItemPlacement.new(instance_id, location_id, foot, WorldItemPlacement.AUTHORED)
		elif candidate == null:
			errors.append("missing_world_item")
		elif candidate.item_id != item_id or candidate.location_id != location_id:
			errors.append("placement_mismatch")
	if not errors.is_empty():
		return _result("move", instance_id, item_id, errors)
	candidate.foot = foot
	return _place("move", candidate, expected_revision)


func _place(kind: String, candidate: WorldItemPlacement, expected_revision: Variant) -> ForagingCommandResult:
	var errors: PackedStringArray = candidate.validation_errors()
	if errors.is_empty() and not _placement_validator.is_valid():
		errors.append("placement_unavailable")
	if not errors.is_empty():
		return _result(kind, candidate.instance_id, candidate.item_id, errors)
	_command_active = true
	# Validator receives copies only. It must return PackedStringArray: empty = valid.
	var validation: Variant = _placement_validator.call(candidate.detached(), snapshot())
	if not validation is PackedStringArray:
		errors.append("invalid_placement_capability")
	else:
		errors.append_array(validation)
	# Recheck after external validation: capacity/selection/location may have changed.
	if errors.is_empty():
		errors.append_array(_guard(candidate.location_id, expected_revision, true))
	if not errors.is_empty():
		_command_active = false
		return _result(kind, candidate.instance_id, candidate.item_id, errors)
	if kind == "drop":
		_session().inventory.consume(candidate.item_id)
	_placements[candidate.instance_id] = candidate.detached()
	return _publish(kind, candidate.instance_id, candidate.item_id, candidate)


func _guard(location_id: String, expected_revision: Variant, inside_command: bool = false) -> PackedStringArray:
	var session: GameSession = _session()
	if not initialized or session == null or not session.initialized:
		return PackedStringArray(["not_initialized"])
	if _command_active and not inside_command:
		return PackedStringArray(["command_busy"])
	if typeof(expected_revision) != TYPE_INT or expected_revision != revision():
		return PackedStringArray(["stale_revision"])
	if _catalog.get_location(location_id) == null or session.current_location_id != location_id:
		return PackedStringArray(["wrong_location"])
	if rod_count() != 1:
		return PackedStringArray(["rod_ownership_conflict"])
	return []


func _publish(kind: String, id: String, item: String, placed: WorldItemPlacement = null) -> ForagingCommandResult:
	_world_revision += 1
	var result: ForagingCommandResult = _result(kind, id, item, [], placed)
	# Result token fixed before callbacks. Nested world commands reject until return.
	committed.emit(revision())
	_command_active = false
	return result


func _result(kind: String, id: String, item: String, errors: PackedStringArray = [], placed: WorldItemPlacement = null) -> ForagingCommandResult:
	return ForagingCommandResult.new(kind, id, item, revision(), errors, placed)


func _session() -> GameSession:
	return _owner.get_ref() as GameSession if _owner != null else null
