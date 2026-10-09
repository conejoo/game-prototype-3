import '../day_night/day_night_clock.dart';
import '../routines/routine_catalog.dart';
import '../routines/routine_model.dart';
import '../routines/routine_resolver.dart';
import '../state/runtime_game_state.dart';

/// One selected participant plan plus deterministic progress from its window.
final class DirectedNpcRoutine {
  const DirectedNpcRoutine({
    required this.routine,
    required this.participantSteps,
    required this.elapsedWindowSeconds,
  });

  final RoutineDefinition routine;
  final RoutineParticipantSteps participantSteps;
  final double elapsedWindowSeconds;

  String get npcId => participantSteps.participantId;
  String get routineId => routine.id;

  /// Routine-authored dialogue entries in strict runtime priority order.
  ///
  /// Current participant/step wins, then routine default. Ordinary NPC graph
  /// resolution remains the caller's final fallback.
  List<String> dialogueEntryNodeIdsFor(String? stepId) {
    final result = <String>[];
    if (stepId != null) {
      for (final entry in routine.interactionPolicy.stepDialogueEntries) {
        if (entry.participantId == npcId && entry.stepId == stepId) {
          result.add(entry.dialogueEntryNodeId);
          break;
        }
      }
    }
    final defaultEntry = routine.interactionPolicy.defaultDialogueEntryNodeId;
    if (defaultEntry != null && !result.contains(defaultEntry)) {
      result.add(defaultEntry);
    }
    return List.unmodifiable(result);
  }

  RoutineDirective? directiveForOutcomeTag(String outcomeTag) {
    for (final binding in routine.interactionPolicy.outcomeDirectives) {
      if (binding.outcomeTag == outcomeTag) {
        return binding.directive;
      }
    }
    return null;
  }
}

/// Active-map routine context captured before opening one dialogue overlay.
final class NpcRoutineDialogueContext {
  NpcRoutineDialogueContext({
    required this.directedRoutine,
    required this.currentStepId,
  }) : preferredEntryNodeIds = directedRoutine.dialogueEntryNodeIdsFor(
         currentStepId,
       );

  final DirectedNpcRoutine directedRoutine;
  final String? currentStepId;
  final List<String> preferredEntryNodeIds;

  String get routineId => directedRoutine.routineId;
  bool get allowsDialogue =>
      directedRoutine.routine.interactionPolicy.allowDialogue;
}

/// Immutable resolver output consumed by active-map presentation adapters.
final class NpcRoutineDirectorPlan {
  factory NpcRoutineDirectorPlan({
    required RoutineResolutionPlan resolution,
    required Iterable<RoutineRejectionDiagnostic> rejections,
    required Iterable<DirectedNpcRoutine> routines,
  }) {
    final sorted = routines.toList()
      ..sort((left, right) => left.npcId.compareTo(right.npcId));
    final sortedRejections = rejections.toList()
      ..sort((left, right) => left.routineId.compareTo(right.routineId));
    return NpcRoutineDirectorPlan._(
      resolution: resolution,
      rejections: List.unmodifiable(sortedRejections),
      routines: List.unmodifiable(sorted),
      byNpcId: Map.unmodifiable({
        for (final routine in sorted) routine.npcId: routine,
      }),
    );
  }

  const NpcRoutineDirectorPlan._({
    required this.resolution,
    required this.rejections,
    required this.routines,
    required this.byNpcId,
  });

  final RoutineResolutionPlan resolution;
  final List<RoutineRejectionDiagnostic> rejections;
  final List<DirectedNpcRoutine> routines;
  final Map<String, DirectedNpcRoutine> byNpcId;

  DirectedNpcRoutine? routineFor(String npcId) => byNpcId[npcId];
}

/// Re-evaluates routine assignments from serializable state only.
///
/// Components, paths, actor positions, and loaded-map lifecycle stay outside
/// this director. Reconstructing presentation consumes [elapsedWindowSeconds]
/// without adding transient fields to [RuntimeGameState].
final class NpcRoutineDirector {
  NpcRoutineDirector({
    required this.catalog,
    this.resolver = const RoutineResolver(),
  });

  final RoutineCatalog catalog;
  final RoutineResolver resolver;

  NpcRoutineDirectorPlan? _currentPlan;
  int _resolutionCount = 0;

  NpcRoutineDirectorPlan? get currentPlan => _currentPlan;
  int get resolutionCount => _resolutionCount;

  NpcRoutineDirectorPlan replan(
    RuntimeGameState state, {
    Set<String>? activeWorldEventIds,
  }) {
    final minuteOfDay = DayNightClock.minuteOfDayForProgress(
      state.dayCycleProgress,
    );
    final time = _routineTime(minuteOfDay.floor());
    final report = resolver.resolveWithDiagnostics(
      catalog: catalog,
      snapshot: RoutineResolutionSnapshot.fromRuntimeState(
        state,
        time: time,
        activeWorldEventIds: activeWorldEventIds,
      ),
    );
    final resolution = report.plan;
    final routines = <DirectedNpcRoutine>[];
    for (final assignment in resolution.assignments) {
      final routine = catalog.findById(assignment.routineId)!;
      routines.add(
        DirectedNpcRoutine(
          routine: routine,
          participantSteps:
              routine.stepsByParticipantId[assignment.participantId]!,
          elapsedWindowSeconds: _elapsedWindowSeconds(
            minuteOfDay: minuteOfDay,
            window: routine.timeWindow,
          ),
        ),
      );
    }
    _resolutionCount++;
    return _currentPlan = NpcRoutineDirectorPlan(
      resolution: resolution,
      rejections: report.rejections,
      routines: routines,
    );
  }
}

RoutineTime _routineTime(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  final minute = minuteOfDay % 60;
  return RoutineTime.parse(
    '${hour.toString().padLeft(2, '0')}:'
    '${minute.toString().padLeft(2, '0')}',
    path: r'$runtime.dayCycleProgress',
  );
}

double _elapsedWindowSeconds({
  required double minuteOfDay,
  required RoutineTimeWindow window,
}) {
  var elapsedMinutes = minuteOfDay - window.start.minuteOfDay;
  if (elapsedMinutes < 0) {
    elapsedMinutes += DayNightClock.minutesPerDay;
  }
  return elapsedMinutes /
      DayNightClock.minutesPerDay *
      DayNightClock.cycleDurationSeconds;
}
