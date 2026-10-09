import 'dart:ui';

import 'package:flame/components.dart';

import '../../world_map/world_map.dart';
import '../../world_map/world_map_authoring_registry.dart';
import '../../world_map/world_map_flattening.dart';
import '../cozy_adventure_game.dart';
import '../campaign/campaign_models.dart';
import '../day_night/day_night_tint_component.dart';
import '../day_night/cliff_shadow_renderer.dart';
import '../day_night/chunked_world_shadow_renderer.dart';
import '../day_night/day_night_cycle.dart';
import '../day_night/light_switch_component.dart';
import '../day_night/night_light_component.dart';
import '../day_night/night_light_ground_pool.dart';
import '../interaction/interaction_hold_system.dart';
import '../interaction/interaction_progress_component.dart';
import '../interaction/interaction_prompt_component.dart';
import '../interaction/interaction_targeting_system.dart';
import '../interaction/world_interactable_component.dart';
import '../items/ranged_item_targeting_component.dart';
import '../navigation/navigation_occupancy.dart';
import '../navigation/navigation_point.dart';
import '../npc/npc_component.dart';
import '../npc/npc_definition.dart';
import '../npc/npc_routine_diagnostics.dart';
import '../npc/npc_routine_director.dart';
import '../npc/npc_routine_executor.dart';
import '../npc/world_map_npc_routine_anchor_source.dart';
import '../resources/resource_node_component.dart';
import '../routines/routine_model.dart';
import '../state/runtime_game_state.dart';
import '../visuals/art_render_plan.dart';
import '../visuals/visual_asset_catalog.dart';
import '../visuals/elevation_plan.dart';
import '../visuals/static_world_render_plan.dart';
import '../visuals/terrain_animation_clock.dart';
import '../visuals/terrain_plan.dart';
import '../weather/weather_components.dart';
import 'chunked_static_world_renderer.dart';
import 'player_component.dart';
import 'location_world.dart';
import 'projected_world_depth.dart';
import 'world_map_portal_component.dart';
import 'world_navigation_static_map.dart';
import 'render_debug_component.dart';
import 'world_marker_component.dart';
import 'world_render_priority.dart';
import 'water_ripple_ambience_renderer.dart';

/// Flame-owned connected map and its static/runtime child assembly.
class CozyAdventureWorld extends LocationWorld {
  CozyAdventureWorld({String mapId = 'alderwake'}) : super(mapId);

  late DayNightTintComponent dayNightTint;
  late WeatherAmbienceComponent weatherAmbience;
  late WeatherEffectsComponent weatherEffects;
  List<WorldShadowRenderEntry> dayShadows = const [];
  List<NightLightComponent> nightLights = const [];
  List<NightLightGroundPool> nightLightGroundPools = const [];
  late ElevationPlan elevationPlan;
  late StaticWorldRenderPlan staticWorldRenderPlan;
  late ChunkedStaticWorldRenderer staticWorldRenderer;
  late ChunkedCliffShadowRenderer cliffShadowRenderer;
  late WorldShadowRenderPlan worldShadowRenderPlan;
  late ChunkedWorldShadowRenderer worldShadowRenderer;
  late WaterRippleAmbienceRenderer waterRippleAmbienceRenderer;
  late RenderDebugComponent renderDebug;
  RangedItemTargetingComponent? itemTargeting;
  final _runtimeChildren = <Component>[];
  final _npcComponentsById = <String, NpcComponent>{};
  final _directedRoutineIdsByNpcId = <String, String>{};
  var _staticDebugPoints = const <RenderDebugPoint>[];
  var _runtimeDebugPoints = const <RenderDebugPoint>[];
  var _hasStaticWorldRenderPlan = false;
  final navigationOccupancy = NavigationOccupancyCoordinator();

  Map<String, NpcComponent> get npcComponentsById =>
      Map.unmodifiable(_npcComponentsById);

  RoutineAnchorMapObject sceneAnchor(CampaignAnchorReference reference) {
    if (reference.mapId != mapId) {
      throw StateError('Scene belongs to another map.');
    }
    return game
        .mapFor(mapId)
        .objects
        .whereType<RoutineAnchorMapObject>()
        .firstWhere((a) => a.id == reference.anchorId);
  }

