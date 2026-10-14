extends RefCounted
## GD003: sparse opaque low rosettes. Visual-only; no physics/nav participation.
## XYZ roots and minimum south Z follow actual imported facade/wall surfaces.
const GROUPS: Array[Vector4] = [
    Vector4(-18.53, 1.91, .85, 1.852),
    Vector4(-17.58, 1.94, 1.10, 1.852),
    Vector4(-14.56, 1.92, .97, 1.852),
    Vector4(-13.63, 1.94, 1.12, 1.852),
    Vector4(-17.73, 5.04, .92, 4.977),
    Vector4(-16.93, 5.08, 1.18, 4.977),
    Vector4(-15.61, 5.03, .80, 4.977),
    Vector4(-14.33, 5.07, 1.04, 4.977),
    Vector4(-13.13, 3.98, .90, -100.0),
    Vector4(-12.68, 3.94, 1.05, -100.0),
    Vector4(-12.53, 3.57, .94, -100.0),
    Vector4(-12.52, 3.15, .72, -100.0),
]
const ORIGINAL_COLORS: Array[Color] = [Color("657c3b"), Color("7e9149"), Color("556f37"), Color("8c9b52")]
const COLORS: Array[Color] = [Color("7b9545"), Color("8ca44f"), Color("6f8d3f"), Color("9bb35c")]

static func command_enabled() -> bool:
    return preload("res://world/map_candidate/grass_pilot_material.gd").command_variant() == "a" and ("--grass-depth=edges" in OS.get_cmdline_user_args() or "--grass-depth=tufts" in OS.get_cmdline_user_args())

static func build(original_look: bool = false) -> MeshInstance3D:
    original_look = original_look or "--grass-look=original" in OS.get_cmdline_user_args()
    var palette: Array[Color] = ORIGINAL_COLORS if original_look else COLORS
    var surface: SurfaceTool = SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    var rng: RandomNumberGenerator = RandomNumberGenerator.new()
    rng.seed = 3003
    var leaves: int = 0
    for group: Vector4 in GROUPS:
        var count: int = rng.randi_range(6, 9)
        for leaf: int in range(count):
            var angle: float = rng.randf_range(0, TAU)
            var direction: Vector2 = Vector2(cos(angle), sin(angle))
            var side: Vector2 = Vector2(-direction.y, direction.x)
            var root: Vector2 = Vector2(group.x, group.y) + Vector2(rng.randf_range(-.045,.045), rng.randf_range(-.035,.035))
            var length: float = rng.randf_range(.14,.26) * group.z
            var width: float = (rng.randf_range(.038,.074) if original_look else rng.randf_range(.020,.040)) * group.z
            # Rounded tapered leaf, six triangles around a shallow central ridge.
            var ring: Array[Vector2] = [root, root + direction * length * .30 + side * width * .78,
                root + direction * length * .68 + side * width, root + direction * length,
                root + direction * length * .68 - side * width, root + direction * length * .30 - side * width * .78]
            var center: Vector2 = root + direction * length * .52
            var color: Color = palette[rng.randi_range(0, palette.size()-1)]
            var ridge: float = rng.randf_range(.028,.048)
            if original_look:
                for index: int in range(ring.size()):
                    # Clamp only object-side leaves; never paint through visible stone.
                    var a: Vector2 = ring[index]
                    var b: Vector2 = ring[(index+1)%ring.size()]
                    a.y = maxf(a.y, group.w)
                    b.y = maxf(b.y, group.w)
                    center.y = maxf(center.y, group.w)
                    var vertices: Array[Vector3] = [Vector3(center.x,ridge,center.y), Vector3(b.x,.014,b.y), Vector3(a.x,.014,a.y)]
                    for vertex: Vector3 in vertices:
                        surface.set_normal(Vector3.UP)
                        surface.set_color(color.srgb_to_linear())
                        surface.add_vertex(vertex)
            else:
                for index: int in [0,2,1,0,3,2,0,4,3,0,5,4]:
                    var point: Vector2 = ring[index]
                    point.y = maxf(point.y,group.w)
                    surface.set_normal(Vector3.UP)
                    surface.set_color(color.srgb_to_linear())
                    surface.add_vertex(Vector3(point.x,.014 if index in [0,3] else ridge,point.y))
            leaves += 1
    var visual: MeshInstance3D = MeshInstance3D.new()
    visual.name = "GrassDepthEdges"
    visual.mesh = surface.commit()
    var material: StandardMaterial3D = StandardMaterial3D.new()
    material.vertex_color_use_as_albedo = true
    material.roughness = .97
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    visual.material_override = material
    visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    visual.set_meta("grass_depth_visual_inventory", {"look":"original" if original_look else "soft", "clumps":GROUPS.size(),"leaves":leaves,"triangles":leaves*(6 if original_look else 4),
        "meshes":1,"batches":1,"materials":1,"textures":0,"decoded_texture_bytes":0,
        "height_m":[.014,.048],"collision":false,"navigation":false,"opaque":true})
    return visual
