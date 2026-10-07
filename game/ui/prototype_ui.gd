class_name PrototypeUI
extends CanvasLayer
## Displays state and submits commands; GameRoot owns pause/session changes.

signal backpack_requested
signal inventory_selection_requested(item_id: Variant)
signal pause_requested
signal resume_requested
signal quit_requested
signal save_requested
signal load_requested
signal dialogue_advance_requested
signal dialogue_choice_requested(choice_id: String)
signal dialogue_cancel_requested
signal journal_requested
signal upgrade_requested
signal debug_mode_requested(enabled: bool)

@onready var pause_overlay: Control = $Screen/PauseOverlay
@onready var resume_button: Button = $Screen/PauseOverlay/Center/Panel/Margin/Options/Resume
@onready var pause_button: Button = $Screen/Header/Margin/Row/Pause
@onready var time_label: Label = $Screen/Header/Margin/Row/PlayTime
@onready var camera_label: Label = $Screen/Footer/Margin/TextBox/Text
@onready var location_label: Label = $Screen/Header/Margin/Row/Titles/Subtitle
@onready var travel_label: Label = $Screen/TravelPrompt
@onready var save_button: Button = $Screen/PauseOverlay/Center/Panel/Margin/Options/Save
@onready var load_button: Button = $Screen/PauseOverlay/Center/Panel/Margin/Options/Load
@onready var save_status: Label = $Screen/PauseOverlay/Center/Panel/Margin/Options/SaveStatus
@onready var dialogue_overlay: Control = $Screen/DialogueOverlay
@onready var dialogue_panel: PanelContainer = $Screen/DialogueOverlay/Center/Panel
@onready var dialogue_title: Label = $Screen/DialogueOverlay/Center/Panel/Margin/Options/Title
@onready var dialogue_text: Label = $Screen/DialogueOverlay/Center/Panel/Margin/Options/Text
@onready var dialogue_choices: VBoxContainer = $Screen/DialogueOverlay/Center/Panel/Margin/Options/Choices
@onready var dialogue_next: Button = $Screen/DialogueOverlay/Center/Panel/Margin/Options/Next
@onready var dialogue_close: Button = $Screen/DialogueOverlay/Center/Panel/Margin/Options/Close
@onready var dialogue_status: Label = $Screen/DialogueOverlay/Center/Panel/Margin/Options/Status
@onready var journal_overlay: Control = $Screen/JournalOverlay
@onready var journal_panel: PanelContainer = $Screen/JournalOverlay/Center/Panel
@onready var journal_text: Label = $Screen/JournalOverlay/Center/Panel/Margin/Options/Scroll/Text
@onready var journal_close: Button = $Screen/JournalOverlay/Center/Panel/Margin/Options/Close
@onready var journal_button: Button = $Screen/Header/Margin/Row/Journal
@onready var objective_label: Label = $Screen/Objective

@onready var upgrade_button: Button = $Screen/JournalOverlay/Center/Panel/Margin/Options/Upgrade
@onready var upgrade_status: Label = $Screen/JournalOverlay/Center/Panel/Margin/Options/UpgradeStatus
@onready var pause_options: VBoxContainer = $Screen/PauseOverlay/Center/Panel/Margin/Options
@onready var settings_options: VBoxContainer = $Screen/PauseOverlay/Center/Panel/Margin/SettingsOptions
@onready var settings_button: Button = $Screen/PauseOverlay/Center/Panel/Margin/Options/Settings
@onready var fps_toggle: CheckButton = $Screen/PauseOverlay/Center/Panel/Margin/SettingsOptions/ShowFPS
@onready var debug_toggle: CheckButton = $Screen/PauseOverlay/Center/Panel/Margin/SettingsOptions/DebugMode
@onready var settings_back: Button = $Screen/PauseOverlay/Center/Panel/Margin/SettingsOptions/Back
@onready var fps_label: Label = $Screen/Diagnostics/FPS
@onready var debug_label: Label = $Screen/Diagnostics/Debug

