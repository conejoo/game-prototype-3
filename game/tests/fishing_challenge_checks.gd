extends SceneTree
## FS003 pure synthetic rules; no player, scene, inventory, save or RNG authority.

const C = preload("res://features/fishing/fishing_challenge_controller.gd")
var assertions: int = 0
var failures: PackedStringArray = []
var traces: Array[Dictionary] = []
var catalog: ContentCatalog = ContentCatalog.new()

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "FS002 current catalog prerequisite")
	_frozen()
	_phases()
	_invalid()
	_boundaries()
	_species()
	_partitions()
	_cancel_restart()
	_check(TestRunEvidence.write_json("fishing-challenge.json", {
		"task":"FS003", "proof":"synthetic pure rules; boundary states explicitly isolated",
		"assertions":assertions+1, "failures":failures, "traces":traces,
		"step_seconds":C.STEP_SECONDS, "state_tolerance":1e-9, "event_tolerance_seconds":C.STEP_SECONDS
	}), "write evidence")
	for failure: String in failures: push_error(failure)
	print("FS003 fishing challenge ", "PASS" if failures.is_empty() else "FAILED", " assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, label: String) -> void:
	assertions += 1
	if not condition: failures.append(label)

func _feature(id: String = "item-bluegill") -> FishingChallengeDefinition:
	return catalog.get_item(id).fishing_challenge

func _new(id: String = "item-bluegill", roll: float = 0.0, held: bool = false) -> FishingChallengeController:
	var controller: FishingChallengeController = C.new()
	_check(controller.start(id,_feature(id),roll,0,held).accepted, "start " + id)
	return controller

func _token(controller: FishingChallengeController) -> int: return controller.snapshot().attempt_token

func _update(controller: FishingChallengeController, dt: float, held: bool = false, generation: int = 0) -> FishingChallengeController.CommandResult:
	var result: FishingChallengeController.CommandResult = controller.update(dt,held,generation,_token(controller))
	_check(result.accepted, "accepted update: " + result.error)
	return result

func _fight(id: String = "item-bluegill") -> FishingChallengeController:
	var controller: FishingChallengeController = _new(id)
	_update(controller,1.5)
	_check(controller.snapshot().phase == "bite", "exact wait boundary")
	_update(controller,0,true,1)
	_check(controller.snapshot().phase == "fighting", "fresh bite press hooks")
	return controller

func _frozen() -> void:
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/fishing/reference/rules.json")).challenge
	_check(rules.initial_tension == C.new().snapshot().tension, "frozen initial tension")
	_check(rules.danger_grace == C.DANGER_GRACE_SECONDS, "frozen danger grace")
	for tier: String in rules.tiers:
		var data: Dictionary = rules.tiers[tier]
		var bounds: Vector4 = C.tier_bounds(tier)
		_check(Vector2(bounds.x,bounds.y).is_equal_approx(Vector2(data.optimal[0],data.optimal[1])), "frozen optimal " + tier)
		_check(Vector2(bounds.z,bounds.w).is_equal_approx(Vector2(data.danger[0],data.danger[1])), "frozen danger " + tier)
		for seconds: float in [0.0,0.1,0.675,1.0,1.9,7.25,29.99]:
			var expected: float = 0.0
			for wave: Array in data.struggle: expected += wave[0] * sin(2.0*PI*seconds/wave[1])
			_check(absf(C.struggle_force(seconds,tier)-expected) <= 1e-14, "frozen curve " + tier + "/" + str(seconds))

func _phases() -> void:
	for roll: float in [0.0,0.5,0.999999999]:
		var controller: FishingChallengeController = _new("item-bluegill",roll)
		var wait: float = 1.5+1.5*roll
		_check(controller.snapshot().wait_seconds == wait and wait >= 1.5 and wait < 3.0, "wait RNG endpoints")
		_update(controller,wait-0.000001)
		_check(controller.snapshot().phase == "waiting", "before bite boundary")
		_update(controller,0.000001)
		_check(controller.snapshot().phase == "bite", "at bite boundary")
	var controller: FishingChallengeController = _new()
	_update(controller,1.8)
	_check(absf(controller.snapshot().phase_elapsed_seconds-0.3)<1e-12, "wait to bite carries hitch overshoot")
	_update(controller,0.899999)
	_check(controller.is_active(), "hook window before exact endpoint")
	_check(_update(controller,0.000001).resolution.outcome == "missed_hook", "exact hook endpoint expires")
	controller = _new()
	_check(_update(controller,10).resolution.outcome == "missed_hook", "hitch spans waiting and entire bite")
	controller = C.new()
	_check(controller.start("",null,0.5,0).accepted, "miss starts normal wait")
	_update(controller,2.249999)
	_check(controller.snapshot().phase == "waiting", "miss waits")
	_check(_update(controller,0.000001).resolution.outcome == "no_bite", "miss exact boundary")
	controller = _new()
	_check(_update(controller,5,true,1).resolution.outcome == "early_reel", "press is sampled before dt even across wait")
	controller = _new("item-bluegill",0,true)
	_update(controller,1.5,true)
	_update(controller,0.2,true)
	_check(controller.snapshot().phase == "bite", "held at cast never auto hooks")
	_update(controller,0,false)
	_update(controller,0,true,1)
	_check(controller.snapshot().phase == "fighting", "release then fresh press hooks")
	controller = _new()
	_update(controller,1.5)
	_update(controller,0,false,1)
	_update(controller,0.1,false,1)
	_check(controller.snapshot().phase == "bite", "released press generation does not hook")
	_update(controller,0.1,true,2)
	_check(absf(controller.snapshot().elapsed_fight_seconds-0.1)<1e-12, "hook update dt carries into fight")
	for id: String in ["item-bluegill","item-river-trout","item-golden-carp"]:
		controller = _new(id)
		_update(controller,1.5)
		_update(controller,_feature(id).hook_window_seconds-0.000001)
		_check(controller.snapshot().phase == "bite", "species hook before endpoint " + id)
		_check(_update(controller,0.000001).resolution.outcome == "missed_hook", "species exact hook expiry " + id)
		controller = _new(id)
		_update(controller,1.5)
		_update(controller,_feature(id).hook_window_seconds-0.000001)
		_update(controller,0,true,1)
		_check(controller.snapshot().phase == "fighting", "species final fresh hook " + id)
	for outcome: String in ["early_reel","missed_hook","no_bite"]:
		controller = C.new()
		_check(controller.start("" if outcome == "no_bite" else "item-bluegill",null if outcome == "no_bite" else _feature(),0,0).accepted, "failure replay fixture")
		var result: FishingChallengeController.CommandResult = _update(controller,10,outcome == "early_reel",1 if outcome == "early_reel" else 0)
		_check(result.resolution.outcome == outcome and not result.resolution.reward_eligible, "failure has no eligible reward " + outcome)
		var token: int = _token(controller)
		_check(not controller.update(10,false,1,token).accepted and not controller.cancel(token).accepted, "failed resolution replay blocked " + outcome)
		_check(controller.start("item-bluegill",_feature(),0,10).accepted, "restart after " + outcome)
		_check(not controller.update(1,false,10,token).accepted, "failed attempt cannot affect restart")

func _invalid() -> void:
	var controller: FishingChallengeController = C.new()
	for value: Variant in [-1,1,1.01,NAN,INF,true,"0",null,{},[]]:
		_check(not controller.start("item-bluegill",_feature(),value,0).accepted, "invalid wait RNG")
	_check(not controller.start("",_feature(),0,0).accepted, "missing fish")
	_check(not controller.start("item-bluegill",null,0,0).accepted, "missing feature")
	_check(not controller.start(" item-bluegill",_feature(),0,0).accepted, "invalid identity")
	for field: String in ["difficulty","hook_window_seconds","minimum_fight_seconds","maximum_fight_seconds"]:
		var feature: FishingChallengeDefinition = _feature().duplicate(true)
		feature.set(field,"unknown" if field == "difficulty" else NAN)
		_check(not controller.start("item-bluegill",feature,0,0).accepted, "invalid feature " + field)
	var invalid_feature: FishingChallengeDefinition = _feature().duplicate(true)
	invalid_feature.maximum_fight_seconds = 1
	_check(not controller.start("item-bluegill",invalid_feature,0,0).accepted, "reversed durations")
	for generation: Variant in [-1,0.5,true,"0",null]: _check(not controller.start("item-bluegill",_feature(),0,generation).accepted, "invalid initial generation")
	_check(not controller.start("item-bluegill",_feature(),0,0,1).accepted, "invalid initial held")
	controller = _new()
	var before: FishingChallengeController.Snapshot = controller.snapshot()
	_check(not controller.start("item-river-trout",_feature("item-river-trout"),0,0).accepted, "overlapping start rejected")
	for dt: Variant in [-1,60.001,NAN,INF,true,"0",null,{},[]]: _check(not controller.update(dt,false,0,_token(controller)).accepted, "invalid delta")
	for generation: Variant in [-1,0.5,true,"0",null]: _check(not controller.update(0,false,generation,_token(controller)).accepted, "invalid update generation")
	for held: Variant in [0,1,"true",null]: _check(not controller.update(0,held,0,_token(controller)).accepted, "invalid held")
	for token: Variant in [-1,0,999,true,1.0,"1",null]: _check(not controller.update(0,false,0,token).accepted, "invalid token")
	_check(not controller.update(0,true,0,_token(controller)).accepted, "held rise requires press")
	_check(controller.snapshot().phase == before.phase and controller.snapshot().phase_elapsed_seconds == before.phase_elapsed_seconds and _token(controller) == before.attempt_token, "rejections leave state intact")
	before.phase = "terminal"
	before.tension = 100
	_check(controller.snapshot().phase == "waiting" and controller.snapshot().tension == 0.5, "snapshot detached")
	var feature: FishingChallengeDefinition = _feature().duplicate(true)
	controller = C.new()
	_check(controller.start("item-bluegill",feature,0,0).accepted, "metadata copied")
	feature.hook_window_seconds = 0.01
	_update(controller,1.6)
	_check(controller.snapshot().phase == "bite", "authored definition cannot mutate active attempt")
	_update(controller,0,true,1)
	_check(not controller.update(0,true,2,_token(controller)).accepted, "held cannot forge second fresh press")
	_check(not controller.update(0,false,0,_token(controller)).accepted, "generation cannot rewind")

func _boundaries() -> void:
	# Isolated synthetic internal state proves exact thresholds and terminal priority.
	# No production setter/force command exists; ordinary trajectories follow below.
	for id: String in ["item-bluegill","item-river-trout","item-golden-carp"]:
		var bounds: Vector4 = C.tier_bounds(_feature(id).difficulty)
		for row: Array in [[bounds.z,0.0],[bounds.z+0.000001,0.25],[bounds.x-0.000001,0.25],[bounds.x,1.0],
			[bounds.y,1.0],[bounds.y+0.000001,0.25],[bounds.w-0.000001,0.25],[bounds.w,0.0]]:
			var controller: FishingChallengeController = _fight(id)
			controller._state.tension = row[0] - (0.65+C.struggle_force(C.STEP_SECONDS,_feature(id).difficulty))*C.STEP_SECONDS
			_update(controller,C.STEP_SECONDS,true,1)
			_check(absf(controller.snapshot().landing_progress-row[1]*C.STEP_SECONDS/_feature(id).minimum_fight_seconds)<1e-12, "inclusive zone progress " + id + "/" + str(row[0]))
			_check((controller.snapshot().danger_seconds>0) == (row[1]==0), "inclusive danger boundary")
	var controller: FishingChallengeController = _fight()
	controller._state.tension = 1.0
	_update(controller,0.75-0.000001,true,1)
	_check(controller.is_active(), "danger below grace survives")
	_check(_update(controller,0.000001,true,1).resolution.outcome == "line_snapped", "danger exact grace snaps")
	_check(controller.snapshot().tension == 1.0, "tension upper clamp")
	controller = _fight()
	controller._state.tension = 0.0
	_check(_update(controller,0.75,false,1).resolution.outcome == "line_slack", "danger exact grace slack")
	_check(controller.snapshot().tension == 0.0, "tension lower clamp")
	controller = _fight()
	controller._state.tension = 0.9001
	controller._state.danger_seconds = 0.7
	_update(controller,C.STEP_SECONDS,false,1)
	_check(controller.snapshot().danger_seconds == 0.0, "return to safe resets danger")
	controller._state.tension = 1.0
	_update(controller,0,true,2)
	_update(controller,C.STEP_SECONDS,true,2)
	_check(absf(controller.snapshot().danger_seconds-C.STEP_SECONDS)<1e-12, "new danger interval starts from zero")
	controller = _fight()
	controller._state.tension = 1.0
	controller._state.danger_seconds = 0.75-C.STEP_SECONDS
	controller._state.landing_progress = 1.0
	controller._state.elapsed_fight_seconds = 5.0-C.STEP_SECONDS
	_check(_update(controller,C.STEP_SECONDS,true,1).resolution.outcome == "line_snapped", "danger wins landing and timeout tie")
	controller = _fight()
	controller._state.landing_progress = 1.0-C.STEP_SECONDS/2.0
	controller._state.elapsed_fight_seconds = 5.0-C.STEP_SECONDS
	_check(_update(controller,C.STEP_SECONDS,true,1).resolution.outcome == "landed", "landing wins timeout tie")
	controller = _fight()
	controller._state.elapsed_fight_seconds = 5.0-0.001
	_update(controller,0.000999,true,1)
	_check(controller.is_active(), "fractional maximum before boundary")
	_check(_update(controller,0.000001,true,1).resolution.outcome == "exhausted", "maximum exact fractional boundary")

func _species() -> void:
	for id: String in ["item-bluegill","item-river-trout","item-golden-carp"]:
		for strategy: String in ["landed","line_slack","line_snapped","exhausted"]:
			var controller: FishingChallengeController = _fight(id)
			var generation: int = 1
			var terminal_count: int = 0
			var resolution: FishingChallengeController.Resolution = null
			for frame: int in 2400:
				var state: FishingChallengeController.Snapshot = controller.snapshot()
				var target: float = 0.5 if strategy == "landed" else state.optimal_maximum+0.06
				var held: bool = state.tension < target
				if strategy == "line_slack": held = false
				if strategy == "line_snapped": held = true
				if held and not state.reel_held: generation += 1
				var result: FishingChallengeController.CommandResult = _update(controller,1.0/60.0,held,generation)
				if result.resolution != null:
					resolution = result.resolution
					terminal_count += 1
					break
			_check(resolution != null, "bounded terminal " + id + "/" + strategy)
			if resolution == null: continue
			_check(resolution.outcome == strategy, "trajectory outcome " + id + "/" + strategy + ": " + resolution.outcome)
			_check(resolution.reward_eligible == (strategy == "landed") and resolution.fish_item_id == id, "single eligible species result")
			_check(terminal_count == 1 and not controller.is_active(), "one terminal event")
			_check(not controller.update(60,false,generation,_token(controller)).accepted and not controller.cancel(_token(controller)).accepted, "terminal cannot resolve/cancel again")
			var recorded: FishingChallengeController.Snapshot = controller.snapshot()
			traces.append({"species":id,"strategy":strategy,"outcome":resolution.outcome,"seconds":controller.snapshot().elapsed_fight_seconds,"tension":controller.snapshot().tension,"progress":controller.snapshot().landing_progress})
			resolution.outcome = "landed"
			resolution.attempt_token = 9999
			_check(controller.snapshot().outcome == recorded.outcome and _token(controller) == recorded.attempt_token, "resolution detached from live state")
			_check(controller.start(id,_feature(id),0,generation).accepted, "restart after fight terminal")
			_check(not controller.update(0,false,generation,recorded.attempt_token).accepted, "fight terminal token invalid after restart")

func _partition_state(partition: Array[float], hooked: bool) -> FishingChallengeController.Snapshot:
	var controller: FishingChallengeController = _fight() if hooked else _new()
	for dt: float in partition: _update(controller,dt,hooked,1 if hooked else 0)
	return controller.snapshot()

func _same(a: FishingChallengeController.Snapshot, b: FishingChallengeController.Snapshot, label: String) -> void:
	_check(a.phase == b.phase and a.outcome == b.outcome, label + " phase/outcome")
	for field: String in ["phase_elapsed_seconds","elapsed_fight_seconds","pending_fight_seconds","tension","landing_progress","danger_seconds","struggle_force"]:
		_check(absf(a.get(field)-b.get(field)) <= 1e-9, label + "/" + field)

func _partitions() -> void:
	_same(_partition_state([2.123],false),_partition_state([0.17,0.333,0.62,1.0],false),"wait/bite phase carry")
	_same(_partition_state([0.513],true),_partition_state([0.017,0.033,0.1,0.003,0.36],true),"fractional fight carry")
	var fine: Array[float] = []
	for i: int in 60: fine.append(1.0/60.0)
	_same(_partition_state([1.0],true),_partition_state(fine,true),"60Hz versus one-second hitch")
	for id: String in ["item-bluegill","item-river-trout","item-golden-carp"]:
		var coarse: FishingChallengeController = _fight(id)
		var split: FishingChallengeController = _fight(id)
		var generation: int = 1
		for segment: int in 400:
			var held: bool = segment % 2 == 0
			if held and segment > 0: generation += 1
			var dt: float = 0.1 if held else 0.12
			_update(coarse,dt,held,generation)
			for fraction: float in [0.13,0.27,0.6]:
				if split.is_active(): _update(split,dt*fraction,held,generation)
			_same(coarse.snapshot(),split.snapshot(),"same timestamp input partitions " + id + "/" + str(segment))
			if not coarse.is_active(): break
		_check(coarse.snapshot().outcome == "landed", "partitioned scripted landing " + id)
	# Large valid updates are bounded, and cannot skip danger checks into a success.
	var controller: FishingChallengeController = _fight()
	_check(_update(controller,60,true,1).resolution.outcome == "line_snapped", "maximum hitch simulates danger first")

func _cancel_restart() -> void:
	for phase: String in ["waiting","bite","fighting"]:
		for reason: String in ["explicit","focus_loss","pause_or_modal","room_or_session_replacement","retry_or_death","combat_engagement","rod_or_capability_invalidated"]:
			var controller: FishingChallengeController = _new()
			if phase in ["bite","fighting"]: _update(controller,1.5)
			if phase == "fighting": _update(controller,0.1,true,1)
			var old_token: int = _token(controller)
			_check(not controller.cancel(old_token+1).accepted and not controller.cancel(old_token,"").accepted, "invalid cancellation leaves attempt active")
			var canceled: FishingChallengeController.CommandResult = controller.cancel(old_token,reason)
			_check(canceled.accepted and canceled.resolution.outcome == "canceled" and canceled.resolution.cancel_reason == reason and not canceled.resolution.reward_eligible, "cancel " + phase + "/" + reason)
			_check(not controller.snapshot().reel_held and controller.snapshot().pending_fight_seconds == 0, "cancel clears input/carry")
			_check(not controller.cancel(old_token).accepted and not controller.update(1,false,1,old_token).accepted, "cancel terminal replay blocked")
			_check(controller.start("item-river-trout",_feature("item-river-trout"),0,5,true).accepted, "restart after cancel")
			_check(_token(controller)>old_token and controller.snapshot().tension == 0.5 and controller.snapshot().landing_progress == 0 and controller.snapshot().danger_seconds == 0, "restart fresh token/state")
			_check(not controller.update(1,false,6,old_token).accepted and not controller.cancel(old_token).accepted, "old callbacks cannot touch restarted attempt")
			_update(controller,1.5,true,5)
			_check(controller.snapshot().phase == "bite", "restart held press cannot hook")
			_update(controller,0,false,5)
			_update(controller,0,true,6)
			_check(controller.snapshot().phase == "fighting", "restart fresh hook")
