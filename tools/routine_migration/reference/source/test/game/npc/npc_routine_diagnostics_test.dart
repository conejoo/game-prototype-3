import 'package:cozy_life_adventure/game/navigation/navigation.dart';
import 'package:cozy_life_adventure/game/npc/npc_routine_diagnostics.dart';
import 'package:cozy_life_adventure/game/npc/npc_routine_diagnostics_component.dart';
import 'package:cozy_life_adventure/game/npc/npc_routine_executor.dart';
import 'package:cozy_life_adventure/game/routines/routine_model.dart';
import 'package:cozy_life_adventure/game/routines/routine_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('formats stable bounded IDs for representative navigation states', () {
    final snapshot = _snapshot();

    final text = snapshot.toBoundedText();

    expect(text, contains('participant=npc-01 routine=morning-rounds'));
    expect(text, contains('step=move-to-archive'));
    expect(text, contains('target=mayor-vale-home/archive-desk'));
    expect(text, contains('path=failed points=3 repath=2'));
    expect(text, contains('no-path=goalBlocked'));
    expect(text, contains('failure=repathAttemptsExhausted'));
    expect(text, contains('occupancy=reserved occupant=npc:mayor-placement'));
    expect(text, contains('blockers=player:player-1'));
    expect(
      text,
      contains('rejected=rain-rounds reason=condition-not-met conflicts=-'),
    );
    expect(
      text,
      contains(
        'rejected=town-briefing reason=participant-conflict '
        'conflicts=npc-01',
      ),
    );
    for (final line in text.split('\n')) {
      expect(
        line.length,
        lessThanOrEqualTo(NpcRoutineDiagnosticsSnapshot.maxLineCharacters),
      );
    }
  });

  test('component starts hidden and samples only while enabled', () {
    var sampleCount = 0;
    final component = NpcRoutineDiagnosticsComponent(
      snapshotSource: () {
        sampleCount++;
        return _snapshot();
      },
    );

    expect(component.enabled, isFalse);
    expect(component.isVisible, isFalse);
    expect(component.text, isEmpty);
    component.update(0.016);
    expect(sampleCount, 0);

    component.setEnabled(true);
    expect(component.enabled, isTrue);
    expect(component.isVisible, isTrue);
    expect(component.text, contains('routines day=4 time=10:00'));
    expect(sampleCount, 1);
    component.update(0.016);
    expect(sampleCount, 2);

    component.setEnabled(false);
    expect(component.enabled, isFalse);
    expect(component.isVisible, isFalse);
    expect(component.text, isEmpty);
    component.update(0.016);
    expect(sampleCount, 2);
  });
}

NpcRoutineDiagnosticsSnapshot _snapshot() => NpcRoutineDiagnosticsSnapshot(
  resolution: RoutineResolutionPlan(
    dayIndex: 4,
    time: RoutineTime.parse('10:00', path: r'$fixture.time'),
    assignments: [
      RoutineParticipantAssignment(
        participantId: 'npc-01',
        routineId: 'morning-rounds',
      ),
    ],
  ),
  rejections: [
    RoutineRejectionDiagnostic(
      routineId: 'town-briefing',
      reason: RoutineRejectionReason.participantConflict,
      conflictingParticipantIds: const ['npc-01'],
    ),
    RoutineRejectionDiagnostic(
      routineId: 'rain-rounds',
      reason: RoutineRejectionReason.conditionNotMet,
    ),
  ],
  participants: [
    NpcRoutineExecutionDiagnostics(
      routineId: 'morning-rounds',
      participantId: 'npc-01',
      currentMapId: 'mayor-vale-home',
      currentStepId: 'move-to-archive',
      executionState: NpcRoutineExecutionState.failed,
      isPaused: false,
      targetMapId: 'mayor-vale-home',
      targetAnchorId: 'archive-desk',
      routeState: NavigationRouteFollowerState.failed,
      pathPointCount: 3,
      repathAttempts: 2,
      failureReason: NpcRoutineFailureReason.repathAttemptsExhausted,
      noPathReason: NavigationNoPathReason.goalBlocked,
      mapNoRouteReason: null,
      occupantId: 'npc:mayor-placement',
      occupancyRegistered: true,
      occupancyBlockerIds: const ['player:player-1'],
    ),
  ],
);
