import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/features/auth/presentation/widgets/account_access_required_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shows [child] only when [AuthCubit] is authenticated; otherwise account-access panel.
///
/// [onAuthenticated] runs once when the user becomes authenticated while this gate
/// is mounted (including if already authenticated on first frame).
class AuthenticatedFeatureGate extends StatefulWidget {
  const AuthenticatedFeatureGate({
    super.key,
    required this.child,
    this.onAuthenticated,
  });

  final Widget child;
  final VoidCallback? onAuthenticated;

  @override
  State<AuthenticatedFeatureGate> createState() => _AuthenticatedFeatureGateState();
}

class _AuthenticatedFeatureGateState extends State<AuthenticatedFeatureGate> {
  bool _authenticatedCallbackDone = false;

  void _maybeNotifyAuthenticated(AuthState state) {
    if (_authenticatedCallbackDone || widget.onAuthenticated == null) {
      return;
    }
    if (state is AuthStateAuthenticated) {
      _authenticatedCallbackDone = true;
      widget.onAuthenticated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) {
        if (current is AuthStateAuthenticated &&
            previous is! AuthStateAuthenticated) {
          return true;
        }
        return false;
      },
      listener: (BuildContext context, AuthState state) {
        _maybeNotifyAuthenticated(state);
      },
      builder: (BuildContext context, AuthState state) {
        if (state is AuthStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AuthStateUnauthenticated) {
          _authenticatedCallbackDone = false;
          return const AccountAccessRequiredPanel(
            key: Key('account_access_required_panel'),
          );
        }
        if (state is AuthStateAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _maybeNotifyAuthenticated(state);
            }
          });
          return widget.child;
        }
        return const AccountAccessRequiredPanel(
          key: Key('account_access_required_panel'),
        );
      },
    );
  }
}
