extends SceneTree
## M017 real historical bytes + labeled synthetic transaction/lifecycle checks.
## All writes use an isolated user:// slot. No normal-play journey claim.
const FIXTURES: PackedStringArray = ["town-fresh", "town-lead", "town-complete", "tollworks-vessel", "tollworks-start-downed"]
var failures: PackedStringArray = []
var report: Dictionary = {"fixtures":[], "round_trips":[], "rejections":[], "retries":[]}
var game: Node3D
var identities: Array[int] = []
var phase: String = "checks"
var report_directory: String

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--phase="):
			phase = argument.trim_prefix("--phase=")
		if argument.begins_with("--report-dir="):
			report_directory = TestRunEvidence.directory()
	game = load("res://app/game_root.tscn").instantiate()
	var detached: ContentManifest = ContentManifest.new()
	detached.definitions.assign(game.content_manifest.definitions)
	for fixture: Array in [["prototype-unsafe-location","unsafe_location",["unsafe-no-floor","unsafe-blocked"]], ["candidate-nav-failure","map_navigation_failure",["alderwake-start","alderwake-from-tollworks"]], ["m017-ally-blocked","map_save_ally_blocked",["alderwake-start","alderwake-from-tollworks"]]]:
		var definition: LocationDefinition = LocationDefinition.new()
		definition.stable_id = fixture[0]
		definition.display_name = "M017 isolated rejection fixture"
		definition.prototype_fixture = true
		definition.scene_path = "res://tests/fixtures/%s.tscn" % fixture[1]
		definition.spawn_ids = PackedStringArray(fixture[2])
		detached.definitions.append(definition)
	game.content_manifest = detached
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0], "Startup rejected")
	_check(TestRunSave.configure(game, "user://saves/m017-transaction.json").is_empty(), "Fixture repository after startup")
	identities = [game.player_placeholder.get_instance_id(),game.companion.get_instance_id()]
	game._set_paused(true)
	for name: String in FIXTURES:
		var source: String = FileAccess.get_file_as_string("res://tests/fixtures/map_saves/%s.json" % name)
		var data: Dictionary = JSON.parse_string(source)
		var decoded: SaveCodec.DecodeResult = SaveCodec.decode(source,game.catalog)
		_check(decoded.errors.is_empty() and decoded.migrated, "Historical v4 migration failed: " + name)
		if phase != "read":
			_write(_slot(name),source)
		var before_bytes: String = FileAccess.get_file_as_string(_slot(name))
		_check(TestRunSave.configure(game, _slot(name)).is_empty(), "Historical fixture repository")
		_check((await game.load_run()).is_empty(), "Historical load rejected: " + name)
		_assert_snapshot(_v5_expected(data),name)
		await _lifecycle(name)
		_assert_arrival(name)
		_check(FileAccess.get_file_as_string(_slot(name)) == before_bytes, "Load changed saved bytes: " + name)
		_check(game.progression.hero_damage() == (40 if not data.progression.upgrade_ids.is_empty() else 25), "Upgrade binding lost: " + name)
		if data.location_id == "prototype-alderwake":
			var counter: Node = game.world_host.current_location.get_node("MarisCounter")
			_check(counter.presentation == ("specialist" if data.completed_effect_ids.size() == 6 else "basic"), "Counter presentation lost: " + name)
		if "tollworks-guardian-cleared" in data.completed_effect_ids and data.location_id == "prototype-tollworks":
			_check(game.guardian.state.health == 0 and game.guardian.collision_layer == 0, "Defeat not restored: " + name)
		report.fixtures.append({"name":name,"location":data.location_id,"spawn":data.spawn_id,"health":data.actors,"effects":data.completed_effect_ids,"position":_positions(),"source_sha256":source.sha256_text()})
		if phase == "write":
			_check(game.save_run().is_empty(), "Process writer failed: " + name)
			# Same parsed envelope, but disk writer formatting need not be identical.
			_check(JSON.parse_string(FileAccess.get_file_as_string(_slot(name))) == JSON.parse_string(JSON.stringify(_v5_expected(data))), "Writer changed durable fields: " + name)
	if phase == "checks":
		await _transactions()
		await _round_trips()
		await _retries()
	elif phase == "read":
		# Read published envelope fields instead of requiring historical formatting.
		_check(OS.get_process_id() > 0, "Process identity missing")
	report["phase"] = phase
	report["pid"] = OS.get_process_id()
	report["failures"] = failures
	report["save_path"] = ProjectSettings.globalize_path(game.save_repository.path)
	_write(TestRunEvidence.path("%s-report.json" % phase),JSON.stringify(report,"\t")+"\n")
	game._set_paused(false)
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	print("M017 ",phase,": ","PASS" if failures.is_empty() else "FAILED","; historical fixtures=",report.fixtures.size(),"; round trips=",report.round_trips.size(),"; rejections=",report.rejections.size(),"; retries=",report.retries.size())
	quit(0 if failures.is_empty() else 1)

