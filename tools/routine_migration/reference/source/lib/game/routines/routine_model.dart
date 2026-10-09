import '../content/strict_json_reader.dart';
import '../state/player_event_journal.dart';

enum RoutineConditionKind {
  worldEventActive,
  worldEventInactive,
  learnedFact,
  relationshipFlagSet,
  relationshipFlagUnset,
  playerEvent,
}

enum RoutineStepKind { move, wait, action, speech }

enum RoutineDirectiveKind {
  resume,
  jumpToStep,
  endRoutineForDay,
  activateWorldEvent,
  deactivateWorldEvent,
}

/// Minute-precision authored time in one normalized day.
final class RoutineTime implements Comparable<RoutineTime> {
  const RoutineTime._(this.hour, this.minute);

  final int hour;
  final int minute;

  int get minuteOfDay => hour * 60 + minute;

  factory RoutineTime.parse(String value, {required String path}) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('$path: Expected time in HH:mm format.');
    }
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) {
      throw FormatException('$path: Time must be between 00:00 and 23:59.');
    }
    return RoutineTime._(hour, minute);
  }

  @override
  int compareTo(RoutineTime other) => minuteOfDay.compareTo(other.minuteOfDay);

  @override
  bool operator ==(Object other) =>
      other is RoutineTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

final class RoutineTimeWindow {
  const RoutineTimeWindow({required this.start, required this.end});

  final RoutineTime start;
  final RoutineTime end;

  bool get isOvernight => end.compareTo(start) < 0;

  /// Whether [time] falls in this inclusive-start, exclusive-end window.
  bool contains(RoutineTime time) {
    final minute = time.minuteOfDay;
    final startMinute = start.minuteOfDay;
    final endMinute = end.minuteOfDay;
    return isOvernight
        ? minute >= startMinute || minute < endMinute
        : minute >= startMinute && minute < endMinute;
  }

  factory RoutineTimeWindow.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    StrictJsonReader.requireExactKeys(json, const {'start', 'end'}, path);
    return RoutineTimeWindow(
      start: RoutineTime.parse(
        StrictJsonReader.string(json, 'start', path),
        path: '$path.start',
      ),
      end: RoutineTime.parse(
        StrictJsonReader.string(json, 'end', path),
        path: '$path.end',
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'start': start.toString(),
    'end': end.toString(),
  };
}

sealed class RoutineCondition {
  const RoutineCondition();

  RoutineConditionKind get kind;

  Map<String, Object?> toJson();

  factory RoutineCondition.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    final kind = _parseEnum(
      RoutineConditionKind.values,
      StrictJsonReader.string(json, 'kind', path),
      '$path.kind',
      'condition kind',
    );
    return switch (kind) {
      RoutineConditionKind.worldEventActive ||
      RoutineConditionKind.worldEventInactive => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'eventId',
        }, path);
        return RoutineWorldEventCondition(
          kind: kind,
          eventId: StrictJsonReader.string(json, 'eventId', path),
        );
      }(),
      RoutineConditionKind.learnedFact => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'npcId',
          'factId',
        }, path);
        return RoutineLearnedFactCondition(
          npcId: StrictJsonReader.string(json, 'npcId', path),
          factId: StrictJsonReader.string(json, 'factId', path),
        );
      }(),
      RoutineConditionKind.relationshipFlagSet ||
      RoutineConditionKind.relationshipFlagUnset => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'npcId',
          'flagId',
        }, path);
        return RoutineRelationshipFlagCondition(
          kind: kind,
          npcId: StrictJsonReader.string(json, 'npcId', path),
          flagId: StrictJsonReader.string(json, 'flagId', path),
        );
      }(),
      RoutineConditionKind.playerEvent => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'eventKind',
          'subjectId',
          'targetId',
          'minimumCount',
          'maximumCount',
          'occurredWithinActiveSeconds',
        }, path);
        final eventKindName = StrictJsonReader.string(json, 'eventKind', path);
        final eventKind = _parseEnum(
          PlayerEventKind.values,
          eventKindName,
          '$path.eventKind',
          'player event kind',
        );
        return RoutinePlayerEventCondition(
          eventKind: eventKind,
          subjectId: StrictJsonReader.nullableString(json, 'subjectId', path),
          targetId: StrictJsonReader.nullableString(json, 'targetId', path),
          minimumCount: StrictJsonReader.integer(json, 'minimumCount', path),
          maximumCount: StrictJsonReader.nullableInteger(
            json,
            'maximumCount',
            path,
          ),
          occurredWithinActiveSeconds: StrictJsonReader.nullableFiniteDouble(
            json,
            'occurredWithinActiveSeconds',
            path,
          ),
        );
      }(),
    };
  }
}

