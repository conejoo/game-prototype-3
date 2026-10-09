import 'package:flame/components.dart';

import '../../world_map/world_map.dart';
import '../interaction/world_interactable_component.dart';
import '../visuals/world_render_depth.dart';
import 'world_render_priority.dart';

/// Runtime projection of one authored [WorldMapPortal].
final class WorldMapPortalComponent extends WorldInteractableComponent {
  WorldMapPortalComponent(this.portal, {bool eligible = true})
    : super(
        targetId: portal.id,
        isInteractionEligible: eligible,
        interactionRadius: 72,
        promptText: portal.prompt,
        holdDuration: Duration.zero,
        position: Vector2(portal.left, portal.top),
        size: Vector2(portal.width, portal.height),
        visualSize: Vector2(portal.width, portal.height),
        visualFootPosition: Vector2(portal.width / 2, portal.height),
        priority: WorldRenderPriority.depthRankStart,
        renderLayer: WorldRenderLayer.structure,
        renderStableId: WorldRenderStableId(
          namespace: 'portal',
          value: portal.id,
        ),
      );

  final WorldMapPortal portal;

  @override
  void onInteractionComplete() {
    game.travelToMap(
      portal.destinationMapId,
      arrivalPosition: Vector2(portal.destinationX, portal.destinationY),
      portalId: portal.id,
    );
  }
}
