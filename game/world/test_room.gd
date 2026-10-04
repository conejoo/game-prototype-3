extends PrototypeLocation
## Visible simulation marker for pause verification; no gameplay rules.

@onready var beacon: Node3D = $TestBeacon


func _ready() -> void:
	super._ready()


func _process(delta: float) -> void:
	beacon.rotate_y(delta * 0.8)
