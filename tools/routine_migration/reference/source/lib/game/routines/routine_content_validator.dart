import '../../world_map/map_project.dart';
import '../../world_map/world_map.dart';
import '../navigation/navigation.dart';
import '../npc/npc_content.dart';
import '../state/player_event_journal.dart';
import '../world/world_map_navigation_portal_graph.dart';
import '../world_events/world_event_catalog.dart';
import 'routine_model.dart';

/// One parsed routine plus its authored source path.
final class RoutineContentDocument {
  const RoutineContentDocument({required this.filePath, required this.routine});

  final String filePath;
  final RoutineDefinition routine;
}

/// Stable cross-content error tied to one routine source field.
final class RoutineContentDiagnostic {
  const RoutineContentDiagnostic({
    required this.filePath,
    required this.routineId,
    required this.fieldPath,
    required this.cause,
    this.stepId,
  });

  final String filePath;
  final String routineId;
  final String fieldPath;
  final String cause;
  final String? stepId;

  @override
  String toString() {
    final step = stepId == null ? '' : ' (step "$stepId")';
    return '$filePath [$routineId] $fieldPath$step: $cause';
  }
}

/// Cross-file routine validation without runtime scheduling or dynamic actors.
///
/// Static path checks consume the public actor-neutral navigation contract.
/// Portal choice and offscreen behavior remain outside navigation core.
final class RoutineContentValidator {
  const RoutineContentValidator();

  List<RoutineContentDiagnostic> validate({
    required Iterable<RoutineContentDocument> documents,
    required WorldEventCatalog worldEvents,
    required NpcCatalog npcs,
    required LoadedMapProject maps,
    required WorldNavigationService navigation,
  }) {
    final diagnostics = <RoutineContentDiagnostic>[];
    final areaIds = <String>{
      for (final map in maps.maps.values)
        for (final zone in map.zones) ...{zone.id, zone.role},
    };
    final resourceIds = <String>{
      for (final map in maps.maps.values)
        for (final object in map.objects)
          if (object is ResourceNodeMapObject) object.definitionId,
    };
    final giftItemIds = <String>{
      for (final npc in npcs.npcs)
        for (final rule in npc.runtime.acceptedGiftRules) rule.itemId,
    };
    final allChoiceIds = <String>{
      for (final npc in npcs.npcs)
        for (final node in npc.dialogue.nodes)
          for (final choice in node.choices) choice.id,
    };
    final portalRoutePlanner = NavigationMapRoutePlanner(
      graph: buildWorldMapNavigationPortalGraph(maps),
      navigation: navigation,
    );

    for (final document in documents) {
      final routine = document.routine;
      void issue(String fieldPath, String cause, {String? stepId}) {
        diagnostics.add(
          RoutineContentDiagnostic(
            filePath: document.filePath,
            routineId: routine.id,
            fieldPath: fieldPath,
            cause: cause,
            stepId: stepId,
          ),
        );
      }

      for (final (index, participantId) in routine.participants.indexed) {
        if (npcs.findById(participantId) == null) {
          issue('\$.participants[$index]', 'Unknown NPC ID "$participantId".');
        }
      }

      for (final (index, condition) in routine.conditions.indexed) {
        final path = '\$.conditions[$index]';
        switch (condition) {
          case RoutineWorldEventCondition(:final eventId):
            if (!worldEvents.containsId(eventId)) {
              issue('$path.eventId', 'Unknown world-event ID "$eventId".');
            }
          case RoutineLearnedFactCondition(:final npcId, :final factId):
            final npc = npcs.findById(npcId);
            if (npc == null) {
              issue('$path.npcId', 'Unknown NPC ID "$npcId".');
            } else if (!npc.runtime.factsById.containsKey(factId)) {
              issue(
                '$path.factId',
                'NPC "$npcId" does not declare fact "$factId".',
              );
            }
          case RoutineRelationshipFlagCondition(:final npcId, :final flagId):
            final npc = npcs.findById(npcId);
            if (npc == null) {
              issue('$path.npcId', 'Unknown NPC ID "$npcId".');
            } else if (!npc.runtime.routine.relationshipFlagIdSet.contains(
              flagId,
            )) {
              issue(
                '$path.flagId',
                'NPC "$npcId" does not declare relationship flag "$flagId".',
              );
            }
          case RoutinePlayerEventCondition():
            _validatePlayerEventCondition(
              condition: condition,
              path: path,
              npcs: npcs,
              areaIds: areaIds,
              resourceIds: resourceIds,
              giftItemIds: giftItemIds,
              allChoiceIds: allChoiceIds,
              issue: issue,
            );
        }
      }

      _validateDialogueReferences(
        routine: routine,
        worldEvents: worldEvents,
        npcs: npcs,
        issue: issue,
      );

      for (final (planIndex, plan) in routine.participantSteps.indexed) {
        final planPath = '\$.participantSteps[$planIndex]';
        final participant = npcs.findById(plan.participantId);
        _ResolvedMove? previousMove;
        for (final (stepIndex, step) in plan.steps.indexed) {
          final stepPath = '$planPath.steps[$stepIndex]';
          switch (step) {
            case RoutineActionStep(:final actionId):
              if (participant != null &&
                  !participant.runtime.routine.actionIdSet.contains(actionId)) {
                issue(
                  '$stepPath.actionId',
                  'NPC "${plan.participantId}" does not declare action '
                      '"$actionId".',
                  stepId: step.id,
                );
              }
            case RoutineMoveStep(:final target):
              final resolved = _resolveAnchor(
                target: target,
                maps: maps,
                path: stepPath,
                stepId: step.id,
                issue: issue,
              );
              final profile = participant?.runtime.routine.agentProfile;
              if (resolved == null || profile == null) {
                previousMove = null;
                continue;
              }
              if (!_canReach(
                navigation: navigation,
                mapId: resolved.mapId,
                start: resolved.point,
                goal: resolved.point,
                profile: profile,
              )) {
                issue(
                  '$stepPath.target',
                  'Anchor "${target.anchorId}" is not statically occupiable '
                      'for navigation profile "${profile.id}".',
                  stepId: step.id,
                );
                previousMove = null;
                continue;
              }
              final previous = previousMove;
              if (previous != null) {
                final routeStatus = _routeStatus(
                  from: previous,
                  to: resolved,
                  planner: portalRoutePlanner,
                  profile: profile,
                );
                switch (routeStatus) {
                  case _RouteStatus.reachable:
                    break;
                  case _RouteStatus.noPortalChain:
                    issue(
                      '$stepPath.target',
                      'No authored portal chain connects map '
                          '"${previous.mapId}" to "${resolved.mapId}".',
                      stepId: step.id,
                    );
                  case _RouteStatus.unreachableLeg:
                    issue(
                      '$stepPath.target',
                      'Static route from anchor "${previous.anchorId}" to '
                          '"${resolved.anchorId}" has an unreachable leg for '
                          'navigation profile "${profile.id}".',
                      stepId: step.id,
                    );
                }
              }
              previousMove = resolved;
            case RoutineWaitStep() || RoutineSpeechStep():
              break;
          }
        }
      }
    }

    diagnostics.sort((left, right) {
      final file = left.filePath.compareTo(right.filePath);
      if (file != 0) return file;
      final routine = left.routineId.compareTo(right.routineId);
      if (routine != 0) return routine;
      final field = left.fieldPath.compareTo(right.fieldPath);
      return field != 0 ? field : left.cause.compareTo(right.cause);
    });
    return List.unmodifiable(diagnostics);
  }
}