final class RoutineWorldEventCondition extends RoutineCondition {
  const RoutineWorldEventCondition({required this.kind, required this.eventId})
    : assert(
        kind == RoutineConditionKind.worldEventActive ||
            kind == RoutineConditionKind.worldEventInactive,
      );

  @override
  final RoutineConditionKind kind;
  final String eventId;

  @override
  Map<String, Object?> toJson() => {'kind': kind.name, 'eventId': eventId};
}

final class RoutineLearnedFactCondition extends RoutineCondition {
  const RoutineLearnedFactCondition({
    required this.npcId,
    required this.factId,
  });

  @override
  RoutineConditionKind get kind => RoutineConditionKind.learnedFact;

  final String npcId;
  final String factId;

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'npcId': npcId,
    'factId': factId,
  };
}

final class RoutineRelationshipFlagCondition extends RoutineCondition {
  const RoutineRelationshipFlagCondition({
    required this.kind,
    required this.npcId,
    required this.flagId,
  }) : assert(
         kind == RoutineConditionKind.relationshipFlagSet ||
             kind == RoutineConditionKind.relationshipFlagUnset,
       );

  @override
  final RoutineConditionKind kind;
  final String npcId;
  final String flagId;

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'npcId': npcId,
    'flagId': flagId,
  };
}

final class RoutinePlayerEventCondition extends RoutineCondition {
  const RoutinePlayerEventCondition({
    required this.eventKind,
    required this.subjectId,
    required this.targetId,
    required this.minimumCount,
    required this.maximumCount,
    required this.occurredWithinActiveSeconds,
  });

  @override
  RoutineConditionKind get kind => RoutineConditionKind.playerEvent;

  final PlayerEventKind eventKind;
  final String? subjectId;
  final String? targetId;
  final int minimumCount;
  final int? maximumCount;
  final double? occurredWithinActiveSeconds;

  PlayerEventCondition get query => PlayerEventCondition(
    kind: eventKind,
    subjectId: subjectId,
    targetId: targetId,
    minimumCount: minimumCount,
    maximumCount: maximumCount,
    occurredWithinActiveSeconds: occurredWithinActiveSeconds,
  );

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'eventKind': eventKind.name,
    'subjectId': subjectId,
    'targetId': targetId,
    'minimumCount': minimumCount,
    'maximumCount': maximumCount,
    'occurredWithinActiveSeconds': occurredWithinActiveSeconds,
  };
}

final class RoutineAnchorReference {
  const RoutineAnchorReference({required this.mapId, required this.anchorId});

  final String mapId;
  final String anchorId;

  factory RoutineAnchorReference.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    StrictJsonReader.requireExactKeys(json, const {'mapId', 'anchorId'}, path);
    return RoutineAnchorReference(
      mapId: StrictJsonReader.string(json, 'mapId', path),
      anchorId: StrictJsonReader.string(json, 'anchorId', path),
    );
  }

  Map<String, Object?> toJson() => {'mapId': mapId, 'anchorId': anchorId};
}

sealed class RoutineStep {
  const RoutineStep({required this.id});

  final String id;
  RoutineStepKind get kind;

  Map<String, Object?> toJson();

