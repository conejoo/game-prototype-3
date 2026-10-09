import 'package:flutter/foundation.dart';

import '../../world_map/world_map.dart';
import '../../world_map/world_map_authoring_registry.dart';
import '../../world_map/world_map_flattening.dart';
import '../../world_map/world_object_catalog.dart';
import '../day_night/day_night_cycle.dart';
import '../dialogue/dialogue_model.dart';
import '../dialogue/dialogue_choice_eligibility.dart';
import '../dialogue/dialogue_repository.dart';
import '../items/item_definition.dart';
import '../items/world_item_placement_validator.dart';
import '../navigation/navigation.dart';
import '../presentation/world_portal_eligibility.dart';
import '../npc/npc_content.dart';
import '../resources/resource_definition.dart';
import '../tutorial/tutorial_progress.dart';
import '../world/world_collision_map.dart';
import '../world/world_navigation_static_map.dart';
import '../world_events/world_event_catalog.dart';
import '../weather/weather_schedule.dart';
import 'hud_snapshot.dart';
import 'inventory_snapshot.dart';
import 'people_snapshot.dart';
import 'player_event_journal.dart';
import 'runtime_game_state.dart';
import '../campaign/quest_action.dart';

class ResourceCollectionResult {
  const ResourceCollectionResult({
    required this.itemId,
    required this.inventoryStatus,
  });

  final String itemId;
  final InventoryAddStatus inventoryStatus;

  bool get collected => inventoryStatus == InventoryAddStatus.added;
}

class ActivityRewardResult {
  const ActivityRewardResult({
    required this.itemId,
    required this.inventoryStatus,
  });

  final String itemId;
  final InventoryAddStatus inventoryStatus;

  bool get added => inventoryStatus == InventoryAddStatus.added;
}

class DialogueChoiceTransition {
  const DialogueChoiceTransition({
    required this.choice,
    required this.previousRelationship,
    required this.nextRelationship,
    required this.nextDialogue,
    required this.milestoneDialogue,
    required this.isGift,
  });

  final DialogueChoice choice;
  final NpcRelationshipState previousRelationship;
  final NpcRelationshipState nextRelationship;
  final DialogueNode? nextDialogue;
  final DialogueNode? milestoneDialogue;
  final bool isGift;
}

class GiftTransition {
  const GiftTransition({
    required this.choice,
    required this.previousRelationship,
    required this.nextRelationship,
    required this.milestoneDialogue,
    this.nextDialogue,
  });

  final DialogueChoice choice;
  final NpcRelationshipState previousRelationship;
  final NpcRelationshipState nextRelationship;
  final DialogueNode? milestoneDialogue;
  final DialogueNode? nextDialogue;
}

/// Committed state of one player-operated light source.
class LightSourceToggleResult {
  const LightSourceToggleResult({
    required this.key,
    required this.label,
    required this.isOn,
  });

  final LightSourceStateKey key;
  final String label;
  final bool isOn;
}

/// Owns serializable NPC memory, dialogue rules, and selector publication.
class RuntimeGameController {
  RuntimeGameController({
    required this.initialState,
    required RuntimeGameState loadedState,
    required this.movementCollisionMap,
    required this.worldMap,
    required this.playerCollisionRadius,
    this.dialogueRepository = const EmptyDialogueRepository(),
    required this.itemCatalog,
    required this.resourceCatalog,
    this.npcCatalog,
    this.worldObjectCatalog,
    required this.worldEventCatalog,
    Map<String, WorldCollisionMap>? locationCollisionMaps,
    Map<String, WorldMap>? locationMaps,
    WorldNavigationService? navigationService,
    this.portalEligibility,
    this.onQuestActions,
  }) {
    _locationCollisionMaps = Map.unmodifiable({
      'alderwake': movementCollisionMap,
      ...?locationCollisionMaps,
    });
    _locationMaps = Map.unmodifiable({'alderwake': worldMap, ...?locationMaps});
    _navigationService =
        navigationService ??
        GridWorldNavigationService(
          mapSource: LoadedWorldNavigationStaticMapSource(
            collisionMaps: _locationCollisionMaps,
          ),
        );
    _state = _bindActiveRelationshipDefinitions(
      _normalizeLoadedLightSourceOverrides(
        _normalizeLoadedPlayerPosition(loadedState),
      ),
    );
    _validateKnownWorldEvents(
      initialState.activeWorldEventIds,
      'initialState.activeWorldEventIds',
    );
    _validateKnownWorldEvents(
      _state.activeWorldEventIds,
      'loadedState.activeWorldEventIds',
    );
    _weatherSample = _sampleWeather(_state);
    _wasInWoods =
        _state.mapId == 'alderwake' &&
        _isInWoods(_state.player.x, _state.player.y);
    _hudSnapshot = ValueNotifier(_deriveHudSnapshot());
    _inventorySnapshot = ValueNotifier(
      InventorySnapshot.fromRuntimeState(_state, itemCatalog: itemCatalog),
    );
    _peopleSnapshot = ValueNotifier(_derivePeopleSnapshot());
    _canGiveGift = ValueNotifier(false);
  }

