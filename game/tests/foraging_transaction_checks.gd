extends SceneTree
## F003 synthetic service/placement fixtures. No physical geometry, input or restart proof.

const FLOWER: String = "item-moonflower"
const ROD: String = ForagingRegistry.ROD_ITEM
const ORIGIN: String = ForagingRegistry.ROD_ORIGIN
const DROP: String = ForagingRegistry.DROP_ID
const ALDER: String = ForagingRegistry.LOCATION
const TOLL: String = "prototype-tollworks"
const RESOURCE: String = ForagingRegistry.ROD_RESOURCE
var failures: PackedStringArray = []
var assertions: int = 0
var catalog: ContentCatalog
var events: Array[Dictionary] = []
var validator_calls: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	catalog = ContentCatalog.new()
	_check(catalog.initialize(load("res://content/prototype_catalog.tres") as ContentManifest).is_empty(), "catalog init")
	_registry()
	_collection()
	_capacity()
	_rod_loop()
	_placement_boundary()
	_observers_and_isolation()
	_check(TestRunEvidence.write_json("foraging-transaction-report.json", {
		"task": "F003", "proof": "synthetic pure commands and injected placement fixtures; no physical/input/save proof",
		"assertions": assertions + 1, "failures": failures, "committed_observations": events,
		"validator_calls": validator_calls, "schema_version": SaveCodec.SCHEMA_VERSION
	}), "write evidence")
	for failure: String in failures:
		push_error(failure)
	print("F003 foraging_transaction_checks ", "PASS" if failures.is_empty() else "FAILED", "; assertions=", assertions)
	quit(0 if failures.is_empty() else 1)


func _registry() -> void:
	var vectors: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../docs/foraging-items-backpack/reference/behavior_vectors.json"))
	_check(ForagingRegistry.entries().size() == 4, "exactly four registry nodes")
	for entry: Dictionary in vectors.nodes:
		var mapped: Dictionary = ForagingRegistry.find(entry.instance_id)
		_check(mapped.location_id == entry.location_id and mapped.resource_id == entry.resource_id and mapped.item_id == entry.item_id, "pinned identity " + entry.instance_id)
		var raw: Array = entry.authored_foot_xyz_m
		_check(mapped.foot == Vector3(raw[0], raw[1], raw[2]), "exact Godot metres " + entry.instance_id)
		mapped.clear()
		_check(not ForagingRegistry.find(entry.instance_id).is_empty(), "registry copies detached")
	_check(ForagingRegistry.find(DROP).is_empty(), "generated identity never authored")
	var unready: ForagingState = ForagingState.new()
	_check(not unready.initialize(null, null).is_empty() and not unready.initialized, "bad service init atomic")
	_check(unready.gather(ALDER, "moonflower-01", "resource-moonflower", 0).errors == PackedStringArray(["not_initialized"]), "unready command rejects")
	var manifest: ContentManifest = (load("res://content/prototype_catalog.tres") as ContentManifest).duplicate(true)
	manifest.definitions.remove_at(20)
	var incomplete: ContentCatalog = ContentCatalog.new()
	_check(incomplete.initialize(manifest).is_empty(), "synthetic registry-missing manifest catalog valid")
	var session: GameSession = GameSession.new()
	_check(not session.initialize(incomplete, ALDER, "alderwake-start", "prototype-hero").is_empty(), "missing pinned resource rejects session")
	_check(not session.initialized and not session.inventory.initialized and not session.foraging.initialized, "no partial service publication")