  factory RoutineStep.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    final kind = _parseEnum(
      RoutineStepKind.values,
      StrictJsonReader.string(json, 'kind', path),
      '$path.kind',
      'step kind',
    );
    return switch (kind) {
      RoutineStepKind.move => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'id',
          'target',
        }, path);
        return RoutineMoveStep(
          id: StrictJsonReader.string(json, 'id', path),
          target: RoutineAnchorReference.fromJson(
            StrictJsonReader.object(json['target'], '$path.target'),
            path: '$path.target',
          ),
        );
      }(),
      RoutineStepKind.wait => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'id',
          'durationSeconds',
        }, path);
        return RoutineWaitStep(
          id: StrictJsonReader.string(json, 'id', path),
          durationSeconds: StrictJsonReader.finiteDouble(
            json,
            'durationSeconds',
            path,
          ),
        );
      }(),
      RoutineStepKind.action => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'id',
          'actionId',
          'durationSeconds',
        }, path);
        return RoutineActionStep(
          id: StrictJsonReader.string(json, 'id', path),
          actionId: StrictJsonReader.string(json, 'actionId', path),
          durationSeconds: StrictJsonReader.finiteDouble(
            json,
            'durationSeconds',
            path,
          ),
        );
      }(),
      RoutineStepKind.speech => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'id',
          'text',
          'durationSeconds',
        }, path);
        return RoutineSpeechStep(
          id: StrictJsonReader.string(json, 'id', path),
          text: StrictJsonReader.string(json, 'text', path),
          durationSeconds: StrictJsonReader.finiteDouble(
            json,
            'durationSeconds',
            path,
          ),
        );
      }(),
    };
  }
}

final class RoutineMoveStep extends RoutineStep {
  const RoutineMoveStep({required super.id, required this.target});

  @override
  RoutineStepKind get kind => RoutineStepKind.move;

  final RoutineAnchorReference target;

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'id': id,
    'target': target.toJson(),
  };
}

final class RoutineWaitStep extends RoutineStep {
  const RoutineWaitStep({required super.id, required this.durationSeconds});

  @override
  RoutineStepKind get kind => RoutineStepKind.wait;

  final double durationSeconds;

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'id': id,
    'durationSeconds': durationSeconds,
  };
}

final class RoutineActionStep extends RoutineStep {
  const RoutineActionStep({
    required super.id,
    required this.actionId,
    required this.durationSeconds,
  });

  @override
  RoutineStepKind get kind => RoutineStepKind.action;

  final String actionId;
  final double durationSeconds;

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'id': id,
    'actionId': actionId,
    'durationSeconds': durationSeconds,
  };
}

final class RoutineSpeechStep extends RoutineStep {
  const RoutineSpeechStep({
    required super.id,
    required this.text,
    required this.durationSeconds,
  });

  @override
  RoutineStepKind get kind => RoutineStepKind.speech;

  final String text;
  final double durationSeconds;

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'id': id,
    'text': text,
    'durationSeconds': durationSeconds,
  };
}

final class RoutineParticipantSteps {
  RoutineParticipantSteps({
    required this.participantId,
    required Iterable<RoutineStep> steps,
  }) : steps = List.unmodifiable(steps);

  final String participantId;
  final List<RoutineStep> steps;

  factory RoutineParticipantSteps.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    StrictJsonReader.requireExactKeys(json, const {
      'participantId',
      'steps',
    }, path);
    final values = StrictJsonReader.list(json, 'steps', path);
    return RoutineParticipantSteps(
      participantId: StrictJsonReader.string(json, 'participantId', path),
      steps: [
        for (final (index, value) in values.indexed)
          RoutineStep.fromJson(
            StrictJsonReader.object(value, '$path.steps[$index]'),
            path: '$path.steps[$index]',
          ),
      ],
    );
  }

  Map<String, Object?> toJson() => {
    'participantId': participantId,
    'steps': [for (final step in steps) step.toJson()],
  };
}

final class RoutineStepDialogueEntry {
  const RoutineStepDialogueEntry({
    required this.participantId,
    required this.stepId,
    required this.dialogueEntryNodeId,
  });

  final String participantId;
  final String stepId;
  final String dialogueEntryNodeId;

  factory RoutineStepDialogueEntry.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    StrictJsonReader.requireExactKeys(json, const {
      'participantId',
      'stepId',
      'dialogueEntryNodeId',
    }, path);
    return RoutineStepDialogueEntry(
      participantId: StrictJsonReader.string(json, 'participantId', path),
      stepId: StrictJsonReader.string(json, 'stepId', path),
      dialogueEntryNodeId: StrictJsonReader.string(
        json,
        'dialogueEntryNodeId',
        path,
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'participantId': participantId,
    'stepId': stepId,
    'dialogueEntryNodeId': dialogueEntryNodeId,
  };
}

sealed class RoutineDirective {
  const RoutineDirective();