  /// Precise successful-operation facts; legacy event aggregation is untouched.
  final void Function(List<QuestAction>)? onQuestActions;

  void publishCommittedState(RuntimeGameState state) => _setState(state);

  final RuntimeGameState initialState;
  WorldCollisionMap movementCollisionMap;
  WorldMap worldMap;
  final double playerCollisionRadius;
  final DialogueRepository dialogueRepository;
  final ResourceDefinitionRepository resourceCatalog;
  final ItemDefinitionCatalog itemCatalog;
  final NpcCatalog? npcCatalog;
  final WorldObjectCatalog? worldObjectCatalog;
  final WorldEventCatalog worldEventCatalog;
  late Map<String, WorldCollisionMap> _locationCollisionMaps;
  late Map<String, WorldMap> _locationMaps;
  late WorldNavigationService _navigationService;
  WorldPortalEligibility? portalEligibility;
  late RuntimeGameState _state;
  late WeatherSample _weatherSample;
  late bool _wasInWoods;
  late final ValueNotifier<HudSnapshot> _hudSnapshot;
  late final ValueNotifier<InventorySnapshot> _inventorySnapshot;
  late final ValueNotifier<PeopleSnapshot> _peopleSnapshot;
  late final ValueNotifier<bool> _canGiveGift;
  DialogueNode? _activeDialogue;

  RuntimeGameState get state => _state;
  ValueListenable<HudSnapshot> get hudSnapshotListenable => _hudSnapshot;
  ValueListenable<InventorySnapshot> get inventorySnapshotListenable =>
      _inventorySnapshot;
  ValueListenable<PeopleSnapshot> get peopleSnapshotListenable =>
      _peopleSnapshot;
  ValueListenable<bool> get canGiveGiftListenable => _canGiveGift;
  bool get canGiveGift => _deriveCanGiveGift();

  WeatherSample get currentWeather => _weatherSample;

  Set<String> get effectiveWorldEventIds => Set.unmodifiable({
    ..._state.activeWorldEventIds,
    if (currentWeather.condition == WeatherCondition.thunderstorm) 'heavy-rain',
  });

  WorldCollisionMap collisionMapFor(String mapId) =>
      _locationCollisionMaps[mapId] ?? movementCollisionMap;

  WorldMap mapFor(String mapId) => _locationMaps[mapId] ?? worldMap;

  /// Resolves saved runtime state before the authored per-instance default.
  bool isLightSourceEnabled(LightSourceStateKey key) {
    final source = _findLightSource(key);
    if (source == null) return false;
    return _state.lightSourceOverrides[key] ??
        source.prop.lightSourceStates[source.source.id] ??
        source.source.initiallyOn;
  }

  /// Flips one source only when its catalog entry allows player interaction.
  LightSourceToggleResult? toggleLightSource(LightSourceStateKey key) {
    final source = _findLightSource(key);
    if (source == null || !source.source.switchable) {
      return null;
    }
    final nextIsOn = !isLightSourceEnabled(key);
    _setState(
      _state.copyWith(
        lightSourceOverrides: {..._state.lightSourceOverrides, key: nextIsOn},
      ),
    );
    return LightSourceToggleResult(
      key: key,
      label: source.source.label,
      isOn: nextIsOn,
    );
  }

  /// Commits a validated new location and its local player arrival point.
  bool travelTo(
    String mapId, {
    required double x,
    required double y,
    String? portalId,
  }) {
    if (!_locationMaps.containsKey(mapId) ||
        !(portalEligibility?.allowsTransition(
              source: mapFor(_state.mapId),
              destinationMapId: mapId,
              x: x,
              y: y,
              portalId: portalId,
            ) ??
            true)) {
      return false;
    }
    final collision = collisionMapFor(mapId);
    if (!collision.canOccupyPlayer(
      centerX: x,
      centerY: y,
      radius: playerCollisionRadius,
    )) {
      return false;
    }
    final sourceMapId = _state.mapId;
    _wasInWoods = false;
    _setState(
      _state.copyWith(
        mapId: mapId,
        player: _state.player.copyWith(x: x, y: y),
      ),
    );
    if (portalId != null) {
      onQuestActions?.call([
        QuestAction(
          kind: QuestActionKind.portalTraversed,
          mapId: sourceMapId,
          subjectId: portalId,
          targetId: mapId,
        ),
      ]);
    }
    return true;
  }

  void setActiveDialogue(DialogueNode? dialogue) {
    _activeDialogue = dialogue;
    _publishGiftAvailability();
  }

