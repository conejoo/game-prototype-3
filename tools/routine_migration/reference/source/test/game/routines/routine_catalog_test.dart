import 'dart:convert';
import 'dart:io';

import 'package:cozy_life_adventure/game/routines/routine_catalog.dart';
import 'package:cozy_life_adventure/game/routines/routine_catalog_loader.dart';
import 'package:cozy_life_adventure/game/routines/routine_model.dart';
import 'package:cozy_life_adventure/game/state/player_event_journal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('routine schema fixtures', () {
    test('load deterministic solo and atomic overnight models', () async {
      final catalog = await const RoutineCatalogLoader(
        source: _FileRoutineContentSource(),
        catalogPath: 'test/fixtures/routines/catalog.valid.json',
      ).load();

      expect(catalog.routineIds, [
        'fixture-group-overnight',
        'fixture-solo-day',
      ]);
      expect(catalog.containsId('fixture-solo-day'), isTrue);
      expect(catalog.findById('missing-routine'), isNull);

      final group = catalog.byId['fixture-group-overnight']!;
      expect(group.timeWindow.isOvernight, isTrue);
      expect(group.timeWindow.start.toString(), '22:30');
      expect(group.timeWindow.end.toString(), '01:15');
      expect(group.participants, ['npc-fixture-a', 'npc-fixture-b']);
      expect(
        group.interactionPolicy.outcomeDirectives.map(
          (binding) => binding.directive.kind,
        ),
        RoutineDirectiveKind.values,
      );
      final jump = group.interactionPolicy.outcomeDirectives[1].directive;
      expect(jump, isA<JumpToRoutineStepDirective>());
      expect(
        (jump as JumpToRoutineStepDirective).participantId,
        'npc-fixture-b',
      );
      expect(jump.stepId, 'b-return');

      final solo = catalog.byId['fixture-solo-day']!;
      expect(
        solo.conditions.map((condition) => condition.kind),
        RoutineConditionKind.values,
      );
      expect(
        solo.participantSteps.single.steps.map((step) => step.kind),
        RoutineStepKind.values,
      );
      final eventCondition =
          solo.conditions.last as RoutinePlayerEventCondition;
      expect(eventCondition.eventKind, PlayerEventKind.resourceGathered);
      expect(eventCondition.query.minimumCount, 1);
      expect(eventCondition.query.maximumCount, 3);
      expect(eventCondition.query.occurredWithinActiveSeconds, 600);
      final move = solo.participantSteps.single.steps.first as RoutineMoveStep;
      expect(move.target.mapId, 'fixture-town');
      expect(move.target.anchorId, 'fixture-square');
    });

    test('round-trips valid index and routine with exact version 1 shape', () {
      final indexJson = _readJson('test/fixtures/routines/catalog.valid.json');
      final index = RoutineCatalogIndex.fromJson(indexJson);
      expect(index.entries.map((entry) => entry.id), [
        'fixture-group-overnight',
        'fixture-solo-day',
      ]);
      expect(
        RoutineCatalogIndex.fromJson(index.toJson()).toJson(),
        index.toJson(),
      );

      final routineJson = _readJson(
        'test/fixtures/routines/valid/fixture_solo_day.json',
      );
      final routine = RoutineDefinition.fromJson(routineJson);
      expect(routine.toJson(), routineJson);
      expect(
        RoutineDefinition.fromJson(routine.toJson()).toJson(),
        routineJson,
      );
    });

    test('models expose immutable collection views', () async {
      final catalog = await const RoutineCatalogLoader(
        source: _FileRoutineContentSource(),
        catalogPath: 'test/fixtures/routines/catalog.valid.json',
      ).load();
      final routine = catalog.routines.first;

      expect(() => catalog.routines.clear(), throwsUnsupportedError);
      expect(() => catalog.byId['added'] = routine, throwsUnsupportedError);
      expect(() => catalog.routineIds.add('added'), throwsUnsupportedError);
      expect(() => routine.participants.clear(), throwsUnsupportedError);
      expect(() => routine.conditions.clear(), throwsUnsupportedError);
      expect(() => routine.participantSteps.clear(), throwsUnsupportedError);
      expect(
        () => routine.participantSteps.first.steps.clear(),
        throwsUnsupportedError,
      );
      expect(
        () => routine.interactionPolicy.outcomeDirectives.clear(),
        throwsUnsupportedError,
      );
    });

    test(
      'documented invalid fixtures fail at stable actionable paths',
      () async {
        await expectLater(
          const RoutineCatalogLoader(
            source: _FileRoutineContentSource(),
            catalogPath:
                'test/fixtures/routines/catalog.invalid-broken-jump.json',
          ).load(),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              allOf(
                contains('fixture_broken_jump.json'),
                contains(r'$.interactionPolicy.outcomeDirectives[0]'),
                contains('missing-step'),
              ),
            ),
          ),
        );

        expect(
          () => RoutineDefinition.fromJson(
            _readJson(
              'test/fixtures/routines/invalid/fixture_unknown_step_kind.json',
            ),
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              allOf(
                contains(r'$.participantSteps[0].steps[0].kind'),
                contains('teleport'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('strict routine parsing and validation', () {
    test('rejects unknown fields and tagged enum values', () {
      final rootUnknown = _routineJson()..['unexpected'] = true;
      _expectInvalid(rootUnknown, r'$');

      final conditionUnknown = _routineJson();
      _conditions(
        conditionUnknown,
      ).add({'kind': 'weatherGuess', 'eventId': 'heavy-rain'});
      _expectInvalid(conditionUnknown, r'$.conditions[0].kind');

      final stepUnknown = _routineJson();
      _steps(stepUnknown).first['kind'] = 'teleport';
      _expectInvalid(stepUnknown, r'$.participantSteps[0].steps[0].kind');

      final directiveUnknown = _routineJson();
      _outcomes(directiveUnknown).add({
        'outcomeTag': 'unknown',
        'directive': {'kind': 'generateDialogue'},
      });
      _expectInvalid(
        directiveUnknown,
        r'$.interactionPolicy.outcomeDirectives[0].directive.kind',
      );

      final variantUnknown = _routineJson();
      _steps(variantUnknown).first['unexpected'] = true;
      _expectInvalid(variantUnknown, r'$.participantSteps[0].steps[0]');
    });

    test('rejects blank stable IDs and speech text', () {
      final cases = <(Map<String, Object?>, String)>[];

      final routineId = _routineJson()..['id'] = ' ';
      cases.add((routineId, r'$.id'));

      final participantId = _routineJson();
      (participantId['participants']! as List<Object?>)[0] = '';
      cases.add((participantId, r'$.participants[0]'));

      final anchorId = _routineJson();
      (_steps(anchorId).first['target']! as Map<String, Object?>)['anchorId'] =
          ' ';
      cases.add((anchorId, r'$.participantSteps[0].steps[0].target.anchorId'));

      final speechText = _routineJson(step: _speechStep());
      _steps(speechText).first['text'] = '  ';
      cases.add((speechText, r'$.participantSteps[0].steps[0].text'));

      final outcomeTag = _routineJson();
      _outcomes(outcomeTag).add({
        'outcomeTag': '',
        'directive': {'kind': 'resume'},
      });
      cases.add((
        outcomeTag,
        r'$.interactionPolicy.outcomeDirectives[0].outcomeTag',
      ));

      for (final (json, path) in cases) {
        _expectInvalid(json, path);
      }
    });

    test('rejects invalid time windows and durations', () {
      for (final (start, end, path) in <(String, String, String)>[
        ('8:00', '09:00', r'$.timeWindow.start'),
        ('24:00', '09:00', r'$.timeWindow.start'),
        ('09:00', '09:00', r'$.timeWindow'),
      ]) {
        final json = _routineJson();
        final window = json['timeWindow']! as Map<String, Object?>;
        window['start'] = start;
        window['end'] = end;
        _expectInvalid(json, path);
      }

      for (final duration in [0, -1]) {
        final json = _routineJson(step: _waitStep(duration));
        _expectInvalid(json, r'$.participantSteps[0].steps[0].durationSeconds');
      }
    });

    test('rejects invalid bounded PlayerEventJournal queries', () {
      final cases = <(Map<String, Object?>, String)>[];

      final unknownKind = _routineJson();
      _conditions(
        unknownKind,
      ).add(_playerEventCondition(eventKind: 'combatWon'));
      cases.add((unknownKind, r'$.conditions[0].eventKind'));

      final negativeMinimum = _routineJson();
      _conditions(negativeMinimum).add(_playerEventCondition(minimumCount: -1));
      cases.add((negativeMinimum, r'$.conditions[0].minimumCount'));

      final invertedBounds = _routineJson();
      _conditions(
        invertedBounds,
      ).add(_playerEventCondition(minimumCount: 2, maximumCount: 1));
      cases.add((invertedBounds, r'$.conditions[0].maximumCount'));

      final negativeRecency = _routineJson();
      _conditions(
        negativeRecency,
      ).add(_playerEventCondition(occurredWithinActiveSeconds: -0.1));
      cases.add((
        negativeRecency,
        r'$.conditions[0].occurredWithinActiveSeconds',
      ));

      for (final (json, path) in cases) {
        _expectInvalid(json, path);
      }
    });

    test('rejects duplicate and mismatched participants and step IDs', () {
      final duplicateParticipant = _routineJson();
      (duplicateParticipant['participants']! as List<Object?>).add(
        'npc-fixture-a',
      );
      _expectInvalid(duplicateParticipant, r'$.participants[1]');

      final undeclaredPlan = _routineJson();
      _participantPlans(undeclaredPlan).first['participantId'] =
          'npc-fixture-b';
      _expectInvalid(undeclaredPlan, r'$.participantSteps[0].participantId');

      final missingPlan = _routineJson();
      _participantPlans(missingPlan).clear();
      _expectInvalid(missingPlan, r'$.participants[0]');

      final duplicatePlan = _routineJson();
      _participantPlans(duplicatePlan).add({
        'participantId': 'npc-fixture-a',
        'steps': [_waitStep(1, id: 'other')],
      });
      _expectInvalid(duplicatePlan, r'$.participantSteps[1].participantId');

      final duplicateStep = _routineJson();
      _steps(duplicateStep).add(_moveStep());
      _expectInvalid(duplicateStep, r'$.participantSteps[0].steps[1].id');
    });

    test('rejects broken interaction entries and outcome jumps', () {
      final missingEntryStep = _routineJson();
      _stepEntries(missingEntryStep).add({
        'participantId': 'npc-fixture-a',
        'stepId': 'missing-step',
        'dialogueEntryNodeId': 'fixture-entry',
      });
      _expectInvalid(
        missingEntryStep,
        r'$.interactionPolicy.stepDialogueEntries[0].stepId',
      );

      final undeclaredJumpParticipant = _routineJson();
      _outcomes(undeclaredJumpParticipant).add({
        'outcomeTag': 'jump',
        'directive': {
          'kind': 'jumpToStep',
          'participantId': 'npc-fixture-b',
          'stepId': 'arrive',
        },
      });
      _expectInvalid(
        undeclaredJumpParticipant,
        r'$.interactionPolicy.outcomeDirectives[0].directive.participantId',
      );

      final brokenJump = _routineJson();
      _outcomes(brokenJump).add({
        'outcomeTag': 'jump',
        'directive': {
          'kind': 'jumpToStep',
          'participantId': 'npc-fixture-a',
          'stepId': 'missing-step',
        },
      });
      _expectInvalid(
        brokenJump,
        r'$.interactionPolicy.outcomeDirectives[0].directive.stepId',
      );

      final duplicateOutcome = _routineJson();
      _outcomes(duplicateOutcome).addAll([
        {
          'outcomeTag': 'same-tag',
          'directive': {'kind': 'resume'},
        },
        {
          'outcomeTag': 'same-tag',
          'directive': {'kind': 'endRoutineForDay'},
        },
      ]);
      _expectInvalid(
        duplicateOutcome,
        r'$.interactionPolicy.outcomeDirectives[1].outcomeTag',
      );

      final disabled = _routineJson(allowDialogue: false);
      (disabled['interactionPolicy']!
              as Map<String, Object?>)['defaultDialogueEntryNodeId'] =
          'fixture-entry';
      _expectInvalid(disabled, r'$.interactionPolicy');
    });
  });

  group('routine catalog index and loader', () {
    test(
      'shipping index loads production routines in stable ID order',
      () async {
        final catalog = await const RoutineCatalogLoader(
          source: _FileRoutineContentSource(),
        ).load();

        expect(catalog.routineIds, [
          'asha-herb-day',
          'asha-herb-evening',
          'celia-repairs-day',
          'celia-repairs-evening',
          'corin-route-day',
          'corin-route-evening',
          'della-inn-day',
          'della-inn-evening',
          'edric-afternoon-river-notes',
          'edric-afternoon-rounds',
          'edric-evening-fishing',
          'edric-evening-rain-shelter',
          'fara-waterfront-day',
          'fara-waterfront-evening',
          'harlan-docks-day',
          'harlan-docks-evening',
          'helena-afternoon-archive',
          'helena-afternoon-ledger-review',
          'helena-afternoon-moonflower-records',
          'helena-evening-archive',
          'ivo-docks-day',
          'ivo-docks-evening',
          'maris-chandlery-day',
          'maris-chandlery-evening',
          'nessa-town-day',
          'nessa-town-evening',
          'orren-town-day',
          'orren-town-evening',
          'pella-dock-day',
          'pella-dock-evening',
          'rook-town-day',
          'rook-town-evening',
          'tess-store-day',
          'tess-store-evening',
          'vale-breakfast',
          'vale-evening-home',
          'vale-midday-briefing',
          'vale-morning-work',
          'vale-overnight-home',
        ]);
      },
    );

    test('rejects index schema, duplicate IDs/assets, and unknown keys', () {
      expect(
        () =>
            RoutineCatalogIndex.fromJson({..._indexJson(), 'schemaVersion': 2}),
        _formatAt(r'$.schemaVersion'),
      );

      final duplicateId = _indexJson();
      (duplicateId['routines']! as List<Object?>).add({
        'schemaVersion': 1,
        'id': 'fixture-routine',
        'asset': 'other.json',
      });
      expect(
        () => RoutineCatalogIndex.fromJson(duplicateId),
        _formatAt(r'$.routines[1].id'),
      );

      final duplicateAsset = _indexJson();
      (duplicateAsset['routines']! as List<Object?>).add({
        'schemaVersion': 1,
        'id': 'other-routine',
        'asset': 'fixture.json',
      });
      expect(
        () => RoutineCatalogIndex.fromJson(duplicateAsset),
        _formatAt(r'$.routines[1].asset'),
      );

      final unknown = _indexJson()..['unexpected'] = true;
      expect(() => RoutineCatalogIndex.fromJson(unknown), _formatAt(r'$'));
    });

    test('loader reports source path, invalid JSON, and ID mismatch', () async {
      final badJson = _MemoryRoutineContentSource({'catalog.json': '{broken'});
      await expectLater(
        RoutineCatalogLoader(
          source: badJson,
          catalogPath: 'catalog.json',
        ).load(),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('catalog.json'),
          ),
        ),
      );

      final mismatch = _MemoryRoutineContentSource({
        'catalog.json': jsonEncode(_indexJson()),
        'fixture.json': jsonEncode(_routineJson(id: 'other-routine')),
      });
      await expectLater(
        RoutineCatalogLoader(
          source: mismatch,
          catalogPath: 'catalog.json',
        ).load(),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            allOf(contains('fixture.json'), contains(r'$.id')),
          ),
        ),
      );
      expect(mismatch.requestedPaths, ['catalog.json', 'fixture.json']);
    });
  });
}

