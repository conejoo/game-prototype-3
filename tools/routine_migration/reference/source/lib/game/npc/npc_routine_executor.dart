import 'dart:math' as math;

import '../navigation/navigation.dart';
import '../routines/routine_model.dart';

enum NpcRoutineExecutionState {
  idle,
  moving,
  blocked,
  waiting,
  acting,
  speaking,
  completed,
  failed,
  canceled,
}

enum NpcRoutineFacing { south, north, west, east }

enum NpcRoutineFailureReason {
  initialOccupancyBlocked,
  noPath,
  noPortalRoute,
  repathAttemptsExhausted,
}

/// One resolved, map-authored routine destination.
final class NpcRoutineAnchor {
  NpcRoutineAnchor({
    required String mapId,
    required String anchorId,
    required this.point,
    this.facing,
  }) : mapId = _validatedIdentity(mapId, 'mapId'),
       anchorId = _validatedIdentity(anchorId, 'anchorId');

  final String mapId;
  final String anchorId;
  final NavigationPoint point;
  final NpcRoutineFacing? facing;
}

/// Resolves routine references without putting raw coordinates in routine data.
abstract interface class NpcRoutineAnchorSource {
  NpcRoutineAnchor? resolve(RoutineAnchorReference reference);
}

/// Shared loaded-map services injected into NPC presentation adapters.
final class NpcRoutineNavigationContext {
  NpcRoutineNavigationContext({
    required String mapId,
    required this.navigation,
    required this.portalRoutePlanner,
    required this.occupancy,
    required this.traversalPolicy,
    required this.anchorSource,
  }) : mapId = _validatedIdentity(mapId, 'mapId');

  final String mapId;
  final WorldNavigationService navigation;
  final NavigationMapRoutePlanner portalRoutePlanner;
  final NavigationOccupancyCoordinator occupancy;
  final NavigationTraversalPolicy traversalPolicy;
  final NpcRoutineAnchorSource anchorSource;
}

/// Immutable developer-only view of one participant's transient execution.
///
/// Contains stable IDs and bounded numeric/enum state only. Authored speech and
/// private NPC profile data are deliberately excluded.
final class NpcRoutineExecutionDiagnostics {
  factory NpcRoutineExecutionDiagnostics({
    required String routineId,
    required String participantId,
    required String currentMapId,
    required String? currentStepId,
    required NpcRoutineExecutionState executionState,
    required bool isPaused,
    required String? targetMapId,
    required String? targetAnchorId,
    required NavigationRouteFollowerState routeState,
    required int pathPointCount,
    required int repathAttempts,
    required NpcRoutineFailureReason? failureReason,
    required NavigationNoPathReason? noPathReason,
    required NavigationMapNoRouteReason? mapNoRouteReason,
    required String occupantId,
    required bool occupancyRegistered,
    required Iterable<String> occupancyBlockerIds,
  }) {
    final blockers = occupancyBlockerIds.toList()..sort();
    for (final (name, value) in [
      ('routineId', routineId),
      ('participantId', participantId),
      ('currentMapId', currentMapId),
      ('occupantId', occupantId),
      if (currentStepId != null) ('currentStepId', currentStepId),
      if (targetMapId != null) ('targetMapId', targetMapId),
      if (targetAnchorId != null) ('targetAnchorId', targetAnchorId),
      for (final blockerId in blockers) ('occupancyBlockerIds', blockerId),
    ]) {
      _validatedIdentity(value, name);
    }
    if ((targetMapId == null) != (targetAnchorId == null)) {
      throw ArgumentError(
        'targetMapId and targetAnchorId must both be present or absent.',
      );
    }
    if (pathPointCount < 0 || repathAttempts < 0) {
      throw ArgumentError(
        'Path point and repath attempt counts must be non-negative.',
      );
    }
    if (blockers.toSet().length != blockers.length) {
      throw ArgumentError.value(
        occupancyBlockerIds,
        'occupancyBlockerIds',
        'IDs must be unique.',
      );
    }
    return NpcRoutineExecutionDiagnostics._(
      routineId: routineId,
      participantId: participantId,
      currentMapId: currentMapId,
      currentStepId: currentStepId,
      executionState: executionState,
      isPaused: isPaused,
      targetMapId: targetMapId,
      targetAnchorId: targetAnchorId,
      routeState: routeState,
      pathPointCount: pathPointCount,
      repathAttempts: repathAttempts,
      failureReason: failureReason,
      noPathReason: noPathReason,
      mapNoRouteReason: mapNoRouteReason,
      occupantId: occupantId,
      occupancyRegistered: occupancyRegistered,
      occupancyBlockerIds: List.unmodifiable(blockers),
    );
  }