  DialogueNode? resolveDialogueForNpc(
    String npcId, {
    Iterable<String> preferredEntryNodeIds = const [],
  }) {
    final relationship = _state.relationships[npcId];
    if (relationship == null) {
      return null;
    }
    final graph = dialogueRepository.graphForNpc(npcId);
    if (graph != null) {
      final visited = <String>{};
      for (final entryNodeId in preferredEntryNodeIds) {
        if (!visited.add(entryNodeId)) {
          continue;
        }
        final preferred =
            DialogueResolver(graph.nodes, entryNodeIds: [entryNodeId]).resolve(
              relationship,
              journal: _state.eventJournal,
              activePlaySeconds: _state.activePlaySeconds,
            );
        if (preferred != null) {
          return preferred;
        }
      }
    }
    return dialogueRepository.resolveFor(
      relationship,
      journal: _state.eventJournal,
      activePlaySeconds: _state.activePlaySeconds,
    );
  }

  DialogueNode? startDialogueForNpc(
    String npcId, {
    Iterable<String> preferredEntryNodeIds = const [],
  }) {
    final node = resolveDialogueForNpc(
      npcId,
      preferredEntryNodeIds: preferredEntryNodeIds,
    );
    if (node == null) {
      return null;
    }
    _enterNode(node);
    return node;
  }

  List<DialogueChoice> availableChoices(DialogueNode node) => List.unmodifiable(
    node.choices.where((choice) => choiceEligibility(node, choice).isAvailable),
  );

  DialogueChoiceEligibility choiceEligibility(
    DialogueNode node,
    DialogueChoice choice,
  ) {
    final relationship = _state.relationships[node.npcId];
    if (relationship == null) {
      return const DialogueChoiceEligibility.unavailable(
        DialogueChoiceIneligibility.missingRelationship,
      );
    }
    return const DialogueChoiceEligibilityService().evaluate(
      choice: choice,
      relationship: relationship,
      journal: _state.eventJournal,
      activePlaySeconds: _state.activePlaySeconds,
      inventoryCounts: _state.inventory.itemCounts,
      itemCatalog: itemCatalog,
      giftRule: _giftRule(node.npcId, choice.giftRuleId),
    );
  }

  ResourceCollectionResult? collectResourceNode({
    required String nodeId,
    required String resourceId,
  }) {
    final resource = resourceCatalog.findById(resourceId);
    if (resource == null) {
      return ResourceCollectionResult(
        itemId: resourceId,
        inventoryStatus: InventoryAddStatus.unknownItem,
      );
    }
    final itemId = resource.item.id;
    final isDroppedItem = _state.worldItemPlacements.containsKey(nodeId);
    final isAuthoredNode = _locationMaps.values.any(
      (map) => map.objects.whereType<ResourceNodeMapObject>().any(
        (object) => object.id == nodeId && object.definitionId == resourceId,
      ),
    );
    if (_state.collectedResourceNodeIds.contains(nodeId) && !isDroppedItem) {
      return null;
    }
    final inventoryResult = _state.inventory.tryAddItem(itemId, itemCatalog);
    if (!inventoryResult.added) {
      return ResourceCollectionResult(
        itemId: itemId,
        inventoryStatus: inventoryResult.status,
      );
    }
    final tutorialFlags =
        _itemHasRole(itemId, ItemContentRole.tutorialMoonflower)
        ? TutorialProgress.recordMoonflowerCollection(_state.tutorialFlags)
        : _state.tutorialFlags;
    _setState(
      _state.copyWith(
        inventory: inventoryResult.inventory,
        collectedResourceNodeIds: isDroppedItem && !isAuthoredNode
            ? _state.collectedResourceNodeIds
            : {..._state.collectedResourceNodeIds, nodeId},
        worldItemPlacements: isDroppedItem
            ? (Map<String, WorldItemPlacement>.of(_state.worldItemPlacements)
                ..remove(nodeId))
            : _state.worldItemPlacements,
        tutorialFlags: tutorialFlags,
        eventJournal: _state.eventJournal.record(
          kind: PlayerEventKind.resourceGathered,
          subjectId: resourceId,
          activeSeconds: _state.activePlaySeconds,
        ),
      ),
    );
    onQuestActions?.call([
      QuestAction(
        kind: QuestActionKind.resourceGathered,
        mapId: _state.mapId,
        subjectId: resourceId,
        detailId: null,
      ),
    ]);
    return ResourceCollectionResult(
      itemId: itemId,
      inventoryStatus: InventoryAddStatus.added,
    );
  }

  /// Reports whether one generated reward can fit without mutating state.
  InventoryAddStatus activityRewardCapacity(String itemId) =>
      _state.inventory.tryAddItem(itemId, itemCatalog).status;

  /// Adds a generated activity reward without changing authored world nodes.
  ActivityRewardResult addActivityReward(String itemId) {
    final inventoryResult = _state.inventory.tryAddItem(itemId, itemCatalog);
    if (inventoryResult.added) {
      _setState(_state.copyWith(inventory: inventoryResult.inventory));
    }
    return ActivityRewardResult(
      itemId: itemId,
      inventoryStatus: inventoryResult.status,
    );
  }