  RoutineDirectiveKind get kind;

  Map<String, Object?> toJson();

  factory RoutineDirective.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    final kind = _parseEnum(
      RoutineDirectiveKind.values,
      StrictJsonReader.string(json, 'kind', path),
      '$path.kind',
      'routine directive kind',
    );
    return switch (kind) {
      RoutineDirectiveKind.resume => () {
        StrictJsonReader.requireExactKeys(json, const {'kind'}, path);
        return const ResumeRoutineDirective();
      }(),
      RoutineDirectiveKind.jumpToStep => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'participantId',
          'stepId',
        }, path);
        return JumpToRoutineStepDirective(
          participantId: StrictJsonReader.string(json, 'participantId', path),
          stepId: StrictJsonReader.string(json, 'stepId', path),
        );
      }(),
      RoutineDirectiveKind.endRoutineForDay => () {
        StrictJsonReader.requireExactKeys(json, const {'kind'}, path);
        return const EndRoutineForDayDirective();
      }(),
      RoutineDirectiveKind.activateWorldEvent ||
      RoutineDirectiveKind.deactivateWorldEvent => () {
        StrictJsonReader.requireExactKeys(json, const {
          'kind',
          'eventId',
        }, path);
        return RoutineWorldEventDirective(
          kind: kind,
          eventId: StrictJsonReader.string(json, 'eventId', path),
        );
      }(),
    };
  }
}

final class ResumeRoutineDirective extends RoutineDirective {
  const ResumeRoutineDirective();

  @override
  RoutineDirectiveKind get kind => RoutineDirectiveKind.resume;

  @override
  Map<String, Object?> toJson() => {'kind': kind.name};
}

final class JumpToRoutineStepDirective extends RoutineDirective {
  const JumpToRoutineStepDirective({
    required this.participantId,
    required this.stepId,
  });

  @override
  RoutineDirectiveKind get kind => RoutineDirectiveKind.jumpToStep;

  final String participantId;
  final String stepId;

  @override
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'participantId': participantId,
    'stepId': stepId,
  };
}

final class EndRoutineForDayDirective extends RoutineDirective {
  const EndRoutineForDayDirective();

  @override
  RoutineDirectiveKind get kind => RoutineDirectiveKind.endRoutineForDay;

  @override
  Map<String, Object?> toJson() => {'kind': kind.name};
}

final class RoutineWorldEventDirective extends RoutineDirective {
  const RoutineWorldEventDirective({required this.kind, required this.eventId})
    : assert(
        kind == RoutineDirectiveKind.activateWorldEvent ||
            kind == RoutineDirectiveKind.deactivateWorldEvent,
      );

  @override
  final RoutineDirectiveKind kind;
  final String eventId;

  @override
  Map<String, Object?> toJson() => {'kind': kind.name, 'eventId': eventId};
}

final class RoutineOutcomeDirective {
  const RoutineOutcomeDirective({
    required this.outcomeTag,
    required this.directive,
  });

  final String outcomeTag;
  final RoutineDirective directive;

  factory RoutineOutcomeDirective.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    StrictJsonReader.requireExactKeys(json, const {
      'outcomeTag',
      'directive',
    }, path);
    return RoutineOutcomeDirective(
      outcomeTag: StrictJsonReader.string(json, 'outcomeTag', path),
      directive: RoutineDirective.fromJson(
        StrictJsonReader.object(json['directive'], '$path.directive'),
        path: '$path.directive',
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'outcomeTag': outcomeTag,
    'directive': directive.toJson(),
  };
}

final class RoutineInteractionPolicy {
  RoutineInteractionPolicy({
    required this.allowDialogue,
    required this.defaultDialogueEntryNodeId,
    required Iterable<RoutineStepDialogueEntry> stepDialogueEntries,
    required Iterable<RoutineOutcomeDirective> outcomeDirectives,
  }) : stepDialogueEntries = List.unmodifiable(stepDialogueEntries),
       outcomeDirectives = List.unmodifiable(outcomeDirectives);

  final bool allowDialogue;
  final String? defaultDialogueEntryNodeId;
  final List<RoutineStepDialogueEntry> stepDialogueEntries;
  final List<RoutineOutcomeDirective> outcomeDirectives;

