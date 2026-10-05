class_name TestRunObservation
extends RefCounted
## Detached, read-only facts and current render outputs. No service commands.

static func environment(game: Node3D) -> Dictionary:
	var state: EnvironmentState = game.session.environment
	var definition: LocationDefinition = game.catalog.get_location(game.session.current_location_id)
	var exterior: ExteriorLights = null
	if game.world_host.current_location is AlderwakeExterior:
		exterior = (game.world_host.current_location as AlderwakeExterior).exterior_lights
	var sources: Array[Dictionary] = []
	for identity: Dictionary in LightSourceRegistry.entries():
		var row: Dictionary = identity.duplicate(true)
		row.enabled = state.light_enabled(identity.location_id, identity.prop_id, identity.source_id)
		var consumer: ExteriorLightConsumer = exterior.consumers.get(identity.prop_id) if exterior != null else null
		row.presented = consumer != null
		if consumer != null:
			row.consumer_enabled = consumer.enabled
			row.intensity = consumer.intensity
			row.emission_energy = consumer.glow_material.emission_energy_multiplier
			row.has_emitter = consumer.emitter != null
			if consumer.emitter != null:
				row.light_energy = consumer.emitter.light_energy
				row.emitter_visible = consumer.emitter.visible
		sources.append(row)
	return {"day_index":state.day_index, "day_cycle_progress":state.day_cycle_progress,
		"time":EnvironmentClock.format_time(state.day_cycle_progress),
		"absolute_minutes":EnvironmentClock.absolute_minutes(state.day_index, state.day_cycle_progress),
		"weather_seed":state.weather_seed, "weather":TestRunSnapshot.weather(state),
		"light_source_overrides":LightSourceRegistry.sorted_overrides(state.light_source_overrides),
		"lighting_profile":definition.lighting_profile,
		"consumer_count":exterior.consumers.size() if exterior != null else 0,
		"emitter_count":exterior.emitter_count if exterior != null else 0, "sources":sources}


static func camera(game: Node3D) -> Dictionary:
	var rig: PrototypeCameraRig = game.camera_rig
	return {"projection":rig.camera.projection, "zoom_factor":rig.zoom_factor,
		"size":rig.camera.size, "fov":rig.camera.fov,
		"move_right":vector(rig.movement_direction(Vector2.RIGHT)),
		"move_back":vector(rig.movement_direction(Vector2.DOWN))}


static func vector(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]
