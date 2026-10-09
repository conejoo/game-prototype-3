import 'dart:io';

import 'package:cozy_life_adventure/game/routines/routine_catalog.dart';
import 'package:cozy_life_adventure/game/routines/routine_catalog_loader.dart';
import 'package:cozy_life_adventure/game/routines/routine_model.dart';
import 'package:cozy_life_adventure/game/routines/routine_resolver.dart';
import 'package:cozy_life_adventure/game/state/player_event_journal.dart';
import 'package:cozy_life_adventure/game/state/runtime_game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RoutineCatalog catalog;

  setUpAll(() async {
    catalog = await const RoutineCatalogLoader(
      source: _FileRoutineContentSource(),
    ).load();
  });

  test('default and heavy-rain fallbacks cover every minute exactly once', () {
    for (var minute = 0; minute < 24 * 60; minute++) {
      final time = _timeAtMinute(minute);
      _expectCompleteCoverage(catalog, _snapshot(time: time), time);
      _expectCompleteCoverage(
        catalog,
        _snapshot(time: time, activeWorldEventIds: {'heavy-rain'}),
        time,
      );
    }

    expect(_assignments(catalog, _snapshot(time: _time('00:00'))), {
      'npc-01': 'vale-overnight-home',
      'npc-02': 'vale-overnight-home',
    });
    expect(_assignments(catalog, _snapshot(time: _time('06:00'))), {
      'npc-01': 'vale-breakfast',
      'npc-02': 'vale-breakfast',
    });
    expect(_assignments(catalog, _snapshot(time: _time('08:00'))), {
      'npc-01': 'vale-morning-work',
      'npc-02': 'vale-morning-work',
    });
    expect(_assignments(catalog, _snapshot(time: _time('12:00'))), {
      'npc-01': 'vale-midday-briefing',
      'npc-02': 'vale-midday-briefing',
    });
    expect(_assignments(catalog, _snapshot(time: _time('13:00'))), {
      'npc-01': 'edric-afternoon-rounds',
      'npc-02': 'helena-afternoon-archive',
    });
    expect(_assignments(catalog, _snapshot(time: _time('17:00'))), {
      'npc-01': 'edric-evening-fishing',
      'npc-02': 'helena-evening-archive',
    });
    expect(_assignments(catalog, _snapshot(time: _time('20:00'))), {
      'npc-01': 'vale-evening-home',
      'npc-02': 'vale-evening-home',
    });
    expect(_assignments(catalog, _snapshot(time: _time('22:00'))), {
      'npc-01': 'vale-overnight-home',
      'npc-02': 'vale-overnight-home',
    });
  });

  test(
    'facts, journal events, flags, and weather replace stable fallbacks',
    () {
      final journal = PlayerEventJournal().record(
        kind: PlayerEventKind.resourceGathered,
        subjectId: 'moonflower',
        activeSeconds: 100,
      );
      final afternoonVariants = _assignments(
        catalog,
        _snapshot(
          time: _time('14:00'),
          learnedFactIds: {'npc-01-river-fishing'},
          eventJournal: journal,
          activePlaySeconds: 100,
        ),
      );

      expect(afternoonVariants, {
        'npc-01': 'edric-afternoon-river-notes',
        'npc-02': 'helena-afternoon-moonflower-records',
      });
      expect(
        _assignments(
          catalog,
          _snapshot(
            time: _time('14:00'),
            npc02Flags: {'npc-02-archive-lead-shared'},
            eventJournal: journal,
            activePlaySeconds: 100,
          ),
        )['npc-02'],
        'helena-afternoon-ledger-review',
      );
      expect(
        _assignments(
          catalog,
          _snapshot(time: _time('18:00'), activeWorldEventIds: {'heavy-rain'}),
        )['npc-01'],
        'edric-evening-rain-shelter',
      );
    },
  );

  test(
    'Maris keeps an ordinary service station every minute without affinity',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'npc-03')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'maris-fitting-01'),
        );
      }
    },
  );

  test(
    'Della keeps an ordinary inn host station every minute without affinity',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'npc-14')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('lantern-rest', 'inn-host-01'),
        );
      }
    },
  );

  test(
    'Rook keeps an accessible town survey station every minute without affinity',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'npc-15')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'ranger-briefing-01'),
        );
      }
    },
  );

  test(
    'Asha offers ordinary care every minute without affinity or farm gates',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'npc-16')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'herb-supplies-01'),
        );
      }
    },
  );

  test(
    'Corin offers solo preparation every minute without affinity or profession gates',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'npc-17')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'corin-route-station-01'),
        );
      }
    },
  );

  test(
    'Fara offers free song access every minute without affinity or profession gates',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'npc-19')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'fara-waterfront-station-01'),
        );
      }
    },
  );

  test(
    'Pella offers ungated dock contact every minute without affinity or profession gates',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'npc-20')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'pella-weaving-01'),
        );
      }
    },
  );

  test(
    'Orren visitor offers ungated town contact every minute without affinity or profession gates',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'visitor-orren-vey')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'traveler-chat-01'),
        );
      }
    },
  );

  test(
    'Nessa visitor offers ungated town contact every minute without affinity or profession gates',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'visitor-nessa-quill')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'nessa-visitor-station-01'),
        );
      }
    },
  );

  test(
    'Harlan keeps an ordinary dock station every minute without affinity',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'npc-04')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'harlan-sluice-practice-01'),
        );
      }
    },
  );

  test(
    'Tess keeps an ordinary store station every minute without affinity',
    () {
      for (var minute = 0; minute < 1440; minute++) {
        final snapshot = _snapshot(time: _timeAtMinute(minute));
        final assignments = const RoutineResolver()
            .resolve(catalog: catalog, snapshot: snapshot)
            .assignments
            .where((a) => a.participantId == 'npc-06')
            .toList();
        expect(assignments, hasLength(1));
        final routine = catalog.byId[assignments.single.routineId]!;
        expect(routine.conditions, isEmpty);
        expect(routine.interactionPolicy.allowDialogue, isTrue);
        final move =
            routine.participantSteps.single.steps.first as RoutineMoveStep;
        expect(
          (move.target.mapId, move.target.anchorId),
          ('alderwake', 'store-service-tess-01'),
        );
      }
    },
  );

  test('Ivo keeps an ordinary dock station every minute without affinity', () {
    for (var minute = 0; minute < 1440; minute++) {
      final snapshot = _snapshot(time: _timeAtMinute(minute));
      final assignments = const RoutineResolver()
          .resolve(catalog: catalog, snapshot: snapshot)
          .assignments
          .where((a) => a.participantId == 'npc-07')
          .toList();
      expect(assignments, hasLength(1));
      final routine = catalog.byId[assignments.single.routineId]!;
      expect(routine.conditions, isEmpty);
      expect(routine.interactionPolicy.allowDialogue, isTrue);
      final move =
          routine.participantSteps.single.steps.first as RoutineMoveStep;
      expect(
        (move.target.mapId, move.target.anchorId),
        ('alderwake', 'passenger-booking-ivo-01'),
      );
    }
  });

  test('production includes solo and atomic group routines', () {
    expect(
      catalog.routines.any((routine) => routine.participants.length == 1),
      isTrue,
    );
    final midday = _assignments(catalog, _snapshot(time: _time('12:30')));
    expect(midday, {
      'npc-01': 'vale-midday-briefing',
      'npc-02': 'vale-midday-briefing',
    });
  });

  test(
    'production and named fixtures cover locked content vocabulary',
    () async {
      final productionConditionKinds = {
        for (final routine in catalog.routines)
          for (final condition in routine.conditions) condition.kind,
      };
      final productionStepKinds = {
        for (final routine in catalog.routines)
          for (final plan in routine.participantSteps)
            for (final step in plan.steps) step.kind,
      };
      final productionDirectiveKinds = {
        for (final routine in catalog.routines)
          for (final outcome in routine.interactionPolicy.outcomeDirectives)
            outcome.directive.kind,
      };
      final documentedFixtures = await const RoutineCatalogLoader(
        source: _FileRoutineContentSource(),
        catalogPath: 'test/fixtures/routines/catalog.valid.json',
      ).load();
      final allDirectiveKinds = {
        ...productionDirectiveKinds,
        for (final routine in documentedFixtures.routines)
          for (final outcome in routine.interactionPolicy.outcomeDirectives)
            outcome.directive.kind,
      };

      expect(productionConditionKinds, RoutineConditionKind.values.toSet());
      expect(productionStepKinds, RoutineStepKind.values.toSet());
      expect(productionDirectiveKinds, {
        RoutineDirectiveKind.resume,
        RoutineDirectiveKind.jumpToStep,
        RoutineDirectiveKind.endRoutineForDay,
      });
      expect(allDirectiveKinds, RoutineDirectiveKind.values.toSet());
    },
  );
}

