import '../content/strict_json_reader.dart';
import 'routine_model.dart';

final class RoutineCatalogEntry {
  const RoutineCatalogEntry({
    required this.schemaVersion,
    required this.id,
    required this.assetPath,
  });

  final int schemaVersion;
  final String id;
  final String assetPath;

  factory RoutineCatalogEntry.fromJson(
    Map<String, Object?> json, {
    required String path,
  }) {
    StrictJsonReader.requireExactKeys(json, const {
      'schemaVersion',
      'id',
      'asset',
    }, path);
    return RoutineCatalogEntry(
      schemaVersion: StrictJsonReader.integer(json, 'schemaVersion', path),
      id: StrictJsonReader.string(json, 'id', path),
      assetPath: StrictJsonReader.string(json, 'asset', path),
    );
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'asset': assetPath,
  };
}

/// Versioned deterministic index of separately authored routine records.
final class RoutineCatalogIndex {
  factory RoutineCatalogIndex({
    required int schemaVersion,
    required Iterable<RoutineCatalogEntry> entries,
  }) {
    final sourceEntries = List<RoutineCatalogEntry>.of(entries);
    final diagnostics = <String>[];
    if (schemaVersion != currentSchemaVersion) {
      diagnostics.add(
        r'$.schemaVersion: Expected schema version '
        '$currentSchemaVersion, got $schemaVersion.',
      );
    }
    final firstIdIndex = <String, int>{};
    final firstAssetIndex = <String, int>{};
    for (final (index, entry) in sourceEntries.indexed) {
      final path = '\$.routines[$index]';
      if (entry.schemaVersion != currentSchemaVersion) {
        diagnostics.add(
          '$path.schemaVersion: Expected schema version '
          '$currentSchemaVersion, got ${entry.schemaVersion}.',
        );
      }
      _validateText(entry.id, '$path.id', 'Routine ID', diagnostics);
      _validateText(entry.assetPath, '$path.asset', 'Asset path', diagnostics);
      final firstId = firstIdIndex[entry.id];
      if (firstId == null) {
        firstIdIndex[entry.id] = index;
      } else {
        diagnostics.add(
          '$path.id: Duplicate routine ID "${entry.id}"; first declared at '
          '\$.routines[$firstId].id.',
        );
      }
      final firstAsset = firstAssetIndex[entry.assetPath];
      if (firstAsset == null) {
        firstAssetIndex[entry.assetPath] = index;
      } else {
        diagnostics.add(
          '$path.asset: Duplicate routine asset "${entry.assetPath}"; first '
          'declared at \$.routines[$firstAsset].asset.',
        );
      }
    }
    diagnostics.sort();
    if (diagnostics.isNotEmpty) {
      throw FormatException(
        'Routine catalog index is invalid:\n${diagnostics.join('\n')}',
      );
    }
    sourceEntries.sort((left, right) => left.id.compareTo(right.id));
    return RoutineCatalogIndex._(
      schemaVersion,
      List.unmodifiable(sourceEntries),
    );
  }

  const RoutineCatalogIndex._(this.schemaVersion, this.entries);

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final List<RoutineCatalogEntry> entries;

  factory RoutineCatalogIndex.fromJson(Map<String, Object?> json) {
    StrictJsonReader.requireExactKeys(json, const {
      'schemaVersion',
      'routines',
    }, r'$');
    final values = StrictJsonReader.list(json, 'routines', r'$');
    return RoutineCatalogIndex(
      schemaVersion: StrictJsonReader.integer(json, 'schemaVersion', r'$'),
      entries: [
        for (final (index, value) in values.indexed)
          RoutineCatalogEntry.fromJson(
            StrictJsonReader.object(value, '\$.routines[$index]'),
            path: '\$.routines[$index]',
          ),
      ],
    );
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'routines': [for (final entry in entries) entry.toJson()],
  };
}

/// Immutable routine registry sorted by stable routine ID.
final class RoutineCatalog {
  factory RoutineCatalog({required Iterable<RoutineDefinition> routines}) {
    final definitions = List<RoutineDefinition>.of(routines)
      ..sort((left, right) => left.id.compareTo(right.id));
    final diagnostics = <String>[];
    final firstIndexById = <String, int>{};
    for (final (index, routine) in definitions.indexed) {
      final routineDiagnostics = const RoutineDefinitionValidator().validate(
        routine,
        path: '\$.routines[$index]',
      );
      diagnostics.addAll(
        routineDiagnostics.map((diagnostic) => diagnostic.toString()),
      );
      final firstIndex = firstIndexById[routine.id];
      if (firstIndex == null) {
        firstIndexById[routine.id] = index;
      } else {
        diagnostics.add(
          '\$.routines[$index].id: Duplicate routine ID "${routine.id}"; '
          'first declared at \$.routines[$firstIndex].id.',
        );
      }
    }
    diagnostics.sort();
    if (diagnostics.isNotEmpty) {
      throw FormatException(
        'Routine catalog is invalid:\n${diagnostics.join('\n')}',
      );
    }
    return RoutineCatalog._(List.unmodifiable(definitions));
  }

  RoutineCatalog._(this.routines)
    : byId = Map.unmodifiable({
        for (final routine in routines) routine.id: routine,
      }),
      routineIds = List.unmodifiable(routines.map((routine) => routine.id));

  final List<RoutineDefinition> routines;
  final Map<String, RoutineDefinition> byId;
  final List<String> routineIds;

  bool containsId(String id) => byId.containsKey(id);

  RoutineDefinition? findById(String id) => byId[id];
}

void _validateText(
  String value,
  String path,
  String label,
  List<String> diagnostics,
) {
  if (value.trim().isEmpty) {
    diagnostics.add('$path: $label cannot be blank.');
  } else if (value != value.trim()) {
    diagnostics.add('$path: $label cannot have surrounding whitespace.');
  }
}
