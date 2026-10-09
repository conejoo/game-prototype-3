import 'package:cozy_life_adventure/game/routines/routine_catalog.dart';
import 'package:cozy_life_adventure/game/routines/routine_model.dart';
import 'package:cozy_life_adventure/game/routines/routine_resolver.dart';
import 'package:cozy_life_adventure/game/state/player_event_journal.dart';
import 'package:cozy_life_adventure/game/state/runtime_game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoutineResolver time windows', () {
    test('uses inclusive start and exclusive end for daytime windows', () {
      final catalog = _catalog([
        _routine(id: 'day-work', start: '08:00', end: '09:00'),
      ]);

      expect(_routineIds(catalog, time: '07:59'), isEmpty);
      expect(_routineIds(catalog, time: '08:00'), ['day-work']);
      expect(_routineIds(catalog, time: '08:59'), ['day-work']);
      expect(_routineIds(catalog, time: '09:00'), isEmpty);
    });

    test('uses exact boundaries for overnight windows', () {
      final catalog = _catalog([
        _routine(id: 'night-watch', start: '22:30', end: '01:15'),
      ]);

      expect(_routineIds(catalog, time: '22:29'), isEmpty);
      expect(_routineIds(catalog, time: '22:30'), ['night-watch']);
      expect(_routineIds(catalog, time: '23:59'), ['night-watch']);
      expect(_routineIds(catalog, time: '00:00'), ['night-watch']);
      expect(_routineIds(catalog, time: '01:14'), ['night-watch']);
      expect(_routineIds(catalog, time: '01:15'), isEmpty);
      expect(_routineIds(catalog, time: '12:00'), isEmpty);
    });
  });

  group('RoutineResolver conditions', () {
    test('requires every condition family to match one immutable snapshot', () {
      final journal = PlayerEventJournal().record(
        kind: PlayerEventKind.resourceGathered,
        subjectId: 'moonflower',
        activeSeconds: 90,
      );
      final matchingRelationship = NpcRelationshipState(
        npcId: 'npc-a',
        learnedFactIds: const {'knows-tides'},
        flags: const {'helped-harbor'},
      );
      final catalog = _catalog([
        _routine(
          id: 'conditioned-work',
          conditions: const [
            RoutineWorldEventCondition(
              kind: RoutineConditionKind.worldEventActive,
              eventId: 'harbor-festival',
            ),
            RoutineWorldEventCondition(
              kind: RoutineConditionKind.worldEventInactive,
              eventId: 'heavy-rain',
            ),
            RoutineLearnedFactCondition(npcId: 'npc-a', factId: 'knows-tides'),
            RoutineRelationshipFlagCondition(
              kind: RoutineConditionKind.relationshipFlagSet,
              npcId: 'npc-a',
              flagId: 'helped-harbor',
            ),
            RoutineRelationshipFlagCondition(
              kind: RoutineConditionKind.relationshipFlagUnset,
              npcId: 'npc-a',
              flagId: 'avoids-harbor',
            ),
            RoutinePlayerEventCondition(
              eventKind: PlayerEventKind.resourceGathered,
              subjectId: 'moonflower',
              targetId: null,
              minimumCount: 1,
              maximumCount: 2,
              occurredWithinActiveSeconds: 20,
            ),
          ],
        ),
      ]);
      final matching = _snapshot(
        activeWorldEventIds: {'harbor-festival'},
        relationships: {'npc-a': matchingRelationship},
        eventJournal: journal,
      );

      expect(_resolve(catalog, matching).routineIds, ['conditioned-work']);

      final failures = <(String, RoutineResolutionSnapshot)>[
        (
          'active world event',
          _snapshot(
            relationships: {'npc-a': matchingRelationship},
            eventJournal: journal,
          ),
        ),
        (
          'inactive world event',
          _snapshot(
            activeWorldEventIds: {'harbor-festival', 'heavy-rain'},
            relationships: {'npc-a': matchingRelationship},
            eventJournal: journal,
          ),
        ),
        (
          'learned fact',
          _snapshot(
            activeWorldEventIds: {'harbor-festival'},
            relationships: {
              'npc-a': NpcRelationshipState(
                npcId: 'npc-a',
                flags: const {'helped-harbor'},
              ),
            },
            eventJournal: journal,
          ),
        ),
        (
          'set relationship flag',
          _snapshot(
            activeWorldEventIds: {'harbor-festival'},
            relationships: {
              'npc-a': NpcRelationshipState(
                npcId: 'npc-a',
                learnedFactIds: const {'knows-tides'},
              ),
            },
            eventJournal: journal,
          ),
        ),
        (
          'unset relationship flag',
          _snapshot(
            activeWorldEventIds: {'harbor-festival'},
            relationships: {
              'npc-a': matchingRelationship.copyWith(
                flags: const {'helped-harbor', 'avoids-harbor'},
              ),
            },
            eventJournal: journal,
          ),
        ),
        (
          'player event query',
          _snapshot(
            activeWorldEventIds: {'harbor-festival'},
            relationships: {'npc-a': matchingRelationship},
          ),
        ),
      ];
      for (final (label, snapshot) in failures) {
        expect(
          _resolve(catalog, snapshot).assignments,
          isEmpty,
          reason: '$label must participate in condition AND.',
        );
      }
    });
  });

  group('RoutineResolver assignment ordering', () {
    test('resolves priority, ID ties, suppression, and groups atomically', () {
      final catalog = _catalog([
        _routine(id: 'highest-a', priority: 50, participants: ['npc-a']),
        _routine(
          id: 'blocked-group',
          priority: 40,
          participants: ['npc-a', 'npc-b'],
        ),
        _routine(id: 'fallback-b', priority: 30, participants: ['npc-b']),
        _routine(id: 'tie-beta', priority: 20, participants: ['npc-c']),
        _routine(id: 'tie-alpha', priority: 20, participants: ['npc-c']),
        _routine(
          id: 'accepted-group',
          priority: 10,
          participants: ['npc-e', 'npc-f'],
        ),
        _routine(id: 'suppressed-d', priority: 100, participants: ['npc-d']),
        _routine(id: 'fallback-d', priority: 1, participants: ['npc-d']),
      ]);

      final plan = _resolve(
        catalog,
        _snapshot(suppressedRoutineIds: {'suppressed-d'}),
      );

      expect(
        {
          for (final assignment in plan.assignments)
            assignment.participantId: assignment.routineId,
        },
        {
          'npc-a': 'highest-a',
          'npc-b': 'fallback-b',
          'npc-c': 'tie-alpha',
          'npc-d': 'fallback-d',
          'npc-e': 'accepted-group',
          'npc-f': 'accepted-group',
        },
      );
      expect(plan.routineIds, [
        'accepted-group',
        'fallback-b',
        'fallback-d',
        'highest-a',
        'tie-alpha',
      ]);
      expect(plan.routineIds, isNot(contains('blocked-group')));
      expect(plan.assignmentFor('npc-b')!.routineId, 'fallback-b');
    });

    test('reports every rejected alternative without changing selection', () {
      final catalog = _catalog([
        _routine(id: 'selected-high', priority: 50),
        _routine(id: 'conflict-low', priority: 10),
        _routine(
          id: 'condition-missing',
          priority: 60,
          participants: const ['npc-b'],
          conditions: const [
            RoutineWorldEventCondition(
              kind: RoutineConditionKind.worldEventActive,
              eventId: 'heavy-rain',
            ),
          ],
        ),
        _routine(
          id: 'outside-window',
          start: '09:00',
          end: '10:00',
          participants: const ['npc-c'],
        ),
        _routine(id: 'suppressed-today', participants: const ['npc-d']),
      ]);
      final snapshot = _snapshot(
        suppressedRoutineIds: const {'suppressed-today'},
      );
      const resolver = RoutineResolver();

      final report = resolver.resolveWithDiagnostics(
        catalog: catalog,
        snapshot: snapshot,
      );

      expect(
        report.plan,
        resolver.resolve(catalog: catalog, snapshot: snapshot),
      );
      expect(report.plan.routineIds, ['selected-high']);
      expect(
        [
          for (final rejection in report.rejections)
            '${rejection.routineId}:${rejection.reason.name}:'
                '${rejection.conflictingParticipantIds.join(',')}',
        ],
        [
          'condition-missing:conditionNotMet:',
          'conflict-low:participantConflict:npc-a',
          'outside-window:outsideWindow:',
          'suppressed-today:suppressedForDay:',
        ],
      );
      expect(
        resolver.resolveWithDiagnostics(catalog: catalog, snapshot: snapshot),
        report,
      );
      expect(() => report.rejections.clear(), throwsUnsupportedError);
      expect(
        () => report.rejections[1].conflictingParticipantIds.add('npc-z'),
        throwsUnsupportedError,
      );
    });
  });

  group('RoutineResolver values', () {
    test('copies runtime state into an immutable resolution snapshot', () {
      final state = RuntimeGameState.initial(npcIds: const ['npc-a']).copyWith(
        dayIndex: 9,
        activeWorldEventIds: {'harbor-festival'},
        suppressedRoutineIds: {'rest-day'},
        relationships: {
          'npc-a': NpcRelationshipState(
            npcId: 'npc-a',
            learnedFactIds: const {'knows-tides'},
            flags: const {'helped-harbor'},
          ),
        },
        eventJournal: PlayerEventJournal().record(
          kind: PlayerEventKind.areaEntered,
          subjectId: 'harbor',
          activeSeconds: 40,
        ),
        activePlaySeconds: 45,
      );

      final snapshot = RoutineResolutionSnapshot.fromRuntimeState(
        state,
        time: _time('06:30'),
      );

      expect(snapshot.dayIndex, 9);
      expect(snapshot.time, _time('06:30'));
      expect(snapshot.activeWorldEventIds, {'harbor-festival'});
      expect(snapshot.suppressedRoutineIds, {'rest-day'});
      expect(snapshot.relationships.keys, {'npc-a'});
      expect(snapshot.eventJournal.lastSequence, 1);
      expect(snapshot.activePlaySeconds, 45);
      expect(
        () => snapshot.activeWorldEventIds.add('heavy-rain'),
        throwsUnsupportedError,
      );
      expect(
        () => snapshot.relationships.remove('npc-a'),
        throwsUnsupportedError,
      );
    });

    test('repeated identical input returns equal immutable plans', () {
      final catalog = _catalog([
        _routine(id: 'paired-work', participants: ['npc-b', 'npc-a']),
      ]);
      final snapshot = _snapshot(dayIndex: 12);

      final first = _resolve(catalog, snapshot);
      final second = _resolve(catalog, snapshot);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.assignments.map((assignment) => assignment.participantId), [
        'npc-a',
        'npc-b',
      ]);
      expect(() => first.assignments.clear(), throwsUnsupportedError);
      expect(() => first.routineIds.add('other'), throwsUnsupportedError);
      expect(
        () => first.byParticipantId.remove('npc-a'),
        throwsUnsupportedError,
      );
    });
  });
}

