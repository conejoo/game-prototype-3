import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

import '../interaction/world_interactable_component.dart';
import '../navigation/navigation.dart';
import '../routines/routine_model.dart';
import '../visuals/visual_asset_catalog.dart';
import '../visuals/world_render_depth.dart';
import '../world/world_render_priority.dart';
import 'npc_definition.dart';
import 'npc_routine_executor.dart';

/// One friendly villager using shared world interaction targeting.
class NpcComponent extends WorldInteractableComponent with HasVisibility {
  NpcComponent({
    required this.objectId,
    required this.definition,
    required this.routineNavigation,
    required Vector2 position,
    String? initialMapId,
  }) : initialMapId = initialMapId ?? routineNavigation.mapId,
       super(
         targetId: objectId,
         interactionRadius: definition.interactionRadius,
         promptText: definition.interactionPrompt,
         holdDuration: Duration.zero,
         position: position,
         size: Vector2(definition.hitWidth, definition.hitHeight),
         visualSize: Vector2(definition.displayWidth, definition.displayHeight),
         visualFootPosition: Vector2(
           definition.hitWidth / 2,
           definition.hitHeight,
         ),
         priority: WorldRenderPriority.depthRankStart,
         renderLayer: WorldRenderLayer.actor,
         renderStableId: WorldRenderStableId(
           namespace: 'actor',
           value: 'npc:$objectId',
         ),
       ) {
    final routineDefinition = definition.package?.runtime.routine;
    if (routineDefinition == null) {
      throw StateError('NPC ${definition.id} has no routine definition.');
    }
    occupancyRegistration = NavigationOccupancyRegistration(
      coordinator: routineNavigation.occupancy,
      occupantId: 'npc:$objectId',
      mapId: routineNavigation.mapId,
      agentProfile: routineDefinition.agentProfile,
    );
    isVisible = this.initialMapId == routineNavigation.mapId;
    isInteractionEligible = isVisible;
  }

  final String objectId;
  final NpcDefinition definition;
  final NpcRoutineNavigationContext routineNavigation;
  final String initialMapId;
  late final NavigationOccupancyRegistration occupancyRegistration;

  static const routineMovementSpeed = 64.0;
  static const routineBlockedWaitSeconds = 0.5;
  static const routineMaximumRepathAttempts = 2;

  late final SpriteAnimationComponent animationComponent;
  NpcRoutineExecutor? _routineExecutor;
  NpcRoutineSpeechComponent? _speechComponent;
  NpcFacing _facing = NpcFacing.south;
  var _isWalking = false;

  bool _sceneLeased = false;
  bool get isSceneLeased => _sceneLeased;

  NpcRoutineExecutor? get routineExecutor => _routineExecutor;
  NpcRoutineExecutionState? get routineState => _routineExecutor?.state;
  NpcFacing get facing => _facing;
  bool get isWalking => _isWalking;
  NpcRoutineSpeechComponent? get speechComponent => _speechComponent;
  bool get isRoutineVisible => isVisible;

  @override
  void onMount() {
    super.onMount();
    if (initialMapId == routineNavigation.mapId) {
      occupancyRegistration.registerCurrentPosition(
        NavigationPoint(x: position.x, y: position.y),
      );
    }
  }

  @override
  void onLoad() {
    super.onLoad();
    final visualAssets = game.visuals.npcVisualsById[definition.id];
    if (visualAssets == null) {
      throw StateError('NPC ${definition.id} has no loaded visual manifest.');
    }
    animationComponent = SpriteAnimationComponent(
      animation: visualAssets.animationFor(facing: _facing),
      size: visualSize,
      position: Vector2(visualSize.x / 2, visualSize.y),
      anchor: Anchor.bottomCenter,
      paint: game.visuals.worldArtPaint,
    );
    presentation.add(animationComponent);
  }