  /// Validate complete destination footprints before acquiring or saving anything.
  void validateSceneCheckpoint(
    CampaignSceneDefinition scene,
    CampaignSceneCheckpoint checkpoint,
  ) {
    final actorIds = scene.roles.map((r) => r.actorId).toSet();
    for (final id in actorIds) {
      final actor = _npcComponentsById[id];
      if (actor == null || !actor.isMounted) {
        throw StateError('Missing real actor $id.');
      }
    }
    final destinations = <({Vector2 point, double radius})>[];
    final playerFoot = sceneAnchor(checkpoint.playerAnchor);
    destinations.add((
      point: Vector2(playerFoot.x, playerFoot.y),
      radius: player.occupancyRegistration.agentProfile.requiredRadius,
    ));
    for (final placement in checkpoint.placements) {
      final role = scene.roles.firstWhere((r) => r.id == placement.roleId);
      final actor = _npcComponentsById[role.actorId]!;
      final foot = sceneAnchor(placement.anchor);
      destinations.add((
        point: Vector2(foot.x, foot.y),
        radius: actor.occupancyRegistration.agentProfile.requiredRadius,
      ));
    }
    final excluded = {
      player.occupancyRegistration.occupantId,
      for (final id in actorIds)
        _npcComponentsById[id]!.occupancyRegistration.occupantId,
    };
    for (var i = 0; i < destinations.length; i++) {
      final d = destinations[i];
      if (!game.activeMovementCollisionMap.canOccupyPlayer(
        centerX: d.point.x,
        centerY: d.point.y,
        radius: d.radius,
      )) {
        throw StateError('Scene foot blocked by world geometry.');
      }
      for (final other in destinations.take(i)) {
        if (d.point.distanceTo(other.point) < d.radius + other.radius) {
          throw StateError('Simultaneous scene footprints overlap.');
        }
      }
      for (final other in navigationOccupancy.reservations) {
        if (!excluded.contains(other.occupantId) &&
            d.point.distanceTo(Vector2(other.center.x, other.center.y)) <
                d.radius + other.agentProfile.requiredRadius) {
          throw StateError('Scene foot occupied by ${other.occupantId}.');
        }
      }
    }
  }

  /// One temporary lease uses existing instances; grouped routines yield together.
  void Function() presentSceneCheckpoint(
    CampaignSceneDefinition scene,
    CampaignSceneCheckpoint checkpoint,
  ) {
    validateSceneCheckpoint(scene, checkpoint);
    final ids = scene.roles.map((r) => r.actorId).toSet();
    final heldIds = {...ids};
    for (final id in ids) {
      final routineId = _directedRoutineIdsByNpcId[id];
      if (routineId != null) {
        heldIds.addAll(game.routineCatalog.findById(routineId)!.participants);
      }
    }
    final releases = <void Function()>[];
    try {
      for (final id in heldIds.toList()..sort()) {
        final actor = _npcComponentsById[id];
        if (actor != null) releases.add(actor.acquireSceneLease());
      }
      for (final id in ids) {
        _npcComponentsById[id]!.showAtSceneFoot(null);
      }
      for (final placement in checkpoint.placements) {
        final role = scene.roles.firstWhere((r) => r.id == placement.roleId);
        final foot = sceneAnchor(placement.anchor);
        _npcComponentsById[role.actorId]!.showAtSceneFoot(
          Vector2(foot.x, foot.y),
          facing: switch (foot.facing) {
            'north' => NpcFacing.north,
            'west' => NpcFacing.west,
            'east' => NpcFacing.east,
            _ => NpcFacing.south,
          },
        );
      }
      final foot = sceneAnchor(checkpoint.playerAnchor);
      player.occupancyRegistration.release();
      player.position.setValues(foot.x, foot.y);
      player.presentation.resyncFromLogicalPosition(player.position);
      player.occupancyRegistration.registerCurrentPosition(
        NavigationPoint(x: foot.x, y: foot.y),
      );
      player.markProjectedDepthDirty();
      refreshProjectedDepthOrder();
    } catch (_) {
      for (final release in releases.reversed) {
        release();
      }
      rethrow;
    }
    var released = false;
    return () {
      if (released) return;
      released = true;
      for (final release in releases.reversed) {
        release();
      }
      refreshProjectedDepthOrder();
    };
  }

