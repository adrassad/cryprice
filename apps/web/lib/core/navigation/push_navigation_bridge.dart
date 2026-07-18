import 'dart:async';

import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:cryprice_frontend/core/shell/cubit/shell_navigation_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';

/// Decouples push routing from [BuildContext].
abstract class PushNavigationBridge {
  void openPortfolio();

  void openAlerts({String? alertId});
}

class PushNavigationBridgeStub implements PushNavigationBridge {
  @override
  void openPortfolio() {}

  @override
  void openAlerts({String? alertId}) {}
}

/// DI singleton; [AppShell] binds [ShellPushNavigationBridge] at runtime.
class MutablePushNavigationBridge implements PushNavigationBridge {
  PushNavigationBridge _delegate = PushNavigationBridgeStub();

  void bind(PushNavigationBridge delegate) {
    _delegate = delegate;
  }

  void reset() {
    _delegate = PushNavigationBridgeStub();
  }

  @override
  void openPortfolio() => _delegate.openPortfolio();

  @override
  void openAlerts({String? alertId}) => _delegate.openAlerts(alertId: alertId);
}

class ShellPushNavigationBridge implements PushNavigationBridge {
  ShellPushNavigationBridge(
    this._shellNavigationCubit,
    this._alertsInboxCubit,
  );

  final ShellNavigationCubit _shellNavigationCubit;
  final AlertsInboxCubit _alertsInboxCubit;

  @override
  void openPortfolio() {
    _shellNavigationCubit.selectSection(AppSection.portfolio);
  }

  @override
  void openAlerts({String? alertId}) {
    if (_shellNavigationCubit.state.selectedSection != AppSection.alerts) {
      _shellNavigationCubit.selectSection(AppSection.alerts);
    }

    final trimmedAlertId = alertId?.trim();
    if (trimmedAlertId == null || trimmedAlertId.isEmpty) {
      return;
    }

    unawaited(_alertsInboxCubit.focusAlert(trimmedAlertId));
  }
}
