import 'package:crypto_tracker_app/core/di/di.dart';
import 'package:crypto_tracker_app/core/cubit/locale_cubit.dart';
import 'package:crypto_tracker_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:crypto_tracker_app/features/auth/presentation/pages/login_page.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/cubit/crypto_cubit.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/pages/crypto_page.dart';
import 'package:crypto_tracker_app/features/theme/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Root: restores session in [main], then switches between [LoginPage] and the main [CryptoPage].
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
          return BlocProvider<TitleCubit>(
            key: const ValueKey('title_cubit_session'),
            create: (_) => di<TitleCubit>(),
            child: CryptoPage(
              onToggleLocale: () {
                context.read<LocaleCubit>().toggleLocale();
              },
              onToggleTheme: () {
                context.read<ThemeCubit>().toggleTheme();
              },
              onLogout: () {
                context.read<AuthCubit>().signOut();
              },
            ),
          );
        }
        return const LoginPage();
      },
    );
  }
}