  /// Makes one owned cataloged item active.
  ///
  /// Returns false when item is missing, unknown, or already active.
  bool activateInventoryItem(String itemId) {
    if (itemCatalog.findById(itemId) == null) {
      return false;
    }
    final nextInventory = _state.inventory.activateItem(itemId);
    if (nextInventory == null || identical(nextInventory, _state.inventory)) {
      return false;
    }
    _setState(_state.copyWith(inventory: nextInventory));
    return true;
  }

  /// Moves an authored or previously dropped movable pickup within its map.
  WorldItemPlacement? moveWorldItem({
    required String instanceId,
    required String itemId,
    required String mapId,
    required double x,
    required double y,
  }) {
    final definition = itemCatalog.findById(itemId);
    final resource = resourceCatalog.findByItemId(itemId);
    final map = _locationMaps[mapId];
    if (definition?.worldBehavior != ItemWorldBehavior.movablePickup ||
        resource == null ||
        map == null ||
        !canPlaceWorldItem(itemId: itemId, mapId: mapId, x: x, y: y)) {
      return null;
    }
    final existing = _state.worldItemPlacements[instanceId];
    final isAuthoredPickup = map.objects.whereType<ResourceNodeMapObject>().any(
      (object) => object.id == instanceId && object.definitionId == resource.id,
    );
    if (existing == null && !isAuthoredPickup) {
      return null;
    }
    if (existing != null &&
        (existing.itemId != itemId || existing.mapId != mapId)) {
      return null;
    }
    final placement = WorldItemPlacement(
      instanceId: instanceId,
      itemId: itemId,
      mapId: mapId,
      x: x,
      y: y,
    );
    _setState(
      _state.copyWith(
        worldItemPlacements: {
          ..._state.worldItemPlacements,
          instanceId: placement,
        },
      ),
    );
    return placement;
  }

  /// Removes one movable item from the backpack and places it in the world.
  WorldItemPlacement? dropInventoryItem({
    required String itemId,
    required String mapId,
    required double x,
    required double y,
  }) {
    final definition = itemCatalog.findById(itemId);
    final map = _locationMaps[mapId];
    if (definition?.worldBehavior != ItemWorldBehavior.movablePickup ||
        map == null ||
        !canPlaceWorldItem(itemId: itemId, mapId: mapId, x: x, y: y) ||
        _state.worldItemPlacements.values.any(
          (placement) => placement.itemId == itemId,
        )) {
      return null;
    }
    final inventory = _state.inventory.consumeItem(itemId);
    if (inventory == null) {
      return null;
    }
    final placement = WorldItemPlacement(
      instanceId: 'dropped-$itemId',
      itemId: itemId,
      mapId: mapId,
      x: x,
      y: y,
    );
    _setState(
      _state.copyWith(
        inventory: inventory,
        worldItemPlacements: {
          ..._state.worldItemPlacements,
          placement.instanceId: placement,
        },
      ),
    );
    return placement;
  }

  /// Whether a movable pickup can be persisted at this exact anchor.
  bool canPlaceWorldItem({
    required String itemId,
    required String mapId,
    required double x,
    required double y,
  }) {
    final map = _locationMaps[mapId];
    final collisionMap = _locationCollisionMaps[mapId];
    if (map == null || collisionMap == null) {
      return false;
    }
    return const WorldItemPlacementValidator().canPlace(
      itemId: itemId,
      resourceCatalog: resourceCatalog,
      mapId: mapId,
      x: x,
      y: y,
      playerX: _state.player.x,
      playerY: _state.player.y,
      playerRadius: playerCollisionRadius,
      map: map,
      collisionMap: collisionMap,
      navigationService: _navigationService,
    );
  }

  DialogueChoiceTransition? selectDialogueChoice(
    DialogueNode node,
    String choiceId,
  ) {
    DialogueChoice? choice;
    for (final candidate in availableChoices(node)) {
      if (candidate.id == choiceId) {
        choice = candidate;
        break;
      }
    }
    if (choice == null) {
      return null;
    }
    if (choice.isGift) {
      return _applyGiftChoice(node, choice);
    }

    final previous = _state.relationships[node.npcId];
    if (previous == null) {
      return null;
    }
    final application = choice.applyTo(
      previous,
      levelOneAffinity: _relationshipDefinition(node.npcId).levelOneAffinity,
    );
    final milestone = _milestoneFor(
      previous: previous,
      next: application.relationship,
      levelIncreased: application.levelIncreased,
    );
    final authoredNext = _targetNode(node.npcId, choice.targetNodeId);
    final nextDialogue = choice.endsConversation
        ? null
        : milestone ?? authoredNext;
    final nextRelationship = nextDialogue == null
        ? application.relationship
        : _relationshipEnteringNode(application.relationship, nextDialogue);
    final journal = _state.eventJournal.record(
      kind: PlayerEventKind.dialogueChoiceSelected,
      subjectId: node.npcId,
      targetId: choice.id,
      activeSeconds: _state.activePlaySeconds,
    );
    _setState(
      _state.copyWith(
        relationships: {..._state.relationships, node.npcId: nextRelationship},
        eventJournal: journal,
      ),
    );
    onQuestActions?.call([
      QuestAction(
        kind: QuestActionKind.dialogueChoiceSelected,
        mapId: _state.mapId,
        subjectId: node.npcId,
        targetId: choice.id,
        detailId: node.id,
      ),
    ]);
    return DialogueChoiceTransition(
      choice: choice,
      previousRelationship: previous,
      nextRelationship: nextRelationship,
      nextDialogue: nextDialogue,
      milestoneDialogue: milestone,
      isGift: false,
    );
  }