  const NpcRoutineExecutionDiagnostics._({
    required this.routineId,
    required this.participantId,
    required this.currentMapId,
    required this.currentStepId,
    required this.executionState,
    required this.isPaused,
    required this.targetMapId,
    required this.targetAnchorId,
    required this.routeState,
    required this.pathPointCount,
    required this.repathAttempts,
    required this.failureReason,
    required this.noPathReason,
    required this.mapNoRouteReason,
    required this.occupantId,
    required this.occupancyRegistered,
    required this.occupancyBlockerIds,
  });

  final String routineId;
  final String participantId;
  final String currentMapId;
  final String? currentStepId;
  final NpcRoutineExecutionState executionState;
  final bool isPaused;
  final String? targetMapId;
  final String? targetAnchorId;
  final NavigationRouteFollowerState routeState;
  final int pathPointCount;
  final int repathAttempts;
  final NpcRoutineFailureReason? failureReason;
  final NavigationNoPathReason? noPathReason;
  final NavigationMapNoRouteReason? mapNoRouteReason;
  final String occupantId;
  final bool occupancyRegistered;
  final List<String> occupancyBlockerIds;
}

/// Pure-Dart, single-participant consumer of authored routine steps.
///
/// Navigation search, route following, and occupancy remain delegated to the
/// generic navigation contracts. Flame presentation only mirrors this state.
final class NpcRoutineExecutor {
  static const _timerEpsilon = 1e-9;

  NpcRoutineExecutor({
    required String routineId,
    required String npcId,
    required String mapId,
    required NavigationPoint initialPosition,
    required RoutineParticipantSteps participantSteps,
    required this.traversalPolicy,
    required this.navigation,
    this.portalRoutePlanner,
    required this.occupancyRegistration,
    required this.anchorSource,
    required double movementSpeed,
    required double blockedWaitSeconds,
    required int maximumRepathAttempts,
    String? initialMapId,
    NpcRoutineFacing initialFacing = NpcRoutineFacing.south,
  }) : routineId = _validatedIdentity(routineId, 'routineId'),
       npcId = _validatedIdentity(npcId, 'npcId'),
       mapId = _validatedIdentity(mapId, 'mapId'),
       _currentMapId = _validatedIdentity(
         initialMapId ?? mapId,
         'initialMapId',
       ),
       _position = initialPosition,
       steps = List.unmodifiable(participantSteps.steps),
       movementSpeed = _validatedPositive(movementSpeed, 'movementSpeed'),
       _facing = initialFacing,
       routeFollower = NavigationRouteFollower(
         waitTimeoutSeconds: blockedWaitSeconds,
         maximumRepathAttempts: maximumRepathAttempts,
       ) {
    if (participantSteps.participantId != this.npcId) {
      throw ArgumentError.value(
        participantSteps.participantId,
        'participantSteps.participantId',
        'must match npcId ${this.npcId}',
      );
    }
    if (occupancyRegistration.mapId != this.mapId) {
      throw ArgumentError.value(
        occupancyRegistration.mapId,
        'occupancyRegistration.mapId',
        'must match mapId ${this.mapId}',
      );
    }
    if (steps.isEmpty) {
      throw ArgumentError.value(steps, 'participantSteps.steps', 'is empty');
    }
    for (final step in steps) {
      switch (step) {
        case RoutineMoveStep():
          break;
        case RoutineWaitStep():
          _validatedPositive(
            step.durationSeconds,
            '${step.id}.durationSeconds',
          );
        case RoutineActionStep():
          _validatedPositive(
            step.durationSeconds,
            '${step.id}.durationSeconds',
          );
        case RoutineSpeechStep():
          _validatedPositive(
            step.durationSeconds,
            '${step.id}.durationSeconds',
          );
      }
    }
  }

