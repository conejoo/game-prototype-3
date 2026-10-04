import 'dart:math';

import '../day_night/day_night_clock.dart';

/// Stable player-facing weather states for exterior maps.
enum WeatherCondition {
  sunny('Sunny'),
  cloudy('Cloudy'),
  rainy('Cloudy with rain'),
  thunderstorm('Cloudy with rain and lightning');

  const WeatherCondition(this.label);

  final String label;

  bool get hasRain => this == rainy || this == thunderstorm;
  bool get hasLightning => this == thunderstorm;
}

/// One deterministic weather period sampled from the durable game clock.
class WeatherSample {
  const WeatherSample({
    required this.condition,
    required this.previousCondition,
    required this.periodIndex,
    required this.periodStartMinutes,
    required this.periodEndMinutes,
    required this.transitionProgress,
  });

  final WeatherCondition condition;
  final WeatherCondition previousCondition;
  final int periodIndex;
  final double periodStartMinutes;
  final double periodEndMinutes;

  /// Visual blend from [previousCondition] to [condition].
  final double transitionProgress;
}

/// Produces a stable per-save forecast without persisting a mutable cursor.
abstract final class WeatherSchedule {
  static const maximumSeed = 0xffffffff;
  static const defaultSeed = 0x6c8e9cf5;
  static const minimumPeriodMinutes = 4 * 60;
  static const maximumPeriodMinutes = 8 * 60;
  static const transitionMinutes = 15.0;

  static WeatherSample sample({
    required int seed,
    required int dayIndex,
    required double dayCycleProgress,
  }) {
    validateSeed(seed);
    if (dayIndex < 0) {
      throw ArgumentError.value(
        dayIndex,
        'dayIndex',
        'Day index must be non-negative.',
      );
    }
    if (!dayCycleProgress.isFinite ||
        dayCycleProgress < 0 ||
        dayCycleProgress >= 1) {
      throw ArgumentError.value(
        dayCycleProgress,
        'dayCycleProgress',
        'Day cycle progress must be in the range [0, 1).',
      );
    }

    final absoluteMinutes =
        dayIndex * DayNightClock.minutesPerDay +
        dayCycleProgress * DayNightClock.minutesPerDay;
    var periodIndex = 0;
    var periodStart = 0.0;
    var previous = WeatherCondition.sunny;
    var current = WeatherCondition.sunny;
    var periodEnd = _periodDuration(seed, periodIndex).toDouble();

    while (absoluteMinutes >= periodEnd) {
      previous = current;
      periodIndex++;
      periodStart = periodEnd;
      current = _nextCondition(seed, periodIndex, previous);
      periodEnd += _periodDuration(seed, periodIndex);
    }

    final transitionProgress = periodIndex == 0
        ? 1.0
        : ((absoluteMinutes - periodStart) / transitionMinutes)
              .clamp(0.0, 1.0)
              .toDouble();
    return WeatherSample(
      condition: current,
      previousCondition: previous,
      periodIndex: periodIndex,
      periodStartMinutes: periodStart,
      periodEndMinutes: periodEnd,
      transitionProgress: transitionProgress,
    );
  }

  static void validateSeed(int seed) {
    if (seed < 0 || seed > maximumSeed) {
      throw ArgumentError.value(
        seed,
        'weatherSeed',
        'Weather seed must be an unsigned 32-bit integer.',
      );
    }
  }

  static int _periodDuration(int seed, int periodIndex) =>
      minimumPeriodMinutes +
      _mix(seed, periodIndex, 0x5f356495) %
          (maximumPeriodMinutes - minimumPeriodMinutes + 1);

  static WeatherCondition _nextCondition(
    int seed,
    int periodIndex,
    WeatherCondition previous,
  ) {
    final roll = _mix(seed, periodIndex, 0x9e3779b9) % 100;
    return switch (previous) {
      WeatherCondition.sunny => WeatherCondition.cloudy,
      WeatherCondition.cloudy =>
        roll < 55 ? WeatherCondition.sunny : WeatherCondition.rainy,
      WeatherCondition.rainy =>
        roll < 65 ? WeatherCondition.cloudy : WeatherCondition.thunderstorm,
      WeatherCondition.thunderstorm =>
        roll < 75 ? WeatherCondition.rainy : WeatherCondition.cloudy,
    };
  }

  static int _mix(int seed, int periodIndex, int salt) {
    var value = (seed ^ ((periodIndex + 1) * 0x9e3779b9) ^ salt) & maximumSeed;
    value = (value ^ (value >> 16)) & maximumSeed;
    value = (value * 0x7feb352d) & maximumSeed;
    value = (value ^ (value >> 15)) & maximumSeed;
    value = (value * 0x846ca68b) & maximumSeed;
    return (value ^ (value >> 16)) & maximumSeed;
  }
}

abstract interface class WeatherSeedSource {
  int nextSeed();
}

final class RandomWeatherSeedSource implements WeatherSeedSource {
  RandomWeatherSeedSource({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  int nextSeed() => (_random.nextInt(1 << 16) << 16) | _random.nextInt(1 << 16);
}

final class FixedWeatherSeedSource implements WeatherSeedSource {
  const FixedWeatherSeedSource(this.seed);

  final int seed;

  @override
  int nextSeed() {
    WeatherSchedule.validateSeed(seed);
    return seed;
  }
}
