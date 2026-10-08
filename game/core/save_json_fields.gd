class_name SaveJsonFields
extends RefCounted
## Reject duplicate decoded keys before JSON's last-key-wins loses evidence.
## Called only after successful JSON parse and future-version protection.

static func validate(raw: String) -> PackedStringArray:
	var containers: Array[Dictionary] = []
	var index: int = 0
	while index < raw.length():
		var character: String = raw[index]
		if character == "{" or character == "[":
			containers.append({"object": character == "{", "keys": {}, "name": containers[-1].get("last", "") if not containers.is_empty() else ""})
		elif character == "}" or character == "]":
			containers.pop_back()
		elif character == '"':
			var start: int = index
			index += 1
			while index < raw.length():
				if raw[index] == "\\": index += 2
				elif raw[index] == '"': break
				else: index += 1
			var following: int = index + 1
			while following < raw.length() and raw.unicode_at(following) <= 32: following += 1
			if following < raw.length() and raw[following] == ":" and not containers.is_empty() and containers[-1].object:
				var key: String = JSON.parse_string(raw.substr(start, index - start + 1))
				if containers[-1].keys.has(key): return PackedStringArray(["duplicate JSON field: " + key])
				containers[-1].keys[key] = true
				containers[-1]["last"] = key
				if containers[-1].name == "item_counts" or key in ["affinity", "level", "last_sequence", "count", "first_sequence", "last_sequence"]:
					var start_value: int = following + 1
					while start_value < raw.length() and raw.unicode_at(start_value) <= 32: start_value += 1
					var end_value: int = start_value
					while end_value < raw.length() and not raw[end_value] in [",", "}", "]", " ", "\t", "\r", "\n"]: end_value += 1
					if not _whole_number(raw.substr(start_value, end_value - start_value)):
						return PackedStringArray(["quantity lexeme must be a whole number"])
		index += 1
	return []


static func _whole_number(token: String) -> bool:
	var parts: PackedStringArray = token.to_lower().split("e")
	if parts.size() > 2 or (parts.size() == 2 and parts[1].length() > 8): return false
	var number: String = parts[0].trim_prefix("-")
	var exponent: int = parts[1].to_int() if parts.size() == 2 else 0
	var point: int = number.find(".")
	var decimals: int = number.length() - point - 1 if point >= 0 else 0
	var digits: String = number.replace(".", "")
	if digits.is_empty() or not digits.is_valid_int(): return false
	var zeros: int = 0
	for index: int in range(digits.length() - 1, -1, -1):
		if digits[index] != "0": break
		zeros += 1
	return zeros == digits.length() or exponent + zeros >= decimals
