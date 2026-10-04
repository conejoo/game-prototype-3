import 'dart:ui';

import 'package:flame/components.dart';

import '../../world_map/world_map.dart';
import '../cozy_adventure_game.dart';
import '../day_night/day_night_clock.dart';
import '../world/world_geometry.dart';
import '../world/world_render_priority.dart';
import 'weather_schedule.dart';

class WeatherVisualState {
  const WeatherVisualState({
    required this.ambienceOpacity,
    required this.shadowOpacityMultiplier,
    required this.rainStreakCount,
    required this.rainOpacity,
  });

  static const clear = WeatherVisualState(
    ambienceOpacity: 0,
    shadowOpacityMultiplier: 1,
    rainStreakCount: 0,
    rainOpacity: 0,
  );

  final double ambienceOpacity;
  final double shadowOpacityMultiplier;
  final double rainStreakCount;
  final double rainOpacity;

  static WeatherVisualState forCondition(WeatherCondition condition) =>
      switch (condition) {
        WeatherCondition.sunny => clear,
        WeatherCondition.cloudy => const WeatherVisualState(
          ambienceOpacity: 0.10,
          shadowOpacityMultiplier: 0.55,
          rainStreakCount: 0,
          rainOpacity: 0,
        ),
        WeatherCondition.rainy => const WeatherVisualState(
          ambienceOpacity: 0.14,
          shadowOpacityMultiplier: 0.25,
          rainStreakCount: 96,
          rainOpacity: 0.28,
        ),
        WeatherCondition.thunderstorm => const WeatherVisualState(
          ambienceOpacity: 0.18,
          shadowOpacityMultiplier: 0.10,
          rainStreakCount: 160,
          rainOpacity: 0.42,
        ),
      };

  static WeatherVisualState fromSample(WeatherSample sample) {
    final previous = forCondition(sample.previousCondition);
    final current = forCondition(sample.condition);
    final t = sample.transitionProgress;
    return WeatherVisualState(
      ambienceOpacity: _lerp(
        previous.ambienceOpacity,
        current.ambienceOpacity,
        t,
      ),
      shadowOpacityMultiplier: _lerp(
        previous.shadowOpacityMultiplier,
        current.shadowOpacityMultiplier,
        t,
      ),
      rainStreakCount: _lerp(
        previous.rainStreakCount,
        current.rainStreakCount,
        t,
      ),
      rainOpacity: _lerp(previous.rainOpacity, current.rainOpacity, t),
    );
  }

  static double _lerp(double left, double right, double t) =>
      left + (right - left) * t;
}

/// Cool overcast wash above day/night tint and below emissive light art.
class WeatherAmbienceComponent extends Component
    with HasGameReference<CozyAdventureGame> {
  WeatherAmbienceComponent({
    required WorldGeometry geometry,
    required this.mode,
  }) : mapBounds = Rect.fromLTRB(
         geometry.left,
         geometry.top,
         geometry.right,
         geometry.bottom,
       ),
       super(priority: WorldRenderPriority.weatherAmbience);

  static const ambienceColor = Color(0xFF667784);

  final Rect mapBounds;
  final WorldMapLightingMode mode;
  final Paint _paint = Paint()..style = PaintingStyle.fill;

  bool get isEnabled => mode == WorldMapLightingMode.outdoorCycle;

  WeatherVisualState get visualState => isEnabled
      ? WeatherVisualState.fromSample(game.currentWeather)
      : WeatherVisualState.clear;

  @override
  void render(Canvas canvas) {
    final opacity = visualState.ambienceOpacity;
    if (opacity <= 0.001) return;
    _paint.color = ambienceColor.withValues(alpha: opacity);
    canvas.drawRect(mapBounds, _paint);
  }
}