func _collection() -> void:
	var session: GameSession = _session()
	var state: ForagingState = session.foraging
	_watch(session)
	var token: int = state.revision()
	_reject(state, _before(state), state.gather(ALDER, "absent", "resource-moonflower", token), "unknown_instance", "unknown")
	_reject(state, _before(state), state.gather(ALDER, "moonflower-01", RESOURCE, token), "resource_mismatch", "wrong definition")
	_reject(state, _before(state), state.gather(ALDER, "moonflower-01", FLOWER, token), "resource_mismatch", "item namespace rejects")
	_reject(state, _before(state), state.pickup(ALDER, "moonflower-01", "resource-moonflower", token), "wrong_operation", "pickup flower")
	_reject(state, _before(state), state.gather(ALDER, ORIGIN, RESOURCE, token), "wrong_operation", "gather rod")
	_reject(state, _before(state), state.gather(TOLL, "moonflower-01", "resource-moonflower", token), "wrong_location", "foreign committed room")
	for stale: Variant in [-1, token + 1, float(token), true, null, "0"]:
		_reject(state, _before(state), state.gather(ALDER, "moonflower-01", "resource-moonflower", stale), "stale_revision", "invalid token")
	var event_count: int = events.size()
	var result: ForagingCommandResult = state.gather(ALDER, "moonflower-01", "resource-moonflower", token)
	_check(result.accepted and result.operation == "gather" and result.instance_id == "moonflower-01" and result.item_id == FLOWER and result.revision == state.revision(), "structured gather success")
	_check(session.inventory.count(FLOWER) == 1 and state.is_collected("moonflower-01") and session.inventory.snapshot().active_item_id == null, "+1 and origin committed without equip")
	_check(events.size() == event_count + 1, "exactly one success publication")
	_reject(state, _before(state), state.gather(ALDER, "moonflower-02", "resource-moonflower", token), "stale_revision", "old token after gather")
	_reject(state, _before(state), state.gather(ALDER, "moonflower-01", "resource-moonflower", state.revision()), "already_collected", "duplicate")
	session.current_location_id = TOLL
	_reject(state, _before(state), state.gather(TOLL, "moonflower-02", "resource-moonflower", state.revision()), "wrong_location", "authored node belongs to Alderwake")
	session.current_location_id = ALDER
	_check(state.gather(ALDER, "moonflower-03", "resource-moonflower", state.revision()).accepted, "collect second flower")
	_check(state.gather(ALDER, "moonflower-02", "resource-moonflower", state.revision()).accepted, "collect final flower")
	_check(session.inventory.count(FLOWER) == 3 and state.snapshot().collected_resource_ids == PackedStringArray(["moonflower-01", "moonflower-02", "moonflower-03"]), "sorted unique authored collected set")
	_check(SaveCodec.SCHEMA_VERSION == 6 and SaveCodec.snapshot(session).has("inventory"), "F004 persistence available")


func _capacity() -> void:
	var session: GameSession = _session()
	var state: ForagingState = session.foraging
	_watch(session)
	_check(session.inventory.add(FLOWER, 99).is_empty() and session.inventory.select(FLOWER).is_empty(), "synthetic flower cap seed")
	_reject(state, _before(state), state.gather(ALDER, "moonflower-01", "resource-moonflower", state.revision()), "stack_full", "full flower node unchanged")
	_check(not state.is_collected("moonflower-01"), "full stack leaves origin")
	var manifest: ContentManifest = (load("res://content/prototype_catalog.tres") as ContentManifest).duplicate(true)
	for index: int in range(20):
		var item: ItemDefinition = ItemDefinition.new()
		item.stable_id = "test-only-capacity-%02d" % index
		item.source_item_id = item.stable_id
		item.display_name = "Synthetic capacity fixture"
		item.description = "F003 detached test-only manifest"
		item.prototype_fixture = true
		manifest.definitions.append(item)
	var fixture_catalog: ContentCatalog = ContentCatalog.new()
	_check(fixture_catalog.initialize(manifest).is_empty(), "test-only capacity catalog")
	session = _session(fixture_catalog)
	state = session.foraging
	_watch(session)
	for index: int in range(20):
		_check(session.inventory.add("test-only-capacity-%02d" % index).is_empty(), "fill capacity slot")
	_check(session.inventory.select("test-only-capacity-00").is_empty(), "full bag selection")
	_reject(state, _before(state), state.gather(ALDER, "moonflower-01", "resource-moonflower", state.revision()), "backpack_full", "full bag gathering")
	_reject(state, _before(state), state.pickup(ALDER, ORIGIN, RESOURCE, state.revision()), "backpack_full", "full bag rod pickup")
	_check(session.inventory.consume("test-only-capacity-19").is_empty(), "free one slot")
	_check(session.inventory.add(FLOWER, 98).is_empty(), "full bag existing flower stack98")
	_check(state.gather(ALDER, "moonflower-01", "resource-moonflower", state.revision()).accepted and session.inventory.count(FLOWER) == 99, "existing stack grows while20 types full")
	_reject(state, _before(state), state.gather(ALDER, "moonflower-02", "resource-moonflower", state.revision()), "stack_full", "100th full-bag flower")
	_check(session.inventory.consume(FLOWER, 99).is_empty(), "free rod slot")
	_check(state.pickup(ALDER, ORIGIN, RESOURCE, state.revision()).accepted, "rod pickup after capacity freed")
	_check(state.bind_placement_validator(_valid).is_empty(), "fixture geometry binding")
	_check(state.drop(ALDER, ROD, Vector3(2, 0, 2), state.revision()).accepted, "fixture rod drop")
	_check(session.inventory.add(FLOWER).is_empty(), "occupy twentieth slot again")
	_reject(state, _before(state), state.pickup(ALDER, DROP, RESOURCE, state.revision()), "backpack_full", "full bag leaves generated placement")
	_check(state.placement(DROP) != null and state.rod_count() == 1, "failed dropped pickup retains world rod")


