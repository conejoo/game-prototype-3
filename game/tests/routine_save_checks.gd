extends SceneTree
## R004 synthetic durable commands/strict saves, real IO and production root restore.
var failures: PackedStringArray = []
var assertions: int = 0
var rejected: PackedStringArray = []
var actors: ContentCatalog = ContentCatalog.new()
var npcs: NpcContentCatalog = NpcContentCatalog.new()

func _initialize() -> void: _run.call_deferred()
func _setup() -> bool:
	_check(actors.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "core catalog")
	_check(npcs.initialize_path(actors).is_empty(), "NPC catalog")
	return actors.initialized and npcs.initialized

func _run() -> void:
	if not _setup(): _finish("routine-save.json"); return
	_commands()
	_rollover()
	_weather()
	var run: GameSession = _complete_run()
	_strict(run)
	_current_fixtures()
	_disk(run)
	await _root(run)
	_finish("routine-save.json")

func _complete_run() -> GameSession:
	var pair: Dictionary = SocialSaveFixture.complete()
	var run: GameSession = pair.session
	for id: String in RoutineFacts.EVENT_IDS:
		_check(run.apply_routine_command(RoutineFactCommand.set_event(run, id, true)).is_empty(), "authored event " + id)
	for id: String in ["vale-midday-briefing", "helena-afternoon-archive", "edric-evening-fishing"]:
		_check(run.apply_routine_command(RoutineFactCommand.suppress_for_day(run, id)).is_empty(), "durable suppression " + id)
	return run

func _fresh() -> GameSession:
	var run: GameSession = GameSession.new()
	_check(run.initialize(actors, "prototype-alderwake", "alderwake-start", "prototype-hero", null, npcs).is_empty(), "fresh session")
	return run

func _commands() -> void:
	var run: GameSession = _fresh()
	var before: Dictionary = SaveCodec.snapshot(run)
	for command: RoutineFactCommand in [null, RoutineFactCommand.new(), RoutineFactCommand.set_event(null, "heavy-rain", true), RoutineFactCommand.set_event(run,"unknown",true), RoutineFactCommand.suppress_for_day(run,"excluded-npc-routine")]:
		_check(not run.apply_routine_command(command).is_empty() and SaveCodec.snapshot(run) == before and run.routine_revision == 0, "invalid command inert")
	var stale: RoutineFactCommand = RoutineFactCommand.suppress_for_day(run, "vale-breakfast")
	var accepted: RoutineFactCommand = RoutineFactCommand.set_event(run,"harbor-festival",true)
	var old_facts: RoutineFacts = run.routines
	_check(run.apply_routine_command(accepted).is_empty(), "typed event command accepted")
	before = SaveCodec.snapshot(run)
	var revision: int = run.routine_revision
	for command: RoutineFactCommand in [accepted, stale, RoutineFactCommand.set_event(run,"harbor-festival",true), RoutineFactCommand.set_event(_fresh(),"heavy-rain",true)]:
		_check(not run.apply_routine_command(command).is_empty() and SaveCodec.snapshot(run) == before and run.routine_revision == revision, "replay/unchanged/foreign/stale command inert")
	_check(old_facts.snapshot().authored_event_ids.is_empty(), "publication detaches old facts")
	var observed: Array[Dictionary] = []
	var observer: Callable = func() -> void:
		observed.append({"facts":run.routines.snapshot(), "revision":run.routine_revision,
			"reentry":run.apply_routine_command(RoutineFactCommand.set_event(run,"heavy-rain",true)), "advance":run.advance(1.0)})
	run.routine_facts_changed.connect(observer)
	_check(run.apply_routine_command(RoutineFactCommand.suppress_for_day(run,"vale-breakfast")).is_empty(), "suppression command publishes")
	run.routine_facts_changed.disconnect(observer)
	_check(observed.size() == 1 and observed[0].facts == run.routines.snapshot() and observed[0].revision == revision+1 and not observed[0].reentry.is_empty() and not observed[0].advance.is_empty(), "observer sees complete publication; reentry cannot half-publish")
	before = SaveCodec.snapshot(run)
	_check(not run.apply_routine_command(RoutineFactCommand.suppress_for_day(run,"vale-breakfast")).is_empty() and SaveCodec.snapshot(run) == before, "duplicate suppression inert")
	for id: String in RoutineContentCatalog.IDS:
		if not run.routines.suppressed(id): _check(run.apply_routine_command(RoutineFactCommand.suppress_for_day(run,id)).is_empty(), "all 25 suppression IDs " + id)
	_check(run.routines.suppressed_ids() == RoutineContentCatalog.IDS, "complete bounded suppression set")
	var detached: Dictionary = run.routines.snapshot()
	detached.authored_event_ids.clear(); detached.suppressed_routine_ids.clear()
	var ids: PackedStringArray = run.routines.authored_events(); ids.clear()
	_check(run.routines.suppressed_ids().size() == 25 and run.routines.event_active("harbor-festival"), "queries detach")

