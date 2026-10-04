class_name EnvironmentClock
extends RefCounted
## Pure source clock rules. Display midnight differs from the 10 AM cycle wrap.

const CYCLE_SECONDS: float = 600.0
const MINUTES_PER_DAY: int = 1440
const START_MINUTES: int = 600
const MAX_DAY_INDEX: int = 3650

class AdvanceResult:
	extends RefCounted
	var day_index: int = 0
	var day_cycle_progress: float = 0.0
	var errors: PackedStringArray = []


static func validate(day_index: int, progress: float) -> PackedStringArray:
	var errors: PackedStringArray = []
	if day_index < 0 or day_index > MAX_DAY_INDEX:
		errors.append("environment day_index must be within 0..3650")
	if not is_finite(progress) or progress < 0.0 or progress >= 1.0:
		errors.append("environment day_cycle_progress must be finite and within [0,1)")
	return errors


static func advance(day_index: int, progress: float, delta: float) -> AdvanceResult:
	var result: AdvanceResult = AdvanceResult.new()
	result.errors = validate(day_index, progress)
	if not is_finite(delta) or delta < 0.0:
		result.errors.append("environment delta must be finite and nonnegative")
	if not result.errors.is_empty():
		return result
	var total_progress: float = progress + delta / CYCLE_SECONDS
	# Check before float-to-int conversion, including enormous finite deltas.
	if total_progress >= float(MAX_DAY_INDEX + 1 - day_index):
		result.errors.append("environment advance exceeds supported day range")
		return result
	var whole_days: int = int(floor(total_progress))
	result.day_index = day_index + whole_days
	result.day_cycle_progress = total_progress - float(whole_days)
	return result


static func absolute_minutes(day_index: int, progress: float) -> float:
	if not validate(day_index, progress).is_empty():
		return NAN
	return float(day_index * MINUTES_PER_DAY) + progress * MINUTES_PER_DAY


static func minute_of_day(progress: float) -> float:
	if not validate(0, progress).is_empty():
		return NAN
	return fmod(START_MINUTES + progress * MINUTES_PER_DAY, MINUTES_PER_DAY)


static func format_time(progress: float) -> String:
	var authored_minutes: float = minute_of_day(progress)
	if not is_finite(authored_minutes):
		return ""
	var minutes: int = int(floor(authored_minutes))
	var hour24: int = minutes / 60
	var hour12: int = hour24 % 12
	if hour12 == 0:
		hour12 = 12
	return "%d:%02d %s" % [hour12, minutes % 60, "AM" if hour24 < 12 else "PM"]
