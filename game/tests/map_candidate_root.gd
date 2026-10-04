extends "res://app/game_root.gd"
## Explicit alternate scene only; candidate never enters the production catalog.


func _ready() -> void:
	var detached: ContentManifest = ContentManifest.new()
	detached.definitions.assign(content_manifest.definitions)
	detached.definitions.append(preload("res://tests/fixtures/map_candidate_location.tres"))
	content_manifest = detached
	initial_location_id = "candidate-alderwake"
	initial_spawn_id = "alderwake-from-tollworks" if "--candidate-return" in OS.get_cmdline_user_args() else "alderwake-start"
	save_repository = SaveRepository.new("user://saves/playtest-map-candidate.json")
	await super._ready()
	# Limit wall snap, then resolve fast downhill contacts against actual
	# nearby walkable physics and full capsule clearance. Normal rooms opt out.
	for actor: ActorPlaceholder in party.members():
		actor.floor_snap_length = 0.04
		actor.floor_contact_height = _candidate_floor_height.bind(actor)
	ui.get_node("Screen/Header/Margin/Row/Titles/Title").text = "ALDERWAKE · TERRAIN CANDIDATE"
	ui.location_label.text = "M010 isolated preview · Companion recovery · No active portals"
	ui.journal_button.visible = false
	print("M010 candidate ready: ", JSON.stringify(world_host.current_location.preview_report))
	if "--candidate-paused" in OS.get_cmdline_user_args():
		_set_paused(true)


func _refresh_journal() -> void:
	ui.show_objective("M010 · Companion follow and safe recovery · Cliffs and water blocked.\nAll doors inactive · Maris pad reserved · East trail closed")


func _refresh_interaction() -> void:
	selected_interaction = null
	if is_instance_valid(player_placeholder):
		ui.show_travel("Candidate feet X %.2f · Z %.2f · Bounds X [-22,125), Z [-18,62)" % [player_placeholder.global_position.x, player_placeholder.global_position.z])


func _toggle_journal() -> void:
	pass


func _candidate_floor_height(feet: Vector3, actor: ActorPlaceholder) -> float:
	if not world_host.current_location is AlderwakeTerrainPreview:
		return NAN
	var space: PhysicsDirectSpaceState3D = actor.get_world_3d().direct_space_state
	var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(feet + Vector3.UP * 0.11, feet + Vector3.DOWN * 0.11, 1))
	if hit.is_empty() or hit.normal.y < 0.96 or not hit.collider.has_meta("candidate_walkable_floor"):
		return NAN
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = actor.get_node("CollisionShape3D").shape
	query.transform.origin = Vector3(feet.x, hit.position.y + 0.82, feet.z)
	query.collision_mask = 1
	return float(hit.position.y) if space.intersect_shape(query).is_empty() else NAN