  /// Captures read-only, non-persisted routine/navigation developer state.
  NpcRoutineDiagnosticsSnapshot routineDiagnosticsSnapshot() {
    final plan = game.routineDirector.currentPlan!;
    final npcIds = _npcComponentsById.keys.toList()..sort();
    return NpcRoutineDiagnosticsSnapshot(
      resolution: plan.resolution,
      rejections: plan.rejections,
      participants: [
        for (final npcId in npcIds)
          if (_npcComponentsById[npcId]?.routineExecutor case final executor?)
            executor.diagnostics,
      ],
    );
  }

  NpcRoutineDialogueContext? routineDialogueContextFor(String npcId) {
    final directed = game.routineDirector.currentPlan?.routineFor(npcId);
    final npc = _npcComponentsById[npcId];
    if (directed == null ||
        npc == null ||
        !npc.isRoutineVisible ||
        _directedRoutineIdsByNpcId[npcId] != directed.routineId ||
        npc.routineExecutor?.routineId != directed.routineId) {
      return null;
    }
    return NpcRoutineDialogueContext(
      directedRoutine: directed,
      currentStepId: npc.routineExecutor?.currentStepId,
    );
  }

  /// Freezes every loaded participant assigned to one atomic routine.
  int pauseRoutineGroup(String routineId) {
    final routine = game.routineCatalog.findById(routineId);
    if (routine == null) {
      return 0;
    }
    var pausedCount = 0;
    final participantIds = routine.participants.toList()..sort();
    for (final npcId in participantIds) {
      if (_directedRoutineIdsByNpcId[npcId] == routineId &&
          (_npcComponentsById[npcId]?.pauseRoutine() ?? false)) {
        pausedCount++;
      }
    }
    return pausedCount;
  }

  int resumeRoutineGroup(String routineId) {
    final routine = game.routineCatalog.findById(routineId);
    if (routine == null) {
      return 0;
    }
    var resumedCount = 0;
    final participantIds = routine.participants.toList()..sort();
    for (final npcId in participantIds) {
      if (_directedRoutineIdsByNpcId[npcId] == routineId &&
          (_npcComponentsById[npcId]?.resumeRoutine() ?? false)) {
        resumedCount++;
      }
    }
    return resumedCount;
  }

  bool jumpRoutineParticipant({
    required String routineId,
    required String npcId,
    required String stepId,
  }) {
    if (_directedRoutineIdsByNpcId[npcId] != routineId) {
      return false;
    }
    return _npcComponentsById[npcId]?.jumpRoutineToStep(stepId) ?? false;
  }

  /// Enables or hides the render diagnostics without changing game state.
  void setRenderDebugEnabled(bool enabled) {
    renderDebug.setEnabled(enabled);
  }

  /// Removes a resource root from render diagnostics before it leaves world.
  void unregisterRenderDebugPoint(PositionComponent root) {
    final updated = _runtimeDebugPoints
        .where((point) => !identical(point.root, root))
        .toList(growable: false);
    if (updated.length == _runtimeDebugPoints.length) {
      return;
    }
    _runtimeDebugPoints = List.unmodifiable(updated);
    _refreshRenderDebugPoints();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    children.register<WorldInteractableComponent>();
    try {
      await _mountWorldChildren();
    } catch (_) {
      _disposeWorldResources();
      rethrow;
    }
    // Initial participants mount asynchronously. Rank them before the first
    // rendered frame so map art cannot briefly share priority zero with
    // terrain, elevation, props, or the player.
    refreshProjectedDepthOrder();
  }

  Future<void> _mountWorldChildren() async {
    await _mountStaticChildren();
    await _mountRuntimeChildren();
  }

