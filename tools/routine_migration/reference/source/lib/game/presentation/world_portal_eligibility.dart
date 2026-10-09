import '../../world_map/world_map.dart';
import '../../world_map/world_map_flattening.dart';
import 'world_presentation.dart';

/// Shared access rules for player portals, transitions, resumes and NPC routes.
/// Collision and interaction range cannot substitute for milestone eligibility.
final class WorldPortalEligibility {
  const WorldPortalEligibility(this.selection);

  final WorldPresentationSelection selection;

  bool allowsMap(String mapId) => switch (mapId) {
    'map-058-keepsakes-outdoor' ||
    'map-058-keepsakes-warm' => selection.isPreviewOverride,
    'buried-tollworks' => selection.tollworksOpen,
    'night-orchard-outer' => selection.tollworksOpen && selection.orchardOpen,
    'night-orchard-inner' =>
      selection.tollworksOpen &&
          selection.orchardOpen &&
          selection.innerOrchardOpen,
    _ => true,
  };

  bool allowsPortal(String sourceMapId, WorldMapPortal portal) {
    final bindingOpen = switch ((sourceMapId, portal.id)) {
      ('alderwake', 'tollworks-entrance-01') => selection.tollworksOpen,
      ('buried-tollworks', 'tollworks-orchard-entrance-01') =>
        selection.orchardOpen,
      ('night-orchard-outer', 'orchard-inner-entrance-01') =>
        selection.innerOrchardOpen,
      ('alderwake', 'tollworks-shortcut-entrance-01') ||
      (
        'buried-tollworks',
        'tollworks-shortcut-exit-01',
      ) => selection.shortcutOpen,
      _ => true,
    };
    // Ordinary authored outward exits remain available even for a formerly
    // invalid location. Shortcut exits still require the shortcut milestone.
    return bindingOpen &&
        (_refugeDepth(portal.destinationMapId) < _refugeDepth(sourceMapId) ||
            allowsMap(portal.destinationMapId));
  }

  /// Forward refuge arrivals must match an eligible current authored portal.
  /// This also prevents direct travel from bypassing a closed shortcut or
  /// hopping over an intermediate gate. Ordinary adapters keep free arrivals.
  bool allowsTransition({
    required WorldMap source,
    required String destinationMapId,
    required double x,
    required double y,
    String? portalId,
  }) {
    if ((destinationMapId == 'map-058-keepsakes-outdoor' ||
            destinationMapId == 'map-058-keepsakes-warm') &&
        !allowsMap(destinationMapId)) {
      return false;
    }
    if (portalId == null && _refugeDepth(destinationMapId) == 0) return true;
    return WorldMapFlattening.flatten(source).portals.any(
      (portal) =>
          (portalId == null || portal.id == portalId) &&
          portal.destinationMapId == destinationMapId &&
          portal.destinationX == x &&
          portal.destinationY == y &&
          allowsPortal(source.mapId, portal),
    );
  }
}

int _refugeDepth(String mapId) => switch (mapId) {
  'buried-tollworks' => 1,
  'night-orchard-outer' => 2,
  'night-orchard-inner' => 3,
  _ => 0,
};
