extends Node3D
## Persistent composition root. Future travel replaces WorldHost's child.

@onready var camera_rig: PrototypeCameraRig = $CameraRig
@onready var player_placeholder: Node3D = $Party/PlayerPlaceholder
@onready var ui: PrototypeUI = $UI

var session: GameSession = GameSession.new()


func _ready() -> void:
	get_tree().auto_accept_quit = false
	camera_rig.set_target(player_placeholder)
	ui.pause_requested.connect(_toggle_pause)
	ui.resume_requested.connect(_resume)
	ui.quit_requested.connect(_quit)
	ui.show_paused(false)
	print("P001: GameRoot ready; WorldHost, Party, CameraRig, UI initialized.")


func _process(delta: float) -> void:
	if not get_tree().paused:
		session.advance(delta)
		ui.show_play_time(session.elapsed_play_seconds)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_toggle_pause()
	elif event.is_action_pressed("quit") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_quit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_quit()


func _toggle_pause() -> void:
	_set_paused(not get_tree().paused)


func _resume() -> void:
	_set_paused(false)


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	ui.show_paused(paused)
	print("P001: %s at play time %.2fs." % ["Paused" if paused else "Resumed", session.elapsed_play_seconds])


func _quit() -> void:
	print("P001: Quit requested%s." % [" while paused" if get_tree().paused else ""])
	get_tree().quit(0)
