extends "res://tests/support/routine_execution_fixture.gd"

func _run() -> void:
	if "--phase=write" in OS.get_cmdline_user_args() or "--phase=read" in OS.get_cmdline_user_args():
		await _process_restart()
		return
	if await setup(0,"prototype-mayor-vale-home"):
		await _test()
	await finish("reconstruction.json")

func _test() -> void:
	var catalog: RoutineContentCatalog = RoutineContentCatalog.new()
	check(catalog.initialize_path(game.npc_catalog).is_empty(),"all25 catalog")
	for routine_id: String in catalog.routine_ids():
		var definition: RoutineDefinition = catalog.get_routine(routine_id)
		for id: String in definition.participants:
			for elapsed: float in [0.0,1.0,50.0,600.0,1e100]:
				var cursor: RoutineExecutor = RoutineExecutor.new()
				check(cursor.initialize(definition,id,execution.world.origin(routine_id,id)),"qualified origin "+routine_id)
				check(cursor.reconstruct(elapsed,execution.world),"bounded reconstruct "+routine_id)
				check(cursor.transitions <= 64 and cursor.foot.is_finite(),"per-actor cap/finite feet "+routine_id)
	# Retain the exact source observation and reproduce its class of failure: town
	# source foot (704,528) transformed with home origin is not a safe home foot.
	var mixed: Vector3 = Vector3((704.0-256.0)/32.0,0,(528.0-384.0)/32.0)
	var mixed_errors: PackedStringArray = NpcWorldAdapter.foot_errors(game.world_host.current_location,mixed,[])
	check(not mixed_errors.is_empty(),"INT064 mixed map/origin foot genuinely fails target floor/capsule")
	observations.append({"case":"INT064 retained pre-repair diagnostic","source_status":"Pending; original enum unconfirmed; source not executed","source_hidden_town_foot":[704,528],"incorrect_home_foot":str(mixed),"actual_errors":mixed_errors,"repair":"qualified map/foot origins; no hidden loaded-map registration"})
	for minute: float in [1320.0,0.0,360.0,480.0]:
		var run: GameSession = SaveCodec.validate(SaveCodec.snapshot(game.session),game.catalog,game.npc_catalog).session
		run.environment.day_cycle_progress = fposmod((minute-600)/1440,1)
		var stage: Dictionary = execution.stage(run)
		check(stage.ok,"fresh/load clock stage "+str(minute))
		if not stage.ok: continue
		var edric: RoutineExecutor = stage.actors["npc-01"]
		check(edric.failure == RoutineExecutor.Failure.NONE,"Edric never hidden failed after reconstruction")
		check(edric.map_id == "prototype-mayor-vale-home","qualified predecessor/home reconstruction "+str(minute))
		if minute == 0:
			check(edric.current_step().id == "rest-until-morning" and edric.foot == Vector3(-5.5,0,.25),"midnight Edric exact authored rest")
		if minute == 360: check(edric.routine.id == "vale-breakfast" and edric.foot == Vector3(-5.5,0,.25),"06:00 starts breakfast from overnight rest")
		observations.append({"case":"synthetic fresh/load clock","minute":minute,"edric":edric.snapshot(),"transitions":stage.transitions})
	# Max supported clock and huge finite deltas use finite step sweeps, no day replay.
	var run: GameSession = SaveCodec.validate(SaveCodec.snapshot(game.session),game.catalog,game.npc_catalog).session
	run.environment.day_index = 3650; run.environment.day_cycle_progress = .99
	var maximum_us: int = 0
	for repeat: int in range(20):
		var start: int = Time.get_ticks_usec()
		var stage: Dictionary = execution.stage(run)
		maximum_us = maxi(maximum_us,Time.get_ticks_usec()-start)
		check(stage.ok and stage.transitions <= 512,"max clock bounded total")
	check(maximum_us <= 50000,"max-clock reconstruction <=50ms measured "+str(maximum_us))
	observations.append({"case":"max-clock reconstruction","day":3650,"progress":.99,"maximum_us":maximum_us,"samples":20})
	var before: Dictionary = execution.snapshot()
	execution.tick(INF); execution.tick(NAN); execution.tick(-1)
	check(execution.snapshot() == before,"bad delta inert")
	var cursor: RoutineExecutor = RoutineExecutor.new()
	check(not cursor.initialize(catalog.get_routine("vale-overnight-home"),"npc-01",{"map":"prototype-mayor-vale-home","foot":Vector3.INF}),"nonfinite qualified origin refuses")
	check(not execution.world.chain("prototype-tollworks","prototype-mayor-vale-home").ok,"unmeasured NPC chain refuses existing player-only Tollworks")

