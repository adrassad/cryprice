import 'package:crypto_tracker_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:crypto_tracker_app/features/auth/presentation/widgets/login_google_cta.dart';
import 'package:crypto_tracker_app/core/cubit/locale_cubit.dart';
import 'package:crypto_tracker_app/features/theme/cubit/theme_cubit.dart';
import 'package:crypto_tracker_app/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          loc.authScreenTitle,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              context.read<LocaleCubit>().toggleLocale();
            },
            tooltip: loc.switchLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
            tooltip: loc.switchTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (BuildContext context, AuthState state) {
              if (state is AuthStateLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      loc.authScreenSubtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    buildLoginGoogleCta(
                      loc: loc,
                      onPressed: () {
                        context.read<AuthCubit>().signInWithGoogle();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
