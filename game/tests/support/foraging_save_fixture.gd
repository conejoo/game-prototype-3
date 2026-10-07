class_name ForagingSaveFixture
extends RefCounted
## Synthetic complete prior quest/environment plus service-only gathering.

static func make(catalog: ContentCatalog, kind: String = "bag") -> GameSession:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/map_saves/town-complete.json"))
	var run: GameSession = SaveCodec.validate(data, catalog).session
	run.current_location_id = ForagingRegistry.LOCATION
	run.current_spawn_id = "alderwake-start"
	run.elapsed_play_seconds = 708.729573002131
	run.environment.day_index = 146
	run.environment.day_cycle_progress = 0.6180339887498948
	run.environment.weather_seed = 4294967295
	for light: Dictionary in LightSourceRegistry.entries():
		if light.switchable: run.environment.set_light_enabled(light.location_id, light.prop_id, light.source_id, not light.default_enabled)
	for entry: Dictionary in ForagingRegistry.entries():
		if entry.item_id != ForagingRegistry.ROD_ITEM:
			run.foraging.gather(ForagingRegistry.LOCATION, entry.instance_id, entry.resource_id, run.foraging.revision())
	run.foraging.bind_placement_validator(func(_placed: WorldItemPlacement, _facts: Dictionary) -> PackedStringArray: return [])
	if kind == "authored":
		run.foraging.move(ForagingRegistry.LOCATION, ForagingRegistry.ROD_ORIGIN, ForagingRegistry.ROD_ITEM, Vector3(3,0,0), run.foraging.revision())
		run.inventory.select("item-moonflower")
	else:
		run.foraging.pickup(ForagingRegistry.LOCATION, ForagingRegistry.ROD_ORIGIN, ForagingRegistry.ROD_RESOURCE, run.foraging.revision())
		run.inventory.select(ForagingRegistry.ROD_ITEM)
		if kind != "bag":
			run.current_location_id = "prototype-tollworks" if kind == "tollworks" else ForagingRegistry.LOCATION
			run.current_spawn_id = "tollworks-from-alderwake" if kind == "tollworks" else "alderwake-start"
			run.foraging.drop(run.current_location_id, ForagingRegistry.ROD_ITEM, Vector3(4,0,1) if kind == "tollworks" else Vector3(3,0,0), run.foraging.revision())
	return run
