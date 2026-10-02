class_name GameSession
extends RefCounted
## Mutable run state; no scene, content-resource, or rendering ownership.

var elapsed_play_seconds: float = 0.0


func advance(delta: float) -> void:
	elapsed_play_seconds += delta
