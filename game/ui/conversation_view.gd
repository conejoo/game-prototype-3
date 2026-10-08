class_name ConversationView
extends PanelContainer
## Snapshot-only portrait modal. Scrolling text/choices/facts; fixed visible exits.
signal choice_requested(id: String, command: Dictionary)
signal advance_requested(command: Dictionary)
signal counter_route_requested(command: Dictionary)
var title: Label
var expression: Label
var portrait: TextureRect
var body: RichTextLabel
var choices: VBoxContainer
var choice_scroll: ScrollContainer
var facts: RichTextLabel
var next: Button
var close: Button
var counter_route: Button
var status: Label
var _snapshot: Dictionary = {}
var highlighted_terms: PackedStringArray = []

func _ready() -> void:
	var margin: MarginContainer = MarginContainer.new()
	for edge: String in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + edge, 18)
	add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	title = Label.new()
	title.add_theme_font_size_override("font_size", 22)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(title)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(row)
	var identity: VBoxContainer = VBoxContainer.new()
	identity.custom_minimum_size.x = 184
	row.add_child(identity)
	portrait = TextureRect.new()
	portrait.custom_minimum_size = Vector2(184,184)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity.add_child(portrait)
	expression = Label.new()
	expression.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	expression.add_theme_font_size_override("font_size", 13)
	identity.add_child(expression)
	var facts_title: Label = Label.new()
	facts_title.text = "Known facts"
	facts_title.add_theme_font_size_override("font_size", 16)
	identity.add_child(facts_title)
	facts = RichTextLabel.new()
	facts.custom_minimum_size = Vector2(184,110)
	facts.size_flags_vertical = Control.SIZE_EXPAND_FILL
	facts.add_theme_font_size_override("normal_font_size", 14)
	facts.add_theme_font_size_override("bold_font_size", 14)
	identity.add_child(facts)
	facts.get_v_scroll_bar().focus_mode = Control.FOCUS_NONE
	var conversation: VBoxContainer = VBoxContainer.new()
	conversation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(conversation)
	body = RichTextLabel.new()
	body.custom_minimum_size.y = 132
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("normal_font_size", 18)
	body.add_theme_font_size_override("bold_font_size", 18)
	conversation.add_child(body)
	body.get_v_scroll_bar().focus_mode = Control.FOCUS_NONE
	choice_scroll = ScrollContainer.new()
	choice_scroll.custom_minimum_size.y = 158
	choice_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choice_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	choice_scroll.follow_focus = true
	conversation.add_child(choice_scroll)
	choice_scroll.get_v_scroll_bar().focus_mode = Control.FOCUS_NONE
	choices = VBoxContainer.new()
	choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choices.add_theme_constant_override("separation", 6)
	choice_scroll.add_child(choices)
	var actions: HBoxContainer = HBoxContainer.new()
	column.add_child(actions)
	next = Button.new()
	next.text = "Continue"
	next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next.custom_minimum_size.y = 44
	actions.add_child(next)
	counter_route = Button.new()
	counter_route.custom_minimum_size.y = 44
	counter_route.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(counter_route)
	counter_route.pressed.connect(func() -> void: counter_route_requested.emit(_snapshot.duplicate(true)))
	close = Button.new()
	close.text = "Close [Esc]"
	close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close.custom_minimum_size.y = 44
	actions.add_child(close)
	status = Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 13)
	column.add_child(status)
	next.pressed.connect(func() -> void: advance_requested.emit(_snapshot.duplicate(true)))
	get_viewport().size_changed.connect(_resize)
	_resize()

func _resize() -> void:
	custom_minimum_size = Vector2(minf(920, get_viewport_rect().size.x - 72), minf(570, get_viewport_rect().size.y - 64))

func present(view: Dictionary, message: String) -> void:
	_snapshot = view.duplicate(true)
	for child: Node in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
	if view.is_empty(): return
	title.text = view.speaker
	expression.text = view.portrait_id.replace("-", " ").capitalize() if not view.portrait_path.is_empty() else "Prototype presentation"
	portrait.texture = load(view.portrait_path) as Texture2D if not view.portrait_path.is_empty() else null
	portrait.visible = portrait.texture != null
	body.clear()
	var text: String = view.text
	var terms: PackedStringArray = []
	for fact: Dictionary in view.facts:
		if fact.id in view.revealed_fact_ids and not fact.highlight_term.is_empty(): terms.append(fact.highlight_term)
	highlighted_terms.clear()
	# Source uses paired Markdown bold markers. Other text remains literal.
	if text.count("**") % 2 == 0:
		var parts: PackedStringArray = text.split("**")
		for index: int in range(parts.size()):
			if index % 2 == 1: body.push_bold()
			_append_highlighted(parts[index], terms)
			if index % 2 == 1: body.pop()
	else: _append_highlighted(text, terms)
	body.scroll_to_line(0)
	facts.clear()
	if view.facts.is_empty(): facts.append_text("No public facts learned yet.")
	for fact: Dictionary in view.facts:
		facts.push_bold()
		facts.append_text(fact.label + "\n")
		facts.pop()
		facts.append_text(fact.description + "\n\n")
	facts.scroll_to_line(0)
	var focus: Array[Button] = []
	for choice: Dictionary in view.choices:
		var button: Button = Button.new()
		button.name = choice.id
		button.text = choice.text + ("\nUnavailable: " + choice.reason if not choice.available else "")
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 46
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = not choice.available
		button.add_theme_color_override("font_disabled_color", Color(.66,.71,.73))
		var command: Dictionary = view.duplicate(true)
		button.pressed.connect(func() -> void: choice_requested.emit(choice.id, command))
		choices.add_child(button)
		if choice.available: focus.append(button)
	choice_scroll.scroll_vertical = 0
	next.visible = view.can_continue
	if next.visible: focus.append(next)
	counter_route.visible = view.npc_id == "npc-03" and view.instance_id == "npc-03-counter"
	counter_route.text = "Recovery / counter" if view.graph_id == "npc-03" else "Chat with Maris"
	if counter_route.visible: focus.append(counter_route)
	focus.append(close)
	status.text = message
	if view.npc_id == "npc-06":
		status.text += ("\n" if not message.is_empty() else "") + "Conversation only. Purchases and delivery jobs unavailable."
	for index: int in range(focus.size()):
		focus[index].focus_next = focus[index].get_path_to(focus[(index + 1) % focus.size()])
		focus[index].focus_previous = focus[index].get_path_to(focus[(index + focus.size() - 1) % focus.size()])
		focus[index].focus_neighbor_left = focus[index].focus_previous
		focus[index].focus_neighbor_top = focus[index].focus_previous
		focus[index].focus_neighbor_right = focus[index].focus_next
		focus[index].focus_neighbor_bottom = focus[index].focus_next
	focus[0].grab_focus()

func _append_highlighted(text: String, terms: PackedStringArray) -> void:
	# Append literal authored text; source brackets are never interpreted as markup.
	var offset: int = 0
	while offset < text.length():
		var start: int = text.length()
		var term: String = ""
		for candidate: String in terms:
			var found: int = text.findn(candidate, offset)
			if found >= 0 and (found < start or (found == start and candidate.length() > term.length())):
				start = found
				term = candidate
		body.append_text(text.substr(offset, start - offset))
		if term.is_empty(): break
		body.push_color(Color(.98,.82,.45))
		highlighted_terms.append(term)
		body.push_bold()
		body.append_text(text.substr(start, term.length()))
		body.pop()
		body.pop()
		offset = start + term.length()
