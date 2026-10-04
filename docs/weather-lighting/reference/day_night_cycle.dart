import 'dart:ui';

import 'day_night_clock.dart';

/// Player-facing portions of one visual day.
enum DayNightPhase {
  day('Day'),
  evening('Evening'),
  night('Night'),
  dawn('Dawn');

  const DayNightPhase(this.label);

  final String label;
}

/// Fully sampled visual state for one normalized point in the cycle.
class DayNightLighting {
  const DayNightLighting({
    required this.ambienceColor,
    required this.ambienceOpacity,
    required this.shadowDisplacement,
    required this.shadowOpacity,
    required this.lightOpacity,
  });

  final Color ambienceColor;
  final double ambienceOpacity;

  /// Cast-shadow displacement per displayed world-height unit.
  final Offset shadowDisplacement;
  final double shadowOpacity;
  final double lightOpacity;

  Color get ambienceTint => Color.fromRGBO(
    (ambienceColor.r * 255).round(),
    (ambienceColor.g * 255).round(),
    (ambienceColor.b * 255).round(),
    ambienceOpacity,
  );
}

final class _LightingKeyframe {
  const _LightingKeyframe(
    this.progress, {
    required this.ambienceColor,
    required this.ambienceOpacity,
    required this.shadowDisplacement,
    required this.shadowOpacity,
    required this.lightOpacity,
  });

  final double progress;
  final Color ambienceColor;
  final double ambienceOpacity;
  final Offset shadowDisplacement;
  final double shadowOpacity;
  final double lightOpacity;
}

/// Converts normalized day progress into visual-only presentation values.
abstract final class DayNightCycle {
  /// One complete visual day lasts ten minutes of active game-loop time.
  static const cycleDurationSeconds = DayNightClock.cycleDurationSeconds;

  /// Peak navy overlay remains dark while preserving gameplay readability.
  static const maximumTintOpacity = 0.58;

  static const shadowColor = Color(0xFF293268);

  /// Maximum absolute horizontal cast per source-height pixel.
  static const maximumShadowHorizontalDisplacement = 0.50;

  /// Maximum southward cast per source-height pixel.
  static const maximumShadowSouthDisplacement = 0.20;

  /// Minimum southward cast per source-height pixel in the shared cycle.
  static const minimumShadowSouthDisplacement = 0.03;

  static const _keyframes = <_LightingKeyframe>[
    _LightingKeyframe(
      0.00,
      ambienceColor: Color(0xFFFFE091),
      ambienceOpacity: 0.04,
      shadowDisplacement: Offset(0.05, minimumShadowSouthDisplacement),
      shadowOpacity: 0.34,
      lightOpacity: 0,
    ),
    _LightingKeyframe(
      0.25,
      ambienceColor: Color(0xFFFFAA6E),
      ambienceOpacity: 0.14,
      shadowDisplacement: Offset(0.28, 0.12),
      shadowOpacity: 0.38,
      lightOpacity: 0,
    ),
    _LightingKeyframe(
      0.30,
      ambienceColor: Color(0xFFE87959),
      ambienceOpacity: 0.18,
      shadowDisplacement: Offset(0.36, 0.15),
      shadowOpacity: 0.36,
      lightOpacity: 0,
    ),
    _LightingKeyframe(
      0.375,
      ambienceColor: Color(0xFFB23C40),
      ambienceOpacity: 0.22,
      shadowDisplacement: Offset(
        maximumShadowHorizontalDisplacement,
        maximumShadowSouthDisplacement,
      ),
      shadowOpacity: 0.30,
      lightOpacity: 0.42,
    ),
    _LightingKeyframe(
      0.50,
      ambienceColor: Color(0xFF0D1B4C),
      ambienceOpacity: maximumTintOpacity,
      shadowDisplacement: Offset(
        maximumShadowHorizontalDisplacement,
        maximumShadowSouthDisplacement,
      ),
      shadowOpacity: 0,
      lightOpacity: 1,
    ),
    _LightingKeyframe(
      0.75,
      ambienceColor: Color(0xFF0D1B4C),
      ambienceOpacity: maximumTintOpacity,
      shadowDisplacement: Offset(
        -maximumShadowHorizontalDisplacement,
        maximumShadowSouthDisplacement,
      ),
      shadowOpacity: 0,
      lightOpacity: 1,
    ),
    _LightingKeyframe(
      0.80,
      ambienceColor: Color(0xFF344171),
      ambienceOpacity: 0.45,
      shadowDisplacement: Offset(
        -maximumShadowHorizontalDisplacement,
        maximumShadowSouthDisplacement,
      ),
      shadowOpacity: 0.18,
      lightOpacity: 1,
    ),
    _LightingKeyframe(
      0.875,
      ambienceColor: Color(0xFF7B6AA5),
      ambienceOpacity: 0.24,
      shadowDisplacement: Offset(-0.34, 0.14),
      shadowOpacity: 0.38,
      lightOpacity: 0.62,
    ),
    _LightingKeyframe(
      0.96,
      ambienceColor: Color(0xFFD7A987),
      ambienceOpacity: 0.10,
      shadowDisplacement: Offset(-0.08, 0.05),
      shadowOpacity: 0.36,
      lightOpacity: 0,
    ),
    _LightingKeyframe(
      1.00,
      ambienceColor: Color(0xFFFFE091),
      ambienceOpacity: 0.04,
      shadowDisplacement: Offset(0.05, minimumShadowSouthDisplacement),
      shadowOpacity: 0.34,
      lightOpacity: 0,
    ),
  ];

