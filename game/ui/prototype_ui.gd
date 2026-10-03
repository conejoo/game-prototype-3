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
signal journal_requested

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
@onready var journal_overlay: Control = $Screen/JournalOverlay
@onready var journal_panel: PanelContainer = $Screen/JournalOverlay/Center/Panel
@onready var journal_text: Label = $Screen/JournalOverlay/Center/Panel/Margin/Options/Text
@onready var journal_close: Button = $Screen/JournalOverlay/Center/Panel/Margin/Options/Close
@onready var journal_button: Button = $Screen/Header/Margin/Row/Journal
@onready var objective_label: Label = $Screen/Objective


func _ready() -> void:
	journal_close.focus_next = NodePath(".")
	journal_close.focus_previous = NodePath(".")
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


func show_paused(paused: bool) -> void:
	pause_overlay.visible = paused
	travel_label.visible = not paused and not dialogue_overlay.visible
	pause_button.disabled = paused
	journal_button.disabled = paused or dialogue_overlay.visible
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
		and not journal_overlay.visible
		and not dialogue_overlay.visible
		and not $Screen/Header.get_global_rect().has_point(point)
		and not $Screen/Footer.get_global_rect().has_point(point)
		and $Screen.get_global_rect().has_point(point)
	)


func show_camera(description: String) -> void:
	camera_label.text = "WASD: move · Mouse: face / click attack · Space: dodge · E: interact · J: journal\n%s · Wheel / +/-: zoom · P: projection · Esc: pause · F10: quit" % description


func show_location(description: String) -> void:
	location_label.text = "P008 / " + description


func show_combat(actor: ActorState, guardian: ActorPlaceholder, retrying: bool) -> void:
	$Screen/CombatStatus.visible = not pause_overlay.visible and not dialogue_overlay.visible and not journal_overlay.visible
	var message: String = "Hero %d / %d" % [actor.health, actor.max_health]
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
	save_button.disabled = busy
	load_button.disabled = busy
	resume_button.disabled = block_resume


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
	travel_label.visible = not open and not dialogue_overlay.visible and not pause_overlay.visible
	pause_button.disabled = open or pause_overlay.visible or dialogue_overlay.visible
	if open:
		journal_close.grab_focus()
	else:
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused != null and journal_panel.is_ancestor_of(focused):
			focused.release_focus()