var _fps_sample_seconds: float = 0.0
var gather_progress: ProgressBar
var backpack: BackpackView
var backpack_button: Button
var active_item_label: Label


func _ready() -> void:
	backpack_button = Button.new()
	backpack_button.name = "Backpack"
	backpack_button.text = "Bag [B]"
	backpack_button.custom_minimum_size = Vector2(86,40)
	backpack_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	$Screen/Header/Margin/Row.add_child(backpack_button)
	backpack_button.pressed.connect(func() -> void: backpack_requested.emit())
	active_item_label = Label.new()
	active_item_label.name = "ActiveItem"
	active_item_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	active_item_label.add_theme_font_size_override("font_size",14)
	$Screen/Footer/Margin/TextBox.add_child(active_item_label)
	$Screen/Footer.offset_top = -130
	backpack = preload("res://ui/backpack_view.gd").new()
	backpack.name = "BackpackOverlay"
	$Screen.add_child(backpack)
	backpack.selection_requested.connect(func(id: Variant) -> void: inventory_selection_requested.emit(id))
	backpack.close_requested.connect(func() -> void: backpack_requested.emit())
	gather_progress = ProgressBar.new()
	gather_progress.name = "GatherProgress"
	gather_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gather_progress.show_percentage = false
	gather_progress.max_value = 1.0
	$Screen.add_child(gather_progress)
	gather_progress.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	gather_progress.offset_left = -150
	gather_progress.offset_right = 150
	gather_progress.offset_top = -162
	gather_progress.offset_bottom = -146
	gather_progress.hide()
	settings_button.pressed.connect(func() -> void: show_settings(true))
	settings_back.pressed.connect(func() -> void: show_settings(false))
	fps_toggle.toggled.connect(_show_fps)
	debug_toggle.toggled.connect(func(enabled: bool) -> void: debug_mode_requested.emit(enabled))
	_set_focus_cycle([fps_toggle, debug_toggle, settings_back])
	upgrade_button.pressed.connect(func() -> void: upgrade_requested.emit())
	journal_button.pressed.connect(func() -> void: journal_requested.emit())
	journal_close.pressed.connect(func() -> void: journal_requested.emit())
	dialogue_next.pressed.connect(func() -> void: dialogue_advance_requested.emit())
	dialogue_close.pressed.connect(func() -> void: dialogue_cancel_requested.emit())
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	save_button.pressed.connect(func() -> void: save_requested.emit())
	load_button.pressed.connect(func() -> void: load_requested.emit())
	$Screen/PauseOverlay/Center/Panel/Margin/Options/Quit.pressed.connect(
		func() -> void: quit_requested.emit()
	)


func show_inventory(snapshot: InventorySnapshot, catalog: ContentCatalog) -> void:
	backpack.present(snapshot,catalog)
	if snapshot.active_item_id == null:
		active_item_label.text = "Active item: none · B: backpack"
	else:
		var item: ItemDefinition = catalog.get_item(snapshot.active_item_id)
		active_item_label.text = ("Active tool: " if item.is_tool() else "Selected item: ") + item.display_name + (" · Fishing unavailable" if item.is_tool() else " · No direct use")
	backpack_button.disabled = pause_overlay.visible or dialogue_overlay.visible or journal_overlay.visible or backpack.visible


func show_foraging_progress(progress: float, active: bool) -> void:
	gather_progress.visible = active
	gather_progress.value = progress


func show_paused(paused: bool) -> void:
	settings_options.hide()
	pause_options.show()
	pause_overlay.visible = paused
	travel_label.visible = not paused and not dialogue_overlay.visible
	pause_button.disabled = paused
	journal_button.disabled = paused or dialogue_overlay.visible
	if paused:
		_refresh_pause_focus()
		resume_button.grab_focus()
	else:
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused != null:
			focused.release_focus()


func _process(delta: float) -> void:
	if not fps_label.visible:
		return
	_fps_sample_seconds += delta
	if _fps_sample_seconds >= 0.25:
		_fps_sample_seconds = 0.0
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()


