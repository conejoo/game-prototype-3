import 'package:cozy_life_adventure/game/navigation/navigation.dart';
import 'package:cozy_life_adventure/game/npc/npc_routine_executor.dart';
import 'package:cozy_life_adventure/game/routines/routine_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NpcRoutineExecutor', () {
    test('executes move, wait, action, and speech in authored order', () {
      final profile = NavigationAgentProfile(
        id: 'town-adult',
        footprintRadius: 2,
      );
      const policy = _GroundPolicy();
      final navigation = _RecordingNavigationService(_directPath);
      final occupancy = NavigationOccupancyCoordinator();
      final registration = _registration(occupancy, profile: profile);
      final executor = NpcRoutineExecutor(
        routineId: 'fixture-morning',
        npcId: 'actor-01',
        mapId: 'town',
        initialPosition: NavigationPoint(x: 0, y: 0),
        participantSteps: _fullPlan(),
        traversalPolicy: policy,
        navigation: navigation,
        occupancyRegistration: registration,
        anchorSource: _AnchorSource({
          'town/market': NpcRoutineAnchor(
            mapId: 'town',
            anchorId: 'market',
            point: NavigationPoint(x: 10, y: 0),
            facing: NpcRoutineFacing.north,
          ),
        }),
        movementSpeed: 10,
        blockedWaitSeconds: 0.5,
        maximumRepathAttempts: 2,
      );

      expect(executor.start(), NpcRoutineExecutionState.moving);
      expect(executor.hasOccupancyReservation, isTrue);
      expect(navigation.requests, hasLength(1));
      expect(navigation.requests.single.agentProfile, same(profile));
      expect(navigation.requests.single.traversalPolicy, same(policy));
      expect(navigation.requests.single.dynamicBlockers, isEmpty);
      final movingDiagnostics = executor.diagnostics;
      expect(movingDiagnostics.routineId, 'fixture-morning');
      expect(movingDiagnostics.participantId, 'actor-01');
      expect(movingDiagnostics.currentStepId, 'move-to-market');
      expect(movingDiagnostics.targetMapId, 'town');
      expect(movingDiagnostics.targetAnchorId, 'market');
      expect(
        movingDiagnostics.routeState,
        NavigationRouteFollowerState.following,
      );
      expect(movingDiagnostics.pathPointCount, 2);
      expect(movingDiagnostics.repathAttempts, 0);
      expect(movingDiagnostics.occupancyRegistered, isTrue);
      expect(movingDiagnostics.occupantId, 'placement-01');
      expect(movingDiagnostics.occupancyBlockerIds, isEmpty);

      executor.update(1);
      expect(executor.position, NavigationPoint(x: 10, y: 0));
      expect(executor.facing, NpcRoutineFacing.north);
      expect(executor.completedStepIds, ['move-to-market']);
      expect(executor.state, NpcRoutineExecutionState.waiting);

      executor.update(0.5);
      expect(executor.completedStepIds, ['move-to-market', 'wait-at-market']);
      expect(executor.state, NpcRoutineExecutionState.acting);
      expect(executor.activeActionId, 'fixture-action');

      executor.update(0.5);
      expect(executor.state, NpcRoutineExecutionState.speaking);
      expect(executor.activeActionId, isNull);
      expect(executor.activeSpeechText, 'Fresh bread this morning.');

      executor.update(0.49);
      expect(executor.state, NpcRoutineExecutionState.speaking);
      executor.update(0.01);

      expect(executor.state, NpcRoutineExecutionState.completed);
      expect(executor.activeSpeechText, isNull);
      expect(executor.completedStepIds, [
        'move-to-market',
        'wait-at-market',
        'market-action',
        'market-speech',
      ]);
      expect(executor.hasOccupancyReservation, isTrue);
      expect(occupancy.reservations.single.occupantId, 'placement-01');
      expect(registration.release(), isTrue);
      expect(occupancy.reservations, isEmpty);
    });

    test('waits, repaths, and fails in place after no-path exhaustion', () {
      var searchCount = 0;
      final navigation = _RecordingNavigationService((request) {
        searchCount++;
        return switch (searchCount) {
          1 => _directPath(request),
          2 => const NavigationNoPath(NavigationNoPathReason.unreachable),
          _ => const NavigationNoPath(NavigationNoPathReason.goalBlocked),
        };
      });
      final occupancy = NavigationOccupancyCoordinator();
      final profile = NavigationAgentProfile(
        id: 'town-adult',
        footprintRadius: 1,
      );
      final registration = _registration(occupancy, profile: profile);
      final executor = NpcRoutineExecutor(
        routineId: 'fixture-blocked',
        npcId: 'actor-01',
        mapId: 'town',
        initialPosition: NavigationPoint(x: 0, y: 0),
        participantSteps: RoutineParticipantSteps(
          participantId: 'actor-01',
          steps: const [
            RoutineMoveStep(
              id: 'move-to-market',
              target: RoutineAnchorReference(mapId: 'town', anchorId: 'market'),
            ),
          ],
        ),
        traversalPolicy: const _GroundPolicy(),
        navigation: navigation,
        occupancyRegistration: registration,
        anchorSource: _AnchorSource({
          'town/market': NpcRoutineAnchor(
            mapId: 'town',
            anchorId: 'market',
            point: NavigationPoint(x: 10, y: 0),
          ),
        }),
        movementSpeed: 20,
        blockedWaitSeconds: 0.5,
        maximumRepathAttempts: 2,
      );
      executor.start();
      occupancy.reserveAll([
        NavigationOccupancyReservation(
          occupantId: 'blocker-01',
          mapId: 'town',
          center: NavigationPoint(x: 10, y: 0),
          agentProfile: profile,
        ),
      ]);

      executor.update(0.5);
      expect(executor.state, NpcRoutineExecutionState.blocked);
      expect(executor.position, NavigationPoint(x: 0, y: 0));
      expect(executor.routeFollower.repathAttempts, 1);
      expect(navigation.requests[1].dynamicBlockers.single.id, 'blocker-01');

      executor.update(0.5);

      expect(executor.state, NpcRoutineExecutionState.failed);
      expect(
        executor.failureReason,
        NpcRoutineFailureReason.repathAttemptsExhausted,
      );
      expect(executor.noPathReason, NavigationNoPathReason.goalBlocked);
      expect(executor.position, NavigationPoint(x: 0, y: 0));
      expect(executor.completedStepIds, isEmpty);
      expect(executor.hasOccupancyReservation, isTrue);
      expect(
        occupancy.reservations.map((reservation) => reservation.occupantId),
        ['blocker-01', 'placement-01'],
      );
      final failedDiagnostics = executor.diagnostics;
      expect(failedDiagnostics.currentStepId, 'move-to-market');
      expect(failedDiagnostics.targetMapId, 'town');
      expect(failedDiagnostics.targetAnchorId, 'market');
      expect(failedDiagnostics.executionState, NpcRoutineExecutionState.failed);
      expect(failedDiagnostics.routeState, NavigationRouteFollowerState.failed);
      expect(failedDiagnostics.repathAttempts, 2);
      expect(
        failedDiagnostics.failureReason,
        NpcRoutineFailureReason.repathAttemptsExhausted,
      );
      expect(
        failedDiagnostics.noPathReason,
        NavigationNoPathReason.goalBlocked,
      );
      expect(failedDiagnostics.occupancyBlockerIds, ['blocker-01']);
      expect(registration.release(), isTrue);
    });

    test('waits at a live blocked goal and resumes after release', () {
      final occupancy = NavigationOccupancyCoordinator();
      final profile = NavigationAgentProfile(
        id: 'town-adult',
        footprintRadius: 1,
      );
      final registration = _registration(occupancy, profile: profile);
      final blocker = NavigationOccupancyRegistration(
        coordinator: occupancy,
        occupantId: 'blocker-01',
        mapId: 'town',
        agentProfile: profile,
      );
      blocker.tryOccupy(NavigationPoint(x: 10, y: 0));
      final navigation = _RecordingNavigationService((request) {
        if (request.dynamicBlockers.isNotEmpty) {
          return const NavigationNoPath(NavigationNoPathReason.goalBlocked);
        }
        return _directPath(request);
      });
      final executor = NpcRoutineExecutor(
        routineId: 'fixture-live-goal-blocker',
        npcId: 'actor-01',
        mapId: 'town',
        initialPosition: NavigationPoint(x: 0, y: 0),
        participantSteps: RoutineParticipantSteps(
          participantId: 'actor-01',
          steps: const [
            RoutineMoveStep(
              id: 'move-to-market',
              target: RoutineAnchorReference(mapId: 'town', anchorId: 'market'),
            ),
          ],
        ),
        traversalPolicy: const _GroundPolicy(),
        navigation: navigation,
        occupancyRegistration: registration,
        anchorSource: _AnchorSource({
          'town/market': NpcRoutineAnchor(
            mapId: 'town',
            anchorId: 'market',
            point: NavigationPoint(x: 10, y: 0),
          ),
        }),
        movementSpeed: 10,
        blockedWaitSeconds: 0.5,
        maximumRepathAttempts: 2,
      );

      expect(executor.start(), NpcRoutineExecutionState.moving);
      expect(navigation.requests, hasLength(2));
      expect(navigation.requests.first.dynamicBlockers.single.id, 'blocker-01');
      expect(navigation.requests.last.dynamicBlockers, isEmpty);

      executor.update(0.8);
      expect(executor.state, NpcRoutineExecutionState.blocked);
      expect(executor.position, NavigationPoint(x: 0, y: 0));
      expect(executor.routeFollower.repathAttempts, 1);

      expect(blocker.release(), isTrue);
      executor.update(0.5);
      expect(executor.state, NpcRoutineExecutionState.moving);
      expect(executor.position, NavigationPoint(x: 5, y: 0));
      executor.update(0.5);

      expect(executor.state, NpcRoutineExecutionState.completed);
      expect(executor.position, NavigationPoint(x: 10, y: 0));
      expect(registration.isRegistered, isTrue);
    });

    test('cancellation clears work but keeps live occupancy registered', () {
      final occupancy = NavigationOccupancyCoordinator();
      final registration = _registration(occupancy);
      final executor = NpcRoutineExecutor(
        routineId: 'fixture-speech',
        npcId: 'actor-01',
        mapId: 'town',
        initialPosition: NavigationPoint(x: 4, y: 4),
        participantSteps: RoutineParticipantSteps(
          participantId: 'actor-01',
          steps: const [
            RoutineSpeechStep(
              id: 'greeting',
              text: 'Good morning.',
              durationSeconds: 10,
            ),
          ],
        ),
        traversalPolicy: const _GroundPolicy(),
        navigation: _RecordingNavigationService(_directPath),
        occupancyRegistration: registration,
        anchorSource: const _AnchorSource({}),
        movementSpeed: 10,
        blockedWaitSeconds: 0.5,
        maximumRepathAttempts: 2,
      );

      expect(executor.start(), NpcRoutineExecutionState.speaking);
      expect(executor.activeSpeechText, 'Good morning.');
      expect(occupancy.reservations, hasLength(1));

      expect(executor.cancel(), isTrue);
      expect(executor.state, NpcRoutineExecutionState.canceled);
      expect(executor.activeSpeechText, isNull);
      expect(executor.activeActionId, isNull);
      expect(
        executor.routeFollower.state,
        NavigationRouteFollowerState.canceled,
      );
      expect(executor.hasOccupancyReservation, isTrue);
      expect(occupancy.reservations, hasLength(1));
      expect(executor.cancel(), isFalse);
      expect(registration.release(), isTrue);
      expect(occupancy.reservations, isEmpty);
    });

    test('pause freezes progress and a paused jump restarts named step', () {
      final occupancy = NavigationOccupancyCoordinator();
      final registration = _registration(occupancy);
      final executor = NpcRoutineExecutor(
        routineId: 'fixture-dialogue-pause',
        npcId: 'actor-01',
        mapId: 'town',
        initialPosition: NavigationPoint(x: 0, y: 0),
        participantSteps: _fullPlan(),
        traversalPolicy: const _GroundPolicy(),
        navigation: _RecordingNavigationService(_directPath),
        occupancyRegistration: registration,
        anchorSource: _AnchorSource({
          'town/market': NpcRoutineAnchor(
            mapId: 'town',
            anchorId: 'market',
            point: NavigationPoint(x: 10, y: 0),
          ),
        }),
        movementSpeed: 10,
        blockedWaitSeconds: 0.5,
        maximumRepathAttempts: 2,
      );
      executor.start();
      executor.update(0.25);
      final pausedPosition = executor.position;

      expect(executor.pause(), isTrue);
      expect(executor.pause(), isFalse);
      executor.update(20);
      expect(executor.position, pausedPosition);
      expect(executor.currentStepId, 'move-to-market');
      expect(executor.completedStepIds, isEmpty);

      expect(executor.jumpToStep('missing-step'), isFalse);
      expect(executor.jumpToStep('market-action'), isTrue);
      expect(executor.currentStepId, 'market-action');
      expect(executor.activeActionId, 'fixture-action');
      executor.update(20);
      expect(executor.currentStepId, 'market-action');

      expect(executor.resume(), isTrue);
      expect(executor.resume(), isFalse);
      executor.update(0.5);
      expect(executor.currentStepId, 'market-speech');
      expect(executor.activeSpeechText, 'Fresh bread this morning.');
      expect(executor.hasOccupancyReservation, isTrue);
    });

    test(
      'walks to visible source portal before offscreen destination snap',
      () {
        final occupancy = NavigationOccupancyCoordinator();
        final executor = NpcRoutineExecutor(
          routineId: 'fixture-cross-map',
          npcId: 'actor-01',
          mapId: 'town',
          initialPosition: NavigationPoint(x: 0, y: 0),
          participantSteps: RoutineParticipantSteps(
            participantId: 'actor-01',
            steps: const [
              RoutineMoveStep(
                id: 'leave-town',
                target: RoutineAnchorReference(
                  mapId: 'forest',
                  anchorId: 'gate',
                ),
              ),
            ],
          ),
          traversalPolicy: const _GroundPolicy(),
          navigation: _RecordingNavigationService(_directPath),
          portalRoutePlanner: _portalPlanner(
            edges: [_portal('town-gate', 'town', 10, 'forest', 20)],
          ),
          occupancyRegistration: _registration(occupancy),
          anchorSource: _AnchorSource({
            'forest/gate': NpcRoutineAnchor(
              mapId: 'forest',
              anchorId: 'gate',
              point: NavigationPoint(x: 30, y: 0),
            ),
          }),
          movementSpeed: 10,
          blockedWaitSeconds: 0.5,
          maximumRepathAttempts: 2,
        );

        expect(executor.start(), NpcRoutineExecutionState.moving);
        expect(executor.currentMapId, 'town');
        expect(executor.isOnLoadedMap, isTrue);
        expect(occupancy.reservations, hasLength(1));

        executor.update(0.5);
        expect(executor.position, NavigationPoint(x: 5, y: 0));
        expect(executor.currentMapId, 'town');
        expect(executor.state, NpcRoutineExecutionState.moving);
        expect(occupancy.reservations, hasLength(1));

        executor.update(0.5);
        expect(executor.position, NavigationPoint(x: 30, y: 0));
        expect(executor.currentMapId, 'forest');
        expect(executor.isOnLoadedMap, isFalse);
        expect(executor.state, NpcRoutineExecutionState.completed);
        expect(executor.completedStepIds, ['leave-town']);
        expect(occupancy.reservations, isEmpty);
      },
    );

    test('offscreen source snaps to loaded destination anchor', () {
      final occupancy = NavigationOccupancyCoordinator();
      final executor = NpcRoutineExecutor(
        routineId: 'fixture-offscreen-source',
        npcId: 'actor-01',
        mapId: 'forest',
        initialMapId: 'town',
        initialPosition: NavigationPoint(x: 0, y: 0),
        participantSteps: RoutineParticipantSteps(
          participantId: 'actor-01',
          steps: const [
            RoutineMoveStep(
              id: 'arrive-at-gate',
              target: RoutineAnchorReference(mapId: 'forest', anchorId: 'gate'),
            ),
          ],
        ),
        traversalPolicy: const _GroundPolicy(),
        navigation: _RecordingNavigationService(_directPath),
        portalRoutePlanner: _portalPlanner(
          edges: [_portal('town-gate', 'town', 10, 'forest', 20)],
        ),
        occupancyRegistration: _registration(occupancy, mapId: 'forest'),
        anchorSource: _AnchorSource({
          'forest/gate': NpcRoutineAnchor(
            mapId: 'forest',
            anchorId: 'gate',
            point: NavigationPoint(x: 30, y: 0),
          ),
        }),
        movementSpeed: 10,
        blockedWaitSeconds: 0.5,
        maximumRepathAttempts: 2,
      );

      expect(executor.start(), NpcRoutineExecutionState.completed);
      expect(executor.currentMapId, 'forest');
      expect(executor.position, NavigationPoint(x: 30, y: 0));
      expect(executor.hasOccupancyReservation, isTrue);
      expect(occupancy.reservations.single.mapId, 'forest');
    });

    test('broken portal route fails visibly without teleporting', () {
      final occupancy = NavigationOccupancyCoordinator();
      final executor = NpcRoutineExecutor(
        routineId: 'fixture-no-portal-route',
        npcId: 'actor-01',
        mapId: 'town',
        initialPosition: NavigationPoint(x: 4, y: 4),
        participantSteps: RoutineParticipantSteps(
          participantId: 'actor-01',
          steps: const [
            RoutineMoveStep(
              id: 'leave-town',
              target: RoutineAnchorReference(mapId: 'forest', anchorId: 'gate'),
            ),
          ],
        ),
        traversalPolicy: const _GroundPolicy(),
        navigation: _RecordingNavigationService(_directPath),
        portalRoutePlanner: _portalPlanner(),
        occupancyRegistration: _registration(occupancy),
        anchorSource: _AnchorSource({
          'forest/gate': NpcRoutineAnchor(
            mapId: 'forest',
            anchorId: 'gate',
            point: NavigationPoint(x: 30, y: 0),
          ),
        }),
        movementSpeed: 10,
        blockedWaitSeconds: 0.5,
        maximumRepathAttempts: 2,
      );

      expect(executor.start(), NpcRoutineExecutionState.failed);
      expect(executor.failureReason, NpcRoutineFailureReason.noPortalRoute);
      expect(
        executor.mapNoRouteReason,
        NavigationMapNoRouteReason.disconnectedMaps,
      );
      expect(executor.currentMapId, 'town');
      expect(executor.position, NavigationPoint(x: 4, y: 4));
      expect(executor.hasOccupancyReservation, isTrue);
    });
  });
}

