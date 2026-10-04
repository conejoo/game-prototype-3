class_name EnvironmentLighting
extends RefCounted
## Pure presentation sampling. Source knots/shadow sense adapted to physical 3D.

class Sample:
	extends RefCounted
	var direct_color: Color
	var direct_energy: float
	var ambient_color: Color
	var ambient_energy: float
	var background_color: Color
	var shadow_opacity: float
	var sun_direction: Vector3

const KNOTS: PackedFloat64Array = [0.0, 0.25, 0.30, 0.375, 0.50, 0.75, 0.80, 0.875, 0.96, 1.0]
const DIRECT_COLORS: Array[Color] = [Color(1,.89,.73), Color(1,.77,.54), Color(1,.65,.43), Color(1,.50,.34), Color(.42,.52,.90), Color(.42,.52,.90), Color(.52,.57,.85), Color(.76,.62,.91), Color(1,.82,.65), Color(1,.89,.73)]
const DIRECT_ENERGIES: PackedFloat64Array = [1.1, 1.0, .86, .65, .18, .18, .28, .65, 1.02, 1.1]
const AMBIENT_COLORS: Array[Color] = [Color(.65,.76,.86), Color(.70,.69,.80), Color(.69,.62,.77), Color(.62,.55,.74), Color(.36,.46,.74), Color(.36,.46,.74), Color(.43,.48,.73), Color(.60,.57,.78), Color(.67,.72,.83), Color(.65,.76,.86)]
const AMBIENT_ENERGIES: PackedFloat64Array = [.65, .60, .55, .50, .48, .48, .50, .54, .62, .65]
const BACKGROUNDS: Array[Color] = [Color(.055,.075,.095), Color(.085,.065,.085), Color(.10,.05,.07), Color(.07,.035,.07), Color(.014,.022,.065), Color(.014,.022,.065), Color(.035,.04,.08), Color(.075,.055,.095), Color(.065,.07,.09), Color(.055,.075,.095)]
const SHADOWS: PackedFloat64Array = [.85, .95, .90, .75, 0.0, 0.0, .45, .95, .90, .85]
const SHADOW_X: PackedFloat64Array = [.05, .28, .36, .50, .50, -.50, -.50, -.34, -.08, .05]
const SHADOW_Z: PackedFloat64Array = [.03, .12, .15, .20, .20, .20, .20, .14, .05, .03]


static func sample(progress: float) -> Sample:
	if not EnvironmentClock.validate(0, progress).is_empty():
		return null
	var right: int = 1
	while KNOTS[right] < progress:
		right += 1
	var left: int = right - 1
	var linear: float = (progress - KNOTS[left]) / (KNOTS[right] - KNOTS[left])
	var blend: float = linear * linear * (3.0 - 2.0 * linear)
	var result: Sample = Sample.new()
	result.direct_color = DIRECT_COLORS[left].lerp(DIRECT_COLORS[right], blend)
	result.direct_energy = lerpf(DIRECT_ENERGIES[left], DIRECT_ENERGIES[right], blend)
	result.ambient_color = AMBIENT_COLORS[left].lerp(AMBIENT_COLORS[right], blend)
	result.ambient_energy = lerpf(AMBIENT_ENERGIES[left], AMBIENT_ENERGIES[right], blend)
	result.background_color = BACKGROUNDS[left].lerp(BACKGROUNDS[right], blend)
	result.shadow_opacity = lerpf(SHADOWS[left], SHADOWS[right], blend)
	# East=+X, south=+Z. Incoming rays point down and toward the cast shadow.
	# Preserve source horizontal sense, avoiding grazing rays/long unstable shadows.
	result.sun_direction = Vector3(2.0 * lerpf(SHADOW_X[left], SHADOW_X[right], blend), -1.0, 2.0 * lerpf(SHADOW_Z[left], SHADOW_Z[right], blend)).normalized()
	return result
