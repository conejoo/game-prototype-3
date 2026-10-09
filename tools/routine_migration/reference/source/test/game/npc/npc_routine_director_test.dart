import 'package:cozy_life_adventure/game/npc/npc_routine_director.dart';
import 'package:cozy_life_adventure/game/routines/routine_catalog.dart';
import 'package:cozy_life_adventure/game/routines/routine_model.dart';
import 'package:cozy_life_adventure/game/state/runtime_game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NpcRoutineDirector', () {
    test(
      'maps persisted cycle time and reconstructs exact window progress',
      () {
        final director = NpcRoutineDirector(
          catalog: RoutineCatalog(
            routines: [
              _routine(id: 'morning-work', start: '09:00', end: '11:00'),
              _routine(id: 'night-watch', start: '22:00', end: '02:00'),
            ],
          ),
        );

        final morning = director.replan(
          RuntimeGameState.initial(npcIds: const ['npc-01']),
        );

        expect(morning.resolution.time.toString(), '10:00');
        expect(morning.resolution.routineIds, ['morning-work']);
        expect(morning.routineFor('npc-01')!.elapsedWindowSeconds, 25);

        final overnight = director.replan(
          RuntimeGameState.initial(
            npcIds: const ['npc-01'],
          ).copyWith(dayCycleProgress: 7 / 12),
        );

        expect(overnight.resolution.time.toString(), '00:00');
        expect(overnight.resolution.routineIds, ['night-watch']);
        expect(overnight.routineFor('npc-01')!.elapsedWindowSeconds, 50);
      },
    );

    test('replans deterministic event, suppression, and rollover changes', () {
      final director = NpcRoutineDirector(
        catalog: RoutineCatalog(
          routines: [
            _routine(id: 'ordinary-day', priority: 1),
            _routine(
              id: 'rain-day',
              priority: 2,
              conditions: const [
                RoutineWorldEventCondition(
                  kind: RoutineConditionKind.worldEventActive,
                  eventId: 'heavy-rain',
                ),
              ],
            ),
          ],
        ),
      );
      final initial = RuntimeGameState.initial(npcIds: const ['npc-01']);

      final ordinary = director.replan(initial);
      final rainy = director.replan(
        initial.copyWith(activeWorldEventIds: {'heavy-rain'}),
      );
      final suppressed = director.replan(
        initial.copyWith(
          activeWorldEventIds: {'heavy-rain'},
          suppressedRoutineIds: {'rain-day'},
        ),
      );
      final nextDay = director.replan(
        initial.copyWith(
          dayIndex: 1,
          activeWorldEventIds: {'heavy-rain'},
          suppressedRoutineIds: const {},
        ),
      );
      final repeated = director.replan(
        initial.copyWith(
          dayIndex: 1,
          activeWorldEventIds: {'heavy-rain'},
          suppressedRoutineIds: const {},
        ),
      );

      expect(ordinary.routineFor('npc-01')!.routineId, 'ordinary-day');
      expect(rainy.routineFor('npc-01')!.routineId, 'rain-day');
      expect(suppressed.routineFor('npc-01')!.routineId, 'ordinary-day');
      expect(nextDay.routineFor('npc-01')!.routineId, 'rain-day');
      expect(nextDay.resolution, repeated.resolution);
      expect(director.currentPlan, same(repeated));
      expect(director.resolutionCount, 5);
    });

    test('exposes step, default, and outcome bindings without UI types', () {
      final routine = RoutineDefinition(
        schemaVersion: RoutineDefinition.currentSchemaVersion,
        id: 'dialogue-rounds',
        priority: 1,
        timeWindow: RoutineTimeWindow(
          start: _time('09:00'),
          end: _time('11:00'),
        ),
        participants: const ['npc-01'],
        conditions: const [],
        interactionPolicy: RoutineInteractionPolicy(
          allowDialogue: true,
          defaultDialogueEntryNodeId: 'routine-default',
          stepDialogueEntries: const [
            RoutineStepDialogueEntry(
              participantId: 'npc-01',
              stepId: 'hold-position',
              dialogueEntryNodeId: 'routine-step',
            ),
          ],
          outcomeDirectives: const [
            RoutineOutcomeDirective(
              outcomeTag: 'resume-work',
              directive: ResumeRoutineDirective(),
            ),
          ],
        ),
        participantSteps: [
          RoutineParticipantSteps(
            participantId: 'npc-01',
            steps: const [
              RoutineWaitStep(id: 'hold-position', durationSeconds: 100),
            ],
          ),
        ],
      );
      final directed =
          NpcRoutineDirector(catalog: RoutineCatalog(routines: [routine]))
              .replan(RuntimeGameState.initial(npcIds: const ['npc-01']))
              .routines
              .single;

      expect(directed.dialogueEntryNodeIdsFor('hold-position'), [
        'routine-step',
        'routine-default',
      ]);
      expect(directed.dialogueEntryNodeIdsFor('other-step'), [
        'routine-default',
      ]);
      expect(
        directed.directiveForOutcomeTag('resume-work'),
        isA<ResumeRoutineDirective>(),
      );
      expect(directed.directiveForOutcomeTag('unknown-outcome'), isNull);
    });
  });
}

RoutineDefinition _routine({
  required String id,
  String start = '09:00',
  String end = '11:00',
  int priority = 1,
  List<RoutineCondition> conditions = const [],
}) => RoutineDefinition(
  schemaVersion: RoutineDefinition.currentSchemaVersion,
  id: id,
  priority: priority,
  timeWindow: RoutineTimeWindow(start: _time(start), end: _time(end)),
  participants: const ['npc-01'],
  conditions: conditions,
  interactionPolicy: RoutineInteractionPolicy(
    allowDialogue: false,
    defaultDialogueEntryNodeId: null,
    stepDialogueEntries: const [],
    outcomeDirectives: const [],
  ),
  participantSteps: [
    RoutineParticipantSteps(
      participantId: 'npc-01',
      steps: const [RoutineWaitStep(id: 'hold-position', durationSeconds: 100)],
    ),
  ],
);

RoutineTime _time(String value) =>
    RoutineTime.parse(value, path: r'$fixture.time');
