class_name PeopleJournalView
extends HBoxContainer
## Detached presentation only. Selection has no session or command access.

signal focus_controls_changed

var list_scroll: ScrollContainer
var list: VBoxContainer
var detail_scroll: ScrollContainer
var detail: VBoxContainer
var portrait: TextureRect
var identity: Label
var relationship: Label
var progress: ProgressBar
var facts: Label
var empty: Label
var rows: Array[Button] = []
var selected_id: String = ""
var _people: Array = []

func _ready() -> void:
	add_theme_constant_override("separation", 18)
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_scroll = ScrollContainer.new()
	list_scroll.custom_minimum_size.x = 190
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_scroll.follow_focus = true
	list_scroll.get_v_scroll_bar().focus_mode = Control.FOCUS_NONE
	add_child(list_scroll)
	list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	list_scroll.add_child(list)
	empty = _label(list)
	empty.text = "Meet someone through conversation to add them here."
	detail_scroll = ScrollContainer.new()
	detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_scroll.focus_mode = Control.FOCUS_ALL
	detail_scroll.get_v_scroll_bar().focus_mode = Control.FOCUS_NONE
	detail_scroll.tooltip_text = "Scroll learned facts with wheel or arrow keys."
	detail_scroll.gui_input.connect(_scroll_input)
	add_child(detail_scroll)
	detail = VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_theme_constant_override("separation", 10)
	detail_scroll.add_child(detail)
	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	detail.add_child(header)
	portrait = TextureRect.new()
	portrait.custom_minimum_size = Vector2(120, 120)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header.add_child(portrait)
	identity = _label(header)
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.add_theme_font_size_override("font_size", 24)
	relationship = _label(detail)
	progress = ProgressBar.new()
	progress.max_value = 1.0
	progress.step = 0.0
	progress.show_percentage = false
	progress.custom_minimum_size.y = 12
	detail.add_child(progress)
	facts = _label(detail)
	facts.add_theme_font_size_override("font_size", 16)

func _label(parent: Node) -> Label:
	var label: Label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func present(snapshot: Dictionary, reset: bool = false) -> void:
	_people = snapshot.get("people", []).duplicate(true)
	if reset: selected_id = ""
	for button: Button in rows:
		list.remove_child(button)
		button.queue_free()
	rows.clear()
	empty.visible = _people.is_empty()
	detail_scroll.visible = not _people.is_empty()
	for person: Dictionary in _people:
		var button: Button = Button.new()
		button.text = person.display_name
		button.name = person.npc_id
		button.custom_minimum_size.y = 44
		button.toggle_mode = true
		list.add_child(button)
		rows.append(button)
		button.pressed.connect(select.bind(String(person.npc_id)))
	if not _people.is_empty():
		if not _people.any(func(row: Dictionary) -> bool: return row.npc_id == selected_id):
			selected_id = _people[0].npc_id
		select(selected_id)
	else:
		selected_id = ""
		portrait.texture = null
		identity.text = ""
		relationship.text = ""
		facts.text = ""
		progress.value = 0
	focus_controls_changed.emit()

func select(id: String) -> void:
	for person: Dictionary in _people:
		if person.npc_id != id: continue
		selected_id = id
		portrait.texture = load(person.portrait_path) if not person.portrait_path.is_empty() else null
		portrait.visible = portrait.texture != null
		identity.text = person.display_name + "\n" + person.pronouns
		relationship.text = "Acquaintance: %d / %d%s" % [person.affinity, person.threshold, " — Reached" if person.level == 1 else ""]
		if person.level_label != null: relationship.text += "\n" + person.level_label
		progress.value = person.progress
		var text: PackedStringArray = []
		var category: String = ""
		for fact: Dictionary in person.facts:
			if fact.category != category:
				category = fact.category
				text.append(category.capitalize())
			text.append(fact.label + "\n" + fact.description + "\n")
		facts.text = "\n".join(text) if not text.is_empty() else "No learned facts yet. Keep talking to learn more."
		detail_scroll.scroll_vertical = 0
		for button: Button in rows: button.set_pressed_no_signal(String(button.name) == id)
		return

func focus_controls() -> Array[Control]:
	var controls: Array[Control] = []
	for button: Button in rows: controls.append(button)
	if detail_scroll.visible: controls.append(detail_scroll)
	return controls

func _scroll_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode in [KEY_UP, KEY_DOWN, KEY_PAGEUP, KEY_PAGEDOWN]:
		var amount: int = int(detail_scroll.size.y) if event.keycode in [KEY_PAGEUP, KEY_PAGEDOWN] else 32
		detail_scroll.scroll_vertical += amount * (-1 if event.keycode in [KEY_UP, KEY_PAGEUP] else 1)
		detail_scroll.accept_event()
