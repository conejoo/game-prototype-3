class_name ForagingHoldController
extends RefCounted
## Transient root-owned attempt. Weak target/session, immutable copied identity.
var action: ForagingAction
var expected_revision: int = -1
var elapsed: float = 0.0
var duration: float = 0.0
var target_position: Vector3
var last_cancel: String = ""
var _target: WeakRef
var _owner: WeakRef

func start(target_node: PrototypeInteractable, run: GameSession, seconds: float) -> void:
	_target = weakref(target_node)
	_owner = weakref(run)
	action = target_node.foraging_action.duplicate() as ForagingAction
	expected_revision = run.foraging.revision()
	target_position = target_node.global_position
	elapsed = 0.0
	duration = seconds
	last_cancel = ""

func active() -> bool:
	return action != null

func target() -> PrototypeInteractable:
	return _target.get_ref() as PrototypeInteractable if _target != null else null

func owner() -> GameSession:
	return _owner.get_ref() as GameSession if _owner != null else null

func progress() -> float:
	return clampf(elapsed / duration, 0, 1) if active() and duration > 0 else 0.0

func cancel(reason: String) -> void:
	if active(): last_cancel = reason
	action = null
	_target = null
	_owner = null
	elapsed = 0
	duration = 0
	expected_revision = -1