func _slot(name: String) -> String:
	return "user://saves/m017-process-%s.json" % name

func _v5_expected(data: Dictionary) -> Dictionary:
	# Independent expected additive migration; historical fixture bytes stay v4.
	var result: Dictionary = data.duplicate(true)
	result.schema_version = 6
	result["inventory"] = {"item_counts":{}, "active_item_id":null}
	result["collected_resource_ids"] = []
	result["world_item_placements"] = []
	result["environment"] = {"day_index":0,"day_cycle_progress":0.0,"weather_seed":1821285621}
	result["light_source_overrides"] = []
	return result

func _assert_snapshot(expected: Dictionary,label: String) -> void:
	_check(JSON.parse_string(JSON.stringify(SaveCodec.snapshot(game.session))) == JSON.parse_string(JSON.stringify(expected)),"Durable envelope changed: " + label)
	_check(game.world_host.session == game.session and game.quests.session == game.session and game.relationships.session == game.session and game.progression.session == game.session,"Owner binding changed: " + label)
	for actor: ActorPlaceholder in game.party.members():
		_check(actor.state == game.session.actors[actor.state.instance_id],"Actor binding changed: " + label)
		_check(actor.collision_layer == (0 if actor.state.health == 0 else 2),"Paused health collision stale: " + label)
		_check(is_equal_approx(actor.visual_root.scale.y,0.18 if actor.state.health == 0 else 1.0),"Paused health visual stale: " + label)

func _positions() -> Array:
	var result: Array = []
	for actor: ActorPlaceholder in game.party.members():
		result.append([actor.global_position.x,actor.global_position.y,actor.global_position.z])
	return result

func _assert_arrival(label: String) -> void:
	var expected: Vector3 = Vector3.ZERO
	match game.session.current_spawn_id:
		"alderwake-from-tollworks": expected = Vector3(107.25,0,1.25)
		"tollworks-from-alderwake": expected = Vector3(0,0,-2.5)
	var index: int = 0
	for actor: ActorPlaceholder in game.party.members():
		var point: Vector3 = expected + Vector3.RIGHT * index
		_check(actor.global_position.distance_to(point) < 0.01,"Misplaced party: " + label + str(actor.global_position))
		_check(actor.velocity.is_zero_approx(),"Arrival retained velocity: " + label)
		index += 1
	_check(game.world_host._placement_errors(game.world_host.current_location.find_spawn(game.session.current_spawn_id)).is_empty(),"Unsafe party arrival: " + label)

