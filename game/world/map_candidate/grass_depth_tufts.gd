extends RefCounted
## GD005:52 fuller upright groups; efficient two-triangle blades, one opaque batch.
## Roots sit outside the actual stone faces, with staggered pockets around GD003 low cover.
const ORIGINAL_GROUPS: Array[Vector4] = [
    # Facade: two irregular six-clump pockets; central door lane stays open.
    Vector4(-18.70,1.93,.23,1.852), Vector4(-18.51,2.10,.19,1.852),
    Vector4(-18.33,1.95,.25,1.852), Vector4(-17.91,1.94,.22,1.852),
    Vector4(-17.69,2.14,.18,1.852), Vector4(-17.43,1.99,.24,1.852),
    Vector4(-14.68,1.94,.22,1.852), Vector4(-14.49,2.12,.18,1.852),
    Vector4(-14.28,1.97,.25,1.852), Vector4(-13.90,1.93,.23,1.852),
    Vector4(-13.70,2.15,.19,1.852), Vector4(-13.42,1.98,.24,1.852),
    # Wall: three-clump pockets, with visible dirt gaps between pockets.
    Vector4(-17.78,5.05,.22,4.977), Vector4(-17.60,5.19,.19,4.977),
    Vector4(-17.40,5.06,.25,4.977), Vector4(-16.95,5.08,.24,4.977),
    Vector4(-16.79,5.24,.20,4.977), Vector4(-16.56,5.04,.23,4.977),
    Vector4(-15.88,5.07,.21,4.977), Vector4(-15.70,5.19,.25,4.977),
    Vector4(-15.47,5.04,.18,4.977), Vector4(-14.74,5.07,.24,4.977),
    Vector4(-14.51,5.22,.19,4.977), Vector4(-14.27,5.06,.23,4.977),
    # Corner: staggered pockets around both arms of the existing elbow.
    Vector4(-13.23,3.96,.23,-100), Vector4(-13.05,4.09,.19,-100),
    Vector4(-12.89,3.91,.25,-100), Vector4(-12.69,4.03,.22,-100),
    Vector4(-12.55,3.84,.24,-100), Vector4(-12.72,3.69,.18,-100),
    Vector4(-12.48,3.53,.23,-100), Vector4(-12.64,3.41,.20,-100),
    Vector4(-12.50,3.21,.25,-100), Vector4(-12.68,3.04,.18,-100),
    Vector4(-12.49,2.88,.22,-100), Vector4(-12.63,2.72,.19,-100),
]
const GROUPS: Array[Vector4] = [
    # Facade: two irregular six-clump pockets; central door lane stays open.
    Vector4(-18.70,1.93,.23,1.852), Vector4(-18.51,2.10,.19,1.852),
    Vector4(-18.33,1.95,.25,1.852), Vector4(-17.91,1.94,.22,1.852),
    Vector4(-17.69,2.14,.18,1.852), Vector4(-17.43,1.99,.24,1.852),
    Vector4(-14.68,1.94,.22,1.852), Vector4(-14.49,2.12,.18,1.852),
    Vector4(-14.28,1.97,.25,1.852), Vector4(-13.90,1.93,.23,1.852),
    Vector4(-13.70,2.15,.19,1.852), Vector4(-13.42,1.98,.24,1.852),
    # Wall: three-clump pockets, with visible dirt gaps between pockets.
    Vector4(-17.78,5.05,.22,4.977), Vector4(-17.60,5.19,.19,4.977),
    Vector4(-17.40,5.06,.25,4.977), Vector4(-16.95,5.08,.24,4.977),
    Vector4(-16.79,5.24,.20,4.977), Vector4(-16.56,5.04,.23,4.977),
    Vector4(-15.88,5.07,.21,4.977), Vector4(-15.70,5.19,.25,4.977),
    Vector4(-15.47,5.04,.18,4.977), Vector4(-14.74,5.07,.24,4.977),
    Vector4(-14.51,5.22,.19,4.977), Vector4(-14.27,5.06,.23,4.977),
    # Corner: staggered pockets around both arms of the existing elbow.
    Vector4(-13.23,3.96,.23,-100), Vector4(-13.05,4.09,.19,-100),
    Vector4(-12.89,3.91,.25,-100), Vector4(-12.69,4.03,.22,-100),
    Vector4(-12.55,3.84,.24,-100), Vector4(-12.72,3.69,.18,-100),
    Vector4(-12.48,3.53,.23,-100), Vector4(-12.64,3.41,.20,-100),
    Vector4(-12.50,3.21,.25,-100), Vector4(-12.68,3.04,.18,-100),
    Vector4(-12.49,2.88,.22,-100), Vector4(-12.63,2.72,.19,-100),
    # Additional staggered roots fill selected pockets; doorway stays clear.
    Vector4(-18.56,2.23,.20,1.852), Vector4(-18.10,2.10,.24,1.852),
    Vector4(-17.62,1.96,.21,1.852), Vector4(-14.62,2.24,.23,1.852),
    Vector4(-14.12,2.11,.20,1.852), Vector4(-13.66,1.95,.24,1.852),
    Vector4(-17.31,5.16,.22,4.977), Vector4(-16.48,5.09,.21,4.977),
    Vector4(-15.96,5.25,.23,4.977), Vector4(-15.16,5.10,.20,4.977),
    Vector4(-14.59,5.10,.24,4.977), Vector4(-13.20,3.74,.22,-100),
    Vector4(-12.97,3.67,.24,-100), Vector4(-12.78,3.48,.20,-100),
    Vector4(-12.60,3.29,.23,-100), Vector4(-12.70,2.92,.21,-100),
]
const ORIGINAL_COLORS: Array[Color] = [Color("657c3b"),Color("7e9149"),Color("556f37"),Color("8c9b52")]
const COLORS: Array[Color] = [Color("7b9545"), Color("8ca44f"), Color("6f8d3f"), Color("9bb35c")]