/// Camera-local procedural rain and deterministic thunderstorm sky flashes.
class WeatherEffectsComponent extends Component
    with HasGameReference<CozyAdventureGame> {
  WeatherEffectsComponent({required this.mode})
    : super(priority: WorldRenderPriority.weatherEffects);

  static const baselineVisibleArea = 480.0 * 270.0;
  static const maximumStreakCount = 200;
  static const lightningMaximumOpacity = 0.32;

  final WorldMapLightingMode mode;
  final Paint _rainPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.65
    ..strokeCap = StrokeCap.round;
  final Paint _flashPaint = Paint()..style = PaintingStyle.fill;

  bool get isEnabled => mode == WorldMapLightingMode.outdoorCycle;

  WeatherVisualState get visualState => isEnabled
      ? WeatherVisualState.fromSample(game.currentWeather)
      : WeatherVisualState.clear;

  int activeStreakCountFor(Rect visibleWorldRect) {
    if (!isEnabled) return 0;
    final areaScale =
        (visibleWorldRect.width * visibleWorldRect.height / baselineVisibleArea)
            .clamp(0.5, 1.5);
    return (visualState.rainStreakCount * areaScale).round().clamp(
      0,
      maximumStreakCount,
    );
  }

  double get lightningOpacity {
    if (!isEnabled || game.currentWeather.condition.hasLightning == false) {
      return 0;
    }
    final sample = game.currentWeather;
    final absoluteMinutes =
        game.runtimeState.dayIndex * DayNightClock.minutesPerDay +
        game.runtimeState.dayCycleProgress * DayNightClock.minutesPerDay;
    final secondsIntoPeriod =
        (absoluteMinutes - sample.periodStartMinutes) /
        DayNightClock.minutesPerDay *
        DayNightClock.cycleDurationSeconds;
    var strikeTime = _lightningInterval(0, sample.periodIndex);
    var strikeIndex = 0;
    while (strikeTime + 0.30 < secondsIntoPeriod) {
      strikeIndex++;
      strikeTime += _lightningInterval(strikeIndex, sample.periodIndex);
    }
    final phase = secondsIntoPeriod - strikeTime;
    if (phase >= 0 && phase < 0.08) {
      return lightningMaximumOpacity * (1 - phase / 0.08);
    }
    if (phase >= 0.18 && phase < 0.30) {
      return lightningMaximumOpacity * 0.8 * (1 - (phase - 0.18) / 0.12);
    }
    return 0;
  }

  @override
  void render(Canvas canvas) {
    if (!isEnabled) return;
    final visible = game.camera.visibleWorldRect;
    final streakCount = activeStreakCountFor(visible);
    if (streakCount > 0) {
      _renderRain(canvas, visible, streakCount);
    }
    final flashOpacity = lightningOpacity;
    if (flashOpacity > 0.001) {
      _flashPaint.color = const Color(
        0xFFE8F1FF,
      ).withValues(alpha: flashOpacity);
      canvas.drawRect(visible, _flashPaint);
    }
  }

  void _renderRain(Canvas canvas, Rect visible, int streakCount) {
    final opacity = visualState.rainOpacity;
    _rainPaint.color = const Color(0xFFC7DDF1).withValues(alpha: opacity);
    final elapsed = game.runtimeState.activePlaySeconds;
    for (var index = 0; index < streakCount; index++) {
      final streak = rainStreakFor(
        index: index,
        visibleWorldRect: visible,
        elapsedSeconds: elapsed,
      );
      canvas.drawLine(streak.start, streak.end, _rainPaint);
    }
  }

  /// Resolves one falling streak on a repeating world-space lattice.
  ///
  /// Camera movement only chooses which lattice repetition is visible. It
  /// never changes a streak's world position, so rain cannot follow the player
  /// or gain/lose world speed when the camera moves.
  RainStreakGeometry rainStreakFor({
    required int index,
    required Rect visibleWorldRect,
    required double elapsedSeconds,
  }) {
    final seed = game.runtimeState.weatherSeed;
    final travelWidth = visibleWorldRect.width;
    final travelHeight = visibleWorldRect.height + 48;
    final lowerY = visibleWorldRect.top - 24;
    final baseX = _unit(seed, index, 0x57a9) * travelWidth;
    final baseY =
        _unit(seed, index, 0x83d1) * travelHeight +
        elapsedSeconds * (140 + _unit(seed, index, 0xb529) * 80);
    final length = 4 + _unit(seed, index, 0x1b56) * 5;
    final start = Offset(
      visibleWorldRect.left + _wrap(baseX - visibleWorldRect.left, travelWidth),
      lowerY + _wrap(baseY - lowerY, travelHeight),
    );
    return RainStreakGeometry(
      start: start,
      end: Offset(start.dx - length * 0.42, start.dy + length),
    );
  }

  double _lightningInterval(int strikeIndex, int periodIndex) =>
      8 +
      _unit(game.runtimeState.weatherSeed ^ periodIndex, strikeIndex, 0xd4e1) *
          10;

  static double _unit(int seed, int index, int salt) {
    var value = (seed ^ ((index + 1) * 0x9e3779b9) ^ salt) & 0xffffffff;
    value = (value ^ (value >> 16)) & 0xffffffff;
    value = (value * 0x7feb352d) & 0xffffffff;
    value = (value ^ (value >> 15)) & 0xffffffff;
    value = (value * 0x846ca68b) & 0xffffffff;
    value = (value ^ (value >> 16)) & 0xffffffff;
    return value / 0xffffffff;
  }

  static double _wrap(double value, double period) =>
      value - (value / period).floor() * period;
}

class RainStreakGeometry {
  const RainStreakGeometry({required this.start, required this.end});

  final Offset start;
  final Offset end;
}
