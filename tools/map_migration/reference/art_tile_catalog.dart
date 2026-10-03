/// Dependency-neutral catalog for exact 32-world-unit layered art bundled with
/// the game.
///
/// IDs intentionally equal Flutter asset keys without the leading `assets/`.
/// Runtime, editor, and validators can agree on art without importing Flame or
/// Flutter. Contact sheets are excluded because they are authoring reference
/// images, not paintable tiles.
final class ArtTileCatalog {
  const ArtTileCatalog._(this.entries);

  static const moonwoodFootbridgeKit = 'moonwood-footbridge';
  static const passengerQuayKit = 'passenger-quay';
  static const fairBridgeKit = 'fair-bridge';
  static const tollworksKit = 'tollworks';

  static const bundled = ArtTileCatalog._([
    ..._moonwoodFootbridge,
    ..._passengerQuay,
    ..._fairBridge,
    ..._tollworks,
  ]);

  final List<ArtTileCatalogEntry> entries;

  // Source crops and exact 16-unit corner masks are recorded in the MAP-029
  // provenance. These remain ordinary 32-unit art cells with separate collision.
  static const _tollworks = <ArtTileCatalogEntry>[
    ArtTileCatalogEntry.tollworks('floor-00', floor: true),
    ArtTileCatalogEntry.tollworks('floor-01', floor: true),
    ArtTileCatalogEntry.tollworks('floor-02', floor: true),
    ArtTileCatalogEntry.tollworks('floor-03', floor: true),
    ArtTileCatalogEntry.tollworks('floor-04', floor: true),
    ArtTileCatalogEntry.tollworks('floor-05', floor: true),
    ArtTileCatalogEntry.tollworks('floor-06', floor: true),
    ArtTileCatalogEntry.tollworks('floor-07', floor: true),
    ArtTileCatalogEntry.tollworks('floor-08', floor: true),
    ArtTileCatalogEntry.tollworks('floor-09', floor: true),
    ArtTileCatalogEntry.tollworks('floor-10', floor: true),
    ArtTileCatalogEntry.tollworks('floor-11', floor: true),
    ArtTileCatalogEntry.tollworks('floor-12', floor: true),
    ArtTileCatalogEntry.tollworks('floor-13', floor: true),
    ArtTileCatalogEntry.tollworks('floor-14', floor: true),
    ArtTileCatalogEntry.tollworks('floor-15', floor: true),
    ArtTileCatalogEntry.tollworks('floor-16', floor: true),
    ArtTileCatalogEntry.tollworks('floor-17', floor: true),
    ArtTileCatalogEntry.tollworks('floor-18', floor: true),
    ArtTileCatalogEntry.tollworks('floor-19', floor: true),
    ArtTileCatalogEntry.tollworks('floor-20', floor: true),
    ArtTileCatalogEntry.tollworks('floor-21', floor: true),
    ArtTileCatalogEntry.tollworks('floor-22', floor: true),
    ArtTileCatalogEntry.tollworks('floor-23', floor: true),
    ArtTileCatalogEntry.tollworks('floor-24', floor: true),
    ArtTileCatalogEntry.tollworks('floor-25', floor: true),
    ArtTileCatalogEntry.tollworks('wall-00'),
    ArtTileCatalogEntry.tollworks('wall-01'),
    ArtTileCatalogEntry.tollworks('wall-02'),
    ArtTileCatalogEntry.tollworks('wall-03'),
    ArtTileCatalogEntry.tollworks('wall-04'),
    ArtTileCatalogEntry.tollworks('wall-05'),
    ArtTileCatalogEntry.tollworks('wall-06'),
    ArtTileCatalogEntry.tollworks('wall-07'),
    ArtTileCatalogEntry.tollworks('wall-08'),
    ArtTileCatalogEntry.tollworks('wall-09'),
    ArtTileCatalogEntry.tollworks('wall-10'),
    ArtTileCatalogEntry.tollworks('wall-11'),
    ArtTileCatalogEntry.tollworks('wall-12'),
    ArtTileCatalogEntry.tollworks('wall-13'),
    ArtTileCatalogEntry.tollworks('wall-14'),
    ArtTileCatalogEntry.tollworks('wall-15'),
    ArtTileCatalogEntry.tollworks('wall-16'),
    ArtTileCatalogEntry.tollworks('wall-17'),
    ArtTileCatalogEntry.tollworks('wall-18'),
    ArtTileCatalogEntry.tollworks('wall-19'),
    ArtTileCatalogEntry.tollworks('wall-20'),
    ArtTileCatalogEntry.tollworks('wall-21'),
    ArtTileCatalogEntry.tollworks('wall-22'),
    ArtTileCatalogEntry.tollworks('wall-23'),
    ArtTileCatalogEntry.tollworks('wall-24'),
    ArtTileCatalogEntry.tollworks('wall-25'),
    ArtTileCatalogEntry.tollworks('wall-26'),
    ArtTileCatalogEntry.tollworks('wall-27'),
    ArtTileCatalogEntry.tollworks('wall-28'),
    ArtTileCatalogEntry.tollworks('wall-29'),
    ArtTileCatalogEntry.tollworks('wall-30'),
    ArtTileCatalogEntry.tollworks('wall-31'),
    ArtTileCatalogEntry.tollworks('wall-32'),
    ArtTileCatalogEntry.tollworks('wall-33'),
    ArtTileCatalogEntry.tollworks('wall-34'),
    ArtTileCatalogEntry.tollworks('wall-35'),
    ArtTileCatalogEntry.tollworks('wall-36'),
    ArtTileCatalogEntry.tollworks('wall-37'),
    ArtTileCatalogEntry.tollworks('wall-38'),
    ArtTileCatalogEntry.tollworks('wall-39'),
    ArtTileCatalogEntry.tollworks('wall-40'),
    ArtTileCatalogEntry.tollworks('wall-41'),
    ArtTileCatalogEntry.tollworks('wall-42'),
    ArtTileCatalogEntry.tollworks('wall-43'),
    ArtTileCatalogEntry.tollworks('wall-44'),
    ArtTileCatalogEntry.tollworks('wall-45'),
    ArtTileCatalogEntry.tollworks('wall-46'),
    ArtTileCatalogEntry.tollworks('wall-47'),
    ArtTileCatalogEntry.tollworks('wall-48'),
    ArtTileCatalogEntry.tollworks('wall-49'),
    ArtTileCatalogEntry.tollworks('wall-50'),
    ArtTileCatalogEntry.tollworks('wall-51'),
    ArtTileCatalogEntry.tollworks('wall-52'),
    ArtTileCatalogEntry.tollworks('wall-53'),
    ArtTileCatalogEntry.tollworks('wall-54'),
    ArtTileCatalogEntry.tollworks('wall-55'),
    ArtTileCatalogEntry.tollworks('wall-56'),
    ArtTileCatalogEntry.tollworks('wall-57'),
    ArtTileCatalogEntry.tollworks('wall-58'),
    ArtTileCatalogEntry.tollworks('wall-59'),
    ArtTileCatalogEntry.tollworks('wall-60'),
    ArtTileCatalogEntry.tollworks('wall-61'),
    ArtTileCatalogEntry.tollworks('wall-62'),
    ArtTileCatalogEntry.tollworks('wall-63'),
    ArtTileCatalogEntry.tollworks('wall-64'),
    ArtTileCatalogEntry.tollworks('wall-65'),
    ArtTileCatalogEntry.tollworks('wall-66'),
    ArtTileCatalogEntry.tollworks('wall-67'),
    ArtTileCatalogEntry.tollworks('wall-68'),
    ArtTileCatalogEntry.tollworks('wall-69'),
    ArtTileCatalogEntry.tollworks('wall-70'),
    ArtTileCatalogEntry.tollworks('wall-71'),
    ArtTileCatalogEntry.tollworks('wall-72'),
    ArtTileCatalogEntry.tollworks('wall-73'),
    ArtTileCatalogEntry.tollworks('floor-26', floor: true),
    ArtTileCatalogEntry.tollworks('floor-27', floor: true),
  ];

