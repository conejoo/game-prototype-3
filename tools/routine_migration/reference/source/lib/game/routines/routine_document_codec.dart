import 'dart:convert';

import 'routine_model.dart';

/// Canonical editor/runtime codec for one routine definition.
final class RoutineDocumentCodec {
  const RoutineDocumentCodec();

  RoutineDefinition decode(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException('Invalid routine JSON: ${error.message}');
    }
    if (decoded is! Map) {
      throw const FormatException('Routine root must be an object.');
    }
    return RoutineDefinition.fromJson(Map<String, Object?>.from(decoded));
  }

  String encode(RoutineDefinition routine) =>
      '${const JsonEncoder.withIndent('  ').convert(routine.toJson())}\n';
}
