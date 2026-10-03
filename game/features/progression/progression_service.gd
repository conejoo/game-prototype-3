class_name ProgressionService
extends RefCounted
## One training point from lead; spent identities, never a second reward counter.

signal changed
const UPGRADE_ID: String = "prototype-deliberate-strike"
const BASE_DAMAGE: int = 25
var catalog: ContentCatalog
var session: GameSession

func initialize(content: ContentCatalog, run: GameSession) -> void:
	catalog = content
	session = run

func available_points() -> int:
	var definition: UpgradeDefinition = catalog.get_upgrade(UPGRADE_ID)
	return (1 if definition.earned_effect_id in session.completed_effect_ids else 0) - session.progression.upgrade_ids.size()

func select_upgrade(id: String) -> DialogueService.ActionResult:
	if id != UPGRADE_ID or catalog.get_upgrade(id) == null:
		return DialogueService.ActionResult.new(false, "Unknown upgrade.")
	if id in session.progression.upgrade_ids:
		return DialogueService.ActionResult.new(true, "Upgrade already selected; no point spent again.")
	if available_points() < 1:
		return DialogueService.ActionResult.new(false, "Accept Maris's lead to earn one preparation point.")
	session.progression.upgrade_ids.append(id)
	changed.emit()
	return DialogueService.ActionResult.new(true, "Deliberate Strike selected: hero damage 25 → 40.")

func hero_damage() -> int:
	var damage: int = BASE_DAMAGE
	for id: String in session.progression.upgrade_ids:
		damage += catalog.get_upgrade(id).damage_bonus
	return damage

static func validate_state(data: Variant, effects: Array, catalog: ContentCatalog) -> PackedStringArray:
	if not data is Dictionary or data.size() != 1 or not data.get("upgrade_ids") is Array or data.upgrade_ids.size() > 1:
		return PackedStringArray(["invalid progression fields/point spending"])
	for id: Variant in data.upgrade_ids:
		if not id is String or id != UPGRADE_ID or catalog.get_upgrade(id) == null or catalog.get_upgrade(id).earned_effect_id not in effects:
			return PackedStringArray(["unknown/unearned upgrade"])
	return []
