extends "res://tests/fishing_reference_checks.gd"
## FS001 fresh ordinary WASD approach proof; no fishing activation, teleport or grants.
var game: Node3D
var views: Array[Dictionary] = []
var traces: Array[Dictionary] = []

func _run() -> void:
	root.size = Vector2i(960,640)
	_read_reference()
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "fresh ordinary arrival")
	if arrival[0]:
		room = game.world_host.current_location
		await _pause_capture("fresh",true)
		await _resume()
		for site: Dictionary in vectors.sites:
			var walk: Dictionary = await TestRunJourney.walk(game,_v3(site.foot),site.id)
			traces.append(walk)
			_check(walk.ok,walk.error)
			print("FS001_WALK ",site.id," ",walk.ok," ",walk.get("actual",walk.error))
			if not walk.ok: break
			var actual: Vector3 = game.player_placeholder.global_position
			var target: Vector3 = _v3(site.target)
			_check(Vector2(actual.x,actual.z).distance_to(Vector2(target.x,target.z)) <= 12, "ordinary actual foot cast range " + site.id)
			_check(_solid_ray(game,actual+Vector3.UP,target).is_empty(), "ordinary rod line unobstructed " + site.id)
			await _pause_capture(site.id)
			await _resume()
		await _pause_capture("final",true)
		_check(game.session.inventory.count("item-fishing-rod") == 0, "site audit has no item activation/grants")
	_check(TestRunEvidence.write_json("sites-index.json",{"task":"FS001","assertions":assertions+1,"failures":failures,"views":views,"traces":traces,"proof":"fresh ordinary viewport WASD plus GUI Resume; no pose, RNG, item, time or quest setup; targets are measured reference points, not active cast previews"}), "ordinary evidence write")
	paused = false
	game.queue_free(); await process_frame
	_finish()

func _pause_capture(label: String, overlay: bool = false) -> void:
	if not paused:
		_key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false)
	for frame: int in range(3): await process_frame
	_check(paused and game.ui.pause_overlay.visible, "actual pause checkpoint")
	var captured: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"debug-input",overlay,"Ordinary fresh viewport WASD dry casting-site audit. Reference water targets only; fishing not implemented.")
	_check(captured.ok,captured.get("error","capture"))
	if captured.ok: views.append(captured)

func _resume() -> void:
	var result: Dictionary = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
	_check(result.ok,result.get("error","GUI Resume"))

func _key(code: int, down: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code; event.physical_keycode = code; event.pressed = down
	root.push_input(event,true)
