import 'dart:convert';
import 'dart:io';

import 'package:cozy_life_adventure/game/dialogue/dialogue_model.dart';
import 'package:cozy_life_adventure/game/navigation/navigation.dart';
import 'package:cozy_life_adventure/game/npc/npc_content.dart';
import 'package:cozy_life_adventure/game/routines/routine_catalog_loader.dart';
import 'package:cozy_life_adventure/game/routines/routine_content_validator.dart';
import 'package:cozy_life_adventure/game/routines/routine_model.dart';
import 'package:cozy_life_adventure/game/world_events/world_event_catalog.dart';
import 'package:cozy_life_adventure/world_map/map_project.dart';
import 'package:cozy_life_adventure/world_map/world_map.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../world_map/world_map_test_fixtures.dart';

void main() {
  group('RoutineContentValidator', () {
    test(
      'accepts documented solo/group fixtures through generic navigation',
      () async {
        final fixture = _FixtureContent();
        final navigation = _RecordingNavigationService(
          GridWorldNavigationService(mapSource: fixture.mapSource),
        );
        final catalog = await const RoutineCatalogLoader(
          source: _FileRoutineContentSource(),
          catalogPath: 'test/fixtures/routines/catalog.valid.json',
        ).load();
        final documents = [
          for (final routine in catalog.routines)
            RoutineContentDocument(
              filePath: switch (routine.id) {
                'fixture-solo-day' =>
                  'test/fixtures/routines/valid/fixture_solo_day.json',
                _ =>
                  'test/fixtures/routines/valid/fixture_group_overnight.json',
              },
              routine: routine,
            ),
        ];

        final diagnostics = const RoutineContentValidator().validate(
          documents: documents,
          worldEvents: fixture.worldEvents,
          npcs: fixture.npcs,
          maps: fixture.maps,
          navigation: navigation,
        );

        expect(diagnostics, isEmpty);
        expect(navigation.requests, isNotEmpty);
        expect(
          navigation.requests.map((request) => request.agentProfile.id),
          everyElement('fixture-adult'),
        );
        expect(
          navigation.requests.expand((request) => request.dynamicBlockers),
          isEmpty,
        );
      },
    );

    test('reports every cross-content reference at stable source fields', () {
      final fixture = _FixtureContent();
      const filePath =
          'test/fixtures/routines/invalid/fixture_invalid_references.json';
      final diagnostics = const RoutineContentValidator().validate(
        documents: [_document(filePath)],
        worldEvents: fixture.worldEvents,
        npcs: fixture.npcs,
        maps: fixture.maps,
        navigation: GridWorldNavigationService(mapSource: fixture.mapSource),
      );
      final fields = diagnostics
          .map((diagnostic) => diagnostic.fieldPath)
          .toSet();

      expect(
        fields,
        containsAll({
          r'$.conditions[0].eventId',
          r'$.conditions[1].factId',
          r'$.conditions[2].flagId',
          r'$.conditions[3].npcId',
          r'$.conditions[4].targetId',
          r'$.interactionPolicy.defaultDialogueEntryNodeId',
          r'$.interactionPolicy.stepDialogueEntries[0].dialogueEntryNodeId',
          r'$.interactionPolicy.outcomeDirectives[0].outcomeTag',
          r'$.interactionPolicy.outcomeDirectives[0].directive.eventId',
          r'$.participantSteps[0].steps[0].target.anchorId',
          r'$.participantSteps[0].steps[1].target.mapId',
          r'$.participantSteps[0].steps[2].actionId',
        }),
      );
      expect(
        diagnostics
            .singleWhere(
              (diagnostic) => diagnostic.fieldPath.endsWith('.actionId'),
            )
            .toString(),
        allOf(
          contains(filePath),
          contains('[fixture-invalid-references]'),
          contains('(step "unknown-action")'),
          contains('missing-action'),
        ),
      );
    });

    test('rejects missing portal chains and unoccupiable anchors', () {
      final fixture = _FixtureContent();
      const filePath =
          'test/fixtures/routines/invalid/fixture_invalid_routes.json';
      List<RoutineContentDiagnostic> validate() =>
          const RoutineContentValidator().validate(
            documents: [_document(filePath)],
            worldEvents: fixture.worldEvents,
            npcs: fixture.npcs,
            maps: fixture.maps,
            navigation: GridWorldNavigationService(
              mapSource: fixture.mapSource,
            ),
          );

      final diagnostics = validate();

      expect(
        diagnostics.map((diagnostic) => diagnostic.cause),
        containsAll([
          contains('No authored portal chain'),
          contains('not statically occupiable'),
        ]),
      );
      expect(
        validate().map((diagnostic) => diagnostic.toString()),
        diagnostics.map((diagnostic) => diagnostic.toString()),
      );
    });

    test('rejects a portal chain with an unreachable static leg', () async {
      final fixture = _FixtureContent(blockTownPortal: true);
      final catalog = await const RoutineCatalogLoader(
        source: _FileRoutineContentSource(),
        catalogPath: 'test/fixtures/routines/catalog.valid.json',
      ).load();
      final group = catalog.findById('fixture-group-overnight')!;

      final diagnostics = const RoutineContentValidator().validate(
        documents: [
          RoutineContentDocument(
            filePath:
                'test/fixtures/routines/valid/fixture_group_overnight.json',
            routine: group,
          ),
        ],
        worldEvents: fixture.worldEvents,
        npcs: fixture.npcs,
        maps: fixture.maps,
        navigation: GridWorldNavigationService(mapSource: fixture.mapSource),
      );

      expect(diagnostics, hasLength(1));
      expect(diagnostics.single.stepId, 'b-return');
      expect(diagnostics.single.cause, contains('unreachable leg'));
    });
  });
}