func _rod_loop() -> void:
	var session: GameSession = _session()
	var state: ForagingState = session.foraging
	_watch(session)
	_check(state.rod_count() == 1 and state.revision() == 0, "fresh authored rod/revision")
	var pre_bind_token: int = state.revision()
	_check(state.bind_placement_validator(_valid).is_empty(), "bind synthetic valid geometry")
	_reject(state, _before(state), state.move(ALDER, ORIGIN, ROD, Vector3.ZERO, pre_bind_token), "stale_revision", "capability rebinding invalidates pending requests")
	for index: int in range(3):
		var result: ForagingCommandResult = state.move(ALDER, ORIGIN, ROD, Vector3(index + 1, 0, 4), state.revision())
		_check(result.accepted and result.placement.provenance == WorldItemPlacement.AUTHORED and result.placement.origin_instance_id == ORIGIN, "authored override provenance")
		_check(state.snapshot().world_item_placements.size() == 1 and not state.is_collected(ORIGIN) and state.rod_count() == 1, "authored move replaces origin, rod remains1")
		result.placement.foot = Vector3.INF
		_check(state.placement(ORIGIN).foot == Vector3(index + 1, 0, 4), "result placement detached")
	_check(state.bind_placement_validator(func(_placed: WorldItemPlacement, _facts: Dictionary) -> PackedStringArray: return PackedStringArray(["synthetic_blocked"])).is_empty(), "reject authored move geometry")
	_reject(state, _before(state), state.move(ALDER, ORIGIN, ROD, Vector3.ZERO, state.revision()), "synthetic_blocked", "invalid authored move keeps prior override")
	_check(state.bind_placement_validator(_valid).is_empty(), "restore authored move capability")
	_check(state.pickup(ALDER, ORIGIN, RESOURCE, state.revision()).accepted, "pickup moved authored rod")
	_check(state.is_collected(ORIGIN) and state.placement(ORIGIN) == null and session.inventory.count(ROD) == 1 and state.rod_count() == 1, "authored pickup jointly consumes override/suppresses origin")
	_reject(state, _before(state), state.pickup(ALDER, ORIGIN, RESOURCE, state.revision()), "already_collected", "rod duplicate grants nothing")
	_reject(state, _before(state), state.move(ALDER, ORIGIN, ROD, Vector3.ZERO, state.revision()), "missing_world_item", "suppressed origin cannot move")
	for index: int in range(8):
		session.current_location_id = ALDER if index % 2 == 0 else TOLL
		var location: String = session.current_location_id
		_check(session.inventory.select(ROD).is_empty(), "select rod")
		var result: ForagingCommandResult = state.drop(location, ROD, Vector3(index + 1, 0, 2), state.revision())
		_check(result.accepted and result.placement.instance_id == DROP and result.placement.provenance == WorldItemPlacement.GENERATED and result.placement.location_id == location, "deterministic generated drop identity")
		_check(session.inventory.count(ROD) == 0 and session.inventory.snapshot().active_item_id == null and state.is_collected(ORIGIN) and state.rod_count() == 1, "final drop clears active, retains suppressed origin, rod1")
		_reject(state, _before(state), state.drop(location, ROD, Vector3.ZERO, state.revision()), "missing_owned_item", "repeat drop rejects")
		_check(state.move(location, DROP, ROD, Vector3(index + 2, 0, 3), state.revision()).accepted, "move generated rod")
		_check(state.snapshot().world_item_placements.size() == 1 and state.rod_count() == 1, "generated move no duplication")
		var before: Dictionary = _before(state)
		session.current_location_id = TOLL if location == ALDER else ALDER
		_reject(state, before, state.pickup(session.current_location_id, DROP, RESOURCE, state.revision()), "wrong_location", "wrong generated room")
		_reject(state, before, state.move(session.current_location_id, DROP, ROD, Vector3.ZERO, state.revision()), "placement_mismatch", "cannot cross-room move")
		session.current_location_id = location
		var token: int = state.revision()
		_check(state.pickup(location, DROP, RESOURCE, token).accepted, "pickup generated rod")
		_check(state.placement(DROP) == null and session.inventory.count(ROD) == 1 and session.inventory.snapshot().active_item_id == null and state.rod_count() == 1, "generated pickup removes placement; bag1; no auto-equip")
		_check(state.snapshot().collected_resource_ids == PackedStringArray([ORIGIN]), "generated ID never collected fact")
		_reject(state, _before(state), state.pickup(location, DROP, RESOURCE, token), "stale_revision", "queued duplicate pickup")
		_reject(state, _before(state), state.pickup(location, DROP, RESOURCE, state.revision()), "unknown_instance", "removed placement cannot recollect")