func _lifecycle(label: String) -> void:
	await physics_frame
	NavigationServer3D.map_force_update(game.world_host.get_world_3d().navigation_map)
	var region: RID = game.world_host.current_location.navigation_region.get_rid()
	_check(NavigationServer3D.map_get_regions(game.world_host.get_world_3d().navigation_map) == [region],"Stale region: " + label)
	_check(game.world_host.get_child_count() == 1 and game.party.get_child_count() == 2 and game.party.members().size() == 2,"Duplicated world/party: " + label)
	_check([game.player_placeholder.get_instance_id(),game.companion.get_instance_id()] == identities,"Wrapper replaced: " + label)
	_check(not game.party.suspended and not game.world_host.transitioning,"Travel lock retained: " + label)

func _load_complete() -> Dictionary:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/map_saves/town-complete.json"))
	_check(TestRunSave.configure(game, "user://saves/m017-transaction.json").is_empty(), "Transaction fixture repository")
	_write(game.save_repository.path,JSON.stringify(data))
	_check((await game.load_run()).is_empty(),"Complete fixture rejected")
	return _v5_expected(data)

func _transactions() -> void:
	var data: Dictionary = await _load_complete()
	var original: PrototypeLocation = game.world_host.current_location
	var live: GameSession = game.session
	var points: Array = _positions()
	var region: RID = original.navigation_region.get_rid()
	for target: Array in [["prototype-unsafe-location","unsafe-no-floor"],["prototype-unsafe-location","unsafe-blocked"],["candidate-nav-failure","alderwake-start"],["m017-ally-blocked","alderwake-start"]]:
		var broken: Dictionary = data.duplicate(true)
		broken.location_id = target[0]
		broken.spawn_id = target[1]
		_write(game.save_repository.path,JSON.stringify(broken))
		_probe_lock.call_deferred()
		var errors: PackedStringArray = await game.load_run()
		_check(not errors.is_empty(),"Unsafe load accepted: " + str(target))
		if target[0] == "m017-ally-blocked":
			_check("party-companion" in ";".join(errors) and not "party-player" in ";".join(errors),"Ally-only failure did not isolate offset capsule")
		_check(game.session == live and game.world_host.current_location == original and _positions() == points,"Rollback changed owners/positions: " + str(target))
		_assert_snapshot(data,str(target))
		await _lifecycle(str(target))
		_check(NavigationServer3D.map_get_regions(game.world_host.get_world_3d().navigation_map) == [region],"Rollback navigation identity changed")
		_check(paused and not game.loading_save and not game.player_placeholder.controls_enabled and not game.companion_ai.enabled,"Rollback input lock incorrect")
		report.rejections.append({"target":target,"errors":errors})
	var future: Dictionary = data.duplicate(true)
	future.schema_version = 99
	_write(game.save_repository.path,JSON.stringify(future))
	_write(game.save_repository.path+".bak",JSON.stringify(data))
	_check(not (await game.load_run()).is_empty() and game.session == live,"Future version accepted/fell back")
	_check(not game.save_run().is_empty(),"Future save overwritten")
	_write(game.save_repository.path,"broken")
	_check((await game.load_run()).is_empty() and "Recovered backup" in game.ui.save_status.text,"Backup restore absent")
	_check(FileAccess.get_file_as_string(game.save_repository.path) == "broken","Backup read rewrote primary")
	_assert_snapshot(data,"backup")
	report.rejections.append({"target":"schema99","errors":"incompatible primary retained; no backup fallback/overwrite"})

func _probe_lock() -> void:
	_check(game.loading_save and game.world_host.transitioning and game.party.suspended,"Load did not lock synchronously")
	_check(not game.save_run().is_empty() and not (await game.load_run()).is_empty(),"Repeated save/load raced transaction")
	game._resume()
	_check(paused,"Resume bypassed transaction")

