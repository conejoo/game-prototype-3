extends "res://tests/fishing_targeting_checks.gd"
## Paused synthetic presenter samples. No rod/input activation or actual cast.
var views: Array[Dictionary] = []
var observations: Array[Dictionary] = []

func _run() -> void:
	if await _startup():
		for orthographic: bool in [true,false]:
			for zoom_value: float in [.8,1.0,1.15]:
				game.camera_rig.zoom_factor = zoom_value
				game.camera_rig.set_orthographic(orthographic)
				await _sample("dock-%s-%s" % ["ortho" if orthographic else "perspective",str(zoom_value).replace(".","_")],SITES[0].foot,SITES[0].point,"eligible")
			game.camera_rig.zoom_factor = 1.15
			game.camera_rig.set_orthographic(orthographic)
			for site: Dictionary in SITES.slice(1):
				await _sample(site.id+"-"+("ortho" if orthographic else "perspective"),site.foot,site.point,"eligible")
		game.camera_rig.zoom_factor = 1
		game.camera_rig.set_orthographic(true)
		await _sample("no-area",SITES[0].foot,Vector3(-12.75,.015,20.25),"no_area")
		await _sample("dry-deck",SITES[0].foot,Vector3(-6.75,.015,18.25),"dry_structure")
		await _sample("dry-bank",SITES[1].foot,Vector3(10.25,.015,13.25),"dry_land")
		await _sample("dry-bridge",Vector3(94,0,-.5),Vector3(98.25,.015,-.25),"dry_structure")
		_pose(SITES[0].foot)
		var pointer: Vector2 = game.camera_rig.camera.unproject_position(SITES[0].point)
		var obstacle: StaticBody3D = _box(SITES[0].point-game.camera_rig.camera.project_ray_normal(pointer)*.8,Vector3(.5,.5,.5))
		await physics_frame
		await _sample("solid-blocked",SITES[0].foot,SITES[0].point,"solid_occlusion")
		obstacle.queue_free()
		await physics_frame
		preview.clear()
		_check(not preview.visible, "preview teardown before final pause checkpoint")
		var captured: Dictionary = await TestRunCapture.capture(game,"final-pause",TestRunEvidence.directory(),"synthetic",true,"FS004 synthetic pose/camera samples; preview cleared. Actual pause overlay verified; no active attempt, cast, reward or movement claim.")
		_check(captured.ok,captured.get("error","final capture"))
		if captured.ok: views.append(captured)
		_check(TestRunEvidence.write_json("preview-index.json", {"task":"FS004", "proof":"synthetic paused camera/player/pointer fixtures displaying real preview against production water/decks/banks; not activated fishing or ordinary movement", "assertions":assertions+1,"failures":failures,"views":views,"observations":observations}), "render evidence write")
	await _finish()

func _sample(label: String, foot: Vector3, point: Vector3, expected: String) -> void:
	_pose(foot)
	game.ui.show_camera(game.camera_rig.description())
	var camera: Camera3D = game.camera_rig.camera
	var pointer: Vector2 = camera.unproject_position(point)
	# Only this isolated paused render fixture supplies world pointer permission.
	# Production UI pause rejection and fresh cast revalidation are tested headless.
	var result: FishingWaterTargetResolver.Result = preview.refresh(room,game.catalog,camera,pointer,foot,true,rod)
	_check(result.status == expected or result.reason == expected, "render target " + label + " " + result.reason)
	_check(preview.visible and preview.caption.text != "", "real visible preview " + label)
	game.ui.pause_overlay.visible = false
	var world_ui_allows: bool = game.ui.accepts_world_pointer(pointer)
	game.ui.pause_overlay.visible = true
	_check(world_ui_allows, "sample in actual world pointer area after removing pause overlay " + label + " " + str(pointer))
	var captured: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",false,"FS004 paused synthetic player/camera/pointer pose, snapshot-only target preview. No fishing activation or RNG; geometry permission explicit only in this fixture.")
	_check(captured.ok,captured.get("error","preview capture"))
	if captured.ok: views.append(captured)
	observations.append({"label":label, "pointer":pointer, "world_ui_allows":world_ui_allows, "target":result.snapshot(), "caption":preview.caption.text})