func _placement_boundary() -> void:
	var session: GameSession = _session()
	var state: ForagingState = session.foraging
	_watch(session)
	_reject(state, _before(state), state.move(ALDER, ORIGIN, ROD, Vector3.ZERO, state.revision()), "placement_unavailable", "no unchecked authored move")
	_check(state.pickup(ALDER, ORIGIN, RESOURCE, state.revision()).accepted and session.inventory.select(ROD).is_empty(), "owned active rod setup")
	_reject(state, _before(state), state.drop(ALDER, ROD, Vector3.ZERO, state.revision()), "placement_unavailable", "no unchecked drop")
	_check(state.bind_placement_validator(func(_placed: WorldItemPlacement, _facts: Dictionary) -> PackedStringArray:
		validator_calls += 1
		return PackedStringArray(["synthetic_blocked"])).is_empty(), "bind rejecting geometry")
	_reject(state, _before(state), state.drop(ALDER, ROD, Vector3.ZERO, state.revision()), "synthetic_blocked", "placement failure keeps active/counts")
	_check(state.bind_placement_validator(func(_placed: WorldItemPlacement, _facts: Dictionary) -> bool: return true).is_empty(), "bind malformed capability")
	_reject(state, _before(state), state.drop(ALDER, ROD, Vector3.ZERO, state.revision()), "invalid_placement_capability", "bool is not validated geometry result")
	_check(state.bind_placement_validator(_valid).is_empty(), "rebind valid geometry")
	var calls: int = validator_calls
	for foot: Vector3 in [Vector3(NAN, 0, 0), Vector3(0, INF, 0), Vector3(0, 0, -INF)]:
		_reject(state, _before(state), state.drop(ALDER, ROD, foot, state.revision()), "invalid_position", "nonfinite foot")
	_check(validator_calls == calls, "bad feet reject before geometry callback")
	_reject(state, _before(state), state.drop(ALDER, FLOWER, Vector3.ZERO, state.revision()), "not_movable", "flower drop excluded")
	_reject(state, _before(state), state.move(ALDER, DROP, "fishing_rod", Vector3.ZERO, state.revision()), "not_movable", "source item ID excluded")
	_reject(state, _before(state), state.move(ALDER, "alias-rod", ROD, Vector3.ZERO, state.revision()), "missing_world_item", "aliases excluded")
	session.current_location_id = "prototype-test-room"
	_reject(state, _before(state), state.drop(session.current_location_id, ROD, Vector3.ZERO, state.revision()), "invalid_generated_placement", "unsupported committed room")
	session.current_location_id = ALDER
	var old_token: int = state.revision()
	_check(session.inventory.select(null).is_empty(), "selection revision changes")
	_reject(state, _before(state), state.drop(ALDER, ROD, Vector3.ZERO, old_token), "stale_revision", "old selection token")
	_check(session.inventory.select(ROD).is_empty(), "restore active selection")
	_check(state.bind_placement_validator(func(placed: WorldItemPlacement, facts: Dictionary) -> PackedStringArray:
		validator_calls += 1
		_check(state.drop(ALDER, ROD, Vector3.ZERO, state.revision()).errors == PackedStringArray(["command_busy"]), "nested geometry command rejects")
		_check(state.bind_placement_validator(Callable()).has("command_busy"), "geometry cannot rebind itself")
		placed.foot = Vector3.INF
		placed.item_id = FLOWER
		facts.inventory.item_counts.clear()
		facts.collected_resource_ids.clear()
		facts.world_item_placements.clear()
		return PackedStringArray()).is_empty(), "detached capability fixture")
	_check(state.drop(ALDER, ROD, Vector3(5, 0, 5), state.revision()).accepted, "capability cannot alter committed candidate")
	_check(state.placement(DROP).foot == Vector3(5, 0, 5) and state.placement(DROP).item_id == ROD and state.is_collected(ORIGIN) and state.rod_count() == 1, "copies protect placement and facts")
	_check(state.bind_placement_validator(func(_placed: WorldItemPlacement, _facts: Dictionary) -> PackedStringArray: return PackedStringArray(["synthetic_water"])).is_empty(), "reject generated move geometry")
	_reject(state, _before(state), state.move(ALDER, DROP, ROD, Vector3.ZERO, state.revision()), "synthetic_water", "invalid move rolls back position")
	_check(state.pickup(ALDER, DROP, RESOURCE, state.revision()).accepted, "recover rod for stale callback")
	_check(state.bind_placement_validator(func(_placed: WorldItemPlacement, _facts: Dictionary) -> PackedStringArray:
		session.inventory.select(ROD)
		return PackedStringArray()).is_empty(), "mutating selection callback fixture")
	var before: Dictionary = state.snapshot()
	var rejected: ForagingCommandResult = state.drop(ALDER, ROD, Vector3.ZERO, state.revision())
	_check(rejected.errors == PackedStringArray(["stale_revision"]) and session.inventory.count(ROD) == 1 and state.placement(DROP) == null and state.snapshot().collected_resource_ids == before.collected_resource_ids, "post-callback selection invalidates command without world mutation")
	_check(state.bind_placement_validator(func(_placed: WorldItemPlacement, _facts: Dictionary) -> PackedStringArray:
		session.current_location_id = TOLL
		return PackedStringArray()).is_empty(), "travel callback fixture")
	_reject(state, _before(state), state.drop(ALDER, ROD, Vector3.ZERO, state.revision()), "wrong_location", "post-validation location rechecked")
	session.current_location_id = ALDER
	_check(state.bind_placement_validator(_valid).is_empty(), "restore valid callback")
	_check(state.drop(ALDER, ROD, Vector3.ZERO, state.revision()).accepted, "guard released after callback rejection")
	var placement: WorldItemPlacement = state.placement(DROP)
	for field: String in ["instance_id", "item_id", "location_id", "provenance", "origin_instance_id"]:
		var invalid: WorldItemPlacement = placement.detached()
		invalid.set(field, "wrong")
		_check(not invalid.validation_errors().is_empty(), "strict typed placement field " + field)
	_check(placement.validation_errors().is_empty(), "generated placement valid")
	_check(state.bind_placement_validator(Callable()).is_empty(), "unbind capability")
	_reject(state, _before(state), state.move(ALDER, DROP, ROD, Vector3.ONE, state.revision()), "placement_unavailable", "unbinding fails closed")


