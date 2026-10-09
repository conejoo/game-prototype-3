import 'navigation_path.dart';
import 'navigation_point.dart';

enum NavigationRouteFollowerState {
  idle,
  following,
  waiting,
  repathRequested,
  completed,
  failed,
  canceled,
}

enum NavigationRouteDirective {
  moveToWaypoint,
  wait,
  requestRepath,
  completed,
  failed,
  canceled,
}

enum NavigationRouteFailureReason { repathAttemptsExhausted }

/// Consumer-facing output from one deterministic route-follower transition.
final class NavigationRouteUpdate {
  const NavigationRouteUpdate.moveTo(this.target)
    : directive = NavigationRouteDirective.moveToWaypoint,
      waitedSeconds = 0,
      repathAttempt = 0,
      failureReason = null,
      noPathReason = null;

  const NavigationRouteUpdate.wait({
    required this.waitedSeconds,
    this.noPathReason,
  }) : directive = NavigationRouteDirective.wait,
       target = null,
       repathAttempt = 0,
       failureReason = null;

  const NavigationRouteUpdate.requestRepath(this.repathAttempt)
    : directive = NavigationRouteDirective.requestRepath,
      target = null,
      waitedSeconds = 0,
      failureReason = null,
      noPathReason = null;

  const NavigationRouteUpdate.completed()
    : directive = NavigationRouteDirective.completed,
      target = null,
      waitedSeconds = 0,
      repathAttempt = 0,
      failureReason = null,
      noPathReason = null;

  const NavigationRouteUpdate.failed({
    required this.failureReason,
    this.noPathReason,
  }) : directive = NavigationRouteDirective.failed,
       target = null,
       waitedSeconds = 0,
       repathAttempt = 0;

  const NavigationRouteUpdate.canceled()
    : directive = NavigationRouteDirective.canceled,
      target = null,
      waitedSeconds = 0,
      repathAttempt = 0,
      failureReason = null,
      noPathReason = null;

  final NavigationRouteDirective directive;
  final NavigationPoint? target;
  final double waitedSeconds;
  final int repathAttempt;
  final NavigationRouteFailureReason? failureReason;
  final NavigationNoPathReason? noPathReason;

  @override
  bool operator ==(Object other) =>
      other is NavigationRouteUpdate &&
      other.directive == directive &&
      other.target == target &&
      other.waitedSeconds == waitedSeconds &&
      other.repathAttempt == repathAttempt &&
      other.failureReason == failureReason &&
      other.noPathReason == noPathReason;

  @override
  int get hashCode => Object.hash(
    directive,
    target,
    waitedSeconds,
    repathAttempt,
    failureReason,
    noPathReason,
  );
}

/// Pure state machine for waypoint progress, temporary waits, and repath hooks.
///
/// Consumer owns position interpolation and chooses how to build a new request.
/// This class emits directives only; it never moves or teleports an actor.
final class NavigationRouteFollower {
  NavigationRouteFollower({
    required double waitTimeoutSeconds,
    required int maximumRepathAttempts,
  }) : waitTimeoutSeconds = _validatedTimeout(waitTimeoutSeconds),
       maximumRepathAttempts = _validatedAttemptLimit(maximumRepathAttempts);

  final double waitTimeoutSeconds;
  final int maximumRepathAttempts;

  NavigationRouteFollowerState _state = NavigationRouteFollowerState.idle;
  NavigationPath? _path;
  int _nextWaypointIndex = 0;
  double _waitedSeconds = 0;
  int _repathAttempts = 0;
  NavigationNoPathReason? _lastNoPathReason;

  NavigationRouteFollowerState get state => _state;
  NavigationPath? get path => _path;
  int get repathAttempts => _repathAttempts;
  NavigationNoPathReason? get lastNoPathReason => _lastNoPathReason;

  NavigationPoint? get nextWaypoint {
    final path = _path;
    return path == null || _nextWaypointIndex >= path.points.length
        ? null
        : path.points[_nextWaypointIndex];
  }