  /// Advances [progress] by active [elapsedSeconds], wrapping at one cycle.
  static double advance(double progress, double elapsedSeconds) {
    _validateProgress(progress);
    if (!elapsedSeconds.isFinite || elapsedSeconds < 0) {
      throw ArgumentError.value(
        elapsedSeconds,
        'elapsedSeconds',
        'Elapsed seconds must be finite and non-negative.',
      );
    }

    return (progress + elapsedSeconds / cycleDurationSeconds) % 1.0;
  }

  static DayNightPhase phaseForProgress(double progress) {
    _validateProgress(progress);
    if (progress < 0.25) return DayNightPhase.day;
    if (progress < 0.50) return DayNightPhase.evening;
    if (progress < 0.75) return DayNightPhase.night;
    return DayNightPhase.dawn;
  }

  static String labelForProgress(double progress) =>
      phaseForProgress(progress).label;

  /// Smooth clean-HD lighting sample for [progress].
  static DayNightLighting lightingForProgress(double progress) {
    _validateProgress(progress);
    var rightIndex = 1;
    while (_keyframes[rightIndex].progress < progress) {
      rightIndex++;
    }
    final left = _keyframes[rightIndex - 1];
    final right = _keyframes[rightIndex];
    final span = right.progress - left.progress;
    final linear = span == 0 ? 0.0 : (progress - left.progress) / span;
    final t = linear * linear * (3 - 2 * linear);
    return DayNightLighting(
      ambienceColor: Color.fromARGB(
        255,
        _lerpInt(left.ambienceColor.r, right.ambienceColor.r, t),
        _lerpInt(left.ambienceColor.g, right.ambienceColor.g, t),
        _lerpInt(left.ambienceColor.b, right.ambienceColor.b, t),
      ),
      ambienceOpacity: _lerp(left.ambienceOpacity, right.ambienceOpacity, t),
      shadowDisplacement: Offset(
        _lerp(left.shadowDisplacement.dx, right.shadowDisplacement.dx, t),
        _lerp(left.shadowDisplacement.dy, right.shadowDisplacement.dy, t),
      ),
      shadowOpacity: _lerp(left.shadowOpacity, right.shadowOpacity, t),
      lightOpacity: _lerp(left.lightOpacity, right.lightOpacity, t),
    );
  }

  static double tintOpacityForProgress(double progress) =>
      lightingForProgress(progress).ambienceOpacity;

  static Color tintForProgress(double progress) =>
      lightingForProgress(progress).ambienceTint;

  /// Maps a cycle Y displacement into [0, 1] between its authored extrema.
  /// Values outside the current cycle range clamp, preserving a prop's bounds
  /// if future lighting keyframes briefly exceed them.
  static double verticalShadowDisplacementProgress(double displacement) {
    if (!displacement.isFinite) {
      throw ArgumentError.value(
        displacement,
        'displacement',
        'Shadow displacement must be finite.',
      );
    }
    return ((displacement - minimumShadowSouthDisplacement) /
            (maximumShadowSouthDisplacement - minimumShadowSouthDisplacement))
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static double _lerp(double left, double right, double t) =>
      left + (right - left) * t;

  static int _lerpInt(double left, double right, double t) =>
      (_lerp(left, right, t) * 255).round().clamp(0, 255);

  static void _validateProgress(double progress) {
    if (!progress.isFinite || progress < 0.0 || progress >= 1.0) {
      throw ArgumentError.value(
        progress,
        'progress',
        'Progress must be greater than or equal to 0.0 and less than 1.0.',
      );
    }
  }
}
