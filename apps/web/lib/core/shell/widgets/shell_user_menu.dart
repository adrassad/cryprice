import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _ShellUserMenuAction { profile, login, logout }

/// Top-right user menu driven by [AuthCubit]; navigation via parent callbacks.
class ShellUserMenu extends StatelessWidget {
  const ShellUserMenu({
    super.key,
    required this.onProfile,
    required this.onLogin,
    required this.onLogout,
  });

  final VoidCallback onProfile;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState state) {
        final bool isLoading = state is AuthStateLoading;
        final bool isAuthenticated = state is AuthStateAuthenticated;

        return PopupMenuButton<_ShellUserMenuAction>(
          tooltip: isAuthenticated ? loc.menuProfile : loc.logIn,
          enabled: !isLoading,
          icon: Icon(
            isAuthenticated ? Icons.account_circle : Icons.account_circle_outlined,
          ),
          onSelected: (_ShellUserMenuAction action) {
            switch (action) {
              case _ShellUserMenuAction.profile:
                onProfile();
              case _ShellUserMenuAction.login:
                onLogin();
              case _ShellUserMenuAction.logout:
                onLogout();
            }
          },
          itemBuilder: (BuildContext context) {
            final menuLoc = AppLocalizations.of(context)!;
            if (state is AuthStateAuthenticated) {
              return <PopupMenuEntry<_ShellUserMenuAction>>[
                PopupMenuItem<_ShellUserMenuAction>(
                  value: _ShellUserMenuAction.profile,
                  child: _ShellUserMenuRow(
                    icon: Icons.person_outline,
                    label: menuLoc.menuProfile,
                  ),
                ),
                PopupMenuItem<_ShellUserMenuAction>(
                  value: _ShellUserMenuAction.logout,
                  child: _ShellUserMenuRow(
                    icon: Icons.logout,
                    label: menuLoc.logOut,
                  ),
                ),
              ];
            }
            if (state is AuthStateUnauthenticated) {
              return <PopupMenuEntry<_ShellUserMenuAction>>[
                PopupMenuItem<_ShellUserMenuAction>(
                  value: _ShellUserMenuAction.login,
                  child: _ShellUserMenuRow(
                    icon: Icons.login,
                    label: menuLoc.logIn,
                  ),
                ),
              ];
            }
            return const <PopupMenuEntry<_ShellUserMenuAction>>[];
          },
        );
      },
    );
  }
}

class _ShellUserMenuRow extends StatelessWidget {
  const _ShellUserMenuRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    );
  }
}
