class_name RoutinePresentation
extends Node3D
## Scene-owned public presentation only. Executor owns all active-time expiry.
## No rewards, interaction, gameplay input, local clock or saved presentation state.
const CLIPS: Dictionary = {"npc-01":{"river-fishing":"action_river_fishing"},"npc-02":{"archive-work":"action_archive_work"}}
var presenter: NpcVisualPresenter
var npc_id: String
var speech: Label3D
var fallback: bool = false

func configure(id: String, visual: NpcVisualPresenter) -> void:
	npc_id = id; presenter = visual
	speech = Label3D.new()
	speech.name = "PublicSpeech"
	speech.position = Vector3(0,2.05,0)
	speech.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	speech.no_depth_test = true
	speech.font_size = 32; speech.outline_size = 8
	speech.pixel_size = .016
	speech.modulate = Color(1,.97,.82)
	speech.outline_modulate = Color(.035,.045,.065,1)
	speech.width = 430
	speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speech.visible = false
	add_child(speech)

func sync(cursor: RoutineExecutor, holds: Dictionary, leased: bool = false) -> void:
	if presenter == null: return
	if cursor == null or cursor.state in [RoutineExecutor.State.COMPLETED,RoutineExecutor.State.FAILED,RoutineExecutor.State.CANCELLED]:
		clear(); return
	var step: RoutineDefinition.Step = cursor.current_step()
	if step == null: clear(); return
	var hidden: bool = leased
	var held: bool = leased
	for reason: String in holds:
		held = held or holds[reason]
		if reason != "pause": hidden = hidden or holds[reason]
	# Hidden labels retain no stale text. Resumption reads the same live authored
	# step, whose timer was held by the root, without a second speech timer.
	var speaking: bool = cursor.state == RoutineExecutor.State.SPEAKING and cursor.remaining > 0 and not hidden and presenter._speed <= .001
	speech.text = step.text if speaking else ""
	speech.visible = speaking
	if held: return
	fallback = false
	if cursor.state == RoutineExecutor.State.ACTING and cursor.remaining > 0:
		var clip: String = CLIPS.get(npc_id,{}).get(step.action_id,"")
		fallback = clip.is_empty() or not presenter.set_action(clip)
		if fallback: presenter.cancel_action()
	else: presenter.cancel_action()
	if cursor.state in [RoutineExecutor.State.WAITING,RoutineExecutor.State.ACTING,RoutineExecutor.State.SPEAKING] and presenter._speed <= .001:
		presenter.face_direction(cursor.facing)

func clear() -> void:
	fallback = false
	if speech != null: speech.text = ""; speech.visible = false
	if presenter != null: presenter.cancel_action()

func _exit_tree() -> void: clear()