  ArtTileCatalogEntry? find(String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  Iterable<ArtTileCatalogEntry> entriesForKit(String kitId) =>
      entries.where((entry) => entry.kitId == kitId);

  static const _moonwoodFootbridge = <ArtTileCatalogEntry>[
    ArtTileCatalogEntry.bridge(0, 0, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.bridge(0, 1, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.bridge(0, 2, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.bridge(0, 3, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.bridge(0, 4, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.bridge(0, 5, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.bridge(1, 0, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.bridge(1, 1, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.bridge(1, 2, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.bridge(1, 3, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.bridge(1, 4, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.bridge(1, 5, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.bridge(2, 0, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.bridge(2, 1, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.bridge(2, 2, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.bridge(2, 3, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.bridge(2, 4, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.bridge(2, 5, ArtTileDepthIntent.inFrontOfActor),
  ];

  static const _passengerQuay = <ArtTileCatalogEntry>[
    ArtTileCatalogEntry.quay('deck-nw'),
    ArtTileCatalogEntry.quay('deck-n'),
    ArtTileCatalogEntry.quay('deck-ne'),
    ArtTileCatalogEntry.quay('deck-w'),
    ArtTileCatalogEntry.quay('deck-center'),
    ArtTileCatalogEntry.quay('deck-e'),
    ArtTileCatalogEntry.quay('deck-sw'),
    ArtTileCatalogEntry.quay('deck-s'),
    ArtTileCatalogEntry.quay('deck-se'),
    ArtTileCatalogEntry.quay('deck-inner-se'),
    ArtTileCatalogEntry.quay('deck-inner-sw'),
    ArtTileCatalogEntry.quay('wall-left', retainingFace: true),
    ArtTileCatalogEntry.quay('wall-center', retainingFace: true),
    ArtTileCatalogEntry.quay('wall-right', retainingFace: true),
  ];

  static const _fairBridge = <ArtTileCatalogEntry>[
    ArtTileCatalogEntry.fairBridge(0, 0, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.fairBridge(0, 1, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.fairBridge(0, 2, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.fairBridge(0, 3, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.fairBridge(0, 4, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.fairBridge(0, 5, ArtTileDepthIntent.behindActor),
    ArtTileCatalogEntry.fairBridge(1, 0, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(1, 1, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(1, 2, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(1, 3, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(1, 4, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(1, 5, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(2, 0, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(2, 1, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(2, 2, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(2, 3, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(2, 4, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(2, 5, ArtTileDepthIntent.walkableSurface),
    ArtTileCatalogEntry.fairBridge(3, 0, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.fairBridge(3, 1, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.fairBridge(3, 2, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.fairBridge(3, 3, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.fairBridge(3, 4, ArtTileDepthIntent.inFrontOfActor),
    ArtTileCatalogEntry.fairBridge(3, 5, ArtTileDepthIntent.inFrontOfActor),
  ];
}

class ArtTileCatalogEntry {
  const ArtTileCatalogEntry(
    this.id,
    this.kitId, {
    this.row,
    this.column,
    this.depthIntent = ArtTileDepthIntent.standard,
  });

  const ArtTileCatalogEntry.bridge(
    int row,
    int column,
    ArtTileDepthIntent depthIntent,
  ) : this(
        'tiles/world/moonwood_footbridge/'
        'moonwood-footbridge-r$row-c$column.png',
        ArtTileCatalog.moonwoodFootbridgeKit,
        row: row,
        column: column,
        depthIntent: depthIntent,
      );

  const ArtTileCatalogEntry.quay(String piece, {bool retainingFace = false})
    : this(
        'tiles/world/passenger_quay/$piece.png',
        ArtTileCatalog.passengerQuayKit,
        depthIntent: retainingFace
            ? ArtTileDepthIntent.inFrontOfActor
            : ArtTileDepthIntent.walkableSurface,
      );

  const ArtTileCatalogEntry.fairBridge(
    int row,
    int column,
    ArtTileDepthIntent depthIntent,
  ) : this(
        'tiles/world/fair_bridge/fair-bridge-r$row-c$column.png',
        ArtTileCatalog.fairBridgeKit,
        row: row,
        column: column,
        depthIntent: depthIntent,
      );

  const ArtTileCatalogEntry.tollworks(String piece, {bool floor = false})
    : this(
        'tiles/world/tollworks/$piece.png',
        ArtTileCatalog.tollworksKit,
        depthIntent: floor
            ? ArtTileDepthIntent.walkableSurface
            : ArtTileDepthIntent.standard,
      );

  final String id;
  final String kitId;
  final int? row;
  final int? column;
  final ArtTileDepthIntent depthIntent;

  String get assetPath => id;
  int get width => 32;
  int get height => 32;
}

enum ArtTileDepthIntent {
  standard,
  behindActor,
  walkableSurface,
  inFrontOfActor,
}
