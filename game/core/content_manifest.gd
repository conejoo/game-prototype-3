class_name ContentManifest
extends Resource
## Explicit authored catalog input. No mutable run state or global discovery.

@export var definitions: Array[ContentDefinition] = []
@export_file("*.json") var fishing_area_layout_path: String = ""
