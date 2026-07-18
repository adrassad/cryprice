import 'package:cryprice_frontend/core/shell/shell_visuals.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/features/auth/presentation/widgets/login_google_cta.dart';
import 'package:cryprice_frontend/features/auth/presentation/widgets/login_trust_block.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Embedded gate for protected features (Portfolio, Alerts, Profile, etc.).
class AccountAccessRequiredPanel extends StatelessWidget {
  const AccountAccessRequiredPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final Size size = MediaQuery.sizeOf(context);
    final bool compact = size.width < 400;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ShellVisuals.authCardMaxWidth,
          ),
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
                    LoginTrustBlock(
                      loc: loc,
                      compact: compact,
                      title: loc.loginRequired,
                      body: loc.accountAccessRequiredBody,
                    ),
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
    );
  }
}
