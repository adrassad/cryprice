bool get isAppShellReloadSupported => false;

/// Clears app-shell caches and reloads without touching auth tokens or user prefs.
Future<void> performAppShellReload({String? buildId}) async {}
