import '../../world_map/map_project.dart';
import '../../world_map/world_map_flattening.dart';
import '../navigation/navigation.dart';
import '../presentation/world_portal_eligibility.dart';

/// Adapts authored map-project portals into actor-neutral navigation edges.
NavigationPortalGraph buildWorldMapNavigationPortalGraph(
  LoadedMapProject project, {
  WorldPortalEligibility? eligibility,
}) => NavigationPortalGraph(
  mapIds: project.maps.keys,
  edges: [
    for (final mapId in project.maps.keys.toList()..sort())
      for (final portal in ([
        ...WorldMapFlattening.flatten(project.maps[mapId]!).portals,
      ]..sort((left, right) => left.id.compareTo(right.id))))
        if (eligibility?.allowsPortal(mapId, portal) ?? true)
          NavigationPortalEdge(
            id: portal.id,
            sourceMapId: mapId,
            sourcePoint: NavigationPoint(
              x: portal.left + portal.width / 2,
              y: portal.top + portal.height / 2,
            ),
            destinationMapId: portal.destinationMapId,
            destinationPoint: NavigationPoint(
              x: portal.destinationX,
              y: portal.destinationY,
            ),
          ),
  ],
);
