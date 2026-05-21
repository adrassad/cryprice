import 'package:cryprice_frontend/core/shell/shell_visuals.dart';
import 'package:cryprice_frontend/core/shell/widgets/shell_left_command_menu.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/features/auth/presentation/widgets/login_google_cta.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Restricted unauthenticated screen: theme, locale, and Google sign-in only.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState prev, AuthState next) {
        if (next is! AuthStateUnauthenticated) {
          return false;
        }
        return next.errorMessage != null;
      },
      listener: (BuildContext context, AuthState state) {
        if (state is! AuthStateUnauthenticated) {
          return;
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (!mounted) {
          return;
        }
        context.read<AuthCubit>().signInWithGoogle();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;
    final Size size = MediaQuery.sizeOf(context);
    final double hPad = size.width < 400 ? 12 : 24;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          loc.authScreenTitle,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: size.width < 400 ? 18 : 20,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ShellVisuals.panel(
              context: context,
              padding: const EdgeInsets.all(6),
              child: const ShellLeftCommandMenu(
                layout: ShellCommandMenuLayout.horizontal,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: ShellVisuals.authCardMaxWidth,
                    ),
                    child: ShellVisuals.panel(
                      context: context,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width < 400 ? 16 : 28,
                        vertical: size.width < 400 ? 24 : 36,
                      ),
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (BuildContext context, AuthState state) {
                          if (state is AuthStateLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                loc.authScreenSubtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: size.width < 400 ? 14 : 15,
                                  height: 1.45,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: size.width < 400 ? 24 : 32),
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
          },
        ),
      ),
    );
  }
}
