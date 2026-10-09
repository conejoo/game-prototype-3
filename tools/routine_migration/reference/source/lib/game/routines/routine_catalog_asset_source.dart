import 'package:flutter/services.dart';

import 'routine_catalog_loader.dart';

/// Flutter asset adapter kept outside pure-Dart routine catalog logic.
final class AssetBundleRoutineContentSource implements RoutineContentSource {
  const AssetBundleRoutineContentSource({this.bundle});

  final AssetBundle? bundle;

  static final Map<String, String> _bundledValues = {};
  static final Map<String, Future<String>> _bundledLoads = {};

  @override
  Future<String> read(String assetPath) {
    final injectedBundle = bundle;
    if (injectedBundle != null) {
      return injectedBundle.loadString(assetPath);
    }
    final cached = _bundledValues[assetPath];
    if (cached != null) {
      return Future.value(cached);
    }
    final pending = _bundledLoads[assetPath] ??= rootBundle.loadString(
      assetPath,
    );
    return pending.then(
      (value) {
        _bundledValues[assetPath] = value;
        _bundledLoads.remove(assetPath);
        return value;
      },
      onError: (Object error, StackTrace stackTrace) {
        _bundledLoads.remove(assetPath);
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
  }
}