  NavigationRouteUpdate start(NavigationPath path) {
    _path = path;
    _nextWaypointIndex = 1;
    _waitedSeconds = 0;
    _repathAttempts = 0;
    _lastNoPathReason = null;
    if (path.points.length == 1) {
      _state = NavigationRouteFollowerState.completed;
      return const NavigationRouteUpdate.completed();
    }
    _state = NavigationRouteFollowerState.following;
    return NavigationRouteUpdate.moveTo(path.points[1]);
  }

  NavigationRouteUpdate markWaypointReached() {
    _requireState(NavigationRouteFollowerState.following);
    final path = _path!;
    _nextWaypointIndex++;
    if (_nextWaypointIndex >= path.points.length) {
      _state = NavigationRouteFollowerState.completed;
      return const NavigationRouteUpdate.completed();
    }
    return NavigationRouteUpdate.moveTo(path.points[_nextWaypointIndex]);
  }

  NavigationRouteUpdate reportBlocked(double elapsedSeconds) {
    if (_state != NavigationRouteFollowerState.following &&
        _state != NavigationRouteFollowerState.waiting) {
      throw StateError('Cannot report blockage while route state is $_state.');
    }
    _validateElapsed(elapsedSeconds);
    _state = NavigationRouteFollowerState.waiting;
    _waitedSeconds += elapsedSeconds;
    if (_waitedSeconds < waitTimeoutSeconds) {
      return NavigationRouteUpdate.wait(waitedSeconds: _waitedSeconds);
    }
    if (_repathAttempts >= maximumRepathAttempts) {
      _state = NavigationRouteFollowerState.failed;
      return NavigationRouteUpdate.failed(
        failureReason: NavigationRouteFailureReason.repathAttemptsExhausted,
        noPathReason: _lastNoPathReason,
      );
    }
    _waitedSeconds = 0;
    _repathAttempts++;
    _state = NavigationRouteFollowerState.repathRequested;
    return NavigationRouteUpdate.requestRepath(_repathAttempts);
  }

  NavigationRouteUpdate reportAvailable() {
    _requireState(NavigationRouteFollowerState.waiting);
    _state = NavigationRouteFollowerState.following;
    _waitedSeconds = 0;
    return NavigationRouteUpdate.moveTo(nextWaypoint!);
  }

  NavigationRouteUpdate applyRepathResult(NavigationPathResult result) {
    _requireState(NavigationRouteFollowerState.repathRequested);
    if (result is NavigationPathSuccess) {
      final currentPath = _path!;
      if (result.path.mapId != currentPath.mapId) {
        throw StateError(
          'Repath map ${result.path.mapId} does not match '
          '${currentPath.mapId}.',
        );
      }
      return start(result.path);
    }
    final noPath = result as NavigationNoPath;
    _lastNoPathReason = noPath.reason;
    if (_repathAttempts >= maximumRepathAttempts) {
      _state = NavigationRouteFollowerState.failed;
      return NavigationRouteUpdate.failed(
        failureReason: NavigationRouteFailureReason.repathAttemptsExhausted,
        noPathReason: noPath.reason,
      );
    }
    _state = NavigationRouteFollowerState.waiting;
    _waitedSeconds = 0;
    return NavigationRouteUpdate.wait(
      waitedSeconds: 0,
      noPathReason: noPath.reason,
    );
  }

  NavigationRouteUpdate cancel() {
    _state = NavigationRouteFollowerState.canceled;
    _path = null;
    _nextWaypointIndex = 0;
    _waitedSeconds = 0;
    return const NavigationRouteUpdate.canceled();
  }

  void _requireState(NavigationRouteFollowerState expected) {
    if (_state != expected) {
      throw StateError('Expected route state $expected, found $_state.');
    }
  }
}

double _validatedTimeout(double value) {
  if (!value.isFinite || value <= 0) {
    throw ArgumentError.value(
      value,
      'waitTimeoutSeconds',
      'must be finite and positive',
    );
  }
  return value;
}

int _validatedAttemptLimit(int value) {
  if (value <= 0) {
    throw ArgumentError.value(
      value,
      'maximumRepathAttempts',
      'must be positive',
    );
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
