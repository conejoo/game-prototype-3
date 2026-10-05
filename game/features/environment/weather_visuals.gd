class_name WeatherVisuals
extends RefCounted
## Detached render values from forecast and authoritative active clock.

class Sample:
	extends RefCounted
	var overcast: float = 0.0
	var rain: float = 0.0
	var storm: float = 0.0
	var flash: float = 0.0
	var phase_seconds: float = 0.0

const OVERCAST: PackedFloat64Array = [0.0, .55, .8, 1.0]
const RAIN: PackedFloat64Array = [0.0, 0.0, .48, 1.0]
const STORM: PackedFloat64Array = [0.0, 0.0, 0.0, 1.0]
const FLASH_INTERVAL: float = 8.0
const FLASH_DURATION: float = .32
const FLASH_PEAK: float = .18


static func sample(forecast: WeatherSchedule.Sample, seed: int, seconds: float) -> Sample:
	if forecast == null or not WeatherSchedule.valid_seed(seed) or not is_finite(seconds) or seconds < 0.0:
		return null
	if forecast.condition < 0 or forecast.condition > 3 or forecast.previous_condition < 0 or forecast.previous_condition > 3:
		return null
	var linear: float = forecast.transition_progress
	if not is_finite(linear) or linear < 0.0 or linear > 1.0:
		return null
	var blend: float = linear * linear * (3.0 - 2.0 * linear)
	var result: Sample = Sample.new()
	result.overcast = lerpf(OVERCAST[forecast.previous_condition], OVERCAST[forecast.condition], blend)
	result.rain = lerpf(RAIN[forecast.previous_condition], RAIN[forecast.condition], blend)
	result.storm = lerpf(STORM[forecast.previous_condition], STORM[forecast.condition], blend)
	# 64 seconds is exactly forty rain cycles; prevents float shader drift on long saves.
	result.phase_seconds = fposmod(seconds, 64.0)
	result.flash = lightning(seed, seconds) * result.storm
	return result


static func lightning(seed: int, seconds: float) -> float:
	if not WeatherSchedule.valid_seed(seed) or not is_finite(seconds) or seconds < 0:
		return 0.0
	var interval: int = floori(seconds / FLASH_INTERVAL)
	var roll: int = WeatherSchedule.mix(seed, interval, 0x374fa821)
	if roll % 3 != 0:
		return 0.0
	var start: float = 1.0 + float((roll >> 8) % 4000) / 1000.0
	var local: float = fposmod(seconds, FLASH_INTERVAL) - start
	if local < 0 or local >= FLASH_DURATION:
		return 0.0
	# Smooth single atmospheric pulse, no gameplay signal or additional shadow light.
	var pulse: float = sin(PI * local / FLASH_DURATION)
	return FLASH_PEAK * pulse * pulse
