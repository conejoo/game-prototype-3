class_name BackpackView
extends Control
## Snapshot-only presentation; root validates every selection command.
signal selection_requested(item_id: Variant)
signal close_requested

var panel: PanelContainer
var slots: Array[Button] = []
var slot_ids: Array[String] = []
var details: Label
var capacity: Label
var close_button: Button
var clear_button: Button
var drop_button: Button
var _last: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(.01,.02,.03,.85)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center: CenterContainer = CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new()
	center.add_child(panel)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(.055,.085,.105,1)
	style.set_border_width_all(2)
	style.border_color = Color(.2,.65,.62)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel",style)
	var margin: MarginContainer = MarginContainer.new()
	panel.add_child(margin)
	for side: String in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_" + side,16)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation",10)
	margin.add_child(column)
	var title: Label = Label.new()
	title.text = "Backpack"
	title.add_theme_font_size_override("font_size",26)
	column.add_child(title)
	capacity = Label.new()
	capacity.add_theme_font_size_override("font_size",14)
	column.add_child(capacity)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	column.add_child(grid)
	for index: int in range(20):
		var button: Button = Button.new()
		button.name = "Slot%02d" % (index + 1)
		button.custom_minimum_size = Vector2(0,54)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size",14)
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.toggle_mode = true
		var active_style: StyleBoxFlat = StyleBoxFlat.new()
		active_style.bg_color = Color(.035,.2,.18,1)
		active_style.border_color = Color(.35,.95,.75,1)
		active_style.set_border_width_all(2)
		button.add_theme_stylebox_override("pressed",active_style)
		button.add_theme_stylebox_override("hover_pressed",active_style)
		button.add_theme_color_override("font_pressed_color",Color(.7,1,.9,1))
		button.add_theme_color_override("font_hover_pressed_color",Color(.7,1,.9,1))
		button.pressed.connect(func() -> void:
			if index < slot_ids.size(): selection_requested.emit(slot_ids[index]))
		grid.add_child(button)
		slots.append(button)
	details = Label.new()
	details.custom_minimum_size.y = 76
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_theme_font_size_override("font_size",14)
	column.add_child(details)
	var actions: HBoxContainer = HBoxContainer.new()
	column.add_child(actions)
	clear_button = Button.new()
	clear_button.text = "Clear selection"
	clear_button.custom_minimum_size.y = 40
	clear_button.pressed.connect(func() -> void: selection_requested.emit(null))
	actions.add_child(clear_button)
	drop_button = Button.new()
	drop_button.text = "Drop rod (unavailable)"
	drop_button.disabled = true
	drop_button.tooltip_text = "Safe rod placement is not available yet."
	actions.add_child(drop_button)
	close_button = Button.new()
	close_button.text = "Close [B / Esc]"
	close_button.custom_minimum_size.y = 40
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button.pressed.connect(func() -> void: close_requested.emit())
	actions.add_child(close_button)
	resized.connect(_fit)
	_fit()
	hide()

func _fit() -> void:
	if panel != null: panel.custom_minimum_size.x = minf(720, maxf(0,size.x - 48))

func present(snapshot: InventorySnapshot, catalog: ContentCatalog, force: bool = false) -> void:
	var facts: Dictionary = snapshot.to_dictionary()
	if facts == _last and not force: return
	_last = facts
	slot_ids.assign(snapshot.item_counts.keys())
	capacity.text = "%d / 20 slots occupied · One stack per item · Tab / Enter: select" % slot_ids.size()
	for index: int in range(20):
		var button: Button = slots[index]
		button.disabled = index >= slot_ids.size()
		button.set_pressed_no_signal(not button.disabled and slot_ids[index] == snapshot.active_item_id)
		if button.disabled:
			button.text = "Empty"
			button.tooltip_text = "Empty slot"
		else:
			var item: ItemDefinition = catalog.get_item(slot_ids[index])
			button.text = "%s\n%d / %d" % [item.display_name,snapshot.item_counts[item.stable_id],item.stack_limit]
			button.tooltip_text = item.display_name + " · " + item.description
	clear_button.disabled = snapshot.active_item_id == null
	drop_button.visible = snapshot.active_item_id == ForagingRegistry.ROD_ITEM
	if snapshot.active_item_id == null:
		details.text = "No active item. Select an owned item to inspect it.\nGathering does not select items automatically."
	else:
		var item: ItemDefinition = catalog.get_item(snapshot.active_item_id)
		details.text = "%s · %d / %d\n%s\n%s" % [item.display_name,snapshot.item_counts[item.stable_id],item.stack_limit,item.description,"Active tool · Fishing unavailable." if item.is_tool() else "Selected item · No direct use."]
	_focus_cycle()

func open(snapshot: InventorySnapshot, catalog: ContentCatalog) -> void:
	present(snapshot,catalog)
	show()
	_focus_cycle()
	var focus: Button = close_button
	for index: int in range(slot_ids.size()):
		if slot_ids[index] == snapshot.active_item_id or (snapshot.active_item_id == null and index == 0):
			focus = slots[index]
			break
	focus.grab_focus()

func close() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused != null and is_ancestor_of(focused): focused.release_focus()
	hide()

func _focus_cycle() -> void:
	var buttons: Array[Button] = []
	for button: Button in slots:
		if not button.disabled: buttons.append(button)
	if not clear_button.disabled: buttons.append(clear_button)
	buttons.append(close_button)
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		button.focus_next = button.get_path_to(buttons[(index + 1) % buttons.size()])
		button.focus_previous = button.get_path_to(buttons[(index + buttons.size() - 1) % buttons.size()])
		button.focus_neighbor_left = button.focus_previous
		button.focus_neighbor_right = button.focus_next
		button.focus_neighbor_top = button.focus_previous
		button.focus_neighbor_bottom = button.focus_next
	var focused: Control = get_viewport().gui_get_focus_owner()
	if visible and (focused == null or not is_ancestor_of(focused) or (focused is Button and focused.disabled)):
		buttons[0].grab_focus()