  final String routineId;
  final String npcId;
  final String mapId;
  final List<RoutineStep> steps;
  final NavigationTraversalPolicy traversalPolicy;
  final WorldNavigationService navigation;
  final NavigationMapRoutePlanner? portalRoutePlanner;
  final NavigationOccupancyRegistration occupancyRegistration;
  final NpcRoutineAnchorSource anchorSource;
  final double movementSpeed;
  final NavigationRouteFollower routeFollower;

  NpcRoutineExecutionState _state = NpcRoutineExecutionState.idle;
  NavigationPoint _position;
  String _currentMapId;
  NpcRoutineFacing _facing;
  int _stepIndex = -1;
  double _remainingStepSeconds = 0;
  NpcRoutineAnchor? _moveTarget;
  NavigationPoint? _activeMovePoint;
  NavigationMapRoute? _activePortalRoute;
  String? _activeActionId;
  String? _activeSpeechText;
  NpcRoutineFailureReason? _failureReason;
  NavigationNoPathReason? _noPathReason;
  NavigationMapNoRouteReason? _mapNoRouteReason;
  bool _isPaused = false;
  final List<String> _completedStepIds = [];
  final Map<String, NpcRoutineAnchor> _resolvedMoveTargets = {};

  NpcRoutineExecutionState get state => _state;
  NavigationPoint get position => _position;
  String get currentMapId => _currentMapId;
  bool get isOnLoadedMap => currentMapId == mapId;
  NpcRoutineFacing get facing => _facing;
  String? get currentStepId => _stepIndex >= 0 && _stepIndex < steps.length
      ? steps[_stepIndex].id
      : null;
  String? get activeActionId => _activeActionId;
  String? get activeSpeechText => _activeSpeechText;
  NpcRoutineFailureReason? get failureReason => _failureReason;
  NavigationNoPathReason? get noPathReason => _noPathReason;
  NavigationMapNoRouteReason? get mapNoRouteReason => _mapNoRouteReason;
  String get occupantId => occupancyRegistration.occupantId;
  NavigationAgentProfile get agentProfile => occupancyRegistration.agentProfile;
  bool get hasOccupancyReservation => occupancyRegistration.isRegistered;
  bool get isPaused => _isPaused;
  List<String> get completedStepIds => List.unmodifiable(_completedStepIds);

  NpcRoutineExecutionDiagnostics get diagnostics {
    final stepId = currentStepId;
    final target = stepId == null ? null : _resolvedMoveTargets[stepId];
    return NpcRoutineExecutionDiagnostics(
      routineId: routineId,
      participantId: npcId,
      currentMapId: currentMapId,
      currentStepId: stepId,
      executionState: state,
      isPaused: isPaused,
      targetMapId: target?.mapId,
      targetAnchorId: target?.anchorId,
      routeState: routeFollower.state,
      pathPointCount: routeFollower.path?.points.length ?? 0,
      repathAttempts: routeFollower.repathAttempts,
      failureReason: failureReason,
      noPathReason: noPathReason ?? routeFollower.lastNoPathReason,
      mapNoRouteReason: mapNoRouteReason,
      occupantId: occupantId,
      occupancyRegistered: hasOccupancyReservation,
      occupancyBlockerIds: [
        for (final blocker in occupancyRegistration.blockers) blocker.id,
      ],
    );
  }

  bool get isActive => switch (_state) {
    NpcRoutineExecutionState.moving ||
    NpcRoutineExecutionState.blocked ||
    NpcRoutineExecutionState.waiting ||
    NpcRoutineExecutionState.acting ||
    NpcRoutineExecutionState.speaking => true,
    NpcRoutineExecutionState.idle ||
    NpcRoutineExecutionState.completed ||
    NpcRoutineExecutionState.failed ||
    NpcRoutineExecutionState.canceled => false,
  };

