extends SceneTree
## AD015 fresh ordinary viewport WASD/E/Esc/P/+/- room journey. Nav supplies route guidance.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var views: Array[Dictionary] = []
var traces: Array[Dictionary] = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0],"fresh ordinary production startup")
	if startup[0]: await _journey()
	_check(TestRunEvidence.write_json("inn-render-index.json",{"task":"AD015","assertions":assertions,"failures":failures,"views":views,"traces":traces,"provenance":"fresh ordinary public viewport controls; runtime navigation supplies explicit route guidance, no teleport/state/time/weather/affinity setup"}),"write evidence")
	paused = false
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("AD015 rendered inn: %d assertions, %d captures, %d failures" % [assertions,views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _journey() -> void:
	var memories: Dictionary = game.session.conversations.snapshot()
	_check(game.session.conversations.memory("npc-14").affinity == 0,"fresh zero-affinity host")
	if not await _walk(RoutineExteriorRegistry.entrance(NpcRegistry.LOCATION,"lantern-rest-entrance-01").player_approach,"town-start-to-public-inn-door"): return
	await _pause()
	await _capture("town-inn-door",true)
	await _resume()
	await _key(KEY_E)
	if not await _arrival("prototype-lantern-rest"): return
	_check(game.session.conversations.snapshot() == memories,"public entry at zero affinity grants no private or social facts")
	_check(game.party.members().size() == 2 and game.player_placeholder.is_on_floor() and game.companion.is_on_floor(),"whole party arrives grounded")
	_check(game.ui.objective_label.text.contains("south inn exit"),"inn HUD points to actual south exit")
	await _pause()
	await _capture("inn-arrival",true)
	await _resume()
	for stop: Dictionary in [{"id":"host","foot":Vector3(-6,0,-10.8)},{"id":"lounge","foot":Vector3(-7,0,-5)},{"id":"breakfast","foot":Vector3(6,0,-4)},{"id":"guest-desk","foot":Vector3(4,0,-12)}]:
		if not await _walk(stop.foot,"ordinary-inn-"+stop.id): return
		if stop.id == "host":
			game._refresh_interaction()
			_check(game.selected_interaction != null and game.selected_interaction.instance_id == "della-inn-host-01","actual host selected through normal approach")
			await _key(KEY_E)
			_check(game.dialogue.active(),"ordinary E opens current host dialogue")
			var dialogue_capture: Dictionary = await TestRunInteractionCapture.dialogue(game,"ordinary-host-dialogue",TestRunEvidence.directory(),"debug-input","Fresh ordinary WASD/E; actual host; no placement/fact/weather/time injection")
			_check(dialogue_capture.ok,dialogue_capture.get("error","host dialogue capture"))
			if dialogue_capture.ok: views.append(dialogue_capture)
			await _key(KEY_ESCAPE)
			_check(not game.dialogue.active() and game.player_placeholder.controls_enabled,"ordinary host dialogue closes")
		for projection: int in range(2):
			var orthographic: bool = projection == 0
			if (game.camera_rig.camera.projection == Camera3D.PROJECTION_ORTHOGONAL) != orthographic: await _key(KEY_P)
			for zoom: float in [.8,1.0,1.15]:
				for step: int in range(8):
					if absf(game.camera_rig.zoom_factor-zoom) <= .01: break
					await _key(KEY_EQUAL if game.camera_rig.zoom_factor > zoom else KEY_MINUS)
				_check(absf(game.camera_rig.zoom_factor-zoom) < .01,"public zoom accepted")
				await _pause()
				await _capture("inn-%s-%s-%02d" % [stop.id,"ortho" if orthographic else "perspective",roundi(zoom*100)])
				await _resume()
	memories = game.session.conversations.snapshot()
	if not await _walk(Vector3(0,0,.65),"ordinary-inn-exit"): return
	await _key(KEY_E)
	if not await _arrival("prototype-alderwake"): return
	_check(game.session.current_spawn_id == "alderwake-from-lantern-rest","public return uses measured qualified exterior spawn")
	_check(game.session.conversations.snapshot() == memories,"public return preserves zero-affinity/facts")
	await _pause()
	await _capture("town-inn-return",true)
	await _resume()
	if not await _walk(Vector3(0,0,0),"ordinary-inn-return-to-town-start"): return
	await _pause()
	await _capture("town-return-revisited",true)
	_check(NavigationServer3D.map_get_regions(game.get_world_3d().navigation_map).size() == 1,"one region after ordinary return")

func _walk(goal: Vector3, label: String) -> bool:
	var result: Dictionary = await TestRunJourney.walk(game,goal,label)
	traces.append(result)
	_check(result.ok,result.error)
	return result.ok

func _arrival(id: String) -> bool:
	for frame: int in range(600):
		await physics_frame
		if game.session.current_location_id == id and not game.world_host.transitioning:
			for settle: int in range(4): await physics_frame
			_check(true,"public E arrived " + id)
			return true
	_check(false,"public E travel did not arrive " + id + " current="+game.session.current_location_id)
	return false

func _pause() -> void:
	await _key(KEY_ESCAPE)
	_check(paused and game.ui.pause_overlay.visible,"verified public Esc pause checkpoint")

func _resume() -> void:
	await _key(KEY_ESCAPE)
	_check(not paused and not game.ui.pause_overlay.visible and game.player_placeholder.controls_enabled,"public Esc resume")

func _capture(label: String, overlay: bool = false) -> void:
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"debug-input",overlay,"Ordinary WASD/E/Esc/P/+/-; explicit runtime-nav route guidance; no placement or clock/weather/social setup")
	_check(capture.ok,capture.get("error","capture " + label))
	if capture.ok: views.append(capture)

func _key(code: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event,true)
	await process_frame
	event = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = false
	root.push_input(event,true)
	await process_frame

func _check(condition: bool, label: String) -> void:
	assertions += 1
	if not condition: failures.append(label)
