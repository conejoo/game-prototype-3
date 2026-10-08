extends "res://tests/npc_01_render.gd"
## G005 ordinary viewport acquisition/interaction. No item/fact/position setup.

func _run() -> void:
	phase = "ordinary"
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0],"fresh production root")
	if startup[0]: await _ordinary()
	_check(TestRunEvidence.write_json("social-gift-ui-ordinary.json", {"task":"G005", "proof":"ordinary viewport WASD/E/mouse/Tab/Enter; no setup mutations", "pid":OS.get_process_id(), "assertions":assertions+1, "failures":failures, "views":captures, "traces":traces}),"evidence write")
	paused = false
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("G005 social_gift_ui_render ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions," captures=",captures.size())
	quit(0 if failures.is_empty() else 1)

func _ordinary() -> void:
	await _pause()
	await _capture("fresh",true)
	await _resume()
	if not await _walk(NpcRegistry.find("npc-01").approach,"ordinary-introduction"): return
	await _talk("npc-01-initial-conversation","introduction")
	await _click(game.ui.dialogue_choices.get_child(0).get_global_rect().get_center())
	_check(game.session.conversations.memory("npc-01").affinity == 1,"ordinary helpful introduction")
	_close()
	for index: int in [1,2]:
		var flower: String = "moonflower-%02d" % index
		var foot: Vector3 = ForagingRegistry.find(flower).foot
		# Existing accepted first-flower approach avoids standing on the art.
		var approach: Vector3 = Vector3(27.5,.25,-2) if index == 1 else foot + Vector3(-.5,0,0)
		if not await _walk(approach,"ordinary-gather-"+flower): return
		game._refresh_interaction()
		_check(game.selected_interaction != null and game.selected_interaction.instance_id == flower,"physical flower selected "+flower)
		_key(KEY_E,true)
		await create_timer(.8).timeout
		_key(KEY_E,false)
		_check(game.session.inventory.count("item-moonflower") == 1 and game.session.foraging.is_collected(flower),"ordinary finite gather "+flower)
		# B/Enter inspects and selects the real gathered flower; no selection required for gifts.
		_key(KEY_B,true); _key(KEY_B,false)
		_key(KEY_ENTER,true); _key(KEY_ENTER,false)
		var bag: Dictionary = await TestRunInteractionCapture.backpack(game,"ordinary-bag-before-"+str(index),TestRunEvidence.directory(),"debug-input","Ordinary gathered Moonflower selected using B/Enter; authored gifting help")
		_check(bag.ok,bag.get("error","bag capture"))
		if bag.ok: captures.append(bag)
		_check(game.ui.backpack.details.text.contains("Gift through conversation"),"Moonflower help updated")
		_key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false)
		if not await _walk(NpcRegistry.find("npc-01").approach,"ordinary-gift-return-"+str(index)): return
		if not await _gift_talk(index): return
		_check("npc-01-moonflower-preference" in game.session.conversations.memory("npc-01").learned_fact_ids,"authored preference disclosed")
		var old: Dictionary = game.dialogue.snapshot()
		var button: Button = game.ui.dialogue_choices.get_child(0)
		_check(not button.disabled,"owned ordinary gift available")
		if index == 1: await _click(button.get_global_rect().get_center())
		else:
			# Reopened source choice takes Tab/Shift-Tab/Enter through contained GUI focus.
			_key(KEY_TAB,true); _key(KEY_TAB,false)
			for step: int in range(8):
				if root.gui_get_focus_owner() == button: break
				_key(KEY_TAB,true); _key(KEY_TAB,false)
			_check(root.gui_get_focus_owner() == button,"ordinary Tab reaches gift")
			_key(KEY_ENTER,true); _key(KEY_ENTER,false)
			await process_frame
		_check(game.session.inventory.count("item-moonflower") == 0 and game.session.inventory.snapshot().active_item_id == null,"one gifted unit clears last selection")
		_check(game.session.conversations.memory("npc-01").affinity == 1+index,"recipient progress immediate")
		var npc: NpcDefinition = game.npc_catalog.get_npc("npc-01")
		var authored_target: String = npc.graph.choices[old.choices[0].id].target_node_id
		_check(game.dialogue.snapshot().node_id == ("npc-01-level-1-milestone" if index == 2 else authored_target),"authored response/milestone displayed")
		_check(game.ui.dialogue_status.text.contains("Gifted Moonflower to "+npc.display_name) and game.ui.dialogue_view.friendship.text.contains("Backpack: 0"),"feedback survives authored node change")
		var accepted: Dictionary = game.session.conversations.snapshot()
		_check(not game._choose_dialogue(old.choices[0].id,old).ok and game.session.conversations.snapshot() == accepted,"ordinary stale command rejected")
		for id: String in NpcContentCatalog.ROSTER:
			if id != "npc-01": _check(game.session.conversations.memory(id).seen_node_ids.is_empty() and game.session.conversations.memory(id).affinity == 0,"other recipient untouched "+id)
		await _dialogue_capture("gift-accepted-"+str(index))
		if index == 2:
			root.size = Vector2i(1440,900)
			await _dialogue_capture("milestone-1440")
			_check(root.size == Vector2i(1440,900),"larger actual viewport measured")
			root.size = Vector2i(960,640)
		_close()
		_key(KEY_B,true); _key(KEY_B,false)
		_check(game.ui.backpack.slot_ids.is_empty() and game.ui.active_item_label.text.begins_with("Active item: none"),"ordinary bag/HUD updated")
		bag = await TestRunInteractionCapture.backpack(game,"ordinary-bag-after-"+str(index),TestRunEvidence.directory(),"debug-input","Gift consumed last genuinely gathered flower; bag empty and active selection cleared")
		_check(bag.ok,bag.get("error","bag capture"))
		if bag.ok: captures.append(bag)
		_key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false)
	# Honest no-item row after normal reopen; milestone cannot replay.
	await _talk("npc-01-follow-up-conversation","reopen-after-two")
	_check(game.ui.dialogue_choices.get_child(0).disabled and game.ui.dialogue_choices.get_child(0).text.contains("No owned Moonflower."),"ordinary missing supply reason")
	_check(game.session.conversations.events().count(NpcEventMemory.GIFT,"moonflower","npc-01") == 2 and "relationshipLevel1Seen" in game.session.conversations.memory("npc-01").flags,"two deliberate gifts / milestone once")
	_check(not game.session.foraging.is_collected("moonflower-03") and game.session.relationship.trust == 0 and game.session.completed_effect_ids.is_empty(),"third finite flower / prior systems intact")
	await _click(game.ui.dialogue_next.get_global_rect().get_center())
	_check(not game.dialogue.active() and game.player_placeholder.controls_enabled,"mouse Continue restores controls")
	# Preserve the independent, existing companion reaction through ordinary UI.
	var social_before: Dictionary = game.session.conversations.snapshot()
	if not await _walk(Vector3(-2.8,0,.8),"ordinary-existing-companion-choice"): return
	_key(KEY_E,true); _key(KEY_E,false)
	await process_frame
	_check(game.dialogue.snapshot().get("graph_id") == "prototype-companion-greeting","ordinary companion station still routes")
	if game.dialogue.snapshot().get("graph_id") != "prototype-companion-greeting": return
	for line: int in range(4):
		if not game.dialogue.snapshot().choices.is_empty(): break
		await _click(game.ui.dialogue_next.get_global_rect().get_center())
	var definition: ConversationDefinition = game.catalog.get_dialogue("prototype-companion-greeting")
	var node: NpcDialogueGraph.NodeDefinition = definition.graph().nodes[game.dialogue.snapshot().node_id]
	var reaction: Button
	for choice: NpcDialogueGraph.Choice in node.choices:
		if choice.command.get("reaction_id","") == "prototype-shared-plan": reaction = game.ui.dialogue_choices.get_node(NodePath(choice.id))
	_check(reaction != null,"existing positive companion choice visible")
	if reaction == null: return
	await _click(reaction.get_global_rect().get_center())
	_check(game.session.relationship.trust == 1 and game.session.conversations.snapshot() == social_before and game.session.inventory.count("item-moonflower") == 0,"companion choice uses independent owner and preserves gifts")
	await _dialogue_capture("existing-companion-choice")
	_close()
	await _pause()
	await _capture("complete-paused",true)

func _gift_talk(index: int) -> bool:
	for attempt: int in range(4):
		_key(KEY_E,true); _key(KEY_E,false)
		await process_frame
		_check(game.dialogue.active(),"ordinary E opens current entry")
		if not game.dialogue.active(): return false
		var view: Dictionary = game.dialogue.snapshot()
		if view.node_id in ["npc-01-moonflower-hint","npc-01-follow-up-conversation"]:
			await _dialogue_capture("gift-choice-"+str(index))
			return true
		_check(view.node_id in ["npc-01-woods-first","npc-01-woods-repeat"],"authored woods-priority detour")
		await _dialogue_capture("source-priority-"+str(index)+"-"+str(attempt))
		_close()
	_check(false,"gift entry never reached after ordinary source detours")
	return false