func _rollover() -> void:
	var run: GameSession = _fresh()
	run.environment.day_cycle_progress = (1439.0-600.0)/1440.0
	_check(run.apply_routine_command(RoutineFactCommand.suppress_for_day(run,"vale-overnight-home")).is_empty(), "night suppression")
	_check(run.apply_routine_command(RoutineFactCommand.set_event(run,"harbor-festival",true)).is_empty(), "event outlives day")
	_check(run.advance(2.0*600.0/1440.0).is_empty() and run.environment.day_index == 0 and run.routines.suppressed("vale-overnight-home"), "physical midnight does not expire facts")
	var context: RoutineResolutionContext = RoutineResolutionContext.from_session(run)
	_check(context.errors.is_empty() and context.suppressed("vale-overnight-home"), "selector samples actual durable facts")
	var stale: RoutineFactCommand = RoutineFactCommand.suppress_for_day(run,"vale-morning-work")
	var revision: int = run.routine_revision
	_check(run.advance(600.0*(1.0-run.environment.day_cycle_progress)).is_empty() and run.environment.day_index == 1 and run.routines.suppressed_ids().is_empty() and run.routines.event_active("harbor-festival") and run.routine_revision == revision+1, "10 AM authoritative rollover clears only suppression")
	_check(not run.apply_routine_command(stale).is_empty(), "prior-day command rejected")
	_check(run.apply_routine_command(RoutineFactCommand.suppress_for_day(run,"vale-morning-work")).is_empty(), "next-day suppression accepted")
	_check(run.advance(1200.0).is_empty() and run.environment.day_index == 3 and run.routines.suppressed_ids().is_empty(), "multi-day bounded advance expires once")
	run.environment.day_index = EnvironmentClock.MAX_DAY_INDEX
	run.environment.day_cycle_progress = 0.99
	_check(run.apply_routine_command(RoutineFactCommand.suppress_for_day(run,"vale-breakfast")).is_empty(), "last-day suppression")
	var before: Dictionary = SaveCodec.snapshot(run)
	for delta: float in [NAN, INF, -1.0, 1e300, 600.0]:
		_check(not run.advance(delta).is_empty() and SaveCodec.snapshot(run) == before, "failed clock advance preserves all facts")
	_check(not RoutineResolutionContext.from_session(null).errors.is_empty(), "null session sample rejects")

func _weather() -> void:
	for condition: String in ["thunderstorm", "rainy"]:
		var run: GameSession = _fresh()
		run.environment.day_index = 1; run.environment.day_cycle_progress = 1.0/3.0
		var found: bool = false
		for seed: int in 1000:
			run.environment.weather_seed = seed
			if run.weather_conditions.condition_id() == condition: found = true; break
		_check(found, "actual seeded weather " + condition)
		var forecast: Dictionary = TestRunSnapshot.weather(run.environment)
		_check(run.apply_routine_command(RoutineFactCommand.set_event(run,"heavy-rain",true)).is_empty(), "authored heavy-rain set")
		_check(RoutineResolutionContext.from_session(run).event_active("heavy-rain"), "authored union effective")
		_check(run.apply_routine_command(RoutineFactCommand.set_event(run,"heavy-rain",false)).is_empty(), "authored heavy-rain removal")
		_check(not run.routines.event_active("heavy-rain") and RoutineResolutionContext.from_session(run).event_active("heavy-rain") == (condition == "thunderstorm") and TestRunSnapshot.weather(run.environment) == forecast, "removal cannot clear derived storm or mutate forecast")

