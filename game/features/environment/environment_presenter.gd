class_name EnvironmentPresenter
extends Node
## One root-owned writer. No timer, session copy, scene listener or saved state.

var weather: WeatherVisuals.Sample
var sun: DirectionalLight3D
var world_environment: WorldEnvironment
var profile: LocationDefinition.LightingProfile = LocationDefinition.LightingProfile.STABLE_INDOOR


func initialize(light: DirectionalLight3D, world: WorldEnvironment) -> void:
	sun = light
	world_environment = world
	# Each root owns its environment; never edit the PackedScene/shared resource.
	world_environment.environment = world_environment.environment.duplicate(true) as Environment


func present(authored_profile: LocationDefinition.LightingProfile, progress: float, weather_sample: WeatherVisuals.Sample = null) -> bool:
	if authored_profile not in [LocationDefinition.LightingProfile.STABLE_INDOOR, LocationDefinition.LightingProfile.OUTDOOR_CYCLE]:
		return false
	var lighting: EnvironmentLighting.Sample = EnvironmentLighting.sample(progress)
	if lighting == null or not is_instance_valid(sun) or not is_instance_valid(world_environment):
		return false
	weather = weather_sample
	profile = authored_profile
	var environment: Environment = world_environment.environment
	sun.shadow_enabled = true
	if profile == LocationDefinition.LightingProfile.STABLE_INDOOR:
		sun.rotation_degrees = Vector3(-55, -25, 0)
		sun.light_color = Color(1, .89, .73)
		sun.light_energy = 1.1
		sun.shadow_opacity = 1.0
		environment.ambient_light_color = Color(.65, .76, .86)
		environment.ambient_light_energy = .65
		environment.background_color = Color(.055, .075, .095)
	else:
		sun.basis = Basis.looking_at(lighting.sun_direction, Vector3.UP)
		sun.light_color = lighting.direct_color
		sun.light_energy = lighting.direct_energy
		sun.shadow_opacity = lighting.shadow_opacity
		environment.ambient_light_color = lighting.ambient_color
		environment.ambient_light_energy = lighting.ambient_energy
		environment.background_color = lighting.background_color
		if weather != null:
			# Neutral cloud fill preserves painted hues and readable nighttime paths.
			sun.light_color = sun.light_color.lerp(Color(.78, .82, .88), weather.overcast * .42)
			sun.light_energy *= lerpf(1.0, .42, weather.overcast)
			sun.shadow_opacity *= lerpf(1.0, .16, weather.overcast)
			environment.ambient_light_color = environment.ambient_light_color.lerp(Color(.62, .67, .75), weather.overcast * .45)
			environment.ambient_light_energy = maxf(.54, environment.ambient_light_energy * lerpf(1.0, .90, weather.overcast)) + weather.flash
			environment.background_color = environment.background_color.lerp(Color(.055, .065, .080), weather.overcast * .65) + Color(.32, .38, .46) * weather.flash
	return true