RoutineResolutionPlan _resolve(
  RoutineCatalog catalog,
  RoutineResolutionSnapshot snapshot,
) => const RoutineResolver().resolve(catalog: catalog, snapshot: snapshot);

List<String> _routineIds(RoutineCatalog catalog, {required String time}) =>
    _resolve(catalog, _snapshot(time: time)).routineIds;

RoutineCatalog _catalog(List<RoutineDefinition> routines) =>
    RoutineCatalog(routines: routines);

RoutineResolutionSnapshot _snapshot({
  String time = '08:30',
  int dayIndex = 4,
  Set<String> activeWorldEventIds = const {},
  Set<String> suppressedRoutineIds = const {},
  Map<String, NpcRelationshipState> relationships = const {},
  PlayerEventJournal? eventJournal,
  double activePlaySeconds = 100,
}) => RoutineResolutionSnapshot(
  dayIndex: dayIndex,
  time: _time(time),
  activeWorldEventIds: activeWorldEventIds,
  suppressedRoutineIds: suppressedRoutineIds,
  relationships: relationships,
  eventJournal: eventJournal ?? PlayerEventJournal(),
  activePlaySeconds: activePlaySeconds,
);

RoutineTime _time(String value) =>
    RoutineTime.parse(value, path: r'$fixture.time');

RoutineDefinition _routine({
  required String id,
  int priority = 1,
  String start = '08:00',
  String end = '09:00',
  List<String> participants = const ['npc-a'],
  List<RoutineCondition> conditions = const [],
}) => RoutineDefinition(
  schemaVersion: RoutineDefinition.currentSchemaVersion,
  id: id,
  priority: priority,
  timeWindow: RoutineTimeWindow(start: _time(start), end: _time(end)),
  participants: participants,
  conditions: conditions,
  interactionPolicy: RoutineInteractionPolicy(
    allowDialogue: false,
    defaultDialogueEntryNodeId: null,
    stepDialogueEntries: const [],
    outcomeDirectives: const [],
  ),
  participantSteps: [
    for (final participantId in participants)
      RoutineParticipantSteps(
        participantId: participantId,
        steps: const [RoutineWaitStep(id: 'wait', durationSeconds: 1)],
      ),
  ],
);