  NpcRoutineExecutionState start() {
    if (_state != NpcRoutineExecutionState.idle) {
      throw StateError('Routine $routineId has already started.');
    }
    _resolveMoveTargets();
    if (isOnLoadedMap) {
      final currentReservation = occupancyRegistration.reservation;
      final decision = currentReservation?.center == position
          ? null
          : occupancyRegistration.tryOccupy(position);
      if (decision != null && !decision.isReserved) {
        _state = NpcRoutineExecutionState.failed;
        _failureReason = NpcRoutineFailureReason.initialOccupancyBlocked;
        return _state;
      }
    } else {
      occupancyRegistration.release();
    }
    _stepIndex = 0;
    _beginCurrentStep();
    return _state;
  }

  void update(double elapsedSeconds) {
    _validateElapsed(elapsedSeconds);
    if (!isActive || _isPaused) {
      return;
    }
    var remaining = elapsedSeconds;
    var transitionBudget = steps.length + 1024;
    while (isActive && transitionBudget-- > 0) {
      final previousState = _state;
      final previousStepIndex = _stepIndex;
      final previousPosition = position;
      final consumed = switch (_state) {
        NpcRoutineExecutionState.moving ||
        NpcRoutineExecutionState.blocked => _advanceMove(remaining),
        NpcRoutineExecutionState.waiting ||
        NpcRoutineExecutionState.acting ||
        NpcRoutineExecutionState.speaking => _advanceTimedStep(remaining),
        NpcRoutineExecutionState.idle ||
        NpcRoutineExecutionState.completed ||
        NpcRoutineExecutionState.failed ||
        NpcRoutineExecutionState.canceled => 0.0,
      };
      remaining = math.max(0, remaining - consumed);
      final madeZeroTimeProgress =
          previousState != _state ||
          previousStepIndex != _stepIndex ||
          previousPosition != position;
      if (remaining == 0 && !madeZeroTimeProgress ||
          consumed == 0 && !madeZeroTimeProgress) {
        return;
      }
    }
    if (transitionBudget <= 0) {
      throw StateError(
        'Routine $routineId exceeded one update transition bound.',
      );
    }
  }

  bool cancel() {
    if (!isActive && _state != NpcRoutineExecutionState.idle) {
      return false;
    }
    routeFollower.cancel();
    _activeActionId = null;
    _activeSpeechText = null;
    _moveTarget = null;
    _activeMovePoint = null;
    _activePortalRoute = null;
    _remainingStepSeconds = 0;
    _isPaused = false;
    _state = NpcRoutineExecutionState.canceled;
    return true;
  }

  /// Freezes current transient work without changing step or route progress.
  bool pause() {
    if (!isActive || _isPaused) {
      return false;
    }
    _isPaused = true;
    return true;
  }

  bool resume() {
    if (!_isPaused || !isActive) {
      return false;
    }
    _isPaused = false;
    return true;
  }

  /// Restarts one authored step while a routine dialogue owns the pause.
  bool jumpToStep(String stepId) {
    if (!_isPaused || !isActive) {
      return false;
    }
    final targetIndex = steps.indexWhere((step) => step.id == stepId);
    if (targetIndex < 0) {
      return false;
    }
    routeFollower.cancel();
    _activeActionId = null;
    _activeSpeechText = null;
    _moveTarget = null;
    _activeMovePoint = null;
    _activePortalRoute = null;
    _remainingStepSeconds = 0;
    _stepIndex = targetIndex;
    _beginCurrentStep();
    return true;
  }

  void _resolveMoveTargets() {
    for (final step in steps.whereType<RoutineMoveStep>()) {
      final target = anchorSource.resolve(step.target);
      if (target == null ||
          target.mapId != step.target.mapId ||
          target.anchorId != step.target.anchorId) {
        throw StateError(
          'Routine $routineId step ${step.id} cannot resolve '
          '${step.target.mapId}/${step.target.anchorId}.',
        );
      }
      _resolvedMoveTargets[step.id] = target;
    }
  }

  void _beginCurrentStep() {
    if (_stepIndex >= steps.length) {
      _state = NpcRoutineExecutionState.completed;
      _isPaused = false;
      return;
    }
    final step = steps[_stepIndex];
    switch (step) {
      case RoutineMoveStep():
        _moveTarget = _resolvedMoveTargets[step.id]!;
        _startMoveToTarget();
      case RoutineWaitStep():
        _remainingStepSeconds = step.durationSeconds;
        _state = NpcRoutineExecutionState.waiting;
      case RoutineActionStep():
        _remainingStepSeconds = step.durationSeconds;
        _activeActionId = step.actionId;
        _state = NpcRoutineExecutionState.acting;
      case RoutineSpeechStep():
        _remainingStepSeconds = step.durationSeconds;
        _activeSpeechText = step.text;
        _state = NpcRoutineExecutionState.speaking;
    }
  }