  Future<void> _mountStaticChildren() async {
    final map = game.mapFor(mapId);
    final flattened = WorldMapFlattening.flatten(map);
    final markers = <WorldMarkerComponent>[];
    for (final object in map.objects.whereType<MarkerMapObject>()) {
      final definition = WorldMapAuthoringRegistry.findMarker(
        object.markerKind,
      );
      if (definition != null) {
        markers.add(
          WorldMarkerComponent(object: object, definition: definition),
        );
      }
    }
    final terrainPlan = mapId == game.mapProject.project.entryMapId
        ? game.visuals.terrainPlan
        : TerrainPlan(map: map, terrainCatalog: game.terrainCatalog);
    elevationPlan = ElevationPlan(map: map);
    staticWorldRenderPlan =
        await StaticWorldRenderPlan.fromWorldCompositedTerrain(
          terrainPlan: terrainPlan,
          elevationPlan: elevationPlan,
          buildingCommands: ArtRenderPlan.createRenderCommands(
            map,
            projection: game.projectionFor(mapId),
          ),
          immutableProps: flattened.props,
          assets: game.visuals,
          worldObjectCatalog: game.worldObjectCatalog,
        );
    _hasStaticWorldRenderPlan = true;
    staticWorldRenderer = ChunkedStaticWorldRenderer(
      plan: staticWorldRenderPlan,
      animationClock: TerrainAnimationClock.fromCatalog(game.terrainCatalog),
    );
    waterRippleAmbienceRenderer = WaterRippleAmbienceRenderer(
      plan: WaterRippleRenderPlan.fromTerrainPlan(
        terrainPlan,
        visualElevationProjection: game.projectionFor(mapId),
      ),
      image: game.visuals.waterRippleImage,
      frameSources: [
        for (final sprite in game.visuals.waterRippleSprites) sprite.src,
      ],
    );
    cliffShadowRenderer = ChunkedCliffShadowRenderer(
      plan: CliffShadowRenderPlan.fromElevationPlan(
        elevationPlan,
        enabled: map.lighting.mode == WorldMapLightingMode.outdoorCycle,
      ),
    );
    worldShadowRenderPlan = WorldShadowRenderPlan.fromProps(
      props: map.lighting.mode == WorldMapLightingMode.outdoorCycle
          ? staticWorldRenderPlan.immutableProps
          : const [],
      maskResolver: game.visuals.shadowMaskImageFor,
      tileSize: map.tileSize,
    );
    worldShadowRenderer = ChunkedWorldShadowRenderer(
      plan: worldShadowRenderPlan,
    );
    dayShadows = worldShadowRenderPlan.entries;
    if (map.lighting.mode == WorldMapLightingMode.outdoorCycle) {
      nightLights = List.unmodifiable([
        for (final prop in staticWorldRenderPlan.immutableProps)
          for (final source in prop.definition.lightSources)
            NightLightComponent(
              prop: prop,
              source: source,
              lightKey: LightSourceStateKey(
                mapId: mapId,
                propId: prop.id,
                sourceId: source.id,
              ),
              overlayImage: game.visuals.nightLightImageFor(source),
            ),
      ]);
      nightLightGroundPools = List.unmodifiable([
        for (final prop in staticWorldRenderPlan.immutableProps)
          for (final source in prop.definition.lightSources)
            if (source.groundLight != null)
              NightLightGroundPool.fromPropSource(
                mapId: mapId,
                prop: prop,
                source: source,
              ),
      ]);
    } else {
      nightLights = const [];
      nightLightGroundPools = const [];
    }
    dayNightTint = DayNightTintComponent(
      geometry: game.collisionMapFor(mapId).geometry,
      mode: map.lighting.mode,
      groundLightPools: nightLightGroundPools,
      isLightSourceEnabled: game.isLightSourceEnabled,
    );
    weatherAmbience = WeatherAmbienceComponent(
      geometry: game.collisionMapFor(mapId).geometry,
      mode: map.lighting.mode,
    );
    weatherEffects = WeatherEffectsComponent(mode: map.lighting.mode);
    renderDebug = RenderDebugComponent(
      map: map,
      projection: game.projectionFor(mapId),
      collisionObstacles: game.collisionMapFor(mapId).obstacles,
    )..setEnabled(game.renderDebugEnabled);
    _staticDebugPoints = List.unmodifiable([
      for (final prop in staticWorldRenderPlan.immutableProps)
        RenderDebugPoint.immutable(
          kind: RenderDebugPointKind.prop,
          id: prop.id,
          bounds: prop.visualBounds,
          anchor: prop.projectedFoot,
        ),
      for (final marker in markers)
        RenderDebugPoint(
          kind: RenderDebugPointKind.marker,
          id: marker.id,
          root: marker,
          projectedYOffsetY: () => marker.presentation.currentOffsetY,
        ),
    ]);
    await addAll([
      ...markers,
      for (final portal in flattened.portals)
        WorldMapPortalComponent(
          portal,
          eligible: game.isPortalEligible(mapId, portal),
        ),
      dayNightTint,
      weatherAmbience,
      ...nightLights,
      weatherEffects,
      renderDebug,
    ]);
    _refreshRenderDebugPoints();
  }