RoutineParticipantSteps _fullPlan() => RoutineParticipantSteps(
  participantId: 'actor-01',
  steps: const [
    RoutineMoveStep(
      id: 'move-to-market',
      target: RoutineAnchorReference(mapId: 'town', anchorId: 'market'),
    ),
    RoutineWaitStep(id: 'wait-at-market', durationSeconds: 0.5),
    RoutineActionStep(
      id: 'market-action',
      actionId: 'fixture-action',
      durationSeconds: 0.5,
    ),
    RoutineSpeechStep(
      id: 'market-speech',
      text: 'Fresh bread this morning.',
      durationSeconds: 0.5,
    ),
  ],
);

NavigationPathResult _directPath(NavigationPathRequest request) =>
    NavigationPathSuccess(
      NavigationPath(
        mapId: request.mapId,
        points: [request.start, request.goal],
        totalCost: 10,
      ),
    );

final class _RecordingNavigationService implements WorldNavigationService {
  _RecordingNavigationService(this.resultFor);

  final NavigationPathResult Function(NavigationPathRequest request) resultFor;
  final List<NavigationPathRequest> requests = [];

  @override
  NavigationPathResult findPath(NavigationPathRequest request) {
    requests.add(request);
    return resultFor(request);
  }

  @override
  bool isReachable(NavigationPathRequest request) =>
      findPath(request) is NavigationPathSuccess;

