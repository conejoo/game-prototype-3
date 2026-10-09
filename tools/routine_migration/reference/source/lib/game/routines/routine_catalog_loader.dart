import 'dart:convert';

import 'routine_catalog.dart';
import 'routine_content_validator.dart';
import 'routine_model.dart';

abstract interface class RoutineContentSource {
  Future<String> read(String assetPath);
}

final class LoadedRoutineCatalog {
  const LoadedRoutineCatalog({
    required this.index,
    required this.catalog,
    required this.documents,
  });

  final RoutineCatalogIndex index;
  final RoutineCatalog catalog;
  final List<RoutineContentDocument> documents;
}

/// Pure-Dart routine loader; file and Flutter asset access stay in adapters.
final class RoutineCatalogLoader {
  const RoutineCatalogLoader({
    required this.source,
    this.catalogPath = 'assets/data/routines/catalog.json',
  });

  final RoutineContentSource source;
  final String catalogPath;

  Future<RoutineCatalog> load() async => (await loadWithDocuments()).catalog;

  Future<LoadedRoutineCatalog> loadWithDocuments() async {
    final RoutineCatalogIndex index;
    try {
      index = RoutineCatalogIndex.fromJson(await _decodeObject(catalogPath));
    } on FormatException catch (error) {
      throw FormatException('$catalogPath: ${error.message}');
    }
    final routines = <RoutineDefinition>[];
    final documents = <RoutineContentDocument>[];
    for (final entry in index.entries) {
      final RoutineDefinition routine;
      try {
        routine = RoutineDefinition.fromJson(
          await _decodeObject(entry.assetPath),
        );
      } on FormatException catch (error) {
        throw FormatException('${entry.assetPath}: ${error.message}');
      }
      if (routine.id != entry.id) {
        throw FormatException(
          '${entry.assetPath}: \$.id: Expected catalog ID "${entry.id}", '
          'got "${routine.id}".',
        );
      }
      routines.add(routine);
      documents.add(
        RoutineContentDocument(filePath: entry.assetPath, routine: routine),
      );
    }
    return LoadedRoutineCatalog(
      index: index,
      catalog: RoutineCatalog(routines: routines),
      documents: List.unmodifiable(documents),
    );
  }

  Future<Map<String, Object?>> _decodeObject(String path) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(await source.read(path));
    } on FormatException catch (error) {
      throw FormatException(error.message);
    }
    if (decoded is! Map) {
      throw const FormatException('Root value must be an object.');
    }
    final result = <String, Object?>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String) {
        throw const FormatException('Root keys must be strings.');
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }
}