  @override
  void update(double dt) {
    staticWorldRenderer.update(dt);
    waterRippleAmbienceRenderer.update(dt);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final visibleWorldRect = game.camera.visibleWorldRect;
    final dayNightLighting = DayNightCycle.lightingForProgress(
      game.runtimeState.dayCycleProgress,
    );
    final weatherVisuals = weatherAmbience.visualState;
    final lighting = DayNightLighting(
      ambienceColor: dayNightLighting.ambienceColor,
      ambienceOpacity: dayNightLighting.ambienceOpacity,
      shadowDisplacement: dayNightLighting.shadowDisplacement,
      shadowOpacity:
          dayNightLighting.shadowOpacity *
          weatherVisuals.shadowOpacityMultiplier,
      lightOpacity: dayNightLighting.lightOpacity,
    );
    staticWorldRenderer.beginFrame(visibleWorldRect);
    waterRippleAmbienceRenderer.beginFrame(visibleWorldRect);
    cliffShadowRenderer.beginFrame(visibleWorldRect);
    worldShadowRenderer.beginFrame(visibleWorldRect, lighting);
    staticWorldRenderer.renderCompositedTerrainBase(canvas);
    waterRippleAmbienceRenderer.render(canvas);
    cliffShadowRenderer.render(canvas, lighting);
  }

  @override
  void renderChild(Canvas canvas, Component child) {
    if (child is ProjectedWorldDepthParticipant) {
      final participant = child as ProjectedWorldDepthParticipant;
      worldShadowRenderer.renderBefore(
        canvas,
        participant.renderDepthKey,
        staticWorldRenderer,
      );
    } else if (child.priority >= WorldRenderPriority.dayNight) {
      worldShadowRenderer.renderRemaining(canvas, staticWorldRenderer);
    }
    super.renderChild(canvas, child);
  }

  @override
  void afterChildrenRendered(Canvas canvas) {
    worldShadowRenderer.renderRemaining(canvas, staticWorldRenderer);
    super.afterChildrenRendered(canvas);
  }

  /// Rebuilds only serializable-state representations, preserving map,
  /// obstacles, world instance, camera, and Flutter-owned overlay listeners.
  @override
  Future<void> resetRuntimeChildren() async {
    cancelActiveInteraction();
    final previousChildren = List<Component>.of(_runtimeChildren);
    final attachedChildren = previousChildren
        .where((child) => child.parent == this && !child.isRemoving)
        .toList(growable: false);
    removeAll(attachedChildren);
    game.processLifecycleEvents();
    await Future.wait(previousChildren.map((child) => child.removed));
    await game.ready();
    _runtimeChildren.clear();
    _npcComponentsById.clear();
    _directedRoutineIdsByNpcId.clear();
    navigationOccupancy.clearMap(mapId);
    _runtimeDebugPoints = const [];
    _refreshRenderDebugPoints();
    await _mountRuntimeChildren();
    game.processLifecycleEvents();
    await game.ready();
    refreshProjectedDepthOrder();
  }