Map<String, Object?> _readJson(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  return (decoded as Map).cast<String, Object?>();
}

void _expectInvalid(Map<String, Object?> json, String path) {
  expect(
    () => RoutineDefinition.fromJson(json),
    _formatAt(path),
    reason: jsonEncode(json),
  );
}

Matcher _formatAt(String path) => throwsA(
  isA<FormatException>().having(
    (error) => error.message,
    'message',
    contains(path),
  ),
);

Map<String, Object?> _indexJson() => {
  'schemaVersion': 1,
  'routines': [
    {'schemaVersion': 1, 'id': 'fixture-routine', 'asset': 'fixture.json'},
  ],
};

Map<String, Object?> _routineJson({
  String id = 'fixture-routine',
  Map<String, Object?>? step,
  bool allowDialogue = true,
}) => {
  'schemaVersion': 1,
  'id': id,
  'priority': 1,
  'timeWindow': {'start': '08:00', 'end': '09:00'},
  'participants': ['npc-fixture-a'],
  'conditions': <Object?>[],
  'interactionPolicy': {
    'allowDialogue': allowDialogue,
    'defaultDialogueEntryNodeId': null,
    'stepDialogueEntries': <Object?>[],
    'outcomeDirectives': <Object?>[],
  },
  'participantSteps': <Object?>[
    {
      'participantId': 'npc-fixture-a',
      'steps': <Object?>[step ?? _moveStep()],
    },
  ],
};

