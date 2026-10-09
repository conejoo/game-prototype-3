class_name GameSession
extends RefCounted
## Mutable run state; no scene, content-resource, or rendering ownership.

var elapsed_play_seconds: float = 0.0
var initialized: bool = false
var current_location_id: String = ""
var current_spawn_id: String = ""
var actors: Dictionary[String, ActorState] = {}
var party_member_ids: PackedStringArray = []
var quests: Dictionary[String, QuestState] = {}
var completed_effect_ids: PackedStringArray = []
var relationship: RelationshipState = RelationshipState.new()
var progression: ProgressionState = ProgressionState.new()
var environment: EnvironmentState = EnvironmentState.new()
var inventory: InventoryState = InventoryState.new()
var foraging: ForagingState = ForagingState.new()
# Durable per-person and bounded event state; cursor stays transient.
var conversations: NpcConversationState = NpcConversationState.new()
var routines: RoutineFacts = RoutineFacts.new()
signal routine_facts_changed
var _routine_revision: int = 0
var _applying_routine_command: bool = false
var routine_revision: int:
	get: return _routine_revision
var weather_conditions: WeatherConditionService = WeatherConditionService.new()
# Transient developer provenance, never a save field.
var review_only: bool = false

const PLAYER_INSTANCE_ID: String = "party-player"
const COMPANION_INSTANCE_ID: String = "party-companion"


func initialize(catalog: ContentCatalog, location_id: String, spawn_id: String, player_id: String, restored_environment: EnvironmentState = null, npc_content: NpcContentCatalog = null) -> PackedStringArray:
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
	var companion: ActorDefinition = catalog.get_actor("prototype-companion")
	if companion == null:
		errors.append("session companion definition 'prototype-companion' is missing")
	if restored_environment != null:
		errors.append_array(restored_environment.validation_errors())
	if not errors.is_empty():
		return errors
	var candidate_inventory: InventoryState = InventoryState.new()
	errors = candidate_inventory.initialize(catalog)
	if not errors.is_empty():
		return errors
	# Validate registry before publishing either item service.
	errors = ForagingRegistry.validation_errors(catalog)
	if not errors.is_empty():
		return errors
	var npc_catalog: NpcContentCatalog = npc_content
	if npc_catalog == null:
		npc_catalog = NpcContentCatalog.new()
		errors = npc_catalog.initialize_path(catalog)
		if not errors.is_empty(): return errors
	var candidate_conversations: NpcConversationState = NpcConversationState.new()
	errors = candidate_conversations.initialize(npc_catalog)
	if not errors.is_empty(): return errors
	conversations = candidate_conversations
	inventory = candidate_inventory
	foraging.initialize(catalog, self)
	actors[PLAYER_INSTANCE_ID] = ActorState.new(PLAYER_INSTANCE_ID, player)
	actors[COMPANION_INSTANCE_ID] = ActorState.new(COMPANION_INSTANCE_ID, companion)
	party_member_ids = PackedStringArray([PLAYER_INSTANCE_ID, COMPANION_INSTANCE_ID])
	current_location_id = location_id
	current_spawn_id = spawn_id
	for definition: QuestDefinition in catalog.quest_definitions():
		quests[definition.stable_id] = QuestState.new()
	# Decoding supplies validated facts; it never generates a replacement seed.
	environment = EnvironmentState.fresh() if restored_environment == null else restored_environment
	weather_conditions.bind_environment(environment)
	initialized = true
	return errors


func advance(delta: float) -> PackedStringArray:
	if not initialized:
		return PackedStringArray(["session is not initialized"])
	if _applying_routine_command:
		return PackedStringArray(["session advance blocked during routine publication"])
	# Validate before publishing either timer, including the supported clock cap.
	if not is_finite(delta) or delta < 0.0 or not is_finite(elapsed_play_seconds + delta):
		return PackedStringArray(["session delta must be finite and nonnegative"])
	var old_day: int = environment.day_index
	var errors: PackedStringArray = environment.advance(delta)
	if errors.is_empty():
		elapsed_play_seconds += delta
		if environment.day_index != old_day:
			routines = routines.without_suppression()
			_routine_revision += 1
	return errors


func apply_routine_command(command: RoutineFactCommand) -> PackedStringArray:
	if not initialized or command == null or _applying_routine_command:
		return PackedStringArray(["routine command requires ready session and non-reentrant typed command"])
	var errors: PackedStringArray = environment.validation_errors()
	errors.append_array(RoutineFacts.restore(routines.snapshot()).errors)
	errors.append_array(command.validation_errors(self))
	if not errors.is_empty(): return errors
	var candidate: RoutineFacts = command.candidate(routines)
	errors = RoutineFacts.restore(candidate.snapshot()).errors
	if not errors.is_empty(): return errors
	_applying_routine_command = true
	routines = candidate
	_routine_revision += 1
	routine_facts_changed.emit()
	_applying_routine_command = false
	return []


func toggle_light(action: LightSwitchAction, expected_enabled: bool) -> PackedStringArray:
	if not initialized or action == null:
		return PackedStringArray(["light command requires a ready session and typed action"])
	var errors: PackedStringArray = action.validation_errors()
	if action.location_id != current_location_id:
		errors.append("light source is not in the committed location")
	if not errors.is_empty():
		return errors
	if environment.light_enabled(action.location_id, action.prop_id, action.source_id) != expected_enabled:
		return PackedStringArray(["light command is stale; source already changed"])
	return environment.set_light_enabled(action.location_id, action.prop_id, action.source_id, not expected_enabled)