  DialogueNode? continueDialogue(DialogueNode node) {
    final next = _targetNode(node.npcId, node.continueTargetId);
    if (next != null) {
      _enterNode(next);
    }
    return next;
  }

  GiftTransition? giveGift(DialogueNode dialogue) {
    DialogueChoice? choice;
    for (final candidate in availableChoices(dialogue)) {
      if (candidate.giftRuleId != null) {
        choice = candidate;
        break;
      }
    }
    if (choice == null) {
      return null;
    }
    final transition = _applyGiftChoice(dialogue, choice);
    return transition == null
        ? null
        : GiftTransition(
            choice: transition.choice,
            previousRelationship: transition.previousRelationship,
            nextRelationship: transition.nextRelationship,
            milestoneDialogue: transition.milestoneDialogue,
            nextDialogue: transition.nextDialogue,
          );
  }

  DialogueChoiceTransition? _applyGiftChoice(
    DialogueNode node,
    DialogueChoice choice,
  ) {
    final previous = _state.relationships[node.npcId];
    final rule = _giftRule(node.npcId, choice.giftRuleId);
    if (previous == null ||
        rule == null ||
        !choiceEligibility(node, choice).isAvailable) {
      return null;
    }
    final nextInventory = _state.inventory.consumeItem(rule.itemId);
    if (nextInventory == null) {
      return null;
    }
    final choiceApplication = choice.applyTo(
      previous,
      levelOneAffinity: _relationshipDefinition(node.npcId).levelOneAffinity,
    );
    final affinity = choiceApplication.relationship.applyAffinityDelta(
      rule.affinityDelta,
      levelOneAffinity: _relationshipDefinition(node.npcId).levelOneAffinity,
    );
    var relationship = affinity.relationship;
    final milestone = _milestoneFor(
      previous: previous,
      next: relationship,
      levelIncreased: previous.level < relationship.level,
    );
    final authoredNext = _targetNode(node.npcId, choice.targetNodeId);
    final nextDialogue = choice.endsConversation
        ? null
        : milestone ?? authoredNext;
    if (nextDialogue != null) {
      relationship = _relationshipEnteringNode(relationship, nextDialogue);
    }
    var journal = _state.eventJournal.record(
      kind: PlayerEventKind.itemGifted,
      subjectId: rule.itemId,
      targetId: node.npcId,
      activeSeconds: _state.activePlaySeconds,
    );
    journal = journal.record(
      kind: PlayerEventKind.dialogueChoiceSelected,
      subjectId: node.npcId,
      targetId: choice.id,
      activeSeconds: _state.activePlaySeconds,
    );
    final tutorialFlags =
        node.npcId == Npc01DialogueIds.npc01Id &&
            _itemHasRole(rule.itemId, ItemContentRole.tutorialMoonflower)
        ? TutorialProgress.recordAcceptedNpc01MoonflowerGift(
            _state.tutorialFlags,
          )
        : _state.tutorialFlags;
    _setState(
      _state.copyWith(
        inventory: nextInventory,
        tutorialFlags: tutorialFlags,
        relationships: {..._state.relationships, node.npcId: relationship},
        eventJournal: journal,
      ),
    );
    onQuestActions?.call([
      QuestAction(
        kind: QuestActionKind.itemGifted,
        mapId: _state.mapId,
        subjectId: rule.itemId,
        targetId: node.npcId,
      ),
      QuestAction(
        kind: QuestActionKind.dialogueChoiceSelected,
        mapId: _state.mapId,
        subjectId: node.npcId,
        targetId: choice.id,
        detailId: node.id,
      ),
    ]);
    return DialogueChoiceTransition(
      choice: choice,
      previousRelationship: previous,
      nextRelationship: relationship,
      nextDialogue: nextDialogue,
      milestoneDialogue: milestone,
      isGift: true,
    );
  }

