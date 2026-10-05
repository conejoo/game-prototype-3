class_name SaveRepository
extends RefCounted
## Single-writer local slot. Read/recovery never changes disk or live state.

var path: String

class ReadResult:
	extends RefCounted
	var session: GameSession
	var errors: PackedStringArray = []
	var recovered: bool = false
	var source: String = ""
	var status: String = ""
	var migrated: bool = false


func _init(save_path: String = "user://saves/returning-fair.json") -> void:
	path = save_path


func read(catalog: ContentCatalog) -> ReadResult:
	var primary: ReadResult = _read_file(path, catalog)
	if primary.session != null or primary.status in ["incompatible", "io"]:
		return primary
	var backup: ReadResult = _read_file(path + ".bak", catalog)
	if backup.session != null:
		backup.recovered = true
		return backup
	primary.errors.append_array(backup.errors)
	return primary


func write(run: GameSession, catalog: ContentCatalog) -> PackedStringArray:
	if run != null and run.review_only:
		return PackedStringArray(["developer environment review cannot be saved"])
	var snapshot: Dictionary = SaveCodec.snapshot(run)
	var candidate: SaveCodec.DecodeResult = SaveCodec.validate(snapshot, catalog)
	if not candidate.errors.is_empty():
		return candidate.errors
	# Never silently replace a newer slot, including a newer backup.
	var primary: ReadResult = _read_file(path, catalog)
	var backup: ReadResult = _read_file(path + ".bak", catalog)
	for existing: ReadResult in [primary, backup]:
		if existing.status in ["incompatible", "io"]:
			return existing.errors
	if primary.status == "malformed" and backup.session == null:
		return PackedStringArray(["save refused: corrupt primary has no validated backup; preserve files and repair/archive slot first"])
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return PackedStringArray(["cannot create save directory: " + path.get_base_dir()])
	# Clock progress must round-trip exactly, especially immediately before wrap.
	var errors: PackedStringArray = _stage(path + ".tmp", JSON.stringify(snapshot, "\t", true, true), catalog)
	if not errors.is_empty():
		return errors
	# A validated primary becomes the backup; corrupt data never replaces it.
	# On first save create a recovery copy before publishing primary.
	if primary.session != null or backup.session == null:
		var backup_data: Dictionary = SaveCodec.snapshot(primary.session) if primary.session != null else snapshot
		errors = _stage(path + ".bak.tmp", JSON.stringify(backup_data, "\t", true, true), catalog)
		if not errors.is_empty():
			return errors
		var backup_error: Error = DirAccess.rename_absolute(path + ".bak.tmp", path + ".bak")
		if backup_error != OK:
			return PackedStringArray(["cannot publish save backup: %s" % error_string(backup_error)])
	var publish_error: Error = DirAccess.rename_absolute(path + ".tmp", path)
	if publish_error != OK:
		return PackedStringArray(["cannot publish save: %s; validated backup retained" % error_string(publish_error)])
	return PackedStringArray()


func _stage(temporary: String, raw: String, catalog: ContentCatalog) -> PackedStringArray:
	var file: FileAccess = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return PackedStringArray(["cannot open temporary save '%s': %s" % [temporary, error_string(FileAccess.get_open_error())]])
	file.store_string(raw)
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK:
		return PackedStringArray(["temporary save write failed: %s" % error_string(error)])
	# Reopen and validate persisted bytes, not merely the in-memory snapshot.
	var verified: ReadResult = _read_file(temporary, catalog)
	return verified.errors


func _read_file(filename: String, catalog: ContentCatalog) -> ReadResult:
	var result: ReadResult = ReadResult.new()
	result.source = filename
	if DirAccess.dir_exists_absolute(filename):
		result.status = "io"
		result.errors.append("save path is a directory: " + filename)
		return result
	if not FileAccess.file_exists(filename):
		result.status = "missing"
		result.errors.append("no save file: " + filename)
		return result
	var file: FileAccess = FileAccess.open(filename, FileAccess.READ)
	if file == null:
		result.status = "io"
		result.errors.append("cannot read save '%s': %s" % [filename, error_string(FileAccess.get_open_error())])
		return result
	var length: int = file.get_length()
	if length > SaveCodec.MAX_BYTES:
		file.close()
		result.status = "malformed"
		result.errors.append("save exceeds 128KiB limit: " + filename)
		return result
	var bytes: PackedByteArray = file.get_buffer(length)
	var error: Error = file.get_error()
	file.close()
	if bytes.size() != length or error != OK:
		result.status = "io"
		result.errors.append("save read failed: " + filename)
		return result
	var decoded: SaveCodec.DecodeResult = SaveCodec.decode(bytes.get_string_from_utf8(), catalog)
	result.session = decoded.session
	result.errors = decoded.errors
	result.migrated = decoded.migrated
	result.status = "valid" if decoded.session != null else ("incompatible" if decoded.incompatible else "malformed")
	return result
