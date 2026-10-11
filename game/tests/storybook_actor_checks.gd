extends SceneTree
const PAINT: Script = preload("res://features/actors/storybook_actor_material.gd")
var failures: PackedStringArray = []
var assertions: int = 0
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game); await game.world_host.transition_finished
	game._set_paused(true)
	var hero: ActorPlaceholder = game.player_placeholder
	var ally: ActorPlaceholder = game.companion
	var guardian: ActorPlaceholder = load("res://features/combat/guardian.tscn").instantiate()
	game.add_child(guardian)
	guardian.initialize(ActorState.new("ad013-review",game.catalog.get_actor("prototype-guardian")))
	for actor: ActorPlaceholder in [hero,ally,guardian]:
		var shape: CapsuleShape3D = actor.get_node("CollisionShape3D").shape
		_check(is_equal_approx(shape.radius,.35) and is_equal_approx(shape.height,1.6),"original capsule hitbox")
		_check(actor.get_node("CollisionShape3D").position == Vector3(0,.8,0),"original collision feet")
		var meshes: Array[MeshInstance3D] = PAINT._meshes(actor.visual_root)
		for mesh: MeshInstance3D in meshes:
			if mesh.name == "Heading": continue
			for surface: int in range(mesh.mesh.get_surface_count()):
				var source: StandardMaterial3D = mesh.mesh.surface_get_material(surface)
				var material: ShaderMaterial = mesh.get_active_material(surface)
				_check(material.shader == PAINT.SHADER and material.get_shader_parameter("painted_atlas") == PAINT.ATLAS,"shared paint")
				_check(source.albedo_texture == null,"original untextured asset retained")
				_check(material.get_shader_parameter("source_metallic") == source.metallic,"metal semantic")
				var emission: Color = source.emission*source.emission_energy_multiplier if source.emission_enabled else Color.BLACK
				_check(material.get_shader_parameter("source_emission") == emission,"exact source emission")
				_check(material.get_shader_parameter("role_fill") == (0.0 if actor == guardian else 0.045),"bounded role fill")
				if actor == guardian:
					_check(PAINT._material(source.duplicate(),"guardian") == material,"reload-equivalent material key reuse")
				if actor != guardian:
					_check(mesh.mesh is CapsuleMesh and is_equal_approx(mesh.mesh.radius,.35) and is_equal_approx(mesh.mesh.height,1.6),"prototype capsule retained")
					_check(material.get_shader_parameter("base_color") == (PAINT.HERO if actor == hero else PAINT.ALLY),"cyan/purple roles")
		var before: int = PAINT.materials.size()
		PAINT.apply(actor)
		_check(PAINT.materials.size() == before,"no per-apply material allocation")
		actor.combat_enabled = true
		actor.combat.cancel(); actor.combat.hit_flash = 0
		actor._update_feedback()
		_check(not actor.combat_marker.visible and actor.visual_root.scale == Vector3.ONE,"idle feedback")
		_check(actor.request_attack(),"attack accepted")
		actor._update_feedback()
		_check(actor.combat_marker.visible and actor.combat_marker.material_override.albedo_color == Color(1,.72,.1),"gold windup")
		actor.combat.advance(actor.combat.windup); actor._update_feedback()
		_check(actor.combat.active() and actor.combat_marker.material_override.albedo_color == Color(1,.2,.12),"red active boundary")
		actor.combat.advance(actor.combat.active_time); actor._update_feedback()
		_check(not actor.combat.active() and actor.combat.busy() and actor.combat_marker.material_override.albedo_color == Color(1,.72,.1),"gold recovery boundary")
		actor.combat.advance(actor.combat.recovery+0.000001); actor._update_feedback()
		_check(not actor.combat.busy() and not actor.combat_marker.visible,"attack end boundary")
		_check(actor.request_dodge(Vector3.RIGHT),"dodge accepted")
		actor._update_feedback()
		_check(actor.combat_marker.material_override.albedo_color == Color(.2,.8,1) and not actor.receive_damage(25),"cyan invulnerable dodge")
		actor.combat.advance(.30)
		_check(actor.receive_damage(25),"damage after dodge")
		actor._update_feedback()
		_check(actor.combat.hit_flash == .18 and actor.combat_marker.material_override.albedo_color == Color.WHITE and is_equal_approx(actor.visual_root.scale.y,.8),"white damage/squash")
		actor.combat.advance(.179); actor._update_feedback()
		_check(actor.combat.hit_flash > 0 and actor.combat_marker.visible,"flash retained before 0.18 seconds")
		actor.combat.advance(.001001); actor._update_feedback()
		_check(not actor.combat_marker.visible and actor.visual_root.scale.y == 1,"flash ends at original boundary")
		_check(actor.receive_damage(100),"death")
		actor._update_feedback()
		_check(not actor.combat_marker.visible and is_equal_approx(actor.visual_root.scale.y,.18) and actor.collision_layer == 0,"flattened death/no collision")
		_check(not actor.request_attack() and not actor.request_dodge(Vector3.RIGHT),"dead actors reject combat")
	_check(PAINT.materials.size() == 7,"two capsule plus five guardian material keys")
	_check(SaveCodec.SCHEMA_VERSION == 8 and SaveCodec.CONTENT_VERSION == 1,"save/content versions")
	if not TestRunEvidence.write_json("actor-material-checks.json",{"task":"AD013","kind":"synthetic isolated feedback/rules and resource checks","assertions":assertions,"failures":failures,"cache_keys":PAINT.materials.size()}): failures.append("report")
	game.queue_free(); await process_frame; paused = false
	for failure: String in failures: push_error(failure)
	print("AD013 actor material checks: ",assertions," assertions; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
func _check(ok: bool,message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)