  bool tryUpdatePlayerPosition({
    required double x,
    required double y,
    required double playerRadius,
    double? currentX,
    double? currentY,
  }) {
    if (!collisionMapFor(_state.mapId).canMovePlayer(
      fromX: currentX ?? _state.player.x,
      fromY: currentY ?? _state.player.y,
      toX: x,
      toY: y,
      radius: playerRadius,
    )) {
      return false;
    }
    final didMove = x != _state.player.x || y != _state.player.y;
    final isInWoods = _state.mapId == 'alderwake' && _isInWoods(x, y);
    final tutorialFlags = didMove
        ? TutorialProgress.recordMovement(
            _state.tutorialFlags,
            isInMoonwood: isInWoods,
          )
        : _state.tutorialFlags;
    var journal = _state.eventJournal;
    final enteredWoods =
        _state.mapId == 'alderwake' && !_wasInWoods && isInWoods;
    if (enteredWoods) {
      journal = journal.record(
        kind: PlayerEventKind.areaEntered,
        subjectId: WorldMapAuthoringRegistry.woods.mapValue,
        activeSeconds: _state.activePlaySeconds,
      );
    }
    _wasInWoods = isInWoods;
    _setState(
      _state.copyWith(
        player: _state.player.copyWith(x: x, y: y),
        tutorialFlags: tutorialFlags,
        eventJournal: journal,
      ),
    );
    if (enteredWoods) {
      onQuestActions?.call([
        const QuestAction(
          kind: QuestActionKind.areaEntered,
          mapId: 'alderwake',
          subjectId: WorldMapAuthoringRegistry.woodsMapValue,
        ),
      ]);
    }
    return true;
  }

  /// Commits bounded gameplay-harness setup without movement progression.
  ///
  /// This updates live serializable truth but deliberately does not record
  /// tutorial movement or area-entry events. Callers also must not request a
  /// save solely because this method succeeds.
  bool relocatePlayerForGameplayHarness({
    required double x,
    required double y,
    required double playerRadius,
  }) {
    if (!collisionMapFor(
      _state.mapId,
    ).canOccupyPlayer(centerX: x, centerY: y, radius: playerRadius)) {
      return false;
    }
    _wasInWoods = _state.mapId == 'alderwake' && _isInWoods(x, y);
    _setState(
      _state.copyWith(
        player: _state.player.copyWith(x: x, y: y),
      ),
    );
    return true;
  }

  void advanceDayCycle(double elapsedSeconds) {
    if (!elapsedSeconds.isFinite || elapsedSeconds <= 0) {
      return;
    }
    if (_state.storyPreview != null) {
      _setState(
        _state.copyWith(
          activePlaySeconds: _state.activePlaySeconds + elapsedSeconds,
        ),
      );
      return;
    }
    final elapsedDayCount =
        (_state.dayCycleProgress +
                elapsedSeconds / DayNightCycle.cycleDurationSeconds)
            .floor();
    _setState(
      _state.copyWith(
        dayCycleProgress: DayNightCycle.advance(
          _state.dayCycleProgress,
          elapsedSeconds,
        ),
        dayIndex: _state.dayIndex + elapsedDayCount,
        suppressedRoutineIds: elapsedDayCount == 0
            ? _state.suppressedRoutineIds
            : const <String>{},
        activePlaySeconds: _state.activePlaySeconds + elapsedSeconds,
      ),
    );
  }

  /// Suppresses one stable routine ID until next day boundary.
  ///
  /// Returns false when routine was already suppressed.
  bool suppressRoutineForCurrentDay(String routineId) {
    if (_state.suppressedRoutineIds.contains(routineId)) {
      return false;
    }
    _setState(
      _state.copyWith(
        suppressedRoutineIds: {..._state.suppressedRoutineIds, routineId},
      ),
    );
    return true;
  }

  /// Reports whether one cataloged world event is active.
  bool isWorldEventActive(String eventId) {
    worldEventCatalog.requireById(eventId);
    return effectiveWorldEventIds.contains(eventId);
  }

  /// Activates one cataloged world event.
  ///
  /// Returns false when event was already active.
  bool activateWorldEvent(String eventId) {
    worldEventCatalog.requireById(eventId);
    if (effectiveWorldEventIds.contains(eventId)) {
      return false;
    }
    _setState(
      _state.copyWith(
        activeWorldEventIds: {..._state.activeWorldEventIds, eventId},
      ),
    );
    return true;
  }

  /// Deactivates one cataloged world event.
  ///
  /// Returns false when event was already inactive.
  bool deactivateWorldEvent(String eventId) {
    worldEventCatalog.requireById(eventId);
    if (!_state.activeWorldEventIds.contains(eventId)) {
      return false;
    }
    _setState(
      _state.copyWith(
        activeWorldEventIds: {..._state.activeWorldEventIds}..remove(eventId),
      ),
    );
    return true;
  }

  void reset({int? weatherSeed}) {
    final resetState = _bindActiveRelationshipDefinitions(
      initialState.copyWith(
        weatherSeed: weatherSeed ?? initialState.weatherSeed,
      ),
    );
    _wasInWoods =
        resetState.mapId == 'alderwake' &&
        _isInWoods(resetState.player.x, resetState.player.y);
    _setState(resetState);
  }