  Future<void> _mountRuntimeChildren() async {
    final map = game.mapFor(mapId);
    player = PlayerComponent(
      player: game.runtimeState.player,
      movementSpeed: CozyAdventureGame.playerMovementSpeed,
      mapId: mapId,
      occupancy: navigationOccupancy,
    );
    interactionPrompt = InteractionPromptComponent();
    interactionTargeting = InteractionTargetingSystem(interactionPrompt);
    interactionProgress = InteractionProgressComponent();
    interactionHold = InteractionHoldSystem(
      interactionTargeting,
      interactionProgress,
    );
    final npcDefinitions = NpcCatalogDefinitionRepository(game.npcCatalog);
    final routinePlan = game.routineDirector.currentPlan!;
    final anchorSource = WorldMapNpcRoutineAnchorSource.fromProject(
      game.mapProject,
    );
    final routineNavigation = NpcRoutineNavigationContext(
      mapId: mapId,
      navigation: game.navigationService,
      portalRoutePlanner: game.portalRoutePlanner,
      occupancy: navigationOccupancy,
      traversalPolicy: const WorldGroundNavigationPolicy(),
      anchorSource: anchorSource,
    );
    final resourceDefinitions = game.contentCatalog.resources;
    final npcs = <NpcComponent>[];
    final resources = <ResourceNodeComponent>[];
    final lightSwitches = <LightSwitchComponent>[];
    final npcPlacements = <String, NpcMapObject>{};
    final sortedNpcObjects = map.objects.whereType<NpcMapObject>().toList()
      ..sort((left, right) => left.id.compareTo(right.id));
    for (final object in sortedNpcObjects) {
      npcPlacements.putIfAbsent(object.definitionId, () => object);
    }
    final npcIds = <String>{
      ...npcPlacements.keys,
      ...routinePlan.byNpcId.keys,
    }.toList()..sort();
    for (final npcId in npcIds) {
      final placement = npcPlacements[npcId];
      final directed = routinePlan.routineFor(npcId);
      if (directed == null && placement == null) {
        continue;
      }
      final definition = npcDefinitions.findById(npcId);
      if (definition == null) {
        continue;
      }
      final origin = directed == null
          ? (mapId: mapId, point: Vector2(placement!.x, placement.y))
          : _routineOrigin(
              npcId: npcId,
              directed: directed,
              anchorSource: anchorSource,
            );
      if (origin == null) {
        continue;
      }
      final npc = NpcComponent(
        objectId: placement?.id ?? npcId,
        definition: definition,
        routineNavigation: routineNavigation,
        position: origin.point,
        initialMapId: origin.mapId,
      );
      npcs.add(npc);
      _npcComponentsById[npcId] = npc;
    }
    for (final object in map.objects) {
      switch (object) {
        case NpcMapObject():
          break;
        case ResourceNodeMapObject():
          if (game.runtimeState.worldItemPlacements.containsKey(object.id)) {
            continue;
          }
          if (game.runtimeState.collectedResourceNodeIds.contains(object.id)) {
            continue;
          }
          final definition = resourceDefinitions.findById(object.definitionId);
          if (definition != null) {
            resources.add(
              ResourceNodeComponent(
                nodeId: object.id,
                resource: definition,
                position: Vector2(object.x, object.y),
              ),
            );
          }
        case PropMapObject() || MarkerMapObject() || RoutineAnchorMapObject():
          break;
      }
    }
    final droppedPlacements =
        game.runtimeState.worldItemPlacements.values
            .where((placement) => placement.mapId == mapId)
            .toList()
          ..sort((left, right) => left.instanceId.compareTo(right.instanceId));
    for (final placement in droppedPlacements) {
      final definition = resourceDefinitions.findByItemId(placement.itemId);
      if (definition != null) {
        resources.add(
          ResourceNodeComponent(
            nodeId: placement.instanceId,
            resource: definition,
            position: Vector2(placement.x, placement.y),
          ),
        );
      }
    }
    if (map.lighting.mode == WorldMapLightingMode.outdoorCycle) {
      for (final prop in staticWorldRenderPlan.immutableProps) {
        for (final source in prop.definition.lightSources) {
          if (!source.switchable) continue;
          if (game.isPresentationLightSource(
            LightSourceStateKey(
              mapId: mapId,
              propId: prop.id,
              sourceId: source.id,
            ),
          )) {
            continue;
          }
          lightSwitches.add(
            LightSwitchComponent(mapId: mapId, prop: prop, source: source),
          );
        }
      }
    }
    final runtimeChildren = <Component>[
      player,
      ...npcs,
      ...resources,
      ...lightSwitches,
      ...game.storyInteractions.components(this),
      interactionTargeting,
      interactionPrompt,
      interactionHold,
      interactionProgress,
    ];
    _runtimeChildren.addAll(runtimeChildren);
    await addAll(runtimeChildren);
    for (final npc in npcs) {
      final directed = routinePlan.routineFor(npc.definition.id);
      if (directed != null) {
        _startDirectedRoutine(npc, directed, reconstruct: true);
      }
    }
    _runtimeDebugPoints = List.unmodifiable([
      RenderDebugPoint(
        kind: RenderDebugPointKind.player,
        id: player.playerId,
        root: player,
        projectedYOffsetY: () => player.presentation.currentOffsetY,
      ),
      for (final npc in npcs)
        RenderDebugPoint(
          kind: RenderDebugPointKind.npc,
          id: npc.objectId,
          root: npc,
          projectedYOffsetY: () => npc.presentation.currentOffsetY,
        ),
      for (final resource in resources)
        RenderDebugPoint(
          kind: RenderDebugPointKind.resource,
          id: resource.targetId,
          root: resource,
          projectedYOffsetY: () => resource.presentation.currentOffsetY,
        ),
      for (final lightSwitch in lightSwitches)
        RenderDebugPoint(
          kind: RenderDebugPointKind.prop,
          id: lightSwitch.targetId,
          root: lightSwitch,
          projectedYOffsetY: () => lightSwitch.presentation.currentOffsetY,
        ),
    ]);
    _refreshRenderDebugPoints();
  }

