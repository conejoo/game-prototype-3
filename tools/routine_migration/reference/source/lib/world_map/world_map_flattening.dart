import 'dart:math' as math;

import 'world_map.dart';

/// Read-only resolved content used by runtime and previews.
///
/// Maps remain editable in grouped form; consumers never need special group
/// branches after calling [WorldMapFlattening.flatten].
final class WorldMapFlattenedContent {
  WorldMapFlattenedContent({
    required List<WorldArtLayer> artLayers,
    required List<PropMapObject> props,
    required List<WorldMapCollider> colliders,
    required List<WorldMapPortal> portals,
  }) : artLayers = List.unmodifiable(artLayers),
       props = List.unmodifiable(props),
       colliders = List.unmodifiable(colliders),
       portals = List.unmodifiable(portals);

  final List<WorldArtLayer> artLayers;
  final List<PropMapObject> props;
  final List<WorldMapCollider> colliders;
  final List<WorldMapPortal> portals;
}

/// Bakes group transforms in memory without mutating authored document data.
abstract final class WorldMapFlattening {
  static WorldMapFlattenedContent flatten(WorldMap map) {
    final artLayers = <WorldArtLayer>[...map.artLayers];
    final props = <PropMapObject>[
      for (final object in map.objects)
        if (object is PropMapObject) object,
    ];
    final colliders = <WorldMapCollider>[...map.colliders];
    final portals = <WorldMapPortal>[...map.portals];

    for (final group in map.groups) {
      for (final layer in group.artLayers) {
        artLayers.add(
          WorldArtLayer(
            id: '${group.id}--${layer.id}',
            name: '${group.id}: ${layer.name}',
            visible: layer.visible,
            cells: [
              for (final cell in layer.cells)
                () {
                  final transformed = group.transformCell(cell.x, cell.y);
                  return WorldArtTileCell(
                    x: transformed.$1,
                    y: transformed.$2,
                    tileId: cell.tileId,
                  );
                }(),
            ],
          ),
        );
      }
      for (final prop in group.props) {
        final point = group.transformPoint(prop.x, prop.y, map.tileSize);
        props.add(
          PropMapObject(
            id: prop.id,
            definitionId: prop.definitionId,
            x: point.x,
            y: point.y,
            collisionEnabled: prop.collisionEnabled,
            lightSourceStates: prop.lightSourceStates,
            renderDepthOffsetY: prop.renderDepthOffsetY,
          ),
        );
      }
      for (final collider in group.colliders) {
        final bounds = _transformRectangle(
          group,
          map.tileSize,
          collider.left,
          collider.top,
          collider.width,
          collider.height,
        );
        colliders.add(
          WorldMapCollider(
            id: collider.id,
            left: bounds.left,
            top: bounds.top,
            width: bounds.width,
            height: bounds.height,
          ),
        );
      }
      for (final portal in group.portals) {
        final bounds = _transformRectangle(
          group,
          map.tileSize,
          portal.left,
          portal.top,
          portal.width,
          portal.height,
        );
        portals.add(
          WorldMapPortal(
            id: portal.id,
            label: portal.label,
            prompt: portal.prompt,
            left: bounds.left,
            top: bounds.top,
            width: bounds.width,
            height: bounds.height,
            destinationMapId: portal.destinationMapId,
            destinationX: portal.destinationX,
            destinationY: portal.destinationY,
          ),
        );
      }
    }
    return WorldMapFlattenedContent(
      artLayers: artLayers,
      props: props,
      colliders: colliders,
      portals: portals,
    );
  }

  static ({double left, double top, double width, double height})
  _transformRectangle(
    WorldMapGroup group,
    int tileSize,
    double left,
    double top,
    double width,
    double height,
  ) {
    final corners = <WorldMapPoint>[
      group.transformPoint(left, top, tileSize),
      group.transformPoint(left + width, top, tileSize),
      group.transformPoint(left, top + height, tileSize),
      group.transformPoint(left + width, top + height, tileSize),
    ];
    final minX = corners.map((point) => point.x).reduce(math.min);
    final maxX = corners.map((point) => point.x).reduce(math.max);
    final minY = corners.map((point) => point.y).reduce(math.min);
    final maxY = corners.map((point) => point.y).reduce(math.max);
    return (left: minX, top: minY, width: maxX - minX, height: maxY - minY);
  }
}
