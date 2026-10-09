import '../state/player_event_journal.dart';
import '../state/runtime_game_state.dart';
import 'routine_catalog.dart';
import 'routine_model.dart';

/// Immutable routine-relevant state sampled at one day and authored clock time.
final class RoutineResolutionSnapshot {
  factory RoutineResolutionSnapshot({
    required int dayIndex,
    required RoutineTime time,
    required Set<String> activeWorldEventIds,
    required Set<String> suppressedRoutineIds,
    required Map<String, NpcRelationshipState> relationships,
    required PlayerEventJournal eventJournal,
    required double activePlaySeconds,
  }) {
    if (dayIndex < 0) {
      throw ArgumentError.value(
        dayIndex,
        'dayIndex',
        'Day index must be non-negative.',
      );
    }
    if (!activePlaySeconds.isFinite || activePlaySeconds < 0) {
      throw ArgumentError.value(
        activePlaySeconds,
        'activePlaySeconds',
        'Active play seconds must be finite and non-negative.',
      );
    }
    _validateIds(activeWorldEventIds, 'activeWorldEventIds');
    _validateIds(suppressedRoutineIds, 'suppressedRoutineIds');
    for (final entry in relationships.entries) {
      _validateId(entry.key, 'relationships');
      if (entry.key != entry.value.npcId) {
        throw ArgumentError.value(
          entry.key,
          'relationships',
          'Relationship key must match its NPC ID.',
        );
      }
    }
    return RoutineResolutionSnapshot._(
      dayIndex: dayIndex,
      time: time,
      activeWorldEventIds: Set.unmodifiable(activeWorldEventIds),
      suppressedRoutineIds: Set.unmodifiable(suppressedRoutineIds),
      relationships: Map.unmodifiable(relationships),
      eventJournal: eventJournal,
      activePlaySeconds: activePlaySeconds,
    );
  }

  const RoutineResolutionSnapshot._({
    required this.dayIndex,
    required this.time,
    required this.activeWorldEventIds,
    required this.suppressedRoutineIds,
    required this.relationships,
    required this.eventJournal,
    required this.activePlaySeconds,
  });

  factory RoutineResolutionSnapshot.fromRuntimeState(
    RuntimeGameState state, {
    required RoutineTime time,
    Set<String>? activeWorldEventIds,
  }) => RoutineResolutionSnapshot(
    dayIndex: state.dayIndex,
    time: time,
    activeWorldEventIds: activeWorldEventIds ?? state.activeWorldEventIds,
    suppressedRoutineIds: state.suppressedRoutineIds,
    relationships: state.relationships,
    eventJournal: state.eventJournal,
    activePlaySeconds: state.activePlaySeconds,
  );

  final int dayIndex;
  final RoutineTime time;
  final Set<String> activeWorldEventIds;
  final Set<String> suppressedRoutineIds;
  final Map<String, NpcRelationshipState> relationships;
  final PlayerEventJournal eventJournal;
  final double activePlaySeconds;
}

/// Stable assignment of one participant to one selected routine.
final class RoutineParticipantAssignment {
  RoutineParticipantAssignment({
    required this.participantId,
    required this.routineId,
  }) {
    _validateId(participantId, 'participantId');
    _validateId(routineId, 'routineId');
  }

  final String participantId;
  final String routineId;

  @override
  bool operator ==(Object other) =>
      other is RoutineParticipantAssignment &&
      other.participantId == participantId &&
      other.routineId == routineId;

  @override
  int get hashCode => Object.hash(participantId, routineId);
}

/// Structurally comparable, deterministic participant plan for one snapshot.
final class RoutineResolutionPlan {
  factory RoutineResolutionPlan({
    required int dayIndex,
    required RoutineTime time,
    required Iterable<RoutineParticipantAssignment> assignments,
  }) {
    if (dayIndex < 0) {
      throw ArgumentError.value(
        dayIndex,
        'dayIndex',
        'Day index must be non-negative.',
      );
    }
    final sortedAssignments = List<RoutineParticipantAssignment>.of(
      assignments,
    )..sort((left, right) => left.participantId.compareTo(right.participantId));
    final byParticipantId = <String, RoutineParticipantAssignment>{};
    final routineIds = <String>{};
    for (final assignment in sortedAssignments) {
      if (byParticipantId.containsKey(assignment.participantId)) {
        throw ArgumentError.value(
          assignment.participantId,
          'assignments',
          'Participant cannot have more than one routine assignment.',
        );
      }
      byParticipantId[assignment.participantId] = assignment;
      routineIds.add(assignment.routineId);
    }
    final sortedRoutineIds = routineIds.toList()..sort();
    return RoutineResolutionPlan._(
      dayIndex: dayIndex,
      time: time,
      assignments: List.unmodifiable(sortedAssignments),
      byParticipantId: Map.unmodifiable(byParticipantId),
      routineIds: List.unmodifiable(sortedRoutineIds),
    );
  }

