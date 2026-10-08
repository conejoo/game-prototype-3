extends SceneTree
## Actual Compatibility framebuffer captures and eight-rig timing observation.
var stage: Node3D
var captures: Array[Dictionary] = []
var failures: PackedStringArray = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	stage = load("res://tests/review/npc_asset_review.tscn").instantiate()
	root.add_child(stage)
	if not stage.errors.is_empty(): failures.append_array(stage.errors)
	else:
		for light: String in ["day","night"]:
			stage.set_light(light)
			for clip: String in ["idle","walk"]:
				for fraction: float in [0.0,.25,.5,.75]:
					var seconds: float = fraction*(4.0 if clip == "idle" else .8)
					stage.set_sample(clip,seconds)
					stage.label_frame("%s / %s / t=%.2fs / eight exported rigs" % [light,clip,seconds])
					await _capture("%s-%s-%02d" % [light,clip,roundi(fraction*100)],clip,seconds,light,"front")
		stage.set_light("day")
		for view: String in ["profile","close","overhead"]:
			stage.set_view(view)
			stage.set_sample("walk",.2)
			stage.label_frame("%s / walk .20s / %s" % [view,"actual default gameplay camera scale" if view == "overhead" else "side silhouette and planted sole"])
			await _capture(view,"walk",.2,"day",view)
		stage.set_view("front")
		stage.set_sample("idle",0)
		for p: NpcVisualPresenter in stage.presenters: p.set_locomotion(.8)
		for i: int in range(16):
			for p: NpcVisualPresenter in stage.presenters: p.player.advance(1.0/120)
			if i in [0,3,7,11,15]:
				stage.label_frame("idle to walk / real 0.12s blend / step %d" % i)
				await _capture("transition-%02d" % i,"idle-to-walk",float(i+1)/120,"day","front")
		for p: NpcVisualPresenter in stage.presenters:
			p.suspend("pause")
			p.player.advance(5)
		stage.label_frame("Suspended exported pose / pause hold / no drift")
		await _capture("paused","suspended",5,"day","front")
		for p: NpcVisualPresenter in stage.presenters: p.resume("pause")
		# Timing is an observed review-scene estimate, not a map FPS guarantee.
		var samples: PackedFloat64Array = []
		for i: int in range(120):
			var start: int = Time.get_ticks_usec()
			for p: NpcVisualPresenter in stage.presenters: p.player.advance(1.0/60)
			await process_frame
			await RenderingServer.frame_post_draw
			samples.append(float(Time.get_ticks_usec()-start)/1000)
		samples.sort()
		var measurement: Dictionary = {"actors":8,"frames":120,"median_frame_wall_ms":samples[60],"p95_frame_wall_ms":samples[114],"rendering_method":RenderingServer.get_current_rendering_method(),"note":"Review scene timing, includes frame scheduling/vsync; not baseline-map performance acceptance"}
		if not TestRunEvidence.write_json("eight-rig-timing.json",measurement): failures.append("timing evidence write")
	if not TestRunEvidence.write_json("npc-render-captures.json",{"captures":captures,"failures":failures,"provenance":"exported GLB + manual AnimationPlayer advance; synthetic review fixture"}): failures.append("capture index write")
	stage.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("N007 rendered review: ","PASS" if failures.is_empty() else "FAIL"," captures=",captures.size())
	quit(0 if failures.is_empty() else 1)

func _capture(label: String, clip: String, seconds: float, light: String, view: String) -> void:
	for frame: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var path: String = TestRunEvidence.path(label + ".png")
	var error: Error = root.get_texture().get_image().save_png(path)
	if error != OK: failures.append("save capture " + label)
	captures.append({"path":path,"label":label,"clip":clip,"seconds":seconds,"light":light,"view":view,"width":root.get_texture().get_width(),"height":root.get_texture().get_height(),"pid":OS.get_process_id(),"error":error})
