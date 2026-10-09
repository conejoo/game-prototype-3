extends SceneTree
## Shared FS005 synthetic pose/RNG/capacity fixtures; actual root and viewport input.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var rows: Array[Dictionary] = []
var suite: String = "fixture"
const FISH: Array[String] = ["item-bluegill","item-river-trout","item-golden-carp"]

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	suite = get_script().resource_path.get_file().trim_prefix("fishing_").trim_suffix("_checks.gd")
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	var manifest: ContentManifest = game.content_manifest.duplicate(true)
	for index: int in range(20):
		var item: ItemDefinition = ItemDefinition.new()
		item.stable_id = "fs005-capacity-%02d" % index
		item.source_item_id = item.stable_id
		item.display_name = "Synthetic capacity"
		item.description = "FS005 isolated fixture only."
		item.prototype_fixture = true
		manifest.definitions.append(item)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-unsafe-location"
	unsafe.display_name = "Synthetic unsafe transition"
	unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"
	unsafe.spawn_ids = PackedStringArray(["unsafe-no-floor","unsafe-blocked"])
	manifest.definitions.append(unsafe)
	game.content_manifest = manifest
	root.add_child(game)
	var arrived: Array = await game.world_host.transition_finished
	_check(arrived[0],"actual root startup")
	game.set_process(false) # Exact synthetic clock/state; each time policy check steps root.
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)
	var errors: PackedStringArray = TestRunSave.configure(game,"user://saves/fs005-"+suite+".json")
	_check(errors.is_empty(),"isolated save repository: "+str(errors))
	var pickup: ForagingCommandResult = game.session.foraging.pickup(ForagingRegistry.LOCATION,ForagingRegistry.ROD_ORIGIN,ForagingRegistry.ROD_RESOURCE,game.session.foraging.revision())
	_check(pickup.accepted,"synthetic legal existing rod pickup")
	_check(game.session.inventory.select(ForagingRegistry.ROD_ITEM).is_empty(),"owned selected rod")
	await physics_frame
	await _exercise()
	_check(TestRunEvidence.write_json("fishing-"+suite+".json",{"task":"FS005","proof":"synthetic positions, deterministic RNG, capacity/lifecycle fixtures; actual production root and viewport input; no ordinary catch/native claim","assertions":assertions+1,"failures":failures,"rows":rows}),"evidence write")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("FS005 fishing ",suite," ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)

func _exercise() -> void: pass

func _cast(id: String = "item-bluegill") -> void:
	if game.fishing.mode() != "idle": game._cancel_fishing("fixture reset")
	_key(KEY_E,false)
	game.set_fishing_reel("pointer",false)
	game.player_placeholder.combat.cancel()
	game.player_placeholder.state.health = game.player_placeholder.state.max_health
	game.player_placeholder.initialize(game.player_placeholder.state)
	game.player_placeholder.combat.hit_flash = 0
	game.window_focused = true
	if paused: game._set_paused(false)
	game.session.inventory.select(ForagingRegistry.ROD_ITEM)
	var foot: Vector3 = Vector3(10,0,13) if id == "item-golden-carp" else Vector3(-7,0,18)
	var target: Vector3 = Vector3(10.25,.015,17.25) if id == "item-golden-carp" else Vector3(-4.75,.015,20.25)
	_pose(foot)
	var pointer: Vector2 = game.camera_rig.camera.unproject_position(target)
	_pointer(pointer)
	game._fishing_rng.seed = _seed(id,target)
	_key(KEY_F)
	_check(game.fishing.mode() == "targeting","F enters targeting " + id)
	_click(pointer)
	_check(game.fishing.active() and game.fishing.snapshot().phase == "waiting" and game.fishing.snapshot().item_id == id,"actual world click begins expected synthetic encounter " + id + " " + str(game.fishing.snapshot()))

func _phase(phase: String, id: String = "item-bluegill") -> void:
	_cast(id)
	if phase == "waiting": return
	game._tick_fishing(game.fishing.snapshot().wait_seconds)
	_check(game.fishing.snapshot().phase == "bite","wait reaches bite")
	if phase == "bite": return
	_key(KEY_E,true)
	_check(game.fishing.snapshot().phase == "fighting","fresh E hooks")

func _land() -> Dictionary:
	var item: String = game.fishing.snapshot().item_id
	var count: int = game.session.inventory.count(item)
	if game.fishing.snapshot().phase == "waiting": game._tick_fishing(game.fishing.snapshot().wait_seconds)
	if game.fishing.snapshot().phase == "bite": _key(KEY_E,true)
	var steps: int = 0
	while game.fishing.active() and steps < 8400:
		var view: Dictionary = game.fishing.snapshot()
		if view.tension <= .48 and not game._e_down: _key(KEY_E,true)
		elif view.tension >= .52 and game._e_down: _key(KEY_E,false)
		game._tick_fishing(.005)
		steps += 1
	var result: Dictionary = game.fishing.snapshot()
	_check(result.outcome == "landed" and result.rewarded and game.session.inventory.count(item) == count+1,"legal synthetic feedback lands +1 " + item + " " + str(result))
	_key(KEY_E,false)
	rows.append({"kind":"legal synthetic feedback trajectory","item":item,"steps":steps,"result":result})
	return result

func _seed(id: String, target: Vector3) -> int:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	for candidate: int in range(10000):
		rng.seed = candidate
		var roll: float = float(rng.randi())/4294967296.0
		var resolved: FishingActivityResolver.Result = FishingActivityResolver.resolve(game.catalog,Vector2(target.x,target.z),roll)
		if resolved.item_id == id: return candidate
	_check(false,"deterministic encounter seed exists " + id)
	return 0

func _pose(foot: Vector3) -> void:
	game.player_placeholder.global_position = foot
	game.camera_rig._process(0)
	var focus: Control = root.gui_get_focus_owner()
	if focus != null: focus.release_focus()

func _key(code: int, down: Variant = null, echo: bool = false) -> void:
	var values: Array = [true,false] if down == null else [down]
	for pressed: bool in values:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		event.echo = echo
		root.push_input(event,true)

func _pointer(point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	root.push_input(event,true)

func _click(point: Vector2, button: int = MOUSE_BUTTON_LEFT) -> void:
	for down: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = button
		event.pressed = down
		root.push_input(event,true)

func _facts() -> String: return TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)
