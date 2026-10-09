extends SceneTree
## Focused P002 checks. Mutate detached fixtures, never cached authored Resources.

const MANIFEST_PATH: String = "res://content/prototype_catalog.tres"
const LOCATION_ID: String = "prototype-test-room"
const SPAWN_ID: String = "prototype-start"
const HERO_ID: String = "prototype-hero"

var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if "--invalid-startup" in OS.get_cmdline_user_args():
		var game: Node3D = (load("res://app/game_root.tscn") as PackedScene).instantiate()
		var invalid: ContentManifest = _fixture()
		invalid.definitions[0].stable_id = ""
		game.content_manifest = invalid
		print("P002 expected failure: invalid catalog must abort application with exit 1.")
		root.add_child(game)
		return
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(load(MANIFEST_PATH) as ContentManifest).is_empty(), "Authored catalog must validate")
	_check(catalog.initialized and catalog.definition_count() == 27, "Catalog must publish twenty-seven definitions")
	_check(catalog.get_actor("npc-03").display_name == "Maris", "Maris supplied stable identity lost")
	_check(catalog.get_actor("prototype-companion").prototype_fixture, "Temporary companion must be labeled")
	_check(catalog.get_dialogue("prototype-companion-greeting").prototype_fixture, "Temporary dialogue must be labeled")
	_check(catalog.get_actor(LOCATION_ID) == null, "Typed lookup must reject wrong definition kind")

	_reject(null, "manifest is missing")
	_reject(ContentManifest.new(), "no definitions")
	var fixture: ContentManifest = _fixture()
	fixture.definitions.append(null)
	_reject(fixture, "is null")
	fixture = _fixture()
	fixture.definitions.append(ContentDefinition.new())
	_reject(fixture, "unsupported definition type")
	fixture = _fixture()
	fixture.definitions.append(fixture.definitions[0].duplicate() as ActorDefinition)
	_reject(fixture, "duplicate stable ID")
	fixture = _fixture()
	fixture.definitions[3].stable_id = HERO_ID
	_reject(fixture, "duplicate stable ID")
	fixture = _fixture()
	fixture.definitions[0].stable_id = " "
	fixture.definitions[0].display_name = " "
	(fixture.definitions[0] as ActorDefinition).max_health = 0
	_reject(fixture, "stable_id must be nonempty")
	_reject(fixture, "display_name must be nonempty")
	_reject(fixture, "max_health must be positive")
	fixture = _fixture()
	(fixture.definitions[3] as LocationDefinition).actor_ids.append("absent-actor")
	_reject(fixture, "missing actor reference 'absent-actor'")
	fixture = _fixture()
	(fixture.definitions[4] as ConversationDefinition).speaker_actor_id = LOCATION_ID
	_reject(fixture, "must be an ActorDefinition")
	fixture = _fixture()
	(fixture.definitions[4] as ConversationDefinition).speaker_actor_id = "absent-speaker"
	_reject(fixture, "missing actor reference 'absent-speaker'")
	fixture = _fixture()
	(fixture.definitions[3] as LocationDefinition).scene_path = "res://world/absent.tscn"
	_reject(fixture, "does not reference an existing PackedScene")
	fixture = _fixture()
	(fixture.definitions[3] as LocationDefinition).scene_path = "D:/external.tscn"
	_reject(fixture, "must be a res:// .tscn path")
	fixture = _fixture()
	(fixture.definitions[3] as LocationDefinition).spawn_ids = []
	_reject(fixture, "at least one stable spawn ID")
	fixture = _fixture()
	(fixture.definitions[3] as LocationDefinition).spawn_ids.append(SPAWN_ID)
	_reject(fixture, "duplicate spawn ID")
	fixture = _fixture()
	(fixture.definitions[3] as LocationDefinition).spawn_ids.append(" ")
	_reject(fixture, "whitespace-padded ID")
	fixture = _fixture()
	TestRunConversation.mutate(fixture.definitions[4], func(data: Dictionary) -> void: data.nodes = [])
	_reject(fixture, "at least one node")
	fixture = _fixture()
	TestRunConversation.mutate(fixture.definitions[4], func(data: Dictionary) -> void: data.nodes[0].text = " ")
	_reject(fixture, "blank line")
	_check(not catalog.initialize(fixture).is_empty(), "Bad replacement catalog must fail")
	_check(catalog.definition_count() == 27 and catalog.get_actor(HERO_ID) != null, "Rejected catalog must preserve published definitions")
	_check(catalog.get_dialogue("prototype-companion-greeting").document().nodes[0].text.begins_with("[Prototype fixture"), "Rejected catalog replaced valid dialogue with malformed content")

	var actor_definition: ActorDefinition = catalog.get_actor(HERO_ID)
	var first: ActorState = ActorState.new("test-actor-1", actor_definition)
	var second: ActorState = ActorState.new("test-actor-2", actor_definition)
	first.health = 7
	_check(second.health == 100 and actor_definition.max_health == 100, "Actor health leaked into another instance or definition")
	_check(first.instance_id != second.instance_id and first.definition_id == second.definition_id, "Instance IDs must differ while definition ID stays shared")
	var session_a: GameSession = GameSession.new()
	var session_b: GameSession = GameSession.new()
	_check(not session_a.initialize(ContentCatalog.new(), LOCATION_ID, SPAWN_ID, HERO_ID).is_empty(), "Session must require validated catalog")
	_check(not session_a.initialize(catalog, "absent-location", SPAWN_ID, HERO_ID).is_empty(), "Session must reject unknown location")
	_check(not session_a.initialize(catalog, LOCATION_ID, "absent-spawn", HERO_ID).is_empty(), "Session must reject unknown spawn")
	_check(not session_a.initialize(catalog, LOCATION_ID, SPAWN_ID, LOCATION_ID).is_empty(), "Session must reject wrong actor kind")
	_check(not session_a.initialized and session_a.actors.is_empty() and session_a.current_location_id.is_empty(), "Failed initialization must not publish partial state")
	_check(session_a.initialize(catalog, LOCATION_ID, SPAWN_ID, HERO_ID).is_empty(), "Session A initialization failed")
	_check(session_b.initialize(catalog, LOCATION_ID, SPAWN_ID, HERO_ID).is_empty(), "Session B initialization failed")
	session_a.actors[GameSession.PLAYER_INSTANCE_ID].health = 31
	session_a.advance(3.0)
	session_a.current_spawn_id = "test-only-progress"
	_check(session_b.actors[GameSession.PLAYER_INSTANCE_ID].health == 100, "Sessions share actor health")
	_check(session_b.elapsed_play_seconds == 0.0 and session_b.current_spawn_id == SPAWN_ID, "Sessions share mutable progress")
	_check(not session_a.initialize(catalog, LOCATION_ID, SPAWN_ID, HERO_ID).is_empty(), "Reinitialization must not reset live progress")
	_check(session_a.actors[GameSession.PLAYER_INSTANCE_ID].health == 31 and session_a.elapsed_play_seconds == 3.0, "Rejected reinitialization reset state")
	_check((load(MANIFEST_PATH) as ContentManifest).definitions[0].stable_id == HERO_ID, "Negative tests mutated authored Resources")
	if failures.is_empty():
		print("P002 checks: PASS — authored catalog, malformed/duplicate/reference rejection, atomic initialization, independent actor health/session progress.")
	else:
		for failure: String in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)


func _fixture() -> ContentManifest:
	# duplicate(true) on a manifest retains external .tres references in Godot.
	# Copy each definition explicitly so negative cases cannot alter cached content.
	var fixture: ContentManifest = ContentManifest.new()
	fixture.fishing_area_layout_path = (load(MANIFEST_PATH) as ContentManifest).fishing_area_layout_path
	for definition: ContentDefinition in (load(MANIFEST_PATH) as ContentManifest).definitions:
		fixture.definitions.append(definition.duplicate(true) as ContentDefinition)
	return fixture


func _reject(manifest: ContentManifest, expected: String) -> void:
	var catalog: ContentCatalog = ContentCatalog.new()
	var errors: PackedStringArray = catalog.initialize(manifest)
	_check(expected in "\n".join(errors), "Missing useful error '%s'; got %s" % [expected, errors])
	_check(not catalog.initialized and catalog.definition_count() == 0, "Invalid catalog published partial definitions")
	print("P002 expected rejection [%s]: %s" % [expected, "; ".join(errors)])


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
