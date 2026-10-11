extends Node
## AD017 appearance only. Existing controls, text snapshots and input owners stay authoritative.
const INK: Color = Color("f0dfbb")
const WOOD: Color = Color("38372e")
const EDGE: Color = Color("958367")
var ui: PrototypeUI
var location: Node
var labels: Array[Dictionary] = []
var elapsed: float = 0.0

static func panel(color: Color = WOOD) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = EDGE
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)
	return style

func initialize(owner_ui: PrototypeUI) -> void:
	ui = owner_ui
	var screen: Control = ui.get_node("Screen")
	var theme: Theme = screen.theme.duplicate()
	theme.default_font_size = 16
	for type_name: String in ["Label", "Button", "CheckButton"]:
		theme.set_color("font_color", type_name, INK)
	theme.set_color("default_color", "RichTextLabel", INK)
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var color: Color = Color("43564d") if state.contains("pressed") else Color("4d5040") if state == "hover" else Color("3e4236")
		theme.set_stylebox(state, "Button", panel(color))
		theme.set_color("font_" + state + "_color", "Button", INK if state != "disabled" else Color("aaa48e"))
	var focus: StyleBoxFlat = panel(Color(0,0,0,0))
	focus.border_color = Color("e7b16e")
	focus.set_border_width_all(2)
	theme.set_stylebox("focus", "Button", focus)
	screen.theme = theme
	ui.backpack.theme = theme
	ui.fishing_view.theme = theme
	for path: String in ["Header", "Footer", "PauseOverlay/Center/Panel", "DialogueOverlay/Center/Panel", "JournalOverlay/Center/Panel"]:
		(screen.get_node(path) as PanelContainer).add_theme_stylebox_override("panel", panel())
	ui.backpack.panel.add_theme_stylebox_override("panel", panel())
	ui.fishing_view.panel.add_theme_stylebox_override("panel", panel())
	ui.fishing_view.bottom_inset = 88
	for path: String in ["Header/Margin", "Footer/Margin"]:
		for side: String in ["left", "right", "top", "bottom"]:
			(screen.get_node(path) as MarginContainer).add_theme_constant_override("margin_" + side, 8)
	screen.get_node("Header/Margin/Row").add_theme_constant_override("separation", 8)
	screen.get_node("Header/Margin/Row/Titles/Title").hide()
	ui.location_label.add_theme_color_override("font_color", INK)
	ui.location_label.add_theme_font_size_override("font_size", 16)
	for button: Button in [ui.pause_button, ui.journal_button, ui.people_button, ui.backpack_button]:
		button.custom_minimum_size.y = 36
		button.add_theme_font_size_override("font_size", 14)
	(screen.get_node("Header") as Control).offset_bottom = 60
	ui.objective_label.add_theme_stylebox_override("normal", panel())
	ui.objective_label.add_theme_color_override("font_color", INK)
	ui.objective_label.offset_left = 12
	ui.objective_label.offset_top = 83
	ui.objective_label.offset_bottom = 127
	ui.objective_label.anchor_right = 0
	ui.objective_label.offset_right = 552
	# Reuse footer's existing pointer-owned rectangle for persistent health/tool text.
	var party_row: HBoxContainer = HBoxContainer.new()
	party_row.name = "PartyStatus"
	party_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	party_row.add_theme_constant_override("separation", 24)
	screen.get_node("Footer/Margin/TextBox").add_child(party_row)
	screen.get_node("Footer/Margin/TextBox").move_child(party_row, 0)
	ui.combat_label.reparent(party_row)
	ui.combat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ui.companion_label.reparent(party_row)
	ui.combat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.combat_label.add_theme_font_size_override("font_size", 14)
	ui.combat_label.add_theme_color_override("font_color", INK)
	ui.active_item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.active_item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var field: Control = screen.get_node("FieldStatus")
	field.anchor_top = 1
	field.anchor_bottom = 1
	field.anchor_right = 0.5
	field.offset_left = 12
	field.offset_right = 280
	field.offset_top = -142
	field.offset_bottom = -82
	ui.travel_label.add_theme_stylebox_override("normal", panel())
	ui.travel_label.add_theme_color_override("font_color", INK)
	ui.travel_label.add_theme_font_size_override("font_size", 16)
	ui.foraging_notice.add_theme_stylebox_override("normal", panel())
	ui.gather_progress.offset_top = -166
	ui.gather_progress.offset_bottom = -150
	ui.get_viewport().size_changed.connect(_fit)
	_fit()

func _fit() -> void:
	ui.objective_label.offset_right = minf(552, ui.get_viewport().get_visible_rect().size.x - 12)

func owns_pointer(point: Vector2) -> bool:
	for label: Label in [ui.objective_label, ui.travel_label, ui.foraging_notice]:
		if label.is_visible_in_tree() and label.get_global_rect().has_point(point): return true
	return false

func _process(delta: float) -> void:
	if ui == null: return
	var debug: bool = ui.debug_toggle.button_pressed
	ui.camera_label.visible = debug
	(ui.get_node("Screen/Footer") as Control).offset_top = -120 if debug else -76
	ui.fishing_view.bottom_inset = ui.get_node("Screen/Footer").size.y + 12
	if ui.fishing_view.visible: ui.fishing_view._fit()
	# Raw message stays available to accessibility/tests; only generic repeated help is quiet.
	if not debug and ui.travel_label.text.begins_with("E near "): ui.travel_label.hide()
	var field: Control = ui.get_node("Screen/FieldStatus")
	field.offset_bottom = -ui.get_node("Screen/Footer").size.y - 12
	field.offset_top = field.offset_bottom - field.get_combined_minimum_size().y
	var game: Node = ui.get_parent()
	if game.get("world_host") == null: return
	if game.world_host.current_location != location:
		location = game.world_host.current_location
		labels.clear()
		if is_instance_valid(location):
			for label: Node in location.find_children("*", "Label3D", true, false):
				# Authored live speech and fishing outcome retain their own visibility/timing owner.
				if label.get_parent() is RoutinePresentation or label.get_parent() is FishingTargetPreview: continue
				labels.append({"node":label,"visible":label.visible})
	elapsed += delta
	if elapsed < 0.15: return
	elapsed = 0
	if not is_instance_valid(location) or not location.is_inside_tree(): return
	var closest: Label3D
	var closest_distance: float = 5.0
	for entry: Dictionary in labels:
		if not is_instance_valid(entry.node): continue
		var label: Label3D = entry.node
		if not label.is_inside_tree(): continue
		var distance: float = label.global_position.distance_to(game.player_placeholder.global_position)
		# Interactable has one current usable screen prompt, without duplicated floating instructions.
		var interaction_ancestor: bool = false
		var parent: Node = label.get_parent()
		while parent != location and parent != null:
			if parent is PrototypeInteractable or parent is MarisCounter: interaction_ancestor = true; break
			parent = parent.get_parent()
		label.visible = entry.visible and debug
		if entry.visible and not interaction_ancestor and not label.get_parent() is SpawnAnchor and distance <= closest_distance:
			closest = label
			closest_distance = distance
	if not debug and is_instance_valid(closest): closest.show()
