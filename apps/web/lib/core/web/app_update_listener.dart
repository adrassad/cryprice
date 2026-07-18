import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/web/app_shell_reload_service.dart';
import 'package:cryprice_frontend/core/web/app_update_service.dart';
import 'package:cryprice_frontend/core/web/app_version_info.dart';
import 'package:cryprice_frontend/core/web/app_version_service.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Checks deploy version metadata and waiting service workers; offers safe reload.
class AppUpdateListener extends StatefulWidget {
  const AppUpdateListener({super.key, required this.child});

  final Widget child;

  /// Tests only: run update checks on the VM host.
  @visibleForTesting
  static bool debugForceUpdateChecks = false;

  @override
  State<AppUpdateListener> createState() => _AppUpdateListenerState();
}

class _AppUpdateListenerState extends State<AppUpdateListener> {
  bool _updatePromptShown = false;
  bool _authRecoveryPromptShown = false;
  bool _manualInstructionsShown = false;
  String? _pendingReloadBuildId;

  @override
  void initState() {
    super.initState();
    if (kIsWeb || AppUpdateListener.debugForceUpdateChecks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
    }
  }

  Future<void> _checkForUpdates() async {
    if (!mounted || isAuthFlowInProgress()) {
      return;
    }

    final versionResult = await checkAppVersionChange();
    if (!mounted || isAuthFlowInProgress()) {
      return;
    }

    if (versionResult == AppVersionCheckResult.reloadAlreadyAttempted) {
      _showManualReloadInstructions();
      return;
    }

    final swWaiting = isAppUpdateCheckSupported && await checkForAppUpdate();
    if (!mounted || isAuthFlowInProgress()) {
      return;
    }

    final needsUpdate =
        versionResult == AppVersionCheckResult.updateAvailable || swWaiting;
    if (needsUpdate) {
      final remote = await fetchRemoteAppVersion();
      _pendingReloadBuildId = remote?.build;
      _showAppUpdateBanner();
    }
  }

  Future<void> _reloadApp() async {
    if (isAuthFlowInProgress()) {
      return;
    }
    final buildId = _pendingReloadBuildId ?? (await fetchRemoteAppVersion())?.build;
    if (isAppShellReloadSupported) {
      await performAppShellReload(buildId: buildId);
      return;
    }
    if (isAppUpdateCheckSupported) {
      await activatePendingAppUpdate();
    }
  }

  void _showAppUpdateBanner() {
    if (!mounted || _updatePromptShown || isAuthFlowInProgress()) {
      return;
    }
    _updatePromptShown = true;
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(loc.appUpdateAvailable),
        action: SnackBarAction(
          label: loc.appUpdateReload,
          onPressed: _reloadApp,
        ),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  void _showAuthRecoveryBanner() {
    if (!mounted || _authRecoveryPromptShown || isAuthFlowInProgress()) {
      return;
    }
    _authRecoveryPromptShown = true;
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(loc.authStaleRecoveryMessage),
        action: SnackBarAction(
          label: loc.authStaleRecoveryReload,
          onPressed: _reloadApp,
        ),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  void _showManualReloadInstructions() {
    if (!mounted || _manualInstructionsShown || isAuthFlowInProgress()) {
      return;
    }
    _manualInstructionsShown = true;
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(loc.appUpdateManualInstructions),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  AuthCubit? _readAuthCubit(BuildContext context) {
    try {
      return context.read<AuthCubit>();
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_readAuthCubit(context) == null) {
      return widget.child;
    }
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) {
        return current is AuthStateUnauthenticated && current.suggestAuthReload;
      },
      listener: (BuildContext context, AuthState state) {
        if (state is AuthStateUnauthenticated && state.suggestAuthReload) {
          _showAuthRecoveryBanner();
        }
      },
      child: widget.child,
    );
  }
}
