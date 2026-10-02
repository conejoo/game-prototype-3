class_name PrototypeUI
extends CanvasLayer
## Displays state and submits commands; GameRoot owns pause/session changes.

signal pause_requested
signal resume_requested
signal quit_requested
signal save_requested
signal load_requested
signal dialogue_advance_requested
signal dialogue_choice_requested(choice_id: String)
signal dialogue_cancel_requested

@onready var pause_overlay: Control = $Screen/PauseOverlay
@onready var resume_button: Button = $Screen/PauseOverlay/Center/Panel/Margin/Options/Resume
@onready var pause_button: Button = $Screen/Header/Margin/Row/Pause
@onready var time_label: Label = $Screen/Header/Margin/Row/PlayTime
@onready var camera_label: Label = $Screen/Footer/Margin/Text
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


func _ready() -> void:
	dialogue_next.pressed.connect(func() -> void: dialogue_advance_requested.emit())
	dialogue_close.pressed.connect(func() -> void: dialogue_cancel_requested.emit())
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	save_button.pressed.connect(func() -> void: save_requested.emit())
	load_button.pressed.connect(func() -> void: load_requested.emit())
	$Screen/PauseOverlay/Center/Panel/Margin/Options/Quit.pressed.connect(
		func() -> void: quit_requested.emit()
	)


func show_paused(paused: bool) -> void:
	pause_overlay.visible = paused
	travel_label.visible = not paused and not dialogue_overlay.visible
	pause_button.disabled = paused
	if paused:
		resume_button.grab_focus()
	else:
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused != null:
			focused.release_focus()


func show_play_time(seconds: float) -> void:
	time_label.text = "Play time %03ds" % int(seconds)


func accepts_world_pointer(point: Vector2) -> bool:
	return (
		not pause_overlay.visible
		and not dialogue_overlay.visible
		and not $Screen/Header.get_global_rect().has_point(point)
		and not $Screen/Footer.get_global_rect().has_point(point)
		and $Screen.get_global_rect().has_point(point)
	)


func show_camera(description: String) -> void:
	camera_label.text = "WASD: move · Mouse: face · E: interact / travel · Wheel / +/-: zoom\n%s · P: projection · Esc: close dialogue / pause · F10: quit" % description


func show_location(description: String) -> void:
	location_label.text = "P006 / " + description


func show_travel(message: String) -> void:
	travel_label.text = message


func set_save_busy(busy: bool) -> void:
	save_button.disabled = busy
	load_button.disabled = busy
	resume_button.disabled = busy


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
	travel_label.visible = not service.active() and not pause_overlay.visible
	pause_button.disabled = pause_overlay.visible or service.active()
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
	if service.awaiting_choice():
		for choice: DialogueChoice in service.definition.choices:
			var button: Button = Button.new()
			button.name = choice.stable_id
			button.text = choice.label
			button.custom_minimum_size.y = 44
			button.pressed.connect(func() -> void: dialogue_choice_requested.emit(choice.stable_id))
			dialogue_choices.add_child(button)
		(dialogue_choices.get_child(0) as Button).grab_focus()
	else:
		dialogue_next.grab_focus()
