import '../world/world_geometry.dart';
import '../persistence/campaign_save_state.dart';
import '../items/item_definition.dart';
import '../weather/weather_schedule.dart';
import '../preview/story_preview_setup.dart';
import '../../world_map/world_map_authoring_registry.dart';
import 'player_event_journal.dart';

/// Serializable game data kept separate from Flame components and Flutter UI.
class PlayerState {
  PlayerState({required this.playerId, required this.x, required this.y}) {
    _validateStableId(playerId, 'playerId');
    _validateFiniteCoordinate(x, 'x');
    _validateFiniteCoordinate(y, 'y');
  }

  final String playerId;
  final double x;
  final double y;

  PlayerState copyWith({String? playerId, double? x, double? y}) {
    return PlayerState(
      playerId: playerId ?? this.playerId,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

/// One dropped inventory item with a persistent position in a world map.
class WorldItemPlacement {
  WorldItemPlacement({
    required this.instanceId,
    required this.itemId,
    required this.mapId,
    required this.x,
    required this.y,
  }) {
    _validateStableId(instanceId, 'instanceId');
    _validateStableId(itemId, 'itemId');
    _validateStableId(mapId, 'mapId');
    _validateFiniteCoordinate(x, 'x');
    _validateFiniteCoordinate(y, 'y');
  }

  final String instanceId;
  final String itemId;
  final String mapId;
  final double x;
  final double y;

  WorldItemPlacement copyWith({double? x, double? y}) => WorldItemPlacement(
    instanceId: instanceId,
    itemId: itemId,
    mapId: mapId,
    x: x ?? this.x,
    y: y ?? this.y,
  );
}

enum InventoryAddStatus { added, unknownItem, backpackFull, stackFull }

class InventoryAddResult {
  const InventoryAddResult({required this.inventory, required this.status});

  final InventoryState inventory;
  final InventoryAddStatus status;

  bool get added => status == InventoryAddStatus.added;
}

class InventoryState {
  factory InventoryState({
    Map<String, int> itemCounts = const {},
    String? activeItemId,
  }) {
    for (final entry in itemCounts.entries) {
      _validateStableId(entry.key, 'itemCounts key');
      if (entry.value <= 0) {
        throw ArgumentError.value(
          entry.value,
          'itemCounts',
          'Stored item counts must be positive.',
        );
      }
    }
    if (itemCounts.length > backpackSlotCapacity) {
      throw ArgumentError.value(
        itemCounts.length,
        'itemCounts',
        'Inventory cannot exceed $backpackSlotCapacity occupied slots.',
      );
    }
    if (activeItemId != null) {
      _validateStableId(activeItemId, 'activeItemId');
      if (!itemCounts.containsKey(activeItemId)) {
        throw ArgumentError.value(
          activeItemId,
          'activeItemId',
          'Active item must be present in inventory.',
        );
      }
    }

    return InventoryState._(Map.unmodifiable(Map.of(itemCounts)), activeItemId);
  }

  InventoryState._(this.itemCounts, this.activeItemId);

  static const backpackSlotCapacity = 20;

  final Map<String, int> itemCounts;
  final String? activeItemId;

  /// Attempts to add [quantity] to one cataloged item stack.
  InventoryAddResult tryAddItem(
    String itemId,
    ItemDefinitionCatalog catalog, {
    int quantity = 1,
  }) {
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be positive.');
    }
    final definition = catalog.findById(itemId);
    if (definition == null) {
      return InventoryAddResult(
        inventory: this,
        status: InventoryAddStatus.unknownItem,
      );
    }
    final currentCount = itemCounts[itemId] ?? 0;
    if (currentCount + quantity > definition.stackLimit) {
      return InventoryAddResult(
        inventory: this,
        status: InventoryAddStatus.stackFull,
      );
    }
    if (currentCount == 0 && itemCounts.length >= backpackSlotCapacity) {
      return InventoryAddResult(
        inventory: this,
        status: InventoryAddStatus.backpackFull,
      );
    }
    final nextItemCounts = Map<String, int>.of(itemCounts);
    nextItemCounts[itemId] = currentCount + quantity;
    return InventoryAddResult(
      inventory: InventoryState(
        itemCounts: nextItemCounts,
        activeItemId: activeItemId,
      ),
      status: InventoryAddStatus.added,
    );
  }

  /// Returns a new inventory with [itemId] active, or null when not owned.
  InventoryState? activateItem(String itemId) {
    if (!itemCounts.containsKey(itemId)) {
      return null;
    }
    if (activeItemId == itemId) {
      return this;
    }
    return InventoryState(itemCounts: itemCounts, activeItemId: itemId);
  }

  /// Consumes one [itemId], or returns null when none is available.
  ///
  /// An exhausted item is removed instead of stored with a zero count.
  InventoryState? consumeItem(String itemId) {
    final currentCount = itemCounts[itemId];
    if (currentCount == null || currentCount <= 0) {
      return null;
    }

    final nextItemCounts = Map<String, int>.of(itemCounts);
    if (currentCount == 1) {
      nextItemCounts.remove(itemId);
    } else {
      nextItemCounts[itemId] = currentCount - 1;
    }
    return InventoryState(
      itemCounts: nextItemCounts,
      activeItemId:
          activeItemId == itemId && !nextItemCounts.containsKey(itemId)
          ? null
          : activeItemId,
    );
  }

  InventoryState copyWith({Map<String, int>? itemCounts}) {
    final nextCounts = itemCounts ?? this.itemCounts;
    return InventoryState(
      itemCounts: nextCounts,
      activeItemId: activeItemId != null && nextCounts.containsKey(activeItemId)
          ? activeItemId
          : null,
    );
  }
}

class NpcRelationshipState {
  factory NpcRelationshipState({
    required String npcId,
    int affinity = 0,
    int? level,
    int levelOneAffinity = defaultLevelOneAffinity,
    Set<String> seenDialogueIds = const {},
    Set<String> learnedFactIds = const {},
    Set<String> appliedChoiceIds = const {},
    Set<String> flags = const {},
  }) {
    _validateStableId(npcId, 'npcId');
    if (affinity < 0) {
      throw ArgumentError.value(
        affinity,
        'affinity',
        'Affinity cannot be negative.',
      );
    }
    final derivedLevel = levelForAffinity(
      affinity,
      levelOneAffinity: levelOneAffinity,
    );
    if (level != null && level != derivedLevel) {
      throw ArgumentError.value(
        level,
        'level',
        'Relationship level must match affinity.',
      );
    }
    _validateStableIds(seenDialogueIds, 'seenDialogueIds');
    _validateStableIds(learnedFactIds, 'learnedFactIds');
    _validateStableIds(appliedChoiceIds, 'appliedChoiceIds');
    _validateStableIds(flags, 'flags');

    return NpcRelationshipState._(
      npcId: npcId,
      affinity: affinity,
      level: derivedLevel,
      seenDialogueIds: Set.unmodifiable(Set.of(seenDialogueIds)),
      learnedFactIds: Set.unmodifiable(Set.of(learnedFactIds)),
      appliedChoiceIds: Set.unmodifiable(Set.of(appliedChoiceIds)),
      flags: Set.unmodifiable(Set.of(flags)),
    );
  }

  /// Restores a persisted derived level before its catalog definition is
  /// available. Runtime hydration re-derives it from the active manifest.
  factory NpcRelationshipState.fromPersisted({
    required String npcId,
    required int affinity,
    required int level,
    Set<String> seenDialogueIds = const {},
    Set<String> learnedFactIds = const {},
    Set<String> appliedChoiceIds = const {},
    Set<String> flags = const {},
  }) {
    _validateStableId(npcId, 'npcId');
    if (affinity < 0) {
      throw ArgumentError.value(
        affinity,
        'affinity',
        'Affinity cannot be negative.',
      );
    }
    if (level < 0 || level > levelOne) {
      throw ArgumentError.value(
        level,
        'level',
        'Relationship level must be 0 or 1.',
      );
    }
    _validateStableIds(seenDialogueIds, 'seenDialogueIds');
    _validateStableIds(learnedFactIds, 'learnedFactIds');
    _validateStableIds(appliedChoiceIds, 'appliedChoiceIds');
    _validateStableIds(flags, 'flags');

    return NpcRelationshipState._(
      npcId: npcId,
      affinity: affinity,
      level: level,
      seenDialogueIds: Set.unmodifiable(Set.of(seenDialogueIds)),
      learnedFactIds: Set.unmodifiable(Set.of(learnedFactIds)),
      appliedChoiceIds: Set.unmodifiable(Set.of(appliedChoiceIds)),
      flags: Set.unmodifiable(Set.of(flags)),
    );
  }

  NpcRelationshipState._({
    required this.npcId,
    required this.affinity,
    required this.level,
    required this.seenDialogueIds,
    required this.learnedFactIds,
    required this.appliedChoiceIds,
    required this.flags,
  });

  final String npcId;
  final int affinity;
  final int level;
  final Set<String> seenDialogueIds;
  final Set<String> learnedFactIds;
  final Set<String> appliedChoiceIds;
  final Set<String> flags;

  /// Default relationship threshold for isolated state tests.
  static const defaultLevelOneAffinity = 3;

  /// Only relationship level currently represented by save data.
  static const levelOne = 1;

  /// Derives relationship level from [affinity] and authored threshold.
  static int levelForAffinity(
    int affinity, {
    int levelOneAffinity = defaultLevelOneAffinity,
  }) {
    if (affinity < 0) {
      throw ArgumentError.value(
        affinity,
        'affinity',
        'Affinity cannot be negative.',
      );
    }
    if (levelOneAffinity <= 0) {
      throw ArgumentError.value(
        levelOneAffinity,
        'levelOneAffinity',
        'Level-one affinity must be positive.',
      );
    }
    return affinity >= levelOneAffinity ? levelOne : 0;
  }

  /// Applies signed affinity change, clamped so persisted affinity stays valid.
  NpcRelationshipAffinityUpdate applyAffinityDelta(
    int affinityDelta, {
    int levelOneAffinity = defaultLevelOneAffinity,
  }) {
    final relationship = NpcRelationshipState(
      npcId: npcId,
      affinity: (affinity + affinityDelta).clamp(0, 0x7fffffff),
      levelOneAffinity: levelOneAffinity,
      seenDialogueIds: seenDialogueIds,
      learnedFactIds: learnedFactIds,
      appliedChoiceIds: appliedChoiceIds,
      flags: flags,
    );
    return NpcRelationshipAffinityUpdate(
      relationship: relationship,
      levelIncreased: level < relationship.level,
    );
  }

  /// Re-derives persisted level using active catalog relationship rules.
  NpcRelationshipState withLevelOneAffinity(int levelOneAffinity) {
    final derivedLevel = levelForAffinity(
      affinity,
      levelOneAffinity: levelOneAffinity,
    );
    if (derivedLevel == level) {
      return this;
    }
    return NpcRelationshipState(
      npcId: npcId,
      affinity: affinity,
      levelOneAffinity: levelOneAffinity,
      seenDialogueIds: seenDialogueIds,
      learnedFactIds: learnedFactIds,
      appliedChoiceIds: appliedChoiceIds,
      flags: flags,
    );
  }

  NpcRelationshipState copyWith({
    String? npcId,
    int? affinity,
    Set<String>? seenDialogueIds,
    Set<String>? learnedFactIds,
    Set<String>? appliedChoiceIds,
    Set<String>? flags,
    int levelOneAffinity = defaultLevelOneAffinity,
  }) {
    final nextAffinity = affinity ?? this.affinity;
    final nextLevel = affinity == null
        ? level
        : levelForAffinity(nextAffinity, levelOneAffinity: levelOneAffinity);
    return NpcRelationshipState.fromPersisted(
      npcId: npcId ?? this.npcId,
      affinity: nextAffinity,
      level: nextLevel,
      seenDialogueIds: seenDialogueIds ?? this.seenDialogueIds,
      learnedFactIds: learnedFactIds ?? this.learnedFactIds,
      appliedChoiceIds: appliedChoiceIds ?? this.appliedChoiceIds,
      flags: flags ?? this.flags,
    );
  }
}

/// Immutable result of applying one affinity change to a relationship.
class NpcRelationshipAffinityUpdate {
  const NpcRelationshipAffinityUpdate({
    required this.relationship,
    required this.levelIncreased,
  });

  final NpcRelationshipState relationship;
  final bool levelIncreased;
}

/// Stable persisted address for one independently switchable prop light.
final class LightSourceStateKey implements Comparable<LightSourceStateKey> {
  const LightSourceStateKey({
    required this.mapId,
    required this.propId,
    required this.sourceId,
  });

  final String mapId;
  final String propId;
  final String sourceId;

  @override
  int compareTo(LightSourceStateKey other) {
    final map = mapId.compareTo(other.mapId);
    if (map != 0) return map;
    final prop = propId.compareTo(other.propId);
    return prop != 0 ? prop : sourceId.compareTo(other.sourceId);
  }

  @override
  bool operator ==(Object other) =>
      other is LightSourceStateKey &&
      other.mapId == mapId &&
      other.propId == propId &&
      other.sourceId == sourceId;

  @override
  int get hashCode => Object.hash(mapId, propId, sourceId);
}

class RuntimeGameState {
  factory RuntimeGameState({
    required PlayerState player,
    String? mapId,
    InventoryState? inventory,
    Map<String, NpcRelationshipState> relationships = const {},
    Set<String> collectedResourceNodeIds = const {},
    double dayCycleProgress = 0.0,
    int dayIndex = 0,
    int weatherSeed = WeatherSchedule.defaultSeed,
    Set<String> activeWorldEventIds = const {},
    Set<String> suppressedRoutineIds = const {},
    Set<String> tutorialFlags = const {},
    Map<LightSourceStateKey, bool> lightSourceOverrides = const {},
    Map<String, WorldItemPlacement> worldItemPlacements = const {},
    PlayerEventJournal? eventJournal,
    double activePlaySeconds = 0.0,
    CampaignSaveState? campaign,
    StoryPreviewSetup? storyPreview,
  }) {
    for (final entry in relationships.entries) {
      _validateStableId(entry.key, 'relationships key');
      if (entry.key != entry.value.npcId) {
        throw ArgumentError.value(
          entry.key,
          'relationships',
          'Relationship key must match its NPC ID.',
        );
      }
    }
    _validateStableIds(collectedResourceNodeIds, 'collectedResourceNodeIds');
    _validateDayCycleProgress(dayCycleProgress);
    _validateDayIndex(dayIndex);
    WeatherSchedule.validateSeed(weatherSeed);
    _validateStableIds(activeWorldEventIds, 'activeWorldEventIds');
    _validateStableIds(suppressedRoutineIds, 'suppressedRoutineIds');
    _validateStableIds(tutorialFlags, 'tutorialFlags');
    for (final entry in lightSourceOverrides.entries) {
      _validateStableId(entry.key.mapId, 'light source map ID');
      _validateStableId(entry.key.propId, 'light source prop ID');
      _validateStableId(entry.key.sourceId, 'light source ID');
    }
    for (final entry in worldItemPlacements.entries) {
      _validateStableId(entry.key, 'worldItemPlacements key');
      if (entry.key != entry.value.instanceId) {
        throw ArgumentError.value(
          entry.key,
          'worldItemPlacements',
          'Placement key must match its instance ID.',
        );
      }
    }
    _validateActivePlaySeconds(activePlaySeconds);

    final resolvedMapId = mapId ?? 'alderwake';
    _validateStableId(resolvedMapId, 'mapId');
    return RuntimeGameState._(
      player: player,
      mapId: resolvedMapId,
      inventory: inventory ?? InventoryState(),
      relationships: Map.unmodifiable(Map.of(relationships)),
      collectedResourceNodeIds: Set.unmodifiable(
        Set.of(collectedResourceNodeIds),
      ),
      dayCycleProgress: dayCycleProgress,
      dayIndex: dayIndex,
      weatherSeed: weatherSeed,
      activeWorldEventIds: Set.unmodifiable(Set.of(activeWorldEventIds)),
      suppressedRoutineIds: Set.unmodifiable(Set.of(suppressedRoutineIds)),
      tutorialFlags: Set.unmodifiable(Set.of(tutorialFlags)),
      lightSourceOverrides: Map.unmodifiable(Map.of(lightSourceOverrides)),
      worldItemPlacements: Map.unmodifiable(Map.of(worldItemPlacements)),
      eventJournal: eventJournal ?? PlayerEventJournal(),
      activePlaySeconds: activePlaySeconds,
      campaign: campaign ?? CampaignSaveState.initial(),
      storyPreview: storyPreview,
    );
  }

  RuntimeGameState._({
    required this.player,
    required this.mapId,
    required this.inventory,
    required this.relationships,
    required this.collectedResourceNodeIds,
    required this.dayCycleProgress,
    required this.dayIndex,
    required this.weatherSeed,
    required this.activeWorldEventIds,
    required this.suppressedRoutineIds,
    required this.tutorialFlags,
    required this.lightSourceOverrides,
    required this.worldItemPlacements,
    required this.eventJournal,
    required this.activePlaySeconds,
    required this.campaign,
    required this.storyPreview,
  });

  static const defaultPlayerId = 'player-1';
  static const npc01Id = WorldMapAuthoringRegistry.npc01MapValue;

  factory RuntimeGameState.initial({
    double? playerSpawnX,
    double? playerSpawnY,
    Iterable<String> npcIds = const [npc01Id],
    int weatherSeed = WeatherSchedule.defaultSeed,
  }) {
    return RuntimeGameState(
      player: PlayerState(
        playerId: defaultPlayerId,
        x: playerSpawnX ?? WorldGeometry.mvp.playerSpawnX,
        y: playerSpawnY ?? WorldGeometry.mvp.playerSpawnY,
      ),
      relationships: {
        for (final npcId in npcIds) npcId: NpcRelationshipState(npcId: npcId),
      },
      weatherSeed: weatherSeed,
    );
  }

  final PlayerState player;

  /// Stable owning map for persisted player coordinates.
  final String mapId;

  final InventoryState inventory;
  final Map<String, NpcRelationshipState> relationships;
  final Set<String> collectedResourceNodeIds;
  final double dayCycleProgress;
  final int dayIndex;
  final int weatherSeed;
  final Set<String> activeWorldEventIds;
  final Set<String> suppressedRoutineIds;
  final Set<String> tutorialFlags;
  final Map<LightSourceStateKey, bool> lightSourceOverrides;
  final Map<String, WorldItemPlacement> worldItemPlacements;
  final PlayerEventJournal eventJournal;
  final double activePlaySeconds;
  final CampaignSaveState campaign;
  final StoryPreviewSetup? storyPreview;

  RuntimeGameState copyWith({
    PlayerState? player,
    String? mapId,
    InventoryState? inventory,
    Map<String, NpcRelationshipState>? relationships,
    Set<String>? collectedResourceNodeIds,
    double? dayCycleProgress,
    int? dayIndex,
    int? weatherSeed,
    Set<String>? activeWorldEventIds,
    Set<String>? suppressedRoutineIds,
    Set<String>? tutorialFlags,
    Map<LightSourceStateKey, bool>? lightSourceOverrides,
    Map<String, WorldItemPlacement>? worldItemPlacements,
    PlayerEventJournal? eventJournal,
    double? activePlaySeconds,
    CampaignSaveState? campaign,
    StoryPreviewSetup? storyPreview,
  }) {
    return RuntimeGameState(
      player: player ?? this.player,
      mapId: mapId ?? this.mapId,
      inventory: inventory ?? this.inventory,
      relationships: relationships ?? this.relationships,
      collectedResourceNodeIds:
          collectedResourceNodeIds ?? this.collectedResourceNodeIds,
      dayCycleProgress: dayCycleProgress ?? this.dayCycleProgress,
      dayIndex: dayIndex ?? this.dayIndex,
      weatherSeed: weatherSeed ?? this.weatherSeed,
      activeWorldEventIds: activeWorldEventIds ?? this.activeWorldEventIds,
      suppressedRoutineIds: suppressedRoutineIds ?? this.suppressedRoutineIds,
      tutorialFlags: tutorialFlags ?? this.tutorialFlags,
      lightSourceOverrides: lightSourceOverrides ?? this.lightSourceOverrides,
      worldItemPlacements: worldItemPlacements ?? this.worldItemPlacements,
      eventJournal: eventJournal ?? this.eventJournal,
      activePlaySeconds: activePlaySeconds ?? this.activePlaySeconds,
      campaign: campaign ?? this.campaign,
      storyPreview: storyPreview ?? this.storyPreview,
    );
  }
}

void _validateStableId(String value, String argumentName) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(
      value,
      argumentName,
      'Stable ID cannot be empty.',
    );
  }
}

void _validateStableIds(Iterable<String> values, String argumentName) {
  for (final value in values) {
    _validateStableId(value, argumentName);
  }
}

void _validateFiniteCoordinate(double value, String argumentName) {
  if (!value.isFinite) {
    throw ArgumentError.value(
      value,
      argumentName,
      'Coordinate must be finite.',
    );
  }
}

void _validateDayCycleProgress(double value) {
  if (!value.isFinite || value < 0.0 || value >= 1.0) {
    throw ArgumentError.value(
      value,
      'dayCycleProgress',
      'Day cycle progress must be greater than or equal to 0.0 and less than 1.0.',
    );
  }
}

void _validateDayIndex(int value) {
  if (value < 0) {
    throw ArgumentError.value(
      value,
      'dayIndex',
      'Day index must be non-negative.',
    );
  }
}

void _validateActivePlaySeconds(double value) {
  if (!value.isFinite || value < 0) {
    throw ArgumentError.value(
      value,
      'activePlaySeconds',
      'Active-play seconds must be finite and non-negative.',
    );
  }
}
