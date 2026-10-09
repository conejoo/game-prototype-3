extends MayorValeHome
## Synthetic candidate changes only arrival feet into the existing solid bed.
func _init() -> void:
	super()
	get_node("Spawns/TownArrival").position = Vector3(-4.5,0,-1)