func _strict(run: GameSession) -> void:
	var before: Dictionary = SaveCodec.snapshot(run)
	var raw: String = TestRunSnapshot.exact_json(before)
	var result: SaveCodec.DecodeResult = SaveCodec.decode(raw, actors, npcs)
	_check(result.session != null and result.errors.is_empty(), "nontrivial current format restores")
	if result.session == null: return
	_check(SaveCodec.snapshot(result.session) == before and TestRunSnapshot.weather(result.session.environment) == TestRunSnapshot.weather(run.environment), "all old/new facts and forecast exactly retained")
	_check(before.routine_facts.size() == 2 and before.routine_facts.keys().all(func(id: String) -> bool: return id in ["authored_event_ids", "suppressed_routine_ids"]), "no saved clock/history/cursor/position duplication")
	_check(result.session != run and result.session.routines != run.routines and result.session.routine_revision == 0, "detached state and transient revision")
	_check(not result.session.apply_routine_command(RoutineFactCommand.set_event(run,"heavy-rain",false)).is_empty(), "restore rejects prior-owner commands")
	_check(result.session.apply_routine_command(RoutineFactCommand.set_event(result.session,"heavy-rain",false)).is_empty() and SaveCodec.snapshot(run) == before, "new binding works independently")
	for value: Variant in [null, true, [], {}, "facts", {"authored_event_ids":[],"suppressed_routine_ids":[],"day_index":0}]:
		var bad: Dictionary = before.duplicate(true); bad.routine_facts = value; _reject(bad,"invalid routine envelope " + str(value))
	for field: String in ["authored_event_ids", "suppressed_routine_ids"]:
		var bad: Dictionary = before.duplicate(true); bad.routine_facts.erase(field); _reject(bad,"missing " + field)
		for value: Variant in [null, true, {}, "ids", [null], [1], [false], [[]], [{}], [""], ["unknown"], ["heavy-rain"] if field == "suppressed_routine_ids" else ["vale-breakfast"], before.routine_facts[field] + before.routine_facts[field]]:
			bad = before.duplicate(true); bad.routine_facts[field] = value; _reject(bad,"invalid " + field + "/" + str(value))
	for field: String in ["day_index", "revision", "npc_positions", "path", "cursor", "lease", "weather", "events"]:
		var bad: Dictionary = before.duplicate(true); bad.routine_facts[field] = 0; _reject(bad,"extra transient/duplicate " + field)
	var bad: Dictionary = before.duplicate(true); bad.erase("routine_facts"); _reject(bad,"missing whole facts field")
	bad = before.duplicate(true); var shared: Array = []; bad.routine_facts.authored_event_ids = shared; bad.routine_facts.suppressed_routine_ids = shared; _reject(bad,"shared facts array")
	var cyclic: Array = []; cyclic.append(cyclic)
	bad = before.duplicate(true); bad.routine_facts.authored_event_ids = cyclic
	_check(SaveCodec.validate(bad,actors,npcs).session == null, "cyclic facts refuse before publication")
	cyclic.clear()
	_check(SaveCodec.decode(raw.replace('"authored_event_ids":', '"authored_event_ids":[],"authored_event_ids":'), actors, npcs).session == null, "duplicate raw fact field refuses")
	for version: int in [1,2,3,4,5,6,7,9,99]:
		bad = before.duplicate(true); bad.schema_version = version; bad.erase("routine_facts")
		var decoded: SaveCodec.DecodeResult = SaveCodec.decode(TestRunSnapshot.exact_json(bad),actors,npcs)
		_check(decoded.session == null and decoded.incompatible, "old/new incompatible before missing-field default " + str(version))
	bad = before.duplicate(true); bad.routine_facts.authored_event_ids.reverse(); bad.routine_facts.suppressed_routine_ids.reverse()
	var unordered: Dictionary = bad.duplicate(true)
	var sorted: SaveCodec.DecodeResult = SaveCodec.validate(bad,actors,npcs)
	_check(sorted.session != null and SaveCodec.snapshot(sorted.session) == before and bad == unordered, "canonical sets do not mutate caller")
	_check(SaveCodec.snapshot(run) == before, "bad saves leave original owner intact")

