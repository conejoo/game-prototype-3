/// Bounded event kinds that deterministic dialogue may query.
enum PlayerEventKind {
  areaEntered,
  resourceGathered,
  itemGifted,
  dialogueChoiceSelected;

  static PlayerEventKind parse(String value) {
    for (final kind in values) {
      if (kind.name == value) {
        return kind;
      }
    }
    throw FormatException('Unknown player event kind "$value".');
  }
}

/// One aggregated player-memory key. Null subject/target values are meaningful.
class PlayerEventKey {
  const PlayerEventKey({required this.kind, this.subjectId, this.targetId});

  final PlayerEventKind kind;
  final String? subjectId;
  final String? targetId;

  @override
  bool operator ==(Object other) =>
      other is PlayerEventKey &&
      other.kind == kind &&
      other.subjectId == subjectId &&
      other.targetId == targetId;

  @override
  int get hashCode => Object.hash(kind, subjectId, targetId);
}

/// Aggregate for every occurrence of one unique [PlayerEventKey].
class PlayerEventFact {
  const PlayerEventFact({
    required this.count,
    required this.firstSequence,
    required this.lastSequence,
    required this.firstActiveSeconds,
    required this.lastActiveSeconds,
  });

  final int count;
  final int firstSequence;
  final int lastSequence;

  /// Null means the event has no active-play timestamp.
  final double? firstActiveSeconds;
  final double? lastActiveSeconds;

  PlayerEventFact record({
    required int sequence,
    required double activeSeconds,
  }) => PlayerEventFact(
    count: count + 1,
    firstSequence: firstSequence,
    lastSequence: sequence,
    firstActiveSeconds: firstActiveSeconds,
    lastActiveSeconds: activeSeconds,
  );
}

/// Immutable, size-bounded player memory aggregated by unique fact key.
class PlayerEventJournal {
  factory PlayerEventJournal({
    Map<PlayerEventKey, PlayerEventFact> facts = const {},
    int lastSequence = 0,
  }) {
    if (lastSequence < 0) {
      throw ArgumentError.value(lastSequence, 'lastSequence');
    }
    for (final entry in facts.entries) {
      _validateId(entry.key.subjectId, 'subjectId');
      _validateId(entry.key.targetId, 'targetId');
      final fact = entry.value;
      if (fact.count <= 0 ||
          fact.firstSequence <= 0 ||
          fact.lastSequence < fact.firstSequence ||
          fact.lastSequence > lastSequence) {
        throw ArgumentError.value(fact, 'facts', 'Invalid event aggregate.');
      }
      _validateSeconds(fact.firstActiveSeconds, 'firstActiveSeconds');
      _validateSeconds(fact.lastActiveSeconds, 'lastActiveSeconds');
      if (fact.firstActiveSeconds != null &&
          fact.lastActiveSeconds != null &&
          fact.lastActiveSeconds! < fact.firstActiveSeconds!) {
        throw ArgumentError.value(
          fact,
          'facts',
          'Last active time cannot precede first active time.',
        );
      }
    }
    return PlayerEventJournal._(Map.unmodifiable(Map.of(facts)), lastSequence);
  }

  const PlayerEventJournal._(this.facts, this.lastSequence);

  final Map<PlayerEventKey, PlayerEventFact> facts;
  final int lastSequence;

  PlayerEventJournal record({
    required PlayerEventKind kind,
    String? subjectId,
    String? targetId,
    required double activeSeconds,
  }) {
    _validateId(subjectId, 'subjectId');
    _validateId(targetId, 'targetId');
    _validateSeconds(activeSeconds, 'activeSeconds');
    final key = PlayerEventKey(
      kind: kind,
      subjectId: subjectId,
      targetId: targetId,
    );
    final sequence = lastSequence + 1;
    final previous = facts[key];
    final nextFact = previous == null
        ? PlayerEventFact(
            count: 1,
            firstSequence: sequence,
            lastSequence: sequence,
            firstActiveSeconds: activeSeconds,
            lastActiveSeconds: activeSeconds,
          )
        : previous.record(sequence: sequence, activeSeconds: activeSeconds);
    return PlayerEventJournal(
      facts: {...facts, key: nextFact},
      lastSequence: sequence,
    );
  }

  int count({
    required PlayerEventKind kind,
    String? subjectId,
    String? targetId,
  }) =>
      facts[PlayerEventKey(
            kind: kind,
            subjectId: subjectId,
            targetId: targetId,
          )]
          ?.count ??
      0;

  PlayerEventFact? find({
    required PlayerEventKind kind,
    String? subjectId,
    String? targetId,
  }) =>
      facts[PlayerEventKey(
        kind: kind,
        subjectId: subjectId,
        targetId: targetId,
      )];

  bool matches(PlayerEventCondition condition, {required double nowSeconds}) {
    final fact = find(
      kind: condition.kind,
      subjectId: condition.subjectId,
      targetId: condition.targetId,
    );
    final count = fact?.count ?? 0;
    if (count < condition.minimumCount ||
        (condition.maximumCount != null && count > condition.maximumCount!)) {
      return false;
    }
    final within = condition.occurredWithinActiveSeconds;
    if (within == null) {
      return true;
    }
    final lastSeconds = fact?.lastActiveSeconds;
    return lastSeconds != null && nowSeconds - lastSeconds <= within;
  }
}

/// Serializable query used by dialogue entry conditions.
class PlayerEventCondition {
  const PlayerEventCondition({
    required this.kind,
    this.subjectId,
    this.targetId,
    this.minimumCount = 1,
    this.maximumCount,
    this.occurredWithinActiveSeconds,
  }) : assert(minimumCount >= 0),
       assert(maximumCount == null || maximumCount >= minimumCount),
       assert(
         occurredWithinActiveSeconds == null ||
             occurredWithinActiveSeconds >= 0,
       );

  final PlayerEventKind kind;
  final String? subjectId;
  final String? targetId;
  final int minimumCount;
  final int? maximumCount;
  final double? occurredWithinActiveSeconds;
}

void _validateId(String? value, String name) {
  if (value != null && value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'ID cannot be blank.');
  }
}

void _validateSeconds(double? value, String name) {
  if (value != null && (!value.isFinite || value < 0)) {
    throw ArgumentError.value(value, name, 'Seconds must be finite and >= 0.');
  }
}
