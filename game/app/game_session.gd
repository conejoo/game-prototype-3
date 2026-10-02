class_name GameSession
extends RefCounted
## Mutable run state; no scene, content-resource, or rendering ownership.

var elapsed_play_seconds: float = 0.0
var initialized: bool = false
var current_location_id: String = ""
var current_spawn_id: String = ""
var actors: Dictionary[String, ActorState] = {}
var party_member_ids: PackedStringArray = []

const PLAYER_INSTANCE_ID: String = "party-player"


func initialize(catalog: ContentCatalog, location_id: String, spawn_id: String, player_id: String) -> PackedStringArray:
	if initialized:
		return PackedStringArray(["session is already initialized"])
	if catalog == null or not catalog.initialized:
		return PackedStringArray(["session requires an initialized content catalog"])
	var errors: PackedStringArray = []
	var location: LocationDefinition = catalog.get_location(location_id)
	var player: ActorDefinition = catalog.get_actor(player_id)
	if location == null:
		errors.append("session location '%s' is missing or is not a location" % location_id)
	elif not spawn_id in location.spawn_ids:
		errors.append("session spawn '%s' is absent from location '%s'" % [spawn_id, location_id])
	if player == null:
		errors.append("session player '%s' is missing or is not an actor" % player_id)
	if not errors.is_empty():
		return errors
	actors[PLAYER_INSTANCE_ID] = ActorState.new(PLAYER_INSTANCE_ID, player)
	party_member_ids = PackedStringArray([PLAYER_INSTANCE_ID])
	current_location_id = location_id
	current_spawn_id = spawn_id
	initialized = true
	return errors


func advance(delta: float) -> void:
	if initialized:
		elapsed_play_seconds += delta