func _observers_and_isolation() -> void:
	var first: GameSession = _session()
	var second: GameSession = _session()
	_watch(first)
	var weak_first: WeakRef = weakref(first)
	first.foraging.committed.connect(func(_token: int) -> void:
		var observed: GameSession = weak_first.get_ref() as GameSession
		_check(observed.foraging.snapshot() == events[-1], "second observer sees intact committed facts after first edits its snapshot")
	)
	var state: ForagingState = first.foraging
	_check(state != second.foraging, "session services independent")
	var other: Dictionary = second.foraging.snapshot()
	_check(state.gather(ALDER, "moonflower-02", "resource-moonflower", state.revision()).accepted, "first session gather")
	_check(second.foraging.snapshot() == other, "world facts and inventory isolated")
	var before: Dictionary = state.snapshot()
	var detached: Dictionary = state.snapshot()
	detached.inventory.item_counts.clear()
	detached.collected_resource_ids.clear()
	detached.world_item_placements.append({"instance_id": "alias"})
	_check(state.snapshot() == before, "snapshots detached")
	_check(not state.initialize(catalog, first).is_empty() and state.snapshot() == before, "reinitialization rejected atomically")
	var token: int = state.revision()
	_check(first.inventory.add(FLOWER).is_empty(), "generic add fixture invalidates token")
	_reject(state, _before(state), state.gather(ALDER, "moonflower-01", "resource-moonflower", token), "stale_revision", "inventory add invalidates token")
	token = state.revision()
	_check(first.inventory.consume(FLOWER).is_empty(), "generic consume fixture invalidates token")
	_reject(state, _before(state), state.gather(ALDER, "moonflower-01", "resource-moonflower", token), "stale_revision", "consume invalidates token")
	_check(first.inventory.add(ROD).is_empty(), "deliberately inconsistent generic rod fixture")
	_reject(state, _before(state), state.pickup(ALDER, ORIGIN, RESOURCE, state.revision()), "rod_ownership_conflict", "bag plus unsuppressed origin rejects")
	_reject(state, _before(state), state.drop(ALDER, ROD, Vector3.ZERO, state.revision()), "rod_ownership_conflict", "cannot turn invalid ownership into duplicate placement")
	_check(first.inventory.consume(ROD).is_empty(), "remove synthetic ownership conflict")
	_check(state.pickup(ALDER, ORIGIN, RESOURCE, state.revision()).accepted, "valid ownership recoverable")
	_check(first.inventory.consume(ROD).is_empty(), "deliberate missing-rod generic consume fixture")
	_reject(state, _before(state), state.move(ALDER, ORIGIN, ROD, Vector3.ZERO, state.revision()), "rod_ownership_conflict", "missing rod cannot respawn origin")
	var weak_state: ForagingState
	var weak_owner: WeakRef
	var temporary: GameSession = _session()
	weak_state = temporary.foraging
	weak_owner = weakref(temporary)
	temporary = null
	_check(weak_owner.get_ref() == null, "service creates no session reference cycle")
	_check(weak_state.pickup(ALDER, ORIGIN, RESOURCE, weak_state.revision()).errors == PackedStringArray(["not_initialized"]), "orphan service commands reject")