  void _startMoveToTarget() {
    final target = _moveTarget!;
    if (target.mapId == currentMapId) {
      if (!isOnLoadedMap) {
        _snapToMoveTarget();
        return;
      }
      _activeMovePoint = target.point;
      _startPathToActiveMovePoint();
      return;
    }

    final result = portalRoutePlanner?.plan(
      NavigationMapRouteRequest(
        sourceMapId: currentMapId,
        sourcePoint: position,
        destinationMapId: target.mapId,
        destinationPoint: target.point,
        agentProfile: agentProfile,
        traversalPolicy: traversalPolicy,
      ),
    );
    if (result is! NavigationMapRouteSuccess) {
      _fail(
        NpcRoutineFailureReason.noPortalRoute,
        mapNoRouteReason: result is NavigationMapNoRoute
            ? result.reason
            : NavigationMapNoRouteReason.disconnectedMaps,
      );
      return;
    }
    if (!isOnLoadedMap) {
      _snapToMoveTarget();
      return;
    }
    _activePortalRoute = result.route;
    _activeMovePoint = result.route.legs.first.path.points.last;
    _startPathToActiveMovePoint();
  }

  void _startPathToActiveMovePoint() {
    final request = _pathRequest();
    final result = navigation.findPath(request);
    if (result is NavigationNoPath) {
      final staticResult = request.dynamicBlockers.isEmpty
          ? result
          : navigation.findPath(_pathRequest(includeDynamicBlockers: false));
      if (staticResult is! NavigationPathSuccess) {
        _fail(NpcRoutineFailureReason.noPath, noPathReason: result.reason);
        return;
      }
      routeFollower.start(staticResult.path);
      _state = NpcRoutineExecutionState.moving;
      return;
    }
    routeFollower.start((result as NavigationPathSuccess).path);
    if (routeFollower.state == NavigationRouteFollowerState.completed) {
      _position = _activeMovePoint!;
      _finishActiveMovePoint();
      return;
    }
    _state = NpcRoutineExecutionState.moving;
  }

  double _advanceMove(double availableSeconds) {
    if (availableSeconds == 0) {
      return 0;
    }
    final target = routeFollower.nextWaypoint!;
    final deltaX = target.x - position.x;
    final deltaY = target.y - position.y;
    final distance = math.sqrt(deltaX * deltaX + deltaY * deltaY);
    if (distance == 0) {
      _markWaypointReached();
      return 0;
    }
    final travelDistance = math.min(distance, movementSpeed * availableSeconds);
    final fraction = travelDistance / distance;
    final proposed = travelDistance == distance
        ? target
        : NavigationPoint(
            x: position.x + deltaX * fraction,
            y: position.y + deltaY * fraction,
          );
    if (!_tryReserve(proposed)) {
      _handleBlocked(availableSeconds);
      return availableSeconds;
    }
    if (_state == NpcRoutineExecutionState.blocked) {
      routeFollower.reportAvailable();
      _state = NpcRoutineExecutionState.moving;
    }
    _position = proposed;
    _facing = _facingForDelta(deltaX, deltaY);
    if (proposed == target) {
      _markWaypointReached();
    }
    return travelDistance / movementSpeed;
  }

  void _markWaypointReached() {
    final update = routeFollower.markWaypointReached();
    if (update.directive != NavigationRouteDirective.completed) {
      return;
    }
    _position = _activeMovePoint!;
    _finishActiveMovePoint();
  }

  void _finishActiveMovePoint() {
    if (_activePortalRoute != null) {
      occupancyRegistration.release();
      _currentMapId = _moveTarget!.mapId;
      _position = _moveTarget!.point;
      _activePortalRoute = null;
    }
    _facing = _moveTarget!.facing ?? _facing;
    _completeCurrentStep();
  }