func _show_fps(enabled: bool) -> void:
	fps_label.visible = enabled
	fps_toggle.set_pressed_no_signal(enabled)
	_fps_sample_seconds = 0.0
	if enabled:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()


func show_debug_mode(enabled: bool) -> void:
	debug_toggle.set_pressed_no_signal(enabled)
	debug_label.visible = enabled


func show_debug_time(progress: float) -> void:
	if debug_label.visible:
		debug_label.text = "Debug · F6: +1 hour · " + EnvironmentClock.format_time(progress)


func settings_open() -> bool:
	return pause_overlay.visible and settings_options.visible


func show_settings(open: bool) -> void:
	if not pause_overlay.visible:
		return
	pause_options.visible = not open
	settings_options.visible = open
	if open:
		fps_toggle.grab_focus()
	else:
		_refresh_pause_focus()
		settings_button.grab_focus()


func _set_focus_cycle(buttons: Array[Button]) -> void:
	for index: int in range(buttons.size()):
		buttons[index].focus_next = buttons[index].get_path_to(buttons[(index + 1) % buttons.size()])
		buttons[index].focus_previous = buttons[index].get_path_to(buttons[(index + buttons.size() - 1) % buttons.size()])


func _refresh_pause_focus() -> void:
	var buttons: Array[Button] = []
	for child: Node in pause_options.get_children():
		if child is Button and not child.disabled and child.visible:
			buttons.append(child)
	_set_focus_cycle(buttons)


func show_play_time(seconds: float) -> void:
	time_label.tooltip_text = "Active play: %ds" % int(seconds)


func show_environment(progress: float, condition: WeatherSchedule.Condition) -> void:
	time_label.text = EnvironmentClock.format_time(progress) + "\n" + WeatherConditionService.display_name(condition)


func accepts_world_pointer(point: Vector2) -> bool:
	return (
		not backpack.visible and not pause_overlay.visible
		and not journal_overlay.visible
		and not dialogue_overlay.visible
		and not $Screen/Header.get_global_rect().has_point(point)
		and not $Screen/Footer.get_global_rect().has_point(point)
		and $Screen.get_global_rect().has_point(point)
	)


func show_camera(description: String) -> void:
	camera_label.text = "WASD: move · Mouse: face / click attack · Space: dodge · E: interact · B: backpack · J: journal\n%s · Wheel / +/-: zoom · P: projection · Esc: pause · F10: quit" % description


func show_location(description: String) -> void:
	location_label.text = "Recovery slice · " + description


func show_companion(actor: ActorState, mode: String, trust: int = 0) -> void:
	$Screen/Footer/Margin/TextBox/CompanionStatus.text = "Temporary companion (prototype) · %d/%d · Trust %d · %s" % [actor.health, actor.max_health, trust, "Down — recovers 3s after combat" if actor.health == 0 else mode.capitalize()]


func show_combat(actor: ActorState, guardian: ActorPlaceholder, retrying: bool, damage: int = 25) -> void:
	$Screen/CombatStatus.visible = not backpack.visible and not pause_overlay.visible and not dialogue_overlay.visible and not journal_overlay.visible
	var message: String = "Hero %d / %d · Strike %d" % [actor.health, actor.max_health, damage]
	if actor.health == 0:
		message = "DEFEATED · R: retry at arrival anchor (quest progress kept)"
	elif is_instance_valid(guardian):
		message += " · Guardian %d / %d" % [guardian.state.health, guardian.state.max_health]
		if guardian.state.health == 0:
			message += " · CLEARED"
		elif guardian.combat.attacking:
			message += " · " + ("STRIKE!" if guardian.combat.active() else ("Gold windup — dodge!" if guardian.combat.elapsed < guardian.combat.windup else "Recovering"))
		else:
			message += " · Approaching"
	if retrying:
		message = "Retrying…"
	$Screen/CombatStatus.text = message


func show_travel(message: String) -> void:
	travel_label.text = message


