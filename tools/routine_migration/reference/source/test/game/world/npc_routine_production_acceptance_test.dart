import 'package:cozy_life_adventure/game/cozy_adventure_game.dart';
import 'package:cozy_life_adventure/game/npc/npc_component.dart';
import 'package:cozy_life_adventure/game/npc/npc_routine_executor.dart';
import 'package:cozy_life_adventure/game/persistence/game_persistence_coordinator.dart';
import 'package:cozy_life_adventure/game/persistence/save_game.dart';
import 'package:cozy_life_adventure/game/state/runtime_game_state.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/game_test_pump.dart';
import '../../support/game_content_test_support.dart';
import '../../support/in_memory_save_game_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'bundled chapter cast routines run a full day and reload durable state',
    (tester) async {
      final repository = InMemorySaveGameRepository(
        initialState: RuntimeGameState.initial(
          npcIds: const [
            'npc-01',
            'npc-02',
            'npc-03',
            'npc-04',
            'npc-06',
            'npc-07',
            'npc-08',
            'npc-14',
            'npc-15',
            'npc-16',
            'npc-17',
            'npc-19',
            'npc-20',
            'visitor-orren-vey',
            'visitor-nessa-quill',
          ],
        ),
      );
      final game = CozyAdventureGame(saveGameRepository: repository);
      await tester.pumpWidget(GameWidget(game: game));
      await settleGameLoad(tester);

      final seenRoutineIds = <String>{};
      final seenStates = <NpcRoutineExecutionState>{};
      final seenActionIds = <String>{};
      final speakingNpcIds = <String>{};
      final seenExecutorMaps = <String>{};

      void observe({bool verifyWorldInvariants = true}) {
        final plan = game.routineDirector.currentPlan!;
        if (plan.resolution.assignments.length != 15 ||
            plan.resolution.assignments
                .map((assignment) => assignment.participantId)
                .toSet()
                .difference(const {
                  'npc-01',
                  'npc-02',
                  'npc-03',
                  'npc-04',
                  'npc-06',
                  'npc-07',
                  'npc-08',
                  'npc-14',
                  'npc-15',
                  'npc-16',
                  'npc-17',
                  'npc-19',
                  'npc-20',
                  'visitor-orren-vey',
                  'visitor-nessa-quill',
                })
                .isNotEmpty) {
          fail(
            'Unexpected full-day participant assignments: '
            '${plan.resolution.assignments}',
          );
        }
        seenRoutineIds.addAll(plan.resolution.routineIds);

        final npcs = game.activeWorld.children
            .whereType<NpcComponent>()
            .toList();
        if (verifyWorldInvariants) {
          expect(npcs, hasLength(15));
          expect(
            game.activeWorld.npcComponentsById.keys,
            unorderedEquals(const [
              'npc-01',
              'npc-02',
              'npc-03',
              'npc-04',
              'npc-06',
              'npc-07',
              'npc-08',
              'npc-14',
              'npc-15',
              'npc-16',
              'npc-17',
              'npc-19',
              'npc-20',
              'visitor-orren-vey',
              'visitor-nessa-quill',
            ]),
          );
          expect(
            npcs.map((npc) => npc.objectId).toSet(),
            hasLength(npcs.length),
          );

          final occupancy = game.activeWorld.navigationOccupancy.reservations;
          expect(
            occupancy.map((reservation) => reservation.occupantId).toSet(),
            hasLength(occupancy.length),
          );
        }

        for (final npc in npcs) {
          final executor = npc.routineExecutor!;
          if (executor.state == NpcRoutineExecutionState.failed) {
            fail(
              '${npc.definition.id}/${executor.routineId} failed: '
              '${executor.failureReason}, ${executor.noPathReason}, '
              '${executor.mapNoRouteReason}',
            );
          }
          seenStates.add(executor.state);
          seenExecutorMaps.add(executor.currentMapId);
          final actionId = executor.activeActionId;
          if (actionId != null) {
            seenActionIds.add(actionId);
          }
          if (executor.activeSpeechText != null) {
            speakingNpcIds.add(npc.definition.id);
          }
        }
      }

      observe();
      for (var hour = 0; hour < 24; hour++) {
        game.advanceDayCycle(25);
        observe();
        for (var second = 0; second < 25; second++) {
          for (final npc in game.activeWorld.npcComponentsById.values) {
            npc.advanceRoutine(1);
          }
          observe(verifyWorldInvariants: false);
        }
      }
      if (game.runtimeState.dayIndex == 0) {
        game.advanceDayCycle(0.001);
        observe();
      }

      expect(game.runtimeState.dayIndex, 1);
      expect(game.runtimeState.suppressedRoutineIds, isEmpty);
      expect(
        seenRoutineIds,
        containsAll(const {
          'harlan-docks-day',
          'harlan-docks-evening',
          'maris-chandlery-day',
          'maris-chandlery-evening',
          'tess-store-day',
          'tess-store-evening',
          'ivo-docks-day',
          'ivo-docks-evening',
          'celia-repairs-day',
          'celia-repairs-evening',
          'della-inn-day',
          'della-inn-evening',
          'rook-town-day',
          'rook-town-evening',
          'asha-herb-day',
          'asha-herb-evening',
          'corin-route-day',
          'corin-route-evening',
          'fara-waterfront-day',
          'fara-waterfront-evening',
          'pella-dock-day',
          'pella-dock-evening',
          'orren-town-day',
          'orren-town-evening',
          'nessa-town-day',
          'nessa-town-evening',
          'vale-morning-work',
          'vale-midday-briefing',
          'edric-afternoon-rounds',
          'helena-afternoon-archive',
          'edric-evening-fishing',
          'helena-evening-archive',
          'vale-evening-home',
          'vale-overnight-home',
          'vale-breakfast',
        }),
      );
      expect(
        seenStates,
        containsAll(const {
          NpcRoutineExecutionState.moving,
          NpcRoutineExecutionState.waiting,
          NpcRoutineExecutionState.acting,
          NpcRoutineExecutionState.speaking,
        }),
      );
      expect(
        seenActionIds,
        containsAll(const {'river-fishing', 'archive-work'}),
      );
      expect(speakingNpcIds, {'npc-01', 'npc-02'});
      expect(seenExecutorMaps, {
        'alderwake',
        'mayor-vale-home',
        'lantern-rest',
      });

      final durableJson = SaveGame.fromRuntimeGameState(
        game.runtimeState,
      ).toJson(itemCatalog: testGameContent.items);
      for (final transientKey in const [
        'routineId',
        'routineStep',
        'routinePaused',
        'npcPositions',
        'navigationPath',
      ]) {
        expect(durableJson, isNot(contains(transientKey)));
      }
      expect(await game.requestSave(), SaveOutcome.saved);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      final reloaded = CozyAdventureGame(saveGameRepository: repository);
      await tester.pumpWidget(GameWidget(game: reloaded));
      await settleGameLoad(tester);

      expect(
        SaveGame.fromRuntimeGameState(
          reloaded.runtimeState,
        ).toJson(itemCatalog: testGameContent.items),
        durableJson,
      );
      expect(
        reloaded.routineDirector.currentPlan!.resolution,
        game.routineDirector.currentPlan!.resolution,
      );
      expect(
        reloaded.activeWorld.npcComponentsById.keys,
        unorderedEquals(const [
          'npc-01',
          'npc-02',
          'npc-03',
          'npc-04',
          'npc-06',
          'npc-07',
          'npc-08',
          'npc-14',
          'npc-15',
          'npc-16',
          'npc-17',
          'npc-19',
          'npc-20',
          'visitor-orren-vey',
          'visitor-nessa-quill',
        ]),
      );
      expect(
        reloaded.activeWorld.npcComponentsById.values.map(
          (npc) => npc.routineState,
        ),
        everyElement(isNot(NpcRoutineExecutionState.failed)),
      );
    },
  );
}
