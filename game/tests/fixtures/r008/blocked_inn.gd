extends LanternRest
## Synthetic occupied actual inn arrival; original geometry preserved.
func _init() -> void:
	super()
	get_node("Spawns/TownArrival").position = Vector3(7.25,0,-14)
