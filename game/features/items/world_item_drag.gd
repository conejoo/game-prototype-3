class_name WorldItemDrag
extends RefCounted
## Transient preview only. Weak ownership; durable mutation belongs to ForagingState.
var _owner: WeakRef
var _target: WeakRef
var instance_id: String = ""
var location_id: String = ""
var expected_revision: int = -1
var original_foot: Vector3
var preview_foot: Variant = null
var errors: PackedStringArray = []

func active() -> bool:
	return _owner != null

func owner() -> GameSession:
	return _owner.get_ref() as GameSession if _owner != null else null

func target() -> PrototypeInteractable:
	return _target.get_ref() as PrototypeInteractable if _target != null else null

func start(run: GameSession, pickup: PrototypeInteractable) -> void:
	_owner = weakref(run)
	_target = weakref(pickup)
	instance_id = pickup.instance_id
	location_id = run.current_location_id
	expected_revision = run.foraging.revision()
	original_foot = pickup.global_position
	preview_foot = null
	errors = []

func cancel() -> void:
	_owner = null
	_target = null
	instance_id = ""
	location_id = ""
	expected_revision = -1
	preview_foot = null
	errors = []
