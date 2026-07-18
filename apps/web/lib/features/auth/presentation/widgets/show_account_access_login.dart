import 'package:cryprice_frontend/core/shell/shell_visuals.dart';
import 'package:cryprice_frontend/features/auth/presentation/auth_error_messages.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/features/auth/presentation/widgets/login_google_cta.dart';
import 'package:cryprice_frontend/features/auth/presentation/widgets/login_trust_block.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens a modal sheet with read-only trust copy and Google account access CTA.
Future<void> showAccountAccessLoginSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return BlocListener<AuthCubit, AuthState>(
        listenWhen: (AuthState prev, AuthState next) =>
            next is AuthStateAuthenticated ||
            (next is AuthStateUnauthenticated && next.errorMessage != null),
        listener: (BuildContext context, AuthState state) {
          if (state is AuthStateAuthenticated) {
            Navigator.of(sheetContext).pop();
            return;
          }
          if (state is AuthStateUnauthenticated && state.errorMessage != null) {
            final loc = AppLocalizations.of(context)!;
            final message = resolveAuthErrorMessage(loc, state.errorMessage);
            if (message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            }
          }
        },
        child: const _AccountAccessLoginSheetBody(),
      );
    },
  );
}

class _AccountAccessLoginSheetBody extends StatelessWidget {
  const _AccountAccessLoginSheetBody();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final Size size = MediaQuery.sizeOf(context);
    final bool compact = size.width < 400;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 24,
          8,
          compact ? 16 : 24,
          16 + bottomInset,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ShellVisuals.authCardMaxWidth,
            maxHeight: size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: ShellVisuals.panel(
              context: context,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 16 : 28,
                vertical: compact ? 24 : 36,
              ),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (BuildContext context, AuthState state) {
                  if (state is AuthStateLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        loc.authScreenTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: compact ? 20 : 28),
                      LoginTrustBlock(loc: loc, compact: compact),
                      SizedBox(height: compact ? 24 : 32),
                      buildLoginGoogleCta(
                        loc: loc,
                        onPressed: () {
                          context.read<AuthCubit>().signInWithGoogle();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