func _disk(run: GameSession) -> void:
	var repository: SaveRepository = SaveRepository.new("user://saves/r004-disk-%d.json" % OS.get_process_id(), npcs)
	var before: Dictionary = SaveCodec.snapshot(run)
	_check(repository.write(run,actors).is_empty(), "primary plus first backup publish")
	var raw: String = FileAccess.get_file_as_string(repository.path)
	_check(raw == FileAccess.get_file_as_string(repository.path+".bak"), "first primary/backup identical")
	var changed: GameSession = SaveCodec.decode(raw,actors,npcs).session
	_check(changed.apply_routine_command(RoutineFactCommand.set_event(changed,"heavy-rain",false)).is_empty(), "next snapshot command")
	for suffix: String in [".tmp", ".bak.tmp"]:
		_check(DirAccess.make_dir_absolute(repository.path+suffix) == OK, "owned IO obstruction")
		_check(not repository.write(changed,actors).is_empty() and FileAccess.get_file_as_string(repository.path) == raw and FileAccess.get_file_as_string(repository.path+".bak") == raw and SaveCodec.snapshot(changed).routine_facts.authored_event_ids == ["harbor-festival"], "failed write no half-publication " + suffix)
		_check(DirAccess.remove_absolute(repository.path+suffix) == OK, "obstruction removed")
	_check(repository.write(changed,actors).is_empty() and FileAccess.get_file_as_string(repository.path+".bak") == raw, "second write retains previous complete backup")
	_check(repository.read(actors).session.routines.authored_events() == PackedStringArray(["harbor-festival"]), "primary current new facts")
	_write(repository.path,"{broken")
	var recovered: SaveRepository.ReadResult = repository.read(actors)
	_check(recovered.recovered and recovered.session != null and SaveCodec.snapshot(recovered.session) == before and FileAccess.get_file_as_string(repository.path) == "{broken", "backup recovery complete/read-only")
	for version: int in [7,9]:
		_write(repository.path+".bak",raw)
		var unsupported: Dictionary = before.duplicate(true); unsupported.schema_version = version
		var old: String = TestRunSnapshot.exact_json(unsupported)
		_write(repository.path,old)
		_check(repository.read(actors).status == "incompatible" and repository.read(actors).session == null and not repository.write(run,actors).is_empty(), "incompatible primary cannot recover/overwrite " + str(version))
		_check(FileAccess.get_file_as_string(repository.path) == old and FileAccess.get_file_as_string(repository.path+".bak") == raw,"incompatible bytes preserved")
		_write(repository.path,raw); _write(repository.path+".bak",old)
		_check(not repository.write(run,actors).is_empty() and FileAccess.get_file_as_string(repository.path) == raw and FileAccess.get_file_as_string(repository.path+".bak") == old, "incompatible backup cannot overwrite " + str(version))
	_write(repository.path,"bad"); _write(repository.path+".bak","bad backup")
	_check(repository.read(actors).session == null and not repository.write(run,actors).is_empty() and SaveCodec.snapshot(run) == before, "both malformed inert")

func _current_fixtures() -> void:
	for path: String in ["res://tests/fixtures/environment_save_v8.json", "res://tests/fixtures/map_saves/town-fresh.json", "res://tests/fixtures/map_saves/town-lead.json", "res://tests/fixtures/map_saves/town-complete.json", "res://tests/fixtures/map_saves/tollworks-vessel.json", "res://tests/fixtures/map_saves/tollworks-start-downed.json"]:
		var raw: String = FileAccess.get_file_as_string(path)
		var decoded: SaveCodec.DecodeResult = SaveCodec.decode(raw,actors,npcs)
		_check(decoded.session != null and decoded.errors.is_empty(), "complete current fixture " + path)
		if decoded.session != null:
			_check(decoded.session.routines.authored_events().is_empty() and decoded.session.routines.suppressed_ids().is_empty(), "explicit empty routine facts " + path)

