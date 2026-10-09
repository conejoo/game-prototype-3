extends "res://tests/support/routine_execution_fixture.gd"
## R012 synthetic cursor/clock cases on real production wrappers and owner holds.
func _run() -> void:
	if await setup(1050):
		await _speech()
		await _action("npc-01","river-fishing","action_river_fishing")
		await _fallback()
		var speaker: RoutineExecutor = execution.actor("npc-01")
		speaker.index = 2; speaker.state = RoutineExecutor.State.SPEAKING; speaker.remaining = 4
		execution.present()
		check(game.world_host.current_location.npc_contacts.routine_presentations["npc-01"].speech.visible,"unload begins with active public speech")
		var ref: WeakRef = weakref(game.world_host.current_location.npc_contacts.routine_presentations["npc-01"])
		check(await travel(RoutineExecutionWorld.HOME),"real unload")
		check(ref.get_ref() == null,"unload destroys speech/accessory owner")
		await _action("npc-02","archive-work","action_archive_work")
		var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
		var active: RoutineExecutor = execution.actor("npc-02")
		active.state = RoutineExecutor.State.ACTING; active.remaining = 2
		execution.present()
		check(adapter.presenters["npc-02"].active_action() == "action_archive_work","dispose begins with active accessory")
		execution.dispose()
		for presentation: RoutinePresentation in adapter.routine_presentations.values():
			check(presentation.speech.text.is_empty() and not presentation.speech.visible and presentation.presenter.active_action().is_empty(),"dispose clears transient output")
	await _view_lane()
	await _finish_r012()

func _speech() -> void:
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	var cursor: RoutineExecutor = execution.actor("npc-01")
	var visual: RoutinePresentation = adapter.routine_presentations["npc-01"]
	check(cursor.state == RoutineExecutor.State.SPEAKING,"17:30 reconstructed public speech")
	execution.present()
	check(visual.speech.visible and visual.speech.text == cursor.current_step().text,"only actual authored step text")
	check(visual.speech is Label3D and visual.speech.get_child_count() == 0,"world label contains no input/collision nodes")
	var before: Dictionary = SaveCodec.snapshot(game.session)
	for reason: String in ["pause","focus","modal","dialogue","travel","death"]:
		var remaining: float = cursor.remaining
		adapter.sync_visuals({reason:true},"",Vector3.ZERO)
		execution.tick(.1,true)
		check(cursor.remaining == remaining,"speech timer held "+reason)
		check(visual.speech.visible == (reason == "pause"),"speech visibility hold "+reason)
		adapter.sync_visuals({reason:false},"",Vector3.ZERO); execution.present()
		check(visual.speech.visible and visual.speech.text == cursor.current_step().text,"speech resumes same step "+reason)
	for frame: int in range(50):
		await step()
		if cursor.state != RoutineExecutor.State.SPEAKING: break
	await step()
	check(cursor.state == RoutineExecutor.State.ACTING and visual.speech.text.is_empty() and not visual.speech.visible,"bounded expiry clears text before action")
	check(SaveCodec.snapshot(game.session) == before,"speech/timing adds no item/fact/quest/event/save field")
	check(not JSON.stringify(execution.snapshot()).contains("quiet river"),"diagnostics never disclose text")