  void _snapToMoveTarget() {
    occupancyRegistration.release();
    _currentMapId = _moveTarget!.mapId;
    _position = _moveTarget!.point;
    if (isOnLoadedMap) {
      occupancyRegistration.registerCurrentPosition(position);
    }
    _facing = _moveTarget!.facing ?? _facing;
    _completeCurrentStep();
  }

  void _handleBlocked(double elapsedSeconds) {
    final update = routeFollower.reportBlocked(elapsedSeconds);
    _state = NpcRoutineExecutionState.blocked;
    if (update.directive != NavigationRouteDirective.requestRepath) {
      return;
    }
    final repath = navigation.findPath(_pathRequest());
    final applied = routeFollower.applyRepathResult(repath);
    switch (applied.directive) {
      case NavigationRouteDirective.moveToWaypoint:
        _state = NpcRoutineExecutionState.moving;
      case NavigationRouteDirective.wait:
        _state = NpcRoutineExecutionState.blocked;
      case NavigationRouteDirective.failed:
        _fail(
          NpcRoutineFailureReason.repathAttemptsExhausted,
          noPathReason: applied.noPathReason,
        );
      case NavigationRouteDirective.requestRepath ||
          NavigationRouteDirective.completed ||
          NavigationRouteDirective.canceled:
        throw StateError('Unexpected repath directive ${applied.directive}.');
    }
  }

  NavigationPathRequest _pathRequest({bool includeDynamicBlockers = true}) =>
      NavigationPathRequest(
        mapId: currentMapId,
        start: position,
        goal: _activeMovePoint!,
        agentProfile: agentProfile,
        traversalPolicy: traversalPolicy,
        dynamicBlockers: includeDynamicBlockers
            ? occupancyRegistration.blockers
            : const [],
      );

  bool _tryReserve(NavigationPoint point) {
    return occupancyRegistration.tryOccupy(point).isReserved;
  }

  double _advanceTimedStep(double availableSeconds) {
    if (availableSeconds == 0) {
      return 0;
    }
    final consumed = math.min(availableSeconds, _remainingStepSeconds);
    _remainingStepSeconds -= consumed;
    if (_remainingStepSeconds <= _timerEpsilon) {
      _remainingStepSeconds = 0;
      _completeCurrentStep();
    }
    return consumed;
  }

  void _completeCurrentStep() {
    _completedStepIds.add(steps[_stepIndex].id);
    _activeActionId = null;
    _activeSpeechText = null;
    _moveTarget = null;
    _activeMovePoint = null;
    _activePortalRoute = null;
    _remainingStepSeconds = 0;
    _stepIndex++;
    _beginCurrentStep();
  }

  void _fail(
    NpcRoutineFailureReason reason, {
    NavigationNoPathReason? noPathReason,
    NavigationMapNoRouteReason? mapNoRouteReason,
  }) {
    _failureReason = reason;
    _noPathReason = noPathReason;
    _mapNoRouteReason = mapNoRouteReason;
    _activeActionId = null;
    _activeSpeechText = null;
    _moveTarget = null;
    _activeMovePoint = null;
    _activePortalRoute = null;
    _remainingStepSeconds = 0;
    _isPaused = false;
    _state = NpcRoutineExecutionState.failed;
  }
}

NpcRoutineFacing _facingForDelta(double deltaX, double deltaY) {
  if (deltaY.abs() >= deltaX.abs()) {
    return deltaY >= 0 ? NpcRoutineFacing.south : NpcRoutineFacing.north;
  }
  return deltaX >= 0 ? NpcRoutineFacing.east : NpcRoutineFacing.west;
}

String _validatedIdentity(String value, String name) {
  if (value.isEmpty || value.trim() != value) {
    throw ArgumentError.value(
      value,
      name,
      'must be non-empty with no surrounding whitespace',
    );
  }
  return value;
}

double _validatedPositive(double value, String name) {
  if (!value.isFinite || value <= 0) {
    throw ArgumentError.value(value, name, 'must be finite and positive');
  }
  return value;
}

void _validateElapsed(double value) {
  if (!value.isFinite || value < 0) {
    throw ArgumentError.value(
      value,
      'elapsedSeconds',
      'must be finite and non-negative',
    );
  }
}