RoutineContentDocument _document(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  return RoutineContentDocument(
    filePath: path,
    routine: RoutineDefinition.fromJson(
      (decoded as Map).cast<String, Object?>(),
    ),
  );
}

final class _FixtureContent {
  _FixtureContent({bool blockTownPortal = false}) {
    final town = validWorld(
      mapId: 'fixture-town',
      columns: 10,
      rows: 10,
      playerSpawn: const WorldMapPoint(x: 32, y: 32),
      objects: [
        RoutineAnchorMapObject(id: 'fixture-square', x: 32, y: 32),
        RoutineAnchorMapObject(id: 'fixture-harbor-west', x: 48, y: 64),
        RoutineAnchorMapObject(id: 'fixture-harbor-east', x: 96, y: 64),
        const ResourceNodeMapObject(
          id: 'fixture-moonflower',
          definitionId: 'moonflower',
          x: 64,
          y: 96,
        ),
      ],
      colliders: const [],
      portals: const [
        WorldMapPortal(
          id: 'fixture-home-door',
          label: 'Fixture home',
          prompt: 'Enter',
          left: 160,
          top: 144,
          width: 32,
          height: 32,
          destinationMapId: 'fixture-home',
          destinationX: 32,
          destinationY: 32,
        ),
      ],
    );
    final home = validWorld(
      mapId: 'fixture-home',
      columns: 6,
      rows: 6,
      playerSpawn: const WorldMapPoint(x: 32, y: 32),
      objects: [RoutineAnchorMapObject(id: 'fixture-entry', x: 64, y: 64)],
      colliders: const [],
    );
    final isolated = validWorld(
      mapId: 'fixture-isolated',
      columns: 6,
      rows: 6,
      playerSpawn: const WorldMapPoint(x: 32, y: 32),
      objects: [
        RoutineAnchorMapObject(id: 'fixture-isolated-open', x: 64, y: 64),
        RoutineAnchorMapObject(id: 'fixture-isolated-blocked', x: 128, y: 128),
      ],
      colliders: const [],
    );
    final mapValues = {
      town.mapId: town,
      home.mapId: home,
      isolated.mapId: isolated,
    };
    maps = LoadedMapProject(
      project: MapProject(
        entryMapId: town.mapId,
        maps: [
          for (final map in mapValues.values)
            MapProjectMap(
              mapId: map.mapId,
              displayLabel: map.mapId,
              jsonPath: '${map.mapId}.json',
            ),
        ],
      ),
      maps: mapValues,
    );
    mapSource = _FixtureMapSource({
      town.mapId: _FixtureStaticMap(
        town,
        blockedPoints: {if (blockTownPortal) (176.0, 160.0)},
      ),
      home.mapId: _FixtureStaticMap(home),
      isolated.mapId: _FixtureStaticMap(
        isolated,
        blockedPoints: {(128.0, 128.0)},
      ),
    });
  }

  final WorldEventCatalog worldEvents = WorldEventCatalog(
    events: const [
      WorldEventDefinition(schemaVersion: 1, id: 'harbor-festival'),
      WorldEventDefinition(schemaVersion: 1, id: 'heavy-rain'),
    ],
  );
  final NpcCatalog npcs = NpcCatalog(
    npcs: [_npc('npc-fixture-a'), _npc('npc-fixture-b')],
  );
  late final LoadedMapProject maps;
  late final _FixtureMapSource mapSource;
}

