/// Non-web stub: no service worker update checks.
Future<bool> checkForAppUpdate() async => false;

Future<void> activatePendingAppUpdate() async {}

Future<void> applyDeferredAppUpdateAfterAuth() async {}

bool get isAppUpdateCheckSupported => false;

bool get hasDeferredAppUpdate => false;