  /// Installs one prepared world while keeping the existing UI listenables.
  /// The game owns the input lock and validates the arrival before calling.
  void installWorld({
    required RuntimeGameState state,
    required WorldMap entryMap,
    required Map<String, WorldMap> maps,
    required Map<String, WorldCollisionMap> collisionMaps,
    required WorldNavigationService navigation,
    WorldPortalEligibility? portalEligibility,
  }) {
    _validateKnownWorldEvents(
      state.activeWorldEventIds,
      'state.activeWorldEventIds',
    );
    worldMap = entryMap;
    movementCollisionMap = collisionMaps[entryMap.mapId]!;
    _locationMaps = Map.unmodifiable(maps);
    _locationCollisionMaps = Map.unmodifiable(collisionMaps);
    _navigationService = navigation;
    this.portalEligibility = portalEligibility;
    _activeDialogue = null;
    _wasInWoods =
        state.mapId == 'alderwake' &&
        _isInWoods(state.player.x, state.player.y);
    _setState(
      _bindActiveRelationshipDefinitions(
        _normalizeLoadedLightSourceOverrides(
          _normalizeLoadedPlayerPosition(state),
        ),
      ),
    );
  }

  void _enterNode(DialogueNode node) {
    final relationship = _state.relationships[node.npcId];
    if (relationship == null) {
      return;
    }
    final next = _relationshipEnteringNode(relationship, node);
    if (!identical(next, relationship)) {
      _setState(
        _state.copyWith(
          relationships: {..._state.relationships, node.npcId: next},
        ),
      );
    }
  }

  NpcRelationshipState _relationshipEnteringNode(
    NpcRelationshipState relationship,
    DialogueNode node,
  ) {
    final seen = relationship.seenDialogueIds.contains(node.id);
    final hasFacts = relationship.learnedFactIds.containsAll(
      node.revealedFactIds,
    );
    final milestone = _relationshipDefinition(node.npcId).levelOneMilestone;
    final milestoneSeenFlagId = milestone?.dialogueNodeId == node.id
        ? milestone!.seenFlagId
        : null;
    final hasMilestoneFlag =
        milestoneSeenFlagId == null ||
        relationship.flags.contains(milestoneSeenFlagId);
    if (seen && hasFacts && hasMilestoneFlag) {
      return relationship;
    }
    return relationship.copyWith(
      seenDialogueIds: {...relationship.seenDialogueIds, node.id},
      learnedFactIds: {...relationship.learnedFactIds, ...node.revealedFactIds},
      flags: {...relationship.flags, ?milestoneSeenFlagId},
    );
  }

  DialogueNode? _milestoneFor({
    required NpcRelationshipState previous,
    required NpcRelationshipState next,
    required bool levelIncreased,
  }) {
    final milestone = _relationshipDefinition(next.npcId).levelOneMilestone;
    if (milestone == null ||
        !levelIncreased ||
        previous.level >= NpcRelationshipState.levelOne ||
        next.level != NpcRelationshipState.levelOne ||
        next.flags.contains(milestone.seenFlagId)) {
      return null;
    }
    return dialogueRepository
        .graphForNpc(next.npcId)
        ?.nodesById[milestone.dialogueNodeId];
  }

  DialogueNode? _targetNode(String npcId, String? targetId) => targetId == null
      ? null
      : dialogueRepository.graphForNpc(npcId)?.nodesById[targetId];

  NpcGiftRule? _giftRule(String npcId, String? ruleId) {
    if (ruleId == null) {
      return null;
    }
    return npcCatalog?.findById(npcId)?.runtime.giftRulesById[ruleId];
  }

  bool _deriveCanGiveGift() {
    final dialogue = _activeDialogue;
    if (dialogue == null) {
      return false;
    }
    return availableChoices(dialogue).any((choice) => choice.isGift);
  }

  bool _itemHasRole(String? itemId, ItemContentRole role) =>
      itemId != null &&
      itemCatalog.findById(itemId)?.contentRoles.contains(role) == true;

  RuntimeGameState _normalizeLoadedPlayerPosition(RuntimeGameState state) {
    if (!(portalEligibility?.allowsMap(state.mapId) ?? true)) {
      final spawn = worldMap.playerSpawn;
      return state.copyWith(
        mapId: worldMap.mapId,
        player: state.player.copyWith(x: spawn.x, y: spawn.y),
      );
    }
    if (!_locationMaps.containsKey(state.mapId)) {
      return state.copyWith(
        mapId: initialState.mapId,
        player: initialState.player,
      );
    }
    final collision = collisionMapFor(state.mapId);
    if (collision.canOccupyPlayer(
      centerX: state.player.x,
      centerY: state.player.y,
      radius: playerCollisionRadius,
    )) {
      return state;
    }
    final spawn = mapFor(state.mapId).playerSpawn;
    return state.copyWith(
      player: state.player.copyWith(x: spawn.x, y: spawn.y),
    );
  }