  factory RoutineInteractionPolicy.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    StrictJsonReader.requireExactKeys(json, const {
      'allowDialogue',
      'defaultDialogueEntryNodeId',
      'stepDialogueEntries',
      'outcomeDirectives',
    }, path);
    final stepEntries = StrictJsonReader.list(
      json,
      'stepDialogueEntries',
      path,
    );
    final outcomeEntries = StrictJsonReader.list(
      json,
      'outcomeDirectives',
      path,
    );
    return RoutineInteractionPolicy(
      allowDialogue: StrictJsonReader.boolean(json, 'allowDialogue', path),
      defaultDialogueEntryNodeId: StrictJsonReader.nullableString(
        json,
        'defaultDialogueEntryNodeId',
        path,
      ),
      stepDialogueEntries: [
        for (final (index, value) in stepEntries.indexed)
          RoutineStepDialogueEntry.fromJson(
            StrictJsonReader.object(value, '$path.stepDialogueEntries[$index]'),
            path: '$path.stepDialogueEntries[$index]',
          ),
      ],
      outcomeDirectives: [
        for (final (index, value) in outcomeEntries.indexed)
          RoutineOutcomeDirective.fromJson(
            StrictJsonReader.object(value, '$path.outcomeDirectives[$index]'),
            path: '$path.outcomeDirectives[$index]',
          ),
      ],
    );
  }

  Map<String, Object?> toJson() => {
    'allowDialogue': allowDialogue,
    'defaultDialogueEntryNodeId': defaultDialogueEntryNodeId,
    'stepDialogueEntries': [
      for (final entry in stepDialogueEntries) entry.toJson(),
    ],
    'outcomeDirectives': [
      for (final outcome in outcomeDirectives) outcome.toJson(),
    ],
  };
}

final class RoutineDefinition {
  RoutineDefinition({
    required this.schemaVersion,
    required this.id,
    required this.priority,
    required this.timeWindow,
    required Iterable<String> participants,
    required Iterable<RoutineCondition> conditions,
    required this.interactionPolicy,
    required Iterable<RoutineParticipantSteps> participantSteps,
  }) : participants = List.unmodifiable(participants),
       conditions = List.unmodifiable(conditions),
       participantSteps = List.unmodifiable(participantSteps),
       stepsByParticipantId = Map.unmodifiable({
         for (final plan in participantSteps) plan.participantId: plan,
       });

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final String id;
  final int priority;
  final RoutineTimeWindow timeWindow;
  final List<String> participants;
  final List<RoutineCondition> conditions;
  final RoutineInteractionPolicy interactionPolicy;
  final List<RoutineParticipantSteps> participantSteps;
  final Map<String, RoutineParticipantSteps> stepsByParticipantId;

  factory RoutineDefinition.fromJson(
    Map<String, Object?> json, {
    String path = r'$',
  }) {
    StrictJsonReader.requireExactKeys(json, const {
      'schemaVersion',
      'id',
      'priority',
      'timeWindow',
      'participants',
      'conditions',
      'interactionPolicy',
      'participantSteps',
    }, path);
    final conditionValues = StrictJsonReader.list(json, 'conditions', path);
    final participantPlanValues = StrictJsonReader.list(
      json,
      'participantSteps',
      path,
    );
    final definition = RoutineDefinition(
      schemaVersion: StrictJsonReader.integer(json, 'schemaVersion', path),
      id: StrictJsonReader.string(json, 'id', path),
      priority: StrictJsonReader.integer(json, 'priority', path),
      timeWindow: RoutineTimeWindow.fromJson(
        StrictJsonReader.object(json['timeWindow'], '$path.timeWindow'),
        path: '$path.timeWindow',
      ),
      participants: StrictJsonReader.stringList(json, 'participants', path),
      conditions: [
        for (final (index, value) in conditionValues.indexed)
          RoutineCondition.fromJson(
            StrictJsonReader.object(value, '$path.conditions[$index]'),
            path: '$path.conditions[$index]',
          ),
      ],
      interactionPolicy: RoutineInteractionPolicy.fromJson(
        StrictJsonReader.object(
          json['interactionPolicy'],
          '$path.interactionPolicy',
        ),
        path: '$path.interactionPolicy',
      ),
      participantSteps: [
        for (final (index, value) in participantPlanValues.indexed)
          RoutineParticipantSteps.fromJson(
            StrictJsonReader.object(value, '$path.participantSteps[$index]'),
            path: '$path.participantSteps[$index]',
          ),
      ],
    );
    final diagnostics = const RoutineDefinitionValidator().validate(
      definition,
      path: path,
    );
    if (diagnostics.isNotEmpty) {
      throw FormatException(
        'Routine definition is invalid:\n${diagnostics.join('\n')}',
      );
    }
    return definition;
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'priority': priority,
    'timeWindow': timeWindow.toJson(),
    'participants': participants,
    'conditions': [for (final condition in conditions) condition.toJson()],
    'interactionPolicy': interactionPolicy.toJson(),
    'participantSteps': [for (final plan in participantSteps) plan.toJson()],
  };
}

