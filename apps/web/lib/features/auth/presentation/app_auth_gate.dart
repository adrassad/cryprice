import 'package:cryprice_frontend/core/di/di.dart';
import 'package:cryprice_frontend/core/shell/app_shell.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_cubit.dart';
import 'package:cryprice_frontend/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cryprice_frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Root: restores session in [main].
///
/// Unauthenticated → [LoginPage] only (theme, locale, Google sign-in).
/// Authenticated → [AppShell] only (dashboard chrome + sections).
class AppAuthGate extends StatelessWidget {
  const AppAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is AuthStateAuthenticated) {
          return AppShell(
            key: const ValueKey('app_shell_authenticated'),
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
            onLogin: () {
              // Unauthenticated users never see [AppShell]; no-op for menu contract.
            },
            onLogout: () {
              context.read<AuthCubit>().signOut();
            },
          );
        }
        return const LoginPage(key: ValueKey('login_page_unauthenticated'));
      },
    );
  }
}
