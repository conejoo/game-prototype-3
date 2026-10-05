class_name TestRunCapture
extends RefCounted
## Pause-gated real viewport capture. Caller declares setup provenance explicitly.

static func capture(game: Node3D, label: String, directory: String, kind: String, overlay: bool = false, note: String = "") -> Dictionary:
	if DisplayServer.get_name() == "headless":
		return {"ok":false, "error":"capture requires real renderer"}
	if kind not in ["debug-input", "synthetic"] or note.is_empty():
		return {"ok":false, "error":"capture requires explicit provenance and note"}
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[A-Za-z0-9_-]{1,96}$")
	if pattern.search(label) == null:
		return {"ok":false, "error":"invalid capture label"}
	var evidence_root: String = ProjectSettings.globalize_path("res://../docs/evidence/").replace("\\", "/").simplify_path().trim_suffix("/")
	var absolute: String = directory.replace("\\", "/").simplify_path().trim_suffix("/")
	if not absolute.begins_with(evidence_root + "/"):
		return {"ok":false, "error":"capture directory outside project evidence"}
	var tree: SceneTree = game.get_tree()
	if not tree.paused or not game.ui.pause_overlay.visible:
		return {"ok":false, "error":"capture lacks verified pause overlay"}
	var path: String = absolute.path_join(label + ".png")
	if FileAccess.file_exists(path):
		return {"ok":false, "error":"capture would overwrite evidence"}
	if DirAccess.make_dir_recursive_absolute(absolute) != OK:
		return {"ok":false, "error":"cannot create capture directory"}
	if not overlay:
		game.ui.show_paused(false)
	for frame: int in range(4):
		await tree.process_frame
	await RenderingServer.frame_post_draw
	# Recheck after rendering awaits: another capture or input may have intervened.
	if not tree.paused or FileAccess.file_exists(path):
		game.ui.show_paused(true)
		return {"ok":false, "error":"pause changed or capture path already exists"}
	var image: Image = tree.root.get_texture().get_image()
	var error: Error = image.save_png(path)
	game.ui.show_paused(true)
	if error != OK:
		return {"ok":false, "error":"PNG failed: " + str(error)}
	return {"ok":true, "label":label, "path":path, "kind":kind, "note":note,
		"paused":tree.paused, "pause_overlay_verified":true, "overlay":overlay,
		"engine_pid":OS.get_process_id(), "engine":Engine.get_version_info()["string"],
		"viewport_size":[image.get_width(), image.get_height()], "camera":TestRunObservation.camera(game),
		"position":TestRunObservation.vector(game.player_placeholder.global_position),
		"location":game.session.current_location_id, "snapshot":SaveCodec.snapshot(game.session),
		"prompt":game.ui.travel_label.text, "environment":TestRunObservation.environment(game)}