static func command_enabled() -> bool:
    return preload("res://world/map_candidate/grass_pilot_material.gd").command_variant() == "a" and "--grass-depth=tufts" in OS.get_cmdline_user_args()

static func groups(original_look: bool = false) -> Array[Vector4]:
    return ORIGINAL_GROUPS if original_look else GROUPS

static func build(original_look: bool = false) -> MeshInstance3D:
    original_look = original_look or "--grass-look=original" in OS.get_cmdline_user_args()
    var palette: Array[Color] = ORIGINAL_COLORS if original_look else COLORS
    var surface: SurfaceTool = SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    var rng: RandomNumberGenerator = RandomNumberGenerator.new()
    rng.seed = 4004
    var blades: int = 0
    for group: Vector4 in groups(original_look):
        var count: int = rng.randi_range(8,9) if original_look else rng.randi_range(10,11)
        for blade: int in range(count):
            var angle: float = rng.randf_range(0,TAU)
            var direction: Vector2 = Vector2(cos(angle),sin(angle))
            var side: Vector2 = Vector2(-direction.y,direction.x)
            var foot: Vector2 = Vector2(group.x,group.y) + Vector2(rng.randf_range(-.035,.035),rng.randf_range(-.025,.025))
            var height: float = group.z * rng.randf_range(.65,1.0)
            var lean: float = rng.randf_range(.055,.14)
            var width: float = rng.randf_range(.030,.050) if original_look else rng.randf_range(.014,.026)
            var middle: Vector2 = foot + direction * lean * .35
            var tip: Vector2 = foot + direction * lean
            var points: Array[Vector3] = []
            for item: Vector3 in [Vector3(foot.x-side.x*width*.45,.010,foot.y-side.y*width*.45),
                Vector3(foot.x+side.x*width*.45,.010,foot.y+side.y*width*.45),
                Vector3(middle.x-side.x*width,height*.53,middle.y-side.y*width),
                Vector3(middle.x+side.x*width,height*.53,middle.y+side.y*width),
                Vector3(tip.x,height,tip.y)]:
                item.z = maxf(item.z,group.w)
                points.append(item)
            var color: Color = palette[rng.randi_range(0,palette.size()-1)].srgb_to_linear()
            if original_look:
                for index: int in [0,2,1,1,2,3,2,4,3]:
                    surface.set_normal(Vector3.UP)
                    surface.set_color(color)
                    surface.add_vertex(points[index])
            else:
                # A tapered diamond keeps silhouette with two triangles per blade.
                var root: Vector3 = (points[0] + points[1]) * .5
                var compact: Array[Vector3] = [root,points[2],points[4],points[3]]
                for index: int in [0,1,3,1,2,3]:
                    surface.set_normal(Vector3.UP)
                    surface.set_color(color)
                    surface.add_vertex(compact[index])
            blades += 1
    var visual: MeshInstance3D = MeshInstance3D.new()
    visual.name = "GrassDepthTufts"
    visual.mesh = surface.commit()
    var material: StandardMaterial3D = StandardMaterial3D.new()
    material.vertex_color_use_as_albedo = true
    material.roughness = .97
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    visual.material_override = material
    visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    visual.set_meta("grass_depth_visual_inventory", {"look":"original" if original_look else "soft", "clumps":groups(original_look).size(),"blades":blades,"triangles":blades*(3 if original_look else 2),
        "meshes":1,"batches":1,"materials":1,"textures":0,"decoded_texture_bytes":0,
        "height_m":[.010,.25],"collision":false,"navigation":false,"opaque":true,"seed":4004})
    return visual