func _root(run: GameSession) -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	var manifest: ContentManifest = ContentManifest.new(); manifest.definitions.assign(game.content_manifest.definitions)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-unsafe-location"; unsafe.display_name = "R004 fixture"; unsafe.prototype_fixture = true
	unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"; unsafe.spawn_ids = ["unsafe-no-floor","unsafe-blocked"]
	manifest.definitions.append(unsafe); game.content_manifest = manifest
	root.add_child(game); await game.world_host.transition_finished
	_check(TestRunSave.configure(game,"user://saves/r004-root.json").is_empty(), "isolated root repository after startup")
	game._set_paused(true)
	_check(game.save_repository.write(run,game.catalog).is_empty() and (await game.load_run()).is_empty(), "root detached restore")
	var before: Dictionary = SaveCodec.snapshot(game.session)
	_check(before == SaveCodec.snapshot(run) and game.dialogue._session == game.session and game.world_host.session == game.session and game.player_placeholder.state == game.session.actors[GameSession.PLAYER_INSTANCE_ID], "every old/new fact and scene service rebound")
	var live: GameSession = game.session; var room: PrototypeLocation = game.world_host.current_location
	var foot: Vector3 = game.player_placeholder.global_position
	var old_command: RoutineFactCommand = RoutineFactCommand.set_event(live,"heavy-rain",false)
	var raw: String = FileAccess.get_file_as_string(game.save_repository.path)
	for mutation: String in ["malformed", "old", "new", "unsafe-no-floor", "unsafe-blocked"]:
		var bad: Dictionary = before.duplicate(true)
		match mutation:
			"malformed": bad.routine_facts.authored_event_ids.append("unknown")
			"old": bad.schema_version = 7
			"new": bad.schema_version = 9
			_: bad.location_id = unsafe.stable_id; bad.spawn_id = mutation
		_write(game.save_repository.path,TestRunSnapshot.exact_json(bad)); _write(game.save_repository.path+".bak","invalid backup")
		_check(not (await game.load_run()).is_empty(), "root rejected " + mutation)
		_check(game.session == live and game.world_host.current_location == room and game.world_host.session == live and game.dialogue._session == live and SaveCodec.snapshot(live) == before and game.player_placeholder.global_position == foot, "failed restore preserves complete owners " + mutation)
	_write(game.save_repository.path,"broken"); _write(game.save_repository.path+".bak",raw)
	_check((await game.load_run()).is_empty() and SaveCodec.snapshot(game.session) == before and game.session != live, "root backup recovery exact detached owner")
	_check(not game.session.apply_routine_command(old_command).is_empty(), "old session command inert after live restore")
	_check(game.session.apply_routine_command(RoutineFactCommand.set_event(game.session,"heavy-rain",false)).is_empty(), "restored owner accepts fresh command")
	_check(game.save_run().is_empty(), "manual current root save")
	_check(game.party.members().size() == 2 and game.session.weather_conditions.sample() != null, "party/weather binding remains")
	game._set_paused(false); game.queue_free(); await process_frame

func _write(path: String, raw: String) -> void:
	var file: FileAccess = FileAccess.open(path,FileAccess.WRITE)
	_check(file != null,"isolated fixture IO")
	if file != null: file.store_string(raw); file.close()
func _reject(data: Dictionary, label: String) -> void:
	var result: SaveCodec.DecodeResult = SaveCodec.validate(data,actors,npcs)
	_check(result.session == null and not result.errors.is_empty(),"reject " + label); rejected.append(label)
func _check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)
func _finish(name: String) -> void:
	_check(TestRunEvidence.write_json(name,{"assertions":assertions,"rejections":rejected,"failures":failures,"proof":"synthetic routine facts; real filesystem and production manual restore"}),"report")
	for error: String in failures: push_error(error)
	print("R004 ",name,": ","PASS" if failures.is_empty() else "FAILED"," assertions=",assertions," rejections=",rejected.size())
	quit(0 if failures.is_empty() else 1)