void _expectCompleteCoverage(
  RoutineCatalog catalog,
  RoutineResolutionSnapshot snapshot,
  RoutineTime time,
) {
  final assignments = _assignments(catalog, snapshot);
  if (assignments.keys.toSet().difference({'npc-01', 'npc-02'}).isNotEmpty ||
      {'npc-01', 'npc-02'}.difference(assignments.keys.toSet()).isNotEmpty) {
    fail('$time resolved unexpected participant coverage: $assignments');
  }
}

Map<String, String> _assignments(
  RoutineCatalog catalog,
  RoutineResolutionSnapshot snapshot,
) => {
  for (final assignment
      in const RoutineResolver()
          .resolve(catalog: catalog, snapshot: snapshot)
          .assignments)
    if (assignment.participantId == 'npc-01' ||
        assignment.participantId == 'npc-02')
      assignment.participantId: assignment.routineId,
};

RoutineResolutionSnapshot _snapshot({
  required RoutineTime time,
  Set<String> activeWorldEventIds = const {},
  Set<String> learnedFactIds = const {},
  Set<String> npc02Flags = const {},
  PlayerEventJournal? eventJournal,
  double activePlaySeconds = 0,
}) => RoutineResolutionSnapshot(
  dayIndex: 0,
  time: time,
  activeWorldEventIds: activeWorldEventIds,
  suppressedRoutineIds: const {},
  relationships: {
    'npc-01': NpcRelationshipState(
      npcId: 'npc-01',
      learnedFactIds: learnedFactIds,
    ),
    'npc-02': NpcRelationshipState(npcId: 'npc-02', flags: npc02Flags),
  },
  eventJournal: eventJournal ?? PlayerEventJournal(),
  activePlaySeconds: activePlaySeconds,
);

RoutineTime _timeAtMinute(int minute) => _time(
  '${(minute ~/ 60).toString().padLeft(2, '0')}:'
  '${(minute % 60).toString().padLeft(2, '0')}',
);

RoutineTime _time(String value) => RoutineTime.parse(value, path: r'$test');

final class _FileRoutineContentSource implements RoutineContentSource {
  const _FileRoutineContentSource();

  @override
  Future<String> read(String assetPath) => File(assetPath).readAsString();
}