final class RoutineDiagnostic {
  const RoutineDiagnostic({required this.path, required this.message});

  final String path;
  final String message;

  @override
  String toString() => '$path: $message';
}

/// Pure semantic validation after exact JSON-shape parsing.
final class RoutineDefinitionValidator {
  const RoutineDefinitionValidator();

  List<RoutineDiagnostic> validate(
    RoutineDefinition routine, {
    String path = r'$',
  }) {
    final diagnostics = <RoutineDiagnostic>[];
    void issue(String issuePath, String message) {
      diagnostics.add(RoutineDiagnostic(path: issuePath, message: message));
    }

    if (routine.schemaVersion != RoutineDefinition.currentSchemaVersion) {
      issue(
        '$path.schemaVersion',
        'Expected schema version ${RoutineDefinition.currentSchemaVersion}, '
            'got ${routine.schemaVersion}.',
      );
    }
    _requireNonBlank(routine.id, '$path.id', 'Routine ID', issue);
    if (routine.priority < 0) {
      issue('$path.priority', 'Priority must be >= 0.');
    }
    if (routine.timeWindow.start == routine.timeWindow.end) {
      issue(
        '$path.timeWindow',
        'Start and end must differ; zero-length windows are invalid.',
      );
    }
    if (routine.participants.isEmpty) {
      issue('$path.participants', 'At least one participant is required.');
    }

    final participantIndexes = <String, int>{};
    for (final (index, participantId) in routine.participants.indexed) {
      final participantPath = '$path.participants[$index]';
      _requireNonBlank(participantId, participantPath, 'Participant ID', issue);
      final firstIndex = participantIndexes[participantId];
      if (firstIndex == null) {
        participantIndexes[participantId] = index;
      } else {
        issue(
          participantPath,
          'Duplicate participant ID "$participantId"; first declared at '
          '$path.participants[$firstIndex].',
        );
      }
    }
    final participantIds = participantIndexes.keys.toSet();

    for (final (index, condition) in routine.conditions.indexed) {
      final conditionPath = '$path.conditions[$index]';
      switch (condition) {
        case RoutineWorldEventCondition(:final eventId):
          _requireNonBlank(
            eventId,
            '$conditionPath.eventId',
            'Event ID',
            issue,
          );
        case RoutineLearnedFactCondition(:final npcId, :final factId):
          _requireNonBlank(npcId, '$conditionPath.npcId', 'NPC ID', issue);
          _requireNonBlank(factId, '$conditionPath.factId', 'Fact ID', issue);
        case RoutineRelationshipFlagCondition(:final npcId, :final flagId):
          _requireNonBlank(npcId, '$conditionPath.npcId', 'NPC ID', issue);
          _requireNonBlank(flagId, '$conditionPath.flagId', 'Flag ID', issue);
        case RoutinePlayerEventCondition(
          :final subjectId,
          :final targetId,
          :final minimumCount,
          :final maximumCount,
          :final occurredWithinActiveSeconds,
        ):
          if (subjectId != null) {
            _requireNonBlank(
              subjectId,
              '$conditionPath.subjectId',
              'Subject ID',
              issue,
            );
          }
          if (targetId != null) {
            _requireNonBlank(
              targetId,
              '$conditionPath.targetId',
              'Target ID',
              issue,
            );
          }
          if (minimumCount < 0) {
            issue('$conditionPath.minimumCount', 'Minimum count must be >= 0.');
          }
          if (maximumCount != null && maximumCount < minimumCount) {
            issue(
              '$conditionPath.maximumCount',
              'Maximum count must be >= minimum count.',
            );
          }
          if (occurredWithinActiveSeconds != null &&
              (!occurredWithinActiveSeconds.isFinite ||
                  occurredWithinActiveSeconds < 0)) {
            issue(
              '$conditionPath.occurredWithinActiveSeconds',
              'Active-play recency must be >= 0 seconds.',
            );
          }
      }
    }

    final planIndexByParticipant = <String, int>{};
    final stepIdsByParticipant = <String, Set<String>>{};
    for (final (planIndex, plan) in routine.participantSteps.indexed) {
      final planPath = '$path.participantSteps[$planIndex]';
      _requireNonBlank(
        plan.participantId,
        '$planPath.participantId',
        'Participant ID',
        issue,
      );
      final firstPlanIndex = planIndexByParticipant[plan.participantId];
      if (firstPlanIndex == null) {
        planIndexByParticipant[plan.participantId] = planIndex;
      } else {
        issue(
          '$planPath.participantId',
          'Duplicate participant step plan for "${plan.participantId}"; '
              'first declared at $path.participantSteps[$firstPlanIndex].',
        );
      }
      if (!participantIds.contains(plan.participantId)) {
        issue(
          '$planPath.participantId',
          'Participant "${plan.participantId}" is not declared.',
        );
      }
      if (plan.steps.isEmpty) {
        issue('$planPath.steps', 'At least one step is required.');
      }
      final stepIndexes = <String, int>{};
      for (final (stepIndex, step) in plan.steps.indexed) {
        final stepPath = '$planPath.steps[$stepIndex]';
        _requireNonBlank(step.id, '$stepPath.id', 'Step ID', issue);
        final firstStepIndex = stepIndexes[step.id];
        if (firstStepIndex == null) {
          stepIndexes[step.id] = stepIndex;
        } else {
          issue(
            '$stepPath.id',
            'Duplicate step ID "${step.id}"; first declared at '
                '$planPath.steps[$firstStepIndex].id.',
          );
        }
        switch (step) {
          case RoutineMoveStep(:final target):
            _requireNonBlank(
              target.mapId,
              '$stepPath.target.mapId',
              'Map ID',
              issue,
            );
            _requireNonBlank(
              target.anchorId,
              '$stepPath.target.anchorId',
              'Anchor ID',
              issue,
            );
          case RoutineWaitStep(:final durationSeconds):
            _requirePositiveDuration(durationSeconds, stepPath, issue);
          case RoutineActionStep(:final actionId, :final durationSeconds):
            _requireNonBlank(
              actionId,
              '$stepPath.actionId',
              'Action ID',
              issue,
            );
            _requirePositiveDuration(durationSeconds, stepPath, issue);
          case RoutineSpeechStep(:final text, :final durationSeconds):
            _requireNonBlank(text, '$stepPath.text', 'Speech text', issue);
            _requirePositiveDuration(durationSeconds, stepPath, issue);
        }
      }
      stepIdsByParticipant[plan.participantId] = stepIndexes.keys.toSet();
    }
    for (final (participantIndex, participantId)
        in routine.participants.indexed) {
      if (!planIndexByParticipant.containsKey(participantId)) {
        issue(
          '$path.participants[$participantIndex]',
          'Participant "$participantId" has no participantSteps entry.',
        );
      }
    }

    final policy = routine.interactionPolicy;
    if (!policy.allowDialogue &&
        (policy.defaultDialogueEntryNodeId != null ||
            policy.stepDialogueEntries.isNotEmpty ||
            policy.outcomeDirectives.isNotEmpty)) {
      issue(
        '$path.interactionPolicy',
        'Dialogue entries and outcomes require allowDialogue=true.',
      );
    }
    final defaultEntry = policy.defaultDialogueEntryNodeId;
    if (defaultEntry != null) {
      _requireNonBlank(
        defaultEntry,
        '$path.interactionPolicy.defaultDialogueEntryNodeId',
        'Dialogue entry node ID',
        issue,
      );
    }
    final entryKeys = <String, int>{};
    for (final (index, entry) in policy.stepDialogueEntries.indexed) {
      final entryPath = '$path.interactionPolicy.stepDialogueEntries[$index]';
      _validateStepReference(
        participantId: entry.participantId,
        stepId: entry.stepId,
        participantIds: participantIds,
        stepIdsByParticipant: stepIdsByParticipant,
        path: entryPath,
        issue: issue,
      );
      _requireNonBlank(
        entry.dialogueEntryNodeId,
        '$entryPath.dialogueEntryNodeId',
        'Dialogue entry node ID',
        issue,
      );
      final key = '${entry.participantId}\u0000${entry.stepId}';
      final firstIndex = entryKeys[key];
      if (firstIndex == null) {
        entryKeys[key] = index;
      } else {
        issue(
          entryPath,
          'Duplicate dialogue entry for participant "${entry.participantId}" '
          'step "${entry.stepId}"; first declared at '
          '$path.interactionPolicy.stepDialogueEntries[$firstIndex].',
        );
      }
    }

    final outcomeIndexes = <String, int>{};
    for (final (index, binding) in policy.outcomeDirectives.indexed) {
      final bindingPath = '$path.interactionPolicy.outcomeDirectives[$index]';
      _requireNonBlank(
        binding.outcomeTag,
        '$bindingPath.outcomeTag',
        'Outcome tag',
        issue,
      );
      final firstIndex = outcomeIndexes[binding.outcomeTag];
      if (firstIndex == null) {
        outcomeIndexes[binding.outcomeTag] = index;
      } else {
        issue(
          '$bindingPath.outcomeTag',
          'Duplicate outcome tag "${binding.outcomeTag}"; first declared at '
              '$path.interactionPolicy.outcomeDirectives[$firstIndex]'
              '.outcomeTag.',
        );
      }
      switch (binding.directive) {
        case ResumeRoutineDirective() || EndRoutineForDayDirective():
          break;
        case JumpToRoutineStepDirective(:final participantId, :final stepId):
          _validateStepReference(
            participantId: participantId,
            stepId: stepId,
            participantIds: participantIds,
            stepIdsByParticipant: stepIdsByParticipant,
            path: '$bindingPath.directive',
            issue: issue,
          );
        case RoutineWorldEventDirective(:final eventId):
          _requireNonBlank(
            eventId,
            '$bindingPath.directive.eventId',
            'Event ID',
            issue,
          );
      }
    }

    diagnostics.sort((left, right) {
      final pathOrder = left.path.compareTo(right.path);
      return pathOrder != 0 ? pathOrder : left.message.compareTo(right.message);
    });
    return List.unmodifiable(diagnostics);
  }
}

