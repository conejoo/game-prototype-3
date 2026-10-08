class_name NpcContentAvailability
extends RefCounted
## Explicit capability classification; data only, never a reward permission.

enum Status { ENABLED, DEFERRED }
var status: Status
var reason: String

func _init(data: Dictionary) -> void:
	status = Status.ENABLED if data["status"] == "enabled" else Status.DEFERRED
	reason = data["reason"]

func is_enabled() -> bool:
	return status == Status.ENABLED
