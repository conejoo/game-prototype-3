class_name RoutineJson
extends RefCounted
## Strict JSON grammar and duplicate-key gate. Godot JSON alone keeps last duplicate
## and accepts trailing commas. Bounded parser rejects before semantic publication.
var _source: String
var _offset: int = 0
var _error: String = ""
var _tokens: int = 0

func decode(source: String, context: String) -> Dictionary:
	_source = source
	_offset = 0
	_error = ""
	_tokens = 0
	if source.length() > 2097152:
		return {"errors": PackedStringArray([context + ": JSON exceeds 2MiB"])}
	var value: Variant = _value(context, 0)
	_space()
	if _offset != _source.length(): _fail(context, "trailing JSON content")
	return {"errors": PackedStringArray([_error]) if not _error.is_empty() else PackedStringArray(), "value": value}

func _fail(path: String, message: String) -> void:
	if _error.is_empty(): _error = "%s byte/character %d: %s" % [path, _offset, message]

func _space() -> void:
	while _offset < _source.length() and _source[_offset] in [" ", "\t", "\r", "\n"]: _offset += 1

func _take(token: String) -> bool:
	_space()
	if _source.substr(_offset, token.length()) != token: return false
	_offset += token.length()
	return true

func _value(path: String, depth: int) -> Variant:
	_space()
	_tokens += 1
	if depth > 64 or _tokens > 100000:
		_fail(path, "JSON nesting/token limit")
		return null
	if not _error.is_empty() or _offset >= _source.length():
		_fail(path, "missing JSON value")
		return null
	var char_at: String = _source[_offset]
	if char_at == "{":
		_offset += 1
		var object: Dictionary = {}
		if _take("}"): return object
		while _error.is_empty():
			_space()
			if _offset >= _source.length() or _source[_offset] != '"':
				_fail(path, "expected object key")
				break
			var key: String = _string(path)
			if object.has(key): _fail(path + "." + key, "duplicate JSON key")
			if not _take(":"): _fail(path, "expected colon")
			object[key] = _value(path + "." + key, depth + 1)
			if _take("}"): break
			if not _take(","): _fail(path, "expected object comma or close")
		return object
	if char_at == "[":
		_offset += 1
		var array: Array = []
		if _take("]"): return array
		while _error.is_empty():
			array.append(_value(path + "[%d]" % array.size(), depth + 1))
			if _take("]"): break
			if not _take(","): _fail(path, "expected array comma or close")
		return array
	if char_at == '"': return _string(path)
	for literal: String in ["true", "false", "null"]:
		if _take(literal): return true if literal == "true" else (false if literal == "false" else null)
	var match_number: RegExMatch = RegEx.create_from_string("^-?(0|[1-9][0-9]*)(\\.[0-9]+)?([eE][+-]?[0-9]+)?").search(_source.substr(_offset))
	if match_number == null:
		_fail(path, "invalid JSON value")
		return null
	var token: String = match_number.get_string()
	_offset += token.length()
	# Reject unsupported magnitude before Godot strtod, whose huge-exponent
	# warning would turn malformed data into an engine diagnostic.
	var exponent_text: String = match_number.get_string(3)
	if token.length() > 512 or token.split(".")[0].split("e")[0].split("E")[0].trim_prefix("-").length() > 309:
		_fail(path, "JSON number magnitude/length exceeds supported double")
		return null
	if not exponent_text.is_empty():
		exponent_text = exponent_text.substr(1)
		if exponent_text.length() > 4 or abs(exponent_text.to_int()) > 308:
			_fail(path, "nonfinite/unsupported JSON exponent")
			return null
	var number: float = token.to_float()
	if not is_finite(number): _fail(path, "nonfinite JSON number")
	return number

func _string(path: String) -> String:
	var start: int = _offset
	_offset += 1
	while _offset < _source.length():
		var char_at: String = _source[_offset]
		_offset += 1
		if char_at == '"':
			var parser: JSON = JSON.new()
			if parser.parse(_source.substr(start, _offset - start)) != OK:
				_fail(path, "invalid JSON string")
				return ""
			return str(parser.data)
		if char_at.unicode_at(0) < 32: _fail(path, "unescaped control character")
		if char_at == "\\":
			if _offset >= _source.length(): break
			var escaped: String = _source[_offset]
			_offset += 1
			if escaped == "u":
				if RegEx.create_from_string("^[0-9a-fA-F]{4}$").search(_source.substr(_offset, 4)) == null:
					_fail(path, "invalid unicode escape")
				_offset += 4
			elif escaped not in ['"', "\\", "/", "b", "f", "n", "r", "t"]:
				_fail(path, "invalid string escape")
	_fail(path, "unterminated JSON string")
	return ""
