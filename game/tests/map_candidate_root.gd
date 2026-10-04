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
	ui.get_node("Screen/Header/Margin/Row/Titles/Title").text = "ALDERWAKE · TERRAIN CANDIDATE"
	ui.location_label.text = "M014 isolated landmark kit · No active portals"
	ui.journal_button.visible = false
	print("M014 candidate ready: ", JSON.stringify(world_host.current_location.preview_report))
	if "--candidate-paused" in OS.get_cmdline_user_args():
		_set_paused(true)


func _refresh_journal() -> void:
	ui.show_objective("M014 · Bridge, Moonwell, closed gate · Cliffs and water blocked.\nAll doors inactive · Maris pad reserved · East trail closed")


func _refresh_interaction() -> void:
	selected_interaction = null
	if is_instance_valid(player_placeholder):
		ui.show_travel("Candidate feet X %.2f · Z %.2f · Bounds X [-22,125), Z [-18,62)" % [player_placeholder.global_position.x, player_placeholder.global_position.z])


func _toggle_journal() -> void:
	pass