void _validateStepReference({
  required String participantId,
  required String stepId,
  required Set<String> participantIds,
  required Map<String, Set<String>> stepIdsByParticipant,
  required String path,
  required void Function(String, String) issue,
}) {
  _requireNonBlank(
    participantId,
    '$path.participantId',
    'Participant ID',
    issue,
  );
  _requireNonBlank(stepId, '$path.stepId', 'Step ID', issue);
  if (!participantIds.contains(participantId)) {
    issue(
      '$path.participantId',
      'Participant "$participantId" is not declared.',
    );
  } else if (!(stepIdsByParticipant[participantId]?.contains(stepId) ??
      false)) {
    issue(
      '$path.stepId',
      'Step "$stepId" does not exist for participant "$participantId".',
    );
  }
}

void _requirePositiveDuration(
  double duration,
  String path,
  void Function(String, String) issue,
) {
  if (!duration.isFinite || duration <= 0) {
    issue('$path.durationSeconds', 'Duration must be finite and > 0 seconds.');
  }
}

void _requireNonBlank(
  String value,
  String path,
  String label,
  void Function(String, String) issue,
) {
  if (value.trim().isEmpty) {
    issue(path, '$label cannot be blank.');
  } else if (value != value.trim()) {
    issue(path, '$label cannot have surrounding whitespace.');
  }
}

T _parseEnum<T extends Enum>(
  Iterable<T> values,
  String value,
  String path,
  String label,
) {
  for (final candidate in values) {
    if (candidate.name == value) {
      return candidate;
    }
  }
  throw FormatException('$path: Unknown $label "$value".');
}
