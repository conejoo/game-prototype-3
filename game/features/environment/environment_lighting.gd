class_name EnvironmentLighting
extends RefCounted
## Pure presentation sampling. Painted palette; original knots/ray sense retained.

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
# Cream daylight, restrained apricot dusk and pale indigo moonlight. Broad fill
# keeps painted albedo groups readable without adding emission or post effects.
const DIRECT_COLORS: Array[Color] = [Color(1,.94,.83), Color(1,.86,.70), Color(1,.79,.64), Color(1,.72,.57), Color(.65,.70,.88), Color(.65,.70,.88), Color(.72,.72,.85), Color(.83,.75,.90), Color(1,.90,.77), Color(1,.94,.83)]
const DIRECT_ENERGIES: PackedFloat64Array = [.98, .92, .80, .62, .18, .18, .28, .62, .94, .98]
const AMBIENT_COLORS: Array[Color] = [Color(.73,.77,.80), Color(.76,.74,.79), Color(.74,.70,.77), Color(.70,.65,.77), Color(.62,.67,.80), Color(.62,.67,.80), Color(.65,.67,.79), Color(.70,.69,.80), Color(.73,.75,.81), Color(.73,.77,.80)]
const AMBIENT_ENERGIES: PackedFloat64Array = [.68, .66, .64, .62, .60, .60, .61, .63, .67, .68]
const BACKGROUNDS: Array[Color] = [Color(.065,.080,.090), Color(.090,.075,.090), Color(.105,.065,.080), Color(.085,.055,.080), Color(.025,.035,.065), Color(.025,.035,.065), Color(.045,.050,.080), Color(.080,.070,.095), Color(.075,.080,.090), Color(.065,.080,.090)]
const SHADOWS: PackedFloat64Array = [.62, .68, .65, .58, 0.0, 0.0, .35, .58, .62, .62]
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
