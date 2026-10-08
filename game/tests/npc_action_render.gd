extends SceneTree
## Rendered synthetic review only; manually frozen sampled poses are labeled.
var stage: Node3D
var captures: Array[Dictionary] = []
var failures: PackedStringArray = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	stage=load("res://tests/review/npc_action_review.tscn").instantiate(); root.add_child(stage)
	failures.append_array(stage.errors)
	if failures.is_empty():
		for p: NpcVisualPresenter in stage.presenters: p.player.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		for light: String in ["day","night"]:
			stage.set_light(light)
			for mode: String in ["idle","walk","action"]:
				for fraction: float in [0.0,.25,.5,.75]:
					stage.set_sample(mode,fraction*(.8 if mode=="walk" else 4))
					stage.label_frame("%s / %s / phase %.2f / sampled exported pose" % [light,mode,fraction])
					await _capture("%s-%s-%02d" % [light,mode,roundi(fraction*100)])
			# Real mixer transitions under both studio lights.
			stage.set_sample("idle",0)
			for p: NpcVisualPresenter in stage.presenters: p.set_action(stage.ACTIONS[stage.presenters.find(p)])
			for frame: int in range(16):
				for p: NpcVisualPresenter in stage.presenters: p.player.advance(1.0/120)
				if frame in [0,3,7,11,15]:
					stage.label_frame("%s / real idle-to-action blend / %.3fs" % [light,float(frame+1)/120])
					await _capture("%s-enter-%02d" % [light,frame])
			for p: NpcVisualPresenter in stage.presenters: p.suspend("pause")
			stage.label_frame(light+" / paused action / exact pose frozen; props retained")
			await _capture(light+"-paused")
			for p: NpcVisualPresenter in stage.presenters: p.resume("pause"); p.suspend("dialogue"); p.resume("dialogue")
			for frame: int in range(16):
				for p: NpcVisualPresenter in stage.presenters: p.player.advance(1.0/120)
				if frame in [0,7,15]:
					stage.label_frame("%s / dialogue cancels action / props hidden / blend step %d" % [light,frame])
					await _capture("%s-interrupt-%02d" % [light,frame])
		stage.set_light("day")
		for view: String in ["profile","back","overhead"]:
			stage.set_view(view); stage.set_sample("action",2)
			stage.label_frame(view+" / action phase .50 / source accessories and grounded feet")
			await _capture(view)
	if not TestRunEvidence.write_json("npc-action-captures.json",{"captures":captures,"failures":failures,"provenance":"synthetic standalone Compatibility review; manual AnimationPlayer sampling and real mixer blends; no gameplay input"}): failures.append("capture index write")
	stage.queue_free(); await process_frame
	for failure: String in failures: push_error(failure)
	print("N016 rendered actions: ","PASS" if failures.is_empty() else "FAIL"," captures=",captures.size())
	quit(0 if failures.is_empty() else 1)

func _capture(label: String) -> void:
	for frame: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var path: String=TestRunEvidence.path(label+".png")
	var error: Error=root.get_texture().get_image().save_png(path)
	if error!=OK: failures.append("save capture "+label)
	captures.append({"path":path,"label":label,"width":root.get_texture().get_width(),"height":root.get_texture().get_height(),"pid":OS.get_process_id(),"manual_review":true,"frame_post_draw":true,"error":error})