  const RoutineResolutionPlan._({
    required this.dayIndex,
    required this.time,
    required this.assignments,
    required this.byParticipantId,
    required this.routineIds,
  });

  final int dayIndex;
  final RoutineTime time;
  final List<RoutineParticipantAssignment> assignments;
  final Map<String, RoutineParticipantAssignment> byParticipantId;
  final List<String> routineIds;

  RoutineParticipantAssignment? assignmentFor(String participantId) =>
      byParticipantId[participantId];

  @override
  bool operator ==(Object other) =>
      other is RoutineResolutionPlan &&
      other.dayIndex == dayIndex &&
      other.time == time &&
      _listEquals(other.assignments, assignments);

  @override
  int get hashCode => Object.hash(dayIndex, time, Object.hashAll(assignments));
}

/// Developer-safe reason one routine was not selected for a snapshot.
enum RoutineRejectionReason {
  suppressedForDay,
  outsideWindow,
  conditionNotMet,
  participantConflict,
}

/// Immutable rejection using stable IDs only, never authored/private text.
final class RoutineRejectionDiagnostic {
  factory RoutineRejectionDiagnostic({
    required String routineId,
    required RoutineRejectionReason reason,
    Iterable<String> conflictingParticipantIds = const [],
  }) {
    _validateId(routineId, 'routineId');
    final conflicts = conflictingParticipantIds.toList()..sort();
    _validateIds(conflicts, 'conflictingParticipantIds');
    if (conflicts.toSet().length != conflicts.length) {
      throw ArgumentError.value(
        conflictingParticipantIds,
        'conflictingParticipantIds',
        'IDs must be unique.',
      );
    }
    if (reason == RoutineRejectionReason.participantConflict &&
        conflicts.isEmpty) {
      throw ArgumentError.value(
        conflictingParticipantIds,
        'conflictingParticipantIds',
        'Participant-conflict diagnostics require at least one ID.',
      );
    }
    if (reason != RoutineRejectionReason.participantConflict &&
        conflicts.isNotEmpty) {
      throw ArgumentError.value(
        conflictingParticipantIds,
        'conflictingParticipantIds',
        'Only participant-conflict diagnostics may contain IDs.',
      );
    }
    return RoutineRejectionDiagnostic._(
      routineId: routineId,
      reason: reason,
      conflictingParticipantIds: List.unmodifiable(conflicts),
    );
  }

  const RoutineRejectionDiagnostic._({
    required this.routineId,
    required this.reason,
    required this.conflictingParticipantIds,
  });

  final String routineId;
  final RoutineRejectionReason reason;
  final List<String> conflictingParticipantIds;

  @override
  bool operator ==(Object other) =>
      other is RoutineRejectionDiagnostic &&
      other.routineId == routineId &&
      other.reason == reason &&
      _listEquals(other.conflictingParticipantIds, conflictingParticipantIds);

  @override
  int get hashCode =>
      Object.hash(routineId, reason, Object.hashAll(conflictingParticipantIds));
}

/// Plan plus opt-in rejection detail produced by the same deterministic pass.
final class RoutineResolutionDiagnosticReport {
  factory RoutineResolutionDiagnosticReport({
    required RoutineResolutionPlan plan,
    required Iterable<RoutineRejectionDiagnostic> rejections,
  }) {
    final sortedRejections = rejections.toList()
      ..sort((left, right) => left.routineId.compareTo(right.routineId));
    return RoutineResolutionDiagnosticReport._(
      plan: plan,
      rejections: List.unmodifiable(sortedRejections),
    );
  }

  const RoutineResolutionDiagnosticReport._({
    required this.plan,
    required this.rejections,
  });

  final RoutineResolutionPlan plan;
  final List<RoutineRejectionDiagnostic> rejections;