Map<String, Object?> _moveStep() => {
  'kind': 'move',
  'id': 'arrive',
  'target': {'mapId': 'fixture-map', 'anchorId': 'fixture-anchor'},
};

Map<String, Object?> _waitStep(num duration, {String id = 'wait'}) => {
  'kind': 'wait',
  'id': id,
  'durationSeconds': duration,
};

Map<String, Object?> _speechStep() => {
  'kind': 'speech',
  'id': 'speak',
  'text': 'Fixture speech.',
  'durationSeconds': 1,
};

Map<String, Object?> _playerEventCondition({
  String eventKind = 'areaEntered',
  int minimumCount = 1,
  int? maximumCount,
  num? occurredWithinActiveSeconds,
}) => {
  'kind': 'playerEvent',
  'eventKind': eventKind,
  'subjectId': 'fixture-area',
  'targetId': null,
  'minimumCount': minimumCount,
  'maximumCount': maximumCount,
  'occurredWithinActiveSeconds': occurredWithinActiveSeconds,
};

List<Map<String, Object?>> _conditions(Map<String, Object?> json) =>
    (json['conditions']! as List<Object?>).cast<Map<String, Object?>>();

List<Map<String, Object?>> _participantPlans(Map<String, Object?> json) =>
    (json['participantSteps']! as List<Object?>).cast<Map<String, Object?>>();

List<Map<String, Object?>> _steps(Map<String, Object?> json) =>
    (_participantPlans(json).first['steps']! as List<Object?>)
        .cast<Map<String, Object?>>();

Map<String, Object?> _interaction(Map<String, Object?> json) =>
    json['interactionPolicy']! as Map<String, Object?>;

List<Map<String, Object?>> _stepEntries(Map<String, Object?> json) =>
    (_interaction(json)['stepDialogueEntries']! as List<Object?>)
        .cast<Map<String, Object?>>();

List<Map<String, Object?>> _outcomes(Map<String, Object?> json) =>
    (_interaction(json)['outcomeDirectives']! as List<Object?>)
        .cast<Map<String, Object?>>();

final class _FileRoutineContentSource implements RoutineContentSource {
  const _FileRoutineContentSource();

  @override
  Future<String> read(String assetPath) => File(assetPath).readAsString();
}

final class _MemoryRoutineContentSource implements RoutineContentSource {
  _MemoryRoutineContentSource(this.values);

  final Map<String, String> values;
  final List<String> requestedPaths = [];

  @override
  Future<String> read(String assetPath) async {
    requestedPaths.add(assetPath);
    return values[assetPath]!;
  }
}