  NpcRoutineExecutionState startRoutine({
    required String routineId,
    required RoutineParticipantSteps participantSteps,
    double movementSpeed = routineMovementSpeed,
    double blockedWaitSeconds = routineBlockedWaitSeconds,
    int maximumRepathAttempts = routineMaximumRepathAttempts,
    String? initialMapId,
  }) {
    if (!isLoaded) {
      throw StateError('NpcComponent must load before starting a routine.');
    }
    final executorInitialMapId =
        initialMapId ?? _routineExecutor?.currentMapId ?? this.initialMapId;
    _routineExecutor?.cancel();
    _removeSpeech();
    final executor = NpcRoutineExecutor(
      routineId: routineId,
      npcId: definition.id,
      mapId: routineNavigation.mapId,
      initialPosition: NavigationPoint(x: position.x, y: position.y),
      participantSteps: participantSteps,
      traversalPolicy: routineNavigation.traversalPolicy,
      navigation: routineNavigation.navigation,
      portalRoutePlanner: routineNavigation.portalRoutePlanner,
      occupancyRegistration: occupancyRegistration,
      anchorSource: routineNavigation.anchorSource,
      movementSpeed: movementSpeed,
      blockedWaitSeconds: blockedWaitSeconds,
      maximumRepathAttempts: maximumRepathAttempts,
      initialMapId: executorInitialMapId,
      initialFacing: _facing.toRoutineFacing(),
    );
    _routineExecutor = executor;
    final state = executor.start();
    _syncRoutinePresentation();
    return state;
  }

  /// Resets transient presentation before deterministic routine reconstruction.
  void restoreRoutineOrigin(Vector2 origin) {
    if (!isLoaded) {
      throw StateError('NpcComponent must load before restoring a routine.');
    }
    position.setFrom(origin);
    _facing = NpcFacing.south;
    presentation.resyncFromLogicalPosition(position);
    if (isMounted) {
      markProjectedDepthDirty();
    }
  }

  bool cancelRoutine() {
    final canceled = _routineExecutor?.cancel() ?? false;
    if (canceled) {
      _syncRoutinePresentation();
    }
    return canceled;
  }

  bool pauseRoutine() {
    final paused = _routineExecutor?.pause() ?? false;
    if (paused) {
      _syncRoutinePresentation();
    }
    return paused;
  }

  bool resumeRoutine() {
    final resumed = _routineExecutor?.resume() ?? false;
    if (resumed) {
      _syncRoutinePresentation();
    }
    return resumed;
  }

  bool jumpRoutineToStep(String stepId) {
    final jumped = _routineExecutor?.jumpToStep(stepId) ?? false;
    if (jumped) {
      _syncRoutinePresentation();
    }
    return jumped;
  }

  @override
  void update(double dt) {
    super.update(dt);
    advanceRoutine(dt);
  }

  /// Advances transient execution, including deterministic offscreen catch-up.
  NpcRoutineExecutionState? advanceRoutine(double elapsedSeconds) {
    final executor = _routineExecutor;
    if (_sceneLeased || executor == null || !executor.isActive) {
      return executor?.state;
    }
    final previousX = position.x;
    final previousY = position.y;
    executor.update(elapsedSeconds);
    position.setValues(executor.position.x, executor.position.y);
    if (position.x != previousX || position.y != previousY) {
      presentation.resyncFromLogicalPosition(position);
      if (isMounted) {
        markProjectedDepthDirty();
      }
    }
    _syncRoutinePresentation();
    return executor.state;
  }

  void _syncRoutinePresentation() {
    final executor = _routineExecutor;
    if (executor == null) {
      return;
    }
    _facing = executor.facing.toNpcFacing();
    isVisible = executor.isOnLoadedMap;
    isInteractionEligible = isVisible;
    if (!isVisible) {
      _isWalking = false;
      animationComponent.playing = false;
      _removeSpeech();
      return;
    }
    _isWalking = executor.state == NpcRoutineExecutionState.moving;
    animationComponent.playing = !executor.isPaused;
    final visuals = game.visuals.npcVisualsById[definition.id];
    if (visuals != null) {
      animationComponent.animation = _isWalking
          ? visuals.walkAnimations[_facing]!
          : visuals.animationFor(
              facing: _facing,
              actionId: executor.activeActionId,
            );
    }
    final speechText = executor.activeSpeechText;
    if (speechText == null) {
      _removeSpeech();
    } else if (_speechComponent?.text != speechText) {
      _removeSpeech();
      final speech = NpcRoutineSpeechComponent(
        text: speechText,
        visualWidth: visualSize.x,
      );
      _speechComponent = speech;
      presentation.add(speech);
    }
  }

