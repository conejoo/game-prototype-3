extends SceneTree
## Startup overwrite regression and refusal guards; synthetic test repositories.
var failures: PackedStringArray = []
var assertions: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_check(not TestRunSave.configure(null, "user://saves/fixture.json").is_empty(), "null root refused")
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	var original: SaveRepository = game.save_repository
	_check(not TestRunSave.configure(game, "user://saves/too-early.json").is_empty() and game.save_repository == original, "pre-ready configuration refused without mutation")
	# Reproduce the old failure: _ready replaces raw pre-startup assignments.
	game.save_repository = SaveRepository.new("user://saves/old-pre-ready.json")
	root.add_child(game)
	_check(not TestRunSave.configure(game, "user://saves/during-startup.json").is_empty(), "in-flight startup refused")
	await game.world_host.transition_finished
	_check(game.save_repository.path != "user://saves/old-pre-ready.json", "runner slot overrides old pre-ready injection")
	game._set_paused(true)
	var fixture_path: String = "user://saves/startup-fixture/root.json"
	_check(TestRunSave.configure(game, fixture_path).is_empty() and game.save_repository.path == fixture_path, "post-startup configuration succeeds")
	var configured: SaveRepository = game.save_repository
	for frame: int in range(4): await process_frame
	_check(game.save_repository == configured and game.save_repository.path == fixture_path, "configuration survives deferred startup")
	for path: String in ["", "res://fixture.json", "user://outside.json", "user://saves/../outside.json", "user://saves/nested/../../outside.json", "user://saves//bad.json", "user://saves/bad\\name.json", "user://saves/fixture.txt", "user://saves/returning-fair.json"]:
		_check(not TestRunSave.configure(game, path).is_empty() and game.save_repository == configured, "invalid path refused without mutation: " + path)
	game.loading_save = true
	_check(not TestRunSave.configure(game, "user://saves/load.json").is_empty() and game.save_repository == configured, "load refused")
	game.loading_save = false
	game.retrying = true
	_check(not TestRunSave.configure(game, "user://saves/retry.json").is_empty() and game.save_repository == configured, "retry refused")
	game.retrying = false
	game.session.actors[GameSession.PLAYER_INSTANCE_ID].health = 37
	_check(game.save_run().is_empty(), "fixture save succeeds")
	_check(FileAccess.file_exists(fixture_path) and FileAccess.file_exists(fixture_path + ".bak"), "fixture primary and backup use requested path")
	game.session.actors[GameSession.PLAYER_INSTANCE_ID].health = 81
	_check((await game.load_run()).is_empty() and game.player_placeholder.state.health == 37 and game.save_repository == configured, "fixture restore retains requested repository")
	game._set_paused(false)
	_check(game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake").is_empty(), "transition starts")
	_check(not TestRunSave.configure(game, "user://saves/travel.json").is_empty() and game.save_repository == configured, "travel refused")
	await game.world_host.transition_finished
	game.queue_free()
	await process_frame
	_check(not TestRunSave.configure(game, fixture_path).is_empty(), "disposed root refused")
	for failure: String in failures: push_error(failure)
	print("Testing save repository: %s assertions=%d" % ["PASS" if failures.is_empty() else "FAIL", assertions])
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
