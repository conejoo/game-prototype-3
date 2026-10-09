import '../../world_map/map_project.dart';
import '../../world_map/world_map.dart';
import '../routines/routine_model.dart';
import '../navigation/navigation_point.dart';
import 'npc_routine_executor.dart';

/// NPC-consumer adapter from invisible map metadata to navigation points.
final class WorldMapNpcRoutineAnchorSource implements NpcRoutineAnchorSource {
  WorldMapNpcRoutineAnchorSource(WorldMap map)
    : _anchorsByQualifiedId = Map.unmodifiable({
        for (final anchor in map.objects.whereType<RoutineAnchorMapObject>())
          '${map.mapId}/${anchor.id}': (map.mapId, anchor),
      });

  WorldMapNpcRoutineAnchorSource.fromProject(LoadedMapProject project)
    : _anchorsByQualifiedId = Map.unmodifiable({
        for (final entry in project.maps.entries)
          for (final anchor
              in entry.value.objects.whereType<RoutineAnchorMapObject>())
            '${entry.key}/${anchor.id}': (entry.key, anchor),
      });

  final Map<String, (String, RoutineAnchorMapObject)> _anchorsByQualifiedId;

  @override
  NpcRoutineAnchor? resolve(RoutineAnchorReference reference) {
    final resolved =
        _anchorsByQualifiedId['${reference.mapId}/${reference.anchorId}'];
    if (resolved == null) {
      return null;
    }
    final (mapId, anchor) = resolved;
    return NpcRoutineAnchor(
      mapId: mapId,
      anchorId: anchor.id,
      point: NavigationPoint(x: anchor.x, y: anchor.y),
      facing: switch (anchor.facing) {
        'south' => NpcRoutineFacing.south,
        'north' => NpcRoutineFacing.north,
        'west' => NpcRoutineFacing.west,
        'east' => NpcRoutineFacing.east,
        null => null,
        final value => throw StateError(
          'Validated routine anchor ${anchor.id} has unknown facing $value.',
        ),
      },
    );
  }
}
