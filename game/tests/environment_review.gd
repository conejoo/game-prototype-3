extends Node
## Explicit debug-only matrix controls. Detached session, isolated namespace,
## real forecast seeds, no forced sample or production save/load path.

const PHASES: Array[float] = [.05, .375, .625, .875]
const PHASE_NAMES: Array[String] = ["Day", "Dusk", "Night", "Dawn"]
var game: Node3D
var phase_index: int = 0
var condition: WeatherSchedule.Condition = WeatherSchedule.Condition.SUNNY
var banner: Label


func initialize(root_game: Node3D, review_namespace: String) -> PackedStringArray:
	if not OS.is_debug_build() or RegEx.create_from_string("^[A-Za-z0-9_-]{1,48}$").search(review_namespace) == null:
		return PackedStringArray(["review requires debug build and safe isolated namespace"])
	var candidate: SaveCodec.DecodeResult = SaveCodec.validate(SaveCodec.snapshot(root_game.session), root_game.catalog)
	if not candidate.errors.is_empty():
		return candidate.errors
	game = root_game
	game.session = candidate.session
	game.session.review_only = true
	game.save_repository = SaveRepository.new("user://environment-review/" + review_namespace + "/disabled.json")
	banner = Label.new()
	banner.name = "EnvironmentReviewBanner"
	banner.add_theme_font_size_override("font_size", 14)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "EnvironmentReviewPanel"
	# Keep the review marker beneath modal menus, which own their text/focus.
	panel.z_index = -1
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game.ui.get_node("Screen").add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	panel.offset_left = 24
	panel.offset_right = 560
	panel.offset_top = -170
	panel.offset_bottom = -120
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(.035, .055, .07, .94)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(banner)
	_update_banner()
	return PackedStringArray()


func apply_preset(phase: int, weather: WeatherSchedule.Condition) -> bool:
	if game == null or not game.session.review_only or not OS.is_debug_build() or phase < 0 or phase >= PHASES.size() or weather < 0 or weather > 3:
		return false
	if not game.get_tree().paused or game.world_host.transitioning or game.loading_save or game.retrying or game.dialogue.active() or game.journal_open or not game.window_focused:
		return false
	# Deterministic real periods, fully blended, at every requested phase.
	for seed: int in range(10000):
		var sample: WeatherSchedule.Sample = WeatherSchedule.new().sample(seed, 2, PHASES[phase])
		if sample.condition == weather and sample.transition_progress == 1.0:
			game.session.environment.day_index = 2
			game.session.environment.day_cycle_progress = PHASES[phase]
			game.session.environment.weather_seed = seed
			phase_index = phase
			condition = weather
			game._present_environment()
			_update_banner()
			return true
	return false


func handle_input(event: InputEvent) -> bool:
	if not event is InputEventKey or not event.pressed or event.echo:
		return false
	if event.keycode == KEY_F7:
		return apply_preset((phase_index + 1) % PHASES.size(), condition)
	if event.keycode == KEY_F8:
		return apply_preset(phase_index, ((int(condition) + 1) % 4) as WeatherSchedule.Condition)
	return false


func _update_banner() -> void:
	banner.text = "DEVELOPER REVIEW · Synthetic · Save/Load disabled\nPause: F7 phase / F8 weather · %s / %s" % [PHASE_NAMES[phase_index], WeatherConditionService.display_name(condition)]
