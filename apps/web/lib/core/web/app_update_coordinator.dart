import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/web/app_update_service.dart';

/// Called when Google auth finishes so deferred SW reload/update can proceed.
Future<void> onAuthFlowEndedForAppUpdate() async {
  if (isAuthFlowInProgress()) {
    return;
  }
  await applyDeferredAppUpdateAfterAuth();
}