NpcPackage _npc(String id) {
  final isFirst = id == 'npc-fixture-a';
  final outcomeTags = isFirst
      ? const [
          'continue-work',
          'resume-group',
          'repeat-task',
          'finish-tonight',
          'start-festival',
          'clear-rain',
        ]
      : const <String>[];
  final defaultNodeId = '$id-routine-default';
  final workingNodeId = '$id-routine-working';
  return NpcPackage(
    entry: NpcCatalogEntry(
      id: id,
      runtimePath: '$id/runtime.json',
      dialoguePath: '$id/dialogue.json',
      visualsPath: '$id/visuals.json',
    ),
    runtime: NpcRuntimeManifest(
      id: id,
      displayName: id,
      shortName: id,
      title: 'Fixture',
      pronouns: 'they/them',
      interactionPrompt: 'Talk',
      relationship: NpcRelationshipDefinition.mvpDefault,
      dimensions: const NpcDimensions(
        hitWidth: 16,
        hitHeight: 16,
        interactionRadius: 32,
      ),
      routine: NpcRoutineDefinition(
        agentProfile: NavigationAgentProfile(
          id: 'fixture-adult',
          footprintRadius: 2,
        ),
        actionIds: [isFirst ? 'write-notes' : 'inspect-crates'],
        relationshipFlagIds: isFirst
            ? const ['npc-fixture-a-greeted', 'npc-fixture-a-busy']
            : const [],
      ),
      facts: isFirst
          ? const [
              NpcFactDefinition(
                id: 'npc-fixture-a-known-route',
                category: 'Fixture',
                label: 'Route',
                description: 'Known route.',
                highlightTerm: 'route',
              ),
            ]
          : const [],
      acceptedGiftRules: const [],
    ),
    dialogue: DialogueGraph(
      npcId: id,
      entryNodeIds: [defaultNodeId],
      nodes: [
        DialogueNode(
          id: defaultNodeId,
          npcId: id,
          speaker: id,
          text: 'Default.',
          priority: 1,
        ),
        DialogueNode(
          id: workingNodeId,
          npcId: id,
          speaker: id,
          text: 'Working.',
          priority: 1,
          choices: [
            for (final tag in outcomeTags)
              DialogueChoice(
                id: '$id-$tag',
                text: tag,
                outcomeTag: tag,
                endsConversation: true,
              ),
          ],
        ),
      ],
    ),
    visuals: NpcVisualManifest(
      npcId: id,
      portraitPaths: const {},
      world: NpcWorldVisualManifest(
        worldCellWidth: 48,
        worldCellHeight: 48,
        rowOrder: ['south', 'north', 'west', 'east'],
        idle: NpcAnimationManifest(
          assetPath: 'idle.png',
          textureCellWidth: 192,
          textureCellHeight: 192,
          framesPerFacing: 4,
          stepSeconds: 0.2,
        ),
        walk: NpcAnimationManifest(
          assetPath: 'walk.png',
          textureCellWidth: 192,
          textureCellHeight: 192,
          framesPerFacing: 3,
          stepSeconds: 0.2,
        ),
        actions: const {},
      ),
    ),
  );
}

final class _FixtureMapSource implements NavigationStaticMapSource {
  const _FixtureMapSource(this.maps);

  final Map<String, NavigationStaticMap> maps;

  @override
  NavigationStaticMap? mapFor(String mapId) => maps[mapId];
}

final class _FixtureStaticMap implements NavigationStaticMap {
  _FixtureStaticMap(
    WorldMap map, {
    Set<(double, double)> blockedPoints = const {},
  }) : mapId = map.mapId,
       staticRevision = '${map.mapId}-v1',
       bounds = NavigationMapBounds(
         left: 0,
         top: 0,
         width: map.width,
         height: map.height,
       ),
       _blockedPoints = Set.unmodifiable(blockedPoints);

  @override
  final String mapId;

  @override
  final String staticRevision;

  @override
  final NavigationMapBounds bounds;

  final Set<(double, double)> _blockedPoints;

  @override
  bool canOccupy(NavigationPoint point, NavigationAgentProfile agentProfile) {
    final radius = agentProfile.requiredRadius;
    return point.x - radius >= bounds.left &&
        point.x + radius <= bounds.right &&
        point.y - radius >= bounds.top &&
        point.y + radius <= bounds.bottom &&
        !_blockedPoints.contains((point.x, point.y));
  }

  @override
  bool allowsStaticTraversal(NavigationTraversal traversal) =>
      canOccupy(traversal.from, traversal.agentProfile) &&
      canOccupy(traversal.to, traversal.agentProfile);
}

final class _RecordingNavigationService implements WorldNavigationService {
  _RecordingNavigationService(this.delegate);

  final WorldNavigationService delegate;
  final List<NavigationPathRequest> requests = [];

  @override
  NavigationPathResult findPath(NavigationPathRequest request) {
    requests.add(request);
    return delegate.findPath(request);
  }

  @override
  bool isReachable(NavigationPathRequest request) =>
      findPath(request) is NavigationPathSuccess;

  @override
  void invalidateMap(String mapId) => delegate.invalidateMap(mapId);
}

final class _FileRoutineContentSource implements RoutineContentSource {
  const _FileRoutineContentSource();

  @override
  Future<String> read(String assetPath) => File(assetPath).readAsString();
}