  void showFishingCastRipple(Vector2 renderedCenter) {
    add(
      FishingCastRippleComponent(
        position: renderedCenter,
        animation: game.visuals.waterRippleAnimation,
      ),
    );
  }

  void showItemTargeting() {
    final current = itemTargeting;
    if (current != null && !current.isRemoving) {
      return;
    }
    final map = game.mapFor(mapId);
    final component = RangedItemTargetingComponent(
      mapSize: Vector2(map.width, map.height),
    );
    itemTargeting = component;
    add(component);
  }

  void hideItemTargeting() {
    final current = itemTargeting;
    itemTargeting = null;
    current?.removeFromParent();
  }

  /// Mounts a newly dropped item without rebuilding unrelated runtime actors.
  void addWorldItemPlacement(WorldItemPlacement placement) {
    if (placement.mapId != mapId) {
      return;
    }
    final definition = game.contentCatalog.resources.findByItemId(
      placement.itemId,
    );
    if (definition == null) {
      return;
    }
    final component = ResourceNodeComponent(
      nodeId: placement.instanceId,
      resource: definition,
      position: Vector2(placement.x, placement.y),
    );
    _runtimeChildren.add(component);
    add(component);
    _runtimeDebugPoints = List.unmodifiable([
      ..._runtimeDebugPoints,
      RenderDebugPoint(
        kind: RenderDebugPointKind.resource,
        id: component.targetId,
        root: component,
        projectedYOffsetY: () => component.presentation.currentOffsetY,
      ),
    ]);
    _refreshRenderDebugPoints();
  }

  /// Applies assignment changes without persisting actor or route state.
  void applyRoutineDirectorPlan(
    NpcRoutineDirectorPlan plan, {
    bool reconstruct = false,
  }) {
    final npcIds = _npcComponentsById.keys.toList()..sort();
    if (reconstruct) {
      _reconstructRoutineDirectorPlan(plan, npcIds);
      return;
    }
    for (final npcId in npcIds) {
      final npc = _npcComponentsById[npcId]!;
      if (npc.isSceneLeased) continue;
      final directed = plan.routineFor(npcId);
      final previousRoutineId = _directedRoutineIdsByNpcId[npcId];
      if (directed?.routineId == previousRoutineId) {
        continue;
      }
      if (previousRoutineId != null) {
        npc.cancelRoutine();
        _directedRoutineIdsByNpcId.remove(npcId);
      }
      if (directed != null) {
        _startDirectedRoutine(npc, directed, reconstruct: false);
      }
    }
  }

