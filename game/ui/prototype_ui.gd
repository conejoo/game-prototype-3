class_name PrototypeUI
extends CanvasLayer
## Displays state and submits commands; GameRoot owns pause/session changes.

signal pause_requested
signal resume_requested
signal quit_requested

@onready var pause_overlay: Control = $Screen/PauseOverlay
@onready var resume_button: Button = $Screen/PauseOverlay/Center/Panel/Margin/Options/Resume
@onready var pause_button: Button = $Screen/Header/Margin/Row/Pause
@onready var time_label: Label = $Screen/Header/Margin/Row/PlayTime
@onready var camera_label: Label = $Screen/Footer/Margin/Text
@onready var location_label: Label = $Screen/Header/Margin/Row/Titles/Subtitle
@onready var travel_label: Label = $Screen/TravelPrompt


func _ready() -> void:
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	$Screen/PauseOverlay/Center/Panel/Margin/Options/Quit.pressed.connect(
		func() -> void: quit_requested.emit()
	)


func show_paused(paused: bool) -> void:
	pause_overlay.visible = paused
	pause_button.disabled = paused
	if paused:
		resume_button.grab_focus()
	else:
		resume_button.release_focus()
		pause_button.release_focus()


func show_play_time(seconds: float) -> void:
	time_label.text = "Play time %03ds" % int(seconds)


func accepts_world_pointer(point: Vector2) -> bool:
	return (
		not pause_overlay.visible
		and not $Screen/Header.get_global_rect().has_point(point)
		and not $Screen/Footer.get_global_rect().has_point(point)
		and $Screen.get_global_rect().has_point(point)
	)


func show_camera(description: String) -> void:
	camera_label.text = "WASD: move · Mouse: face · E: travel at gate · Wheel / +/-: zoom\n%s · P: projection · Esc: pause/resume · F10: quit" % description


func show_location(description: String) -> void:
	location_label.text = "P004 / " + description


func show_travel(message: String) -> void:
	travel_label.text = message