  @override
  bool operator ==(Object other) =>
      other is RoutineResolutionDiagnosticReport &&
      other.plan == plan &&
      _listEquals(other.rejections, rejections);

  @override
  int get hashCode => Object.hash(plan, Object.hashAll(rejections));
}

/// Selects eligible routines without actor, timer, UI, or movement behavior.
final class RoutineResolver {
  const RoutineResolver();

  RoutineResolutionPlan resolve({
    required RoutineCatalog catalog,
    required RoutineResolutionSnapshot snapshot,
  }) => resolveWithDiagnostics(catalog: catalog, snapshot: snapshot).plan;

  /// Resolves once while recording why every non-selected alternative lost.
  ///
  /// Rejection precedence is suppression, window, conditions, then participant
  /// conflict. Detail contains stable IDs and enums only.
  RoutineResolutionDiagnosticReport resolveWithDiagnostics({
    required RoutineCatalog catalog,
    required RoutineResolutionSnapshot snapshot,
  }) {
    final candidates = <RoutineDefinition>[];
    final rejections = <RoutineRejectionDiagnostic>[];
    for (final routine in catalog.routines) {
      final rejectionReason = snapshot.suppressedRoutineIds.contains(routine.id)
          ? RoutineRejectionReason.suppressedForDay
          : !routine.timeWindow.contains(snapshot.time)
          ? RoutineRejectionReason.outsideWindow
          : !routine.conditions.every(
              (condition) => _matchesCondition(condition, snapshot),
            )
          ? RoutineRejectionReason.conditionNotMet
          : null;
      if (rejectionReason == null) {
        candidates.add(routine);
      } else {
        rejections.add(
          RoutineRejectionDiagnostic(
            routineId: routine.id,
            reason: rejectionReason,
          ),
        );
      }
    }
    candidates.sort((left, right) {
      final priority = right.priority.compareTo(left.priority);
      return priority != 0 ? priority : left.id.compareTo(right.id);
    });

    final occupiedParticipantIds = <String>{};
    final assignments = <RoutineParticipantAssignment>[];
    for (final routine in candidates) {
      final conflicts = routine.participants
          .where(occupiedParticipantIds.contains)
          .toList();
      if (conflicts.isNotEmpty) {
        rejections.add(
          RoutineRejectionDiagnostic(
            routineId: routine.id,
            reason: RoutineRejectionReason.participantConflict,
            conflictingParticipantIds: conflicts,
          ),
        );
        continue;
      }
      occupiedParticipantIds.addAll(routine.participants);
      assignments.addAll([
        for (final participantId in routine.participants)
          RoutineParticipantAssignment(
            participantId: participantId,
            routineId: routine.id,
          ),
      ]);
    }

    return RoutineResolutionDiagnosticReport(
      plan: RoutineResolutionPlan(
        dayIndex: snapshot.dayIndex,
        time: snapshot.time,
        assignments: assignments,
      ),
      rejections: rejections,
    );
  }
}

bool _matchesCondition(
  RoutineCondition condition,
  RoutineResolutionSnapshot snapshot,
) => switch (condition) {
  RoutineWorldEventCondition(:final kind, :final eventId) => switch (kind) {
    RoutineConditionKind.worldEventActive =>
      snapshot.activeWorldEventIds.contains(eventId),
    RoutineConditionKind.worldEventInactive =>
      !snapshot.activeWorldEventIds.contains(eventId),
    _ => false,
  },
  RoutineLearnedFactCondition(:final npcId, :final factId) =>
    snapshot.relationships[npcId]?.learnedFactIds.contains(factId) ?? false,
  RoutineRelationshipFlagCondition(:final kind, :final npcId, :final flagId) =>
    switch (kind) {
      RoutineConditionKind.relationshipFlagSet =>
        snapshot.relationships[npcId]?.flags.contains(flagId) ?? false,
      RoutineConditionKind.relationshipFlagUnset =>
        !(snapshot.relationships[npcId]?.flags.contains(flagId) ?? false),
      _ => false,
    },
  RoutinePlayerEventCondition() => snapshot.eventJournal.matches(
    condition.query,
    nowSeconds: snapshot.activePlaySeconds,
  ),
};

void _validateIds(Iterable<String> values, String argumentName) {
  for (final value in values) {
    _validateId(value, argumentName);
  }
}

void _validateId(String value, String argumentName) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, argumentName, 'ID cannot be blank.');
  }
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}