func _process_restart() -> void:
	var writing: bool = "--phase=write" in OS.get_cmdline_user_args()
	if not await setup(0 if writing else 600,"prototype-mayor-vale-home" if writing else "prototype-alderwake"):
		await finish("restart-failed.json"); return
	check(TestRunSave.configure(game,"user://saves/r010-restart.json").is_empty(),"isolated primary/backup restart slot")
	game._set_paused(true)
	var oracle_path: String = game.save_repository.path+".oracle"
	if writing:
		check(game.save_run().is_empty() and game.save_run().is_empty(),"actual root saves primary/backup at midnight")
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.WRITE)
		check(file != null,"writer oracle file")
		if file != null: file.store_string(JSON.stringify(TestRunSnapshot.oracle(game.session),"",true,true)); file.close()
	else:
		var old: GameSession = game.session
		check((await game.load_run()).is_empty(),"fresh process actual manual Load")
		var oracle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(oracle_path))
		var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
		check(TestRunSnapshot.compare_restored(game.session,oracle,disk.session).is_empty(),"distinct process exact complete durable/forecast restore")
		check(game.session != old and execution._session == game.session and game.world_host.session == game.session,"execution/session/world owners rebound once")
		check(execution.actor("npc-01").current_step().id == "rest-until-morning" and execution.actor("npc-01").foot == Vector3(-5.5,0,.25),"manual midnight Load reconstructs Edric home rest")
		check(game.world_host.current_location.npc_contacts.targets.size() == 2,"restored two Vale bodies, no hidden extra contacts")
		check(game.save_run().is_empty(),"restored re-save")
		for suffix: String in ["",".bak"]:
			var decoded: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(game.save_repository.path+suffix),game.catalog,game.npc_catalog)
			check(decoded.session != null and TestRunSnapshot.exact_json(SaveCodec.snapshot(decoded.session)) == oracle.snapshot_json,"exact current primary/backup "+suffix)
	observations.append({"case":"separate-process manual save/load","writing":writing,"pid":OS.get_process_id(),"execution":execution.snapshot()})
	for minute: int in [1320,360]:
		check(TestRunSave.configure(game,"user://saves/r010-restart-"+str(minute)+".json").is_empty(),"isolated22/06 slot")
		oracle_path = game.save_repository.path+".oracle"
		if writing:
			var candidate: GameSession = SaveCodec.validate(SaveCodec.snapshot(game.session),game.catalog,game.npc_catalog).session
			candidate.environment.day_cycle_progress = fposmod((float(minute)-600.0)/1440.0,1)
			check(game.save_repository.write(candidate,game.catalog).is_empty(),"synthetic22/06 complete current save")
			check((await game.load_run()).is_empty() and game.save_run().is_empty(),"actual physical22/06 Load/Save")
			var file: FileAccess = FileAccess.open(oracle_path,FileAccess.WRITE)
			check(file != null,"22/06 oracle")
			if file != null: file.store_string(JSON.stringify(TestRunSnapshot.oracle(game.session),"",true,true)); file.close()
		else:
			check((await game.load_run()).is_empty(),"separate process22/06 manual Load")
			var oracle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(oracle_path))
			var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
			check(TestRunSnapshot.compare_restored(game.session,oracle,disk.session).is_empty(),"22/06 exact durable/forecast oracle")
			check(game.save_run().is_empty(),"22/06 exact re-save")
			for suffix: String in ["",".bak"]:
				var decoded: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(game.save_repository.path+suffix),game.catalog,game.npc_catalog)
				check(decoded.session != null and TestRunSnapshot.exact_json(SaveCodec.snapshot(decoded.session)) == oracle.snapshot_json,"22/06 exact primary/backup "+suffix)
		check(execution.actor("npc-01").failure == RoutineExecutor.Failure.NONE and execution.actor("npc-01").map_id == RoutineExecutionWorld.HOME,"22/06 visible safe Edric reconstructed")
		check(game.world_host.current_location.npc_contacts.targets.size() == 2 and NavigationServer3D.map_get_regions(game.world_host.get_world_3d().navigation_map).size() == 1,"22/06 one home region/two wrappers")
		observations.append({"case":"separate-process22/06","minute":minute,"writing":writing,"edric":execution.actor("npc-01").snapshot()})
	await finish("restart-write.json" if writing else "restart-read.json")