  void _removeSpeech() {
    _speechComponent?.removeFromParent();
    _speechComponent = null;
  }

  /// Preserve the actual executor, including its prior pause state. The lease
  /// never substitutes a coordinate move for routine-authored navigation.
  void Function() acquireSceneLease() {
    if (_sceneLeased) throw StateError('Actor already reserved by a scene.');
    final oldPosition = position.clone();
    final oldFacing = _facing;
    final visible = isVisible;
    final eligible = isInteractionEligible;
    final reservation = occupancyRegistration.reservation;
    final pausedHere = pauseRoutine();
    _sceneLeased = true;
    _removeSpeech();
    var released = false;
    return () {
      if (released) return;
      released = true;
      _sceneLeased = false;
      position.setFrom(oldPosition);
      _facing = oldFacing;
      presentation.resyncFromLogicalPosition(position);
      occupancyRegistration.release();
      if (reservation != null) {
        occupancyRegistration.registerCurrentPosition(reservation.center);
      }
      if (pausedHere) resumeRoutine();
      _syncRoutinePresentation();
      if (_routineExecutor == null) {
        animationComponent.animation = game
            .visuals
            .npcVisualsById[definition.id]!
            .animationFor(facing: oldFacing);
      }
      isVisible = visible;
      isInteractionEligible = eligible;
      if (isMounted) markProjectedDepthDirty();
    };
  }

  void showAtSceneFoot(Vector2? foot, {NpcFacing facing = NpcFacing.south}) {
    if (!_sceneLeased) throw StateError('Scene must acquire actor first.');
    occupancyRegistration.release();
    isVisible = foot != null;
    isInteractionEligible = false;
    _isWalking = false;
    if (foot == null) return;
    position.setFrom(foot);
    _facing = facing;
    presentation.resyncFromLogicalPosition(position);
    animationComponent.animation = game.visuals.npcVisualsById[definition.id]!
        .animationFor(facing: facing);
    animationComponent.playing = true;
    occupancyRegistration.registerCurrentPosition(
      NavigationPoint(x: foot.x, y: foot.y),
    );
    if (isMounted) markProjectedDepthDirty();
  }

  @override
  void onInteractionComplete() {
    game.openDialogueForNpc(definition.id);
  }

  @override
  void onRemove() {
    _routineExecutor?.cancel();
    occupancyRegistration.release();
    _removeSpeech();
    super.onRemove();
  }
}

/// Short world-space routine speech owned by its NPC presentation.
class NpcRoutineSpeechComponent extends TextComponent<TextPaint> {
  NpcRoutineSpeechComponent({required String text, required double visualWidth})
    : super(
        text: text,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFFF8EE),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: Color(0xCC000000), blurRadius: 2)],
          ),
        ),
        position: Vector2(visualWidth / 2, -6),
        anchor: Anchor.bottomCenter,
        priority: 2,
      );
}

extension on NpcFacing {
  NpcRoutineFacing toRoutineFacing() => switch (this) {
    NpcFacing.south => NpcRoutineFacing.south,
    NpcFacing.north => NpcRoutineFacing.north,
    NpcFacing.west => NpcRoutineFacing.west,
    NpcFacing.east => NpcRoutineFacing.east,
  };
}

extension on NpcRoutineFacing {
  NpcFacing toNpcFacing() => switch (this) {
    NpcRoutineFacing.south => NpcFacing.south,
    NpcRoutineFacing.north => NpcFacing.north,
    NpcRoutineFacing.west => NpcFacing.west,
    NpcRoutineFacing.east => NpcFacing.east,
  };
}
