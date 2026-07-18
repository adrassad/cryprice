import 'package:cryprice_frontend/core/di/di.dart';
import 'package:cryprice_frontend/core/config/push_config.dart';
import 'package:cryprice_frontend/core/theme/cryprice_theme.dart';
import 'package:cryprice_frontend/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:cryprice_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:cryprice_frontend/features/auth/presentation/app_auth_gate.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/features/push_notifications/data/firebase/push_background_handler.dart';
import 'package:cryprice_frontend/features/push_notifications/presentation/push_notification_coordinator.dart';
import 'package:cryprice_frontend/core/cubit/locale_cubit.dart';
import 'package:cryprice_frontend/features/theme/cubit/theme_cubit.dart';
import 'package:cryprice_frontend/firebase_options.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (PushConfig.isFirebaseConfigured) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(pushBackgroundMessageHandler);
  }
  setupDependencies();
  if (PushConfig.isFirebaseConfigured) {
    await di<PushNotificationCoordinator>().initialize();
  }
  final authCubit = AuthCubit(
    di<AuthRepository>(),
    di<GoogleSignInGateway>(),
    pushCoordinator: di<PushNotificationCoordinator>(),
  );
  final redirectCompleted = await authCubit.completePendingGoogleRedirect();
  if (!redirectCompleted) {
    await authCubit.restore();
  }
  final localeCubit = LocaleCubit();
  await localeCubit.loadLocale();
  final themeCubit = di<ThemeCubit>();
  await themeCubit.loadTheme();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
        BlocProvider<ThemeCubit>.value(value: themeCubit),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              theme: CrypriceTheme.light(),
              darkTheme: CrypriceTheme.dark(),
              themeMode: themeMode,
              title: 'CryPrice',
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('ru')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const AppAuthGate(),
            );
          },
        );
      },
    );
  }
}
