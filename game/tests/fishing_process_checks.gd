extends "res://tests/fishing_integration_checks.gd"
## FS007 independent synthetic rich-state processes; actual GUI pair is rendered separately.

func _exercise() -> void:
	task = "FS007"
	var writing: bool = "--phase=write" in OS.get_cmdline_user_args()
	suite = "process-write" if writing else "process-read"
	var oracle_path: String = game.save_repository.path+".fs007-oracle"
	_check(game.fishing.mode() == "idle" and game.session.inventory.count("item-bluegill") == 0,"fresh process has no fish/attempt inheritance")
	if writing:
		await _rich_baseline()
		for id: String in FISH:
			_cast(id)
			_land()
		_check(game.session.inventory.select("item-golden-carp").is_empty(),"synthetic selected fish")
		game._set_paused(true)
		_check(game.save_run().is_empty(),"manual writer save")
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.WRITE)
		_check(file != null,"writer typed oracle sidecar")
		if file != null:
			file.store_var(TestRunSnapshot.oracle(game.session))
			file.close()
	else:
		game._set_paused(true)
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.READ)
		_check(file != null,"independent rich writer oracle")
		if file == null: return
		var oracle: Dictionary = file.get_var(false)
		file.close()
		_check((await game.load_run()).is_empty(),"manual independent reader load")
		var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
		_check(disk.session != null,"independent typed disk read")
		if disk.session != null:
			var errors: PackedStringArray = TestRunSnapshot.compare_restored(game.session,oracle,disk.session)
			_check(errors.is_empty(),"different PID/exact every rich fact/forecast " + str(errors))
		for id: String in FISH: _check(game.session.inventory.count(id) == 1,"exact restored species count " + id)
		_check(game.session.inventory.snapshot().active_item_id == "item-golden-carp" and game.fishing.mode() == "idle" and not game.fishing_effects.visible,"selected fish restored without transient attempt")
		var stable: String = _facts()
		_check(game.save_run().is_empty() and _facts() == stable,"reader paused re-save inert")
		await _failed_save()
	rows.append({"engine_pid":OS.get_process_id(),"phase":"write" if writing else "read","user_data":OS.get_user_data_dir(),"snapshot":SaveCodec.snapshot(game.session)})