void _validateDialogueReferences({
  required RoutineDefinition routine,
  required WorldEventCatalog worldEvents,
  required NpcCatalog npcs,
  required void Function(String, String, {String? stepId}) issue,
}) {
  final policy = routine.interactionPolicy;
  final defaultEntry = policy.defaultDialogueEntryNodeId;
  if (defaultEntry != null) {
    for (final participantId in routine.participants) {
      final participant = npcs.findById(participantId);
      if (participant != null &&
          !participant.dialogue.nodesById.containsKey(defaultEntry)) {
        issue(
          r'$.interactionPolicy.defaultDialogueEntryNodeId',
          'NPC "$participantId" has no dialogue node "$defaultEntry".',
        );
      }
    }
  }
  for (final (index, entry) in policy.stepDialogueEntries.indexed) {
    final participant = npcs.findById(entry.participantId);
    if (participant != null &&
        !participant.dialogue.nodesById.containsKey(
          entry.dialogueEntryNodeId,
        )) {
      issue(
        '\$.interactionPolicy.stepDialogueEntries[$index]'
            '.dialogueEntryNodeId',
        'NPC "${entry.participantId}" has no dialogue node '
            '"${entry.dialogueEntryNodeId}".',
        stepId: entry.stepId,
      );
    }
  }
  final participantOutcomeTags = <String>{
    for (final participantId in routine.participants)
      if (npcs.findById(participantId) case final participant?)
        for (final node in participant.dialogue.nodes)
          ...node.choices
              .map((choice) => choice.outcomeTag)
              .whereType<String>(),
  };
  for (final (index, outcome) in policy.outcomeDirectives.indexed) {
    final path = '\$.interactionPolicy.outcomeDirectives[$index]';
    if (!participantOutcomeTags.contains(outcome.outcomeTag)) {
      issue(
        '$path.outcomeTag',
        'No participating NPC dialogue declares outcome tag '
            '"${outcome.outcomeTag}".',
      );
    }
    switch (outcome.directive) {
      case RoutineWorldEventDirective(:final eventId):
        if (!worldEvents.containsId(eventId)) {
          issue(
            '$path.directive.eventId',
            'Unknown world-event ID "$eventId".',
          );
        }
      case ResumeRoutineDirective() ||
          JumpToRoutineStepDirective() ||
          EndRoutineForDayDirective():
        break;
    }
  }
}