func _round_trips() -> void:
	var complete: Dictionary = await _load_complete()
	for trip: int in range(12): # Two warmup + ten replacement round trips.
		for destination: String in ["prototype-tollworks","prototype-alderwake"]:
			var previous: WeakRef = weakref(game.world_host.current_location)
			var previous_region: RID = game.world_host.current_location.navigation_region.get_rid()
			var spawn: String = "tollworks-from-alderwake" if destination == "prototype-tollworks" else "alderwake-from-tollworks"
			_check(game.world_host.request_transition(destination,spawn).is_empty(),"Round trip rejected")
			_check(game.party.suspended and not game.world_host.request_transition(destination,spawn).is_empty(),"Round trip lock absent")
			var result: Array = await game.world_host.transition_finished
			_check(result[0],"Round trip placement failed")
			complete.location_id = destination
			complete.spawn_id = spawn
			_assert_snapshot(complete,"roundtrip")
			_assert_arrival("roundtrip")
			await _lifecycle("roundtrip")
			_check(previous.get_ref() == null and not previous_region in NavigationServer3D.map_get_regions(game.world_host.get_world_3d().navigation_map),"Old scene/nav retained")
			if destination == "prototype-tollworks":
				_check(game.guardian.state.health == 0 and game.guardian.collision_layer == 0,"Guardian respawned")
			for step: QuestStep in game.catalog.get_quest("prototype-maris-recovery").steps:
				_check(game.quests.apply("prototype-maris-recovery",step.action_id,step.location_id,step.source_id).ok,"Completed objective retry rejected")
			_check(game.relationships.apply("prototype-shared-plan").ok and game.progression.select_upgrade("prototype-deliberate-strike").ok,"Once-only retry rejected")
			_assert_snapshot(complete,"once-only replay")
			report.round_trips.append({"trip":trip,"destination":destination,"regions":1,"party_wrappers":identities})

func _retries() -> void:
	for target: Array in [["prototype-alderwake","alderwake-start"],["prototype-alderwake","alderwake-from-tollworks"],["prototype-tollworks","tollworks-start"],["prototype-tollworks","tollworks-from-alderwake"]]:
		var data: Dictionary = await _load_complete()
		data.location_id = target[0]
		data.spawn_id = target[1]
		_write(game.save_repository.path,JSON.stringify(data))
		_check((await game.load_run()).is_empty(),"Retry prerequisite rejected")
		game.player_placeholder.state.health = 0 # Synthetic death; actual R input separately.
		game.companion.state.health = 0
		await game.retry_encounter()
		game._set_paused(true)
		data.actors[0].health = 100
		data.actors[1].health = 100
		# Retry intentionally resumes time, but no durable gameplay fact changes.
		data.elapsed_play_seconds = game.session.elapsed_play_seconds
		data.environment = SaveCodec.snapshot(game.session).environment
		_assert_snapshot(data,"retry")
		_assert_arrival("retry")
		await _lifecycle("retry")
		_check(not game.retrying,"Retry lock retained")
		report.retries.append({"target":target,"health":[100,100],"position":_positions()})
	await _load_complete()
	var original: PrototypeLocation = game.world_host.current_location
	var definition: LocationDefinition = game.catalog.get_location("prototype-alderwake")
	var original_path: String = definition.scene_path
	definition.scene_path = "res://tests/fixtures/map_save_retry_failure.tscn"
	game.player_placeholder.state.health = 0
	game.companion.state.health = 13
	var points: Array = _positions()
	await game.retry_encounter() # Expected logged rejection; no healing on failure.
	definition.scene_path = original_path
	game._set_paused(true)
	_check(game.world_host.current_location == original and game.player_placeholder.state.health == 0 and game.companion.state.health == 13 and _positions() == points,"Rejected retry healed/replaced party")
	_check(not game.retrying and not game.party.suspended,"Rejected retry retained lock")
	await _lifecycle("rejected retry")
	report.retries.append({"target":"synthetic nav failure","health":[0,13],"retained_original":true})

func _write(path: String,raw: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var file: FileAccess = FileAccess.open(path,FileAccess.WRITE)
	_check(file != null,"Cannot write isolated evidence: " + path)
	if file != null:
		file.store_string(raw)
		file.close()

func _check(condition: bool,message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