func set_save_busy(busy: bool, block_resume: bool = false) -> void:
	var changed: bool = save_button.disabled != busy or load_button.disabled != busy or resume_button.disabled != block_resume
	save_button.disabled = busy
	load_button.disabled = busy
	resume_button.disabled = block_resume
	if changed:
		_refresh_pause_focus()


func show_save_status(message: String) -> void:
	save_status.text = message


func dialogue_accepts_pointer(point: Vector2) -> bool:
	return dialogue_overlay.visible and dialogue_panel.get_global_rect().has_point(point)


func show_dialogue(service: DialogueService, result: DialogueService.ActionResult) -> void:
	var was_visible: bool = dialogue_overlay.visible
	for child: Node in dialogue_choices.get_children():
		dialogue_choices.remove_child(child)
		child.queue_free()
	dialogue_overlay.visible = service.active()
	travel_label.visible = not service.active() and not backpack.visible and not pause_overlay.visible
	pause_button.disabled = pause_overlay.visible or service.active()
	journal_button.disabled = pause_overlay.visible or service.active()
	if not service.active():
		if was_visible:
			var focused: Control = get_viewport().gui_get_focus_owner()
			if focused != null:
				focused.release_focus()
		return
	dialogue_title.text = service.definition.display_name
	dialogue_text.text = service.current_lines()[service.line_index]
	dialogue_status.text = result.message
	dialogue_next.visible = not service.awaiting_choice()
	dialogue_next.text = "Continue" if service.line_index + 1 < service.current_lines().size() else "Finish"
	var focus_buttons: Array[Button] = []
	if service.awaiting_choice():
		for choice: DialogueChoice in service.definition.choices:
			var button: Button = Button.new()
			button.name = choice.stable_id
			button.text = choice.label
			button.custom_minimum_size.y = 44
			button.pressed.connect(func() -> void: dialogue_choice_requested.emit(choice.stable_id))
			dialogue_choices.add_child(button)
			focus_buttons.append(button)
		(dialogue_choices.get_child(0) as Button).grab_focus()
	else:
		focus_buttons.append(dialogue_next)
		dialogue_next.grab_focus()
	focus_buttons.append(dialogue_close)
	for index: int in range(focus_buttons.size()):
		var button: Button = focus_buttons[index]
		button.focus_next = button.get_path_to(focus_buttons[(index + 1) % focus_buttons.size()])
		button.focus_previous = button.get_path_to(focus_buttons[(index + focus_buttons.size() - 1) % focus_buttons.size()])


func show_objective(text: String) -> void:
	objective_label.text = "Quest · " + text


func show_journal(open: bool, text: String) -> void:
	journal_overlay.visible = open
	journal_text.text = text
	travel_label.visible = not open and not dialogue_overlay.visible and not backpack.visible and not pause_overlay.visible
	pause_button.disabled = open or pause_overlay.visible or dialogue_overlay.visible
	if open:
		journal_close.grab_focus()
	else:
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused != null and journal_panel.is_ancestor_of(focused):
			focused.release_focus()


func show_upgrade(service: ProgressionService) -> void:
	var selected: bool = ProgressionService.UPGRADE_ID in service.session.progression.upgrade_ids
	upgrade_button.disabled = selected or service.available_points() < 1
	upgrade_button.text = "Deliberate Strike selected · damage 40" if selected else "Spend 1 preparation point: Deliberate Strike (+15 damage)"
	upgrade_status.text = "Preparation complete · Deliberate Strike: 25 → 40 damage (prototype training)." if selected else "Preparation points: %d · %s" % [service.available_points(), "Select below before entering Tollworks." if service.available_points() > 0 else "Accept Maris's lead to earn 1. Prototype training."]
	var buttons: Array[Button] = []
	if not upgrade_button.disabled:
		buttons.append(upgrade_button)
	buttons.append(journal_close)
	for index: int in range(buttons.size()):
		buttons[index].focus_next = buttons[index].get_path_to(buttons[(index + 1) % buttons.size()])
		buttons[index].focus_previous = buttons[index].get_path_to(buttons[(index + buttons.size() - 1) % buttons.size()])
