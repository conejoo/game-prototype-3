extends SceneTree
## R010 shared isolated fixture. Explicit synthetic clock/party setup is recorded.
var game: Node3D
var execution: RoutineExecutionDirector
var failures: PackedStringArray = []
var assertions: int = 0
var observations: Array[Dictionary] = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void: pass

func setup(minute: float, location: String = "prototype-alderwake", manual: bool = true) -> bool:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var ready: Array = await game.world_host.transition_finished
	check(ready[0],"fresh root startup")
	if not ready[0]: return false
	game.set_process(false)
	game.routine_execution.dispose() # Synthetic seek replaces the default production owner.
	game.session.environment.day_cycle_progress = fposmod((minute-600.0)/1440.0,1.0)
	execution = RoutineExecutionDirector.new()
	check(execution.initialize(game.catalog,game.npc_catalog,game.session).is_empty(),"validated executor initialize")
	game.routine_execution = execution; game.world_host.routine_execution = execution
	game.dialogue.routine_owner = execution
	var definition: LocationDefinition = game.catalog.get_location(location)
	check(game.world_host.request_transition(location,definition.spawn_ids[0]).is_empty(),"synthetic fresh placement request")
	ready = await game.world_host.transition_finished
	check(ready[0],"safe reconstructed scene publication "+str(ready[1]))
	if not ready[0]: return false
	if manual: manual_mode()
	else: game.set_process(true)
	return true

func manual_mode() -> void:
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)
	game.world_host.current_location.npc_contacts.set_physics_process(false)
	game.player_placeholder.global_position = Vector3(-15,0,0) if game.session.current_location_id == "prototype-alderwake" else Vector3(2,0,-8.5)
	game.companion.global_position = Vector3(-14,0,0) if game.session.current_location_id == "prototype-alderwake" else Vector3(5,0,-8.5)
	game._sync_npc_visuals()

func step(dt: float = .1, advance_clock: bool = false) -> void:
	execution.tick(dt)
	game.world_host.current_location.npc_contacts._physics_process(dt)
	if advance_clock: game.session.advance(dt)
	await physics_frame

func travel(map_id: String) -> bool:
	var definition: LocationDefinition = game.catalog.get_location(map_id)
	check(game.world_host.request_transition(map_id,definition.spawn_ids[0]).is_empty(),"player fixture transition request "+map_id)
	var ready: Array = await game.world_host.transition_finished
	check(ready[0],"player transition success "+str(ready[1]))
	if ready[0]: manual_mode()
	return ready[0]

func check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)

func finish(filename: String) -> void:
	check(TestRunEvidence.write_json(filename,{"task":"R010","assertions":assertions,"failures":failures,"observations":observations,"provenance":"synthetic initial clock/party placement; real target scene/physics/portal lifecycle and bounded active-delta execution; not ordinary full-day/native acceptance"}),"evidence")
	paused = false
	if execution != null: execution.dispose()
	if game != null: game.queue_free()
	await process_frame
	for error: String in failures: push_error(error)
	print("R010 %s %d assertions %d failures" % [filename,assertions,failures.size()])
	quit(0 if failures.is_empty() else 1)