  void _reconstructRoutineDirectorPlan(
    NpcRoutineDirectorPlan plan,
    List<String> npcIds,
  ) {
    final originsByNpcId = <String, ({String mapId, Vector2 point})>{};
    final anchorSource = WorldMapNpcRoutineAnchorSource.fromProject(
      game.mapProject,
    );

    for (final npcId in npcIds) {
      final npc = _npcComponentsById[npcId]!;
      npc.cancelRoutine();
      npc.occupancyRegistration.release();
      _directedRoutineIdsByNpcId.remove(npcId);
    }

    for (final npcId in npcIds) {
      final directed = plan.routineFor(npcId);
      if (directed == null) {
        continue;
      }
      final origin = _routineOrigin(
        npcId: npcId,
        directed: directed,
        anchorSource: anchorSource,
      );
      if (origin == null) {
        continue;
      }
      final npc = _npcComponentsById[npcId]!;
      npc.restoreRoutineOrigin(origin.point);
      originsByNpcId[npcId] = origin;
      if (origin.mapId == mapId) {
        npc.occupancyRegistration.registerCurrentPosition(
          NavigationPoint(x: origin.point.x, y: origin.point.y),
        );
      }
    }

    for (final npcId in npcIds) {
      final directed = plan.routineFor(npcId);
      final origin = originsByNpcId[npcId];
      if (directed == null || origin == null) {
        continue;
      }
      _startDirectedRoutine(
        _npcComponentsById[npcId]!,
        directed,
        reconstruct: true,
        initialMapId: origin.mapId,
      );
    }
  }

  ({String mapId, Vector2 point})? _routineOrigin({
    required String npcId,
    required DirectedNpcRoutine directed,
    required NpcRoutineAnchorSource anchorSource,
  }) {
    final placements = <({String mapId, NpcMapObject object})>[];
    final mapIds = game.mapProject.maps.keys.toList()..sort();
    for (final candidateMapId in mapIds) {
      final objects =
          game
              .mapFor(candidateMapId)
              .objects
              .whereType<NpcMapObject>()
              .where((object) => object.definitionId == npcId)
              .toList()
            ..sort((left, right) => left.id.compareTo(right.id));
      placements.addAll([
        for (final object in objects) (mapId: candidateMapId, object: object),
      ]);
    }
    if (placements.isNotEmpty) {
      final origin = placements.first;
      return (
        mapId: origin.mapId,
        point: Vector2(origin.object.x, origin.object.y),
      );
    }
    for (final step in directed.participantSteps.steps) {
      if (step case RoutineMoveStep(:final target)) {
        final anchor = anchorSource.resolve(target);
        if (anchor != null) {
          return (
            mapId: anchor.mapId,
            point: Vector2(anchor.point.x, anchor.point.y),
          );
        }
      }
    }
    return null;
  }

  void _startDirectedRoutine(
    NpcComponent npc,
    DirectedNpcRoutine directed, {
    required bool reconstruct,
    String? initialMapId,
  }) {
    npc.startRoutine(
      routineId: directed.routineId,
      participantSteps: directed.participantSteps,
      initialMapId: initialMapId,
    );
    _directedRoutineIdsByNpcId[npc.definition.id] = directed.routineId;
    if (reconstruct && directed.elapsedWindowSeconds > 0) {
      npc.advanceRoutine(directed.elapsedWindowSeconds);
    }
  }

  void _refreshRenderDebugPoints() {
    renderDebug.replacePoints([..._staticDebugPoints, ..._runtimeDebugPoints]);
  }

  @override
  void onRemove() {
    _disposeWorldResources();
    super.onRemove();
  }

  void _disposeWorldResources() {
    navigationOccupancy.clearMap(mapId);
    if (_hasStaticWorldRenderPlan) {
      staticWorldRenderPlan.dispose();
      _hasStaticWorldRenderPlan = false;
    }
  }
}
