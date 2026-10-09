class_name FishingView
extends Control
## Detached snapshots only. Buttons submit input; no phase/reward/time authority.
signal reel_requested(held: bool)
signal cancel_requested

class TensionMeter extends Control:
	var view: Dictionary = {}
	func _draw() -> void:
		var stops: Array = [0.0,view.get("danger_min",.1),view.get("safe_min",.3),view.get("safe_max",.7),view.get("danger_max",.9),1.0]
		var colors: Array[Color] = [Color("b74748"),Color("b59145"),Color("39866c"),Color("b59145"),Color("b74748")]
		for index: int in range(5):
			draw_rect(Rect2(float(stops[index])*size.x,4,(float(stops[index+1])-float(stops[index]))*size.x,size.y-8),colors[index])
		var x: float = clampf(view.get("tension",.5),0,1)*size.x
		draw_line(Vector2(x,0),Vector2(x,size.y),Color.WHITE,4)

var panel: PanelContainer
var title: Label
var instruction: Label
var tension_text: Label
var legend: Label
var meter: TensionMeter
var landing: ProgressBar
var progress_text: Label
var reel_button: Button
var cancel_button: Button
var _snapshot: Dictionary = {}
var _pointer_held: bool = false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel = PanelContainer.new()
	add_child(panel)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("132831")
	style.border_color = Color("75bcb1")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel",style)
	var margin: MarginContainer = MarginContainer.new()
	panel.add_child(margin)
	for side: String in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,12)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation",6)
	margin.add_child(column)
	title = _label(column,22)
	instruction = _label(column,16)
	tension_text = _label(column,16)
	meter = TensionMeter.new()
	meter.custom_minimum_size.y = 24
	meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(meter)
	legend = _label(column,14)
	progress_text = _label(column,16)
	landing = ProgressBar.new()
	landing.custom_minimum_size.y = 12
	landing.max_value = 1
	landing.show_percentage = false
	landing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(landing)
	var actions: HBoxContainer = HBoxContainer.new()
	column.add_child(actions)
	reel_button = Button.new()
	reel_button.text = "Hold Reel / E"
	reel_button.custom_minimum_size = Vector2(0,42)
	reel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reel_button.focus_mode = Control.FOCUS_NONE
	reel_button.gui_input.connect(_reel_input)
	actions.add_child(reel_button)
	cancel_button = Button.new()
	cancel_button.text = "Cancel [F / right-click]"
	cancel_button.custom_minimum_size.y = 42
	cancel_button.focus_mode = Control.FOCUS_NONE
	cancel_button.pressed.connect(func() -> void: cancel_requested.emit())
	actions.add_child(cancel_button)
	resized.connect(_fit)
	panel.resized.connect(_fit)
	hide()

func _label(column: VBoxContainer, font_size: int) -> Label:
	var label: Label = Label.new()
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("f3f6ed"))
	# Explicit short lines avoid the zero-width autowrap/minimum-height cycle
	# when a live phase shows new labels before container layout has settled.
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(label)
	return label

func _fit() -> void:
	panel.custom_minimum_size.x = minf(400,maxf(0,size.x-48))
	panel.position = Vector2(size.x-24-panel.size.x,size.y-(18 if _snapshot.get("mode","idle") != "idle" else 142)-panel.size.y)

func accepts_pointer(point: Vector2) -> bool:
	return visible and panel.get_global_rect().has_point(point)

func present(view: Dictionary, available: bool) -> void:
	_snapshot = view.duplicate(true)
	var active: bool = view.get("mode","idle") != "idle"
	visible = available and (active or not str(view.get("feedback","")).is_empty())
	if not visible or not active: _release_pointer()
	var phase: String = view.get("phase","idle")
	var fighting: bool = phase == "fighting" and active
	tension_text.visible = fighting
	meter.visible = fighting
	legend.visible = fighting
	landing.visible = fighting
	progress_text.visible = fighting
	reel_button.visible = view.get("mode") == "attempt"
	cancel_button.visible = active
	if phase == "targeting":
		title.text = "Fishing: choose open water"
		instruction.text = "Click water within 12m to cast. Esc: cancel + pause."
	elif phase == "waiting":
		title.text = "Waiting for a bite..."
		instruction.text = "Do not reel yet. Wait for BITE, then press E or Reel."
	elif phase == "bite":
		title.text = "BITE! Hook it now!"
		instruction.text = "Fresh press: E or Reel. Hold to tighten; release to ease."
	elif fighting:
		title.text = "Reeling " + str(view.get("fish_name","fish"))
		instruction.text = "Hold E / Reel raises tension; release lowers it."
		var tension: float = view.tension
		var zone: String = "DANGER: slack" if tension <= view.danger_min else "DANGER: snap" if tension >= view.danger_max else "SAFE" if tension >= view.safe_min and tension <= view.safe_max else "WARNING"
		tension_text.text = "Tension %d%% - %s%s" % [roundi(tension*100),zone," - holding" if view.reel_held else " - released"]
		legend.text = "Danger <= %d%% | Safe %d-%d%%\nDanger >= %d%%" % [roundi(view.danger_min*100),roundi(view.safe_min*100),roundi(view.safe_max*100),roundi(view.danger_max*100)]
		meter.view = view.duplicate(true)
		meter.queue_redraw()
		landing.value = view.progress
		progress_text.text = "Landing %d%%" % roundi(view.progress*100)
	else:
		title.text = "Fishing: " + str(view.get("outcome","ended")).replace("_"," ").capitalize()
		instruction.text = str(view.get("feedback",""))
	if active and not str(view.get("feedback","")).is_empty() and phase == "targeting": instruction.text = view.feedback
	instruction.text = _wrapped(instruction.text,40)
	_fit()
	_resize_panel.call_deferred()

func _resize_panel() -> void:
	panel.reset_size()
	_fit()

static func _wrapped(value: String, width: int) -> String:
	var result: String = ""
	var line: String = ""
	for word: String in value.split(" "):
		if not line.is_empty() and line.length()+word.length()+1 > width:
			result += line+"\n"
			line = ""
		line += (" " if not line.is_empty() else "")+word
	return result+line

func _reel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not _pointer_held:
			_pointer_held = true
			reel_requested.emit(true)
		elif not event.pressed: _release_pointer()

func _input(event: InputEvent) -> void:
	# A release anywhere ends pointer ownership, even outside the original button.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed: _release_pointer()

func _release_pointer() -> void:
	if not _pointer_held: return
	_pointer_held = false
	reel_requested.emit(false)

func _exit_tree() -> void: _release_pointer()