  RuntimeGameState _normalizeLoadedLightSourceOverrides(
    RuntimeGameState state,
  ) {
    if (state.lightSourceOverrides.isEmpty || worldObjectCatalog == null) {
      return state;
    }
    final known = <LightSourceStateKey, bool>{};
    for (final entry in state.lightSourceOverrides.entries) {
      if (_findLightSourceInMaps(entry.key) != null) {
        known[entry.key] = entry.value;
      }
    }
    return known.length == state.lightSourceOverrides.length
        ? state
        : state.copyWith(lightSourceOverrides: known);
  }

  ({PropMapObject prop, WorldObjectLightSourceMetadata source})?
  _findLightSource(LightSourceStateKey key) => _findLightSourceInMaps(key);

  ({PropMapObject prop, WorldObjectLightSourceMetadata source})?
  _findLightSourceInMaps(LightSourceStateKey key) {
    final catalog = worldObjectCatalog;
    final map = _locationMaps[key.mapId];
    if (catalog == null || map == null) return null;
    for (final prop in WorldMapFlattening.flatten(map).props) {
      if (prop.id != key.propId) continue;
      final definition = catalog.findById(prop.definitionId);
      WorldObjectLightSourceMetadata? source;
      for (final candidate in definition?.lightSources ?? const []) {
        if (candidate.id == key.sourceId) {
          source = candidate;
          break;
        }
      }
      return source == null ? null : (prop: prop, source: source);
    }
    return null;
  }

  RuntimeGameState _bindActiveRelationshipDefinitions(RuntimeGameState state) {
    final relationships = {...state.relationships};
    var changed = false;
    for (final id in initialState.relationships.keys) {
      final current = relationships[id] ?? NpcRelationshipState(npcId: id);
      final normalized = current.withLevelOneAffinity(
        _relationshipDefinition(id).levelOneAffinity,
      );
      relationships[id] = normalized;
      changed =
          changed ||
          !identical(current, normalized) ||
          !state.relationships.containsKey(id);
    }
    if (!changed) {
      return state;
    }
    return state.copyWith(relationships: relationships);
  }

  NpcRelationshipDefinition _relationshipDefinition(String npcId) =>
      npcCatalog?.findById(npcId)?.runtime.relationship ??
      NpcRelationshipDefinition.mvpDefault;

  void _validateKnownWorldEvents(Iterable<String> ids, String path) {
    final sortedIds = ids.toList()..sort();
    for (final (index, id) in sortedIds.indexed) {
      try {
        worldEventCatalog.requireById(id);
      } on ArgumentError catch (error) {
        throw ArgumentError.value(id, '$path[$index]', error.message);
      }
    }
  }

  bool _isInWoods(double x, double y) => worldMap.zones.any(
    (zone) =>
        zone.role == WorldMapAuthoringRegistry.woods.mapValue &&
        x >= zone.left &&
        x <= zone.right &&
        y >= zone.top &&
        y <= zone.bottom,
  );

  PeopleSnapshot _derivePeopleSnapshot() => npcCatalog == null
      ? const PeopleSnapshot([])
      : PeopleSnapshot.fromRuntimeState(_state, npcCatalog!);

  HudSnapshot _deriveHudSnapshot() => HudSnapshot.fromRuntimeState(
    _state,
    itemCatalog: itemCatalog,
    npc01Relationship: _relationshipDefinition(Npc01DialogueIds.npc01Id),
    weatherCondition: _weatherSample.condition,
  );

  void _setState(RuntimeGameState nextState) {
    _state = nextState;
    _weatherSample = _sampleWeather(_state);
    _hudSnapshot.value = _deriveHudSnapshot();
    _inventorySnapshot.value = InventorySnapshot.fromRuntimeState(
      _state,
      itemCatalog: itemCatalog,
    );
    _peopleSnapshot.value = _derivePeopleSnapshot();
    _publishGiftAvailability();
  }

  WeatherSample _sampleWeather(RuntimeGameState state) {
    if (state.storyPreview case final setup?) {
      return WeatherSample(
        condition: setup.weather,
        previousCondition: setup.weather,
        periodIndex: 0,
        periodStartMinutes: 0,
        periodEndMinutes: 1440,
        transitionProgress: 1,
      );
    }
    return WeatherSchedule.sample(
      seed: state.weatherSeed,
      dayIndex: state.dayIndex,
      dayCycleProgress: state.dayCycleProgress,
    );
  }

  void _publishGiftAvailability() {
    _canGiveGift.value = _deriveCanGiveGift();
  }

  void dispose() {
    _hudSnapshot.dispose();
    _inventorySnapshot.dispose();
    _peopleSnapshot.dispose();
    _canGiveGift.dispose();
  }
}
