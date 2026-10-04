extends PrototypeLocation
## Explicit synthetic bake failure, absent from the normal catalog.


func prepare_navigation() -> PackedStringArray:
	return PackedStringArray(["M009 expected navigation bake rejection"])
