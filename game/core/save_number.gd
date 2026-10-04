class_name SaveNumber
extends RefCounted
## Bounded decimal-to-double conversion for durable timers. Godot 4.7.2's
## String.to_float/JSON parser can round the double immediately below 1 to 1.
## Decimal long division extracts significand bits, then rounds once, ties-even.

const MAX_TOKEN_LENGTH: int = 1100


static func parse(token: String) -> float:
	if token.length() > MAX_TOKEN_LENGTH:
		return NAN
	var negative: bool = token.begins_with("-")
	var text: String = token.substr(1) if negative else token
	var parts: PackedStringArray = text.to_lower().split("e")
	var exponent: int = 0
	if parts.size() > 1:
		if parts[1].length() > 5:
			return NAN
		exponent = parts[1].to_int()
	text = parts[0]
	var point: int = text.find(".")
	var decimal_position: int = (text.length() if point < 0 else point) + exponent
	var digits: String = text.replace(".", "")
	while digits.begins_with("0"):
		digits = digits.substr(1)
		decimal_position -= 1
	if digits.is_empty():
		return _zero(negative)
	# Timers are bounded at <=315360000; values outside this envelope fail.
	if decimal_position > 9:
		return -INF if negative else INF
	if decimal_position < -400:
		return _zero(negative)
	var integer_part: int = 0
	var fractional: String
	if decimal_position > 0:
		integer_part = (digits.left(decimal_position) + "0".repeat(maxi(0, decimal_position - digits.length()))).to_int()
		fractional = digits.substr(mini(decimal_position, digits.length()))
	else:
		fractional = "0".repeat(-decimal_position) + digits
	var fraction: Array[int] = []
	for index: int in range(fractional.length()):
		fraction.append(fractional.unicode_at(index) - 48)
	var bits: Array[int] = []
	var binary_exponent: int = 0
	if integer_part > 0:
		var highest: int = 0
		while (integer_part >> (highest + 1)) > 0:
			highest += 1
		binary_exponent = highest
		for shift: int in range(highest, -1, -1):
			bits.append((integer_part >> shift) & 1)
	var position: int = -1
	var remainder: bool = _nonzero(fraction)
	while remainder and bits.size() < 54 and position >= -1075:
		var carry: int = 0
		for index: int in range(fraction.size() - 1, -1, -1):
			var product: int = fraction[index] * 2 + carry
			fraction[index] = product % 10
			carry = product / 10
		if not bits.is_empty() or carry != 0:
			if bits.is_empty():
				binary_exponent = position
			bits.append(carry)
		position -= 1
		remainder = _nonzero(fraction)
	if bits.is_empty():
		return _zero(negative)
	var count: int = mini(53, binary_exponent + 1075)
	var retained: int = mini(count, bits.size())
	var mantissa: int = 0
	for index: int in range(retained):
		mantissa = (mantissa << 1) | bits[index]
	if bits.size() > count:
		var sticky: bool = remainder
		for index: int in range(count + 1, bits.size()):
			sticky = sticky or bits[index] != 0
		if bits[count] == 1 and (sticky or (mantissa & 1) == 1):
			mantissa += 1
		retained = count
	var scale: int = binary_exponent - retained + 1
	# Split the scale to avoid underflowing an intermediate power for subnormals.
	var value: float = float(mantissa) * pow(2.0, maxi(scale, -1022))
	if scale < -1022:
		value *= pow(2.0, scale + 1022)
	return -value if negative else value


static func _zero(negative: bool) -> float:
	var value: float = float(0)
	return -value if negative else value


static func _nonzero(digits: Array[int]) -> bool:
	for digit: int in digits:
		if digit != 0:
			return true
	return false


static func restore_timers(raw: String, data: Dictionary) -> PackedStringArray:
	# JSON already validated structure. Read key/value lexemes while skipping
	# strings, including escaped keys; no regex can mistake an ID for a number.
	var tokens: Dictionary[String, String] = {}
	var index: int = 0
	while index < raw.length():
		if raw[index] != '"':
			index += 1
			continue
		var start: int = index
		index += 1
		while index < raw.length():
			if raw[index] == "\\":
				index += 2
			elif raw[index] == '"':
				break
			else:
				index += 1
		index += 1
		var key: Variant = JSON.parse_string(raw.substr(start, index - start))
		var following: int = index
		while following < raw.length() and raw.unicode_at(following) <= 32:
			following += 1
		if following >= raw.length() or raw[following] != ":" or not key in ["elapsed_play_seconds", "day_cycle_progress"]:
			continue
		following += 1
		while following < raw.length() and raw.unicode_at(following) <= 32:
			following += 1
		var end: int = following
		while end < raw.length() and raw[end] in "0123456789.eE+-":
			end += 1
		if end > following:
			if tokens.has(key):
				return PackedStringArray(["duplicate saved timer field: " + key])
			tokens[key] = raw.substr(following, end - following)
	if (data.get("elapsed_play_seconds") is int or data.get("elapsed_play_seconds") is float) and tokens.has("elapsed_play_seconds"):
		data.elapsed_play_seconds = parse(tokens.elapsed_play_seconds)
	if data.get("environment") is Dictionary:
		var environment: Dictionary = data.environment
		if (environment.get("day_cycle_progress") is int or environment.get("day_cycle_progress") is float) and tokens.has("day_cycle_progress"):
			environment.day_cycle_progress = parse(tokens.day_cycle_progress)
	return PackedStringArray()