func _action(id: String, action: String, clip: String) -> void:
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	var cursor: RoutineExecutor = execution.actor(id)
	check(cursor != null,"actual actor "+id)
	if cursor == null: return
	# Explicit synthetic cursor selects existing authored step, never invents text.
	for index: int in range(cursor.steps.size()):
		if cursor.steps[index].action_id == action: cursor.index = index; break
	cursor.state = RoutineExecutor.State.ACTING; cursor.remaining = 8
	var p: NpcVisualPresenter = adapter.presenters[id]
	var visual: RoutinePresentation = adapter.routine_presentations[id]
	var model: Node3D = p.model
	var feet: Vector3 = adapter.targets[id].global_position
	var before: Dictionary = SaveCodec.snapshot(game.session)
	execution.present()
	check(p.model.scene_file_path == NpcRegistry.VISUAL_ASSETS[id] and p.active_action() == clip,"production explicit mapping "+id)
	check(not visual.fallback and (-p.basis.z).is_equal_approx(cursor.facing),"station facing "+id)
	for frame: int in range(100): execution.present()
	check(p.model == model and p.get_child_count() == 1,"unchanged presentation never remounts rig")
	for reason: String in ["pause","focus","modal","dialogue","travel","death"]:
		var remaining: float = cursor.remaining
		adapter.sync_visuals({reason:true},"",Vector3.ZERO); execution.tick(.1,true)
		var pose: PackedVector3Array = NpcAssetProbe.deformed_vertices(p)
		var time: float = p.player.current_animation_position
		await create_timer(.04).timeout
		check(cursor.remaining == remaining and p.suspended() and p.player.current_animation_position == time and NpcAssetProbe.deformed_vertices(p) == pose,"held timer and real pose "+reason+id)
		check(p.active_action() == (clip if reason in ["pause","focus"] else ""),"safe pose retention versus unsafe accessory cancellation "+reason)
		adapter.sync_visuals({reason:false},"",Vector3.ZERO); execution.present()
		check(not p.suspended() and p.active_action() == clip,"resume same active step "+reason)
	p.set_locomotion(2); execution.present()
	check(p.active_action().is_empty() and p.player.current_animation == "walk","cannot act while achieved motion nonzero")
	p.set_locomotion(0); execution.present()
	check(p.active_action() == clip,"stopped actor restores declared action")
	cursor.state = RoutineExecutor.State.CANCELLED; execution.present()
	check(p.active_action().is_empty() and not visual.speech.visible,"cancel leaves idle without prop/label")
	check(adapter.targets[id].global_position == feet and SaveCodec.snapshot(game.session) == before,"visual holds no feet/rewards/durable mutation")
	observations.append({"id":id,"clip":clip,"model":p.model.scene_file_path,"foot":feet,"fallback":visual.fallback})

func _fallback() -> void:
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	var presentation: RoutinePresentation = adapter.routine_presentations["npc-07"]
	var cursor: RoutineExecutor = execution.actor("npc-01")
	cursor.state = RoutineExecutor.State.ACTING
	presentation.sync(cursor,{})
	check(presentation.fallback and presentation.presenter.active_action().is_empty() and presentation.presenter.player.current_animation == "idle","unmapped optional declared action uses exported idle, no invented sheet")
	presentation.clear()

func _view_lane() -> void:
	# Retain/diagnose the first rendered fixture's full river approach.
	# This is a synthetic occupancy refusal, not a successful ambient journey.
	if execution != null: execution.dispose()
	if game != null: game.queue_free(); await process_frame
	if not await setup(1020): return
	game.player_placeholder.global_position = Vector3(13,0,-1)
	game.companion.global_position = Vector3(12,0,-1)
	game._sync_npc_visuals()
	for frame: int in range(4): await physics_frame
	var cursor: RoutineExecutor = execution.actor("npc-01")
	for frame: int in range(400):
		await step()
		if cursor.state in [RoutineExecutor.State.FAILED,RoutineExecutor.State.SPEAKING]: break
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	observations.append({"case":"original full river leg with ordinary stationary contacts","cursor":cursor.snapshot(),"movement":adapter.movers["npc-01"].failure,"blocker":adapter.movers["npc-01"].blocker,"hero":game.player_placeholder.global_position,"ally":game.companion.global_position})
	check(cursor.state == RoutineExecutor.State.FAILED and cursor.failure_detail.get("blocker","") == "npc-06","stationary Tess on navigation leg causes typed bounded refusal; safe presentation remains inert")
	check(adapter.presenters["npc-01"].active_action().is_empty() and not adapter.routine_presentations["npc-01"].speech.visible,"failed movement publishes no false action/speech")

func _finish_r012() -> void:
	check(TestRunEvidence.write_json("routine-presentation.json",{"task":"R012","assertions":assertions,"failures":failures,"observations":observations,"provenance":"synthetic initial clocks/cursor/action/party cases; real wrappers, active holds, unload/dispose and negative full-leg occupancy; no ordinary schedule/native claim"}),"R012 evidence")
	paused = false
	if execution != null: execution.dispose()
	if game != null: game.queue_free()
	await process_frame
	for error: String in failures: push_error(error)
	print("R012 presentation %d assertions %d failures" % [assertions,failures.size()])
	quit(0 if failures.is_empty() else 1)