func _watch(session: GameSession) -> void:
	var weak: WeakRef = weakref(session)
	session.foraging.committed.connect(func(token: int) -> void:
		var owner: GameSession = weak.get_ref() as GameSession
		var state: ForagingState = owner.foraging
		var facts: Dictionary = state.snapshot()
		_check(facts.revision == token and state.rod_count() == 1, "observer sees committed token and rod1")
		_check(state.pickup(owner.current_location_id, ORIGIN, RESOURCE, token).errors == PackedStringArray(["command_busy"]), "observer cannot reenter world command")
		for id: String in facts.collected_resource_ids:
			_check(id != DROP and state.placement(id) == null, "observer sees origin suppression with no lingering override")
		if state.placement(DROP) != null:
			_check(owner.inventory.count(ROD) == 0 and owner.inventory.snapshot().active_item_id != ROD and state.is_collected(ORIGIN), "observer sees consumed bag/active and committed drop")
		events.append(facts.duplicate(true))
		facts.inventory.item_counts.clear()
		facts.collected_resource_ids.clear()
	)


func _valid(_placed: WorldItemPlacement, _facts: Dictionary) -> PackedStringArray:
	validator_calls += 1
	return []


func _session(selected_catalog: ContentCatalog = null) -> GameSession:
	var result: GameSession = GameSession.new()
	_check(result.initialize(catalog if selected_catalog == null else selected_catalog, ALDER, "alderwake-start", "prototype-hero").is_empty(), "session init")
	return result


func _before(state: ForagingState) -> Dictionary:
	return {"facts": state.snapshot(), "event_count": events.size()}


func _reject(state: ForagingState, before: Dictionary, result: ForagingCommandResult, error: String, label: String) -> void:
	# Every rejected caller passes its pre-command snapshot; read-only result has no event.
	_check(not result.accepted and error in result.errors and result.revision == state.revision(), "structured rejection " + label)
	_check(state.snapshot() == before.facts, "atomic rejection " + label)
	_check(events.size() == before.event_count, "rejection publishes nothing " + label)


func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
