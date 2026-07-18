import 'dart:async' show unawaited;

import 'package:cryprice_frontend/core/shell/app_shell.dart';
import 'package:cryprice_frontend/core/web/app_update_listener.dart';
import 'package:cryprice_frontend/features/auth/presentation/auth_error_messages.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/features/push_notifications/presentation/push_notification_coordinator.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:cryprice_frontend/features/auth/presentation/widgets/show_account_access_login.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_cubit.dart';
import 'package:cryprice_frontend/core/di/di.dart';
import 'package:cryprice_frontend/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cryprice_frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void _showGoogleAuthRedirectErrorSnackBar(BuildContext context, String? errorMessage) {
  final loc = AppLocalizations.of(context)!;
  final message = resolveAuthErrorMessage(loc, errorMessage);
  if (message == null) {
    return;
  }
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// Shows redirect errors set in [main] before the first frame.
class _AuthRedirectErrorBootstrap extends StatefulWidget {
  const _AuthRedirectErrorBootstrap({required this.child});

  final Widget child;

  @override
  State<_AuthRedirectErrorBootstrap> createState() => _AuthRedirectErrorBootstrapState();
}

class _AuthRedirectErrorBootstrapState extends State<_AuthRedirectErrorBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final state = context.read<AuthCubit>().state;
      if (state is AuthStateUnauthenticated &&
          state.errorMessage == kGoogleAuthRedirectFailedErrorCode) {
        _showGoogleAuthRedirectErrorSnackBar(context, state.errorMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Root: restores session in [main].
///
/// Loading → spinner. Otherwise → [AppShell] (guest or authenticated).
class AppAuthGate extends StatelessWidget {
  const AppAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AppUpdateListener(
      child: _AuthRedirectErrorBootstrap(
        child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (AuthState previous, AuthState current) {
          if (current is AuthStateUnauthenticated &&
              previous is AuthStateAuthenticated) {
            return true;
          }
          if (current is AuthStateAuthenticated &&
              previous is! AuthStateAuthenticated) {
            return true;
          }
          if (current is AuthStateUnauthenticated &&
              current.errorMessage == kGoogleAuthRedirectFailedErrorCode &&
              previous is! AuthStateUnauthenticated) {
            return true;
          }
          return false;
        },
        listener: (BuildContext context, AuthState state) {
          if (state is AuthStateAuthenticated) {
            unawaited(di<PushNotificationCoordinator>().onAuthenticated());
          }
          if (state is AuthStateUnauthenticated &&
              state.errorMessage == kGoogleAuthRedirectFailedErrorCode) {
            _showGoogleAuthRedirectErrorSnackBar(context, state.errorMessage);
            return;
          }
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthStateLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final authCubit = context.read<AuthCubit>();
            return AppShell(
              key: ValueKey<String>('app_shell_${authCubit.sessionEpoch}'),
              onProfile: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider<ProfileCubit>(create: (_) => di<ProfileCubit>()),
                        BlocProvider<AlertRulesCubit>(create: (_) => di<AlertRulesCubit>()),
                      ],
                      child: const ProfilePage(),
                    ),
                  ),
                );
              },
              onLogin: () => showAccountAccessLoginSheet(context),
              onLogout: () {
                context.read<AuthCubit>().signOut();
              },
            );
          },
        ),
        ),
      ),
    );
  }
}