  @override
  void invalidateMap(String mapId) {}
}

final class _AnchorSource implements NpcRoutineAnchorSource {
  const _AnchorSource(this.anchors);

  final Map<String, NpcRoutineAnchor> anchors;

  @override
  NpcRoutineAnchor? resolve(RoutineAnchorReference reference) =>
      anchors['${reference.mapId}/${reference.anchorId}'];
}

NavigationOccupancyRegistration _registration(
  NavigationOccupancyCoordinator occupancy, {
  NavigationAgentProfile? profile,
  String mapId = 'town',
}) => NavigationOccupancyRegistration(
  coordinator: occupancy,
  occupantId: 'placement-01',
  mapId: mapId,
  agentProfile:
      profile ?? NavigationAgentProfile(id: 'town-adult', footprintRadius: 1),
);

NavigationMapRoutePlanner _portalPlanner({
  List<NavigationPortalEdge> edges = const [],
}) => NavigationMapRoutePlanner(
  graph: NavigationPortalGraph(mapIds: const ['forest', 'town'], edges: edges),
  navigation: _RecordingNavigationService(_directPath),
);

NavigationPortalEdge _portal(
  String id,
  String sourceMapId,
  double sourceX,
  String destinationMapId,
  double destinationX,
) => NavigationPortalEdge(
  id: id,
  sourceMapId: sourceMapId,
  sourcePoint: NavigationPoint(x: sourceX, y: 0),
  destinationMapId: destinationMapId,
  destinationPoint: NavigationPoint(x: destinationX, y: 0),
);

final class _GroundPolicy implements NavigationTraversalPolicy {
  const _GroundPolicy();

  @override
  String get cacheKey => 'fixture-ground-v1';

  @override
  bool allowsTraversal(NavigationTraversal traversal) => true;

  @override
  double movementCost(NavigationTraversal traversal) => traversal.baseCost;
}
