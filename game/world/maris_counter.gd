class_name MarisCounter
extends PrototypeInteractable
## Location-owned presentation only. Root supplies authoritative session effects.

var presentation: String = "basic"


func validation_errors(catalog: ContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors(catalog)
	for id: String in ["prototype-maris-counter", "prototype-maris-fitting", "prototype-maris-specialist"]:
		if catalog.get_dialogue(id) == null:
			errors.append("missing counter variant dialogue '%s'" % id)
	return errors


func apply_facts(effects: PackedStringArray) -> void:
	presentation = "specialist" if "maris-reconnected" in effects else ("fitting" if "maris-returned-to-town" in effects else "basic")
	dialogue_id = {"basic": "prototype-maris-counter", "fitting": "prototype-maris-fitting", "specialist": "prototype-maris-specialist"}[presentation]
	prompt = {"basic": "Talk to Maris · basic supplies", "fitting": "Help Maris reconnect and fit river gear", "specialist": "Inspect Maris's restored specialist service"}[presentation]
	$VisualRoot/FittingGear.visible = presentation == "fitting"
	$VisualRoot/SpecialistGear.visible = presentation == "specialist"
	$Sign.text = {"basic": "Maris [npc-03]\nBasic supplies only", "fitting": "Maris [npc-03]\nFamiliar fitting ready", "specialist": "Maris [npc-03]\nSpecialist service restored"}[presentation]
	$VisualRoot/ServiceBoard.text = "Line / lamp oil\n" + {"basic": "Specialist unavailable", "fitting": "Fitting in progress", "specialist": "Specialist fittings"}[presentation]