void _validatePlayerEventCondition({
  required RoutinePlayerEventCondition condition,
  required String path,
  required NpcCatalog npcs,
  required Set<String> areaIds,
  required Set<String> resourceIds,
  required Set<String> giftItemIds,
  required Set<String> allChoiceIds,
  required void Function(String, String, {String? stepId}) issue,
}) {
  final subjectId = condition.subjectId;
  final targetId = condition.targetId;
  switch (condition.eventKind) {
    case PlayerEventKind.areaEntered:
      if (subjectId != null && !areaIds.contains(subjectId)) {
        issue('$path.subjectId', 'Unknown authored area ID "$subjectId".');
      }
    case PlayerEventKind.resourceGathered:
      if (subjectId != null && !resourceIds.contains(subjectId)) {
        issue('$path.subjectId', 'Unknown resource ID "$subjectId".');
      }
    case PlayerEventKind.itemGifted:
      if (subjectId != null && !giftItemIds.contains(subjectId)) {
        issue('$path.subjectId', 'Unknown gift item ID "$subjectId".');
      }
      if (targetId != null && npcs.findById(targetId) == null) {
        issue('$path.targetId', 'Unknown NPC ID "$targetId".');
      }
    case PlayerEventKind.dialogueChoiceSelected:
      final participant = subjectId == null ? null : npcs.findById(subjectId);
      if (subjectId != null && participant == null) {
        issue('$path.subjectId', 'Unknown NPC ID "$subjectId".');
      }
      if (targetId != null) {
        final choiceIds = participant == null
            ? allChoiceIds
            : {
                for (final node in participant.dialogue.nodes)
                  for (final choice in node.choices) choice.id,
              };
        if (!choiceIds.contains(targetId)) {
          issue(
            '$path.targetId',
            'Unknown dialogue choice ID "$targetId"'
                '${subjectId == null ? '' : ' for NPC "$subjectId"'}.',
          );
        }
      }
  }
}

_ResolvedMove? _resolveAnchor({
  required RoutineAnchorReference target,
  required LoadedMapProject maps,
  required String path,
  required String stepId,
  required void Function(String, String, {String? stepId}) issue,
}) {
  final map = maps.maps[target.mapId];
  if (map == null) {
    issue(
      '$path.target.mapId',
      'Unknown map ID "${target.mapId}".',
      stepId: stepId,
    );
    return null;
  }
  RoutineAnchorMapObject? anchor;
  for (final object in map.objects) {
    if (object is RoutineAnchorMapObject && object.id == target.anchorId) {
      anchor = object;
      break;
    }
  }
  if (anchor == null) {
    issue(
      '$path.target.anchorId',
      'Map "${target.mapId}" has no routine anchor "${target.anchorId}".',
      stepId: stepId,
    );
    return null;
  }
  return _ResolvedMove(
    mapId: target.mapId,
    anchorId: target.anchorId,
    point: NavigationPoint(x: anchor.x, y: anchor.y),
  );
}

_RouteStatus _routeStatus({
  required _ResolvedMove from,
  required _ResolvedMove to,
  required NavigationMapRoutePlanner planner,
  required NavigationAgentProfile profile,
}) {
  final result = planner.plan(
    NavigationMapRouteRequest(
      sourceMapId: from.mapId,
      sourcePoint: from.point,
      destinationMapId: to.mapId,
      destinationPoint: to.point,
      agentProfile: profile,
      traversalPolicy: const _RoutineStaticTraversalPolicy(),
    ),
  );
  return switch (result) {
    NavigationMapRouteSuccess() => _RouteStatus.reachable,
    NavigationMapNoRoute(
      reason: NavigationMapNoRouteReason.disconnectedMaps ||
          NavigationMapNoRouteReason.unknownMap,
    ) =>
      _RouteStatus.noPortalChain,
    NavigationMapNoRoute() => _RouteStatus.unreachableLeg,
  };
}

bool _canReach({
  required WorldNavigationService navigation,
  required String mapId,
  required NavigationPoint start,
  required NavigationPoint goal,
  required NavigationAgentProfile profile,
}) {
  try {
    return navigation.isReachable(
      NavigationPathRequest(
        mapId: mapId,
        start: start,
        goal: goal,
        agentProfile: profile,
        traversalPolicy: const _RoutineStaticTraversalPolicy(),
      ),
    );
  } on StateError {
    return false;
  }
}

final class _ResolvedMove {
  const _ResolvedMove({
    required this.mapId,
    required this.anchorId,
    required this.point,
  });

  final String mapId;
  final String anchorId;
  final NavigationPoint point;
}

enum _RouteStatus { reachable, noPortalChain, unreachableLeg }

final class _RoutineStaticTraversalPolicy implements NavigationTraversalPolicy {
  const _RoutineStaticTraversalPolicy();

  @override
  String get cacheKey => 'routine-content-static-v1';

  @override
  bool allowsTraversal(NavigationTraversal traversal) => true;

  @override
  double movementCost(NavigationTraversal traversal) => traversal.baseCost;
}
